-- #TODO Copyright here

local L = AceLocale:GetLocale("GU");

----------------------------------------------------------
-- Item types
-- Source https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

TYPE_ARMOR = "Armor";
TYPE_CONSUMABLE = "Consumable";
TYPE_CONTAINER = "Container";
TYPE_GEM = "Gem";
TYPE_KEY = "Key";
TYPE_MISC = "Miscellaneous";
TYPE_MONEY = "Money";
TYPE_REAGENT = "Reagent";
TYPE_RECIPE = "Recipe";
TYPE_PROJECTILE = "Projectile";
TYPE_QUEST = "Quest";
TYPE_QUIVER = "Quiver";
TYPE_TRADE_GOODS = "Trade Goods";
TYPE_WEAPON = "Weapon";

----------------------------------------------------------
-- Item subtypes
-- Source: https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

SUBTYPE_MISC = "Miscellaneous";
SUBTYPE_CLOTH = "Cloth";
SUBTYPE_LEATHER = "Leather";
SUBTYPE_MAIL = "Mail";
SUBTYPE_PLATE = "Plate";
SUBTYPE_SHIELDS = "Shields";
SUBTYPE_LIBRAMS = "Librams";
SUBTYPE_IDOLS = "Idols";
SUBTYPE_TOTEMS = "Totems";
SUBTYPE_SIGILS = "Sigils";

SUBTYPE_FOOD_DRINK = "Food & Drink";
SUBTYPE_POTION = "Potion";
SUBTYPE_ELIXIR = "Elixir";
SUBTYPE_FLASK = "Flask";
SUBTYPE_BANDAGE = "Bandage";
SUBTYPE_ITEM_ENHANCEMENT = "Item Enhancement";
SUBTYPE_SCROLL = "Scroll";
SUBTYPE_OTHER = "Other";
SUBTYPE_CONSUMABLE = "Consumable";

SUBTYPE_BAG = "Bag";
SUBTYPE_ENCHANTING_BAG = "Enchanting Bag";
SUBTYPE_ENGINEERING_BAG = "Engineering Bag";
SUBTYPE_GEM_BAG = "Gem Bag";
SUBTYPE_HERB_BAG = "Herb Bag";
SUBTYPE_LEATHERWORKING_BAG = "Leatherworking Bag";
SUBTYPE_MINING_BAG = "Mining Bag";
SUBTYPE_SOUL_BAG = "Soul Bag";

SUBTYPE_BLUE = "Blue";
SUBTYPE_GREEN = "Green";
SUBTYPE_ORANGE = "Orange";
SUBTYPE_META = "Meta";
SUBTYPE_PRISMATIC = "Prismatic";
SUBTYPE_PURPLE = "Purple";
SUBTYPE_RED = "Red";
SUBTYPE_SIMPLE = "Simple";
SUBTYPE_YELLOW = "Yellow";
SUBTYPE_ARTIFACT_RELIC = "Artifact Relic";

SUBTYPE_KEY = "Key";

SUBTYPE_JUNK = "Junk";
SUBTYPE_REAGENT = "Reagent";
SUBTYPE_PET = "Pet";
SUBTYPE_HOLIDAY = "Holiday";
SUBTYPE_MOUNT = "Mount";
SUBTYPE_OTHER = "Other";

SUBTYPE_REAGENT = "Reagent";

SUBTYPE_ALCHEMY = "Alchemy";
SUBTYPE_BLACKSMITHING = "Blacksmithing";
SUBTYPE_BOOK = "Book";
SUBTYPE_COOKING = "Cooking";
SUBTYPE_ENCHANTING = "Enchanting";
SUBTYPE_ENGINEERING = "Engineering";
SUBTYPE_FIRST_AID = "First Aid";
SUBTYPE_INSCRIPTION = "Inscription";
SUBTYPE_LEATHERWORKING = "Leatherworking";
SUBTYPE_TAILORING = "Tailoring";

SUBTYPE_ARROW = "Arrow";
SUBTYPE_BULLET = "Bullet";

