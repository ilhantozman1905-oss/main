--!nonstrict
local Lighting=game:GetService("Lighting")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local World={}
local teal=Color3.fromRGB(72,218,203)
function World.part(parent,name,size,position,color,material)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position
    p.Anchored=true; p.Color=color or Color3.fromRGB(65,75,94); p.Material=material or Enum.Material.Metal
    p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent
    return p
end
function World.label(part,text,color)
    local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(250,65)
    gui.StudsOffset=Vector3.new(0,4,0); gui.MaxDistance=125; gui.AlwaysOnTop=false; gui.Parent=part
    local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1)
    label.BackgroundTransparency=1; label.Text=text; label.TextColor3=color or teal
    label.TextStrokeTransparency=0.25; label.Font=Enum.Font.GothamBold; label.TextSize=17
    label.TextWrapped=true; label.Parent=gui; return label
end
function World.prompt(part,text,callback)
    local p=Instance.new("ProximityPrompt"); p.ActionText=text; p.ObjectText=part.Name
    p.MaxActivationDistance=16; p.HoldDuration=0.15; p.RequiresLineOfSight=false; p.Parent=part
    p.Triggered:Connect(callback); return p
end
function World.start(config)
    local self=setmetatable({Zones={},Bases={},Robots={}}, {__index=World})
    local root=Instance.new("Folder"); root.Name="MoonWorld"; root.Parent=workspace; self.Root=root
    workspace.Gravity=config.Gravity
    Lighting.ClockTime=0; Lighting.Brightness=2; Lighting.Ambient=Color3.fromRGB(92,106,145)
    Lighting.OutdoorAmbient=Color3.fromRGB(82,90,125)
    local sky=Instance.new("Sky"); sky.StarCount=5000; sky.CelestialBodiesShown=true; sky.Parent=Lighting
    World.part(root,"Lunar Bedrock",Vector3.new(530,5,530),Vector3.new(0,-3,170),Color3.fromRGB(66,73,91),Enum.Material.Slate)
    World.part(root,"LSD Landing Plaza",Vector3.new(190,1,85),Vector3.new(0,-0.5,0))
    local earth=World.part(root,"Earth",Vector3.new(90,90,90),Vector3.new(0,230,-430),Color3.fromRGB(55,127,215),Enum.Material.Neon)
    earth.Shape=Enum.PartType.Ball; earth.CanCollide=false
    local sign=World.part(root,"LSD Dispatch",Vector3.new(27,9,1),Vector3.new(0,12,-35))
    World.label(sign,"MOON SCRUBBERS\nLUNAR SURFACE DEPARTMENT",teal)
    local board=World.part(root,"Crew Leaderboard",Vector3.new(18,12,1),Vector3.new(33,8,-32))
    self.Board=World.label(board,"CREW LEADERBOARD\nClock in. Clean up. Cash out.")
    local spawn=Instance.new("SpawnLocation"); spawn.Name="LSD Arrival"
    spawn.Size=Vector3.new(6,1,6); spawn.Position=Vector3.new(0,0.6,-12)
    spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0; spawn.Parent=root
    for id,z in ipairs(config.Zones) do
        local model=Instance.new("Model"); model.Name=z.Name; model.Parent=root
        local floor=World.part(model,"DustField",Vector3.new(80,1,80),Vector3.new(z.X,-0.5,z.Z),Color3.fromRGB(82,92,111),Enum.Material.Slate)
        floor:SetAttribute("ZoneId",id)
        local entry=World.part(model,"Zone Beacon",Vector3.new(2,9,2),Vector3.new(z.X,4,z.Z-43),teal,Enum.Material.Neon)
        World.label(entry,z.Name.."\n"..z.Value.." credits / dust • suit "..z.Suit)
        self.Zones[id]={Floor=floor,Center=Vector3.new(z.X,0,z.Z),Entry=entry}
        -- Crater rims, rocks and crystals decorate the outside; grids remain navigable.
        for k=1,12 do
            local angle=k*math.pi/6; local pos=Vector3.new(z.X+math.cos(angle)*46,2,z.Z+math.sin(angle)*46)
            local rock=World.part(model,id==5 and "Lunar Crystal" or "Crater Rim",Vector3.new(6,3+(k%4)*2,6),pos,
                id==5 and Color3.fromRGB(165,100,245) or Color3.fromRGB(94,96,109),id==5 and Enum.Material.Neon or Enum.Material.Rock)
            rock.CFrame=rock.CFrame*CFrame.Angles(0,k,math.rad(k%3*12))
        end
        if id==4 then
            World.part(model,"Abandoned Habitat",Vector3.new(15,10,12),Vector3.new(z.X+30,5,z.Z+48),Color3.fromRGB(87,97,104))
        elseif id==5 then
            World.part(model,"Cavern Canopy",Vector3.new(90,3,90),Vector3.new(z.X,22,z.Z),Color3.fromRGB(51,46,67),Enum.Material.Rock)
        end
    end
    local slots={Vector3.new(-60,0,-10),Vector3.new(60,0,-10),Vector3.new(-60,0,40),Vector3.new(60,0,40)}
    for id,pos in ipairs(slots) do
        local model=Instance.new("Model"); model.Name="BasePlot"..id; model.Parent=root
        World.part(model,"Foundation",Vector3.new(49,0.8,43),pos+Vector3.new(0,0,0))
        local nameplate=World.part(model,"Base Sign",Vector3.new(18,3,1),pos+Vector3.new(0,6,-20),Color3.fromRGB(30,40,57))
        local base={Model=model,Position=pos,Label=World.label(nameplate,"AVAILABLE LSD CONTRACT"),Buildings={}}
        for index,b in ipairs(config.Buildings) do
            local x=(index-3)*9
            local p=World.part(model,b.Name,Vector3.new(7,3,7),pos+Vector3.new(x,2,5))
            World.part(model,b.Id.."Roof",Vector3.new(8,0.5,8),p.Position+Vector3.new(0,2,0),teal)
            base.Buildings[b.Id]=p
            World.label(p,b.Name.."\nLEVEL 0")
        end
        local depot=World.part(model,"SHIP DUST",Vector3.new(8,0.3,8),pos+Vector3.new(-14,0.7,-10),Color3.fromRGB(248,179,65),Enum.Material.Neon)
        base.Depot=depot
        local rocket=World.part(model,"Delivery Capsule",Vector3.new(7,3,3),pos+Vector3.new(-14,4,-10),Color3.fromRGB(230,235,240))
        rocket.Shape=Enum.PartType.Cylinder; rocket.CFrame=rocket.CFrame*CFrame.Angles(0,0,math.pi/2)
        base.Rocket=rocket
        local antenna=World.part(model,"LSD Antenna",Vector3.new(0.7,12,0.7),pos+Vector3.new(20,6,-12))
        local dish=World.part(model,"Satellite Dish",Vector3.new(5,1,5),antenna.Position+Vector3.new(0,6,0),Color3.fromRGB(218,226,237))
        dish.Shape=Enum.PartType.Ball
        for _,x in ipairs({-23,23}) do
            World.part(model,"Base Light",Vector3.new(0.4,0.3,37),pos+Vector3.new(x,0.5,0),teal,Enum.Material.Neon)
        end
        local light=Instance.new("PointLight"); light.Color=teal; light.Range=26; light.Brightness=2; light.Parent=nameplate
        self.Bases[id]=base
    end
    return self
