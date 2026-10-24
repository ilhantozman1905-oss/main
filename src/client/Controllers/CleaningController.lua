--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Cleaning = {}

function Cleaning.start(config, root, input, viewmodel, ui, effects)
    local player = Players.LocalPlayer
    local c = config.Cleaning
    local remotes = root:WaitForChild("Remotes")
    local floor = workspace:WaitForChild("MoonScrubbersPrototype"):WaitForChild("CleanSurface")
    local surface = Instance.new("SurfaceGui")
    surface.Name, surface.Face, surface.Adornee = "LocalDustGrid", Enum.NormalId.Top, floor
    surface.CanvasSize = Vector2.new(c.Columns * 32, c.Rows * 32)
    surface.LightInfluence, surface.AlwaysOnTop = 1, false
    surface.Parent = player:WaitForChild("PlayerGui")
    local frames = {}
    for row = 1, c.Rows do
        for column = 1, c.Columns do
            local id = (row - 1) * c.Columns + column
            local frame = Instance.new("Frame")
            frame.Size = UDim2.fromScale(1 / c.Columns, 1 / c.Rows)
            frame.Position = UDim2.fromScale((column - 1) / c.Columns, (row - 1) / c.Rows)
            frame.BorderSizePixel = 0
            frame.BackgroundColor3 = Color3.fromRGB(166, 151, 123)
            frame.Parent = surface
            frames[id] = frame
        end
    end
    local function apply(cells, progress)
        for id, remaining in pairs(cells) do
            if frames[id] then frames[id].BackgroundTransparency = 1 - remaining / c.DustPerCell end
        end
        ui:setProgress(progress)
    end
    -- Connect before requesting a snapshot; buffer deltas while the request is in flight.
    local ready, queued, revision = false, {}, -1
    remotes.CellsChanged.OnClientEvent:Connect(function(cells, progress, incomingRevision)
        if not ready then table.insert(queued, {cells, progress, incomingRevision}); return end
        if incomingRevision <= revision then return end
        revision = incomingRevision
        apply(cells, progress)
    end)
    local snapshot = remotes.Snapshot:InvokeServer()
    assert(snapshot, "Initial dust snapshot unavailable")
    revision = snapshot.revision
    apply(snapshot.cells, snapshot.progress)
    for _, delta in ipairs(queued) do
        if delta[3] > revision then
            revision = delta[3]
            apply(delta[1], delta[2])
        end
    end
    ready = true
    remotes.Collected.OnClientEvent:Connect(function(position) effects:collected(position) end)

    local equipped, previousMode, previousMin, previousMax = false, nil, nil, nil
    local function setEquipped(enabled)
        if equipped == enabled then return end
        equipped = enabled
        if enabled then
            previousMode = player.CameraMode
            previousMin, previousMax = player.CameraMinZoomDistance, player.CameraMaxZoomDistance
            player.CameraMode = Enum.CameraMode.LockFirstPerson
            player.CameraMinZoomDistance, player.CameraMaxZoomDistance = 0.5, 0.5
        else
            player.CameraMode = previousMode or Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = previousMax or 128
            player.CameraMinZoomDistance = previousMin or 0.5
        end
        input:setEnabled(enabled)
        ui.enabled = enabled
        ui:update()
    end
    local characterConnections = {}
    local function onCharacter(character)
        setEquipped(false)
        for _, connection in ipairs(characterConnections) do connection:Disconnect() end
        characterConnections = {}
        local function refresh()
            local tool = character:FindFirstChild("LSD Toothbrush")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            setEquipped(tool ~= nil and humanoid ~= nil and humanoid.Health > 0)
        end
        table.insert(characterConnections, character.ChildAdded:Connect(refresh))
        table.insert(characterConnections, character.ChildRemoved:Connect(refresh))
        local humanoid = character:WaitForChild("Humanoid")
        table.insert(characterConnections, humanoid.Died:Connect(function() setEquipped(false) end))
        refresh()
    end
    player.CharacterAdded:Connect(onCharacter)
    player.CharacterRemoving:Connect(function() setEquipped(false) end)
    if player.Character then task.spawn(onCharacter, player.Character) end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Include
    rayParams.FilterDescendantsInstances = {floor}
    local lastSent = 0
    RunService:BindToRenderStep("MoonBrush", Enum.RenderPriority.Camera.Value + 1, function()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local active = equipped and input.held
        viewmodel:update(camera, equipped, active, os.clock())
        effects:update(active)
        if not active or os.clock() - lastSent < 1 / c.RequestsPerSecond then return end
        lastSent = os.clock()
        local size = camera.ViewportSize
        local ray = camera:ViewportPointToRay(size.X / 2, size.Y / 2)
        local hit = workspace:Raycast(ray.Origin, ray.Direction * c.MaxReach, rayParams)
        if hit then remotes.Scrub:FireServer(hit.Position) end
    end)
end

return Cleaning
