//=============================================================================
// R6AbstractFirstPersonHands - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//===============================================================================
//  [R6AbstractFirstPersonHands] 
//===============================================================================
class R6AbstractFirstPersonHands extends R6
    AbstractFirstPersonWeapon
    abstract;

var bool m_bPlayWaitAnim;  // hands are playing a waiting anim
var bool m_bCanQuitOnAnimEnd;  // once this animation calls anim end qe can quit the state
var bool m_bCannotPlayEmpty;  // If this is false, fireEmpty does not do anything
var bool m_bInBurst;  // this is true while the hands are firing a burst
var bool m_bBipodDeployed;  // use weapon bipod animation
var bool bShowLog;
var bool bPlayerWalking;
var float m_fAnimAcceleration;
var R6AbstractFirstPersonWeapon AssociatedWeapon;
var R6AbstractGadget AssociatedGadget;
var(R6HandAnimation) name m_HandFire;
var(R6HandAnimation) name m_HandFireLast;
var(R6HandAnimation) name m_HandBipodFire;
var(R6HandAnimation) name m_HandReloadEmpty;
var(R6HandAnimation) name m_HandBipodReloadEmpty;
var(R6HandAnimation) name m_WaitAnim1;
var(R6HandAnimation) name m_WaitAnim2;
var(R6HandAnimation) name m_WalkAnim;

function PostBeginPlay()
{
	// End:0x18
	if((!HasAnim('Fire')))
	{
		m_HandFire = 'Neutral';
	}
	// End:0x30
	if((!HasAnim('FireLast')))
	{
		m_HandFireLast = m_HandFire;
	}
	// End:0x48
	if((!HasAnim('BipodFire')))
	{
		m_HandBipodFire = m_HandFire;
	}
	// End:0x60
	if((!HasAnim('ReloadEmpty')))
	{
		m_HandReloadEmpty = 'Reload';
	}
	// End:0x78
	if((!HasAnim('BipodReloadEmpty')))
	{
		m_HandBipodReloadEmpty = 'BipodReload';
	}
	// End:0x90
	if((!HasAnim('Wait01')))
	{
		m_WaitAnim1 = 'Wait_c';
	}
	// End:0xA8
	if((!HasAnim('Wait02')))
	{
		m_WaitAnim2 = m_WaitAnim1;
	}
	// End:0xC0
	if((!HasAnim('walk_c')))
	{
		m_WalkAnim = 'Wait_c';
	}
	super.PostBeginPlay();
	return;
}

function ResetNeutralAnim()
{
	AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
	AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
	return;
}

function PlayWalkingAnimation()
{
	// End:0x13
	if(IsInState('Waiting'))
	{
		LoopAnim(m_WalkAnim);
	}
	bPlayerWalking = true;
	return;
}

function StopWalkingAnimation()
{
	// End:0x13
	if(IsInState('Waiting'))
	{
		LoopAnim('Wait_c');
	}
	bPlayerWalking = false;
	return;
}

simulated function SetAssociatedWeapon(R6AbstractFirstPersonWeapon AWeapon)
{
	AssociatedWeapon = AWeapon;
	return;
}

simulated function SetAssociatedGadget(R6AbstractGadget AGadget)
{
	AssociatedGadget = AGadget;
	return;
}

