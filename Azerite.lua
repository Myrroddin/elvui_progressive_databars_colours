local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateAzerite(self)
    local bar = EDB.StatusBars.Azerite
    local color = E.db.EPDBC.azeriteBar.color
    bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if E.db.EPDBC.azeriteBar.progress and azeriteItemLocation then
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation) -- do I need this?

        local avg = xp / totalLevelXP
        avg = EPDBC:Round(avg, 2)
        bar:SetAlpha(avg)
    else
        bar:SetAlpha(0.8)
    end
end

function EPDBC:HookAzeriteBar()
    local bar = EDB.StatusBars.Azerite
    if E.db.EPDBC.enabled and bar then
        if not EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
            EPDBC:SecureHook(EDB, "AzeriteBar_Update", UpdateAzerite)
        end
    elseif not E.db.EPDBC.enabled or not bar then
        if EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
            EPDBC:Unhook(EDB, "AzeriteBar_Update")
        end
        EPDBC:RestoreAzeriteBar()
    end
    EDB:AzeriteBar_Update()
end

function EPDBC:RestoreAzeriteBar()
    local bar = EDB.StatusBars.Azerite
    if bar then
        bar:SetStatusBarColor(.901, .8, .601, 0.8)
    end
end