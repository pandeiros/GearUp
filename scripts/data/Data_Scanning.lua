-- #TODO Copyright here

local GU = _G.GU;

local Data = GU.Data;
local Logger = GU.Logger;
local Misc = GU.Misc;
local Style = GU.Style;
local Colors = GU.Style.Colors;
-- local Async = GU.Async;
local Locales = GU.Locales;
local Frames = GU.Frames;

local L = GU_AceLocale:GetLocale("GU");

----------------------------------------------------------

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
        if (self:IsValidItemID(prioID)) then
            return prioID, nil;
        end

        Logger:Err("Data:GetItemIDToScan Invalid Item ID found: %d", prioID);
        return nil, nil;
    end

    local scanDB = GU.db.global.scanDB;
    local currentIndex = self:GetNextItemIDIndex(self.lastIndexScanned);
    local currentItemID = self:GetItemIDAtIndex(currentIndex);

    while (currentIndex ~= self.lastIndexScanned) do
        if (not scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] and currentItemID ~= 0) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] = GU_ITEM_STATUS_PENDING;
            return currentItemID, currentIndex;
        end

        if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] == GU_ITEM_STATUS_PENDING and currentItemID ~= 0) then
            return currentItemID, currentIndex;
        end

        currentIndex = self:GetNextItemIDIndex(currentIndex);
        currentItemID = self:GetItemIDAtIndex(currentIndex);
    end

    return nil, nil;
end

function Data:GetItemIDForTooltipFix()
    if (Misc:Length(self.prioTooltipIDList) > 0) then
        local prioID = table.remove(self.prioTooltipIDList);
        if (self:IsValidItemID(prioID)) then
            return prioID, nil;
        end

        Logger:Err("Data:GetItemIDForTooltipFix Invalid Item ID found: %d", prioID);
        return nil, nil;
    end

    local scanDB = GU.db.global.scanDB;
    local currentIndex = self:GetNextItemIDIndex(self.lastTooltipIndex);
    local currentItemID = self:GetItemIDAtIndex(currentIndex);

    while (currentIndex ~= self.lastTooltipIndex) do
        if (not scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] and currentItemID ~= 0) then
            scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] = GU_ITEM_STATUS_PENDING;
            return currentItemID, currentIndex;
        end

        if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentItemID] == GU_ITEM_STATUS_SCANNED and currentItemID ~= 0) then
            return currentItemID, currentIndex;
        end

        currentIndex = self:GetNextItemIDIndex(currentIndex);
        currentItemID = self:GetItemIDAtIndex(currentIndex);
    end

    return nil, nil;
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
    
    local scanItemID, scanItemIndex = self:GetItemIDToScan();
    local tooltipItemID, tooltipItemIndex = self:GetItemIDForTooltipFix();

    Logger:Verb("%d (%d),   %d (%d)", scanItemID, scanItemIndex, tooltipItemID, tooltipItemIndex);

    local scanSuccess, tooltipFixSuccess = false, false;

    if (scanItemID ~= nil) then
        scanSuccess = self:ScanItem(scanItemID, nil, scanItemIndex);
    end

    self.scanningCount = self.scanningCount + 1;

    if (self.scanningCount % 10000 == 0) then
        local pending, invalid, deprecated, scanned, parsed, remaining = self:GetScanningStatus(Locales:GetDatabaseLocaleKey());
        Logger:Verb("=== Scanned %d items. Remaining IDs to scan: %d", self.scanningCount, remaining);

        if (remaining <= 0) then
            self:SetScanEnabled(false);
        end
    end

    if (tooltipItemID ~= nil) then
        tooltipFixSuccess = self:FixItemTooltip(tooltipItemID, nil, tooltipItemIndex);
    end

    -- if (not scanSuccess and not tooltipFixSuccess) then
    --     Logger:Log("End of scan.");
    --     self:SetScanEnabled(false);
    -- end    
end

function Data:ScanItem(itemID, itemLink, itemIndex)
    itemID = tonumber(itemID);
    if (itemID == nil or tonumber(itemID) <= 0) then
        if (itemLink) then
            itemID = Misc:GetItemIDFromLink(itemLink);
        else
            return nil;
        end
    end

    if (itemIndex ~= nil and itemIndex > 0) then
        self.lastIndexScanned = itemIndex;
    end

    if (itemID == nil or itemID < 0 or Data:WasScanned(itemID)) then
        return nil;
    end

    local scanDB = GU.db.global.scanDB;

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

