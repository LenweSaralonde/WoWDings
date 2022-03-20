-- WoWDings
-- By LenweSaralonde

-- SendChatMessage hook function
-- @param string msg
-- @param string system
-- @param string language
-- @param string target
function WoWDings_SendChatMessage(msg, system, language, target)
	WoWDings_OldSendChatMessage(WoWDings_Transform(msg, system), system, language, target)
end

-- hook SendChatMessage function
WoWDings_OldSendChatMessage = SendChatMessage
SendChatMessage = WoWDings_SendChatMessage

-- BNSendWhisper hook function
-- @param integer id
-- @param string  text
function WoWDings_BNSendWhisper(id, text)
	WoWDings_OldBNSendWhisper(id, WoWDings_Transform(text))
end

-- hook BNSendWhisper function
WoWDings_OldBNSendWhisper = BNSendWhisper
BNSendWhisper = WoWDings_BNSendWhisper


-- BNSendConversationMessage hook function
-- @param integer channel
-- @param string  text
function WoWDings_BNSendConversationMessage(channel, text)
	WoWDings_OldBNSendConversationMessage(channel, WoWDings_Transform(text))
end

-- hook BNSendConversationMessage function
WoWDings_OldBNSendConversationMessage = BNSendConversationMessage
BNSendConversationMessage = WoWDings_BNSendConversationMessage


-- BNSetCustomMessage hook function
-- @param string text
function WoWDings_BNSetCustomMessage(text)
	WoWDings_OldBNSetCustomMessage(WoWDings_Transform(text))
end

-- hook BNSetCustomMessage function
WoWDings_OldBNSetCustomMessage = BNSetCustomMessage
BNSetCustomMessage = WoWDings_BNSetCustomMessage

-- Gets current map pin location
-- @return string
function WoWDings_MapPin()
	if C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition and MAP_PIN_HYPERLINK then
		local mapID = C_Map.GetBestMapForUnit('player')
		local pos = mapID and C_Map.GetPlayerMapPosition(mapID, 'player')
		if pos == nil then
			return WoWDings_Here()
		end
		local x = floor(pos.x * 10000)
		local y = floor(pos.y * 10000)
		return "|cffffff00|Hworldmap:" .. mapID .. ":" .. x .. ":" .. y .. "|h[" .. MAP_PIN_HYPERLINK .. "]|h|r"
	end

	return WoWDings_Here()
end

-- Gets current location
-- @return string
function WoWDings_Here()
	local location = GetRealZoneText() or UNKNOWN
	if (GetSubZoneText() ~= "") then
		location = location .. ', ' .. GetSubZoneText()
	end

	return location
end

-- Perform text replacements
-- @param string msg
-- @param string system
-- @return string
function WoWDings_Transform(msg, system)
	local range, codes, code, symbol, ranges

	-- Role Play Broadcasting message: do not transform
	if string.find(msg, "^RPB%d+~") then
		return msg
	end

	-- Russianize ;)
	if string.find(msg, "^RU%s+") and system ~= 'SAY' and system ~= 'YELL' then
		msg = string.gsub(msg, "^RU%s*", '')
		msg = WoWDings_Russianize(msg)
	end

	-- Addon download link
	msg = string.gsub(msg, "%(WD%)", WOWDINGS_AD)

	-- Current location
	msg = string.gsub(msg, "%(here%)", WoWDings_Here())

	-- Map pin
	msg = string.gsub(msg, "%(pin%)", WoWDings_MapPin())

	-- Full target info
	local target, realm = UnitName('target')
	if (target ~= nil) then
		if (realm ~= nil) then
			target = target .. '-' .. realm
		end

		if (UnitIsPlayer('target')) then
			local race = UnitRace('target')
			if (race ~= nil) then
				target = target .. ' ' .. race
			end

			local class = UnitClass('target')
			if (class ~= nil) then
				target = target .. ' ' .. class
			end

			local level = UnitLevel('target')
			if (level ~= nil) then
				target = target .. ' lvl ' .. level
			end

			local guild = GetGuildInfo('target')
			if (guild ~= nil) then
				target = target .. ' <' .. guild .. '>'
			end
		end

		msg = string.gsub(msg, "%(target%)", target)
		msg = string.gsub(msg, "%(t%)",      target)
	else
		msg = string.gsub(msg, "%(target%)", '%%t')
		msg = string.gsub(msg, "%(t%)",      '%%t')
	end

	if system ~= 'SAY' and system ~= 'YELL' then
		for _, ranges in pairs(WOWDINGS) do
			local i
			for i = table.getn(ranges), 1, -1 do
				range = ranges[i]
				for symbol, codes in pairs(range) do
					for _, code in pairs(codes) do
						msg = WoWDings_StrReplace(msg, code, symbol)
					end
				end
			end
		end
	end

	return msg
end

--- Replace string content by another one, without regexp
-- @param str (string)
-- @param search (string)
-- @param replace (string)
-- @return (string)

function WoWDings_StrReplace(str, search, replace)
	local function esc(x)
		return (x:gsub('%%', '%%%%')
		         :gsub('^%^', '%%^')
		         :gsub('%$$', '%%$')
		         :gsub('%(', '%%(')
		         :gsub('%)', '%%)')
		         :gsub('%.', '%%.')
		         :gsub('%[', '%%[')
		         :gsub('%]', '%%]')
		         :gsub('%*', '%%*')
		         :gsub('%+', '%%+')
		         :gsub('%-', '%%-')
		         :gsub('%?', '%%?'))
	end

	return string.gsub(str, esc(search), esc(replace))
end

-- Russianize text, because it's fun
-- @param string msg
-- @return string
function WoWDings_Russianize(msg)
	local find, replace, x

	for find, replace in pairs(WOWDINGS_RUSSIAN) do
		x = math.random(table.getn(replace))
		if (math.random(6) >= 2) then
			msg = string.gsub(msg, find, replace[x])
		end
	end

	return msg
end

-- /wd command
SlashCmdList["WOWDINGS"] = function()
	local rangeName, range, ranges, codes, code, symbol, str, strCodes, i

	for rangeName, ranges in pairs(WOWDINGS) do
		rangeName = "|cFFFFFF00"..rangeName.."|r"
		DEFAULT_CHAT_FRAME:AddMessage("========== "..rangeName.." ==========")
		str = ""
		for i = 1, table.getn(ranges), 1 do
			range = ranges[i]
			for symbol, codes in pairs(range) do
				if (symbol == "|")  then symbol = "Unescaped ||" end
				if (symbol == "\r") then symbol = "End of line"    end
				symbol = "|cFFFFFF00"..symbol.."|r"
				str = str..symbol..":"
				for _, code in pairs(codes) do
					code = string.gsub(code, "%%", "")
					code = "|cFF00FF00"..code.."|r"
					str = str..code.." "
				end
				str = str.." "
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage(str)
	end

	rangeName = "|cFFFFFF00Dynamic Shortcuts|r"
	DEFAULT_CHAT_FRAME:AddMessage("========== "..rangeName.." ==========")
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Full target info|r: |cFF00FF00(t) (target)|r")
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Current location|r: |cFF00FF00(here)|r")
	DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00WoWDings download link|r: |cFF00FF00(WD)|r")
end

-- Command aliases
SLASH_WOWDINGS1 = "/wowdings"
SLASH_WOWDINGS2 = "/wd"