#include "scripts/savedata.lua"
#include "scripts/textbox.lua"

local modname = "Ion Cannon Beacon"

local enabledText = "Enabled"
local disabledText = "Disabled"

function init()
	saveFileInit()
	
	for i = 1, 20 do DebugPrint(" ") end
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
			evaVolume = 1
			effectVolume = 1
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Save and exit", 200, 50) then
			--SetBool(moddataPrefix .. "UseEvaAnnouncer", useEvaAnnouncer)
			SetBool(moddataPrefix .. "DowngradeExplosion", downgradeExplosion)
			SetBool(moddataPrefix .. "QuickTrigger", quickTrigger)
			SetFloat(moddataPrefix .. "EvaVolume", evaVolume)
			SetFloat(moddataPrefix .. "EffectVolume", effectVolume)
			Menu()
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Cancel", 200, 50) then
			Menu()
		end
	UiPop()
	
	UiPush()
		UiWordWrap(700)
	
		UiTranslate(UiCenter(), 50)
		UiAlign("center middle")
	
		UiFont("bold.ttf", 60)
		UiTranslate(0, 50)
		UiText(modname)
	
		UiTranslate(0, 80)
		
		UiFont("regular.ttf", 26)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		
		--[[if UiTextButton("Toggle EVA Announcer: " .. (useEvaAnnouncer and enabledText or disabledText) , 400, 40) then
			useEvaAnnouncer = not useEvaAnnouncer
		end
		
		UiTranslate(0, 50)
		
		UiText("Disabling this option disables the announcer.")
		
		UiTranslate(0, 70)]]--
		
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
		
		UiTranslate(0, 100)
		
		UiText("EVA (Announcer) Volume")
		
		UiTranslate(0, 25)
		
		evaVolume = slider(evaVolume, 0, 1, 200)
		
		UiTranslate(0, 50)
		
		UiText("This allows you to lower the volume of EVA, or completely disable it.\n(If you had her off previously, this should've been set automatically)")
		
		UiTranslate(0, 100)
		
		UiText("Effect Volume")
		
		UiTranslate(0, 25)
		
		effectVolume = slider(effectVolume, 0, 1, 200)
		
		UiTranslate(0, 50)
		UiText("This modifies the sound of the sound effects. Such as the charging sound.")
	UiPop()
end

function tick()
	textboxClass.tick()
end

function slider(value, min, max, width)
	local done = true
	value = (value - min) / (max - min)
	UiPush()
		UiRect(width, 3)
		UiTranslate(-width / 2, 0)
		value, done = UiSlider("ui/common/dot.png", "x", value * width, 0, width) / width
		
		value = roundToDecimal((value * (max-min) + min), 2)
		
		UiTranslate(-50, 0)
		UiText(value)
	UiPop()
	
	return value, done
end