//=============================================================================
// R6DemolitionsGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6DemolitionsGadget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/06 * Created by Rima Brek
//=============================================================================
class R6DemolitionsGadget extends R6Gadget
    abstract
    native;

var bool m_bDetonated;
var bool m_bChargeInPosition;
var bool m_bCanPlaceCharge;
var bool m_bInstallingCharge;
var bool m_bCancelChargeInstallation;
var bool m_bRaiseWeapon;
var bool m_bHide;
var bool m_bDetonator;
var R6Reticule m_ReticuleConfirm;
var R6Reticule m_ReticuleBlock;
var R6Reticule m_ReticuleDetonator;
var StaticMesh m_DetonatorStaticMesh;  // 1st person
var Texture m_DetonatorTexture;
var StaticMesh m_ChargeStaticMesh;  // 3rd person
var R6Grenade BulletActor;
var name m_ChargeAttachPoint;
var name m_DetonatorAttachPoint;
var Class<Emitter> m_pExplosionParticles;
var Vector m_vLocation;
// NEW IN 1.60
var string m_szReticuleBlockClass;
// NEW IN 1.60
var string m_szDetonatorReticuleClass;

replication
{
	// Pos:0x00D
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientMyUnitIsDestroyed;

	// Pos:0x01A
	unreliable if((int(Role) < int(ROLE_Authority)))
		ServerCancelChargeInstallation, ServerGotoSetExplosive;

	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		BulletActor, m_bDetonator, 
		m_bHide;
}

event NbBulletChange()
{
	return;
}

function MyUnitIsDestroyed()
{
	// End:0x18
	if((int(m_iNbBulletsInWeapon) == 0))
	{
		m_bHide = true;		
	}
	else
	{
		m_bHide = false;
	}
	m_bDetonator = false;
	ClientMyUnitIsDestroyed();
	return;
}

simulated function ClientMyUnitIsDestroyed()
{
	m_bDetonated = false;
	m_bRaiseWeapon = false;
	m_bChargeInPosition = false;
	BulletActor.m_bDestroyedByImpact = true;
	// End:0x86
	if(IsInState('ChargeArmed'))
	{
		R6Pawn(Owner).m_bIsFiringState = false;
		// End:0x65
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('DiscardWeapon');
		}
		// End:0x7C
		if((int(m_iNbBulletsInWeapon) <= 0))
		{
			GotoState('NoChargesLeft');			
		}
		else
		{
			GotoState('GetNextCharge');
		}		
	}
	else
	{
		// End:0xAA
		if((int(m_iNbBulletsInWeapon) > 0))
		{
			// End:0xAA
			if((m_FPHands != none))
			{
				SetAmmoStaticMesh();
				SwitchToChargeHandAnimations();
			}
		}
	}
	return;
}

simulated function UpdateHands()
{
	// End:0x32
	if((m_bChargeInPosition == true))
	{
		m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
		SwitchToDetonatorHandAnimations();		
	}
	else
	{
		SetAmmoStaticMesh();
		SwitchToChargeHandAnimations();
	}
	return;
}

event PostBeginPlay()
{
	super(R6Weapons).PostBeginPlay();
	SetGadgetStaticMesh();
	return;
}

simulated function PostNetBeginPlay()
{
	super(Actor).PostNetBeginPlay();
	SetGadgetStaticMesh();
	return;
}

simulated function ServerPlaceCharge(Vector vLocation)
{
	local Rotator rDesiredRotation;

	// End:0x0F
	if((int(m_iNbBulletsInWeapon) == 0))
	{
		return;
	}
	(m_iNbBulletsInWeapon--);
	m_bDetonator = true;
	rDesiredRotation = Pawn(Owner).GetViewRotation();
	rDesiredRotation.Pitch = 0;
	(rDesiredRotation.Yaw += 32768);
	BulletActor = R6Grenade(Spawn(m_pBulletClass, self));
	// End:0xE1
	if(bShowLog)
	{
		Log(((((("R6DemolitionsGadget :: ServerPlaceCharge() " $ string(BulletActor)) $ " rDesiredRotation=") $ string(rDesiredRotation)) $ " vLocation=") $ string(vLocation)));
	}
	BulletActor.SetLocation((vLocation + vect(0.0000000, 0.0000000, 10.0000000)));
	BulletActor.SetRotation(rDesiredRotation);
	BulletActor.m_Weapon = self;
	BulletActor.Instigator = Pawn(Owner);
	BulletActor.SetSpeed(0.0000000);
	m_AttachPoint = m_DetonatorAttachPoint;
	SetStaticMesh(default.StaticMesh);
	Pawn(Owner).AttachToBone(self, m_AttachPoint);
	return;
}

