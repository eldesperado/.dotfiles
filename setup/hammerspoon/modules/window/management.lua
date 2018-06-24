
-- Window management
-----------------------------------------------
local m = {}
local hswindow = hs.window
local alert = require('hs.alert').show
local isRectsApproxMatch = jspoon.utils.misc.isRectsApproxMatch
local lastWindowLocation = {
  center = {},
  max = {},
}

-----------------------------------------------
-- Default Settings
-----------------------------------------------
m.config = {
  animationDuration = .2,
  grid = {
    MARGINX = 0,
    MARGINY = 0,
    GRIDWIDTH = 12,
    GRIDHEIGHT = 4,
  }
}


-----------------------------------------------
-- Resize currently focused window
-----------------------------------------------

m.resize = function(w,h,x,y)
  local win = hswindow.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  f.x = max.x + (max.w * x)
  f.y = max.y + (max.h * y)
  f.w = max.w * w
  f.h = max.h * h
  win:setFrame(f)
end


-----------------------------------------------
-- Toggle align center currently focused window
-----------------------------------------------

m.toggleCenter = function()
  local win = hswindow.focusedWindow()
  local winFrame = win:frame()
  local winThis = win:id()
  local screen = win:screen()
  local size = win:size()
  local max = screen:frame()
  local centerFrame = win:frame()

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  centerFrame.x = 0 + (max.w / 2) - (size.w / 2)
  centerFrame.y = 0 + (max.h / 2) - (size.h / 2)

  if isRectsApproxMatch(winFrame, centerFrame) then
    if lastWindowLocation.center[winThis] then
      win:setFrame(lastWindowLocation.center[winThis])
      lastWindowLocation.center[winThis] = nil
    end
  else
    lastWindowLocation.center[winThis] = winFrame
    win:setFrame(centerFrame)
  end
end


-----------------------------------------------
-- Increment resize currently focused window
-----------------------------------------------

m.increment = function(increment, increase)

  local win = hswindow.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  if not increase then increment = 0 - increment end

  f.x = f.x - (increment / 2)
  f.y = f.y - (increment / 2)
  f.w = f.w + increment
  f.h = f.h + increment

  -- make sure we dont go off the screen
  if f.x < 0 then f.x = 0 end

  win:setFrame(f,0)
end



-----------------------------------------------
-- Toggle fullscreen on the current window
-----------------------------------------------

m.toggleFullscreen = function()
  local win = hswindow.focusedWindow()

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  win:toggleFullScreen()
end


-----------------------------------------------
-- Toggle maximize on the current window
-----------------------------------------------

m.toggleMaximize = function()
  local win = hswindow.focusedWindow()
  local winFrame = win:frame()
  local winThis = win:id()
  local screenFrame = win:screen():frame()

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  if isRectsApproxMatch(winFrame, screenFrame) then
    if lastWindowLocation.max[winThis] then
      win:setFrame(lastWindowLocation.max[winThis])
      lastWindowLocation.max[winThis] = nil
    end
  else
    lastWindowLocation.max[winThis] = winFrame
    win:maximize()
  end
end


-----------------------------------------------
-- Move current window to another screen
-----------------------------------------------

m.moveToScreen = function(screen)
  local win = hswindow.focusedWindow()
  local screens = 0
  for _ in pairs(hs.screen.allScreens()) do screens = screens + 1 end
  hswindow.animationDuration = 0

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  if screens >= 2 then
    if screen == 'prev' then
      local prevScreen = win:screen():previous()
      win:moveToScreen(prevScreen)
      alert("Previous Monitor")
    elseif screen == 'next' then
      local nextScreen = win:screen():next()
      win:moveToScreen(nextScreen)
      alert("Next Monitor")
    end
  else
    alert("There's only one monitor...")
  end

  -- reset animation duration
  hswindow.animationDuration = animationDuration

end

-----------------------------------------------
-- Push window
-----------------------------------------------

