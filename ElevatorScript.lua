local Elevator = {}

--Global Services--
local TweenService = game:GetService('TweenService')
--Global Variable Information--
local totalTime = 5
local maxModelsTweening = 5
local newSegment = game.ReplicatedStorage:WaitForChild('Clone')
local newFloor = game.ReplicatedStorage:WaitForChild('1FloorClone')
--Global Tween Information--
local LiftControls = require(game.Workspace:FindFirstChild('Lift'):FindFirstChild('LiftControls'))
local soundVolume = TweenInfo.new(totalTime, Enum.EasingStyle.Linear)

local emitterProperties = {Rate = 0}
local emitterInfo = TweenInfo.new(totalTime, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)

local defaultTweenTime = TweenInfo.new(totalTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local floorTweenTime = TweenInfo.new(totalTime, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
--Metatable Indexing--
Elevator.__index = Elevator
--Creates a new Elevator instance with specified variables--
function Elevator.new(position, isFilled)
	local newElevator = {}

	newElevator.pos = position -- the position of the new elevator, can be changed to anything
	newElevator.isFilled = isFilled -- a variable that is meant to see if the elevator cab is occupied. Could be used in an environment where there are many elevators running at the same time.
	newElevator.onNewFloor = false -- variable telling if elevator is on the new floor
	newElevator.passedSegments = 0 -- amount of cloned segments an elevator has passed
	--Other variables that manage the elevator, such as SFX, the Instance, 
	newElevator.addfloor = false
	newElevator.Instance = game.ReplicatedStorage.Elevator:Clone() -- a new cloned instance of the new elevator
	newElevator.totalModelsTweening = 0
	newElevator.Instance.Parent = game.Workspace -- parent set
	newElevator.dampenForFloor = false
	newElevator.Instance:MoveTo(newElevator.pos) -- moves elevator to desired position
	newElevator.SFX = newElevator.Instance.Lift.Sounds:FindFirstChild('ElevatorSFX')
	newElevator.doorChangecount = 0
	return setmetatable(newElevator, Elevator) -- returns the Elevator metatable
end


function Elevator:SetOccupancy(occupied)
	self.isFilled = occupied -- setting the occupancy variable of the elevator, when a player gets assigned to it.
end


function Elevator:TeleportCharacterToLift(character)
	if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild('Humanoid') then
		character:FindFirstChild('HumanoidRootPart').CFrame = self.Instance:FindFirstChild("Spawn").CFrame -- teleports player character to the elevator cab.
	else
		error("Attempt to teleport a non-character entity to a lift.") -- if there isn't a humanoid and humanoidRootPart, the entity isn't a character
	end
end
--SegmentedFunctions--
local function spawnNewSegments(elevator) -- main function of the script, handles the spawning of new segments in the elevator illusion.

	local max = maxModelsTweening -- total amount of models needed
	local cur = elevator.totalModelsTweening
	print(max - cur) -- a simple check for the output. Otherwise unneccessary
	for i = 1, max - cur do -- for each remaining segments to spawn, do so.
		local highest = nil
		for i, v in pairs(elevator.Instance['Tweening Models']:GetChildren()) do -- for each model in the tweeningModels folder (where new models get placed) tween them.
			if highest == nil then -- finding the highest model in Y position 
				highest = v
			else if v.PrimaryPart.Position.Y < highest.PrimaryPart.Position.Y then -- switch to > for up, in case of wanting an elevator that goes up instead of down
					highest = v
				end
			end
		end
		if maxModelsTweening - elevator.totalModelsTweening > 0 and elevator.addfloor == false and elevator.onNewFloor == false then
			local clone = newSegment:Clone() -- clones the template in ReplicatedStorage
			elevator.totalModelsTweening = elevator.totalModelsTweening + 1 -- adds 1 to total amount of tweening models
			clone.Parent = elevator.Instance['Tweening Models'] -- puts the clone into the tweeningModels folder
			local highestBase = highest:FindFirstChild('Base') -- finds the highest model's base.
			clone:MoveTo(Vector3.new(highestBase.Position.X, highestBase.Position.Y - 78, highestBase.Position.Z)) -- reverse operation for up, same as last conversion, moves the Model to the top or bottom of the illusion models.
			local base = clone:FindFirstChild('Base') -- clone's base part
			local newProperties = {Position = Vector3.new(base.Position.X, base.Position.Y + 78, base.Position.Z)} -- reverse operation for up, same as last conversion, creates tweenProperties for the new model
			local Tween
			if elevator.dampenForFloor == false then
				Tween = TweenService:Create(base, defaultTweenTime, newProperties) -- if it's not time for a new floor, continue tweening time with normal easing
			else
				Tween = TweenService:Create(base, floorTweenTime, newProperties) -- if it's time for a new floor, dampen the tweening to make the elevator slow to a stop
				print('dampened')
			end
			Tween:Play()
		elseif maxModelsTweening - elevator.totalModelsTweening > 0 and elevator.addfloor == true and elevator.onNewFloor == false then -- if a new floor wants to be added, and there isn't one already there, prepare the system to do so.
			local clone = newFloor:Clone()-- clones a new floor model
			elevator.totalModelsTweening = elevator.totalModelsTweening + 1 -- add one to the amount of models tweening
			clone.Parent = elevator.Instance['Tweening Models']
			local highestBase = highest:FindFirstChild('Base')
			clone:MoveTo(Vector3.new(highestBase.Position.X, highestBase.Position.Y - 78, highestBase.Position.Z)) -- change the highestBase.Position.Y - to a plus for up
			local base = clone:FindFirstChild('Base')
			local newProperties = {Position = Vector3.new(base.Position.X, base.Position.Y - 78, base.Position.Z)} -- reverse operation here for Up
			
			--pretty much the same stuff as above, but preparing for the creation of a new floor
			local Tween
			Tween = TweenService:Create(base, floorTweenTime, newProperties)
			elevator.addfloor = false
			elevator.dampenForFloor = true

			Tween:Play()
		else
			print('Probably too many Segments') -- if there's too many segments in use, this will print
		end
	end
end

local function checkIfNeedDestroyed(elevator)
	for i, v in pairs(elevator.Instance['Tweening Models']:GetChildren()) do
		if v.PrimaryPart.Position.Y > 78 then -- -78 for down, 78 for up (switch sign as well)
			v:Destroy() -- destroys the segment if it reached too high on the Y scale
			elevator.passedSegments = elevator.passedSegments + 1
			elevator.totalModelsTweening = elevator.totalModelsTweening - 1

		end
		--elseif v:FindFirstChild('TweenPos').Value < 4 and v:FindFirstChild('TweenPos').Value > 0 then
		--	v:FindFirstChild('TweenPos').Value = v:FindFirstChild('TweenPos').Value + 1
		--end
	end

end

local function moveTween(elevator) -- the function for moving all the models that are existent
	for i, v in pairs(elevator.Instance['Tweening Models']:GetChildren()) do
		if v.Name == "1FloorClone" and v:FindFirstChild('TweenPos').Value == maxModelsTweening - 1 then -- flop sign for down, only triggers if the clone is named the new floor name and makes sure that the segment isn't on the very top of the system
			elevator.onNewFloor = true
			print('value is changed.')
			elevator.passedSegments = 0
			--sets up the segment and prepares it to tween
			local base = v:FindFirstChild('Base')
			-- setup with different properties to ease it to a stop instead of a linear, sudden stop
			local newProperties = {Position = Vector3.new(base.Position.X, base.Position.Y + 78, base.Position.Z)} -- change to minus for down
			local Tween

			Tween = TweenService:Create(base, floorTweenTime, newProperties)
			elevator.addfloor = false


			Tween:Play()
			v:FindFirstChild('TweenPos').Value = v:FindFirstChild('TweenPos').Value + 1
			local prop = {Volume = 0}
			local quietSound = TweenService:Create(elevator.SFX['Hydraulic Freight Elevator Motor Run'], soundVolume, prop)
			quietSound:Play()
			for i, v in pairs(elevator.Instance:WaitForChild('Lift'):WaitForChild('Emitters'):GetChildren()) do
				local newTween = TweenService:Create(v.ParticleEmitter, emitterInfo, emitterProperties)
				newTween:Play()
			end
		else -- if it doesn't equal the first parameters, go here. This is for any segment that doesn't have a door opening
			-- sets up segment for movement
			local base = v:FindFirstChild('Base')
			local newProperties = {Position = Vector3.new(base.Position.X, base.Position.Y + 78, base.Position.Z)} -- change to minus for down
			local Tween
			if elevator.addfloor == true then
				Tween = TweenService:Create(base, floorTweenTime, newProperties)
			else
				Tween = TweenService:Create(base, defaultTweenTime, newProperties)
			end

			Tween:Play()
			v:FindFirstChild('TweenPos').Value = v:FindFirstChild('TweenPos').Value + 1

		end
		checkIfNeedDestroyed(elevator)
	end
end

function Elevator:OpenDoors() -- opens the doors of the elevator
	
	--sets up basic properties for each of the doors.
	local info = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local rightBase = self.Instance.Lift:FindFirstChild('RDoor').PrimaryPart
	local rightProperty = {Position = Vector3.new(rightBase.Position.X, rightBase.Position.Y, rightBase.Position.Z + 3)}
	local leftBase = self.Instance.Lift:FindFirstChild('LDoor').PrimaryPart
	local leftProperty = {Position = Vector3.new(leftBase.Position.X, leftBase.Position.Y, leftBase.Position.Z - 3)}

	local openR = TweenService:Create(self.Instance.Lift:FindFirstChild('RDoor').PrimaryPart, info, rightProperty)
	local openL = TweenService:Create(self.Instance.Lift:FindFirstChild('LDoor').PrimaryPart, info, leftProperty)
	--plays the tweens and sound
	self.SFX['Freight Elevator 5 (SFX)']:Play()
	openR:Play()
	openL:Play()
end

function Elevator:CloseDoors()-- closes the doors
	
	--sets up the properties to close it with
	local info = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local rightBase = self.Instance.Lift:FindFirstChild('RDoor').PrimaryPart
	local rightProperty = {Position = Vector3.new(rightBase.Position.X, rightBase.Position.Y, rightBase.Position.Z - 3)}
	local leftBase = self.Instance.Lift:FindFirstChild('LDoor').PrimaryPart
	local leftProperty = {Position = Vector3.new(leftBase.Position.X, leftBase.Position.Y, leftBase.Position.Z + 3)}

	local closeR = TweenService:Create(self.Instance.Lift:FindFirstChild('RDoor').PrimaryPart, info, rightProperty)
	local closeL = TweenService:Create(self.Instance.Lift:FindFirstChild('LDoor').PrimaryPart, info, leftProperty)
	--plays the closing tweens
	self.SFX['Freight Elevator 5 (SFX)']:Play()
	closeR:Play()
	closeL:Play()
end

function Elevator:BeginDescent() -- starts the main loop of the elevator movement
	self.SFX["Hydraulic Freight Elevator Motor Run"]:Play() -- plays the background noise
	while true do
		if self.passedSegments == maxModelsTweening then -- if passed segments have exceeded the amount of maxModels, add a new floor
			self.addfloor = true
			self.dampenForFloor = true
			print('adding floor.')
		end
		if self.onNewFloor == true then -- if on a new floor, do the following
			print('on a new floor.')
			self.SFX["Hydraulic Freight Elevator Motor Run"]:Stop() -- stop the sounds
			self.SFX['Hydraulic Freight Elevator Motor Run'].Volume = 1 -- reset the volume from the volume descale tween
			self.doorChangeCount = 0
			while true do -- open and close the doors 3 times
				self.doorChangeCount += 1
				self:OpenDoors()
				wait(5)
				self:CloseDoors()
				wait(5)
				if self.doorChangeCount >= 3 then -- if they've opened three times, do the following
					self.onNewFloor = false
					print("leaving")
					self.SFX["Hydraulic Freight Elevator Motor Run"]:Play() -- restart the sound
					for i, v in pairs(self.Instance:WaitForChild('Lift'):WaitForChild('Emitters'):GetChildren()) do -- restart the emitters
						v.ParticleEmitter.Rate = 600
					end

					break
				end
			end
			continue
		elseif self.onNewFloor == false then -- constantly add new segments and move them
			spawnNewSegments(self)
			moveTween(self)
		end

		wait(totalTime) -- wait time between floors
	end
end




return Elevator