state Reloading
{
	function EndState()
	{
		// End:0x39
		if(bShowLog)
		{
			Log((("HANDS - " $ string(self)) $ " -  Leaving State Reloading"));
		}
		return;
	}

	simulated event AnimEnd(int Channel)
	{
		// End:0x96
		if((Channel == 0))
		{
			// End:0x34
			if(m_bBipodDeployed)
			{
				AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_BipodNeutral;				
			}
			else
			{
				AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
			}
			AssociatedWeapon.PlayAnim(AssociatedWeapon.m_WeaponNeutralAnim);
			GotoState('Waiting');
			AssociatedWeapon.GotoState('None');
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x37
		if(bShowLog)
		{
			Log((("HANDS - " $ string(self)) $ " -  Begin State Reloading"));
		}
		R6Pawn(Owner.Owner).ServerPlayReloadAnimAgain();
		AssociatedWeapon.GotoState('Reloading');
		// End:0x13B
		if((m_bReloadEmpty == true))
		{
			// End:0xD6
			if(m_bBipodDeployed)
			{
				PlayAnim(m_HandBipodReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
				AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);				
			}
			else
			{
				PlayAnim(m_HandReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
				AssociatedWeapon.PlayAnim(AssociatedWeapon.m_ReloadEmpty, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			}
			m_bReloadEmpty = false;			
		}
		else
		{
			// End:0x1A1
			if(m_bBipodDeployed)
			{
				PlayAnim('BipodReload', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
				AssociatedWeapon.PlayAnim(AssociatedWeapon.m_BipodReload, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);				
			}
			else
			{
				PlayAnim('Reload', R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
				AssociatedWeapon.PlayAnim(AssociatedWeapon.m_Reload, R6Pawn(Owner.Owner).m_fReloadSpeedMultiplier);
			}
		}
		return;
	}
	stop;
}

state DiscardWeapon
{
	simulated event AnimEnd(int Channel)
	{
		// End:0x56
		if(bShowLog)
		{
			Log((((((("HANDS - " $ string(self)) $ " -  ") $ string(self)) $ " -   IN:") @ string(self)) @ "::DiscardWeapon::AnimEnd()"));
		}
		// End:0x63
		if((Owner == none))
		{
			return;
		}
		// End:0x8A
		if((Channel == 0))
		{
			SetDrawType(0);
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x4B
		if(bShowLog)
		{
			Log((((("HANDS - " $ string(self)) $ " -  IN:") @ string(self)) @ "::DiscardWeapon::BeginState()"));
		}
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_UnEquipSnd, 3) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
		// End:0xC7
		if(m_bBipodDeployed)
		{
			__NFUN_259__('BipodEnd', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodDiscard);			
		}
		else
		{
			__NFUN_259__('End', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
		}
		return;
	}
	stop;
}

state RaiseWeapon
{
	simulated event AnimEnd(int Channel)
	{
		// End:0x26
		if(__NFUN_154__(Channel, 0))
		{
			__NFUN_113__('Waiting');
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x3E
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  RaiseWeapon, Animation Begin"));
		}
		SetDrawType(2);
		m_bBipodDeployed = __NFUN_130__(R6Pawn(Owner.Owner).m_bIsProne, R6AbstractWeapon(Owner).GotBipod());
		AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_EquipSnd, 3);
		// End:0x115
		if(m_bBipodDeployed)
		{
			__NFUN_259__('BipodBegin', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodRaise);			
		}
		else
		{
			__NFUN_259__('Begin', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));
		}
		return;
	}
	stop;
}

state PutWeaponDown
{
	simulated event AnimEnd(int Channel)
	{
		// End:0x27
		if(__NFUN_154__(Channel, 0))
		{
			SetDrawType(0);
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
		}
		return;
	}

	simulated function BeginState()
	{
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_UnEquipSnd, 3);
		// End:0x7C
		if(m_bBipodDeployed)
		{
			__NFUN_259__('BipodEnd');
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodDiscard, __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));			
		}
		else
		{
			__NFUN_259__('End', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), 1.5000000));
		}
		return;
	}
	stop;
}

state BringWeaponUp
{
	simulated function BeginState()
	{
		SetDrawType(2);
		m_bBipodDeployed = __NFUN_130__(R6Pawn(Owner.Owner).m_bIsProne, R6AbstractWeapon(Owner).GotBipod());
		AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
		Owner.Owner.__NFUN_264__(R6AbstractWeapon(Owner).m_EquipSnd, 3);
		// End:0xD7
		if(m_bBipodDeployed)
		{
			__NFUN_259__('BipodBegin');
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodRaise, __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), m_fAnimAcceleration));			
		}
		else
		{
			__NFUN_259__('Begin', __NFUN_171__(R6Pawn(Owner.Owner).ArmorSkillEffect(), 1.5000000));
		}
		return;
	}

	simulated event AnimEnd(int Channel)
	{
		// End:0x26
		if(__NFUN_154__(Channel, 0))
		{
			__NFUN_113__('Waiting');
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
		}
		return;
	}
	stop;
}

