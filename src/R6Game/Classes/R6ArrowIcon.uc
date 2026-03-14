//=============================================================================
// R6ArrowIcon - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ArrowUpIcon.uc : Up arrow for planning only.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Joel Tremblay
//=============================================================================
class R6ArrowIcon extends R6ReferenceIcons;

var Vector m_vPointToReach;
var Vector m_vStartLocation;

state FollowPath
{
	function Tick(float DeltaTime)
	{
		// End:0x7D
		if(__NFUN_154__(int(Physics), int(5)))
		{
			// End:0x7A
			if(__NFUN_130__(__NFUN_176__(__NFUN_186__(float(__NFUN_147__(DesiredRotation.Yaw, __NFUN_156__(Rotation.Yaw, 65535)))), float(20)), __NFUN_176__(__NFUN_186__(float(__NFUN_147__(DesiredRotation.Pitch, __NFUN_156__(Rotation.Pitch, 65535)))), float(20))))
			{
				R6PlanningPawn(Owner).ArrowRotationIsOK();
			}			
		}
		else
		{
			// End:0xB2
			if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_vPointToReach, m_vStartLocation)), __NFUN_225__(__NFUN_216__(Location, m_vStartLocation))))
			{
				R6PlanningPawn(Owner).ArrowReachedNavPoint();
			}
		}
		m_u8SpritePlanningAngle = byte(__NFUN_146__(__NFUN_145__(Rotation.Yaw, 255), 64));
		return;
	}

	function EndState()
	{
		m_bSpriteShowOver = false;
		Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		return;
	}

	function BeginState()
	{
		m_bSpriteShowOver = true;
		return;
	}
	stop;
}

defaultproperties
{
	Physics=6
	bHidden=true
	bIgnoreOutOfWorld=true
	bRotateToDesired=true
	m_bSpriteShownIn3DInPlanning=true
	DrawScale=1.2500000
	Texture=Texture'R6Planning.Icons.PlanIcon_Arrow'
	RotationRate=(Pitch=0,Yaw=5000,Roll=0)
}
