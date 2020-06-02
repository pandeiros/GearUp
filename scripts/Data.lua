-- #TODO Copyright here

local Arma = _G.Arma;

local Data = Arma.Data;
local Style = Arma.Style;
local Logger = Arma.Logger;
local Misc = Arma.Misc;

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
    self:ResetItemDatabase();
    local itemDB = Arma.db.global.itemDB;

    local totalItems = 0;
    local testItemIDs = {873, 16797, 19721, 13952, 19348}
    -- Iterate over all items and add only valid ones.
    -- for itemID=1,MAX_ITEM_ID do
    for i = 1, #testItemIDs do
        local itemID = testItemIDs[i];
        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
            itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);

        if (itemName ~= nil) then
            if (not self:ValidateItem(itemName)) then
                itemDB.deprecatedItems = itemDB.deprecatedItems + 1;
            else
                itemDB.validItems = itemDB.validItems + 1;
                self:AddItem(itemID, itemName, itemLink, itemRarity, itemType, itemSubtype);
            end
        else
            itemDB.invalidIDs = itemDB.invalidIDs + 1;
        end
    end

    Logger:Printf("- Found %d items", itemDB.validItems);
    Logger:Printf("- Found %d deprecated/old/test items", itemDB.deprecatedItems);
    Logger:Printf("- Found %d invalid IDs", itemDB.invalidIDs);

    Data:PrintDatabase();
end

function Data:ResetItemDatabase()
    Arma.db.global.itemDB = {};

    local itemDB = Arma.db.global.itemDB;

    itemDB.idMap = {};
    itemDB.nameMap = {};
    itemDB.rarityMap = {};
    itemDB.typeMap = {};
    itemDB.subtypeMap = {};
    itemDB.propertiesMap = {};

    itemDB.unscannedItems = {};
    itemDB.validItems = 0;
    itemDB.deprecatedItems = 0;
    itemDB.invalidIDs = 0;          -- If invalidIDS > 0, we need to rescan them once again, just to be sure.
end

-- Create the tooltip for parsing.
local ParsingTooltip = CreateFrame("GameTooltip", "ArmaParsingTooltip", nil, "GameTooltipTemplate")
ParsingTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Data:GetTooltipText(link)
    -- Pass the item link to the tooltip.
    ParsingTooltip:SetHyperlink(link)

    -- Scan the tooltip:
    local tooltipText = "";
    for i = 2, ParsingTooltip:NumLines() do -- Line 1 is always the name so you can skip it.
        local left = _G["ArmaParsingTooltipTextLeft"..i]:GetText()
        local right = _G["ArmaParsingTooltipTextRight"..i]:GetText()
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

function Data:AddItem(id, itemName, itemLink, itemRarity, itemType, itemSubtype)
    Logger:Print(itemLink);

    -- Map id to link
    Arma.db.global.itemDB.idMap[id] = itemLink;

    local tooltipText = self:GetTooltipText(itemLink);

    self:ProcessItemName(id, itemName);
    self:ProcessItemRarity(id, itemRarity);
    self:ProcessItemType(id, itemType);
    self:ProcessItemSubtype(id, itemSubtype);
    self:ParseItemTooltip(id, itemType, itemSubtype, tooltipText);
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

function Data:ProcessItemName(id, itemName)
    local itemDB = Arma.db.global.itemDB;

    words = {};
    for w in itemName:gmatch("%S+") do table.insert(words, w) end

    for i = 1, #words do
        if (not itemDB.nameMap[words[i]]) then
            itemDB.nameMap[words[i]] = {};
        end

        table.insert(itemDB.nameMap[words[i]], id);
    end
end

function Data:ProcessItemRarity(id, itemRarity)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.rarityMap[Misc:GetRarityName(itemRarity)]) then
        itemDB.rarityMap[Misc:GetRarityName(itemRarity)] = {};
    end

    table.insert(itemDB.rarityMap[Misc:GetRarityName(itemRarity)], id);
end

function Data:ProcessItemType(id, itemType)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.typeMap[itemType]) then
        itemDB.typeMap[itemType] = {};
    end

    table.insert(itemDB.typeMap[itemType], id);
end

function Data:ProcessItemSubtype(id, itemSubtype)
    local itemDB = Arma.db.global.itemDB;

    if (not itemDB.subtypeMap[itemSubtype]) then
        itemDB.subtypeMap[itemSubtype] = {};
    end

    table.insert(itemDB.subtypeMap[itemSubtype], id);
end

function Data:ParseItemTooltip(id, itemType, itemSubtype, tooltipText)
    -- Split the text into lines.
    lines = {}
    for s in tooltipText:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    for i = 1, #lines do
        self:ParseItemTooltipLine(id, itemType, itemSubtype, lines[i]);
    end
end