auto state Waiting
{
	simulated function Timer()
	{
		local int WhichAnim, HowLongBeforeWait;

		// End:0x60
		if(__NFUN_155__(int(DrawType), int(0)))
		{
			StopAnimating();
			WhichAnim = __NFUN_167__(10);
			// End:0x37
			if(__NFUN_150__(WhichAnim, 5))
			{
				__NFUN_259__(m_WaitAnim1);				
			}
			else
			{
				__NFUN_259__(m_WaitAnim2);
			}
			m_bPlayWaitAnim = true;
			HowLongBeforeWait = __NFUN_167__(10);
			__NFUN_280__(float(__NFUN_146__(HowLongBeforeWait, 5)), false);
		}
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x47
		if(__NFUN_242__(m_bPlayWaitAnim, true))
		{
			m_bPlayWaitAnim = false;
			// End:0x28
			if(m_bBipodDeployed)
			{
				__NFUN_260__('Bipod_nt');				
			}
			else
			{
				// End:0x3F
				if(__NFUN_242__(bPlayerWalking, true))
				{
					__NFUN_260__(m_WalkAnim);					
				}
				else
				{
					__NFUN_260__('Wait_c');
				}
			}
		}
		return;
	}

	function StopTimer()
	{
		__NFUN_280__(0.0000000, false);
		return;
	}

	function StartTimer()
	{
		local int HowLongBeforeWait;

		// End:0x29
		if(__NFUN_155__(int(DrawType), int(0)))
		{
			HowLongBeforeWait = __NFUN_167__(10);
			__NFUN_280__(float(__NFUN_146__(HowLongBeforeWait, 5)), false);
		}
		return;
	}

	simulated function EndState()
	{
		// End:0x34
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  Waiting::EndState "));
		}
		StopAnimating();
		StopTimer();
		return;
	}

	simulated function BeginState()
	{
		// End:0x36
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  Waiting::BeginState "));
		}
		// End:0x4A
		if(m_bBipodDeployed)
		{
			__NFUN_260__('Bipod_nt');			
		}
		else
		{
			// End:0x61
			if(__NFUN_242__(bPlayerWalking, true))
			{
				__NFUN_260__(m_WalkAnim);				
			}
			else
			{
				__NFUN_260__('Wait_c');
			}
		}
		StartTimer();
		return;
	}
	stop;
}

simulated state FiringWeapon
{
	function EndState()
	{
		// End:0x3C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  Leaving State FiringWeapon"));
		}
		AnimBlendParams(1, 0.0000000);
		return;
	}

	function AnimEnd(int iChannel)
	{
		// End:0x1A
		if(__NFUN_132__(__NFUN_155__(iChannel, 0), __NFUN_114__(Owner, none)))
		{
			return;
		}
		// End:0x7E
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  FiringWeapon::AnimEnd Can quit: "), string(m_bCanQuitOnAnimEnd)), " In burst "), string(m_bInBurst)));
		}
		// End:0x131
		if(__NFUN_242__(m_bCanQuitOnAnimEnd, true))
		{
			// End:0xD5
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  EndAnim, goto wait Owner : "), string(R6AbstractWeapon(Owner))));
			}
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_WeaponNeutralAnim);
			AnimBlendParams(1, 0.0000000);
			__NFUN_113__('Waiting');
			R6AbstractWeapon(Owner).FirstPersonAnimOver();
			m_bCanQuitOnAnimEnd = false;
			m_bCannotPlayEmpty = false;
			m_bInBurst = false;			
		}
		else
		{
			// End:0x1BE
			if(__NFUN_242__(m_bInBurst, true))
			{
				// End:0x172
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  EndAnim, loop Burst"));
				}
				AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
				__NFUN_260__('Fireburst_c', R6AbstractWeapon(Owner).m_fFireAnimRate, 0.1000000);
				AssociatedWeapon.LoopWeaponBurst();				
			}
			else
			{
				// End:0x1FC
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  EndAnim, playing fireburst_2"));
				}
				m_bCannotPlayEmpty = true;
				m_bCanQuitOnAnimEnd = true;
				AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
				__NFUN_259__('Fireburst_e',, 0.1000000);
				AssociatedWeapon.StopWeaponBurst();
			}
		}
		return;
	}

	function StopFiring()
	{
		// End:0x2C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  StopFiring"));
		}
		m_bInBurst = false;
		AnimEnd(0);
		return;
	}

	function InterruptFiring()
	{
		// End:0x31
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  InterruptFiring"));
		}
		m_bCanQuitOnAnimEnd = true;
		m_bInBurst = false;
		AnimEnd(0);
		return;
	}

	function FireEmpty()
	{
		// End:0x2C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  Fire Empty"));
		}
		// End:0x51
		if(__NFUN_129__(m_bBipodDeployed))
		{
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_FireEmpty);
		}
		// End:0x6D
		if(__NFUN_242__(m_bCannotPlayEmpty, false))
		{
			__NFUN_259__('FireEmpty');
			m_bCanQuitOnAnimEnd = true;
		}
		return;
	}

	function FireLastBullet()
	{
		// End:0x30
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  FireLastBullet"));
		}
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		// End:0x7B
		if(m_bBipodDeployed)
		{
			__NFUN_259__(m_HandBipodFire);
			AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_BipodNeutral;			
		}
		else
		{
			__NFUN_259__(m_HandFireLast);
			// End:0xB7
			if(bShowLog)
			{
				__NFUN_231__(__NFUN_112__("New neutral anim is: ", string(AssociatedWeapon.m_Empty)));
			}
			AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Empty;
			AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_FireLast);
		}
		m_bCanQuitOnAnimEnd = true;
		return;
	}

	function FireSingleShot()
	{
		// End:0x30
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  FireSingleShot"));
		}
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		// End:0x5E
		if(m_bBipodDeployed)
		{
			__NFUN_259__(m_HandBipodFire);			
		}
		else
		{
			__NFUN_259__(m_HandFire);
		}
		m_bCanQuitOnAnimEnd = true;
		return;
	}

	function FireThreeShots()
	{
		// End:0x72
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  FireThreeShots rate = "), string(R6AbstractWeapon(Owner).m_fFireAnimRate)), "Blend = "), string(R6AbstractWeapon(Owner).m_fFPBlend)));
		}
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		__NFUN_259__('Fireburst_b', R6AbstractWeapon(Owner).m_fFireAnimRate);
		m_bCanQuitOnAnimEnd = false;
		return;
	}

	function StartBurst()
	{
		// End:0x70
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  StartBurst rate = "), string(R6AbstractWeapon(Owner).m_fFireAnimRate)), "  Blend = "), string(R6AbstractWeapon(Owner).m_fFPBlend)));
		}
		m_bCanQuitOnAnimEnd = false;
		AnimBlendParams(1, R6AbstractWeapon(Owner).m_fFPBlend);
		__NFUN_259__('Fireburst_b', R6AbstractWeapon(Owner).m_fFireAnimRate);
		m_bInBurst = true;
		AssociatedWeapon.StartWeaponBurst();
		return;
	}

	function BeginState()
	{
		// End:0x34
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  Begin Firing Anims"));
		}
		__NFUN_260__('Neutral',,, 1);
		return;
	}
	stop;
}

