-- local references to global functions so we don't conflict
local _G = _G
local unpack = _G.unpack

local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateHonor(event, unit)
    if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then return end

    local bar = EDB.StatusBars.Honor
    EDB:SetVisibility(bar)

	if not EDB.db.honor.enable then return end -- nothing to see here

    local colour = EDB.db.colors.honor
    local r, g, b, a = colour.r, colour.g, colour.b, colour.a or 1.0

    local minimumValue, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)

    if maximumValue == 0 then maximumValue = 1 end -- prevent division by 0 error

    local avg = currentValue / maximumValue
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    a = E.db.EPDBC.honorBar.progress and avg or 1.0

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookHonorBar()
    local bar = EDB.StatusBars.Honor

    if bar then
        if not EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:SecureHook(EDB, "HonorBar_Update", UpdateHonor)
        end
    end

    EDB:HonorBar_Update()
end

function EPDBC:RestoreHonorBar()
    local bar = EDB.StatusBars.Honor
    if bar then
        if EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:Unhook(EDB, "HonorBar_Update")
        end

        EDB:HonorBar_Update()
    end
end