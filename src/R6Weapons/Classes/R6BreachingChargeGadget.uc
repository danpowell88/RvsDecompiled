//=============================================================================
// R6BreachingChargeGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
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
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerSetDoor;
}

function ServerDetonate()
{
	m_IORDoor.RemoveBreach(BulletActor);
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
		Log((" NonPlayerPlaceCharge() aDoor=" $ string(aDoor)));
	}
	m_IORDoor = R6IORotatingDoor(aDoor);
	ServerPlaceCharge(m_IORDoor.Location);
	m_bChargeInPosition = true;
	GotoState('ChargeArmed');
	return;
}

function NPCDetonateCharge()
{
	// End:0x40
	if(bShowLog)
	{
		Log((" NPCDetonateCharge() m_bChargeInPosition=" $ string(m_bChargeInPosition)));
	}
	// End:0x68
	if(m_bChargeInPosition)
	{
		m_IORDoor.RemoveBreach(BulletActor);
		Explode();
		m_bChargeInPosition = false;
	}
	return;
}

function bool CharacterOnOtherSide()
{
	local int iDiffYaw;

	iDiffYaw = ((m_IORDoor.Rotation.Yaw - Owner.Rotation.Yaw) & 65535);
	// End:0x46
	if((iDiffYaw < 32768))
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
	BulletActor = R6Grenade(Spawn(m_pBulletClass, self));
	// End:0x73
	if(bShowLog)
	{
		Log(((("  ServerPlaceCharge was called for Breach... BulletActor=" $ string(BulletActor)) $ " : ") $ string(m_IORDoor)));
	}
	// End:0x9C
	if((((BulletActor == none) || (m_IORDoor == none)) || (int(m_iNbBulletsInWeapon) == 0)))
	{
		return;
	}
	BulletActor.m_Weapon = self;
	BulletActor.Instigator = Pawn(Owner);
	BulletActor.SetSpeed(0.0000000);
	BulletActor.SetOwner(m_IORDoor);
	BulletActor.SetBase(m_IORDoor, m_IORDoor.Location);
	m_IORDoor.AddBreach(BulletActor);
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
	(m_iNbBulletsInWeapon--);
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
	BulletActor.Destroy();
	return;
}

function bool CanPlaceCharge()
{
	local Vector vFeetLocation, vLookLocation, vHitLocation, vHitNormal;
	local Actor HitActor;
	local R6Pawn pawnOwner;

	pawnOwner = R6Pawn(Owner);
	// End:0x5D
	if(((pawnOwner.m_bIsProne || (!pawnOwner.IsStationary())) || (pawnOwner.m_fPeeking != pawnOwner.1000.0000000)))
	{
		return false;
	}
	// End:0xA3
	if(((pawnOwner.m_Door == none) || (pawnOwner.m_Door2 == none)))
	{
		m_IORDoor = R6IORotatingDoor(pawnOwner.m_potentialActionActor);		
	}
	else
	{
		// End:0x12C
		if((VSize((pawnOwner.m_Door.m_RotatingDoor.Location - pawnOwner.Location)) < VSize((pawnOwner.m_Door2.m_RotatingDoor.Location - pawnOwner.Location))))
		{
			m_IORDoor = pawnOwner.m_Door.m_RotatingDoor;			
		}
		else
		{
			m_IORDoor = pawnOwner.m_Door2.m_RotatingDoor;
		}
	}
	// End:0x156
	if((m_IORDoor == none))
	{
		return false;
	}
	// End:0x17E
	if((m_IORDoor.m_bInProcessOfClosing || m_IORDoor.m_bInProcessOfOpening))
	{
		return false;
	}
	// End:0x1A8
	if((!pawnOwner.m_bIsPlayer))
	{
		m_vLocation = m_IORDoor.Location;
		return true;
	}
	HitActor = pawnOwner.Trace(vHitLocation, vHitNormal, (Owner.Location + (float(100) * Vector(Owner.Rotation))), Owner.Location, true);
	// End:0x21E
	if(((HitActor == none) || (!HitActor.IsA('R6IORotatingDoor'))))
	{
		return false;
	}
	// End:0x250
	if((R6IORotatingDoor(HitActor).m_bTreatDoorAsWindow || R6IORotatingDoor(HitActor).m_bBroken))
	{
		return false;
	}
	m_vLocation = m_IORDoor.Location;
	// End:0x27A
	if((!pawnOwner.IsLocallyControlled()))
	{
		return true;
	}
	// End:0x2AB
	if((m_IORDoor == R6PlayerController(pawnOwner.Controller).m_CurrentCircumstantialAction.aQueryTarget))
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
	if((Owner == none))
	{
		return;
	}
	// End:0xB1
	if((m_bInstallingCharge && ((m_IORDoor.m_bInProcessOfClosing || m_IORDoor.m_bInProcessOfOpening) || (m_IORDoor.m_fNetDamagePercentage < 10.0000000))))
	{
		// End:0xAB
		if(((int(Level.NetMode) == int(NM_Client)) || ((int(Level.NetMode) == int(NM_ListenServer)) && R6Pawn(Owner).IsLocallyControlled())))
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
		if((((!R6Pawn(Owner).m_bIsPlayer) || R6Pawn(Owner).m_bPostureTransition) || (!m_bInstallingCharge)))
		{
			return;
		}
		// End:0xA2
		if(bShowLog)
		{
			Log(((string(self) $ " state ChargeReady : Timer() has expired ") $ string(R6PlayerController(Pawn(Owner).Controller).m_bPlacedExplosive)));
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
			GotoState('ChargeArmed');
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
