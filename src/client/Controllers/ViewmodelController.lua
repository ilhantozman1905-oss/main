--!nonstrict
local V={}
function V.new(config)
    local self={Model=Instance.new("Model"),Parts={},Tier=0}
    self.Model.Name="LSD First Person Tool"
    function self:build(tier,cosmetic)
        self.Model:ClearAllChildren(); self.Parts={}; self.Tier=tier; self.Cosmetic=cosmetic
        local function part(name,size,color,offset,shape)
            local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Color=color
            p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.CastShadow=false
            if shape then p.Shape=shape end
            p.Parent=self.Model; table.insert(self.Parts,{Part=p,Offset=offset})
        end
        local rgb=cosmetic>0 and config.Rarities[cosmetic].Color or {70,205,195}
        local tint=Color3.fromRGB(rgb[1],rgb[2],rgb[3])
        part("EVA Glove",Vector3.new(0.3,0.35,0.45),Color3.fromRGB(235,237,240),CFrame.new(0,-0.1,0))
        if tier<6 then
            part("Handle",Vector3.new(0.1+tier*0.015,0.1,1+tier*0.08),tint,CFrame.new(0,0,-0.4))
            part("Brush Head",Vector3.new(0.2+tier*0.12,0.12,0.3+tier*0.08),tint,CFrame.new(0,0,-1))
            part("Bristles",Vector3.new(0.18+tier*0.12,0.14,0.25+tier*0.08),Color3.fromRGB(236,225,184),CFrame.new(0,0.12,-1))
        else
            part("Vacuum Body",Vector3.new(0.45,0.45,0.8),tint,CFrame.new(0,0,-0.45))
            part("Nozzle",Vector3.new(0.2,0.2,1),Color3.fromRGB(95,111,140),CFrame.new(0,0,-1.15))
            if tier==8 then part("Laser Core",Vector3.new(0.08,0.08,1.4),Color3.fromRGB(190,125,255),CFrame.new(0,0,-1.7)) end
        end
    end
    function self:update(camera,enabled,held,time,tier)
        local cosmetic=game:GetService("Players").LocalPlayer:GetAttribute("CosmeticTier") or 0
        if tier~=self.Tier or cosmetic~=self.Cosmetic then self:build(tier,cosmetic) end
        self.Model.Parent=enabled and camera or nil
        if not enabled then return end
        local stroke=held and math.sin(time*(tier<6 and 24 or 35)) or 0
        local pose=camera.CFrame*CFrame.new(0.55+stroke*(tier<6 and 0.12 or 0.02),-0.48,-0.85)*CFrame.Angles(math.rad(-12),math.rad(-15+stroke*6),math.rad(-12))
        for _,item in ipairs(self.Parts) do item.Part.CFrame=pose*item.Offset end
    end
    return self
end
return V
