--!nonstrict
local TeleportService=game:GetService("TeleportService")
local MemoryStoreService=game:GetService("MemoryStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Lobby={}
function Lobby.new(g)
    return setmetatable({Game=g,Codes=MemoryStoreService:GetHashMap("MoonScrubbersFriendRooms_v1"),Busy={},Last={}},{__index=Lobby})
end
function Lobby:request(player,mode,code)
    if mode~="Public" and mode~="Solo" and mode~="Friends" and mode~="Join" then return end
    if self.Busy[player] or (self.Last[player] and os.clock()-self.Last[player]<10) then return end
    self.Last[player]=os.clock()
    if mode=="Public" and game.PrivateServerId=="" then self.Game:notice(player,"Public crew session joined. Welcome to your lunar career."); return end
    if RunService:IsStudio() then self.Game:notice(player,"Studio uses local play. Solo/Friends teleporting requires a published experience."); return end
    self.Busy[player]=true
    task.spawn(function()
        local ok,err=pcall(function()
            if mode=="Public" then TeleportService:TeleportAsync(game.PlaceId,{player}); return end
            local reserved
            if mode=="Join" then
                if type(code)~="string" or not code:match("^%x%x%x%x%x%x%x%x$") then error("Enter the eight-character friend code.") end
                reserved=self.Codes:GetAsync(code:upper())
                if not reserved then error("Code expired or not found.") end
            elseif mode=="Solo" or mode=="Friends" then
                reserved=TeleportService:ReserveServerAsync(game.PlaceId)
                if mode=="Friends" then
                    local token=HttpService:GenerateGUID(false):gsub("%-",""):sub(1,8):upper()
                    self.Codes:SetAsync(token,reserved,86400)
                    player:SetAttribute("FriendCode",token)
                    self.Game:notice(player,"Friend room code: "..token..". Copy it before travelling.")
                    -- Code is non-secret join capability, not the reserved-server access code.
                    self.Game.Remotes.RoomCode:FireClient(player,token)
                    task.wait(8)
                end
            else return end
            local options=Instance.new("TeleportOptions"); options.ReservedServerAccessCode=reserved
            options:SetTeleportData({Mode=mode,FriendCode=player:GetAttribute("FriendCode")})
            TeleportService:TeleportAsync(game.PlaceId,{player},options)
        end)
        if not ok and player.Parent then self.Game:notice(player,"Room unavailable: "..tostring(err):sub(1,150)) end
        self.Busy[player]=nil
    end)
end
return Lobby
