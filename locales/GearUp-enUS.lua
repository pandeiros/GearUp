-- #TODO Copyright here

local L = GU_AceLocale:NewLocale("GU", "enUS", true, false);
local GL = GU_AceLocale:GetLocale("GU");

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
L["SUBTYPE_FISHING"] = "Fishing";
L["SUBTYPE_HERBALISM"] = "Herbalism";
L["SUBTYPE_INSCRIPTION"] = "Inscription";
L["SUBTYPE_JEWELCRAFTING"] = "Jewelcrafting";
L["SUBTYPE_LEATHERWORKING"] = "Leatherworking";
L["SUBTYPE_MINING"] = "Mining";
L["SUBTYPE_SKINNING"] = "Skinning";
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
-- Races
----------------------------------------------------------

L["RACE_HUMAN"] = "Human";
L["RACE_NIGHT_ELF"] = "Night Elf";
L["RACE_DWARF"] = "Dwarf";
L["RACE_GNOME"] = "Gnome";
L["RACE_DRAENEI"] = "Draenei";
L["RACE_ORC"] = "Orc";
L["RACE_UNDEAD"] = "Undead";
L["RACE_TAUREN"] = "Tauren";
L["RACE_TROLL"] = "Troll";
L["RACE_BLOOD_ELF"] = "Blood Elf";

----------------------------------------------------------
-- Damage
----------------------------------------------------------

L["DAMAGE"] = "Damage";
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

-- TODO Need to iterate through all scanned items and verify these names
-- based on items' equipLocations property.

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
L["SLOT_RELIC"] = "Relic";
L["SLOT_SPECIAL"] = "Special";      -- Sigils, Totems, Librams -- TODO: potentially not used.

----------------------------------------------------------
-- Properties
----------------------------------------------------------

-- Common
L["PROPERTY_LEVEL_REQUIRED"] = "Requires Level";
L["PROPERTY_DURABILITY"] = "Durability";
L["PROPERTY_SOULBOUND"] = "Soulbound";
L["PROPERTY_BOP"] = "Binds when picked up";
L["PROPERTY_BOE"] = "Binds when equipped";
L["PROPERTY_BOU"] = "Binds when used";
L["PROPERTY_UNIQUE"] = "Unique";
L["PROPERTY_UNIQUE_EQUIPPED"] = "Unique-Equipped";
L["PROPERTY_QUEST_ITEM"] = "Quest Item";
L["PROPERTY_QUEST_ITEM_BEGIN"] = "This Item Begins a Quest";
L["PROPERTY_RANDOM_ENCH"] = "Random enchantment";
L["PROPERTY_DURATION"] = "Duration";
L["PROPERTY_LOCKED"] = "Locked";

L["PROPERTY_REPUTATION_NEUTRAL"] = "Neutral";
L["PROPERTY_REPUTATION_FRIENDLY"] = "Friendly";
L["PROPERTY_REPUTATION_HONORED"] = "Honored";
L["PROPERTY_REPUTATION_REVERED"] = "Revered";
L["PROPERTY_REPUTATION_EXALTED"] = "Exalted";

L["PROPERTY_FACTION_ARGENT_DAWN"] = "Argent Dawn";
L["PROPERTY_FACTION_BLOODSAIL_BUCCANEERS"] = "Bloodsail Buccaneers";
L["PROPERTY_FACTION_BROOD_OF_NOZDORMU"] = "Brood of Nozdormu";
L["PROPERTY_FACTION_CENARION_CIRCLE"] = "Cenarion Circle";
L["PROPERTY_FACTION_HYDRAXIAN_WATERLORDS"] = "Hydraxian Waterlords";
L["PROPERTY_FACTION_THORIUM_BROTHERHOOD"] = "Thorium Brotherhood";
L["PROPERTY_FACTION_TIMBERMAW_HOLD"] = "Timbermaw Hold";
L["PROPERTY_FACTION_WINTERSABER_TRAINERS"] = "Wintersaber Trainers";
L["PROPERTY_FACTION_ZANDALAR_TRIBE"] = "Zandalar Tribe";

L["PROPERTY_FACTION_ALLIANCE_STORMWIND"] = "Stormwind";
L["PROPERTY_FACTION_ALLIANCE_IRONFORGE"] = "Ironforge";
L["PROPERTY_FACTION_ALLIANCE_DARNASSUS"] = "Darnassus";
L["PROPERTY_FACTION_ALLIANCE_GNOMEREGAN_EXILES"] = "Gnomeregan Exiles";
L["PROPERTY_FACTION_HORDE_ORGRIMMAR"] = "Orgrimmar";
L["PROPERTY_FACTION_HORDE_THUNDER_BLUFF"] = "Thunder Bluff";
L["PROPERTY_FACTION_HORDE_UNDERCITY"] = "Undercity";
L["PROPERTY_FACTION_HORDE_DARKSPEAR_TROLLS"] = "Darkspear Trolls";

