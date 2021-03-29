-- #TODO Copyright here

local GU = _G.GU;
local Colors = GU.Style.Colors;

local Logger = {};
GU.Logger = Logger;

----------------------------------------------------------
-- Logging helpers
----------------------------------------------------------

local GU_PREFIX = "<GU> ";

-- Print to default tab. 
function Logger:Print(...)
    local style = GU.db.profile.style;
    GU_AceConsole:Print(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.logColor, ...));
end

-- Print formatted text to default tab.
function Logger:Printf(format, ...)
    local style = GU.db.profile.style;
    GU_AceConsole:Printf(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.logColor, format), ...);
end

-- Print formatted text to default tab with custom color.
function Logger:Printfc(color, format, ...)
    GU_AceConsole:Printf(DEFAULT_CHAT_FRAME, Colors:GetColorStr(color, format), ...);
end

-- Verbose logging. Only available with dev mode enabled.
function Logger:Verb(format, ...)
    if (not GU:GetDevModeEnabled()) then
        return;
    end

    format = GU_PREFIX .. format;
    local style = GU.db.profile.style;
    self:Printfc(style.verboseColor, format, ...);
end

function Logger:Log(format, ...)
    format = GU_PREFIX .. format;
    self:Printf(format, ...);
end

function Logger:Warn(format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:Printfc(style.warningColor, format, ...);
end

function Logger:Err(format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:Printfc(style.errorColor, format, ...);
end

-- Official user messages. Uses addon-specific prefix and text color.
function Logger:Display(format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:Printfc(style.displayColor, format, ...);
end