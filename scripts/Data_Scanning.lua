-- #TODO Copyright here

local GU = _G.GU;

local Data = GU.Data;
local Logger = GU.Logger;
local Misc = GU.Misc;
local Style = GU.Style;
local Colors = GU.Style.Colors;
local Async = GU.Async;
local Locales = GU.Locales;
local Frames = GU.Frames;

local L = GU_AceLocale:GetLocale("GU");

-- Data taken from classic.wowhead.com
local MAX_ITEM_ID = 194101;                 -- 24284        These values are from Wowhead TBC Database
local MAX_ITEM_COUNT = 25731;               -- allegedly...
local MAX_ITEM_DEPRECATED_COUNT = 904;      -- allegedly...
local SCANNING_ITEM_RANGES = {
    {0, 40000},
    {43516, 43516},
    {180089, 180089},
    {184000, 192000},
    {194101, 194101}
}

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

-- TODO This list was for Classic WoW, pending review for TBC/WotLK
-- List of unused IDs which items cannot be excluded using name patterns.
local deprecatedIDs = {
    -- 13503, 7950, 13262, 3529, 20368, 24071, 3320, 21584, 3536, 20005, 14390, 14383, 14382, 14388, 14389, 19065, 19129,
    -- 18951, 13843, 23072, 23162, 22230, 7948, 3542, 3538, 7951, 19971, 20502, 7949, 23058, 17108, 7953, 9443, 18303, 15141,
    -- 15780, 18342, 18341, 3533, 3528, 16785, 17769, 17142, 13847, 13848, 13846, 13849, 6724, 6728, 6711, 6707, 6708, 6698,
    -- 17783, 17782, 18582, 19989, 7187, 18584, 18583, 3527, 3547, 21613, 21614, 21612, 21587, 21588, 3541, 3537, 3522, 3526,
    -- 3529, 2554, 18023, 7952, 21594, 18320, 20003, 13844, 13842, 13845, 18355, 18304, 22273, 18316, 19986, 20524, 19186, 7869,
    -- 12585
}

function Data:GetMaxItemCount()
    return MAX_ITEM_COUNT;
end

function Data:GetMaxItemID()
    return MAX_ITEM_ID;
end

function Data:GetScanningStatus(locale)
    local scanDB = GU.db.global.scanDB;

    local pending = 0;
    local invalid = 0;
    local deprecated = 0;
    local scanned = 0;
    local parsed = 0;

    for _, v in pairs(scanDB.status[locale]) do
        if v == GU_ITEM_STATUS_PENDING then pending = pending + 1;
        elseif v == GU_ITEM_STATUS_INVALID then invalid = invalid + 1;
        elseif v == GU_ITEM_STATUS_DEPRECATED then deprecated = deprecated + 1;
        elseif v == GU_ITEM_STATUS_SCANNED then scanned = scanned + 1;
        elseif v == GU_ITEM_STATUS_PARSED then parsed = parsed + 1;
        end
    end

    local remaining = self:GetMaxItemCount() - scanned;
    
    return pending, invalid, deprecated, scanned, parsed, remaining;
end

function Data:GetTooltipStatus()
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

    return invalid, empty, incorrect, valid;
end

function Data:SetScanEnabled(scanEnabled)
    Logger:Log("%s %s.", "Item scan", Misc:IFTE(scanEnabled, "enabled", "disabled"));
    local scanDB = GU.db.global.scanDB;
    scanDB.scanEnabled = scanEnabled;
end

function Data:IsScanEnabled()
    local scanDB = GU.db.global.scanDB;
    return scanDB.scanEnabled;
end

function Data:WasScanned(itemID)
    local scanDB = GU.db.global.scanDB;
    if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] ~= nil and scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] ~= GU_ITEM_STATUS_PENDING) then
        return true;
    end

    return false;
end

