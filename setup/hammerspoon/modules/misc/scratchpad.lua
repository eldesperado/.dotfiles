-- Scratchpad
--   Quick place to jot down info. I use this for short-term todos and reminders, mostly. Thanks to @scottcs
--   <https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/modules/scratchpad.lua>
-----------------------------------------------

local m = {}

local ufile = require('utils.file')
local alert = require('hs.alert')
local config = jspoon.config

local lastApp = nil
local chooser = nil
local menu = nil
local visible = false

m.config = {
  -- menubar priority (lower is lefter)
  menupriority = 1400,
  width = 60,
  file = ufile.toPath(config.paths.base, 'scratchpad.md'),
  fileTmp = ufile.toPath(config.paths.tmp, 'scratchpad.md'),
  menubar = {
    icon = 'assets/icons/scratchpad/icon.pdf',
    tooltip = 'Scratchpad',
  },
}

-- COMMANDS
local commands = {
  {
    ['text'] = 'Append...',
    ['subText'] = 'Append to Scratchpad',
    ['command'] = 'append',
  },
  {
    ['text'] = 'Edit',
    ['subText'] = 'Edit Scratchpad',
    ['command'] = 'edit',
  },
}
--------------------

-- refocus on the app that was focused before the chooser was invoked
local function refocus()
  if lastApp ~= nil then
    lastApp:activate()
    lastApp = nil
  end
end

-- This resets the choices to the command table, and has the desired side
-- effect of resetting the highlighted choice as well.
local function resetChoices()
  chooser:rows(#commands)
  -- add commands
  local choices = {}
  for _, command in ipairs(commands) do
    choices[#choices+1] = command
  end
  chooser:choices(choices)
end

-- remove a specific line from the scratchpad file
local function removeLine(line)
  -- write out the scratchpad file to a temp file, line by line, skipping the
  -- line we want to remove, then move the temp file to overwrite the
  -- scratchpad file. this makes things slightly more atomic, to try to avoid
  -- data corruption.
  -- local tmpfile = ufile.toPath(hsm.config.paths.tmp, 'scratchpad.md')
  local tmpfile = m.config.fileTmp
  local f = io.open(tmpfile, 'w+')
  for oldline in io.lines(m.config.file) do
    if oldline ~= line then f:write(oldline..'\n') end
  end
  f:close()

  ufile.move(tmpfile, m.config.file, true,
    function(output) end,
    function(err) alert.show('Error updating Scratchpad file: ' .. err) end
  )
end

-- callback when a chooser choice is made, which in this case will only be one
-- of the commands.
local function choiceCallback(choice)
  refocus()
  visible = false

  if choice.command == 'append' then
    -- append the query string to the scratchpad file
    ufile.append(m.config.file, chooser:query())
  elseif choice.command == 'edit' then
    -- open the scratchpad file in an editor
    m.edit()
  end

  -- set the chooser back to the default state
  resetChoices()
  chooser:query('')
end

-- callback when the menubar icon is clicked.
local function menuClickCallback(mods)
  local list = {}

  if mods.shift or mods.ctrl then
    -- edit the scratchpad
    m.edit()
  else
    -- show the contents of the scratchpad as a menu
    if ufile.exists(m.config.file) then
      for line in io.lines(m.config.file) do
        -- if a line is clicked, copy it to the clipboard
        -- if a line is ctrl-clicked, remove that line from the scratchpad file
        local function menuItemClickCallback(itemmods)
          if itemmods.ctrl then
            removeLine(line)
          else
            hs.pasteboard.setContents(line)
          end
        end
        list[#list+1] = {title=tostring(line), fn=menuItemClickCallback}
      end
    end
  end
  list[#list+1] = { title = "-" }
  list[#list+1] = { title="Add Item", fn=m.toggle }
  list[#list+1] = { title="Edit Scratchpad", fn=m.edit }
  return list
end

-- open the scratchpad file in the default .md editor
function m.edit()
  if not ufile.exists(m.config.file) then
    ufile.create(m.config.file)
  end
  local task = hs.task.new('/usr/bin/open', nil, {'-t', m.config.file})
  task:start()
end

-- toggle chooser visibility
function m.toggle()
  if chooser ~= nil then
    if visible then
      m.hide()
    else
      m.show()
    end
  end
end

-- show the chooser
function m.show()
  if chooser ~= nil then
    lastApp = hs.application.frontmostApplication()
    chooser:show()
    visible = true
  end
end

-- hide the chooser
function m.hide()
  if chooser ~= nil then
    -- hide calls choiceCallback
    chooser:hide()
  end
end

function m.start()
  menu = hs.menubar.newWithPriority(m.config.menupriority)
  -- menu:setTitle(m.config.menubar.icon)
  menu:setIcon(hs.image.imageFromPath(m.config.menubar.icon):setSize({w=16,h=16}))
  menu:setTooltip(m.config.menubar.tooltip)
  menu:setMenu(menuClickCallback)

  chooser = hs.chooser.new(choiceCallback)
  chooser:width(m.config.width)
  -- disable built-in search
  chooser:queryChangedCallback(function() end)

  resetChoices()
end

function m.stop()
  if chooser then chooser:delete() end
  if menu then menu:delete() end

  chooser = nil
  menu = nil
  lastApp = nil
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Scratchpad Toggle"] = m.toggle

return m
