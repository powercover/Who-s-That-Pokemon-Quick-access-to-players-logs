-- Update these when a new raid tier / M+ season starts on Warcraft Logs.
-- Raid can stay nil to open the character's current (latest) raid zone.
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
	"MENU_UNIT_GUILD",
	"MENU_UNIT_CHAT",
	"MENU_UNIT_COMMUNITIES_WOW_MEMBER",
	"MENU_UNIT_COMMUNITIES_GUILD_MEMBER",
}

local function EncodeURIComponent(value)
	return (tostring(value):gsub("([^%w%-_%.~])", function(char)
		return string.format("%%%02X", string.byte(char))
	end))
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

local function RealmToSlug(realm)
	if type(realm) ~= "string" or realm == "" then
		return nil
	end

	local original = realm
	realm = realm:gsub("['’]", "")
	realm = realm:gsub("[%.%(%)]", "")
	realm = realm:gsub("[%s_]+", "-")

	-- Normalized names (Area52, TwistingNether) need separators inserted.
	-- Display names that only lost an apostrophe (Kel'Thuzad) must stay intact.
	if not original:find("[ %-'’]", 1) then
		realm = realm:gsub("(%l)(%u)", "%1-%2")
		realm = realm:gsub("(%a)(%d)", "%1-%2")
		realm = realm:gsub("(%d)(%a)", "%1-%2")
	end

	realm = realm:gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
	return strlower(realm)
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

local function GetCharacterFromContext(contextData)
	contextData = contextData or {}

	local unit = contextData.unit
	local name = contextData.name
	local realm = contextData.server
	local guid = contextData.guid

	if unit and UnitExists(unit) then
		if not UnitIsPlayer(unit) then
			return nil
		end
		guid = guid or UnitGUID(unit)
		local unitName, unitRealm = UnitNameUnmodified(unit)
		name = name or unitName
		realm = realm or unitRealm
	end

	if (not name or not realm or realm == "") and guid and guid:match("^Player%-") then
		local _, _, _, _, _, guidName, guidRealm = GetPlayerInfoByGUID(guid)
		name = name or guidName
		if guidRealm and guidRealm ~= "" then
			realm = guidRealm
		end
	end

	if type(name) == "string" then
		local splitName, splitRealm = SplitNameRealm(name)
		name = splitName
		realm = realm or splitRealm
	end

	if not name or name == "" or name == UNKNOWN then
		return nil
	end

	if not realm or realm == "" then
		realm = GetRealmName()
	elseif GetNormalizedRealmName and realm == GetNormalizedRealmName() then
		realm = GetRealmName()
	end

	local slug = RealmToSlug(realm)
	if not slug then
		return nil
	end

	return name, slug, realm
end

local function BuildLogsURL(name, realmSlug, zoneID)
	local region = GetWCLRegion()
	local url = string.format(
		"%s/character/%s/%s/%s",
		GetWCLHost(region),
		EncodeURIComponent(region),
		EncodeURIComponent(realmSlug),
		EncodeURIComponent(name)
	)
	if zoneID then
		url = url .. "?zone=" .. tostring(zoneID)
	end
	return url
end

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
		editBox:SetText(data or "")
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

local function OpenLogs(name, realmSlug, kind)
	local zoneID = (kind == "mplus") and WCL_MPLUS_ZONE or WCL_RAID_ZONE
	local url = BuildLogsURL(name, realmSlug, zoneID)
	StaticPopup_Show("WHOSTHATPOKEMON_COPY_URL", nil, nil, url)
end

local function AddLogsButtons(_, rootDescription, contextData)
	local name, realmSlug = GetCharacterFromContext(contextData)
	if not name then
		return
	end

	rootDescription:CreateDivider()
	rootDescription:CreateTitle("Warcraft Logs")
	rootDescription:CreateButton("Open Raid Logs", function()
		OpenLogs(name, realmSlug, "raid")
	end)
	rootDescription:CreateButton("Open M+ Logs", function()
		OpenLogs(name, realmSlug, "mplus")
	end)
end

if Menu and Menu.ModifyMenu then
	for _, tag in ipairs(PLAYER_MENU_TAGS) do
		Menu.ModifyMenu(tag, AddLogsButtons)
	end
end
