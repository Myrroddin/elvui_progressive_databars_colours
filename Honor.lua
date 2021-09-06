local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateHonor(self)
    local bar = EDB.StatusBars.Honor
    local color = E.db.EPDBC.honorBar.color
    bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    if E.db.EPDBC.honorBar.progress then
        local avg = UnitHonor("player") / UnitHonorMax("player")
        avg = EPDBC:Round(avg, 2)
        bar:SetAlpha(avg)
    else
        bar:SetAlpha(0.8)
    end
end

function EPDBC:HookHonorBar()
    local bar = EDB.StatusBars.Honor
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:SecureHook(EDB, "HonorBar_Update", UpdateHonor)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "HonorBar_Update") then
            EPDBC:Unhook(EDB, "HonorBar_Update")
        end
        EPDBC:RestoreHonorBar()
    end
    EDB:HonorBar_Update()
end

function EPDBC:RestoreHonorBar()
    local bar = EDB.StatusBars.Honor
    if bar then
        bar:SetStatusBarColor(0.941, 0.447, 0.254, 0.8)
    end
end