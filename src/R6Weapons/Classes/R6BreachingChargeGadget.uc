//=============================================================================
// R6BreachingChargeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6BreachingChargeGadget : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/04 * Created by Rima Brek
//=============================================================================
class R6BreachingChargeGadget extends R6DemolitionsGadget;

var R6IORotatingDoor m_IORDoor;

replication
{
	// Pos:0x000
	reliable if(__NFUN_150__(int(Role), int(ROLE_Authority)))
		ServerSetDoor;
}

function ServerDetonate()
{
	m_IORDoor.__NFUN_2019__(BulletActor);
	super.ServerDetonate();
	return;
}

simulated function PlaceChargeAnimation()
{
	ServerPlaceChargeAnimation();
	return;
}

function ServerPlaceChargeAnimation()
{
	R6Pawn(Owner).SetNextPendingAction(16);
	return;
}

function NPCPlaceCharge(Actor aDoor)
{
	// End:0x34
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(" NonPlayerPlaceCharge() aDoor=", string(aDoor)));
	}
	m_IORDoor = R6IORotatingDoor(aDoor);
	ServerPlaceCharge(m_IORDoor.Location);
	m_bChargeInPosition = true;
	__NFUN_113__('ChargeArmed');
	return;
}

function NPCDetonateCharge()
{
	// End:0x40
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(" NPCDetonateCharge() m_bChargeInPosition=", string(m_bChargeInPosition)));
	}
	// End:0x68
	if(m_bChargeInPosition)
	{
		m_IORDoor.__NFUN_2019__(BulletActor);
		Explode();
		m_bChargeInPosition = false;
	}
	return;
}

function bool CharacterOnOtherSide()
{
	local int iDiffYaw;

	iDiffYaw = __NFUN_156__(__NFUN_147__(m_IORDoor.Rotation.Yaw, Owner.Rotation.Yaw), 65535);
	// End:0x46
	if(__NFUN_150__(iDiffYaw, 32768))
	{
		return true;
	}
	return false;
	return;
}

simulated function ServerSetDoor(R6IORotatingDoor aDoor)
{
	m_IORDoor = aDoor;
	return;
}

simulated function ServerPlaceCharge(Vector vLocation)
{
	BulletActor = R6Grenade(__NFUN_278__(m_pBulletClass, self));
	// End:0x73
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__("  ServerPlaceCharge was called for Breach... BulletActor=", string(BulletActor)), " : "), string(m_IORDoor)));
	}
	// End:0x9C
	if(__NFUN_132__(__NFUN_132__(__NFUN_114__(BulletActor, none), __NFUN_114__(m_IORDoor, none)), __NFUN_154__(int(m_iNbBulletsInWeapon), 0)))
	{
		return;
	}
	BulletActor.m_Weapon = self;
	BulletActor.Instigator = Pawn(Owner);
	BulletActor.SetSpeed(0.0000000);
	BulletActor.__NFUN_272__(m_IORDoor);
	BulletActor.__NFUN_298__(m_IORDoor, m_IORDoor.Location);
	m_IORDoor.__NFUN_2018__(BulletActor);
	BulletActor.bUnlit = m_IORDoor.bUnlit;
	BulletActor.bSpecialLit = m_IORDoor.bSpecialLit;
	// End:0x189
	if(m_IORDoor.m_bIsOpeningClockWise)
	{
		BulletActor.SetRelativeLocation(vect(-64.0000000, 2.5000000, 0.0000000));		
	}
	else
	{
		BulletActor.SetRelativeLocation(vect(-64.0000000, -2.5000000, 0.0000000));
	}
	// End:0x1CD
	if(CharacterOnOtherSide())
	{
		BulletActor.SetRelativeRotation(rot(0, 32768, 0));		
	}
	else
	{
		BulletActor.SetRelativeRotation(rot(0, 0, 0));
	}
	m_AttachPoint = m_DetonatorAttachPoint;
	SetStaticMesh(default.StaticMesh);
	Pawn(Owner).AttachToBone(self, m_AttachPoint);
	__NFUN_140__(m_iNbBulletsInWeapon);
	m_bDetonator = true;
	return;
}

function SetAmmoStaticMesh()
{
	m_FPWeapon.m_smGun.SetStaticMesh(StaticMesh'R61stWeapons_SM.Items.R61stBreachingCharge');
	return;
}

function Explode()
{
	BulletActor.Explode();
	BulletActor.__NFUN_279__();
	return;
}

