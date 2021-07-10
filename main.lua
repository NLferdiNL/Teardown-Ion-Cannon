#include "datascripts/color4.lua"
#include "scripts/utils.lua"
#include "scripts/savedata.lua"
#include "scripts/ui.lua"

local beaconClass = {
	active = false,
	evaTicker = 0,
	transform = nil,
	beepTimer = 0,
	timer = 30,
	streaks = {},
	warmupSndTriggered = false,
	rtsSpritePulse = 0,
	rtsPulseForward = false
}
local maxActiveBeacons = 5
local currBeaconIndex = 1
local activeBeacons = {}

local explosionWaveClass = {
	active = false,
	transform = nil,
	maxSize = 50,
	lifetime = 0,
	maxLifetime = 0.5,
}
local currWaveIndex = 1
local maxActiveWaves = 5
local activeWaves = {}

local startedPlacing = false
local placingBeacon = false
local toolDown = false

local placementTimer = 3
local currentPlacementTime = 0

local beaconSprite = nil
local circleSprite = nil
local sphereSprite = nil
local lineSprite = nil

local beepSound = nil
local warmupSound = nil
local fireSound = nil

local spriteCircleSize = 75

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

local rtsCameraActive = GetBool("level.rtsCameraActive") or false

function init()
	saveFileInit()
	
	if downgradeExplosion then
		range = math.floor(range / 2)
		explosions = 3
	end
	
	if quickTrigger then
		placementTimer = 1
		beaconClass.timer = 20
	end
	
	RegisterTool("ioncannonbeacon", "Ion Cannon Beacon", "MOD/vox/beacon.vox")
	SetBool("game.tool.ioncannonbeacon.enabled", true)
	
	beaconSprite = LoadSprite("sprites/beacon.png")
	circleSprite = LoadSprite("sprites/circle.png")
	sphereSprite = LoadSprite("sprites/sphere.png")
	lineSprite = LoadSprite("sprites/line.png")
	
	beepSound = LoadSound("snd/com_ion_beep.ogg")
	warmupSound = LoadSound("snd/ion_warmup.ogg")
	fireSound = LoadSound("snd/ion_fire.ogg")
end

function tick(dt)
	rtsCameraActive = GetBool("level.rtsCameraActive") or false
	
	if rtsCameraActive then
		placementTimer = 1
	elseif not quickTrigger then
		placementTimer = 3
	end
	
	toolLogic(dt)
	placementLogic(dt)
	
	drawRTSPlacementSprite()
	
	allBeaconsHandler(dt)
	
	allWavesHandler(dt)
end

function draw(dt)	
	drawUI(dt)
	
	if useEvaAnnouncer then
		allEvaHander(dt)
	end
	
	beaconPlacementSoundHandler()
end

function toolLogic(dt)
	if GetString("game.player.tool") ~= "ioncannonbeacon" then
		toolDown = false
		placingBeacon = false
		return
	end
	
	if InputDown("usetool") or (rtsCameraActive and InputDown("lmb")) then
		local playerTransform = GetPlayerTransform()
	
		if not toolDown then
			placingBeacon = true
			startedPlacing = true
			placingPlayerPos = playerTransform.pos
		end
		
		toolDown = true
		
		if placingBeacon and not rtsCameraActive then
			SetPlayerTransform(Transform(placingPlayerPos, playerTransform.rot))
		end
	else
		toolDown = false
		placingBeacon = false
		startedPlacing = false
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
		
		local beaconTransform = nil
		
		if rtsCameraActive then
			local cameraTransform = GetCameraTransform()
			
			local forwardPos = TransformToParentPoint(cameraTransform, Vec(0, 0, -2))
			local satellitePos = TransformToParentPoint(cameraTransform, Vec(0, 0, -1))
			local direction = VecDir(satellitePos, forwardPos)
			
			local hit, hitPoint = raycast(cameraTransform.pos, direction)
			
			if hit then
				beaconTransform = Transform(hitPoint)
			else
				return
			end
		else
			beaconTransform = GetPlayerTransform()
		end
	
		local newBeacon = createBeacon(beaconTransform)
		
		activeBeacons[currBeaconIndex] = newBeacon
		
		currBeaconIndex = (currBeaconIndex % maxActiveBeacons) + 1
	end
end

-- Object handlers

function allBeaconsHandler(dt)
	for i = 1, #activeBeacons do
		local currentBeacon = activeBeacons[i]
		
		if currentBeacon ~= nil and currentBeacon.active == true then
			drawBeaconSprite(currentBeacon)
	
			drawBeaconAnim(dt, currentBeacon)
			
			if beaconTimerLogic(dt, currentBeacon) then
				explodeBeacon(currentBeacon)
				currentBeacon.active = false
			end
			
			beaconSoundHandler(dt, currentBeacon)
		end
	end
