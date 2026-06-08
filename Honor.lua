-- local references to global functions
local UnitHonor, UnitHonorMax = UnitHonor, UnitHonorMax

local E = ElvUI[1]
---@cast E ElvUI

local EDB = E:GetModule("DataBars")
---@type EPDBC
local EPDBC = E:GetModule("EPDBC")

---@return number current
---@return number maximum
local function GetCurrentAndMaximumValues()
	local current, maximum = UnitHonor("player"), UnitHonorMax("player")
	if maximum <= 0 then maximum = 1 end

	return current, maximum
end

local function UpdateHonor()
	local bar = EDB.StatusBars.Honor
	if not bar then return end

	EDB:SetVisibility(bar)

	if not EDB.db.honor.enable or bar:ShouldHide() then return end

	local color = EDB.db.colors and EDB.db.colors.honor or {}
	local r, g, b = color.r or 0.94, color.g or 0.45, color.b or 0.25
	local baseA = color.a or 1

	-- get current & max values
	local currentValue, maximumValue = GetCurrentAndMaximumValues()

	local rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	-- alpha: use progress smoothing alpha when enabled, otherwise use base alpha
	local alpha = (E.db.EPDBC.honorBar.progress and rational) or baseA

	bar:SetStatusBarColor(r, g, b, alpha)
end

function EPDBC:HookHonorBar()
	local bar = EDB.StatusBars.Honor
	if not bar then return end

	if not EPDBC:IsHooked(EDB, "HonorBar_Update") then
		EPDBC:SecureHook(EDB, "HonorBar_Update", UpdateHonor)
	end

	-- force an immediate update after hooking
	EDB:HonorBar_Update()
end

function EPDBC:RestoreHonorBar()
	local bar = EDB.StatusBars.Honor
	if not bar then return end

	if EPDBC:IsHooked(EDB, "HonorBar_Update") then
		EPDBC:Unhook(EDB, "HonorBar_Update")
	end

	EDB:HonorBar_Update()
end