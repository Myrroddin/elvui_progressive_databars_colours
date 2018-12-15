local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateHonor(self)
    local bar = self.honorBar
    local color = E.db.EPDBC.honorBar.color
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    if E.db.EPDBC.honorBar.progress then
        local avg = UnitHonor("player") / UnitHonorMax("player")
        avg = EPDBC:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(0.8)
    end
end

function EPDBC:HookHonorBar()
    local bar = EDB.honorBar
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "UpdateHonor") then
            EPDBC:SecureHook(EDB, "UpdateHonor", UpdateHonor)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "UpdateHonor") then
            EPDBC:Unhook(EDB, "UpdateHonor")
        end
        EPDBC:RestoreHonorBar()
    end
    EDB:UpdateHonor()
end

function EPDBC:RestoreHonorBar()
    local bar = EDB.honorBar
    if bar then
        bar.statusBar:SetStatusBarColor(0.941, 0.447, 0.254, 0.8)
    end
end