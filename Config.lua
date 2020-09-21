-- #TODO Copyright here

local Arma = _G.Arma;

-- Version
ADDON_VERSION = "0.1.1"

-- Dev mode
ARMA_DEV_MODE_ENABLED = true;   -- whether dev mode is enabled AT ALL
ARMA_DEV_MODE_FORCED = true;    -- whether we force dev mode, even if not toggled via console (requires ARMA_DEV_MODE_ENABLED to true)

-- Commonly used variables
ARMA_DISPLAY_NAME = "Armamentarium"
ARMA_ADDON_NAME = "Arma";
ARMA_DB_NAME = "ArmaDB";
ARMA_DB_CHAR_NAME = "ArmaCharacterDB";

-- Events stubs
function Arma:PLAYER_LOGIN()                self:PlayerLogin();         end
-- function Arma:AUCTION_HOUSE_SHOW()         self:AuctionHouseShow();      end
-- function Arma:AUCTION_HOUSE_CLOSED()       self:AuctionHouseClosed();      end
-- function Arma:AUCTION_ITEM_LIST_UPDATE()   self:AuctionItemListUpdate();      end
function Arma:GET_ITEM_INFO_RECEIVED()   self:GetItemInfoReceived();      end

-- Event registration
Arma:RegisterEvent("PLAYER_LOGIN");
Arma:RegisterEvent("GET_ITEM_INFO_RECEIVED");
-- Arma:RegisterEvent("AUCTION_HOUSE_SHOW");
-- Arma:RegisterEvent("AUCTION_HOUSE_CLOSED");
-- Arma:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");