-- LeaderboardManager.server.lua
-- Persists and retrieves race scores via DataStoreService

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local LeaderboardManager = {}

local store = DataStoreService:GetDataStore(GameConfig.DATASTORE_KEY)

-- In-memory cache updated each session
local cachedScores = {}   -- array of { userId, name, points }

local function pointsForPosition(position)
	if position == 1 then return GameConfig.POINTS_1ST
	elseif position == 2 then return GameConfig.POINTS_2ND
	elseif position == 3 then return GameConfig.POINTS_3RD
	else return GameConfig.POINTS_FINISH
	end
end

-- Load scores from DataStore on startup
local function loadScores()
	local success, data = pcall(function()
		return store:GetAsync("TopScores")
	end)
	if success and data then
		cachedScores = data
	end
end

local function saveScores()
	pcall(function()
		store:SetAsync("TopScores", cachedScores)
	end)
end

-- results: array of { userId, name, finished, laps }
-- Assumes they are already sorted by finish position (index = position)
function LeaderboardManager.UpdateScores(results)
	local scoreMap = {}
	for _, entry in ipairs(cachedScores) do
		scoreMap[entry.userId] = entry
	end

	for position, result in ipairs(results) do
		if result.finished then
			local pts = pointsForPosition(position)
			if scoreMap[result.userId] then
				scoreMap[result.userId].points = scoreMap[result.userId].points + pts
			else
				scoreMap[result.userId] = { userId = result.userId, name = result.name, points = pts }
			end
		end
	end

	-- Rebuild sorted list
	cachedScores = {}
	for _, entry in pairs(scoreMap) do
		table.insert(cachedScores, entry)
	end
	table.sort(cachedScores, function(a, b) return a.points > b.points end)

	-- Trim to leaderboard size
	while #cachedScores > GameConfig.LEADERBOARD_SIZE do
		table.remove(cachedScores)
	end

	saveScores()
	print("[LeaderboardManager] Scores updated, top player:", cachedScores[1] and cachedScores[1].name or "none")
end

function LeaderboardManager.GetTopScores()
	return cachedScores
end

-- Startup
loadScores()
print("[LeaderboardManager] Initialized,", #cachedScores, "scores loaded")

return LeaderboardManager
