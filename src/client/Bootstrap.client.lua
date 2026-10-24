--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local root=RS:WaitForChild("MoonScrubbers")
while not root:GetAttribute("Ready") do root:GetAttributeChangedSignal("Ready"):Wait() end
local player=Players.LocalPlayer
while not player:GetAttribute("Loaded") do player:GetAttributeChangedSignal("Loaded"):Wait() end
local config=require(root.Shared.Config); local remotes=root:WaitForChild("Remotes")
local controllers=script.Parent.Controllers
local input=require(controllers.InputController).new()
local viewmodel=require(controllers.ViewmodelController).new(config)
local ui=require(controllers.UIController).new(config,remotes)
local effects=require(controllers.EffectsController).new(config)
remotes.Event.OnClientEvent:Connect(function()
    local Debris=game:GetService("Debris")
    local TweenService=game:GetService("TweenService")
    for i=1,12 do
        task.delay(i*0.4,function()
            local meteor=Instance.new("Part"); meteor.Size=Vector3.new(2,2,5); meteor.Anchored=true
            meteor.CanCollide=false; meteor.CanQuery=false; meteor.Material=Enum.Material.Neon
            meteor.Color=Color3.fromRGB(255,170,75); meteor.Position=Vector3.new(math.random(-150,150),170,math.random(60,250))
            meteor.Parent=workspace
            TweenService:Create(meteor,TweenInfo.new(1.4),{Position=meteor.Position+Vector3.new(30,-165,20),Transparency=1}):Play()
            Debris:AddItem(meteor,1.5)
        end)
    end
end)
require(controllers.CleaningController).start(config,root,input,viewmodel,ui,effects)
