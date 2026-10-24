--!nonstrict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Rules=require(ReplicatedStorage.MoonScrubbers.Shared.GameRules)
local State=require(script.Parent.PlayerStateService)
local Game={}
function Game.new(config,world,remotes)
    local self=setmetatable({Config=config,World=world,Remotes=remotes,Rules=Rules,Profiles={},Bases={},
        LastClean={},LastSale={},LastAction={},LastTravel={},LastActive={},LastSnapshot={},EventMultiplier=1,EventEnds=0,Random=Random.new()}, {__index=Game})
    self.Data=require(script.Parent.DataService).new(config)
    self.Cleaning=require(script.Parent.CleaningService).new(self)
    self.Vehicles=require(script.Parent.VehicleService).new(self)
    self.Lobby=require(script.Parent.LobbyService).new(self)
    return self
end
function Game:notice(player,text) if player.Parent then self.Remotes.Notice:FireClient(player,text) end end
function Game:attributes(player)
    local p=self.Profiles[player]; if not p then return end
    player:SetAttribute("Dust",p.Dust); player:SetAttribute("Cash",p.Cash)
    player:SetAttribute("TankCapacity",Rules.capacity(p,self.Config)); player:SetAttribute("ToolTier",p.Tool)
    player:SetAttribute("VehicleDust",p.VehicleDust); player:SetAttribute("CosmeticTier",p.Equipped)
    State.apply(player,p,self.Config)
    local stats=player:FindFirstChild("leaderstats")
    if stats then stats.Credits.Value=math.floor(p.Cash); stats.Cleaned.Value=math.floor(p.TotalCleaned) end
end
function Game:public(player)
    local p=self.Profiles[player]; if not p then return nil end
    Rules.periods(p,os.time())
    local state=Rules.clone(p)
    state.SaveStatus=player:GetAttribute("SaveStatus"); state.Capacity=Rules.capacity(p,self.Config)
    state.Event=self.EventMultiplier>1 and "METEOR SHOWER • 1.5x dust value" or "LSD shift in progress"
    state.Session=game.PrivateServerId=="" and "Public crew" or "Private crew"
    state.FriendCode=player:GetAttribute("FriendCode")
    return state
end
function Game:publish(player)
    self:attributes(player); self.Remotes.State:FireClient(player,self:public(player))
end
function Game:nearBase(player,distance)
    local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    return root and hum and hum.Health>0 and self.Bases[player] and (root.Position-self.Bases[player].Position).Magnitude<distance
end
function Game:travel(player,position)
    if self.LastTravel[player] and os.clock()-self.LastTravel[player]<3 then return false end
    local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return false end
    if hum.SeatPart then self:notice(player,"Jump out of your vehicle before fast travelling."); return false end
    self.LastTravel[player]=os.clock(); hum:UnequipTools()
    char:PivotTo(CFrame.new(position+Vector3.new(0,5,0))); char.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero
    return true
end
function Game:sell(player)
    local p=self.Profiles[player]; local base=self.Bases[player]
    if not p or not self:nearBase(player,60) then return end
    local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position-base.Depot.Position).Magnitude>23 then self:notice(player,"Walk onto the gold SHIP DUST pad at your base."); return end
    if self.LastSale[player] and os.clock()-self.LastSale[player]<1 then return end
    self.LastSale[player]=os.clock()
    local ok,result=Rules.sell(p,self.Config)
    if ok then self.World:ship(base); self:notice(player,"Shipment launched! +"..result.." credits") else self:notice(player,result) end
    self:publish(player)
