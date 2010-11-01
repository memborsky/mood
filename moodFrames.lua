-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
local _VERSION = GetAddOnMetadata(parent, 'version')
_G["mood"] = mood

-----------------
-- mood Frames --
-----------------
local frames = {
	["main"] = {
		["frame"] = nil,
		["buttons"] = {},
		["checkbutton"] = {},
	},
}

local frameTables = {
	["backdrop"] = {
		["table"] = {
			bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
			edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
			edgeSize = 1,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		},
		["color"] = {0.1, 0.1, 0.1, 1},
	},
	["border"] = {
		["table"] = {
			bgFile = nil,
			edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
			edgeSize = 2,
			insets = {left = 2, right = 2, top = 2, bottom = 2}
		},
		["color"] = {0.6, 0.6, 0.6, 1},
	},
}

------------------------------------------
-- Create the main Frames for the addon --
------------------------------------------
mood.CreateMood = function ()

	-- Handle string out
	local output = function(method, mood, names)

		-- Our toons name
		local playerName = UnitName("player")

		---------------------------------------------
		-- Replace string literals with real value --
		---------------------------------------------
		local string = moodDB["methods"][method]["string"]

		if string.find(string, "@mood@") then
			string = string.gsub(string, "@mood@", mood)
		end

		if string.find(string, "@name@") then
			string = string.gsub(string, "@name@", playerName)
		end

		------------------------
		-- Output the strings --
		------------------------
		if method == "SELF" then
			print("mood: " .. string)
		end
	end

	----------------------------
	-- OnClick (mood buttons) --
	----------------------------
	local OnClick = function(self, button, mood)

		for method, data in pairs(moodDB.methods) do

			local checked = data.checked
			local names = data.names

			if checked then
				output(method, mood, names)
			end
		end

		-- Save our mood
		moodDB.ood = mood

		-- Close mood frame
		frames.main.frame:Hide()
	end


	--------------------------
	-- Create the mainframe --
	--------------------------
	if not frames.main.frame or frames.main.frame ~= nil then
		-- Create our main frame
		local mainframe = CreateFrame("Frame", "moodFrame_mood", UIParent)
		mainframe:EnableMouse(true)
		mainframe:SetFrameStrata("BACKGROUND")
		mainframe:SetWidth(moodDB.frames.main.width)
		mainframe:SetHeight(moodDB.frames.main.height)
		mainframe:SetPoint(
			moodDB.frames.main.position.point,
			moodDB.frames.main.anchor,
			moodDB.frames.main.position.refPoint,
			moodDB.frames.main.position.x,
			moodDB.frames.main.position.y
		)

		mainframe:SetBackdrop(frameTables.backdrop.table)
		mainframe:SetBackdropColor(unpack(frameTables.backdrop.color))
		mainframe:SetBackdropBorderColor(unpack(frameTables.border.color))

		mainframe.text = mainframe:CreateFontString(nil, "OVERLAY")
		mainframe.text:SetFont(moodDB.frames.font.normal, 12)
		mainframe.text:SetPoint("TOP", mainframe, "TOP", 0, -5)
		mainframe.text:SetText("Select a mood:")
		mainframe:Hide()

		-- Set frame name just in case for later reference
		mainframe.name = "mood"

		-- Allow our main frame to move by left mouse button and save the position after it gets done moving
		mainframe:SetMovable(true)
		mainframe:RegisterForDrag("LeftButton")
		mainframe:SetScript("OnDragStart", mainframe.StartMoving)
		mainframe:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			point, _, rpoint, x, y = self:GetPoint()
			moodDB.frames.main.position.point = point
			moodDB.frames.main.position.refPoint = rpoint
			moodDB.frames.main.position.x = x
			moodDB.frames.main.position.y = y
		end)

		-- Set previous silenced check and clean up globals cuz we are cool!
		mainframe:SetScript("OnShow", function() mood_CheckButton_Silenced:SetChecked(moodDB.silenced); collectgarbage() end)
				
		-- Set our mainframe to the frame references table
		frames.main.frame = mainframe


		------------------
		-- Mood Buttons --
		------------------
		local bPrev

		for id, button in pairs(moodDB.frames.main.buttons) do
			local b = CreateFrame("Button", "moodButton_" .. button.name, mainframe, "UIPanelButtonTemplate")
			b:SetSize(mainframe:GetWidth() - 10, 25)
			b:SetText("")

			-- Custom font string for button (Color coding button text is FUN!)
			local text = b:CreateFontString(nil, "OVERLAY")
			text:SetFont(moodDB.frames.font.normal, 11)
			text:SetPoint("CENTER", b, "CENTER", 0, 0)
			text:SetTextColor(unpack(button.color))
			text:SetAlpha(1) -- Just incase the color pack has a lower alpha
			text:SetText(button.name)
			text:Show()

			-- Skin the button
			b:SetNormalTexture("")
			b:SetPushedTexture("")
			b:SetHighlightTexture("")
			b:SetDisabledTexture("")
			b:SetBackdrop(frameTables.backdrop.table)
			b:SetBackdropColor(unpack(frameTables.backdrop.color))
			b:SetBackdropBorderColor(unpack(button.color))

			-- Set it up for left button clicks and take care of the click
			b:RegisterForClicks("LeftButtonUp")
			b:SetScript("OnClick", function(self, bu) OnClick(self, bu, button.name) end)

			-- Set the buttons name for later retrival
			b.name = name
			b:Show()

			-- Move the button into place
			b:ClearAllPoints()

			if id == 1 then
				-- Our first button on the frame
				b:SetPoint("TOP", mainframe, "TOP", 0, -25)
			else
				-- all the rest of the buttons
				b:SetPoint("TOPLEFT", bPrev, "BOTTOMLEFT", 0, -5)
			end

			-- Save for moving new buttons below this one
			bPrev = b

			-- Save to our reference table
			frames["main"]["buttons"][button.name] = b
		end


		-----------------
		-- CheckButton --
		-----------------
		local checkButton = CreateFrame("CheckButton", "mood_CheckButton_Silenced", mainframe)
		checkButton:SetWidth(18)
		checkButton:SetHeight(18)
		checkButton:SetPoint("TOPLEFT", bPrev, "BOTTOMLEFT", 0, -1)
		checkButton:SetFrameLevel(mainframe:GetFrameLevel() + 1)

		-- Save on clicking
		checkButton:SetScript("OnClick", function(self) moodDB.silenced = self:GetChecked() end)

		checkButton:SetHitRectInsets(0, -65, 0, 0)

		checkButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		checkButton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		checkButton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		checkButton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		checkButton:Show()

		frames.main.checkbutton.button = checkbutton

		local checkButtonText = checkButton:CreateFontString(nil, "OVERLAY")
		checkButtonText:SetFont(moodDB.frames.font.normal, 11)
		checkButtonText:SetPoint("LEFT", checkButton, "RIGHT", 2, 0)
		checkButtonText:SetText("Silenced")
		checkButtonText:Show()

		frames.main.checkbutton.text = checkButtonText
		
	end

end

mood.ToggleMood = function()
	ToggleFrame(frames.main.frame)
end
