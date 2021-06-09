moddataPrefix = "savegame.mod.IonCannonBeacon"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	range = GetInt(moddataPrefix .. "ExplosiveRange")
	explosions = GetInt(moddataPrefix .. "Explosions")
	explosionsUp = GetInt(moddataPrefix .. "ExplosionsUp")
	
	if saveVersion < 1 then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", 1)
		
		range = 30
		SetInt(moddataPrefix .. "ExplosiveRange", range)
		
		explosions = 5
		SetInt(moddataPrefix .. "Explosions", explosions)
		
		explosionsUp = 10
		SetInt(moddataPrefix .. "ExplosionsUp", explosionsUp)
	end
end