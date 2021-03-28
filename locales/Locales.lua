-- #TODO Copyright here

MAIN_LOCALE_DB_KEY = "main";

local L = AceLocale:GetLocale("Arma");
local mainLocales = {"enUS", "enGB"};		-- Locales that uses "main" database, without need for translation.
local supportedLocales = {"enUS", "enGB"};
local locale = GetLocale();

function IsSupportingCurrentLocale()
    for _, v in pairs(supportedLocales) do
		if v == locale then return true end
	end
	return false
end

function GetDatabaseLocaleKey()
	for _, v in pairs(mainLocales) do
		if v == locale then return MAIN_LOCALE_DB_KEY end
	end
	return locale
end


----------------------------------------------------------
-- Generated locales
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