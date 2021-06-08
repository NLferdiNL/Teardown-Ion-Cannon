#include "datascripts/color4.lua"
#include "scripts/utils.lua"
#include "scripts/savedata.lua"
#include "scripts/ui.lua"

local beaconClass = {
	active = false,
	evaTicker = 0,
	transform = nil,
	timer = 30,
	streaks = {},
}

-- TODO: Following variables to options.

local range = 30 -- Centered around player.
local explosions = 4 -- Amount of explosions divided between range.
local explosionsUp = 5

local circleSize = 75

-- END OPTION VARS

local currentBeacon = nil

local placingBeacon = false
local toolDown = false

local placementTimer = 3
local currentPlacementTime = 0

local beaconSprite = nil
local circleSprite = nil
local lineSprite = nil

local beepSound = nil

-- TODO: Clean up number sounds
local evaBeaconDeployedSound = "snd/ion_cannon_beacon_deployed.ogg"
local evaSatelliteApproachingSound = "snd/warning_ion_cannon_satalite_approacing.ogg"
local evaYouHaveSound =  "snd/eva_you_have.ogg"
local evaCount20Sound =  "snd/eva_20.ogg"
local evaCount15Sound =  "snd/eva_15.ogg"
local evaCount10Sound =  "snd/eva_10.ogg"
local evaCount09Sound =  "snd/eva_9.ogg"
local evaCount08Sound =  "snd/eva_8.ogg"
local evaCount07Sound =  "snd/eva_7.ogg"
local evaCount06Sound =  "snd/eva_6.ogg"
local evaCount05Sound =  "snd/eva_5.ogg"
local evaCount04Sound =  "snd/eva_4.ogg"
local evaCount03Sound =  "snd/eva_3.ogg"
local evaCount02Sound =  "snd/eva_2.ogg"
local evaCount01Sound =  "snd/eva_1.ogg"
local evaCount00Sound =  "snd/eva_0.ogg"
local evaSecondsToSound =  "snd/eva_seconds_to_reach_minimum_safe_distance.ogg"

local placingBeaconSound = "snd/ion_beacon_set.ogg"

local placingPlayerPos = nil

function init()
	saveFileInit()
	
	RegisterTool("ioncannonbeacon", "Ion Cannon Beacon ", "MOD/vox/molotov.vox")
	SetBool("game.tool.ioncannonbeacon.enabled", true)
	
	beaconSprite = LoadSprite("sprites/beacon.png")
	circleSprite = LoadSprite("sprites/circle.png")
	lineSprite = LoadSprite("sprites/line.png")
	
	beepSound = LoadSound("snd/com_ion_beep.ogg")
end

function tick(dt)
	toolLogic(dt)
	placementLogic(dt)
	
	drawBeaconSprite(currentBeacon)
	
	drawBeaconAnim(dt, currentBeacon)
	
	beaconTimerLogic(dt, currentBeacon)
	
	beaconSoundHandler(dt, currentBeacon)
end

function draw(dt)	
	drawUI(dt)
	evaSoundHandler(dt, currentBeacon)
	
	beaconPlacementSound()
end

function toolLogic(dt)
	if GetString("game.player.tool") ~= "ioncannonbeacon" then
		placingBeacon = false
		return
	end
	
	if InputDown("usetool") then
		local playerTransform = GetPlayerTransform()
	
		if not toolDown then
			placingBeacon = true
			placingPlayerPos = playerTransform.pos
		end
		
		toolDown = true
		SetPlayerTransform(Transform(placingPlayerPos, playerTransform.rot))
	else
		toolDown = false
		placingBeacon = false
	end
end

function placementLogic(dt)
	if not toolDown then
		currentPlacementTime = 0
		return
	end
	
	if not placingBeacon then
		return
	end
	
	currentPlacementTime = currentPlacementTime + dt
	
	if currentPlacementTime >= placementTimer then
		placingBeacon = false
		currentPlacementTime = 0
		createBeacon(GetPlayerTransform())
	end
end

function beaconTimerLogic(dt, beacon)
	if beacon == nil then
		return
	end
	
	beacon.timer = beacon.timer - dt
	
	if beacon.timer <= 0 then
		explodeBeacon(beacon)
		beacon.active = false
		currentBeacon = nil --TODO: Wipe this beacon from array.
	end
end

function explodeBeacon(beacon)
	if beacon == nil or beacon.active == false then
		return
	end
	
	local minPos = VecAdd(beacon.transform.pos, Vec(-range / 2, 0, -range / 2))
	
	for y = 0, explosionsUp do
		local currPos = VecAdd(beacon.transform.pos, Vec(0, range * 2 / explosionsUp * y, 0))
		Explosion(currPos, 4)
	end
	
	for x = 0, explosions do
		for z = 0, explosions do
			local currPos = VecAdd(minPos, Vec(range / explosions * x, 0, range / explosions * z))
			
			if x ~= explosions / 2 and z ~= explosions / 2 then
				Explosion(currPos, 4)
			end
		end
	end
	
	local centerPos = VecAdd(minPos, Vec(range / explosions * explosions / 2, 0, range / explosions * explosions / 2))
	Explosion(centerPos, 4)