end
function World:assign(player)
    for _,base in ipairs(self.Bases) do
        if not base.Owner then base.Owner=player; base.Label.Text=player.DisplayName.."'S LUNAR BASE"; return base end
    end
end
function World:upgrade(base,p)
    for id,part in pairs(base.Buildings) do
        local level=p.Buildings[id]
        part.Size=Vector3.new(7,3+level*1.5,7)
        part.Position=Vector3.new(part.Position.X,base.Position.Y+2+level*0.75,part.Position.Z)
        part.Color=Color3.fromRGB(65+level*12,75+level*15,94+level*12)
        local roof=base.Model:FindFirstChild(id.."Roof")
        roof.Position=part.Position+Vector3.new(0,part.Size.Y/2+0.3,0)
        part:FindFirstChildOfClass("BillboardGui").TextLabel.Text=part.Name.."\nLEVEL "..level
    end
end
function World:ship(base)
    -- Separate visual clone: multiple shipments cannot destroy or move the depot.
    local rocket=base.Rocket:Clone(); rocket.Name="Launched Shipment"; rocket.Parent=self.Root
    local fire=Instance.new("Fire"); fire.Size=7; fire.Heat=12; fire.Parent=rocket
    TweenService:Create(rocket,TweenInfo.new(3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=rocket.CFrame+Vector3.new(0,180,0),Transparency=1}):Play()
    Debris:AddItem(rocket,3.2)
end
function World:release(player)
    for _,base in ipairs(self.Bases) do
        if base.Owner==player then base.Owner=nil; base.Label.Text="AVAILABLE LSD CONTRACT" end
    end
    local robots=self.Robots[player]
    if robots then for _,r in ipairs(robots) do r:Destroy() end end
    self.Robots[player]=nil
end
function World:robot(player,index,tier,position)
    self.Robots[player]=self.Robots[player] or {}
    local list=self.Robots[player]
    if not list[index] then
        local p=World.part(self.Root,"LSD Robot",Vector3.new(2,1.5,2),position,teal)
        p.CanCollide=false; p.CanQuery=false; World.label(p,tier.Name,teal); list[index]=p
    end
    local target=position+Vector3.new(0,1+(index%2)*0.6,0)
    TweenService:Create(list[index],TweenInfo.new(1.8),{Position=target}):Play()
end
return World
