local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)


function disconnect(a, b)
	for _, con in pairs(a:GetChildren()) do
		if con.ClassName == "ObjectValue" then
			if con.Value == b then
				con:Destroy()
			end
		end
	end
	for _, con in pairs(b:GetChildren()) do
		if con.ClassName == "ObjectValue" then
			if con.Value == a then
				con:Destroy()
			end
		end
	end
end


Button.Info = {
	"Remove Nodes",
	"Remove existing nodes and any Connections to them",
	"http://www.roblox.com/asset/?id=208426068"
}


function Button.Activate(pButton)
	pButton:SetActive(true)
	warn("Click a node to remove it. CANNOT BE UN-DONE.")
end



function Button.MDown(hit, pos)
	if hit ~= nil then
		if hit:IsA("Part") and (hit.Name == "node_walk" or hit.Name == "path_track" or hit.Name == "node_ai") then
			for _, con in pairs(hit:GetChildren()) do
				if con.Name == "Connection" then
					disconnect(hit, con.Value)
				end
			end
			hit:Destroy()
			warn("Node and its Connections removed successfully.", 1.5)
		end
	end
end




return Button