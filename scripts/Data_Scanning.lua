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
local MAX_ITEM_ID = 24283;
local MAX_ITEM_COUNT = 15906;

function Data:GetMaxItemCount()
    return MAX_ITEM_COUNT;
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

    local remaining = self:GetMaxItemCount() - deprecated - scanned;
    
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
    if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] ~= nil and scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] ~= GU_ITEM_STATUS_PENDING) then
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

    if (self:WasScanned(itemID) == false) then
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

    local itemLinkOrID = itemID or itemLink;
    itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
        itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLinkOrID);

    if (itemName == nil) then
        scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_PENDING;
    else
        if (not Data:ValidateItem(itemName)) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_DEPRECATED;
        else
            self:AddItemTooltip(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
            itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice);
        end
    end
end

-- Filters out invalid, deprecated, old or test items.
function Data:ValidateItem(name)
    if (not name) then
        return false;
    end

    local lname = strlower(name);
    if (strfind(lname, "deprecated") ~= nil or strfind(lname, "deptecated") ~= nil) then
        return false;
    end

    if (strfind(lname, "test") ~= nil) then
        return false;
    end
    
    if (strfind(name, "OLD") ~= nil or strfind(lname, "(old)") ~= nil) then
        return false;
    end

    return true;
end

function Data:AddItemTooltip(itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
    itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice)
    itemID = tonumber(itemID);
    Logger:Log("Adding item: %s", itemLink);

    local scanDB = GU.db.global.scanDB;

    scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] = GU_ITEM_STATUS_SCANNED;
    scanDB.items[Locales:GetDatabaseLocaleKey()][itemID] = self:CreateItemStructure(
        itemID, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, 
        itemType, itemSubtype, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice);
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