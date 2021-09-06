local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience(self)
    local bar = EDB.StatusBars.Experience
    local xpColor = E.db.EPDBC.experienceBar.xpColor
    local restColor = E.db.EPDBC.experienceBar.restColor
    local isMaxLevel = UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

    if isMaxLevel then
        status:SetMinMaxValues(0, 1)
        rested:SetMinMaxValues(0, 0)
        status:SetValue(1)
        rested:SetValue(0)
        status:SetAlpha(1)
        rested:SetAlpha(0)

        if E.db.EPDBC.experienceBar.capped then
            bar.text:SetText(L["Capped"])
        end
    end

    bar:SetStatusBarColor(xpColor.r, xpColor.g, xpColor.b, xpColor.a)
    bar.Rested:SetStatusBarColor(restColor.r, restColor.g, restColor.b, restColor.a)

    if E.db.EPDBC.experienceBar.progress and not isMaxLevel then
        local avg = UnitXP("player")/UnitXPMax("player")
        avg = EPDBC:Round(avg, 2)
        bar:SetAlpha(avg)
    elseif not E.db.EPDBC.experienceBar.progress then
        bar:SetAlpha(0.8)
    end
end

local function ExperienceBar_OnEnter()
    local isMaxLevel = UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

    if isMaxLevel and E.db.EPDBC.experienceBar.capped then
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["Experience"])
	    GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L["XP:"], L["Capped"])
        GameTooltip:Show()
    end
end

-- hook the XP bar text and colour
function EPDBC:HookXPText()
    local bar = EDB.StatusBars.Experience
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
            EPDBC:SecureHook(EDB, "ExperienceBar_Update", UpdateExperience)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
            EPDBC:Unhook(EDB, "ExperienceBar_Update")
        end
        EPDBC:RestoreXPColours()
    end
    EDB:ExperienceBar_Update()
end

-- hook the GameTooltip of the XP bar
function EPDBC:HookXPTooltip()
    local bar = EDB.StatusBars.Experience
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "ExperienceBar_OnEnter") then
            EPDBC:SecureHookScript(EDB, "ExperienceBar_OnEnter", ExperienceBar_OnEnter)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "ExperienceBar_OnEnter") then
            EPDBC:Unhook(EDB, "ExperienceBar_OnEnter")
        end
    end
end

function EPDBC:RestoreXPColours()
    local bar = EDB.StatusBars.Experience
    if bar then
        bar:SetStatusBarColor(0, 0.4, 1, 0.8) -- ElvUI default colour
        bar:SetMinMaxValues(0, 0)
        bar:SetValue(0)

        bar.Rested:SetStatusBarColor(1, 0, 1, 0.2)
        bar.Rested:SetMinMaxValues(0, 0)
        bar.Rested:SetValue(0)
    end
end