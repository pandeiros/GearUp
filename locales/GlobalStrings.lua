-- #TODO Copyright here

local L = GU_AceLocale:GetLocale("GU");

if (not GU_DEV_MODE_ENABLED) then return; end

----------------------------------------------------------
-- Item types
-- Source https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

GU_TYPE_ARMOR = "Armor";
GU_TYPE_CONSUMABLE = "Consumable";
GU_TYPE_CONTAINER = "Container";
GU_TYPE_GEM = "Gem";
GU_TYPE_KEY = "Key";
GU_TYPE_MISC = "Miscellaneous";
GU_TYPE_MONEY = "Money";
GU_TYPE_REAGENT = "Reagent";
GU_TYPE_RECIPE = "Recipe";
GU_TYPE_PROJECTILE = "Projectile";
GU_TYPE_QUEST = "Quest";
GU_TYPE_QUIVER = "Quiver";
GU_TYPE_TRADE_GOODS = "Trade Goods";
GU_TYPE_WEAPON = "Weapon";

----------------------------------------------------------
-- Item subtypes
-- Source: https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

GU_SUBTYPE_MISC = "Miscellaneous";
GU_SUBTYPE_CLOTH = "Cloth";
GU_SUBTYPE_LEATHER = "Leather";
GU_SUBTYPE_MAIL = "Mail";
GU_SUBTYPE_PLATE = "Plate";
GU_SUBTYPE_SHIELDS = "Shields";
GU_SUBTYPE_LIBRAMS = "Librams";
GU_SUBTYPE_IDOLS = "Idols";
GU_SUBTYPE_TOTEMS = "Totems";
GU_SUBTYPE_SIGILS = "Sigils";

GU_SUBTYPE_FOOD_DRINK = "Food & Drink";
GU_SUBTYPE_POTION = "Potion";
GU_SUBTYPE_ELIXIR = "Elixir";
GU_SUBTYPE_FLASK = "Flask";
GU_SUBTYPE_BANDAGE = "Bandage";
GU_SUBTYPE_ITEM_ENHANCEMENT = "Item Enhancement";
GU_SUBTYPE_SCROLL = "Scroll";
GU_SUBTYPE_OTHER = "Other";
GU_SUBTYPE_CONSUMABLE = "Consumable";

GU_SUBTYPE_BAG = "Bag";
GU_SUBTYPE_ENCHANTING_BAG = "Enchanting Bag";
GU_SUBTYPE_ENGINEERING_BAG = "Engineering Bag";
GU_SUBTYPE_GEM_BAG = "Gem Bag";
GU_SUBTYPE_HERB_BAG = "Herb Bag";
GU_SUBTYPE_LEATHERWORKING_BAG = "Leatherworking Bag";
GU_SUBTYPE_MINING_BAG = "Mining Bag";
GU_SUBTYPE_SOUL_BAG = "Soul Bag";

GU_SUBTYPE_BLUE = "Blue";
GU_SUBTYPE_GREEN = "Green";
GU_SUBTYPE_ORANGE = "Orange";
GU_SUBTYPE_META = "Meta";
GU_SUBTYPE_PRISMATIC = "Prismatic";
GU_SUBTYPE_PURPLE = "Purple";
GU_SUBTYPE_RED = "Red";
GU_SUBTYPE_SIMPLE = "Simple";
GU_SUBTYPE_YELLOW = "Yellow";
GU_SUBTYPE_ARTIFACT_RELIC = "Artifact Relic";

GU_SUBTYPE_KEY = "Key";

GU_SUBTYPE_JUNK = "Junk";
GU_SUBTYPE_REAGENT = "Reagent";
GU_SUBTYPE_PET = "Pet";
GU_SUBTYPE_HOLIDAY = "Holiday";
GU_SUBTYPE_MOUNT = "Mount";
GU_SUBTYPE_OTHER = "Other";

GU_SUBTYPE_REAGENT = "Reagent";

GU_SUBTYPE_ALCHEMY = "Alchemy";
GU_SUBTYPE_BLACKSMITHING = "Blacksmithing";
GU_SUBTYPE_BOOK = "Book";
GU_SUBTYPE_COOKING = "Cooking";
GU_SUBTYPE_ENCHANTING = "Enchanting";
GU_SUBTYPE_ENGINEERING = "Engineering";
GU_SUBTYPE_FIRST_AID = "First Aid";
GU_SUBTYPE_INSCRIPTION = "Inscription";
GU_SUBTYPE_LEATHERWORKING = "Leatherworking";
GU_SUBTYPE_TAILORING = "Tailoring";

