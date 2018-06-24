-- Nightshift
--   Auto shift the temp of your monitor
--   Default settings: 2800K + inverted from 21 to 7,
--   with a long transition duration (19->23 and 5->9)
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show

m.config = {
  -- menubar priority (lower is lefter)
  menupriority = 1100,
  isActiveKey = 'jspoon_nightshift',
  colorTemp = 2800,
  nightStart = '21:00',
  nightEnd = '7:00',
  transition = '4h',
  invertAtNight = false,
  -- Disable nightshift/inversion for: Photos and screensaver/login window
  windowfilterDisable = {
    Photos = { focused = true },
    loginwindow = { visible = true, allowRoles = '*' }
  },
  dayColorTemp = 6500,
  menubar = {
    tooltip = "Nightshift",
  },
  message = {
    on = 'Nightshift enabled',
    off = 'Nightshift disabled'
  },
  icon = {
    on = "assets/icons/nightshift/on.png",
    off = "assets/icons/nightshift/off.png",
  }
}

-- Disable by default
m.enabled = false

-- Get the state key, used in config for messages and menubar icons
m.getStateKey = function(state) return state and 'on' or 'off' end

-- Sets and persists the state
m.setState = function(state)
    local stateKey = m.getStateKey(state)
    -- Set menubar icon
    m.menubar:setIcon(hs.image.imageFromPath(m.config.icon[stateKey]):setSize({w=16,h=16}))
    -- Log state to console
    m.log.i('Setting to ' .. stateKey)
    -- Alert message to user
    alert(m.config.message[stateKey])
    -- Set the state
    if(state) then
      hs.redshift.start(
        m.config.colorTemp,
        m.config.nightStart,
        m.config.nightEnd,
        m.config.transition,
        m.config.invertAtNight,
        hs.window.filter.new(m.config.windowfilterDisable, 'wf-redshift'),
        m.config.dayColorTemp
      )
    else
      hs.redshift.stop()
    end
    m.enabled = state
    -- Persist the state across sessions
    hs.settings.set(m.config.isActiveKey, state)
end

-- Helper: toggle nightshift state
m.toggleState = function()
  if(m.enabled) then
    m.setState(false)
  else
    m.setState(true)
  end
end

-- Helper: toggle inversion of colours
m.toggleInvert = hs.redshift.toggleInvert

-- Handlers
m.handleClick = m.toggleState

-- Start nightshift
m.start = function()
  -- Setup menubar app
  m.menubar = hs.menubar.newWithPriority(m.config.menupriority)
  -- Get the persistant state
  local persistedState = hs.settings.get(m.config.isActiveKey)
  if m.menubar then
    m.log.i('Persisted state was ' .. m.getStateKey(persistedState))
    -- Set the tooltip
    m.menubar:setTooltip(m.config.menubar.tooltip)
    -- Set the click handler
    m.menubar:setClickCallback(m.handleClick)
    -- Set the state
    m.setState(persistedState)
  end

end

-- Triggers
-----------
m.triggers = {}
m.triggers["Nightshift Invert"] = m.toggleInvert
m.triggers["Nightshift Toggle"] = m.toggleState

--------
return m
