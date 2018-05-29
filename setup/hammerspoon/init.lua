mash = {
  position = {"ctrl", "alt", "cmd"},
  focus    = {"ctrl", "alt"},
  utils    = {"ctrl", "alt", "cmd"},
  apps     = {"cmd", "ctrl", "alt", "shift"}
}

require('setup')

require('apps')
require('position')
require('focus')
require('spaces')
require('wifi')
require('others')

hs.alert.show("Hammerspoon, at your service!")