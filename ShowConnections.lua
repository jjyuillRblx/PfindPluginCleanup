local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)
local PathLib = require(script.Parent.Parent.PathfindingLibrary)
local nodes = workspace:FindFirstChild("Nodes", true)
local Connections = {}
local MasterTable, mnt_index


Button.Info = {
	"Connection View",
	"Show individual Connections/toggle Connection grid",
	""
}


function toggleAll(disable)
	if disable then
		for _, c in pairs(Connections) do
			c:Destroy()
		end
	else
		for _, n in pairs(nodes:GetChildren()) do
			toggleNode(n)
		end
	end
end

function toggleNode(node, disable)
	--gui.DrawLine()
	if disable then
		local localId = PathLib.SearchByBrick(MasterTable, node)
		for id, c in pairs(Connections) do
			if id == localId then
				c:Destroy()
				table.remove(Connections, id)
			end
		end
	else
		for _, c in pairs(node:GetChildren()) do
			if c.Name == "Connection" then
				if c.Value ~= nil then
					local con = c.Value
					local line = Dialog.DrawLine(c.Position, con.Position)
					local id = PathLib.SearchByBrick(MasterTable, node)
					if Connections[id] == nil then
						Connections[id] = {}
						table.insert(Connections[id], line)
					else
						table.insert(Connections[id], line)
					end
				end
			end
		end
	end
end


function Button.Activate(pButton)
	pButton:SetActive(true)
	nodes = workspace:FindFirstChild("Nodes", true)
	if nodes then
		MasterTable, mnt_index = PathLib.CollectNodes(nodes)
		warn("Click nodes to see their Connections, press MOUSE2 to unselect, press 'C' to show ALL Connections")
	else
		warn("'Nodes' not a descendant of Workspace, cannot use this feature")
		pButton:SetActive(false)
	end
end


function Button.MDown(hit, pos)
	if hit ~= nil then
		if hit.Name == "node_walk" then
			if hit:FindFirstChild("Connection") then
				toggleNode(hit)
			else
				warn("Node has no Connections")
			end
		end
	end
end


function Button.M2Down(hit, pos)
	if hit ~= nil then
		if hit.Name == "node_walk" then
			if hit:FindFirstChild("Connection") then
				toggleNode(hit, true)
			end
		end
	end
end

function Button.KeyDown(key)
	if key == "c" then
		toggleAll()
	end
end



return Button