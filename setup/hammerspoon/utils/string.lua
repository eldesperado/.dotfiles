-- String Utilities
--   Mostly thanks to @scottcs
--   <https://github.com/scottcs/dot_hammerspoon/blob/master/.hammerspoon/utils/string.lua>
-----------------------------------------------
local lib = {}

-- Split a string on pattern
-- @returns Table
lib.split = function(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local lastEnd = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    lastEnd = e+1
    s, e, cap = str:find(fpat, lastEnd)
  end
  if lastEnd <= #str then
    cap = str:sub(lastEnd)
    table.insert(t, cap)
  end
  return t
end

-- Trim whitespace from a string
lib.trim = function(str)
  return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'
end

-- Remove surrounding quotes from a string
-- @returns String
lib.unquote = function(str)
  local newStr = str:match("['\"](.-)['\"]")
  if newStr ~= nil then return newStr end
  return str
end

-- Does a string begins with another string?
-- @returns Boolean
lib.beginsWith = function(str, other)
   return string.sub(str, 1, string.len(other)) == other
end

-- Does a string ends with another string?
-- @returns Boolean
lib.endsWith = function(str, other)
   return string.sub(str, -string.len(other)) == other
end

-- Chop off the beginning of a string if it matches the other string
-- @returns String
lib.chopBeginning = function(str, beginning)
  if lib.beginsWith(str, beginning) then
    return string.sub(str, string.len(beginning)+1)
  end
  return str
end

-- Chop off the end of a string if it matches the other string
-- @returns String
lib.chopEnding = function(str, ending)
  if lib.endsWith(str, ending) then
    return string.sub(str, 0, -string.len(ending)-1)
  end
  return str
end

-- Pads str to length len with char from right
lib.lpad = function(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end

return lib
