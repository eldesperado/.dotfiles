
-- Autohide applications:
-- If focused show it, if not hide it.
-----------------------------------------------
local m = {}

local hotkey = require "hs.hotkey"
local alert = require "hs.alert"
local isActive = true

m.config = {
  isActiveKey = 'jspoon_autohide',
  applications = {
    "Calendar",
    "Finder",
  },
  message = {
    enabled = 'Application Auto Hide Enabled',
    disabled = 'Application Auto Hide Disabled',
  },
}

-- Watch autohide applications
m.watcher = hs.application.watcher.new(function(name, event, app)
  if isActive == false then
    return
  end

  for _, value in pairs(m.config.applications) do
    if name == value and event == hs.application.watcher.deactivated then
      app:hide()
    end
  end
end)

-- Set the autohide state
m.setState = function(state)
  local stateString = state and 'enabled' or 'disabled'
  alert.show(m.config.message[stateString])
  -- save the state
  isActive = state
  -- Persist the state across sessions
  hs.settings.set(m.config.isActiveKey, state)
end

-- Toggle the autohide state
m.toggle = function()
  m.setState(not isActive)
end

-- Start the autohide module
m.start = function()
  local persistedState = hs.settings.get(m.config.isActiveKey)
  if persistedState ~= nil then
    isActive = persistedState
  end
  m.watcher:start()
  m.setState(isActive)
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Autohide Toggle"] = m.toggle

----------------------------------------------------------------------------
return m
