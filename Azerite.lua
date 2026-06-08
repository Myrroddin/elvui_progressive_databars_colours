-- local references to global functions
local FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel

local E = ElvUI[1]
---@cast E ElvUI

local EDB = E:GetModule("DataBars")
---@type EPDBC
local EPDBC = E:GetModule("EPDBC")

---@return number? current
---@return number maximum
---@return boolean hasActiveAzeriteItem
local function GetCurrentAndMaximumValues()
	local current, maximum, hasActiveAzeriteItem, item
	item = FindActiveAzeriteItem()
	if item then
		current, maximum = GetAzeriteItemXPInfo(item)
		hasActiveAzeriteItem = true

		if IsAzeriteItemAtMaxLevel() then
			current, maximum = 1, 1
		end
	else
		hasActiveAzeriteItem = false
	end

	if not maximum or maximum <= 0 then
		maximum = 1
	end

	return current, maximum, hasActiveAzeriteItem
end

local function UpdateAzerite()
	local bar = EDB.StatusBars.Azerite
	if not bar then return end

	EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	-- get current & max values
	local currentValue, maximumValue, hasActiveAzeriteItem = GetCurrentAndMaximumValues()
	if not hasActiveAzeriteItem or not currentValue then return end

	local rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	local color = EDB.db.colors and EDB.db.colors.azerite or {}
	local r, g, b = color.r or 0.901, color.g or 0.8, color.b or 0.601
	local baseA = color.a or 1

	-- alpha: use progress smoothing alpha when enabled, otherwise base alpha
	local alpha = (E.db.EPDBC.azeriteBar.progress and rational) or baseA

	bar:SetStatusBarColor(r, g, b, alpha)
end

function EPDBC:HookAzeriteBar()
	local bar = EDB.StatusBars.Azerite
	if not bar then return end

	if not EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
		EPDBC:SecureHook(EDB, "AzeriteBar_Update", UpdateAzerite)
	end

	-- force an immediate update after hooking
	EDB:AzeriteBar_Update()
end

function EPDBC:RestoreAzeriteBar()
	local bar = EDB.StatusBars.Azerite
	if not bar then return end

	if EPDBC:IsHooked(EDB, "AzeriteBar_Update") then
		EPDBC:Unhook(EDB, "AzeriteBar_Update")
	end

	EDB:AzeriteBar_Update()
end