end

function drawUI(dt)
	if not placingBeacon then
		return
	end
	
	UiPush()
		UiAlign("center middle")
		UiTranslate(UiWidth() * 0.5, UiHeight() * 0.8)
		
		UiPush()
			c_UiColor(Color4.Orange)
			
			UiTranslate(-100, 15)
			
			UiAlign("left middle")
			
			UiRect(200 / placementTimer * currentPlacementTime, 30)
		UiPop()
		
		UiPush()
			c_UiColor(Color4.White)
			UiRect(200, 2)
			
			UiTranslate(0, 30)
			
			UiRect(200, 2)
			
			UiTranslate(-100, -15)
			
			UiRect(2, 32)
			
			UiTranslate(200, 0)
			
			UiRect(2, 32)
		UiPop()
	UiPop()
end

function generateBeaconStreaks(beacon)
	local beaconPos = beacon.transform.pos

	for i = 1, 20 do
		beacon.streaks[i] = {}
		
		local dir = rndVec(10)
		
		dir[2] = beaconPos[2]
		
		dir = VecScale(dir, circleSize / 10)
		
		dir = VecAdd(beaconPos, dir)
		
		dir = VecAdd(dir, Vec(0, 200, 0))
		
		beacon.streaks[i].pos = dir
		beacon.streaks[i].offset = i / 2
		beacon.streaks[i].height = 100
	end
end

function createBeacon(transform)
	-- TODO: Rework to array.
	if currentBeacon ~= nil and currentBeacon.active then
		return
	end
	
	currentBeacon = deepcopy(beaconClass)
	currentBeacon.transform = TransformCopy(transform)
	currentBeacon.active = true
	
	currentBeacon.transform.pos = VecAdd(currentBeacon.transform.pos, Vec(0, 0.5, 0))
	
	generateBeaconStreaks(currentBeacon)
end

function drawBeaconAnim(dt, beacon)
	if beacon == nil then
		return
	end
	
	local cameraTransform = GetCameraTransform()
	local beaconPos = beacon.transform.pos
	local bTimer = beacon.timer
	
	--Circle down
	if bTimer <= 12 then
		local circleOffset = -(10 - bTimer) * 50 - (10 - bTimer) * 100
		
		circleOffset = circleOffset % 200 - 200
		
		local alpha = 1 - (100 / 10 * bTimer / 100)
		
		for circle = 0, 15 do
			local currPos = Vec(beaconPos[1], beaconPos[2] + circle * 50 + circleOffset, beaconPos[3])
			local currRot = QuatLookAt(currPos, beaconPos)
			
			local currTransform = Transform(currPos, currRot)
			
			DrawSprite(circleSprite, currTransform, circleSize, circleSize, 0, 0.5, 1, alpha, true, false)
		end
	end
	
	-- Centering Streaks
	if bTimer <= 10 then
		local alpha = 1 - (100 / 10 * bTimer / 100)
		
		for i = 1, #beacon.streaks do
			local currStreak = beacon.streaks[i]
			local lifetimeOffset = currStreak.offset
			
			if lifetimeOffset > 0 then
				currStreak.offset = currStreak.offset - dt * 2
			else
				local currStreakPos = currStreak.pos
				
				local dirToBeacon = VecDir(currStreakPos, beaconPos)
				
				local streakLookAtPos = VecCopy(cameraTransform.pos)
				streakLookAtPos[2] = currStreakPos[2]
				
				local beaconAdjustedForHeightPos = VecCopy(beaconPos)
				
				beaconAdjustedForHeightPos[2] = streakLookAtPos[2]
				
				local distToBeacon = VecDist(currStreakPos, beaconAdjustedForHeightPos)
				
				local traveledDistance = dt * 100
				
				DebugPrint(distToBeacon)
				
				if distToBeacon <= 2 then
					traveledDistance = 0
				end
				
				local distTraveled = VecScale(dirToBeacon, traveledDistance)
				
				beacon.streaks[i].pos = VecAdd(currStreakPos, distTraveled)
				
				if beacon.streaks[i].height > 0 then
					beacon.streaks[i].height = beacon.streaks[i].height - dt * 10
					beacon.streaks[i].pos[2] = beacon.streaks[i].pos[2] - dt * 10
				end
				
				local streakSpriteRot = QuatLookAt(currStreakPos, streakLookAtPos)
				local spriteTransform = Transform(currStreakPos, streakSpriteRot)
				
				local red = math.random(0, 1)
			
				local green = math.random(75, 100) / 100
				
				local blue = 1
				
				if distToBeacon >= 2 or bTimer > 1.5 then
					DrawSprite(lineSprite, spriteTransform, 3, 200, 0, 0.75, 1, alpha, true, false)
				else
					local red = math.random(0, 1)
			
					local green = math.random(75, 100) / 100
					
					local blue = 1
					
					alpha = alpha / 1.2
					
					DrawSprite(lineSprite, spriteTransform, 7 + i * 5, 200, red, green, blue, alpha, true, false)
				end
			end
		end
	end
	
	-- TODO: After explosion effects
	
