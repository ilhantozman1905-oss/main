--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local root=RS:WaitForChild("MoonScrubbers")
local config=require(root.Shared.Config)
local folder=Instance.new("Folder"); folder.Name="Remotes"; folder.Parent=root
local remotes={}
for _,name in ipairs({"Scrub","Collected","CellsChanged","Action","State","Notice","Capsule","OpenPanel","Drive","Lobby","RoomCode","Event"}) do
    local event=Instance.new("RemoteEvent"); event.Name=name; event.Parent=folder; remotes[name]=event
end
local snapshot=Instance.new("RemoteFunction"); snapshot.Name="Snapshot"; snapshot.Parent=folder; remotes.Snapshot=snapshot
local world=require(script.Parent.Services.WorldService).start(config)
local service=require(script.Parent.Services.GameService).new(config,world,remotes)
service:start(); root:SetAttribute("Ready",true)
print("[Moon Scrubbers] "..config.Version.." — clean, ship, upgrade, explore!")
