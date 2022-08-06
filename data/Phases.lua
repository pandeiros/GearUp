-- #TODO Copyright here

local GU = _G.GU;

local Phases = {};
GU.Data.Phases = Phases;

----------------------------------------------------------

----------------------------------------------------------
-- Phase functions
----------------------------------------------------------

function Phases:GetCurrentPhase()
    return Phases:GetCurrentPhase_V();
end

function Phases:GetPhaseForItemID(itemID)
    return Phases:GetPhaseForItemID_V(itemID);
end

function Phases:IsPhaseAvailable(phase)
    return Phases:IsPhaseAvailable_V(phase);
end 