function Data:MarkItemIDAsPending(itemID)
    local scanDB = GU.db.global.scanDB;

    if (type(itemID) ~= "number") then
        return;
    end

    local itemName = "";
    local status = scanDB.status[Locales:GetDatabaseLocaleKey()][itemID];

    if (status and status ~= GU_ITEM_STATUS_PENDING) then
        if (status == GU_ITEM_STATUS_DEPRECATED) then
            itemName = scanDB.deprecated[itemID];
            scanDB.deprecated[itemID] = nil;
        elseif (status == GU_ITEM_STATUS_SCANNED or status == GU_ITEM_STATUS_PARSED) then
            itemName = scanDB.items[Locales:GetDatabaseLocaleKey()][itemID].name;
            scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] = nil;
            scanDB.items[Locales:GetDatabaseLocaleKey()][itemID] = nil;
        end

        Logger:Verb("Marking %s (ID: %d) as pending.", itemName, itemID);
    end
end

function Data:MarkItemIDAsDeprecated(itemID, itemName)
    local scanDB = GU.db.global.scanDB;

    if (type(itemID) ~= "number") then
        return;
    end

    itemName = itemName or "UNKNOWN";

    scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_DEPRECATED;
    scanDB.items[Locales:GetDatabaseLocaleKey()][itemID] = nil;
    scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] = nil;
    scanDB.deprecated[itemID] = itemName;

    Logger:Verb("Marking %s (ID: %d) as deprecated. Removed associated data.", itemName, itemID);
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

function Data:GetItemIDToScan()
    if (Misc:Length(self.prioScanIDList) > 0) then
        local prioID = table.remove(self.prioScanIDList);
        return prioID, true;
    end

    local scanDB = GU.db.global.scanDB;
    local currentID = self:GetNextItemIDToScan(self.lastIDScanned);

    while (currentID ~= self.lastIDScanned) do
        if (not scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] and currentID ~= 0) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] = GU_ITEM_STATUS_PENDING;
            return currentID, false;
        end

        if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] == GU_ITEM_STATUS_PENDING and currentID ~= 0) then
            return currentID, false;
        end

        currentID = self:GetNextItemIDToScan(currentID);
    end

    return nil, false;
end

function Data:GetNextItemIDToScan(currentItemID)
    -- for k, v in pairs(SCANNING_ITEM_RANGES) do
    for i = 1, #SCANNING_ITEM_RANGES do
        -- Before range
        -- if (currentItemID < v[1]) then
        if (currentItemID < SCANNING_ITEM_RANGES[i][1]) then
            -- return v[1];
            return SCANNING_ITEM_RANGES[i][1];
        end

        -- In range
        if (currentItemID >= SCANNING_ITEM_RANGES[i][1] and currentItemID < SCANNING_ITEM_RANGES[i][2]) then
        -- if (currentItemID >= v[1] and currentItemID < v[2]) then
            return currentItemID + 1;
        end

        -- Beyond all range
        if (currentItemID >= self:GetMaxItemID()) then
        -- if (currentItemID >= v[2]) then
            return 0;
        end
    end

    Logger:Err("GetNextItemIDToScan Cannot obtain a valid ID. Current ID: %d", currentID);
    return nil;
end

function Data:GetItemIDForTooltipFix()
    if (Misc:Length(self.prioTooltipIDList) > 0) then
        local prioID = table.remove(self.prioTooltipIDList);
        return prioID, true;
    end

    local scanDB = GU.db.global.scanDB;
    local currentID = self:GetNextItemIDToScan(self.lastIDScanned);

    while (currentID ~= self.lastIDScanned) do
        if (not scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] and currentID ~= 0) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] = GU_ITEM_STATUS_PENDING;
            return currentID, false;
        end

        if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] == GU_ITEM_STATUS_SCANNED and currentID ~= 0) then
            return currentID, false;
        end

        currentID = self:GetNextItemIDToScan(currentID);
    end

    return nil, false;
end

