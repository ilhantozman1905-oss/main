--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local root = ReplicatedStorage:WaitForChild("MoonScrubbers")
local Config = require(root.Shared.Config)

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = root
local remotes = {}
for name, class in pairs({Scrub = "RemoteEvent", Collected = "RemoteEvent", CellsChanged = "RemoteEvent", Snapshot = "RemoteFunction"}) do
    local remote = Instance.new(class)
    remote.Name, remote.Parent = name, remotesFolder
    remotes[name] = remote
end

-- Isolated prototype geometry; never clears an existing map or changes gravity.
assert(not workspace:FindFirstChild("MoonScrubbersPrototype"), "Prototype already exists")
local world = Instance.new("Folder")
world.Name, world.Parent = "MoonScrubbersPrototype", workspace
local floor = Instance.new("Part")
floor.Name = "CleanSurface"
floor.Anchored = true
floor.Size = Vector3.new(Config.Cleaning.Columns * Config.Cleaning.CellSize, 1, Config.Cleaning.Rows * Config.Cleaning.CellSize)
floor.Position = Vector3.new(0, Config.World.FloorY - 0.5, 0)
floor.Material = Enum.Material.Slate
floor.Color = Color3.fromRGB(82, 91, 108)
floor.Parent = world
local spawn = Instance.new("SpawnLocation")
spawn.Name = "MoonSpawn"
spawn.Size = Vector3.new(4, 1, 4)
spawn.Anchored, spawn.CanCollide, spawn.CanQuery = true, false, false
spawn.Transparency = 1
spawn.Position = Vector3.new(0, Config.World.SpawnHeight, 0)
spawn.Neutral, spawn.Duration = true, 0
spawn.Parent = world

require(script.Parent.Services.PlayerStateService).start(Config)
require(script.Parent.Services.CleaningService).start(Config, floor, remotes)
root:SetAttribute("Ready", true)
print("[Moon Scrubbers] Step 2 ready: equip toothbrush, look down, hold and sweep")
