-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
local _VERSION = GetAddOnMetadata(parent, 'version')
_G["mood"] = mood

-- Local variables
local dummy = function() end
local newChar = false
local font = [=[Interface\Addons\mood\media\neuropol x cd rg.ttf]=]

local backdropTable = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0}
}
local backdropColor = {0.1, 0.1, 0.1, 1}

local borderTable = {
	bgFile = nil,
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeSize = 2,
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}
local borderColor = {0.6, 0.6, 0.6, 1}

local frames = {
	['main'] = {
		['frame'] = nil,
		['buttons'] = {},
	}
}

-- Used to streamline frame creations
local FrameFactory = function(name, x, y, width, height, point, rpoint, anchor, parent, inherit, strata, mouse)
	local panel = CreateFrame("Frame", name, parent, inherit)
	panel:EnableMouse(mouse)
	panel:SetFrameStrata(strata)
	panel:SetWidth(width)
	panel:SetHeight(height)
	panel:SetPoint(point, anchor, rpoint, x, y)
	panel:SetBackdrop(backdropTable)
	panel:SetBackdropColor(unpack(backdropColor))
	panel:SetBackdropBorderColor(unpack(borderColor))
	
	panel.text = panel:CreateFontString(nil, "OVERLAY")
	panel.text:SetFont(font, 12)
	panel.text:SetPoint("TOP", panel, "TOP", 0, -5)
	panel.text:SetText("Select a mood:")
	panel:Hide()
	return panel
end

-- Used to streamline the button creation
local ButtonFactory = function(name, caption, parent, width, height, font, color)
	local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetText("") -- Clear the button text for custom font usage.

	local text = button:CreateFontString(nil, "OVERLAY")
	text:SetFont(font, 11)
	text:SetPoint("CENTER", button, "CENTER", 0, 0)
	text:SetTextColor(unpack(color))
	text:SetAlpha(1) -- Just incase the color pack has a different alpha
	text:SetText(caption)
	text:Show()

	-- Skinning buttons
	button:SetNormalTexture("")
	button:SetPushedTexture("")
	button:SetHighlightTexture("")
	button:SetDisabledTexture("")

	button:SetBackdrop(backdropTable)
	button:SetBackdropColor(unpack(backdropColor))
	button:SetBackdropBorderColor(unpack(color))

	button:RegisterForClicks("LeftButtonUp")
	button:Show()
	return button
end

------------------------
-- Handles the output --
------------------------
local handleOutput = function(method, mood, names)
	local string = moodG['strings'][method]

	if method == "WHISPER" or method == "CHANNEL" then
		for _, player in pairs(names) do
			SendChatMessage(format(string, mood), method, nil, player)
		end
	elseif method == "SELF" then
		print("mood: " .. format(string, mood))
	end
end

--------------------------------
-- Handle the button clicking --
--------------------------------
local buttonOnClick = function(self, button, mood)
	for _, method in pairs(moodG.methods) do
		local checked = moodP['settings']['methods'][method]['checked']
		local names = moodP['settings']['methods'][method]['names']
		if checked then
			handleOutput(method, mood, names)
		end
	end

	-- Save our mood
	moodP.currentMood = mood

	-- Close mood frame
	frames.main.frame:Hide()
end

-- global variables
playerClass = select(2, UnitClass("player"))