end
function Game:action(player,kind,index)
    if type(kind)~="string" or #kind>30 then return end
    if index~=nil and (type(index)~="number" or index~=index or index%1~=0 or index<1 or index>20) then return end
    local p=self.Profiles[player]; if not p then return end
    local now=os.clock()
    if self.LastAction[player] and now-self.LastAction[player]<0.18 then return end
    self.LastAction[player]=now; self.LastActive[player]=now
    if kind=="Sell" then self:sell(player); return
    elseif kind=="FieldSell" then
        local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local nearby=false
        if root then for _,z in ipairs(self.World.Zones) do if (root.Position-z.Entry.Position).Magnitude<20 then nearby=true end end end
        if p.Buildings.Radio<2 or not nearby then self:notice(player,"Radio level 2 and proximity to a field beacon are required."); return end
        local ok,result=Rules.sell(p,self.Config)
        if ok then self.World:ship(self.Bases[player]); self:notice(player,"Remote shipment! +"..result.." credits") else self:notice(player,result) end
    elseif kind=="Home" then self:travel(player,self.Bases[player].Position+Vector3.new(0,0,-14)); return
    elseif kind=="Travel" then
        if not index or index>p.Zone then self:notice(player,"Unlock that zone first."); return end
        self:travel(player,self.World.Zones[index].Center+Vector3.new(0,0,-34)); return
    elseif kind=="RobotZone" then
        if not index or index>p.Zone then return end
        p.RobotZone=index; self:notice(player,"Robots assigned to "..self.Config.Zones[index].Name)
    elseif kind=="SpawnVehicle" then
        local ok,msg=self.Vehicles:spawn(player); self:notice(player,msg)
    elseif kind=="Daily" or kind=="DailyMission" or kind=="WeeklyMission" then
        local ok,result
        if kind=="Daily" then ok,result=Rules.daily(p,os.time())
        else ok,result=Rules.mission(p,os.time(),kind=="WeeklyMission") end
        self:notice(player,ok and ("Delivery received! +"..result.." credits and capsules") or result)
    elseif kind=="Open" then
        local ok,result=Rules.open(p,self.Config,self.Random:NextNumber())
        if ok then self.Remotes.Capsule:FireClient(player,result) else self:notice(player,result) end
    elseif kind=="Craft" then
        if p.Fragments<100 then self:notice(player,"100 fragments are needed to craft a capsule.")
        else p.Fragments=p.Fragments-100; p.Capsules=p.Capsules+1 end
    elseif kind=="Cosmetic" then
        if index and p.Cosmetics[tostring(index)] then p.Equipped=index end
    elseif kind=="Prestige" then
        if not self:nearBase(player,55) then self:notice(player,"Return home before rehiring."); return end
        local ok,result=Rules.prestige(p,self.Config,os.time())
        if ok then self.Vehicles:remove(player)
            local robots=self.World.Robots[player]
            if robots then for _,robot in ipairs(robots) do robot:Destroy() end end
            self.World.Robots[player]=nil
            self.World:upgrade(self.Bases[player],p)
            self:travel(player,self.Bases[player].Position) end
        self:notice(player,result)
    else
        if not self:nearBase(player,55) then self:notice(player,"Return to your base to buy upgrades."); return end
        local ok,result=Rules.purchase(p,self.Config,kind,index)
        if ok then self.World:upgrade(self.Bases[player],p); self:notice(player,"Unlocked: "..result)
        else self:notice(player,result) end
    end
    self:publish(player)
end
function Game:add(player)
    local profile,status=self.Data:load(player)
    if not profile then player:Kick(status); return end
    if not player.Parent then self.Data:save(player,profile,true); return end
    local base=self.World:assign(player)
    if not base then self.Data:save(player,profile,true); player:Kick("All lunar bases are occupied."); return end
    self.Profiles[player]=profile; self.Bases[player]=base; self.LastActive[player]=os.clock()
    Rules.periods(profile,os.time()); local offline=Rules.offline(profile,self.Config,os.time())
    player:SetAttribute("SaveStatus",status)
    local data=player:GetJoinData(); local code=data.TeleportData and data.TeleportData.FriendCode
    if type(code)=="string" and #code==8 then player:SetAttribute("FriendCode",code) end
    local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
    for _,name in ipairs({"Credits","Cleaned"}) do local v=Instance.new("IntValue"); v.Name=name; v.Parent=stats end
    self.World:upgrade(base,profile); self:attributes(player)
    local function spawned(character) State.spawn(player,character,profile,self.Config,base) end
    player.CharacterAdded:Connect(spawned)
    if player.Character then task.spawn(spawned,player.Character) end
    player:SetAttribute("Loaded",true)
    if offline>0 then task.delay(5,function() self:notice(player,"Your robots earned "..offline.." credits while you were away (3h cap).") end) end
    local touchConnection
    touchConnection=base.Depot.Touched:Connect(function(hit)
        if self.Profiles[player] and player.Character and hit:IsDescendantOf(player.Character) then self:sell(player) end
    end)
    base.TouchConnection=touchConnection
    self.World.prompt(base.Depot,"SHIP DUST",function(visitor) if visitor==player then self:sell(player) else self:notice(visitor,"This is another cleaner's depot. Use HOME to find yours.") end end)
    for id,part in pairs(base.Buildings) do
        self.World.prompt(part,"OPEN "..id:upper(),function(visitor)
            if visitor==player then self.Remotes.OpenPanel:FireClient(player,id=="Garage" and "Vehicles" or id=="Radio" and "Robots" or id=="HQ" and "Missions" or "Shop") end
        end)
    end
