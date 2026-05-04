-- local references to global functions
local UnitHonor, UnitHonorMax = UnitHonor, UnitHonorMax

local E = ElvUI[1]
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local function GetCurrentAndMaximumValues()
	local current, maximum = UnitHonor("player"), UnitHonorMax("player")
	if maximum <= 0 then maximum = 1 end

	return current, maximum
end

local function UpdateAzerite()
	local bar = EDB.StatusBars.Azerite
	if not bar then return end

	-- bail if azerite disabled
	if not bar.db.enable or bar:ShouldHide() then return end

	local color = EDB.db.colors.azerite
	local r, g, b = color.r or  0.901, color.g or 0.8, color.b or 0.601
	local baseA = color.a or 1

	-- get current & max values
	local _, currentValue, maximumValue = EPDBC:GetCurrentMaxValues(bar)
	maximumValue = (maximumValue and maximumValue > 0) and maximumValue or 1

	local rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	-- alpha: use progress smoothing alpha when enabled, otherwise base alpha
	local useProgress = E.db and E.db.EPDBC and E.db.EPDBC.azeriteBar and E.db.EPDBC.azeriteBar.progress
	local alpha = useProgress and rational or baseA

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