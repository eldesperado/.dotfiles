
-- Spoons
-- Adapted from: <https://github.com/zzamboni/dot-hammerspoon/blob/master/init.lua>
-----------------------------------------------

local spoons = {}

-- Check if hs.spoons is available
if hs.spoons == nil then
   hs.alert("Old version of hammerspoon detected. Please upgrade, to enable the use of Spoons.")
end

-- Try to load SpoonInstall, then check if it loaded
local function tryLoadSpoonInstall ()
  hs.loadSpoon("SpoonInstall")
end

if pcall(tryLoadSpoonInstall) then

  -- I prefer sync notifications, makes them easier to read
  spoon.SpoonInstall.use_syncinstall = true

  -- This is just a shortcut to make the declarations below look more readable,
  -- i.e. `spoons.install:andUse()` instead of `spoon.SpoonInstall:andUse()`
  spoons.install=spoon.SpoonInstall

else
  hs.alert("Please manually install the 'SpoonInstall' spoon to enable auto install of some modules.", 10)

  -- add dummy andUse so a warning is shown in the console if a spoon is loaded
  spoons.install = {}
  spoons.install.andUse = function(_, name)
    jspoon.fn.printBlock(
      "Could not load '" .. name .. "' Spoon. Please manually install the SpoonInstall spoon first."
    )
  end
end

----------------------------------------------------------------------------
return spoons
