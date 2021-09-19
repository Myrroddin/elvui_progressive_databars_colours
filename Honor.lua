local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateHonor(self)
    local bar = EDB.StatusBars.Honor
    local r, g, b, a = bar:GetStatusBarColor()
    local currentValue, maximum = EPDBC:GetCurentMaxValues(bar)
    local avg = currentValue / maximum
    avg = EPDBC:Round(avg, E.db.EPDBC.progressSmoothing.decimalLength)
    
    if not E.db.EPDBC.honorBar.progress then
        a = 1.0
    else
        a = avg
    end

    bar:SetStatusBarColor(r, g, b, a)
end

function EPDBC:HookHonorBar()
    local bar = EDB.StatusBars.Honor
    if bar then
        if not EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:SecureHook(EDB, "HonorBar_Update", UpdateHonor)
        elseif EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:Unhook(EDB, "HonorBar_Update")
            EPDBC:RestoreHonorBar()
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