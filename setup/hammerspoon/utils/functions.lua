
-- Helper functions
-----------------------------------------------
local fn = {}
local strUtil = require('utils.string')

-- Deep merge a table
-----------------------------------------------
function fn.merge(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      fn.merge(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

-- Deep merge a table without overriding the first
--------------------------------------------------
function fn.mergeNoOveride(t1, t2)
  local merged = {}
  for k, v in pairs(t1) do
    merged[k] = v
  end
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(merged[k] or false) == "table") then
      merged[k] = fn.mergeNoOveride(merged[k], t2[k])
    else
      merged[k] = v
    end
  end
  return merged
end

-- Get the length of a table
-----------------------------------------------
function fn.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- Overide config with ./config.lua if available
-----------------------------------------------
function fn.configOveride(defaults)
  local config = {}
  local configFile = 'config'
  if(hs.fs.fileUTI(configFile .. '.lua')) then
    config = require(configFile)
  end
  return fn.merge(defaults, config)
end

-- Print a block in the console
-----------------------------------------------
function fn.printBlock(str)
  local strLen = string.len(str) + 2
  local hr = strUtil.lpad('', strLen, '-')
  print(hr)
  print(" " .. str)
  print(hr .. "\n")
end

-- Inspect a variable
-----------------------------------------------
function fn.inspect(v)
  print(hs.inspect(v))
end

-- Find in a table
-----------------------------------------------
function fn.tablefind(tab, el)
  for index, value in pairs(tab) do
    if value == el then
      return index
    end
  end
end

-- Add key(s) to an array
-----------------------------------------------
function fn.arrayAdd(arr, add)
  if type(add) == "string" then add = { add } end
  if type(add) == "table" then
    for _, v in pairs(add) do
      table.insert(arr, v)
    end
  end
  return arr
end

-- Remove key(s) from an array
-----------------------------------------------
function fn.arrayRemove(arr, remove)
  if type(remove) == "string" then remove = { remove } end
  if type(remove) == "table" then
    for _, v in pairs(remove) do
      table.remove( arr, fn.tablefind(arr, v) )
    end
  end
  return arr
end

----------------------------------------------------------------------------
return fn
