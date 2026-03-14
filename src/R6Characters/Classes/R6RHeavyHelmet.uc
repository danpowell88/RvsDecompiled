//=============================================================================
//  R6RHeavyHelmet.uc : heavy rainbow helmet
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//
//=============================================================================
class R6RHeavyHelmet extends R6RHelmet;

#exec NEW StaticMesh File="models\R6RHeavyHelmOpen.ASE" Name="R6RHeavyHatOpen"
#exec NEW StaticMesh File="models\R6RHeavyHelm.ASE" Name="R6RHeavyHat"

// --- Functions ---
function SetHelmetStaticMesh(bool bOpen) {}

defaultproperties
{
}
