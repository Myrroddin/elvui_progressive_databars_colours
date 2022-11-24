-- local references to global functions so we don't conflict
local _G = _G
local unpack = _G.unpack

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateExperience()
    local bar = EDB.StatusBars.Experience
    EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here
    
    local xpColour = EDB.db.colors.experience
    local r, g, b, a = xpColour.r, xpColour.g, xpColour.b, xpColour.a

    local currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)

    if maximumValue <= 1 then maximumValue = 1 end -- prevent division by 0 error

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    if E:XPIsLevelMax() then
        avg = 1.0
        a = 1.0
    end

    a = E.db.EPDBC.experienceBar.progress and avg or a

    bar:SetStatusBarColor(r, g, b, a)
end

-- hook the XP bar
function EPDBC:HookXPBar()
    local bar = EDB.StatusBars.Experience

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