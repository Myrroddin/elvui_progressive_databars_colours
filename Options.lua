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
                    capped = {
                        order = 10,
                        name = L["Capped"],
                        desc = L["Replace XP text with the word 'Capped' at max level."],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.experienceBar.capped
                        end,
                        set = function(info, value)
                            E.db.EPDBC.experienceBar.capped = value
                            EDB:ExperienceBar_Update()
                        end
                    },
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
                    },
                    xpColor = {
                        order = 30,
                        name = L["XP Color"],
                        desc = L["Select your preferred XP color."],
                        type = "color",
                        hasAlpha = true,
                        get = function()
                            local c = E.db.EPDBC.experienceBar.xpColor
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            local c = E.db.EPDBC.experienceBar.xpColor
                            c.r, c.g, c.b, c.a = r, g, b, a
                            EDB:ExperienceBar_Update()
                        end
                    },
                    restColor = {
                        order = 40,
                        name = L["Rested Color"],
                        desc = L["Select your preferred rested color."],
                        type = "color",
                        hasAlpha = true,
                        get = function()
                            local c = E.db.EPDBC.experienceBar.restColor
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            local c = E.db.EPDBC.experienceBar.restColor
                            c.r, c.g, c.b, c.a = r, g, b, a
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
                    capped = {
                        order = 10,
                        name = L["Capped"],
                        desc = L["Replace rep text with the word 'Capped' or 'Paragon' at max."],
                        type = "toggle",
                        get = function()
                            return E.db.EPDBC.reputationBar.capped
                        end,
                        set = function(info, value)
                            E.db.EPDBC.reputationBar.capped = value
                            EDB:ReputationBar_Update()
                        end
                    },
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
                    },
                    textFormat = {
                        order = 30,
                        name = L["'Paragon' Format"],
                        desc = L["If 'Capped' is toggled and watched faction is a Paragon then choose short or long."],
                        type = "select",
                        values = {
                            ["P"] = L["P"],
                            ["Paragon"] = L["Paragon"]
                        },
                        get = function()
                            return E.db.EPDBC.reputationBar.textFormat
                        end,
                        set = function(info, value)
                            E.db.EPDBC.reputationBar.textFormat = value
                            EDB:ReputationBar_Update()
                        end
                    },
                    color = {
                        order = 40,
                        name = L["Progress Colour"],
                        desc = L["Change rep bar colour by standing."],
                        type = "select",
                        values = {
                            ["ascii"] = "ASCII",
                            ["blizzard"] = "Blizzard",
                            ["custom"] = L["Custom"]
                        },
                        get = function()
                            return E.db.EPDBC.reputationBar.color
                        end,
                        set = function(info, value)
                            E.db.EPDBC.reputationBar.color = value
                            EDB:ReputationBar_Update()
                        end
                    },
                    description = {
                        order = 50,
                        name = "---------- " .. L["Custom Colors"] .. " ---------",
                        type = "description",
                        fontSize = "large"
                    },
                    hated = {
                        order = 60,
                        name = FACTION_STANDING_LABEL1,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[1]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[1]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    hostile = {
                        order = 70,
                        name = FACTION_STANDING_LABEL2,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[2]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[2]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    unfriendly = {
                        order = 80,
                        name = FACTION_STANDING_LABEL3,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[3]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[3]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    neutral = {
                        order = 90,
                        name = FACTION_STANDING_LABEL4,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[4]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[4]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    friendly = {
                        order = 100,
                        name = FACTION_STANDING_LABEL5,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[5]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[5]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    honored = {
                        order = 110,
                        name = FACTION_STANDING_LABEL6,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[6]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[6]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    revered = {
                        order = 120,
                        name = FACTION_STANDING_LABEL7,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[7]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[7]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    exalted = {
                        order = 130,
                        name = FACTION_STANDING_LABEL8,
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[8]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[8]
                            c.r, c.g, c.b = r, g, b
                            EDB:ReputationBar_Update()
                        end
                    },
                    paragon = {
                        order = 140,
                        name = L["Paragon"],
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.EPDBC.reputationBar.userColors[9]
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.reputationBar.userColors[9]
                            c.r, c.g, c.b = r, g, b
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
                    },
                    color = {
                        order = 20,
                        name = L["Honor Color"],
                        desc = L["Change the honor bar color."],
                        type = "color",
                        hasAlpha = true,
                        get = function()
                            local c = E.db.EPDBC.honorBar.color
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            local c = E.db.EPDBC.honorBar.color
                            c.r, c.g, c.b, c.a = r, g, b, a
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
                    },
                    color = {
                        order = 20,
                        name = L["Azerite Color"],
                        desc = L["Change the Azerite bar color"],
                        type = "color",
                        hasAlpha = true,
                        get = function()
                            local c = E.db.EPDBC.azeriteBar.color
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.EPDBC.azeriteBar.color
                            c.r, c.g, c.b = r, g, b
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