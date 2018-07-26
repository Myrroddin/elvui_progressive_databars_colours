local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn

local function UpdateAzerite(self)
    local bar = self.azeriteBar
    local color = E.db.PCB.azeriteBar.color
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if E.db.PCB.azeriteBar.progress and azeriteItemLocation then
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation) -- do I need this?

        local avg = xp / totalLevelXP
        avg = PCB:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(1)
    end
end

function PCB:HookAzeriteBar()
    if E.db.PCB.enabled and EDB.azeriteBar then
        if not PCB:IsHooked(EDB, "UpdateAzerite") then
            PCB:SecureHook(EDB, "UpdateAzerite", UpdateAzerite)
        end
    elseif not E.db.PCB.enabled or not EDB.azeriteBar then
        if PCB:IsHooked(EDB, "UpdateAzerite") then
            PCB:Unhook(EDB, "UpdateAzerite")
        end
        PCB:RestoreAzeriteBar()
    end
    EDB:UpdateAzerite()
end

function PCB:RestoreAzeriteBar()
    local bar = EDB.azeriteBar

    if bar then
        bar.statusBar:SetAlpha(1)
        bar.statusBar:SetStatusBarColor(.901, .8, .601)
    end
end