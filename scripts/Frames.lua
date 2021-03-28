-- #TODO Copyright here

local GU = _G.GU;
local Style = GU.Style;
local Colors = Style.Colors;
local Data = GU.Data;
local Logger = GU.Logger;
local Async = GU.Async;
local Misc = GU.Misc;

local Frames = {};
local Tooltip = {};
GU_MainFrame = AceGUI:Create("Frame");

GU.Frames = Frames;
GU.Frames.Tooltip = Tooltip;
GU.Frames.MainFrame = GU_MainFrame;

----------------------------------------------------------
-- Main frame
----------------------------------------------------------

AceGUI:Release(GU_MainFrame);

function GU_MainFrame:GetName()
    return "GU_MainFrame";
end

function GU_MainFrame:Draw()
    self.timeSinceOpened = 0;
    self.timeSinceLastUpdate = 0;
    self.updateInterval = 0.1;
    -- self.updateInterval = 0.0167;
    self.count = 0;

    self:SetTitle(GU_ADDON_NAME);
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
        GU_MainFrame:DrawSettingsTab(container);
    elseif group == "OtherTab" then
        GU_MainFrame:DrawOtherTab(container);
    end
end

function GU_MainFrame:DrawTabs()
    self.TabGroup = AceGUI:Create("TabGroup");
    self.TabGroup:SetLayout("Flow");
    self.TabGroup:SetTabs({
        {text="Settings", value="SettingsTab"}, 
        {text="Other", value="OtherTab"}});
    self.TabGroup:SetCallback("OnGroupSelected", SelectGroup);
    self.TabGroup:SelectTab("SettingsTab");
end

