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

    -- local verb = Logger:IsVerboseLogEnabled();  -- TEMP
    -- if (verb) then 
    --     Logger:SetVerboseLogEnabled(false);
    -- end

    -- Make a temp item structure
    self.tempParsedItem = Misc:DeepCopy(scanDB.items[Locales:GetDatabaseLocaleKey()][itemID]);

    -- Reset parsing variables
    self.tempParsedRecipeMaterials = nil;
    self.tempParsedRecipeRequirement = nil;
    self.tempParsedProfessionRequirement = nil;
    self.tempParsedSet = nil;

    -- Parse tooltip lines
    local result, isEmpty = self:ParseItemTooltip(itemID);

    -- If every line was parsed correctly, add item (and set if eligible) to database
    if (result) then
        if (not isEmpty) then
            -- self:PrintItemInfo(self.tempParsedItem, itemID);
            -- Logger:Log("Data:ParseItem Parsed item: %s (%d)", self.tempParsedItem.name, itemID);
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

    -- Logger:IsVerboseLogEnabled(verb); -- TEMP
end

function Data:ParseItemTooltip(itemID)
    local scanDB = GU.db.global.scanDB;
    local tooltipText = scanDB.tooltips[Locales:GetDatabaseLocaleKey()][itemID];

    -- Split the text into lines.
    lines = {}
    for s in tooltipText:gmatch("[^\r\n]+") do
        if (s ~= "") then
            table.insert(lines, s);
        end
    end

    -- Parse each line and stop if error occured.
    local result = false;
    local remainingLines = #lines;
    for i = 1, #lines do
        remainingLines = #lines - i;
        result = self:ParseItemTooltipLine(itemID, lines[i], remainingLines);
        if (not result) then
            Logger:Err("Data:ParseItemTooltip Remaining lines: %d", remainingLines);
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
function Data:ParseItemTooltipLine(itemID, tooltipLine, remainingLines)
    tooltipLine = tooltipLine:match(GU_REGEX_REMOVE_EDGE_SPACES);
    if (string.len(tooltipLine) == 0) then
        return true;
    end

    if (not L) then
        Logger:Err("Data:ParseItemTooltipLine Locale table 'L' is invalid.");
        return false;
    end

    local itemType = self.tempParsedItem.type;
    local itemSubtype = self.tempParsedItem.subtype;

    --------------------------------------------------------------
    -- TODO Convert all number parameters using "tonumber".
    -- TODO Verify recipes items once database is exported.
    --------------------------------------------------------------

    -- Need to check cause recipes can have Bind when X properties.
    if (itemType ~= L["TYPE_RECIPE"] or not self.tempParsedProfessionRequirement) then
        -- Check binding and uniqueness.
        if (tooltipLine:find(GU_REGEX_SOULBOUND)) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_SOULBOUND");
            return true;    -- do nothing
        elseif (tooltipLine:find(GU_REGEX_UNIQUE)) then
            local uniqueCount = tooltipLine:match(GU_REGEX_UNIQUE);
            uniqueCount = tonumber(uniqueCount) or 1;
            self:AddItemProperty(GU_PROPERTY_UNIQUE, uniqueCount);
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
        elseif (tooltipLine:find(GU_REGEX_BOU)) then
            self:AddItemProperty(GU_PROPERTY_BOU, true);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_BOU");
            return true;
        end
    end

    -- Check common properties (level required, durability, classes, flavor text etc.)

    -- Use Effects. Example: Use: Restores 375 to 625 mana. (5 Mins Cooldown)
    local useEffect = tooltipLine:match(GU_REGEX_USE_EFFECT);
    if (useEffect) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_USE_EFFECT");
        if (itemType == L["TYPE_RECIPE"] and itemSubtype == L["SUBTYPE_BOOK"]) then
            self.tempParsedProfessionRequirement = true;
        end
        return self:ProcessItemTooltipLineUseEffect(itemID, itemSubtype, useEffect);
    end

    -- With this we skip item definition within recipe's tooltip.
    if (itemType == L["TYPE_RECIPE"] and self.tempParsedProfessionRequirement and remainingLines > 0) then
        return true;
    end
    if (self.tempParsedRecipeRequirement and remainingLines > 0) then
        return true;
    end

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
        local classesTable = {};
        classes:gsub("([%a%s]+),?%s?", function (w)
            table.insert(classesTable, w)
        end)

        local classAdded = false;
        for i = 1, #classesTable do
            if (Misc:Contains(GU_CLASSES, classesTable[i])) then
                if (not self.tempParsedItem.classes) then
                    self.tempParsedItem.classes = {};
                end
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

    -- Eligible races. Example: Races: Orc, Undead, Tauren, Troll
    local races = tooltipLine:match(GU_REGEX_RACES);
    if (races) then        
        local racesTable = {};
        races:gsub("([%a%s]+),?%s?", function (w)
            table.insert(racesTable, w)
        end)

        local raceAdded = false;
        for i = 1, #racesTable do
            if (Misc:Contains(GU_RACES, racesTable[i])) then
                if (not self.tempParsedItem.races) then
                    self.tempParsedItem.races = {};
                end
                table.insert(self.tempParsedItem.races, racesTable[i]);
                raceAdded = true;
            else
                Logger:Err("Data:ParseItemTooltipLine Found unsupported race name: %s", racesTable[i]);
                return false;
            end
        end

        if (not raceAdded) then
            Logger:Err("Data:ParseItemTooltipLine Tooltip line matched 'Races: ...', but no valid race was found.");
        else
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_RACES");
        end

        return raceAdded;
    end
    
    -- Flavor text. Example: "The head of the Black Dragonflight's Brood Mother"
    local flavorText = tooltipLine:match(GU_REGEX_FLAVOR_TEXT);
    if (flavorText) then
        self:AddItemProperty(GU_PROPERTY_FLAVOR_TEXT, flavorText);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_FLAVOR_TEXT");
        return true;
    end

    -- Quest item
    local questItem = tooltipLine:match(GU_REGEX_QUEST_ITEM);
    if (questItem) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_QUEST_ITEM");
        return true;
    end

    -- This Item Begins a Quest
    local questItemBegin = tooltipLine:match(GU_REGEX_QUEST_ITEM_BEGIN);
    if (questItemBegin) then
        self:AddItemProperty(GU_PROPERTY_QUEST_BEGIN, true);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_QUEST_ITEM_BEGIN");
        return true;
    end

    -- Random enchantment
    local randomEnch = tooltipLine:match(GU_REGEX_RANDOM_ENCH);
    if (randomEnch) then
        self.tempParsedItem.randomEnchantment = true;
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_RANDOM_ENCH");
        return true;
    end

    -- Duration. Example: Duration: 5 min
    local duration = tooltipLine:match(GU_REGEX_DURATION);
    if (duration) then
        self:AddItemProperty(GU_PROPERTY_DURATION, duration);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_DURATION");
        return true;
    end

    -- Faction reputation requirement. Example: Requires Argent Dawn - Honored
    local faction, reputation = tooltipLine:match(GU_REGEX_REPUTATION_REQUIREMENT);
    if (faction and reputation) then
        if (Misc:Contains(GU_PROPERTY_FACTIONS, faction) and Misc:Contains(GU_PROPERTY_REPUTATIONS, reputation)) then
            self:AddItemProperty(faction, reputation);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_REPUTATION_REQUIREMENT");
            return true;
        else
            Logger:Err("Data:ParseItemTooltipLine Invalid reputation and/or faction found: %s - %s", faction, reputation);
            return false;
        end
    end

    -- PVP rank requirement. Example: Requires Grand Marshal
    if (itemType ~= L["TYPE_RECIPE"]) then
        local pvpRank = tooltipLine:match(GU_REGEX_PVP_RANK_REQUIREMENT);
        if (pvpRank) then
            if (Misc:Contains(GU_PROPERTY_RIDING_SKILLS, pvpRank) or pvpRank == "Poisons") then
                -- DO NOTHING
            elseif (Misc:Contains(GU_PROPERTY_PVP_RANKS, pvpRank)) then
                self:AddItemProperty(GU_PROPERTY_PVP_RANK, pvpRank);
                Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_PVP_RANK_REQUIREMENT");
                return true;
            else
                Logger:Err("Data:ParseItemTooltipLine Invalid pvp rank found: %s", pvpRank);
                return false;
            end
        end
    end

    -- Conjured item.
    local conjuredItem = tooltipLine:match(GU_REGEX_CONJURED_ITEM);
    if (conjuredItem) then
        self:AddItemProperty(GU_PROPERTY_CONJURED_ITEM, true);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CONJURED_ITEM");
        return true;
    end

    -- We want to check this only once.
    if (not self.tempParsedProfessionRequirement) then
        -- Profession requirement. Example: Requires Cooking (75)
        local professionOrSpec, professionLevel = tooltipLine:match(GU_REGEX_PROFESSION_REQUIREMENT);
        if (professionOrSpec and professionLevel) then
            professionLevel = tonumber(professionLevel);
            -- These will be parsed later, skip for now.
            if (Misc:Contains(GU_PROPERTY_RIDING_SKILLS, professionOrSpec) or professionOrSpec == "Poisons") then
                -- DO NOTHING
            elseif (Misc:Contains(GU_RECIPE_SUBTYPES, professionOrSpec)) then
                self:AddItemProperty(professionOrSpec, professionLevel);
                self.tempParsedProfessionRequirement = true;
                Logger:Verb("Tooltip line '%s' matched against regex %s (profession)", tooltipLine, "GU_REGEX_PROFESSION_REQUIREMENT");
                return true;
            elseif (Misc:Contains(GU_CLASS_SPECS, professionOrSpec)) then
                self:AddItemProperty(professionOrSpec, professionLevel);
                self.tempParsedProfessionRequirement = true;
                Logger:Verb("Tooltip line '%s' matched against regex %s (spec)", tooltipLine, "GU_REGEX_PROFESSION_REQUIREMENT");
                return true;
            else
                Logger:Err("Data:ParseItemTooltipLine Found unsupported profession or spec: %s (%d)", professionOrSpec, professionLevel);
                return false;
            end
        end
    end

    -- Charges. Example: 10 Charges
    local charges = tooltipLine:match(GU_REGEX_CHARGES);
    if (charges) then
        self:AddItemProperty(GU_PROPERTY_CHARGES, charges);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CHARGES");
        return true;
    end

    -- Locked.
    local locked = tooltipLine:match(GU_REGEX_LOCKED);
    if (locked) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_LOCKED");
        return true;
    end

    -- <Right Click for Details>
    local details = tooltipLine:match(GU_REGEX_DETAILS);
    if (details) then
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_DETAILS");
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
        local equipEffect = tooltipLine:match(GU_REGEX_EQUIP_EFFECT);
        if (equipEffect) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_EFFECT");
            return self:ProcessItemTooltipLineEquipEffect(itemID, itemSubtype, equipEffect);
        end

        -- Attributes. Example: +8 Stamina | +16 Intellect
        -- Resistances. Example: +15 Fire Resistance
        local sign, attributeBonus, attributeName, resistance = tooltipLine:match(GU_REGEX_EQUIP_ATTRIBUTE);
        if (sign and attributeBonus and attributeName) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_EQUIP_ATTRIBUTE");
            if (sign == "-") then
                attributeBonus = attributeBonus * -1;
            end
            if (resistance and resistance == L["PROPERTY_RESISTANCE"]) then
                if (Misc:Contains(GU_DAMAGE_TYPES, attributeName)) then
                    local resistanceNameAndType = attributeName .. " " .. resistance;
                    self:AddItemProperty(resistanceNameAndType, attributeBonus);
                    return true;
                else
                    Logger:Err("Data:ParseItemTooltipLine Found unsupported resistance type: %s", attributeName);
                    return false;
                end
            else
                if (Misc:Contains(GU_DAMAGE_TYPES, attributeName) and resistance == "Damage" and itemType == L["TYPE_WEAPON"]) then
                    -- DO NOTHING. This will processed in weapon's extra damage.
                elseif (Misc:Contains(GU_PROPERTY_ATTRIBUTES, attributeName)) then
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
                return self:AddParsedSet(setName, tonumber(setPieces));
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
                    return self:AddParsedSetBonus(tonumber(bonusTier), bonusDescription);
                end
            end
        end

        -- Slot/Type parsing. Examples: Off Hand Shield | Legs Plate | Held in Off-hand | Relic Totem | Two-Hand Fishing Pole
        -- | One Hand Fist Weapon | Off-Hand Fist Weapon
        -- This is tricky, cause there are multiple configurations.
        -- Generally we only check for correct slot/type configuration and move on. This information is not stored, as it is
        -- provided from GetItemInfo in form of type, subtype and equip location data.
        -- TODO: The only exception is the Main Hand/One-Hand/Off Hand slots for weapons. This one need to be stored.

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
                else
                    local slot = type1 .. " " .. type2;
                    if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, slot)) then
                        self:AddItemProperty(slot, true);
                    end
                    return true;
                end
            -- Here it's getting trickier.
            -- First we check for obvious one: Held In Off-hand
            -- Then we check if last two types form a valid type, thus the first one being a slot name.
            -- If that's not the case, we check the first two types for a valid slot name, thus the last one being the item type.
            elseif (typeCount == 3) then
                local itemType = type1 .. " " .. type2 .. " " .. type3;
                if (itemType == L["PROPERTY_OFF_HAND_HELD"]) then
                    return true;
                end
                itemType = type2 .. " " .. type3;
                if (Misc:Contains(GU_PROPERTY_WEAPON_TYPES, itemType) and Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1)) then
                    local slot = type1;
                    if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, slot)) then
                        self:AddItemProperty(slot, true);
                    end
                    return true;
                end
                itemType = type1 .. " " .. type2;
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, itemType) and Misc:Contains(GU_PROPERTY_WEAPON_TYPES, type3)
                    or Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, itemType) and Misc:Contains(GU_PROPERTY_ARMOR_TYPES, type3)) then
                    if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, itemType)) then
                        self:AddItemProperty(itemType, true);
                    end
                    return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 3 strings: %s", tooltipLine);
                return false;
            -- This can either be Slot + Type or two-words Type     
            elseif (typeCount == 2) then
                local itemType = type1 .. " " .. type2;
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, itemType)) then
                    if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, itemType)) then
                        self:AddItemProperty(itemType, true);
                    end
                    return true;
                end
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1) and Misc:Contains(GU_PROPERTY_WEAPON_TYPES, type2)
                    or Misc:Contains(GU_PROPERTY_ARMOR_SLOTS, type1) and Misc:Contains(GU_PROPERTY_ARMOR_TYPES, type2)
                    or (type1 == L["PROPERTY_AMMO"] or type1 == L["TYPE_PROJECTILE"]) and (type2 == L["SUBTYPE_ARROW"] or type2 == L["SUBTYPE_BULLET"])) then
                        if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, type1)) then
                            self:AddItemProperty(type1, true);
                        end    
                        return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 2 strings: %s", tooltipLine);
                return false;
            else
                if (Misc:Contains(GU_PROPERTY_WEAPON_SLOTS, type1)) then
                    if (Misc:Contains(GU_PROPERTY_WEAPON_ONE_HAND_SLOTS, type1)) then
                        self:AddItemProperty(type1, true);
                    end    
                    return true;
                end
                if (Misc:Contains(GU_PROPERTY_WEAPON_TYPES, type1)) then
                    return true;
                end
                if (Misc:Contains(GU_PROPERTY_ARMOR_SLOTS, type1)) then
                    return true;
                end

                Logger:Err("Data:ParseItemTooltipLine Cannot parse type/slot configuration for 1 string: %s", tooltipLine);
                return false;

            end
        end
    end

    -- Now we divide parsing into separate functions to make it more readable and easier to debug.
    local result = false;
    
    if (itemType == L["TYPE_WEAPON"]) then
        result = self:ParseWeaponItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_ARMOR"]) then
        result = self:ParseArmorItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_RECIPE"]) then
        result = self:ParseRecipeItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_CONTAINER"]) then
        result = self:ParseContainerItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_MISC"]) then
        result = self:ParseMiscItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_CONSUMABLE"]) then
        result = self:ParseConsumableItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_QUIVER"]) then
        result = self:ParseQuiverItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_PROJECTILE"]) then
        result = self:ParseProjectileItemTooltipLine(itemID, itemSubtype, tooltipLine);
    elseif (itemType == L["TYPE_TRADE_GOODS"]) then
        result = self:ParseTradeGoodsItemTooltipLine(itemID, itemSubtype, tooltipLine);
    end

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
            elseif (Misc:Contains(GU_DAMAGE_TYPES, damageType)) then
                self:AddItemProperty(GU_PROPERTY_DAMAGE_TYPE, damageType);
            else
                Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental damage type: %s", damageType);
                return false;
            end
        end

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_DAMAGE_AND_SPEED");
        return true;
    end

    -- Basic weapon damage version #2. Example: 20 Damage
    local fixedDamage = "";
    fixedDamage, damageType, weaponSpeed = tooltipLine:match(GU_REGEX_WEAPON_DAMAGE_AND_SPEED2);
    if (fixedDamage and weaponSpeed) then
        self:AddItemProperty(GU_PROPERTY_DAMAGE_MIN, fixedDamage);
        self:AddItemProperty(GU_PROPERTY_DAMAGE_MAX, fixedDamage);
        weaponSpeed = tonumber(weaponSpeed);
        self:AddItemProperty(GU_PROPERTY_DAMAGE_SPEED, weaponSpeed);

        if (damageType) then
            if (damageType == "") then
                damageType = GU_DAMAGE_TYPE_PHYSICAL;
            elseif (Misc:Contains(GU_DAMAGE_TYPES, damageType)) then
                self:AddItemProperty(GU_PROPERTY_DAMAGE_TYPE, damageType);
            else
                Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental damage type: %s", damageType);
                return false;
            end
        end

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_DAMAGE_AND_SPEED2");
        return true;
    end

    -- Extra elemental damage. Example: + 1 - 5 Frost Damage
    local extraMinDamage, extraMaxDamage, extraDamageType = tooltipLine:match(GU_REGEX_WEAPON_EXTRA_DAMAGE);
    if (extraMinDamage and extraMaxDamage) then
        self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_MIN, tonumber(extraMinDamage));
        self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_MAX, tonumber(extraMaxDamage));

        if (extraDamageType and extraDamageType ~= "") then
            if (Misc:Contains(GU_DAMAGE_TYPES, extraDamageType)) then
                self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_TYPE, extraDamageType);
            else
                Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental extra damage type: %s", extraDamageType);
                return false;
            end
        end    

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_EXTRA_DAMAGE");
        return true;
    end

    -- Extra elemental damage 2. Example: +5 Frost Damage
    local extraDamage2, extraDamageType2 = tooltipLine:match(GU_REGEX_WEAPON_EXTRA_DAMAGE2);
    if (extraDamage2 and extraDamageType2) then
        self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE, tonumber(extraDamage2));

        if (Misc:Contains(GU_DAMAGE_TYPES, extraDamageType2)) then
            self:AddItemProperty(GU_PROPERTY_EXTRA_DAMAGE_TYPE, extraDamageType2);
        else
            Logger:Err("Data:ParseWeaponItemTooltipLine Found unsupported weapon's elemental extra damage type: %s", extraDamageType2);
            return false;
        end

        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_WEAPON_EXTRA_DAMAGE2");
        return true;
    end

    -- Damage per second. Example (42.2 damage per second)
    local weaponDPS = tooltipLine:match(GU_REGEX_WEAPON_DPS);
    if (weaponDPS) then
        if (not tonumber(weaponDPS)) then
            Logger:Err("Data:ParseWeaponItemTooltipLine Cannot convert weapon dps to a number: %s", weaponDPS);
            return false;
        end
        self:AddItemProperty(GU_PROPERTY_DPS, tonumber(weaponDPS));
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

