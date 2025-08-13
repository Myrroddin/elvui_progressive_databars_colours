local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience()
    local bar = EDB.StatusBars and EDB.StatusBars.Experience
    if not bar then return end

    -- bail if experience disabled
	if not bar.db and bar.db.enable or bar:ShouldHide() then return end

    local color = EDB.db.colors and EDB.db.colors.experience or {}
    local r, g, b = color.r or 1, color.g or 1, color.b or 1
    local baseA = (E:XPIsLevelMax() and 1.0) or color.a or 0.8

    local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
    maximumValue = (maximumValue and maximumValue > 0) and maximumValue or 1

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, (E.db and E.db.EPDBC and E.db.EPDBC.progressSmoothing and E.db.EPDBC.progressSmoothing.decimalLength) or 3)

    -- alpha: use progress smoothing alpha when enabled, otherwise base alpha 0.8
    local useProgress = E.db and E.db.EPDBC and E.db.EPDBC.experienceBar and E.db.EPDBC.experienceBar.progress
    local a = useProgress and avg or baseA

    bar:SetStatusBarColor(r, g, b, a)
end

-- hook the XP bar
function EPDBC:HookXPBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Experience
    if not bar then return end

    if not EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
        EPDBC:SecureHook(EDB, "ExperienceBar_Update", UpdateExperience)
    end

    -- force an immediate update after hooking
    EDB:ExperienceBar_Update()
end

function EPDBC:RestoreExperienceBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Experience
    if not bar then return end

    if EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
        EPDBC:Unhook(EDB, "ExperienceBar_Update")
    end

    EDB:ExperienceBar_Update()
end