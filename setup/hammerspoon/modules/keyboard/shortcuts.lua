
-- Shortcuts
-- Display keyboard shortcuts in modal window
-----------------------------------------------
local m = {}
m.helpstr = ''
m.table = {}

m.config = {
  helpCharPad = 30,
  fadeOut = .5,
  fadeIn = .3,
  keyStrings = {
    ["left"] = "←",
    ["right"] = "→",
    ["up"] = "↑",
    ["down"] = "↓",
    ["cmd"] = "⌘",
    ["alt"] = "⌥",
    ["option"] = "⌥",
    ["opt"] = "⌥",
    ["ctrl"] = "⌃",
    ["shift"] = "⇧",
    ["space"] = "␣",
    ["escape"] = "⎋",
  },
}

-- Close the shortcut modal window
m.close = function()
  m.helpOverlayBG:hide(m.config.fadeOut)
  m.helpOverlayX:hide(m.config.fadeOut/2)
  m.helpOverlay:hide(m.config.fadeOut/2)
  m.removeEscKeyBinding()
end

-- Calculate font size that will fit inside the modal window
m.calcFontSize = function(windowHeight, min, max)
  local size = windowHeight / jspoon.fn.tablelength(m.table) * .45
  if(size < min) then size = min or 10 end
  if(size > max) then size = max or 30 end
  return size
end

-- Calculate the required width of the modal window
m.calcWindowWidth = function(fontSize)
  return fontSize * m.config.helpCharPad * 1.1
end

-- Replace key string with symbol
m.makeShortcutReplacements = function(str)
  if(type(str) == "string" and m.config.keyStrings[string.lower(str)]) then
    str = m.config.keyStrings[string.lower(str)]
  elseif(jspoon.utils.keys.modifiers[str]) then
    str = jspoon.utils.keys.modifiers[str]
  end
  if (type(str) == "table") then
    local newStr1 = ""
    local newStr2
    for key, value in pairs(str) do
      if (type(value) == "string") then
        newStr2 = m.makeShortcutReplacements(value)
        newStr1 = newStr1 .. newStr2
      end
    end
    str = newStr1
  end
  return str
end

-- Create keyboard shortcut helper string
m.createShortcutString = function(keysTable)
  local keys = {}
  for key, value in pairs(keysTable) do
    if (key <= 2) then
      keys[key] = m.makeShortcutReplacements(value)
    end
  end
  return table.concat(keys, " + ")
end

-- Build the modal overlay
m.showHelpOverlay = function(message)
  if m.helpOverlay then
    m.helpOverlayX:delete()
    m.helpOverlayBG:delete()
    m.helpOverlay:delete()
    if m.helpOverlayTimer then
      m.helpOverlayTimer:stop()
    end
  end

  local scr = hs.screen.primaryScreen():currentMode()
  local windowHeight = scr.h - 400
  local fontSize = m.calcFontSize(windowHeight, 12, 24)
  local windowWidth = m.calcWindowWidth(fontSize)
  local ov = {
    p = 30,
    w = windowWidth,
    h = windowHeight,
    x = scr.w / 2 - windowWidth / 2,
    y = scr.h / 2 - windowHeight / 2 - 50,
  }

  m.helpOverlayX = hs.drawing.text(hs.geometry.rect(ov.x + ov.w, ov.y, 50, 50), "×")
  m.helpOverlayBG = hs.drawing.rectangle(hs.geometry.rect(ov.x, ov.y, ov.w + ov.p * 2, ov.h + ov.p * 2))
  m.helpOverlay = hs.drawing.text(hs.geometry.rect(ov.x + ov.p, ov.y + ov.p, ov.w, ov.h), message)
  local font = hs.styledtext.convertFont({
    name = 'Fira Code',
    size = fontSize
  }, 0)
  local textStyle = {
    font = font,
    paragraphStyle = {
      alignment = "left",
      lineSpacing = fontSize * .6,
      tabStops = {{
        location = fontSize * .1 * 180,
        tabStopType = 'right'
      },
      {
        location = fontSize * .1 * 245,
        tabStopType = 'right'
      }}
    },
    shadow = {
      offset = {h = -1, w = 1},
      blurRadius = 3
    }
  }
  m.helpOverlayBG:setFillColor({["red"]=0,["blue"]=0,["green"]=0,["alpha"]=0.8}):setFill(true):show()
  m.helpOverlay:setStyledText(hs.styledtext.ansi(message, textStyle))
  m.helpOverlayX:setTextSize(50)
  m.helpOverlay:bringToFront(true)
  m.helpOverlay:show(m.config.fadeIn)
  m.helpOverlayX:bringToFront(true):show(m.config.fadeIn)
  m.helpOverlayX:setClickCallback(m.close)
  m.helpOverlay:setClickCallback(m.close)
end

-- (re)create the modal window text
m.updateHelpString = function()
  local scTable = jspoon.utils.keys.shortcuts
  m.table = {}
  table.insert(m.table, "\t KEYBOARD\tSHORTCUTS")
  for key, value in pairs(scTable) do
    local scTitle = key
    local scKeys = m.createShortcutString(value)
    if value[3] == false then
      m.log.i(key .. ' is excluded from help overlay')
    else
      table.insert(m.table, string.format("\t%s\t%s", scTitle, scKeys ))
    end
  end
  table.sort(m.table)
  m.helpstr = table.concat(m.table,'\n')
end

-- Display the shortcut modal window
m.display = function()
  m.updateHelpString()
  m.showHelpOverlay(m.helpstr)
  m.addEscKeyBinding()
end

-- Bind the escape key to enable closing the modal window
m.addEscKeyBinding = function()
  m.escKey = hs.hotkey.bind('', 'escape', nil, m.close)
end

-- Unbind the escape key
m.removeEscKeyBinding = function()
  if(m.escKey ~= nil) then
    m.escKey:delete()
  end
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Keyboard Help"] = m.display

----------------------------------------------------------------------------
return m
