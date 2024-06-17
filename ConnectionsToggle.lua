local Button = { }

local Dialog = require(script.Parent.Parent.DialogLib)
local Directory : Folder = game.CollectionService:GetTagged("NodeDirectory")

Button.Info = {
	"Show Connections",
	"Show Connections",
	""
}

function Button.Activate(pButton)
	pButton:SetActive(true)
	
	for _, Node in Directory do
		for _, con in Node:GetChildren() do
			if con.ClassName == "ObjectValue" and con.Name == "Connection" then
				local Node2 = con.Value
				
				Dialog.DrawLine(Node.Position, Node2.Position, 2)
			end
		end
	end
end

function Button.Deactivate()
	Dialog.DestroyLines()
end

return Button