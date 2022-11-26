-- local references to global functions so we don't conflict
local _G = _G
local C_GossipInfo = _G.C_GossipInfo
local C_MajorFactions = _G.C_MajorFactions
local C_Reputation = _G.C_Reputation
local MAX_REPUTATION_REACTION = _G.MAX_REPUTATION_REACTION
local RENOWN_LEVEL_LABEL = _G.RENOWN_LEVEL_LABEL
local UNKNOWN = _G.UNKNOWN
local unpack = _G.unpack
local format = _G.format
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI"s DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local functions called via hooking -----------------------------------------
local function UpdateReputation()
    local bar = EDB.StatusBars.Reputation
    EDB:SetVisibility(bar)

    if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here

    local name, standingID, _, _, _, factionID = GetWatchedFactionInfo()
    if not factionID then return end -- nothing to see here

    local friendshipInfo, rankInfo, majorFactionData
    local displayString, textFormat = "", EDB.db.reputation.textFormat
    local label, avg, rewardPending, capped, percent, colour, a

    -- handle friends
    friendshipInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID)
    if friendshipInfo and friendshipInfo.friendshipFactionID > 0 then
        rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
        label = friendshipInfo.reaction
        rankInfo.currentLevel = rankInfo.currentLevel or 0
        rankInfo.maxLevel = rankInfo.maxLevel or 0
        local difference = 8 - rankInfo.maxLevel

        standingID = rankInfo.currentLevel + difference -- put it on a hated (1) to exalted (8) scale

        -- stay within hated (1) to exalted (8) bounds
        if standingID >= 8 then
            standingID = 8
        end
        if standingID <= 1 then
            standingID = 1
        end
    end

    local minimumValue, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)

    -- fill the bar at lowest reputation
    if E.db.EPDBC.reputationBar.fillHated then
        if (standingID <= 1) or (friendshipInfo.friendshipFactionID > 0 and friendshipInfo.standing <= 1) then
            if currentValue == minimumValue then
                a, minimumValue, currentValue, maximumValue = 1.0, 0, 1, 1
            end
        end
    end

    -- fill the bar at max reputation
    if E.db.EPDBC.reputationBar.fillExalted then
        if (standingID == MAX_REPUTATION_REACTION) or (friendshipInfo.friendshipFactionID > 0 and rankInfo.currentLevel == rankInfo.maxLevel) then
            a, minimumValue, currentValue, maximumValue = 1.0, 0, 1, 1
            capped = true
            percent = 100
        end
    end

    -- paragon code
    if C_Reputation.IsFactionParagon(factionID) then
        standingID = 9 -- jump to Paragon colour
        label = L["Paragon"]

        currentValue, maximumValue, _, rewardPending = C_Reputation.GetFactionParagonInfo(factionID)
        currentValue = currentValue % maximumValue
        minimumValue = 0
        capped = nil
        percent = nil

        -- show paragon rewards icon (or not) as per user preferences
        bar.Reward:ClearAllPoints()
        bar.Reward:SetPoint("CENTER", bar, EDB.db.reputation.rewardPosition)
        bar.Reward:SetShown(rewardPending and EDB.db.reputation.showReward)

    -- major faction code
    elseif C_Reputation.IsMajorFaction(factionID) then
        majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
        if majorFactionData and majorFactionData.factionID > 0 then
            if (standingID == MAX_REPUTATION_REACTION) or (friendshipInfo.friendshipFactionID > 0 and rankInfo.currentLevel == rankInfo.maxLevel) then
                standingID = 10 -- jump to major faction colour
                local renownColor = EDB.db.colors.factionColors[10]
                local renownHex = E:RGBToHex(renownColor.r, renownColor.g, renownColor.b)
                label = format("%s%s|r %s", renownHex, RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

                currentValue = majorFactionData.renownReputationEarned
                maximumValue = majorFactionData.renownLevelThreshold
                currentValue = currentValue % maximumValue
                minimumValue = 0
                capped = nil
                percent = nil
            end
        end
    end

    bar:SetMinMaxValues(minimumValue, maximumValue)
    bar:SetValue(currentValue)

    if maximumValue == 0 then maximumValue = 1 end -- prevent division by 0 error

    avg = currentValue / maximumValue
    percent = percent or avg * 100
    if percent < 100 then
        percent = EPDBC:Round(percent, 2)
    else
        percent = EPDBC:Round(percent, 0)
    end

    -- avg may be out of 0-1 bounds for alpha, fix
    if avg > 1 then
        avg = avg / 10
    end

    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    a = E.db.EPDBC.reputationBar.progress and avg or 1.0

    -- set bar text correctly
    if not label then
        label = _G["FACTION_STANDING_LABEL" .. standingID] or UNKNOWN
    end

    if capped and textFormat ~= "NONE" then -- show only name and standing on exalted
        displayString = format("%s: [%s]", name, label)
    elseif textFormat == "PERCENT" then
        displayString = format("%s: %d%% [%s]", name, percent, label)
    elseif textFormat == "CURMAX" then
        displayString = format("%s: %s - %s [%s]", name, E:ShortValue(currentValue), E:ShortValue(maximumValue), label)
    elseif textFormat == "CURPERC" then
        displayString = format("%s: %s - %d%% [%s]", name, E:ShortValue(currentValue), percent, label)
    elseif textFormat == "CUR" then
        displayString = format("%s: %s [%s]", name, E:ShortValue(currentValue), label)
    elseif textFormat == "REM" then
        displayString = format("%s: %s [%s]", name, E:ShortValue(maximumValue - currentValue), label)
    elseif textFormat == "CURREM" then
        displayString = format("%s: %s - %s [%s]", name, E:ShortValue(currentValue), E:ShortValue(maximumValue - currentValue), label)
    elseif textFormat == "CURPERCREM" then
        displayString = format("%s: %s - %d%% (%s) [%s]", name, E:ShortValue(currentValue), percent, E:ShortValue(maximumValue - currentValue), label)
    end
    bar.text:SetText(displayString)

    -- colour the bar
    colour = EDB.db.colors.factionColors[standingID]
    bar:SetStatusBarColor(colour.r, colour.g, colour.b, a or 1)
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