L["PROPERTY_PVP_RANK_PRIVATE"] = "Private";
L["PROPERTY_PVP_RANK_CORPORAL"] = "Corporal";
L["PROPERTY_PVP_RANK_SERGEANT"] = "Sergeant";
L["PROPERTY_PVP_RANK_MASTER_SERGEANT"] = "Master Sergeant";
L["PROPERTY_PVP_RANK_SERGEANT_MAJOR"] = "Sergeant Major";
L["PROPERTY_PVP_RANK_KNIGHT"] = "Knight";
L["PROPERTY_PVP_RANK_KNIGHT_LIEUTENANT"] = "Knight-Lieutenant";
L["PROPERTY_PVP_RANK_KNIGHT_CAPTAIN"] = "Knight-Captain";
L["PROPERTY_PVP_RANK_KNIGHT_CHAMPION"] = "Knight-Champion";
L["PROPERTY_PVP_RANK_LIEUTENANT_COMMANDER"] = "Lieutenant Commander";
L["PROPERTY_PVP_RANK_COMMANDER"] = "Commander";
L["PROPERTY_PVP_RANK_MARSHAL"] = "Marshal";
L["PROPERTY_PVP_RANK_FIELD_MARSHAL"] = "Field Marshal";
L["PROPERTY_PVP_RANK_GRAND_MARSHALL"] = "Grand Marshal";

L["PROPERTY_PVP_RANK_SCOUT"] = "Scout";
L["PROPERTY_PVP_RANK_GRUNT"] = "Grunt";
L["PROPERTY_PVP_RANK_SERGEANT"] = "Sergeant";
L["PROPERTY_PVP_RANK_SENIOR_SERGEANT"] = "Senior Sergeant";
L["PROPERTY_PVP_RANK_FIRST_SERGEANT"] = "First Sergeant";
L["PROPERTY_PVP_RANK_STONE_GUARD"] = "Stone Guard";
L["PROPERTY_PVP_RANK_BLOOD_GUARD"] = "Blood Guard";
L["PROPERTY_PVP_RANK_LEGIONNAIRE"] = "Legionnaire";
L["PROPERTY_PVP_RANK_CENTURION"] = "Centurion";
L["PROPERTY_PVP_RANK_CHAMPION"] = "Champion";
L["PROPERTY_PVP_RANK_LIEUTENANT_GENERAL"] = "Lieutenant General";
L["PROPERTY_PVP_RANK_GENERAL"] = "General";
L["PROPERTY_PVP_RANK_WARLORD"] = "Warlord";
L["PROPERTY_PVP_RANK_HIGH_WARLORD"] = "High Warlord";

-- Weapon
L["PROPERTY_DAMAGE_MIN"] = "Max Damage";
L["PROPERTY_DAMAGE_MAX"] = "Min Damage";
L["PROPERTY_DAMAGE_TYPE"] = "Damage Type";
L["PROPERTY_EXTRA_DAMAGE_MIN"] = "Min Extra Damage";
L["PROPERTY_EXTRA_DAMAGE_MAX"] = "Max Extra Damage";
L["PROPERTY_EXTRA_DAMAGE_TYPE"] = "Extra Damage Type";
L["PROPERTY_DAMAGE_SPEED"] = "Speed";
L["PROPERTY_DPS"] = "DPS";

L["PROPERTY_ONE_HAND"] = "One-Hand";
L["PROPERTY_TWO_HAND"] = "Two-Hand";
L["PROPERTY_MAIN_HAND"] = "Main Hand";
L["PROPERTY_OFF_HAND"] = "Off Hand";
L["PROPERTY_OFF_HAND_HELD"] = "Held In Off-hand";

L["PROPERTY_BOW"] = "Bow";
L["PROPERTY_CROSSBOW"] = "Crossbow";
L["PROPERTY_DAGGER"] = "Dagger";
L["PROPERTY_GUN"] = "Gun";
L["PROPERTY_FISHING_POLE"] = "Fishing Pole";
L["PROPERTY_FIST_WEAPON"] = "Fist Weapon";
L["PROPERTY_AXE"] = "Axe";
L["PROPERTY_MACE"] = "Mace";
L["PROPERTY_SWORD"] = "Sword";
L["PROPERTY_POLEARM"] = "Polearm";
L["PROPERTY_STAFF"] = "Staff";
L["PROPERTY_THROWN"] = "Thrown";
L["PROPERTY_WAND"] = "Wand";

