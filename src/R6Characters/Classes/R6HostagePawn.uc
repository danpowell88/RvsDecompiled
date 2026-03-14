//=============================================================================
// R6HostagePawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6HostagePawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation
//=============================================================================
class R6HostagePawn extends R6Hostage;

simulated event PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R6Hostage_UKX.HostageAnims');
	super.PostBeginPlay();
	return;
}

defaultproperties
{
	m_FOVClass=Class'R6Characters.R6FieldOfView'
	Mesh=SkeletalMesh'R6Hostage_UKX.NightWatchMesh'
	KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel196'
	Skins=/* Array type was not detected. */
}
