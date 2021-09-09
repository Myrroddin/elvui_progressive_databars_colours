local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local EPDBC = E:GetModule("EPDBC") -- this AddOn

local function UpdateAzerite(self)
    local bar = EDB.StatusBars.Azerite

    if not E.db.EPDBC.azeriteBar.progress then
        bar:SetAlpha(1.0)
        return
    end

    local currentValue, maximum = EPDBC:GetCurentMaxValues(bar)

    local avg = currentValue / maximum
    avg = EPDBC:Round(avg, 2)
    bar:SetAlpha(avg)
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
        bar:SetStatusBarTexture(0.901, 0.8, .601, 1.0)
    end
end