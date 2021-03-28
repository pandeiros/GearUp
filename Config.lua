-- #TODO Copyright here

local GU = _G.GU;

-- Version
ADDON_VERSION = "0.1.1"

-- Dev mode
GU_DEV_MODE_ENABLED = true;   -- whether dev mode is enabled AT ALL
GU_DEV_MODE_FORCED = true;    -- whether we force dev mode, even if not toggled via console (requires GU_DEV_MODE_ENABLED to true)

-- Commonly used variables
GU_DISPLAY_NAME = "Gear Up!";
GU_ADDON_NAME = "GU";
GU_DB_NAME = "GUDB";
GU_DB_CHAR_NAME = "GUCharacterDB";

-- Events stubs
function GU:PLAYER_LOGIN()                self:PlayerLogin();         end
-- function GU:AUCTION_HOUSE_SHOW()         self:AuctionHouseShow();      end
-- function GU:AUCTION_HOUSE_CLOSED()       self:AuctionHouseClosed();      end
-- function GU:AUCTION_ITEM_LIST_UPDATE()   self:AuctionItemListUpdate();      end
function GU:GET_ITEM_INFO_RECEIVED()   self:GetItemInfoReceived();      end

-- Event registration
GU:RegisterEvent("PLAYER_LOGIN");
GU:RegisterEvent("GET_ITEM_INFO_RECEIVED");
-- GU:RegisterEvent("AUCTION_HOUSE_SHOW");
-- GU:RegisterEvent("AUCTION_HOUSE_CLOSED");
-- GU:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");