--!strict
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Effects = {}

function Effects.new(config)
    local sound = Instance.new("Sound")
    sound.Name = "MoonBrushing"
    sound.SoundId = config.Audio.BrushSoundId
    sound.Volume, sound.Looped = 0.16, true
    sound.PlaybackSpeed = 1.7
    sound.Parent = workspace.CurrentCamera
    local self = {lastCollection = -math.huge}
    function self:collected(position)
        self.lastCollection = os.clock()
        if sound.SoundId ~= "" and not sound.IsPlaying then sound:Play() end
        local bead = Instance.new("Part")
        bead.Name, bead.Shape = "LocalDust", Enum.PartType.Ball
        bead.Size = Vector3.new(0.12, 0.12, 0.12)
        bead.Anchored = true
        bead.CanCollide, bead.CanTouch, bead.CanQuery = false, false, false
        bead.Color = Color3.fromRGB(219, 195, 149)
        bead.Position, bead.Parent = position + Vector3.new(0, 0.1, 0), workspace
        local emitter = Instance.new("ParticleEmitter")
        emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
        emitter.Color = ColorSequence.new(bead.Color)
        emitter.Rate = 0
        emitter.Lifetime = NumberRange.new(0.2, 0.4)
        emitter.Speed = NumberRange.new(0.5, 1.5)
        emitter.SpreadAngle = Vector2.new(60, 60)
        emitter.Size = NumberSequence.new(0.18)
        emitter.Parent = bead
        emitter:Emit(4)
        local character = Players.LocalPlayer.Character
        local tank = character and character:FindFirstChild("DustTank")
        if tank then
            TweenService:Create(bead, TweenInfo.new(0.35), {Position = tank.Position, Transparency = 1}):Play()
        end
        Debris:AddItem(bead, 0.5)
    end
    function self:update(active)
        if not active or os.clock() - self.lastCollection > 0.25 then sound:Stop() end
    end
    return self
end

return Effects
