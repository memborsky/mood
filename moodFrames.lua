-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
local _VERSION = GetAddOnMetadata(parent, 'version')
_G["mood"] = mood

-----------------
-- mood Frames --
-----------------
local frames = {
  ["main"] = nil,
  ["buttons"] = {},
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

----------------------------
-- Frame Factory Creation --
  ----------------------------
local FrameFactory = function(name, x, y, width, height, point, rpoint, anchor, parent, inherit, strata, mouse)
  local panel = CreateFrame("Frame", "mood_" .. name, parent, inherit)
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

  panel.name = name
  return panel
  end

  -----------------------------
  -- Button Factory Creation --
  -----------------------------
local ButtonFactory = function(name, caption, parent, width, height, font, color)
  local button = CreateFrame("Button", "mood_" .. name, parent, "UIPanelButtonTemplate")
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

  button.name = name

  return button
end

------------------------------------------
-- Create the main Frames for the addon --
------------------------------------------
mood.CreateFrames = function ()

  -- Handle string out
  local outputString = function(method, mood, names)

    -- Allow the user to replace strings using @<var>@ as a dynamic replacement in the string
    -- 
    -- @playername@ (non-case match) = mood.vars.personal.playerName
    -- @mood@ (non-case match) = mood.vars.personal.mood
    local string = mood['vars']['personal']['strings'][method]

    --if string.find(string, "@mood@") then

    if method == "WHISPER" or method == "CHANNEL" then
      for _, player in pairs(names) do
        SendChatMessage(format(string, mood), method, nil, player)
      end
    elseif method == "SELF" then
      print("mood: " .. format(string, mood))
    end
  end

  -- Handle button clicking
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


end

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
