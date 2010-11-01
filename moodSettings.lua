-- Setup mood as a global and grab a copy of the version # set in the .toc
local parent, mood = ...
_G["mood"] = mood

-----------------------------
-- Handles loading of vars --
-----------------------------
mood.LoadVars = function ()
	if not moodDB or moodDB == nil or moodDB == {} then
		-- Load our variables
		moodDB = {
			-- Is the addon silenced?
			["silenced"]	= false,

			-- Frame Factory settings
			["frames"] = {
				-- Our Main mood frame. This is the money maker!
				["main"] = {
					["position"] = {
						["x"]		= 0,
						["y"]		= 0,
						["point"]	= "CENTER",
						["refPoint"]	= "CENTER",
					},
					["height"]	= 130, -- (25 + (30 * #(moodDB.frames.main.buttons)) + 15)	
					["width"]	= 100,
					["buttons"]	= {
						[1] = {
							["name"]	= "Excellent",
							["color"]	= {0, 1, 0, .4},
						},
						[2] = {
							["name"]	= "Ok",
							["color"]	= {1, 1, 0, .4},
						},
						[3] = {
							["name"]	= "Terrible",
							["color"]	= {1, 0, 0, .4},
						},
					},
				}, -- ["main"] = {

				["font"] = {
					["normal"]	= [=[Interface\Addons\mood\media\neuropol x cd rg.ttf]=],
				},
			}, -- ["frames"] = {

			["methods"] = {
				["WHISPER"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "I'm currently in a @mood@ mood.",
				},
				["CHANNEL"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "I'm currently in a @mood@ mood.",
				},
				["PARTY"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "I'm currently in a @mood@ mood.",
				},
				["GUILD"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "I'm currently in a @mood@ mood.",
				},
				["OFFICER"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "I'm currently in a @mood@ mood.",
				},
				["EMOTE"] = {
					["checked"]	= false,
					["names"]	= {},
					["string"]	= "is currently in a @mood@ mood.",
				},
				["SELF"] = {
					["checked"]	= true,
					["names"]	= {},
					["string"]	= "Your mood is currently set to @mood@.",
				},
			}, -- ["methods"] = {

			["mood"] = nil, -- new character

			["lastLogin"] = { -- Last time we logged in
				["weekday"]		= 0,
				["month"]		= 0,
				["day"]			= 0,
				["year"]		= 0,
			}, -- ["lastLogin"] = {

		} -- moodDB = {

	end -- if not moodDB or moodDB == {} then
end

mood.SaveDate = function()
	local weekday, month, day, year = CalendarGetDate()
	moodDB.lastLogin = {
		["weekday"] = weekday,
		["month"] = month,
		["day"] = day,
		["year"] = year,
	}
end

mood.LoggedToday = function()
	local weekday, month, day, year = CalendarGetDate()

	local lastLog = moodDB.lastLogin
	if (lastLog.weekday == weekday and
		lastLog.month == month and
		lastLog.day == day and
		lastLog.year == year
	) then
		return true
	end

	return false
end

mood.SaveVars = function()
	-- Save our last login to now
	mood.SaveDate()
end
