local Rules=dofile("src/shared/GameRules.lua")
local C=dofile("src/shared/Config.lua")
local count=0
local function test(name,run) run(); count=count+1; print("PASS "..name) end
local function near(a,b) assert(math.abs(a-b)<0.00001,tostring(a).." ~= "..tostring(b)) end
local function profile() return Rules.new(1800000000) end

test("first complete shift sells actual dust and purchases first tool",function()
    local p=profile(); p.Dust=50; p.TankValue=50
    assert(Rules.sell(p,C)); assert(p.Cash==50 and p.Dust==0 and p.TankValue==0)
    p.Dust=50; p.TankValue=50; assert(Rules.sell(p,C))
    assert(Rules.purchase(p,C,"Tool")); assert(p.Tool==2 and p.Cash==0)
end)
test("empty sale cannot mint credits",function()
    local p=profile(); assert(not Rules.sell(p,C)); assert(p.Cash==0)
end)
test("mixed zone and vehicle values survive until sale",function()
    local p=profile(); p.Dust=20; p.TankValue=50; p.VehicleDust=100; p.VehicleValue=300
    local ok,amount=Rules.sell(p,C); assert(ok); near(amount,350)
    assert(p.VehicleDust==0 and p.VehicleValue==0 and p.Shipments==1)
end)
test("insufficient funds never deduct or grant upgrades",function()
    local p=profile(); local ok=Rules.purchase(p,C,"Suit")
    assert(not ok and p.Suit==1 and p.Cash==0)
end)
test("zone suit prerequisite is checked before charging",function()
    local p=profile(); p.Cash=10000
    assert(not Rules.purchase(p,C,"Zone")); assert(p.Cash==10000)
    assert(Rules.purchase(p,C,"Suit")); assert(Rules.purchase(p,C,"Zone")); assert(p.Zone==2)
end)
test("capacities increase with both tank and suit",function()
    local p=profile(); p.Cash=10000; assert(Rules.capacity(p,C)==50)
    assert(Rules.purchase(p,C,"Tank")); assert(Rules.capacity(p,C)==90)
    assert(Rules.purchase(p,C,"Suit")); assert(Rules.capacity(p,C)==135)
end)
test("building upgrades cap at five and cannot overcharge",function()
    local p=profile(); p.Cash=10000000
    for _=1,5 do assert(Rules.purchase(p,C,"Depot")) end
    local cash=p.Cash; assert(not Rules.purchase(p,C,"Depot")); assert(p.Cash==cash)
end)
test("robot unlocks and ownership cap are enforced",function()
    local p=profile(); p.Cash=10000000
    assert(not Rules.purchase(p,C,"Robot",4)); p.Buildings.Radio=3
    for _=1,8 do assert(Rules.purchase(p,C,"Robot",4)) end
    local cash=p.Cash; assert(not Rules.purchase(p,C,"Robot",1)); assert(p.Cash==cash)
end)
test("daily login is once per UTC day with streak reset",function()
    local p=profile(); local now=1800000000
    assert(Rules.daily(p,now)); local cash=p.Cash
    assert(not Rules.daily(p,now+1)); assert(p.Cash==cash)
    assert(Rules.daily(p,now+86400)); assert(p.Streak==2)
    assert(Rules.daily(p,now+4*86400)); assert(p.Streak==1)
end)
test("missions cannot be claimed early or twice",function()
    local p=profile(); local now=1800000000
    assert(not Rules.mission(p,now,false)); Rules.record(p,250,now)
    assert(Rules.mission(p,now,false)); local cash=p.Cash
    assert(not Rules.mission(p,now,false)); assert(p.Cash==cash)
    Rules.periods(p,now+86400); assert(p.DailyClean==0 and not p.DailyClaimed)
end)
test("all capsule rarity boundaries match published probabilities",function()
    for _,case in ipairs({{0,1},{0.5999,1},{0.6,2},{0.8499,2},{0.85,3},{0.95,4},{0.99,5},{0.9999,5}}) do
        local p=profile(); local ok,reward=Rules.open(p,C,case[1]); assert(ok and reward.Rarity==case[2])
    end
end)
test("pity guarantees rare or better and resets on a rare",function()
    local p=profile(); p.Capsules=25
    for _=1,19 do local ok,r=Rules.open(p,C,0); assert(ok and r.Rarity==1) end
    assert(p.Pity==19); local ok,r=Rules.open(p,C,0); assert(ok and r.Rarity==2 and p.Pity==0)
end)
test("duplicates become fragments and do not create ownership copies",function()
    local p=profile(); p.Capsules=2
    local _,a=Rules.open(p,C,0.99); local _,b=Rules.open(p,C,0.99)
    assert(not a.Duplicate and b.Duplicate); assert(p.Fragments==50)
end)
test("invalid and empty capsule rolls preserve inventory",function()
    local p=profile(); assert(not Rules.open(p,C,1)); assert(p.Capsules==1)
    p.Capsules=0; assert(not Rules.open(p,C,0)); assert(p.Capsules==0)
end)
test("cleaning milestones grant each capsule once",function()
    local p=profile(); Rules.record(p,499,1800000000); assert(p.Capsules==1)
    Rules.record(p,1,1800000000); assert(p.Capsules==2)
    Rules.record(p,1,1800000000); assert(p.Capsules==2)
end)
test("offline earnings cap at three hours and reject future clock gains",function()
    local p=profile(); p.Robots={1}; p.LastSeen=0
    local amount=Rules.offline(p,C,999999); near(amount,math.floor(C.OfflineLimit*1.2*0.15+0.5))
    p.LastSeen=9999999; assert(Rules.offline(p,C,2)==0)
end)
test("prestige preserves collectibles but resets the business",function()
    local p=profile(); p.Cash=C.PrestigeCost; p.Tool=5; p.Robots={1,2}; p.Cosmetics["5"]=true; p.Equipped=5
    assert(Rules.prestige(p,C,1800000000)); assert(p.Prestige==1 and p.Cash==0 and p.Tool==1 and #p.Robots==0)
    assert(p.Cosmetics["5"] and p.Equipped==5); near(Rules.multiplier(p,C),1.25)
end)
test("old and malformed numeric profile fields are normalized",function()
    local p=Rules.normalize({Tool=100,Suit=-1,Tank=0/0,Cash=math.huge,Robots={1,99,"2"}},1800000000,C)
    assert(p.Tool==#C.Tools and p.Suit==1 and p.Tank==0 and p.Cash==0 and #p.Robots==1)
end)
test("late game tools suits zones and vehicles are reachable without Robux",function()
    local p=profile(); p.Cash=10000000
    for _=2,#C.Tools do assert(Rules.purchase(p,C,"Tool")) end
    for _=2,#C.Suits do assert(Rules.purchase(p,C,"Suit")) end
    for _=2,#C.Zones do assert(Rules.purchase(p,C,"Zone")) end
    for _=1,#C.Vehicles do assert(Rules.purchase(p,C,"Vehicle")) end
    assert(p.Zone==5 and p.Tool==8 and p.Suit==4 and p.Vehicle==6)
end)
print(count.." economy/progression tests passed")
