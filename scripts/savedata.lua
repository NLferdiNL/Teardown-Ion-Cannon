moddataPrefix = "savegame.mod.IonCannonBeacon"

function saveFileInit()
	saveVersion = GetInt(moddataPrefix .. "Version")
	range = GetInt(moddataPrefix .. "ExplosiveRange")
	explosions = GetInt(moddataPrefix .. "Explosions")
	explosionsUp = GetInt(moddataPrefix .. "ExplosionsUp")
	useEvaAnnouncer = GetBool(moddataPrefix .. "UseEvaAnnouncer")
	downgradeExplosion = GetBool(moddataPrefix .. "DowngradeExplosion")
	quickTrigger = GetBool(moddataPrefix .. "QuickTrigger")
	
	if saveVersion < 1 or saveVersion == nil then
		saveVersion = 1
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		range = 30
		SetInt(moddataPrefix .. "ExplosiveRange", range)
		
		explosions = 5
		SetInt(moddataPrefix .. "Explosions", explosions)
		
		--[[explosionsUp = 10
		SetInt(moddataPrefix .. "ExplosionsUp", explosionsUp)]]--
	end
	
	if saveVersion < 2 then
		saveVersion = 2
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		useEvaAnnouncer = true
		SetBool(moddataPrefix .. "UseEvaAnnouncer", useEvaAnnouncer)
	end
	
	if saveVersion < 3 then
		saveVersion = 3
		SetInt(moddataPrefix .. "Version", saveVersion)
		
		downgradeExplosion = false
		SetBool(moddataPrefix .. "DowngradeExplosion", downgradeExplosion)
		
		quickTrigger = false
		SetBool(moddataPrefix .. "QuickTrigger", quickTrigger)
		
		explosionsUp = 15
		SetInt(moddataPrefix .. "ExplosionsUp", explosionsUp)
	end
end