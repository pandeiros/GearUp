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

    if (not GU.db.global.itemDB) then
        self:ResetItemDatabase();
    end

    local scanDB = GU.db.global.scanDB;
    for k, v in pairs(scanDB.status[Locales:GetDatabaseLocaleKey()]) do
        if (k >= self:GetMaxItemID()) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][k] = nil;
        end
    end

    self:InitProperties();
end

function Data:InitProperties()
    local scanDB = GU.db.global.scanDB

    scanDB.scanEnabled = scanDB.scanEnabled or false;
    scanDB.parseEnabled = scanDB.parseEnabled or false;
    scanDB.scanVersion = scanDB.scanVersion or GU_ADDON_VERSION;

    self.lastIDScanned = 0;
    self.lastIDParsed = 0;
    self.prioIDList = {};
end

function Data:HasTasks()
    local scanDB = GU.db.global.scanDB

    if (scanDB.scanEnabled or scanDB.parseEnabled) then
        return true;
    end

    return false;
end

function Data:DoTasks(taskCount)
    for _ = 1,taskCount do
        self:ScanItems();
    end
end

function Data:Cleanup()
    self:SetScanEnabled(false);
    self:SetParseEnabled(false);
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
    --     classes : {}                 -- list of available classes or empty for all
    --     set : string                 -- Name of the set, if eligible
    --     properties : {}              -- List of name -> value pairs for common properties
    --     equipBonuses : {}            -- List of unique equip, use and onHit bonuses.
    --     useBonuses : {}
    --     onHitBonuses : {}
    -- }
    -- Structure (localised)
    -- itemID = {
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

function Data:MarkItemIDAsDeprecated(itemID, itemName)
    local scanDB = GU.db.global.scanDB;

    if (type(itemID) ~= "number") then
        return;
    end

    scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_DEPRECATED;
    scanDB.items[Locales:GetDatabaseLocaleKey()][itemID] = nil;
    scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] = nil;
    scanDB.deprecated[itemID] = itemName;

    itemName = itemName or "UNKNOWN";
    Logger:Verb("Marking %s (ID: %d) as deprecated. Removing associated data.", itemName, itemID);
end

function Data:MarkItemIDAsScanned(itemID)
    local scanDB = GU.db.global.scanDB;

    if (type(itemID) ~= "number") then
        return;
    end

    local status = scanDB.status[Locales:GetDatabaseLocaleKey()][itemID];
    if (status ~= GU_ITEM_STATUS_SCANNED) then
        if (status == GU_ITEM_STATUS_DEPRECATED) then
            scanDB.deprecated[itemID] = nil;
        elseif (status == GU_ITEM_STATUS_PARSED) then
            local item = scanDB.items[Locales:GetDatabaseLocaleKey()][itemID];
            self:ResetParsedProperties(item);
        end

        scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_SCANNED;

        Logger:Verb("Marking %s (ID: %d) as scanned.", scanDB.items[Locales:GetDatabaseLocaleKey()][itemID].name, itemID);
    end
end

function Data:ResetParsedProperties(item)
    local scanDB = GU.db.global.scanDB;

    local set = item.set;
    if (set and set ~= "") then
        scanDB.sets[Locales:GetDatabaseLocaleKey()][set] = nil;
    end

    item.classes = {};
    item.set = "";
    item.properties = {};
    item.equipBonuses = {};
    item.useBonuses = {};
    item.onHitBonuses = {};
end

function Data:RestoreDeprecatedItem(itemID)
    local scanDB = GU.db.global.scanDB;

    if (type(itemID) ~= "number") then
        return;
    end

    local itemName = scanDB.deprecated[itemID];

    if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] == GU_ITEM_STATUS_DEPRECATED) then
        scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_PENDING;
        scanDB.deprecated[itemID] = nil;
    end

    Logger:Verb("Marking %s (ID: %d) as pending.", itemName, itemID);
    self:AddPrioItemToScan(itemID);
end

function Data:PrintDatabaseStats()
    local scanDB = GU.db.global.scanDB;

    local pending, invalid, deprecated, scanned, parsed, remaining = self:GetScanningStatus(Locales:GetDatabaseLocaleKey());

    Logger:Log("Scanning enabled: %s", Misc:BoolToString(scanDB.scanEnabled));
    Logger:Log("Parsing enabled: %s", Misc:BoolToString(scanDB.parseEnabled));
    Logger:Log("- Pending items: %d", pending);
    Logger:Log("- Invalid items: %d", invalid);
    Logger:Log("- Deprecated items: %d", deprecated);
    Logger:Log("- Scanned items: %d", scanned);
    Logger:Log("- Parsed items: %d", parsed);
    Logger:Log("- Remaining items: %d", remaining);
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
-- Debug purposes only.

function Data:PrintDatabase()
    local scanDB = GU.db.global.scanDB;

end

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

function Data:RemoveVersionFromItems()
    local scanDB = GU.db.global.scanDB;

    for k,v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        scanDB.items[Locales:GetDatabaseLocaleKey()][k].version = nil;
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

function Data:PrintTooltipStatus()
    local scanDB = GU.db.global.scanDB;

    local invalid, empty, incorrect, valid = 0, 0, 0, 0;
    for k,v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        if (scanDB.tooltips[Locales:GetDatabaseLocaleKey()][k]) then
            if (scanDB.tooltips[Locales:GetDatabaseLocaleKey()][k] == "") then
                if (v.type == GU_TYPE_ARMOR or v.type == GU_TYPE_WEAPON) then
                    incorrect = incorrect + 1;
                else
                    empty = empty + 1;
                end
            else
                valid = valid + 1;
            end
        else
            invalid = invalid + 1;
        end
    end

    Logger:Log("- Invalid tooltips: %d", invalid);
    Logger:Log("- Empty tooltips: %d", empty);
    Logger:Log("- Incorrect tooltips: %d", incorrect);
    Logger:Log("- Valid tooltips: %d", valid);

end