function GU_MainFrame:DrawSettingsTab(container)
    local description = AceGUI:Create("Label");
    description:SetText("This is Settings Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = AceGUI:Create("Button");
    button:SetText("Button");
    button:SetWidth(200);
    container:AddChild(button);
end
    
function GU_MainFrame:DrawOtherTab(container)
    local description = AceGUI:Create("Label");
    description:SetText("This is Other Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = AceGUI:Create("Button");
    button:SetText("Button");
    button:SetWidth(200);
    container:AddChild(button);
end

function GU_MainFrame:Tick(deltaTime)
end

function GU_MainFrame:OnUpdate(timeElapsed)
end

-- GU_MainFrame.frame:SetScript("OnUpdate", function(self, timeElapsed) GU_MainFrame:OnUpdate(timeElapsed) end);

local UpdateFrame = CreateFrame("Frame");
UpdateFrame:SetScript("OnUpdate", function(self, timeElapsed)
    Frames:OnUpdate(timeElapsed);
end)

----------------------------------------------------------

function Frames:Initialize()
    self.timeSinceOpened = 0;
    self.timeSinceLastUpdate = 0;
    self.updateInterval = 0.1;
    -- self.updateInterval = 0.0167;
    self.count = 0;
end

Frames:Initialize();

function Frames:Tick(deltaTime)
    -- Data:ScanItems();
    -- local itemDB = GU.db.global.itemDB;
    -- Logger:Verb(itemDB.processedIDs .. " -- " .. itemDB.deprecatedIDs .. " -- " .. #itemDB.invalidIDs);
end

function Frames:OnUpdate(timeElapsed)
    if (math.floor(self.timeSinceOpened + timeElapsed) > math.floor(self.timeSinceOpened)) then
        -- Logger:Verb(self.count);
        self.count = 0;
    end
    self.timeSinceOpened = self.timeSinceOpened + timeElapsed;
    self.timeSinceLastUpdate = self.timeSinceLastUpdate + timeElapsed;
    
    -- Code running at max 60fps
    local deltaTime = math.max(timeElapsed, self.updateInterval);
    while (self.timeSinceLastUpdate > deltaTime) do
        self.count = self.count + 1;
        self:Tick(deltaTime);  
        self.timeSinceLastUpdate = self.timeSinceLastUpdate - deltaTime;
    end

    -- Task scheduling
    for _ = 1,1 do
        Async:ScheduleTask();
        Data:ScanItems();
    end
end

function Frames:OpenMainFrame()
    self.MainFrame = AceGUI:Create("Frame");
    table.insert(UISpecialFrames, "GU_MainFrame");
    self.MainFrame:Draw();
end

function Frames:CloseMainFrame()
    if (self.MainFrame) then
        self.MainFrame:Release();
    end
end

function Frames:OpenConfigFrame()
    -- self.ConfigFrame = AceGUI:Create("Frame");
    -- table.insert(UISpecialFrames, "GU_ConfigFrame");
    -- self.ConfigFrame:Draw();
end

function Frames:CloseConfigFrame()
    -- if (self.ConfigFrame) then
    --     self.ConfigFrame:Release();
    -- end
end

-----------------------------------------------------------

function Tooltip:AddItemInfo(tooltip)
    local style = GU.db.profile.style;
    
    local name, link = tooltip:GetItem();
    local itemID = Misc:GetItemIDFromLink(link);

    if (link or itemID) then
        Data:AddPendingItemToScan(itemID, link);
    end

    if (link) then
        -- tooltip:AddLine(GU_ADDON_NAME, Colors:HEXToRGB(style.primaryAccentColor));
        local s = string.sub(link, 1, 10) .. string.sub(link, 13, -1);
        -- tooltip:AddLine(s, Colors:HEXToRGB(style.primaryAccentColor));
        -- Logger:Display(s);
        -- Logger:Display(link);
        -- PrintAllData(tooltip);
        -- if (tooltip.default ~= nil) then
        --     tooltip.default = nil;
        --     print("DEFAULT");
        -- else
        --     -- tooltip.default = 1;
        --     print("NO DEFAULT");
        -- end
        -- local attr = tooltip:GetAttribute();
        -- local spell = tooltip:GetSpell();
        -- local id = tooltip:GetID();
        -- local unit = tooltip:GetUnit();
        -- local forbid = tooltip:IsForbidden();
        -- print(attr);
        -- print(spell);
        -- print(id);
        -- print(unit);
        -- print(forbid);
        -- tooltip:SetRecipeResultItem(3473);
        -- local text = Data:GetTooltipText(link);
        -- print(text);
        return;
    end

    -- local itemData = Data:PrepareTooltipData(itemID);

    -- self:PrintItemData(itemData, 0);

    local vendorPrice = Misc:GetItemVendorPrice(itemID);

    local bShouldShowInfo = (vendorPrice > 0);
    if (bShouldShowInfo) then
        tooltip:AddLine(" ", Colors:HEXToRGB(style.primaryAccentColor));
        tooltip:AddLine(GU_ADDON_NAME, Colors:HEXToRGB(style.primaryAccentColor));
        if (vendorPrice > 0) then
            -- SetTooltipMoney(tooltip, vendorPrice, "STATIC", Colors:GetColorStr(style.vendorColor, "|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:"), "");
            --tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:  " .. Data:GetMoneyValueWithTextures(vendorPrice), Colors:HEXToRGB(style.vendorColor));
        end
        -- TEST
        -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_01:0|t |TInterface\\Icons\\INV_Misc_Coin_02:16|t |TInterface\\Icons\\INV_Misc_Coin_03:16|t ", Colors:HEXToRGB(style.mainColor));
        -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_04:16|t |TInterface\\Icons\\INV_Misc_Coin_05:16|t |TInterface\\Icons\\INV_Misc_Coin_06:16|t ", Colors:HEXToRGB(style.mainColor));
        -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_07:16|t |TInterface\\Icons\\INV_Misc_Coin_08:16|t |TInterface\\Icons\\INV_Misc_Coin_09:16|t ", Colors:HEXToRGB(style.mainColor));
        -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_10:16|t |TInterface\\Icons\\INV_Misc_Coin_11:16|t |TInterface\\Icons\\INV_Misc_Coin_12:16|t ", Colors:HEXToRGB(style.mainColor));
        -- tooltip:AddLine("|TInterface\\Icons\\INV_Misc_Coin_13:16|t |TInterface\\Icons\\INV_Misc_Coin_14:16|t |TInterface\\Icons\\INV_Misc_Coin_15:16|t ", Colors:HEXToRGB(style.mainColor));

        -- tooltip:AddLine(Professions:GetProfessionIcon(0) .. Professions:GetProfessionIcon(1) .. Professions:GetProfessionIcon(2) .. Professions:GetProfessionIcon(3), Colors:HEXToRGB(COLOR_WHITE));
        -- tooltip:AddLine(Professions:GetProfessionIcon(4) .. Professions:GetProfessionIcon(5) .. Professions:GetProfessionIcon(6) .. Professions:GetProfessionIcon(7), Colors:HEXToRGB(COLOR_WHITE));
        -- tooltip:AddLine(Professions:GetProfessionIcon(8) .. Professions:GetProfessionIcon(9) .. Professions:GetProfessionIcon(10) .. Professions:GetProfessionIcon(11), Colors:HEXToRGB(COLOR_WHITE));

        -- VENDOR
        tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tVendor for:  " .. Misc:GetMoneyValueWithTextures(vendorPrice), Colors:HEXToRGB(style.primaryAccentColor));
        -- tooltip:AddLine("    Full stack:  " .. Data:GetMoneyValueWithTextures(vendorPrice * 20) .. " (20)", Colors:HEXToRGB(style.vendorColor));

        -- AH
        tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tAuction for:  " .. Misc:GetMoneyValueWithTextures(21) .. Colors:GetColorStr(Style:GetOperationQualityColor(3), " (+300%)"), Colors:HEXToRGB(style.secondaryAccentColor));
        -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(20) .. "  Cut:  ".. Data:GetMoneyValueWithTextures(1), Colors:HEXToRGB(style.auctionColor));
        -- tooltip:AddLine("    Min Buyout:  " .. Data:GetMoneyValueWithTextures(22) .. "  Items:  ".. Colors:GetColorStr(COLOR_WHITE, "47") .. "  Auctions:  " .. Colors:GetColorStr(COLOR_WHITE, "26"), Colors:HEXToRGB(style.auctionColor));

        -- CRAFT
        tooltip:AddLine("|TInterface\\Moneyframe\\Arrow-Right-Disabled:0|tCraft:  " .. "Alchemy" .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Protection Potion") .. " and Auction for:  " .. Misc:GetMoneyValueWithTextures(250) .. Colors:GetColorStr(Style:GetOperationQualityColor(4), " (+500%)"), Colors:HEXToRGB(style.primaryAccentColor));
        -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(100) .. "  Cut:  ".. Data:GetMoneyValueWithTextures(12), Colors:HEXToRGB(style.craftColor));
        -- tooltip:AddLine("    Profit:  " .. Data:GetMoneyValueWithTextures(30) .. " per " .. Colors:GetColorStr(Style:GetRarityColor(1), "Firefin Snapper"), Colors:HEXToRGB(style.craftColor));
        -- tooltip:AddLine("    Requires:  " .. Professions:GetProfessionIcon(0) .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Oil") .. ", " .. Colors:GetColorStr(Style:GetRarityColor(1), " Small Flame Sac").. ", ".. Colors:GetColorStr(Style:GetRarityColor(1), " Empty Vial"), Colors:HEXToRGB(style.craftColor));
        -- tooltip:AddLine("        " .. Professions:GetProfessionIcon(0) .. " " .. Colors:GetColorStr(Style:GetRarityColor(1), "Fire Oil") .. " requires: " .. Colors:GetColorStr(Style:GetRarityColor(1), " Firefin Snapper [2]").. ", ".. Colors:GetColorStr(Style:GetRarityColor(1), " Empty Vial"), Colors:HEXToRGB(style.craftColor));
        -- END TEST    
    end
end

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