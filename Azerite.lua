local E, L, V, P, G = unpack(ElvUI)
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local function UpdateAzerite(event, unit)
    -- cheap early filters first
    if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then
        return
    end

    local bar = EDB.StatusBars and EDB.StatusBars.Azerite
    if not bar then return end

    -- visibility handled by EDB; bail if azerite disabled
    EDB:SetVisibility(bar)
    if not (EDB.db and EDB.db.azerite and EDB.db.azerite.enable) then
        return
    end

    local color = EDB.db.colors and EDB.db.colors.azerite or {}
    local r, g, b = color.r or 1, color.g or 1, color.b or 1
    local baseA = color.a or 1.0

    -- get current & max values
    local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
    maximumValue = (maximumValue and maximumValue > 0) and maximumValue or 1

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, (E.db and E.db.EPDBC and E.db.EPDBC.progressSmoothing and E.db.EPDBC.progressSmoothing.decimalLength) or 3)

    -- alpha: use progress smoothing alpha when enabled, otherwise base alpha 1.0
    local useProgress = E.db and E.db.EPDBC and E.db.EPDBC.azeriteBar and E.db.EPDBC.azeriteBar.progress
    local a = useProgress and avg or baseA

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookAzeriteBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Azerite
    if not bar then return end

    if not EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
        EPDBC:SecureHook(EDB, "AzeriteBar_Update", UpdateAzerite)
    end

    -- force an immediate update after hooking
    EDB:AzeriteBar_Update()
end

function EPDBC:RestoreAzeriteBar()
    local bar = EDB.StatusBars and EDB.StatusBars.Azerite
    if not bar then return end

    if EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
        EPDBC:Unhook(EDB, "AzeriteBar_Update")
    end

    EDB:AzeriteBar_Update()
end