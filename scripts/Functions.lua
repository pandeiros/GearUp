-- #TODO Copyright here

local GU = _G.GU;
local Colors = GU.Style.Colors;
local Logger = GU.Logger;

----------------------------------------------------------
-- Logging helpers
----------------------------------------------------------

-- Print welcome message after player login.
function GU:PrintWelcomeMessage()
	local loginCount = self.db.char.loginCount;
	local style = self.db.profile.style;

	if loginCount == 0 then
		Logger:Printf("Hello there, %s! I do believe this is the first time we've met. Nice to meet you!", Colors:GetColorStr(style.primaryAccentColor, UnitName("Player")));
	elseif loginCount == 1 then
		Logger:Printf("Hello there, %s! How nice to see you again. I do believe I've seen you %d time before.", Colors:GetColorStr(style.primaryAccentColor, UnitName("Player")), loginCount);
	else
		Logger:Printf("Hello there, %s! How nice to see you again. I do believe I've seen you %d times before.", Colors:GetColorStr(style.primaryAccentColor, UnitName("Player")), loginCount);
	end

	self.db.char.loginCount = self.db.char.loginCount + 1;
end