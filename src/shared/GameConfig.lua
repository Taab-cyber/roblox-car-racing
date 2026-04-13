-- GameConfig.lua
-- Shared configuration constants for the racing game

local GameConfig = {}

-- Race settings
GameConfig.MAX_PLAYERS = 8
GameConfig.COUNTDOWN_TIME = 5       -- seconds before race starts
GameConfig.LAP_COUNT = 3
GameConfig.RACE_TIMEOUT = 300       -- max race duration in seconds

-- Car settings
GameConfig.MAX_SPEED = 120          -- studs/second
GameConfig.ACCELERATION = 40
GameConfig.BRAKE_FORCE = 80
GameConfig.TURN_SPEED = 2.5

-- AI settings
GameConfig.AI_COUNT = 4             -- number of AI racers per race
GameConfig.AI_DIFFICULTY = {
	EASY   = { speed = 0.70, reaction = 0.5 },
	MEDIUM = { speed = 0.85, reaction = 0.3 },
	HARD   = { speed = 1.00, reaction = 0.1 },
}
GameConfig.DEFAULT_AI_DIFFICULTY = "MEDIUM"

-- Leaderboard settings
GameConfig.LEADERBOARD_SIZE = 10    -- top N scores stored
GameConfig.POINTS_1ST = 10
GameConfig.POINTS_2ND = 7
GameConfig.POINTS_3RD = 5
GameConfig.POINTS_FINISH = 2        -- any finisher gets this

-- DataStore key
GameConfig.DATASTORE_KEY = "RacingLeaderboard_v1"

return GameConfig
