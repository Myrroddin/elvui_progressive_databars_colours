local E, L, V, P, G = unpack(ElvUI) -- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local EDB = E:GetModule("DataBars") -- ElvUI's DataBars
local PCB = E:GetModule("PCB") -- this AddOn
local bar = EDB.artifactBar -- less typing

local function UpdateArtifact()
    local aColor = E.db.PCB.artifactBar.artColor

    local current = select(5, C_ArtifactUI.GetEquippedArtifactInfo())

    -- exit out for characters with no artififact weapon equipped
    if not current then return end

    local numTraits = select(6, C_ArtifactUI.GetEquippedArtifactInfo())
    local tier = select(13, C_ArtifactUI.GetEquippedArtifactInfo())
    local nextCost = C_ArtifactUI.GetCostForPointAtRank(numTraits, tier)

    local avg = current / nextCost
    avg = PCB:Round(avg, 2)

    bar.statusBar:SetStatusBarColor(aColor.r, aColor.g, aColor.b)

    if E.db.PCB.artifactBar.progress then
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(1)
    end
end

function PCB:HookArtifactBar()
    if E.db.PCB.enabled and bar then
        if not PCB:IsHooked(EDB, "UpdateArtifact", UpdateArtifact) then
            PCB:SecureHook(EDB, "UpdateArtifact", UpdateArtifact)
        end
    elseif not E.db.PCB.enabled or not bar then
        if PCB:IsHooked(EDB, "UpdateArtifact") then
            PCB:UnHook(EDB, "UpdateArtifact")
        end
        PCB:RestoreArtifactBar()
    end
    EDB:UpdateArtifact()
end

function PCB:RestoreArtifactBar()
    if bar then
        bar:SetStatusBarColor(.901, .8, .601)
        bar:SetAlpha(1)
    end
end