SUBTYPE_QUEST = "Quest";

SUBTYPE_AMMO_POUCH = "Ammo Pouch";
SUBTYPE_QUIVER = "Quiver";

SUBTYPE_ARMOR_ENCHANTMENT = "Armor Enchantment";
SUBTYPE_CLOTH = "Cloth";
SUBTYPE_DEVICES = "Devices";
SUBTYPE_ELEMENTAL = "Elemental";
SUBTYPE_ENCHANTING = "Enchanting";
SUBTYPE_EXPLOSIVES = "Explosives";
SUBTYPE_HERB = "Herb";
SUBTYPE_JEWELCRAFTING = "Jewelcrafting";
SUBTYPE_LEATHER = "Leather";
SUBTYPE_MATERIALS = "Materials";
SUBTYPE_MEAT = "Meat";
SUBTYPE_METAL_STONE = "Metal & Stone";
SUBTYPE_OTHER = "Other";
SUBTYPE_PARTS = "Parts";
SUBTYPE_TRADE_GOODS = "Trade Goods";
SUBTYPE_WEAPON_ENCHANTMENT = "Weapon Enchantment";

SUBTYPE_BOWS = "Bows";
SUBTYPE_CROSSBOWS = "Crossbows";
SUBTYPE_DAGGERS = "Daggers";
SUBTYPE_GUNS = "Guns";
SUBTYPE_FISHING_POLES = "Fishing Poles";
SUBTYPE_FIST_WEAPONS = "Fist Weapons";
SUBTYPE_MISC = "Miscellaneous";
SUBTYPE_ONE_HANDED_AXES = "One-Handed Axes";
SUBTYPE_ONE_HANDED_MACES = "One-Handed Maces";
SUBTYPE_ONE_HANDED_SWORDS = "One-Handed Swords";
SUBTYPE_POLEARMS = "Polearms";
SUBTYPE_STAVES = "Staves";
SUBTYPE_THROWN = "Thrown";
SUBTYPE_TWO_HANDED_AXES = "Two-Handed Axes";
SUBTYPE_TWO_HANDED_MACES = "Two-Handed Maces";
SUBTYPE_TWO_HANDED_SWORDS = "Two-Handed Swords";
SUBTYPE_WANDS = "Wands";
SUBTYPE_ONE_HAND = "One-Hand";
SUBTYPE_TWO_HAND = "Two-Hand";

----------------------------------------------------------
-- Classes
----------------------------------------------------------

CLASS_DEATHKNIGHT = "Death Knight";
CLASS_DEMONHUNTER = "Demon Hunter";
CLASS_DRUID = "Druid";
CLASS_HUNTER = "Hunter";
CLASS_MAGE = "Mage";
CLASS_MONK = "Monk";
CLASS_PALADIN = "Paladin";
CLASS_PRIEST = "Priest";
CLASS_ROGUE = "Rogue";
CLASS_SHAMAN = "Shaman";
CLASS_WARLOCK = "Warlock";
CLASS_WARRIOR = "Warrior";

----------------------------------------------------------
-- Damage types
----------------------------------------------------------

DAMAGE_TYPE_PHYSICAL = "Physical";
DAMAGE_TYPE_ARCANE = "Arcane";
DAMAGE_TYPE_FIRE = "Fire";
DAMAGE_TYPE_FROST = "Frost";
DAMAGE_TYPE_NATURE = "Nature";
DAMAGE_TYPE_HOLY = "Holy";
DAMAGE_TYPE_SHADOW = "Shadow";

----------------------------------------------------------
-- Equipment slots
----------------------------------------------------------

