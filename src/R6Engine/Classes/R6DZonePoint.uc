//=============================================================================
// R6DZonePoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DZonePoint.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZonePoint extends R6DeploymentZone
	native
 placeable;

var(R6DZone) Actor.EStance m_eStance;
var(R6DZone) bool m_bUseReactionZone;
var(R6DZone) float m_fReactionZoneX;
var(R6DZone) float m_fReactionZoneY;
var(R6DZone) Vector m_vReactionZoneCenter;

defaultproperties
{
	m_fReactionZoneX=300.0000000
	m_fReactionZoneY=300.0000000
	bDirectional=true
}
