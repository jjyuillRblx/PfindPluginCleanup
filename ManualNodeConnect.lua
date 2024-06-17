local Button = { Active = false }
local Dialog = require(script.Parent.Parent.DialogLib)

function selectionbox(part)
	local b = Instance.new("SelectionBox", part)
	b.Name = "SELECTION"
	b.Adornee = part
	b.Visible = true
	
	return b
end

function connect(a, b, draw)
	local conVal = Instance.new("ObjectValue", a)
	local conVal2 = Instance.new("ObjectValue", b)
	conVal.Name = "Connection"
	conVal2.Name = "Connection"
	conVal.Value = b
	conVal2.Value = a
	
	if showConnections then
		Dialog.DrawLine(a.Position, b.Position)
	end
end

Button.Info = {
	"Connect Nodes",
	"Manually connect nodes",
	"http://www.roblox.com/asset/?id=207047511"
}

function Button.Activate(pButton)
	warn("Click 2 nodes to connect them, Press C to toggle showing new Connections,  Press Z to unselect node")
	pButton:SetActive(true)
end

function Button.MDown(hit, pos)
	if hit ~= nil then
		if hit:IsA("Part") and (hit.Name == "node_walk" or hit.Name == "path_track" or hit.Name == "node_ai") then
			if hit == nodeselected then
				warn("Cant connect node to itself!", 1.5)
			else
				if nodeselected ~= nil then
					connect(hit, nodeselected)
					warn("Nodes connected!", 1)
					nodeselected.SELECTION:Destroy()
					nodeselected = nil
				else
					warn("Node selected!", 1)
					selectionbox(hit)
					nodeselected = hit
				end
			end
		end
	end
end

function Button.KeyDown(key)
	key = key:lower()
	if key == "c" then
		showConnections = not showConnections
		warn("Changed showing Connections to: "..tostring(showConnections))
	elseif key == "z" then
		warn("Node unselected!", 1.5)
		nodeselected.SELECTION:Destroy()
		nodeselected = nil
	end
end

return Button