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
local MAX_ITEM_ID = 24284;                  -- 24284
local MAX_ITEM_COUNT = 15910;               -- allegedly...
local MAX_ITEM_DEPRECATED_COUNT = 1687;     -- allegedly...

-- List of unused IDs which items cannot be excluded using name patterns.
local deprecatedIDs = {
    13503, 7950, 13262, 3529, 20368, 24071, 3320, 21584, 3536, 20005, 14390, 14383, 14382, 14388, 14389, 19065, 19129,
    18951, 13843, 23072, 23162, 22230, 7948, 3542, 3538, 7951, 19971, 20502, 7949, 23058, 17108, 7953, 9443, 18303, 15141,
    15780, 18342, 18341, 3533, 3528, 16785, 17769, 17142, 13847, 13848, 13846, 13849, 6724, 6728, 6711, 6707, 6708, 6698,
    17783, 17782, 18582, 19989, 7187, 18584, 18583, 3527, 3547, 21613, 21614, 21612, 21587, 21588, 3541, 3537, 3522, 3526,
    3529, 2554, 18023, 7952, 21594, 18320, 20003, 13844, 13842, 13845, 18355, 18304, 22273, 18316, 19986, 20524, 19186
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

function Data:GetItemIDToScan()
    if (Misc:Length(self.prioIDList) > 0) then
        local prioID = table.remove(self.prioIDList);
        return prioID;
    end

    local scanDB = GU.db.global.scanDB;
    local currentID = (self.lastIDScanned + 1) % MAX_ITEM_ID;

    while (currentID ~= self.lastIDScanned) do
        if (not scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] and currentID ~= 0) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] = GU_ITEM_STATUS_PENDING;
            return currentID;
        end

        if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] == GU_ITEM_STATUS_PENDING and currentID ~= 0) then
            return currentID;
        end

        currentID = (currentID + 1) % MAX_ITEM_ID;
    end

    return nil;
end

function Data:AddPrioItemToScan(itemID, itemLink)
    if (itemID == nil and itemLink == nil) then
        return;
    end

    if (itemID == nil) then
        itemID = Misc:GetItemIDFromLink(itemLink);
    end

    if (self:WasScanned(itemID) == false and not Misc:Contains(self.prioIDList, itemID)) then
        Logger:Log("Adding prio item ID: %d", itemID);
        table.insert(self.prioIDList, itemID);
    end
end

function Data:ScanItems()
    local scanDB = GU.db.global.scanDB;
    if (not scanDB.scanEnabled) then
        return
    end
    
    local itemID = self:GetItemIDToScan();
    if (itemID ~= nil) then
        self:ScanItem(itemID);
    else
        Logger:Log("End of scan.");
        self:SetScanEnabled(false);
    end    
end

function Data:ScanItem(itemID, itemLink)
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

    self.lastIDScanned = itemID;

    local itemLinkOrID = itemID or itemLink;
    itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
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
end

function Data:FixScannedItems()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Fixing scanned items...");
    local count = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_SCANNED or v == GU_ITEM_STATUS_PARSED) then
            if (scanItemsDB[k] == nil 
                or scanItemsDB[k] ~= nil and scanItemsDB[k].name ~= nil and not Data:ValidateItem(scanItemsDB[k].name, k)) then
                Data:MarkItemIDAsDeprecated(k);
                count = count + 1;
            end
        end
    end

    Logger:Log("Fixing scanned items finished. Fixed %d items.", count);
end

function Data:FixItemTooltips()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Fixing item tooltips...");
    local count = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_SCANNED or v == GU_ITEM_STATUS_PARSED) then
            if (scanItemsDB[k] ~= nil) then
                Data:AddItemTooltip(k, Misc:GenerateFullItemLink(k, scanItemsDB[k].rarity, scanItemsDB[k].name));
                count = count + 1;
            end
        end
    end

    Logger:Log("Fixing item tooltips finished. Fixed %d tooltips.", count);
end

function Data:RestoreDeprecatedItems()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Restoring deprecated items...");
    local count = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_DEPRECATED) then
            local itemName = scanDB.deprecated[k];
            if (not itemName) then
                itemName, _, _, _, _, _, _, 
                    _, _, _, _ = GetItemInfo(k);
            end

            itemName = itemName or "test name";

            if (self:ValidateItem(itemName, k)) then
                self:RestoreDeprecatedItem(k);
                count = count + 1;
            end
        end
    end

    Logger:Log("Restoring deprecated items finished. Restored %d items.", count);
end

function Data:FixDeprecatedNames()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Fixing deprecated names...");
    local count = 0;
    local remaining = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_DEPRECATED) then
            local itemName = scanDB.deprecated[k];
            if (not itemName) then
                itemName, _, _, _, _, _, _, 
                    _, _, _, _ = GetItemInfo(k);

                scanDB.deprecated[k] = itemName;

                if (not itemName) then
                    remaining = remaining + 1;
                else
                    count = count + 1;
                end        
            end
        end
    end

    Logger:Log("Fixing deprecated names finished. Fixed %d items, remaining: %d.", count, remaining);
end

function Data:AddAllDeprecatedIDs()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];

    for k,v in pairs(deprecatedIDs) do
        if (statusDB[v] ~= GU_ITEM_STATUS_DEPRECATED) then
            itemName, _, _, _, _, _, _, 
            _, _, _, _ = GetItemInfo(k);
            itemName = itemName or nil;

            self:MarkItemIDAsDeprecated(v, itemName);
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

function Data:AddItemTooltip(itemID, itemLink)
    itemID = tonumber(itemID);
    local scanDB = GU.db.global.scanDB;

    scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID] = self:GetTooltipText(itemLink);
end

function Data:CreateItemStructure(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
    itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)

    if (Locales:IsCurrentLocaleMainLocale()) then
        local item = {
            version = GU_ADDON_VERSION,
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
            set = "",
            properties = {},
            equipBonuses = {},
            useBonuses = {},
            onHitBonuses = {}
        }

        return item;
    else
        local item = {
            version = GU_ADDON_VERSION,
            name = itemName,
            equipBonuses = {},
            useBonuses = {},
            onHitBonuses = {}
        }

        return item;
    end
end

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
                -- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
                --     itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(k);
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