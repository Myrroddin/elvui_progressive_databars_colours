-- local references to global functions so we don"t conflict
local _G = _G
local unpack = _G.unpack

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI"s DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateAzerite(event, unit)
    if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then return end

    local bar = EDB.StatusBars.Azerite
    EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end -- nothing to see here

    local colour = EDB.db.colors.azerite
    local r, g, b, a = colour.r, colour.g, colour.b, colour.a or 1.0

    local minimumValue, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)

    if maximumValue == 0 then maximumValue = 1 end -- prevent division by 0 error

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    a = E.db.EPDBC.azeriteBar.progress and avg or 1.0

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookAzeriteBar()
    local bar = EDB.StatusBars.Azerite

    if bar then
        if not EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
            EPDBC:SecureHook(EDB, "AzeriteBar_Update", UpdateAzerite)
        end
    end

    EDB:AzeriteBar_Update()
end

function EPDBC:RestoreAzeriteBar()
    local bar = EDB.StatusBars.Azerite

    if bar then
        if EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
            EPDBC:Unhook(EDB, "AzeriteBar_Update")
        end

        EDB:AzeriteBar_Update()
    end
end