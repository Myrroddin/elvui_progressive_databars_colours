-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)
-- get the DataBars module
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")
local module_name, private_table = ...

-- translate the module's name. normally I wouldn't do this, but it does have an awkward name
local uiName = L["Progressively Colored DataBars"]

function EPDBC:GetOptions()
    local options = options or {
        order = 10,
        type = "group",
        name = uiName,
        childGroups = "tab",
        args = {
            enabled = {
                order = 10,
                name = ENABLE,
                desc = L["Toggle module on/off. If off, it restores DataBars to ElvUI defaults."],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.enabled
                end,
                set = function(info, value)
                    E.db.EPDBC.enabled = value
                    EPDBC:EnableDisable()
                end
            },
            blendProgress = {
                order = 20,
                name = L["Blend Progress"],
                type = "header",
            },
            experienceBar = {
                order = 30,
                name = XPBAR_LABEL,
                desc = L["Progressively blend the bar as you gain XP."],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.experienceBar.progress
                end,
                set = function(info, value)
                    E.db.EPDBC.experienceBar.progress = value
                    EDB:ExperienceBar_Update()
                end
            },
            reputationBar = {
                order = 40,
                name = L["Reputation Bar"],
                type = "toggle",
                desc = L["Progressively blend the bar as you gain reputation."],
                get = function()
                    return E.db.EPDBC.reputationBar.progress
                end,
                set = function(info, value)
                    E.db.EPDBC.reputationBar.progress = value
                    EDB:ReputationBar_Update()
                end
            },
            honorBar = {
                order = 50,
                name = L["Honor Bar"],
                desc = L["Progressively blend the bar as you gain honor."],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.honorBar.progress
                end,
                set = function(info, value)
                    E.db.EPDBC.honorBar.progress = value
                    EDB:HonorBar_Update()
                end
            },
            --@version-retail@
            azeriteBar = {
                order = 60,
                name = L["Azerite Bar"],
                desc = L["Progressively blend the bar as you gain Azerite Power"],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.azeriteBar.progress
                end,
                set = function(info, value)
                    E.db.EPDBC.azeriteBar.progress = value
                    EDB:AzeriteBar_Update()
                end
            },
            --@end-version-retail@
            miscellaneous = {
                order = 70,
                name = MISCELLANEOUS,
                type = "header",
            },
            fillExalted = {
                order = 80,
                name = L["Fill Exalted"],
                desc = L["The Reputation bar looks full at exalted or max friendship"],
                type = "toggle",
                width = "double",
                get = function()
                    return E.db.EPDBC.reputationBar.fillExalted
                end,
                set = function(info, value)
                    E.db.EPDBC.reputationBar.fillExalted = value
                    EDB:ReputationBar_Update()
                end
            },
            coloredFactionTooltips = {
                order = 90,
                name = L["Tooltip Reaction Colors"],
                desc = L["Use custom faction colours for reaction tooltips"],
                type = "toggle",
                width = "double",
                get = function()
                    return E.db.EPDBC.reputationBar.coloredFactionTooltips
                end,
                set = function(info, value)
                    E.db.EPDBC.reputationBar.coloredFactionTooltips = value
                end
            },
            header3 = {
                order = 100,
                name = "",
                type = "header",
            }
        }
    }
    -- support for LibAboutPanel-2.0
	options.args.aboutTab = self:AboutOptionsTable(module_name)
	options.args.aboutTab.order = -1 -- -1 means "put it last"
    return options
end