-- #TODO Copyright here

local GU = _G.GU;
local Misc = GU.Misc;
local Style = GU.Style;
local Colors = Style.Colors;

----------------------------------------------------------
-- Classes
----------------------------------------------------------

local CLASSES_ID = {
	[0]		= GU_CLASS_DEATHKNIGHT,
	[1]		= GU_CLASS_DEMONHUNTER,
	[2]		= GU_CLASS_DRUID,
	[3]		= GU_CLASS_HUNTER,
	[4]		= GU_CLASS_MAGE,
	[5]		= GU_CLASS_MONK,
	[6]		= GU_CLASS_PALADIN,
	[7]		= GU_CLASS_PRIEST,
	[8]		= GU_CLASS_ROGUE,
	[9]		= GU_CLASS_SHAMAN,
	[10]	= GU_CLASS_WARLOCK,
	[11]	= GU_CLASS_WARRIOR,
}

function Misc:GetClassNameByID(classID)
	return CLASSES_ID[classID];
end

----------------------------------------------------------
-- Items & Inventory functions
----------------------------------------------------------

local MAX_LEVEL = 60;

local COIN_TEXTURES = {
    "|TInterface\\Moneyframe\\UI-GoldIcon:0:0:4:0|t",
    "|TInterface\\Moneyframe\\UI-SilverIcon:0:0:4:0|t",
    "|TInterface\\Moneyframe\\UI-CopperIcon:0:0:4:0|t"
}

-- coinType: 1 - gold, 2 - silver, 3 - copper
function Misc:GetCoinTextureWithValue(value, coinType)
    if (value > 0) then
        return Colors:GetColorStr(GU_COLOR_WHITE, tostring(value)) .. COIN_TEXTURES[coinType] .. "  ";
    else
        return "";
    end
end
function Misc:GetMoneyValueWithTextures(price)
    local copper = price % 100;
    price = math.floor(price/100);
    local silver = price % 100;
    price = math.floor(price/100);
    local gold = price % 100;

    return self:GetCoinTextureWithValue(gold, 1) .. self:GetCoinTextureWithValue(silver, 2) .. self:GetCoinTextureWithValue(copper, 3);
end

function Misc:GetItemDataFromLink(itemLink)
	-- example: |cffffffff|Hitem:4592::::::::12:::::::|h[Longjaw Mud Snapper]|h|r
	if (not itemLink) then
		return;
	end

	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
	"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
	return Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name;
end

function Misc:GetItemIDFromLink(itemLink)
	if (not itemLink) then
		return;
	end

	local _, _, ID = self:GetItemDataFromLink(itemLink);
    return tonumber(ID);
end

function Misc:GenerateSimpleItemLinkFromID(itemID)
	return string.format("|cffffffff|Hitem:%d::::::::%d:::::::|h[Item link]|h|r", itemID, MAX_LEVEL);
end

function Misc:GenerateFullItemLink(itemID, rarity, name)
	return string.format("|cff%s|Hitem:%d::::::::%d:::::::|h[%s]|h|r", Style:GetRarityColor(rarity), itemID, MAX_LEVEL, name);
end

function Misc:GetPrintableItemLink(itemLink)
	if (not itemLink) then
		return "invalid";
	end

	local printable = gsub(itemLink, "\124", "\124\124");
	return printable;
end

function Misc:GetItemVendorPrice(itemIDOrLink)
	local name, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemIDOrLink);
	if (not name) then
		itemSellPrice = 0;
	end

    return itemSellPrice;
end

function Misc:GetRarityName(rarityLevel)
	if (rarityLevel == 0) then return "Poor"; end
	if (rarityLevel == 1) then return "Common"; end
	if (rarityLevel == 2) then return "Uncommon"; end
	if (rarityLevel == 3) then return "Rare"; end
	if (rarityLevel == 4) then return "Epic"; end
	if (rarityLevel == 5) then return "Legendary"; end
	if (rarityLevel == 6) then return "Artifact"; end
	if (rarityLevel == 7) then return "Heirloom"; end

	return "Unknown";
end

function Misc:GetRarityLevel(rarityName)
	if (rarityName == "Poor") then return 0; end
	if (rarityName == "Common") then return 1; end
	if (rarityName == "Uncommon") then return 2; end
	if (rarityName == "Rare") then return 3; end
	if (rarityName == "Epic") then return 4; end
	if (rarityName == "Legendary") then return 5; end
	if (rarityName == "Artifact") then return 6; end
	if (rarityName == "Heirloom") then return 7; end

	return -1;
