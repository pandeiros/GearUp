-- #TODO Copyright here

local Arma = _G.Arma;
local Colors = Arma.Style.Colors;

local Logger = {};
Arma.Logger = Logger;

----------------------------------------------------------
-- Logging helpers
----------------------------------------------------------

-- Print to default tab. 
function Logger:Print(...)
    local style = Arma.db.profile.style;
    AceConsole:Print(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.logColor, ...));
end

-- Print formatted text to default tab.
function Logger:Printf(format, ...)
    local style = Arma.db.profile.style;
    AceConsole:Printf(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.logColor, format), ...);
end

function Logger:Printfc(color, format, ...)
    AceConsole:Printf(DEFAULT_CHAT_FRAME, Colors:GetColorStr(color, format), ...);
end

function Logger:Verb(format, ...)
    if (not Arma:GetDevModeEnabled()) then
        return;
    end

    local style = Arma.db.profile.style;
    self:Printfc(style.verboseColor, format, ...);
end
function Logger:Log(format, ...)
    self:Printf(format, ...);
end
function Logger:Warn(format, ...)
    local style = Arma.db.profile.style;
    self:Printfc(style.warningColor, format, ...);
end
function Logger:Err(format, ...)
    local style = Arma.db.profile.style;
    self:Printfc(style.errorColor, format, ...);
end