--!nonstrict
local Grid=require(game.ReplicatedStorage.MoonScrubbers.Shared.Grid)
local Cleaning={}
function Cleaning.new(gameService)
    local self=setmetatable({Game=gameService,Zones={},Sessions={},Dirty={},Revision=0},{__index=Cleaning})
    local c=gameService.Config.Cleaning
    local random=Random.new()
    for id,zone in ipairs(gameService.World.Zones) do
        local cells,rare={},{}
        for cell=1,c.Columns*c.Rows do cells[cell]=c.DustPerCell; rare[cell]=random:NextNumber()<0.015 end
        self.Zones[id]={Cells=cells,Rare=rare,Floor=zone.Floor,CleanedAt={}}
    end
    return self
end
function Cleaning:snapshot()
    local zones={}
    for id,z in ipairs(self.Zones) do zones[id]={Cells=table.clone(z.Cells),Rare=z.Rare} end
    return {Zones=zones,Revision=self.Revision}
end
function Cleaning:progress(id)
    local remaining=0; for _,v in ipairs(self.Zones[id].Cells) do remaining=remaining+v end
    local c=self.Game.Config.Cleaning
    return 1-remaining/(c.Columns*c.Rows*c.DustPerCell)
end
function Cleaning:take(player,zoneId,position,radius,budget,kind)
    local gameService=self.Game; local p=gameService.Profiles[player]; local z=self.Zones[zoneId]
    if not p or not z or zoneId>p.Zone then return 0 end
    local c=gameService.Config.Cleaning
    local point=z.Floor.CFrame:PointToObjectSpace(position)
    if not Grid.cellAt(point.X,point.Z,c.CellSize,c.Columns,c.Rows) then return 0 end
    local capacity,stored
    if kind=="Robot" then capacity=50+#p.Robots*30+p.Buildings.Depot*50; stored=p.RobotDust
    elseif kind=="Vehicle" then capacity=gameService.Config.Vehicles[p.Vehicle].Capacity; stored=p.VehicleDust
    else capacity=gameService.Rules.capacity(p,gameService.Config); stored=p.Dust end
    local ids=Grid.cellsWithin(point.X,point.Z,radius,c.CellSize,c.Columns,c.Rows)
    local before={}
    for _,cell in ipairs(ids) do before[cell]=z.Cells[cell] end
    local amount,changes=Grid.collect(z.Cells,ids,budget,stored,capacity)
    if amount<=0 then return 0 end
    local value=0
    for cell,left in pairs(changes) do
        -- Value exactly the dust removed, preserving mixed normal/rare cell values.
        local prior=before[cell]
        value=value+math.max(0,prior-left)*(z.Rare[cell] and 8 or 1)
        z.CleanedAt[cell]=os.clock()
    end
    value=value*gameService.Config.Zones[zoneId].Value*gameService.EventMultiplier
    if kind=="Robot" then p.RobotDust=p.RobotDust+amount; p.RobotValue=p.RobotValue+value
    elseif kind=="Vehicle" then p.VehicleDust=p.VehicleDust+amount; p.VehicleValue=p.VehicleValue+value
    else
        gameService.LastClean=gameService.LastClean or {}
        gameService.LastClean[player]=os.clock()
        local nearby=0
        for other in pairs(gameService.Profiles) do
            if other~=player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                if os.clock()-(gameService.LastClean[other] or -math.huge)<5 and (other.Character.HumanoidRootPart.Position-position).Magnitude<25 then nearby=nearby+1 end
            end
        end
        p.Dust=p.Dust+amount; p.TankValue=p.TankValue+value*(1+math.min(0.15,nearby*0.05))
        p.Tutorial=math.max(p.Tutorial,2)
        gameService.Remotes.Collected:FireClient(player,position,amount)
    end
    gameService.Rules.record(p,amount,os.time())
    self.Revision=self.Revision+1
    self.Dirty[zoneId]=self.Dirty[zoneId] or {}
    for cell,left in pairs(changes) do self.Dirty[zoneId][cell]=left end
    gameService:attributes(player)
    return amount
end
function Cleaning:scrub(player,target)
    local g=self.Game; local p=g.Profiles[player]; if not p then return end
    local now=os.clock(); local s=self.Sessions[player] or {}; self.Sessions[player]=s
    if s.Request and now-s.Request<0.09 then return end
    s.Request=now
    if typeof(target)~="Vector3" or not Grid.finiteVector(target.X,target.Y,target.Z) then return end
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    local head=char and char:FindFirstChild("Head"); local tool=char and char:FindFirstChildOfClass("Tool")
    if not hum or hum.Health<=0 or hum.SeatPart or not head or not tool or not tool:GetAttribute("MoonTool") then return end
    local stats=g.Config.Tools[p.Tool]; local direction=target-head.Position
    if direction.Magnitude<0.01 or direction.Magnitude>stats.Reach then return end
    local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={char}
    local hit=workspace:Raycast(head.Position,direction.Unit*(direction.Magnitude+0.25),params)
    local zoneId=hit and hit.Instance:GetAttribute("ZoneId")
    if not zoneId or zoneId>p.Zone or (hit.Position-target).Magnitude>0.6 or hit.Normal.Y<0.8 then return end
    local last,at=s.Target,s.At; s.Target=target; s.At=now; g.LastActive[player]=now
    if not last or now-at>0.5 then return end
    local distance=(target-last).Magnitude
    if distance<g.Config.Cleaning.MinStrokeDistance or distance>g.Config.Cleaning.MaxStrokeDistance then return end
    self:take(player,zoneId,hit.Position,stats.Radius,stats.Rate*(1+p.Buildings.Workshop*0.08)*math.min(now-at,0.2),"Player")
end
function Cleaning:tick()
    local c=self.Game.Config.Cleaning; local now=os.clock()
    for id,z in ipairs(self.Zones) do
        for cell,at in pairs(z.CleanedAt) do
            if now-at>c.RespawnSeconds then
                z.Cells[cell]=c.DustPerCell
                z.CleanedAt[cell]=nil; self.Dirty[id]=self.Dirty[id] or {}; self.Dirty[id][cell]=c.DustPerCell
                self.Revision=self.Revision+1
            end
        end
    end
    if next(self.Dirty) then
        local progress={}; for id in pairs(self.Dirty) do progress[id]=self:progress(id) end
        self.Game.Remotes.CellsChanged:FireAllClients(self.Dirty,progress,self.Revision); self.Dirty={}
    end
end
return Cleaning
