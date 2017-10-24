local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local SLE = LibStub("AceAddon-3.0"):GetAddon("ElvUI_SLE", true) -- Shadow & Light
if SLE then
    local SDB = SLE:GetModule("DataBars") -- Shadow & Light's DataBars
end
local PCB = E:GetModule("PCB") -- this AddOn
local bar = EDB.expBar -- less typing

local function UpdateExperience()
    local xpColor = E.db.PCB.experienceBar.xpColor
    local isMaxLevel = UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

    if isMaxLevel then
        bar.statusBar:SetMinMaxValues(0, 1)
        bar.rested:SetMinMaxValues(0, 0)
        bar.statusBar:SetValue(1)
        bar.rested:SetValue(0)
        bar.statusBar:SetAlpha(1)

        if E.db.PCB.experienceBar.capped then
            bar.text:SetText(L["Capped"])
        end
    end

    bar.statusBar:SetStatusBarColor(xpColor.r, xpColor.g, xpColor.b, xpColor.a)

    if E.db.PCB.experienceBar.progress and not isMaxLevel then
        local avg = UnitXP("player")/UnitXPMax("player")
        avg = PCB:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    elseif not E.db.PCB.experienceBar.progress or isMaxLevel then
        bar.statusBar:SetAlpha(0.8)
    end
end

local function ExperienceBar_OnEnter()
    local isMaxLevel = UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

    if isMaxLevel and E.db.PCB.experienceBar.capped then
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Experience"])
	    GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L["XP:"], L["Capped"])
        GameTooltip:Show()
    end
end

-- hook the XP bar text and colour
function PCB:HookXPText()
    if E.db.PCB.enabled and bar then
        if not PCB:IsHooked(EDB, "UpdateExperience") then
            PCB:SecureHook(EDB, "UpdateExperience", UpdateExperience)
            if SLE then
                if not PCB:IsHooked(SDB, "UpdateExperience") then
                    PCB:SecureHook(SDB, "UpdateExperience", UpdateExperience)
                end
            end
        end
    elseif not E.db.PCB.enabled or not bar then
        if PCB:IsHooked(EDB, "UpdateExperience") then
            PCB:Unhook(EDB, "UpdateExperience")
            if SLE then
                if PCB:IsHooked(SDB, "UpdateExperience") then
                    PCB:Unhook(SDB, "UpdateExperience")
                end
            end
        end
        PCB:RestoreXPColours()
    end
    EDB:UpdateExperience()
end

-- hook the GameTooltip of the XP bar
function PCB:HookXPTooltip()
    if E.db.PCB.enabled and bar then
        if not PCB:IsHooked(_G["ElvUI_ExperienceBar"], "OnEnter") then
            PCB:SecureHookScript(_G["ElvUI_ExperienceBar"], "OnEnter", ExperienceBar_OnEnter)
        end
    elseif not E.db.PCB.enabled or not bar then
        if PCB:IsHooked(_G["ElvUI_ExperienceBar"], "OnEnter") then
            PCB:Unhook(_G["ElvUI_ExperienceBar"], "OnEnter")
        end
    end
end

function PCB:RestoreXPColours()
    if bar then
        bar.statusBar:SetStatusBarColor(0, 0.4, 1, 0.8) -- ElvUI default colour
        bar.statusBar:SetAlpha(0.8)
        bar.statusBar:SetMinMaxValues(0, 0)
        bar.statusBar:SetValue(0)
    end
end