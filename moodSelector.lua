-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, ns = ...

-- Localize our mood addon
local mood = ns.mood

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

local function OutputMood (method, mood, names)

  -- Our toons name
  local playerName = UnitName("player")

  -- Replace string literals with real value
  local string = moodDB["methods"][method]["string"]

  if string.find(string, "@mood@") then
    string = string.gsub(string, "@mood@", mood)
  end

  if string.find(string, "@name@") then
    string = string.gsub(string, "@name@", playerName)
  end

  -- Output the strings
  if method == "SELF" then
    print("mood: " .. string)
  elseif method ~= "WHISPER" or method ~= "CHANNEL" then
    SendChatMessage(string, method)
  elseif method == "WHISPER" then
    for _, name in pairs(names) do
      --if UnitIsConnected(name) then
      SendChatMessage(string, method, nil, name)
      --end
    end
  elseif method == "CHANNEL" then
    for _, name in pairs(names) do
      local id = GetChannelName(name)
      if id ~= nil then
        SendChatMessage(string, method, nil, id)
      end
    end
  end

end

-------------------
-- Frame Factory --
-------------------
function mood:CreateFrame (frameType, name, parent, inherit, setPoints, width, height, strata)

  local frame

  -- There has to be an easier way to do this in LUA.
  if frameType ~= nil and name ~= nil and parent ~= nil and inherit ~= nil then
    frame = CreateFrame(frameType, name, parent, inherit)
  elseif frameType ~= nil and name ~= nil and parent ~= nil and inherit == nil then
    frame = CreateFrame(frameType, name, parent)
  elseif frameType ~= nil and name ~= nil and parent == nil and inherit == nil then
    frame = CreateFrame(frameType, name)
  elseif frameType ~= nil and name == nil and parent == nil and inherit == nil then
    frame = CreateFrame(frameType)
  else -- Generic fream creation
    frame = CreateFrame"Frame"
  end

  -- Data in the array should look like the following
  -- This array can be an array of these arrays to allow for them to carry out multiple setpoint operations.
  --[[
  points = {
  ["point"] = Point to adjust to based on anchor.
  ["ofsx"] = Frame X Offset
  ["ofsy"] = Frame Y Offset
  ["relativeFrame"] = Name of frame/object to attach to.
  ["realtivePoint"] = Point relativeFrame will attach to.
  }
  --]]
  if setPoints ~= nil then
    frame:ClearAllPoints()

    if type(setPoints) == "table" then
      if setPoints["point"] == nil or type(setPoints[0]) == "table" then
        for point in pairs(setPoints) do
          if type(point) == "table" and point["point"] ~= nil then
            frame:SetPoint(point.point, point.relativeFrame, point.relativePoint, point.ofsx, point.ofsy)
          end
        end
      else
        frame:SetPoint(setPoints.point, setPoints.relativeFrame, setPoints.relativePoint, setPoints.ofsx, setPoints.ofsy)
      end
    elseif type(setPoints) == "string" then
      frame:SetPoint(setPoints)
    end
  end

  if width ~= nil then
    frame:SetWidth(width)
  end

  if height ~= nil then
    frame:SetHeight(height)
  end

  if strata ~= nil then
    frame:SetFrameStrata(strata)
  end

  -- Return the frame
  return frame
end

