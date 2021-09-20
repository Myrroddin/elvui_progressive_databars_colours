local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local functions called via hooking -----------------------------------------
local function UpdateReputation(self)
    local bar = EDB.StatusBars.Reputation
    local r, g, b, a = bar:GetStatusBarColor()
    local currentValue, maximum = EPDBC:GetCurentMaxValues(bar)
    local avg = currentValue / maximum
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    
    if not E.db.EPDBC.reputationBar.progress then
        a = 1.0
    else
        a = avg
    end

    local name, standingID, minimum, maximum, value, factionID = GetWatchedFactionInfo()

    -- fill the bar at max reputation
    if E.db.EPDBC.reputationBar.fillExalted then
        if standingID == MAX_REPUTATION_REACTION then
            --@version-retail@
            if C_Reputation.IsFactionParagon(factionID) then -- don't want fill the bar at Paragon
                return
            end
            --@end-version-retail@
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(1)
        end
    end

    -- fill the bar at lowest reputation
    if E.db.EPDBC.reputationBar.fillHated then
        if standingID == 1 and value == 0 then
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(1)
        end
    end

    -- blend the bar
    bar:SetStatusBarColor(r, g, b, a)
end

-- hooking fuctions -----------------------------------------------------------
function EPDBC:HookRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar then
        if not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
            EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
        end
    end
    EDB:ReputationBar_Update()
end

function EPDBC:RestoreRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar then
        if EPDBC:IsHooked("ReputationBar_Update") then
            EPDBC:Unhook("ReputationBar_Update")
        end

        EDB:ReputationBar_Update()
    end
end