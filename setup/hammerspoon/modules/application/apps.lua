
-- Toggle an application:
-----------------------------------------------
local m = {}

local mouse = require('utils.mouse')

m.toggleApp = function(appName)
    local app = hs.appfinder.appFromName(appName)
    if not app or app:isHidden() then
      hs.application.launchOrFocus(appName)
    elseif hs.application.frontmostApplication() ~= app then
      app:activate()
      mouse:centerCursorOnFocusedWindow()
    else
      app:hide()
    end
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Brave Toggle"] = function() m.toggleApp("Microsoft Edge") end
m.triggers["Xcode Toggle"] = function() m.toggleApp("Xcode") end
m.triggers["Zalo Toggle"] = function() m.toggleApp("Zalo") end
m.triggers["Reveal Toggle"] = function() m.toggleApp("Todoist") end
m.triggers["iTerm Toggle"] = function() m.toggleApp("iTerm") end
m.triggers["Visual Studio Code Toggle"] = function() m.toggleApp("Visual Studio Code") end
m.triggers["SourceTree Toggle"] = function() m.toggleApp("SourceTree") end
m.triggers["Dash Toggle"] = function() m.toggleApp("Dash") end
m.triggers["Pulse Secure Toggle"] = function() m.toggleApp("Pulse Secure") end
m.triggers["Spotify Toggle"] = function() m.toggleApp("Spotify") end
m.triggers["Microsoft Outlook Toggle"] = function() m.toggleApp("Outlook") end
m.triggers["Finder Toggle"] = function() m.toggleApp("Finder") end
m.triggers["Simulator Toggle"] = function() m.toggleApp("Simulator") end
m.triggers["Anki"] = function() m.toggleApp("Anki") end
m.triggers["Microsoft Note"] = function() m.toggleApp("Microsoft Note") end

----------------------------------------------------------------------------
return m
