--!strict
local Players = game:GetService("Players")
local State = {}

function State.start(config)
    local function characterAdded(player, character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        local backpack = player:WaitForChild("Backpack", 10)
        if not humanoid or not backpack or not player.Parent then return end
        local tool = Instance.new("Tool")
        tool.Name = "LSD Toothbrush"
        tool.RequiresHandle = false
        tool.CanBeDropped = false
        tool:SetAttribute("MoonTool", true)
        tool.Parent = backpack
        humanoid:EquipTool(tool)

        local pack = Instance.new("Part")
        pack.Name = "DustTank"
        pack.Size = Vector3.new(1.4, 1.8, 0.7)
        pack.Color = Color3.fromRGB(65, 74, 90)
        pack.Massless = true
        pack.CanCollide, pack.CanTouch, pack.CanQuery = false, false, false
        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if not torso then pack:Destroy(); return end
        pack.CFrame = torso.CFrame * CFrame.new(0, 0, 0.85)
        pack.Parent = character
        local weld = Instance.new("WeldConstraint")
        weld.Part0, weld.Part1, weld.Parent = torso, pack, pack
        local gui = Instance.new("SurfaceGui")
        gui.Face = Enum.NormalId.Back
        gui.CanvasSize = Vector2.new(140, 180)
        gui.Parent = pack
        local background = Instance.new("Frame")
        background.Size = UDim2.fromScale(0.7, 0.8)
        background.Position = UDim2.fromScale(0.15, 0.1)
        background.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
        background.Parent = gui
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.AnchorPoint = Vector2.new(0, 1)
        fill.Position = UDim2.fromScale(0, 1)
        fill.BackgroundColor3 = Color3.fromRGB(210, 181, 123)
        fill.Parent = background
        -- Only the server updates tank quantities and the replicated backpack gauge.
        local function update()
            local ratio = player:GetAttribute("Dust") / player:GetAttribute("TankCapacity")
            fill.Size = UDim2.fromScale(1, math.clamp(ratio, 0, 1))
        end
        update()
        local connection = player:GetAttributeChangedSignal("Dust"):Connect(update)
        pack.Destroying:Once(function() connection:Disconnect() end)
    end
    local function added(player)
        player:SetAttribute("Dust", 0)
        player:SetAttribute("TankCapacity", config.StartingStats.TankCapacity)
        player.CharacterAdded:Connect(function(character) characterAdded(player, character) end)
        if player.Character then task.spawn(characterAdded, player, player.Character) end
    end
    Players.PlayerAdded:Connect(added)
    for _, player in ipairs(Players:GetPlayers()) do added(player) end
end

return State