-- Armor
L["PROPERTY_ARMOR"] = "Armor";
L["PROPERTY_BLOCK"] = "Block";

L["PROPERTY_CLOTH"] = "Cloth";
L["PROPERTY_LEATHER"] = "Leather";
L["PROPERTY_MAIL"] = "Mail";
L["PROPERTY_PLATE"] = "Plate";
L["PROPERTY_SHIELD"] = "Shield";
L["PROPERTY_LIBRAM"] = "Libram";
L["PROPERTY_IDOL"] = "Idol";
L["PROPERTY_TOTEM"] = "Totem";
L["PROPERTY_SIGIL"] = "Sigil";

-- Projectile
L["PROPERTY_AMMO"] = "Ammo";

-- Consumable
L["PROPERTY_CONJURED_ITEM"] = "Conjured Item";

-- Misc
L["PROPERTY_HORSE_RIDING"] = "Horse Riding";
L["PROPERTY_TIGER_RIDING"] = "Tiger Riding";
L["PROPERTY_RAM_RIDING"] = "Ram Riding";
L["PROPERTY_MECHANOSTRIDER_PILOTING"] = "Mechanostrider Piloting";
L["PROPERTY_WOLF_RIDING"] = "Wolf Riding";
L["PROPERTY_UNDEAD_HORSEMANSHIP"] = "Undead Horsemanship";
L["PROPERTY_KODO_RIDING"] = "Kodo Riding";
L["PROPERTY_RAPTOR_RIDING"] = "Raptor Riding";

-- Equippable
L["PROPERTY_SET"] = "Set";

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

L["PROPERTY_ENEMY_TYPE_UNDEAD"] = "Undead";
L["PROPERTY_ENEMY_TYPE_DRAGONS"] = "Dragons";
L["PROPERTY_ENEMY_TYPE_BEASTS"] = "Beasts";
L["PROPERTY_ENEMY_TYPE_DEMONS"] = "Demons";
L["PROPERTY_ENEMY_TYPE_ELEMENTALS"] = "Elementals";

L["PROPERTY_WEAPON_SKILL_AXES"] = "Axes";
L["PROPERTY_WEAPON_SKILL_BOWS"] = "Bows";
L["PROPERTY_WEAPON_SKILL_CROSSBOWS"] = "Crossbows";
L["PROPERTY_WEAPON_SKILL_DAGGERS"] = "Daggers";
L["PROPERTY_WEAPON_SKILL_FIST_WEAPON"] = "Fist Weapons";
L["PROPERTY_WEAPON_SKILL_GUNS"] = "Guns";
L["PROPERTY_WEAPON_SKILL_MACES"] = "Maces";
L["PROPERTY_WEAPON_SKILL_POLEARMS"] = "Polearms";
L["PROPERTY_WEAPON_SKILL_STAVES"] = "Staves";
L["PROPERTY_WEAPON_SKILL_SWORDS"] = "Swords";
L["PROPERTY_WEAPON_SKILL_THROWN"] = "Thrown";
L["PROPERTY_WEAPON_SKILL_AXES_2H"] = "Two-handed Axes";
L["PROPERTY_WEAPON_SKILL_MACES_2H"] = "Two-handed Maces";
L["PROPERTY_WEAPON_SKILL_SWORDS_2H"] = "Two-handed Swords";

L["PROPERTY_BG_AV"] = "Alterac Valley";

----------------------------------------------------------
-- Regex
----------------------------------------------------------

-- TODO If trick with GL doesn't work in parsing, write those entries manually.
-- NOTE: WoW Lua api does not support %g in patterns.

-- Common
L["REGEX_UNIQUE_EQUIPPED"] = "Unique%-Equipped";
L["REGEX_UNIQUE"] = GL["PROPERTY_UNIQUE"] .. "%s?%(?(%d*)%)?";

