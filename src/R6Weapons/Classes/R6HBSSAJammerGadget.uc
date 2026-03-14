//=============================================================================
// R6HBSSAJammerGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  [R6HBSSAJammerGadget.uc] Heart Beat Sensor Stant Alone Jammer Gadget
//=============================================================================
class R6HBSSAJammerGadget extends R6DemolitionsGadget;

function Fire(float fValue)
{
	// End:0x2A
	if(__NFUN_242__(Pawn(Owner).Controller.m_bLockWeaponActions, false))
	{
		__NFUN_113__('ArmingCharge');
	}
	return;
}

simulated function PlaceChargeAnimation()
{
	ServerPlaceChargeAnimation();
	return;
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(Owner).SetNextPendingAction(17);
	return;
}

function SetAmmoStaticMesh()
{
	m_FPWeapon.m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stHBSSAJ');
	return;
}

simulated function ServerPlaceCharge(Vector vLocation)
{
	local Rotator rDesiredRotation;
	local R6SAHeartBeatJammer aSAHeartBeatJammer;

	// End:0x0F
	if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
	{
		return;
	}
	__NFUN_140__(m_iNbBulletsInWeapon);
	// End:0x2B
	if(__NFUN_154__(int(m_iNbBulletsInWeapon), 0))
	{
		m_bHide = true;
	}
	rDesiredRotation = Pawn(Owner).GetViewRotation();
	// End:0xAE
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("aSAHeartBeatJammer :: ServerPlaceCharge() rDesiredRotation=", string(rDesiredRotation)), " vLocation="), string(vLocation)));
	}
	rDesiredRotation.Pitch = 0;
	__NFUN_161__(rDesiredRotation.Yaw, 32768);
	aSAHeartBeatJammer = __NFUN_278__(Class'R6Engine.R6SAHeartBeatJammer');
	aSAHeartBeatJammer.Instigator = none;
	aSAHeartBeatJammer.__NFUN_267__(__NFUN_215__(vLocation, vect(0.0000000, 0.0000000, 10.0000000)));
	aSAHeartBeatJammer.__NFUN_299__(rDesiredRotation);
	aSAHeartBeatJammer.SetSpeed(0.0000000);
	return;
}

simulated event HideAttachment()
{
	__NFUN_113__('NoChargesLeft');
	super.HideAttachment();
	return;
}

event NbBulletChange()
{
	// End:0x17
	if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
	{
		__NFUN_113__('GetNextCharge');		
	}
	else
	{
		__NFUN_113__('NoChargesLeft');
	}
	return;
}

function bool CanSwitchToWeapon()
{
	// End:0x12
	if(__NFUN_151__(int(m_iNbBulletsInWeapon), 0))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

state ArmingCharge
{
	function BeginState()
	{
		// End:0x30
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(string(self), " entered state ArmingCharge..."));
		}
		SetStaticMesh(m_ChargeStaticMesh);
		Pawn(Owner).AttachToBone(self, m_AttachPoint);
		m_bDetonated = false;
		// End:0x8C
		if(__NFUN_154__(int(Pawn(Owner).Controller.bFire), 1))
		{
			Fire(0.0000000);
		}
		return;
	}

	function Timer()
	{
		local R6Pawn pawnOwner;

		pawnOwner = R6Pawn(Owner);
		// End:0x47
		if(__NFUN_132__(__NFUN_132__(__NFUN_129__(pawnOwner.m_bIsPlayer), pawnOwner.m_bPostureTransition), __NFUN_129__(m_bInstallingCharge)))
		{
			return;
		}
		// End:0xA9
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(string(self), " state ArmingCharge : Timer() has expired "), string(R6PlayerController(Pawn(Owner).Controller).m_bPlacedExplosive)));
		}
		// End:0x13B
		if(R6PlayerController(Pawn(Owner).Controller).m_bPlacedExplosive)
		{
			ServerPlaceCharge(m_vLocation);
			m_bChargeInPosition = true;
			m_bInstallingCharge = false;
			// End:0x13B
			if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)), __NFUN_154__(int(Level.NetMode), int(NM_ListenServer))))
			{
				// End:0x134
				if(__NFUN_155__(int(m_iNbBulletsInWeapon), 0))
				{
					__NFUN_113__('GetNextCharge');					
				}
				else
				{
					__NFUN_113__('NoChargesLeft');
				}
			}
		}
		return;
	}

	function Fire(float fValue)
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(R6Pawn(Owner).Controller);
		// End:0x4D
		if(__NFUN_132__(__NFUN_132__(m_bChargeInPosition, __NFUN_129__(m_bCanPlaceCharge)), __NFUN_242__(PlayerCtrl.m_bLockWeaponActions, true)))
		{
			return;
		}
		// End:0x6B
		if(__NFUN_119__(m_SingleFireStereoSnd, none))
		{
			Owner.__NFUN_264__(m_SingleFireStereoSnd, 2);
		}
		PlayerCtrl.m_bLockWeaponActions = true;
		HideReticule();
		PlayerCtrl.__NFUN_113__('PlayerSetExplosive');
		PlaceChargeAnimation();
		m_vLocation = PlayerCtrl.m_vDefaultLocation;
		__NFUN_280__(0.1000000, true);
		m_bInstallingCharge = true;
		// End:0xD8
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('DiscardWeapon');
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x33
		if(__NFUN_242__(m_bCancelChargeInstallation, true))
		{
			m_bCancelChargeInstallation = false;
			Pawn(Owner).Controller.m_bLockWeaponActions = false;
		}
		return;
	}
	stop;
}

