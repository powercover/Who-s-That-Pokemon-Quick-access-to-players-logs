-- Update these when a new raid tier / M+ season starts on Warcraft Logs.
local WCL_RAID_ZONE = 53  -- The Venomous Abyss (Midnight 12.1)
local WCL_MPLUS_ZONE = 55 -- Mythic+ Season 2 (Midnight 12.1)

local REGION_BY_ID = {
	[1] = "us",
	[2] = "kr",
	[3] = "eu",
	[4] = "tw",
	[5] = "cn",
}

local PLAYER_MENU_TAGS = {
	"MENU_UNIT_SELF",
	"MENU_UNIT_PLAYER",
	"MENU_UNIT_ENEMY_PLAYER",
	"MENU_UNIT_PARTY",
	"MENU_UNIT_RAID",
	"MENU_UNIT_RAID_PLAYER",
	"MENU_UNIT_FOCUS",
	"MENU_UNIT_TARGET",
	"MENU_UNIT_ARENAENEMY",
	"MENU_UNIT_FRIEND",
	"MENU_UNIT_FRIEND_OFFLINE",
	"MENU_UNIT_BN_FRIEND",
	"MENU_UNIT_BN_FRIEND_OFFLINE",
	"MENU_UNIT_GUILD",
	"MENU_UNIT_CHAT",
	"MENU_UNIT_COMMUNITIES_WOW_MEMBER",
	"MENU_UNIT_COMMUNITIES_GUILD_MEMBER",
}

