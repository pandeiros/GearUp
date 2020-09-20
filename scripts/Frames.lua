-- #TODO Copyright here

local Arma = _G.Arma;
local Style = Arma.Style;
local Colors = Style.Colors;
local Data = Arma.Data;
local Logger = Arma.Logger;

local Frames = {};
local Tooltip = {};
Arma_MainFrame = AceGUI:Create("Frame");

Arma.Frames = Frames;
Arma.Frames.Tooltip = Tooltip;
Arma.Frames.MainFrame = Arma_MainFrame;

----------------------------------------------------------
-- Main frame
----------------------------------------------------------

AceGUI:Release(Arma_MainFrame);

function Arma_MainFrame:GetName()
    return "Arma_MainFrame";
end

function Arma_MainFrame:Draw()
    self.timeSinceOpened = 0;
    self.timeSinceLastUpdate = 0;
    self.updateInterval = 0.005;  -- 0.0167;
    self.count = 0;

    self:SetTitle(ARMA_ADDON_NAME);
    self:SetStatusText("");
    self:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end);
    self:SetLayout("Fill");

    self:DrawTabs();

    self:AddChild(self.TabGroup);
end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
    container:ReleaseChildren();
    if group == "SettingsTab" then
        Arma_MainFrame:DrawSettingsTab(container);
    elseif group == "OtherTab" then
        Arma_MainFrame:DrawOtherTab(container);
    end
end

function Arma_MainFrame:DrawTabs()
    self.TabGroup = AceGUI:Create("TabGroup");
    self.TabGroup:SetLayout("Flow");
    self.TabGroup:SetTabs({
        {text="Settings", value="SettingsTab"}, 
        {text="Other", value="OtherTab"}});
    self.TabGroup:SetCallback("OnGroupSelected", SelectGroup);
    self.TabGroup:SelectTab("SettingsTab");
end

