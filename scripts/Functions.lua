-- #TODO Copyright here

local Arma = _G.Arma;
local Colors = Arma.Style.Colors;
local Logger = Arma.Logger;

----------------------------------------------------------
-- Logging helpers
----------------------------------------------------------

-- Print welcome message after player login.
function Arma:PrintWelcomeMessage()
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