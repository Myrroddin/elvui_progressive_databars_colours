local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience(self)
    local bar = EDB.StatusBars.Experience
    if not bar then return end -- nothing to see here
    
    local r, g, b, a = bar:GetStatusBarColor()
    local currentValue, maximum = EPDBC:GetCurrentMaxValues(bar)
    local avg = currentValue / maximum
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    local playerAtMaxLevel = UnitXPMax("player") <= 0

    if not E.db.EPDBC.experienceBar.progress or playerAtMaxLevel then
        a = 0.8
    else
        a = avg
    end

    bar:SetStatusBarColor(r, g, b, a)
end

-- hook the XP bar
function EPDBC:HookXPBar()
    local bar = EDB.StatusBars.Experience
    local isEnabled = bar.db.enable
    if not isEnabled then return end -- experience bar disabled, exit

    if bar then
        if not EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
            EPDBC:SecureHook(EDB, "ExperienceBar_Update", UpdateExperience)
        end
    end

    EDB:ExperienceBar_Update()
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