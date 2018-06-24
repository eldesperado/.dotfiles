-- Global Namespace
-----------------------------------------------
jspoon = {}
jspoon.utils = {}
jspoon.loadedModules = {}

jspoon.fn = require("utils.functions")

-- Add break in console
jspoon.fn.printBlock("(Re)loading jspoon")

-- Load initial utils
jspoon.utils.file = require("utils.file")
jspoon.utils.spoons = require("utils.spoons")

-- Map spoons installer to shorter path
jspoon.install = jspoon.utils.spoons.install

-- Config
---- Load default first, overrides second
-----------------------------------------------
local config = {}
config.bindings = require('bindings')
config.global = {}

-- File paths
config.global.paths = {}
config.global.paths.base   = os.getenv('HOME')
config.global.paths.tmp    = os.getenv('TMPDIR')
config.global.paths.cloud  = jspoon.utils.file.toPath(config.global.paths.base, 'Dropbox')
config.global.paths.dump   = jspoon.utils.file.toPath(config.global.paths.cloud, 'Actions/Dump')
config.global.paths.hs     = jspoon.utils.file.toPath(config.global.paths.base, '.hammerspoon')
config.global.paths.assets = jspoon.utils.file.toPath(config.global.paths.hs,   'assets')

-- Default log level
config.global.loglevel = 'warning'

-- Overide config with local file
jspoon.fn.configOveride(config)

-- Set global config
jspoon.config = config.global


-- Logging and custom utilities
-----------------------------------------------
jspoon.utils.alert = require("utils.alert")
jspoon.utils.keys = require("utils.keys")
jspoon.utils.load = require("utils.load")
jspoon.utils.misc = require("utils.misc")
jspoon.utils.watch = require("utils.watch")

-- Modules to load
-----------------------------------------------
local modules = jspoon.utils.load.allFromDirectory('')

-- Include/Exclude extra modules
jspoon.fn.arrayAdd(modules, config.modulesInclude)
jspoon.fn.arrayRemove(modules, config.modulesExclude)

-- Adjust some modules default logging
-----------------------------------------------
require("hs.hotkey").setLogLevel("warning")

-- Optional local-only file
-----------------------------------------------
local localOnly=loadfile(hs.configdir .. "/init-local.lua")
if localOnly then
   localOnly()
end

-- Load, configure, and start each module
-----------------------------------------------
jspoon.loadedModules = jspoon.utils.load.all(modules)
jspoon.utils.load.applyAllConfig(jspoon.loadedModules)
jspoon.utils.load.startAll(jspoon.loadedModules)
jspoon.utils.keys.getTriggersFromModules(jspoon.loadedModules)
jspoon.utils.keys.setModifiers(config.bindings.keys.modifiers)
jspoon.utils.keys.bindAll(config.bindings.keys.triggers)
jspoon.utils.keys.activate()

-- Watch config for file changes
-----------------------------------------------
jspoon.utils.watch.configPath("bindings.lua")
jspoon.utils.watch.configPath("config.lua")
jspoon.utils.watch.configPath("init.lua")
jspoon.utils.watch.configPath("init-local.lua")
jspoon.utils.watch.configPath("modules/")
jspoon.utils.watch.configPath("utils/")

-- Let us know we've got the latest and greatest
------------------------------------------------
jspoon.utils.alert.onScreen("Hammerspoon, at your service!")
jspoon.fn.printBlock("jspoon Loaded")
