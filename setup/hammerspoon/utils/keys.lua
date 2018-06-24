
-- Key binding and utilities
-----------------------------------------------
local keys = {}
local alert = jspoon.utils.alert
local log = hs.logger.new('Keys', "debug").i
local hotkey = require "hs.hotkey"

keys.modifiers = {}
keys.triggers = {}
keys.bound = {}
keys.shortcuts = {}


-- Modifiers
-----------------------------------------------

function keys.getModifier(modifierName)
  if(keys.modifiers[modifierName]) then
    return keys.modifiers[modifierName]
  else
    log(modifierName .. " doesnt exist")
  end
end


function keys.setModifier(modifierName, modifier)
  keys.modifiers[modifierName] = modifier
end


function keys.setModifiers(modifierTable)
  for modifierName, modifier in pairs(modifierTable) do
    if(keys.modifiers[modifierName]) then
      log(modifierName .. " already exists, not binding")
    else
      keys.setModifier(modifierName, modifier);
    end
  end
end


-- Triggers
-----------------------------------------------

function keys.setTrigger(triggerName, triggerFn)
  keys.triggers[triggerName] = triggerFn
end


function keys.setTriggers(triggersTable)
  for triggerName, triggerBinding in pairs(triggersTable) do
    if(keys.triggers[triggerName]) then
      log(triggerName .. " already exists, not binding")
    else
      keys.setTrigger(triggerName, triggerBinding);
    end
  end
end


function keys.getTriggersFromModules(modules)
  for moduleName, moduleValues in pairs(modules) do
    if(moduleValues.triggers) then
      keys.setTriggers(moduleValues.triggers)
    end
  end
end



-- Bindings
-----------------------------------------------

function keys.bindKey(keyName, keyBinding, fn)
  if(keys.getModifier(keyBinding[1])) then
    keys.bound[keyName] = hotkey.new(keys.getModifier(keyBinding[1]), keyBinding[2], nil, fn)
    keys.shortcuts[keyName] = keyBinding
  end
end


function keys.bindKeyByName(keyName, keyBinding)
  if(keys.triggers[keyName] == nil) then
    log(keyName .. " doesnt exist")
  else
    keys.bindKey(keyName, keyBinding, keys.triggers[keyName])
  end
end


function keys.bindAll(keysTable)
  for keyName, keyBinding in pairs(keysTable) do
    keys.bindKeyByName(keyName, keyBinding)
  end
end


function keys.activate()
  for index, key in pairs(keys.bound) do
    key:enable()
  end
  log("Keys activated")
end


function keys.deactivate()
  for index, key in pairs(keys.bound) do
    key:disable()
  end
  log("Keys deactivated")
end


----------------------------------------------------------------------------
return keys
