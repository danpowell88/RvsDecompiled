//=============================================================================
// R6RHeavyHelmet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6RHeavyHelmet.uc : heavy rainbow helmet
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//
//=============================================================================
class R6RHeavyHelmet extends R6RHelmet;

function SetHelmetStaticMesh(bool bOpen)
{
	// End:0x17
	if(bOpen)
	{
		SetStaticMesh(StaticMesh'R6Characters.R6RHeavyHatOpen');		
	}
	else
	{
		SetStaticMesh(StaticMesh'R6Characters.R6RHeavyHat');
	}
	return;
}

defaultproperties
{
	DrawScale=1.1000000
	StaticMesh=StaticMesh'R6Characters.R6RHeavyHat'
	Skins=/* Array type was not detected. */
}
