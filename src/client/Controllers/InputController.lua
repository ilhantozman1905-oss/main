--!strict
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Input = {}

function Input.new()
    local self = {held = false, enabled = false}
    UserInputService.WindowFocusReleased:Connect(function() self.held = false end)
    GuiService.MenuOpened:Connect(function() self.held = false end)
    function self:setEnabled(enabled)
        self.enabled, self.held = enabled, false
        ContextActionService:UnbindAction("MoonScrub")
        if not enabled then return end
        ContextActionService:BindAction("MoonScrub", function(_, state)
            self.held = state == Enum.UserInputState.Begin or state == Enum.UserInputState.Change
            return Enum.ContextActionResult.Sink
        end, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
        ContextActionService:SetTitle("MoonScrub", "POETS")
        ContextActionService:SetPosition("MoonScrub", UDim2.fromScale(0.78, 0.55))
    end
    return self
end

return Input
