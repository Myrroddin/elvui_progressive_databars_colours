-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)

-- create the plugin for ElvUI
local EPDBC = E:NewModule("EPDBC", "AceEvent-3.0", "AceHook-3.0", "LibAboutPanel-2.0")
-- we can use this to automatically insert our GUI tables when ElvUI_Config is loaded
local LEP = LibStub("LibElvUIPlugin-1.0")
-- the vaarg statement
local addonName, addon = ...

-- default options
P["EPDBC"] = {
    enabled = true,
    experienceBar = {
        progress = true
    },
    reputationBar = {
        progress = true,
        fillExalted = true,
        fillHated = true
    },
    honorBar = {
        progress = true
    },
    --@version-retail@
    azeriteBar = {
        progress = true
    },
    --@end-version-retail@
    progressSmoothing = {
        decimalLength = 3
    }
}

-- register plugin so options are properly inserted when config is loaded
function EPDBC:Initialize()
    LEP:RegisterPlugin(addonName, EPDBC.InsertOptions)
    if E.db.EPDBC.enabled then
        EPDBC:StartUp()
    end
end

-- insert our GUI options into ElvUI's config screen
function EPDBC:InsertOptions()
    if E.Options.args.EPDBC == nil then
        E.Options.args.EPDBC = EPDBC:GetOptions()
    end
end

-- register the module with ElvUI. ElvUI will now call EPDBC:Initialize() when ElvUI is ready to load our plugin
E:RegisterModule(EPDBC:GetName())

function EPDBC:StartUp()
    -- replace reputation databar colours
    E.db["databars"]["colors"]["factionColors"][1]["b"] = 0
    E.db["databars"]["colors"]["factionColors"][1]["g"] = 0
    E.db["databars"]["colors"]["factionColors"][1]["r"] = 1
    E.db["databars"]["colors"]["factionColors"][2]["b"] = 0.27843137254902
    E.db["databars"]["colors"]["factionColors"][2]["g"] = 0.38823529411765
    E.db["databars"]["colors"]["factionColors"][2]["r"] = 1
    E.db["databars"]["colors"]["factionColors"][3]["b"] = 0
    E.db["databars"]["colors"]["factionColors"][3]["g"] = 0.64705882352941
    E.db["databars"]["colors"]["factionColors"][3]["r"] = 1
    E.db["databars"]["colors"]["factionColors"][4]["g"] = 1
    E.db["databars"]["colors"]["factionColors"][4]["r"] = 1
    E.db["databars"]["colors"]["factionColors"][5]["b"] = 0
    E.db["databars"]["colors"]["factionColors"][5]["g"] = 0.50196078431373
    E.db["databars"]["colors"]["factionColors"][6]["b"] = 0.92941176470588
    E.db["databars"]["colors"]["factionColors"][6]["g"] = 0.5843137254902
    E.db["databars"]["colors"]["factionColors"][6]["r"] = 0.3921568627451
    E.db["databars"]["colors"]["factionColors"][7]["b"] = 0.88627450980392
    E.db["databars"]["colors"]["factionColors"][7]["g"] = 0.16862745098039
    E.db["databars"]["colors"]["factionColors"][7]["r"] = 0.54117647058824
    E.db["databars"]["colors"]["factionColors"][8]["b"] = 0.50196078431373
    E.db["databars"]["colors"]["factionColors"][8]["g"] = 0
    E.db["databars"]["colors"]["factionColors"][8]["r"] = 0.50196078431373
    --@version-retail@
    E.db["databars"]["colors"]["factionColors"][9]["b"] = 0.70588235294118
    E.db["databars"]["colors"]["factionColors"][9]["g"] = 0.41176470588235
    E.db["databars"]["colors"]["factionColors"][9]["r"] = 1
    --@end-version-retail@
    E.db["databars"]["colors"]["useCustomFactionColors"] = true

    -- replace tooltip faction colours
    E.db["tooltip"]["factionColors"][1]["b"] = 0
    E.db["tooltip"]["factionColors"][1]["g"] = 0
    E.db["tooltip"]["factionColors"][1]["r"] = 1
    E.db["tooltip"]["factionColors"][2]["b"] = 0.27843137254902
    E.db["tooltip"]["factionColors"][2]["g"] = 0.38823529411765
    E.db["tooltip"]["factionColors"][2]["r"] = 1
    E.db["tooltip"]["factionColors"][3]["b"] = 0
    E.db["tooltip"]["factionColors"][3]["g"] = 0.64705882352941
    E.db["tooltip"]["factionColors"][3]["r"] = 1
    E.db["tooltip"]["factionColors"][4]["g"] = 1
    E.db["tooltip"]["factionColors"][4]["r"] = 1
    E.db["tooltip"]["factionColors"][5]["b"] = 0
    E.db["tooltip"]["factionColors"][5]["g"] = 0.50196078431373
    E.db["tooltip"]["factionColors"][6]["b"] = 0.92941176470588
    E.db["tooltip"]["factionColors"][6]["g"] = 0.5843137254902
    E.db["tooltip"]["factionColors"][6]["r"] = 0.3921568627451
    E.db["tooltip"]["factionColors"][7]["b"] = 0.88627450980392
    E.db["tooltip"]["factionColors"][7]["g"] = 0.16862745098039
    E.db["tooltip"]["factionColors"][7]["r"] = 0.54117647058824
    E.db["tooltip"]["factionColors"][8]["b"] = 0.50196078431373
    E.db["tooltip"]["factionColors"][8]["g"] = 0
    E.db["tooltip"]["factionColors"][8]["r"] = 0.50196078431373
    E.db["tooltip"]["useCustomFactionColors"] = true

    EPDBC:HookXPBar()
    EPDBC:HookRepBar()
    --@version-retail@
    EPDBC.HookHonorBar()
    EPDBC:HookAzeriteBar()
    --@end-version-retail@
