
-- Playground
--   A place for trying stuff out
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show

-- Toggle an application:
-- if frontmost: hide it. if not: activate/launch it
-----------------------------------------------

function m.testSomething()
  alert(hs.host.operatingSystemVersionString())
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Test Something"] = m.testSomething

----------------------------------------------------------------------------
return m
