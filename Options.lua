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
            experienceBar = {
                order = 20,
                name = XPBAR_LABEL,
                type = "group",
                args = {
                    progress = {
                        order = 20,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain XP."],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.experienceBar.progress
                        end,
                        set = function(info, value)
                            E.db.EPDBC.experienceBar.progress = value
                            EDB:ExperienceBar_Update()
                        end
                    }
                }
            },
            reputationBar = {
                order = 30,
                name = L["Reputation Bar"],
                type = "group",
                args = {
                    progress = {
                        order = 20,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain reputation."],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.reputationBar.progress
                        end,
                        set = function(info, value)
                            E.db.EPDBC.reputationBar.progress = value
                            EDB:ReputationBar_Update()
                        end
                    }
                }
            },
            honorBar = {
                order = 40,
                name = L["Honor Bar"],
                type = "group",
                args = {
                    progress = {
                        order = 10,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain honor."],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.honorBar.progress
                        end,
                        set = function(info, value)
                            E.db.EPDBC.honorBar.progress = value
                            EDB:HonorBar_Update()
                        end
                    }
                }
            },
            azeriteBar = {
                order = 50,
                name = L["Azerite Bar"],
                type = "group",
                args = {
                    progress = {
                        order = 10,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain Azerite Power"],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.azeriteBar.progress
                        end,
                        set = function(info, value)
                            E.db.EPDBC.azeriteBar.progress = value
                            EDB:AzeriteBar_Update()
                        end
                    }
                }
            }
        }
    }
    -- support for LibAboutPanel-2.0
	options.args.aboutTab = self:AboutOptionsTable(module_name)
	options.args.aboutTab.order = -1 -- -1 means "put it last"
    return options
end