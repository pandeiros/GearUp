-- #TODO Copyright here

local Arma = _G.Arma;

local Data = Arma.Data;
local Logger = Arma.Logger;
local Misc = Arma.Misc;
local Style = Arma.Style;
local Colors = Arma.Style.Colors;
local Async = Arma.Async;

-- Data taken from classic.wowhead.com
local MAX_ITEM_ID = 24283;
local MAX_ITEM_COUNT = 15906;

local Data_ProcessItemID = Async:Async(function(itemID)
    -- itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
    --         itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);
    -- Data:AddItem(itemID, itemName, itemLink, itemRarity, itemType, itemSubtype);
    
    local itemDB = Arma.db.global.itemDB;
    -- itemDB.processedIDs = itemDB.processedIDs + 1;
    -- if (itemDB.processedIDs % 1000 == 0) then
    --     print("Processed: ", itemDB.processedIDs);
    -- end
    -- Logger:Verb("Processed ID %d", itemID);
end)

local Data_ReceiveIDToParse = Async:Async(function(ids)
    for i = 1, #ids do
        if i % 2 == 1 then
            Async:Await(Data_ProcessItemID, ids[i]);
        else
            Async:Await(Data_ProcessItemID(ids[i]));
        end
    end
end)

local Data_GenerateItemIDs = Async:Async(function(startingID, endingID)
    local ids = {};
    local itemDB = Arma.db.global.itemDB;
    local testItemIDs = {873, 16797, 19721, 13952, 19348, 21603}

    -- Iterate from startingID to endingID and add only valid ones.
    for i = startingID, endingID do
        local itemID = i;

        -- table.insert(ids, itemID);

        itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
            itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);

        if (itemName ~= nil) then
            if (not Data:ValidateItem(itemName)) then
                itemDB.deprecatedIDs[itemID] = true;
            else
                table.insert(ids, itemID);
            end
        else
            itemDB.invalidIDs[itemID] = true;
        end
    end

    -- -- Iterate over all items and add only valid ones.
    -- for itemID=1,MAX_ITEM_ID do
    -- -- for i = 1, #testItemIDs do
    --     -- local itemID = testItemIDs[i];
    --     itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
    --         itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemID);

    --     if (itemName ~= nil) then
    --         if (not Data:ValidateItem(itemName)) then
    --             itemDB.deprecatedIDs = itemDB.deprecatedIDs + 1;
    --         else
    --             itemDB.validItems = itemDB.validItems + 1;
    --             -- ids[i] = itemID;
    --             table.insert(ids, itemID);
    --         end
    --     else
    --         itemDB.invalidIDs = itemDB.invalidIDs + 1;
    --     end
    -- end

    return ids;
end)

function Data:Initialize()
    self.lastIDScanned = 1;
end

function Data:DatabaseReset()
    -- Reset item database.
    self.lastIDScanned = 1;
    self:ResetItemDatabase();
end

function Data:SetScanEnabled(scanEnabled)
    local itemDB = Arma.db.global.itemDB;
    itemDB.scanEnabled = scanEnabled;
end

function Data.IsScanEnabled()
    local itemDB = Arma.db.global.itemDB;
    return itemDB.scanEnabled;
end

function Data:GetItemIDToScan()
    local itemDB = Arma.db.global.itemDB;

    if (Length(itemDB.idMap) + Length(itemDB.deprecatedIDs) == MAX_ITEM_COUNT) then
        return false, 0;
    end

    self.lastIDScanned = (self.lastIDScanned + 1) % MAX_ITEM_ID;

    while (Data:WasScanned(self.lastIDScanned)) do
        self.lastIDScanned = (self.lastIDScanned + 1) % MAX_ITEM_ID;
    end

    return true, self.lastIDScanned;
end

function Data:ScanItems()
    local itemDB = Arma.db.global.itemDB;
    if (not itemDB.scanEnabled) then
        return
    end
    
    local result, itemID = self:GetItemIDToScan();
    if (result) then
        self:ScanItem(itemID);
    else
        Logger:Print("End of scan.");
        self:SetScanEnabled(false);
    end    
end

function Data:ScanItem(itemID, itemLink)
    if (itemID == nil or tonumber(itemID) <= 0) then
        return;
    end

    if (Data:WasScanned(itemID)) then
        return;
    end

    local itemDB = Arma.db.global.itemDB;

    local itemLinkOrID = itemID or itemLink;
    itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubtype, 
        itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLinkOrID);

    if (itemName ~= nil) then
        if (not Data:ValidateItem(itemName)) then
            itemDB.deprecatedIDs[itemID] = true;
        else
            self:AddItem(itemID, itemName, itemLink, itemRarity, itemType, itemSubtype);
        end
    else
        if (not itemDB.invalidIDs[itemID]) then
            itemDB.invalidIDs[itemID] = true;
        end
    end
