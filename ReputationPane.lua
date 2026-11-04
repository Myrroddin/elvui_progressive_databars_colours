-- Keep pane-specific frame layouts separate from the DataBar's progress logic.
local ElvUI = _G.ElvUI
local E = ElvUI[1]
local _G = _G
local GetFactionInfo = GetFactionInfo
local EPDBC = E:GetModule("EPDBC")

local function IsEnabled()
	return E.db.EPDBC.enabled and E.db.EPDBC.reputationPane
end

local function UpdatePaneBar(bar, factionData)
	if not bar then return end
	local state = EPDBC:GetReputationBarState(factionData)
	if not state then return end

	-- Apply opacity to the fill only, keeping text and icons fully readable.
	-- Forever uses a filled texture; the other clients use StatusBars.
	if E.Forever then
		local range = state.maximum - state.minimum
		local progress = range > 0 and (state.value - state.minimum) / range or 0
		bar:SetFillPercent(progress) -- Blizzard clamps this to the visible 0-1 range.
		bar.Fill:SetVertexColor(state.r, state.g, state.b, state.alpha)
	else
		bar:SetMinMaxValues(state.minimum, state.maximum)
		bar:SetValue(state.value)
		bar:SetStatusBarColor(state.r, state.g, state.b, state.alpha)
	end
end

local function UpdateModernRow(row)
	local data = row.elementData
	if data and (not data.isHeader or data.isHeaderWithRep) then
		UpdatePaneBar(row.Content and row.Content.ReputationBar, data)
	end
end

local function UpdateModernPane(scrollBox)
	if not IsEnabled() then return end

	-- ScrollBox reuses rows. Apply the shared state after every scroll/update.
	scrollBox:ForEachFrame(UpdateModernRow)
end

local function UpdateDetailPane(frame, factionData)
	if IsEnabled() then
		UpdatePaneBar(frame.StandingBar, factionData)
	end
end

local function UpdateClassicPane()
	if not IsEnabled() then return end

	for i = 1, _G.NUM_FACTIONS_DISPLAYED do
		local row = _G["ReputationBar"..i]
		-- Era/TBC rows are StatusBars; Wrath/Mists put a StatusBar inside each row.
		local bar = (E.Classic or E.TBC) and row or _G["ReputationBar"..i.."ReputationBar"]
		if row and bar and row.index and row:IsShown() and bar:IsShown() then
			-- These clients still use the legacy listing API in Blizzard's own pane.
			local _, _, reaction, lower, upper, standing, _, _, _, _, _, _, _, factionID = GetFactionInfo(row.index)
			UpdatePaneBar(bar, {
				reaction = reaction, factionID = factionID,
				currentReactionThreshold = lower, nextReactionThreshold = upper, currentStanding = standing
			})
		end
	end
end

function EPDBC:RestoreReputationPane()
	self:UnregisterEvent("ADDON_LOADED")
	local frame = _G.ReputationFrame
	if not frame then return end

	local wasHooked
	if E.Modern then
		if self:IsHooked(frame.ScrollBox, "Update") then
			self:Unhook(frame.ScrollBox, "Update")
			wasHooked = true
		end
		if E.Forever and self:IsHooked(frame.ReputationDetailFrame, "RefreshStandingBar") then
			self:Unhook(frame.ReputationDetailFrame, "RefreshStandingBar")
		end
	elseif self:IsHooked("ReputationFrame_Update") then
		self:Unhook("ReputationFrame_Update")
		wasHooked = true
	end

	-- Let Blizzard restore the original fill and colours, including rows and details.
	-- Avoid changing global colour tables that are shared with unrelated UI.
	if wasHooked and frame:IsShown() then
		if E.Modern then
			frame:Update()
		else
			_G.ReputationFrame_Update()
		end
	end
end

function EPDBC:UpdateReputationPane()
	if not IsEnabled() then
		self:RestoreReputationPane()
		return
	end

	local frame = _G.ReputationFrame
	if not frame then
		-- Also supports clients that create the character pane after addon startup.
		self:RegisterEvent("ADDON_LOADED", "UpdateReputationPane")
		return
	end
	self:UnregisterEvent("ADDON_LOADED")

	if E.Modern then
		if not self:IsHooked(frame.ScrollBox, "Update") then
			self:SecureHook(frame.ScrollBox, "Update", UpdateModernPane)
		end
		if E.Forever and not self:IsHooked(frame.ReputationDetailFrame, "RefreshStandingBar") then
			self:SecureHook(frame.ReputationDetailFrame, "RefreshStandingBar", UpdateDetailPane)
		end
		if frame:IsShown() then
			UpdateModernPane(frame.ScrollBox)
			if E.Forever then frame.ReputationDetailFrame:Refresh() end
		end
	else
		if not self:IsHooked("ReputationFrame_Update") then
			self:SecureHook("ReputationFrame_Update", UpdateClassicPane)
		end
		if frame:IsShown() then UpdateClassicPane() end
	end
end