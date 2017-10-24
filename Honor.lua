local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn
local bar = EDB.honorBar -- less typing

local function UpdateHonor()
    local color = E.db.PCB.honorBar.color
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

    if E.db.PCB.honorBar.progress then
        local avg = UnitHonor("player") / UnitHonorMax("player")
        avg = PCB:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(1)
    end
end

function PCB:HookHonorBar()
    if E.db.PCB.enabled and bar then
        if not PCB:IsHooked(EDB, "UpdateHonor") then
            PCB:SecureHook(EDB, "UpdateHonor", UpdateHonor)
        end
    elseif not E.db.PCB.enabled or not EDB.honorBar then
        if PCB:IsHooked(EDB, "UpdateHonor") then
            PCB:Unhook(EDB, "UpdateHonor")
        end
        PCB:RestoreHonorBar()
    end
    EDB:UpdateHonor()
end

function PCB:RestoreHonorBar()
    if bar then
        bar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
        bar.statusBar:SetAlpha(1)
    end
end