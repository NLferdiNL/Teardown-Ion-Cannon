moddataPrefix = "savegame.mod.IonCannonBeacon"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	
	if saveVersion < 1 then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", 1)
	end
end