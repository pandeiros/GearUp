-- #TODO Copyright here

local Arma = _G.Arma;

local Data = Arma.Data;
local Style = Arma.Style;

-- Database defaults
ARMA_DB_DEFAULT_PROFILE_NAME = "Default";
ARMA_DB_DEFAULTS = {
    profile = {
        style = Style:GetDefaultStyle(),
    },

    char = {
        enabled = true,
        loginCount = 0,
    }
}