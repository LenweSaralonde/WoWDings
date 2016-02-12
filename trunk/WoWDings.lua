-- WoWDings
-- Version @project-version@
-- By @project-author@

-- SendChatMessage hook function
-- @param string msg
-- @param string system
-- @param string language
-- @param string target
function WoWDings_SendChatMessage(msg, system, language, target)
	WoWDings_OldSendChatMessage(WoWDings_Transform(msg), system, language, target)
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


-- Perform text replacements
-- @param string msg
-- @return string
function WoWDings_Transform(msg)
	local range, codes, code, symbol, ranges

	-- Role Play Broadcasting message: do not transform
	if string.find(msg, "^RPB%d+~") then
		return msg
	end

	-- Russianize ;)
	if string.find(msg, "^RU%s+") then
		msg = string.gsub(msg, "^RU%s*", '')
		if system ~= 'SAY' and system ~= 'YELL' then
			msg = WoWDings_Russianize(msg)
		end
	end

	-- Addon download link
	msg = string.gsub(msg, "%(WD%)", WOWDINGS_AD)

	-- Current location
	local location = GetRealZoneText()
	if (GetSubZoneText() ~= "") then
		location = location .. ', ' .. GetSubZoneText()
	end
	msg = string.gsub(msg, "%(here%)", location)

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

	if system ~= 'SAY' then
		for _, ranges in pairs(WOWDINGS) do
			for _, range in pairs(ranges) do
				for symbol, codes in pairs(range) do
					for _, code in pairs(codes) do
						msg = string.gsub(msg, code, symbol)
					end
				end
			end
		end
	end

	return msg
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