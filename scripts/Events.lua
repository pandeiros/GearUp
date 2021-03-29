-- #TODO Copyright here

local GU = _G.GU
local Logger = GU.Logger;

function GU:PlayerLogin()
	self:Initialize();
	self:PrintWelcomeMessage();
end

-- function GU:GetItemInfoReceived(itemID, success)
-- 	if not success then success = "" end;
-- 	if itemID ~= nil then
-- 		Logger:Verb(itemID .. ": " .. success);
-- 	end
-- end

---------------------------------------------------------

function GU.ToolTipHook(tooltip)
	GU.Frames.Tooltip:AddItemInfo(tooltip);
end

GameTooltip:HookScript("OnTooltipSetItem", GU.ToolTipHook);
ItemRefTooltip:HookScript("OnTooltipSetItem", GU.ToolTipHook);