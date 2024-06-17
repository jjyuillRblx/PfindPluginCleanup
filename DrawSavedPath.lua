local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)
local history = {}
local PathLib = require(script.Parent.Parent.PathfindingLibrary)
local nodeDir = workspace:FindFirstChild("Nodes", true)
local showConnections = true
local nodeselected = nil
local drawnpaths = {}

Button.Info = {
	"Test Saved Path",
	"Draw a selected path folder you have saved with the plugin",
	""
}

function Button.Activate(pButton)
	pButton:SetActive(true)
	local sel = game.Selection:Get()[1]
	if sel.ClassName == "Folder" and string.find(string.lower(sel.Name), "path") then
		local path = {}
		for _, nodeVal in pairs(sel:GetChildren()) do
			table.insert(path, nodeVal.Value)
		end
		if #path > 0 then
			local dpath = PathLib.DrawPath(path)
			table.insert(drawnpaths, dpath)
		else
			warn("Selected path did not contain nodes!", 2.5)
		end
	else
		warn("No valid path folder selected!", 2.5)
		pButton:SetActive(false)
	end
end

function Button.Deactivate(pButton)
	for _, path in pairs(drawnpaths) do
		path:Destroy()
	end
	drawnpaths = {}
end



return Button