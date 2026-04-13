-- TrackSelector.client.lua
-- Lobby UI that lets the player browse and vote for a track

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local TrackData = require(Shared:WaitForChild("TrackData"))

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RE_TrackSelected = Remotes:WaitForChild("TrackSelected")
local RE_RaceStart = Remotes:WaitForChild("RaceStart")

-- Build UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrackSelector"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(0, 500, 0, 420)
background.Position = UDim2.new(0.5, -250, 0.5, -210)
background.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
background.BorderSizePixel = 0
background.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = background

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 220, 0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Text = "SELECT A TRACK"
title.Parent = background

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -60)
listFrame.Position = UDim2.new(0, 10, 0, 55)
listFrame.BackgroundTransparency = 1
listFrame.ScrollBarThickness = 6
listFrame.Parent = background

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = listFrame

local selectedTrackId = TrackData.Tracks[1].id

local function setSelected(id)
	selectedTrackId = id
	RE_TrackSelected:FireServer(id)
end

-- Create a button for each track
for i, track in ipairs(TrackData.Tracks) do
	local btn = Instance.new("TextButton")
	btn.Name = track.id
	btn.Size = UDim2.new(1, 0, 0, 80)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamSemibold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Text = track.name .. "\n" .. (track.laps or 3) .. " laps"
	btn.LayoutOrder = i
	btn.Parent = listFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		-- Highlight selection
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
		setSelected(track.id)
	end)
end

-- Update canvas size to match content
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Select first track by default
setSelected(selectedTrackId)

-- Hide when race starts
RE_RaceStart.OnClientEvent:Connect(function()
	screenGui.Enabled = false
end)

print("[TrackSelector] Initialized")
