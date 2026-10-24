--!nonstrict
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local ContextActionService=game:GetService("ContextActionService")
local GuiService=game:GetService("GuiService")
local TweenService=game:GetService("TweenService")
local RS=game:GetService("ReplicatedStorage")
local Rules=require(RS.MoonScrubbers.Shared.GameRules)
local UI={}
local C={Bg=Color3.fromRGB(13,20,34),Panel=Color3.fromRGB(24,35,53),Card=Color3.fromRGB(33,47,66),
    Teal=Color3.fromRGB(75,226,204),Gold=Color3.fromRGB(255,195,87),Text=Color3.fromRGB(232,240,247),Muted=Color3.fromRGB(151,171,193)}
local function make(class,parent,properties)
    local item=Instance.new(class)
    for key,value in pairs(properties or {}) do item[key]=value end
    item.Parent=parent; return item
end
local function corner(item,radius) make("UICorner",item,{CornerRadius=UDim.new(0,radius or 10)}) end
local function text(parent,content,size,color)
    return make("TextLabel",parent,{BackgroundTransparency=1,Text=content,TextSize=size or 15,
        Font=Enum.Font.GothamMedium,TextColor3=color or C.Text,TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,Size=UDim2.new(1,0,0,26)})
end
local function button(parent,title,callback,color)
    local b=make("TextButton",parent,{Text=title,TextSize=14,Font=Enum.Font.GothamBold,
        BackgroundColor3=color or C.Teal,TextColor3=C.Bg,Size=UDim2.fromOffset(150,38),
        BorderSizePixel=0,AutoButtonColor=true,Selectable=true,Modal=false})
    corner(b,8); b.Activated:Connect(callback); return b