GU_SUBTYPE_ARROW = "Arrow";
GU_SUBTYPE_BULLET = "Bullet";

GU_SUBTYPE_QUEST = "Quest";

GU_SUBTYPE_AMMO_POUCH = "Ammo Pouch";
GU_SUBTYPE_QUIVER = "Quiver";

GU_SUBTYPE_ARMOR_ENCHANTMENT = "Armor Enchantment";
GU_SUBTYPE_CLOTH = "Cloth";
GU_SUBTYPE_DEVICES = "Devices";
GU_SUBTYPE_ELEMENTAL = "Elemental";
GU_SUBTYPE_ENCHANTING = "Enchanting";
GU_SUBTYPE_EXPLOSIVES = "Explosives";
GU_SUBTYPE_HERB = "Herb";
GU_SUBTYPE_JEWELCRAFTING = "Jewelcrafting";
GU_SUBTYPE_LEATHER = "Leather";
GU_SUBTYPE_MATERIALS = "Materials";
GU_SUBTYPE_MEAT = "Meat";
GU_SUBTYPE_METAL_STONE = "Metal & Stone";
GU_SUBTYPE_OTHER = "Other";
GU_SUBTYPE_PARTS = "Parts";
GU_SUBTYPE_TRADE_GOODS = "Trade Goods";
GU_SUBTYPE_WEAPON_ENCHANTMENT = "Weapon Enchantment";

GU_SUBTYPE_BOWS = "Bows";
GU_SUBTYPE_CROSSBOWS = "Crossbows";
GU_SUBTYPE_DAGGERS = "Daggers";
GU_SUBTYPE_GUNS = "Guns";
GU_SUBTYPE_FISHING_POLES = "Fishing Poles";
GU_SUBTYPE_FIST_WEAPONS = "Fist Weapons";
GU_SUBTYPE_MISC = "Miscellaneous";
GU_SUBTYPE_ONE_HANDED_AXES = "One-Handed Axes";
GU_SUBTYPE_ONE_HANDED_MACES = "One-Handed Maces";
GU_SUBTYPE_ONE_HANDED_SWORDS = "One-Handed Swords";
GU_SUBTYPE_POLEARMS = "Polearms";
GU_SUBTYPE_STAVES = "Staves";
GU_SUBTYPE_THROWN = "Thrown";
GU_SUBTYPE_TWO_HANDED_AXES = "Two-Handed Axes";
GU_SUBTYPE_TWO_HANDED_MACES = "Two-Handed Maces";
GU_SUBTYPE_TWO_HANDED_SWORDS = "Two-Handed Swords";
GU_SUBTYPE_WANDS = "Wands";
GU_SUBTYPE_ONE_HAND = "One-Hand";
GU_SUBTYPE_TWO_HAND = "Two-Hand";

----------------------------------------------------------
-- Classes
----------------------------------------------------------

GU_CLASS_DEATHKNIGHT = "Death Knight";
GU_CLASS_DEMONHUNTER = "Demon Hunter";
GU_CLASS_DRUID = "Druid";
GU_CLASS_HUNTER = "Hunter";
GU_CLASS_MAGE = "Mage";
GU_CLASS_MONK = "Monk";
GU_CLASS_PALADIN = "Paladin";
GU_CLASS_PRIEST = "Priest";
GU_CLASS_ROGUE = "Rogue";
GU_CLASS_SHAMAN = "Shaman";
GU_CLASS_WARLOCK = "Warlock";
GU_CLASS_WARRIOR = "Warrior";

GU_CLASSES = {
    L["CLASS_DEATHKNIGHT"],
    L["CLASS_DEMONHUNTER"],
    L["CLASS_DRUID"],
    L["CLASS_HUNTER"],
    L["CLASS_MAGE"],
    L["CLASS_MONK"],
    L["CLASS_PALADIN"],
    L["CLASS_PRIEST"],
    L["CLASS_ROGUE"],
    L["CLASS_SHAMAN"],
    L["CLASS_WARLOCK"],
    L["CLASS_WARRIOR"]
}

