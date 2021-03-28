-- #TODO Copyright here

local GU = _G.GU;

local Data = GU.Data;
local Style = GU.Style;

-- Database defaults
GU_DB_DEFAULT_PROFILE_NAME = "Default";
GU_DB_DEFAULTS = {
    profile = {
        style = Style:GetDefaultStyle(),
    },

    char = {
        enabled = true,
        loginCount = 0,
    }
}