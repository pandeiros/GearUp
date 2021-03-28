-- #TODO Copyright here

local GU = _G.GU;

local Frames = GU.Frames;
local Data = GU.Data;
local Logger = GU.Logger;

local Options = {};
Data.Options = Options;

local OptionsTable = {
    name = GU_ADDON_NAME,
    handler = GU,
    type = 'group',
    args = {
        devmode = {
            hidden = "GetDevModeToggleHidden",
            guiHidden = true,
            type = "toggle",
            name = "Development mode toggle",
            desc = "Enable/disable development mode",
            set = "SetDevModeToggle",
            get = "GetDevModeToggle",
            order = 1,
        },

        reset = {
            hidden = "GetDevModeToggleHidden",
            guiHidden = true,
            type = "execute",
            name = "Data reset",
            desc = "Reset all data to default state",
            func = "ResetAllData",
            order = 2,
            confirm = true,
        },

        config = {
            guiHidden = true,
            type = 'execute',
            name = 'Gear Up config',
            desc = 'Open Gear Up configuration window',
            func = 'OpenConfig',
        },

        toggle = {
            type = "toggle",
            name = "Enable/Disable toggle",
            desc = "Enable/disable the Gear Up addon",
            set = "SetEnableToggle",
            get = "GetEnableToggle",
        },

        test = {
            guiHidden = true,
            type = 'execute',
            name = 'Test',
            desc = 'Test command',
            func = 'TestCommand',
        },

        scan = {
            guiHidden = true,
            type = "toggle",
            name = "Enable/Disable Item Scan",
            desc = "Enable/Disble item scanning and parsing",
            set = "SetScanEnabled",
            get = "GetScanEnabled",
        },

        dbreset = {
            guiHidden = true,
            type = "execute",
            name = "Database reset",
            desc = "Erase item databse",
            func = "DatabaseReset",
        },

        stats = {
            guiHidden = true,
            type = "execute",
            name = "DB Statistics",
            desc = "Print database stats",
            func = "DatabaseStats",
        }
    },
}

AceConfig:RegisterOptionsTable(GU_ADDON_NAME, OptionsTable, {"gu", "gearup"});
Options.OptionsTable = OptionsTable;

-- Development mode
function GU:GetDevModeEnabled()
    return (GU_DEV_MODE_FORCED or GU_DEV_MODE_ENABLED and not self:GetDevModeToggleHidden());
end

function GU:GetDevModeToggleHidden()
    return not self.devmode;
end

function GU:SetDevModeToggle(info, val)
    if (not GU_DEV_MODE_ENABLED) then
        return
    end
    
    self.devmode = val;
    Logger:Printf("Development mode %s.", IFTE(val, "enabled", "disabled"));
end

function GU:GetDevModeToggle(info)
    return self.devmode;
end

-- Reset
function GU:ResetAllData(info)
    if (not self:GetDevModeEnabled()) then
        return
    end

    Logger:Print("Resetting data...");

    self.db:ResetDB(DEFAULT_DB_NAME);

    GUDB = nil;
    GUCharacterDB = nil;
end

-- Config
function GU:OpenConfig(info)
    -- Frames:OpenConfigFrame();
    Frames:OpenMainFrame();
end

-- Enable toggle
function GU:SetEnableToggle(info, val)
    self.db.char.enabled = val;
    Logger:Printf("%s %s.", GU_DISPLAY_NAME, IFTE(val, "enabled", "disabled"));
end

function GU:GetEnableToggle(info)
    return self.db.char.enabled;
end

-- Test
function GU:TestCommand(info)
    -- Data:PrintAllItemLinks();
    Logger:Display("|cffff00ff|Hitem:6337::::::1179::60:::::::|h[Infantry Leggings]|h|r");
    Logger:Display("|cffff00ff|Hitem:6337::::::::60:::::::|h[Infantry Leggings]|h|r");
end

-- Scan
function GU:SetScanEnabled(info, val)
    Data:SetScanEnabled(val);
    Data:RemoveID(5071);
    Logger:Printf("%s %s.", "Item scan", IFTE(val, "enabled", "disabled"));
end

function GU:GetScanEnabled(info)
    return Data.IsScanEnabled();
end

-- Reset database
function GU:DatabaseReset(info)
    Data:DatabaseReset();
end

-- Print database stats
function GU:DatabaseStats(info)
    Data:PrintDatabaseStats();
    -- Data:PrintDatabase();
end