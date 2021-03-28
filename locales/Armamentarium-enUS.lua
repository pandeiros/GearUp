-- #TODO Copyright here

local L = AceLocale:NewLocale("Arma", "enUS", true, true);

if L then

----------------------------------------------------------
-- Item types
-- Source https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

L["TYPE_ARMOR"] = "Armor";
L["TYPE_CONSUMABLE"] = "Consumable";
L["TYPE_CONTAINER"] = "Container";
L["TYPE_GEM"] = "Gem";
L["TYPE_KEY"] = "Key";
L["TYPE_MISC"] = "Miscellaneous";
L["TYPE_MONEY"] = "Money";
L["TYPE_REAGENT"] = "Reagent";
L["TYPE_RECIPE"] = "Recipe";
L["TYPE_PROJECTILE"] = "Projectile";
L["TYPE_QUEST"] = "Quest";
L["TYPE_QUIVER"] = "Quiver";
L["TYPE_TRADE_GOODS"] = "Trade Goods";
L["TYPE_WEAPON"] = "Weapon";

----------------------------------------------------------
-- Item subtypes
-- Source: https://wowwiki.fandom.com/wiki/ItemType
----------------------------------------------------------

L["SUBTYPE_MISC"] = "Miscellaneous";
L["SUBTYPE_CLOTH"] = "Cloth";
L["SUBTYPE_LEATHER"] = "Leather";
L["SUBTYPE_MAIL"] = "Mail";
L["SUBTYPE_PLATE"] = "Plate";
L["SUBTYPE_SHIELDS"] = "Shields";
L["SUBTYPE_LIBRAMS"] = "Librams";
L["SUBTYPE_IDOLS"] = "Idols";
L["SUBTYPE_TOTEMS"] = "Totems";
L["SUBTYPE_SIGILS"] = "Sigils";

L["SUBTYPE_FOOD_DRINK"] = "Food & Drink";
L["SUBTYPE_POTION"] = "Potion";
L["SUBTYPE_ELIXIR"] = "Elixir";
L["SUBTYPE_FLASK"] = "Flask";
L["SUBTYPE_BANDAGE"] = "Bandage";
L["SUBTYPE_ITEM_ENHANCEMENT"] = "Item Enhancement";
L["SUBTYPE_SCROLL"] = "Scroll";
L["SUBTYPE_OTHER"] = "Other";
L["SUBTYPE_CONSUMABLE"] = "Consumable";

L["SUBTYPE_BAG"] = "Bag";
L["SUBTYPE_ENCHANTING_BAG"] = "Enchanting Bag";
L["SUBTYPE_ENGINEERING_BAG"] = "Engineering Bag";
L["SUBTYPE_GEM_BAG"] = "Gem Bag";
L["SUBTYPE_HERB_BAG"] = "Herb Bag";
L["SUBTYPE_LEATHERWORKING_BAG"] = "Leatherworking Bag";
L["SUBTYPE_MINING_BAG"] = "Mining Bag";
L["SUBTYPE_SOUL_BAG"] = "Soul Bag";

L["SUBTYPE_BLUE"] = "Blue";
L["SUBTYPE_GREEN"] = "Green";
L["SUBTYPE_ORANGE"] = "Orange";
L["SUBTYPE_META"] = "Meta";
L["SUBTYPE_PRISMATIC"] = "Prismatic";
L["SUBTYPE_PURPLE"] = "Purple";
L["SUBTYPE_RED"] = "Red";
L["SUBTYPE_SIMPLE"] = "Simple";
L["SUBTYPE_YELLOW"] = "Yellow";
L["SUBTYPE_ARTIFACT_RELIC"] = "Artifact Relic";

L["SUBTYPE_KEY"] = "Key";

L["SUBTYPE_JUNK"] = "Junk";
L["SUBTYPE_REAGENT"] = "Reagent";
L["SUBTYPE_PET"] = "Pet";
L["SUBTYPE_HOLIDAY"] = "Holiday";
L["SUBTYPE_MOUNT"] = "Mount";
L["SUBTYPE_OTHER"] = "Other";

