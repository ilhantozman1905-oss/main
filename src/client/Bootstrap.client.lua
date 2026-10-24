--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local root = ReplicatedStorage:WaitForChild("MoonScrubbers")
while not root:GetAttribute("Ready") do root:GetAttributeChangedSignal("Ready"):Wait() end
local Config = require(root.Shared.Config)
local controllers = script.Parent.Controllers
local input = require(controllers.InputController).new()
local viewmodel = require(controllers.ViewmodelController).new()
local ui = require(controllers.UIController).new()
local effects = require(controllers.EffectsController).new(Config)
require(controllers.CleaningController).start(Config, root, input, viewmodel, ui, effects)
