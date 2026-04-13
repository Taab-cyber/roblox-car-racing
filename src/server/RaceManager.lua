-- RaceManager.lua
-- Handles race logic: spawning, lap tracking, finish detection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local TrackData = require(Shared:WaitForChild("TrackData"))

local RaceManager = {}

-- Callbacks set by GameManager
RaceManager.OnLapComplete = nil
RaceManager.OnRaceEnd = nil

-- Active race state
local activeRace = nil  -- { trackId, players, startTime, lapCounts, checkpoints }

local function getSpawnCFrame(spawn)
	return CFrame.new(spawn.x, spawn.y, spawn.z) * CFrame.Angles(0, math.rad(spawn.ry or 0), 0)
end

local function spawnPlayer(player, spawnData)
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = getSpawnCFrame(spawnData)
	end
end

-- Start a new race; returns the track table
function RaceManager.StartRace(trackId, players)
	local track = TrackData.GetTrack(trackId)
	assert(track, "Unknown track: " .. tostring(trackId))

	activeRace = {
		trackId     = trackId,
		track       = track,
		players     = players,
		startTime   = os.clock(),
		lapCounts   = {},
		nextWaypoint = {},
		finished    = {},
	}

	local laps = track.laps or GameConfig.LAP_COUNT

	for i, player in ipairs(players) do
		activeRace.lapCounts[player.UserId]   = 0
		activeRace.nextWaypoint[player.UserId] = 1
		activeRace.finished[player.UserId]    = false
		local spawn = track.spawns[i] or track.spawns[1]
		spawnPlayer(player, spawn)
	end

	print("[RaceManager] Race started on", track.name, "with", #players, "player(s)")
	return track
end

-- Call each frame or on checkpoint trigger with player + waypoint index hit
function RaceManager.CheckpointReached(player, waypointIndex)
	if not activeRace then return end
	local uid = player.UserId
	if activeRace.finished[uid] then return end

	local expected = activeRace.nextWaypoint[uid]
	if waypointIndex ~= expected then return end

	local totalWaypoints = #activeRace.track.waypoints
	activeRace.nextWaypoint[uid] = (expected % totalWaypoints) + 1

	-- Completed a full lap when wrapping back to waypoint 1
	if activeRace.nextWaypoint[uid] == 1 then
		activeRace.lapCounts[uid] = (activeRace.lapCounts[uid] or 0) + 1
		local laps = activeRace.track.laps or GameConfig.LAP_COUNT
		if RaceManager.OnLapComplete then
			RaceManager.OnLapComplete(player, activeRace.lapCounts[uid])
		end
		if activeRace.lapCounts[uid] >= laps then
			RaceManager.PlayerFinished(player)
		end
	end
end

function RaceManager.PlayerFinished(player)
	if not activeRace then return end
	local uid = player.UserId
	activeRace.finished[uid] = true

	local position = 1
	for _, p in ipairs(activeRace.players) do
		if p ~= player and activeRace.finished[p.UserId] then
			position = position + 1
		end
	end

	local elapsed = os.clock() - activeRace.startTime
	print(string.format("[RaceManager] %s finished in position %d (%.2fs)", player.Name, position, elapsed))

	-- Check if all players finished
	local allDone = true
	for _, p in ipairs(activeRace.players) do
		if not activeRace.finished[p.UserId] then
			allDone = false
			break
		end
	end

	if allDone and RaceManager.OnRaceEnd then
		local results = {}
		for _, p in ipairs(activeRace.players) do
			table.insert(results, {
				player   = p,
				userId   = p.UserId,
				name     = p.Name,
				finished = activeRace.finished[p.UserId],
				laps     = activeRace.lapCounts[p.UserId] or 0,
			})
		end
		RaceManager.OnRaceEnd(results)
		activeRace = nil
	end
end

function RaceManager.RemovePlayer(player)
	if not activeRace then return end
	for i, p in ipairs(activeRace.players) do
		if p == player then
			table.remove(activeRace.players, i)
			activeRace.finished[player.UserId] = true
			break
		end
	end
end

function RaceManager.GetActiveRace()
	return activeRace
end

return RaceManager
