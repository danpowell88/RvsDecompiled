//=============================================================================
// R6CameraDirection - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6CameraDirection.uc : Sniper icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15 * Created by Joel Tremblay
//=============================================================================
class R6CameraDirection extends R6ReferenceIcons;

function SetPlanningRotation(Rotator PointRotation)
{
	m_u8SpritePlanningAngle = byte((PointRotation.Yaw / 255));
	return;
}

defaultproperties
{
	bHidden=true
	DrawScale=6.0000000
	Texture=Texture'R6Planning.Icons.PlanIcon_CamDirection'
}