function Data:AddPrioItemToScan(itemID, itemLink)
    if (itemID == nil and itemLink == nil) then
        return;
    end

    if (itemID == nil) then
        itemID = Misc:GetItemIDFromLink(itemLink);
    end

    if (self:WasScanned(itemID) == false and not Misc:Contains(self.prioScanIDList, itemID)) then
        Logger:Verb("Adding prio item ID for scanning: %d", itemID);
        table.insert(self.prioScanIDList, itemID);
    end

    if (not Misc:Contains(self.prioTooltipIDList, itemID)) then
        Logger:Verb("Adding prio item ID for tooltip fixing: %d", itemID);
        table.insert(self.prioTooltipIDList, itemID);
    end
end

function Data:ScanItems()
    local scanDB = GU.db.global.scanDB;
    if (not scanDB.scanEnabled) then
        return
    end
    
    local scanItemID, scanPrioID = self:GetItemIDToScan();
    local tooltipItemID, tooltipPrioID = self:GetItemIDForTooltipFix();

    if (scanItemID == 1) then
        Logger:Log("=== SCANNING STARTED FROM BEGINNING ==================")
    end

    if (scanItemID % 1000 == 0) then
        Logger:Verb("=== SCANNING ID: %d", scanItemID);
    end

    -- for i = 1, #SCANNING_ITEM_RANGES do
    --     Logger:Verb("%d - <%d, %d>", i, SCANNING_ITEM_RANGES[i][1], SCANNING_ITEM_RANGES[i][2]);
    -- end

    local scanSuccess, tooltipFixSuccess = false, false;

    if (scanItemID ~= nil) then
        scanSuccess = self:ScanItem(scanItemID, nil, scanPrioID);
    end

    if (tooltipItemID ~= nil) then
        tooltipFixSuccess = self:FixItemTooltip(tooltipItemID, nil, tooltipPrioID);
    end

    if (not scanSuccess and not tooltipFixSuccess) then
        Logger:Log("End of scan.");
        self:SetScanEnabled(false);
    end    
end

function Data:ScanItem(itemID, itemLink, scanPrioID)
    itemID = tonumber(itemID);
    if (itemID == nil or tonumber(itemID) <= 0) then
        if (itemLink) then
            itemID = Misc:GetItemIDFromLink(itemLink);
        else
            return;
        end
    end

    if (itemID == nil or itemID < 0 or Data:WasScanned(itemID)) then
        return;
    end

    local scanDB = GU.db.global.scanDB;

    if (not scanPrioID) then
        self.lastIDScanned = itemID;
    end

    local itemLinkOrID = itemID or itemLink;
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
        itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLinkOrID);

    if (itemName == nil) then
        scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_PENDING;
    else
        if (not Data:ValidateItem(itemName, itemID)) then
            self:MarkItemIDAsDeprecated(itemID, itemName);
        else
            self:AddScannedItem(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
                itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice);
        end
    end

    return true;
end

function Data:FixItemTooltip(itemID, itemLink, tooltipPrioID)
    itemID = tonumber(itemID);
    if (itemID == nil or tonumber(itemID) <= 0) then
        if (itemLink) then
            itemID = Misc:GetItemIDFromLink(itemLink);
        else
            return;
        end
    end

    if (itemID == nil or itemID < 0) then
        return;
    end

    local scanDB = GU.db.global.scanDB;

    if (not tooltipPrioID) then
        self.lastIDForTooltip = itemID;
    end

    if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] and scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] == GU_ITEM_STATUS_SCANNED) then
        local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
        local tooltip, replaced = self:AddItemTooltip(itemID, Misc:GenerateFullItemLink(itemID, scanItemsDB[itemID].rarity, scanItemsDB[itemID].name));
        if (not tooltip) then
            Logger:Err("Data:FixItemTooltip Invalid tooltip found for item %s (%d)", scanItemsDB[itemID].name, itemID);
            return false;
        elseif (replaced) then
            Logger:Log("Fixed item tooltip for ID: %d", itemID);            
        end
    end
end

