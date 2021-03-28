-- #TODO Copyright here

local Arma = _G.Arma;
local Misc = Arma.Misc;
local Style = Arma.Style;
local Colors = Style.Colors;

----------------------------------------------------------
-- Classes
----------------------------------------------------------

local CLASSES_ID = {
	[0]		= CLASS_DEATHKNIGHT,
	[1]		= CLASS_DEMONHUNTER,
	[2]		= CLASS_DRUID,
	[3]		= CLASS_HUNTER,
	[4]		= CLASS_MAGE,
	[5]		= CLASS_MONK,
	[6]		= CLASS_PALADIN,
	[7]		= CLASS_PRIEST,
	[8]		= CLASS_ROGUE,
	[9]		= CLASS_SHAMAN,
	[10]	= CLASS_WARLOCK,
	[11]	= CLASS_WARRIOR,
}

function Misc:GetClassNameByID(classID)
	return CLASSES_ID[classID];
end

----------------------------------------------------------
-- Items & Inventory functions
----------------------------------------------------------

local COIN_TEXTURES = {
    "|TInterface\\Moneyframe\\UI-GoldIcon:0:0:4:0|t",
    "|TInterface\\Moneyframe\\UI-SilverIcon:0:0:4:0|t",
    "|TInterface\\Moneyframe\\UI-CopperIcon:0:0:4:0|t"
}

-- coinType: 1 - gold, 2 - silver, 3 - copper
function Misc:GetCoinTextureWithValue(value, coinType)
    if (value > 0) then
        return Colors:GetColorStr(COLOR_WHITE, tostring(value)) .. COIN_TEXTURES[coinType] .. "  ";
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
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4,
    Suffix, Unique, LinkLvl, Name = string.find(itemLink,
	"|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	
	return Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, Name;
end

function Misc:GetItemIDFromLink(itemLink)
	local _, _, ID = self:GetItemDataFromLink(itemLink);
    return tonumber(ID);
end

function Misc:GenerateItemLinkFromID(itemID)
	return string.format("|cffffffff|Hitem:%d::::::::60:::::::|h[Item link]|h|r", itemID);
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
function IFTE(condition, if_true, if_false)
    if condition then return if_true else return if_false end
end

-- Clamp
function Clamp(value, min, max)
	if (value > max) then
		return max;
	elseif (value < min) then
		return min;
	end

	return value;
end

-- Converts a decimal number to hexadecimal number.
function DECToHEX(decNumber)
	local hexNumber = "0x";
	local hex = "";
    while (decNumber > 0) do
        local index = math.fmod(decNumber, 16) + 1;
        decNumber = math.floor(decNumber / 16);
        hex = string.sub('0123456789ABCDEF', index, index) .. hex;			
    end

    if (string.len(hex) == 0) then
        hex = "0";
	end
	
	hexNumber = hexNumber .. hex;

    return hexNumber;
end

function Inc(value)
	value = value + 1;
	return value;
end

function Dec(value)
	return value - 1;
end

function Length(t)
	local length = 0;
	if (type(t) == "table") then
		for k,v in pairs(t) do
			length = length + 1;
		end
	end

	return length;
end

----------------------------------------------------------
-- Objects/Tables
----------------------------------------------------------

function CreateObject(objectOrName, ...)
    local object,name
	local i=1
	if type(objectorname)=="table" then
		object=objectorname
		name=...
		i=2
	else
		name=objectorname
	end

    object = object or {}
    object.name = name
    
    return object
end

function GetAllDataOld(t, prevData)
	-- if prevData == nil, start empty, otherwise start with prevData
	local data = prevData or {}
  
	-- copy all the attributes from t
	for k,v in pairs(t) do
	  data[k] = data[k] or v
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
	return GetAllDataOld(index, data)
end

function PrintAllDataOld(t, prevData)
	-- if prevData == nil, start empty, otherwise start with prevData
	local data = prevData or {}
	print("==========================");
	
	-- copy all the attributes from t
	for k,v in pairs(t) do
		print(tostring(k) .. " -> " .. tostring(v));
		data[k] = data[k] or v
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
	return PrintAllDataOld(index, data)
end

function PrintAllProperties(t, prevData)
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
	return PrintAllProperties(index, data)
end

function PrintAllData(object, prevData, keys, depth)
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
	PrintAllData(index, data, keys, depth + 1);

	-- printing time
	if (depth == 0) then
		table.sort(keys);

		for i,k in ipairs(keys) do
			if (type(data[k]) ~= "function") then 
				PrintProperty(k, data[k], 0);
			end
		end
		-- print("========================");
		for i,k in ipairs(keys) do
			if (type(data[k]) == "function") then 
				PrintProperty(k, data[k], 0);
			end
		end
	end
end

function PrintProperty(property, value, depth)
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
			PrintProperty(k, v, depth+1);
		end	
	end
end