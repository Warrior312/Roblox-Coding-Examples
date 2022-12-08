local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local Info = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local ZeroPosition = game.Workspace.Hourglasses.Griffindor.Scaler.Position.Y
local RemovePoints = game.ReplicatedStorage.RemoveAllPoints


RemovePoints.Event:Connect(function(player)
	
	local function removePoints(currentHouse, points, Points)
		for i = 1, points do
			local oldPoint = currentHouse.Points:WaitForChild(tostring(currentHouse.Points:GetAttribute('CurrentPoints')))
			oldPoint.BodyForce.Force = Vector3.new(0, oldPoint:GetMass() * workspace.Gravity * 1.2, 0)
			oldPoint.Anchored = false
			Points:SetAttribute("CurrentPoints", currentHouse.Points:GetAttribute('CurrentPoints') - 1)
			wait(0.00000001)
		end
		wait(1.3)
		local Scaler = currentHouse:FindFirstChild('Scaler')
		if Scaler then
			local highestPart = nil

			for i, v in pairs(currentHouse.Points:GetChildren()) do
				if highestPart == nil then
					highestPart = v
				else
					if v.Position.Y > highestPart.Position.Y and highestPart.Anchored == true then
						highestPart = v
					end
				end
			end
			local Properties
			if currentHouse.Points:GetAttribute('CurrentPoints') == 0 then
				Properties = {Position = Vector3.new(Scaler.Position.X, ZeroPosition, Scaler.Position.Z)}
			else
				Properties = {Position = Vector3.new(Scaler.Position.X, highestPart.Position.Y, Scaler.Position.Z)}
			end

			local Tween = TweenService:Create(Scaler, Info, Properties)
			Tween:Play()
			Scaler.SurfaceGui.TextLabel.Text = tostring(currentHouse.Points:GetAttribute("CurrentPoints"))
		end
	end
	
	removePoints(game.Workspace.Hourglasses.Griffindor, game.Workspace.Hourglasses.Griffindor.Points:GetAttribute('CurrentPoints'),game.Workspace.Hourglasses.Griffindor.Points)
	removePoints(game.Workspace.Hourglasses.Hufflepuff, game.Workspace.Hourglasses.Hufflepuff.Points:GetAttribute('CurrentPoints'),game.Workspace.Hourglasses.Hufflepuff.Points)
	removePoints(game.Workspace.Hourglasses.Ravenclaw, game.Workspace.Hourglasses.Ravenclaw.Points:GetAttribute('CurrentPoints'),game.Workspace.Hourglasses.Ravenclaw.Points)
	removePoints(game.Workspace.Hourglasses.Slytherin, game.Workspace.Hourglasses.Slytherin.Points:GetAttribute('CurrentPoints'),game.Workspace.Hourglasses.Slytherin.Points)
	game.ReplicatedStorage.CompletedPointRemoval:Fire()
end)




Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local messageSplit = string.split(msg, " ")
		local points = tonumber(messageSplit[1])
		local targetedHouse = messageSplit[4]
		local currentHouse = game.Workspace.Hourglasses:FindFirstChild(targetedHouse)
		spawn(function()
			local Points = currentHouse.Points
			
			if string.lower(messageSplit[2]) == 'points' and string.lower(messageSplit[3]) == 'to' then
				
				for i = 1, points do
					Points:SetAttribute("CurrentPoints", currentHouse.Points:GetAttribute('CurrentPoints') + 1)
					local newPoint = currentHouse.PointSpawn:Clone()
					newPoint.Parent = currentHouse.Points
					newPoint.Transparency = 0
					newPoint.Anchored = false
					newPoint.CanCollide = true
					newPoint.Name = tostring(currentHouse.Points:GetAttribute('CurrentPoints'))
					
					spawn(function()
						wait(1)
						newPoint.Anchored = true
					end)
					wait(0.0000000000000000000000001)--(0.001)
					
					
				end
				wait(0.5)
				local Scaler = currentHouse:FindFirstChild('Scaler')
				if Scaler then
					local highestPart = nil

					for i, v in pairs(currentHouse.Points:GetChildren()) do
						if highestPart == nil then
							highestPart = v
						else
							if v.Position.Y > highestPart.Position.Y and highestPart.Anchored == true then
								highestPart = v
							end
						end
					end
					local Properties = {Position = Vector3.new(Scaler.Position.X, highestPart.Position.Y, Scaler.Position.Z)}

					local Tween = TweenService:Create(Scaler, Info, Properties)
					Tween:Play()
					Scaler.SurfaceGui.TextLabel.Text = tostring(currentHouse.Points:GetAttribute("CurrentPoints"))


				end
			elseif string.lower(messageSplit[2]) == 'points' and string.lower(messageSplit[3]) == 'from' then 
				
				
				
				for i = 1, points do
					local oldPoint = currentHouse.Points:WaitForChild(tostring(currentHouse.Points:GetAttribute('CurrentPoints')))
					oldPoint.BodyForce.Force = Vector3.new(0, oldPoint:GetMass() * workspace.Gravity * 1.2, 0)
					oldPoint.Anchored = false
					Points:SetAttribute("CurrentPoints", currentHouse.Points:GetAttribute('CurrentPoints') - 1)
					wait(0.001)
				end
				wait(1.3)
				local Scaler = currentHouse:FindFirstChild('Scaler')
				if Scaler then
					local highestPart = nil
					
					for i, v in pairs(currentHouse.Points:GetChildren()) do
						if highestPart == nil then
							highestPart = v
						else
							if v.Position.Y > highestPart.Position.Y and highestPart.Anchored == true then
								highestPart = v
							end
						end
					end
					local Properties
					if currentHouse.Points:GetAttribute('CurrentPoints') == 0 then
						Properties = {Position = Vector3.new(Scaler.Position.X, ZeroPosition, Scaler.Position.Z)}
					else
						Properties = {Position = Vector3.new(Scaler.Position.X, highestPart.Position.Y, Scaler.Position.Z)}
					end
					
					local Tween = TweenService:Create(Scaler, Info, Properties)
					Tween:Play()
					Scaler.SurfaceGui.TextLabel.Text = tostring(currentHouse.Points:GetAttribute("CurrentPoints"))


				end
			end
		end)
		
	end)
end)

---4.2, 3.7, -14.75