state GetNextCharge
{
	function BeginState()
	{
		// End:0x3C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(string(self), " state HBSAJ GetNextCharge : beginState() "));
		}
		m_bChargeInPosition = false;
		m_bRaiseWeapon = false;
		__NFUN_280__(0.1000000, true);
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		// End:0x92
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('RaiseWeapon');			
		}
		else
		{
			FirstPersonAnimOver();
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		m_bRaiseWeapon = true;
		return;
	}

	function Timer()
	{
		// End:0x0D
		if(__NFUN_129__(m_bRaiseWeapon))
		{
			return;
		}
		// End:0x33
		if(__NFUN_154__(int(Pawn(Owner).Controller.bFire), 1))
		{
			return;
		}
		__NFUN_113__('ArmingCharge');
		return;
	}
	stop;
}

state RaiseWeapon
{
	function FirstPersonAnimOver()
	{
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		__NFUN_113__('ArmingCharge');
		return;
	}

	simulated function BeginState()
	{
		// End:0x39
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("WEAPON - BeginState of RaiseWeapon for ", string(self)));
		}
		// End:0x71
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('RaiseWeapon');
			m_FPWeapon.m_smGun.bHidden = false;			
		}
		else
		{
			FirstPersonAnimOver();
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}
	stop;
}

state NoChargesLeft
{
	function BeginState()
	{
		local R6PlayerController PController;

		// End:0x44
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(string(self), " HBSSAJammer state NoChargesLeft : BeginState()..."));
		}
		Pawn(Owner).Controller.m_bHideReticule = true;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		PController = R6PlayerController(Pawn(Owner).Controller);
		// End:0xE7
		if(__NFUN_119__(PController, none))
		{
			// End:0xD8
			if(__NFUN_119__(R6Pawn(Owner).m_WeaponsCarried[0], none))
			{
				PController.PrimaryWeapon();				
			}
			else
			{
				PController.SecondaryWeapon();
			}
		}
		return;
	}
	stop;
}

defaultproperties
{
	m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensorSA_Jamer'
	m_iClipCapacity=1
	m_fMuzzleVelocity=1000.0000000
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBSSAJ'
	m_pFPWeaponClass=Class'R61stWeapons.R61stHBSSAJ'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandGrenade_nt"
	m_PawnWaitAnimHigh="StandGrenade_nt"
	m_PawnWaitAnimProne="ProneGrenade_nt"
	m_PawnFiringAnim="CrouchClaymore"
	m_PawnFiringAnimProne="ProneClaymore"
	m_AttachPoint="TagSAHBSensorJammer"
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=384.0000000,Z=100.0000000)
	m_NameID="HBSSAJammerGadget"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensorSA_Jamer'
}