end

function Data:PrintDatabaseStats()
    local itemDB = Arma.db.global.itemDB;

    Logger:Printf("- Found %d valid items", Length(itemDB.idMap));
    Logger:Printf("- Found %d deprecated/old/test items", Length(itemDB.deprecatedIDs));
    Logger:Printf("- Found %d invalid item IDs", Length(itemDB.invalidIDs));
    Logger:Printf("- Unparsed IDs remaining: %d",  MAX_ITEM_COUNT - Length(itemDB.idMap) - Length(itemDB.deprecatedIDs));
end

function Data:RescanAllItems(shouldReset)
    Logger:Print("Scanning...");
    local testItemIDs = {873, 16797, 19721, 13952, 19348, 21603}
    -- for i = 1, #testItemIDs do
        -- local itemID = testItemIDs[i];
    -- end
end

function Data:WasScanned(itemID)
    local itemDB = Arma.db.global.itemDB;
    if (itemDB.idMap[itemID] ~= nil or itemDB.deprecatedIDs[itemID] ~= nil) then
        return true;
    end

    return false;
end

function Data:ResetItemDatabase()
    Arma.db.global.itemDB = {};

    local itemDB = Arma.db.global.itemDB;

    itemDB.scanEnabled = false;

    itemDB.idMap = {};              -- maps item ID to item link

    itemDB.nameMap = {};            -- maps words in item name to item IDs
    itemDB.rarityMap = {};          -- maps item rarity to item IDs
    itemDB.typeMap = {};            -- maps item type to item IDs
    itemDB.subtypeMap = {};         -- maps item subtype to item IDs
    itemDB.classMap = {};           -- maps eligible class to item IDs or to "all" if there's no requirement
    itemDB.propertyMap = {};        -- maps item ID to parsed list of properties this item has

    itemDB.deprecatedIDs = {};
    itemDB.invalidIDs = {};   
end

function Data:RemoveID(itemID)
    local itemDB = Arma.db.global.itemDB;

    if (itemDB.idMap[itemID] ~= nil) then
        itemDB.idMap[itemID] = nil;
    elseif (itemDB.deprecatedIDs[itemID] ~= nil) then
        itemDB.deprecatedIDs[itemID] = nil;
    elseif (itemDB.invalidIDs[itemID] ~= nil) then
        itemDB.invalidIDs[itemID] = nil;
    end
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
    Logger:Display("Adding item: %s", itemLink);

    local itemDB = Arma.db.global.itemDB;

    -- Map id to link
    itemDB.idMap[id] = itemLink;

    if (itemDB.invalidIDs[id] == true) then
        itemDB.invalidIDs[id] = nil;
    end

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
    
    if (strfind(name, "OLD") ~= nil or strfind(lname, "(old)") ~= nil) then
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

    -- Create new property entry for this item.
    local itemDB = Arma.db.global.itemDB;
    if (not itemDB.propertyMap[id]) then
        itemDB.propertyMap[id] = {};
    end

    for i = 1, #lines do
        self:ParseItemTooltipLine(id, itemType, itemSubtype, lines[i]);
    end
end

