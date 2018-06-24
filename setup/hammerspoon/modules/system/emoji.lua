
-- System.Emoji
-- http://www.hammerspoon.org/Spoons/Emojis.html
-----------------------------------------------
local m = {}

jspoon.install:andUse( "Emojis",
   {
      hotkeys = { toggle = { {"cmd","alt","ctrl"}, "e" } }
   }
)


-- Add triggers
-----------------------------------------------
m.triggers = {}
-- m.triggers["Emojis Trigger"] = hs.caffeinate.lockScreen

----------------------------------------------------------------------------
return m
