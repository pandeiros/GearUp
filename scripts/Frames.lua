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
GU_MainFrame = GU_AceGUI:Create("Frame");

GU.Frames = Frames;
GU.Frames.Tooltip = Tooltip;
GU.Frames.MainFrame = GU_MainFrame;

----------------------------------------------------------
-- Main frame
----------------------------------------------------------

GU_AceGUI:Release(GU_MainFrame);

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
    self:SetCallback("OnClose", function(widget) GU_AceGUI:Release(widget) end);
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
    self.TabGroup = GU_AceGUI:Create("TabGroup");
    self.TabGroup:SetLayout("Flow");
    self.TabGroup:SetTabs({
        {text="Settings", value="SettingsTab"}, 
        {text="Other", value="OtherTab"}});
    self.TabGroup:SetCallback("OnGroupSelected", SelectGroup);
    self.TabGroup:SelectTab("SettingsTab");
end

function GU_MainFrame:DrawSettingsTab(container)
    local description = GU_AceGUI:Create("Label");
    description:SetText("This is Settings Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = GU_AceGUI:Create("Button");
    button:SetText("Button");
    button:SetWidth(200);
    container:AddChild(button);
end
    
function GU_MainFrame:DrawOtherTab(container)
    local description = GU_AceGUI:Create("Label");
    description:SetText("This is Other Tab");
    description:SetFullWidth(true);
    container:AddChild(description);
    
    local button = GU_AceGUI:Create("Button");
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
    self.updateInterval = 0.0167;

    self.count = 0;
    self.taskSpeed = 1.0;
    self.maxTasks = 100;
end

Frames:Initialize();

function Frames:Tick(deltaTime)

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

    -- Dynamic task speed adjusting.
    if (timeElapsed > 0) then
        if (timeElapsed / self.updateInterval > 1.25 and self.taskSpeed > 0.0) then
            self.taskSpeed = math.max(0.0, self.taskSpeed - 0.05);
            -- Logger:Verb("Frames:OnUpdate Decreasing task speed to %1.2f", self.taskSpeed);
        elseif (timeElapsed / self.updateInterval < 0.75 and self.taskSpeed < 1.0) then
            self.taskSpeed = math.min(1.0, self.taskSpeed + 0.05);
            -- Logger:Verb("Frames:OnUpdate Increasing task speed to %1.2f", self.taskSpeed);
        end
    else
        self.taskSpeed = 0.0;
    end   

    -- Task scheduling
    local taskCount = math.max(1, math.floor(self.maxTasks * self.taskSpeed));

    if (Data:HasTasks()) then
        Data:DoTasks(taskCount);
    end
end

function Frames:OpenMainFrame()
    self.MainFrame = GU_AceGUI:Create("Frame");
    table.insert(UISpecialFrames, "GU_MainFrame");
    self.MainFrame:Draw();
end

function Frames:CloseMainFrame()
    if (self.MainFrame) then
        self.MainFrame:Release();
    end
end

function Frames:OpenConfigFrame()
    -- self.ConfigFrame = GU_AceGUI:Create("Frame");
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
        Data:AddPrioItemToScan(itemID, link);
    end

    if (link) then
        -- tooltip:AddLine(GU_ADDON_NAME, Colors:HEXToRGB(style.primaryAccentColor));
        -- local s = string.sub(link, 1, 10) .. string.sub(link, 13, -1);

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
end