L["SUBTYPE_REAGENT"] = "Reagent";

L["SUBTYPE_ALCHEMY"] = "Alchemy";
L["SUBTYPE_BLACKSMITHING"] = "Blacksmithing";
L["SUBTYPE_BOOK"] = "Book";
L["SUBTYPE_COOKING"] = "Cooking";
L["SUBTYPE_ENCHANTING"] = "Enchanting";
L["SUBTYPE_ENGINEERING"] = "Engineering";
L["SUBTYPE_FIRST_AID"] = "First Aid";
L["SUBTYPE_INSCRIPTION"] = "Inscription";
L["SUBTYPE_LEATHERWORKING"] = "Leatherworking";
L["SUBTYPE_TAILORING"] = "Tailoring";

L["SUBTYPE_ARROW"] = "Arrow";
L["SUBTYPE_BULLET"] = "Bullet";

L["SUBTYPE_QUEST"] = "Quest";

L["SUBTYPE_AMMO_POUCH"] = "Ammo Pouch";
L["SUBTYPE_QUIVER"] = "Quiver";

L["SUBTYPE_ARMOR_ENCHANTMENT"] = "Armor Enchantment";
L["SUBTYPE_CLOTH"] = "Cloth";
L["SUBTYPE_DEVICES"] = "Devices";
L["SUBTYPE_ELEMENTAL"] = "Elemental";
L["SUBTYPE_ENCHANTING"] = "Enchanting";
L["SUBTYPE_EXPLOSIVES"] = "Explosives";
L["SUBTYPE_HERB"] = "Herb";
L["SUBTYPE_JEWELCRAFTING"] = "Jewelcrafting";
L["SUBTYPE_LEATHER"] = "Leather";
L["SUBTYPE_MATERIALS"] = "Materials";
L["SUBTYPE_MEAT"] = "Meat";
L["SUBTYPE_METAL_STONE"] = "Metal & Stone";
L["SUBTYPE_OTHER"] = "Other";
L["SUBTYPE_PARTS"] = "Parts";
L["SUBTYPE_TRADE_GOODS"] = "Trade Goods";
L["SUBTYPE_WEAPON_ENCHANTMENT"] = "Weapon Enchantment";

L["SUBTYPE_BOWS"] = "Bows";
L["SUBTYPE_CROSSBOWS"] = "Crossbows";
L["SUBTYPE_DAGGERS"] = "Daggers";
L["SUBTYPE_GUNS"] = "Guns";
L["SUBTYPE_FISHING_POLES"] = "Fishing Poles";
L["SUBTYPE_FIST_WEAPONS"] = "Fist Weapons";
L["SUBTYPE_MISC"] = "Miscellaneous";
L["SUBTYPE_ONE_HANDED_AXES"] = "One-Handed Axes";
L["SUBTYPE_ONE_HANDED_MACES"] = "One-Handed Maces";
L["SUBTYPE_ONE_HANDED_SWORDS"] = "One-Handed Swords";
L["SUBTYPE_POLEARMS"] = "Polearms";
L["SUBTYPE_STAVES"] = "Staves";
L["SUBTYPE_THROWN"] = "Thrown";
L["SUBTYPE_TWO_HANDED_AXES"] = "Two-Handed Axes";
L["SUBTYPE_TWO_HANDED_MACES"] = "Two-Handed Maces";
L["SUBTYPE_TWO_HANDED_SWORDS"] = "Two-Handed Swords";
L["SUBTYPE_WANDS"] = "Wands";
L["SUBTYPE_ONE_HAND"] = "One-Hand";
L["SUBTYPE_TWO_HAND"] = "Two-Hand";

----------------------------------------------------------
-- Classes
----------------------------------------------------------

L["CLASS_DEATHKNIGHT"] = "Death Knight";
L["CLASS_DEMONHUNTER"] = "Demon Hunter";
L["CLASS_DRUID"] = "Druid";
L["CLASS_HUNTER"] = "Hunter";
L["CLASS_MAGE"] = "Mage";
L["CLASS_MONK"] = "Monk";
L["CLASS_PALADIN"] = "Paladin";
L["CLASS_PRIEST"] = "Priest";
L["CLASS_ROGUE"] = "Rogue";
L["CLASS_SHAMAN"] = "Shaman";
L["CLASS_WARLOCK"] = "Warlock";
L["CLASS_WARRIOR"] = "Warrior";

