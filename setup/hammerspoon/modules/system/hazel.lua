-- module: Hazel - automatic file system actions
-- (Inspired by the Hazel app, by noodlesoft)
--

-- TODO: if file exists in destination, rename + 1?
-- TODO: move directories, exclude based on pattern

local m = {}

local globals = jspoon.config
local ufile = require('utils.file')
local ufunctions = require('utils.functions')

-- time constants
local TIME = {}
TIME.MINUTE = 60
TIME.HOUR = TIME.MINUTE * 60
TIME.DAY = TIME.HOUR * 24
TIME.WEEK = TIME.DAY * 7

-- directory watchers
local watch = {}
local timer = nil

local paths = globals.paths
paths.desktop = ufile.toPath(globals.paths.base, 'Desktop')
paths.desktopArchive = ufile.toPath(paths.desktop, 'Archive')
paths.downloads = ufile.toPath(globals.paths.base, 'Downloads')
paths.downloadsArchive = ufile.toPath(paths.downloads, 'Archive')

m.config = {
  -- when unhiding extensions, ignore these
  hiddenExtensions = {
    app = true,
  },
  -- seconds to wait after file changed, before running rules
  waitTime = 5,
  -- interval to run check paths timer
  timerInterval = TIME.HOUR,
  -- paths to watch
  watchers = {
    -- clean up desktop every week
    desktop = {
      dir = paths.desktop,
      enabled = true,
      oldFiles = {
        move = paths.desktopArchive,
        time = TIME.WEEK,
      },
    },
    -- clean up downloads every week
    downloads = {
      dir = paths.downloads,
      enabled = false,
      oldFiles = {
        move = paths.downloadsArchive,
        time = TIME.WEEK,
      },
    },
    -- sort out downloads archive
    downloadsArchive = {
      dir = paths.downloadsArchive,
      enabled = false,
      moveFiles = {
        apps = {
          dir = ufile.toPath(paths.downloadsArchive, 'Applications'),
          ext = { app = true },
        },
        audio = {
          dir = ufile.toPath(paths.downloadsArchive, 'Audio'),
          ext = { mp3 = true, wav = true },
        },
        databases = {
          dir = ufile.toPath(paths.downloadsArchive, 'Databases'),
          ext = { sql = true },
        },
        diskImages = {
          dir = ufile.toPath(paths.downloadsArchive, 'Disk Images'),
          ext = { dmg = true },
        },
        images = {
          dir = ufile.toPath(paths.downloadsArchive, 'Images'),
          ext = { gif = true, jpg = true, jpeg = true, png = true, svg = true },
        },
        pdfs = {
          dir = ufile.toPath(paths.downloadsArchive, 'PDFs'),
          ext = 'pdf',
        },
        sheets = {
          dir = ufile.toPath(paths.downloadsArchive, 'Spreadsheets'),
          ext = { csv = true, xls = true, xlsx = true },
        },
        text = {
          dir = ufile.toPath(paths.downloadsArchive, 'Text'),
          ext = { doc = true, docx = true, md = true, odt = true },
        },
        video = {
          dir = ufile.toPath(paths.downloadsArchive, 'Videos'),
          ext = { mov = true, mp4 = true },
        },
        zips = {
          dir = ufile.toPath(paths.downloadsArchive, 'ZIP'),
          ext = { gz = true, zip = true },
        },
      },
    },
    -- move stuff in dump to desktop after 6 weeks
    dump = {
      dir = paths.dump,
      enabled = false,
      oldFiles = {
        time = TIME.WEEK * 6,
        move = paths.desktop,
        tag = 'Needs Attention',
        notify = ' has been ignored for 6 weeks!',
      },
    },
  },
  defaultConfig = {
    dir = false,
    enabled = true,
    excludeColourTagged = true,
    moveFiles = false,
    oldFiles = {
      time = TIME.DAY,
      move = false,
      tag = false,
      notify = false,
    },
    unhideExtension = false,
  },
}

-- catch if you try to move to the same directory
local function isMovingToSameDirectory(key, file, toPath)
  local parent, filename, ext = ufile.splitPath(file)
  local to = toPath .. '/' .. filename
  if file == to then
    m.log.e('[' .. key .. "] Trying to move file to same directory:\n  " .. file .. " to\n  " .. to)
    -- stop the watcher so we prevent an infinite loop
    m.stopWatcher(key)
    return true
  end
  return false
end

-- Check watcher is enabled and dir is set and exists
local function canRunWatcherModule(config)
  return
    config.enabled and
    config.dir and
    ufile.exists(config.dir)
end

