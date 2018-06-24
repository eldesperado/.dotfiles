-- AnyComplete
--   Use google's suggestion API to help type stuff fast. Thanks to @andrewhampton
--   <https://github.com/andrewhampton/dotfiles/blob/master/hammerspoon/.hammerspoon/anycomplete.lua>
-----------------------------------------------
local m = {}
local GOOGLE_ENDPOINT = 'https://suggestqueries.google.com/complete/search?client=firefox&q=%s'

m.config = {
  ui = {
    dark = true,
    fgColour = { red = .4, green = .5, blue = .6, alpha = 1 },
    subTextColor = { red = .3, green = .4, blue = .5, alpha = 1 },
  }
}

-- Create the chooser instance
m.complete = function()
  local current = hs.application.frontmostApplication()

  local chooser = hs.chooser.new(function(choosen)
      current:activate()
      hs.eventtap.keyStrokes(choosen.text)
  end)

  chooser:queryChangedCallback(function(string)
      local query = hs.http.encodeForQuery(string)

      hs.http.asyncGet(string.format(GOOGLE_ENDPOINT, query), nil, function(status, data)
          if not data then return end

          local ok, results = pcall(function() return hs.json.decode(data) end)
          if not ok then return end

          choices = hs.fnutils.imap(results[2], function(result)
              return {
                  ["text"] = result,
              }
          end)

          chooser:choices(choices)
      end)
  end)

  m.setUIAndShow(chooser)

end

-- Set the chooser UI to light/dark and display it
m.setUIAndShow = function(chooserInstance)
  chooserInstance:bgDark(m.config.ui.dark)
  chooserInstance:fgColor(m.config.ui.fgColour)
  chooserInstance:subTextColor(m.config.ui.subTextColor)
  chooserInstance:searchSubText(false)
  chooserInstance:show()
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Anycomplete"] = m.complete

return m
