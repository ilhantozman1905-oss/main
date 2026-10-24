--!nonstrict
local RunService=game:GetService("RunService")
local Vehicle={}
function Vehicle.new(g)
    local self=setmetatable({Game=g,Active={},Input={}},{__index=Vehicle})
    RunService.Heartbeat:Connect(function(dt) self:step(math.min(dt,0.1)) end)
    return self
end
function Vehicle:remove(player)
    if self.Active[player] then self.Active[player].Model:Destroy() end
    self.Active[player]=nil; self.Input[player]=nil
end
function Vehicle:spawn(player)
    local g=self.Game; local p=g.Profiles[player]; local base=g.Bases[player]
    if p.Vehicle<1 then return false,"Buy a vehicle in the garage first." end
    if not g:nearBase(player,65) then return false,"Return to your base to deploy a vehicle." end
    self:remove(player)
    local stats=g.Config.Vehicles[p.Vehicle]; local model=Instance.new("Model"); model.Name=player.Name.."'s "..stats.Name
    local chassis=g.World.part(model,"Chassis",Vector3.new(7,1.5,10),base.Position+Vector3.new(0,5,-24),Color3.fromRGB(242,177,62))
    chassis.CFrame=chassis.CFrame*CFrame.Angles(0,math.pi,0)
    chassis.Anchored=false; model.PrimaryPart=chassis
    local function weld(part)
        part.Anchored=false; part.Massless=true
        local w=Instance.new("WeldConstraint"); w.Part0=chassis; w.Part1=part; w.Parent=part
    end
    local seat=Instance.new("VehicleSeat"); seat.Name="Driver"; seat.Size=Vector3.new(2,1,2)
    seat.CFrame=chassis.CFrame*CFrame.new(0,1.5,0); seat.Parent=model; weld(seat)
    local passenger=Instance.new("Seat"); passenger.Name="Crew Seat"; passenger.Size=Vector3.new(2,1,2)
    passenger.CFrame=chassis.CFrame*CFrame.new(0,1.5,3); passenger.Parent=model; weld(passenger)
    for _,x in ipairs({-3.6,3.6}) do for _,z in ipairs({-3.2,3.2}) do
        local wheel=g.World.part(model,"Wheel",Vector3.new(1.4,2.8,2.8),chassis.Position+Vector3.new(x,-0.5,z),Color3.fromRGB(30,35,48))
        wheel.Shape=Enum.PartType.Cylinder; weld(wheel)
    end end
    local brush=g.World.part(model,"Sweeper",Vector3.new(stats.Radius*2,0.8,1.5),chassis.CFrame:PointToWorldSpace(Vector3.new(0,-0.6,-5.5)),Color3.fromRGB(65,225,210))
    brush.CanCollide=false; weld(brush)
    local attachment=Instance.new("Attachment"); attachment.Parent=chassis
    local align=Instance.new("AlignOrientation"); align.Mode=Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0=attachment; align.MaxTorque=150000; align.Responsiveness=6; align.Parent=chassis
    if p.Vehicle>=3 then
        local tank=g.World.part(model,"Industrial Dust Tank",Vector3.new(5,2.5,2),chassis.CFrame:PointToWorldSpace(Vector3.new(0,2.2,-2.5)),Color3.fromRGB(87,114,140))
        weld(tank)
    end
    if p.Vehicle==6 then
        for _,side in ipairs({-1,1}) do
            local wing=g.World.part(model,"Starship Wing",Vector3.new(8,0.4,6),chassis.Position+Vector3.new(side*6,0,1),Color3.fromRGB(120,90,190))
            weld(wing)
            local engine=g.World.part(model,"Ion Engine",Vector3.new(2,2,3),chassis.CFrame:PointToWorldSpace(Vector3.new(side*5,0,5)),Color3.fromRGB(80,225,240),Enum.Material.Neon)
            weld(engine)
        end
    end
    g.World.label(chassis,stats.Name.." / "..stats.Capacity.." dust")
    model.Parent=g.World.Root; chassis:SetNetworkOwner(nil)
    self.Active[player]={Model=model,Body=chassis,Seat=seat,Align=align,Yaw=math.pi,Timer=0}
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:UnequipTools(); task.delay(0.2,function() if seat.Parent then seat:Sit(hum) end end) end
    return true,"Vehicle deployed. Drive with WASD, stick or Roblox touch controls; dust is collected while moving."
end
function Vehicle:drive(player,input)
    if typeof(input)~="Vector2" or input.X~=input.X or input.Y~=input.Y then return end
    if math.abs(input.X)>1 or math.abs(input.Y)>1 then return end
    local v=self.Active[player]
    if not v or not v.Seat.Occupant or v.Seat.Occupant.Parent~=player.Character then return end
    local old=self.Input[player]
    if old and os.clock()-old.At<0.07 then return end
    self.Input[player]={Vector=input,At=os.clock()}
end
function Vehicle:step(dt)
    for player,v in pairs(self.Active) do
        local p=self.Game.Profiles[player]
        if p and v.Body.Parent then
            local stats=self.Game.Config.Vehicles[p.Vehicle]
            local input=self.Input[player]
            local vector=input and os.clock()-input.At<0.4 and input.Vector or Vector2.zero
            if not v.Seat.Occupant or v.Seat.Occupant.Parent~=player.Character then vector=Vector2.zero end
            v.Yaw=v.Yaw-vector.X*dt*1.4
            v.Align.CFrame=CFrame.Angles(0,v.Yaw,0)
            local velocity=v.Body.AssemblyLinearVelocity
            local direction=CFrame.Angles(0,v.Yaw,0).LookVector*vector.Y*stats.Speed*(1+p.Buildings.Garage*0.04)
            local blend=math.min(1,dt*2)
            v.Body.AssemblyLinearVelocity=Vector3.new(velocity.X+(direction.X-velocity.X)*blend,velocity.Y,velocity.Z+(direction.Z-velocity.Z)*blend)
            v.Timer=v.Timer+dt
            if v.Timer>=0.2 then
                local elapsed=math.min(v.Timer,0.3); v.Timer=0
                if Vector3.new(velocity.X,0,velocity.Z).Magnitude>2 and vector.Y~=0 then
                    for id,z in ipairs(self.Game.World.Zones) do
                        local delta=v.Body.Position-z.Center
                        if math.abs(delta.X)<40 and math.abs(delta.Z)<40 and math.abs(delta.Y)<10 then
                            self.Game.Cleaning:take(player,id,v.Body.Position,stats.Radius,stats.Rate*elapsed,"Vehicle"); break
                        end
                    end
                end
                local base=self.Game.Bases[player]
                if (v.Body.Position-base.Depot.Position).Magnitude<22 and p.VehicleDust>0 then self.Game:sell(player) end
            end
            if v.Body.Position.Y < -50 then self:remove(player) end
        end
    end
end
return Vehicle
