--!strict
local Config = {
    MaxPlayers = 4,
    Cleaning = {
        CellSize = 4,
        Columns = 16,
        Rows = 16,
        DustPerCell = 4,
        DustPerSecond = 6,
        MaxReach = 10,
        RequestsPerSecond = 10,
        MinStrokeDistance = 0.12,
        MaxStrokeDistance = 5,
        BrushRadius = 1.6,
        ReplicationInterval = 0.15,
    },
    StartingStats = { TankCapacity = 50, ToolId = "Toothbrush" },
    World = { FloorY = 0, SpawnHeight = 5 },
    -- Set this to an audio asset you own/have permission to use. Empty is silent.
    Audio = { BrushSoundId = "" },
}
local function freeze(value)
    for _, child in pairs(value) do
        if type(child) == "table" then freeze(child) end
    end
    return table.freeze(value)
end
return freeze(Config)