function Data:ParseItemTooltipLine(id, itemType, itemSubtype, tooltipLine)
    local itemDB = Arma.db.global.itemDB;

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
                    self:AddItemProperty(id, PROPERTY_DAMAGE_MIN, minDamage);
                    self:AddItemProperty(id, PROPERTY_DAMAGE_MAX, maxDamage);
                end
                if (damageType) then
                    if (damageType == "") then
                        damageType = DAMAGE_TYPE_PHYSICAL;
                    end
                    self:AddItemProperty(id, PROPERTY_DAMAGE_TYPE, damageType);
                end
            end

            -- Weapon speed. Example: Speed 2.40
            local weaponSpeed = tooltipLine:match("Speed%s(%d+%.%d+)");
            if (weaponSpeed) then
                self:AddItemProperty(id, PROPERTY_DAMAGE_SPEED, weaponSpeed);
                return;
            end

            -- Extra elemental damage. Example: + 1 - 5 Frost Damage
            local extraMinDamage, extraMaxDamage, extraDamageType = tooltipLine:match("%+%s(%d+)%s%-%s(%d+)%s*(%a*)%sDamage");
            if (extraMinDamage and extraMaxDamage) then
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_MIN, extraMinDamage);
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_MAX, extraMaxDamage);
            end
            if (extraDamageType and extraDamageType ~= "") then
                self:AddItemProperty(id, PROPERTY_EXTRA_DAMAGE_TYPE, extraDamageType);
            end

            -- Damage per second. Example (42.2 damage per second)
            local weaponDPS = tooltipLine:match("(%d+%.%d)%sdamage per second");
            if (weaponDPS) then
                self:AddItemProperty(id, PROPERTY_DPS, weaponDPS);
            end

        elseif (itemType == "Armor") then
            -- Armor value: Example: 2345 Armor
            local armor = tooltipLine:match("(%d+) Armor");
            if (armor) then
                self:AddItemProperty(id, PROPERTY_ARMOR, armor);
            end

            if (itemSubtype == "Shields") then
                -- Block value. Example: 39 Block
                local block = tooltipLine:match("(%d+) Block");
                if (block) then
                    self:AddItemProperty(id, PROPERTY_BLOCK, block);
                end    
            end

        elseif (itemType == "Projectile") then
        else
        end

        -- Attributes. Example: +8 Stamina | +16 Intellect
        local attributeBonus, attributeName, resistance = tooltipLine:match("%+(%d+)%s(%a+)%s*(%a*)");
        if (attributeBonus and attributeName) then
            if (resistance and resistance ~= "") then
                local resistanceNameAndType = attributeName .. " " .. resistance;
                self:AddItemProperty(id, resistanceNameAndType, attributeBonus);
            else
                self:AddItemProperty(id, attributeName, attributeBonus);
            end
        end

        -- Level requirement. Example: Requires Level 55
        local levelReq = tooltipLine:match("Requires Level (%d+)");
        if (levelReq) then
            self:AddItemProperty(id, PROPERTY_LEVEL_REQUIRED, levelReq);
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
                if (not itemDB.classMap[classes[i]]) then
                    itemDB.classMap[classes[i]] = {};
                end
            
                table.insert(itemDB.classMap[classes[i]], id);
            end
        end

        -- Equip, Chance on hit and Use bonuses. Examples:
        -- Equip: Increases damage and healing done by magical spells and effects by up to 29
        -- Chance on hit: Delivers a fatal wound for 240 damage
        -- Use: Restores 375 to 625 mana. (5 Mins Cooldown)
        local equipBonus = tooltipLine:match("Equip: (.+)");
        if (equipBonus) then
            -- Logger:Print("Equip: " .. equipBonus);
            self:ProcessItemTooltipLineEquip(id, tooltipLine);
        end
        local chanceOnHitBonus = tooltipLine:match("Chance on hit: (.+)");
        if (chanceOnHitBonus) then
            -- Logger:Print("Chance on hit: " .. chanceOnHitBonus);
        end
        local useBonus = tooltipLine:match("Use: (.+)");
        if (useBonus) then
            -- Logger:Print("Use: " .. useBonus);
        end
    end
end

function Data:ProcessItemTooltipLineEquip(id, tooltipLine)
    -- Spell power. Example: Increases damage and healing done by magical spells and effects by up to 29
    local spellPower = tooltipLine:match("Increases damage and healing done by magical spells and effects by up to (%d+)");
end

-- These two will not be used right now.
function Data:ProcessItemTooltipLineChanceOnHit(id, tooltipLine)
end
function Data:ProcessItemTooltipLineUse(id, tooltipLine)
end

function Data:AddItemProperty(id, propertyKey, propertyValue)
    local itemDB = Arma.db.global.itemDB;
    itemDB.propertyMap[id][propertyKey] = propertyValue;
    -- Logger:Verb("[" .. id .. "] - " .. propertyKey .. ": " .. propertyValue);
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
    for k,v in pairs(itemDB.propertyMap) do
        Logger:Print(k);
        for k1,v1 in pairs(v) do
            Logger:Print(k1 .. " -> " .. v1);
        end
    end
end

function Data:PrintAllItemLinks()
    local itemDB = Arma.db.global.itemDB;

    Logger:Display("|cffff00ff|Hitem:19019:911:::::1741::60:::::::|h[Thunderfury, Blessed Blade of the Windseeker]|h|r");
    -- |cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r
    -- for k,v in pairs(itemDB.idMap) do
    --     local s = string.sub(v, 1, 10) .. string.sub(v, 13, -1);
    --     Logger:Display("%d -> %s", k, s);
    -- end
end