function Data:ParseRecipeItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Poison requirement. Example: Requires Poisons (100)
    local poisonLevel = tooltipLine:match(GU_REGEX_CONSUMABLE_POISON_REQUIREMENT);
    if (poisonLevel) then
        if (not tonumber(poisonLevel)) then
            poisonLevel = 0;
        end
        self.tempParsedRecipeRequirement = true;
        self:AddItemProperty(GU_PROPERTY_POISONS, poisonLevel);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CONSUMABLE_POISON_REQUIREMENT");
        return true;
    end

    -- Required materials. Example: Requires Stringy Vulture Meat, Murloc Eye, Goretusk Snout | Requires Bronze Bar (4)
    local materials = tooltipLine:match(GU_REGEX_RECIPE_REQUIRE_MATERIALS);
    if (materials) then
        self.tempParsedRecipeMaterials = true;
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_RECIPE_REQUIRE_MATERIALS");
        return true;
    end

    if (self.tempParsedRecipeMaterials or self.tempParsedRecipeRequirement) then
        Logger:Err("Data:ParseRecipeItemTooltipLine Could not parse recipes's tooltip line: %s", tooltipLine);
        return false;    
    end

    return true;
end

function Data:ParseContainerItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Bag slots and type. Example: 24 Slot Enchanting Bag
    local slots, bagType = tooltipLine:match(GU_REGEX_CONTAINER_SLOTS_AND_TYPE);
    if (slots and bagType) then
        if (Misc:Contains(GU_CONTAINER_SUBTYPES, bagType)) then
            self:AddItemProperty(bagType, true);
            self:AddItemProperty(GU_PROPERTY_SLOTS, slots);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CONTAINER_SLOTS_AND_TYPE");
            return true;
        else
            Logger:Err("Data:ParseContainerItemTooltipLine Invalid bag type found: %s", bagType);
            return false;    
        end
    end

    Logger:Err("Data:ParseContainerItemTooltipLine Could not parse container's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseMiscItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Riding skill requirement. Example: Requires Tiger Riding (1)
    local ridingSkill = tooltipLine:match(GU_REGEX_MOUNT_RIDING);
    if (ridingSkill) then
        if (Misc:Contains(GU_PROPERTY_RIDING_SKILLS, ridingSkill)) then
            self:AddItemProperty(ridingSkill, true);
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_MOUNT_RIDING");
            return true;
        else
            Logger:Err("Data:ParseContainerItemTooltipLine Invalid riding skill found: %s", ridingSkill);
            return false;    
        end
    end

    local customTooltipLines = {
        "Requires Tazan's Key"
    }

    for k,v in pairs(customTooltipLines) do
        if (tooltipLine == v) then
            Logger:Verb("Tooltip line '%s' matched against custom misc regex %s", tooltipLine, v);
            return true;
        end
    end

    Logger:Err("Data:ParseMiscItemTooltipLine Could not parse misc's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseConsumableItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Poison requirement. Example: Requires Poisons (100)
    local poisonLevel = tooltipLine:match(GU_REGEX_CONSUMABLE_POISON_REQUIREMENT);
    if (poisonLevel) then
        if (not tonumber(poisonLevel)) then
            poisonLevel = 0;
        end
        self:AddItemProperty(GU_PROPERTY_POISONS, poisonLevel);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CONSUMABLE_POISON_REQUIREMENT");
        return true;
    end

    -- Subtlety. Example: Requires Subtlety (150)
    local subtlety = tooltipLine:match(GU_REGEX_CONSUMABLE_SUBTLETY_REQUIREMENT);
    if (subtlety) then
        self:AddItemProperty(GU_PROPERTY_SUBTLETY, subtlety);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_CONSUMABLE_SUBTLETY_REQUIREMENT");
        return true;
    end

    -- Poison descriptions.
    local poisons = {
        GU_REGEX_CONSUMABLE_POISON1,
        GU_REGEX_CONSUMABLE_POISON2,
        GU_REGEX_CONSUMABLE_POISON3,
        GU_REGEX_CONSUMABLE_POISON4,
        GU_REGEX_CONSUMABLE_POISON5,
        GU_REGEX_CONSUMABLE_POISON6
    }

    for k,v in pairs(poisons) do
        charges = tooltipLine:match(v);
        if (charges) then
            Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, v);
            if (tonumber(charges)) then
                self:AddItemProperty(GU_PROPERTY_CHARGES, tonumber(charges));            
            end
            return true;
        end
    end

    Logger:Err("Data:ParseConsumableItemTooltipLine Could not parse consumable's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseQuiverItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Quiver slots. Example: 6 Slot Quiver
    local slots = tooltipLine:match(GU_REGEX_QUIVER_QUIVER_SLOTS);
    if (slots) then
        self:AddItemProperty(GU_PROPERTY_SLOTS, slots);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_QUIVER_QUIVER_SLOTS");
        return true;
    end

    -- Ammo pouch slots: Example: 6 Slot Ammo Pouch
    slots = tooltipLine:match(GU_REGEX_QUIVER_AMMO_POUCH_SLOTS);
    if (slots) then
        self:AddItemProperty(GU_PROPERTY_SLOTS, slots);
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_QUIVER_AMMO_POUCH_SLOTS");
        return true;
    end

    Logger:Err("Data:ParseQuiverItemTooltipLine Could not parse quiver's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseProjectileItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Projectile dps. Example: Adds 1.5 damage per second
    local projectileDPS = tooltipLine:match(GU_REGEX_PROJECTILE_DPS);
    if (projectileDPS) then
        if (not tonumber(projectileDPS)) then
            Logger:Err("Data:ParseProjectileItemTooltipLine Cannot convert projectile dps to a number: %s", projectileDPS);
            return false;
        end
        self:AddItemProperty(GU_PROPERTY_DPS, tonumber(projectileDPS));
        Logger:Verb("Tooltip line '%s' matched against regex %s", tooltipLine, "GU_REGEX_PROJECTILE_DPS");
        return true;
    end

    Logger:Err("Data:ParseProjectileItemTooltipLine Could not parse projectile's tooltip line: %s", tooltipLine);
    return false;
end

function Data:ParseTradeGoodsItemTooltipLine(itemID, itemSubtype, tooltipLine)
    -- Custom tooltip lines to ignore
    if (itemID == 9719 and tooltipLine:match(GU_REGEX_WEAPON_DAMAGE)) then
        return true;
    end

    Logger:Err("Data:ParseTradeGoodsItemTooltipLine Could not parse trade goods' tooltip line: %s", tooltipLine);
    return false;
end

function Data:ProcessItemTooltipLineEquipEffect(itemID, itemSubtype, equipEffect)
    -- Spell power. Example: Increases damage and healing done by magical spells and effects by up to 29
    local spellPower = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_POWER);
    if (spellPower) then
        self:AddItemProperty(GU_PROPERTY_SPELL_POWER, spellPower);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_POWER");
        return true;
    end
    
    -- Spell healing. Example: Increases healing done by spells and effects by up to 21
    local spellHealing = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_HEALING);
    if (spellHealing) then
        self:AddItemProperty(GU_PROPERTY_SPELL_HEALING, spellHealing);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_HEALING");
        return true;
    end

    -- Spell damage for type. Example: Increases damage done by Frost spells and effects by up to 21
    local spellDamageType, spellDamageTypeValue = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_DAMAGE_TYPE);
    if (spellDamageType and spellDamageTypeValue) then
        if (Misc:Contains(GU_DAMAGE_TYPES, spellDamageType)) then
            local property = spellDamageType .. " " .. GU_PROPERTY_SPELL_DAMAGE;
            self:AddItemProperty(property, spellDamageTypeValue);
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_DAMAGE_TYPE");
            return true;
        else
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported spell damage type found '%s' for: %s", spellDamageType, equipEffect);
            return false;
        end
    end
    
    -- Spell critical strike chance. Example: Improves your chance to get a critical strike with spells by 1%.
    local spellCritChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_CRITICAL_STRIKE_CHANCE);
    if (spellCritChance) then
        self:AddItemProperty(GU_PROPERTY_SPELL_CRITICAL_STRIKE_CHANCE, spellCritChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_CRITICAL_STRIKE_CHANCE");
        return true;
    end
    
    -- Spell hit chance. Example: Improves your chance to hit with spells by 1%.
    local spellHitChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_HIT_CHANCE);
    if (spellHitChance) then
        self:AddItemProperty(GU_PROPERTY_SPELL_HIT_CHANCE, spellHitChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_HIT_CHANCE");
        return true;
    end
    
    -- Spell resistance decrease. Example: Decreases the magical resistances of your spell targets by 10.
    local spellResistanceDecrease = equipEffect:match(GU_REGEX_EQUIP_EFFECT_SPELL_RESISTANCE_DECREASE);
    if (spellResistanceDecrease) then
        self:AddItemProperty(GU_PROPERTY_SPELL_RESISTANCE_DECREASE, spellResistanceDecrease);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_SPELL_RESISTANCE_DECREASE");
        return true;
    end

    -- Healing per second. Example: Restores 3 health every 4 sec
    local healthRestored, healthSeconds = equipEffect:match(GU_REGEX_EQUIP_EFFECT_HPS);
    if (healthRestored and healthSeconds) then
        local hps = tonumber(healthRestored) / tonumber(healthSeconds);
        self:AddItemProperty(GU_PROPERTY_HPS, hps);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_HPS");
        return true;
    end

    -- Health per 5 second. Example: Restores 5 health per 5 sec
    local hp5 = equipEffect:match(GU_REGEX_EQUIP_EFFECT_HP5);
    if (hp5) then
        self:AddItemProperty(GU_PROPERTY_HP5, hp5);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_HP5");
        return true;
    end

    -- Mana per 5 second. Example: Restores 5 mana per 5 sec
    local mp5 = equipEffect:match(GU_REGEX_EQUIP_EFFECT_MP5);
    if (mp5) then
        self:AddItemProperty(GU_PROPERTY_MP5, mp5);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_MP5");
        return true;
    end

    -- Critical strike chance. Example: Improves your chance to get a critical strike by 1%.
    local critStrikeChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_CRITICAL_STRIKE_CHANCE);
    if (critStrikeChance) then
        self:AddItemProperty(GU_PROPERTY_CRITICAL_STRIKE_CHANCE, critStrikeChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_CRITICAL_STRIKE_CHANCE");
        return true;
    end

    -- Hit chance. Example: Improves your chance to hit by 1%.
    local hitChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_HIT_CHANCE);
    if (hitChance) then
        self:AddItemProperty(GU_PROPERTY_HIT_CHANCE, hitChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_HIT_CHANCE");
        return true;
    end    
    
    -- Attack power vs. enemy type. Example:  +30 Attack Power when fighting Undead | Attack Power increased by 18 when fighting Beasts
    local apTypeValue, apType = equipEffect:match(GU_REGEX_EQUIP_EFFECT_AP_TYPE);
    if (not apTypeValue or not apType) then
        apTypeValue, apType = equipEffect:match(GU_REGEX_EQUIP_EFFECT_AP_TYPE2);
    end
    if (apTypeValue and apType) then
        if (Misc:Contains(GU_PROPERTY_ENEMY_TYPES, apType)) then
            local property = apType .. " " .. GU_PROPERTY_ATTACK_POWER;
            self:AddItemProperty(property, apTypeValue);
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_AP_TYPE");
            return true;
        else
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported enemy type found '%s' for: %s", apType, equipEffect);
            return false;
        end
    end

    -- Attack power. Example: +20 Attack Power
    local ap = equipEffect:match(GU_REGEX_EQUIP_EFFECT_AP);
    if (ap) then
        self:AddItemProperty(GU_PROPERTY_ATTACK_POWER, ap);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_AP");
        return true;
    end

    -- Ranged attack speed. Example: Increases ranged attack speed by 10%.
    local rangedAttackSpeed = equipEffect:match(GU_REGEX_EQUIP_EFFECT_RANGED_ATTACK_SPEED);
    if (rangedAttackSpeed) then
        self:AddItemProperty(GU_PROPERTY_RANGED_ATTACK_SPEED, rangedAttackSpeed);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_RANGED_ATTACK_SPEED");
        return true;
    end

    -- Ranged attack power. Example: +14 ranged Attack Power.
    local rangedAttackPower = equipEffect:match(GU_REGEX_EQUIP_EFFECT_RANGED_ATTACK_POWER);
    if (rangedAttackPower) then
        self:AddItemProperty(GU_PROPERTY_RANGED_ATTACK_POWER, rangedAttackPower);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_RANGED_ATTACK_POWER");
        return true;
    end

    -- Defense. Example: Increased Defense +5
    local defense = equipEffect:match(GU_REGEX_EQUIP_EFFECT_DEFENSE);
    if (defense) then
        self:AddItemProperty(GU_PROPERTY_DEFENSE, defense);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_DEFENSE");
        return true;
    end

    -- Block chance. Example: Increases your chance to block attacks with a shield by 2%
    local blockChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_BLOCK_CHANCE);
    if (blockChance) then
        self:AddItemProperty(GU_PROPERTY_BLOCK_CHANCE, blockChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_BLOCK_CHANCE");
        return true;
    end

    -- Block value. Example: Increases the block value of your shield by 27.
    local blockValue = equipEffect:match(GU_REGEX_EQUIP_EFFECT_BLOCK_VALUE);
    if (blockValue) then
        self:AddItemProperty(GU_PROPERTY_BLOCK_VALUE, blockValue);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_BLOCK_VALUE");
        return true;
    end

    -- Dodge. Example: Increases your chance to dodge an attack by 1%.
    local dodgeChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_DODGE_CHANCE);
    if (dodgeChance) then
        self:AddItemProperty(GU_PROPERTY_DODGE_CHANCE, dodgeChance);
        Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_DODGE_CHANCE");
        return true;
    end

    -- Parry chance. Example: Increases/Decreases your chance to parry an attack by 1%.
    local parry, parryChance = equipEffect:match(GU_REGEX_EQUIP_EFFECT_PARRY_CHANCE);
    if (parry and parryChance) then
        if (parry == "Increases" or parry == "Decreases") then
            if (parry == "Decreases") then
                parryChance = tonumber(parryChance) * -1;
            end
            self:AddItemProperty(GU_PROPERTY_PARRY_CHANCE, parryChance);
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_PARRY_CHANCE");
            return true;
        else
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported parry type found '%s' for: %s", parry, equipEffect);
            return false;
        end
    end

    local weaponSkillResult = 1;
    local professionSkillResult = 1;

    -- Weapon skill. Example: Increased Two-handed Axes +2
    local weaponSkill, weaponSkillValue = equipEffect:match(GU_REGEX_EQUIP_EFFECT_WEAPON_SKILL);
    if (weaponSkill and weaponSkillValue) then
        weaponSkillResult = 2;
        if (Misc:Contains(GU_PROPERTY_WEAPON_SKILLS, weaponSkill)) then
            self:AddItemProperty(weaponSkill, tonumber(weaponSkillValue));
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_WEAPON_SKILL");
            return true;
        else
            weaponSkillResult = 3;
        end
    end

    -- Profession skill. Example: Increased Fishing +2
    local professionSkill, professionSkillValue = equipEffect:match(GU_REGEX_EQUIP_EFFECT_PROFESSION_SKILL);
    if (professionSkill and professionSkillValue) then
        professionSkillResult = 2;
        if (Misc:Contains(GU_RECIPE_SUBTYPES, professionSkill)) then
            self:AddItemProperty(professionSkill, tonumber(professionSkillValue));
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_PROFESSION_SKILL");
            return true;
        else
            professionSkillResult = 3;
        end
    end

    if (weaponSkillResult ~= 2 and professionSkillResult ~= 2) then
        if (weaponSkillResult == 3) then
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported weapon skill type found '%s' for: %s", weaponSkill, equipEffect);
            return false;        
        elseif (professionSkillResult == 3) then
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported profession skill type found '%s' for: %s", professionSkill, equipEffect);
            return false;        
        end
    end

    -- Profession skill #2. Example: Herbalism +5
    professionSkill, professionSkillValue = equipEffect:match(GU_REGEX_EQUIP_EFFECT_PROFESSION_SKILL2);
    if (professionSkill and professionSkillValue) then
        if (Misc:Contains(GU_RECIPE_SUBTYPES, professionSkill)) then
            self:AddItemProperty(professionSkill, tonumber(professionSkillValue));
            Logger:Verb("-- Tooltip line '%s' matched against regex %s", equipEffect, "GU_REGEX_EQUIP_EFFECT_PROFESSION_SKILL2");
            return true;
        else
            Logger:Err("Data:ProcessItemTooltipLineEquipEffect Unsupported profession skill type found '%s' for: %s", professionSkill, equipEffect);
            return false;        
        end
    end

    local customEquipEffects = {
        "When struck in combat has a 1% chance of inflicting 50 Frost damage to the attacker and freezing them for 5 sec.",
        "When struck in combat has a 1% chance of inflicting 75 to 125 Shadow damage to the attacker.",
        "When struck in combat has a 3% chance of stealing 35 life from target enemy.",
        "When struck in combat has a 1% chance of dealing 75 to 125 Fire damage to all targets around you.",
        "When struck in combat has a 1% chance of raising a thorny shield that inflicts 3 Nature damage to attackers when hit and increases Nature resistance by 50 for 30 sec.",
        "When struck in combat has a 3% chance to encase the caster in bone, increasing armor by 150 for 20 sec.",
        "When struck by a melee attacker, that attacker has a 5% chance of being put to sleep for 10 sec.  Only affects enemies level 50 and below.",
        "When struck in combat has a 1% chance of inflicting 105 to 175 Shadow damage to the attacker.",
        "When struck in combat has a 3% chance to heal you for 60 to 100.",
        "When struck in combat has a 5% chance of inflicting 35 to 65 Nature damage to the attacker.",
        "When struck in combat inflicts 3 Arcane damage to the attacker.",      -- TODO Property?
        "When struck in combat has a 1% chance of reducing all melee damage taken by 25 for 10 sec.",
        "When struck has a 3% chance of stealing 120 life from the attacker over 4 sec.",
        "When struck in combat has a 5% chance to make you invulnerable to melee damage for 3 sec. This effect can only occur once every 30 sec.",
        "When struck in combat has a 1% chance of increasing all party member's armor by 250 for 30 sec.",
        "When shapeshifting into Cat form the Druid gains 20 energy, when shapeshifting into Bear form the Druid gains 5 rage.",
        "Enchants the main hand weapon with fire, granting each attack a chance to deal 25 to 35 additional fire damage.",
        "Have a 2% chance when struck in combat of increasing armor by 350 for 15 sec.",
        "Has a 2% chance when struck in combat of protecting you with a holy shield.",
        "Has a 1% chance when struck in combat of increasing chance to block by 50% for 10 sec.",
        "Chance to strike your ranged target with a Flaming Cannonball for 33 to 49 Fire damage.",
        "Chance to strike your target with a Frost Arrow for 31 to 45 Frost damage.",
        "Chance to strike your ranged target with a Searing Arrow for 18 to 26 Fire damage.",
        "Chance to strike your ranged target with a Venom Shot for 31 to 45 Nature damage.",
        "Chance to strike your ranged target with a Fire Blast for 12 to 18 Fire damage.",
        "Chance to strike your ranged target with a Quill Shot for 66 to 98 Nature damage.",
        "Chance to strike your ranged target with a Shadowbolt for 13 to 19 Shadow damage.",
        "Chance to strike your ranged target with a Flaming Shell for 18 to 26 Fire damage.",
        "Chance to strike your ranged target with Shadow Shot for 18 to 26 Shadow damage.",
        "Deals 5 Fire damage to anyone who strikes you with a melee attack.",
        "Deals 60 to 90 damage when you are the victim of a critical melee strike.",
        "Deals damage and drains 100 to 500 mana every second if you are not worthy.",
        "Deals 5 to 35 damage every time you block.",
        "Increases your lockpicking skill slightly.",
        "Nearby elven gems appear on the minimap.",
        "Nearby Gahz'ridian appears on the minimap.",
        "Increase the Spirit of nearby party members by 4.",
        "Increases swim speed by 15%.",
        "Increases your effective stealth level by 1.",     -- TODO Make this a property
        "Increases your stealth detection.",    -- TODO Make this a property,
        "Increases Defense by 3, Shadow resistance by 10 and your normal health regeneration by 3.",    -- TODO Properties?
        "Increases mount speed by 3%.",     -- TODO Make this a property,
        "Increases movement speed and life regeneration rate.",
        "Increases your resistance to silence effects by 7%.",
        "Increases the damage absorbed by your Mana Shield by 285.",    -- TODO Spell/Abilities properties?
        "Increases the duration of your Sprint ability by 3 sec.",  -- TODO ^
        "Increases the Holy damage bonus of your Judgement of the Crusader by 20.", -- TODO ^
        "Increases the damage done by your Multi-Shot by 4%.",  -- TODO ^
        "Increases the speed of your Ghost Wolf ability by 15%.",   -- TODO ^
        "Slightly increases your stealth detection.",
        "Improves your chance to get a critical strike with missile weapons by 1%.",    -- TODO Make this a property.
        "5% chance of dealing 15 to 25 Fire damage on a successful melee attack.",
        "2% chance on melee hit to gain 1 extra attack.",
        "Allows underwater breathing.",
        "Impress others with your fashion sense.",
        "Adds 4 fire damage to your weapon attack.",
        "Adds 3 Lightning damage to your melee attacks.",
        "Immune to Disarm.",    -- TODO Property?
        "Grants a chance on striking the enemy for 50 to 70 Fire damage.",
        "Reduces the cooldown of your Fade ability by 2 sec.",   -- TODO Property for spell cooldown reduction?
        "Reduces the mana cost of your Arcane Shot by 15.",     -- TODO Property for spell cost reduction?
        "Hamstring Rage cost reduced by 3.",        -- TODO ^
        "Protects the wearer from being fully engulfed by Shadow Flame.",
        "Restores 150 mana or 20 rage when you kill a target that gives experience; this effect cannot occur more than once every 10 seconds.",
    }

    for k,v in pairs(customEquipEffects) do
        if (equipEffect == v) then
            table.insert(self.tempParsedItem.equipEffects, equipEffect);
            Logger:Verb("-- Tooltip line '%s' matched against custom equip effect.", equipEffect);
            return true;
        end
    end
    
    local stoneEffects = {
        "Enchants the main hand weapon with fire, granting each attack a chance to deal (%d+) to (%d+) additional fire damage"
    }

    for k,v in pairs(stoneEffects) do
        if (equipEffect:match(v)) then
            table.insert(self.tempParsedItem.equipEffects, equipEffect);
            Logger:Verb("-- Tooltip line '%s' matched against custom stone effect.", equipEffect);
            return true;
        end
    end

    Logger:Err("Data:ProcessItemTooltipLineEquipEffect Could not parse equip effect from tooltip line: %s", equipEffect);
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