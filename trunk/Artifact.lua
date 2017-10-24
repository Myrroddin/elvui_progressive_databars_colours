local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn

local function UpdateArtifact(self)
    if not HasArtifactEquipped() then
        -- no artifact weapon or fishing pole equipped, exit out
        return
    end

    local bar = self.artifactBar
    local aColor = E.db.PCB.artifactBar.artColor

    bar.statusBar:SetStatusBarColor(aColor.r, aColor.g, aColor.b)

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
    if E.db.PCB.enabled and EDB.artifactBar then
        if not PCB:IsHooked(EDB, "UpdateArtifact", UpdateArtifact) then
            PCB:SecureHook(EDB, "UpdateArtifact", UpdateArtifact)
        end
    elseif not E.db.PCB.enabled or not EDB.artifactBar then
        if PCB:IsHooked(EDB, "UpdateArtifact") then
            PCB:Unhook(EDB, "UpdateArtifact")
        end
        PCB:RestoreArtifactBar()
    end
    EDB:UpdateArtifact()
end

function PCB:RestoreArtifactBar()
    local bar = EDB.artifactBar
    if bar then
        bar.statusBar:SetStatusBarColor(.901, .8, .601)
        bar.statusBar:SetAlpha(1)
    end
end