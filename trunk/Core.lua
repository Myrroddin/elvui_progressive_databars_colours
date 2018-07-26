-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)

-- create the plugin for ElvUI
local PCB = E:NewModule("PCB", "AceEvent-3.0", "AceHook-3.0")
-- we can use this to automatically insert our GUI tables when ElvUI_Config is loaded
local LEP = LibStub("LibElvUIPlugin-1.0")
-- the vaarg statement
local addonName, addon = ...

-- default options
P["PCB"] = {
    enabled = true,
    experienceBar = {
        capped = true,
        progress = true,
        xpColor = {r = 0, g = 0.4, b = 1, a = 0.8}
    },
    reputationBar = {
        capped = true,
        progress = true,
        color = "ascii",
        textFormat = "Paragon"
    },
    honorBar = {
        progress = true,
        color = {r = 240/255, g = 114/255, b = 65/255}
    },
    azeriteBar = {
        progress = true,
        color = {r = 0.901, g = 0.8, b = 0.601}
    }
}

local function InitializeCallback()
    PCB:Initialize()
end

-- register plugin so options are properly inserted when config is loaded
function PCB:Initialize()
    LEP:RegisterPlugin(addonName, PCB.InsertOptions)
    P["PCB"].artifactBar = nil
    PCB:EnableDisable()
end

-- insert our GUI options into ElvUI's config screen
function PCB:InsertOptions()
    if not E.Options.args.PCB then
        E.Options.args.PCB = PCB:GetOptions()
    end
end

-- register the module with ElvUI. ElvUI will now call PCB:Initialize() when ElvUI is ready to load our plugin
E:RegisterModule(PCB:GetName(), InitializeCallback)

function PCB:EnableDisable()
    -- these functions have both enable/disable checks
    PCB:HookXPText()
    PCB:HookXPTooltip()
    PCB:HookRepText()
    PCB:HookRepTooltip()
    PCB:HookHonorBar()
    PCB:HookAzeriteBar()

    if not E.db.PCB.enabled then
        PCB:UnhookAll() -- make sure no hooks are left behind
    end
end

function PCB:Round(num, idp)
    if num <= 0.1 then
        return 0.1
    end
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end