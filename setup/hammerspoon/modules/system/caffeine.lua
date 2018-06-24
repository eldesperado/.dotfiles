-- Caffeine
--   Keep computer awake
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show

m.config = {
  -- menubar priority (lower is lefter)
  menupriority = 1200,
  isActiveKey = 'jspoon_caffeine',
  message = {
    caffinated = 'Coffee is good',
    decaffinated = 'Sleep is good'
  },
  assets = {
    caffinated = "assets/icons/caffeine/on.pdf",
    decaffinated = "assets/icons/caffeine/off.pdf",
  }
}

-- Get the state key (used for getting the menubar icon and message)
m.getStateKey = function(state) return state and 'caffinated' or 'decaffinated' end

-- Set the caffinated state and persist it
m.setState = function(state)
  local stateKey = m.getStateKey(state)
  -- Set menubar icon
  m.menubar:setIcon(m.config.assets[stateKey])
  -- Log state to console
  m.log.i('Setting to ' .. stateKey)
  -- Alert message to user
  alert(m.config.message[stateKey])
  -- Set the caffeinate state
  hs.caffeinate.set("displayIdle", state)
  -- Persist the state across sessions
  hs.settings.set(m.config.isActiveKey, state)
end

-- Toggle the state
m.toggleState = function()
  m.setState(hs.caffeinate.toggle("displayIdle"))
end

-- Handle clicks on the menubar icon
m.handleClick = function()
  m.toggleState()
end

-- Start the module
m.start = function()
  m.menubar = hs.menubar.newWithPriority(m.config.menupriority)
  -- Get the persistant state
  local persistedState = hs.settings.get(m.config.isActiveKey)
  if m.menubar then
    m.log.i('Persisted state was ' .. m.getStateKey(persistedState))
    -- Set the click handler
    m.menubar:setClickCallback(m.handleClick)
    -- Set the state
    m.setState(persistedState)
  end
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Caffeine Toggle"] = m.handleClick


----------------------------------------------------------------------------
return m