function bool CanPlaceCharge()
{
	local Vector vFeetLocation, vLookLocation, vHitLocation, vHitNormal;
	local Actor HitActor;
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	// End:0x5D
	if(__NFUN_132__(__NFUN_132__(pawnOwner.m_bIsProne, __NFUN_129__(pawnOwner.IsStationary())), __NFUN_181__(pawnOwner.m_fPeeking, pawnOwner.1000.0000000)))
	{
		return false;
	}
	// End:0xA3
	if(__NFUN_132__(__NFUN_114__(pawnOwner.m_Door, none), __NFUN_114__(pawnOwner.m_Door2, none)))
	{
		m_IORDoor = R6IORotatingDoor(pawnOwner.m_potentialActionActor);		
	}
	else
	{
		// End:0x12C
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(pawnOwner.m_Door.m_RotatingDoor.Location, pawnOwner.Location)), __NFUN_225__(__NFUN_216__(pawnOwner.m_Door2.m_RotatingDoor.Location, pawnOwner.Location))))
		{
			m_IORDoor = pawnOwner.m_Door.m_RotatingDoor;			
		}
		else
		{
			m_IORDoor = pawnOwner.m_Door2.m_RotatingDoor;
		}
	}
	// End:0x156
	if(__NFUN_114__(m_IORDoor, none))
	{
		return false;
	}
	// End:0x17E
	if(__NFUN_132__(m_IORDoor.m_bInProcessOfClosing, m_IORDoor.m_bInProcessOfOpening))
	{
		return false;
	}
	// End:0x1A8
	if(__NFUN_129__(pawnOwner.m_bIsPlayer))
	{
		m_vLocation = m_IORDoor.Location;
		return true;
	}
	HitActor = pawnOwner.__NFUN_277__(vHitLocation, vHitNormal, __NFUN_215__(Owner.Location, __NFUN_213__(float(100), Vector(Owner.Rotation))), Owner.Location, true);
	// End:0x21E
	if(__NFUN_132__(__NFUN_114__(HitActor, none), __NFUN_129__(HitActor.__NFUN_303__('R6IORotatingDoor'))))
	{
		return false;
	}
	// End:0x250
	if(__NFUN_132__(R6IORotatingDoor(HitActor).m_bTreatDoorAsWindow, R6IORotatingDoor(HitActor).m_bBroken))
	{
		return false;
	}
	m_vLocation = m_IORDoor.Location;
	// End:0x27A
	if(__NFUN_129__(pawnOwner.IsLocallyControlled()))
	{
		return true;
	}
	// End:0x2AB
	if(__NFUN_114__(m_IORDoor, R6PlayerController(pawnOwner.Controller).m_CurrentCircumstantialAction.aQueryTarget))
	{
		return true;
	}
	return false;
	return;
}

simulated function name GetFiringAnimName()
{
	// End:0x20
	if(Pawn(Owner).bIsCrouched)
	{
		return 'CrouchPlaceBreach';		
	}
	else
	{
		return m_PawnFiringAnim;
	}
	return;
}

simulated function Tick(float fDeltaTime)
{
	// End:0x0D
	if(__NFUN_114__(Owner, none))
	{
		return;
	}
	// End:0xB1
	if(__NFUN_130__(m_bInstallingCharge, __NFUN_132__(__NFUN_132__(m_IORDoor.m_bInProcessOfClosing, m_IORDoor.m_bInProcessOfOpening), __NFUN_176__(m_IORDoor.m_fNetDamagePercentage, 10.0000000))))
	{
		// End:0xAB
		if(__NFUN_132__(__NFUN_154__(int(Level.NetMode), int(NM_Client)), __NFUN_130__(__NFUN_154__(int(Level.NetMode), int(NM_ListenServer)), R6Pawn(Owner).IsLocallyControlled())))
		{
			ServerCancelChargeInstallation();
		}
		CancelChargeInstallation();
	}
	super.Tick(fDeltaTime);
	return;
}

state ChargeReady
{
	// set timer for placing charge - check demolitions skill...
	function Timer()
	{
		// End:0x41
		if(__NFUN_132__(__NFUN_132__(__NFUN_129__(R6Pawn(Owner).m_bIsPlayer), R6Pawn(Owner).m_bPostureTransition), __NFUN_129__(m_bInstallingCharge)))
		{
			return;
		}
		// End:0xA2
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(string(self), " state ChargeReady : Timer() has expired "), string(R6PlayerController(Pawn(Owner).Controller).m_bPlacedExplosive)));
		}
		// End:0x119
		if(R6PlayerController(Pawn(Owner).Controller).m_bPlacedExplosive)
		{
			ServerSetDoor(m_IORDoor);
			ServerPlaceCharge(m_vLocation);
			m_bChargeInPosition = true;
			m_bInstallingCharge = false;
			m_bRaiseWeapon = false;
			m_FPWeapon.m_smGun.SetStaticMesh(m_DetonatorStaticMesh);
			__NFUN_113__('ChargeArmed');
		}
		return;
	}
	stop;
}

defaultproperties
{
	m_DetonatorStaticMesh=StaticMesh'R61stWeapons_SM.Items.R61stBreachingDetonator'
	m_ChargeStaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingCharge'
	m_ChargeAttachPoint="TagC4Hand"
	m_iClipCapacity=3
	m_pBulletClass=Class'R6Weapons.R6BreachingChargeUnit'
	m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripBreach'
	m_pFPWeaponClass=Class'R61stWeapons.R61stBreachingCharge'
	m_SingleFireStereoSnd=Sound'Gadget_BreachingCharge.Play_BreachingChargePlacement'
	m_SingleFireEndStereoSnd=Sound'Gadget_BreachingCharge.Stop_BreachingCharge_Go'
	m_HUDTexture=Texture'R6HUD.HUDElements'
	m_PawnWaitAnimLow="StandGrenade_nt"
	m_PawnWaitAnimHigh="StandGrenade_nt"
	m_PawnWaitAnimProne="ProneGrenade_nt"
	m_PawnFiringAnim="StandPlaceBreach"
	m_AttachPoint="TagC4Hand"
	m_HUDTexturePos=(W=32.0000000,X=100.0000000,Y=352.0000000,Z=100.0000000)
	m_NameID="BreachingChargeGadget"
	StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdBreachingDetonator'
}
