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

-- Clears all entries from database that are outside of scanning range.
function Data:RemoveOutOfRangeEntries()
    local scanDB = GU.db.global.scanDB;
    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
    local tooltipsDB = scanDB.tooltips[Locales:GetDatabaseLocaleKey()];
    local deprecatedDB = scanDB.deprecated;

    Logger:Log("Removing entries out of scanning range...");
    
    self:RemoveOutOfRangeEntries_Internal(scanItemsDB, "scanItemsDB");
    self:RemoveOutOfRangeEntries_Internal(statusDB, "statusDB");
    self:RemoveOutOfRangeEntries_Internal(tooltipsDB, "tooltipsDB");
    self:RemoveOutOfRangeEntries_Internal(deprecatedDB, "deprecatedDB");

    Logger:Log("Removing entries finished.");    
end

function Data:RemoveOutOfRangeEntries_Internal(database, contextStr)
    if (database == nil) then
        return;
    end

    local scanDB = GU.db.global.scanDB;

    local statusDB = scanDB.status[Locales:GetDatabaseLocaleKey()];
    local scanItemsDB = scanDB.items[Locales:GetDatabaseLocaleKey()];
    local tooltipsDB = scanDB.tooltips[Locales:GetDatabaseLocaleKey()];
    local deprecatedDB = scanDB.deprecated;

    local count = 0;

    for k,v in pairs(database) do
        if (self:GetNextItemIDToScan(k - 1) ~= k) then
            scanItemsDB[k] = nil;
            statusDB[k] = nil;
            tooltipsDB[k] = nil;
            deprecatedDB[k] = nil;

            count = count + 1;
        end
    end

    Logger:Log("Removed %d out of range entries from %s.", count, contextStr);   
end