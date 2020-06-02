-- #TODO Copyright here

local Arma = _G.Arma;

local Data = Arma.Data;
local Style = Arma.Style;
local Logger = Arma.Logger;

-- Database defaults
ARMA_DB_DEFAULT_PROFILE_NAME = "Default";
ARMA_DB_DEFAULTS = {
    profile = {
        style = Style:GetDefaultStyle(),
    },

    char = {
        enabled = true,
        loginCount = 0,
    }
}

local MAX_ITEM_ID = 25000;

function Data:ScanItems()
    Logger:Print("Scanning...");

    -- Reset item database.
    Arma.db.global.itemDB = {};
    Arma.db.global.unscannedItems = {};
    Arma.db.global.validItems = 0;
    Arma.db.global.deprecatedItems = 0;
    Arma.db.global.invalidIDs = 0;          -- IF invalidIDS > 0, we need to rescan again.

    local totalItems = 0;
    -- Iterate over all items and add only valid ones.
    for itemID=873,873 do
        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, 
            itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);

        if (itemName ~= nil) then
            if (not self:ValidateItem(itemName)) then
                Arma.db.global.deprecatedItems = Arma.db.global.deprecatedItems + 1;
            else
                Arma.db.global.validItems = Arma.db.global.validItems + 1;
                self:AddItem(itemID, itemName, itemLink, itemRarity, itemType, itemSubType);
            end
        else
            Arma.db.global.invalidIDs = Arma.db.global.invalidIDs + 1;
        end
    end

    Logger:Printf("- Found %d items", Arma.db.global.validItems);
    Logger:Printf("- Found %d deprecated/old/test items", Arma.db.global.deprecatedItems);
    Logger:Printf("- Found %d invalid IDs", Arma.db.global.invalidIDs);
end

-- -- Construct your saarch pattern based on the existing global string:
-- local S_UPGRADE_LEVEL   = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")

-- Create the tooltip:
local scantip = CreateFrame("GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

-- Create a function for simplicity's sake:
local function GetTooltipText(link)
    -- Pass the item link to the tooltip:
    scantip:SetHyperlink(link)

    local tooltipText = "";
    -- Scan the tooltip:
    for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
        local left = _G["MyScanningTooltipTextLeft"..i]:GetText()
        local right = _G["MyScanningTooltipTextRight"..i]:GetText()
        if left and left ~= "" then
            tooltipText = tooltipText .. left;
        end

        if right and right ~= "" then
            tooltipText = tooltipText .. " " .. right .. "\n";
        else
            tooltipText = tooltipText .. "\n";
        end
    end

    return tooltipText;
end

function Data:AddItem(id, name, link, rarity, type, subtype)
    Logger:Print(link .. " - " .. type);
    local text = GetTooltipText(link)
    Logger:Print(text);
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
    
    if (strfind(lname, "old") == 1) then
        return false;
    end

    return true;
end

function Data:ProcessItemName(id, name)
end

function Data:ProcessItemRarity(id, rarity)
end

function Data:ProcessItemType(id, type)
end

function Data:ProcessItemSubtype(id, subtype)
end