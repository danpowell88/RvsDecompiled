//=============================================================================
// R6CameraSpot - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CameraSpot.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CameraSpot extends Actor
    placeable;

defaultproperties
{
	bStatic=true
	bHidden=true
	bCollideWhenPlacing=true
	bDirectional=true
	DrawScale=3.0000000
	Texture=Texture'R6Engine.S_CameraSpot'
}