----------------------------------------------------------
-- Damage types
----------------------------------------------------------

GU_DAMAGE_TYPE_PHYSICAL = "Physical";
GU_DAMAGE_TYPE_ARCANE = "Arcane";
GU_DAMAGE_TYPE_FIRE = "Fire";
GU_DAMAGE_TYPE_FROST = "Frost";
GU_DAMAGE_TYPE_NATURE = "Nature";
GU_DAMAGE_TYPE_HOLY = "Holy";
GU_DAMAGE_TYPE_SHADOW = "Shadow";

-- This should contain all elemental damage types AND their varieties (if locale has adjective declension)
GU_ELEMENTAL_DAMAGE_TYPES = {
    L["DAMAGE_TYPE_ARCANE"],
    L["DAMAGE_TYPE_FIRE"],
    L["DAMAGE_TYPE_FROST"],
    L["DAMAGE_TYPE_NATURE"],
    L["DAMAGE_TYPE_HOLY"],
    L["DAMAGE_TYPE_SHADOW"]
    -- HERE INSERT ALL VARIETIES FOR ALL LOCALES NOT COVERED BY L["..."]
    -- Really necessary? Probably these properties are only scanned for enUS locale.
}

----------------------------------------------------------
-- Equipment slots
----------------------------------------------------------

GU_SLOT_HEAD = "Head";
GU_SLOT_NECK = "Neck";
GU_SLOT_SHOULDER = "Shoulder";
GU_SLOT_BACK = "Back";
GU_SLOT_CHEST = "Chest";
GU_SLOT_SHIRT = "Shirt";
GU_SLOT_TABARD = "Tabard";
GU_SLOT_WRIST = "Wrist";
GU_SLOT_HANDS = "Hands";
GU_SLOT_WAIST = "Waist";
GU_SLOT_LEGS = "Legs";
GU_SLOT_FEET = "Feet";
GU_SLOT_FINGER = "Finger";
GU_SLOT_TRINKET = "Trinket";
GU_SLOT_OFF_HAND = "Off-Hand";
GU_SLOT_ONE_HAND = "One-Hand";
GU_SLOT_TWO_HAND = "Two-Hand";
GU_SLOT_MAIN_HAND = "Main-Hand";
GU_SLOT_RANGED = "Ranged";
GU_SLOT_SPECIAL = "Special";

----------------------------------------------------------
-- Properties
----------------------------------------------------------

-- Common
GU_PROPERTY_LEVEL_REQUIRED = "Requires Level";
GU_PROPERTY_DURABILITY = "Durability";
GU_PROPERTY_SOULBOUND = "Soulbound";            -- TODO: potentially not used.
GU_PROPERTY_BOP = "Binds when picked up";
GU_PROPERTY_BOE = "Binds when equipped";
GU_PROPERTY_UNIQUE = "Unique";
GU_PROPERTY_UNIQUE_EQUIPPED = "Unique-Equipped";
GU_PROPERTY_FLAVOR_TEXT = "Flavor Text";

-- Weapon
GU_PROPERTY_DAMAGE_MIN = "Max Damage";
GU_PROPERTY_DAMAGE_MAX = "Min Damage";
GU_PROPERTY_DAMAGE_TYPE = "Damage Type";
GU_PROPERTY_EXTRA_DAMAGE_MIN = "Min Extra Damage";
GU_PROPERTY_EXTRA_DAMAGE_MAX = "Max Extra Damage";
GU_PROPERTY_EXTRA_DAMAGE_TYPE = "Extra Damage Type";
GU_PROPERTY_DAMAGE_SPEED = "Speed";
GU_PROPERTY_DPS = "DPS";

GU_PROPERTY_WEAPON_TYPES = {
    L["PROPERTY_BOW"],
    L["PROPERTY_CROSSBOW"],
    L["PROPERTY_DAGGER"],
    L["PROPERTY_GUN"],
    L["PROPERTY_FISHING_POLE"],
    L["PROPERTY_FIST_WEAPON"],
    L["PROPERTY_AXE"],
    L["PROPERTY_MACE"],
    L["PROPERTY_SWORD"],
    L["PROPERTY_POLEARM"],
    L["PROPERTY_STAFF"],
    L["PROPERTY_THROWN"],
    L["PROPERTY_WAND"]
}