m.pushWindow = function(direction)
  local win = hs.window.focusedWindow()
  local winGrid = hs.grid.get(win)
  local result

  if not win then
    m.alertCannotManipulateWindow()
    return
  end

  if(direction == "up") then
    if(winGrid.y == 0) then
      -- make window shorter if we are at the top
      result = hs.grid.resizeWindowShorter(win)
    else
      result = hs.grid.pushWindowUp(win)
    end
  elseif(direction == "right") then
    if(winGrid.x == (m.config.grid.GRIDWIDTH - winGrid.w)) then
      -- make window thinner if we are at the right
      result = hs.grid.resizeWindowThinner(win)
    end
    result = hs.grid.pushWindowRight(win)
  elseif(direction == "down") then
    if(winGrid.y == (m.config.grid.GRIDHEIGHT - winGrid.h)) then
      -- make window shorter if we are at the top
      result = hs.grid.resizeWindowShorter(win)
    end
    result = hs.grid.pushWindowDown(win)
  elseif(direction == "left") then
    if(winGrid.x == 0) then
      -- make window thinner if we are at the left
      result = hs.grid.resizeWindowThinner(win)
    else
      result = hs.grid.pushWindowLeft(win)
    end
  end
end

-----------------------------------------------
-- Check can move window
-----------------------------------------------

m.alertCannotManipulateWindow = function()
  alert("Can't move window")
end


-----------------------------------------------
-- Start
-----------------------------------------------
function m.start()
  -- Set the default animation duration
  hswindow.animationDuration = m.config.animationDuration

  hs.grid.MARGINX    = m.config.grid.MARGINX
  hs.grid.MARGINY    = m.config.grid.MARGINY
  hs.grid.GRIDWIDTH  = m.config.grid.GRIDWIDTH
  hs.grid.GRIDHEIGHT = m.config.grid.GRIDHEIGHT

end


-- Add triggers
-----------------------------------------------
m.triggers = {}

-- Center current window
m.triggers["Window Toggle Center"] = m.toggleCenter

-- Resize current window to maximise or fullscreen
m.triggers["Window Toggle Maximise"] = m.toggleMaximize
m.triggers["Window Toggle Fullscreen"] = m.toggleFullscreen

-- Resize current window to half of the screen using arrow keys
m.triggers["Window Half Left"]   = function() m.resize(.5, 1, 0, 0) end
m.triggers["Window Half Right"]  = function() m.resize(.5, 1,.5, 0) end
m.triggers["Window Half Top"]    = function() m.resize( 1,.5, 0, 0) end
m.triggers["Window Half Bottom"] = function() m.resize( 1,.5, 0,.5) end

-- Move current window to quarter of the screen using u,i,j,k
m.triggers["Window Quarter Top Left"]     = function() m.resize(.5,.5, 0, 0) end
m.triggers["Window Quarter Top Right"]    = function() m.resize(.5,.5,.5, 0) end
m.triggers["Window Quarter Bottom Right"] = function() m.resize(.5,.5, 0,.5) end
m.triggers["Window Quarter Bottom Left"]  = function() m.resize(.5,.5,.5,.5) end

-- Make current window larger/smaller
m.triggers["Window Larger"]  = function() m.increment(20, true) end
m.triggers["Window Smaller"] = function() m.increment(20, false) end

-- Move current window to next/prev display
m.triggers["Window Previous Screen"] = function() m.moveToScreen('prev') end
m.triggers["Window Next Screen"]     = function() m.moveToScreen('next') end

-- Shift window on grid
m.triggers["Window Push Left"]  = function() m.pushWindow('left') end
m.triggers["Window Push Right"] = function() m.pushWindow('right') end
m.triggers["Window Push Up"]    = function() m.pushWindow('up') end
m.triggers["Window Push Down"]  = function() m.pushWindow('down') end

-- Resize window on grid
m.triggers["Window Resize Thinner"] = function() hs.grid.resizeWindowThinner(hs.window.focusedWindow()) end
m.triggers["Window Resize Shorter"] = function() hs.grid.resizeWindowShorter(hs.window.focusedWindow()) end
m.triggers["Window Resize Taller"]  = function() hs.grid.resizeWindowTaller(hs.window.focusedWindow()) end
m.triggers["Window Resize Wider"]   = function() hs.grid.resizeWindowWider(hs.window.focusedWindow()) end

-- Interactive grid
m.triggers["Window Show Grid"] = function() hs.grid.show(nil, true) end
m.triggers["Window Hide Grid"] = hs.grid.hide


----------------------------------------------------------------------------
return m
