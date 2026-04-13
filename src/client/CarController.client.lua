-- CarController.client.lua
-- Handles local car input and sends movement to the server via VehicleSeat or custom physics

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Input state
local input = { forward = 0, turn = 0, brake = false }

-- Key bindings
local KEY_MAP = {
	[Enum.KeyCode.W]      = function(s) input.forward = s and  1 or 0 end,
	[Enum.KeyCode.S]      = function(s) input.forward = s and -1 or 0 end,
	[Enum.KeyCode.Up]     = function(s) input.forward = s and  1 or 0 end,
	[Enum.KeyCode.Down]   = function(s) input.forward = s and -1 or 0 end,
	[Enum.KeyCode.A]      = function(s) input.turn    = s and -1 or 0 end,
	[Enum.KeyCode.D]      = function(s) input.turn    = s and  1 or 0 end,
	[Enum.KeyCode.Left]   = function(s) input.turn    = s and -1 or 0 end,
	[Enum.KeyCode.Right]  = function(s) input.turn    = s and  1 or 0 end,
	[Enum.KeyCode.Space]  = function(s) input.brake   = s end,
}

UserInputService.InputBegan:Connect(function(inp, processed)
	if processed then return end
	local fn = KEY_MAP[inp.KeyCode]
	if fn then fn(true) end
end)

UserInputService.InputEnded:Connect(function(inp)
	local fn = KEY_MAP[inp.KeyCode]
	if fn then fn(false) end
end)

-- Mobile / gamepad thumbstick
UserInputService.InputChanged:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.Gamepad1 then
		if inp.KeyCode == Enum.KeyCode.Thumbstick1 then
			input.turn    = inp.Position.X
			input.forward = inp.Position.Y
		end
	end
end)

-- Drive loop — applies velocity directly to the character's HumanoidRootPart
-- Replace this with VehicleSeat logic when a proper car model is added
local racing = false

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RE_RaceStart = Remotes:WaitForChild("RaceStart")
local RE_RaceEnd   = Remotes:WaitForChild("RaceEnd")

RE_RaceStart.OnClientEvent:Connect(function()
	racing = true
	print("[CarController] Race started — controls active")
end)

RE_RaceEnd.OnClientEvent:Connect(function()
	racing = false
	input = { forward = 0, turn = 0, brake = false }
	print("[CarController] Race ended — controls disabled")
end)

RunService.Heartbeat:Connect(function(dt)
	if not racing then return end
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local speed = input.brake and (GameConfig.MAX_SPEED * 0.1) or GameConfig.MAX_SPEED
	local moveVec = hrp.CFrame.LookVector * (input.forward * speed)

	hrp.AssemblyLinearVelocity = Vector3.new(moveVec.X, hrp.AssemblyLinearVelocity.Y, moveVec.Z)

	if input.turn ~= 0 then
		local turnDelta = input.turn * GameConfig.TURN_SPEED * dt
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, -turnDelta, 0)
	end
end)

print("[CarController] Initialized")
