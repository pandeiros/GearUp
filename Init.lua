-- #TODO Copyright here

-- Libraries
GU_AceAddon = LibStub("AceAddon-3.0");
GU_AceConsole = LibStub("AceConsole-3.0");
GU_AceGUI = LibStub("AceGUI-3.0");
GU_AceConfig = LibStub("AceConfig-3.0");
GU_AceDB = LibStub("AceDB-3.0");
GU_AceDBOptions = LibStub("AceDBOptions-3.0");
GU_AceEvent = LibStub("AceEvent-3.0");
GU_AceLocale = LibStub("AceLocale-3.0");
GU_AceTimer = LibStub("AceTimer-3.0");
GU_AceSerializer = LibStub("AceSerializer-3.0");

-- Main addon object
_G.GU = GU_AceAddon:NewAddon("GU", "AceEvent-3.0", "AceTimer-3.0");

-- Main objects
_G.GU.Data = {};
_G.GU.Style = {};
_G.GU.Misc = {};