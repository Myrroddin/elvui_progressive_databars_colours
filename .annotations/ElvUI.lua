---@meta

---@alias ElvUI_Locales table<string, string|boolean>
---@alias ElvUI_CharDB table
---@alias ElvUI_ProfileDB table
---@alias ElvUI_GlobalDB table

---@class ElvUI_Color
---@field r number?
---@field g number?
---@field b number?
---@field a number?
---@field colorStr string?

---@class ElvUI_WatchedFactionInfo
---@field name string?
---@field reaction number?
---@field currentReactionThreshold number?
---@field nextReactionThreshold number?
---@field currentStanding number?
---@field factionID number?

---@class ElvUI_oUF
---@field colors table

---@class ElvUI_DataBarStatusBar: StatusBar
---@field db table
---@field Quest StatusBar?
---@field Rested StatusBar?
---@field ShouldHide fun(self: ElvUI_DataBarStatusBar): boolean

---@class ElvUI_DataBars
---@field db table
---@field StatusBars table<string, ElvUI_DataBarStatusBar>
---@field SetVisibility fun(self: ElvUI_DataBars, bar: ElvUI_DataBarStatusBar)
---@field ExperienceBar_Update fun(self: ElvUI_DataBars)
---@field ExperienceBar_QuestXP fun(self: ElvUI_DataBars)
---@field ReputationBar_Update fun(self: ElvUI_DataBars)
---@field HonorBar_Update fun(self: ElvUI_DataBars)
---@field AzeriteBar_Update fun(self: ElvUI_DataBars)

---@class LibElvUIPlugin-1.0
---@field RegisterPlugin fun(self: LibElvUIPlugin-1.0, name: string, callback?: function|string, isLib?: boolean, version?: string|number): table?
---@field HookInitialize fun(self: LibElvUIPlugin-1.0, tbl: table, func: function|string)

---@class ElvUI: AceAddon-3.0
---@field version string|number
---@field db table
---@field private table
---@field Options table
---@field PopupDialogs table
---@field Libs table
---@field media table
---@field oUF ElvUI_oUF
---@field Retail boolean
---@field Mists boolean
---@field Wrath boolean
---@field TBC boolean
---@field Classic boolean
---@field ClassicEra boolean
---@field mylevel number
---@field myLevel number
---@field GetModule fun(self: ElvUI, name: "DataBars"): ElvUI_DataBars
---@field GetModule fun(self: ElvUI, name: string): table
---@field NewModule fun(self: ElvUI, name: string, ...: string): table
---@field RegisterModule fun(self: ElvUI, name: string)
---@field UpdateAll fun(self: ElvUI, private?: boolean)
---@field Delay fun(self: ElvUI, delay: number, func: function, ...): unknown
---@field StaticPopup_Show fun(self: ElvUI, which: string, ...): unknown
---@field ToggleOptions fun(self: ElvUI)
---@field XPIsLevelMax fun(self: ElvUI): boolean
---@field GetWatchedFactionInfo fun(self: ElvUI): ElvUI_WatchedFactionInfo

---@type [ElvUI, ElvUI_Locales, ElvUI_CharDB, ElvUI_ProfileDB, ElvUI_GlobalDB]
ElvUI = ElvUI