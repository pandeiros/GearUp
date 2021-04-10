-- #TODO Copyright here

local GU = _G.GU;

local Frames = GU.Frames;
local Data = GU.Data;
local Logger = GU.Logger;
local Misc = GU.Misc;

local Options = {};
Data.Options = Options;

local OptionsTable = {
    name = GU_ADDON_NAME,
    handler = GU,
    type = 'group',
    args = {
        reset = {
            hidden = "GetDevModeOptionsHidden",
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

        test = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = 'execute',
            name = 'Test',
            desc = 'Test command',
            func = 'TestCommand',
        },

        scan = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "toggle",
            name = "Enable/Disable Item Scan",
            desc = "Enable/Disable item scanning",
            set = "SetScanEnabled",
            get = "GetScanEnabled",
        },

        parse = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "toggle",
            name = "Enable/Disable Item Parse",
            desc = "Enable/Disable item parsing",
            set = "SetParseEnabled",
            get = "GetParseEnabled",
        },

        scanreset = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "execute",
            name = "Reset scanning database",
            desc = "Reset scanning database",
            func = "ResetScanningDatabase",
        },

        stats = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "execute",
            name = "DB Statistics",
            desc = "Print database stats",
            func = "DatabaseStats",
        },

        verbose = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "toggle",
            name = "Enable/Disable Verbose Log",
            desc = "Enable/Disable detailed logging.",
            set = "SetVerboseLogEnabled",
            get = "GetVerboseLogEnabled",
        },

        fix = {
            hidden = "GetDevModeOptionsHidden",
            guiHidden = true,
            type = "execute",
            name = "Fix Scan",
            desc = "Fix scanned database. Available options: validate|deprecated|tooltips|depnames",
            func = "FixScan",
        }
    },
}

GU_AceConfig:RegisterOptionsTable(GU_ADDON_NAME, OptionsTable, {"gu", "gearup"});
Options.OptionsTable = OptionsTable;

function GU:PrintNoAccessError(context)
    Logger:Err("You don't have permission to execute: %s", context)
end

function GU:GetDevModeEnabled()
    return GU_DEV_MODE_ENABLED;
end

function GU:GetDevModeOptionsHidden()
    return not self:GetDevModeEnabled();
end

-- Reset
function GU:ResetAllData(info)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Reset All Data");
        return
    end

    Logger:Log("Resetting all data...");

    Data:Cleanup();

    self.db:ResetDB(DEFAULT_DB_NAME);

    GUDB = nil;
    GUCharacterDB = nil;

    self:InitializeDB();

    Data:ResetDatabase();
end

-- Config
function GU:OpenConfig(info)
    -- Frames:OpenConfigFrame();
    Frames:OpenMainFrame();
end

-- Test
function GU:TestCommand(info)
    -- Data:PrintAllItemLinks();
    -- Data:PrintDeprecatedItems();
    -- Data:RestoreDeprecatedItems();
    -- Data:FixDeprecatedNames();
    -- Data:AddAllDeprecatedIDs();
    -- Data:SerializeTest();
    -- print(Data:GetTooltipText(Misc:GenerateFullItemLink(21330, 4, "Conqueror's Spaulders")));
    -- Data:DeleteAllItemTooltips();
    Data:PrintItemInfoByID(11811);
    Data:PrintItemInfoByID(2040);
    -- Data:PrintScannedItemsWithEmptyTooltip();
end

-- Scan
function GU:SetScanEnabled(info, val)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Set Scan Enabled");
        return
    end

    Data:SetScanEnabled(val);
end

function GU:GetScanEnabled(info)
    return Data:IsScanEnabled();
end

-- Parse
function GU:SetParseEnabled(info, val)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Set Parse Enabled");
        return
    end

    Data:SetParseEnabled(val);
end

function GU:GetParseEnabled(info)
    return Data:IsParseEnabled();
end

-- Reset database
function GU:ResetScanningDatabase(info)
    Data:ResetScanningDatabase();
end

-- Print database stats
function GU:DatabaseStats(info)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Database Stats");
        return;
    end

    Data:PrintDatabaseStats();
end

-- Verbose log
function GU:SetVerboseLogEnabled(info, val)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Set Verbose Log Enabled");
        return
    end

    Logger:SetVerboseLogEnabled(val);
end

function GU:GetVerboseLogEnabled(info)
    return Logger:IsVerboseLogEnabled();
end

-- Scan fixing
function GU:FixScan(info)
    if (not self:GetDevModeEnabled()) then
        self:PrintNoAccessError("Fix Scan");
        return;
    end

    local param = string.match(info.input, "fix (.+)")
    if (param) then
        if (param == "validate") then
            Data:ValidateScannedItems();
        elseif (param == "tooltips") then
            Data:CheckItemTooltips();
        elseif (param == "deprecated") then
            Data:RevalidateDeprecatedItems();
        elseif (param == "depnames") then
            Data:FixDeprecatedNames();
        else
            Logger:Err("FixScan Invalid option given: %s", param);
        end
    else
        Logger:Err("FixScan No option given, don't know what to fix.");
    end
end