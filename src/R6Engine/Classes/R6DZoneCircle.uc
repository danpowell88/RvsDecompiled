//=============================================================================
// R6DZoneCircle - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DZoneCircle.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/11 * Created by Guillaume Borgia
//=============================================================================
class R6DZoneCircle extends R6DeploymentZone
	native
 placeable;

var(R6DZone) float m_fRadius;

defaultproperties
{
	m_fRadius=250.0000000
}