----------------------------------------------------------
-- Damage types
----------------------------------------------------------

L["DAMAGE_TYPE_PHYSICAL"] = "Physical";
L["DAMAGE_TYPE_ARCANE"] = "Arcane";
L["DAMAGE_TYPE_FIRE"] = "Fire";
L["DAMAGE_TYPE_FROST"] = "Frost";
L["DAMAGE_TYPE_NATURE"] = "Nature";
L["DAMAGE_TYPE_HOLY"] = "Holy";
L["DAMAGE_TYPE_SHADOW"] = "Shadow";

----------------------------------------------------------
-- Equipment slots
----------------------------------------------------------

L["SLOT_HEAD"] = "Head";
L["SLOT_NECK"] = "Neck";
L["SLOT_SHOULDER"] = "Shoulder";
L["SLOT_BACK"] = "Back";
L["SLOT_CHEST"] = "Chest";
L["SLOT_SHIRT"] = "Shirt";
L["SLOT_TABARD"] = "Tabard";
L["SLOT_WRIST"] = "Wrist";
L["SLOT_HANDS"] = "Hands";
L["SLOT_WAIST"] = "Waist";
L["SLOT_LEGS"] = "Legs";
L["SLOT_FEET"] = "Feet";
L["SLOT_FINGER"] = "Finger";
L["SLOT_TRINKET"] = "Trinket";
L["SLOT_OFF_HAND"] = "Off-Hand";
L["SLOT_ONE_HAND"] = "One-Hand";
L["SLOT_TWO_HAND"] = "Two-Hand";
L["SLOT_MAIN_HAND"] = "Main-Hand";
L["SLOT_RANGED"] = "Ranged";
L["SLOT_SPECIAL"] = "Special";      -- Sigils, Totems, Librams

----------------------------------------------------------
-- Properties
----------------------------------------------------------

L["PROPERTY_DAMAGE_MIN"] = "Max Damage";
L["PROPERTY_DAMAGE_MAX"] = "Min Damage";
L["PROPERTY_DAMAGE_TYPE"] = "Damage Type";
L["PROPERTY_EXTRA_DAMAGE_MIN"] = "Min Extra Damage";
L["PROPERTY_EXTRA_DAMAGE_MAX"] = "Max Extra Damage";
L["PROPERTY_EXTRA_DAMAGE_TYPE"] = "Extra Damage Type";
L["PROPERTY_DAMAGE_SPEED"] = "Speed";
L["PROPERTY_DPS"] = "DPS";
L["PROPERTY_ARMOR"] = "Armor";
L["PROPERTY_BLOCK"] = "Block";

L["PROPERTY_RESISTANCE"] = "Resistance";
L["PROPERTY_RESISTANCE_ARCANE"] = "Arcane Resistance";
L["PROPERTY_RESISTANCE_FIRE"] = "Fire Resistance";
L["PROPERTY_RESISTANCE_FROST"] = "Frost Resistance";
L["PROPERTY_RESISTANCE_NATURE"] = "Nature Resistance";
L["PROPERTY_RESISTANCE_SHADOW"] = "Shadow Resistance";

L["PROPERTY_STRENGTH"] = "Strength";
L["PROPERTY_STAMINA"] = "Stamina";
L["PROPERTY_AGILITY"] = "Agility";
L["PROPERTY_INTELLECT"] = "Intellect";
L["PROPERTY_SPIRIT"] = "Spirit";

L["PROPERTY_LEVEL_REQUIRED"] = "Level Required";
L["PROPERTY_SOULBOUND"] = "Soulbound";
L["PROPERTY_BOP"] = "Binds when picked up";
L["PROPERTY_BOE"] = "Binds when equipped";
L["PROPERTY_UNIQUE"] = "Unique";

end