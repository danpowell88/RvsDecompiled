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

	m_u8SpritePlanningAngle = byte(__NFUN_145__(iDoorClosedYaw, 255));
	rPointDoorRotator = Rotator(__NFUN_216__(vPointLocation, Location));
	// End:0x46
	if(__NFUN_150__(rPointDoorRotator.Yaw, 0))
	{
		__NFUN_161__(rPointDoorRotator.Yaw, 65536);
	}
	iYawDifference = __NFUN_147__(rPointDoorRotator.Yaw, iDoorClosedYaw);
	// End:0x74
	if(__NFUN_150__(iYawDifference, 0))
	{
		__NFUN_161__(iYawDifference, 65536);
	}
	// End:0x8B
	if(__NFUN_150__(iYawDifference, 0))
	{
		__NFUN_161__(iYawDifference, 65536);
	}
	// End:0xC3
	if(__NFUN_151__(iYawDifference, 32767))
	{
		vDirection = DrawScale3D;
		__NFUN_182__(vDirection.Y, float(-1));
		SetDrawScale3D(vDirection);
	}
	return;
}

defaultproperties
{
	m_bSkipHitDetection=false
	Texture=Texture'R6Planning.Icons.PlanIcon_BreachDoor'
}
