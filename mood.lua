-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, ns = ...
local global = GetAddOnMetadata(parent, 'X-mood')
local _VERSION = GetAddOnMetadata(parent, 'version')

local mood = CreateFrame"Frame"

-- OnEvent's to addon loading
local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		-- Check we are loading our vars
		local name = ...

		if name == "mood" then
			-- Load'em up!
			mood:LoadVars(_VERSION)

		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		-- Create the main mood selection frame
		mood:CreateMoodFrames()

		-- If we aren't on the same day, fire open the window to ask for the players mood today
		if not mood:LoggedToday() then
			mood:ToggleFrame("mood")
		end

		-- Create the options interface frameage
		--mood:CreateOptions()
		--
	elseif event == "PLAYER_LOGOUT" then

		-- Save them vars for next time
		mood:SaveVars()

	end

	-- Unregister the event from the module.
	--self:UnregisterEvent(event);

end

mood:RegisterEvent("ADDON_LOADED") -- Used to pull back previous mood:
mood:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.
mood:RegisterEvent("PLAYER_LOGOUT") -- Used to save our var off before we leave game, Justin Case

mood:SetScript("OnEvent", OnEvent)

-- Slash command
SLASH_MOOD1 = "/mood"
function SlashCmdList.MOOD(message)
	message = strtrim(message or "")

	if message == "" then
		mood:ToggleFrame("mood")
	elseif message == "options" then
		print("Doing options window")
	elseif message == "players" then
		print("Doing mood players frame toggle")
	elseif message == "debugon" then
		print("Turning mood debugging on.")
		moodDB.debug = true
	elseif message == "debugoff" then
		print("Turning mood debugging off.")
		moodDB.debug = false
	else
		print("mood usage:")
		print("/mood - toggle mood select frame")
		print("/mood options - open to mood options pane")
		print("/mood players - toggle mood players pane")
	end
end

-- Jacked from haste's oUF for globalizing the mood namespace var
if (global) then
	if (parent ~= 'mood' and global == 'mood') then
		error("%s is doing it wrong and settings its global to mood.", parent)
	else
		_G[parent] = mood
	end
end
ns.mood = mood
