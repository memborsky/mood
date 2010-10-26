-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, ns = ...
local _VERSION = GetAddOnMetadata(parent, 'version')
local global = GetAddonMetadata(parent, 'X=mood')

local mood = {}

-- Local variables
local dummy = function() end
local playerClass = select(2, UnitClass("player"))
local playerName = UnitName("Player")
local playerRealm = GetRealmName()
local newCharacter = true

-- 
mood.frames = {}
mood.strings = {}
mood.outputMethods = {}



mood.strings = {
	['guild'] = playerName .. "'s mood is currently set to %s.",
	['whisper'] = "Is currently in a %s mood.",
	['party'] = "I'm currently in a %s mood.",
	['raid'] = "I'm currently in a %s mood.",
}

local whisper = {
	"Keltric", "Belliofria", "Jankly", -- addon author (Bell) used for testing
}

---------------------------------------
-- Stuff to hanlde loading the addon --
---------------------------------------

local mood.loader = CreateFrame"Frame"

local OnEvent = function(self, event, ...)
	if event == "ADDON_LOADED" then
		local arg1 = ...
		if arg1 == "currentMood" and currentMood == nil then
			currentMood = "Happy"				
			-- Fire mood frame to set new mood.
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		for _, player in ipairs(whisper) do
			print(player)
			if UnitIsConnected(player) then
				SendChatMessage(format(output['whisper'], currentMood), "WHISPER", nil, player)
			end
		end
	end
end

mood.loader:RegisterEvent("ADDON_LOADED") -- Used to pull back previous mood.
mood.loader:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.

mood.loader:SetScript("OnEvent", OnEvent)

--------------------
-- Globalize mood --
--------------------
-- Jacked from haste/oUF
mood.version = _VERSION

if (global) then
	if (parent ~= "mood" and global == "mood") then
		error("%s is doing it wrong and setting its global to mood.", parent)
	else
		_G[global] = oUF
	end
end
ns.mood = mood
