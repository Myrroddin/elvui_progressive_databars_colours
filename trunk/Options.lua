-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)
-- get the DataBars module
local EDB = E:GetModule("DataBars")
local PCB = E:GetModule("PCB")

-- translate the module's name. normally I wouldn't do this, but it does have an awkward name
local uiName = L["Progressively Colored DataBars"]

function PCB:GetOptions()
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
                    return E.db.PCB.enabled
                end,
                set = function(info, value)
                    E.db.PCB.enabled = value
                    PCB:EnableDisable()
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
                            return E.db.PCB.experienceBar.capped
                        end,
                        set = function(info, value)
                            E.db.PCB.experienceBar.capped = value
                            EDB:UpdateExperience()
                        end
                    },
                    progress = {
                        order = 20,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain XP."],
                        type = "toggle",
                        get = function()
                            return E.db.PCB.experienceBar.progress
                        end,
                        set = function(info, value)
                            E.db.PCB.experienceBar.progress = value
                            EDB:UpdateExperience()
                        end
                    },
                    xpColor = {
                        order = 30,
                        name = L["XP Color"],
                        desc = L["Select your preferred XP color."],
                        type = "color",
                        hasAlpha = true,
                        get = function()
                            local c = E.db.PCB.experienceBar.xpColor
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(info, r, g, b, a)
                            local c = E.db.PCB.experienceBar.xpColor
                            c.r, c.g, c.b, c.a = r, g, b, a
                            EDB:UpdateExperience()
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
                            return E.db.PCB.reputationBar.capped
                        end,
                        set = function(info, value)
                            E.db.PCB.reputationBar.capped = value
                            EDB:UpdateReputation()
                        end
                    },
                    progress = {
                        order = 20,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you gain reputation."],
                        type = "toggle",
                        get = function()
                            return E.db.PCB.reputationBar.progress
                        end,
                        set = function(info, value)
                            E.db.PCB.reputationBar.progress = value
                            EDB:UpdateReputation()
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
                            return E.db.PCB.reputationBar.textFormat
                        end,
                        set = function(info, value)
                            E.db.PCB.reputationBar.textFormat = value
                            EDB:UpdateReputation()
                        end
                    },
                    color = {
                        order = 40,
                        name = L["Progress Colour"],
                        desc = L["Change rep bar colour by standing."],
                        type = "select",
                        values = {
                            ["ascii"] = "ASCII",
                            ["blizzard"] = "Blizzard"
                        },
                        get = function()
                            return E.db.PCB.reputationBar.color
                        end,
                        set = function(info, value)
                            E.db.PCB.reputationBar.color = value
                            EDB:UpdateReputation()
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
                            return E.db.PCB.honorBar.progress
                        end,
                        set = function(info, value)
                            E.db.PCB.honorBar.progress = value
                            EDB:UpdateHonor()
                        end
                    },
                    color = {
                        order = 20,
                        name = L["Honor Color"],
                        desc = L["Change the honor bar color."],
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.PCB.honorBar.color
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.PCB.honorBar.color
                            c.r, c.g, c.b = r, g, b
                            EDB:UpdateHonor()
                        end
                    }
                }
            },
            artifactBar = {
                order = 50,
                name = L["Artifact Bar"],
                type = "group",
                args  = {
                    progress = {
                        order = 10,
                        name = L["Blend Progress"],
                        desc = L["Progressively blend the bar as you spend artifact power."],
                        type = "toggle",
                        get = function()
                            return E.db.PCB.artifactBar.progress
                        end,
                        set = function(info, value)
                            E.db.PCB.artifactBar.progress = value
                            EDB:UpdateArtifact()
                        end
                    },
                    artColor = {
                        order = 20,
                        name = L["Spent AP Color"],
                        desc = L["Change the color of the spent artifact power bar."],
                        type = "color",
                        hasAlpha = false,
                        get = function()
                            local c = E.db.PCB.artifactBar.artColor
                            return c.r, c.g, c.b
                        end,
                        set = function(info, r, g, b)
                            local c = E.db.PCB.artifactBar.artColor
                            c.r, c.g, c.b = r, g, b
                            EDB:UpdateArtifact()
                        end
                    }
                }
            }
        }
    }
    return options
end