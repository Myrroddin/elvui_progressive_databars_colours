-- local references to global functions
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks
local GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local huge = math.huge
local IsFactionParagonForCurrentPlayer = C_Reputation.IsFactionParagonForCurrentPlayer
local IsMajorFaction = C_Reputation.IsMajorFaction
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local max = math.max
local min = math.min

local ElvUI = _G.ElvUI
local E = ElvUI[1]

local ElvUF = E.oUF
local EDB = E:GetModule("DataBars")
local EPDBC = E:GetModule("EPDBC")

-- Share the standing-to-colour mapping with the game's reputation pane.
-- Friendship ranks end at Exalted; Paragon and Renown use ElvUI's extra slots.
function EPDBC:GetReputationReaction(factionID, reaction)
	local friendshipInfo = (E.Mists or E.Modern) and factionID and GetFriendshipReputation(factionID)
	if friendshipInfo and friendshipInfo.friendshipFactionID and friendshipInfo.friendshipFactionID > 0 then
		local rankInfo = GetFriendshipReputationRanks(factionID)
		local diff = MAX_REPUTATION_REACTION - (rankInfo.maxLevel or 0)
		return min(max((rankInfo.currentLevel or 0) + diff, 1), MAX_REPUTATION_REACTION), friendshipInfo
	end

	-- Match ElvUI's priority: friendship, then Paragon, then Renown.
	-- E.Modern includes Forever; the APIs determine which faction types exist.
	if E.Modern and factionID then
		if IsFactionParagonForCurrentPlayer(factionID) then return 9 end
		if IsMajorFaction(factionID) then return 10 end
	end

	-- Unknown standings use Hated rather than an undefined colour slot 0.
	return reaction == 0 and 1 or reaction
end

-- All clients use the same within-tier progress calculation.
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

-- One display state drives both the watched DataBar and every pane entry.
-- This function changes no frames; it combines the faction APIs with live settings.
function EPDBC:GetReputationBarState(data)
	if not data then return end
	local reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID
	if not reaction or not currentReactionThreshold or not nextReactionThreshold or not currentStanding then return end

	local rational, alpha, friendshipInfo, majorFactionData, currentValue, maximumValue
	local isFriendshipCapped, isParagon, isCappedExalted, isRenownCapped

	-- The shared mapping preserves the friendship rank adjustment on Mists/Modern.
	reaction, friendshipInfo = EPDBC:GetReputationReaction(factionID, reaction)
	if friendshipInfo then
		currentReactionThreshold, nextReactionThreshold, currentStanding = friendshipInfo.reactionThreshold or 0, friendshipInfo.nextThreshold or huge, friendshipInfo.standing or 1
		isFriendshipCapped = nextReactionThreshold == huge
	end

	isParagon = reaction == 9
	if isParagon then
		local current, threshold = GetFactionParagonInfo(factionID)

		if current and threshold and threshold > 0 then
			reaction, currentReactionThreshold, nextReactionThreshold, currentStanding = 9, 0, threshold, current % threshold
		end
	end

	-- Renown uses progress within the current level, or a full bar at maximum.
	if reaction == 10 then
		majorFactionData = GetMajorFactionData(factionID)
		if not majorFactionData or majorFactionData.factionID <= 0 then return end
		reaction, currentReactionThreshold, nextReactionThreshold = 10, 0, majorFactionData.renownLevelThreshold
		isRenownCapped = HasMaximumRenown(factionID)
		currentStanding = isRenownCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
	end

	-- Classic Era, TBC, and Wrath use ordinary standings. The same fallback
	-- handles ordinary factions on Mists, Standard, and Forever.
	isCappedExalted = reaction == MAX_REPUTATION_REACTION and not isParagon

	if isFriendshipCapped or isCappedExalted or isRenownCapped then
		currentValue, maximumValue = 1, 1
	else
		currentValue, maximumValue = GetCurrentAndMaximumValues(currentStanding, currentReactionThreshold, nextReactionThreshold)
	end

	-- Shared presentation: read the live profile so option changes apply immediately.
	-- we shouldn't upvalue either of these since they can be modified by the user; we need to access them directly each update
	local customColors = EDB.db.colors.useCustomFactionColors
	local customReaction = reaction == 9 or reaction == 10 -- 9 is Paragon, 10 is Renown
	local color = ((customColors or customReaction) and EDB.db.colors.factionColors[reaction]) or ElvUF.colors.reaction[reaction] or {}
	local r, g, b = color.r or 1, color.g or 1, color.b or 1
	local baseA = (customColors and color.a) or EDB.db.colors.reputationAlpha

	rational = currentValue / maximumValue
	rational = EPDBC:Round(rational, E.db.EPDBC.progressSmoothing.decimalLength or 3)

	-- alpha: use progress smoothing when enabled, otherwise use base alpha
	alpha = (E.db.EPDBC.reputationBar.progress and rational) or baseA

	if (E.db.EPDBC.reputationBar.fillHated and reaction == 1 and currentValue == 0)
	or (E.db.EPDBC.reputationBar.fillExalted and reaction == 9 and currentValue == maximumValue)
	or (E.db.EPDBC.reputationBar.fillExalted and (isCappedExalted or isFriendshipCapped or isRenownCapped)) then
		alpha = 1
		currentReactionThreshold, nextReactionThreshold, currentStanding = 0, 1, 1
	end

	-- Match ElvUI's baseline ranges when no fill override is requested. Keeping
	-- these values in the shared state also restores the normal fill immediately
	-- when the user turns Fill Hated/Exalted off.
	return {
		reaction = reaction,
		minimum = (nextReactionThreshold == huge or currentReactionThreshold == nextReactionThreshold) and 0 or currentReactionThreshold,
		maximum = nextReactionThreshold == huge and 1 or nextReactionThreshold,
		value = currentStanding,
		r = r, g = g, b = b, alpha = alpha or 1
	}
end

local function UpdateReputation()
	-- The pane must update even when the separate DataBar is hidden.
	EPDBC:UpdateReputationPane()

	local bar = EDB.StatusBars.Reputation
	if not bar then return end
	EDB:SetVisibility(bar)
	if not bar.db.enable or bar:ShouldHide() then return end

	-- ElvUI wraps the legacy tuple API and the modern table API for us.
	local data = E:GetWatchedFactionInfo()
	if not data or not data.name then return end
	local state = EPDBC:GetReputationBarState(data)
	if not state then return end

	bar:SetMinMaxValues(state.minimum, state.maximum)
	bar:SetValue(state.value)
	bar:SetStatusBarColor(state.r, state.g, state.b, state.alpha)
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