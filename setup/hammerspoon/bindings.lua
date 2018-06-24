
-- Default bindings
--   Overide: config.lua.example --> config.lua
-----------------------------------------------
local bindings = {}
local keys = {}


-- Key Bindings
-----------------------------------------------
keys.modifiers = {
  ['position'] = {"ctrl", "alt", "cmd"},
  ['focus']    = {"ctrl", "alt"},
  ['utils']    = {"ctrl", "alt", "shift"},
  ['apps']     = {"cmd", "ctrl", "alt", "shift"}
}

-- Set up hotkeys
-----------------------------------------------
keys.triggers = {

  -- Apps
  -----------------------------------------------
  ["Autohide Toggle"] = { "focus", "F13" },

  ["Google Chrome Toggle"] = { "apps", "1" },
  ["Xcode Toggle"] = { "apps", "2" },
  ["Zalo Toggle"] = { "apps", "3" },
  ["Reveal Toggle"] = { "apps", "4" },
  ["iTerm Toggle"] = { "apps", "i" },
  ["Visual Studio Code Toggle"] = { "apps", "c" },
  ["SourceTree Toggle"] = { "apps", "s" },
  ["Dash Toggle"] = { "apps", "d" },
  ["Pulse Secure Toggle"] = { "apps", "p" },
  ["Spotify Toggle"] = { "apps", "m" },
  ["Microsoft Outlook Toggle"] = { "apps", "e" },
  ["Finder Toggle"] = { "apps", "f" },

  -- Audio
  -----------------------------------------------
  ["Spotify What Track"] = { "utils", "w" },

  -- Keyboard
  -----------------------------------------------
  ["Keyboard Help"] = { "utils", "/", false },

  -- Misc
  -----------------------------------------------
  ["Test Something"] = { "utils", "t", false },
  ["Anycomplete"] = { "utils", "a" },
  ["Defeat Paste Blocking"] = { "utils", "v" },
  ["Scratchpad Toggle"] = { "utils", "Space" },

  -- Hammerspoon
  ["Hammerspoon Console"] = { "utils", "\\" },
  ["Hammerspoon Reload"] = { "utils", "R", false },
  ["Hammerspoon Docs"] = { "utils", "`" },
  ["Reload Hammerspoon"] = { "utils", "-" },

  -- System
  -----------------------------------------------
  -- ["Bluetooth Toggle"] = { "mash", "E" },
  ["Caffeine Toggle"] = { "utils", "," },

  ["System Lock"] = { "utils", "l" },
  ["System Sleep"] = { "utils", "s" },

  -- Network
  ["WiFi Toggle"] = { "utils", "F5" },
  ["WiFi Reconnect"] = { "utils", "r" },
  ["Ping"] = { "utils", "p" },

  ["Window Hints"] = { "utils", "." },

  -- Window management Hotkeys
  -----------------------------------------------

  -- Center current window
  ["Window Toggle Center"] = { "position", "c" },

  -- Resize current window to maximise or fullscreen
  ["Window Toggle Maximise"] = { "position", "." },
  ["Window Toggle Fullscreen"] = { "position", "f" },

  -- Resize current window to half of the screen
  ["Window Half Left"]   = { "position", "h" },
  ["Window Half Right"]  = { "position", "k" },
  ["Window Half Top"]    = { "position", "u" },
  ["Window Half Bottom"] = { "position", "j" },

  -- Push current window around the grid
  ["Window Push Left"]  = { "position", "Left" },
  ["Window Push Right"] = { "position", "Right" },
  ["Window Push Up"]    = { "position", "Up" },
  ["Window Push Down"]  = { "position", "Down" },

  -- Resize current window to grid
  ["Window Resize Thinner"] = { "position", "[" },
  ["Window Resize Wider"]   = { "position", "]" },
  ["Window Resize Taller"]  = { "position", "=" },
  ["Window Resize Shorter"] = { "position", "'" },

  -- Move current window to next/prev display
  ["Window Next Screen"] = { "position", "0" },

  -- Show interactive grid
  ["Window Show Grid"] = { "position", "§" },

}

----------------------------------------------------------------------------
bindings.keys = keys

return bindings
