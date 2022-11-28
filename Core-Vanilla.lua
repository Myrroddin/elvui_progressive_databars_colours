-- local references to global functions so we don't conflict
local _G = _G
local CLOSE = _G.CLOSE
local ReloadUI = _G.ReloadUI
local math = _G.math
local LibStub = _G.LibStub
local GetCVarBool = _G.GetCVarBool
local GetAddOnMetadata = _G.GetAddOnMetadata
local StopMusic = _G.StopMusic
local unpack = _G.unpack
local tonumber = _G.tonumber

-- the vaarg statement
local addonName, addon = ...
local Version = GetAddOnMetadata(addonName, "Version")
--@debug@
if Version:match("@") then
    Version = 1
end
--@end-debug@
Version = tonumber(Version)

-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)

-- create the plugin for ElvUI
local MyPluginName = L["Progressively Colored DataBars"]
local EPDBC = E:NewModule("EPDBC", "AceEvent-3.0", "AceHook-3.0", "LibAboutPanel-2.0")
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
EPDBC.Eversion = tonumber(GetAddOnMetadata(addonName, "X-ElvUI-Version")) -- minimum compatible ElvUI version
local Eversion = tonumber(E.version) -- installed ElvUI version

-- we can use this to automatically insert our GUI tables when ElvUI_Config is loaded
local LEP = LibStub("LibElvUIPlugin-1.0")

-- default options
P["EPDBC"] = {
    enabled = true,
    experienceBar = {
        progress = true
    },
    reputationBar = {
        progress = true,
        fillExalted = true,
        fillHated = true
    },
    progressSmoothing = {
        decimalLength = 3
    }
}

-- This function will hold our layout settings
local function SetupLayout(layout)
    if layout == "databars" then
        -- replace reputation databar colours
        E.db["databars"]["colors"]["factionColors"][1]["b"] = 0.00000000000000
        E.db["databars"]["colors"]["factionColors"][1]["g"] = 0.00000000000000
        E.db["databars"]["colors"]["factionColors"][1]["r"] = 1.00000000000000
        E.db["databars"]["colors"]["factionColors"][2]["b"] = 0.27843137254902
        E.db["databars"]["colors"]["factionColors"][2]["g"] = 0.38823529411765
        E.db["databars"]["colors"]["factionColors"][2]["r"] = 1.00000000000000
        E.db["databars"]["colors"]["factionColors"][3]["b"] = 0.00000000000000
        E.db["databars"]["colors"]["factionColors"][3]["g"] = 0.64705882352941
        E.db["databars"]["colors"]["factionColors"][3]["r"] = 1.00000000000000
        E.db["databars"]["colors"]["factionColors"][4]["g"] = 1.00000000000000
        E.db["databars"]["colors"]["factionColors"][4]["r"] = 1.00000000000000
        E.db["databars"]["colors"]["factionColors"][5]["b"] = 0.00000000000000
        E.db["databars"]["colors"]["factionColors"][5]["g"] = 0.50196078431373
        E.db["databars"]["colors"]["factionColors"][6]["b"] = 0.92941176470588
        E.db["databars"]["colors"]["factionColors"][6]["g"] = 0.58431372549020
        E.db["databars"]["colors"]["factionColors"][6]["r"] = 0.39215686274510
        E.db["databars"]["colors"]["factionColors"][7]["b"] = 0.88627450980392
        E.db["databars"]["colors"]["factionColors"][7]["g"] = 0.16862745098039
        E.db["databars"]["colors"]["factionColors"][7]["r"] = 0.54117647058824
        E.db["databars"]["colors"]["factionColors"][8]["b"] = 0.50196078431373
        E.db["databars"]["colors"]["factionColors"][8]["g"] = 0.00000000000000
        E.db["databars"]["colors"]["factionColors"][8]["r"] = 0.50196078431373
    elseif layout == "tooltip" then
        -- replace tooltip faction colours
        E.db["tooltip"]["factionColors"][1]["b"] = 0.00000000000000
        E.db["tooltip"]["factionColors"][1]["g"] = 0.00000000000000
        E.db["tooltip"]["factionColors"][1]["r"] = 1.00000000000000
        E.db["tooltip"]["factionColors"][2]["b"] = 0.27843137254902
        E.db["tooltip"]["factionColors"][2]["g"] = 0.38823529411765
        E.db["tooltip"]["factionColors"][2]["r"] = 1.00000000000000
        E.db["tooltip"]["factionColors"][3]["b"] = 0.00000000000000
        E.db["tooltip"]["factionColors"][3]["g"] = 0.64705882352941
        E.db["tooltip"]["factionColors"][3]["r"] = 1.00000000000000
        E.db["tooltip"]["factionColors"][4]["g"] = 1.00000000000000
        E.db["tooltip"]["factionColors"][4]["r"] = 1.00000000000000
        E.db["tooltip"]["factionColors"][5]["b"] = 0.00000000000000
        E.db["tooltip"]["factionColors"][5]["g"] = 0.50196078431373
        E.db["tooltip"]["factionColors"][6]["b"] = 0.92941176470588
        E.db["tooltip"]["factionColors"][6]["g"] = 0.58431372549020
        E.db["tooltip"]["factionColors"][6]["r"] = 0.39215686274510
        E.db["tooltip"]["factionColors"][7]["b"] = 0.88627450980392
        E.db["tooltip"]["factionColors"][7]["g"] = 0.16862745098039
        E.db["tooltip"]["factionColors"][7]["r"] = 0.54117647058824
        E.db["tooltip"]["factionColors"][8]["b"] = 0.50196078431373
        E.db["tooltip"]["factionColors"][8]["g"] = 0.00000000000000
        E.db["tooltip"]["factionColors"][8]["r"] = 0.50196078431373
    end

    -- Update ElvUI
    E:UpdateAll(true)

    -- Show message about layout being set
    PluginInstallStepComplete.message = L["Layout Set"]
    PluginInstallStepComplete:Show()
