local parent, ns = ...
local version = GetAddOnMetadata(parent, 'version')

local dummy = function() end

local playerClass = select(2, UnitClass("player"))
local playerName = UnitName("Player")
local playerRealm = GetRealmName()

local output = {
	['guild'] = playerName .. "'s mood is currently set to %s.",
	['whisper'] = "Is currently in a %s mood.",
	['party'] = "I'm currently in a %s mood.",
	['raid'] = "I'm currently in a %s mood.",
}

local whisper = {
	"Keltric", "Belliofria", "Jankly", -- addon author (Bell) used for testing
}


local mood = CreateFrame"Frame"

local OnEvent = function(self, event, arg1, ...)
	if (event == "ADDON_LOADED" and arg1 == "currentMood") then
		if currentMood == nil then
			currentMood = "Happy"	
		else
			for player in ipairs(whisper) do
				if UnitIsConnected(player) then
					SendChatMessage(format(output['whisper'], currentMood), "WHISPER", nil, player)
				end
			end
		end
	end
end

mood:RegisterEvent("ADDON_LOADED") -- Used to pull back previous mood.
mood:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.

mood:SetScript("OnEvent", OnEvent)
