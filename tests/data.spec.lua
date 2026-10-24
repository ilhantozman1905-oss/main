local Rules=dofile("src/shared/GameRules.lua")
local C=dofile("src/shared/Config.lua")
local player={UserId=42}
local state,unavailable,studio,sequence=nil,false,false,0
local store={}
function store:UpdateAsync(_,callback)
    if unavailable then error("service unavailable") end
    local result=callback(Rules.clone(state))
    if result then state=Rules.clone(result) end
    return state
end
local module={}; local services={
    DataStoreService={GetDataStore=function() return store end},
    RunService={IsStudio=function() return studio end},
    HttpService={GenerateGUID=function() sequence=sequence+1; return tostring(sequence) end},
}
_G.game={JobId="test-server",ReplicatedStorage={MoonScrubbers={Shared={GameRules=module}}}}
function game:GetService(name) return services[name] end
_G.task={wait=function() end}
local oldRequire=require
_G.require=function(m) if m==module then return Rules end; return oldRequire(m) end
local Data=dofile("src/server/Services/DataService.lua")
_G.require=oldRequire
local count=0
local function test(name,run) state=nil; unavailable=false; studio=false; run(); count=count+1; print("PASS "..name) end
test("session lock prevents concurrent profile ownership",function()
    local a=Data.new(C); local b=Data.new(C)
    assert(a:load(player)); assert(not b:load(player))
end)
test("saving and releasing allows a new server to recover progression",function()
    local a=Data.new(C); local p=a:load(player); p.Cash=1234; p.Robots={2}
    assert(a:save(player,p,true))
    local b=Data.new(C); local nextProfile=b:load(player)
    assert(nextProfile.Cash==1234 and nextProfile.Robots[1]==2)
end)
test("production load failures never create a writable fresh profile",function()
    unavailable=true; local a=Data.new(C)
    local p=a:load(player); assert(p==nil and a.Sessions[player]==nil)
end)
test("Studio fallback is explicitly memory-only",function()
    unavailable=true; studio=true; local a=Data.new(C)
    local p,status=a:load(player)
    assert(p and status:match("session only") and a.Sessions[player].Memory)
    assert(a:save(player,p,true))
end)
test("a server that lost its lease cannot overwrite another save",function()
    local a=Data.new(C); local p=a:load(player); p.Cash=9999
    state.Lock.Token="another-server"; state.Profile.Cash=7
    assert(not a:save(player,p,false)); assert(state.Profile.Cash==7)
end)
print(count.." persistence tests passed")
