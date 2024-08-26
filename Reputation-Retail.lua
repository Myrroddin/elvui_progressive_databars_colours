-- local references to global functions so we don't conflict
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local RENOWN_LEVEL_LABEL = RENOWN_LEVEL_LABEL
local UNKNOWN = UNKNOWN
local abs = math.abs
local huge = math.huge
local unpack = unpack
local format = format
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks
local GetMajorFactionData = C_MajorFactions.GetMajorFactionData
local HasMaximumRenown = C_MajorFactions.HasMaximumRenown
local GetWatchedFactionData = C_Reputation.GetWatchedFactionData
local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local IsMajorFaction = C_Reputation.IsMajorFaction

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI"s DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local functions called via hooking -----------------------------------------
local function UpdateReputation()
    local bar = EDB.StatusBars.Reputation
    EDB:SetVisibility(bar)

    if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here

    local factionData = GetWatchedFactionData()
    if not factionData then return end -- nothing to see here

    local factionID = factionData.factionID or 0
    local name = factionData.name or UNKNOWN
    local standingID = factionData.reaction or 0
    local minimumValue = factionData.currentReactionThreshold or 0
    local maximumValue = factionData.nextReactionThreshold or huge
    local currentValue = factionData.currentStanding or 0

    if (not factionID) or (factionID == 0) then return end -- nothing to see here

    local _, friendshipInfo, rankInfo, majorFactionData
    local displayString, textFormat = "", EDB.db.reputation.textFormat
    local label, avg, rewardPending, capped, percent, colour, a

    -- handle friends
    friendshipInfo = GetFriendshipReputation(factionID)
    if (friendshipInfo and friendshipInfo.friendshipFactionID) and (friendshipInfo.friendshipFactionID > 1) then
        rankInfo = GetFriendshipReputationRanks(factionID)
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

        minimumValue, maximumValue, currentValue = friendshipInfo.reactionThreshold or 0, friendshipInfo.nextThreshold or huge, friendshipInfo.standing or 0
    end

    -- normalize bar values, otherwise minimumValue gets added to maximumValue and currentValue, EX: friendly looks like 3000-9000 instead of 0-6000
    maximumValue = maximumValue - minimumValue
    currentValue = currentValue - minimumValue
    minimumValue = 0

    -- fill the bar at lowest reputation
    if E.db.EPDBC.reputationBar.fillHated then
        if standingID <= 1 then
            if currentValue == minimumValue then
                a, minimumValue, currentValue, maximumValue = 1, 0, 1, 1
            end
        end
    end

    -- fill the bar at max reputation
    if E.db.EPDBC.reputationBar.fillExalted then
        if (standingID == MAX_REPUTATION_REACTION) or (friendshipInfo.friendshipFactionID > 0 and rankInfo.currentLevel == rankInfo.maxLevel) then
            a, minimumValue, currentValue, maximumValue = 1, 0, 1, 1
            capped = true
            percent = 100
        end
    end

    -- paragon code
    if IsFactionParagon(factionID) then
        standingID = 9 -- jump to Paragon colour
        label = L["Paragon"]

        currentValue, maximumValue, _, rewardPending = GetFactionParagonInfo(factionID)
        currentValue = currentValue % maximumValue
        if rewardPending then
            currentValue = currentValue + maximumValue
        end
        minimumValue = 0
        capped = nil
        percent = nil

        -- show paragon rewards icon (or not) as per user preferences
        bar.Reward:ClearAllPoints()
        bar.Reward:SetPoint("CENTER", bar, EDB.db.reputation.rewardPosition)
        bar.Reward:SetShown(rewardPending and EDB.db.reputation.showReward)

    -- major faction code
    elseif IsMajorFaction(factionID) then
        majorFactionData = GetMajorFactionData(factionID)
        if not majorFactionData then return end -- not a major faction
        if majorFactionData.factionID > 0 then
            standingID = 10 -- jump to major faction colour
            local renownColor = EDB.db.colors.factionColors[10]
            local renownHex = E:RGBToHex(renownColor.r, renownColor.g, renownColor.b)
            label = format("%s%s|r %s", renownHex, RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

            capped = HasMaximumRenown(factionID)
            percent = capped and 100 or nil

            currentValue = capped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
            maximumValue = majorFactionData.renownLevelThreshold
            minimumValue = 0

            if capped then
                -- make the bar full at max renown
                minimumValue, currentValue, maximumValue = 0, 1, 1
            end
        end
    end

    bar:SetMinMaxValues(0, maximumValue)
    bar:SetValue(currentValue)

    if maximumValue == 0 then maximumValue = 1 end -- prevent division by 0 error

    avg = currentValue / maximumValue

    -- avg may be out of 0-1 bounds for alpha, fix
    avg = abs(avg)
    while avg > 1 do
        avg = avg / 10
    end

    percent = percent or avg * 100
    if percent < 100 then
        percent = EPDBC:Round(percent, 2)
    else
        percent = EPDBC:Round(percent, 0)
    end

    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    a = E.db.EPDBC.reputationBar.progress and avg or 1

    -- set bar text correctly
    if not label then
        label = _G["FACTION_STANDING_LABEL" .. standingID] or UNKNOWN
    end

    if capped and textFormat ~= "NONE" then -- show only name and standing at Exalted,Best Friends, or max Renown
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

        EDB:ReputationBar_Update()
    end
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