//=============================================================================
// R6TerroristPawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TerroristPawn.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/15 * Creation 
//=============================================================================
class R6TerroristPawn extends R6Terrorist;

function PostBeginPlay()
{
	super.PostBeginPlay();
	LinkSkelAnim(MeshAnimation'R6Terrorist_UKX.TerroristAnims');
	return;
}

defaultproperties
{
	m_FOVClass=Class'R6Characters.R6FieldOfView'
	Mesh=SkeletalMesh'R6Terrorist_UKX.Militant01Mesh'
	KParams=KarmaParamsSkel'R6Characters.KarmaParamsSkel248'
	Skins=/* Array type was not detected. */
}
