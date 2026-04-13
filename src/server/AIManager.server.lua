-- AIManager.server.lua
-- Spawns and drives AI racers along track waypoints

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local AIManager = {}

local activeAgents = {}   -- array of agent state tables
local heartbeatConn = nil

local function getDifficulty()
	return GameConfig.AI_DIFFICULTY[GameConfig.DEFAULT_AI_DIFFICULTY]
end

-- Creates a simple NPC model to represent an AI racer
local function createAIModel(name, spawnCFrame)
	local model = Instance.new("Model")
	model.Name = name

	local body = Instance.new("Part")
	body.Name = "HumanoidRootPart"
	body.Size = Vector3.new(4, 2, 8)
	body.CFrame = spawnCFrame
	body.BrickColor = BrickColor.new("Bright red")
	body.Anchored = false
	body.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model

	model.PrimaryPart = body
	model.Parent = workspace
	return model
end

function AIManager.SpawnAI(track)
	AIManager.ClearAI()
	if not track then return end

	local difficulty = getDifficulty()
	local count = math.min(GameConfig.AI_COUNT, #track.spawns)

	for i = 1, count do
		local spawn = track.spawns[i] or track.spawns[1]
		local spawnCF = CFrame.new(spawn.x, spawn.y, spawn.z) * CFrame.Angles(0, math.rad(spawn.ry or 0), 0)
		local model = createAIModel("AI_Racer_" .. i, spawnCF)

		table.insert(activeAgents, {
			model        = model,
			waypoints    = track.waypoints,
			waypointIndex = 1,
			speed        = GameConfig.MAX_SPEED * difficulty.speed,
			lap          = 0,
			totalLaps    = track.laps or GameConfig.LAP_COUNT,
			finished     = false,
		})
	end

	-- Drive AI each frame
	heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		for _, agent in ipairs(activeAgents) do
			if agent.finished then continue end
			local body = agent.model and agent.model.PrimaryPart
			if not body then continue end

			local wp = agent.waypoints[agent.waypointIndex]
			local target = Vector3.new(wp.x, wp.y, wp.z)
			local pos = body.Position
			local dir = (target - pos)
			local dist = dir.Magnitude

			if dist < 10 then
				-- Advance waypoint
				agent.waypointIndex = (agent.waypointIndex % #agent.waypoints) + 1
				if agent.waypointIndex == 1 then
					agent.lap = agent.lap + 1
					if agent.lap >= agent.totalLaps then
						agent.finished = true
						print("[AIManager]", agent.model.Name, "finished!")
					end
				end
			else
				local move = dir.Unit * agent.speed * dt
				body.CFrame = CFrame.new(pos + move, pos + dir.Unit)
			end
		end
	end)

	print("[AIManager] Spawned", #activeAgents, "AI racers on", track.name)
end

function AIManager.ClearAI()
	if heartbeatConn then
		heartbeatConn:Disconnect()
		heartbeatConn = nil
	end
	for _, agent in ipairs(activeAgents) do
		if agent.model and agent.model.Parent then
			agent.model:Destroy()
		end
	end
	activeAgents = {}
end

return AIManager
