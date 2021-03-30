-- ********************************************************
-- *                      Gear Up!                        *
-- ********************************************************
-- *                                                      *
-- *  This addon is written and copyrighted by:           *
-- *    - Pandeiros (Pandeirosa @ EU-ZandalarTribe)       *
-- *                                                      *
-- ********************************************************

local GU = _G.GU;

local Data = GU.Data;

-- Also, a brief note for more advanced authors: 
-- If for some reason your addon causes LoadAddon() to be called in the main chunk,
-- OnInitialize will fire prematurely for your addon, so you'll need to take other measures
-- to delay initializing AceDB since SavedVariables still won't be loaded.
function GU:OnInitialize()
    self:Initialize();
end

function GU:Initialize()
    if (type(self.init) ~= "boolean" or not self.init) then
        self:InitializeDB();
    end

    self.init = true;
end

function GU:InitializeDB()
    self.db = GU_AceDB:New("GUDB", GU_DB_DEFAULTS, true);

    Data:Initialize();
    Data.Options.OptionsTable.args.profiles = GU_AceDBOptions:GetOptionsTable(self.db)
end