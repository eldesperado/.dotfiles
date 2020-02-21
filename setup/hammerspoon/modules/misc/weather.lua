-- Weather
--   Current conditions for your location
--   Largely based on <https://github.com/skamsie/hs-weather>
-------------------------------------------------------------
local m = {}

local hsDir = hs.fs.currentDir()
local alert = require("hs.alert").show
local settings = require("hs.settings")
local iconsDir = (hsDir .. '/assets/icons/weather/')
local urlBase = 'https://query.yahooapis.com/v1/public/yql?q='
local query = 'select item.title, item.condition from weather.forecast where \
               woeid in (select woeid from geo.places(1) where text="'

m.config = {
  -- menubar priority (lower is lefter)
  menupriority = 100,
  cacheKey = "jspoon_weather",
  geolocation = false,
  location = "Ho Chi Minh, VN",
  refresh = 1800,
  units = "C"
}

m.cache = settings.get(m.config.cacheKey)

-- https://developer.yahoo.com/weather/archive.html#codes
-- icons by RNS, Freepik, Vectors Market, Yannick at http://www.flaticon.com
weatherSymbols = {
  ['load'] = (iconsDir .. 'loading.png'), -- loading
  [0] = (iconsDir .. 'tornado.png'),      -- tornado
  [1] = (iconsDir .. 'storm.png'),        -- tropical storm
  [2] = (iconsDir .. 'tornado.png'),      -- hurricane
  [3] = (iconsDir .. 'storm-5.png'),      -- severe thunderstorms
  [4] = (iconsDir .. 'storm-4.png'),      -- thunderstorms
  [5] = (iconsDir .. 'sleet.png'),        -- mixed rain and snow
  [6] = (iconsDir .. 'sleet.png'),        -- mixed rain and sleet
  [7] = (iconsDir .. 'sleet.png'),        -- mixed snow and sleet
  [8] = (iconsDir .. 'drizzle.png'),      -- freezing drizzle
  [9] = (iconsDir .. 'drizzle.png'),      -- drizzle
  [10] = (iconsDir .. 'drizzle.png'),     -- freezing rain
  [11] = (iconsDir .. 'rain-1.png'),      -- showers
  [12] = (iconsDir .. 'rain-1.png'),      -- showers
  [13] = (iconsDir .. 'snowflake.png'),   -- snow flurries
  [14] = (iconsDir .. 'snowflake.png'),   -- light snow showers
  [15] = (iconsDir .. 'snowflake.png'),   -- blowing snow
  [16] = (iconsDir .. 'snowflake.png'),   -- snow
  [17] = (iconsDir .. 'hail.png'),        -- hail
  [18] = (iconsDir .. 'sleet.png'),       -- sleet
  [19] = (iconsDir .. 'haze.png'),        -- dust
  [20] = (iconsDir .. 'mist.png'),        -- foggy
  [21] = (iconsDir .. 'haze.png'),        -- haze
  [22] = (iconsDir .. 'mist.png'),        -- smoky
  [23] = (iconsDir .. 'wind-1.png'),      -- blustery
  [24] = (iconsDir .. 'windy-1.png'),     -- windy
  [25] = (iconsDir .. 'cold.png'),        -- cold
  [26] = (iconsDir .. 'clouds.png'),      -- cloudy
  [27] = (iconsDir .. 'night.png'),       -- mostly cloudy (night)
  [28] = (iconsDir .. 'cloudy.png'),      -- mostly cloudy (day)
  [29] = (iconsDir .. 'cloudy-4.png'),    -- partly cloudy (night)
  [30] = (iconsDir .. 'cloudy-5.png'),    -- partly cloudy (day)
  [31] = (iconsDir .. 'moon-2.png'),      -- clear (night)
  [32] = (iconsDir .. 'sun-1.png'),       -- sunny
  [33] = (iconsDir .. 'night-2.png'),     -- fair (night)
  [34] = (iconsDir .. 'cloudy-1.png'),    -- fair (day)
  [35] = (iconsDir .. 'hail.png'),        -- mixed rain and hail
  [36] = (iconsDir .. 'temperature.png'), -- hot
  [37] = (iconsDir .. 'storm-4.png'),     -- isolated thunderstorms
  [38] = (iconsDir .. 'storm-2.png'),     -- scattered thunderstorms
  [39] = (iconsDir .. 'rain-3.png'),      -- scattered thunderstorms
  [40] = (iconsDir .. 'rain-6.png'),      -- scattered showers
  [41] = (iconsDir .. 'snowflake.png'),   -- heavy snow
  [42] = (iconsDir .. 'snowflake.png'),   -- scattered snow showers
  [43] = (iconsDir .. 'snowflake.png'),   -- heavy snow
  [44] = (iconsDir .. 'cloudy.png'),      -- party cloudy
  [45] = (iconsDir .. 'storm.png'),       -- thundershowers
  [46] = (iconsDir .. 'snowflake.png'),   -- snow showers
  [47] = (iconsDir .. 'lightning.png'),   -- isolated thundershowers
  [3200] = (iconsDir .. 'na.png')         -- not available
}

