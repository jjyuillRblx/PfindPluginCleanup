local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)
local PathLib = require(script.Parent.Parent.PathfindingLibrary)
local nodeselected = nil
local nodes = workspace:FindFirstChild("Nodes", true)
local drawnPaths = {}

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

Button.Info = {
	"Test Path",
	"Test a path on an existing nodegraph in workspace by selecting two nodes (path will be drawn)",
	"http://www.roblox.com/asset/?id=207047513"
}

function selectionbox(part)
	local b = Instance.new("SelectionBox", part)
	b.Name = "SELECTION"
	b.Adornee = part
	b.Visible = true
	return b
end


function Button.Activate(pButton)
	pButton:SetActive(true)
	nodes = workspace:FindFirstChild("Nodes", true)
	if nodes then
		warn("Click any 2 nodes to find the shortest path between them. 'Z' un-selects node, 'X' deletes drawn paths", 4)
	else
		warn("Cannot find paths, nodegraph not found in workspace!")
		pButton:SetActive(false)
	end
end

function Button.Deactivate(pButton)
	for _, path in pairs(drawnPaths) do
		path:Destroy()
	end
	drawnPaths = {}
end

function Button.MDown(hit, pos)
	if hit ~= nil then
		if hit:IsA("Part") and (hit.Name == "node_walk" or hit.Name == "path_track" or hit.Name == "node_ai") then
			if nodeselected ~= nil then
				local MasterTable, mnt_index = PathLib.CollectNodes(nodes)
				local id1 = PathLib.SearchByBrick(MasterTable, hit)
				local id2 = PathLib.SearchByBrick(MasterTable, nodeselected)
				local path = PathLib.AStar(MasterTable, id1, id2)
				local drawn = PathLib.DrawPath(path)
				drawn.Name = "PluginFoundPath"
				drawn.Parent = workspace.Ignore
				table.insert(drawnPaths, drawn)
				warn("Path found and drawn! Additional info in output", 2.2)
				warn("Path length in nodes: " .. #path .. " , Path length in studs: " .. PathLib.GetPathLength(path))
				nodeselected.SELECTION:Destroy()
				nodeselected = nil
			else
				selectionbox(hit)
				nodeselected = hit
				warn("Node selected!", 1.5)
			end
		end
	end
end



function Button.KeyDown(key)
	if key == "z" then
		if nodeselected ~= nil then
			nodeselected.SELECTION:Destroy()
			nodeselected = nil
			warn("Canceled node select", 1.5)
		end
	elseif key == "x" then
		for k,v in pairs(workspace.Ignore:children()) do
			if v.Name == "PluginFoundPath" then
				v:Destroy()
			end
		end
	end
end




return Button