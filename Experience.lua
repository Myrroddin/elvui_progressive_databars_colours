local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience()
    local bar = EDB.StatusBars and EDB.StatusBars.Experience
    if not bar then return end

    -- visibility handled by EDB; bail if honor disabled
    EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here

    local colour = EDB.db.colors.experience
    local r, g, b, a = colour.r, colour.g, colour.b, colour.a or 0.8

    local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)

    if (not maximumValue) or (maximumValue <= 0) then maximumValue = 1 end -- prevent division by 0 error

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    if E:XPIsLevelMax() then
        avg = 1.0
        a = 1.0
    end

    a = E.db.EPDBC.experienceBar.progress and avg or 0.8

    bar:SetStatusBarColor(r, g, b, a)
end

-- hook the XP bar
function EPDBC:HookXPBar()
    local bar = EDB.StatusBars.Experience

    if bar then
        if not EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
            EPDBC:SecureHook(EDB, "ExperienceBar_Update", UpdateExperience)
        end

        EDB:ExperienceBar_Update()
    end
end

function EPDBC:RestoreXPBar()
    local bar = EDB.StatusBars.Experience
    if bar then
        if EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
            EPDBC:Unhook(EDB, "ExperienceBar_Update")
        end

        EDB:ExperienceBar_Update()
    end
end