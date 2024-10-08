-- local references to global functions so we don't conflict
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local UNKNOWN = UNKNOWN
local abs = math.abs
local unpack = unpack
local format = format
local GetWatchedFactionInfo = GetWatchedFactionInfo

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local functions called via hooking -----------------------------------------
local function UpdateReputation()
    local bar = EDB.StatusBars.Reputation
    EDB:SetVisibility(bar)

    if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here

    local name, standingID, minimumValue, maximumValue, currentValue, factionID = GetWatchedFactionInfo()
    if not factionID then return end -- nothing to see here

    local displayString, textFormat = "", EDB.db.reputation.textFormat
    local label, avg, capped, percent, colour, a

    -- normalize bar values, otherwise minimumValue gets added to maximumValue and currentValue, EX: friendly looks like 3000-9000 instead of 0-6000
    maximumValue = maximumValue or 0
    currentValue = currentValue or 0
    minimumValue = minimumValue or 0
    maximumValue = maximumValue - minimumValue
    currentValue = currentValue - minimumValue
    minimumValue = 0

    -- fill the bar at lowest reputation
    if E.db.EPDBC.reputationBar.fillHated then
        if standingID <= 1 then
            if currentValue == minimumValue then
                a, minimumValue, currentValue, maximumValue = 1.0, 0, 1, 1
            end
        end
    end

    -- fill the bar at max reputation
    if E.db.EPDBC.reputationBar.fillExalted then
        if standingID == MAX_REPUTATION_REACTION then
            a, currentValue, maximumValue = 1.0, 1, 1
            capped = true
            percent = 100
        end
    end

    bar:SetMinMaxValues(minimumValue, maximumValue)
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