state HandsDown
{
	simulated function EndState()
	{
		StopAnimating();
		__NFUN_259__('OneHand_e');
		return;
	}

	event AnimEnd(int iChannel)
	{
		__NFUN_260__('OneHand_nt');
		return;
	}

	simulated function BeginState()
	{
		__NFUN_259__('OneHand_b');
		return;
	}
	stop;
}

state DeployBipod
{
	event AnimEnd(int iChannel)
	{
		// End:0x36
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  DeployBipod::AnimEnd"));
		}
		__NFUN_113__('Waiting');
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function BeginState()
	{
		// End:0x39
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  DeployBipod::BeginState"));
		}
		__NFUN_259__('Bipod_b');
		AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodDeploy);
		m_bBipodDeployed = true;
		AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
		AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_BipodNeutral;
		return;
	}

	function EndState()
	{
		// End:0x37
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  DeployBipod::EndState"));
		}
		return;
	}
	stop;
}

state CloseBipod
{
	simulated function EndState()
	{
		// End:0x36
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  CloseBipod::EndState"));
		}
		m_bBipodDeployed = false;
		AssociatedWeapon.m_bWeaponBipodDeployed = m_bBipodDeployed;
		AssociatedWeapon.m_WeaponNeutralAnim = AssociatedWeapon.m_Neutral;
		return;
	}

	event AnimEnd(int iChannel)
	{
		// End:0x35
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  CloseBipod::AnimEnd"));
		}
		__NFUN_113__('Waiting');
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function BeginState()
	{
		// End:0x38
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  CloseBipod::BeginState"));
		}
		__NFUN_259__('Bipod_e');
		AssociatedWeapon.__NFUN_259__(AssociatedWeapon.m_BipodClose);
		return;
	}
	stop;
}

state ZoomIn
{
	event AnimEnd(int iChannel)
	{
		// End:0x31
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__("HANDS - ", string(self)), " -  ZoomIn::AnimEnd"));
		}
		__NFUN_113__('Waiting');
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function BeginState()
	{
		// End:0x16
		if(__NFUN_263__('ZoomIn'))
		{
			__NFUN_259__('ZoomIn');			
		}
		else
		{
			AnimEnd(0);
		}
		return;
	}
	stop;
}

state ZoomOut
{
	event AnimEnd(int iChannel)
	{
		__NFUN_260__(AssociatedWeapon.m_WeaponNeutralAnim);
		__NFUN_113__('Waiting');
		R6AbstractWeapon(Owner).FirstPersonAnimOver();
		return;
	}

	simulated function BeginState()
	{
		// End:0x16
		if(__NFUN_263__('ZoomOut'))
		{
			__NFUN_259__('ZoomOut');			
		}
		else
		{
			AnimEnd(0);
		}
		return;
	}
	stop;
}

defaultproperties
{
	m_fAnimAcceleration=1.2000000
	m_HandFire="Fire"
	m_HandFireLast="FireLast"
	m_HandBipodFire="BipodFire"
	m_HandReloadEmpty="ReloadEmpty"
	m_HandBipodReloadEmpty="BipodReloadEmpty"
	m_WaitAnim1="Wait01"
	m_WaitAnim2="Wait02"
	m_WalkAnim="walk_c"
	bHidden=true
}
