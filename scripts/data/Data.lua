-- #TODO Copyright here

local GU = _G.GU;

local Data = GU.Data;
local Style = GU.Style;
local Locales = GU.Locales;
local Logger = GU.Logger;
local Frames = GU.Frames;
local Misc = GU.Misc;

-- Database defaults
GU_DB_DEFAULT_PROFILE_NAME = "Default";
GU_DB_DEFAULTS = {
    profile = {
        style = Style:GetDefaultStyle(),
    }
}

GU_ITEM_STATUS_PENDING      = 0;    -- Data for this item cannot yet be obtained (probably because of WoW API limits).
GU_ITEM_STATUS_INVALID      = 1;    -- There is no item for this ID (this can be determined when deprecated + scanned == MAX_ITEM_COUNT)
GU_ITEM_STATUS_DEPRECATED   = 2;    -- Item's name suggest it's an old or deprecated item and no longer visible in game.
GU_ITEM_STATUS_SCANNED      = 3;    -- Item's data was obtaing from WoW API and its tooltip stored.
GU_ITEM_STATUS_PARSED       = 4;    -- Item's tooltip is fully parsed and ready for export.

function Data:Initialize()
    if (not GU.db.global.scanDB) then
        self:ResetScanningDatabase();
    end

    if (not GU.db.global.parseDB) then
        self:ResetParsingDatabase();
    end

    GU.db.global.itemDB = {}; 

    local scanDB = GU.db.global.scanDB;
    for k, v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        v.equipBonuses = nil;
        v.useBonuses = nil;
        v.onHitBonuses = nil;
        v.equipEffects = {};
        v.useEffects = {};
        v.onHitEffects = {};
    end

    self:InitProperties();
end

function Data:InitProperties()
    local scanDB = GU.db.global.scanDB

    scanDB.scanEnabled = scanDB.scanEnabled or false;
    scanDB.parseEnabled = scanDB.parseEnabled or false;

    -- TODO Flavor check
    -- Rather than base scan version on addon version use some mix of addon + flavor version.
    -- Because of the fact that the same addon is used to scan and parse data for all flavors,
    -- once the saved scan version doesn't match the current flavor and patch, prevent scanning
    -- and parsing before scanning database is reset.
    scanDB.scanVersion = scanDB.scanVersion or GU_ADDON_VERSION;

    self.lastIndexScanned = 1;
    self.lastTooltipIndex = 1;
    self.scanningCount = 0;
    self.prioScanIDList = {};
    self.prioTooltipIDList = {};

    self.lastIDParsed = 0;

    self.fixingItems = false;
end

function Data:HasTasks()
    local scanDB = GU.db.global.scanDB

    if (scanDB.scanEnabled or scanDB.parseEnabled or self.fixingItems) then
        return true;
    end

    return false;
end

function Data:DoTasks(taskCount)
    for _ = 1,taskCount do
        self:ScanItems();
        self:ParseItems();
        self:FixItems();
    end
end

function Data:Cleanup()
    self:SetScanEnabled(false);
    self:SetParseEnabled(false);
end

function Data:ResetDatabase()
    self:ResetScanningDatabase();
    self:ResetParsingDatabase();
end

function Data:ResetParsingDatabase()
    GU.db.global.parseDB = {};       -- Contains processed, final info about items.

    local parseDB = GU.db.global.parseDB;

    -- Create structures for supported locales.
    -- self:CreateLocalizedParsingStructures("esES");
end

