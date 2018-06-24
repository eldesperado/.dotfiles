
-- Path watching
-----------------------------------------------

local watch = {}

function watch.reloadConfig(files)
  hs.reload()
end


function watch.configPath(configPath)
  hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/" .. configPath, watch.reloadConfig):start()
end

----------------------------------------------------------------------------
return watch
