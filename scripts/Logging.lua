-- #TODO Copyright here

local GU = _G.GU;
local Colors = GU.Style.Colors;

local Logger = {};
GU.Logger = Logger;

----------------------------------------------------------
-- Logging helpers
----------------------------------------------------------

local GU_PREFIX = "<GU> ";

Logger.debugLogEnabled = false;
Logger.verboseLogEnabled = false;

GU_CHAT_FRAME_SCAN = "Scan";

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

function Logger:GetChatFrame(chatNameOrIndex)
    local chatFrame = nil;
    if (type(chatNameOrIndex) == "number") then
        chatFrame = getglobal("ChatFrame"..chatNameOrIndex)
    elseif (type(chatNameOrIndex) == "string" and chatNameOrIndex:find("ChatFrame%d+") ~= nil) then
        chatFrame = getglobal(chatNameOrIndex);
    elseif (type(chatNameOrIndex) == "string") then
        for i = 1, NUM_CHAT_WINDOWS do
            local frame = getglobal("ChatFrame"..i);
            if (frame.name == chatNameOrIndex) then
                chatFrame = frame;
            end
        end
    end

    return chatFrame;
end

-- Print to a specific chat. 
function Logger:PrintChat(chat, silent, ...)
    local style = GU.db.profile.style;

    local frame = self:GetChatFrame(chat);
    if (not silent and not frame) then
        self:Warn("Logger:PrintChat Invalid chat index or name given: %s", chat);
        return;
    end

    GU_AceConsole:Print(frame, Colors:GetColorStr(style.logColor, ...));
end

-- Print formatted text to a specific chat.
function Logger:PrintfChat(chat, silent, format, ...)
    local style = GU.db.profile.style;

    local frame = self:GetChatFrame(chat);
    if (not silent and not frame) then
        self:Warn("Logger:PrintfChat Invalid chat index or name given: %s", chat);
        return;
    end

    GU_AceConsole:Printf(frame, Colors:GetColorStr(style.logColor, format), ...);
end

-- Print formatted text to a specific chat with custom color.
function Logger:PrintfcChat(chat, silent, color, format, ...)
    local frame = self:GetChatFrame(chat);
    if (not silent and not frame) then
        self:Warn("Logger:PrintfcChat Invalid chat index or name given: %s", chat);
        return;
    end

    GU_AceConsole:Printf(frame, Colors:GetColorStr(color, format), ...);
end

----------------------------------------------------------

-- Debug logging. Only available with dev mode enabled.
function Logger:Debug(format, ...)
    if (not GU:GetDevModeEnabled() or not self.debugLogEnabled) then
        return;
    end

    format = GU_PREFIX .. format;
    local style = GU.db.profile.style;
    self:Printfc(style.debugColor, format, ...);
end

-- Verbose logging. Only available with dev mode enabled.
function Logger:Verb(format, ...)
    if (not GU:GetDevModeEnabled() or not self.verboseLogEnabled) then
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

----------------------------------------------------------
-- Custom chat frame logging functions variants
----------------------------------------------------------

-- Debug logging. Only available with dev mode enabled.
function Logger:DebugChat(chat, silent, format, ...)
    if (not GU:GetDevModeEnabled() or not self.debugLogEnabled) then
        return;
    end

    format = GU_PREFIX .. format;
    local style = GU.db.profile.style;
    self:PrintfcChat(chat, silent, style.debugColor, format, ...);
end

-- Verbose logging. Only available with dev mode enabled.
function Logger:VerbChat(chat, silent, format, ...)
    if (not GU:GetDevModeEnabled() or not self.verboseLogEnabled) then
        return;
    end

    format = GU_PREFIX .. format;
    local style = GU.db.profile.style;
    self:PrintfcChat(chat, silent, style.verboseColor, format, ...);
end

function Logger:LogChat(chat, silent, format, ...)
    format = GU_PREFIX .. format;
    self:PrintfChat(chat, silent, format, ...);
end

function Logger:WarnChat(chat, silent, format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:PrintfcChat(chat, silent, style.warningColor, format, ...);
end

function Logger:ErrChat(chat, silent, format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:PrintfcChat(chat, silent, style.errorColor, format, ...);
end

-- Official user messages. Uses addon-specific prefix and text color.
function Logger:DisplayChat(chat, silent, format, ...)
    local style = GU.db.profile.style;
    format = GU_PREFIX .. format;
    self:PrintfcChat(chat, silent, style.displayColor, format, ...);
end

----------------------------------------------------------

function Logger:SetVerboseLogEnabled(val)
    if (val) then
        Logger:Log("Verbose logging enabled.");
    else
        Logger:Log("Verbose logging disabled.");
    end
    self.verboseLogEnabled = val;
end

function Logger:IsVerboseLogEnabled()
    return self.verboseLogEnabled;
end

function Logger:SetDebugLogEnabled(val)
    if (val) then
        Logger:Log("Debug logging enabled.");
    else
        Logger:Log("Debug logging disabled.");
    end
    self.debugLogEnabled = val;
end

function Logger:IsDebugLogEnabled()
    return self.debugLogEnabled;
end