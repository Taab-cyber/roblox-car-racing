-- GameManager.server.lua
-- Top-level server orchestrator: manages game state and coordinates managers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local Server = ServerScriptService:WaitForChild("Server")
local RaceManager = require(Server:WaitForChild("RaceManager"))
local LeaderboardManager = require(Server:WaitForChild("LeaderboardManager"))
local AIManager = require(Server:WaitForChild("AIManager"))

-- RemoteEvents (folder pre-created by default.project.json)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local function makeRemote(name, isFunction)
	local r = Instance.new(isFunction and "RemoteFunction" or "RemoteEvent")
	r.Name = name
	r.Parent = Remotes
	return r
end

local RE = {
	RaceStart        = makeRemote("RaceStart"),
	RaceEnd          = makeRemote("RaceEnd"),
	LapComplete      = makeRemote("LapComplete"),
	PositionUpdate   = makeRemote("PositionUpdate"),
	TrackSelected    = makeRemote("TrackSelected"),
	RequestLeaderboard = makeRemote("RequestLeaderboard", true),
}

-- Game states
local STATE = { LOBBY = "Lobby", COUNTDOWN = "Countdown", RACING = "Racing", RESULTS = "Results" }
local currentState = STATE.LOBBY
local selectedTrackId = "desert_circuit"

-- Players in the current race
local racePlayers = {}

local function setState(newState)
	currentState = newState
	print("[GameManager] State →", newState)
end

local function startCountdown()
	setState(STATE.COUNTDOWN)
	task.delay(GameConfig.COUNTDOWN_TIME, function()
		if currentState == STATE.COUNTDOWN then
			local trackData = RaceManager.StartRace(selectedTrackId, racePlayers)
			AIManager.SpawnAI(trackData)
			RE.RaceStart:FireAllClients(selectedTrackId)
			setState(STATE.RACING)
		end
	end)
end

-- Track selection from client
RE.TrackSelected.OnServerEvent:Connect(function(player, trackId)
	if currentState ~= STATE.LOBBY then return end
	selectedTrackId = trackId
	print("[GameManager] Track selected:", trackId, "by", player.Name)
end)

-- Leaderboard request
RE.RequestLeaderboard.OnServerInvoke = function(_player)
	return LeaderboardManager.GetTopScores()
end

-- Lap complete relay
RaceManager.OnLapComplete = function(player, lapNumber)
	RE.LapComplete:FireClient(player, lapNumber)
end

-- Race finished
RaceManager.OnRaceEnd = function(results)
	setState(STATE.RESULTS)
	LeaderboardManager.UpdateScores(results)
	RE.RaceEnd:FireAllClients(results)
	AIManager.ClearAI()

	task.delay(10, function()
		setState(STATE.LOBBY)
		racePlayers = {}
	end)
end

-- Auto-start when enough players join
Players.PlayerAdded:Connect(function(player)
	table.insert(racePlayers, player)
	if #racePlayers >= 2 and currentState == STATE.LOBBY then
		startCountdown()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	for i, p in ipairs(racePlayers) do
		if p == player then
			table.remove(racePlayers, i)
			break
		end
	end
	RaceManager.RemovePlayer(player)
end)

print("[GameManager] Initialized")
