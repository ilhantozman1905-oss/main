--!strict
local Viewmodel = {}

function Viewmodel.new()
    local model = Instance.new("Model")
    model.Name = "MoonToothbrushViewmodel"
    local parts = {}
    local function part(name, size, color, offset)
        local item = Instance.new("Part")
        item.Name, item.Size, item.Color = name, size, color
        item.Anchored = true
        item.CanCollide, item.CanTouch, item.CanQuery, item.CastShadow = false, false, false, false
        item.Parent = model
        table.insert(parts, {part = item, offset = offset})
    end
    part("Glove", Vector3.new(0.32, 0.38, 0.5), Color3.fromRGB(228, 231, 232), CFrame.new(0, -0.12, 0))
    part("Handle", Vector3.new(0.11, 0.1, 1.05), Color3.fromRGB(72, 184, 193), CFrame.new(0, 0, -0.38))
    part("BrushHead", Vector3.new(0.24, 0.1, 0.35), Color3.fromRGB(72, 184, 193), CFrame.new(0, 0, -1))
    part("Bristles", Vector3.new(0.21, 0.13, 0.3), Color3.fromRGB(242, 239, 211), CFrame.new(0, 0.1, -1))
    local self = {model = model}
    function self:update(camera, enabled, held, time)
        model.Parent = enabled and camera or nil
        if not enabled then return end
        local stroke = held and math.sin(time * 24) or 0
        local pose = camera.CFrame * CFrame.new(0.55 + stroke * 0.12, -0.48, -0.85)
            * CFrame.Angles(math.rad(-12), math.rad(-15 + stroke * 8), math.rad(-12))
        for _, item in ipairs(parts) do item.part.CFrame = pose * item.offset end
    end
    return self
end

return Viewmodel