end

function EPDBC:ShutDown()
    -- reset reputation databar colours
    E.db["databars"]["colors"]["factionColors"][1]["b"] = 0.22
    E.db["databars"]["colors"]["factionColors"][1]["g"] = 0.30
    E.db["databars"]["colors"]["factionColors"][1]["r"] = 0.80
    E.db["databars"]["colors"]["factionColors"][2]["b"] = 0.22
    E.db["databars"]["colors"]["factionColors"][2]["g"] = 0.30
    E.db["databars"]["colors"]["factionColors"][2]["r"] = 0.80
    E.db["databars"]["colors"]["factionColors"][3]["b"] = 0
    E.db["databars"]["colors"]["factionColors"][3]["g"] = 0.27
    E.db["databars"]["colors"]["factionColors"][3]["r"] = 0.75
    E.db["databars"]["colors"]["factionColors"][4]["b"] = 0
    E.db["databars"]["colors"]["factionColors"][4]["g"] = 0.70
    E.db["databars"]["colors"]["factionColors"][4]["r"] = 0.90
    E.db["databars"]["colors"]["factionColors"][5]["b"] = 0.10
    E.db["databars"]["colors"]["factionColors"][5]["g"] = 0.60
    E.db["databars"]["colors"]["factionColors"][5]["r"] = 0
    E.db["databars"]["colors"]["factionColors"][6]["b"] = 0.10
    E.db["databars"]["colors"]["factionColors"][6]["g"] = 0.60
    E.db["databars"]["colors"]["factionColors"][6]["r"] = 0
    E.db["databars"]["colors"]["factionColors"][7]["b"] = 0.10
    E.db["databars"]["colors"]["factionColors"][7]["g"] = 0.60
    E.db["databars"]["colors"]["factionColors"][7]["r"] = 0
    E.db["databars"]["colors"]["factionColors"][8]["b"] = 0.10
    E.db["databars"]["colors"]["factionColors"][8]["g"] = 0.60
    E.db["databars"]["colors"]["factionColors"][8]["r"] = 0
    --@version-retail@
    E.db["databars"]["colors"]["factionColors"][9]["b"] = 0.10
    E.db["databars"]["colors"]["factionColors"][9]["g"] = 0.60
    E.db["databars"]["colors"]["factionColors"][9]["r"] = 0
    --@end-version-retail@
    E.db["databars"]["colors"]["useCustomFactionColors"] = false

    -- reset tooltip faction colours
    E.db["tooltip"]["factionColors"][1]["b"] = 0.22
    E.db["tooltip"]["factionColors"][1]["g"] = 0.30
    E.db["tooltip"]["factionColors"][1]["r"] = 0.80
    E.db["tooltip"]["factionColors"][2]["b"] = 0.22
    E.db["tooltip"]["factionColors"][2]["g"] = 0.30
    E.db["tooltip"]["factionColors"][2]["r"] = 0.80
    E.db["tooltip"]["factionColors"][3]["g"] = 0.27
    E.db["tooltip"]["factionColors"][3]["r"] = 0.75
    E.db["tooltip"]["factionColors"][4]["b"] = 0
    E.db["tooltip"]["factionColors"][4]["g"] = 0.70
    E.db["tooltip"]["factionColors"][4]["r"] = 0.90
    E.db["tooltip"]["factionColors"][5]["b"] = 0.10
    E.db["tooltip"]["factionColors"][5]["g"] = 0.60
    E.db["tooltip"]["factionColors"][5]["r"] = 0
    E.db["tooltip"]["factionColors"][6]["b"] = 0.10
    E.db["tooltip"]["factionColors"][6]["g"] = 0.60
    E.db["tooltip"]["factionColors"][6]["r"] = 0
    E.db["tooltip"]["factionColors"][7]["b"] = 0.10
    E.db["tooltip"]["factionColors"][7]["g"] = 0.60
    E.db["tooltip"]["factionColors"][7]["r"] = 0
    E.db["tooltip"]["factionColors"][8]["b"] = 0.10
    E.db["tooltip"]["factionColors"][8]["g"] = 0.60
    E.db["tooltip"]["factionColors"][8]["r"] = 0
    E.db["tooltip"]["useCustomFactionColors"] = false

    EPDBC:UnhookAll()
    EPDBC:RestoreRepBar()
    EPDBC:RestoreXPBar()
    --@version-retail@
    EPDBC:RestoreHonorBar()
    EPDBC:RestoreAzeriteBar()
    --@end-version-retail@
    EPDBC:UnhookAll()
end

-- utility functions
function EPDBC:Round(num, idp)
    if num <= 0.1 then return 0.1 end

    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function EPDBC:GetCurrentMaxValues(statusBar)
    local minimum, maximum = statusBar:GetMinMaxValues()
    local currentValue = statusBar:GetValue()

    -- prevent divide by 0 error
    if maximum <= 1 then maximum = 1 end

    return currentValue, maximum
end