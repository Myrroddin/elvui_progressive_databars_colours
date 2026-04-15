-- local references to global functions so we don't conflict
local UNKNOWN = UNKNOWN
local huge = math.huge
local abs = math.abs
local min = math.min
local max = math.max
local format = format
local unpack = unpack

-- API compatibility flags
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local isMists = WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC

local E, L, V, P, G = unpack(ElvUI)
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local formatStrings = {
    ["PERCENT"] = "%s: %d%% [%s]",
    ["CURMAX"] = "%s: %s - %s [%s]",
    ["CURPERC"] = "%s: %s - %d%% [%s]",
    ["CUR"] = "%s: %s [%s]",
    ["REM"] = "%s: %s [%s]",
    ["CURREM"] = "%s: %s - %s [%s]",
    ["CURPERCREM"] = "%s: %s - %d%% (%s) [%s]",
}

-------------------------------------------------
-- Unified Faction API Wrapper
-------------------------------------------------
local function GetFactionData()
    if isMainline then
        local data = C_Reputation.GetWatchedFactionData()
        if not data then return nil end
        return data.name, data.reaction, data.factionID
    else
        local name, standingID, _, _, _, factionID = GetWatchedFactionInfo()
        return name, standingID, factionID
    end
end

local function UpdateReputation()
    local bar = EDB.StatusBars and EDB.StatusBars.Reputation
    if not bar then return end

    -- bail if reputation disabled
	if not bar.db and bar.db.enable or bar:ShouldHide() then return end

    local name, standingID, factionID = GetFactionData()
    if not name or not factionID or factionID <= 0 then return end

    local label, avg, percent, capped, rewardPending, a
    local friendshipInfo, rankInfo, majorFactionData
    local textFormat = EDB.db and EDB.db.reputation and EDB.db.reputation.textFormat

    -- get current & max values
    local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
    maximumValue = (maximumValue and maximumValue > 0) and maximumValue or 1

    if isMists or E.Retail then
        friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendshipInfo and friendshipInfo.friendshipFactionID and friendshipInfo.friendshipFactionID > 1 then
            rankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
            label = friendshipInfo.reaction
            local diff = 8 - (rankInfo.maxLevel or 0)
            standingID = min(max((rankInfo.currentLevel or 0) + diff, 1), 8)

            if E.db.EPDBC.reputationBar.fillExalted and friendshipInfo and friendshipInfo.friendshipFactionID > 0 and rankInfo and rankInfo.currentLevel == rankInfo.maxLevel then
                currentValue, maximumValue, a = 0, 1, 1
                capped, percent = true, 100
            end
        end
    end

    if E.db.EPDBC.reputationBar.fillHated and standingID <= 1 and currentValue == 0 then
        currentValue, maximumValue, a = 0, 1, 1
    elseif E.db.EPDBC.reputationBar.fillExalted and standingID == MAX_REPUTATION_REACTION then
        currentValue, maximumValue, a = 0, 1, 1
        capped, percent = true, 100
    end

    if E.Retail then
        if C_Reputation.IsFactionParagon(factionID) then
            standingID = 9
            label = L["Paragon"]
            currentValue, maximumValue, _, rewardPending = C_Reputation.GetFactionParagonInfo(factionID)
            currentValue = currentValue % maximumValue
            if rewardPending then currentValue = currentValue + maximumValue end
            capped, percent = nil, nil
        elseif C_Reputation.IsMajorFaction(factionID) then
            majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
            if not majorFactionData or majorFactionData.factionID <= 0 then return end
            standingID = 10
            local c = EDB.db.colors and EDB.db.db.colors.factionColors[10]
            label = format("%s%s|r %s", E:RGBToHex(c.r, c.g, c.b), RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)
            capped = C_MajorFactions.HasMaximumRenown(factionID)
            percent = capped and 100 or nil
            currentValue = capped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
            maximumValue = majorFactionData.renownLevelThreshold
            if capped then currentValue, maximumValue, a = 0, 1, 1 end
        end
    end

    local color = EDB.db.colors.factionColors[standingID] or _G.FACTION_BAR_COLORS[standingID] or {}
    local r, g, b = color.r or 1, color.g or 1, color.b or 1
    local baseA = color.a or 1.0

    avg = currentValue / maximumValue

    bar:SetMinMaxValues(0, maximumValue)
    bar:SetValue(currentValue)

    avg = abs(currentValue / maximumValue)
    while avg > 1 do avg = avg / 10 end
    percent = percent or avg * 100
    percent = percent < 100 and EPDBC:Round(percent, 2) or EPDBC:Round(percent, 0)
    avg = EPDBC:Round(avg, (E.db and E.db.EPDBC and E.db.EPDBC.progressSmoothing and E.db.EPDBC.progressSmoothing.decimalLength) or 3)

    if not label then
        label = _G["FACTION_STANDING_LABEL" .. standingID] or UNKNOWN
    end

    local displayString = ""
    if capped and textFormat ~= "NONE" then
        displayString = format("%s: [%s]", name, label)
    elseif formatStrings[textFormat] then
        displayString = format(formatStrings[textFormat], name, E:ShortValue(currentValue), E:ShortValue(maximumValue), label, E:ShortValue(maximumValue - currentValue))
    end
    bar.text:SetText(displayString)

    -- alpha: use progress smoothing alpha when enabled, otherwise base alpha 1.0
    local useProgress = E.db and E.db.EPDBC and E.db.EPDBC.reputationBar and E.db.EPDBC.reputationBar.progress
    a = useProgress and avg or baseA

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar and not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
        EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
    end
    EDB:ReputationBar_Update()
end

function EPDBC:RestoreRepBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Reputation
    if not bar then return end
    if EPDBC:IsHooked(EDB, "ReputationBar_Update") then
        EPDBC:Unhook(EDB, "ReputationBar_Update")
    end
    EDB:ReputationBar_Update()
end