SLOT_HEAD = "Head";
SLOT_NECK = "Neck";
SLOT_SHOULDER = "Shoulder";
SLOT_BACK = "Back";
SLOT_CHEST = "Chest";
SLOT_SHIRT = "Shirt";
SLOT_TABARD = "Tabard";
SLOT_WRIST = "Wrist";
SLOT_HANDS = "Hands";
SLOT_WAIST = "Waist";
SLOT_LEGS = "Legs";
SLOT_FEET = "Feet";
SLOT_FINGER = "Finger";
SLOT_TRINKET = "Trinket";
SLOT_OFF_HAND = "Off-Hand";
SLOT_ONE_HAND = "One-Hand";
SLOT_TWO_HAND = "Two-Hand";
SLOT_MAIN_HAND = "Main-Hand";
SLOT_RANGED = "Ranged";
SLOT_SPECIAL = "Special";

----------------------------------------------------------
-- Properties
----------------------------------------------------------

PROPERTY_DAMAGE_MIN = "Max Damage";
PROPERTY_DAMAGE_MAX = "Min Damage";
PROPERTY_DAMAGE_TYPE = "Damage Type";
PROPERTY_EXTRA_DAMAGE_MIN = "Min Extra Damage";
PROPERTY_EXTRA_DAMAGE_MAX = "Max Extra Damage";
PROPERTY_EXTRA_DAMAGE_TYPE = "Extra Damage Type";
PROPERTY_DAMAGE_SPEED = "Speed";
PROPERTY_DPS = "DPS";
PROPERTY_ARMOR = "Armor";
PROPERTY_BLOCK = "Block";

PROPERTY_RESISTANCE = "Resistance";
PROPERTY_RESISTANCE_ARCANE = "Arcane Resistance";
PROPERTY_RESISTANCE_FIRE = "Fire Resistance";
PROPERTY_RESISTANCE_FROST = "Frost Resistance";
PROPERTY_RESISTANCE_NATURE = "Nature Resistance";
PROPERTY_RESISTANCE_SHADOW = "Shadow Resistance";

PROPERTY_STRENGTH = "Strength";
PROPERTY_STAMINA = "Stamina";
PROPERTY_AGILITY = "Agility";
PROPERTY_INTELLECT = "Intellect";
PROPERTY_SPIRIT = "Spirit";

PROPERTY_LEVEL_REQUIRED = "Level Required";
PROPERTY_SOULBOUND = "Soulbound";
PROPERTY_BOP = "Binds when picked up";
PROPERTY_BOE = "Binds when equipped";
PROPERTY_UNIQUE = "Unique";

----------------------------------------------------------
-- Regex
----------------------------------------------------------

REGEX_REMOVE_EDGE_SPACES = "%s*(.*)%s*";

if L then

REGEX_SOULBOUND = L["PROPERTY_SOULBOUND"];
REGEX_BOP = L["PROPERTY_BOP"];
REGEX_BOE = L["PROPERTY_BOE"];
REGEX_UNIQUE = L["PROPERTY_UNIQUE"];

REGEX_HEAD = L["REGEX_HEAD"] .. ".*";
REGEX_NECK = L["SLOT_NECK"];
REGEX_SHOULDER = L["SLOT_SHOULDER"] .. ".*";
REGEX_BACK = L["SLOT_BACK"];
REGEX_CHEST = L["SLOT_CHEST"] .. ".*";
REGEX_SHIRT = L["SLOT_SHIRT"];
REGEX_TABARD = L["SLOT_TABARD"];
REGEX_WRIST = L["SLOT_WRIST"] .. ".*";
REGEX_HANDS = L["SLOT_HANDS"] .. ".*";
REGEX_WAIST = L["SLOT_WAIST"] .. ".*";
REGEX_LEGS = L["SLOT_LEGS"] .. ".*";
REGEX_FEET = L["SLOT_FEET"] .. ".*";
REGEX_FINGER = L["SLOT_FINGER"];
REGEX_TRINKET = L["SLOT_TRINKET"];
REGEX_OFF_HAND = L["SLOT_OFF_HAND"] .. ".*";
REGEX_ONE_HAND = L["SLOT_ONE_HAND"] .. ".*";
REGEX_TWO_HAND = L["SLOT_TWO_HAND"] .. ".*";
REGEX_MAIN_HAND = L["SLOT_MAIN_HAND"] .. ".*"; 



end