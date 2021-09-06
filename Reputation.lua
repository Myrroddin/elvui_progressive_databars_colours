local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

-- local variables ------------------------------------------------------------
-- Blizzard's FACTION_BAR_COLORS only has 8 entries but we'll fix that
local EPDBC_REP_BAR_COLORS = {
    [1] = {r = 1.00, g = 0.00, b = 0.00},       -- hated
    [2] = {r = 0.62, g = 0.62, b = 0.62},       -- hostile
    [3] = {r = 0.00, g = 0.80, b = 1.00},       -- unfriendly
    [4] = {r = 1.00, g = 1.00, b = 1.00},       -- neutral
    [5] = {r = 0.00, g = 1.00, b = 0.00},       -- friendly
    [6] = {r = 0.25, g = 0.40, b = 0.90},       -- honored
    [7] = {r = 0.60, g = 0.20, b = 0.80},       -- revered
    [8] = {r = 1.00, g = 0.50, b = 0.00},       -- exalted
    [9] = {r = 0.90, g = 0.80, b = 0.50},       -- paragon
}
local BACKUP = FACTION_BAR_COLORS[1]

-- helper function ------------------------------------------------------------
local function CheckRep(standingID, factionID, friendID, nextFriendThreshold)
    local isCapped = false
    local isParagon = C_Reputation.IsFactionParagon(factionID)

    if standingID == MAX_REPUTATION_REACTION then
        isCapped = true
    elseif isParagon then
        isCapped = false
    elseif nextFriendThreshold then
        isCapped = false
    elseif not nextFriendThreshold and friendID then
        isCapped = true
    end

    return isCapped, isParagon
end

-- local functions called via hooking -----------------------------------------
local function ReputationBar_OnEnter()
    local name, standingID, minimum, maximum, value, factionID = GetWatchedFactionInfo()
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
    local isCapped, isParagon = CheckRep(standingID, factionID, friendID, nextFriendThreshold)


    if name and E.db.EPDBC.reputationBar.capped then
        if isCapped and not isParagon then
            GameTooltip:ClearLines()

            if friendID then
                GameTooltip:AddLine(friendName)
            elseif not isParagon then
                GameTooltip:AddLine(name)
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(REPUTATION .. ":", L["Capped"])
            GameTooltip:Show()
        elseif isParagon then
            local replacement = L[E.db.EPDBC.reputationBar.textFormat == "P" and "P" or "Paragon"]

            for line = 1, GameTooltip:NumLines() do
                local lineTextRight = _G["GameTooltipTextRight" .. line]
                local lineTextRightText = lineTextRight:GetText()
                if lineTextRightText and lineTextRightText:len() >= 1 then
                    lineTextRight:SetText(gsub(lineTextRightText, FACTION_STANDING_LABEL8, replacement))
                end
            end
            GameTooltip:Show()
        end
    end
end

local function UpdateReputation(self)
    local name, standingID, minimum, maximum, value, factionID = GetWatchedFactionInfo()
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
    local isCapped, isParagon = CheckRep(standingID, factionID, friendID, nextFriendThreshold)
    local bar = EDB.StatusBars.Reputation

    if isCapped and not isParagon then
        -- don't want a blank bar at non-Paragon Exalted
        bar:SetMinMaxValues(0, 1)
        bar:SetValue(1)
    end

    if name then -- only do stuff if name has value
        if E.db.EPDBC.reputationBar.capped then
            if isCapped and not isParagon then
                if friendID then
                    bar.text:SetText(friendName .. ": " .. L["Capped"])
                elseif not isParagon then
                    bar.text:SetText(name .. ": " .. L["Capped"])
                end
            elseif isParagon then
                local replacement = L[E.db.EPDBC.reputationBar.textFormat == "P" and "P" or "Paragon"]
                replacement = "[" .. replacement .. "]"
                local barText = bar.text:GetText()
                if barText and barText:len() >= 1 then
                    barText = gsub(barText, "%[(.+)%]", replacement)
                    bar.text:SetText(barText)
                end
            end
        end

        -- color the rep bar
        local choice = E.db.EPDBC.reputationBar.color
        local color
        if isParagon then
            standingID = standingID + 1
        end

        if choice == "ascii" then
            color = EPDBC_REP_BAR_COLORS[standingID] or BACKUP
        elseif choice == "custom" then
            color = E.db.EPDBC.reputationBar.userColors[reaction] or BACKUP
        else
            color = FACTION_BAR_COLORS[reaction] or BACKUP
        end
        bar:SetStatusBarColor(color.r, color.g, color.b)

        -- blend the bar
        local avg = value / maximum
        avg = EPDBC:Round(avg, 2)
        if E.db.EPDBC.reputationBar.progress then
            bar:SetAlpha(avg)
        else
            bar:SetAlpha(1)
        end
    end
end

-- hooking fuctions -----------------------------------------------------------
function EPDBC:HookRepTooltip()
    local bar = EDB.StatusBars.Reputation
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "ReputationBar_OnEnter") then
            EPDBC:SecureHookScript(EDB, "ReputationBar_OnEnter", ReputationBar_OnEnter)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "ReputationBar_OnEnter") then
            EPDBC:Unhook(EDB, "ReputationBar_OnEnter")
        end
    end
end

function EPDBC:HookRepText()
    local bar = EDB.StatusBars.Reputation
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
            EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "ReputationBar_Update") then
            EPDBC:Unhook(EDB, "ReputationBar_Update")
        end
        EPDBC:RestoreRepColors()
    end
    EDB:ReputationBar_Update()
end

function EPDBC:RestoreRepColors()
    local bar = EDB.StatusBars.Reputation
    if bar then
        local _, standingID = GetWatchedFactionInfo()
        local color = FACTION_BAR_COLORS[standingID] or BACKUP

        bar:SetStatusBarColor(color.r, color.g, color.b)
        bar:SetAlpha(1)
    end
end