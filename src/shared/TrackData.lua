-- TrackData.lua
-- Track definitions: waypoints, spawn positions, and metadata

local TrackData = {}

-- Each track has:
--   name        display name
--   thumbnail   asset ID string for UI
--   laps        override lap count (nil = use GameConfig default)
--   spawns      array of CFrame-style {x, y, z, rx, ry, rz} spawn positions
--   waypoints   ordered array of {x, y, z} checkpoint positions

TrackData.Tracks = {
	{
		id         = "desert_circuit",
		name       = "Desert Circuit",
		thumbnail  = "rbxassetid://0",
		laps       = 3,
		spawns = {
			{ x =   0, y = 5, z =   0, ry =   0 },
			{ x =   6, y = 5, z =   0, ry =   0 },
			{ x = -6, y = 5, z =   0, ry =   0 },
			{ x =  12, y = 5, z =   0, ry =   0 },
		},
		waypoints = {
			{ x =   0, y = 5, z =  -80 },
			{ x =  80, y = 5, z = -160 },
			{ x = 160, y = 5, z =  -80 },
			{ x = 160, y = 5, z =   80 },
			{ x =  80, y = 5, z =  160 },
			{ x =   0, y = 5, z =   80 },
		},
	},
	{
		id         = "mountain_pass",
		name       = "Mountain Pass",
		thumbnail  = "rbxassetid://0",
		laps       = 2,
		spawns = {
			{ x =   0, y = 20, z =   0, ry =  90 },
			{ x =   6, y = 20, z =   0, ry =  90 },
			{ x =  -6, y = 20, z =   0, ry =  90 },
			{ x =  12, y = 20, z =   0, ry =  90 },
		},
		waypoints = {
			{ x = 100, y = 25, z =   0 },
			{ x = 200, y = 40, z = -50 },
			{ x = 250, y = 60, z = -150 },
			{ x = 200, y = 40, z = -250 },
			{ x = 100, y = 25, z = -300 },
			{ x =   0, y = 20, z = -250 },
		},
	},
	{
		id         = "city_sprint",
		name       = "City Sprint",
		thumbnail  = "rbxassetid://0",
		laps       = 1,
		spawns = {
			{ x =   0, y = 3, z =   0, ry = 180 },
			{ x =   6, y = 3, z =   0, ry = 180 },
			{ x =  -6, y = 3, z =   0, ry = 180 },
			{ x =  12, y = 3, z =   0, ry = 180 },
		},
		waypoints = {
			{ x =   0, y = 3, z = -100 },
			{ x =  50, y = 3, z = -200 },
			{ x = 150, y = 3, z = -200 },
			{ x = 200, y = 3, z = -100 },
			{ x = 150, y = 3, z =    0 },
			{ x =  50, y = 3, z =    0 },
		},
	},
}

-- Returns a track table by id, or nil
function TrackData.GetTrack(id)
	for _, track in ipairs(TrackData.Tracks) do
		if track.id == id then
			return track
		end
	end
	return nil
end

return TrackData
