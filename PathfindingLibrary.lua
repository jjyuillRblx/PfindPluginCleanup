--Don't touch
local PathLib = {}
local master_node_table, mnt_index

--Touch
local ai_max_range = math.huge
local printAStarPerformance = false

local NormalIds = {
	Enum.NormalId.Front;
	Enum.NormalId.Back;
	Enum.NormalId.Right;
	Enum.NormalId.Left;
	Enum.NormalId.Top;
	Enum.NormalId.Bottom;
}

function PathLib.SearchById(MasterTable, searchId)
	for i, j in pairs(MasterTable) do
		if j.ID == searchId then
			return j.Brick
		end
	end
	return nil
end


function PathLib.SearchByBrick(MasterTable, brick)
	for i, j in pairs(MasterTable) do
		if j.Brick == brick then
			return j.ID
		end
	end
	return nil
end


function drawColoredSurface(part, face)
	local surfGui = Instance.new("SurfaceGui", part)
	surfGui.Name = tostring(face).."Layer"
	surfGui.CanvasSize = Vector2.new(64, 64)
	surfGui.Adornee = part
	surfGui.Face = face
	surfGui.Enabled = true
	local lab = Instance.new("ImageLabel", surfGui)
	lab.Size = UDim2.new(1, 0, 1, 0)
	lab.BorderSizePixel = 1
	return lab
end


local function drawColoredSurfaces(part, color, transparency)
	local labs = {}
	for label = 1, 6 do
		labs[label] = drawColoredSurface(part, NormalIds[label])
	end
	for _, v in pairs(labs) do
		v.BackgroundColor3 = color
		v.BackgroundTransparency = transparency
		v.BorderColor3 = color
	end
end



local function drawLine(p, a, b, c, width)
	local distance = (b.Position - a.Position).Magnitude
	local part = Instance.new("Part", p)
	part.Transparency  = 1
	part.Anchored      = true
	part.CanCollide    = false
	part.TopSurface    = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.formFactor    = Enum.FormFactor.Custom
	part.Size          = Vector3.new(width or 0.2, 0.2, distance)
	part.CFrame        = CFrame.new(b.Position, a.Position) * CFrame.new(0, 0, -distance/2)
	part.Archivable    = false
	local pl = Instance.new("PointLight", part)
	pl.Shadows = true
	pl.Range = 16
	pl.Color = c
	drawColoredSurfaces(part, c, 0.2)
	return part
end


function PathLib.GetPathLength(path)
	local prev = path[1]
	local plen = 0
	for node = 2, #path do
		local dist = (path[node].Position - prev.Position).Magnitude
		plen = plen + dist
	end
	return plen
end


function PathLib.DrawPath(path)
	local drawn = Instance.new("Model", workspace)
	drawn.Name = "DrawnPath"
	local red, green, last
	local num = 0
	local pLen = #path
	local colorInterval = (255 / pLen) / 255
	local a = path[1]
	local b = path[pLen]
	for _, p in pairs(path) do
		if num < 255 then
			num = num + 1
		end
		if not (last == nil)then
			red = num * colorInterval
			drawLine(drawn, last, p, Color3.new(1 - red, red, 0), 2)
		end
		last = p
	end
	return drawn
end


local function nodeObjectFromBrick(brick)
	if brick.ClassName ~= "Part" then
		return nil
	end
	local node_index = mnt_index
	master_node_table[node_index] = {
		ID = mnt_index,
		Brick = brick,
		Connections = {}
	}
	for i, child in pairs(brick:GetChildren()) do
		if child.ClassName == "ObjectValue" and child.Name == "Connection" then
			local brick2 = child.Value
			if brick2 == nil then
				error("Cannot parse nodegraph, Connection value nil at node " .. PathLib.SearchByBrick(master_node_table, brick))
			end
			local ID = PathLib.SearchByBrick(master_node_table, brick2)
			if ID == nil then
				mnt_index = mnt_index + 1
				ID = nodeObjectFromBrick(brick2)
			end
			local con = {
				ID = ID,
				G = (master_node_table[ID].Brick.Position - brick.Position).Magnitude
			}
			table.insert(master_node_table[node_index].Connections, con)
		end
	end

	return node_index
