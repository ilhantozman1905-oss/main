-- Real server action/collection modules under small Roblox-service adapters.
local Rules=dofile("src/shared/GameRules.lua")
local Grid=dofile("src/shared/Grid.lua")
local Config=dofile("src/shared/Config.lua")
local oldRequire=require
local shared={GameRules={},Grid={}}
local stateModule={}
local modules={[shared.GameRules]=Rules,[shared.Grid]=Grid,[stateModule]={apply=function() end}}
_G.game={ReplicatedStorage={MoonScrubbers={Shared=shared}}}
function game:GetService(name)
    if name=="ReplicatedStorage" then return self.ReplicatedStorage end
    return {}
end
_G.script={Parent={PlayerStateService=stateModule}}
_G.require=function(module) if modules[module] then return modules[module] end; return oldRequire(module) end
local Game=dofile("src/server/Services/GameService.lua")
local Cleaning=dofile("src/server/Services/CleaningService.lua")
_G.require=oldRequire
local count=0
local function test(name,run) run(); count=count+1; print("PASS "..name) end
local function near(a,b) assert(math.abs(a-b)<0.00001,tostring(a).." ~= "..tostring(b)) end
local function setup()
    local player={Name="Cleaner"}
    local p=Rules.new(os.time())
    local g=setmetatable({Config=Config,Rules=Rules,Profiles={[player]=p},Bases={[player]={}},
        LastAction={},LastActive={},EventMultiplier=1,LastSale={},World={upgrade=function() end},
        Remotes={Collected={FireClient=function() end}}},{__index=Game})
    g.nearBase=function() return true end
    g.notice=function(self,_,message) self.Message=message end
    g.publish=function() end; g.attributes=function() end
    local cells={}; for id=1,400 do cells[id]=6 end
    local floor={CFrame={PointToObjectSpace=function(_,point) return point end}}
    local clean=setmetatable({Game=g,Zones={{Cells=cells,Rare={},Floor=floor,CleanedAt={}}},Dirty={},Revision=0},{__index=Cleaning})
    return g,clean,player,p
end
test("server rejects malformed action payloads without mutation",function()
    local g,_,player,p=setup(); p.Cash=1000
    g:action(player,{},1); g:action(player,"Tool",0/0); g:action(player,"Tool",999); g:action(player,"Tool",{})
    assert(p.Cash==1000 and p.Tool==1)
end)
test("server rejects purchases away from the player's base",function()
    local g,_,player,p=setup(); p.Cash=1000; g.nearBase=function() return false end
    g:action(player,"Tool"); assert(p.Tool==1 and p.Cash==1000)
end)
test("server charges catalog price and rate limits repeated requests",function()
    local g,_,player,p=setup(); p.Cash=1000
    g:action(player,"Tool"); g:action(player,"Tool")
    assert(p.Tool==2 and p.Cash==900)
end)
test("rare dust is valued from actual drained amount exactly once",function()
    local _,clean,player,p=setup(); local id=Grid.cellAt(2,2,4,20,20); clean.Zones[1].Rare[id]=true
    near(clean:take(player,1,{X=2,Z=2},1.6,5,"Player"),5)
    near(clean:take(player,1,{X=2,Z=2},1.6,5,"Player"),1)
    near(p.TankValue,48); near(p.Dust,6)
end)
test("shared server cells cannot pay two players for the same dust",function()
    local g,clean,a,pa=setup(); local b={}; local pb=Rules.new(os.time()); g.Profiles[b]=pb
    clean:take(a,1,{X=2,Z=2},1.6,5,"Player")
    clean:take(b,1,{X=2,Z=2},1.6,5,"Player")
    near(pa.Dust+pb.Dust,6); near(pa.TankValue+pb.TankValue,6)
end)
test("locked zones and full tanks cannot remove dust",function()
    local _,clean,player,p=setup(); local id=Grid.cellAt(2,2,4,20,20)
    near(clean:take(player,2,{X=2,Z=2},1.6,5,"Player"),0)
    p.Dust=50; near(clean:take(player,1,{X=2,Z=2},1.6,5,"Player"),0)
    assert(clean.Zones[1].Cells[id]==6)
end)
test("vehicle and robot storage never fills the player's backpack",function()
    local _,clean,player,p=setup(); p.Vehicle=1
    clean:take(player,1,{X=2,Z=2},1.6,2,"Vehicle")
    clean:take(player,1,{X=2,Z=2},1.6,2,"Robot")
    assert(p.Dust==0 and p.VehicleDust==2 and p.RobotDust==2)
end)
test("meteor multiplier applies only to newly collected dust",function()
    local g,clean,player,p=setup()
    clean:take(player,1,{X=2,Z=2},1.6,2,"Player"); g.EventMultiplier=1.5
    clean:take(player,1,{X=2,Z=2},1.6,2,"Player")
    near(p.TankValue,5)
end)
print(count.." server integration tests passed")
