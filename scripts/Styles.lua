-- TODO Copyright here

local GU = _G.GU;
local Style = GU.Style;
local Misc = GU.Misc;

local Colors = {};
GU.Style.Colors = Colors;

-- Color shades (from darkest to lighest, 0 - 16)
local COLOR_SHADES = {
    ["Gray"]            = {"000000", "0F0F0F", "1F1F1F", "2F2F2F", "3F3F3F", "4F4F4F", "5F5F5F", "6F6F6F", "7F7F7F", "8F8F8F", "9F9F9F", "AFAFAF", "BFBFBF", "CFCFCF", "DFDFDF", "EFEFEF", "FFFFFF"},
    ["Red"]             = {"1C0000", "380000", "550000", "710000", "8D0000", "AA0000", "C60000", "E20000", "FF0000", "FF1C1C", "FF3838", "FF5555", "FF7171", "FF8D8D", "FFAAAA", "FFC6C6", "FFE2E2"},
    ["Orange"]          = {"1C0E00", "381C00", "552A00", "713800", "8D4600", "AA5500", "C66300", "E27100", "FF7F00", "FF8D1C", "FF9B38", "FFAA55", "FFB871", "FFC68D", "FFD4AA", "FFE2C6", "FFF0E2"},
    ["Yellow"]          = {"1C1C00", "383800", "555500", "717100", "8D8D00", "AAAA00", "C6C600", "E2E200", "FFFF00", "FFFF1C", "FFFF38", "FFFF55", "FFFF71", "FFFF8D", "FFFFAA", "FFFFC6", "FFFFE2"},
    ["Lime"]            = {"0E1C00", "1C3800", "2A5500", "387100", "468D00", "55AA00", "63C600", "71E200", "7FFF00", "8DFF1C", "9BFF38", "AAFF55", "B8FF71", "C6FF8D", "D4FFAA", "E2FFC6", "F0FFE2"},
    ["Green"]           = {"001C00", "003800", "005500", "007100", "008D00", "00AA00", "00C600", "00E200", "00FF00", "1CFF1C", "38FF38", "55FF55", "71FF71", "8DFF8D", "AAFFAA", "C6FFC6", "E2FFE2"},
    ["LightGreen"]      = {"001C0E", "00381C", "00552A", "007138", "008D46", "00AA55", "00C663", "00E271", "00FF7F", "1CFF8D", "38FF9B", "55FFAA", "71FFB8", "8DFFC6", "AAFFD4", "C6FFE2", "E2FFF0"},
    ["Turquoise"]       = {"001C1C", "003838", "005555", "007171", "008D8D", "00AAAA", "00C6C6", "00E2E2", "00FFFF", "1CFFFF", "38FFFF", "55FFFF", "71FFFF", "8DFFFF", "AAFFFF", "C6FFFF", "E2FFFF"},
    ["Azure"]           = {"000E1C", "001C38", "002A55", "003871", "00468D", "0055AA", "0063C6", "0071E2", "007FFF", "1C8DFF", "389BFF", "55AAFF", "71B8FF", "8DC6FF", "AAD4FF", "C6E2FF", "E2F0FF"},
    ["Blue"]            = {"00001C", "000038", "000055", "000071", "00008D", "0000AA", "0000C6", "0000E2", "0000FF", "1C1CFF", "3838FF", "5555FF", "7171FF", "8D8DFF", "AAAAFF", "C6C6FF", "E2E2FF"},
    ["Purple"]          = {"0E001C", "1C0038", "2A0055", "380071", "46008D", "5500AA", "6300C6", "7100E2", "7F00FF", "8D1CFF", "9B38FF", "AA55FF", "B871FF", "C68DFF", "D4AAFF", "E2C6FF", "F0E2FF"},
    ["Fuchsia"]         = {"1C001C", "380038", "550055", "710071", "8D008D", "AA00AA", "C600C6", "E200E2", "FF00FF", "FF1CFF", "FF38FF", "FF55FF", "FF71FF", "FF8DFF", "FFAAFF", "FFC6FF", "FFE2FF"},
    ["Pink"]            = {"1C000E", "38001C", "55002A", "710038", "8D0046", "AA0055", "C60063", "E20071", "FF007F", "FF1C8D", "FF389B", "FF55AA", "FF71B8", "FF8DC6", "FFAAD4", "FFC6E2", "FFE2F0"},
}

-- Color groups
local COLOR_DATA = {
    ["Rarity"]      = {"9D9D9D", "FFFFFF", "1EFF00", "0070DD", "A335EE", "FF8000", "E6CC80", "00CCFF"},
    ["Class"]       = {
        [GU_CLASS_DEATHKNIGHT]   = "C41E3A",
        [GU_CLASS_DEMONHUNTER]   = "A330C9",
        [GU_CLASS_DRUID]         = "FF7C0A",
        [GU_CLASS_HUNTER]        = "AAD372",
        [GU_CLASS_MAGE]          = "3FC6EA",
        [GU_CLASS_MONK]          = "00FF96",
        [GU_CLASS_PALADIN]       = "F48CBA",
        [GU_CLASS_PRIEST]        = "FFFFFF",
        [GU_CLASS_ROGUE]         = "FFF468",
        [GU_CLASS_SHAMAN]        = "0070DE",
        [GU_CLASS_WARLOCK]       = "8787ED",
        [GU_CLASS_WARRIOR]       = "C69B6D",
    },   
}

