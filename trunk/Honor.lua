local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn

local function UpdateHonor()
    local bar = EDB.honorBar

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
    if E.db.PCB.enabled then
        if not PCB:IsHooked(E:GetModule("DataBars"), "UpdateHonor") then
            PCB:SecureHook(E:GetModule("DataBars"), "UpdateHonor", UpdateHonor)
        end
    else
        if PCB:IsHooked(E:GetModule("DataBars"), "UpdateHonor") then
            PCB:Unhook(E:GetModule("DataBars"), "UpdateHonor")
        end
        PCB:RestoreHonorBar()
    end
    EDB:UpdateHonor()
end

function PCB:RestoreHonorBar()
    local bar = EDB.honorBar
    bar.statusBar:SetStatusBarColor(240/255, 114/255, 65/255)
    bar.statusBar:SetAlpha(1)
end