-- move a given file to toPath, overwriting the destination, with logging
local function moveFileToPath(key, file, toPath)
  local function onFileMoveSuccess(_)
    m.log.i('Moved '..file..' to '..toPath)
  end

  local function onFileMoveFailure(stdErr)
    m.log.e('Error moving '..file..' to '..toPath..': '..stdErr)
  end
  -- TODO: also dont override file by default.
  -- eg if you had an download.pdf file in downloads, everytime you
  -- downloaded another of the same name it would overwrite it
  if not isMovingToSameDirectory(key, file, toPath) then
    ufile.move(file, toPath, false, onFileMoveSuccess, onFileMoveFailure)
  end
end

-- a filter that returns true if the given file should be ignored
local function ignored(file)
  if file == nil then return true end

  local _, filename, _ = ufile.splitPath(file)

  -- ignore dotfiles
  if filename:match('^%.') then return true end

  return false
end

----------------------------------------------------------------------
----------------------------------------------------------------------
-- NOTE: Be careful not to modify a file each time it is watched.
-- This will cause the watch* function to be re-run every m.config.waitTime
-- seconds, since the file gets modified each time, which triggers the
-- watch* function again.
----------------------------------------------------------------------
----------------------------------------------------------------------

-- callback for watching a given directory
-- process_cb is given a single argument that is a table consisting of:
--   {file: the full file path, parent: the file's parent directory full path,
--   filename: the basename of the file with extension, ext: the extension}
local function watchPath(path, files, process_cb)
  -- m.log.d('watchPath', path, hs.inspect(files))

  -- wait a little while before doing anything, to give files a chance to
  -- settle down.
  hs.timer.doAfter(m.config.waitTime, function()
    -- loop through the files and call the process_cb function on any that are
    -- not ignored, still exist, and are found in the given path.
    for _,file in ipairs(files) do
      if not ignored(file) and ufile.exists(file) then
        local parent, filename, ext = ufile.splitPath(file)
        local data = {file=file, parent=parent, filename=filename, ext=ext}
        if parent == path then process_cb(data) end
      end
    end
  end):start()
end

-- callback for watching a directory
local function watchDirectory(key, cfg, files)
  local config = ufunctions.mergeNoOveride(m.config.defaultConfig, cfg)

  -- Check watcher is enabled and dir is set and exists
  if not canRunWatcherModule(config) then return false end

  -- m.log.w('Watch: ' .. key)

  watchPath(config.dir, files, function(data)
    -- m.log.w('Watch: ' .. key ..' processing', hs.inspect(data))

    -- skip if files are colour tagged
    if config.excludeColourTagged and ufile.isColorTagged(data.file) then return false end

    -- unhide extensions for files written here
    if config.unhideExtension then
      ufile.unhideExtension(data.file, data.ext, config.hiddenExtensions)
    end

    -- move files
    if config.moveFiles then
      for k,_ in pairs(config.moveFiles) do
        if(data.ext) then
          local value = config.moveFiles[k]
          local ext = string.lower(data.ext)
          if ext == value.ext or value.ext[ext] then
            moveFileToPath(key, data.file, value.dir)
          end
        end
      end
    end

    -- for files that are older than
    if config.oldFiles.move or config.oldFiles.tag then

      if ufile.isOlderThan(data.file, config.oldFiles.time) then
        -- tag the file
        if config.oldFiles.tag then
          ufile.setTag(data.file, config.oldFiles.tag)
        end

        -- move file
        if config.oldFiles.move then
          moveFileToPath(key, data.file, config.oldFiles.move)
        end
        -- send a notification
        if config.oldFiles.notify then
          alert(data.filename .. config.oldFiles.notify)
        end
      end
    end

  end)
end

local function checkPaths()
  for key,_ in pairs(m.config.watchers) do
    local value = m.config.watchers[key]
    if canRunWatcherModule(value) then
      ufile.runOnFiles( value.dir, function(files) watchDirectory(key, value, files) end)
    else
      m.log.d('Could\'t check "' .. key .. '" watcher. Either module is not enabled or the '.. value.dir ..' directory doesn\'t exist.')
    end
  end
end

-- stop a watcher
m.stopWatcher = function(key, clear)
  if watch[key] then
    watch[key]:stop()
    if clear then
      watch[key] = nil
    end
  else
    m.log.e('Could\'t stop ' .. key .. ' watcher, doesn\'t exist.')
  end
end

-- start the module
m.start = function()
  -- run checkPaths every {timerInterval}
  timer = hs.timer.new(m.config.timerInterval, checkPaths)
  timer:start()

  for key,_ in pairs(m.config.watchers) do
    local value = m.config.watchers[key]
    if ufile.exists(value.dir) then
      watch[key] = hs.pathwatcher.new(value.dir, function(files) watchDirectory(key, value, files) end)
      watch[key]:start()
    end
  end
  checkPaths()
end

m.stop = function()
  if timer then timer:stop() end
  timer = nil

  for key,_ in pairs(watch) do stopWatcher(key, true) end
end

return m