GU_PROPERTY_WEAPON_SLOTS = {
    L["PROPERTY_ONE_HAND"],
    L["PROPERTY_TWO_HAND"],
    L["PROPERTY_MAIN_HAND"],
    L["PROPERTY_OFF_HAND"],
    L["PROPERTY_OFF_HAND_HELD"],
    L["SLOT_RANGED"]
}

-- Armor
GU_PROPERTY_ARMOR = "Armor";
GU_PROPERTY_BLOCK = "Block";

GU_PROPERTY_ARMOR_TYPES = {
    L["PROPERTY_CLOTH"],
    L["PROPERTY_LEATHER"],
    L["PROPERTY_MAIL"],
    L["PROPERTY_PLATE"],
    L["PROPERTY_SHIELD"],
    L["PROPERTY_LIBRAM"],
    L["PROPERTY_IDOL"],
    L["PROPERTY_TOTEM"],
    L["PROPERTY_SIGIL"]
}

GU_PROPERTY_ARMOR_SLOTS = {
    L["SLOT_HEAD"],
    L["SLOT_NECK"],
    L["SLOT_SHOULDER"],
    L["SLOT_BACK"],
    L["SLOT_CHEST"],
    L["SLOT_SHIRT"],
    L["SLOT_TABARD"],
    L["SLOT_WRIST"],
    L["SLOT_HANDS"],
    L["SLOT_WAIST"],
    L["SLOT_LEGS"],
    L["SLOT_FEET"],
    L["SLOT_FINGER"],
    L["SLOT_TRINKET"],
    L["SLOT_RELIC"]
}

-- Equippable
GU_PROPERTY_RESISTANCE = "Resistance";
GU_PROPERTY_RESISTANCE_ARCANE = "Arcane Resistance";
GU_PROPERTY_RESISTANCE_FIRE = "Fire Resistance";
GU_PROPERTY_RESISTANCE_FROST = "Frost Resistance";
GU_PROPERTY_RESISTANCE_NATURE = "Nature Resistance";
GU_PROPERTY_RESISTANCE_SHADOW = "Shadow Resistance";

GU_PROPERTY_STRENGTH = "Strength";
GU_PROPERTY_STAMINA = "Stamina";
GU_PROPERTY_AGILITY = "Agility";
GU_PROPERTY_INTELLECT = "Intellect";
GU_PROPERTY_SPIRIT = "Spirit";

GU_PROPERTY_ATTRIBUTES = {
    L["PROPERTY_STRENGTH"],
    L["PROPERTY_STAMINA"],
    L["PROPERTY_AGILITY"],
    L["PROPERTY_INTELLECT"],
    L["PROPERTY_SPIRIT"]
}

GU_PROPERTY_SPELL_POWER = "Spell Power";
GU_PROPERTY_SPELL_DAMAGE = "Spell Damage";
GU_PROPERTY_SPELL_HEALING = "Spell Healing";

----------------------------------------------------------
-- Regex
----------------------------------------------------------

function GetExactRegexString(pattern)
    return "^" .. pattern .. "$";
end

GU_REGEX_REMOVE_EDGE_SPACES = GetExactRegexString("%s*(.*)%s*");

if L then

-- Common
GU_REGEX_SOULBOUND = GetExactRegexString(L["PROPERTY_SOULBOUND"]);
GU_REGEX_BOP = GetExactRegexString(L["PROPERTY_BOP"]);
GU_REGEX_BOE = GetExactRegexString(L["PROPERTY_BOE"]);
GU_REGEX_UNIQUE = GetExactRegexString(L["PROPERTY_UNIQUE"]);
GU_REGEX_UNIQUE_EQUIPPED = GetExactRegexString(L["REGEX_UNIQUE_EQUIPPED"]);

GU_REGEX_LEVEL_REQUIRED = GetExactRegexString(L["REGEX_LEVEL_REQUIRED"]);
GU_REGEX_DURABILITY = GetExactRegexString(L["REGEX_DURABILITY"]);
GU_REGEX_CLASSES = GetExactRegexString(L["REGEX_CLASSES"]);
GU_REGEX_FLAVOR_TEXT = GetExactRegexString(L["REGEX_FLAVOR_TEXT"]);
GU_REGEX_USE_EFFECT = GetExactRegexString(L["REGEX_USE_EFFECT"]);
GU_REGEX_QUEST_ITEM = GetExactRegexString(L["REGEX_QUEST_ITEM"]);
GU_REGEX_RANDOM_ENCH = GetExactRegexString(L["REGEX_RANDOM_ENCH"]);