function Arma_MainFrame:DrawSettingsTab(container)
    local description = AceGUI:Create("Label");
    description:SetText("This is Settings Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = AceGUI:Create("Button");
    button:SetText("Button");
    button:SetWidth(200);
    container:AddChild(button);
end
    
function Arma_MainFrame:DrawOtherTab(container)
    local description = AceGUI:Create("Label");
    description:SetText("This is Other Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = AceGUI:Create("Button");
    button:SetText("Button");
    button:SetWidth(200);
    container:AddChild(button);
end

function Arma_MainFrame:OnUpdate(timeElapsed)
    self.timeSinceLastUpdate = self.timeSinceLastUpdate + timeElapsed;
    
    if (math.floor(self.timeSinceOpened + timeElapsed) > math.floor(self.timeSinceOpened)) then
        Logger:Verb(self.count);
        self.count = 0;
    end
    self.timeSinceOpened = self.timeSinceOpened + timeElapsed;
    
    local delta = timeElapsed / 10;

    while (self.timeSinceLastUpdate > delta) do
        self.count = self.count + 1;

      --
      -- Insert your OnUpdate code here
      --
  
      self.timeSinceLastUpdate = self.timeSinceLastUpdate - delta;
    end
end

Arma_MainFrame.frame:SetScript("OnUpdate", function(self, timeElapsed) Arma_MainFrame:OnUpdate(timeElapsed) end);

----------------------------------------------------------

function Frames:OpenMainFrame()
    self.MainFrame = AceGUI:Create("Frame");
    table.insert(UISpecialFrames, "Arma_MainFrame");
    self.MainFrame:Draw();
end

function Frames:CloseMainFrame()
    if (self.MainFrame) then
        self.MainFrame:Release();
    end
end

function Frames:OpenConfigFrame()
    -- self.ConfigFrame = AceGUI:Create("Frame");
    -- table.insert(UISpecialFrames, "Arma_ConfigFrame");
    -- self.ConfigFrame:Draw();
end

function Frames:CloseMainFrame()
    -- if (self.ConfigFrame) then
    --     self.ConfigFrame:Release();
    -- end
end

-----------------------------------------------------------

-- function Tooltip:AddItemInfo(tooltip)
--     local style = Arma.db.profile.style;
    
--     local name, link = tooltip:GetItem();
--     local itemID = Data:GetItemIDFromLink(link);
--     local itemData = Data:PrepareTooltipData(itemID);

--     -- self:PrintItemData(itemData, 0);

--     local vendorPrice = Data:GetItemVendorPrice(itemID);

--     local bShouldShowInfo = (vendorPrice > 0);
--     if (bShouldShowInfo) then
--         tooltip:AddLine(" ", Colors:HEXToRGB(style.mainColor));
--         tooltip:AddLine(ARMA_ADDON_NAME, Colors:HEXToRGB(style.mainColor));
--         if (vendorPrice > 0) then
--             -- SetTooltipMoney(tooltip, vendorPrice, "STATIC", Colors:GetColorStr(style.vendorColor, "|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:"), "");
--             --tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:  " .. Data:GetMoneyValueWithTextures(vendorPrice), Colors:HEXToRGB(style.vendorColor));
--         end
--         -- TEST
--         -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_01:0|t |TInterface\\Icons\\INV_Misc_Coin_02:16|t |TInterface\\Icons\\INV_Misc_Coin_03:16|t ", Colors:HEXToRGB(style.mainColor));
--         -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_04:16|t |TInterface\\Icons\\INV_Misc_Coin_05:16|t |TInterface\\Icons\\INV_Misc_Coin_06:16|t ", Colors:HEXToRGB(style.mainColor));
--         -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_07:16|t |TInterface\\Icons\\INV_Misc_Coin_08:16|t |TInterface\\Icons\\INV_Misc_Coin_09:16|t ", Colors:HEXToRGB(style.mainColor));
--         -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_10:16|t |TInterface\\Icons\\INV_Misc_Coin_11:16|t |TInterface\\Icons\\INV_Misc_Coin_12:16|t ", Colors:HEXToRGB(style.mainColor));
--         -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_13:16|t |TInterface\\Icons\\INV_Misc_Coin_14:16|t |TInterface\\Icons\\INV_Misc_Coin_15:16|t ", Colors:HEXToRGB(style.mainColor));

--         -- tooltip:AddLine(Professions:GetProfessionIcon(0) .. Professions:GetProfessionIcon(1) .. Professions:GetProfessionIcon(2) .. Professions:GetProfessionIcon(3), Colors:HEXToRGB(COLOR_WHITE));
--         -- tooltip:AddLine(Professions:GetProfessionIcon(4) .. Professions:GetProfessionIcon(5) .. Professions:GetProfessionIcon(6) .. Professions:GetProfessionIcon(7), Colors:HEXToRGB(COLOR_WHITE));
--         -- tooltip:AddLine(Professions:GetProfessionIcon(8) .. Professions:GetProfessionIcon(9) .. Professions:GetProfessionIcon(10) .. Professions:GetProfessionIcon(11), Colors:HEXToRGB(COLOR_WHITE));

--         -- VENDOR
--         tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:  " .. Data:GetMoneyValueWithTextures(vendorPrice), Colors:HEXToRGB(style.vendorColor));
--         -- tooltip:AddLine("    Full stack:  " .. Data:GetMoneyValueWithTextures(vendorPrice * 20) .. " (20)", Colors:HEXToRGB(style.vendorColor));

--         -- AH
--         tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tAuction for:  " .. Data:GetMoneyValueWithTextures(21) .. Colors:GetColorStr(Style:GetOperationQualityColor(3), " (+300%)"), Colors:HEXToRGB(style.auctionColor));
--         -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(20) .. "  Cut:  ".. Data:GetMoneyValueWithTextures(1), Colors:HEXToRGB(style.auctionColor));
--         -- tooltip:AddLine("    Min Buyout:  " .. Data:GetMoneyValueWithTextures(22) .. "  Items:  ".. Colors:GetColorStr(COLOR_WHITE, "47") .. "  Auctions:  " .. Colors:GetColorStr(COLOR_WHITE, "26"), Colors:HEXToRGB(style.auctionColor));

--         -- CRAFT
--         tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tCraft:  " .. Professions:GetProfessionIcon(0) .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Protection Potion") .. " and Auction for:  " .. Data:GetMoneyValueWithTextures(250) .. Colors:GetColorStr(Style:GetOperationQualityColor(4), " (+500%)"), Colors:HEXToRGB(style.craftColor));
--         -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(100) .. "  Cut:  ".. Data:GetMoneyValueWithTextures(12), Colors:HEXToRGB(style.craftColor));
--         -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(30) .. " per " .. Colors:GetColorStr(Style:GetRarityColor(1), "Firefin Snapper"), Colors:HEXToRGB(style.craftColor));
--         -- tooltip:AddLine("    Requires:  " .. Professions:GetProfessionIcon(0) .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Oil") .. ", " .. Colors:GetColorStr(Style:GetRarityColor(1), " Small Flame Sac").. ", ".. Colors:GetColorStr(Style:GetRarityColor(1), " Empty Vial"), Colors:HEXToRGB(style.craftColor));
--         -- tooltip:AddLine("        " .. Professions:GetProfessionIcon(0) .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Oil") .. " requires: " .. Colors:GetColorStr(Style:GetRarityColor(1), " Firefin Snapper [2]").. ", ".. Colors:GetColorStr(Style:GetRarityColor(1), " Empty Vial"), Colors:HEXToRGB(style.craftColor));
--         -- END TEST    
--     end
-- end

-- function Tooltip:PrintItemData(itemData, indent)
--     if (not itemData.itemID) then
--         return;
--     end
    
--     local itemName = GetItemInfo(itemData.itemID);

--     Logger:Printf("%s%s (%d):", string.rep(" ", indent * 4), itemName, itemData.itemID);
--     Logger:Printf("%s- Vendor price: %d, AH price: %d", string.rep(" ", indent * 4), itemData.vendorPrice, 123);
--     for k,v in pairs(itemData.reagentFor) do
--         self:PrintItemData(v, indent + 1);
--     end
-- end