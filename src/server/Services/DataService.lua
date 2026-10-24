--!nonstrict
local DSS=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local Rules=require(game.ReplicatedStorage.MoonScrubbers.Shared.GameRules)
local Data={}
function Data.new(config)
    local ok,store=pcall(function() return DSS:GetDataStore("MoonScrubbers_Profiles_v2") end)
    return setmetatable({Config=config,Store=ok and store or nil,
        Token=game.JobId..HttpService:GenerateGUID(false),Sessions={},Saving={}}, {__index=Data})
end
function Data:load(player)
    local key="player_"..player.UserId
    local loaded,locked
    for attempt=1,5 do
        loaded=nil; locked=nil
        local ok=pcall(function()
            self.Store:UpdateAsync(key,function(old)
                old=old or {}
                if old.Lock and old.Lock.Token~=self.Token and old.Lock.Expires>os.time() then locked=true; return nil end
                locked=false; loaded=Rules.normalize(old.Profile,os.time(),self.Config)
                return {Profile=loaded,Lock={Token=self.Token,Expires=os.time()+180}}
            end)
        end)
        if ok and loaded then self.Sessions[player]={Key=key,Memory=false}; return loaded,"Cloud saves active" end
        if locked then
            if attempt==5 then return nil,"Your profile is open on another server. Wait a moment and rejoin." end
            -- Normal teleports may reach the destination just before the source releases its lease.
            task.wait(1.5)
        elseif attempt>=3 then break
        else task.wait(attempt) end
    end
    if RunService:IsStudio() then
        self.Sessions[player]={Memory=true}
        return Rules.new(os.time()),"STUDIO: session only; publish and enable API access for saving"
    end
    return nil,"Saving is unavailable. Rejoin shortly; your existing data has not been overwritten."
end
function Data:save(player,profile,release)
    while self.Saving[player] do task.wait(0.1) end
    local session=self.Sessions[player]
    if not session then return false end
    if session.Memory then if release then self.Sessions[player]=nil end; return true end
    self.Saving[player]=true
    profile.LastSeen=os.time()
    local copy=Rules.clone(profile)
    local success=false
    for attempt=1,3 do
        local wrote=false
        local ok=pcall(function()
            self.Store:UpdateAsync(session.Key,function(old)
                if not old or not old.Lock or old.Lock.Token~=self.Token then wrote=false; return nil end
                wrote=true
                return {Profile=copy,Lock=not release and {Token=self.Token,Expires=os.time()+180} or nil}
            end)
        end)
        if ok and wrote then success=true; break end
        task.wait(attempt)
    end
    self.Saving[player]=nil
    if release then self.Sessions[player]=nil end
    return success
end
return Data
