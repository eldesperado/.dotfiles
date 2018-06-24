
-- Wifi
--   Notify on wifi changes
-----------------------------------------------
local m = {}
local alert = require('hs.alert').show
local wifi = require('hs.wifi')

-- keep track of the previously connected network
local lastNetwork = wifi.currentNetwork()
-- Open Hotspot Dashboard once connected to WiFi network at home.
local homeWifi = "Lau1A"
local loginSiteURL = "http://hotspot.in/login"
local defaultBrowser = "Google Chrome"

m.config = {
  icon = 'assets/icons/wifi/airport.png'
}

-- callback called when wifi network changes
local function ssidChangedCallback()
    local newNetwork = wifi.currentNetwork()

    -- send notification if we're on a different network than we were before
    if lastNetwork ~= newNetwork then
      hs.notify.new({
        title = 'Wi-Fi Status',
        subTitle = newNetwork and 'Network:' or 'Disconnected',
        informativeText = newNetwork,
        contentImage = m.config.icon,
        autoWithdraw = true,
        hasActionButton = false,
      }):send()

      lastNetwork = newNetwork
    end
end

-- Get the wifi status
m.status = function()
  output = io.popen("networksetup -getairportpower en0", "r")
  result = output:read()
  return result:find(": On") and "on" or "off"
end

-- Toggle the wifi on and off
m.toggle = function()
  if m.status() == "on" then
    alert("Wi-Fi: Off")
    os.execute("networksetup -setairportpower en0 off")
  else
    alert("Wi-Fi: On")
    os.execute("networksetup -setairportpower en0 on")
  end
end

m.loginWifi = function ()
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
end

m.reconnectWifi = function()
  local ssid = hs.wifi.currentNetwork()
  if not ssid then
      return
  end

  hs.alert.show("Reconnecting to: " .. ssid)
  hs.execute("networksetup -setairportpower en0 off")
  hs.execute("networksetup -setairportpower en0 on")
end

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

m.ping = function()
  hs.network.ping.ping("8.8.8.8", 1, 0.01, 1.0, "any", pingResult)
end

-- Start the module
m.start = function()
  m.watcher = wifi.watcher.new(ssidChangedCallback)
  m.watcher:start()
end

-- Stop the module
m.stop = function()
  m.watcher:stop()
  m.watcher = nil
end

-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["WiFi Toggle"] = m.toggle
m.triggers["WiFi Reconnect"] = m.reconnectWifi
m.triggers["Ping"] = m.ping

----------------------------------------------------------------------------
return m
