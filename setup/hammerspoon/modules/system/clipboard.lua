-- Clipboard management
--   Manage clipboard history
--     Mainly based on dbmrq's clipboard.lua
--     (https://github.com/dbmrq/dotfiles/blob/master/home/.hammerspoon/clipboard.lua)
-----------------------------------------------
local m = {}
local settings = require("hs.settings")
local pasteboard = require("hs.pasteboard")
local pasteboardCounter = 0

m.config = {
  -- menubar priority (lower is lefter)
  menupriority = 1300,
  menubar = {
    historySize = 30,
    title = "✂",
    tooltip = "Clipboard",
    width = 40,
  },
  clipboardKey = 'jspoon_clipboard',
}

m.lastChange = pasteboard.changeCount()
m.history = settings.get(m.config.clipboardKey) or {}

-- Clear all items from pasteboard
m.clearAll = function()
  pasteboard.clearContents()
  m.history = {}
  settings.set(m.config.clipboardKey, m.history)
  pasteboardCounter = pasteboard.changeCount()
end

-- Clear last item from pasteboard
m.clearLastItem = function()
  table.remove(m.history, #m.history)
  settings.set(m.config.clipboardKey, m.history)
  pasteboardCounter = pasteboard.changeCount()
end

-- Add item from pasteboard
m.addToClipboard = function(item)
  -- limit quantity of entries
  while (#m.history >= m.config.menubar.historySize) do
    table.remove(m.history, 1)
  end
  table.insert(m.history, item)
  settings.set(m.config.clipboardKey, m.history)
end

m.copyOrPaste = function(string, key)
  if (key.alt == true) then
    hs.eventtap.keyStrokes(string)
  else
    pasteboard.setContents(string)
    last_change = pasteboard.changeCount()
  end
end

-- Populate the pasteboard menu
m.populateMenu = function(key)
  menuData = {}
  if (#m.history == 0) then
    table.insert(menuData, {title="None", disabled = true})
  else
    for k, v in pairs(m.history) do
      if string.len(v) > m.config.menubar.width then
        table.insert(menuData, 1,
          {title=string.sub(v, 0, m.config.menubar.width).."…",
          fn = function() m.copyOrPaste(v, key) end })
      else
        table.insert(menuData, 1,
          {title=v, fn = function() m.copyOrPaste(v, key) end })
      end
    end
  end
  table.insert(menuData, {title="-"})
  table.insert(menuData,
    {title="Clear All", fn = function() m.clearAll() end })
  return menuData
end

-- Store the string that was copied in the pasteboard
m.storeCopy = function()
  pasteboardCounter = pasteboard.changeCount()
  if pasteboardCounter > m.lastChange then
    currentContents = pasteboard.getContents()
    m.addToClipboard(currentContents)
    m.lastChange = pasteboardCounter
  end
end

-- Start the module
m.start = function()
  local copy
  m.menubar = hs.menubar.newWithPriority(m.config.menupriority)
  m.menubar:setTooltip(m.config.menubar.tooltip)
  m.menubar:setTitle(m.config.menubar.title)
  m.menubar:setMenu(m.populateMenu)

  copy = hs.hotkey.bind({"cmd"}, "c", function()
    copy:disable()
    hs.eventtap.keyStroke({"cmd"}, "c")
    copy:enable()
    hs.timer.doAfter(1, m.storeCopy)
  end)
end


-- Add triggers
-----------------------------------------------
m.triggers = {}


----------------------------------------------------------------------------
return m
