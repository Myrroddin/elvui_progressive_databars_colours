local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local functions called via hooking -----------------------------------------
local function UpdateReputation(self)
    local bar = EDB.StatusBars.Reputation
    local name, standingID, minimum, maximum, value, factionID = GetWatchedFactionInfo()

    if not bar or not name then return end -- nothing to see here

    local r, g, b, a = bar:GetStatusBarColor()
    local currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    
    if not E.db.EPDBC.reputationBar.progress then
        a = 1.0
    else
        a = avg
    end

    -- fill the bar at lowest reputation
    if E.db.EPDBC.reputationBar.fillHated then
        if standingID <= 1 then
            if value >= 1 or currentValue >= 1 then
                bar:SetMinMaxValues(0, maximumValue)
                bar:SetValue(currentValue)
                a = avg
            else
                bar:SetMinMaxValues(0, 1)
                bar:SetValue(1)
                a = 1.0
            end
        end
    end

    -- fill the bar at max reputation
    if E.db.EPDBC.reputationBar.fillExalted then
        if standingID == MAX_REPUTATION_REACTION then
            if value == maximumValue then
                bar:SetMinMaxValues(0, 1)
                bar:SetValue(1)
                a = 1.0
            end
        end
    end
    
    --@version-retail@
    -- handle friends
    local friendID = GetFriendshipReputation(factionID)

    if friendID then
        local currentRank, maximumRank = GetFriendshipReputationRanks(friendID)
        local difference = 8 - maximumRank

        currentRank = currentRank + difference -- put it on a hated (1) to exalted (8) scale

        -- keep it within bounds
        if currentRank >= 8 then
            currentRank = 8
        end
        if currentRank <= 1 then
            currentRank = 1
        end

        if C_Reputation.IsFactionParagon(factionID) then
            currentRank = currentRank + 1 -- put it on a hated (1) to paragon (9) scale

            -- keep it within bounds
            if currentRank >= 9 then
                currentRank = 9
            end

            local currentParagonValue, thresholdParagonValue = C_Reputation.GetFactionParagonInfo(factionID)
            bar:SetMinMaxValues(0, thresholdParagonValue)
            bar:SetValue(currentParagonValue)
            avg = currentParagonValue / thresholdParagonValue
            avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
            a = avg

            -- set bar text correctly
            bar.text:SetText(name .. ":" .." " .. currentParagonValue .. " - " .. thresholdParagonValue .. " [" .. L["Paragon"] .. "]")

            -- show paragon rewards icon (or not) as per user preferences
            bar.Reward:SetPoint('CENTER', bar, EDB.db.reputation.rewardPosition)
        end

        -- colour the reputation bar for friends
        local colour = EDB.db.colors.factionColors[currentRank]
        r, g, b = colour.r, colour.g, colour.b
    end
    --@end-version-retail@

    -- blend the bar
    bar:SetStatusBarColor(r, g, b, a)
end

-- hooking fuctions -----------------------------------------------------------
function EPDBC:HookRepBar()
    local bar = EDB.StatusBars.Reputation
    local isEnabled = bar.db.enable
    if not isEnabled then return end -- reputaion bar disabled, exit

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