function Data:FixItemTooltip(itemID, itemLink, tooltipItemIndex)
    itemID = tonumber(itemID);
    if (itemID == nil or tonumber(itemID) <= 0) then
        if (itemLink) then
            itemID = Misc:GetItemIDFromLink(itemLink);
        else
            return nil;
        end
    end

    if (tooltipItemIndex ~= nil and tooltipItemIndex > 0) then
        self.lastTooltipIndex = tooltipItemIndex;
    end

    if (itemID == nil or itemID < 0) then
        return nil;
    end

    local scanDB = GU.db.global.scanDB;

    if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] and scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] == GU_ITEM_STATUS_SCANNED) then
        local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
        local tooltip, replaced = self:AddItemTooltip(itemID, Misc:GenerateFullItemLink(itemID, scanItemsDB[itemID].rarity, scanItemsDB[itemID].name));
        if (not tooltip) then
            Logger:Err("Data:FixItemTooltip Invalid tooltip found for item %s (%d)", scanItemsDB[itemID].name, itemID);
            return false;
        elseif (replaced) then
            Logger:LogChat(GU_CHAT_FRAME_SCAN, false, "Fixed item tooltip for ID: %d", itemID);            
        end
    end
end

-- Filters out invalid, deprecated, old or test items.
function Data:ValidateItem(name, itemID)
    if (type(itemID) == "number") then
        if (Misc:Contains(self:GetDeprecatedItemIDs(), itemID)) then
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

    if (strfind(lname, "temp") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'temp' string.", itemID, name);
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

    if (strfind(lname, "peep") ~= nil) then
        Logger:Verb("%5d - %s is deprecated/invalid. Reason: name contains 'peep' string.", itemID, name);
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
    Logger:LogChat(GU_CHAT_FRAME_SCAN, false, "Adding item: %s", itemLink);
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

    for k,v in pairs(self:GetDeprecatedItemIDs()) do
        if (statusDB[v] ~= GU_ITEM_STATUS_DEPRECATED) then
            local itemName, _, _, _, _, _, _, 
            _, _, _, _ = GetItemInfo(v);
            itemName = itemName or nil;

            Logger:Log("Marking item ID %s as deprecated (name: %s).", v, itemName or "<invalid>");
            self:MarkItemIDAsDeprecated(v, itemName);
        end
    end
end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function Data:PrintPendingItems()
    if (not self.printPendCount) then
        self.printPendCount = 0;
    end

    local printPendCountLocal = self.printPendCount;
    local count = 0;
    local increment = 25;
    local scanDB = GU.db.global.scanDB;
    local foundItems = false;

    Logger:Log("Printing pending items (%d - %d)", printPendCountLocal, printPendCountLocal + increment);

    for k,v in pairs(scanDB.status[Locales:GetDatabaseLocaleKey()]) do
        if (v == GU_ITEM_STATUS_PENDING) then
            if (count >= printPendCountLocal and count < printPendCountLocal + increment) then
                local item = scanDB.items[Locales:GetDatabaseLocaleKey()][k];
                if (item) then
                    Logger:Display("%5d -> %s", k, Misc:GenerateFullItemLink(k, item.rarity, item.name));
                end

                foundItems = true;
                if (not item) then
                    Logger:Display("%5d -> %s", k, Misc:GenerateSimpleItemLinkFromID(k));
                end
            end
            count = count + 1;
        end
    end

    if (not foundItems) then
        self.printPendCount = 0;
    else
        self.printPendCount = self.printPendCount + increment;
    end
end

function Data:PrintDeprecatedItems()
    if (not self.depCount) then
        self.depCount = 0;
    end

    local depCountLocal = self.depCount;
    local count = 0;
    local increment = 25;
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

function Data:PrintScannedItems()
    if (not self.printScanCount) then
        self.printScanCount = 0;
    end

    local printScanCountLocal = self.printScanCount;
    local count = 0;
    local increment = 25;
    local scanDB = GU.db.global.scanDB;
    local foundItems = false;

    Logger:Log("Printing scanned items (%d - %d)", printScanCountLocal, printScanCountLocal + increment);

    for k,v in pairs(scanDB.status[Locales:GetDatabaseLocaleKey()]) do
        if (v == GU_ITEM_STATUS_SCANNED) then
            if (count >= printScanCountLocal and count < printScanCountLocal + increment) then
                local item = scanDB.items[Locales:GetDatabaseLocaleKey()][k];
                if (item) then
                    Logger:Display("%5d -> %s", k, Misc:GenerateFullItemLink(k, item.rarity, item.name));
                end

                foundItems = true;
                if (not item) then
                    Logger:Display("%5d - invalid", k);
                end
            end
            count = count + 1;
        end
    end

    if (not foundItems) then
        self.printScanCount = 0;
    else
        self.printScanCount = self.printScanCount + increment;
    end
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
