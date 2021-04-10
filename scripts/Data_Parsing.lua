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

function Data:ResetParsedProperties(item)
    local scanDB = GU.db.global.scanDB;

    local set = item.set;
    if (set and set ~= "") then
        scanDB.sets[Locales:GetDatabaseLocaleKey()][set] = nil;
    end

    item.classes = {};
    item.set = "";
    item.properties = {};
    item.equipEffects = {};
    item.useEffects = {};
    item.onHitEffects = {};
end

function Data:GetItemIDToParse()
    local scanDB = GU.db.global.scanDB;
    local currentID = (self.lastIDParsed + 1) % self:GetMaxItemID();

    if (currentID < 0) then
        currentID = 1;
    end

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
    local result, isEmpty = self:ParseItemTooltip(itemID);

    -- If every line was parsed correctly, add item (and set if eligible) to database
    if (result) then
        if (not isEmpty) then
            self:PrintItemInfo(self.tempParsedItem, itemID);
            -- self:SetParseEnabled(false); -- temporary
            -- Add item to database here.
            -- Add set to database here.
        end
    -- If not, delete temp item, stop parsing and print where error was found and why.
    else
        Logger:Err("Data:ParseItem Parsing stopped on item:");
        self:PrintItemInfo(self.tempParsedItem, itemID);
        self.tempParsedItem = nil;
        self.tempParsedSet = nil;
        self.lastIDParsed = self.lastIDParsed - 1;
        self:SetParseEnabled(false);
    end
end

