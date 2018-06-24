
-- Music
--   Music related stuff
-----------------------------------------------
local m = {}

-- Display the currently playing track in Spotify
m.spotifyWhatTrack = function()
  hs.spotify.displayCurrentTrack()
end


-- Add triggers
-----------------------------------------------
m.triggers = {}
m.triggers["Spotify What Track"] = m.spotifyWhatTrack

----------------------------------------------------------------------------
return m
