-- local references to global functions so we don't conflict
local UNKNOWN = UNKNOWN
local huge = math.huge
local abs = math.abs
local min = math.min
local max = math.max
local format = format
local unpack = unpack

local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks
local GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local GetWatchedFactionData = C_Reputation.GetWatchedFactionData
local GetWatchedFactionInfo = GetWatchedFactionInfo
local IsFactionParagon = C_Reputation.IsFactionParagon
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local IsMajorFaction = C_Reputation.IsMajorFaction
local isMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

local E, L, V, P, G = unpack(ElvUI)
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local function NormalizeValues(minVal, maxVal, curVal)
    return 0, maxVal - minVal, curVal - minVal
end

local formatStrings = {
    ["PERCENT"] = "%s: %d%% [%s]",
    ["CURMAX"] = "%s: %s - %s [%s]",
    ["CURPERC"] = "%s: %s - %d%% [%s]",
    ["CUR"] = "%s: %s [%s]",
    ["REM"] = "%s: %s [%s]",
    ["CURREM"] = "%s: %s - %s [%s]",
    ["CURPERCREM"] = "%s: %s - %d%% (%s) [%s]",
}

local function UpdateReputation()
    local bar = EDB.StatusBars.Reputation
    EDB:SetVisibility(bar)
    if not bar.db.enable or bar:ShouldHide() then return end

    local name, standingID, minVal, maxVal, curVal, factionID

    if E.Retail then
        local factionData = GetWatchedFactionData()
        if not factionData then return end
        factionID = factionData.factionID or 0
        name = factionData.name or UNKNOWN
        standingID = factionData.reaction or 0
        minVal = factionData.currentReactionThreshold or 0
        maxVal = factionData.nextReactionThreshold or huge
        curVal = factionData.currentStanding or 0
    else
        name, standingID, minVal, maxVal, curVal, factionID = GetWatchedFactionInfo()
    end

    if not factionID or factionID == 0 then return end

    local label, avg, percent, capped, rewardPending, a
    local friendshipInfo, rankInfo, majorFactionData
    local textFormat = EDB.db.reputation.textFormat

    if isMists or E.Retail then
        friendshipInfo = GetFriendshipReputation(factionID)
        if friendshipInfo and friendshipInfo.friendshipFactionID and friendshipInfo.friendshipFactionID > 1 then
            rankInfo = GetFriendshipReputationRanks(factionID)
            label = friendshipInfo.reaction
            local diff = 8 - (rankInfo.maxLevel or 0)
            standingID = min(max((rankInfo.currentLevel or 0) + diff, 1), 8)
            minVal, maxVal, curVal = friendshipInfo.reactionThreshold or 0, friendshipInfo.nextThreshold or huge, friendshipInfo.standing or 0
        end
    end

    maxVal, curVal = NormalizeValues(minVal, maxVal, curVal)

    if E.db.EPDBC.reputationBar.fillHated and standingID <= 1 and curVal == 0 then
        a, minVal, curVal, maxVal = 1, 0, 1, 1
    end

    if E.db.EPDBC.reputationBar.fillExalted and friendshipInfo and friendshipInfo.friendshipFactionID > 0 and rankInfo and rankInfo.currentLevel == rankInfo.maxLevel then
        a, minVal, curVal, maxVal = 1, 0, 1, 1
        capped, percent = true, 100
    elseif E.db.EPDBC.reputationBar.fillExalted and standingID == MAX_REPUTATION_REACTION then
        a, minVal, curVal, maxVal = 1, 0, 1, 1
        capped, percent = true, 100
    end

    if E.Retail then
        if IsFactionParagon(factionID) then
            standingID = 9
            label = L["Paragon"]
            curVal, maxVal, _, rewardPending = GetFactionParagonInfo(factionID)
            curVal = curVal % maxVal
            if rewardPending then curVal = curVal + maxVal end
            minVal, capped, percent = 0, nil, nil
            bar.Reward:ClearAllPoints()
            bar.Reward:SetPoint("CENTER", bar, EDB.db.reputation.rewardPosition)
            bar.Reward:SetShown(rewardPending and EDB.db.reputation.showReward)
        elseif IsMajorFaction(factionID) then
            majorFactionData = GetMajorFactionData(factionID)
            if not majorFactionData or majorFactionData.factionID <= 0 then return end
            standingID = 10
            local c = EDB.db.colors.factionColors[10]
            label = format("%s%s|r %s", E:RGBToHex(c.r, c.g, c.b), RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)
            capped = HasMaximumRenown(factionID)
            percent = capped and 100 or nil
            curVal = capped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
            maxVal = majorFactionData.renownLevelThreshold
            minVal = 0
            if capped then minVal, curVal, maxVal = 0, 1, 1 end
        end
    end

    if (not maxVal) or (maxVal <= 0) then maxVal = 1 end -- prevent division by 0 error
    bar:SetMinMaxValues(0, maxVal)
    bar:SetValue(curVal)

    avg = abs(curVal / maxVal)
    while avg > 1 do avg = avg / 10 end
    percent = percent or avg * 100
    percent = percent < 100 and EPDBC:Round(percent, 2) or EPDBC:Round(percent, 0)
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    a = E.db.EPDBC.reputationBar.progress and avg or 1

    if not label then
        label = _G["FACTION_STANDING_LABEL" .. standingID] or UNKNOWN
    end

    local displayString = ""
    if capped and textFormat ~= "NONE" then
        displayString = format("%s: [%s]", name, label)
    elseif formatStrings[textFormat] then
        displayString = format(formatStrings[textFormat], name, E:ShortValue(curVal), E:ShortValue(maxVal), label, E:ShortValue(maxVal - curVal))
    end
    bar.text:SetText(displayString)

    local c = EDB.db.colors.factionColors[standingID]
    bar:SetStatusBarColor(c.r, c.g, c.b, a or 1)
end

function EPDBC:HookRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar and not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
        EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
    end
    EDB:ReputationBar_Update()
end

function EPDBC:RestoreRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar and EPDBC:IsHooked("ReputationBar_Update") then
        EPDBC:Unhook("ReputationBar_Update")
    end
    EDB:ReputationBar_Update()
end