-- OnEvent's to addon loading
local loaderOnEvent = function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if not moodG or moodG == nil or moodG == {} then
			local playerName = UnitName("player")

			moodG = {
				['methods'] = {
					"WHISPER", "CHANNEL", "PARTY", "GUILD", "OFFICER", "EMOTE", "SELF"
				},
				['strings'] = {
					['GUILD'] = playerName .. "'s mood is currently set to %s.",
					['OFFICER'] = playerName .. "'s mood is currently set to %s.",
					['WHISPER'] = "I'm currently in a %s mood.",
					['PARTY'] = "I'm currently in a %s mood.",
					['CHANNEL'] = "I'm currently in a %s mood.",
					['EMOTE'] = "is currently in a %s mood.",
					['SELF'] = "Your mood is currently set to %s.",
				},
			}
		end

		if not moodP or moodP == nil or moodP == {} then
			-- Used to flag for new character going into PLAYER_ENTERING_WORLD.
			newChar = true

			moodP = {
				['settings'] = {
					['methods'] = {
						["WHISPER"] = {
							['checked'] = false,
							['names'] = {},
						},
						["CHANNEL"] = {
							['checked'] = false,
							['names'] = {},
						},
						["PARTY"] = {
							['checked'] = false,
						},
						["GUILD"] = {
							['checked'] = false,
						},
						["OFFICER"] = {
							['checked'] = false,
						},
						["EMOTE"] = {
							['checked'] = false,
						},
						["SELF"] = {
							['checked'] = false,
						},
					},
					['mood'] = "Ok",
				},
				['frames'] = {
					['main'] = {
						[''] = "",
						[''] = "",
						[''] = "",
						['x'] = 100,
						['y'] = 112,
					},
					['buttons'] = {
						[1] = {
							['name'] = "Excellent",
							['color'] = {0, 1, 0, .4},
						},
						[2] = {
							['name'] = "Ok",
							['color'] = {1, 1, 0, .4},
						},
						[3] = {
							['name'] = "Terrible",
							['color'] = {1, 0, 0, .4},
						},
					},
				},
				['strings'] = moodG.strings,
			}
		end

		self:UnregisterEvent(event)
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		if not moodP.lastLogin then return end

		-- Frame to hold the moood select options
		-- We are doing this after the loader loads so that we can have saved data.
		if not frames.main.frame or frames.main.frame ~= nil then
			--local FrameFactory = function(name, x, y, width, height, point, rpoint, anchor, parent, inherit, strata, mouse)
			local moodselect = FrameFactory(
				"moodselect",
				moodP.frames.main.x or 0,
				moodP.frames.main.y or 0,
				100, 112,
				moodP.frames.main.point or "CENTER",
				moodP.frames.main.rPoint or "CENTER",
				UIParent, UIParent, "ButtonFrameTemplate", "BACKGROUND", true)

			-- Setup main frame to allow for movement and save it's position after done moving.
			moodselect:SetMovable(true)
			moodselect:RegisterForDrag("LeftButton")
			moodselect:SetScript("OnDragStart", moodselect.StartMoving)
			moodselect:SetScript("OnDragStop", function(self)
				self:StopMovingOrSizing()
				point, _, rpoint, x, y = self:GetPoint()
				moodP.frames.main.point = point
				moodP.frames.main.rpoint = rpoint
				moodP.frames.main.x = x
				moodP.frames.main.y = y
			end)

			-- Close the frame on by pressing the right mouse button on the frame
			--[[
			moodselect:RegisterForClicks("RightMouseUp")
			moodselect:SetScript("OnMouseUp", function(self, ...)
				local arg1 = ...

				if arg1 == "RightButton" then
					self:Hide()
				end
			end)
			--]]

			frames.main.frame = moodselect
		end

		-- Setup the buttons
		if not frames.main.buttons or frames.main.buttons ~= {} then
			for id, button in pairs(moodP.frames.buttons) do
				local b = ButtonFactory("mood_" .. button.name .. "Button", button.name, frames.main.frame, frames.main.frame:GetWidth() - 10, 24, font, button.color)

				b:ClearAllPoints()

				if id == 1 then
					b:SetPoint("TOP", frames.main.frame, "TOP", 0, -25)
				else
					b:SetPoint("TOPLEFT", buttonPrev, "BOTTOMLEFT", 0, -5)
				end

				b:SetScript("OnClick", function(self, bu) buttonOnClick(self, bu, button.name) end)

				buttonPrev = b
				frames['main']['buttons'][button.name] = b
			end
		end

		local weekday, month, day, year = CalendarGetDate()
		if moodP.lastLogin ~= {weekday,month,day,year} then
			local method = moodP.settings.method
			local mood = moodP.settings.mood
			local string = moodG['strings'][method]
		
			if method == "WHISPER" or method == "CHANNEL" then 
				for _, player in ipairs(moodP.settings.names) do
					SendChatMessage(format(string, mood), method, nil, player)
				end
			end

			self:UnregisterEvent(event)
		end

	elseif event == "PLAYER_LOGOUT" then
		local weekday, month, day, year = CalendarGetDate()
		moodP.lastLogin = string:join({weekday, month, day, year})
		moodP = sort(moodP)
		moodG = sort(moodG)
	end
end


-- Handles the loading of the addon
local moodLoader = CreateFrame"Frame"

moodLoader:RegisterEvent("PLAYER_LOGIN") -- Used to pull back previous mood.
moodLoader:RegisterEvent("PLAYER_ENTERING_WORLD") -- Used to set the new mood for first loads into the world.
moodLoader:RegisterEvent("PLAYER_LOGOUT") -- Used to save our var off before we leave game, Justin Case

moodLoader:SetScript("OnEvent", loaderOnEvent)


-- Slash command
SlashCmdList["MOOD"] = function() ToggleFrame(frames.main.frame) end
SLASH_MOOD1 = "/mood"
