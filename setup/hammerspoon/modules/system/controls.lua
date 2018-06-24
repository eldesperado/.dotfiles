
-- System
--   Mac system related functions
-----------------------------------------------
local m = {}


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["System Lock"] = hs.caffeinate.lockScreen
m.triggers["System Sleep"] = hs.caffeinate.systemSleep
m.triggers["System Screensaver"] = hs.caffeinate.startScreensaver

----------------------------------------------------------------------------
return m
