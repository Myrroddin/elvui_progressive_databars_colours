local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn

local function UpdateArtifact(self)
    local bar = self.artifactBar
    local aColor = E.db.PCB.artifactBar.artColor
    local bColor = E.db.PCB.artifactBar.bagColor

    bar.statusBar:SetStatusBarColor(aColor.r, aColor.g, aColor.b)
    bar.bagValue:SetStatusBarColor(bColor.r, bColor.g, bColor.b)

    if E.db.PCB.artifactBar.progress then
        local current = select(5, C_ArtifactUI.GetEquippedArtifactInfo())
        local numTraits = select(6, C_ArtifactUI.GetEquippedArtifactInfo())
        local tier = select(13, C_ArtifactUI.GetEquippedArtifactInfo())
        local nextCost = C_ArtifactUI.GetCostForPointAtRank(numTraits, tier)

        local avg = current / nextCost
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