local Button = { Active = false }

local Dialog = require(script.Parent.Parent.DialogLib)

local Connections = 0
local TotalNodes = 0
local Paths = 0

function disconnectAll(Nodes)
	for _, c in pairs(Nodes:children()) do
		if c.Name == "Connection" then
			c:Destroy()
		else
			disconnectAll(c)
		end
	end
end

function connect(a, b)
	local conVal = Instance.new("ObjectValue", a)
	local conVal2 = Instance.new("ObjectValue", b)
	conVal.Name = "Connection"
	conVal2.Name = "Connection"
	conVal.Value = b
	conVal2.Value = a
end


function isConnected(a, b)
	local pos1 = a.Position
	local pos2 = b.Position
	local ray = Ray.new(pos1, (pos2 - pos1).unit * 999)
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, { Dialog.Ignore })
	
	return hit == b
end


function connectNodes(Nodes)
	local Bar = Dialog.ProgressBar("Compiling nodegraph...", 0)
	
	local Start = tick()
	
	for _, n1 in pairs(Nodes:children()) do
		task.wait()
		
		TotalNodes += 1
		
		Bar:TextUpdate("Compiling nodegraph...    ".. TotalNodes.. " / ".. #Nodes.. " \nNodes parsed \n".. (TotalNodes / #Nodes).. "% completed")
		Bar:Update(TotalNodes / #Nodes)
		
		for _, n2 in Nodes:children() do
			Paths = Paths + 1
			
			if isConnected(n1, n2) then
				Connections += 1
				
				connect(n1, n2)
			end
		end
	end
	
	Bar:Kill()
	
	warn("Nodegraph was calculated successfully! The compile took ", (tick() - Start), " seconds. See output for extra information.")
	warn(Connections, "Connections were created on", TotalNodes, "Nodes!") 
	warn(Paths, "possible paths")
	
	TotalNodes = 0
	Connections = 0
	Paths = 0
end


Button.Info = {
	"Recalculate Nodegraph",
	"Calculate or Recalculate an existing Nodegraph in workspace. Will overwrite any previous graph!",
	"http://www.roblox.com/asset/?id=207047507"
}


function Button.Activate(Button)
	Button:SetActive(true)
	
	local Nodes = game.CollectionService:GetTagged("APFNodes") or { }
	
	if Nodes and #Nodes > 0 then
		disconnectAll(Nodes)
		connectNodes(Nodes:GetChildren())
	else
		warn("No Nodes found, Calculation abandoned.")
	end
end



return Button