end

-- This function is executed when you press "Skip Process" or "Finished" in the installer.
local function InstallComplete()
    if GetCVarBool("Sound_EnableMusic") then
        StopMusic()
    end

    -- Set a variable tracking the version of the addon when layout was installed
    -- Fix repeating installation, then set the variable correctly
    E.db["EPDBC"].install_version = nil
    E.private["EPDBC"].install_complete = Version

    ReloadUI()
end

-- This is the data we pass on to the ElvUI Plugin Installer.
-- The Plugin Installer is reponsible for displaying the install guide for this layout.
local InstallerData = {
    Title = format("|cff4beb2c%s %s|r", MyPluginName, L["Installation"]),
	Name = MyPluginName,
    Pages = {
        [1] = function()
            PluginInstallFrame.SubTitle:SetFormattedText(L["Welcome to the installation for %s."], MyPluginName)
            PluginInstallFrame.Desc1:SetText(L["This installation process will guide you through a few steps and apply settings to your current ElvUI profile. If you want to be able to go back to your original settings then create a new profile before going through this installation process."])
            PluginInstallFrame.Desc2:SetText(L["Please press the continue button if you wish to go through the installation process, otherwise click the 'Skip Process' button."])
            PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
			PluginInstallFrame.Option1:SetText(L["Skip Process"])
        end,
        [2] = function()
            PluginInstallFrame.SubTitle:SetText(L["DataBars"])
            PluginInstallFrame.Desc1:SetText(L["Colourize your DataBars"])
            PluginInstallFrame.Desc2:SetText(L["Importance: |cffFF3333High|r"])
            PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupLayout("databars") end)
			PluginInstallFrame.Option1:SetText(L["Colourize"])
        end,
        [3] = function()
            PluginInstallFrame.SubTitle:SetText(L["Tooltip"])
            PluginInstallFrame.Desc1:SetText(L["Colourize your Tooltip"])
            PluginInstallFrame.Desc2:SetText(L["Importance: |cffFF3333High|r"])
            PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", function() SetupLayout("tooltip") end)
			PluginInstallFrame.Option1:SetText(L["Colourize"])
        end,
        [4] = function()
            PluginInstallFrame.SubTitle:SetText(L["Installation Complete"])
			PluginInstallFrame.Desc1:SetText(L["You have completed the installation process."])
			PluginInstallFrame.Desc2:SetText(L["Please click the button below in order to finalize the process and automatically reload your UI."])
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
			PluginInstallFrame.Option1:SetText(L["Finished"])
        end,
    },
	StepTitles = {
		[1] = L["Welcome"],
		[2] = L["DataBars"],
		[3] = L["Tooltip"],
        [4] = L["Installation Complete"],
	},
	StepTitlesColor = {1, 1, 1},
	StepTitlesColorSelected = {0, 0.702, 1},
	StepTitleWidth = 200,
	StepTitleButtonWidth = 180,
	StepTitleTextJustification = "RIGHT",
}
addon.InstallerData = InstallerData

