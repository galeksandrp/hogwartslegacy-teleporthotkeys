-- TELEPORT HOTKEYS 
-- https://www.nexusmods.com/hogwartslegacy/mods/1289

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

-- This is the hotkey to show the Pop-Up Message with the bindings
-- DEFAULT: Key.END
messageKey = Key.END

-- Whether or not to show the in-game pop-up for hotkeys automatically after loading screens.
-- Set to true to enable the pop-up
-- DEFAULT: false
showHotkeysPopUp = false


--------------------------------------------------
--  D O  N O T   M O D I F Y   B E L O W  --------
--------------------------------------------------

local scriptStart 	= false
KeysTable			= require('./Mods/TeleportHotkeys/Scripts/KeysTable')
MsgPos 				= nil
KeyModifier			= ModifierKey.ALT


--------------------- HOTKEYS MESSAGE
function ShowHotkeys()
	local UIManager 	= FindFirstOf("UIManager")
	local HotKeysMsg	= "\n >>> TELEPORT HOTKEYS <<<\n" 
						.. "\nThis Message: " 			.. "[ ALT + " .. KeysTable.keys[messageKey] 	.." ]"
						.. "\n\nWAYPOINT / MAP MARKER: ".. "[ ALT + " .. KeysTable.keys[waypointKey] 	.." ]"
						.. "\nTRACKED MISSION: " 		.. "[ ALT + " .. KeysTable.keys[missionKey]		.." ]"
						.. "\nSAFE TELEPORT: " 			.. "[ ALT + " .. KeysTable.keys[safeTelportKey]	.." "
	UIManager:SetAndShowHintMessage(HotKeysMsg, MsgPos, true, 10)
end

--------------------- CLEAR MISSION PATH
function ClearMissionPath()
	local PathManager = FindFirstOf('PathNavigationManager')
	PathManager:ClearPathAndMissionTarget()
	print(" - Teleport Hotkeys: Mission Untracked")
end


--------------------- TELEPORT: WAYPOINT / MAP MARKER
function To_WaypointMapMarker()

local UIManager 	= FindFirstOf('UIManager')
local FastTravel 	= FindFirstOf('FastTravelManager')
local PathManager 	= FindFirstOf('PathNavigationManager')
local MissLoc		= PathManager:GetMissionDestinationLocation()

	ExecuteInGameThread(function()
		if MissLoc.X ~= 0 and MissLoc.Y ~= 0 then
			ClearMissionPath()
		end
		
		if PathManager:HasDestinationLocation(false) then
			
			local DestLoc 	= PathManager:GetPathDestinationLocation()
			local WayMark 	= PathManager:GetWaymarkerDestinationLocation()
			local hFix		= 2000 -- (1500 ok?, 50000 test)
				
			if DestLoc then 
				FixedDest1 = {	['X'] = DestLoc.X, ['Y'] = DestLoc.Y, ['Z'] = DestLoc.Z + hFix }
				FastTravel:FastTravel_TeleportToXYZ(FixedDest1.X, FixedDest1.Y, FixedDest1.Z)
				DestLoc = nil --saved destination reset
												
			elseif WayMark then --and not DestLoc ???
				FixedDest2 = {	['X'] = WayMark.X, ['Y'] = WayMark.Y, ['Z'] = WayMark.Z + hFix }
				FastTravel:FastTravel_TeleportToXYZ(FixedDest2.X, FixedDest2.Y, FixedDest2.Z)
				WayMark = nil --saved destination reset
				
			end
			
		else
			UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n NO WAYMARK PIN FOUND !", MsgPos, true, 8)
		end
	end)
end

--------------------- TELEPORT: MISSION MARKER 
function To_MissionMarker()
	local UIManager 	= FindFirstOf('UIManager')
	local FastTravel 	= FindFirstOf('FastTravelManager')
	local PathManager 	= FindFirstOf('PathNavigationManager')
	local MissLoc		= PathManager:GetMissionDestinationLocation()
	
	local FixedDest3 	= {	['X'] = MissLoc.X, ['Y'] = MissLoc.Y, ['Z'] = MissLoc.Z }
							
	ExecuteInGameThread(function()
		if PathManager:HasDestinationLocation(false) then
		
			if MissLoc.X ~= 0 and MissLoc.Y ~= 0 then
				FastTravel:FastTravel_TeleportToXYZ(FixedDest3.X, FixedDest3.Y, FixedDest3.Z)
				MissLoc = nil --saved destination reset
			else
				UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n YOU'RE NOT TRACKING A MISSION !", MsgPos, true, 8)
			end
		else
			UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n NO MISSION TRACKED FOUND \nOR THE MISSION HAS NO LOCATION", MsgPos, true, 8)
		end
	end)
end

--------------------- TELEPORT: CLOSEST UNLOCKED SAVE LOCATION TO PLAYER
function To_SafeLocation()
	local FastTravel 	= FindFirstOf('FastTravelManager')
	ExecuteInGameThread(function()
		FastTravel:StartFastTravelToClosestUnlockedSaveLocationToPlayer()
	end)
end


--------------------- BINDINGS: 
RegisterKeyBind(messageKey, {KeyModifier}, ShowHotkeys) --MESSAGE POP-UP
RegisterKeyBind(waypointKey, {KeyModifier}, To_WaypointMapMarker) --TO: WAYPOINT / MAP MARKER
RegisterKeyBind(missionKey, {KeyModifier}, To_MissionMarker) --TO: MISSION MARKER
RegisterKeyBind(safeTelportKey, {KeyModifier}, To_SafeLocation) --TO: UNLOCKED SAVE LOCATION TO PLAYER

------------------- TEST KEY - MESSAGE CALL
--local testKey = Key.X
--RegisterKeyBind(testKey, {KeyModifier}, function()
--	ShowHotkeys()
--end)

--------------------- LOADING
NotifyOnNewObject('/Script/Phoenix.Loadingcreen', function(self)
    print(" - Teleport Hotkeys: LOADED")
    scriptStart = true
end)

--if scriptStart then
--	if not PathManager:IsValid() then
--		ExecuteWithDelay(3000, LoadingNew)
--	end
--end 

function LoadingNew()
    local Loading = StaticFindObject('/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised')
    if not Loading:IsValid() then
       ExecuteWithDelay(3000, LoadingNew)
       return
    end
	
	--RegisterHook('/Script/Engine.PlayerController:ClientRestart', function(Context, NewPawn)
    RegisterHook('/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised', function()
		if scriptStart then
			scriptStart = false
			print(" - Teleport Hotkeys: RELOADED")
		end
		if showHotkeysPopUp then
			ExecuteWithDelay(5000, ShowHotkeys)
		end
	end)
end

LoadingNew()

