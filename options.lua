#include "scripts/savedata.lua"
#include "scripts/textbox.lua"

local modname = "Ion Cannon Beacon"

local enabledText = "Enabled"
local disabledText = "Disabled"

function init()
	saveFileInit()
end

function draw()
	--[[local mX, mY = UiGetMousePos()
	UiButtonImageBox("ui/common/box-solid-6.png", 6, 6)
	UiTranslate(mX, mY)
	UiRect(10, 10)
	UiTranslate(-mX, -mY)]]--
	
	UiPush()
		UiTranslate(UiWidth(), UiHeight())
		UiTranslate(-50, 3 * -50)
		UiAlign("right bottom")
	
		UiFont("regular.ttf", 26)
		
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		
		if UiTextButton("Reset to default", 200, 50) then
			useEvaAnnouncer = true
			downgradeExplosion = false
			quickTrigger = false
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Save and exit", 200, 50) then
			SetBool(moddataPrefix .. "UseEvaAnnouncer", useEvaAnnouncer)
			SetBool(moddataPrefix .. "DowngradeExplosion", downgradeExplosion)
			SetBool(moddataPrefix .. "QuickTrigger", quickTrigger)
			Menu()
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Cancel", 200, 50) then
			Menu()
		end
	UiPop()
	
	UiPush()
		UiWordWrap(800)
	
		UiTranslate(UiCenter(), 50)
		UiAlign("center middle")
	
		UiFont("bold.ttf", 60)
		UiTranslate(0, 50)
		UiText(modname)
		
		UiWordWrap(400)
	
		UiTranslate(0, 80)
		
		UiFont("regular.ttf", 26)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		
		if UiTextButton("Toggle EVA Announcer: " .. (useEvaAnnouncer and enabledText or disabledText) , 400, 40) then
			useEvaAnnouncer = not useEvaAnnouncer
		end
		
		UiTranslate(0, 50)
		
		UiText("Disabling this option disables the announcer.")
		
		UiTranslate(0, 70)
		
		if UiTextButton("Toggle Lite Beacon: " .. (downgradeExplosion and enabledText or disabledText) , 400, 40) then
			downgradeExplosion = not downgradeExplosion
		end
		
		UiTranslate(0, 50)
		
		UiText("Enabling this open halves the damage/range for performance.")
		
		UiTranslate(0, 70)
		
		if UiTextButton("Toggle Quick Explosion: " .. (quickTrigger and enabledText or disabledText) , 400, 40) then
			quickTrigger = not quickTrigger
		end
		
		UiTranslate(0, 50)
		
		UiText("Enabling this open shortens the countdown.")
	UiPop()
end

function tick()
	textboxClass.tick()
end