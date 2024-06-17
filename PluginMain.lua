--jjyuill
-- based off StealthKing95 A* plugin. Modified to be more modern. and not make 17k Buttons (Og asset ID: 207049192)

local Buttons = script.Parent.Buttons

local loadOrder = {
	"PlaceNodes",
	"RecalcNodegraph",
	"ManualNodeConnect",
	"ManualDisconnect",
	"NodeRemover",
	"FindPath",
	"InstallModule",
	"SetPath",
	"ConnectionsToggle",
	"DrawSavedPath",
	"ShowIDs"
}

local Toolbar : PluginToolbar = plugin:CreateToolbar("A* Pathing Tools")

local UIS : UserInputService = game.UserInputService
local ActiveCallbacks = { }
local Directory : Folder = game.CollectionService:GetTagged("NodeDirectory")

if not Directory or #Directory == 0 then
	Directory = Instance.new("Folder")
	Directory.Name = "NodeDirectory"
	Directory:AddTag("NodeDirectory")
	Directory.Parent = game.ServerStorage
else
	Directory = Directory[1]
end

shared.Directory = Directory

UIS.InputBegan:Connect(function(IO)
	for _, Func in ActiveCallbacks do
		local s, f = pcall(function()
			Func(string.gsub(tostring(IO.KeyCode), "Enum.KeyCode.", ""))
		end)
		
		if not s then warn(f) end
	end
end)

for _, ButtonName in loadOrder do
	local ButtonStatus, Err = pcall(function()
		local Button : ModuleScript = Buttons:FindFirstChild(ButtonName)
		local Callback : Button = require(Button)

		local PluginButton : PluginToolbarButton = Toolbar:CreateButton(Callback.Info[1], Callback.Info[2], Callback.Info[3])
		local Mouse : Mouse = plugin:GetMouse()

		if Callback.Deactivate ~= nil then
			plugin.Deactivation:connect(Callback.Deactivate)
		end
		
		PluginButton.Click:connect(function()
			if Callback.Click ~= nil then
				Callback.Click()
			end
			
			Callback.Active = not Callback.Active
			
			if Callback.Active then
				plugin:Activate(true)
				
				Callback.Activate(PluginButton)
			else
				if Callback.Deactivate ~= nil then
					Callback.Deactivate(PluginButton)
				end
				
				PluginButton:SetActive(false)
			end
		end)
		
		if Callback.MDown ~= nil then
			Mouse.Button1Down:connect(function()
				Callback.MDown(Mouse.Target, Mouse.Hit.Position)
			end)
		end
		if Callback.M2Down ~= nil then
			Mouse.Button2Down:connect(function()
				Callback.M2Down(Mouse.Target, Mouse.Hit.Position)
			end)
		end
		if Callback.KeyDown ~= nil then
			table.insert(ActiveCallbacks, Callback.KeyDown)
		end
	end)

	if not ButtonStatus then
		error(Err)
	end
end
