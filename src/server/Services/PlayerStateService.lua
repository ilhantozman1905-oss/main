--!nonstrict
local State={}
function State.apply(player,p,config)
    local char=player.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.WalkSpeed=config.Suits[p.Suit].Speed
    hum.UseJumpPower=true; hum.JumpPower=25
    local rgb=(p.Equipped>0 and config.Rarities[p.Equipped] or config.Suits[p.Suit]).Color
    local color=Color3.fromRGB(rgb[1],rgb[2],rgb[3])
    for _,part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" and part.Name~="DustTank" then part.Color=color end
    end
    local tool=char:FindFirstChildOfClass("Tool")
    if not tool and player:FindFirstChild("Backpack") then tool=player.Backpack:FindFirstChildOfClass("Tool") end
    if tool and tool:GetAttribute("MoonTool") then tool.Name="LSD "..config.Tools[p.Tool].Name; tool:SetAttribute("ToolTier",p.Tool) end
    local pack=char:FindFirstChild("DustTank")
    if pack then
        pack.Color=color
        local gui=pack:FindFirstChildOfClass("SurfaceGui")
        if gui then gui.Background.Fill.Size=UDim2.fromScale(1,math.clamp(p.Dust/(player:GetAttribute("TankCapacity") or 50),0,1)) end
    end
end
function State.spawn(player,character,p,config,base)
    local hum=character:WaitForChild("Humanoid",10)
    local torso=character:WaitForChild("HumanoidRootPart",10)
    local bag=player:WaitForChild("Backpack",10)
    if not hum or not torso or not bag or not player.Parent then return end
    character:PivotTo(CFrame.new(base.Position+Vector3.new(0,5,-14)))
    local tool=Instance.new("Tool"); tool.Name="LSD "..config.Tools[p.Tool].Name
    tool.RequiresHandle=false; tool.CanBeDropped=false; tool:SetAttribute("MoonTool",true)
    tool:SetAttribute("ToolTier",p.Tool); tool.Parent=bag
    -- Third-person brush. The first-person viewmodel is separate and local.
    local hand=character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
    if hand then
        local brush=Instance.new("Part"); brush.Name="WorldBrush"; brush.Size=Vector3.new(0.15,0.15,1.5)
        brush.CanCollide=false; brush.CanQuery=false; brush.Massless=true
        brush.Color=Color3.fromRGB(75,220,205); brush.CFrame=hand.CFrame*CFrame.new(0,-0.2,-0.6)
        brush.Parent=tool
        local weld=Instance.new("WeldConstraint"); weld.Part0=hand; weld.Part1=brush; weld.Parent=brush
    end
    local pack=Instance.new("Part"); pack.Name="DustTank"; pack.Size=Vector3.new(1.5,1.9,0.8)
    pack.Massless=true; pack.CanCollide=false; pack.CanQuery=false; pack.CanTouch=false
    local back=character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    if back then
        pack.CFrame=back.CFrame*CFrame.new(0,0,0.9); pack.Parent=character
        local weld=Instance.new("WeldConstraint"); weld.Part0=back; weld.Part1=pack; weld.Parent=pack
        local gui=Instance.new("SurfaceGui"); gui.Face=Enum.NormalId.Back; gui.CanvasSize=Vector2.new(100,150); gui.Parent=pack
        local bg=Instance.new("Frame"); bg.Name="Background"; bg.Size=UDim2.fromScale(0.7,0.8)
        bg.Position=UDim2.fromScale(0.15,0.1); bg.BackgroundColor3=Color3.fromRGB(20,25,36); bg.Parent=gui
        local fill=Instance.new("Frame"); fill.Name="Fill"; fill.AnchorPoint=Vector2.new(0,1)
        fill.Position=UDim2.fromScale(0,1); fill.BackgroundColor3=Color3.fromRGB(248,186,80); fill.Parent=bg
    end
    -- Clear cosmetic accessories; preserve the user's actual avatar data.
    local helmet=Instance.new("Part"); helmet.Name="EVAHelmet"; helmet.Shape=Enum.PartType.Ball
    helmet.Size=Vector3.new(2,2,2); helmet.Transparency=0.55; helmet.Material=Enum.Material.Glass
    helmet.Color=Color3.fromRGB(180,210,235); helmet.CanCollide=false; helmet.CanQuery=false; helmet.Massless=true
    local head=character:FindFirstChild("Head")
    if head then helmet.CFrame=head.CFrame; helmet.Parent=character
        local weld=Instance.new("WeldConstraint"); weld.Part0=head; weld.Part1=helmet; weld.Parent=helmet end
    State.apply(player,p,config)
    -- Start in third person so the base and shop UI are discoverable.
end
return State
