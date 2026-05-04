-- local references to global functions
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION

local E = ElvUI[1]
local ElvUF = E.oUF
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

local function GetCurrentAndMaximumValues(currentStanding, currentReactionThreshold, nextReactionThreshold)
	local current = currentStanding - currentReactionThreshold
	local maximum = nextReactionThreshold - currentReactionThreshold

	if maximum < 0 then
		maximum = current -- account for negative maximum
	end

	if current == maximum then
		return 1, 1
	else
		maximum = (maximum ~= 0 and maximum) or 1 -- prevent a division by zero
		return current, maximum
	end
end

local function UpdateReputation()
	local bar = EDB.StatusBars.Reputation
	EDB:SetVisibility(bar)

	if not bar.db.enable or bar:ShouldHide() then return end

	local data = E:GetWatchedFactionInfo() -- ElvUI function that converts returned values into a table https://warcraft.wiki.gg/wiki/API_C_Reputation.GetWatchedFactionData
	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding
	if not name then return end -- exit if we don't have a faction

	local rational, alpha, currentValue, maximumValue, isCappedExalted

	-- unknown factions are forced to Hated rather than reaction 0
	if reaction == 0 then
		reaction = 1
	end

	-- Blizzard's API starts counting at 0/Neutral, with full Exalted being 42000, while we need the *real* values for the reputation tier, so we need to do some math to convert them
	isCappedExalted = reaction == MAX_REPUTATION_REACTION

	if isCappedExalted then
		currentValue, maximumValue = 1, 1
	else
		currentValue, maximumValue = GetCurrentAndMaximumValues(currentStanding, currentReactionThreshold, nextReactionThreshold)
	end

	-- we shouldn't upvalue either of these since they can be modified by the user; we need to access them directly each update
	local customColors = EDB.db.colors.useCustomFactionColors
	local color = (customColors and EDB.db.colors.factionColors[reaction]) or ElvUF.colors.reaction[reaction]
	local r, g, b = color.r or 1, color.g or 1, color.b or 1
	local baseA = (customColors and color.a) or EDB.db.colors.reputationAlpha

	rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	-- alpha: use progress smoothing when enabled, otherwise use base alpha
	alpha = (E.db.EPDBC.reputationBar.progress and rational) or baseA

	if (E.db.EPDBC.reputationBar.fillHated and reaction == 1 and currentValue == 0)
	or (E.db.EPDBC.reputationBar.fillExalted and isCappedExalted) then
		currentValue, maximumValue, alpha = 1, 1, 1
		bar:SetMinMaxValues(0, maximumValue)
		bar:SetValue(currentValue)
	end

	bar:SetStatusBarColor(r, g, b, alpha or 1)
end

function EPDBC:HookRepBar()
	local bar = EDB.StatusBars.Reputation
	if not bar then return end
	if not EPDBC:IsHooked(EDB, "ReputationBar_Update") then
		EPDBC:SecureHook(EDB, "ReputationBar_Update", UpdateReputation)
	end
	EDB:ReputationBar_Update()
end

function EPDBC:RestoreRepBar()
	local bar = EDB.StatusBars.Reputation
	if not bar then return end
	if EPDBC:IsHooked(EDB, "ReputationBar_Update") then
		EPDBC:Unhook(EDB, "ReputationBar_Update")
	end
	EDB:ReputationBar_Update()
end