function Data:ResetScanningDatabase()
    GU.db.global.scanDB = {};         -- Contains scanned and parsed info about items (developers only).

    local scanDB = GU.db.global.scanDB

    scanDB.scanEnabled = false;
    scanDB.parseEnabled = false;
    scanDB.scanVersion = GU_ADDON_VERSION;

    -- Maps item ID to its tooltip as string.
    -- This is used to ease up scanning process and for future comparisons with new tooltips.
    -- Structure:
    -- itemID = "item tooltip text"
    scanDB.tooltips = {};
    scanDB.tooltips[MAIN_LOCALE_DB_KEY] = {};

    -- Maps item ID to its data.
    -- Structure (enUS):
    -- itemID = {
    --     name : string (enUS)
    --     rarity : int <0; 7>
    --     itemLevel : int
    --     minLevel : int <0; 60>       -- 0 mean no level requirement
    --     type : string (enUS)
    --     subtype : string (enUS)
    --     stacks : int
    --     equipLocation : string
    --     texture : string
    --     sellPrice : int
    --     classes : {}                 -- List of available classes or empty for all
    --     races : {}                   -- List of available races or empty for all
    --     set : string                 -- Name of the set, if eligible
    --     randomEnchantment : bool
    --     properties : {}              -- List of name -> value pairs for common properties
    --     equipEffects : {}            -- List of unique equip, use and onHit effects.
    --     useEffects : {}
    --     onHitEffects : {}
    -- }
    -- Structure (localised)
    -- itemID = {
    --     name : string
    --     equipEffects : {}
    --     useEffects : {}
    --     onHitEffects : {}
    -- }
    scanDB.items = {};
    scanDB.items[MAIN_LOCALE_DB_KEY] = {};

    -- Maps item ID to parsing status: pending, invalid, deprecated, scanned or parsed
    scanDB.status = {};
    scanDB.status[MAIN_LOCALE_DB_KEY] = {};

    -- Maps item ID of a deprecated item to its name. This is only for debugging purposes.
    scanDB.deprecated = {};

    -- Maps set name to set details (items, bonuses etc.)
    -- Structure (enUS):
    -- setName = {
    --     items : {}          -- List of item IDs for this set.
    --     bonuses : {}        -- List of tier -> bonus pairs (eg. 2 -> bonus description)
    -- }
    -- Structure (localised):
    -- setName = {
    --     nameEN : string     -- Default set name for enUS locale. NOTE: This can be parsed manually after parsing enUS locale.
    --     bonuses : {}        -- Localized set bonuses
    -- }
    scanDB.sets = {};
    scanDB.sets[MAIN_LOCALE_DB_KEY] = {};

    -- Create structures for supported locales.
    -- self:CreateLocalizedScanningStructures("esES");
end

function Data:CreateLocalizedParsingStructures(locale)
    local parseDB = GU.db.global.parseDB;

    if (Locales:IsSupportingLocale(locale)) then
        -- TODO
    else 
        Logger:Err("Data:CreateLocalizedParsingStructures Locale %s is not supported.", locale);
    end
end

function Data:CreateLocalizedScanningStructures(locale)
    local scanDB = GU.db.global.scanDB;

    if (Locales:IsSupportingLocale(locale)) then
        scanDB.tooltips[locale] = {};
        scanDB.items[locale] = {};
        scanDB.status[locale] = {};
        scanDB.sets[locale] = {};
    else 
        Logger:Err("Data:CreateLocalizedScanningStructures Locale %s is not supported.", locale);
    end
end

function Data:PrintDatabaseStats()
    local scanDB = GU.db.global.scanDB;

    local pending, invalid, deprecated, scanned, parsed, remaining = self:GetScanningStatus(Locales:GetDatabaseLocaleKey());
    local invalidTooltips, emptyTooltips, incorrectTooltips, validTooltips = self:GetTooltipStatus();

    Logger:Log("Scanning enabled: %s", Misc:BoolToString(scanDB.scanEnabled));
    Logger:Log("Parsing enabled: %s", Misc:BoolToString(scanDB.parseEnabled));
    Logger:Log("- Pending items: %d", pending);
    Logger:Log("- Invalid items: %d", invalid);
    Logger:Log("- Deprecated items: %d", deprecated);
    Logger:Log("- Scanned items: %d", scanned);
    Logger:Log("- Parsed items: %d", parsed);
    Logger:Log("- Remaining items: %d", remaining);
    Logger:Log("");
    Logger:Log("Tooltip info:");
    Logger:Log("- Invalid tooltips: %d", invalidTooltips);
    Logger:Log("- Empty tooltips: %d", emptyTooltips);
    Logger:Log("- Incorrect tooltips: %d", incorrectTooltips);
    Logger:Log("- Valid tooltips: %d", validTooltips);
