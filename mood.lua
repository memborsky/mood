-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
local _VERSION = GetAddOnMetadata(parent, 'version')
_G["mood"] = mood

-- OnEvent's to addon loading
local loaderOnEvent = function(self, event, ...)
	if event == "ADDON_LOADED" then
		-- Check we are loading our vars
		local name = ...

		if name == "mood" then
			-- Load'em up!
			mood.LoadVars()

			-- Make sure we don't attempt to load more than once
			self:UnregisterEvent(event)
		end
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		-- Create the main mood selection frame
		mood.CreateMood()

		-- If we aren't on the same day, fire open the window to ask for the players mood today
		if not mood.LoggedToday() then
			mood.ToggleMood()
		end

		-- Create the options interface frameage
		--mood.CreateOptions()
		--
	elseif event == "PLAYER_LOGOUT" then
	
		-- Save them vars for next time
		mood.SaveVars()

	end
end


-- Handles the loading of the addon
local moodLoader = CreateFrame"Frame"

moodLoader:RegisterEvent("ADDON_LOADED") -- Used to pull back previous mood.
moodLoader:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.
moodLoader:RegisterEvent("PLAYER_LOGOUT") -- Used to save our var off before we leave game, Justin Case

moodLoader:SetScript("OnEvent", loaderOnEvent)


-- Slash command
SlashCmdList["MOOD"] = function() mood.ToggleMood() end
SLASH_MOOD1 = "/mood"
