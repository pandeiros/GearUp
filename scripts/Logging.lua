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
    AceConsole:Print(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.loggingColor, ...));
end

-- Print formatted text to default tab.
function Logger:Printf(format, ...)
    local style = Arma.db.profile.style;
    AceConsole:Printf(DEFAULT_CHAT_FRAME, Colors:GetColorStr(style.loggingColor, format), ...);
end