function Data:ParseItemTooltipLine(id, itemType, itemSubtype, tooltipLine)
    if (tooltipLine:find("Soulbound") or tooltipLine:find("Soulbound") or tooltipLine:find("Soulbound")) then
        -- do nothing...
    elseif (tooltipLine:find("Unique")) then
        -- do nothing...
    else
        if (itemType == "Weapon") then
            -- Basic weapon damage values and optional type. Example: 57 - 105 (Arcane) Damage
            -- Condition to distinguish from extra damage
            if (tooltipLine:find("%+") == nil) then
                local minDamage, maxDamage, damageType = tooltipLine:match("(%d+)%s%-%s(%d+)%s*(%a*)%sDamage");
                if (minDamage and maxDamage) then
                    Logger:Print("Min DMG: " .. minDamage);
                    Logger:Print("Max DMG: " .. maxDamage);
                end
                if (damageType) then
                    if (damageType == "") then
                        damageType = "Physical";
                    end    
                    Logger:Print("Damage type: " .. damageType);
                end
            end

            -- Weapon speed. Example: Speed 2.40
            local weaponSpeed = tooltipLine:match("Speed%s(%d+%.%d+)");
            if (weaponSpeed) then
                Logger:Print("Speed: " .. weaponSpeed);
                return;
            end

            -- Extra elemental damage. Example: + 1 - 5 Frost Damage
            local extraMinDamage, extraMaxDamage, extraDamageType = tooltipLine:match("%+%s(%d+)%s%-%s(%d+)%s*(%a*)%sDamage");
            if (extraMinDamage and extraMaxDamage) then
                Logger:Print("Extra min DMG: " .. extraMinDamage);
                Logger:Print("Extra max DMG: " .. extraMaxDamage);
            end
            if (extraDamageType and extraDamageType ~= "") then
                Logger:Print("Extra damage type: " .. extraDamageType);
            end

            -- Damage per second. Example (42.2 damage per second)
            local weaponDPS = tooltipLine:match("(%d+%.%d)%sdamage per second");
            if (weaponDPS) then
                Logger:Print("DPS: " .. weaponDPS);
            end

        elseif (itemType == "Armor") then
            -- Armor value: Example: 2345 Armor
            local armor = tooltipLine:match("(%d+) Armor");
            if (armor) then
                Logger:Print("Armor: " .. armor);
            end

            if (itemSubtype == "Shields") then
                -- Block value. Example: 39 Block
                local block = tooltipLine:match("(%d+) Block");
                if (block) then
                    Logger:Print("Block: " .. block);
                end    
            end

        elseif (itemType == "Projectile") then
        else
        end

        -- Attributes. Example: +8 Stamina | +16 Intellect
        local attributeBonus, attributeName, resistance = tooltipLine:match("%+(%d+)%s(%a+)%s*(%a*)");
        if (attributeBonus and attributeName) then
            if (resistance and resistance ~= "") then
                Logger:Print(attributeName .. " " .. resistance .. " " .. attributeBonus);
            else
                Logger:Print(attributeName .. " " .. attributeBonus);
            end
        end

        -- Level requirement. Example: Requires Level 55
        local levelReq = tooltipLine:match("Requires Level (%d+)");
        if (levelReq) then
            Logger:Print("Min level: " .. levelReq);
        end

        -- Eligible classes. Example: Classes: Mage | Classes: Mage, Warlock
        if (tooltipLine:find("Classes: .+")) then
            tooltipLine = tooltipLine:gsub(",", "");
            tooltipLine = tooltipLine:gsub("Classes: ", "");
            
            local classes = {};
            tooltipLine:gsub("(%a+)", function (w)
                table.insert(classes, w)
            end)

            for i = 1, #classes do
                Logger:Print("Eligible class: " .. classes[i]);
            end
        end

        -- Equip, Chance on hit and Use bonuses. Examples:
        -- Equip: Increases damage and healing done by magical spells and effects by up to 29
        -- Chance on hit: Delivers a fatal wound for 240 damage
        -- Use: Restores 375 to 625 mana. (5 Mins Cooldown)
        local equipBonus = tooltipLine:match("Equip: (.+)");
        if (equipBonus) then
            Logger:Print("Equip: " .. equipBonus);
        end
        local chanceOnHitBonus = tooltipLine:match("Chance on hit: (.+)");
        if (chanceOnHitBonus) then
            Logger:Print("Chance on hit: " .. chanceOnHitBonus);
        end
        local useBonus = tooltipLine:match("Use: (.+)");
        if (useBonus) then
            Logger:Print("Use: " .. useBonus);
        end
    end
end

-- Debug purposes only.
function Data:PrintDatabase()
    local itemDB = Arma.db.global.itemDB;

    for k,v in pairs(itemDB.nameMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.rarityMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.typeMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
    for k,v in pairs(itemDB.subtypeMap) do
        for i = 1, #v do
            Logger:Print(k .. " -> " .. v[i]);
        end
    end
end