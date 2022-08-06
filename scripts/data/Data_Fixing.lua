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

function Data:FixItems()
    if (not self.fixingItems) then
        return;
    end

    self:RemoveInvalidIDs_DoTasks();
end

-- Iterate through all scanDB entries and remove invalid IDs.
-- Valid IDs are contained in ALL_ITEM_IDS.
function Data:RemoveInvalidIDs()
    local scanDB = GU.db.global.scanDB;
    
    self.fixingItems = true;

    self.idsToCheck = {
        ["statusDB"] = {
            currentID = -1,
            maxID = 0,
            count = 0,
            scanned = 0
        },
        ["scanItemsDB"] = {
            currentID = -1,
            maxID = 0,
            count = 0,
            scanned = 0
        },
        ["tooltipsDB"] = {
            currentID = -1,
            maxID = 0,
            count = 0,
            scanned = 0
        },
        ["deprecatedDB"] = {
            currentID = -1,
            maxID = 0,
            count = 0,
            scanned = 0
        },
    }

    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
    local tooltipsDB = scanDB.tooltips[Locales:GetDatabaseLocaleKey()];
    local deprecatedDB = scanDB.deprecated;

    Logger:Log("Removing invalid IDs from scanning database...");

    self:RemoveInvalidIDs_Prepare(statusDB, "statusDB");
    self:RemoveInvalidIDs_Prepare(scanItemsDB, "scanItemsDB");
    self:RemoveInvalidIDs_Prepare(tooltipsDB, "tooltipsDB");
    self:RemoveInvalidIDs_Prepare(deprecatedDB, "deprecatedDB");
end

function Data:RemoveInvalidIDs_Prepare(database, name)
    if (database == nil) then
        self.idsToCheck[name] = nil;
        return;
    end

    for k,v in pairs(database) do
        if (k > self.idsToCheck[name].maxID) then
            self.idsToCheck[name].maxID = k;
        end
    end

    Logger:Log("RemoveInvalidIDs_Prepare Max ID for %s: %d", name, self.idsToCheck[name].maxID);   
end

function Data:RemoveInvalidIDs_DoTasks()
    local scanDB = GU.db.global.scanDB;

    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
    local tooltipsDB = scanDB.tooltips[Locales:GetDatabaseLocaleKey()];
    local deprecatedDB = scanDB.deprecated;

    local result = nil;
    local singleResult = nil;

    singleResult = self:RemoveInvalidIDs_Internal(statusDB, "statusDB");
    if (not singleResult and self.idsToCheck["statusDB"]) then
        Logger:Log("Removed %d invalid IDs from %s.", self.idsToCheck["statusDB"].count, "statusDB");   
        self.idsToCheck["statusDB"] = nil;   
    end
    result = result or singleResult;

    singleResult = self:RemoveInvalidIDs_Internal(scanItemsDB, "scanItemsDB");
    if (not singleResult and self.idsToCheck["scanItemsDB"]) then
        Logger:Log("Removed %d invalid IDs from %s.", self.idsToCheck["scanItemsDB"].count, "scanItemsDB");   
        self.idsToCheck["scanItemsDB"] = nil;   
    end
    result = result or singleResult;

    singleResult = self:RemoveInvalidIDs_Internal(tooltipsDB, "tooltipsDB");
    if (not singleResult and self.idsToCheck["tooltipsDB"]) then
        Logger:Log("Removed %d invalid IDs from %s.", self.idsToCheck["tooltipsDB"].count, "tooltipsDB");   
        self.idsToCheck["tooltipsDB"] = nil;   
    end
    result = result or singleResult;

    singleResult = self:RemoveInvalidIDs_Internal(deprecatedDB, "deprecatedDB");
    if (not singleResult and self.idsToCheck["deprecatedDB"]) then
        Logger:Log("Removed %d invalid IDs from %s.", self.idsToCheck["deprecatedDB"].count, "deprecatedDB");   
        self.idsToCheck["deprecatedDB"] = nil;
    end
    result = result or singleResult;

    if (not result) then
        Logger:Log("Removing invalid IDs finished.");    
        self.fixingItems = false;
        self.idsToCheck = nil;
    end
end

function Data:RemoveInvalidIDs_Internal(database, name)
    if (database == nil or not self.idsToCheck[name]) then
        return nil;
    end

    local currentID = self.idsToCheck[name].currentID;
    while (database[currentID] == nil and currentID < self.idsToCheck[name].maxID) do
        currentID = currentID + 1;
    end

    self.idsToCheck[name].scanned = self.idsToCheck[name].scanned + 1;

    if (self.idsToCheck[name].scanned % 1000 == 0) then
        Logger:Log("Data:RemoveInvalidIDs_Internal Scanned %d IDs for %s.", self.idsToCheck[name].scanned, name);
    end

    if (not self:IsValidItemID(currentID)) then
        database[currentID] = nil;
        self.idsToCheck[name].count = self.idsToCheck[name].count + 1;
    end

    currentID = currentID + 1;
    self.idsToCheck[name].currentID = currentID;

    if (currentID >= self.idsToCheck[name].maxID) then
        return nil
    end

    return currentID;
end

-- Iterate through scanned and parsed items to find ones that should be marked as deprecated.
function Data:ValidateScannedItems()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Validating scanned and parsed items...");
    local count = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_SCANNED or v == GU_ITEM_STATUS_PARSED) then
            if (scanItemsDB[k] == nil 
                or scanItemsDB[k] ~= nil and scanItemsDB[k].name ~= nil and not Data:ValidateItem(scanItemsDB[k].name, k)) then
                self:MarkItemIDAsDeprecated(k, scanItemsDB[k].name);
                count = count + 1;
            end
        end
    end

    Logger:Log("Validating items finished. Fixed %d items.", count);
end

-- Iterate through scanned and parsed items and check if some tooltips need fixing.
function Data:CheckItemTooltips()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Checking item tooltips...");
    local count = 0;

    for k,v in pairs(statusDB) do
        if (v == GU_ITEM_STATUS_SCANNED or v == GU_ITEM_STATUS_PARSED) then
            if (scanItemsDB[k] ~= nil) then
                local tooltip, replaced = self:AddItemTooltip(k, Misc:GenerateFullItemLink(k, scanItemsDB[k].rarity, scanItemsDB[k].name));
                if (tooltip ~= nil and replaced) then
                    count = count + 1;
                end
            end
        end
    end

    Logger:Log("Checking item tooltips finished. Fixed %d tooltips.", count);
end

-- Iterate through deprecated items and if one's name passed validation, mark it as pending for future scan.
function Data:RevalidateDeprecatedItems()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];

    Logger:Log("Revalidating deprecated items...");
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
                self:MarkItemIDAsPending(k);
                count = count + 1;
            end
        end
    end

    Logger:Log("Revalidating deprecated items finished. Restored %d items.", count);
end

-- Iterate through deprecated items and try to fix their names.
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