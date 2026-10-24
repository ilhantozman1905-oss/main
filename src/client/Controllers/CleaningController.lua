--!nonstrict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Cleaning={}
function Cleaning.start(config,root,input,viewmodel,ui,effects)
    local player=Players.LocalPlayer; local remotes=root:WaitForChild("Remotes"); local c=config.Cleaning
    local world=workspace:WaitForChild("MoonWorld")
    local floors,frames,surfaces={},{},{}
    for _,part in ipairs(world:GetDescendants()) do
        if part:IsA("BasePart") and part:GetAttribute("ZoneId") then floors[part:GetAttribute("ZoneId")]=part end
    end
    -- The server creates geometry before Ready; wait for all streamed/replicated fields.
    while #floors<#config.Zones do
        task.wait(0.1)
        for _,part in ipairs(world:GetDescendants()) do
            if part:IsA("BasePart") and part:GetAttribute("ZoneId") then floors[part:GetAttribute("ZoneId")]=part end
        end
    end
    for id,floor in ipairs(floors) do
        local surface=Instance.new("SurfaceGui"); surface.Name="LocalDustGrid"..id
        surface.Face=Enum.NormalId.Top; surface.Adornee=floor; surface.CanvasSize=Vector2.new(c.Columns*24,c.Rows*24)
        surface.LightInfluence=0.5; surface.Parent=player.PlayerGui; frames[id]={}; surfaces[id]=surface
        for row=1,c.Rows do for column=1,c.Columns do
            local cell=(row-1)*c.Columns+column; local frame=Instance.new("Frame")
            frame.Size=UDim2.fromScale(1/c.Columns,1/c.Rows)
            frame.Position=UDim2.fromScale((column-1)/c.Columns,(row-1)/c.Rows)
            frame.BorderSizePixel=0
            local rgb=config.Zones[id].Color; frame.BackgroundColor3=Color3.fromRGB(rgb[1],rgb[2],rgb[3])
            frame.Parent=surface; frames[id][cell]=frame
        end end
    end
    local ready,queue,revision=false,{},-1
    local progress={}
    local function apply(zones,percent)
        for zoneKey,cells in pairs(zones) do local id=tonumber(zoneKey)
            for cellKey,left in pairs(cells) do local cell=tonumber(cellKey)
            if frames[id] and frames[id][cell] then frames[id][cell].BackgroundTransparency=1-left/c.DustPerCell end
        end end
        for id,value in pairs(percent or {}) do progress[tonumber(id)]=value end
    end
    remotes.CellsChanged.OnClientEvent:Connect(function(zones,percent,incoming)
        if not ready then table.insert(queue,{zones,percent,incoming}); return end
        if incoming<=revision then return end
        revision=incoming; apply(zones,percent)
    end)
    local snapshot=remotes.Snapshot:InvokeServer()
    if not snapshot then task.wait(1.1); snapshot=remotes.Snapshot:InvokeServer() end
    assert(snapshot,"Server profile not ready; please rejoin")
    revision=snapshot.Revision
    for id,z in ipairs(snapshot.Zones) do
        apply({[id]=z.Cells})
        local remaining=0
        for cell,left in ipairs(z.Cells) do
            remaining=remaining+left
            if z.Rare[cell] then frames[id][cell].BackgroundColor3=Color3.fromRGB(255,204,93) end
        end
        progress[id]=1-remaining/(c.Columns*c.Rows*c.DustPerCell)
    end
    for _,delta in ipairs(queue) do if delta[3]>revision then revision=delta[3]; apply(delta[1],delta[2]) end end
    ready=true; ui:setState(snapshot.State)
    remotes.Collected.OnClientEvent:Connect(function(position) effects:collected(position) end)
    local equipped=false; local oldMode,oldMin,oldMax
    local function setEquipped(enabled)
        if equipped==enabled then return end
        equipped=enabled
        if enabled then
            oldMode=player.CameraMode; oldMin=player.CameraMinZoomDistance; oldMax=player.CameraMaxZoomDistance
            player.CameraMode=Enum.CameraMode.LockFirstPerson
            player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=0.5
        else
            player.CameraMode=oldMode or Enum.CameraMode.Classic
            player.CameraMaxZoomDistance=oldMax or 128; player.CameraMinZoomDistance=oldMin or 0.5
        end
        input:setEnabled(enabled); ui.Enabled=enabled; ui:updateHud()
    end
    local rayParams=RaycastParams.new(); rayParams.FilterType=Enum.RaycastFilterType.Include; rayParams.FilterDescendantsInstances=floors
    local lastSent,lastDrive,lastProgress=0,0,0
    RunService:BindToRenderStep("MoonBrush",Enum.RenderPriority.Camera.Value+1,function()
        local camera=workspace.CurrentCamera; if not camera then return end
        local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        local tool=char and char:FindFirstChildOfClass("Tool")
        local enabled=tool~=nil and tool:GetAttribute("MoonTool")==true and hum~=nil and hum.Health>0 and hum.SeatPart==nil and not ui.Modal
        setEquipped(enabled)
        if tool then local brush=tool:FindFirstChild("WorldBrush"); if brush then brush.LocalTransparencyModifier=enabled and 1 or 0 end end
        local helmet=char and char:FindFirstChild("EVAHelmet"); if helmet then helmet.LocalTransparencyModifier=enabled and 1 or 0 end
        local active=enabled and input.held
        local tier=player:GetAttribute("ToolTier") or 1
        viewmodel:update(camera,enabled,active,os.clock(),tier)
        effects:update(active)
        if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") and os.clock()-lastDrive>0.1 then
            lastDrive=os.clock()
            remotes.Drive:FireServer(ui.Modal and Vector2.zero or Vector2.new(hum.SeatPart.SteerFloat,hum.SeatPart.ThrottleFloat))
        end
        if os.clock()-lastProgress>0.5 and char and char:FindFirstChild("HumanoidRootPart") then
            lastProgress=os.clock(); local point=char.HumanoidRootPart.Position
            for id,z in ipairs(config.Zones) do
                surfaces[id].Enabled=(point-Vector3.new(z.X,0,z.Z)).Magnitude<125
                if math.abs(point.X-z.X)<42 and math.abs(point.Z-z.Z)<42 then ui:setProgress(progress[id] or 0,z.Name) end
            end
        end
        if not active or os.clock()-lastSent<1/c.RequestsPerSecond then return end
        lastSent=os.clock()
        local size=camera.ViewportSize; local ray=camera:ViewportPointToRay(size.X/2,size.Y/2)
        local hit=workspace:Raycast(ray.Origin,ray.Direction*config.Tools[tier].Reach,rayParams)
        if hit then remotes.Scrub:FireServer(hit.Position) end
    end)
end
return Cleaning
