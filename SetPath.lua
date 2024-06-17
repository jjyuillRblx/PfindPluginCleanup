local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)
local PathLib = require(script.Parent.Parent.PathfindingLibrary)
local nodeselected = nil
local nodes = workspace:FindFirstChild("Nodes", true)
local drawnPaths = {}
local spath = {}
local savegui
local continueClick
local saveClick
	
	
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function SavePaths()
	local root = game.ReplicatedStorage:FindFirstChild("SavedPaths")
	if not root then
		root = Instance.new("Folder", game.ReplicatedStorage)
		root.Name = "SavedPaths"
	end

	local fld = Instance.new("Folder", root)
	fld.Name = "SavedPath"
	local nn = 0
	for _, node in pairs(spath) do
		nn = nn + 1
		local ov = Instance.new("ObjectValue", fld)
		ov.Name = "Node"..tostring(nn)
		ov.Value = node
	end
end





Button.Info = {
	"Save Path",
	"Save a path for later use, such as guard patrol paths.",
	"http://www.roblox.com/asset/?id=484993726"
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
	savegui = script.Parent.Parent.SaveGui:clone()
	savegui.Parent = game.CoreGui
	
	continueClick = savegui.Frame.Continue.MouseButton1Click:connect(ContinueClick)
	saveClick = savegui.Frame.Save.MouseButton1Click:connect(SaveClick)
	
	
	nodes = workspace:FindFirstChild("Nodes", true)
	if nodes then
		warn("Click two different nodes to select a path. You can then either save or continue the path.", 4)
	else
		warn("Cannot save paths, nodegraph not found in workspace!")
		pButton:SetActive(false)
	end
end

function Button.Deactivate(pButton)
	for _, path in pairs(drawnPaths) do
		path:Destroy()
	end
	drawnPaths = {}
	if savegui ~= nil then
		savegui:Destroy()
	end
	if continueClick ~= nil then
		continueClick:disconnect()
	end
	if saveClick ~= nil then
		saveClick:disconnect()
	end
end


local prevPathEnd
local lastEndNode

function SaveClick()
	local var
	if pathDrawn then
		var = SavePaths()
	end
	warn("Path saved as 'ReplicatedStorage/SavedPaths/SavedPath' !", 3)
	savegui.Frame.Continue.TextColor3 = Color3.new(112/255, 112/255, 112/255)
	savegui.Frame.Save.TextColor3 = Color3.new(112/255, 112/255, 112/255)
	pathDrawn = false
	for _, path in pairs(drawnPaths) do
		path:Destroy()
	end
	drawnPaths = {}
	lastEndNode = nil
	spath = {}
end


function ContinueClick()
	if pathDrawn then
		warn("Connect the goal of the previous path to a node to continue the path", 3.1)
		savegui.Frame.Continue.TextColor3 = Color3.new(112/255, 112/255, 112/255)
		lastEndNode = prevPathEnd
		pathDrawn = false
	end
end

function Button.MDown(hit, pos)
	if hit ~= nil then
		if hit:IsA("Part") and (hit.Name == "node_walk" or hit.Name == "path_track" or hit.Name == "node_ai") then
			if hit == lastEndNode then
				warn("Cannot connect node to itself!", 2.5)
				return
			end
			if nodeselected ~= nil or lastEndNode ~= nil then
				local MasterTable, mnt_index = PathLib.CollectNodes(nodes)
				local id2 = PathLib.SearchByBrick(MasterTable, hit)
				local id1 = lastEndNode or PathLib.SearchByBrick(MasterTable, nodeselected)
				prevPathEnd = id2
				local path = PathLib.AStar(MasterTable, id1, id2)
				local drawn = PathLib.DrawPath(path)
				drawn.Name = "PluginFoundPath"
				drawn.Parent = workspace.Ignore
				table.insert(drawnPaths, drawn)
				warn("Path found and drawn! Additional info in output", 2.2)
				warn("Path length in nodes: " .. #path .. " , Path length in studs: " .. PathLib.GetPathLength(path))
				if nodeselected ~= nil then
					nodeselected.SELECTION:Destroy()
					nodeselected = nil
				end
				savegui.Frame.Continue.TextColor3 = Color3.new(1, 1, 1)
				savegui.Frame.Save.TextColor3 = Color3.new(1, 1, 1)
				local nnodes = #spath
				local tpath = {}
				for num, node in pairs(path) do
					tpath[#tpath + 1] = node
				end
				for num, node in pairs(tpath) do
					spath[#spath + 1] = node
				end
				if #spath > 0 then
					warn("Path has been extended! Continue or save", 2.2)
				end
				pathDrawn = true
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