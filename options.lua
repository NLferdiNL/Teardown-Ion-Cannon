#include "scripts/savedata.lua"
#include "scripts/textbox.lua"

local modname = "Ion Cannon Beacon"

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
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Save and exit", 200, 50) then
			SetBool(moddataPrefix .. "UseEvaAnnouncer", useEvaAnnouncer)
			Menu()
		end
		
		UiTranslate(0, 60)
		
		if UiTextButton("Cancel", 200, 50) then
			Menu()
		end
	UiPop()
	
	UiPush()
		UiWordWrap(400)
	
		UiTranslate(UiCenter(), 50)
		UiAlign("center middle")
	
		UiFont("bold.ttf", 48)
		UiTranslate(0, 50)
		UiText(modname)
	
		UiTranslate(0, 100)
		
		UiFont("regular.ttf", 26)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		
		local statusText = "Disabled"
		
		if useEvaAnnouncer then
			statusText = "Enabled"
		end
		
		if UiTextButton("Toggle EVA Announcer: " .. statusText , 400, 40) then
			useEvaAnnouncer = not useEvaAnnouncer
		end
		
		UiTranslate(0, 50)
		
		UiText("Disabling this option disables the announcer.")
	UiPop()
end

function tick()
	textboxClass.tick()
end