end
function Game:remove(player)
    player:SetAttribute("Loaded",false)
    local p=self.Profiles[player]
    -- Detach gameplay before yielding for save so rewards cannot mutate a departing profile.
    self.Profiles[player]=nil
    if p then self.Data:save(player,p,true) end
    local base=self.Bases[player]
    if base and base.TouchConnection then base.TouchConnection:Disconnect(); base.TouchConnection=nil end
    if base then for _,item in ipairs(base.Model:GetDescendants()) do if item:IsA("ProximityPrompt") then item:Destroy() end end end
    self.Vehicles:remove(player); self.World:release(player)
    self.Bases[player]=nil; self.LastClean[player]=nil; self.LastSale[player]=nil; self.LastAction[player]=nil; self.LastTravel[player]=nil
    self.LastActive[player]=nil; self.LastSnapshot[player]=nil; self.Cleaning.Sessions[player]=nil
    self.Lobby.Last[player]=nil
end
function Game:robots()
    for player,p in pairs(self.Profiles) do
        for index,tier in ipairs(p.Robots) do
            local zone=self.World.Zones[p.RobotZone]; local target=zone.Center+Vector3.new(self.Random:NextNumber(-35,35),0,self.Random:NextNumber(-35,35))
            self.World:robot(player,index,self.Config.Robots[tier],target)
            self.Cleaning:take(player,p.RobotZone,target,4+tier,2*self.Config.Robots[tier].Rate,"Robot")
        end
        if p.RobotDust>0 then
            local pay=Rules.credit(p,p.RobotValue*Rules.multiplier(p,self.Config)*(1+p.Buildings.Depot*0.1))
            p.RobotDust=0; p.RobotValue=0
            self:attributes(player)
        end
    end
end
function Game:start()
    self.Remotes.Action.OnServerEvent:Connect(function(player,kind,index) self:action(player,kind,index) end)
    self.Remotes.Scrub.OnServerEvent:Connect(function(player,target) self.Cleaning:scrub(player,target) end)
    self.Remotes.Drive.OnServerEvent:Connect(function(player,input) self.Vehicles:drive(player,input) end)
    self.Remotes.Lobby.OnServerEvent:Connect(function(player,mode,code)
        if self.Profiles[player] and type(mode)=="string" then self.Lobby:request(player,mode,code) end
    end)
    self.Remotes.Snapshot.OnServerInvoke=function(player)
        if not self.Profiles[player] then return nil end
        if self.LastSnapshot[player] and os.clock()-self.LastSnapshot[player]<1 then return nil end
        self.LastSnapshot[player]=os.clock()
        local out=self.Cleaning:snapshot(); out.State=self:public(player); return out
    end
    Players.PlayerAdded:Connect(function(player) self:add(player) end)
    Players.PlayerRemoving:Connect(function(player) self:remove(player) end)
    for _,player in ipairs(Players:GetPlayers()) do task.spawn(function() self:add(player) end) end
    task.spawn(function()
        local ticks=0
        while true do task.wait(0.15); self.Cleaning:tick(); ticks=ticks+1
            if ticks%14==0 then self:robots() end
            if ticks%20==0 then
                local lines={"CREW LEADERBOARD"}; local list={}
                for player,p in pairs(self.Profiles) do table.insert(list,{Name=player.DisplayName,Value=p.TotalEarned}); self:publish(player) end
                table.sort(list,function(a,b) return a.Value>b.Value end)
                for rank,row in ipairs(list) do table.insert(lines,rank..". "..row.Name.."  $"..math.floor(row.Value)) end
                self.World.Board.Text=table.concat(lines,"\n")
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(60)
            for player,p in pairs(self.Profiles) do task.spawn(function()
                if not self.Data:save(player,p,false) and player.Parent then
                    player:SetAttribute("SaveStatus","SAVE FAILED — reconnect before continuing")
                    -- Stop further progression if the session lease can no longer be renewed.
                    player:Kick("Your save could not be secured. Rejoin shortly to protect your progress.")
                end
            end) end
        end
    end)
    task.spawn(function()
        local radio={"You're paid to clean, not stare at the stars.","LSD budget update: still one toothbrush.","Your robot has requested a union representative."}
        while true do task.wait(45)
            for player in pairs(self.Profiles) do
                if os.clock()-(self.LastActive[player] or 0)>35 then self:notice(player,"LSD RADIO: "..radio[self.Random:NextInteger(1,#radio)]) end
            end
        end
    end)
    task.spawn(function()
        while true do task.wait(240); self.EventMultiplier=1.5
            for player in pairs(self.Profiles) do self:notice(player,"METEOR SHOWER! Dust is worth 1.5x for 60 seconds.") end
            self.Remotes.Event:FireAllClients("Meteor")
            task.wait(60); self.EventMultiplier=1
        end
    end)
    game:BindToClose(function()
        local remaining=0
        for player,p in pairs(self.Profiles) do remaining=remaining+1
            task.spawn(function() self.Data:save(player,p,true); remaining=remaining-1 end) end
        local deadline=os.clock()+25
        while (remaining>0 or next(self.Data.Saving)~=nil) and os.clock()<deadline do task.wait(0.1) end
    end)
end
return Game
