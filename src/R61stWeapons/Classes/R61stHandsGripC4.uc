//=============================================================================
// R61stHandsGripC4 - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R61stHandsGripC4.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/05 * Created by Rima Brek
//=============================================================================
class R61stHandsGripC4 extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripC4A');
	super.PostBeginPlay();
	m_HandFire = 'Fire';
	return;
}

simulated state FiringWeapon
{
	function AnimEnd(int iChannel)
	{
		// End:0x1A
		if(__NFUN_132__(__NFUN_155__(iChannel, 0), __NFUN_114__(Owner, none)))
		{
			return;
		}
		// End:0x41
		if(bShowLog)
		{
			__NFUN_231__("HANDS - EndAnim, goto wait");
		}
		AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_WeaponNeutralAnim);
		AnimBlendParams(1, 0.0000000);
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		m_bCanQuitOnAnimEnd = false;
		m_bCannotPlayEmpty = false;
		m_bInBurst = false;
		__NFUN_113__('DiscardWeaponAfterFire');
		return;
	}
	stop;
}

state DiscardWeaponAfterFire
{
	function Timer()
	{
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated event AnimEnd(int Channel)
	{
		// End:0x3C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("IN:", string(self)), "::DiscardWeaponAfterFire::AnimEnd()"));
		}
		// End:0x49
		if(__NFUN_114__(Owner, none))
		{
			return;
		}
		// End:0x73
		if(__NFUN_154__(Channel, 0))
		{
			SetDrawType(0);
			__NFUN_280__(R6AbstractWeapon(Owner).m_fPauseWhenChanging, false);
		}
		// End:0xB0
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("OUT:", string(self)), "::DiscardWeaponAfterFire::AnimEnd()"));
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x3F
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("IN:", string(self)), "::DiscardWeaponAfterFire::BeginState()"));
		}
		__NFUN_259__('FireEmpty', R6Pawn(Owner.Owner).ArmorSkillEffect());
		// End:0xA4
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("OUT:", string(self)), "::DiscardWeaponAfterFire::BeginState()"));
		}
		return;
	}
	stop;
}

state DiscardWeapon
{
	function Timer()
	{
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated event AnimEnd(int Channel)
	{
		// End:0x56
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  "), string(self)), " -   IN:"), string(self)), "::DiscardWeapon::AnimEnd()"));
		}
		// End:0x63
		if(__NFUN_114__(Owner, none))
		{
			return;
		}
		// End:0x8D
		if(__NFUN_154__(Channel, 0))
		{
			SetDrawType(0);
			__NFUN_280__(R6AbstractWeapon(Owner).m_fPauseWhenChanging, false);
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x4B
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  IN:"), string(self)), "::DiscardWeapon::BeginState()"));
		}
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_UnEquipSnd, 3);
		__NFUN_259__('End', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
		return;
	}
	stop;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
