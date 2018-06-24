-- File and directory related utilities
--   Mostly thanks to @scottcs
--   <https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/utils/file.lua>
-----------------------------------------------
local lib = {}

local function handleExists(path)
  if not path then
    hs.logger.new('file utils','warning').w('Nil path')
    return false
  elseif not lib.exists(path) then
    hs.logger.new('file utils','warning').w(path .. ' doesn\'t exist')
    return false
  end
  return true
end


-- Return true if the file exists, else false
lib.exists = function(name)
  if not name then return false end
  local f = io.open(name,'r')
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

-- Takes a list of path parts, returns a string with the parts delimited by '/'
lib.toPath = function(...)
  return table.concat({...}, '/')
end

-- Splits a string by '/', returning the parent dir, filename (with extension),
-- and the extension alone.
lib.splitPath = function(file)
  local parent = file:match('(.+)/[^/]+$')
  if parent == nil then parent = '.' end
  local filename = file:match('/([^/]+)$')
  if filename == nil then filename = file end
  local ext = filename:match('%.([^.]+)$')
  return parent, filename, ext
end

-- Make a parent dir for a file. Does not error if it exists already.
lib.makeParentDir = function(path)
  local parent, _, _ = lib.splitPath(path)
  local ok, err = hs.fs.mkdir(parent)
  if ok == nil then
    if err == 'File exists' then
      ok = true
    end
  end
  return ok, err
end

-- Create a file (making parent directories if necessary).
lib.create = function(path)
  if lib.makeParentDir(path) then
    io.open(path, 'w'):close()
  end
end

-- Append a line of text to a file.
lib.append = function(file, text)
  if text == '' then return end

  local f = io.open(file, 'a')
  f:write(tostring(text) .. '\n')
  f:close()
end

-- Move a file. This calls task (so runs asynchronously), so calls onSuccess
-- and onFailure callback functions depending on the result. Set force to true
-- to overwrite.
lib.move = function(from, to, force, onSuccess, onFailure)
  force = force and '-f' or '-n'

  local function callback(exitCode, stdOut, stdErr)
    if exitCode == 0 then
      onSuccess(stdOut)
    else
      onFailure(stdErr)
    end
  end
  local _, filename, _ = lib.splitPath(from)
  local path = lib.toPath(to, filename)
  if not lib.exists(to) then
    lib.makeParentDir(path)
  end
  if(handleExists(path)) then print(path ..'exists') end
  if lib.exists(from) then
    hs.task.new('/bin/mv', callback, {force, from, to}):start()
  end
end

-- If the given file is older than the given time (in epoch seconds), return
-- true. This checks the inode change time, not the original file creation
-- time.
lib.isOlderThan = function(file, seconds)
  local age = os.time() - hs.fs.attributes(file, 'change')
  if age > seconds then return true end
  return false
end

-- Return the last modified time of a file in epoch seconds.
lib.lastModified = function(file)
  local when = os.time()
  if lib.exists(file) then when = hs.fs.attributes(file, 'modification') end
  return when
end

-- If any files are found in the given path, make a list of them and call the
-- given callback function with that list.
lib.runOnFiles = function(path, callback)
  if not handleExists(path) then
    return false
  else
    local iter, data = hs.fs.dir(path)
    local files = {}
    repeat
      local item = iter(data)
      if item ~= nil then table.insert(files, lib.toPath(path, item)) end
    until item == nil
    if #files > 0 then callback(files) end
  end
end

-- Unhide the extension on the given file, if it matches the extension given,
-- and that extension does not exist in the given hiddenExtensions table.
lib.unhideExtension = function(file, ext, hiddenExtensions)
  if ext == nil or hiddenExtensions == nil or hiddenExtensions[ext] == nil then
    local function unhide(exitCode, stdOut, stdErr)
      if exitCode == 0 and tonumber(stdOut) == 1 then
        hs.task.new('/usr/bin/SetFile', nil, {'-a', 'e', file}):start()
      end
    end
    hs.task.new('/usr/bin/GetFileInfo', unhide, {'-aE', file}):start()
  end
end


-- Returns true if the file has any default OS X color tag enabled.
lib.isColorTagged = function(file)
  local colors = {
    Red = true,
    Orange = true,
    Yellow = true,
    Green = true,
    Blue = true,
    Purple = true,
    Gray = true,
  }
  local tags = hs.fs.tagsGet(file)

  if tags ~= nil then
    for _,tag in ipairs(tags) do
      if colors[tag] then return true end
    end
  end
  return false
end

-- Simply set a single tag on a file
lib.setTag = function(file, tag) hs.fs.tagsAdd(file, {tag}) end

-- Return a string that ensures the given file ends with the given extension.
lib.withExtension = function(filePath, ext)
  local path = filePath
  local extMatch = '%.'..ext..'$'
  if not string.find(path, extMatch) then path = path..'.'..ext end
  return path
end

-- load a json file into a lua table and return it
lib.loadJSON = function(file)
  local data = nil
  local f = io.open(file, 'r')
  if f then
    local content = f:read('*all')
    f:close()
    if content then
      ok, data = pcall(function() return hs.json.decode(content) end)
      if not ok then
        hsm.log.e('loadJSON:', data)
        data = nil
      end
    end
  end
  return data
end

return lib
