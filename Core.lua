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
        progress = true,
        xpColor = {r = 0, g = 0.4, b = 1, a = 0.8},
        restColor = {r = 1, g = 0, b = 1, a = 0.4},
        questColor = {r = 0, g = 1, b = 0, a = 0.4}
    },
    reputationBar = {
        progress = true,
        fillExalted = true,
        factionColors = {
            {r = 0.8, g = 0.3, b = 0.22},   -- hated
			{r = 0.8, g = 0.3, b = 0.22},   -- hostile
			{r = 0.75, g = 0.27, b = 0},    -- unfriendly
			{r = 0.9, g = 0.7, b = 0},      -- neutral
			{r = 0, g = 0.6, b = 0.1},      -- friendly
			{r = 0, g = 0.6, b = 0.1},      -- honored
			{r = 0, g = 0.6, b = 0.1},      -- revered
			{r = 0, g = 0.6, b = 0.1},      -- exalted
            --@version-retail@
			{r = 0, g = 0.6, b = 0.1}       -- paragon
            --@end-version-retail@
        }
    },
    honorBar = {
        progress = true,
        honorColor = {r = 0.94, g = 0.45, b = 0.25, a = 1}
    },
    azeriteBar = {
        progress = true,
        azeriteColor = {r = 0.901, g = 0.8, b = 0.601, a = 1}
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
    --@version-retail@
    EPDBC:HookAzeriteBar()
    --@end-version-retail@

    if not E.db.EPDBC.enabled then
        EPDBC:UnhookAll() -- make sure no hooks are left behind
    end
end

-- utility functions
function EPDBC:Round(num, idp)
    if num <= 0.1 then return 0.1 end

    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function EPDBC:GetCurentMaxValues(statusBar)
    local minimum, maximum = statusBar:GetMinMaxValues()
    local currentValue = statusBar:GetValue()

    -- prevent divide by 0 error
    if maximum <= 1 then maximum = 1 end

    return currentValue, maximum
end