
-- Toggle an application:
-----------------------------------------------
local m = {}

m.toggleApp = function(appName)
    local app = hs.appfinder.appFromName(appName)
    if not app or app:isHidden() then
      hs.application.launchOrFocus(appName)
    elseif hs.application.frontmostApplication() ~= app then
      app:activate()
    else
      app:hide()
    end
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Google Chrome Toggle"] = function() m.toggleApp("Google Chrome") end
m.triggers["Xcode Toggle"] = function() m.toggleApp("Xcode") end
m.triggers["Zalo Toggle"] = function() m.toggleApp("Zalo") end
m.triggers["Reveal Toggle"] = function() m.toggleApp("Reveal") end
m.triggers["iTerm Toggle"] = function() m.toggleApp("iTerm") end
m.triggers["Visual Studio Code Toggle"] = function() m.toggleApp("Visual Studio Code") end
m.triggers["SourceTree Toggle"] = function() m.toggleApp("SourceTree") end
m.triggers["Dash Toggle"] = function() m.toggleApp("Dash") end
m.triggers["Pulse Secure Toggle"] = function() m.toggleApp("Pulse Secure") end
m.triggers["Spotify Toggle"] = function() m.toggleApp("Spotify") end
m.triggers["Microsoft Outlook Toggle"] = function() m.toggleApp("Microsoft Outlook") end
m.triggers["Finder Toggle"] = function() m.toggleApp("Finder") end

----------------------------------------------------------------------------
return m
