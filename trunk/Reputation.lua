local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local SLE = LibStub("AceAddon-3.0"):GetAddon("ElvUI_SLE", true) -- Shadow & Light
if SLE then
    local SDB = SLE:GetModule("DataBars") -- Shadow & Light's DataBars
end
local PCB = E:GetModule("PCB") -- this AddOn

-- local variables ------------------------------------------------------------
-- Blizzard's FACTION_BAR_COLORS only has 8 entries but we'll fix that
local PCB_REP_BAR_COLORS = {
    [1] = {r = 1, g = 0, b = 0, a = 1},             -- hated
    [2] = {r = 1, g = 0.55, b = 0, a = 1},          -- hostile
    [3] = {r = 1, g = 1, b = 0, a = 1},             -- unfriendly
    [4] = {r = 1, g = 1, b = 1, a = 1},             -- neutral
    [5] = {r = 0, g = 1, b = 0, a = 1},             -- friendly
    [6] = {r = 0.25,  g = 0.4,  b = 0.9, a = 1},    -- honored
    [7] = {r = 0.6, g = 0.2, b = 0.8, a = 1},       -- revered
    [8] = {r = 0.9, g = 0.8,  b = 0.5, a = 1},      -- exalted
    [9] = {r = 0.75,  g = 0.75, b = 0.75, a = 1},   -- paragon
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


    if name and E.db.PCB.reputationBar.capped then
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
            local replacement = L[E.db.PCB.reputationBar.textFormat == "P" and "P" or "Paragon"]

            for line = 1, GameTooltip:NumLines() do
                local lineTextRight = _G["GameTooltipTextRight" .. line]
                local lineTextRightText = lineTextRight:GetText()
                if lineTextRightText then
                    lineTextRight:SetText(gsub(lineTextRightText, FACTION_STANDING_LABEL8, replacement))
                end
            end
            GameTooltip:Show()
        end
    end
end

local function UpdateReputation(self)
    local bar = self.repBar
    local name, standingID, minimum, maximum, value, factionID = GetWatchedFactionInfo()
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
    local isCapped, isParagon = CheckRep(standingID, factionID, friendID, nextFriendThreshold)

    if isCapped and not isParagon then
        -- don't want a blank bar at non-Paragon Exalted
        bar.statusBar:SetMinMaxValues(0, 1)
        bar.statusBar:SetValue(1)
    end

    if name then -- only do stuff if name has value
        if E.db.PCB.reputationBar.capped then
            if isCapped and not isParagon then
                if friendID then
                    bar.text:SetText(friendName .. ": " .. L["Capped"])
                elseif not isParagon then
                    bar.text:SetText(name .. ": " .. L["Capped"])
                end
            elseif isParagon then
                local replacement = L[E.db.PCB.reputationBar.textFormat == "P" and "P" or "Paragon"]
                replacement = "[" .. replacement .. "]"
                local barText = bar.text:GetText()
                barText = gsub(barText, "%[(.+)%]", replacement)
                bar.text:SetText(barText)
            end
        end

        -- color the rep bar
        if E.db.PCB.reputationBar.color == "ascii" then
            if isParagon then
                standingID = standingID + 1
            end

            local color = PCB_REP_BAR_COLORS[standingID] or BACKUP
            bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)
        else
            local color = FACTION_BAR_COLORS[standingID] or BACKUP
            bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)
        end

        -- blend the bar
        local avg = value / maximum
        avg = PCB:Round(avg, 2)
        if E.db.PCB.reputationBar.progress then
            bar.statusBar:SetAlpha(avg)
        else
            bar.statusBar:SetAlpha(1)
        end
    end
end

-- hooking fuctions -----------------------------------------------------------
function PCB:HookRepTooltip()
    if E.db.PCB.enabled and EDB.repBar then
        if not PCB:IsHooked(_G["ElvUI_ReputationBar"], "OnEnter") then
            PCB:SecureHookScript(_G["ElvUI_ReputationBar"], "OnEnter", ReputationBar_OnEnter)
        end
    elseif not E.db.PCB.enabled or not EDB.repBar then
        if PCB:IsHooked(_G["ElvUI_ReputationBar"], "OnEnter") then
            PCB:Unhook(_G["ElvUI_ReputationBar"], "OnEnter")
        end
    end
end

function PCB:HookRepText()
    if E.db.PCB.enabled and EDB.repBar then
        if not PCB:IsHooked(EDB, "UpdateReputation") then
            PCB:SecureHook(EDB, "UpdateReputation", UpdateReputation)
            if SLE then
                if not PCB:IsHooked(SDB, "UpdateReputation") then
                    PCB:SecureHook(SDB, "UpdateReputation", UpdateReputation)
                end
            end
        end
    elseif not E.db.PCB.enabled or not EDB.repBar then
        if PCB:IsHooked(EDB, "UpdateReputation") then
            PCB:Unhook(EDB, "UpdateReputation")
            if SLE then
                if PCB:IsHooked(SDB, "UpdateReputation") then
                    PCB:Unhook(SDB, "UpdateReputation")
                end
            end
        end
        PCB:RestoreRepColors()
    end
    EDB:UpdateReputation()
end

function PCB:RestoreRepColors()
    local bar = EDB.repBar
    if bar then
        local _, standingID = GetWatchedFactionInfo()
        local color = FACTION_BAR_COLORS[standingID] or BACKUP

        bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)
        bar.statusBar:SetAlpha(1)
    end
end