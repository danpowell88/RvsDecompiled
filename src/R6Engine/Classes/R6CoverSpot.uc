//=============================================================================
// R6CoverSpot - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6CoverSpot.uc : Place where AI can go to take cover from fire
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/08 * Created by Guillaume Borgia
//=============================================================================
class R6CoverSpot extends NavigationPoint
    native
    hidecategories(Lighting,LightColor,Karma,Force);

const C_iPawnRadius = 40;
const C_iPawnPeekingRadius = 60;

enum ECoverShotDir
{
	COVERDIR_Over,                  // 0
	COVERDIR_Left,                  // 1
	COVERDIR_Right                  // 2
};

var() R6CoverSpot.ECoverShotDir m_eShotDir;

defaultproperties
{
	bDirectional=true
	bObsolete=true
	Texture=Texture'R6Engine_T.Icons.CoverSpot'
}
