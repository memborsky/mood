-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, ns = ...
local global = GetAddOnMetadata(parent, 'X-mood')
local _VERSION = GetAddOnMetadata(parent, 'version')

local mood = {}

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
		mood:CreateMood()

		-- If we aren't on the same day, fire open the window to ask for the players mood today
		if not mood:LoggedToday() then
			mood:ToggleMood()
		end

		-- Create the options interface frameage
		--mood:CreateOptions()
		--
	elseif event == "PLAYER_LOGOUT" then
	
		-- Save them vars for next time
		mood:SaveVars()

	end

  -- Unregister the event from the module.
  self:UnregisterEvent(event);

end

mood:RegisterEvent("ADDON_LOADED") -- Used to pull back previous mood:
mood:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.
mood:RegisterEvent("PLAYER_LOGOUT") -- Used to save our var off before we leave game, Justin Case

mood:SetScript("OnEvent", OnEvent)

-- Slash command
SlashCmdList["MOOD"] = function() mood:ToggleMood() end
SLASH_MOOD1 = "/mood"

if (global) then
  if (parent ~= 'mood' and global == 'mood') then
    error("%s is doing it wrong and settings its global to mood.", parent)
  else
    _G[parent] = mood
  end
end
ns.mood = mood
