
-- Misc system related tasks
-----------------------------------------------
local m = {}
local alert = require('hs.alert')

-- Show the date and time
-----------------------------------------------
m.showDateAndTime = function()
  alert.show(os.date("It's %R on %B %e, %G"))
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Show Date And Time"] = m.showDateAndTime

----------------------------------------------------------------------------
return m
