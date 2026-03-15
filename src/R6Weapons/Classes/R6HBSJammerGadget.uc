//=============================================================================
// R6HBSJammerGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6HBSJammerGadget extends R6Gadget;

var bool m_bHeartBeatJammerOn;  // Heart Beat Jammer ativated.

replication
{
	// Pos:0x000
	unreliable if((int(Role) < int(ROLE_Authority)))
		ServerToggleHeartBeatJammerProperties;
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

function ServerToggleHeartBeatJammerProperties(bool bGadgetOn)
{
	// End:0x46
	if(bShowLog)
	{
		Log(("HBJ - ServerToggleHeartBeatJammerProperties is " $ string(bGadgetOn)));
	}
	R6Pawn(Owner).m_bHBJammerOn = bGadgetOn;
	return;
}

// When the player change the weapon we have to desactivate the HBS
simulated function RemoveFirstPersonWeapon()
{
	super(R6Weapons).RemoveFirstPersonWeapon();
	TurnOnGadget(false);
	return;
}

// When we change player in the team we have to desactivate or reactivate the HBS
simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
	super(R6Weapons).LoadFirstPersonWeapon(NetOwner, LocalPlayerController);
	TurnOnGadget(m_bHeartBeatJammerOn);
	return true;
	return;
}

simulated function TurnOnGadget(bool bGadgetOn)
{
	// End:0x2D
	if(((R6Pawn(Owner) == none) || (!R6Pawn(Owner).IsLocallyControlled())))
	{
		return;
	}
	m_bHeartBeatJammerOn = bGadgetOn;
	ServerToggleHeartBeatJammerProperties(bGadgetOn);
	return;
}

// Turn off the heart beat sensor
simulated function DisableWeaponOrGadget()
{
	TurnOnGadget(false);
	return;
}

state PutWeaponDown
{
	simulated function BeginState()
	{
		// End:0x1B
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('PutWeaponDown');
		}
		TurnOnGadget(false);
		// End:0x6E
		if(bShowLog)
		{
			Log(((("HBSJammer - BeginState of PutWeaponDown for" @ string(self)) @ "=") @ string(m_bHeartBeatJammerOn)));
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		return;
	}
	stop;
}

state BringWeaponUp
{
	function FirstPersonAnimOver()
	{
		GotoState('None');
		TurnOnGadget(true);
		// End:0x63
		if(bShowLog)
		{
			Log(((("HBSJammer - FirstPersonAnimOver of BringWeaponUp for" @ string(self)) @ "=") @ string(m_bHeartBeatJammerOn)));
		}
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
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
			Log(("HBS - FirstPersonAnimOver in RaiseWeapon for " $ string(self)));
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		GotoState('None');
		return;
	}

	function BeginState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		m_FPHands.GotoState('RaiseWeapon');
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		TurnOnGadget(true);
		return;
	}
	stop;
}

state DiscardWeapon
{
	simulated function BeginState()
	{
		TurnOnGadget(false);
		// End:0x53
		if(bShowLog)
		{
			Log(((("HBSJammer - BeginState of DiscardWeapon for" @ string(self)) @ "=") @ string(m_bHeartBeatJammerOn)));
		}
		// End:0xAC
		if((m_FPHands != none))
		{
			Pawn(Owner).Controller.m_bLockWeaponActions = true;
			Pawn(Owner).Controller.m_bHideReticule = true;
			m_FPHands.GotoState('DiscardWeapon');
		}
		return;
	}
	stop;
}

state NormalFire
{
	simulated function BeginState()
	{
		GotoState('None');
		return;
	}
	stop;
}

defaultproperties
{
	m_fMuzzleVelocity=1000.0000000
	m_szReticuleClass="DOT"
	m_bHiddenWhenNotInUse=true
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripHBSJ'
	m_pFPWeaponClass=Class'R61stWeapons.R61stHBSJ'
	m_EquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Equip'
	m_UnEquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Unequip'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandHandGunLow_nt"
	m_PawnWaitAnimHigh="StandHandGunHigh_nt"
	m_PawnWaitAnimProne="ProneHandGun_nt"
	m_AttachPoint="TagHBSJammer"
	m_HUDTexturePos=(W=32.0000000,X=400.0000000,Y=384.0000000,Z=100.0000000)
	m_NameID="HBSJammerGadget"
	bCollideWorld=true
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensor_Jamer'
}