L["REGEX_LEVEL_REQUIRED"] = GL["PROPERTY_LEVEL_REQUIRED"] .. " (%d+)";
L["REGEX_DURABILITY"] = GL["PROPERTY_DURABILITY"] .. " %d+ / (%d+)";
L["REGEX_CLASSES"] = "Classes: (.+)";
L["REGEX_RACES"] = "Races: (.+)";
L["REGEX_FLAVOR_TEXT"] = "(\".+\")";
L["REGEX_USE_EFFECT"] = "Use: (.+)";
L["REGEX_QUEST_ITEM"] = GL["PROPERTY_QUEST_ITEM"];
L["REGEX_QUEST_ITEM_BEGIN"] = GL["PROPERTY_QUEST_ITEM_BEGIN"];
L["REGEX_RANDOM_ENCH"] = "<" .. GL["PROPERTY_RANDOM_ENCH"] .. ">";
L["REGEX_REPUTATION_REQUIREMENT"] = "Requires (.+) %- (%a+)";
L["REGEX_PROFESSION_REQUIREMENT"] = "Requires ([%a%s]+) %((%d+)%)";
L["REGEX_CHARGES"] = "(%d+) Charges";
L["REGEX_DETAILS"] = "<Right Click for Details>";
L["REGEX_PVP_RANK_REQUIREMENT"] = "Requires ([%a%s%-]+)";

-- Equippable
L["REGEX_EQUIP_ATTRIBUTE"] = "([%+%-])(%d+)%s(%a+)%s*(%a*)";
L["REGEX_EQUIP_SET_NAME"] = "([%a%s%-']+) %(0/(%d+)%)";
L["REGEX_EQUIP_SET_BONUS"] = "%((%d+)%) " .. GL["PROPERTY_SET"] .. ": (.+)%."
L["REGEX_EQUIP_SLOT_AND_TYPE"] = "([%a%-]+)%s?([%a%-]*)%s?([%a%-]*)%s?([%a%-]*)";

L["REGEX_EQUIP_EFFECT"] = "Equip: (.+)";
L["REGEX_EQUIP_EFFECT_SPELL_POWER"] = "Increases damage and healing done by magical spells and effects by up to (%d+)";
L["REGEX_EQUIP_EFFECT_SPELL_DAMAGE_TYPE"] = "Increases damage done by (%a+) spells and effects by up to (%d+)";
L["REGEX_EQUIP_EFFECT_SPELL_DAMAGE_ENEMY_TYPE"] = "Increases damage done to (%a+) by magical spells and effects by up to (%d+)";
L["REGEX_EQUIP_EFFECT_SPELL_HEALING"] = "Increases healing done by spells and effects by up to (%d+)";
L["REGEX_EQUIP_EFFECT_SPELL_CRITICAL_STRIKE_CHANCE"] = "Improves your chance to get a critical strike with spells by (%d+)%%";
L["REGEX_EQUIP_EFFECT_SPELL_HIT_CHANCE"] = "Improves your chance to hit with spells by (%d+)%%";
L["REGEX_EQUIP_EFFECT_SPELL_RESISTANCE_DECREASE"] = "Decreases the magical resistances of your spell targets by (%d)";
L["REGEX_EQUIP_EFFECT_HPS"] = "Restores (%d+) health every (%d+%.?%d-) sec";
L["REGEX_EQUIP_EFFECT_HP5"] = "Restores (%d+) health per 5 sec";
L["REGEX_EQUIP_EFFECT_MP5"] = "Restores (%d+) mana per 5 sec";
L["REGEX_EQUIP_EFFECT_CRITICAL_STRIKE_CHANCE"] = "Improves your chance to get a critical strike by (%d+)%%";
L["REGEX_EQUIP_EFFECT_HIT_CHANCE"] = "Improves your chance to hit by (%d+)%%";
L["REGEX_EQUIP_EFFECT_AP"] = "%+(%d+) Attack Power";
L["REGEX_EQUIP_EFFECT_AP_TYPE"] = "%+(%d+) Attack Power when fighting (%a+)";
L["REGEX_EQUIP_EFFECT_AP_TYPE2"] = "Attack Power increased by (%d+) when fighting (%a+)";
L["REGEX_EQUIP_EFFECT_RANGED_ATTACK_SPEED"] = "Increases ranged attack speed by (%d+)%%";
L["REGEX_EQUIP_EFFECT_RANGED_ATTACK_POWER"] = "%+(%d+) ranged Attack Power";
L["REGEX_EQUIP_EFFECT_DEFENSE"] = "Increased Defense %+(%d+)";
L["REGEX_EQUIP_EFFECT_BLOCK_CHANCE"] = "Increases your chance to block attacks with a shield by (%d+)%%";
L["REGEX_EQUIP_EFFECT_BLOCK_VALUE"] = "Increases the block value of your shield by (%d+)";
L["REGEX_EQUIP_EFFECT_DODGE_CHANCE"] = "Increases your chance to dodge an attack by (%d+)%%";
L["REGEX_EQUIP_EFFECT_PARRY_CHANCE"] = "(%a+) your chance to parry an attack by (%d+)%%";
L["REGEX_EQUIP_EFFECT_WEAPON_SKILL"] = "Increased ([%a%-%s]+) %+(%d+)";
L["REGEX_EQUIP_EFFECT_PROFESSION_SKILL"] = "Increased ([%a%-%s]+) %+(%d+)";
L["REGEX_EQUIP_EFFECT_PROFESSION_SKILL2"] = "([%a%-%s]+) %+(%d+)";

