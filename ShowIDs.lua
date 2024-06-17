local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)
local PathLib = require(script.Parent.Parent.PathfindingLibrary)
local nodes = workspace:FindFirstChild("Nodes", true)
local MasterTable, mnt_index


Button.Info = {
	"Show IDs",
	"Show node IDs",
	""
}

--localId = PathLib.SearchByBrick(MasterTable, node)

function bbgui(p, text)
	local bg = Instance.new("BillboardGui", p)
	local lb = Instance.new("TextLabel", bg)
	bg.Adornee = p
	bg.Name = "NodeIdDisplay"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.StudsOffset = Vector3.new(0, 2, 0)
	lb.Size = UDim2.new(1, 0, 1, 0)
	lb.BackgroundTransparency = 1
	lb.TextColor3 = Color3.new(1, 1, 1)
	lb.FontSize = Enum.FontSize.Size24
	lb.Text = text
	return bg
end


function Button.Activate(pButton)
	pButton:SetActive(true)
	nodes = workspace:FindFirstChild("Nodes", true)
	if nodes then
		if #nodes:GetChildren() > 0 then
			MasterTable, mnt_index = PathLib.CollectNodes(nodes)
			for _, node in pairs(nodes:GetChildren()) do
				if node:FindFirstChild("NodeIdDisplay") then
					node.NodeIdDisplay:Destroy()
				else
					local id = PathLib.SearchByBrick(MasterTable, node)
					bbgui(node, "#" .. id)
				end
			end
			pButton:SetActive(false)
		else
			warn("Nodes model is empty, cannot use this feature")
			pButton:SetActive(false)
		end
	else
		warn("'Nodes' not a descendant of Workspace, cannot use this feature")
		pButton:SetActive(false)
	end
end




return Button