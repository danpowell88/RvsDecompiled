//=============================================================================
// R6Stairs - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Stairs.uc : use a Stairs class to mark the top and bottom of stairs
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/29 * Created by Rima Brek
//    2002/04/12   Recreated for a different purpose
//=============================================================================
class R6Stairs extends NavigationPoint
	native
 hidecategories(Lighting,LightColor,Karma,Force);

var() bool m_bIsTopOfStairs;

defaultproperties
{
	bCollideWhenPlacing=false
	bDirectional=true
	Texture=Texture'R6Engine.S_StairsNavP'
}