function ServerPlaceChargeAnimation()
{
	return;
}

function PlaceChargeAnimation()
{
	return;
}

function Activate()
{
	return;
}

function SetAmmoStaticMesh()
{
	return;
}

function ServerDetonate()
{
	// End:0x15
	if((int(m_iNbBulletsInWeapon) == 0))
	{
		m_bHide = true;
	}
	m_bDetonator = false;
	// End:0x4A
	if(bShowLog)
	{
		Log((" Explode() BulletActor=" $ string(BulletActor)));
	}
	BulletActor.Explode();
	BulletActor.Destroy();
	return;
}

function Fire(float fValue)
{
	// End:0x63
	if(bShowLog)
	{
		Log(((("(R6DemolitionsGadget) WEAPON - R6Weapons.NoState::Fire(", string(fValue)) $ ") for weapon " $ ???) $ string(self)));
	}
	// End:0x88
	if((Pawn(Owner).Controller.m_bLockWeaponActions == true))
	{
		return;
	}
	m_FPHands.StopTimer();
	// End:0xB2
	if(m_bChargeInPosition)
	{
		m_bDetonated = false;
		GotoState('ChargeArmed');		
	}
	else
	{
		GotoState('ChargeReady');
	}
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

simulated function bool LoadFirstPersonWeapon(optional Pawn NetOwner, optional Controller LocalPlayerController)
{
	super(R6Weapons).LoadFirstPersonWeapon(NetOwner, LocalPlayerController);
	// End:0x3F
	if((m_bChargeInPosition == true))
	{
		SwitchToDetonatorHandAnimations();
		m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
	}
	return true;
	return;
}

//When changing charter, this is to start playing the wait animations.
function StartLoopingAnims()
{
	// End:0x2C
	if((m_FPHands != none))
	{
		m_FPHands.SetDrawType(2);
		m_FPHands.GotoState('Waiting');
	}
	return;
}

function SwitchToDetonatorHandAnimations()
{
	m_FPHands.UnLinkSkelAnim();
	m_FPHands.LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripDetonatorA');
	return;
}

function SwitchToChargeHandAnimations()
{
	m_FPHands.UnLinkSkelAnim();
	m_FPHands.LinkSkelAnim(MeshAnimation'R61stHands_UKX.R61stHandsGripBreachA');
	return;
}

//Delete the first person weapon.  To keep only one in memory
simulated function RemoveFirstPersonWeapon()
{
	// End:0x17
	if((m_FPHands != none))
	{
		m_FPHands.Destroy();
	}
	m_FPHands = none;
	// End:0x44
	if((m_FPWeapon != none))
	{
		m_FPWeapon.DestroySM();
		m_FPWeapon.Destroy();
	}
	m_FPWeapon = none;
	// End:0x6C
	if((m_MagazineGadget != none))
	{
		m_MagazineGadget.DestroyFPGadget();
		m_MagazineGadget = none;
	}
	DestroyReticules();
	return;
}

function HideReticule()
{
	m_ReticuleInstance = none;
	return;
}

function DestroyReticules()
{
	local R6Reticule aReticule;

	aReticule = m_ReticuleConfirm;
	m_ReticuleConfirm = none;
	// End:0x29
	if((aReticule != none))
	{
		aReticule.Destroy();
	}
	aReticule = m_ReticuleBlock;
	m_ReticuleBlock = none;
	// End:0x52
	if((aReticule != none))
	{
		aReticule.Destroy();
	}
	aReticule = m_ReticuleDetonator;
	m_ReticuleDetonator = none;
	// End:0x7B
	if((aReticule != none))
	{
		aReticule.Destroy();
	}
	m_ReticuleInstance = none;
	return;
}

simulated function R6SetReticule(optional Controller LocalPlayerController)
{
	local R6PlayerController PlayerCtrl;
	local Class<Actor> ReticuleToSpawn;

	// End:0x21E
	if(Owner.IsA('R6Rainbow'))
	{
		// End:0x21E
		if(((m_szReticuleClass != "") && (m_ReticuleInstance == none)))
		{
			ReticuleToSpawn = Class'Engine.Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleClass);
			m_ReticuleConfirm = R6Reticule(Spawn(ReticuleToSpawn));
			ReticuleToSpawn = Class'Engine.Actor'.static.GetModMgr().GetCurrentReticule(m_szReticuleBlockClass);
			m_ReticuleBlock = R6Reticule(Spawn(ReticuleToSpawn));
			ReticuleToSpawn = Class'Engine.Actor'.static.GetModMgr().GetCurrentReticule(m_szDetonatorReticuleClass);
			m_ReticuleDetonator = R6Reticule(Spawn(ReticuleToSpawn));
			m_ReticuleInstance = m_ReticuleBlock;
			m_ReticuleConfirm.SetOwner(Owner);
			m_ReticuleBlock.SetOwner(Owner);
			m_ReticuleDetonator.SetOwner(Owner);
			// End:0x17A
			if((int(Level.NetMode) == int(NM_Standalone)))
			{
				m_ReticuleConfirm.m_bShowNames = GetGameOptions().HUDShowPlayersName;
				m_ReticuleBlock.m_bShowNames = GetGameOptions().HUDShowPlayersName;
				m_ReticuleDetonator.m_bShowNames = GetGameOptions().HUDShowPlayersName;				
			}
			else
			{
				PlayerCtrl = R6PlayerController(LocalPlayerController);
				// End:0x1B3
				if((PlayerCtrl == none))
				{
					PlayerCtrl = R6PlayerController(R6Pawn(Owner).Controller);
				}
				m_ReticuleConfirm.m_bShowNames = R6GameReplicationInfo(PlayerCtrl.GameReplicationInfo).m_bShowNames;
				m_ReticuleBlock.m_bShowNames = m_ReticuleConfirm.m_bShowNames;
				m_ReticuleDetonator.m_bShowNames = m_ReticuleConfirm.m_bShowNames;
			}
		}
	}
	return;
}

// this must be redefined in each demolitions gadget class
simulated function bool CanPlaceCharge()
{
	local Vector vFeetLocation, vLookLocation;
	local R6Pawn pawnOwner;
	local R6PlayerController PlayerCtrl;

	pawnOwner = R6Pawn(Owner);
	PlayerCtrl = R6PlayerController(pawnOwner.Controller);
	// End:0x4C
	if(((Owner == none) || (pawnOwner.Controller == none)))
	{
		return false;
	}
	// End:0x60
	if(pawnOwner.m_bPostureTransition)
	{
		return false;
	}
	// End:0x98
	if((PlayerCtrl != none))
	{
		vLookLocation = PlayerCtrl.m_vDefaultLocation;
		// End:0x98
		if((vLookLocation == vect(0.0000000, 0.0000000, 0.0000000)))
		{
			return false;
		}
	}
	// End:0xD1
	if(((!pawnOwner.IsStationary()) || (pawnOwner.m_fPeeking != pawnOwner.1000.0000000)))
	{
		return false;
	}
	vFeetLocation = Owner.Location;
	(vFeetLocation.Z -= pawnOwner.CollisionHeight);
	// End:0x118
	if((VSize((vLookLocation - vFeetLocation)) < float(75)))
	{
		return true;
	}
	return false;
	return;
}

function ServerGotoSetExplosive()
{
	R6Pawn(Owner).PlayWeaponSound(3);
	R6PlayerController(Pawn(Owner).Controller).GotoState('PlayerSetExplosive');
	return;
}

function ServerCancelChargeInstallation()
{
	// End:0x54
	if(bShowLog)
	{
		Log(("Server Cancel Charge Installation : " $ string(R6PlayerController(Pawn(Owner).Controller).GetStateName())));
	}
	R6Pawn(Owner).PlayWeaponSound(4);
	// End:0x119
	if(R6Pawn(Owner).IsAlive())
	{
		R6Pawn(Owner).m_bToggleServerCancelPlacingCharge = (!R6Pawn(Owner).m_bToggleServerCancelPlacingCharge);
		// End:0x119
		if((!((Class'Engine.Actor'.static.GetModMgr().IsMissionPack() && Owner.IsA('R6Rainbow')) && R6Rainbow(Owner).m_bIsSurrended)))
		{
			R6PlayerController(Pawn(Owner).Controller).GotoState('PlayerWalking');
		}
	}
	return;
}

simulated function CancelChargeInstallation()
{
	// End:0x27
	if(bShowLog)
	{
		Log("Cancel Charge Installation");
	}
	SetTimer(0.0000000, false);
	m_bCancelChargeInstallation = true;
	m_bInstallingCharge = false;
	// End:0xD4
	if(R6Pawn(Owner).IsAlive())
	{
		// End:0xC4
		if((!((Class'Engine.Actor'.static.GetModMgr().IsMissionPack() && Owner.IsA('R6Rainbow')) && R6Rainbow(Owner).m_bIsSurrended)))
		{
			R6PlayerController(Pawn(Owner).Controller).GotoState('PlayerWalking');
		}
		m_FPHands.GotoState('RaiseWeapon');
	}
	return;
}

simulated function Tick(float fDeltaTime)
{
	// End:0x28
	if(((Owner == none) || (self != R6Pawn(Owner).EngineWeapon)))
	{
		return;
	}
	super(Actor).Tick(fDeltaTime);
	// End:0x49
	if((m_bChargeInPosition || m_bDetonated))
	{
		return;
	}
	// End:0xD1
	if((m_bInstallingCharge && (int(Pawn(Owner).Controller.bFire) == 0)))
	{
		// End:0xCB
		if(((int(Level.NetMode) == int(NM_Client)) || ((int(Level.NetMode) == int(NM_ListenServer)) && R6Pawn(Owner).IsLocallyControlled())))
		{
			ServerCancelChargeInstallation();
		}
		CancelChargeInstallation();
	}
	// End:0xDC
	if(m_bInstallingCharge)
	{
		return;
	}
	m_bCanPlaceCharge = CanPlaceCharge();
	// End:0x100
	if(m_bCanPlaceCharge)
	{
		m_ReticuleInstance = m_ReticuleConfirm;		
	}
	else
	{
		m_ReticuleInstance = m_ReticuleBlock;
	}
	return;
}

simulated event HideAttachment()
{
	// End:0x41
	if(bShowLog)
	{
		Log(((("***** HideAttachment for" @ string(self)) @ "****** : ") $ string(m_bHide)));
	}
	// End:0x58
	if((m_bHide == true))
	{
		SetDrawType(0);		
	}
	else
	{
		SetDrawType(8);
		bHidden = false;
	}
	return;
}

simulated event SetGadgetStaticMesh()
{
	// End:0x46
	if(bShowLog)
	{
		Log(((("***** SetGadgetStaticMesh for" @ string(self)) @ "****** : ") $ string(m_bDetonator)));
	}
	// End:0x82
	if(m_bDetonator)
	{
		m_AttachPoint = m_DetonatorAttachPoint;
		SetStaticMesh(default.StaticMesh);
		Pawn(Owner).AttachToBone(self, m_AttachPoint);		
	}
	else
	{
		m_AttachPoint = m_ChargeAttachPoint;
		SetStaticMesh(m_ChargeStaticMesh);
		Pawn(Owner).AttachToBone(self, m_AttachPoint);
	}
	return;
}

function bool CanSwitchToWeapon()
{
	// End:0x51
	if(bShowLog)
	{
		Log(((((("***** CanSwitchToWeapon for" @ string(self)) @ string(m_bDetonator)) @ string(m_iNbBulletsInWeapon)) @ string(GetStateName())) @ "******"));
	}
	// End:0x7D
	if(((m_bDetonator || (int(m_iNbBulletsInWeapon) > 0)) && (!IsInState('ChargeReady'))))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

state RaiseWeapon
{
	function Fire(float Value)
	{
		return;
	}

	function AltFire(float Value)
	{
		return;
	}

	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		return;
	}

	simulated function FirstPersonAnimOver()
	{
		// End:0x37
		if(bShowLog)
		{
			Log("FirstPersonAnimOver()  R6DemolitionsGadget");
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		// End:0x74
		if(m_bChargeInPosition)
		{
			m_bDetonated = false;
			GotoState('ChargeArmed');			
		}
		else
		{
			GotoState('ChargeReady');
		}
		return;
	}

	simulated function BeginState()
	{
		// End:0x39
		if(bShowLog)
		{
			Log(("WEAPON - BeginState of RaiseWeapon for " $ string(self)));
		}
		Pawn(Owner).Controller.m_bLockWeaponActions = true;
		// End:0x7B
		if((m_FPHands != none))
		{
			m_bRaiseWeapon = true;
			m_FPHands.GotoState('RaiseWeapon');
		}
		return;
	}
	stop;
}

state ChargeReady
{
	function BeginState()
	{
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		m_bRaiseWeapon = false;
		// End:0x56
		if(bShowLog)
		{
			Log((string(self) $ " entered state ChargeReady..."));
		}
		m_AttachPoint = m_ChargeAttachPoint;
		SetStaticMesh(m_ChargeStaticMesh);
		Pawn(Owner).AttachToBone(self, m_AttachPoint);
		m_bDetonated = false;
		// End:0xCB
		if(((int(Pawn(Owner).Controller.bFire) == 1) && (CanPlaceCharge() == true)))
		{
			Fire(0.0000000);
		}
		return;
	}

	function EndState()
	{
		// End:0x2E
		if(bShowLog)
		{
			Log((string(self) $ " exited state ChargeReady..."));
		}
		SetTimer(0.0000000, false);
		return;
	}

	// set timer for placing charge - check demolitions skill...
	function Timer()
	{
		local R6Pawn pawnOwner;
		local R6PlayerController PlayerCtrl;

		pawnOwner = R6Pawn(Owner);
		PlayerCtrl = R6PlayerController(pawnOwner.Controller);
		// End:0x60
		if((((!pawnOwner.m_bIsPlayer) || pawnOwner.m_bPostureTransition) || (!m_bInstallingCharge)))
		{
			return;
		}
		// End:0xC5
		if(bShowLog)
		{
			Log(((((string(self) $ " state ChargeReady : Timer() has expired ") $ string(PlayerCtrl.m_bPlacedExplosive)) $ " : ") $ string(PlayerCtrl.GetStateName())));
		}
		// End:0x11E
		if(PlayerCtrl.m_bPlacedExplosive)
		{
			ServerPlaceCharge(m_vLocation);
			m_bChargeInPosition = true;
			m_bInstallingCharge = false;
			m_bRaiseWeapon = false;
			m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
			GotoState('ChargeArmed');
		}
		return;
	}

	function Fire(float fValue)
	{
		local R6PlayerController PlayerCtrl;

		PlayerCtrl = R6PlayerController(R6Pawn(Owner).Controller);
		// End:0x4D
		if(((m_bChargeInPosition || (!m_bCanPlaceCharge)) || (PlayerCtrl.m_bLockWeaponActions == true)))
		{
			return;
		}
		PlayerCtrl.DoZoom(true);
		PlayerCtrl.m_bLockWeaponActions = true;
		m_bInstallingCharge = true;
		HideReticule();
		// End:0x9B
		if((int(Level.NetMode) == int(NM_Client)))
		{
			ServerGotoSetExplosive();
		}
		PlayerCtrl.GotoState('PlayerSetExplosive');
		PlaceChargeAnimation();
		m_vLocation = PlayerCtrl.m_vDefaultLocation;
		// End:0x124
		if(bShowLog)
		{
			Log(((string(self) $ " state ChargeReady : Remote Charge has been placed at m_vLocation = ") $ string(m_vLocation)));
		}
		// End:0x13F
		if((m_FPHands != none))
		{
			m_FPHands.GotoState('DiscardWeapon');
		}
		SetTimer(0.1000000, true);
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x3C
		if((m_bCancelChargeInstallation == true))
		{
			m_bCancelChargeInstallation = false;
			Pawn(Owner).Controller.m_bLockWeaponActions = false;
			SetTimer(0.0000000, false);
		}
		return;
	}
	stop;
}

state ChargeArmed
{
	function BeginState()
	{
		// End:0x3E
		if(bShowLog)
		{
			Log(((string(self) $ " state ChargeArmed : beginState() ") $ string(m_bRaiseWeapon)));
		}
		m_ReticuleInstance = m_ReticuleDetonator;
		Pawn(Owner).Controller.m_bHideReticule = false;
		// End:0xAA
		if((m_FPHands != none))
		{
			SwitchToDetonatorHandAnimations();
			// End:0x9F
			if((!m_bRaiseWeapon))
			{
				m_bRaiseWeapon = true;
				m_FPHands.GotoState('RaiseWeapon');				
			}
			else
			{
				m_bRaiseWeapon = false;
			}			
		}
		else
		{
			m_bRaiseWeapon = false;
		}
		return;
	}

	function EndState()
	{
		// End:0x4D
		if(bShowLog)
		{
			Log(((((string(self) $ " state ChargeArmed : endState() ") $ string(m_bDetonated)) $ " : ") $ string(m_bChargeInPosition)));
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		// End:0x2E
		if(bShowLog)
		{
			Log(("First person anim over " $ string(m_bRaiseWeapon)));
		}
		// End:0x63
		if(m_bRaiseWeapon)
		{
			Pawn(Owner).Controller.m_bLockWeaponActions = false;
			m_bRaiseWeapon = false;
			return;			
		}
		else
		{
			// End:0x100
			if(m_bDetonated)
			{
				// End:0xB7
				if(bShowLog)
				{
					Log(((string(self) $ " state ChargeArmed : DETONATE CHARGE!!! # left :") $ string(m_iNbBulletsInWeapon)));
				}
				ServerDetonate();
				m_bChargeInPosition = false;
				SetStaticMesh(none);
				R6Pawn(Owner).m_bIsFiringState = false;
				// End:0xF9
				if((int(m_iNbBulletsInWeapon) <= 0))
				{
					GotoState('NoChargesLeft');					
				}
				else
				{
					GotoState('GetNextCharge');
				}
			}
		}
		return;
	}

	function Fire(float fValue)
	{
		// End:0xDA
		if((!m_bRaiseWeapon))
		{
			// End:0x89
			if((!m_bDetonated))
			{
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
				R6Pawn(Owner).m_bIsFiringState = true;
				m_bDetonated = true;
				// End:0x80
				if((m_FPHands != none))
				{
					m_FPHands.GotoState('FiringWeapon');
					m_FPHands.FireSingleShot();					
				}
				else
				{
					FirstPersonAnimOver();
				}				
			}
			else
			{
				// End:0xDA
				if(bShowLog)
				{
					Log((string(self) $ " state ChargeArmed : DO NOTHING));
				}
			}
		}
		return;
	}
	stop;
}

state GetNextCharge
{
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

	function BeginState()
	{
		// End:0x36
		if(bShowLog)
		{
			Log((string(self) $ " state GetNextCharge : beginState() "));
		}
		return;
	}

	function FirstPersonAnimOver()
	{
		m_AttachPoint = m_ChargeAttachPoint;
		SetAmmoStaticMesh();
		// End:0x32
		if((m_FPHands != none))
		{
			SwitchToChargeHandAnimations();
			m_FPHands.GotoState('RaiseWeapon');
		}
		GotoState('ChargeReady');
		return;
	}
	stop;
}

state NoChargesLeft
{
	function BeginState()
	{
		// End:0x38
		if(bShowLog)
		{
			Log((string(self) $ " state NoChargesLeft : BeginState()..."));
		}
		Pawn(Owner).Controller.m_bHideReticule = true;
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

	function FirstPersonAnimOver()
	{
		local R6PlayerController PController;

		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		PController = R6PlayerController(Pawn(Owner).Controller);
		// End:0x84
		if((PController != none))
		{
			// End:0x75
			if((R6Pawn(Owner).m_WeaponsCarried[0] != none))
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

state DiscardWeapon
{
	function Fire(float Value)
	{
		return;
	}

	function AltFire(float Value)
	{
		return;
	}

	function StopFire(optional bool bSoundOnly)
	{
		return;
	}

	function StopAltFire()
	{
		return;
	}

	function PlayReloading()
	{
		return;
	}

	simulated function BeginState()
	{
		m_bRaiseWeapon = false;
		// End:0xE1
		if((m_FPHands != none))
		{
			// End:0x59
			if(bShowLog)
			{
				Log((((("***** DiscardWeapon for" @ string(self)) @ string(m_bDetonator)) @ string(m_iNbBulletsInWeapon)) @ "******"));
			}
			// End:0xB0
			if((Pawn(Owner).Controller != none))
			{
				Pawn(Owner).Controller.m_bHideReticule = true;
				Pawn(Owner).Controller.m_bLockWeaponActions = true;
			}
			// End:0xDB
			if((m_bDetonator || (int(m_iNbBulletsInWeapon) > 0)))
			{
				m_FPHands.GotoState('DiscardWeapon');				
			}
			else
			{
				FirstPersonAnimOver();
			}
		}
		return;
	}
	stop;
}

state BringWeaponUp
{
	simulated function BeginState()
	{
		// End:0x47
		if(bShowLog)
		{
			Log(((("WEAPON - " $ string(self)) $ " - BeginState of BringWeaponUp for ") $ string(self)));
		}
		// End:0x87
		if((m_FPHands != none))
		{
			// End:0x74
			if(((int(m_iNbBulletsInWeapon) == 0) && m_bDetonated))
			{
				GotoState('NoChargesLeft');				
			}
			else
			{
				m_FPHands.GotoState('BringWeaponUp');
			}			
		}
		else
		{
			FirstPersonAnimOver();
		}
		return;
	}

	simulated function FirstPersonAnimOver()
	{
		// End:0x37
		if(bShowLog)
		{
			Log("FirstPersonAnimOver()  R6DemolitionsGadget");
		}
		R6PlayerController(Pawn(Owner).Controller).ServerWeaponUpAnimDone();
		// End:0x74
		if(m_bChargeInPosition)
		{
			m_bDetonated = false;
			GotoState('ChargeArmed');			
		}
		else
		{
			GotoState('ChargeReady');
		}
		return;
	}

	simulated function EndState()
	{
		Pawn(Owner).Controller.m_bHideReticule = false;
		Pawn(Owner).Controller.m_bLockWeaponActions = false;
		m_bRaiseWeapon = true;
		return;
	}
	stop;
}

defaultproperties
{
	m_DetonatorAttachPoint="TagDetonatorHand"
	m_szReticuleBlockClass="CROSS"
	m_szDetonatorReticuleClass="DOT"
	m_iClipCapacity=2
	m_szReticuleClass="GRENADE"
	m_bHiddenWhenNotInUse=true
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripC4'
	m_bDisplayHudInfo=true
	m_EquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Equip'
	m_UnEquipSnd=Sound'Foley_HBSJammer.Play_HBSJ_Unequip'
	m_NameID="DiffuseKit"
	bCollideWorld=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_pReticuleBlockClass
// REMOVED IN 1.60: var m_pDetonatorReticuleClass
// REMOVED IN 1.60: function ShowInfo
