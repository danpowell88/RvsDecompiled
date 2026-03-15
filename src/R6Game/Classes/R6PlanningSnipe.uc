//=============================================================================
// R6PlanningSnipe - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlanningSnipe.uc : Sniper icon in the planning phase.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15 * Created by Joel Tremblay
//=============================================================================
class R6PlanningSnipe extends R6ReferenceIcons;

function Rotator SetDirectionRotator(Vector vTowards)
{
	local Rotator rActionRotator;
	local Vector vResultVector;

	vResultVector = Normal((vTowards - Location));
	rActionRotator = Rotator(vResultVector);
	m_u8SpritePlanningAngle = byte((rActionRotator.Yaw / 255));
	return rActionRotator;
	return;
}

defaultproperties
{
	DrawScale=2.5000000
	Texture=Texture'R6Planning.Icons.PlanIcon_Snipe'
}
