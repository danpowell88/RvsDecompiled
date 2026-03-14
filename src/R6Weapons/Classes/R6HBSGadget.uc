//=============================================================================
// R6HBSGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HBSGadget extends R6Gadget
    native;

var bool m_bHeartBeatOn;  // Heart Beat sensor activation.
var Sound m_sndActivation;
var Sound m_sndDesactivation;

replication
{
	// Pos:0x000
	unreliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerToggleHeartBeatProperties;
}

// Export UR6HBSGadget::execToggleHeartBeatProperties(FFrame&, void* const)
native(2700) final function ToggleHeartBeatProperties(bool bTurnItOn);

simulated event bool IsGoggles()
{
	return true;
	return;
}

function ServerToggleHeartBeatProperties(bool bActiveHeartBeat)
{
	// End:0x3E
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("HBS - ServerToggleHeartBeatProperties =", string(bActiveHeartBeat)));
	}
	m_bHeartBeatOn = bActiveHeartBeat;
	return;
}

// ----------------------------------------
// All This function do nothing in the HBS
function Fire(float fValue)
{
	return;
}

function StopFire(optional bool bSoundOnly)
{
	return;
}

function AltFire(float fValue)
{
	return;
}

function StopAltFire()
{
	return;
}

// Display the HeartBeat in the map.
function DisplayHeartBeat(bool bActivateHeartBeat)
{
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	// End:0x26
	if(__NFUN_129__(pawnOwner.IsLocallyControlled()))
	{
		return;
	}
	// End:0x67
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - DisplayHeartBeat =", string(bActivateHeartBeat)), string(m_sndActivation)), string(m_sndDesactivation)));
	}
	m_bHeartBeatOn = bActivateHeartBeat;
	// End:0x93
	if(bActivateHeartBeat)
	{
		pawnOwner.__NFUN_264__(m_sndActivation, 3);		
	}
	else
	{
		pawnOwner.__NFUN_264__(m_sndDesactivation, 3);
	}
	ServerToggleHeartBeatProperties(bActivateHeartBeat);
	__NFUN_2700__(bActivateHeartBeat);
	return;
}

// When the player change the weapon we have to desactivate the HBS
simulated function RemoveFirstPersonWeapon()
{
	super(R6Weapons).RemoveFirstPersonWeapon();
	DisplayHeartBeat(false);
	// End:0x43
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("HBS - RemoveFirstPersonWeapon =", string(m_bHeartBeatOn)));
	}
	return;
}

// When we change player in the team we have to desactivate or reactivate the HBS
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
	super(R6Weapons).LoadFirstPersonWeapon(NetOwner, LocalPlayerController);
	// End:0x44
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("HBS - LoadFirstPersonWeapon =", string(m_bHeartBeatOn)));
	}
	DisplayHeartBeat(m_bHeartBeatOn);
	return true;
	return;
}

// Turn off the heart beat sensor
simulated function DisableWeaponOrGadget()
{
	DisplayHeartBeat(false);
	// End:0x3B
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("HBS - DisableWeaponOrGadget =", string(m_bHeartBeatOn)));
	}
	return;
}

function StartLoopingAnims()
{
	// End:0x2C
	if(__NFUN_119__(m_FPHands, none))
	{
		m_FPHands.SetDrawType(0);
		m_FPHands.__NFUN_113__('Waiting');
	}
	__NFUN_113__('None');
	return;
}

state PutWeaponDown
{
	simulated function BeginState()
	{
		// End:0x3A
		if(__NFUN_119__(m_FPHands, none))
		{
			m_FPHands.__NFUN_113__('PutWeaponDown');
			Pawn(Owner).Controller.m_bLockWeaponActions = true;
		}
		DisplayHeartBeat(false);
		// End:0x87
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - BeginState of PutWeaponDown for", string(self)), "="), string(m_bHeartBeatOn)));
		}
		return;
	}
	stop;
}

state BringWeaponUp
{
	simulated function BeginState()
	{
		super.BeginState();
		// End:0x34
		if(__NFUN_242__(R6Pawn(Owner).m_bActivateNightVision, true))
		{
			R6Pawn(Owner).ToggleNightVision();
		}
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}

	function FirstPersonAnimOver()
	{
		__NFUN_113__('None');
		DisplayHeartBeat(true);
		// End:0x5D
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - FirstPersonAnimOver of BringWeaponUp for", string(self)), "="), string(m_bHeartBeatOn)));
		}
		return;
	}
	stop;
}

state RaiseWeapon
{
	function FirstPersonAnimOver()
	{
		// End:0x3F
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("HBS - FirstPersonAnimOver in RaiseWeapon for ", string(self)));
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		__NFUN_113__('None');
		return;
	}

	simulated function BeginState()
	{
		// End:0x44
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - BeginState of RaiseWeapon for", string(self)), "="), string(m_bHeartBeatOn)));
		}
		super.BeginState();
		// End:0x78
		if(__NFUN_242__(R6Pawn(Owner).m_bActivateNightVision, true))
		{
			R6Pawn(Owner).ToggleNightVision();
		}
		return;
	}

	simulated function EndState()
	{
		// End:0x42
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - EndState of RaiseWeapon for", string(self)), "="), string(m_bHeartBeatOn)));
		}
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		DisplayHeartBeat(true);
		return;
	}
	stop;
}

state DiscardWeapon
{
	simulated function BeginState()
	{
		local Pawn aPawn;

		DisplayHeartBeat(false);
		// End:0x4D
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__(__NFUN_168__("HBS - BeginState of DiscardWeapon for", string(self)), "="), string(m_bHeartBeatOn)));
		}
		// End:0xC0
		if(__NFUN_119__(m_FPHands, none))
		{
			aPawn = Pawn(Owner);
			// End:0xB0
			if(__NFUN_119__(aPawn.Controller, none))
			{
				aPawn.Controller.m_bHideReticule = true;
				aPawn.Controller.m_bLockWeaponActions = true;
			}
			m_FPHands.__NFUN_113__('DiscardWeapon');
		}
		return;
	}

	simulated function EndState()
	{
		// End:0x34
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__(__NFUN_168__("IN:", string(self)), "::DiscardWeapon::EndState()"));
		}
		return;
	}
	stop;
}

state NormalFire
{
	simulated function BeginState()
	{
		__NFUN_113__('None');
		return;
	}
	stop;
}

defaultproperties
{
	m_sndActivation=Sound'Foley_HBSensor.Play_HBSensorAction1'
	m_sndDesactivation=Sound'Foley_HBSensor.Stop_HBSensorAction1'
	m_fMuzzleVelocity=1000.0000000
	m_bHiddenWhenNotInUse=true
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBS'
	m_pFPWeaponClass=Class'R61stWeapons.R61stHBS'
	m_EquipSnd=Sound'Foley_HBSensor.Play_HBS_Equip'
	m_UnEquipSnd=Sound'Foley_HBSensor.Play_HBS_Unequip'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandHBS_nt"
	m_PawnWaitAnimHigh="StandHBS_nt"
	m_PawnWaitAnimProne="ProneHBS_nt"
	m_PawnFiringAnim="StandHBS"
	m_PawnFiringAnimProne="ProneHBS"
	m_AttachPoint="TagHBHand"
	m_HUDTexturePos=(W=32.0000000,X=300.0000000,Y=352.0000000,Z=100.0000000)
	m_NameID="HBSGadget"
	bCollideWorld=true
	DrawScale=1.1000000
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensor'
}