-- Set the weather icon, based on the code
m.setIcon = function(app, code)
  local iconPath = code and weatherSymbols[code] or weatherSymbols[3200]
  app:setIcon(hs.image.imageFromPath(iconPath):setSize({w=16,h=16}))
end

-- Set text in the menubar (usually the temp)
m.setTitle = function(app, unitSys, temp)
  if unitSys == 'C' then
    local tempCelsius = m.toCelsius(temp)
    local tempRounded = math.floor(tempCelsius * 10 + 0.5) / 10
    app:setTitle(tempRounded .. ' °C ')
  elseif unitSys == false then
    app:setTitle(temp)
  else
    app:setTitle(temp .. ' °F ')
  end
end

-- Encode the url
function urlencode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
      function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str
end

-- Convert farenheit to celsius
m.toCelsius = function(f)
  return (f - 32) * 5 / 9
end

-- Set the menubar UI
m.setUI = function(code, unitSys, temp, title, condition)
  m.setIcon(m.app, code)
  m.setTitle(m.app, unitSys, temp)
  m.app:setTooltip((title .. '\n' .. 'Condition: ' .. condition))
  settings.set(m.config.cacheKey, {
    code = code,
    unitSys = unitSys,
    temp = temp,
    title = title,
    condition = condition
  })

end

-- Get the weather forcast from the service
m.getFromService = function(location, unitSys)
  local weatherEndpoint = (
    urlBase .. urlencode(query .. location .. '")') .. '&format=json')
  m.setLoading(location)
  hs.http.asyncGet(weatherEndpoint, nil,
    function(code, body, table)
      if code ~= 200 then
        m.log.i('Could not get m. Response code: ' .. code)
      else
        m.log.i('Weather for ' .. location .. ': ' .. body)
        local response = hs.json.decode(body)
        if(response.query.results) then
          local temp = response.query.results.channel.item.condition.temp
          local code = tonumber(response.query.results.channel.item.condition.code)
          local condition = response.query.results.channel.item.condition.text
          local title = response.query.results.channel.item.title
          m.setUI(code, unitSys, temp, title, condition)
        else
          alert('There was a problem loading the weather for ' .. location, 3)
          -- get the cached version
          m.init()
        end
      end
    end)
end

-- Get weather for current location
-- Hammerspoon needs access to OS location services
m.getForCurrentLocation = function(unitSys)
  if hs.location.services_enabled() then
    hs.location.start()
    hs.timer.doAfter(1,
      function ()
        local loc = hs.location.get()
        hs.location.stop()
        m.getFromService('(' .. loc.latitude .. ',' .. loc.longitude .. ')', unitSys)
      end)
  else
    m.log.i('Location services disabled!')
  end
end

-- Get the latest weather
m.set = function(conf)
  if conf.geolocation then
    m.getForCurrentLocation(conf.units)
  else
    m.getFromService(conf.location, conf.units)
  end
end

-- Set the loading
m.setLoading = function(location)
  m.setIcon(m.app, "load")
  m.setTitle(m.app, false, "Loading...")
  m.app:setTooltip("Loading latest weather for " .. location)
end

-- Update the weather
m.update = function()
  m.set(m.config)
end

-- Show the cached weather if available
m.init = function()
  if(m.cache) then
    local ca = m.cache
    m.setUI(ca.code, ca.unitSys, ca.temp, ca.title, ca.condition)
  else
    m.set(m.config)
  end
end

-- -- Start the module
-- m.start = function(conf)
--   m.app = hs.menubar.newWithPriority(m.config.menupriority)
--   -- refresh on click
--   m.app:setClickCallback(m.update)
--   -- update weather every so often
--   w = hs.timer.doEvery(m.config.refresh, m.update)
--   -- set initial view
--   m.init()
-- end


-- -- Add triggers
-- -----------------------------------------------
-- m.triggers = {}
-- m.triggers["Weather Refresh"] = m.update


----------------------------------------------------------------------------
return m
