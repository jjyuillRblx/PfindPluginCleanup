local Button = { Active = false }


local Dialog = require(script.Parent.Parent.DialogLib)

Button.Info = {
	"Install Module", 
	"Install the Pathfinding Module", 
	"http://www.roblox.com/asset/?id=207047513"
}


function Button.Activate(pButton)
	pButton:SetActive(true)
	local newMod = script.Parent.Parent.PathfindingLibrary:clone()
	newMod.Parent = workspace
	warn("Pathfinding module has been installed successfully! Check your workspace for the module and examples!")
	pButton:SetActive(false)
end



return Button