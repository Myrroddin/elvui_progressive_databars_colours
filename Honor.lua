local E, L, V, P, G = unpack(ElvUI)
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local function UpdateHonor(event, unit)
    -- cheap early filters first
    if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
        return
    end

    local bar = EDB.StatusBars and EDB.StatusBars.Honor
    if not bar then return end

    -- visibility handled by EDB; bail if honor disabled
    EDB:SetVisibility(bar)
    if not (EDB.db and EDB.db.honor and EDB.db.honor.enable) then
        return
    end

    local color = EDB.db.colors and EDB.db.colors.honor or {}
    local r, g, b = color.r or 1, color.g or 1, color.b or 1
    local baseA = color.a or 1.0

    -- get current & max values
    local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
    maximumValue = (maximumValue and maximumValue > 0) and maximumValue or 1

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, (E.db and E.db.EPDBC and E.db.EPDBC.progressSmoothing and E.db.EPDBC.progressSmoothing.decimalLength) or 3)

    -- alpha: use progress smoothing alpha when enabled, otherwise base alpha 1.0
    local useProgress = E.db and E.db.EPDBC and E.db.EPDBC.honorBar and E.db.EPDBC.honorBar.progress
    local a = useProgress and avg or baseA

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookHonorBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Honor
    if not bar then return end

    if not EPDBC:IsHooked(EDB, "HonorBar_Update") then
        EPDBC:SecureHook(EDB, "HonorBar_Update", UpdateHonor)
    end

    -- force an immediate update after hooking
    EDB:HonorBar_Update()
end

function EPDBC:RestoreHonorBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Honor
    if not bar then return end

    if EPDBC:IsHooked(EDB, "HonorBar_Update") then
        EPDBC:Unhook(EDB, "HonorBar_Update")
    end

    EDB:HonorBar_Update()
end