-- Filters out invalid, deprecated, old or test items.
function Data:ValidateItem(name, itemID)
    if (type(itemID) == "number") then
        if (Misc:Contains(deprecatedIDs, itemID)) then
            Logger:Verb("%5d - %s is deprecated/invalid. Reason: invalid ID", itemID, name);
            return false;
        end
    end
    
    if (not name) then
        return false;
    end

    local lname = strlower(name);
    if (strfind(lname, "deprecated") ~= nil or strfind(lname, "deptecated") ~= nil or strfind(name, "DEP") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'deprecated' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "test") ~= nil and strfind(lname, "intestines") == nil and strfind(lname, "untested") == nil
            and strfind(lname, "greatest") == nil and strfind(lname, "contest") == nil
            and name ~= "Field Testing Kit" and name ~= "Testament of Hope" and name ~= "Un'Goro Tested Sample"
            and name ~= "Corrupt Tested Sample") then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'test' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "monster %- ") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'monster - ' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "bug") ~= nil and name ~= "Bug Eye") then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'bug' string.", itemID, name);
        return false;
    end
    
    if (strfind(name, "OLD") ~= nil or strfind(lname, "%(old%)") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'old' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "unused") ~= nil and name ~= "Unused Scraping Vial") then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'unused' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "dnd") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'dnd' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "pvp") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'pvp' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "random") ~= nil and name ~= "Hallowed Wand - Random") then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'random' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "%[ph%]") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'ph' string.", itemID, name);
        return false;
    end 
    
    if (strfind(name, "%%") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains '%%' string.", itemID, name);
        return false;
    end 
    
    if (strfind(lname, "level ") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'level' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "alex's") ~= nil or strfind(lname, "alex ") ~= nil) then     -- mind the space in "alex "
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'alex' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "jeff") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'jeff' string.", itemID, name);
        return false;
    end

    if (strfind(name, "AHNQIRAJ") ~= nil or strfind(lname, "qatest") ~= nil or strfind(lname, "qaenchant") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'ahnqiraj' or 'QA' string.", itemID, name);
        return false;
    end

    if (strfind(lname, "63 ") ~= nil or strfind(lname, "90 ") ~= nil or strfind(lname, "1000 ") ~= nil or strfind(lname, "1300 ") ~= nil 
        or strfind(lname, "1500 ") ~= nil or strfind(lname, "1800 ") ~= nil or strfind(lname, "2000 ") ~= nil 
        or strfind(lname, "2100 ") ~= nil or strfind(lname, "2200 ") ~= nil or strfind(lname, "2500 ") ~= nil or strfind(lname, "2600 ") ~= nil 
        or strfind(lname, "2800 ") ~= nil or strfind(lname, "2900 ") ~= nil 
        or strfind(lname, "3300 ") ~= nil or strfind(lname, "3500 ") ~= nil) then
            Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains invalid number.", itemID, name);
        return false;
    end

    return true;
end

function Data:AddScannedItem(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
        itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)
    Logger:Log("Adding item: %s", itemLink);
    local scanDB = GU.db.global.scanDB;

    self:AddItemInfo(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
        itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice);
    self:AddItemTooltip(itemID, itemLink);

    scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_SCANNED;
end

function Data:AddItemInfo(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
        itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)
    itemID = tonumber(itemID);
    local scanDB = GU.db.global.scanDB;

    scanDB.items[Locales:GetDatabaseLocaleKey()][itemID] = self:CreateItemStructure(
        itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
        itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice);
end

function Data:FindItemIDByItemName(itemName)
    local scanDB = GU.db.global.scanDB;
    local itemID = nil;
    for k,v in pairs(scanDB.items[Locales:GetDatabaseLocaleKey()]) do
        if (v.name == itemName) then
            itemID = k;
            break;
        end
    end

    return itemID;
end

-- This will only add item tooltip if current one was invalid or if new one is valid AND longer than old one.
function Data:AddItemTooltip(itemID, itemLink)
    itemID = tonumber(itemID);

    local scanDB = GU.db.global.scanDB;
    local tooltip = self:GetTooltipText(itemLink);

    if (tooltip == nil or tooltip == "invalid") then
        return nil, false;
    end

    if (not scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] or 
            string.len(tooltip) > string.len(scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID])) then
        if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] == GU_ITEM_STATUS_PARSED) then
            self:MarkItemIDAsScanned(itemID);
        end
        scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] = tooltip;
        return tooltip, true;
    end

    return tooltip, false;