function Data:ParseItemTooltip(itemID)
    local scanDB = GU.db.global.scanDB;
    local tooltipText = scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID];

    -- Split the text into lines.
    lines = {}
    for s in tooltipText:gmatch("[^\r\n]+") do
        if (s ~= "") then
            table.insert(lines, s)
        end
    end

    -- Parse each line and stop if error occured.
    local result = false;
    for i = 1, #lines do
        result = self:ParseItemTooltipLine(itemID, lines[i]);
        if (not result) then
            return false, false;
        end
    end

    if (result) then
        -- We do an extra validation here, especially for sets.
        if (self.tempParsedSet) then
            if (self.tempParsedSet.remainingItems > 0) then
                Logger:Err("Data:ParseItemTooltip Not all set items were parsed correctly (remaining: %d)", self.tempParsedSet.remainingItems);
                return false, false;
            end
            if (#self.tempParsedSet.bonuses == 0) then
                Logger:Err("Data:ParseItemTooltip Parsed set contains no valid bonuses.");
                return false, false;
            end
        end
    else
        -- Empty tooltip.
        return true, true;
    end

    return true, false;
end

-- Not the best and optimized parsing algorithm, but we need to do it only once.
function Data:ParseItemTooltipLine(itemID, tooltipLine)
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
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_SOULBOUND");
        return true;    -- do nothing
    elseif (tooltipLine:find(GU_REGEX_UNIQUE)) then
        self:AddItemProperty(GU_PROPERTY_UNIQUE, true);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_UNIQUE");
        return true;
    elseif (tooltipLine:find(GU_REGEX_UNIQUE_EQUIPPED)) then
        local uniqueEquipped = tooltipLine:match(GU_REGEX_UNIQUE_EQUIPPED);
        self:AddItemProperty(GU_PROPERTY_UNIQUE_EQUIPPED, uniqueEquipped);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_UNIQUE_EQUIPPED");
        return true;
    elseif (tooltipLine:find(GU_REGEX_BOP)) then
        self:AddItemProperty(GU_PROPERTY_BOP, true);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_BOP");
        return true;
    elseif (tooltipLine:find(GU_REGEX_BOE)) then
        self:AddItemProperty(GU_PROPERTY_BOE, true);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_BOE");
        return true;
    end

    -- Check common properties (level required, durability, classes, flavor text etc.)

    -- Level required. Example: Requires Level 51
    local levelRequired = tooltipLine:match(GU_REGEX_LEVEL_REQUIRED);
    if (levelRequired) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_LEVEL_REQUIRED");
        return true;
    end

    -- Durability: Example: Durability 50 / 50
    local durability = tooltipLine:match(GU_REGEX_DURABILITY);
    if (durability) then
        self:AddItemProperty(GU_PROPERTY_DURABILITY, durability);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_DURABILITY");
        return true;
    end

    -- Eligible classes. Example: Classes: Mage | Classes: Mage, Warlock
    local classes = tooltipLine:match(GU_REGEX_CLASSES);
    if (classes) then        
        classes = classes:gsub(",", "");

        local classesTable = {};
        classes:gsub("(%a+)", function (w)
            table.insert(classesTable, w)
        end)

        local classAdded = false;
        for i = 1, #classesTable do
            if (Misc:Contains(GU_CLASSES, classesTable[i])) then
                table.insert(self.tempParsedItem.classes, classesTable[i]);
                classAdded = true;
            else
                Logger:Err("Data:ParseItemTooltipLine Found unsupported class name: %s", classesTable[i]);
                return false;
            end
        end

        if (not classAdded) then
            Logger:Err("Data:ParseItemTooltipLine Tooltip line matched 'Classes: ...', but no valid class was found.");
        else
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CLASSES");
        end

        return classAdded;
    end

    -- Flavor text. Example: "The head of the Black Dragonflight's Brood Mother"
    local flavorText = tooltipLine:match(GU_REGEX_FLAVOR_TEXT);
    if (flavorText) then
        self:AddItemProperty(GU_PROPERTY_FLAVOR_TEXT, flavorText);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_FLAVOR_TEXT");
        return true;
    end

    -- Use Effects. Example: Use: Restores 375 to 625 mana. (5 Mins Cooldown)
    local useEffect = tooltipLine:match(GU_REGEX_USE_EFFECT);
    if (useEffect) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_USE_EFFECT");
        return self:ProcessItemTooltipLineUseEffect(itemID, itemSubtype, useEffect);
    end

    -- Quest item
    local questItem = tooltipLine:match(GU_REGEX_QUEST_ITEM);
    if (questItem) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_QUEST_ITEM");
        return true;
    end

    -- Random enchantment
    local randomEnch = tooltipLine:match(GU_REGEX_RANDOM_ENCH);
    if (randomEnch) then
        self.tempParsedItem.randomEnchantment = true;
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_RANDOM_ENCH");
        return true;
    end

    -- Check for common equippable items' properties, eg. sets, equipEffects, useEffects, armor,
    -- attributes (like Intellect), resistances, classes
    local equipLocation = self.tempParsedItem.equipLocation;
    if (equipLocation and equipLocation ~= "") then

        -- Armor value: Example: 2345 Armor
        local armor = tooltipLine:match(GU_REGEX_ARMOR_ARMOR);
        if (armor) then
            self:AddItemProperty(GU_PROPERTY_ARMOR, armor);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_ARMOR_ARMOR");
            return true;
        end

        -- Equip Effects. Example: Equip: Increases damage and healing done by magical spells and effects by up to 29
        local equipEffect = tooltipLine:match(GU_REGEX_EQUIP_EQUIP_EFFECT);
        if (equipEffect) then
            return self:ProcessItemTooltipLineEquipEffect(itemID, itemSubtype, equipEffect);
        end

        -- Attributes. Example: +8 Stamina | +16 Intellect
        -- Resistances. Example: + 15 Fire Resistance
        local attributeBonus, attributeName, resistance = tooltipLine:match(GU_REGEX_EQUIP_ATTRIBUTE);
        if (attributeBonus and attributeName) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_ATTRIBUTE");

            if (resistance and resistance == L["PROPERTY_RESISTANCE"]) then
                if (Misc:Contains(GU_ELEMENTAL_DAMAGE_TYPES, attributeName)) then
                    local resistanceNameAndType = attributeName .. " " .. resistance;
                    self:AddItemProperty(resistanceNameAndType, attributeBonus);
                    return true;
                else
                    Logger:Err("Data:ParseItemTooltipLine Found unsupported resistance type: %s", attributeName);
                    return false;
                end
            else
                if (Misc:Contains(GU_PROPERTY_ATTRIBUTES, attributeName)) then
                    self:AddItemProperty(attributeName, attributeBonus);
                    return true;
                else
                    Logger:Err("Data:ParseItemTooltipLine Found unsupported attribute: %s", attributeName);
                    return false;
                end
            end
        end

        -- Sets. Example:
        -- Battlegear of Might (0/8)
        --  Belt of Might
        --  Bracers of Might
        --  Breastplate of Might
        --  Gauntlets of Might
        --  Helm of Might
        --  Legplates of Might
        --  Pauldrons of Might
        --  Sabatons of Might

        -- (3) Set : Increases the block value of your shield by 30.
        -- (5) Set : Gives you a 20% chance to generate an additional Rage point whenever damage is dealt to you.
        -- (8) Set : Increases the threat generated by Sunder Armor by 15%.

        if (not self.tempParsedSet) then
            local setName, setPieces = tooltipLine:match(GU_REGEX_EQUIP_SET_NAME);
            if (setName and setPieces) then
                self.tempParsedItem.set = setName;
                Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_SET_NAME");
                return self:AddParsedSet(setName, setPieces);
            end
        else    
            -- First we add all set items
            if (self.tempParsedSet.remainingItems > 0) then
                local setItemName = tooltipLine:match(GU_REGEX_EQUIP_SET_ITEM);
                if (setItemName) then
                    self.tempParsedSet.remainingItems = self.tempParsedSet.remainingItems - 1;
                    Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_SET_ITEM");
                    return self:AddParsedSetItem(setItemName);
                end
            else
                -- Then we parse set bonuses.
                local bonusTier, bonusDescription = tooltipLine:match(GU_REGEX_EQUIP_SET_BONUS);
                if (bonusTier and bonusDescription) then
                    Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_SET_BONUS");
                    return self:AddParsedSetBonus(bonusTier, bonusDescription);
                end
            end
        end

        -- Slot/Type parsing. Examples: Off Hand Shield | Legs Plate | Held in Off-hand | Relic Totem | Two-Hand Fishing Pole
        -- | One Hand Fist Weapon | Off-Hand Fist Weapon
        -- This is tricky, cause there are multiple configurations.
        -- Generally we only check for correct slot/type configuration and move on. This information is not stored, as it is
        -- provided from GetItemInfo in form of type, subtype and equip location data.

        -- There are at most 4 different strings that we need to match.
        -- Pattern will pass even if only type1 is valid, so we need to check if every other string is non-empty.
        local type1, type2, type3, type4 = string.match(tooltipLine, GU_REGEX_EQUIP_SLOT_AND_TYPE);
        local typeCount = 4;
        if (type1) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_SLOT_AND_TYPE");

            -- The best solution here is to work our way backwards and start from the longest ones.
            if (not type4 or type4 == "") then typeCount = typeCount - 1; end
            if (not type3 or type3 == "") then typeCount = typeCount - 1; end
            if (not type2 or type2 == "") then typeCount = typeCount - 1; end
            
            -- This is only true for Fist Weapons (Fishing Poles are 'Two-Hand', so only 3 strings total).
            if (typeCount == 4) then
                local itemType = type3 .. " " .. type4;
                if (itemType ~= L["PROPERTY_FIST_WEAPON"]) then
                    Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration (expected Fist Weapon): ", tooltipLine);
                    return false;            
                end
            -- Here it's getting trickier.
            -- First we check for obvious one: Held In Off-hand
            -- Then we check if last two types form a valid type, thus the first one being a slot name.
            -- If that's not the case, we check the first two types for a valid slot name, thus the last one being the item type.
            elseif (typeCount == 3) then
                if (string.match(type1 .. " " .. type2 .. " " .. type3, L["PROPERTY_OFF_HAND_HELD"])) then
                    return true;
                end
                local itemType = type2 .. " " .. type3;
                if (Misc:Contains(GU_PROPERTY_WEAPON_TYPES, itemType) and Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1)) then
                    return true;
                end
                itemType = type1 .. " " .. type2;
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, itemType) and Misc:Contains(GU_PROPERTY_WEAPON_TYPES, type3)) then
                    return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 3 strings: ", tooltipLine);
                return false;
            -- This can either be Slot + Type or two-words Type     
            elseif (typeCount == 2) then
                local itemType = type1 .. " " .. type2;
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, itemType)) then
                    return true;
                end
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1) and Misc:Contains(GU_PROPERTY_WEAPON_TYPES, type2)
                    or Misc:Contains(GU_PROPERTY_ARMOR_SLOTS, type1) and Misc:Contains(GU_PROPERTY_ARMOR_TYPES, type2)
                    or type1 == L["PROPERTY_AMMO"] and (type2 == L["SUBTYPE_ARROW"] or type2 == L["SUBTYPE_BULLET"])) then
                        return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 2 strings: ", tooltipLine);
                return false;
            else
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1)) then
                    return true;
                end
                if (Misc:Contains(GU_PROPERTY_ARMOR_SLOTS, type1)) then
                    return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 1 string: ", tooltipLine);
                return false;

            end
        end
    end

    -- Now we divide parsing into separate functions to make it more readable and easier to debug.
    local itemType = self.tempParsedItem.type;
    local itemSubtype = self.tempParsedItem.subtype;
    local result = false;
    
    if (itemType == L["TYPE_WEAPON"]) then
        result = self:ParseWeaponItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_ARMOR"]) then
        result = self:ParseArmorItemTooltipLine(itemID, itemSubtype, tooltipLine);
    end
    -- TODO
    -- Containers (bags and profession bags)

    if (not result) then
        Logger:Err("Data:ParseItemTooltipLine Tooltip line parsing unsuccessful for %s", tooltipLine);
        return false;
    end

    return true;
