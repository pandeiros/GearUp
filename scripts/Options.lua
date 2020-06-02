-- #TODO Copyright here

local Arma = _G.Arma;

local Frames = Arma.Frames;
local Data = Arma.Data;
local Logger = Arma.Logger;

local Options = {};
Data.Options = Options;

local OptionsTable = {
    name = ARMA_ADDON_NAME,
    handler = Arma,
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
            name = 'Armamentarium config',
            desc = 'Open Armamentarium configuration window',
            func = 'OpenConfig',
        },

        toggle = {
            type = "toggle",
            name = "Enable/Disable toggle",
            desc = "Enable/disable the Armamentarium addon",
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
            type = "execute",
            name = "Item Scan",
            desc = "Scan item dabasase",
            func = "ScanCommand",
        }
    },
}

AceConfig:RegisterOptionsTable(ARMA_ADDON_NAME, OptionsTable, {"arma", "armamentarium"});
Options.OptionsTable = OptionsTable;

-- Development mode
function Arma:GetDevModeEnabled()
    return (ARMA_DEV_MODE_ENABLED and not self:GetDevModeToggleHidden());
end

function Arma:GetDevModeToggleHidden()
    return not self.devmode;
end

function Arma:SetDevModeToggle(info, val)
    if (not ARMA_DEV_MODE_ENABLED) then
        return
    end
    
    self.devmode = val;
    Logger:Printf("Development mode %s.", IFTE(val, "enabled", "disabled"));
end

function Arma:GetDevModeToggle(info)
    return self.devmode;
end

-- Reset
function Arma:ResetAllData(info)
    if (not self:GetDevModeEnabled()) then
        return
    end

    Logger:Print("Resetting data...");

    self.db:ResetDB(DEFAULT_DB_NAME);

    ArmaDB = nil;
    ArmaCharacterDB = nil;
end

-- Config
function Arma:OpenConfig(info)
    -- Frames:OpenConfigFrame();
    Frames:OpenMainFrame();
end

-- Enable toggle
function Arma:SetEnableToggle(info, val)
    self.db.char.enabled = val;
    Logger:Printf("%s %s.", ARMA_DISPLAY_NAME, IFTE(val, "enabled", "disabled"));
end

function Arma:GetEnableToggle(info)
    return self.db.char.enabled;
end

-- Test
function Arma:TestCommand(info)

end

-- Scan
function Arma:ScanCommand(info)
    Data:ScanItems();
end