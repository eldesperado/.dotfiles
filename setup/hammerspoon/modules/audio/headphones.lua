
-- Headphones
--   Mute when headphones unplugged
-----------------------------------------------
local m = {}
local alert = require('hs.alert')

m.config = {
  message = 'Headphone jack changed, muting.'
}

-- Mute on headphone jack plugged/unplugged
m.audioCallback = function(uid, eventName, eventScope, channelIdx)
  if eventName == 'jack' then
    alert.show(m.config.message)
    hs.audiodevice.defaultOutputDevice():setVolume(0)
  end
end

m.start = function()
  local defaultDevice = hs.audiodevice.defaultOutputDevice()
  defaultDevice:watcherCallback(m.audioCallback);
  defaultDevice:watcherStart();
end

----------------------------------------------------------------------------
return m
