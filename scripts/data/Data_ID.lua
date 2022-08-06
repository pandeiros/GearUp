-- #TODO Copyright here

local GU = _G.GU;

local Data = GU.Data;

----------------------------------------------------------

-- #TODO This list was for Classic WoW, pending review for TBC/WotLK
-- List of unused IDs which items cannot be excluded using name patterns.
local deprecatedIDs = {
    12729, 186451, 186452, 186440
    -- 13503, 7950, 13262, 3529, 20368, 24071, 3320, 21584, 3536, 20005, 14390, 14383, 14382, 14388, 14389, 19065, 19129,
    -- 18951, 13843, 23072, 23162, 22230, 7948, 3542, 3538, 7951, 19971, 20502, 7949, 23058, 17108, 7953, 9443, 18303, 15141,
    -- 15780, 18342, 18341, 3533, 3528, 16785, 17769, 17142, 13847, 13848, 13846, 13849, 6724, 6728, 6711, 6707, 6708, 6698,
    -- 17783, 17782, 18582, 19989, 7187, 18584, 18583, 3527, 3547, 21613, 21614, 21612, 21587, 21588, 3541, 3537, 3522, 3526,
    -- 3529, 2554, 18023, 7952, 21594, 18320, 20003, 13844, 13842, 13845, 18355, 18304, 22273, 18316, 19986, 20524, 19186, 7869,
    -- 12585
}

function Data:GetAllItemIDs()
    return Data:GetAllItemIDs_V();
end

function Data:GetDeprecatedItemIDs()
    return deprecatedIDs;
end

function Data:GetMaxItemCount()
    return Data:GetMaxItemCount_V();
end

function Data:GetMaxItemDeprecatedCount()
    return Data:GetMaxItemDeprecatedCount_V();
end

function Data:GetNextItemIDIndex(index)
    local ids = self:GetAllItemIDs();
    if (index <= 0) then
        return 1;
    elseif (index > #ids) then
        return 1;
    end

    return index + 1;
end

function Data:GetItemIDAtIndex(index)
    local ids = self:GetAllItemIDs();
    if (index >= 1 and index <= #ids) then
        return ids[index];
    end
       
    return -1;
end

function Data:IsValidItemIndex(index)
    local ids = self:GetAllItemIDs();
    if (index >= 1 and index <= #ids) then
        return true;
    end
    
    return false;
end

-- NOTE: This is slow!
function Data:IsValidItemID(itemID)
    if (itemID < 0) then
        return false;
    end
    
    local ids = self:GetAllItemIDs();
    for k,v in pairs(ids) do
        -- IDs are sorted so if we are already past the searched ID, return false.
        if (v > itemID) then
            return false;
        end
        if (v == itemID) then
            return true;
        end
    end

    return false;
end