-- Compact ASCII or hex-of-folded-bytes → already percent-encoded WCL slug.
-- Values are ASCII so Cyrillic р (byte 0x80) never sits in a Lua gsub/string key.
local WCL_REALM_SLUGS = {
	["boreantundra"] = "%D0%B1%D0%BE%D1%80%D0%B5%D0%B8%D1%81%D0%BA%D0%B0%D1%8F-%D1%82%D1%83%D0%BD%D0%B4%D1%80%D0%B0",
	["d0b1d0bed180d0b5d0b8d181d0bad0b0d18fd182d183d0bdd0b4d180d0b0"] = "%D0%B1%D0%BE%D1%80%D0%B5%D0%B8%D1%81%D0%BA%D0%B0%D1%8F-%D1%82%D1%83%D0%BD%D0%B4%D1%80%D0%B0",
	["howlingfjord"] = "%D1%80%D0%B5%D0%B2%D1%83%D1%89%D0%B8%D0%B8-%D1%84%D1%8C%D0%BE%D1%80%D0%B4",
	["d180d0b5d0b2d183d189d0b8d0b8d184d18cd0bed180d0b4"] = "%D1%80%D0%B5%D0%B2%D1%83%D1%89%D0%B8%D0%B8-%D1%84%D1%8C%D0%BE%D1%80%D0%B4",
	["eversong"] = "%D0%B2%D0%B5%D1%87%D0%BD%D0%B0%D1%8F-%D0%BF%D0%B5%D1%81%D0%BD%D1%8F",
	["d0b2d0b5d187d0bdd0b0d18fd0bfd0b5d181d0bdd18f"] = "%D0%B2%D0%B5%D1%87%D0%BD%D0%B0%D1%8F-%D0%BF%D0%B5%D1%81%D0%BD%D1%8F",
	["bootybay"] = "%D0%BF%D0%B8%D1%80%D0%B0%D1%82%D1%81%D0%BA%D0%B0%D1%8F-%D0%B1%D1%83%D1%85%D1%82%D0%B0",
	["d0bfd0b8d180d0b0d182d181d0bad0b0d18fd0b1d183d185d182d0b0"] = "%D0%BF%D0%B8%D1%80%D0%B0%D1%82%D1%81%D0%BA%D0%B0%D1%8F-%D0%B1%D1%83%D1%85%D1%82%D0%B0",
	["soulflayer"] = "%D1%81%D0%B2%D0%B5%D0%B6%D0%B5%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8C-%D0%B4%D1%83%D1%88",
	["d181d0b2d0b5d0b6d0b5d0b2d0b0d182d0b5d0bbd18cd0b4d183d188"] = "%D1%81%D0%B2%D0%B5%D0%B6%D0%B5%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8C-%D0%B4%D1%83%D1%88",
	["deathguard"] = "%D1%81%D1%82%D1%80%D0%B0%D0%B6-%D1%81%D0%BC%D0%B5%D1%80%D1%82%D0%B8",
	["d181d182d180d0b0d0b6d181d0bcd0b5d180d182d0b8"] = "%D1%81%D1%82%D1%80%D0%B0%D0%B6-%D1%81%D0%BC%D0%B5%D1%80%D1%82%D0%B8",
	["deathweaver"] = "%D1%82%D0%BA%D0%B0%D1%87-%D1%81%D0%BC%D0%B5%D1%80%D1%82%D0%B8",
	["d182d0bad0b0d187d181d0bcd0b5d180d182d0b8"] = "%D1%82%D0%BA%D0%B0%D1%87-%D1%81%D0%BC%D0%B5%D1%80%D1%82%D0%B8",
	["blackscar"] = "%D1%87%D0%B5%D1%80%D0%BD%D1%8B%D0%B8-%D1%88%D1%80%D0%B0%D0%BC",
	["d187d0b5d180d0bdd18bd0b8d188d180d0b0d0bc"] = "%D1%87%D0%B5%D1%80%D0%BD%D1%8B%D0%B8-%D1%88%D1%80%D0%B0%D0%BC",
	["ashenvale"] = "%D1%8F%D1%81%D0%B5%D0%BD%D0%B5%D0%B2%D1%8B%D0%B8-%D0%BB%D0%B5%D1%81",
	["d18fd181d0b5d0bdd0b5d0b2d18bd0b8d0bbd0b5d181"] = "%D1%8F%D1%81%D0%B5%D0%BD%D0%B5%D0%B2%D1%8B%D0%B8-%D0%BB%D0%B5%D1%81",
	["lichking"] = "%D0%BA%D0%BE%D1%80%D0%BE%D0%BB%D1%8C%D0%BB%D0%B8%D1%87",
	["d0bad0bed180d0bed0bbd18cd0bbd0b8d187"] = "%D0%BA%D0%BE%D1%80%D0%BE%D0%BB%D1%8C%D0%BB%D0%B8%D1%87",
	["gordunni"] = "%D0%B3%D0%BE%D1%80%D0%B4%D1%83%D0%BD%D0%BD%D0%B8",
	["d0b3d0bed180d0b4d183d0bdd0bdd0b8"] = "%D0%B3%D0%BE%D1%80%D0%B4%D1%83%D0%BD%D0%BD%D0%B8",
	["deepholm"] = "%D0%BF%D0%BE%D0%B4%D0%B7%D0%B5%D0%BC%D1%8C%D0%B5",
	["d0bfd0bed0b4d0b7d0b5d0bcd18cd0b5"] = "%D0%BF%D0%BE%D0%B4%D0%B7%D0%B5%D0%BC%D1%8C%D0%B5",
	["greymane"] = "%D1%81%D0%B5%D0%B4%D0%BE%D0%B3%D1%80%D0%B8%D0%B2",
	["d181d0b5d0b4d0bed0b3d180d0b8d0b2"] = "%D1%81%D0%B5%D0%B4%D0%BE%D0%B3%D1%80%D0%B8%D0%B2",
	["galakrond"] = "%D0%B3%D0%B0%D0%BB%D0%B0%D0%BA%D1%80%D0%BE%D0%BD%D0%B4",
	["d0b3d0b0d0bbd0b0d0bad180d0bed0bdd0b4"] = "%D0%B3%D0%B0%D0%BB%D0%B0%D0%BA%D1%80%D0%BE%D0%BD%D0%B4",
	["razuvious"] = "%D1%80%D0%B0%D0%B7%D1%83%D0%B2%D0%B8%D0%B8",
	["d180d0b0d0b7d183d0b2d0b8d0b8"] = "%D1%80%D0%B0%D0%B7%D1%83%D0%B2%D0%B8%D0%B8",
	["fordragon"] = "%D0%B4%D1%80%D0%B0%D0%BA%D0%BE%D0%BD%D0%BE%D0%BC%D0%BE%D1%80",
	["d0b4d180d0b0d0bad0bed0bdd0bed0bcd0bed180"] = "%D0%B4%D1%80%D0%B0%D0%BA%D0%BE%D0%BD%D0%BE%D0%BC%D0%BE%D1%80",
	["azuregos"] = "%D0%B0%D0%B7%D1%83%D1%80%D0%B5%D0%B3%D0%BE%D1%81",
	["d0b0d0b7d183d180d0b5d0b3d0bed181"] = "%D0%B0%D0%B7%D1%83%D1%80%D0%B5%D0%B3%D0%BE%D1%81",
	["thermaplugg"] = "%D1%82%D0%B5%D1%80%D0%BC%D0%BE%D1%88%D1%82%D0%B5%D0%BF%D1%81%D0%B5%D0%BB%D1%8C",
	["d182d0b5d180d0bcd0bed188d182d0b5d0bfd181d0b5d0bbd18c"] = "%D1%82%D0%B5%D1%80%D0%BC%D0%BE%D1%88%D1%82%D0%B5%D0%BF%D1%81%D0%B5%D0%BB%D1%8C",
	["grom"] = "%D0%B3%D1%80%D0%BE%D0%BC",
	["d0b3d180d0bed0bc"] = "%D0%B3%D1%80%D0%BE%D0%BC",
	["goldrinn"] = "%D0%B3%D0%BE%D0%BB%D0%B4%D1%80%D0%B8%D0%BD%D0%BD",
	["d0b3d0bed0bbd0b4d180d0b8d0bdd0bd"] = "%D0%B3%D0%BE%D0%BB%D0%B4%D1%80%D0%B8%D0%BD%D0%BD",
}

