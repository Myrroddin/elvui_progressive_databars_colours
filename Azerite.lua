local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateAzerite(self)
    local bar = EDB.StatusBars.Azerite
    if not bar then return end -- nothing to see here

    local r, g, b, a = bar:GetStatusBarColor()
    local currentValue, maximum = EPDBC:GetCurrentMaxValues(bar)
    local avg = currentValue / maximum
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)

    if not E.db.EPDBC.AzeriteBarProgress then
        a = 1.0
    else
        a = avg
    end

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookAzeriteBar()
    local bar = EDB.StatusBars.Azerite
    local isEnabled = bar.db.enable
    if not isEnabled then return end -- azerite bar disabled, exit
    
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