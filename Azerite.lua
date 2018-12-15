local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateAzerite(self)
    local bar = self.azeriteBar
    local color = E.db.EPDBC.azeriteBar.color
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if E.db.EPDBC.azeriteBar.progress and azeriteItemLocation then
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation) -- do I need this?

        local avg = xp / totalLevelXP
        avg = EPDBC:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(0.8)
    end
end

function EPDBC:HookAzeriteBar()
    local bar = EDB.azeriteBar
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "UpdateAzerite") then
            EPDBC:SecureHook(EDB, "UpdateAzerite", UpdateAzerite)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "UpdateAzerite") then
            EPDBC:Unhook(EDB, "UpdateAzerite")
        end
        EPDBC:RestoreAzeriteBar()
    end
    EDB:UpdateAzerite()
end

function EPDBC:RestoreAzeriteBar()
    local bar = EDB.azeriteBar
    if bar then
        bar.statusBar:SetStatusBarColor(.901, .8, .601, 0.8)
    end
end