end

function Data:GetItemStatusAsString(status)
    if (status == GU_ITEM_STATUS_PENDING) then return "Pending"; end
    if (status == GU_ITEM_STATUS_INVALID) then return "Invalid"; end
    if (status == GU_ITEM_STATUS_DEPRECATED) then return "Deprecated"; end
    if (status == GU_ITEM_STATUS_SCANNED) then return "Scanned"; end
    if (status == GU_ITEM_STATUS_PARSED) then return "Parsed"; end

    return "unknown";
end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Data:PrintAllItemLinks()
    local scanDB = GU.db.global.scanDB;

    for k,v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        Logger:Display("%d -> %s", k, Misc:GenerateFullItemLink(k, v.rarity, v.name));
    end
end

function Data:PrintItemInfoByID(id)
    local scanDB = GU.db.global.scanDB;

    if (scanDB.items[Locales:GetDatabaseLocaleKey()][id] ~= nil) then
        local item = scanDB.items[Locales:GetDatabaseLocaleKey()][id];
        self:PrintItemInfo(item, id);
    elseif (scanDB.status[Locales:GetDatabaseLocaleKey()][id] == GU_ITEM_STATUS_DEPRECATED) then
        Logger:Display("%s (ID: %d) is deprecated", scanDB.deprecated[id], id);
    else
        Logger:Display("No data for ID: %d (status: %s)", id, self:GetItemStatusAsString(scanDB.status[Locales:GetDatabaseLocaleKey()][id]));
    end
end

function Data:PrintItemInfo(item, id)
    local scanDB = GU.db.global.scanDB;

    Logger:Display("%s (ID: %d)",  item.name, id);
    Logger:Display("%s", Misc:GenerateFullItemLink(id, item.rarity, item.name));
    Logger:Display("- Status: %s", self:GetItemStatusAsString(scanDB.status[Locales:GetDatabaseLocaleKey()][id]));
    Logger:Display("- Type/Subtype: %s/%s", item.type, item.subtype);
    Logger:Display("- Equip location: %s", item.equipLocation);
    Logger:Display("- Set: %s", item.set);
    Logger:Display("- Classes: %s", Misc:GetTableAsString(item.classes or {}, ", "));
    Logger:Display("- Races: %s", Misc:GetTableAsString(item.races or {}, ", "));
    Logger:Display("- Random enchantment: %s", Misc:BoolToString(item.randomEnchantment or false));
    Logger:Display("- Properties:");
    for k,v in pairs(item.properties) do
        Logger:Display("--- %s: %s", k, tostring(v));
	end
    Logger:Display("- Equip effects:");
    for k,v in pairs(item.equipEffects) do
        Logger:Display("--- %s: %s", k, tostring(v));
	end
    Logger:Display("- Use effects:");
    for k,v in pairs(item.useEffects) do
        Logger:Display("--- %s: %s", k, tostring(v));
	end
    Logger:Display("- Chance on hit effects:");
    for k,v in pairs(item.onHitEffects) do
        Logger:Display("--- %s: %s", k, tostring(v));
	end
     
    local scanDB = GU.db.global.scanDB;

    if (scanDB.tooltips[Locales:GetDatabaseLocaleKey()][id]) then
        local tooltip = scanDB.tooltips[Locales:GetDatabaseLocaleKey()][id];
        if (tooltip == nil or tooltip == "") then
            Logger:Display("- Tooltip: empty");
        else
            Logger:Display("- Tooltip:\n%s", tooltip);
        end
    else
        Logger:Display("- Tooltip: none");
    end
end

function Data:SerializeTest()
    local scanDB = GU.db.global.scanDB;

    local str = GU_AceSerializer:Serialize(scanDB.items[Locales:GetDatabaseLocaleKey()][12640]);
    Logger:Log(str);
end

function Data:DeleteAllItemTooltips()
    local scanDB = GU.db.global.scanDB;

    for k,v in pairs(scanDB.tooltips[Locales:GetDatabaseLocaleKey()]) do
        if (v) then
            scanDB.tooltips[Locales:GetDatabaseLocaleKey()][k] = nil;
        end
    end
end