end

function drawBeaconSprite(beacon)
	if beacon ~= nil then
		local beaconPos = beacon.transform.pos
		
		local spritePos = VecCopy(beaconPos)
		
		spritePos = VecAdd(spritePos, Vec(0, -0.25, 0))
	
		local cameraTransform = GetCameraTransform()
		
		local lookPos = VecCopy(cameraTransform.pos)
		
		lookPos[2] = beaconPos[2]
	
		beacon.transform.rot = QuatLookAt(beaconPos, lookPos)
		
		local spriteTransform = Transform(spritePos, beacon.transform.rot)
		
		DrawSprite(beaconSprite, spriteTransform, 0.5, 0.5, 1, 1, 1, 1, true, false)
	end
end

function beaconSoundHandler(dt, beacon)
	if beacon == nil then
		return
	end
	
	
end

function evaSoundHandler(dt, beacon)
	if beacon == nil then
		return
	end
	
	if beacon.evaTicker >= 1 and beacon.evaTicker < 12 then
		beacon.evaTicker = beacon.evaTicker + dt
	elseif beacon.evaTicker <= 0 then
		beacon.evaTicker = 1
		UiSound(evaBeaconDeployedSound)
	end
	
	if beacon.evaTicker >= 4 and beacon.evaTicker < 5 then
		beacon.evaTicker = 5
		UiSound(evaSatelliteApproachingSound)
	end
	
	if beacon.evaTicker >= 8.5 and beacon.evaTicker < 9 then
		beacon.evaTicker = 9
		UiSound(evaYouHaveSound)
	end
	
	if beacon.evaTicker >= 10 and beacon.evaTicker < 11 then
		beacon.evaTicker = 11
		UiSound(evaCount20Sound)
	end
	
	if beacon.evaTicker >= 11.5 and beacon.evaTicker < 12 then
		beacon.evaTicker = 12
		UiSound(evaSecondsToSound)
	end
	
	if beacon.evaTicker <= 23 then
		local bTimer = math.floor(beacon.timer)
		
		if bTimer == 15 and beacon.evaTicker == 12 then
			UiSound(evaCount15Sound)
			beacon.evaTicker = 13
		end
		
		if bTimer == 10 and beacon.evaTicker == 13 then
			UiSound(evaCount10Sound)
			beacon.evaTicker = 14
		end
		
		if bTimer == 9 and beacon.evaTicker == 14 then
			UiSound(evaCount09Sound)
			beacon.evaTicker = 15
		end
		
		if bTimer == 8 and beacon.evaTicker == 15 then
			UiSound(evaCount08Sound)
			beacon.evaTicker = 16
		end
		
		if bTimer == 7 and beacon.evaTicker == 16 then
			UiSound(evaCount07Sound)
			beacon.evaTicker = 17
		end
		
		if bTimer == 6 and beacon.evaTicker == 17 then
			UiSound(evaCount06Sound)
			beacon.evaTicker = 18
		end
		
		if bTimer == 5 and beacon.evaTicker == 18 then
			UiSound(evaCount05Sound)
			beacon.evaTicker = 19
		end
		
		if bTimer == 4 and beacon.evaTicker == 19 then
			UiSound(evaCount04Sound)
			beacon.evaTicker = 20
		end
		
		if bTimer == 3 and beacon.evaTicker == 20 then
			UiSound(evaCount03Sound)
			beacon.evaTicker = 21
		end
		
		if bTimer == 2 and beacon.evaTicker == 21 then
			UiSound(evaCount02Sound)
			beacon.evaTicker = 22
		end
		
		if bTimer == 1 and beacon.evaTicker == 22 then
			UiSound(evaCount01Sound)
			beacon.evaTicker = 23
		end
		
		if bTimer == 0 and beacon.evaTicker == 23 then
			UiSound(evaCount00Sound)
			beacon.evaTicker = 24
		end
	end
end

function beaconPlacementSound()
-- TODO: Fix this.
	if not placingBeacon then
		return
	end
	
	UiSoundLoop(beaconPlacementSound, 10)
end