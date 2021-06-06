#include "scripts/utils.lua"

Color4 = {}

Color4.Prototype = {
	r = 0,
	g = 0,
	b = 0,
	a = 1,
}

Color4.From255 = function(r, g, b, a)
	local newColor = deepcopy(Color4.Prototype)
	
	newColor.r = r / 255 or Color4.Prototype.r
	newColor.g = g / 255  or Color4.Prototype.g
	newColor.b = b / 255  or Color4.Prototype.b
	newColor.a = a / 255  or Color4.Prototype.a
	
	return newColor
end

Color4.New = function(r, g, b, a)
	local newColor = deepcopy(Color4.Prototype)
	
	newColor.r = r or Color4.Prototype.r
	newColor.g = g or Color4.Prototype.g
	newColor.b = b or Color4.Prototype.b
	newColor.a = a or Color4.Prototype.a
	
	return newColor
end

Color4.White = Color4.New(1, 1, 1, 1)

Color4.LightGray = Color4.New(0.75, 0.75, 0.75, 1)

Color4.Gray = Color4.New(0.5, 0.5, 0.5, 1)

Color4.DarkGray = Color4.New(0.25, 0.25, 0.25, 1)

Color4.Black = Color4.New(0, 0, 0, 1)

Color4.Red = Color4.New(1, 0, 0, 1)

Color4.Green = Color4.New(0, 1, 0, 1)

Color4.Blue = Color4.New(0, 0, 1, 1)

Color4.Yellow = Color4.New(1, 1, 0, 1)

Color4.Orange = Color4.New(1, 0.7, 0, 1)