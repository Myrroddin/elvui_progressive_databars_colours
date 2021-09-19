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
function EPDBC:HookRepBar()
    local bar = EDB.StatusBars.Reputation
    if bar then
        if not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
            EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
        end
    elseif EPDBC:IsHooked(EDB, "ReputationBar_Update") then
        EPDBC:Unhook(EDB, "ReputationBar_Update")
        EPDBC:RestoreRepBar()
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