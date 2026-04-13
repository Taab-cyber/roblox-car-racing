-- HUD.client.lua
-- Race HUD: lap counter, position, timer, leaderboard panel

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RE_RaceStart = Remotes:WaitForChild("RaceStart")
local RE_RaceEnd   = Remotes:WaitForChild("RaceEnd")
local RE_LapComplete = Remotes:WaitForChild("LapComplete")

-- Build ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local function makeLabel(name, text, pos, size, textSize, color)
	local frame = Instance.new("Frame")
	frame.Name = name .. "Frame"
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Position = pos
	frame.Size = size
	frame.Parent = screenGui

	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent = frame
	return label
end

local lapLabel  = makeLabel("LapLabel",  "LAP 0 / 3",  UDim2.new(0, 10, 0, 10),  UDim2.new(0, 200, 0, 50), 24)
local posLabel  = makeLabel("PosLabel",  "POS -",       UDim2.new(0, 10, 0, 65),  UDim2.new(0, 200, 0, 50), 24)
local timeLabel = makeLabel("TimeLabel", "0:00.000",    UDim2.new(1, -210, 0, 10), UDim2.new(0, 200, 0, 50), 24, Color3.fromRGB(255, 220, 0))

-- Countdown overlay
local countdownLabel = makeLabel("Countdown", "",
	UDim2.new(0.5, -150, 0.4, 0), UDim2.new(0, 300, 0, 100), 48, Color3.fromRGB(255, 80, 80))
countdownLabel.Parent.BackgroundTransparency = 1

-- State
local racing = false
local raceStartTime = 0
local currentLap = 0
local totalLaps = 3

screenGui.Enabled = false

RE_RaceStart.OnClientEvent:Connect(function(_trackId)
	racing = true
	raceStartTime = os.clock()
	currentLap = 0
	lapLabel.Text = string.format("LAP %d / %d", currentLap, totalLaps)
	posLabel.Text = "POS 1"
	timeLabel.Text = "0:00.000"
	screenGui.Enabled = true
	countdownLabel.Text = ""
	print("[HUD] Race started")
end)

RE_LapComplete.OnClientEvent:Connect(function(lapNumber)
	currentLap = lapNumber
	lapLabel.Text = string.format("LAP %d / %d", currentLap, totalLaps)
end)

RE_RaceEnd.OnClientEvent:Connect(function(results)
	racing = false
	-- Show final result
	local position = 1
	for i, r in ipairs(results) do
		if r.userId == player.UserId then
			position = i
			break
		end
	end
	countdownLabel.Text = position == 1 and "YOU WIN!" or "POSITION " .. position
	countdownLabel.TextColor3 = position == 1 and Color3.fromRGB(255, 220, 0) or Color3.fromRGB(255, 255, 255)

	task.delay(5, function()
		screenGui.Enabled = false
	end)
end)

-- Timer update
RunService.RenderStepped:Connect(function()
	if not racing then return end
	local elapsed = os.clock() - raceStartTime
	local minutes = math.floor(elapsed / 60)
	local seconds = elapsed % 60
	timeLabel.Text = string.format("%d:%05.3f", minutes, seconds)
end)

print("[HUD] Initialized")
