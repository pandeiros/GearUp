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

GU_ITEM_STATUS_PENDING      = 0;    -- Data for this item cannot yet be obtained (probably because WoW API limits).
GU_ITEM_STATUS_INVALID      = 1;    -- There is no item for this ID (this can be determined when deprecated + scanned == MAX_ITEM_COUNT)
GU_ITEM_STATUS_DEPRECATED   = 2;    -- Item's name suggest it's an old or deprecated item and no longer visible in game.
GU_ITEM_STATUS_SCANNED      = 3;    -- Item's data was obtaing from WoW API and its tooltip stored.
GU_ITEM_STATUS_PARSED       = 4;    -- Item's tooltip is fully parsed and ready for export.

function Data:Initialize()
    if (not GU.db.global.scanDB) then
        self:ResetScanningDatabase();
    end

    if (not GU.db.global.itemDB) then
        self:ResetItemDatabase();
    end
end

function Data:Cleanup()
    self:SetScanEnabled(false);
end

function Data:ResetDatabase()
    self:ResetItemDatabase();
    self:ResetScanningDatabase();
end

function Data:ResetItemDatabase()
    GU.db.global.itemDB = {};       -- Contains processed, final info about items.

    local itemDB = GU.db.global.itemDB;

    -- Create structures for supported locales.
    -- self:CreateLocalizedItemStructures("esES");
end

function Data:ResetScanningDatabase()
    GU.db.global.scanDB = {};         -- Contains scanned and parsed info about items (developers only).

    self.lastIDScanned = 1;
    -- self.LastPendingID = 0;
    self.prioIDList = {};

    local scanDB = GU.db.global.scanDB

    scanDB.scanEnabled = false;

    -- Maps item ID to its tooltip as string.
    -- This is used to ease up scanning process and for future comparisons with new tooltips.
    -- Structure:
    -- itemID = "item tooltip text"
    scanDB.tooltips = {};
    scanDB.tooltips[MAIN_LOCALE_DB_KEY] = {};

    -- Maps item ID to its data.
    -- Structure (enUS):
    -- itemID = {
    --     version : string             -- Addon version when this was last scanned.
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
    --     classes : {}                 -- list of available classes or empty for all
    --     set : string                 -- Name of the set, if eligible
    --     properties : {}              -- List of name -> value pairs for common properties
    --     equipBonuses : {}            -- List of unique equip, use and onHit bonuses.
    --     useBonuses : {}
    --     onHitBonuses : {}
    -- }
    -- Structure (localised)
    -- itemID = {
    --     version : string             -- Addon version when this was last scanned.
    --     name : string
    --     equipBonuses : {}
    --     useBonuses : {}
    --     onHit : {}
    -- }
    scanDB.items = {};
    scanDB.items[MAIN_LOCALE_DB_KEY] = {};

    -- Maps item ID to parsing status: pending, invalid, deprecated, scanned or parsed
    scanDB.status = {};
    scanDB.status[MAIN_LOCALE_DB_KEY] = {};

    -- Maps set name to set details (items, bonuses etc.)
    -- Structure (enUS):
    -- setName = {
    --     items : {}          -- List of item IDs for this set.
    --     bonuses : {}        -- List of tier -> bonus pairs (eg. 2 -> bonus description)
    -- }
    -- Structure (localised):
    -- setName = {
    --     nameEN : string     -- Default set name for enUS locale.
    --     bonuses : {}        -- Localized set bonuses
    -- }
    scanDB.sets = {};
    scanDB.sets[MAIN_LOCALE_DB_KEY] = {};

    -- Create structures for supported locales.
    -- self:CreateLocalizedScanningStructures("esES");
end

function Data:CreateLocalizedItemStructures(locale)
    local itemDB = GU.db.global.itemDB;

    if (Locales:IsSupportingLocale(locale)) then
        -- TODO
    else 
        Logger:Err("Data:CreateLocalizedItemStructures Locale %s is not supported.", locale);
    end
end

function Data:CreateLocalizedScanningStructures(locale)
    local scanDB = GU.db.global.scanDB

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

    Logger:Log("Scanning enabled: %s", Misc:BoolToString(scanDB.scanEnabled));
    Logger:Log("- Pending items: %d", pending);
    Logger:Log("- Invalid items: %d", invalid);
    Logger:Log("- Deprecated items: %d", deprecated);
    Logger:Log("- Scanned items: %d", scanned);
    Logger:Log("- Parsed items: %d", parsed);
    Logger:Log("- Remaining items: %d", remaining);
end

-- Debug purposes only.
function Data:PrintDatabase()
    local scanDB = GU.db.global.scanDB;

end

function Data:PrintAllItemLinks()
    local scanDB = GU.db.global.scanDB;

    -- Logger:Display("|cffff00ff|Hitem:19019:911:::::1741::60:::::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r");
    -- |cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
    for k,v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        Logger:Display("%d -> %s", k, Misc:GenerateFullItemLink(k, v.rarity, v.name));
    end
end