end

function allWavesHandler(dt)
	for i = 1, #activeWaves do
		local currWave = activeWaves[i]
		
		if currWave ~= nil and currWave.active == true then
			if explosionWaveHandler(dt, currWave) then
				currWave.active = false
			end
		end
	end
end

function allEvaHander(dt)
	for i = 1, #activeBeacons do
		local currentBeacon = activeBeacons[i]
		
		if currentBeacon ~= nil and currentBeacon.active == true then
			evaSoundHandler(dt, currentBeacon)
		end
	end
end

function beaconTimerLogic(dt, beacon)
	if beacon == nil then
		return
	end
	
	beacon.timer = beacon.timer - dt
	
	if beacon.rtsPulseForward then
		beacon.rtsSpritePulse = beacon.rtsSpritePulse + dt / 2
		
		if beacon.rtsSpritePulse > 0.3 then
			beacon.rtsSpritePulse = 0.3
			beacon.rtsPulseForward = false
		end
	else
		beacon.rtsSpritePulse = beacon.rtsSpritePulse - dt / 2
		
		if beacon.rtsSpritePulse < 0 then
			beacon.rtsSpritePulse = 0
			beacon.rtsPulseForward = true
		end
	end
	
	if beacon.timer <= 0 then
		return true
	end
	
	return false
end

-- Potential TODO: Find all broken objects in the area and
--                 launch them from the center.
-- Another TODO: Less lagg mode, remove small pieces of debris.
--               (If total debris count is large.)
function explodeBeacon(beacon)
	if beacon == nil or beacon.active == false then
		return
	end
	
	PlaySound(fireSound, beacon.transform.pos, 10)
	
	local newWave = createExplosionWave(beacon.transform)
	
	activeWaves[currWaveIndex] = newWave
		
	currWaveIndex = (currWaveIndex % maxActiveWaves) + 1
	
	local minPos = VecAdd(beacon.transform.pos, Vec(-range / 2, 0, -range / 2))
	
	for y = 0, explosionsUp do
		local currPos = VecAdd(beacon.transform.pos, Vec(0, range * 4 / explosionsUp * y, 0))
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

-- UI Functions (excludes sound specific functions)

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

-- Creation Functions

function createBeacon(transform)
	local currentBeacon = deepcopy(beaconClass)
	
	currentBeacon.active = true
	
	currentBeacon.transform = TransformCopy(transform)
	
	currentBeacon.transform.pos = VecAdd(currentBeacon.transform.pos, Vec(0, 0.5, 0))
	
	generateBeaconStreaks(currentBeacon)
	
	return currentBeacon
end

function createExplosionWave(transform)
	local transformCopy = TransformCopy(transform)
	
	local wave = deepcopy(explosionWaveClass)
	
	wave.active = true
	
	wave.transform = transformCopy
	
	return wave
end

function generateBeaconStreaks(beacon)
	local beaconPos = beacon.transform.pos

	for i = 1, 15 do
		beacon.streaks[i] = {}
		
		local dir = rndVec(1)
		
		dir[2] = 0
		
		dir = VecScale(dir, spriteCircleSize)
		
		dir = VecAdd(beaconPos, dir)
		
		dir = VecAdd(dir, Vec(0, 400, 0))
		
		beacon.streaks[i].pos = dir
		beacon.streaks[i].offset = i
		beacon.streaks[i].height = 100
	end
end

-- World Sound functions

function beaconSoundHandler(dt, beacon)
	if beacon == nil then
		return
	end
	
	beacon.beepTimer = beacon.beepTimer + dt
	
	if beacon.beepTimer > 1 then
		beacon.beepTimer = 0
		PlaySound(beepSound, beacon.transform.pos)
	end
	
	if beacon.timer <= 11 and beacon.warmupSndTriggered == false then
		beacon.warmupSndTriggered = true
		PlaySound(warmupSound, beacon.transform.pos, 10)
	end
end

-- Sprite functions

