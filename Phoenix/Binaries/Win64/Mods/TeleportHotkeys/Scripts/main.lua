-- TELEPORT HOTKEYS 
-- https://www.nexusmods.com/hogwartslegacy/mods/1289

-- KEY CUSTOMIZATION: see "Available Keys.txt" inside the zip for available keys.


-- This is the hotkey that teleports you to the pinned Waypoint 
-- or to a tracked Map Marker
-- DEFAULT: Key.PAGE_UP
waypointKey = Key.PAGE_UP

-- This is the hotkey that teleports you to the Mission location
-- DEFAULT: Key.PAGE_DOWN
missionKey = Key.PAGE_DOWN

-- This is the hotkey that teleports you forward a few meters
-- DEFAULT: Key.F
forwardKey = Key.F

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
local msgShown		= false
KeysTable			= require('./Mods/TeleportHotkeys/Scripts/KeysTable')
MsgPos 				= nil
KeyModifier			= {ModifierKey.ALT}


--------------------- HOTKEYS MESSAGE
function ShowHotkeys()
  local HotKeysMsg = "\n >>> TELEPORT HOTKEYS <<<\n" 
    .. "\nThis Message: [ " 			..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[messageKey] 		.." ]"
    .. "\n\nWAYPOINT / MAP MARKER: [ "	..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[waypointKey] 		.." ]"
    .. "\nTRACKED MISSION: [ " 			..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[missionKey]		.." ]"
	.. "\nFORWARD: [ " 					..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[forwardKey]		.." ]"
    .. "\nSAFE TELEPORT: [ " 			..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[safeTelportKey]	.." " ;
  
  local UIManager	= FindFirstOf('UIManager')
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
  local PathManager = FindFirstOf('PathNavigationManager')
  local MissLoc		= PathManager:GetMissionDestinationLocation()
  

    if MissLoc.X ~= 0 and MissLoc.Y ~= 0 then
      ClearMissionPath()
    end
  	
  	if PathManager:HasDestinationLocation(false) then
  	  local DestLoc	= PathManager:GetPathDestinationLocation()
  	  local WayMark	= PathManager:GetWaymarkerDestinationLocation()
  	  local hFix	= 2000 -- (1500 ok?, 50000 test)
  			
      if DestLoc then 
        FixedDest1 = {['X'] = DestLoc.X, ['Y'] = DestLoc.Y, ['Z'] = DestLoc.Z + hFix}
        FastTravel:FastTravel_TeleportToXYZ(FixedDest1.X, FixedDest1.Y, FixedDest1.Z)
        DestLoc = nil --saved destination reset
  		
      elseif WayMark then --and not DestLoc ?
        FixedDest2 = {['X'] = WayMark.X, ['Y'] = WayMark.Y, ['Z'] = WayMark.Z + hFix}
        FastTravel:FastTravel_TeleportToXYZ(FixedDest2.X, FixedDest2.Y, FixedDest2.Z)
        WayMark = nil --saved destination reset
      end
    else
	  UIManager:SetAndShowHintMessage("  Teleport Hotkeys: \n NO WAYMARK PIN FOUND !", MsgPos, true, 8)
    end

end

--------------------- TELEPORT: MISSION MARKER 
function To_MissionMarker()
  local UIManager 	= FindFirstOf('UIManager')
  local FastTravel 	= FindFirstOf('FastTravelManager')
  local PathManager = FindFirstOf('PathNavigationManager')
  local MissLoc		= PathManager:GetMissionDestinationLocation()
  
  local FixedDest3 	= {	['X'] = MissLoc.X, ['Y'] = MissLoc.Y, ['Z'] = MissLoc.Z }
  						

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

end

--------------------- TELEPORT: CLOSEST UNLOCKED SAVE LOCATION TO PLAYER
function To_SafeLocation()
  local FastTravel = FindFirstOf('FastTravelManager')

    FastTravel:StartFastTravelToClosestUnlockedSaveLocationToPlayer()

end

--------------------- TELEPORT: FORWARD
function To_Forward()

	local Player 		= FindFirstOf('Biped_Player')
	local UIManager		= FindFirstOf('UIManager')
	local FastTravel 	= FindFirstOf('FastTravelManager')
	local forwardAmount = 350.0
	
	local PlLoc = Player:K2_GetActorLocation()
	local PlRot = Player:K2_GetActorRotation()
	local LocX = PlLoc["X"]
	local LocY = PlLoc["Y"]
	local LocZ = PlLoc["Z"] + 10
	local direction = math.rad(PlRot["Yaw"])
	
	local function getNewXY(x, y, orientation, forward)
		local getX = math.cos(orientation) * forward
		local getY = math.sin(orientation) * forward
		newLocation_X = x + getX
		newLocation_Y = y + getY
		return newLocation_X, newLocation_Y
	end
	
	getNewXY(LocX, LocY, direction, forwardAmount)
  	FastTravel:FastTravel_TeleportToXYZ(newLocation_X, newLocation_Y, LocZ)
	
	stuckMsg = "FORWARD TELEPORT:\nIf You're stuck, you can press again the hotkey"
				.."\n or Safe Teleport ( " ..KeysTable.modifiers[KeyModifier[1]].." + "..KeysTable.keys[safeTelportKey].." )"
	
	if not msgShown then
		UIManager:SetAndShowHintMessage(stuckMsg, MsgPos, true, 10)
		msgShown = true
	end

end


--------------------- BINDINGS: 
RegisterKeyBind(messageKey, KeyModifier, ShowHotkeys) 			--MESSAGE POP-UP
RegisterKeyBind(waypointKey, KeyModifier, To_WaypointMapMarker) --TO: WAYPOINT / MAP MARKER
RegisterKeyBind(missionKey, KeyModifier, To_MissionMarker) 		--TO: MISSION MARKER
RegisterKeyBind(forwardKey, KeyModifier, To_Forward) 			--TO FORWARD
RegisterKeyBind(safeTelportKey, KeyModifier, To_SafeLocation) 	--TO: CLOSEST UNLOCKED SAVE LOCATION TO PLAYER


--------------------- LOADING
NotifyOnNewObject('/Script/Phoenix.Loadingcreen', function(self)
  scriptStart = true --print(" - Teleport Hotkeys: LOADED")
end)

function LoadingNew()
  local Loading = StaticFindObject('/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised')
  if not Loading:IsValid() then
    ExecuteWithDelay(3000, LoadingNew)
    return
  end
  
  --RegisterHook('/Script/Engine.PlayerController:ClientRestart', function()
  RegisterHook('/Game/UI/LoadingScreen/UI_BP_NewLoadingScreen.UI_BP_NewLoadingScreen_C:OnCurtainRaised', function()
    if scriptStart then
      scriptStart = false
      print(" - Teleport Hotkeys: RELOADED")
      if showHotkeysPopUp then
        ShowHotkeys() --ExecuteWithDelay(5000, ShowHotkeys)
      end
    end
  end)
end

LoadingNew()
