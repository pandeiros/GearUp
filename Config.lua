-- #TODO Copyright here

local GU = _G.GU;

----------------------------------------------------------

-- Version
GU_ADDON_VERSION = "0.3.0";

-- Dev mode
GU_DEV_MODE_ENABLED = false;   -- whether dev mode is enabled or not.

-- Commonly used variables
GU_ADDON_DISPLAY_NAME = "Gear Up!";
GU_ADDON_NAME = "GU";
GU_DB_NAME = "GUDB";
GU_DB_CHAR_NAME = "GUCharacterDB";

-- Events stubs
function GU:PLAYER_LOGIN()                self:PlayerLogin();         end
-- function GU:GET_ITEM_INFO_RECEIVED()   self:GetItemInfoReceived();      end

-- function GU:AUCTION_HOUSE_SHOW()         self:AuctionHouseShow();      end
-- function GU:AUCTION_HOUSE_CLOSED()       self:AuctionHouseClosed();      end
-- function GU:AUCTION_ITEM_LIST_UPDATE()   self:AuctionItemListUpdate();      end

-- Event registration
GU:RegisterEvent("PLAYER_LOGIN");
-- GU:RegisterEvent("GET_ITEM_INFO_RECEIVED");

-- GU:RegisterEvent("AUCTION_HOUSE_SHOW");
-- GU:RegisterEvent("AUCTION_HOUSE_CLOSED");
-- GU:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");