end

----------------------------------------------------------
-- Misc. functions
----------------------------------------------------------

-- Lua-style ternary operator.
function Misc:IFTE(condition, if_true, if_false)
    if condition then return if_true else return if_false end
end

-- Clamp
function Misc:Clamp(value, min, max)
	if (value > max) then
		return max;
	elseif (value < min) then
		return min;
	end

	return value;
end

function Misc:Inc(value)
	value = value + 1;
	return value;
end

function Misc:Dec(value)
	return value - 1;
end

function Misc:Length(t)
	local length = 0;
	if (type(t) == "table") then
		for k,v in pairs(t) do
			length = length + 1;
		end
	end

	return length;
end

function Misc:BoolToString(bool)
	if (bool) then
		return "true";
	else
		return "false";
	end
end

function Misc:Contains(t, item)
	if (type(t) == "table") then
		for k,v in pairs(t) do
			if (v == item) then
				return true;
			end
		end
	end

	return false;
end

----------------------------------------------------------
-- Objects/Tables
----------------------------------------------------------

-- This is only valid for tables with string values.
function Misc:GetTableAsString(t, delimiter)
	if (not t) then
		return "";
	end
	if (not delimiter) then
		delimiter = " ";
	end
	
	local s = "";
	local firstItem = true;
	for k,v in pairs(t) do
		if (not firstItem) then
			s = s .. delimiter;
		end
		s = s .. v;
		firstItem = false;
	end

	return s;
end

function Misc:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Misc:CreateObject(objectOrName, ...)
    local object,name
	local i=1
	if type(objectOrName)=="table" then
		object=objectOrName
		name=...
		i=2
	else
		name=objectOrName
	end

    object = object or {}
    object.name = name
    
    return object
end

function Misc:PrintAllProperties(t, prevData)
	-- if prevData == nil, start empty, otherwise start with prevData
	local data = prevData or {}
	print("==========================");
	
	-- copy all the attributes from t
	for k,v in pairs(t) do
		if (type(v) ~= "function") then
			print(tostring(k) .. " -> " .. tostring(v));
			data[k] = data[k] or v
		end
	end
  
	-- get t's metatable, or exit if not existing
	local mt = getmetatable(t)
	if type(mt) ~='table' then
		return data;
	end
  
	-- get the __index from mt, or exit if not table
	local index = mt.__index
	if type(index) ~='table' then
		return data;
	end
  
	-- include the data from index into data, recursively, and return
	return self:PrintAllProperties(index, data)
end

function Misc:PrintAllData(object, prevData, keys, depth)
	-- if prevData == nil, start empty, otherwise start with prevData
	local data = prevData or {}
	local keys = keys or {};
	depth = depth or 0;
	
	-- print all the attributes from t
	for k,v in pairs(object) do
		-- print(tostring(k) .. " -> " .. tostring(v));
		data[k] = data[k] or v
		table.insert(keys, tostring(k));
	end
  
	-- get t's metatable, or exit if not existing
	local mt = getmetatable(object)
	if type(mt) ~='table' then
		return;
	end
  
	-- get the __index from mt, or exit if not table
	local index = mt.__index
	if type(index) ~='table' then
		return;
	end
  
	-- include the data from index into data, recursively, and return
	self:PrintAllData(index, data, keys, depth + 1);

	-- printing time
	if (depth == 0) then
		table.sort(keys);

		for i,k in ipairs(keys) do
			if (type(data[k]) ~= "function") then 
				self:PrintProperty(k, data[k], 0);
			end
		end
		-- print("========================");
		for i,k in ipairs(keys) do
			if (type(data[k]) == "function") then 
				self:PrintProperty(k, data[k], 0);
			end
		end
	end
end

function Misc:PrintProperty(property, value, depth)
	local str = " ";
	for _ = 0, depth do
		str = "-" .. str;
	end

	if (type(value) == "function") then
		-- print(str .. tostring(property));
	elseif (type(value) ~= "table") then
		print(str .. tostring(property) .. " : " .. tostring(value));
	else
		print(str .. tostring(property))
		for k,v in pairs(value) do
			self:PrintProperty(k, v, depth+1);
		end	
	end
end