-- register plugin so options are properly inserted when config is loaded
function EPDBC:Initialize()
    -- check ElvUI version for mismatch
    if Eversion < EPDBC.Eversion then
        E:Delay(2, function() E:StaticPopup_Show("EPDBC_VERSION_MISMATCH") end)
		return
    end

    E.private["EPDBC"] = E.private["EPDBC"] or {}

    -- Initiate installation process if ElvUI install is complete and our plugin install has not yet been run
	if E.private["EPDBC"].install_complete == nil then
		E:GetModule("PluginInstaller"):Queue(InstallerData)
	end

    -- Insert our options table when ElvUI config is loaded
    LEP:RegisterPlugin(addonName, EPDBC.InsertOptions)

    if E.db.EPDBC.enabled then
        EPDBC:StartUp()
    end
end

-- insert our GUI options into ElvUI's config screen
function EPDBC:InsertOptions()
    E.Options.args.EPDBC = EPDBC:GetOptions()
end

-- register the module with ElvUI. ElvUI will now call EPDBC:Initialize() when ElvUI is ready to load our plugin
E:RegisterModule(EPDBC:GetName())

-- ElvUI version check popup if mismatch
E.PopupDialogs["EPDBC_VERSION_MISMATCH"] = {
    format(L["%s\n\nYour ElvUI version %.2f is not compatible with EPDBC.\nMinimum ElvUI version needed is %.2f. Please download it from here:\n"], MyPluginName, Eversion, EPDBC.Eversion),
    button1 = CLOSE,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hasEditBox = 1,
	OnShow = function(self)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = "https://www.tukui.org/download.php?ui=elvui"
		self.editBox:SetText("https://www.tukui.org/download.php?ui=elvui")
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end
}

-- called when EPDBC is enabled in the options
function EPDBC:StartUp()
    E.db["databars"]["colors"]["useCustomFactionColors"] = true
    E.db["tooltip"]["useCustomFactionColors"] = true

    EPDBC:HookXPBar()
    EPDBC:HookRepBar()

    -- call ElvUI's functions to update the bars
    EDB:ExperienceBar_Update()
    EDB:ReputationBar_Update()
end

-- called when EPDBC is disabled in the options
function EPDBC:ShutDown()
    E.db["databars"]["colors"]["useCustomFactionColors"] = false
    E.db["tooltip"]["useCustomFactionColors"] = false

    EPDBC:RestoreRepBar()
    EPDBC:RestoreXPBar()
    EPDBC:UnhookAll()

    -- call ElvUI's functions to update the bars
    EDB:ExperienceBar_Update()
    EDB:ReputationBar_Update()
end

-- utility functions
function EPDBC:Round(num, idp)
    if num <= 0.1 then return 0.1 end

    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function EPDBC:GetCurrentMaxValues(statusBar)
    local minimumValue, maximumValue = statusBar:GetMinMaxValues()
    local currentValue = statusBar:GetValue()

    return minimumValue, currentValue, maximumValue
end