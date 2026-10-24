--!strict
local Players = game:GetService("Players")
local UI = {}

function UI.new()
    local player = Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.IgnoreGuiInset = "MoonHUD", false, false
    gui.Parent = player:WaitForChild("PlayerGui")
    local function label(name, position, size, text)
        local item = Instance.new("TextLabel")
        item.Name, item.Position, item.Size = name, position, size
        item.BackgroundColor3 = Color3.fromRGB(21, 28, 42)
        item.BackgroundTransparency = 0.15
        item.TextColor3 = Color3.fromRGB(237, 241, 245)
        item.Font = Enum.Font.GothamBold
        item.TextSize, item.TextWrapped = 16, true
        item.Text, item.Parent = text, gui
        return item
    end
    local tank = label("Tank", UDim2.fromScale(0.03, 0.03), UDim2.fromScale(0.4, 0.065), "")
    local progress = label("Progress", UDim2.fromScale(0.57, 0.03), UDim2.fromScale(0.4, 0.065), "Zone: 0% schoon")
    local help = label("Help", UDim2.fromScale(0.1, 0.78), UDim2.fromScale(0.8, 0.12), "")
    local crosshair = label("Crosshair", UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 12), "+")
    crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
    crosshair.BackgroundTransparency = 1
    local bar = Instance.new("Frame")
    bar.Size, bar.Position = UDim2.fromScale(0, 0.006), UDim2.fromScale(0.03, 0.097)
    bar.BackgroundColor3 = Color3.fromRGB(214, 185, 126)
    bar.BorderSizePixel, bar.Parent = 0, gui
    local self = {enabled = false}
    function self:update()
        local dust = player:GetAttribute("Dust") or 0
        local capacity = player:GetAttribute("TankCapacity") or 50
        tank.Text = string.format("STOFTANK  %.1f / %d", dust, capacity)
        bar.Size = UDim2.fromScale(0.4 * math.clamp(dust / capacity, 0, 1), 0.006)
        crosshair.Visible = self.enabled
        if dust >= capacity - 0.001 then
            help.Text = "Tank vol! Verkopen volgt in stap 4. Herstart de testsessie om opnieuw te testen."
        elseif self.enabled then
            help.Text = "Kijk omlaag. Houd muis / R2 / POETS vast en beweeg het richtpunt over het stof."
        else
            help.Text = "Rust je LSD Toothbrush uit om te poetsen."
        end
    end
    function self:setProgress(value)
        progress.Text = string.format("ZONE  %.1f%% schoon", value * 100)
    end
    player:GetAttributeChangedSignal("Dust"):Connect(function() self:update() end)
    player:GetAttributeChangedSignal("TankCapacity"):Connect(function() self:update() end)
    self:update()
    return self
end

return UI
