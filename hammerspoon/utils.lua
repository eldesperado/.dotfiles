local utils = {}

-- Escapes a string for the shell
utils.shellescape = function (s)
  if s == "" then
    return "''"
  end

  return s:gsub("([^A-Za-z0-9_%-.,:/@\n])", "\\%1"):gsub("(\n)", "'\n'")
end

-- Joins a table of arguments into a command line string, escaping
-- each element for the shell
utils.shelljoin = function (...)
  local args = {...}
  local s = ""

  for _, arg in ipairs(args) do
    if s ~= "" then
      s = s .. " "
    end
    if type(arg) == "table" then
      s = s .. utils.shelljoin(table.unpack(arg))
    else
      s = s .. utils.shellescape(tostring(arg))
    end
  end

  return s
end

return utils