end

function Data:CreateItemStructure(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
    itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)

    if (Locales:IsCurrentLocaleMainLocale()) then
        local item = {
            name = itemName,
            rarity = itemRarity,
            itemLevel = itemLevel,
            minLevel = itemMinLevel,
            type = itemType,
            subtype = itemSubtype,
            stacks = itemStackCount,
            equipLocation = itemEquipLoc,
            texture = itemTexture,
            sellPrice = itemSellPrice,
            classes = {},
            races = {},
            set = "",
            randomEnchantment = false,
            properties = {},
            equipEffects = {},
            useEffects = {},
            onHitEffects = {}
        }

        return item;
    else
        local item = {
            name = itemName,
            set = "",
            equipEffects = {},
            useEffects = {},
            onHitEffects = {}
        }

        return item;
    end
end

function Data:AddAllDeprecatedIDs()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];

    for k,v in pairs(deprecatedIDs) do
        if (statusDB[v] ~= GU_ITEM_STATUS_DEPRECATED) then
            local itemName, _, _, _, _, _, _, 
            _, _, _, _ = GetItemInfo(k);
            itemName = itemName or nil;

            self:MarkItemIDAsDeprecated(v, itemName);
        end
    end
end

----------------------------------------------------------
-- Debug purposes only

function Data:PrintDeprecatedItems()
    if (not self.depCount) then
        self.depCount = 0;
    end

    local depCountLocal = self.depCount;
    local count = 0;
    local increment = 20;
    local scanDB = GU.db.global.scanDB;
    local foundItems = false;

    local verb = Logger:IsVerboseLogEnabled();
    if (not verb) then 
        Logger:SetVerboseLogEnabled(true);
    end
    Logger:Log("Printing deprecated items (%d - %d)", depCountLocal, depCountLocal + increment);

    for k,v in pairs(scanDB.status[Locales:GetDatabaseLocaleKey()]) do
        if (v == GU_ITEM_STATUS_DEPRECATED) then
            if (count >= depCountLocal and count < depCountLocal + increment) then
                itemName = scanDB.deprecated[k];
                foundItems = true;
                if (not itemName) then
                    Logger:Display("%5d - invalid", k);
                else
                    Logger:Display("%5d - %s", k, itemName);
                    self:ValidateItem(itemName, k);
                end
            end
            count = count + 1;
        end
    end

    if (not foundItems) then
        self.depCount = 0;
    else
        self.depCount = self.depCount + increment;
    end

    Logger:SetVerboseLogEnabled(verb);
end

function Data:PrintScannedItemsWithEmptyTooltip()
    if (not self.tooltipCount) then
        self.tooltipCount = 0;
    end

    local tooltipCount = self.tooltipCount;
    local count = 0;
    local increment = 25;
    local scanDB = GU.db.global.scanDB;
    local foundItems = false;

    local verb = Logger:IsVerboseLogEnabled();
    if (not verb) then 
        Logger:SetVerboseLogEnabled(true);
    end

    Logger:Log("Printing scanned items (%d - %d)", tooltipCount, tooltipCount + increment);

    for k,v in pairs(scanDB.status[Locales:GetDatabaseLocaleKey()]) do
        if (v == GU_ITEM_STATUS_SCANNED) then
            if (count >= tooltipCount and count < tooltipCount + increment) then
                local tooltip = scanDB.tooltips[Locales:GetDatabaseLocaleKey()][k];
                if (tooltip and tooltip == "") then
                    local item = scanDB.items[Locales:GetDatabaseLocaleKey()][k];
                    Logger:Display("%5d - %s", k, Misc:GenerateFullItemLink(k, item.rarity, item.name));
                end

                foundItems = true;
            end
            count = count + 1;
        end
    end

    if (not foundItems) then
        self.tooltipCount = 0;
    else
        self.tooltipCount = self.tooltipCount + increment;
    end

    Logger:SetVerboseLogEnabled(verb);
end