-- Lua 5.1 gsub("%80") is a capture; never encode with gsub. BYTE_HEX[128] is "%80".
local BYTE_HEX = {}
for i = 0, 255 do
	BYTE_HEX[i] = string.format("%%%02X", i)
end

local function EncodeURIComponent(text)
	if type(text) ~= "string" then
		return ""
	end
	local out = {}
	for i = 1, #text do
		local b = strbyte(text, i)
		-- Unreserved: ALPHA / DIGIT / "-" / "." / "_" / "~"
		if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
			or b == 45 or b == 46 or b == 95 or b == 126 then
			out[#out + 1] = strchar(b)
		else
			out[#out + 1] = BYTE_HEX[b]
		end
	end
	return table.concat(out)
end

local function IsSecret(value)
	return issecretvalue and issecretvalue(value)
end

-- Menu names can be |K…|k tokens. Never put those in a WCL URL.
local function IsPlaintext(value)
	if IsSecret(value) then
		return false
	end
	if type(value) ~= "string" or value == "" then
		return false
	end
	if value == UNKNOWN or (UNKNOWNOBJECT and value == UNKNOWNOBJECT) then
		return false
	end
	if value:find("|K", 1, true) then
		return false
	end
	return true
end

local function HexOfBytes(bytes)
	local out = {}
	for i = 1, #bytes do
		out[i] = string.format("%02x", bytes[i])
	end
	return table.concat(out)
end

local function EncodeBytes(bytes)
	local out = {}
	for i = 1, #bytes do
		local b = bytes[i]
		if (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)
			or b == 45 or b == 46 or b == 95 or b == 126 then
			out[#out + 1] = strchar(b)
		else
			out[#out + 1] = BYTE_HEX[b]
		end
	end
	return table.concat(out)
end

local function AsciiCompact(text)
	local out = {}
	for i = 1, #text do
		local b = strbyte(text, i)
		if b >= 65 and b <= 90 then
			out[#out + 1] = strchar(b + 32)
		elseif (b >= 97 and b <= 122) or (b >= 48 and b <= 57) then
			out[#out + 1] = strchar(b)
		end
	end
	return table.concat(out)
end

-- Fold to WCL slug bytes without gsub. Й/й→и, Ё/ё→е. compact omits space/hyphen.
local function FoldRealmBytes(text, compact)
	local bytes = {}
	local function emit(b)
		if compact then
			if b == 32 or b == 45 or b == 95 or b == 39 then
				return
			end
		else
			if b == 32 or b == 95 then
				b = 45
			elseif b == 39 then
				return
			end
		end
		bytes[#bytes + 1] = b
	end

	local i = 1
	local n = #text
	while i <= n do
		local b1 = strbyte(text, i)
		if b1 < 128 then
			if b1 >= 65 and b1 <= 90 then
				emit(b1 + 32)
			elseif b1 == 46 or b1 == 40 or b1 == 41 then
				-- skip . ( )
			else
				emit(b1)
			end
			i = i + 1
		elseif b1 == 208 and i < n then
			local b2 = strbyte(text, i + 1)
			if b2 == 0x81 then
				emit(208)
				emit(181) -- Ё → е
			elseif b2 == 0x99 or b2 == 0xB9 then
				emit(208)
				emit(184) -- Й/й → и
			elseif b2 >= 0x90 and b2 <= 0x9F then
				emit(208)
				emit(b2 + 32)
			elseif b2 >= 0xA0 and b2 <= 0xAF then
				emit(209)
				emit(b2 - 32)
			else
				emit(208)
				emit(b2)
			end
			i = i + 2
		elseif b1 == 209 and i < n then
			local b2 = strbyte(text, i + 1)
			if b2 == 0x91 then
				emit(208)
				emit(181) -- ё → е
			else
				emit(209)
				emit(b2)
			end
			i = i + 2
		elseif b1 == 226 and i + 1 < n then
			local b2 = strbyte(text, i + 1)
			local b3 = strbyte(text, i + 2)
			if b2 == 128 and (b3 == 152 or b3 == 153) then
				-- skip ‘ ’
			else
				emit(b1)
				emit(b2)
				emit(b3)
			end
			i = i + 3
		elseif b1 >= 224 and i + 1 < n then
			emit(b1)
			emit(strbyte(text, i + 1))
			emit(strbyte(text, i + 2))
			i = i + 3
		else
			emit(b1)
			i = i + 1
		end
	end
	return bytes
end

local function RealmToSlug(realm)
	if not IsPlaintext(realm) then
		return nil
	end

	local original = realm
	local asciiKey = AsciiCompact(original)
	local hexKey = HexOfBytes(FoldRealmBytes(original, true))
	local mapped = (asciiKey ~= "" and WCL_REALM_SLUGS[asciiKey]) or WCL_REALM_SLUGS[hexKey]
	if mapped then
		return mapped
	end

	local hadSpace = original:find(" ", 1, true) ~= nil
	local hadHyphen = original:find("-", 1, true) ~= nil
	local hadApos = original:find("'", 1, true) ~= nil

	local source = original
	-- Normalized Latin names (TwistingNether, Area52). Skip Kel'Thuzad / Azjol-Nerub.
	if not hadSpace and not hadHyphen and not hadApos then
		source = source:gsub("(%l)(%u)", "%1-%2")
		source = source:gsub("(%a)(%d)", "%1-%2")
		source = source:gsub("(%d)(%a)", "%1-%2")
	end

	local bytes = FoldRealmBytes(source, false)
	if hadHyphen and not hadSpace then
		local stripped = {}
		for i = 1, #bytes do
			if bytes[i] ~= 45 then
				stripped[#stripped + 1] = bytes[i]
			end
		end
		bytes = stripped
	end

	local clean = {}
	for i = 1, #bytes do
		local b = bytes[i]
		if b == 45 then
			if #clean > 0 and clean[#clean] ~= 45 then
				clean[#clean + 1] = 45
			end
		else
			clean[#clean + 1] = b
		end
	end
	if clean[1] == 45 then
		table.remove(clean, 1)
	end
	if clean[#clean] == 45 then
		clean[#clean] = nil
	end
	if #clean == 0 then
		return nil
	end
	return EncodeBytes(clean)
end

local function GetWCLRegion()
	local locale = GetLocale()
	if locale == "zhTW" then
		return "tw"
	end
	if locale == "zhCN" then
		return "cn"
	end

	local regionID = GetCurrentRegion and GetCurrentRegion()
	if REGION_BY_ID[regionID] then
		return REGION_BY_ID[regionID]
	end

	local regionName = GetCurrentRegionName and GetCurrentRegionName()
	if type(regionName) == "string" and regionName ~= "" then
		regionName = regionName:lower()
		if regionName:find("eu", 1, true) then
			return "eu"
		end
		if regionName:find("kr", 1, true) or regionName:find("ko", 1, true) then
			return "kr"
		end
		if regionName:find("tw", 1, true) then
			return "tw"
		end
		if regionName:find("cn", 1, true) then
			return "cn"
		end
	end

	return "us"
end

local function GetWCLHost(region)
	if region == "cn" then
		return "https://cn.warcraftlogs.com"
	end
	return "https://www.warcraftlogs.com"
end

local function SplitNameRealm(fullName)
	if type(fullName) ~= "string" then
		return nil, nil
	end
	local name, realm = fullName:match("^([^-]+)%-(.+)$")
	if name then
		return name, realm
	end
	return fullName, nil
end

local function FinishCharacter(name, realm, guid, region)
	if IsPlaintext(guid) and guid:sub(1, 7) == "Player-" then
		local _, _, _, _, _, guidName, guidRealm = GetPlayerInfoByGUID(guid)
		if IsPlaintext(guidName) then
			name = guidName
		end
		if IsPlaintext(guidRealm) then
			realm = guidRealm
		end
	end

	if name then
		local splitName, splitRealm = SplitNameRealm(name)
		if splitName and IsPlaintext(splitName) then
			name = splitName
			if not realm and IsPlaintext(splitRealm) then
				realm = splitRealm
			end
		end
	end

	if not IsPlaintext(name) or name:find("#", 1, true) then
		return nil
	end

	if not IsPlaintext(realm) then
		realm = GetRealmName()
	elseif GetNormalizedRealmName and realm == GetNormalizedRealmName() then
		realm = GetRealmName()
	end

	local slug = RealmToSlug(realm)
	if not slug then
		return nil
	end

	return name, slug, realm, region
end

local function GetBattleNetAccountInfo(contextData, owner)
	if not C_BattleNet then
		return nil
	end
	if contextData.accountInfo then
		return contextData.accountInfo
	end
	local bnetID = contextData.bnetIDAccount
	if not bnetID and owner then
		bnetID = owner.bnetIDAccount
		if not bnetID and owner.buttonType == FRIENDS_BUTTON_TYPE_BNET and owner.id and C_BattleNet.GetFriendAccountInfo then
			return C_BattleNet.GetFriendAccountInfo(owner.id)
		end
	end
	if bnetID and C_BattleNet.GetAccountInfoByID then
		return C_BattleNet.GetAccountInfoByID(bnetID)
	end
	if IsPlaintext(contextData.guid) and C_BattleNet.GetAccountInfoByGUID then
		return C_BattleNet.GetAccountInfoByGUID(contextData.guid)
	end
	return nil
end

local function GetCharacterFromBattleNet(contextData, owner)
	local accountInfo = GetBattleNetAccountInfo(contextData, owner)
	local game = accountInfo and accountInfo.gameAccountInfo
	if not game or not game.isOnline then
		return nil
	end
	if WOW_PROJECT_MAINLINE and game.wowProjectID and game.wowProjectID ~= WOW_PROJECT_MAINLINE then
		return nil
	end
	if game.clientProgram and BNET_CLIENT_WOW and game.clientProgram ~= BNET_CLIENT_WOW then
		return nil
	end
	if not IsPlaintext(game.characterName) then
		return nil
	end
	local realm = game.realmDisplayName or game.realmName
	local region
	if game.isInCurrentRegion == false and game.regionID and REGION_BY_ID[game.regionID] then
		region = REGION_BY_ID[game.regionID]
	end
	return FinishCharacter(game.characterName, realm, game.playerGuid, region)
end

local function GetCharacterFromWowFriend(contextData, owner)
	if not C_FriendList then
		return nil
	end
	local info
	if owner and owner.buttonType == FRIENDS_BUTTON_TYPE_WOW and owner.id and C_FriendList.GetFriendInfoByIndex then
		info = C_FriendList.GetFriendInfoByIndex(owner.id)
	elseif IsPlaintext(contextData.name) and C_FriendList.GetFriendInfo then
		info = C_FriendList.GetFriendInfo(contextData.name)
	end
	if type(info) ~= "table" or not IsPlaintext(info.name) then
		return nil
	end
	return FinishCharacter(info.name, nil, info.guid)
end

local function GetCharacterFromContext(contextData, owner)
	contextData = contextData or {}

	local name, slug, realm, region = GetCharacterFromBattleNet(contextData, owner)
	if name then
		return name, slug, realm, region
	end

	name, slug, realm, region = GetCharacterFromWowFriend(contextData, owner)
	if name then
		return name, slug, realm, region
	end

	local unit = contextData.unit
	local guid = contextData.guid
	name = nil
	realm = nil

	if unit then
		if not UnitExists(unit) or not UnitIsPlayer(unit) then
			return nil
		end
		if not IsSecret(unit) then
			guid = guid or UnitGUID(unit)
			local unitName, unitRealm = UnitNameUnmodified(unit)
			if IsPlaintext(unitName) then
				name = unitName
			end
			if IsPlaintext(unitRealm) then
				realm = unitRealm
			end
		end
	end

	if not name and IsPlaintext(contextData.name) then
		name = contextData.name
	end
	if not realm and IsPlaintext(contextData.server) then
		realm = contextData.server
	end

	return FinishCharacter(name, realm, guid)
end

local function GetCharacterFromFullName(fullName)
	if not IsPlaintext(fullName) then
		return nil
	end
	local name, realm = SplitNameRealm(fullName)
	return FinishCharacter(name, realm)
end

local function BuildLogsURL(name, realmSlug, zoneID, region)
	region = region or GetWCLRegion()
	local encodedRealm = realmSlug
	if not realmSlug:find("%", 1, true) then
		encodedRealm = EncodeURIComponent(realmSlug)
	end
	local url = string.format(
		"%s/character/%s/%s/%s",
		GetWCLHost(region),
		region,
		encodedRealm,
		EncodeURIComponent(name)
	)
	if zoneID then
		url = url .. "?zone=" .. tostring(zoneID)
	end
	return url
end

local pendingCopyURL = ""

StaticPopupDialogs["WHOSTHATPOKEMON_COPY_URL"] = {
	text = "Press Ctrl+C to copy the Warcraft Logs URL:",
	button1 = CLOSE,
	hasEditBox = true,
	editBoxWidth = 360,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnShow = function(dialog, data)
		local editBox = dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox
		if not editBox then
			return
		end
		local url = pendingCopyURL
		if type(data) == "string" and data ~= "" then
			url = data
		elseif type(dialog.data) == "string" and dialog.data ~= "" then
			url = dialog.data
		end
		if editBox.SetMaxLetters then
			editBox:SetMaxLetters(1024)
		end
		editBox:SetText(url)
		editBox:HighlightText()
		editBox:SetFocus()
		editBox:SetScript("OnKeyUp", function(_, key)
			if key == "C" and IsControlKeyDown() then
				dialog:Hide()
			end
		end)
	end,
	OnHide = function(dialog)
		local editBox = dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox
		if editBox then
			editBox:SetScript("OnKeyUp", nil)
		end
	end,
	EditBoxOnEscapePressed = function(editBox)
		editBox:GetParent():Hide()
	end,
	EditBoxOnEnterPressed = function(editBox)
		editBox:GetParent():Hide()
	end,
}

local function OpenLogs(name, realmSlug, kind, region)
	local zoneID = (kind == "mplus") and WCL_MPLUS_ZONE or WCL_RAID_ZONE
	pendingCopyURL = BuildLogsURL(name, realmSlug, zoneID, region)
	StaticPopup_Show("WHOSTHATPOKEMON_COPY_URL", nil, nil, pendingCopyURL)
end

local function AppendLogsButtons(rootDescription, name, realmSlug, region)
	if not name or not realmSlug then
		return
	end

	rootDescription:CreateDivider()
	rootDescription:CreateTitle("Warcraft Logs")
	rootDescription:CreateButton("Open Raid Logs", function()
		OpenLogs(name, realmSlug, "raid", region)
	end)
	rootDescription:CreateButton("Open M+ Logs", function()
		OpenLogs(name, realmSlug, "mplus", region)
	end)
end

local function AddLogsButtons(owner, rootDescription, contextData)
	local name, realmSlug, _, region = GetCharacterFromContext(contextData, owner)
	AppendLogsButtons(rootDescription, name, realmSlug, region)
end

local function AddLogsButtonsFromFullName(rootDescription, fullName)
	local name, realmSlug = GetCharacterFromFullName(fullName)
	AppendLogsButtons(rootDescription, name, realmSlug)
end

local function AddLFGSearchEntryButtons(owner, rootDescription)
	local resultID = owner and owner.resultID
	if not resultID or not C_LFGList then
		return
	end

	local ok, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
	if ok and info then
		AddLogsButtonsFromFullName(rootDescription, info.leaderName)
	end
end

local function AddLFGApplicantButtons(owner, rootDescription)
	if not owner or not C_LFGList or not C_LFGList.GetApplicantMemberInfo then
		return
	end

	local parent = owner.GetParent and owner:GetParent()
	local applicantID = parent and parent.applicantID
	local memberIdx = owner.memberIdx
	if not applicantID or not memberIdx then
		return
	end

	local ok, name = pcall(C_LFGList.GetApplicantMemberInfo, applicantID, memberIdx)
	if ok then
		AddLogsButtonsFromFullName(rootDescription, name)
	end
end

if Menu and Menu.ModifyMenu then
	for _, tag in ipairs(PLAYER_MENU_TAGS) do
		Menu.ModifyMenu(tag, AddLogsButtons)
	end
	Menu.ModifyMenu("MENU_LFG_FRAME_SEARCH_ENTRY", AddLFGSearchEntryButtons)
	Menu.ModifyMenu("MENU_LFG_FRAME_MEMBER_APPLY", AddLFGApplicantButtons)
end
