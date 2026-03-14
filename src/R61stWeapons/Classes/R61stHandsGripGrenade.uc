//=============================================================================
// R61stHandsGripGrenade - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R61stHandsGripGrenade ] 
//===============================================================================
class R61stHandsGripGrenade extends R6
    AbstractFirstPersonHands;

function PostBeginPlay()
{
	LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripGrenadeA');
	super.PostBeginPlay();
	return;
}

auto state Waiting
{
	simulated function Timer()
	{
		local int HowLongBeforeWait;

		__NFUN_259__('Wait01');
		m_bPlayWaitAnim = true;
		HowLongBeforeWait = __NFUN_167__(10);
		__NFUN_280__(float(__NFUN_146__(HowLongBeforeWait, 5)), false);
		return;
	}
	stop;
}

state RaiseWeapon
{
	simulated function BeginState()
	{
		SetDrawType(2);
		AssociatedWeapon.SetDrawType(2);
		AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_WeaponNeutralAnim);
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_EquipSnd, 3);
		__NFUN_259__('Begin', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
		return;
	}
	stop;
}

simulated state FiringWeapon
{
	function EndState()
	{
		return;
	}

	function FireEmpty()
	{
		return;
	}

	function BeginState()
	{
		__NFUN_260__('Neutral',,, 1);
		return;
	}

	simulated function AnimEnd(int iChannel)
	{
		// End:0x1A
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("animEnd ", string(self)));
		}
		// End:0x34
		if(__NFUN_132__(__NFUN_155__(iChannel, 0), __NFUN_114__(Owner, none)))
		{
			return;
		}
		// End:0x90
		if(__NFUN_242__(m_bCanQuitOnAnimEnd, true))
		{
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_WeaponNeutralAnim);
			AnimBlendParams(1, 0.0000000);
			__NFUN_260__('Empty_nt');
			m_bCanQuitOnAnimEnd = false;
			m_bCannotPlayEmpty = false;
			m_bInBurst = false;
			__NFUN_113__('None');			
		}
		else
		{
			AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
			__NFUN_260__('Fire_nt', R6AbstractWeapon(Owner).m_fFireAnimRate, 0.1000000);
		}
		// End:0xE3
		if(bShowLog)
		{
			__NFUN_231__("Calling FPAO");
		}
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function FireGrenadeThrow()
	{
		AssociatedWeapon.SetDrawType(0);
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		__NFUN_259__('Fire_Up', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), 0.8000000));
		m_bCanQuitOnAnimEnd = true;
		// End:0x82
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("FireGrenadeThrow ", string(self)));
		}
		return;
	}

	simulated function FireGrenadeRoll()
	{
		AssociatedWeapon.SetDrawType(0);
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		__NFUN_259__('Fire_Down', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), 0.8000000));
		m_bCanQuitOnAnimEnd = true;
		// End:0x81
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("FireGrenadeRoll ", string(self)));
		}
		return;
	}

	simulated function FireSingleShot()
	{
		AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_Fire, R6Pawn(Owner.Owner).ArmorSkillEffect());
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		__NFUN_259__('Fire', R6Pawn(Owner.Owner).ArmorSkillEffect());
		m_bCanQuitOnAnimEnd = false;
		// End:0x9F
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("FireSingleShot ", string(self)));
		}
		return;
	}
	stop;
}

defaultproperties
{
	DrawType=0
	Mesh=SkeletalMesh'R61stHands_UKX.R61stHands'
}