function drawRTSPlacementSprite()
	if not rtsCameraActive or GetString("game.player.tool") ~= "ioncannonbeacon" then
		return
	end
	
	local cameraTransform = GetCameraTransform()
	
	local forwardPos = TransformToParentPoint(cameraTransform, Vec(0, 0, -2))
	local satellitePos = TransformToParentPoint(cameraTransform, Vec(0, 0, -1))
	local direction = VecDir(satellitePos, forwardPos)
	
	local hit, hitPoint = raycast(cameraTransform.pos, direction)
	
	if not hit then
		return
	end
	
	local spriteRot = QuatLookAt(hitPoint, VecAdd(hitPoint, Vec(0, 1, 0)))
	
	DrawSprite(circleSprite, Transform(hitPoint, spriteRot), spriteCircleSize / 10, spriteCircleSize / 10, 1, 1, 0, 1, false, false)
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
		
		for circle = 0, 10 do
			local currPos = Vec(beaconPos[1], beaconPos[2] + circle * 100 + circleOffset, beaconPos[3])
			local currRot = QuatLookAt(currPos, beaconPos)
			
			local currTransform = Transform(currPos, currRot)
			
			DrawSprite(circleSprite, currTransform, spriteCircleSize, spriteCircleSize, 0, 0.5, 1, alpha, true, false)
		end
	end
	
	-- Centering Streaks
	if bTimer <= 10 then
		local alpha = 1 - (100 / 10 * bTimer / 100)
		
		for i = 1, #beacon.streaks do
			local currStreak = beacon.streaks[i]
			local lifetimeOffset = currStreak.offset
			
			if lifetimeOffset > 0 then
				currStreak.offset = currStreak.offset - dt * 4
			else
				local currStreakPos = currStreak.pos
				
				local dirToBeacon = VecDir(currStreakPos, beaconPos)
				
				local streakLookAtPos = VecCopy(cameraTransform.pos)
				streakLookAtPos[2] = currStreakPos[2]
				
				local beaconAdjustedForHeightPos = VecCopy(beaconPos)
				
				beaconAdjustedForHeightPos[2] = streakLookAtPos[2]
				
				local distToBeacon = VecDist(currStreakPos, beaconAdjustedForHeightPos)
				
				local traveledDistance = dt * 100
				
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
					DrawSprite(lineSprite, spriteTransform, 3, 400, 0, 0.75, 1, alpha, true, false)
				else
					local red = math.random(0, 1)
			
					local green = math.random(75, 100) / 100
					
					local blue = 1
					
					alpha = alpha / 1.2
					
					DrawSprite(lineSprite, spriteTransform, 7 + i * 5, 400, red, green, blue, alpha, true, false)
				end
			end
		end
	end
end

function drawBeaconSprite(beacon)
	if beacon ~= nil then
		local beaconPos = beacon.transform.pos
		
		local spritePos = VecCopy(beaconPos)
		
		if rtsCameraActive then
			spritePos = VecAdd(spritePos, Vec(0, -0.5, 0))
		else
			spritePos = VecAdd(spritePos, Vec(0, -0.25, 0))
		end
	
		local cameraTransform = GetCameraTransform()
		
		local lookPos = nil
		
		if rtsCameraActive then
			lookPos = VecAdd(spritePos, Vec(0, 1, 0))
		else
			lookPos = VecCopy(cameraTransform.pos)
			
			lookPos[2] = beaconPos[2]
		end
	
		beacon.transform.rot = QuatLookAt(beaconPos, lookPos)
		
		local spriteTransform = Transform(spritePos, beacon.transform.rot)
		
		local spriteToUse = nil
		
		if rtsCameraActive then
			DrawSprite(circleSprite, spriteTransform, spriteCircleSize, spriteCircleSize, 0, 0.5, 0.7, 0.1 + beacon.rtsSpritePulse, false, false)
		else
			DrawSprite(beaconSprite, spriteTransform, 0.25, 0.5, 1, 1, 1, 1, true, false)
		end
	end
end

function explosionWaveHandler(dt, wave)
	if wave == nil then
		return true
	end
	
	wave.lifetime = wave.lifetime + dt
	
	if wave.lifetime >= wave.maxLifetime then
		return true
	end
	
	local waveSize = wave.maxSize / wave.maxLifetime * wave.lifetime 
	
	local cameraTransform = GetCameraTransform()
	
	local lookRot = QuatLookAt(wave.transform.pos, cameraTransform.pos)
	
	local currTransform = Transform(wave.transform.pos, lookRot)
	
	local alpha = 1 - 100 / wave.maxLifetime * wave.lifetime / 100
	
	DrawSprite(sphereSprite, currTransform, waveSize, waveSize, 0, 0, 1, alpha, true, false)
	
	return false
end

-- UI Sound Functions

function evaSoundHandler(dt, beacon)
	-- Most certainly could've made this cleaner.
	-- But it works, for now.
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
		if quickTrigger then
			UiSound(evaCount10Sound)
		else
			UiSound(evaCount20Sound)
		end
	end
	
	if beacon.evaTicker >= 11.5 and beacon.evaTicker < 12 then
		beacon.evaTicker = 12
		UiSound(evaSecondsToSound)
	end
	
	if beacon.evaTicker <= 23 then
		local bTimer = math.floor(beacon.timer)
		
		if quickTrigger and beacon.evaTicker == 12 then
			beacon.evaTicker = 18
		elseif bTimer == 15 and beacon.evaTicker == 12 then
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

function beaconPlacementSoundHandler()
	if not placingBeacon or not startedPlacing then
		return
	end
	
	startedPlacing = false
	
	UiSound(placingBeaconSound)
end