GU_COLOR_BLACK     = "000000";
GU_COLOR_WHITE     = "FFFFFF";
GU_COLOR_RED       = "FF0000";
GU_COLOR_ORANGE    = "FF7F00";
GU_COLOR_YELLOW    = "FFFF00";
GU_COLOR_LIME      = "7FFF00";
GU_COLOR_GREEN     = "00FF00";
GU_COLOR_LGREEN    = "00FF7F";
GU_COLOR_TURQUOISE = "00FFFF";
GU_COLOR_AZURE     = "007FFF";
GU_COLOR_BLUE      = "0000FF";
GU_COLOR_PURPLE    = "7F00FF";
GU_COLOR_FUCHSIA   = "FF00FF";
GU_COLOR_PINK      = "FF007F";

-- Styles
local DEFAULT_STYLE = {
    primaryAccentColor      = COLOR_SHADES["Orange"][11],
    secondaryAccentColor    = COLOR_SHADES["Blue"][8],
    primaryFontColor        = COLOR_SHADES["Gray"][16],
    secondaryFontColor      = COLOR_SHADES["Gray"][15],
    backgroundColor         = COLOR_SHADES["Gray"][3],

    displayColor            = COLOR_SHADES["Orange"][11],
    verboseColor            = COLOR_SHADES["Gray"][10],
    logColor                = GU_COLOR_WHITE,
    warningColor            = GU_COLOR_YELLOW,
    errorColor              = GU_COLOR_RED,
}

-- Operation quality.
local OP_QUALITY_COLORS = {
    COLOR_DATA["Rarity"][1],
    COLOR_SHADES["Red"][8], 
    COLOR_SHADES["Yellow"][8], 
    COLOR_SHADES["Green"][8], 
    COLOR_SHADES["Blue"][8],
    COLOR_SHADES["Purple"][8]
}

function Style:GetDefaultStyle()
    return DEFAULT_STYLE;
end

-- Brightness range 0-16
function Style:GetColorShade(color, brightness)
    return COLOR_SHADES[color][brightness + 1];
end

-- Rarity level between 0 and 7
function Style:GetRarityColor(rarityLevel)
    return COLOR_DATA["Rarity"][rarityLevel + 1];
end

-- Operation quality between 1 and 6 (worst to best)
function Style:GetOperationQualityColor(opQuality)
    return OP_QUALITY_COLORS[opQuality];
end

function Style:GetClassColor(class)
    if (COLOR_DATA["Class"][class]) then
        return COLOR_DATA["Class"][class];
    end

    return "FFFFFF";
end

----------------------------------------------------------
-- Color functions
----------------------------------------------------------

-- Adds FF at the beginning.
function Colors:GetColor(hexColor)
    if (string.len(hexColor) == 6) then
        return "FF" .. hexColor;
    elseif (string.len(hexColor) == 8) then
        return hexColor;
    end
        
    return "FFFF0000";
end

-- Construct hex color with given alphaValue <0, 1>.
function Colors:GetColorAlpha(hexColor, alphaValue)
    if (type(alphaValue) ~= "number") then
        return "FF" .. hexColor;
    end

    alphaValue = Misc:Clamp(alphaValue, 0.0, 1.0);
    alphaValue = math.floor(255 * alphaValue);
    hexValue = Misc:DECToHEX(alphaValue);
    hexValue = hexValue:gsub("0x","");

    return hexValue .. hexColor;
end

function Colors:GetColorStr(hexColor, str)
    if (string.len(hexColor) == 6) then
        hexColor = self:GetColor(hexColor);
    end

    return "|c" .. hexColor .. str .. "|r";
end

function Colors:HEXToRGB(hex)
    local hex = hex:gsub("#", "");
    hex = hex:gsub("0x", "");
    
    if hex:len() == 3 then
		return (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255;
    else
		return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255;
    end
end

function Colors:RGB(r, g, b)
    return {r, g, b};
end

function Colors:UnwrapRGB(rgb)
    return rgb[0], rgb[1], rgb[2];
end

function Colors:RGBToHEX(rgb)
	local hexadecimal = '#';

	for key, value in pairs(rgb) do
		local hex = '';
		while (value > 0) do
			local index = math.fmod(value, 16) + 1;
			value = math.floor(value / 16);
			hex = string.sub('0123456789ABCDEF', index, index) .. hex;			
		end

		if (string.len(hex) == 0) then
			hex = '00';
		elseif (string.len(hex) == 1) then
			hex = '0' .. hex;
		end

		hexadecimal = hexadecimal .. hex;
	end

	return hexadecimal
end

function Colors:GetColorTestString()
    local test = "";
    for key, value in pairs(COLOR_SHADES) do
        for key2, value2 in pairs(value) do
            test = test .. self:GetColorStr(value2, "\#");
        end
        test = test .. "\n";
    end
end
