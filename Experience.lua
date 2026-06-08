-- local references to global functions
local GetXPExhaustion = GetXPExhaustion
local min = math.min
local UnitXP, UnitXPMax = UnitXP, UnitXPMax

local E = ElvUI[1]
---@cast E ElvUI

local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
---@type EPDBC
local EPDBC = E:GetModule("EPDBC") -- this AddOn

---@return number current
---@return number maximum
---@return boolean isMaxLevel
local function GetCurrentAndMaximumValues()
	local current, maximum = UnitXP("player"), UnitXPMax("player")
	if maximum <= 0 then maximum = 1 end

	local isMaxLevel = E:XPIsLevelMax()
	if isMaxLevel then
		current, maximum = 1, 1
	end

	return current, maximum, isMaxLevel
end

---@param bar ElvUI_DataBarStatusBar
---@param currentValue number
---@param maximumValue number
---@param isMaxLevel boolean
local function UpdateRestedAlpha(bar, currentValue, maximumValue, isMaxLevel)
	if isMaxLevel or not bar.Rested or not bar.Rested:IsShown() then return end

	local restedXP = GetXPExhaustion() or 0
	if restedXP <= 0 then return end

	-- ElvUI bounds the rested bar to the current level, so alpha should use the visible rested segment.
	local restedValue = min(currentValue + restedXP, maximumValue)
	local visibleRestedXP = restedValue - currentValue
	if visibleRestedXP <= 0 then return end

	local rational = visibleRestedXP / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3, true)

	local restedColor = EDB.db.colors and EDB.db.colors.rested or {}
	local r, g, b = restedColor.r or 1, restedColor.g or 0, restedColor.b or 1
	local baseA = restedColor.a or 0.4

	local alpha = (E.db.EPDBC.experienceBar.progress and rational) or baseA

	bar.Rested:SetStatusBarColor(r, g, b, alpha)
end

local function UpdateExperience()
	local bar = EDB.StatusBars.Experience
	if not bar then return end

	EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local currentValue, maximumValue, isMaxLevel = GetCurrentAndMaximumValues()

	local rational, alpha

	local color = EDB.db.colors and EDB.db.colors.experience or {}
	local r, g, b, a = color.r or 0, color.g or 0.4, color.b or 1, color.a or 0.8
	local baseA = (isMaxLevel and 1) or a

	rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	-- alpha: use progress smoothing alpha when enabled, otherwise use base alpha
	alpha = (E.db.EPDBC.experienceBar.progress and rational) or baseA

	bar:SetStatusBarColor(r, g, b, alpha)
	UpdateRestedAlpha(bar, currentValue, maximumValue, isMaxLevel)
end

function EPDBC:UpdateQuestAlpha()
	local bar = EDB.StatusBars.Experience
	if not bar or not bar.Quest or not bar.Quest:IsShown() then return end

	local _, maximumValue, isMaxLevel = GetCurrentAndMaximumValues()
	if isMaxLevel then return end

	-- derive quest XP safely
	local questBarValue = bar.Quest:GetValue() or 0

	-- IMPORTANT: ElvUI clamps this already using min()
	local rational = questBarValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3, true)

	local baseColor = EDB.db.colors and EDB.db.colors.quest or {}
	local r, g, b = baseColor.r or 0, baseColor.g or 1, baseColor.b or 0
	local baseA = baseColor.a or 0.4

	local alpha = (E.db.EPDBC.experienceBar.progress and rational) or baseA

	bar.Quest:SetStatusBarColor(r, g, b, alpha)
end

-- hook the XP bar
function EPDBC:HookXPBar()
	local bar = EDB.StatusBars.Experience
	if not bar then return end

	if not EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
		EPDBC:SecureHook(EDB, "ExperienceBar_Update", UpdateExperience)
	end

	if not EPDBC:IsHooked(EDB, "ExperienceBar_QuestXP") then
		EPDBC:SecureHook(EDB, "ExperienceBar_QuestXP", "UpdateQuestAlpha")
	end

	-- force an immediate update after hooking
	EDB:ExperienceBar_Update()
end

function EPDBC:RestoreExperienceBar()
	local bar = EDB.StatusBars.Experience
	if not bar then return end

	if EPDBC:IsHooked(EDB, "ExperienceBar_Update") then
		EPDBC:Unhook(EDB, "ExperienceBar_Update")
	end

	if EPDBC:IsHooked(EDB, "ExperienceBar_QuestXP") then
		EPDBC:Unhook(EDB, "ExperienceBar_QuestXP")
	end

	EDB:ExperienceBar_Update()
end