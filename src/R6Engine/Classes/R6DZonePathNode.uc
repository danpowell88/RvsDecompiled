//=============================================================================
// R6DZonePathNode - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DZonePathNode.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePathNode extends Actor
	native
 placeable;

var(R6DZone) int m_AnimChance;
var(R6DZone) bool m_bWait;
var(R6DZone) float m_fRadius;
var R6DZonePath m_pPath;
var(R6DZone) Sound m_SoundToPlay;
var(R6DZone) Sound m_SoundToPlayStop;
var(R6DZone) name m_AnimToPlay;

event Destroyed()
{
	return;
}

defaultproperties
{
	m_bWait=true
	m_fRadius=50.0000000
	bHidden=true
	m_bUseR6Availability=true
	CollisionRadius=40.0000000
	CollisionHeight=85.0000000
	Texture=Texture'R6Engine_T.Icons.DZoneTer'
}
