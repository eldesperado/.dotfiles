-- 

-- Open Hotspot Dashboard once connected to WiFi network at home.
local homeWifi = "Lau1A"
local loginSiteURL = "http://hotspot.in/login"
local defaultBrowser = "Google Chrome"

hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  -- short-circuit if disconnecting
  if not currentWifi then return end

  local note = hs.notify.new({
    title="Connected to WiFi", 
    informativeText="Now connected to " .. currentWifi
  }):send()

  --Dismiss notification in 3 seconds
  --Notification does not auto-withdraw if Hammerspoon is set to use "Alerts"
  --in System Preferences > Notifications
  hs.timer.doAfter(3, function ()
    note:withdraw()
    note = nil
  end)

  if currentWifi == homeWifi then
    -- Allowance for internet connectivity delays.
    hs.timer.doAfter(3, function ()
        hs.network.ping.ping(
            "8.8.8.8", 1, 0.01, 1.0, "any", 
            function(object, message, seqnum, error)
                if message == "didFinish" then
                    avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
                    if avg == 0.0 then
                        -- @todo: Explore possibilities of using `hs.webview`
                        hs.execute("open " .. loginSiteURL)
      
                        --Make notification clickable. Browser window will be focused on click:
                        hs.notify.new(function () 
                            hs.application.launchOrFocus(defaultBrowser)
                        end, {title="No network. Open Wifi Login page!"}):send()
                    end
                end
            end
        )
    end)
  end
end):start()

-- Reconnect the current wifi SSID
hs.hotkey.bind(
    mash.utils,
    "r",
    function()
        local ssid = hs.wifi.currentNetwork()
        if not ssid then
            return
        end

        hs.alert.show("Reconnecting to: " .. ssid)
        hs.execute("networksetup -setairportpower en0 off")
        hs.execute("networksetup -setairportpower en0 on")
    end
)

-- Ping Google's DNS to retrieve the status of my current network
hs.hotkey.bind(
    mash.utils,
    "p", 
    function()
        hs.network.ping.ping("8.8.8.8", 1, 0.01, 1.0, "any", pingResult)
    end
)
function pingResult(object, message, seqnum, error)
    if message == "didFinish" then
        avg = tonumber(string.match(object:summary(), '/(%d+.%d+)/'))
        if avg == 0.0 then
            hs.alert.show("No network")
        elseif avg < 200.0 then
            hs.alert.show("Network good (" .. avg .. "ms)")
        elseif avg < 500.0 then
            hs.alert.show("Network poor (" .. avg .. "ms)")
        else
            hs.alert.show("Network bad (" .. avg .. "ms)")
        end
    end
end

-- Monitor internet status with a menubar item
local wifiMenu = hs.menubar.new():setTitle("?")
wifiWatcher = hs.network.reachability.forAddress("8.8.8.8"):setCallback(
    function(self, flags)

        if (flags & hs.network.reachability.flags.reachable) > 0 then
            -- Internet is reachable
            wifiMenu:setTitle("😍")
        else
            -- Interner is not reachable
            wifiMenu:setTitle("❗")
        end
    end
):start()