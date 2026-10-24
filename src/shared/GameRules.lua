--!nonstrict
-- Pure progression; mutations are invoked by the server, never by the UI.
local Rules = {}
function Rules.clone(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=Rules.clone(v) end; return out
end
function Rules.new(now)
    return {Schema=2,Cash=0,Dust=0,TankValue=0,Tool=1,Suit=1,Tank=0,Zone=1,
        Robots={},RobotZone=1,RobotDust=0,RobotValue=0,Vehicle=0,VehicleDust=0,VehicleValue=0,
        Prestige=0,Buildings={Depot=0,Workshop=0,Garage=0,HQ=0,Radio=0},
        Capsules=1,Pity=0,Fragments=0,Cosmetics={},Equipped=0,
        TotalCleaned=0,TotalEarned=0,Shipments=0,CapsuleMilestone=0,
        LastSeen=now,LoginDay=-1,Streak=0,DailyDay=-1,WeeklyWeek=-1,
        DailyClean=0,WeeklyClean=0,DailyClaimed=false,WeeklyClaimed=false,Tutorial=1}
end
function Rules.normalize(saved,now,c)
    local p=Rules.new(now)
    if type(saved)=="table" then
        for key,default in pairs(p) do
            if type(saved[key])==type(default) then p[key]=Rules.clone(saved[key]) end
        end
    end
    for key,value in pairs(p) do
        if type(value)=="number" and (value~=value or math.abs(value)==math.huge) then p[key]=0 end
    end
    local function level(key,low,high) p[key]=math.max(low,math.min(high,math.floor(p[key]))) end
    level("Tool",1,#c.Tools); level("Suit",1,#c.Suits); level("Zone",1,#c.Zones)
    level("Vehicle",0,#c.Vehicles); level("Tank",0,10); level("Prestige",0,1000)
    for _,b in ipairs(c.Buildings) do
        p.Buildings[b.Id]=math.max(0,math.min(5,math.floor(tonumber(p.Buildings[b.Id]) or 0)))
    end
    local robots={}
    for _,tier in ipairs(p.Robots) do
        if type(tier)=="number" and tier%1==0 and c.Robots[tier] and #robots<8 then table.insert(robots,tier) end
    end
    p.Robots=robots; p.RobotZone=math.max(1,math.min(p.Zone,math.floor(p.RobotZone)))
    p.Cash=math.max(0,p.Cash); p.Schema=2
    return p
end
function Rules.capacity(p,c) return math.floor(50*1.8^p.Tank*c.Suits[p.Suit].Capacity) end
function Rules.multiplier(p,c) return c.Suits[p.Suit].Bonus*(1+p.Prestige*0.25)*(1+p.Buildings.HQ*0.05) end
function Rules.periods(p,now)
    local day,week=math.floor(now/86400),math.floor(now/604800)
    if p.DailyDay~=day then p.DailyDay=day; p.DailyClean=0; p.DailyClaimed=false end
    if p.WeeklyWeek~=week then p.WeeklyWeek=week; p.WeeklyClean=0; p.WeeklyClaimed=false end
end
function Rules.record(p,amount,now)
    Rules.periods(p,now)
    p.TotalCleaned=p.TotalCleaned+amount; p.DailyClean=p.DailyClean+amount; p.WeeklyClean=p.WeeklyClean+amount
    local milestone=math.floor(p.TotalCleaned/500)
    if milestone>p.CapsuleMilestone then p.Capsules=p.Capsules+milestone-p.CapsuleMilestone; p.CapsuleMilestone=milestone end
end
function Rules.credit(p,amount)
    amount=math.max(0,math.floor(amount+0.5)); p.Cash=p.Cash+amount; p.TotalEarned=p.TotalEarned+amount
    return amount
end
function Rules.sell(p,c)
    if p.Dust+p.VehicleDust<=0 then return false,"Your tanks are empty. Go make a tiny difference." end
    local value=(p.TankValue+p.VehicleValue)*Rules.multiplier(p,c)*(1+p.Buildings.Depot*0.1)
    p.Dust=0; p.TankValue=0; p.VehicleDust=0; p.VehicleValue=0; p.Shipments=p.Shipments+1
    p.Tutorial=math.max(p.Tutorial,3)
    return true,Rules.credit(p,value)
end
function Rules.offer(p,c,kind,index)
    if kind=="Tool" then local v=c.Tools[p.Tool+1]; return v and v.Cost,v and v.Name
    elseif kind=="Suit" then local v=c.Suits[p.Suit+1]; return v and v.Cost,v and v.Name
    elseif kind=="Tank" then return p.Tank<10 and math.floor(80*2.25^p.Tank) or nil,"Tank capacity"
    elseif kind=="Zone" then local v=c.Zones[p.Zone+1]; return v and v.Cost,v and v.Name
    elseif kind=="Vehicle" then local v=c.Vehicles[p.Vehicle+1]; return v and v.Cost,v and v.Name
    elseif kind=="Robot" then local v=c.Robots[index]; return #p.Robots<8 and v and v.Cost or nil,v and v.Name
    elseif kind=="Capsule" then return c.CapsuleCost,"Delivery capsule" end
    for _,b in ipairs(c.Buildings) do
        if kind==b.Id then return p.Buildings[b.Id]<5 and math.floor(b.Cost*2.5^p.Buildings[b.Id]) or nil,b.Name end
    end
    return nil,nil
end
function Rules.purchase(p,c,kind,index)
    local price,name=Rules.offer(p,c,kind,index)
    if not price then return false,"Already maxed out or unavailable." end
    if kind=="Zone" and p.Suit<c.Zones[p.Zone+1].Suit then return false,"Upgrade your suit first." end
    if kind=="Robot" and index>p.Buildings.Radio+1 then return false,"Upgrade your radio tower to unlock this robot." end
    if p.Cash<price then return false,"Not enough credits. Ship more dust!" end
    p.Cash=p.Cash-price
    if kind=="Robot" then table.insert(p.Robots,index)
    elseif kind=="Capsule" then p.Capsules=p.Capsules+1
    elseif p.Buildings[kind]~=nil then p.Buildings[kind]=p.Buildings[kind]+1
    else p[kind]=p[kind]+1 end
    p.Tutorial=math.max(p.Tutorial,4)
    return true,name
end
function Rules.daily(p,now)
    local day=math.floor(now/86400)
    if p.LoginDay==day then return false,"Daily delivery already collected." end
    p.Streak=p.LoginDay==day-1 and p.Streak+1 or 1; p.LoginDay=day; p.Capsules=p.Capsules+1
    return true,Rules.credit(p,100+math.min(p.Streak,7)*50)
end
function Rules.mission(p,now,weekly)
    Rules.periods(p,now)
    local count=weekly and p.WeeklyClean or p.DailyClean
    local claimed=weekly and p.WeeklyClaimed or p.DailyClaimed
    if claimed or count<(weekly and 2000 or 250) then return false,"Mission not ready to claim." end
    if weekly then p.WeeklyClaimed=true else p.DailyClaimed=true end
    p.Capsules=p.Capsules+(weekly and 3 or 1)
    return true,Rules.credit(p,weekly and 3000 or 400)
end
function Rules.open(p,c,roll)
    if p.Capsules<1 then return false,"No capsules. Earn more through cleaning, missions or daily rewards." end
    if type(roll)~="number" or roll~=roll or roll<0 or roll>=1 then return false,"Invalid roll" end
    p.Capsules=p.Capsules-1
    local forced=p.Pity>=c.Pity-1
    local cursor=roll*(forced and 40 or 100)
    local rarity=forced and 2 or 1
    for id,r in ipairs(c.Rarities) do
        if not forced or id>1 then cursor=cursor-r.Weight; if cursor<0 then rarity=id; break end end
    end
    p.Pity=rarity>=2 and 0 or p.Pity+1
    local id=tostring(rarity); local duplicate=p.Cosmetics[id]==true
    if duplicate then p.Fragments=p.Fragments+rarity*10 else p.Cosmetics[id]=true; p.Equipped=rarity end
    return true,{Rarity=rarity,Duplicate=duplicate,Name=c.Rarities[rarity].Name.." EVA finish"}
end
function Rules.offline(p,c,now)
    local seconds=math.max(0,math.min(c.OfflineLimit,now-p.LastSeen)); local rate=0
    for _,tier in ipairs(p.Robots) do rate=rate+c.Robots[tier].Rate end
    p.LastSeen=now
    return Rules.credit(p,seconds*rate*c.Zones[p.RobotZone].Value*0.15)
end
function Rules.prestige(p,c,now)
    if p.Cash<c.PrestigeCost then return false,"Prestige requires 250,000 unspent credits." end
    local fresh=Rules.new(now)
    fresh.Prestige=p.Prestige+1; fresh.Cosmetics=Rules.clone(p.Cosmetics); fresh.Equipped=p.Equipped
    fresh.Fragments=p.Fragments; fresh.Capsules=p.Capsules; fresh.TotalEarned=p.TotalEarned
    fresh.LoginDay=p.LoginDay; fresh.Streak=p.Streak
    for key in pairs(p) do p[key]=nil end
    for key,value in pairs(fresh) do p[key]=value end
    return true,"Rehired! Permanent earnings bonus increased by 25%."
end
return Rules
