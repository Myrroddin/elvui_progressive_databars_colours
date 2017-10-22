local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn

local function UpdateArtifact(self)
    local bar = self.artifactBar
    local aColor = E.db.PCB.artifactBar.artColor
    local bColor = E.db.PCB.artifactBar.bagColor

    bar.statusBar:SetStatusBarColor(aColor.r, artColor.g, artColor.b)
    bar.bagValue:SetStatusBarColor(bColor.r, bColor.g, bColor.b)

    if E.db.PCB.artifactBar.progress then
        local _, _, _, _, totalAP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
        local _, ap, apForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)

        local avg = ap / apForNextPoint
        avg = PCB:Round(avg, 2)

        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(1)
    end
end

function PCB:HookArtifactBar()
    if E.db.PCB.enabled then
        if not PCB:IsHooked(E:GetModule("DataBars"), "UpdateArtifact", UpdateArtifact) then
            PCB:SecureHook(E:GetModule("DataBars"), "UpdateArtifact", UpdateArtifact)
        end
    else
        if PCB:IsHooked(E:GetModule("DataBars"), "UpdateArtifact") then
            PCB:UnHook(E:GetModule("DataBars"), "UpdateArtifact")
        end
        PCB:RestoreArtifactBar()
    end
    EDB:UpdateArtifact()
end

function PCB:RestoreArtifactBar()
    EDB.statusBar:SetStatusBarColor(.901, .8, .601)
    EDB.bagValue:SetStatusBarColor(0, 0.43, 0.95)
    EDB.statusBar:SetAlpha(1)
end