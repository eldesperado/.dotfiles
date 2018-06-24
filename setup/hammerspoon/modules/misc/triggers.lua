-- Triggers
--   For triggers with no home
-----------------------------------------------
local m = {}

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Window Hints"] = hs.hints.windowHints
m.triggers["Hammerspoon Console"] = hs.toggleConsole
m.triggers["Hammerspoon Reload"] = hs.reload
m.triggers["Hammerspoon Docs"] = hs.hsdocs

m.triggers["Defeat Paste Blocking"] = function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end

----------------------------------------------------------------------------
return m
