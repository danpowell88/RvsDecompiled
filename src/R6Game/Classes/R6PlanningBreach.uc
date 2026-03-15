//=============================================================================
// R6PlanningBreach - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningBreach.uc : Breach Door icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/20 * Created by Joel Tremblay
//=============================================================================
class R6PlanningBreach extends R6ReferenceIcons;

function SetSpriteAngle(int iDoorClosedYaw, Vector vPointLocation)
{
	local Vector vDirection;
	local Rotator rPointDoorRotator;
	local int iYawDifference;

	m_u8SpritePlanningAngle = byte((iDoorClosedYaw / 255));
	rPointDoorRotator = Rotator((vPointLocation - Location));
	// End:0x46
	if((rPointDoorRotator.Yaw < 0))
	{
		(rPointDoorRotator.Yaw += 65536);
	}
	iYawDifference = (rPointDoorRotator.Yaw - iDoorClosedYaw);
	// End:0x74
	if((iYawDifference < 0))
	{
		(iYawDifference += 65536);
	}
	// End:0x8B
	if((iYawDifference < 0))
	{
		(iYawDifference += 65536);
	}
	// End:0xC3
	if((iYawDifference > 32767))
	{
		vDirection = DrawScale3D;
		(vDirection.Y *= float(-1));
		SetDrawScale3D(vDirection);
	}
	return;
}

defaultproperties
{
	m_bSkipHitDetection=false
	Texture=Texture'R6Planning.Icons.PlanIcon_BreachDoor'
}