-- Weapon
L["REGEX_WEAPON_DAMAGE"] = "(%d+)%s%-%s(%d+)%s*(%a*)%sDamage";
L["REGEX_WEAPON_DAMAGE2"] = "(%d+)%s*(%a*)%sDamage";
L["REGEX_WEAPON_SPEED"] = "Speed%s(%d+%.%d+)";
L["REGEX_WEAPON_DAMAGE_AND_SPEED"] = GL["REGEX_WEAPON_DAMAGE"] .. "%s+" .. GL["REGEX_WEAPON_SPEED"];
L["REGEX_WEAPON_DAMAGE_AND_SPEED2"] = GL["REGEX_WEAPON_DAMAGE2"] .. "%s+" .. GL["REGEX_WEAPON_SPEED"];
L["REGEX_WEAPON_EXTRA_DAMAGE"] = "%+%s(%d+)%s%-%s(%d+)%s*(%a*)%sDamage";
L["REGEX_WEAPON_EXTRA_DAMAGE2"] = "%+(%d+) (%a+) Damage";
L["REGEX_WEAPON_DPS"] = "%((%d+%.?%d-)%sdamage per second%)";
L["REGEX_WEAPON_CHANCE_ON_HIT"] = "Chance on hit: (.+)";

-- Armor
L["REGEX_ARMOR_BLOCK"] = "(%d+) " .. GL["PROPERTY_BLOCK"];
L["REGEX_ARMOR_ARMOR"] = "(%d+) " .. GL["PROPERTY_ARMOR"];

-- Recipes
L["REGEX_RECIPE_REQUIRE_MATERIALS"] = "Requires ([%a%s,%(%)%d]+)";

-- Containers
L["REGEX_CONTAINER_SLOTS_AND_TYPE"] = "(%d+) Slot ([%a%s]+)";

-- Consumables
L["REGEX_CONSUMABLE_POISON_REQUIREMENT"] = "Requires Poisons%s?%(?(%d*)%)?";
L["REGEX_CONSUMABLE_POISON1"] = "Each strike has a %d+%% chance of poisoning the enemy for %d+ Nature damage over %d+ sec%.  Stacks up to %d+ times on a single target%.  (%d+) charges%.";
L["REGEX_CONSUMABLE_POISON2"] = "Each strike has a %d+%% chance of poisoning the enemy, slowing their movement speed by %d+%% for %d+ sec%.";
L["REGEX_CONSUMABLE_POISON3"] = "Each strike has a %d+%% chance of poisoning the enemy, increasing their casting time by %d+%% for %d+ sec%.  (%d+) charges%.";
L["REGEX_CONSUMABLE_POISON4"] = "Each strike has a chance of poisoning the enemy which instantly inflicts %d+%-%d+ damage%. %(%d+ Sec Cooldown%)";
L["REGEX_CONSUMABLE_POISON5"] = "Each strike has a %d+%% chance of poisoning the enemy which instantly inflicts %d+ to %d+ Nature damage%.  (%d+) charges%.";
L["REGEX_CONSUMABLE_POISON6"] = "Each strike has a %d+%% chance of poisoning the enemy, reducing all healing effects used on them by %d+ for %d+ sec%.  Stacks up to %d+ times on a single target%.  (%d+) charges%.";
L["REGEX_CONSUMABLE_SUBTLETY_REQUIREMENT"] = "Requires Subtlety %((%d+)%)";

-- Quiver
L["REGEX_QUIVER_QUIVER_SLOTS"] = "(%d+) Slot Quiver";
L["REGEX_QUIVER_AMMO_POUCH_SLOTS"] = "(%d+) Slot Ammo Pouch";

-- Projectile
L["REGEX_PROJECTILE_DPS"] = "Adds (%d+%.?%d-) damage per second";

-- Misc
L["REGEX_MOUNT_RIDING"] = "Requires (%a+%s%a+) %(%d+%)";
L["REGEX_DURATION"] = "Duration: (.+)";

end