end

function Data:ParseWeaponItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Basic weapon damage values and optional type. Example: 57 - 105 Arcane Damage
    -- Weapon speed. Example: Speed 2.40
    local minDamage, maxDamage, damageType, weaponSpeed = tooltipLine:match(GU_REGEX_WEAPON_DAMAGE_AND_SPEED);
    if (minDamage and maxDamage and weaponSpeed) then
        self:AddItemProperty(GU_PROPERTY_DAMAGE_MIN, minDamage);
        self:AddItemProperty(GU_PROPERTY_DAMAGE_MAX, maxDamage);
        weaponSpeed = tonumber(weaponSpeed);
        self:AddItemProperty(GU_PROPERTY_DAMAGE_SPEED, weaponSpeed);

        if (damageType) then
            if (damageType == "") then
                damageType = GU_DAMAGE_TYPE_PHYSICAL;
            elseif (Misc:Contains(GU_ELEMENTAL_DAMAGE_TYPES, damageType)) then
                self:AddItemProperty(GU_PROPERTY_DAMAGE_TYPE, damageType);
            else
                Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental damage type: %s", damageType);
                return false;
            end
        end

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_DAMAGE_AND_SPEED");
        return true;
    end

    -- Extra elemental damage. Example: + 1 - 5 Frost Damage
    local extraMinDamage, extraMaxDamage, extraDamageType = tooltipLine:match(GU_REGEX_WEAPON_EXTRA_DAMAGE);
    if (extraMinDamage and extraMaxDamage) then
        self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_MIN, extraMinDamage);
        self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_MAX, extraMaxDamage);

        if (extraDamageType and extraDamageType ~= "") then
            if (Misc:Contains(GU_ELEMENTAL_DAMAGE_TYPES, extraDamageType)) then
                self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_TYPE, extraDamageType);
            else
                Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental extra damage type: %s", extraDamageType);
                return false;
            end
        end    

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_EXTRA_DAMAGE");
        return true;
    end

    -- Damage per second. Example (42.2 damage per second)
    local weaponDPS = tooltipLine:match(GU_REGEX_WEAPON_DPS);
    if (weaponDPS) then
        self:AddItemProperty(GU_PROPERTY_DPS, weaponDPS);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_DPS");
        return true;
    end

    -- Chance on hit, which is valid only for weapons. Example: Chance on hit: Delivers a fatal wound for 240 damage
    -- This is basically treated as custom property, not indexed, because of the variety
    -- of wording of similar effects and (in most cases) unknown proc chance.
    local chanceOnHit = tooltipLine:match(GU_REGEX_WEAPON_CHANCE_ON_HIT);
    if (chanceOnHit and not Misc:Contains(self.tempParsedItem.onHitEffects, chanceOnHit)) then
        table.insert(self.tempParsedItem.onHitEffects, chanceOnHit);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_CHANCE_ON_HIT");
        return true;
    end

    Logger:Err("Data:ParseWeaponItemTooltipLine Could not parse weapon's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseArmorItemTooltipLine(itemID, itemSubtype, tooltipLine)
    if (itemSubtype == L["SUBTYPE_SHIELDS"]) then
        -- Block value. Example: 39 Block
        local block = tooltipLine:match(GU_REGEX_ARMOR_BLOCK);
        if (block) then
            self:AddItemProperty(GU_PROPERTY_BLOCK, block);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_ARMOR_BLOCK");
            return true;
        end
        
        Logger:Err("Data:ParseArmorItemTooltipLine Could not parse shield's tooltip line: %s", tooltipLine);
        return false;
    end

    return true;    
end

function Data:ProcessItemTooltipLineEquipEffect(itemID, itemSubtype, equipEffect)
    -- Spell power. Example: Increases damage and healing done by magical spells and effects by up to 29
    local spellPower = equipEffect:match(GU_REGEX_EQUIP_EQUIP_EFFECT_SPELL_POWER);
    if (spellPower) then
        self:AddItemProperty(GU_PROPERTY_SPELL_POWER, spellPower);
        Logger:Verb("Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EQUIP_EFFECT_SPELL_POWER");
        return true;
    end

    return false;
end

function Data:ProcessItemTooltipLineUseEffect(itemID, itemSubtype, useEffect)
    if (useEffect and not Misc:Contains(self.tempParsedItem.useEffects, useEffect)) then
        table.insert(self.tempParsedItem.useEffects, useEffect);
        return true;
    end

    Logger:Err("Data:ProcessItemTooltipLineUseEffect Invalid or duplicate Use Effect found: %s", useEffect);
    return false;
end

function Data:AddParsedSet(setName, setPieces)
    if (setName) then
        self.tempParsedSet = {
            name = setName,
            remainingItems = setPieces,
            items = {},
            bonuses = {}
        }
        return true;
    else
        Logger:Err("Data:AddParsedSet Invalid set name");
        return false;
    end
end

function Data:AddParsedSetItem(itemName)
    local itemID = self:FindItemIDByItemName(itemName);
    if (itemID) then
        if (itemID > 0 and not Misc:Contains(self.tempParsedSet.items, itemID)) then
            table.insert(self.tempParsedSet.items, itemID);
            return true;
        else
            Logger:Err("Data:AddParsedSetItem Invalid or duplicate ID (%d) found for set: %s", itemID, self.tempParsedSet.name);
            return false;    
        end    
    else
        Logger:Err("Data:AddParsedSetItem Could not find a valid item ID for item: %s", itemName);
        return false;
    end
end

function Data:AddParsedSetBonus(bonusTier, bonusDescription)
    local bonus = {tier = bonusTier, desc = bonusDescription};
    if (not Misc:Contains(self.tempParsedSet.items, bonus)) then
        table.insert(self.tempParsedSet.bonuses, bonus);
        return true;
    end

    Logger:Err("Data:AddParsedSetBonus Duplicate bonus found - (%d) : %s ", bonusTier, bonusDescription);
    return false;
end

function Data:AddItemProperty(propertyKey, propertyValue)
    if (Locales:IsCurrentLocaleMainLocale() and not self.tempParsedItem.properties[propertyKey]) then
        self.tempParsedItem.properties[propertyKey] = propertyValue;
    end
end