end
local function money(value) return string.format("%s cr",tostring(math.floor(value or 0))) end
function UI.new(config,remotes)
    local player=Players.LocalPlayer
    local self=setmetatable({Config=config,Remotes=remotes,State=nil,Modal=true,Page="Welcome",Enabled=false,ToastId=0}, {__index=UI})
    local gui=make("ScreenGui",player:WaitForChild("PlayerGui"),{Name="MoonHUD",ResetOnSpawn=false,
        IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    self.Gui=gui
    local header=make("Frame",gui,{Position=UDim2.fromOffset(12,10),Size=UDim2.new(1,-24,0,90),BackgroundColor3=C.Bg,BorderSizePixel=0})
    corner(header)
    local brand=text(header,"MOON SCRUBBERS  /  LSD",17,C.Teal); brand.Position=UDim2.fromOffset(14,7); brand.Size=UDim2.new(0.6,-20,0,24)
    self.Cash=text(header,"0 cr",20,C.Gold); self.Cash.TextXAlignment=Enum.TextXAlignment.Right
    self.Cash.Position=UDim2.new(0.6,0,0,7); self.Cash.Size=UDim2.new(0.4,-14,0,24)
    self.Tank=text(header,"TANK  0 / 50",14); self.Tank.Position=UDim2.fromOffset(14,35); self.Tank.Size=UDim2.new(0.55,-14,0,21)
    self.Status=text(header,"Connecting to LSD dispatch…",11,C.Muted); self.Status.Position=UDim2.fromOffset(14,61); self.Status.Size=UDim2.new(1,-28,0,20)
    local track=make("Frame",header,{Position=UDim2.new(0.57,0,0,41),Size=UDim2.new(0.4,0,0,9),BackgroundColor3=C.Card,BorderSizePixel=0})
    corner(track,5); self.Fill=make("Frame",track,{Size=UDim2.fromScale(0,1),BackgroundColor3=C.Teal,BorderSizePixel=0}); corner(self.Fill,5)
    self.Crosshair=make("TextLabel",gui,{Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.fromOffset(15,15),Text="+",TextColor3=C.Teal,TextSize=22,BackgroundTransparency=1})
    local nav=make("ScrollingFrame",gui,{Position=UDim2.new(0,12,1,-58),Size=UDim2.new(1,-24,0,46),
        BackgroundColor3=C.Bg,BorderSizePixel=0,CanvasSize=UDim2.fromOffset(1160,0),ScrollBarThickness=3,
        ScrollingDirection=Enum.ScrollingDirection.X})
    corner(nav)
    make("UIListLayout",nav,{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    for index,page in ipairs({"Brush","Home","Sell","Shop","Base","Zones","Robots","Vehicles","Capsules","Missions","Crew"}) do
        local b=button(nav,page,function()
            if page=="Brush" then
                local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if char:FindFirstChildOfClass("Tool") then hum:UnequipTools()
                    else local bag=player:FindFirstChild("Backpack"); local tool=bag and bag:FindFirstChildOfClass("Tool")
                        if tool then hum:EquipTool(tool) end end
                end
                self:close()
            elseif page=="Home" then remotes.Action:FireServer("Home"); self:close()
            elseif page=="Sell" then remotes.Action:FireServer("Sell")
            else self:open(page) end
        end,(page=="Sell") and C.Gold or C.Teal)
        b.Size=UDim2.fromOffset(98,40); b.LayoutOrder=index
    end
    self.Hint=text(gui,"Equip your brush from the backpack. Clean → HOME → gold shipping pad → SELL.",13,C.Text)
    self.Hint.BackgroundColor3=C.Bg; self.Hint.BackgroundTransparency=0.15
    self.Hint.Position=UDim2.new(0.1,0,1,-105); self.Hint.Size=UDim2.new(0.8,0,0,37); corner(self.Hint,8)
    self.Panel=make("Frame",gui,{Position=UDim2.fromScale(0.5,0.49),AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.new(1,-36,1,-220),BackgroundColor3=C.Panel,BorderSizePixel=0,Visible=true})
    make("UISizeConstraint",self.Panel,{MaxSize=Vector2.new(850,640),MinSize=Vector2.new(280,140)}); corner(self.Panel,14)
    self.Title=text(self.Panel,"LUNAR SURFACE DEPARTMENT",20,C.Teal); self.Title.Position=UDim2.fromOffset(16,12); self.Title.Size=UDim2.new(1,-90,0,32)
    local close=button(self.Panel,"X",function() self:close() end,C.Gold)
    close.Modal=true
    close.Size=UDim2.fromOffset(38,32); close.Position=UDim2.new(1,-50,0,12)
    self.List=make("ScrollingFrame",self.Panel,{Position=UDim2.fromOffset(12,54),Size=UDim2.new(1,-24,1,-66),
        BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()})
    make("UIListLayout",self.List,{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder})
    self.Toast=text(gui,"",16,C.Gold); self.Toast.BackgroundColor3=C.Bg; self.Toast.BackgroundTransparency=0.05
    self.Toast.Position=UDim2.new(0.1,0,0,109); self.Toast.Size=UDim2.new(0.8,0,0,54); self.Toast.Visible=false; self.Toast.ZIndex=8; corner(self.Toast)
    remotes.Notice.OnClientEvent:Connect(function(message) self:notice(message) end)
    remotes.OpenPanel.OnClientEvent:Connect(function(page) self:open(page) end)
    remotes.State.OnClientEvent:Connect(function(state) self:setState(state) end)
    remotes.RoomCode.OnClientEvent:Connect(function(code) self:notice("FRIEND CODE: "..code.." — travelling in 8 seconds"); self.Code=code; self:open("Crew") end)
    remotes.Capsule.OnClientEvent:Connect(function(result) self:reveal(result) end)
    player:GetAttributeChangedSignal("Dust"):Connect(function() self:updateHud() end)
    player:GetAttributeChangedSignal("Cash"):Connect(function() self:updateHud() end)
    player:GetAttributeChangedSignal("TankCapacity"):Connect(function() self:updateHud() end)
    ContextActionService:BindAction("MoonMenu",function(_,state)
        if state==Enum.UserInputState.Begin then
            if self.Modal then self:close() else self:open("Shop") end
        end
        return Enum.ContextActionResult.Sink
    end,false,Enum.KeyCode.M,Enum.KeyCode.ButtonY)
    UserInputService.InputBegan:Connect(function(event,processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        if event.KeyCode==Enum.KeyCode.H then self:send("Home"); self:close() end
    end)
    self:render()
    return self
end
function UI:send(kind,index) self.Pending=true; self.Remotes.Action:FireServer(kind,index) end
function UI:notice(message)
    self.ToastId=self.ToastId+1; local id=self.ToastId
    self.Toast.Text=tostring(message); self.Toast.Visible=true
    task.delay(6,function() if self.ToastId==id then self.Toast.Visible=false end end)
end
function UI:open(page)
    self.Page=page; self.Modal=true; self.Panel.Visible=true; self:render()
    local first=self.List:FindFirstChildWhichIsA("TextButton",true)
    if first then GuiService.SelectedObject=first end
end
function UI:close() self.Modal=false; self.Panel.Visible=false; GuiService.SelectedObject=nil end
function UI:card(title,description,action,callback,color)
    local f=make("Frame",self.List,{Size=UDim2.new(1,-8,0,112),BackgroundColor3=C.Card,BorderSizePixel=0})
    corner(f)
    local titleLabel=text(f,title,16,color or C.Text); titleLabel.Position=UDim2.fromOffset(12,8); titleLabel.Size=UDim2.new(1,-24,0,23)
    local desc=text(f,description,12,C.Muted); desc.Position=UDim2.fromOffset(12,34); desc.Size=UDim2.new(1,-24,0,30)
    if action then local b=button(f,action,callback,color); b.Position=UDim2.fromOffset(12,69); b.Size=UDim2.new(1,-24,0,32) end
    return f
end
function UI:render()
    for _,child in ipairs(self.List:GetChildren()) do if child:IsA("Frame") or child:IsA("TextBox") then child:Destroy() end end
    self.Title.Text=self.Page=="Welcome" and "YOUR LUNAR CAREER STARTS HERE" or string.upper(self.Page).." / LSD DISPATCH"
    local p=self.State; local c=self.Config
    if not p then self:card("Contacting dispatch…","Loading your profile and base. Please wait."); return end
    local function buy(kind,index)
        local price,name=Rules.offer(p,c,kind,index)
        return price and (name.." • "..money(price)) or "MAX LEVEL",function() self:send(kind,index) end
    end
    if self.Page=="Welcome" then
        self:card("The budget only covered a toothbrush.","Your personal base is behind you. Clean the dusty plains, ship dust from your gold depot pad, then upgrade.","START MY SHIFT",function() self:close() end)
        self:card("First mission: become slightly less underfunded","1 Equip brush. 2 Look down, hold + scrub. 3 HOME. 4 Walk to gold pad and SELL. 5 SHOP.","TRAVEL TO DUSTY PLAINS",function() self:send("Travel",1); self:close() end)
        self:card("Daily delivery waiting","Claim free credits and a capsule to start your shift.","CLAIM DAILY DELIVERY",function() self:send("Daily") end,C.Gold)
        self:card("Solo / Public / Friends","Choose a crew mode; Studio supports local test play.","CREW MENU",function() self:open("Crew") end)
    elseif self.Page=="Shop" then
        for _,kind in ipairs({"Tool","Suit","Tank"}) do
            local label,callback=buy(kind)
            local current=kind=="Tool" and c.Tools[p.Tool].Name or kind=="Suit" and c.Suits[p.Suit].Name or (p.Capacity.." dust capacity")
            self:card(kind.." / "..current,"Purchase at your base. Upgrades are permanent and automatically equipped.",label,callback)
        end
    elseif self.Page=="Base" then
        for _,b in ipairs(c.Buildings) do
            local label,callback=buy(b.Id)
            local effects={Depot="+10% sale value per level; robot storage increases.",Workshop="+8% manual cleaning speed per level.",Garage="+4% vehicle speed per level.",HQ="+5% all shipment earnings per level.",Radio="Unlocks the next robot tier (up to tier 4)."}
            self:card(b.Name.." / LEVEL "..p.Buildings[b.Id],effects[b.Id],label,callback)
        end
        self:card("SECONDARY DEPOT","Radio level 2 unlocks remote shipping from the field beacon.","SHIP AT FIELD BEACON",function() self:send("FieldSell") end,C.Gold)
    elseif self.Page=="Zones" then
        local label,callback=buy("Zone"); self:card("Unlock the next contract","Zones require credits and the listed suit level.",label,callback,C.Gold)
        for id,z in ipairs(c.Zones) do
            self:card(z.Name..(id>p.Zone and " / LOCKED" or " / OPEN"),"Dust value x"..z.Value.." • suit level "..z.Suit.." • "..money(z.Cost),
                id<=p.Zone and "TRAVEL" or "LOCKED",function() if id<=p.Zone then self:send("Travel",id); self:close() end end)
        end
    elseif self.Page=="Robots" then
        self:card("AUTOMATION / "..#p.Robots.." of 8 robots","Robots scrub real shared dust and automatically deliver payment. Offline earnings: 15% rate, capped at 3 hours.")
        for id,r in ipairs(c.Robots) do local label,callback=buy("Robot",id)
            self:card(r.Name,r.Rate.." dust/sec • requires radio level "..math.max(0,id-1),label,callback) end
        for id,z in ipairs(c.Zones) do if id<=p.Zone then
            self:card(z.Name,p.RobotZone==id and "Current robot work zone" or "Send all robots to this zone","ASSIGN ROBOTS",function() self:send("RobotZone",id) end)
        end end
    elseif self.Page=="Vehicles" then
        local label,callback=buy("Vehicle"); self:card("GARAGE / "..(p.Vehicle>0 and c.Vehicles[p.Vehicle].Name or "No vehicle"),"Vehicles have independent tanks. Drive to your gold depot pad to unload.",label,callback)
        self:card("DEPLOY CURRENT VEHICLE","Return to base first. Drive with WASD, gamepad stick or touch vehicle controls. Jump to exit.","DEPLOY",function() self:send("SpawnVehicle"); self:close() end,C.Gold)
        self:card("VEHICLE TANK",string.format("%.1f dust stored",p.VehicleDust))
    elseif self.Page=="Capsules" then
        self:card("DELIVERY CAPSULES / "..p.Capsules,"Common 60% • Rare 25% • Epic 10% • Legendary 4% • Mythic 1%","OPEN CAPSULE",function() self:send("Open") end,C.Gold)
        self:card("PITY / "..p.Pity.." of "..c.Pity,"After 19 consecutive Common drops: Rare 62.5%, Epic 25%, Legendary 10%, Mythic 2.5%. Cosmetic finishes only.")
        local label,callback=buy("Capsule"); self:card("EXTRA DELIVERY","Buy with earned credits. No Robux or paid random rewards are enabled.",label,callback)
        self:card("DUPLICATE RECYCLING / "..p.Fragments.." fragments","Duplicates become 10 × rarity-tier fragments. Craft one capsule for 100 fragments.","CRAFT CAPSULE",function() self:send("Craft") end)
        for id,r in ipairs(c.Rarities) do
            self:card(r.Name.." EVA FINISH",p.Cosmetics[tostring(id)] and "Owned • changes suit and brush tint" or "Not yet discovered",
                p.Equipped==id and "EQUIPPED" or "EQUIP",function() self:send("Cosmetic",id) end,Color3.fromRGB(r.Color[1],r.Color[2],r.Color[3]))
        end
    elseif self.Page=="Missions" then
        self:card("DAILY DELIVERY / STREAK "..p.Streak,"Once per UTC day: credits + one capsule. Streak bonuses cap at day 7.","CLAIM LOGIN REWARD",function() self:send("Daily") end,C.Gold)
        self:card("DAILY / "..math.floor(p.DailyClean).." / 250 dust","400 credits + one capsule. "..(p.DailyClaimed and "Already claimed." or "Keep scrubbing."),"CLAIM DAILY MISSION",function() self:send("DailyMission") end)
        self:card("WEEKLY / "..math.floor(p.WeeklyClean).." / 2000 dust","3,000 credits + three capsules. "..(p.WeeklyClaimed and "Already claimed." or "Robots and vehicles count."),"CLAIM WEEKLY MISSION",function() self:send("WeeklyMission") end)
        self:card("CAREER ALBUM",math.floor(p.TotalCleaned).." dust cleaned • "..p.Shipments.." shipments • "..money(p.TotalEarned).." earned")
        self:card("ACHIEVEMENTS",(p.Shipments>0 and "[DONE] First Shipment" or "[ ] First Shipment").." / "..(#p.Robots>0 and "[DONE] Management" or "[ ] Management").." / "..(p.Zone==5 and "[DONE] Moon Master" or "[ ] Moon Master"))
        self:card("PRESTIGE / "..p.Prestige,"Reset cash, upgrades, zones and robots for +25% permanent earnings. Keep cosmetics, fragments and capsules. Requires 250,000 credits.","REHIRE ME…",function() self:open("ConfirmPrestige") end,C.Gold)
    elseif self.Page=="ConfirmPrestige" then
        self:card("CONFIRM CAREER RESET","This spends your current progression and starts a new career with a permanent earnings bonus.","CONFIRM PRESTIGE",function() self:send("Prestige"); self:open("Missions") end,C.Gold)
        self:card("KEEP MY CURRENT CAREER","No changes will be made.","CANCEL",function() self:open("Missions") end)
    elseif self.Page=="Crew" then
        self:card("PUBLIC CREW / UP TO 4 PLAYERS","Clean together for up to +15% dust value when crew members are within 25 studs.","PUBLIC",function() self.Remotes.Lobby:FireServer("Public"); self:close() end)
        self:card("SOLO CONTRACT","Reserve a fresh private server. Published experiences only.","PLAY SOLO",function() self.Remotes.Lobby:FireServer("Solo") end)
        self:card("FRIENDS CONTRACT",(self.Code or p.FriendCode) and ("ROOM CODE: "..(self.Code or p.FriendCode)) or "Create a room and share the eight-character code. Code lasts 24 hours.","CREATE FRIEND ROOM",function() self.Remotes.Lobby:FireServer("Friends") end)
        local box=make("TextBox",self.List,{Size=UDim2.new(1,-8,0,44),PlaceholderText="Enter friend code",Text="",TextColor3=C.Text,BackgroundColor3=C.Card,TextSize=18,Font=Enum.Font.Gotham,ClearTextOnFocus=false})
        corner(box)
        self:card("JOIN A FRIEND","Enter their code above. Codes are shared manually; no direct invite integration yet.","JOIN",function() self.Remotes.Lobby:FireServer("Join",box.Text:upper():gsub("%s", "")) end)
    end
end
function UI:setState(state)
    self.State=state; self:updateHud()
    -- Avoid destroying focused gamepad controls or the friend-code text field on periodic updates.
    if self.Modal and (self.Pending or not self.RenderedPage) then self:render(); self.RenderedPage=true end
    self.Pending=false
end
function UI:updateHud()
    local player=Players.LocalPlayer
    local dust=player:GetAttribute("Dust") or 0; local cap=player:GetAttribute("TankCapacity") or 50
    self.Cash.Text=money(player:GetAttribute("Cash") or 0)
    self.Tank.Text=string.format("TANK  %.1f / %d",dust,cap)
    self.Fill.Size=UDim2.fromScale(math.clamp(dust/cap,0,1),1)
    self.Fill.BackgroundColor3=dust>=cap-0.001 and C.Gold or C.Teal
    local p=self.State
    self.Status.Text=p and (p.Event.."  /  "..(p.SaveStatus or "")) or "Loading profile…"
    if dust>=cap-0.001 then self.Hint.Text="TANK FULL → H / HOME → gold shipping pad → SELL. M / Y opens menus."
    elseif p and p.Tutorial<3 then self.Hint.Text="Equip BRUSH • look down • hold and sweep. M / Y: menu. H: home. Ship on the gold pad."
    else self.Hint.Text="M / Y: menus • H: home. Clean → ship → upgrade. ZONES unlock better dust." end
    self.Crosshair.Visible=self.Enabled and not self.Modal
end
function UI:setProgress(value,zoneName)
    if not self.Modal and self.State then self.Status.Text=string.format("%s • %.1f%% clean  /  %s",zoneName or "Lunar surface",value*100,self.State.Event) end
end
function UI:reveal(result)
    self:open("Capsules")
    local overlay=make("Frame",self.Gui,{Size=UDim2.fromScale(1,1),BackgroundColor3=C.Bg,BackgroundTransparency=0.05,ZIndex=20})
    local r=self.Config.Rarities[result.Rarity]; local color=Color3.fromRGB(r.Color[1],r.Color[2],r.Color[3])
    local title=text(overlay,"DELIVERY INCOMING…",28,C.Gold); title.Size=UDim2.fromScale(0.8,0.25); title.Position=UDim2.fromScale(0.1,0.25); title.TextXAlignment=Enum.TextXAlignment.Center; title.ZIndex=21
    local capsule=make("Frame",overlay,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.57),Size=UDim2.fromOffset(100,120),BackgroundColor3=C.Teal,ZIndex=21})
    corner(capsule,30)
    task.spawn(function()
        for i=1,12 do capsule.Rotation=(i%2==0 and 1 or -1)*(i+3); task.wait(0.07) end
        capsule.Rotation=0; capsule.BackgroundColor3=color
        TweenService:Create(capsule,TweenInfo.new(0.4),{Size=UDim2.fromOffset(150,160)}):Play()
        title.Text=result.Name..(result.Duplicate and "\nDUPLICATE → fragments" or "\nNEW FINISH UNLOCKED"); title.TextColor3=color
        task.wait(2.2); overlay:Destroy(); self:render()
    end)
end
return UI
