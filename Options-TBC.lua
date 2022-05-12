-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)
-- get the DataBars module
local EDB = E:GetModule("DataBars")
local ETT = E:GetModule("Tooltip")
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
                    EDB.db.colors.useCustomFactionColors = value
                    ETT.db.useCustomFactionColors = value
                    if value then
                        EPDBC:StartUp()
                    else
                        EPDBC:ShutDown()
                    end
                    E:RefreshGUI()
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
            --@version-retail@
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
                type = "header"
            },
            fillExalted = {
                order = 80,
                name = L["Fill Exalted"],
                desc = L["The Reputation bar looks full at exalted"],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.reputationBar.fillExalted
                end,
                set = function(info, value)
                    E.db.EPDBC.reputationBar.fillExalted = value
                    EDB:ReputationBar_Update()
                end
            },
            fillHated = {
                order = 90,
                name = L["Fill Hated"],
                desc = L["The Reputation bar looks full at 0 hated, when you cannot lose any more reputation"],
                type = "toggle",
                get = function()
                    return E.db.EPDBC.reputationBar.fillHated
                end,
                set = function(info, value)
                    E.db.EPDBC.reputationBar.fillHated = value
                    EDB:ReputationBar_Update()
                end
            },
            progressSmoothing = {
                order = 100,
                name = L["Progress Smoothing"],
                desc = L["Number of decimals to use when blending the bars' alpha as you gain xp, honour, rep, etc"],
                type = "range",
                get = function()
                    return E.db.EPDBC.progressSmoothing.decimalLength
                end,
                set = function(info, value)
                    E.db.EPDBC.progressSmoothing.decimalLength = value
                    EDB:ReputationBar_Update()
                    EDB:ExperienceBar_Update()
                    --@version-retail@
                    EDB:HonorBar_Update()
                    EDB:AzeriteBar_Update()
                    --@end-version-retail@
                end,
                min = 1,
                max = 10,
                step = 1
            },
            header3 = {
                order = 110,
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