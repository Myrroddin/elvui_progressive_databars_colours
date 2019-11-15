-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)

-- create the plugin for ElvUI
local EPDBC = E:NewModule("EPDBC", "AceEvent-3.0", "AceHook-3.0")
-- we can use this to automatically insert our GUI tables when ElvUI_Config is loaded
local LEP = LibStub("LibElvUIPlugin-1.0")
-- the vaarg statement
local addonName, addon = ...

-- default options
P["EPDBC"] = {
    enabled = true,
    experienceBar = {
        capped = true,
        progress = true,
        xpColor = {r = 0, g = 0.4, b = 1, a = 0.8},
        restColor = {r = 1, g = 0, b = 1, a = 0.2}
    },
    reputationBar = {
        capped = true,
        progress = true,
        color = "ascii",
        textFormat = "Paragon",
        userColors = {
            [1] = {r = 1, g = 0, b = 0},             -- hated
            [2] = {r = 1, g = 0.55, b = 0},          -- hostile
            [3] = {r = 1, g = 1, b = 0},             -- unfriendly
            [4] = {r = 1, g = 1, b = 1},             -- neutral
            [5] = {r = 0, g = 1, b = 0},             -- friendly
            [6] = {r = 0.25,  g = 0.4,  b = 0.9},    -- honored
            [7] = {r = 0.6, g = 0.2, b = 0.8},       -- revered
            [8] = {r = 0.9, g = 0.8,  b = 0.5},      -- exalted
            [9] = {r = 0.75,  g = 0.75, b = 0.75}    -- paragon
        }
    },
    honorBar = {
        progress = true,
        color = {r = 0.941, g = 0.447, b = 0.254, a = 0.8}
    },
    azeriteBar = {
        progress = true,
        color = {r = 0.901, g = 0.8, b = 0.601, a = 0.8}
    }
}

local function InitializeCallback()
    EPDBC:Initialize()
end

-- register plugin so options are properly inserted when config is loaded
function EPDBC:Initialize()
    LEP:RegisterPlugin(addonName, EPDBC.InsertOptions)
    EPDBC:EnableDisable()
end

-- insert our GUI options into ElvUI's config screen
function EPDBC:InsertOptions()
    if not E.Options.args.EPDBC then
        E.Options.args.EPDBC = EPDBC:GetOptions()
    end
end

-- register the module with ElvUI. ElvUI will now call EPDBC:Initialize() when ElvUI is ready to load our plugin
E:RegisterModule(EPDBC:GetName(), InitializeCallback)

function EPDBC:EnableDisable()
    -- these functions have both enable/disable checks
    EPDBC:HookXPText()
    EPDBC:HookXPTooltip()
    EPDBC:HookRepText()
    EPDBC:HookRepTooltip()
    EPDBC:HookHonorBar()
    EPDBC:HookAzeriteBar()

    if not E.db.EPDBC.enabled then
        EPDBC:UnhookAll() -- make sure no hooks are left behind
    end
end

function EPDBC:Round(num, idp)
    if num <= 0.1 then
        return 0.1
    end
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end