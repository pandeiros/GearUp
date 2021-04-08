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

function Data:SetParseEnabled(parseEnabled)
    Logger:Log("%s %s.", "Item parse", Misc:IFTE(parseEnabled, "enabled", "disabled"));
    local scanDB = GU.db.global.scanDB;
    scanDB.parseEnabled = parseEnabled;
end

function Data:IsParseEnabled()
    local scanDB = GU.db.global.scanDB;
    return scanDB.parseEnabled;
end

function Data:WasParsed(itemID)
    local scanDB = GU.db.global.scanDB;
    if (scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] ~= nil and scanDB.status[Locales:GetDatabaseLocaleKey()][itemID] == GU_ITEM_STATUS_PARSED) then
        return true;
    end

    return false;
end

-- Create the tooltip for parsing.
local ParsingTooltip = CreateFrame("GameTooltip", "GUParsingTooltip", nil, "GameTooltipTemplate")
ParsingTooltip:SetOwner(UIParent, "ANCHOR_NONE")

function Data:GetTooltipText(itemLink)
    local itemID = Misc:GetItemIDFromLink(itemLink);

    if (not itemID or itemID < 0) then
        return "invalid";
    end

    -- Use SetHyperLink for specific item variation. Use SetItemID for generic item (i.e. to include <Random enchantment> property)
    -- ParsingTooltip:SetHyperlink(itemLink)
    ParsingTooltip:SetItemByID(itemID)

    local name = _G["GUParsingTooltipTextLeft1"]:GetText();
    if (not name or name == "") then
        return "invalid";
    end
    
    -- Scan the tooltip:
    local tooltipText = "";
    for i = 2, ParsingTooltip:NumLines() do -- Line 1 is always the name so you can skip it.
        local left = _G["GUParsingTooltipTextLeft"..i]:GetText()
        local right = _G["GUParsingTooltipTextRight"..i]:GetText()

        local line = "";
        if left and left ~= "" then
            line = line .. left;
        end
        if right and right ~= "" then
            line = line .. " " .. right;
        end

        tooltipText = tooltipText .. line .. "\n";
    end

    return tooltipText;
end

function Data:GetItemIDToParse()
    local scanDB = GU.db.global.scanDB;
    local currentID = (self.lastIDParsed + 1) % self:GetMaxItemID();

    while (currentID ~= self.lastIDParsed) do
        if (currentID ~= 0 and scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] ~= nil) then
            if (scanDB.status[Locales:GetDatabaseLocaleKey()][currentID] == GU_ITEM_STATUS_SCANNED) then
                return currentID;
            end
        end

        currentID = (currentID + 1) % self:GetMaxItemID();
    end

    return nil;
end

function Data:ParseItems()
    local scanDB = GU.db.global.scanDB;
    if (not scanDB.parseEnabled) then
        return
    end
    
    local itemID = self:GetItemIDToParse();
    if (itemID ~= nil) then
        self:ParseItem(itemID);
    else
        Logger:Log("End of parse.");
        self:SetParseEnabled(false);
    end  
end

function Data:ParseItem(itemID)
    itemID = tonumber(itemID);
    if (itemID == nil or itemID <= 0 or Data:WasParsed(itemID)) then
        return;
    end

    local scanDB = GU.db.global.scanDB;

    self.lastIDParsed = itemID;

    -- Make a temp item structure
    self.tempParsedItem = Misc:DeepCopy(scanDB.items[Locales:GetDatabaseLocaleKey()][itemID]);

    -- Parse tooltip lines
    local result = self:ParseItemTooltip(itemID);

    -- If every line was parsed correctly, add item to database.
    if (result) then
        self:PrintItemInfo(self.tempParsedItem, itemID);
        self:SetParseEnabled(false); -- temporary
    -- If not, delete temp item, stop parsing and print where error was found and why.
    else
        self.tempParsedItem = nil;
        self:SetParseEnabled(false);
    end
end

function Data:ParseItemTooltip(itemID, itemType, itemSubtype, tooltipText)
    -- Split the text into lines.
    lines = {}
    for s in tooltipText:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    -- Parse each line and stop if error occured.
    for i = 1, #lines do
        local result = self:ParseItemTooltipLine(itemID, lines[i]);
        if (not result) then
            return false;
        end
    end

    return true;
end

function Data:ParseItemTooltipLine(id, tooltipLine)
    local itemDB = GU.db.global.itemDB;

    tooltipLine = tooltipLine:match(GU_REGEX_REMOVE_EDGE_SPACES);
    if (string.len(tooltipLine) == 0) then
        return true;
    end

    if (not L) then
        Logger:Err("Data:ParseItemTooltipLine Locale table 'L' is invalid.");
        return false;
    end

    -- Check binding and uniqueness.
    if (tooltipLine:find(GU_REGEX_SOULBOUND)) then
        return true;    -- do nothing
    elseif (tooltipLine:find(GU_REGEX_UNIQUE)) then
        self:AddItemProperty(GU_PROPERTY_UNIQUE, true);
        return true;
    elseif (tooltipLine:find(GU_REGEX_UNIQUE_EQUIPPED)) then
        local uniqueEquipped = tooltipLine:match(GU_REGEX_UNIQUE_EQUIPPED);
        self:AddItemProperty(GU_PROPERTY_UNIQUE_EQUIPPED, uniqueEquipped);
        return true;
    elseif (tooltipLine:find(GU_REGEX_BOP)) then
        self:AddItemProperty(GU_PROPERTY_BOP, true);
        return true;
    elseif (tooltipLine:find(GU_REGEX_BOE)) then
        self:AddItemProperty(GU_PROPERTY_BOE, true);
        return true;
    end

    -- Check common properties (level required, durability etc.)
    local levelRequired = tooltipLine:match(GU_REGEX_LEVEL_REQUIRED);

    local itemType = self.tempParsedItem.type;
    local itemSubtype = self.tempParsedItem.subtype;

    if (tooltipLine:find(REGEX_SOULBOUND) or tooltipLine:find(REGEX_BOP) or tooltipLine:find(REGEX_BOE)) then
        -- do nothing...
    elseif (tooltipLine:find(REGEX_UNIQUE)) then
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

function Data:AddItemProperty(propertyKey, propertyValue)
    self.tempParsedItem.properties[propertyKey] = propertyValue;
end