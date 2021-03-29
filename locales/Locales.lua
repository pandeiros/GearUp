-- #TODO Copyright here

MAIN_LOCALE_DB_KEY = "main";

local L = GU_AceLocale:GetLocale("GU");
local mainLocales = {"enUS", "enGB"};		-- Locales that uses "main" database, without need for translation.
local supportedLocales = {"enUS", "enGB"};
local currentLocale = GetLocale();

local GU = _G.GU;

local Locales = {};
GU.Locales = Locales;

function Locales:GetCurrentLocale()
	return currentLocale;
end

function Locales:IsCurrentLocaleMainLocale()
	for _, v in pairs(mainLocales) do
		if v == currentLocale then return true end
	end
	return false;
end

function Locales:IsSupportingCurrentLocale()
    for _, v in pairs(supportedLocales) do
		if v == currentLocale then return true end
	end
	return false;
end

function Locales:IsSupportingLocale(locale)
    for _, v in pairs(supportedLocales) do
		if v == locale then return true end
	end
	return false;
end

function Locales:GetDatabaseLocaleKey()
	for _, v in pairs(mainLocales) do
		if v == currentLocale then return MAIN_LOCALE_DB_KEY end
	end
	return currentLocale;
end

----------------------------------------------------------
-- Generated localized strings
----------------------------------------------------------

if (L) then

L["Professions"]     = _G["TRADE_SKILLS"];
L["Alchemy"]         = GetSpellInfo(2259);
L["Blacksmithing"]   = GetSpellInfo(2018);
L["Cooking"]         = GetSpellInfo(2550);
L["Enchanting"]      = GetSpellInfo(7411);
L["Engineering"]     = GetSpellInfo(4036);
L["First Aid"]       = GetSpellInfo(3273);
L["Fishing"]         = GetSpellInfo(7732);
L["Herbalism"]       = GetSpellInfo(2366);
L["Mining"]          = GetSpellInfo(2575);
L["Leatherworking"]  = GetSpellInfo(2108);
L["Skinning"]        = GetSpellInfo(8618);
L["Tailoring"]       = GetSpellInfo(3908);

end