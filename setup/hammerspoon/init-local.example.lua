print("==== LOCAL ONLY: BEGIN ============================")

local hyper = {"cmd","alt","ctrl"}

----------------------------------------------------------------------

-- http://www.hammerspoon.org/Spoons/ToggleSkypeMute.html
jspoon.install:andUse("ToggleSkypeMute",
  {
    disable = true,
    hotkeys = {
      toggle_skype = { hyper, "z" }
    }
  }
)


print("==== LOCAL ONLY: END ==============================")
