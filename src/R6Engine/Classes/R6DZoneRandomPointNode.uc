//=============================================================================
// R6DZoneRandomPointNode - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6DZoneRandomPointNode.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneRandomPointNode extends Actor
    native
    placeable;

var(R6DZone) Actor.EStance m_eStance;
var(R6DZone) int m_iGroupID;
var(R6DZone) bool m_bHighPriority;
// NEW IN 1.60
var(R6DZone) bool m_bAllowLeave;
var R6DZoneRandomPoints m_pZone;

defaultproperties
{
	m_eStance=1
	m_bAllowLeave=true
	bHidden=true
	m_bUseR6Availability=true
	bDirectional=true
	CollisionRadius=40.0000000
	CollisionHeight=85.0000000
	Texture=Texture'R6Engine_T.Icons.DZoneTer'
}
