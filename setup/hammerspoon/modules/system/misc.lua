
-- Misc system related tasks
-----------------------------------------------
local m = {}
local alert = require('hs.alert')

-- Show the date and time
-----------------------------------------------
m.showDateAndTime = function()
  alert.show(os.date("It's %R on %B %e, %G"))
end

-- Reload config
m.reloadHammer = function()
  hs.reload()
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Show Date And Time"] = m.showDateAndTime
m.triggers["Reload Hammerspoon"] = m.reloadHammer

----------------------------------------------------------------------------
return m
