local Module = { }
local Parts = { }

function Module.DestroyLines()
	for	_, Part in Parts do
		Part:Destroy()
	end
	
	Parts = { }
end

function Module.DrawLine(Pos1, Pos2, Width)
	local Ignore = Module.Ignore
	
	if not Ignore then
		Ignore = Instance.new("Folder")
		Ignore.Name = "Ignore"
		Ignore.Parent = workspace
		
		Module.Ignore = Ignore
	end
	
	local Distance = (Pos1 - Pos2).Magnitude
	local RayPart = script.NodeConnector:Clone()
	RayPart.Size = Vector3.new(Width or 0.2, 0.2, Distance)
	RayPart.CFrame = CFrame.new(Pos1, Pos2) * CFrame.new(0, 0, -Distance / 2)
	RayPart.Archivable = false
	
	RayPart.Parent = Ignore
	
	return RayPart
end

function Module.ProgressBar(Start)
	local Gui = script.Progress:Clone()
	Gui = game:GetService("CoreGui")
	
	local Label = Gui.Main.TextLabel
	local Progress = Gui.Main.Progress
	
	Progress.Size = UDim2.new(Start / 100, 0, 1, 0)
	
	return {
		Update = function(Percent)
			Progress.Size = UDim2.new(Percent, 0, 1, 0)
		end;
		TextUpdate = function(Text)
			Label.Text = Text
		end;
		Kill = function(Time)
			task.wait(Time or 0)
			
			Gui:Destroy()
		end
	}
end

return Module
