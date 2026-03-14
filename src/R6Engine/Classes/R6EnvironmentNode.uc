//=============================================================================
// R6EnvironmentNode - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6EnvironmentNode.uc : nodes that contain information about the environment,
//                          location of walls, corners, etc...
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Rima Brek
//=============================================================================
class R6EnvironmentNode extends Actor
	native
 placeable;

var Vector m_vLookDir;

function PostBeginPlay()
{
	super.PostBeginPlay();
	m_vLookDir = Vector(Rotation);
	m_vLookDir = __NFUN_226__(m_vLookDir);
	return;
}

function Touch(Actor Other)
{
	return;
}

function UnTouch(Actor Other)
{
	return;
}

defaultproperties
{
	bCollideActors=true
	bDirectional=true
}
