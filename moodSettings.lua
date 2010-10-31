-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
_G["mood"] = mood

-----------
-- Fonts --
-----------
mood.fonts = {
  ["normal"] = [=[Interface\Addons\mood\media\neuropol x cd rg.ttf]=]
}

-----------------------------
-- Handles loading of vars --
  -----------------------------
mood.LoadVars = function ()
  -- Used for string output literals
  local playerName = UnitName("player");

  -- Used to initialize the last time we logged in to be today.
  local weekday, month, day, year = CalendarGetDate();

  -- Load our variables
  mood.vars = {
    -- Default variables
      ["default"] = {
        ["methods"] = {"WHISPER", "CHANNEL", "PARTY", "GUILD", "OFFICER", "EMOTE", "SELF"},
        ["strings"] = {
          ["GUILD"] = "I'm currently in a @mood@ mood.",
          ["OFFICER"] = "I'm currently in a @mood@ mood.",
          ["WHISPER"] = "I'm currently in a @mood@ mood.",
          ["PARTY"] = "I'm currently in a @mood@ mood.",
          ["CHANNEL"] = "I'm currently in a @mood@ mood.",
          ["EMOTE"] = "is currently in a @mood@ mood.",
          ["SELF"] = "Your mood is currently set to @mood@.",
        },
        ["buttons"] = {
          [1] = {
            ["name"] = "Excellent",
            ["color"] = {0, 1, 0, .4},
          },
          [2] = {
            ["name"] = "Ok",
            ["color"] = {1, 1, 0, .4},
          },
          [3] = {
            ["name"] = "Terrible",
            ["color"] = {1, 0, 0, .4},
          },
        },
      },

    -- Our personal settings per character
      ["personal"] = {
        -- playerName just incase we name change.
          ["playerName"] = moodDB.playerName == playerName and moodDB.playerName or playerName

          -- Output methods and their current settings
          ["methods"] = {
            ["WHISPER"] = moodDB.methods.WHISPER or false,
            ["WHISPERNames"] = moodDB.methods.WHISPERNames or {playerName},
            ["CHANNEL"] = moodDB.methods.CHANNEL or false,
            ["CHANNELNames"] = moodDB.methods.CHANNELNames or {},
            ["PARTY"] = moodDB.methods.PARTY or false,
            ["GUILD"] = moodDB.methods.GUILD or false,
            ["OFFICER"] = moodDB.methods.OFFICER or false,
            ["EMOTE"] = moodDB.methods.EMOTE or false,
            ["SELF"] = moodDB.methods.SELF or true, -- Only output method on initial addon configuration
          },

        ["frames"] = {
          -- The button data for factory creation.
            ["buttons"] = moodDB.frames.buttons or mood.vars.default.buttons,

          -- The last location of our main frame and if we are set to silent output or not for relogs
            ["main"] = {
              ["x"] = moodDB.frames.main.x or 100,
              ["y"] = moodDB.frames.main.y or (25 + (29 * #(moodDB.frames.buttons)) + 15),
              ["point"] = moodDB.frames.main.point or "CENTER",
              ["refPoint"] = moodDB.frames.main.refPoint or "CENTER",
              ["silent"] = moodDB.frames.main.silent or false,
            },
        },

        -- Our current mood (nil for new character)
          ["mood"] = moodDB.mood or nil,

        -- Our strings for output (Needs to eventually support locale strings and UTF8).
          ["strings"] = moodDB.strings or mood.default.strings,

        -- Last time we logged into the game on this character
          ["lastLogin"] = {
            ["weekday"] = moodDB.lastLogin.weekday or weekday,
            ["month"] = moodDB.lastLogin.month or month,
            ["day"] = moodDB.lastLogin.day or day,
            ["year"] = moodDB.lastLogin.year or year,
          },

      }, -- mood.vars.personal

  }

end

mood.SaveVars = function()
  -- Saves our variables
  mooDB = mood.vars.personal
  end