-- Equippable
GU_REGEX_EQUIP_ATTRIBUTE = GetExactRegexString(L["REGEX_EQUIP_ATTRIBUTE"]);
GU_REGEX_EQUIP_SET_NAME = GetExactRegexString(L["REGEX_EQUIP_SET_NAME"]);
GU_REGEX_EQUIP_SET_ITEM = GetExactRegexString("(.+)");
GU_REGEX_EQUIP_SET_BONUS = GetExactRegexString(L["REGEX_EQUIP_SET_BONUS"]);
GU_REGEX_EQUIP_SLOT_AND_TYPE = GetExactRegexString(L["REGEX_EQUIP_SLOT_AND_TYPE"]);

GU_REGEX_EQUIP_EQUIP_EFFECT = GetExactRegexString(L["REGEX_EQUIP_EQUIP_EFFECT"]);
GU_REGEX_EQUIP_EQUIP_EFFECT_SPELL_POWER = L["REGEX_EQUIP_EQUIP_EFFECT_SPELL_POWER"];

-- Weapon
GU_REGEX_WEAPON_DAMAGE_AND_SPEED = GetExactRegexString(L["REGEX_WEAPON_DAMAGE_AND_SPEED"]);
GU_REGEX_WEAPON_EXTRA_DAMAGE = GetExactRegexString(L["REGEX_WEAPON_EXTRA_DAMAGE"]);
GU_REGEX_WEAPON_DPS = GetExactRegexString(L["REGEX_WEAPON_DPS"]);
GU_REGEX_WEAPON_CHANCE_ON_HIT = GetExactRegexString(L["REGEX_WEAPON_CHANCE_ON_HIT"]);

-- Armor
GU_REGEX_ARMOR_BLOCK = GetExactRegexString(L["REGEX_ARMOR_BLOCK"]);
GU_REGEX_ARMOR_ARMOR = GetExactRegexString(L["REGEX_ARMOR_ARMOR"]);

-- Other
-- GU_REGEX_HEAD = GetExactRegexString(L["REGEX_HEAD"] .. ".*");
GU_REGEX_NECK = GetExactRegexString(L["SLOT_NECK"]);
GU_REGEX_SHOULDER = GetExactRegexString(L["SLOT_SHOULDER"] .. ".*");
GU_REGEX_BACK = GetExactRegexString(L["SLOT_BACK"]);
GU_REGEX_CHEST = GetExactRegexString(L["SLOT_CHEST"] .. ".*");
GU_REGEX_SHIRT = GetExactRegexString(L["SLOT_SHIRT"]);
GU_REGEX_TABARD = GetExactRegexString(L["SLOT_TABARD"]);
GU_REGEX_WRIST = GetExactRegexString(L["SLOT_WRIST"] .. ".*");
GU_REGEX_HANDS = GetExactRegexString(L["SLOT_HANDS"] .. ".*");
GU_REGEX_WAIST = GetExactRegexString(L["SLOT_WAIST"] .. ".*");
GU_REGEX_LEGS = GetExactRegexString(L["SLOT_LEGS"] .. ".*");
GU_REGEX_FEET = GetExactRegexString(L["SLOT_FEET"] .. ".*");
GU_REGEX_FINGER = GetExactRegexString(L["SLOT_FINGER"]);
GU_REGEX_TRINKET = GetExactRegexString(L["SLOT_TRINKET"]);
GU_REGEX_OFF_HAND = GetExactRegexString(L["SLOT_OFF_HAND"] .. ".*");
GU_REGEX_ONE_HAND = GetExactRegexString(L["SLOT_ONE_HAND"] .. ".*");
GU_REGEX_TWO_HAND = GetExactRegexString(L["SLOT_TWO_HAND"] .. ".*");
GU_REGEX_MAIN_HAND = GetExactRegexString(L["SLOT_MAIN_HAND"] .. ".*"); 

end