end

function PathLib.CollectNodes(model)
	master_node_table = {}
	mnt_index = 1
	for i, child in pairs(model:GetChildren()) do
		if child.ClassName == "Part" and PathLib.SearchByBrick(master_node_table, child) == nil then
			nodeObjectFromBrick(child)
			mnt_index = mnt_index + 1
		end
	end
	return master_node_table, mnt_index
end



local function heuristic(id1, id2)
	local p1 = master_node_table[id1].Brick.Position
	local p2 = master_node_table[id2].Brick.Position
	return (p1 - p2).Magnitude
end


local function len(t) --returns table length for tables with string indexing
	local l = 0
	for i, j in pairs(t) do
		if j ~= nil then
			l = l + 1
		end
	end
	return l
end



local function getPath(t, n)
	if t[n] == nil then
		return {n}
	else
		local t2 = getPath(t, t[n])
		table.insert(t2, n)
		return t2
	end
end

function PathLib.GetFarthestNode(Position, ReturnBrick, dir, MasterTable)
	local NodeDir = shared.Directory:GetChildren()
	
	local Farthest = NodeDir[1]
	
	for n = 2, #NodeDir do
		local Old = (Farthest.Position - Position).Magnitude
		local new = (Position - NodeDir[n].Position).Magnitude
		
		if new > Old then
			Farthest = NodeDir[n]
		end
	end
	
	return ReturnBrick and Farthest or PathLib.SearchByBrick(MasterTable, Farthest)
end

function PathLib.GetNearestNode(Position, ReturnBrick, dir, MasterTable)
	local NodeDir = shared.Directory:GetChildren()
	
	local Nearest = NodeDir[1]
	
	for n = 2, #NodeDir do
		local Old = (Nearest.Position - Position).Magnitude
		local new = (Position - NodeDir[n].Position).Magnitude
		
		if new < Old then
			Nearest = NodeDir[n]
		end
	end
	
	return ReturnBrick and Nearest or PathLib.SearchByBrick(MasterTable, Nearest)
end

--Combine^

function PathLib.AStar(MasterTable, startID, endID)
	local now = tick()
	local closed = {}
	local open = {startID}
	local previous = {}
	local g_score = {}
	local f_score = {}

	g_score[startID] = 0
	f_score[startID] = heuristic(startID, endID)

	while len(open) > 0 do
		local current, current_i = nil, nil
		for i, j in pairs(open) do
			if current == nil then
				current = j
				current_i = i
			else
				if j ~= nil then
					if f_score[j] < f_score[current] then
						current = j
						current_i = i
					end
				end
			end
		end

		if current == endID then
			local path = getPath(previous, endID)
			local ret = {}
			for i, j in pairs(path) do
				table.insert(ret, MasterTable[j].Brick)
			end
			if printAStarPerformance then
				print("Time taken for AStar to run: "..tostring(tick() - now))
			end
			return ret
		end

		open[current_i] = nil
		table.insert(closed, current)

		for i, j in pairs(MasterTable[current].Connections) do
			local in_closed = false
			for k, l in pairs(closed) do
				if l == j.ID then
					in_closed = true
					break
				end
			end
			if in_closed == false then
				local tentative_score = g_score[current] + j.G
				local in_open = false
				for k, l in pairs(open) do
					if l == j.ID then
						in_open = true
						break
					end
				end
				if in_open == false or tentative_score < g_score[j.ID] then
					previous[j.ID] = current
					g_score[j.ID] = tentative_score
					f_score[j.ID] = g_score[j.ID] + heuristic(j.ID, endID)
					if in_open == false then
						table.insert(open, j.ID)
					end
				end
			end
		end
	end
	return nil
end

return PathLib
