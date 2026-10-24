--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Grid = require(ReplicatedStorage.MoonScrubbers.Shared.Grid)
local Service = {}

function Service.start(config, floor, remotes)
    local c = config.Cleaning
    local cells, pending, sessions = {}, {}, {}
    local totalCollected, revision = 0, 0
    for id = 1, c.Columns * c.Rows do cells[id] = c.DustPerCell end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = {floor}

    remotes.Snapshot.OnServerInvoke = function(player)
        local now = os.clock()
        local session = sessions[player] or {}
        sessions[player] = session
        if session.snapshotAt and now - session.snapshotAt < 1 then return nil end
        session.snapshotAt = now
        return {cells = table.clone(cells), progress = totalCollected / (c.Columns * c.Rows * c.DustPerCell), revision = revision}
    end

    remotes.Scrub.OnServerEvent:Connect(function(player, target)
        local now = os.clock()
        local session = sessions[player] or {}
        sessions[player] = session
        -- Rate limit before any raycasts or collection work, including invalid requests.
        if session.requestAt and now - session.requestAt < 0.9 / c.RequestsPerSecond then return end
        session.requestAt = now
        if typeof(target) ~= "Vector3" or not Grid.finiteVector(target.X, target.Y, target.Z) then return end
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local tool = character and character:FindFirstChild("LSD Toothbrush")
        if not head or not humanoid or humanoid.Health <= 0 or not tool or not tool:GetAttribute("MoonTool") then return end
        local direction = target - head.Position
        if direction.Magnitude < 0.01 or direction.Magnitude > c.MaxReach then return end
        -- Check actual line of sight: characters and scenery can obstruct the floor.
        local visibility = RaycastParams.new()
        visibility.FilterType = Enum.RaycastFilterType.Exclude
        visibility.FilterDescendantsInstances = {character}
        local visibleHit = workspace:Raycast(head.Position, direction.Unit * (direction.Magnitude + 0.2), visibility)
        if not visibleHit or visibleHit.Instance ~= floor then return end
        local hit = workspace:Raycast(head.Position, direction.Unit * (direction.Magnitude + 0.2), rayParams)
        if not hit or (hit.Position - target).Magnitude > 0.5 or hit.Normal.Y < 0.9 then return end
        local localPoint = floor.CFrame:PointToObjectSpace(hit.Position)
        if not Grid.cellAt(localPoint.X, localPoint.Z, c.CellSize, c.Columns, c.Rows) then return end
        local previous, previousAt = session.target, session.validAt
        session.target, session.validAt = target, now
        -- Holding still does not farm dust. Real aim/movement drives the brush strokes.
        if not previous or now - previousAt > 0.5 then return end
        local distance = (target - previous).Magnitude
        if distance < c.MinStrokeDistance or distance > c.MaxStrokeDistance then return end
        local tank = player:GetAttribute("Dust") or 0
        local capacity = player:GetAttribute("TankCapacity") or config.StartingStats.TankCapacity
        local ids = Grid.cellsWithin(localPoint.X, localPoint.Z, c.BrushRadius, c.CellSize, c.Columns, c.Rows)
        local budget = c.DustPerSecond * math.min(now - previousAt, 0.2)
        local amount, changes = Grid.collect(cells, ids, budget, tank, capacity)
        if amount <= 0 then return end
        player:SetAttribute("Dust", math.min(capacity, tank + amount))
        totalCollected = totalCollected + amount
        revision = revision + 1
        for id, remaining in pairs(changes) do pending[id] = remaining end
        remotes.Collected:FireClient(player, hit.Position, amount)
    end)

    Players.PlayerRemoving:Connect(function(player) sessions[player] = nil end)
    task.spawn(function()
        while floor.Parent do
            task.wait(c.ReplicationInterval)
            if next(pending) then
                remotes.CellsChanged:FireAllClients(pending, totalCollected / (c.Columns * c.Rows * c.DustPerCell), revision)
                pending = {}
            end
        end
    end)
end

return Service
