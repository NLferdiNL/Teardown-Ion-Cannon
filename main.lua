#include "datascripts/color4.lua"
#include "scripts/utils.lua"
#include "scripts/savedata.lua"
#include "scripts/ui.lua"

local beaconClass = {
	active = false,
	transform = nil,
	timer = 5,
	streaks = {},
}

local currentBeacon = nil

local placingBeacon = false
local toolDown = false

local placementTimer = 3
local currentPlacementTime = 0

local beaconSprite = nil

local placingPlayerPos = nil

function init()
	saveFileInit()
	
	RegisterTool("ioncannonbeacon", "Ion Cannon Beacon ", "MOD/vox/molotov.vox")
	SetBool("game.tool.ioncannonbeacon.enabled", true)
	
	beaconSprite = LoadSprite("sprites/beacon.png")
end

function tick(dt)
	toolLogic(dt)
	placementLogic(dt)
	drawBeacon()
	
	beaconLogic(dt)
end

function draw(dt)	
	drawUI(dt)
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
		DebugPrint("place")
	end
end

function beaconLogic(dt)
	if currentBeacon == nil then
		return
	end
	
	currentBeacon.timer = currentBeacon.timer - dt
	
	DebugPrint(currentBeacon.timer)
	
	if currentBeacon.timer <= 0 then
		explodeBeacon(currentBeacon)
		currentBeacon = nil
	end
end

function explodeBeacon(beacon)
	local range = 40
	local explosions = 5
	local minPos = VecAdd(beacon.transform.pos, Vec(-range / 2, 0, -range / 2))
	
	for x = 0, explosions do
		for z = 0, explosions do
			local currPos = VecAdd(minPos, Vec(range / explosions * x, 0, range / explosions * z))
			Explosion(currPos, 4)
		end
	end
	
	for y = 0, explosions do
		local currPos = VecAdd(beacon.transform.pos, Vec(0, range / explosions * y, 0))
		Explosion(currPos, 4)
	end
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

function createBeacon(transform)
	if currentBeacon == nil then
		currentBeacon = deepcopy(beaconClass)
		currentBeacon.transform = TransformCopy(transform)
		currentBeacon.active = true
		
		currentBeacon.transform.pos = VecAdd(currentBeacon.transform.pos, Vec(0, 0.5, 0))
	end
end

function drawBeacon()
	if currentBeacon ~= nil then
		local beaconPos = currentBeacon.transform.pos
	
		local cameraTransform = GetCameraTransform()
		
		local lookPos = VecCopy(cameraTransform.pos)
		
		lookPos[2] = beaconPos[2]
	
		currentBeacon.transform.rot = QuatLookAt(beaconPos, lookPos)
		
		DrawSprite(beaconSprite, currentBeacon.transform, 0.5, 0.5, 1, 1, 1, 1, true, false)
	end
end