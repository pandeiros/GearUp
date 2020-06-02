-- #TODO Copyright here

local Arma = _G.Arma;

local Items = {};
Arma.Items = Items;

----------------------------------------------------------
-- Equipment properties
----------------------------------------------------------

local ITEM_KEYWORDS = {
    "Soulbound", "Unique", "Requires", "Level", "Binds when",
}

local WEAPON_KEYWORDS = {
	"One-Hand", "One-Handed", "One Hand", "1H", "Main-Hand", "Main Hand", "MH", "Two-Hand", "Two-Handed", "Two Hand", "2H",
	"Off-Hand", "Held in Off-Hand", "Off Hand", "OH", "Ranged", "Thrown",
	"Axe", "Bow", "Gun", "Mace", "Polearm", "Sword", "Staff", "Fist", "Misc", "Miscellaneous", "Dagger", "Crossbow", "Wand", "Fishing", "Pole",
}

local WEAPON_SLOTS_KEYWORDS = {
    "Main Hand", "Off Hand", "Ranged", "Ammo",
}

local ARMOR_KEYWORDS = {
    "Cloth", "Leather", "Mail", "Plate", "Shield", "Libram", "Idol", "Totem", "Sigil",
}

local ARMOR_SLOTS_KEYWORDS = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Hand", "Waist", "Leg", "Foot", "Finger", "Trinket",
}

local PROJECTILE_KEYWORDS = {
    "Projectile", "Arrow", "Bullet", "Quiver", "Ammo Pouch", "Pouch",
}

local ITEM_KEYWORDS_PLURAL = {
	"Axes", "Bows", "Guns", "Maces", "Polearms", "Swords", "Staves", "Daggers", "Crossbows",
	"Wands", "Shields", "Librams", "Idols", "Totems", "Sigils",
	"Shoulders", "Legs", "Feet", "Hands", "Fingers",
}

local PROPERTIES_KEYWORDS = {
	"Intellect", "Int", "Stamina", "Stam", "Agility", "Agi", "Strength", "Str", "Spirit", "Spi",
	"Resistance", "Res", "Arcane", "Nature", "Fire", "Frost", "Shadow", "Holy",
	"Arcane Resistance", "AR", "Nature Resistance", "NR", "Fire Resistance", "Frost Resistance", "FR", "Shadow Resistance", "SR",
	"Armor",
}

local EQUIP_EFFECT_KEYWORDS = {
	"Defense", "Def", "Parry", "Attack Power", "AP", "Dodge", "Attack Speed", "Block",
	"Spell Power", "SP", "Mana", "Health", "per 5 sec", "%",
	"damage and healing done", "healing done", "spells and effects", "Arcane", "Nature", "Fire", "Frost", "Shadow", "Holy",
	"Critical Strike", "Critical Chance", "Critical Hit", "Crit", "Crit Chance", "Spell Crit",
	"Hit", "Hit Chance", "Spell Hit",
	"Increased", "Improves", "Immune", "Disarm",
	"Swords", "Two-Handed Swords", "Axes", "Two-Handed Axes", "Maces", "Two-Handed Maces", "Bows", "Guns", "Polearms", "Staves",
	"Fists", "Daggers", "Crossbows", "Wands",
}