-- TELEPORT HOTKEYS
-- KEY CUSTOMIZATION: see "Available Keys.txt" inside the zip for available keys


-- This is the hotkey that teleports you to the pinned Waypoint 
-- or to a tracked Map Marker 
-- DEFAULT: Key.PAGE_UP
waypointKey = Key.PAGE_UP


-- This is the hotkey that teleports you to the Mission location
-- DEFAULT: Key.PAGE_DOWN
missionKey = Key.PAGE_DOWN


-- This is the hotkey that teleports you to the Closest Unlocked Save Location
-- DEFAULT: Key.HOME
safeTelportKey = Key.HOME


-- Whether or not to show the in-game pop-up for hotkeys after the loading screens.
-- Set to false to disable the pop-up
-- DEFAULT: true
showHotkeysPopUp = true 


----------------------------------------------------------------------------------------------
----------- D O  N O T   M O D I F Y   B E L O W  --------------------------------------------
----------------------------------------------------------------------------------------------


local scriptStart 	= false
KeysTable			= require("./Mods/TeleportHotkeys/Scripts/KeysTable")

--UIManager 	= FindFirstOf("UIManager")
--FastTravel 	= FindFirstOf("FastTravelManager")
--PathManager = FindFirstOf("PathNavigationManager")
--
--FastTravel 			= FindFirstOf("FastTravelManager")
--UIManager 			= FindFirstOf("UIManager")
MsgPos 				= nil
KeyModifier			= ModifierKey.ALT


--------------------- WAYPOINT / MAP MARKER
RegisterKeyBind(waypointKey, {KeyModifier}, function()
	ExecuteInGameThread(function()
		
		local UIManager 	= FindFirstOf("UIManager")
		local FastTravel 	= FindFirstOf("FastTravelManager")
		local PathManager 	= FindFirstOf("PathNavigationManager")
		local MissLoc		= PathManager:GetMissionDestinationLocation()
		
		if MissLoc.X ~= 0 and MissLoc.Y ~= 0 then
			UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n UNABLE TO TELEPORT TO A WAYPOINT \nWHILE TRACKING A MISSION. \nUNTRACK THE MISSIONG AND RETRY.", MsgPos, true, 15)
			return
		end
		
		if PathManager:HasDestinationLocation(false) then
			
			local DestLoc 	= PathManager:GetPathDestinationLocation()
			local WayMark 	= PathManager:GetWaymarkerDestinationLocation()
			local hFix		= 1000 -- (1000 ok?, 500000 test)
				
			if DestLoc then 
				FixedDest1 = {	["X"] = DestLoc.X, 
								["Y"] = DestLoc.Y,
								["Z"] = DestLoc.Z + hFix }
					
				FastTravel:FastTravel_TeleportToXYZ(FixedDest1.X, FixedDest1.Y, FixedDest1.Z)
				DestLoc = nil --saved destination reset
				--print("\n  - Teleport Hotkeys: Used FixedDest1")
												
			elseif WayMark then --and not DestLoc ???
				FixedDest2 = {	["X"] = WayMark.X, 
								["Y"] = WayMark.Y,
								["Z"] = WayMark.Z + hFix }
								
				FastTravel:FastTravel_TeleportToXYZ(FixedDest2.X, FixedDest2.Y, FixedDest2.Z)
				WayMark = nil --saved destination reset
				--print("\n  - Teleport Hotkeys: Used FixedDest2")
				
			end
		else
			UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n NO WAYMARK PIN FOUND !", MsgPos, true, 10)
		end
	end)
end)


--------------------- MISSION MARKER
RegisterKeyBind(missionKey, {KeyModifier}, function()
	ExecuteInGameThread(function()
		
		local UIManager 	= FindFirstOf("UIManager")
		local FastTravel 	= FindFirstOf("FastTravelManager")
		local PathManager 	= FindFirstOf("PathNavigationManager")
		local MissLoc		= PathManager:GetMissionDestinationLocation()
		
		local FixedDest3 	= {	["X"] = MissLoc.X, 
								["Y"] = MissLoc.Y,
								["Z"] = MissLoc.Z }
		
		if PathManager:HasDestinationLocation(false) then
		
			if MissLoc.X ~= 0 and MissLoc.Y ~= 0 then
				FastTravel:FastTravel_TeleportToXYZ(FixedDest3.X, FixedDest3.Y, FixedDest3.Z)
				MissLoc = nil --saved destination reset
				--print("\n  - Teleport Hotkeys: Used FixedDest3")
			else
				UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n YOU'RE NOT TRACKING A MISSION !", MsgPos, true, 10)
			end
		else
			UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n NO MISSION TRACKED FOUND \nOR THE MISSION HAS NO LOCATION", MsgPos, true, 10)
		
		end
	end)
end)


--------------------- CLOSEST UNLOCKED SAVE LOCATION TO PLAYER
RegisterKeyBind(safeTelportKey, {KeyModifier}, function()
	ExecuteInGameThread(function()
		local FastTravel 	= FindFirstOf("FastTravelManager")
		FastTravel:StartFastTravelToClosestUnlockedSaveLocationToPlayer()
		--print("\n  - Teleport Hotkeys: Used safeTelportKey")
	end)
end)


--------------------- PathManager FIX
if scriptStart then
	if not PathManager:IsValid() then
		ExecuteWithDelay(4000, LoadingNew)
	end
--[[ Error: [Lua::call_function] 
lua_pcall returned Tried calling a member function 
but the UObject instance is nullptr \n 
stack traceback: [C]: in method 'HasDestinationLocation' --]]
end 


--------------------- HOTKEYS MESSAGE
function ShowHotkeys()
	if showHotkeysPopUp then
		local UIManager 	= FindFirstOf("UIManager")
		local HotKeysMsg	= "   TELEPORT HOTKEYS \n" 
							.. "\nWAYPOINT / MAP MARKER: " 	.. "[ ALT + " .. KeysTable.keys[waypointKey] 	.." ]"
							.. "\nTRACKED MISSION: " 		.. "[ ALT + " .. KeysTable.keys[missionKey]		.." ]"
							.. "\nSAFE TELEPORT: " 			.. "[ ALT + " .. KeysTable.keys[safeTelportKey]	.." "
		
		UIManager:SetAndShowHintMessage(HotKeysMsg, MsgPos, true, 8)
	end
end


------------------- MESSAGE CALL
--local testKey = Key.X
--RegisterKeyBind(testKey, {KeyModifier}, function()
--	ShowHotkeys()
--end)


--------------------- LOADING
NotifyOnNewObject("/Script/Phoenix.Loadingcreen", function(self)
    print('  - Teleport Hotkeys: LOADED')
    scriptStart = true
end)

function LoadingNew()
    local Loading = StaticFindObject("/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised")
    if not Loading:IsValid() then
       ExecuteWithDelay(3000, LoadingNew)
       return
    end

    RegisterHook("/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised", function()
		if scriptStart then
			scriptStart = false
			print(' - Teleport Hotkeys: RELOADED')
			
			ExecuteWithDelay(5000, function()
				ShowHotkeys()
			end)
		end
	end)
end

LoadingNew()

