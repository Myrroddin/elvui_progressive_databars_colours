local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience(self)
    local bar = EDB.StatusBars.Experience
    local xpColor = E.db.EPDBC.experienceBar.xpColor
    local restColor = E.db.EPDBC.experienceBar.restColor
    local isMaxLevel = UnitXPMax("player")

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

-- hook the XP bar
function EPDBC:HookXPBar()
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