------------------------------------------
-- Create the main Frames for the addon --
------------------------------------------
function mood:CreateMoodFrames ()

  ----------------------------
  -- OnClick (mood buttons) --
  ----------------------------
  local OnClick = function(self, button, currentMood)

    for method, data in pairs(moodDB.methods) do

      local checked = data.checked
      local names = data.names

      if checked then
        OutputMood(method, currentMood, names)
      end
    end

    -- Save our mood
    moodDB.mood = currentMood

    -- Save our last login date just to be safe if we crash or change zones or basically pick our nose
    mood:SaveDate()

    -- Toggle the frame
    ToggleFrame(frames.main.frame)
  end

  local mainDB = moodDB.frames

  --------------------------
  -- Create the mainframe --
  --------------------------
  if not frames.main.frame or frames.main.frame ~= nil then

    local framePoints = {
      ["point"] = mainDB.main.position.point,
      ["relativeFrame"] = mainDB.main.position.anchor or UIParent,
      ["relativePoint"] = mainDB.main.position.refPoint,
      ["ofsx"] = mainDB.main.position.x,
      ["ofsy"] = mainDB.main.position.y,
    }

    -- Create our main frame
    -- Reference function -> mood:CreateFrame(frameType, name, parent, inherit, setPoints, width, height, strata)

    local mainframe = mood:CreateFrame("Frame", "mood_Frame_mood", UIParent, nil, framePoints, mainDB.main.width, mainDB.main.height, "BACKGROUND")

    -- locally customize the mood panel
    mainframe:EnableMouse(true)
    mainframe:SetBackdrop(frameTables.backdrop.table)
    mainframe:SetBackdropColor(unpack(frameTables.backdrop.color))
    mainframe:SetBackdropBorderColor(unpack(frameTables.border.color))

    mainframe.text = mainframe:CreateFontString(nil, "OVERLAY")
    mainframe.text:SetFont(mainDB.font.normal, 12)
    mainframe.text:SetPoint("TOP", mainframe, "TOP", 0, -5)
    mainframe.text:SetText("Select a mood:")
    mainframe:Hide()

    -- Allow our main frame to move by left mouse button and save the position after it gets done moving
    mainframe:SetMovable(true)
    mainframe:RegisterForDrag("LeftButton")
    mainframe:SetScript("OnDragStart", mainframe.StartMoving)
    mainframe:SetScript("OnDragStop", function(self)
      self:StopMovingOrSizing()
      point, anchor, refPoint, x, y = self:GetPoint()
      mainDB.main.position.point = point
      mainDB.main.position.refPoint = refPoint
      mainDB.main.position.x = x
      mainDB.main.position.y = y
      mainDB.main.position.anchor = anchor
    end)

    -- Set previous silenced check and clean up globals cuz we are cool!
    mainframe:SetScript("OnShow", function() mood_CheckButton_Silenced:SetChecked(moodDB.silenced); collectgarbage() end)

    -- Set our mainframe to the frame references table
    frames.main.frame = mainframe


    ------------------
    -- Mood Buttons --
    ------------------
    do
      local bWidth = mainframe:GetWidth() - 10

      local bPoints = {
        [1] = {
          ["ofsx"] = 0,
          ["ofsy"] = -25,
          ["relativePoint"] = "TOP",
          ["point"] = "TOP",
          ["relativeFrame"] = mainframe,
        },
        [2] = {
          ["ofsx"] = 0,
          ["ofsy"] = -5,
          ["relativePoint"] = "BOTTOMLEFT",
          ["point"] = "TOPLEFT",
          ["relativeFrame"] = mainframe,
        },
      }

      for id, button in pairs(mainDB.main.buttons) do
        -- Reference function -> mood:CreateFrame(frameType, name, parent, inherit, setPoints, width, height, strata)
        local point = id == 1 and bPoints[1] or bPoints[2]
        local b = mood:CreateFrame("Button", "mood_Button_" .. button.name, mainframe, "UIPanelButtonTemplate", point, bWidth, 25, nil)
        b:SetText("")

        -- Custom font string for button (Color coding button text is FUN!)
        local text = b:CreateFontString(nil, "OVERLAY")
        text:SetFont(mainDB.font.normal, 11)
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

        -- Save for moving new buttons below this one
        bPoints[2]["relativeFrame"] = b

        -- Save to our reference table
        frames["main"]["buttons"][button.name] = b
      end
    end


    -----------------
    -- CheckButton --
    -----------------
    do
      local point = {
        ["ofsx"] = 0,
        ["ofsy"] = -1,
        ["relativePoint"] = "BOTTOMLEFT",
        ["point"] = "TOPLEFT",
        ["realtiveFrame"] = _G["mood_Button_" .. mainDB.main.buttons[#(mainDB.main.buttons)]["name"]],
      }

      --function mood:CreateFrame (frameType, name, parent, inherit, setPoints, width, height, strata)
      local checkButton = mood:CreateFrame("CheckButton", "mood_CheckButton_Silenced", mainframe, nil, point, 18, 18, nil)
      -- This need to change and we need to grab the last button's name and calculate the off reference name.
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
      checkButtonText:SetFont(mainDB.font.normal, 11)
      checkButtonText:SetPoint("LEFT", checkButton, "RIGHT", 2, 0)
      checkButtonText:SetText("Silenced")
      checkButtonText:Show()

      frames.main.checkbutton.text = checkButtonText

    end -- Check Button

  end -- if not frames.main.frame or frames.main.frame ~= nil then

  if moodDB.debug == true then
    mood.frames = frames
  end

end -- function mood:CreateMoodFrames ()

function mood:ToggleFrame (frameName)
  if type(frameName) == "string" then
    if frameName == "mood" then
      ToggleFrame(frames.main.frame)
    end
  end
end
