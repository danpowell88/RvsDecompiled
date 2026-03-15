//=============================================================================
// R6Terrorist - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Terrorist.uc : This is the pawn class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add Basic Animations 
//    Eric - June 12th, 2001    - Add PatrolNode Interaction
//=============================================================================
class R6Terrorist extends R6Pawn
    abstract
    native;

enum ETerroristCircumstantialAction
{
	CAT_None,                       // 0
	CAT_Secure                      // 1
};

enum EStrategy
{
	STRATEGY_PatrolPath,            // 0
	STRATEGY_PatrolArea,            // 1
	STRATEGY_GuardPoint,            // 2
	STRATEGY_Hunt,                  // 3
	STRATEGY_Test                   // 4
};

enum EDefCon
{
	DEFCON_0,                       // 0
	DEFCON_1,                       // 1
	DEFCON_2,                       // 2
	DEFCON_3,                       // 3
	DEFCON_4,                       // 4
	DEFCON_5                        // 5
};

enum ETerroPersonality
{
	PERSO_Coward,                   // 0
	PERSO_DeskJockey,               // 1
	PERSO_Normal,                   // 2
	PERSO_Hardened,                 // 3
	PERSO_SuicideBomber,            // 4
	PERSO_Sniper                    // 5
};

enum ENetworkSpecialAnim
{
	NWA_NonValid,                   // 0
	NWA_Playing,                    // 1
	NWA_Looping                     // 2
};

// Variable defining the terrorist
var() R6Terrorist.EDefCon m_eDefCon;
var() R6Terrorist.ETerroPersonality m_ePersonality;
var() R6Terrorist.EStrategy m_eStrategy;
var() Actor.EStance m_eStartingStance;
var R6Pawn.EHeadAttachmentType m_eHeadAttachmentType;
var R6Pawn.ETerroristType m_eTerroType;
var R6Terrorist.ENetworkSpecialAnim m_eSpecialAnimValid;  // For network. When true, a newly relevant must play the special anim.
var() byte m_wWantedAimingPitch;  // Pitch wanted for the gun
var() byte m_wWantedHeadYaw;  // Yaw wanted for the head
var() int m_iGroupID;
var() int m_iCurrentAimingPitch;  // Current pitch of the gun.  Updated in UpdateAiming
var() int m_iCurrentHeadYaw;  // Current yaw of the head.  Updated in UpdateAiming
var() int m_iDiffLevel;  // Current difficulty level of this terrorist (from gameinfo)
var bool m_bBoltActionRifle;
var() bool m_bHaveAGrenade;
var bool m_bInitFinished;
var() bool m_bAllowLeave;  // Whether the therrorist can or not leave his zone
var bool m_bPreventCrouching;  // Whether the therrorist can or not crouch
var(Debug) bool m_bHearNothing;  // Only for debug purpose
var() bool m_bSprayFire;  // Not the same animation when sprayfiring
// State variable
var bool m_bPreventWeaponAnimation;
var() bool m_bIsUnderArrest;
// Patrol Movements
var bool m_bPatrolForward;
var bool m_bEnteringView;
var float m_fPlayerCAStartTime;
var R6THeadAttachment m_HeadAttachment;
var Actor m_Radio;
var R6TerroristAI m_controller;
var R6DeploymentZone m_DZone;
var name m_szSpecialAnimName;
// Variable defining the terrorist state
var() Rotator m_rFiringRotation;
var() string m_szUsedTemplate;
var() string m_szPrimaryWeapon;
var() string m_szGrenadeWeapon;
var() string m_szGadget;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bIsUnderArrest, m_bPreventWeaponAnimation, 
		m_bSprayFire, m_eDefCon, 
		m_eSpecialAnimValid, m_szSpecialAnimName;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		m_wWantedAimingPitch, m_wWantedHeadYaw;
}

//============================================================================
// event Destroyed - 
//============================================================================
simulated event Destroyed()
{
	super.Destroyed();
	// End:0x24
	if((m_HeadAttachment != none))
	{
		m_HeadAttachment.Destroy();
		m_HeadAttachment = none;
	}
	return;
}

//============================================================================
// Rotator GetFiringRotation - 
//============================================================================
function Rotator GetFiringRotation()
{
	return m_rFiringRotation;
	return;
}

//============================================================================
// PostBeginPlay - 
//============================================================================
simulated function PostBeginPlay()
{
	local Vector vTagLocation;
	local Rotator rTagRotator;

	// End:0x36
	if((Level.Game != none))
	{
		assert((default.m_iTeam == R6AbstractGameInfo(Level.Game).1));
	}
	super.PostBeginPlay();
	SetMovementPhysics();
	return;
}

//============================================================================
// SetToNormalWeapon - 
//============================================================================
function SetToNormalWeapon()
{
	EngineWeapon = GetWeaponInGroup(1);
	// End:0x26
	if((EngineWeapon == none))
	{
		EngineWeapon = GetWeaponInGroup(2);
	}
	EngineWeapon.RemoteRole = ROLE_SimulatedProxy;
	// End:0x76
	if((EngineWeapon != none))
	{
		AttachWeapon(EngineWeapon, 'TagRightHand');
		EngineWeapon.WeaponInitialization(self);
		m_pBulletManager.SetBulletParameter(EngineWeapon);
	}
	return;
}

//============================================================================
// SetToGrenade - 
//============================================================================
function SetToGrenade()
{
	// End:0x3F
	if(((!EngineWeapon.m_bUseMicroAnim) && (int(EngineWeapon.m_eWeaponType) != int(0))))
	{
		AttachWeapon(EngineWeapon, 'TagLeftHand');
	}
	EngineWeapon = GetWeaponInGroup(3);
	EngineWeapon.bHidden = false;
	AttachWeapon(EngineWeapon, 'TagRightHand');
	return;
}

//============================================================================
// FinishInitialization - 
//============================================================================
event FinishInitialization()
{
	CommonInit();
	return;
}

//============================================================================
// CommonInit -  Common initialization between R6Terrorist and R6MatineeTerrorist
//============================================================================
function CommonInit()
{
	local float fFactor;
	local R6EngineWeapon aGrenade;

	// End:0x11
	if((Controller != none))
	{
		UnPossessed();
	}
	Controller = Spawn(ControllerClass);
	Controller.Possess(self);
	// End:0x4D
	if((m_szPrimaryWeapon != ""))
	{
		ServerGivesWeaponToClient(m_szPrimaryWeapon, 1);
		SetToNormalWeapon();
	}
	// End:0x9E
	if((m_szGrenadeWeapon != ""))
	{
		ServerGivesWeaponToClient(m_szGrenadeWeapon, 3);
		m_bHaveAGrenade = true;
		aGrenade = GetWeaponInGroup(3);
		aGrenade.RemoteRole = ROLE_SimulatedProxy;
		aGrenade.bHidden = true;
	}
	Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
	Controller.m_PawnRepInfo.m_bSex = bIsFemale;
	// End:0x102
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;
	}
	// End:0x165
	if((EngineWeapon != none))
	{
		// End:0x144
		if(((int(EngineWeapon.m_eWeaponType) == int(4)) && EngineWeapon.IsA('R6BoltActionSniperRifle')))
		{
			m_bBoltActionRifle = true;
		}
		EngineWeapon.m_bUnlimitedClip = true;
		EngineWeapon.SetTerroristNbOfClips(1);
	}
	// End:0x1D4
	if(((m_szGadget != "") && (int(Level.NetMode) != int(NM_DedicatedServer))))
	{
		R6AbstractWeapon(EngineWeapon).R6SetGadget(Class<R6AbstractGadget>(DynamicLoadObject(m_szGadget, Class'Core.Class')));
		R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(true, true);
	}
	// End:0x255
	if((int(m_eHeadAttachmentType) != int(3)))
	{
		m_HeadAttachment = Spawn(Class'R6Engine.R6THeadAttachment');
		// End:0x242
		if(m_HeadAttachment.SetAttachmentStaticMesh(m_eHeadAttachmentType, m_eTerroType))
		{
			m_HeadAttachment.SetOwner(self);
			AttachToBone(m_HeadAttachment, 'R6 Head');
			m_bHaveGasMask = (int(m_eHeadAttachmentType) == int(2));			
		}
		else
		{
			m_HeadAttachment.Destroy();
			m_HeadAttachment = none;
		}
	}
	AttachCollisionBox(2);
	// End:0x34D
	if((R6AbstractGameInfo(Level.Game) != none))
	{
		m_iDiffLevel = R6AbstractGameInfo(Level.Game).m_iDiffLevel;
		// End:0x2AB
		if((m_iDiffLevel == 0))
		{
			m_iDiffLevel = 2;
		}
		switch(m_iDiffLevel)
		{
			// End:0x2C4
			case 1:
				fFactor = 0.4000000;
				// End:0x2ED
				break;
			// End:0x2D7
			case 2:
				fFactor = 0.7000000;
				// End:0x2ED
				break;
			// End:0x2EA
			case 3:
				fFactor = 1.2500000;
				// End:0x2ED
				break;
			// End:0xFFFF
			default:
				break;
		}
		(m_fSkillAssault *= fFactor);
		(m_fSkillDemolitions *= fFactor);
		(m_fSkillElectronics *= fFactor);
		(m_fSkillSniper *= fFactor);
		(m_fSkillStealth *= fFactor);
		(m_fSkillSelfControl *= fFactor);
		(m_fSkillLeadership *= fFactor);
		(m_fSkillObservation *= fFactor);
	}
	return;
}

//============================================================================
// SetMovementPhysics - 
//============================================================================
simulated function SetMovementPhysics()
{
	SetPhysics(1);
	return;
}

//============================================================================
// AnimateStandTurning
//============================================================================
simulated function AnimateStandTurning()
{
	// End:0x41
	if(((m_bDroppedWeapon || (EngineWeapon == none)) || (int(m_eDefCon) > int(3))))
	{
		TurnLeftAnim = 'RelaxTurnLeft';
		TurnRightAnim = 'RelaxTurnRight';		
	}
	else
	{
		TurnLeftAnim = m_standTurnLeftName;
		TurnRightAnim = m_standTurnRightName;
	}
	return;
}

//============================================================================
// AnimateWalking() 
//============================================================================
simulated function AnimateWalking()
{
	// End:0x6C
	if(((m_bDroppedWeapon || (EngineWeapon == none)) || (int(m_eDefCon) > int(3))))
	{
		m_fWalkingSpeed = 116.0000000;
		MovementAnims[0] = 'RelaxWalkForward';
		MovementAnims[1] = m_standWalkLeftName;
		MovementAnims[2] = 'RelaxWalkForward';
		MovementAnims[3] = m_standWalkRightName;		
	}
	else
	{
		// End:0xC0
		if((int(m_eHealth) == int(1)))
		{
			m_fWalkingSpeed = 120.0000000;
			MovementAnims[0] = 'HurtStandWalkForward';
			MovementAnims[1] = m_standWalkLeftName;
			MovementAnims[2] = 'HurtStandWalkBack';
			MovementAnims[3] = m_standWalkRightName;			
		}
		else
		{
			m_fWalkingSpeed = 170.0000000;
			MovementAnims[0] = m_standWalkForwardName;
			MovementAnims[1] = m_standWalkLeftName;
			MovementAnims[2] = m_standWalkBackName;
			MovementAnims[3] = m_standWalkRightName;
		}
	}
	return;
}

//============================================================================
// AnimateRunning() 
//============================================================================
simulated function AnimateRunning()
{
	local name nFoward;

	nFoward = 'StandRunSubGunForward';
	// End:0x74
	if(((!m_bDroppedWeapon) && (EngineWeapon != none)))
	{
		switch(EngineWeapon.m_eWeaponType)
		{
			// End:0x58
			case 1:
				// End:0x55
				if(EngineWeapon.m_bUseMicroAnim)
				{
					nFoward = 'StandRunHandGun';
				}
				// End:0x71
				break;
			// End:0x6B
			case 0:
				nFoward = 'StandRunHandGun';
				// End:0x71
				break;
			// End:0xFFFF
			default:
				// End:0x71
				break;
				break;
		}		
	}
	else
	{
		nFoward = 'StandRunHandGun';
	}
	MovementAnims[0] = nFoward;
	MovementAnims[1] = 'StandRunLeft';
	MovementAnims[2] = 'StandWalkBack';
	MovementAnims[3] = 'StandRunRight';
	return;
}

//============================================================================
// function AnimateWalkingUpStairs - 
//============================================================================
simulated function AnimateWalkingUpStairs()
{
	super.AnimateWalkingUpStairs();
	// End:0x3B
	if(((m_bDroppedWeapon || (EngineWeapon == none)) || (int(m_eDefCon) > int(3))))
	{
		MovementAnims[0] = 'RelaxStairUp';
	}
	return;
}

//============================================================================
// function AnimateWalkingDownStairs - 
//============================================================================
simulated function AnimateWalkingDownStairs()
{
	super.AnimateWalkingDownStairs();
	// End:0x3B
	if(((m_bDroppedWeapon || (EngineWeapon == none)) || (int(m_eDefCon) > int(3))))
	{
		MovementAnims[0] = 'RelaxStairDown';
	}
	return;
}

//============================================================================
// PlayWaiting - 
//============================================================================
simulated function PlayWaiting()
{
	local name Anim;
	local R6Terrorist.EDefCon EDefCon;

	// End:0x21
	if((m_bDroppedWeapon || (EngineWeapon == none)))
	{
		EDefCon = 5;		
	}
	else
	{
		EDefCon = m_eDefCon;
	}
	// End:0x44
	if((int(Physics) == int(2)))
	{
		PlayFalling();
		return;
	}
	// End:0x55
	if(m_bIsUnderArrest)
	{
		PlayArrestWaiting();
		return;
	}
	// End:0x66
	if(m_bIsKneeling)
	{
		PlayKneelWaiting();
		return;
	}
	// End:0x77
	if(bIsCrouched)
	{
		PlayCrouchWaiting();
		return;
	}
	// End:0x88
	if(m_bIsProne)
	{
		PlayProneWaiting();
		return;
	}
	// End:0x99
	if(m_bIsClimbingLadder)
	{
		AnimateStoppedOnLadder();
		return;
	}
	switch(EDefCon)
	{
		// End:0xA5
		case 1:
		// End:0xAA
		case 2:
		// End:0x12F
		case 3:
			SetRandomWaiting(6, true);
			switch(m_bRepPlayWaitAnim)
			{
				// End:0xD2
				case 0:
					Anim = 'StandWaitLookFarSubGun01';
					// End:0x12C
					break;
				// End:0xE5
				case 1:
					Anim = 'StandWaitLookFarSubGun02';
					// End:0x12C
					break;
				// End:0xF8
				case 2:
					Anim = 'StandWaitResightSubGun';
					// End:0x12C
					break;
				// End:0x10B
				case 3:
					Anim = 'StandWaitStiffLegsSubGun';
					// End:0x12C
					break;
				// End:0x11E
				case 4:
					Anim = 'StandWaitStiffNeckSubGun';
					// End:0x12C
					break;
				// End:0xFFFF
				default:
					Anim = 'StandWaitWipeNoseSubGun';
					break;
			}
			// End:0x256
			break;
		// End:0x134
		case 4:
		// End:0x253
		case 5:
			SetRandomWaiting(14);
			switch(m_bRepPlayWaitAnim)
			{
				// End:0x15B
				case 0:
					Anim = 'RelaxWaitBreathe';
					// End:0x250
					break;
				// End:0x16E
				case 1:
					Anim = 'RelaxWaitBend';
					// End:0x250
					break;
				// End:0x181
				case 2:
					Anim = 'RelaxWaitCrackNeck';
					// End:0x250
					break;
				// End:0x194
				case 3:
					Anim = 'RelaxWaitLookAround01';
					// End:0x250
					break;
				// End:0x1A7
				case 4:
					Anim = 'RelaxWaitLookAround02';
					// End:0x250
					break;
				// End:0x1BA
				case 5:
					Anim = 'RelaxWaitLookFar';
					// End:0x250
					break;
				// End:0x1CD
				case 6:
					Anim = 'RelaxWaitPickShoe';
					// End:0x250
					break;
				// End:0x1E0
				case 7:
					Anim = 'RelaxWaitScratchNose';
					// End:0x250
					break;
				// End:0x1F3
				case 8:
					Anim = 'RelaxWaitShiftWeight01';
					// End:0x250
					break;
				// End:0x206
				case 9:
					Anim = 'RelaxWaitShiftWeight02';
					// End:0x250
					break;
				// End:0x219
				case 10:
					Anim = 'RelaxWaitShiftWeight03';
					// End:0x250
					break;
				// End:0x22C
				case 11:
					Anim = 'RelaxWaitShuffle';
					// End:0x250
					break;
				// End:0x23F
				case 12:
					Anim = 'RelaxWaitSlapFly';
					// End:0x250
					break;
				// End:0xFFFF
				default:
					Anim = 'RelaxWaitStretch';
					// End:0x250
					break;
					break;
			}
			// End:0x256
			break;
		// End:0xFFFF
		default:
			break;
	}
	R6LoopAnim(Anim, 1.0000000);
	return;
}

//============================================================================
// PlayCrouchWaiting() - 
//============================================================================
simulated function PlayCrouchWaiting()
{
	local name Anim;

	SetRandomWaiting(6);
	switch(m_bRepPlayWaitAnim)
	{
		// End:0x22
		case 0:
			Anim = 'CrouchWaitBreatheSubGun01';
			// End:0x7C
			break;
		// End:0x35
		case 1:
			Anim = 'CrouchWaitBreatheSubGun02';
			// End:0x7C
			break;
		// End:0x48
		case 2:
			Anim = 'CrouchWaitLookAroundSubGun';
			// End:0x7C
			break;
		// End:0x5B
		case 3:
			Anim = 'CrouchWaitLookAtSubGun';
			// End:0x7C
			break;
		// End:0x6E
		case 4:
			Anim = 'CrouchWaitRepositionSubGun';
			// End:0x7C
			break;
		// End:0xFFFF
		default:
			Anim = 'CrouchWaitStiffNeckSubGun';
			break;
	}
	R6LoopAnim(Anim, 1.0000000);
	return;
}

//============================================================================
// PlayProneWaiting - 
//============================================================================
simulated function PlayProneWaiting()
{
	R6LoopAnim('ProneWaitBreathe', 1.0000000);
	return;
}

//============================================================================
// PlayKneelWaiting() - 
//============================================================================
simulated function PlayKneelWaiting()
{
	m_ePlayerIsUsingHands = 3;
	R6LoopAnim('Kneel_nt', 0.0100000);
	return;
}

//============================================================================
// PlayArrestWaiting() - 
//============================================================================
simulated function PlayArrestWaiting()
{
	local name Anim;

	m_ePlayerIsUsingHands = 3;
	SetRandomWaiting(4);
	switch(m_bRepPlayWaitAnim)
	{
		// End:0x2A
		case 0:
			Anim = 'KneelArrestWait01';
			// End:0x38
			break;
		// End:0xFFFF
		default:
			Anim = 'KneelArrestWait02';
			break;
	}
	R6LoopAnim(Anim, 1.0000000);
	return;
}

//============================================================================
// PlayDuck - 
//============================================================================
simulated function PlayDuck()
{
	local name Anim;

	// End:0x20
	if(EngineWeapon.m_bUseMicroAnim)
	{
		Anim = 'CrouchMicroHigh_nt';		
	}
	else
	{
		// End:0x47
		if((int(EngineWeapon.m_eWeaponType) == int(0)))
		{
			Anim = 'CrouchHandGunHigh_nt';			
		}
		else
		{
			Anim = 'CrouchSubGunHigh_nt';
		}
	}
	R6LoopAnim(Anim);
	return;
}

//============================================================================
// ResetArrest - 
//============================================================================
function ResetArrest()
{
	// End:0x45
	if(IsAlive())
	{
		AnimBlendToAlpha(16, 0.0000000, 0.5000000);
		m_ePlayerIsUsingHands = 0;
		PlayWeaponAnimation();
		m_bPawnSpecificAnimInProgress = false;
		m_bIsUnderArrest = false;
		PlayWaiting();
		SetCollision(true, true, true);
	}
	return;
}

//============================================================================
// R6QueryCircumstantialAction - 
//============================================================================
event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	// End:0x105
	if((m_bIsKneeling && IsAlive()))
	{
		Query.iHasAction = 1;
		// End:0x48
		if((fDistance < m_fCircumstantialActionRange))
		{
			Query.iInRange = 1;			
		}
		else
		{
			Query.iInRange = 0;
		}
		Query.textureIcon = Texture'R6ActionIcons.HandcuffTerrorist';
		Query.fPlayerActionTimeRequired = 0.0000000;
		Query.bCanBeInterrupted = true;
		Query.iPlayerActionID = 1;
		Query.iTeamActionID = 1;
		Query.iTeamActionIDList[0] = 1;
		Query.iTeamActionIDList[1] = 0;
		Query.iTeamActionIDList[2] = 0;
		Query.iTeamActionIDList[3] = 0;		
	}
	else
	{
		Query.iHasAction = 0;
	}
	return;
}

//============================================================================
// string R6GetCircumstantialActionString - 
//============================================================================
simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x35
		case int(1):
			return Localize("RDVOrder", "Order_Secure", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

//===========================================================================//
// R6GetCircumstantialActionProgress() -                                      
//===========================================================================//
function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
	local name Anim;
	local float fFrame, fRate;

	actingPawn.GetAnimParams(1, Anim, fFrame, fRate);
	Clamp(int(fFrame), 0, 100);
	return int((fFrame * float(100)));
	return;
}

//===========================================================================//
// R6CircumstantialActionProgressStart()                                     //
//===========================================================================//
function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
	m_fPlayerCAStartTime = Level.TimeSeconds;
	return;
}

function ReleaseGrenade()
{
	// End:0x0D
	if((!IsAlive()))
	{
		return;
	}
	m_rFiringRotation = m_controller.GetGrenadeDirection(m_controller.Enemy);
	EngineWeapon.ThrowGrenade();
	EngineWeapon.bHidden = true;
	m_bHaveAGrenade = false;
	return;
}

function EndGrenade()
{
	return;
}

simulated event AnimEnd(int iChannel)
{
	// End:0x67
	if(((iChannel == 16) && (int(m_eSpecialAnimValid) != int(2))))
	{
		AnimBlendToAlpha(16, 0.0000000, 0.5000000);
		m_ePlayerIsUsingHands = 0;
		PlayWeaponAnimation();
		m_bPawnSpecificAnimInProgress = false;
		// End:0x67
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_eSpecialAnimValid = 0;
		}
	}
	super.AnimEnd(iChannel);
	return;
}

//============================================================================
// BOOL R6TakeDamage - 
//============================================================================
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local int iResult;

	iResult = super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	ChangeAnimation();
	return iResult;
	return;
}

//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting()
{
	// End:0x0B
	if(m_bIsKneeling)
	{
		return false;
	}
	// End:0x1A
	if((int(m_bIsFiringWeapon) == 1))
	{
		return true;
	}
	// End:0x3B
	if((IsAlive() && Controller.IsInState('Attack')))
	{
		return true;
	}
	return false;
	return;
}

//============================================================================
// R6TerroristMgr GetManager - 
//============================================================================
function R6TerroristMgr GetManager()
{
	return R6TerroristMgr(Level.GetTerroristMgr());
	return;
}

// Movement function not supposed to be called for a terrorist
simulated function AnimateCrouchRunning()
{
	return;
}

simulated function AnimateCrouchRunningUpStairs()
{
	return;
}

simulated function AnimateCrouchRunningDownStairs()
{
	return;
}

event EndOfGrenadeEffect(Pawn.EGrenadeType eType)
{
	// End:0x18
	if((int(eType) == int(2)))
	{
		SetNextPendingAction(2);
	}
	return;
}

function StartHunting()
{
	// End:0x2B
	if((!m_DZone.m_bHuntDisallowed))
	{
		m_eStrategy = 3;
		m_controller.GotoStateNoThreat();
	}
	return;
}

//============================================================================
// function PlayMoving - 
//============================================================================
simulated function PlayMoving()
{
	m_ePlayerIsUsingHands = 0;
	super.PlayMoving();
	return;
}

//============================================================================
// event ReceivedWeapons - 
//============================================================================
simulated event ReceivedWeapons()
{
	EngineWeapon = GetWeaponInGroup(1);
	// End:0x26
	if((EngineWeapon == none))
	{
		EngineWeapon = GetWeaponInGroup(2);
	}
	// End:0x45
	if((EngineWeapon != none))
	{
		R6AbstractWeapon(EngineWeapon).CreateWeaponEmitters();
	}
	PlayWeaponAnimation();
	return;
}

//============================================================================
// function GetNormalWeaponAnimation - 
//============================================================================
simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim)
{
	stAnim.bBackward = false;
	stAnim.bPlayOnce = false;
	stAnim.fTweenTime = 0.3000000;
	stAnim.fRate = 1.0000000;
	stAnim.nBlendName = 'R6 Spine';
	// End:0x76
	if((((m_bPreventWeaponAnimation || m_bPawnSpecificAnimInProgress) || m_bIsKneeling) || m_bIsClimbingLadder))
	{
		return false;
	}
	m_ePlayerIsUsingHands = 0;
	// End:0x9A
	if(m_bIsProne)
	{
		stAnim.nAnimToPlay = 'Prone_nt';		
	}
	else
	{
		// End:0xD3
		if((m_bDroppedWeapon || (EngineWeapon == none)))
		{
			stAnim.nBlendName = 'R6 R Clavicle';
			stAnim.nAnimToPlay = 'Relax_nt';			
		}
		else
		{
			// End:0x1BF
			if(bIsCrouched)
			{
				// End:0x15B
				if((m_bUseHighStance && (int(m_eDefCon) <= int(3))))
				{
					// End:0x11C
					if(EngineWeapon.m_bUseMicroAnim)
					{
						stAnim.nAnimToPlay = 'CrouchMicroHigh_nt';						
					}
					else
					{
						// End:0x148
						if((int(EngineWeapon.m_eWeaponType) == int(0)))
						{
							stAnim.nAnimToPlay = 'CrouchHandGunHigh_nt';							
						}
						else
						{
							stAnim.nAnimToPlay = 'CrouchSubGunHigh_nt';
						}
					}					
				}
				else
				{
					// End:0x180
					if(EngineWeapon.m_bUseMicroAnim)
					{
						stAnim.nAnimToPlay = 'CrouchMicroLow_nt';						
					}
					else
					{
						// End:0x1AC
						if((int(EngineWeapon.m_eWeaponType) == int(0)))
						{
							stAnim.nAnimToPlay = 'CrouchHandGunLow_nt';							
						}
						else
						{
							stAnim.nAnimToPlay = 'CrouchSubGunLow_nt';
						}
					}
				}				
			}
			else
			{
				// End:0x299
				if(m_bUseHighStance)
				{
					// End:0x235
					if(m_bSprayFire)
					{
						// End:0x1F6
						if(EngineWeapon.m_bUseMicroAnim)
						{
							stAnim.nAnimToPlay = 'StandMicroMid_nt';							
						}
						else
						{
							// End:0x222
							if((int(EngineWeapon.m_eWeaponType) == int(0)))
							{
								stAnim.nAnimToPlay = 'StandHandGunHigh_nt';								
							}
							else
							{
								stAnim.nAnimToPlay = 'StandSubGunMid_nt';
							}
						}						
					}
					else
					{
						// End:0x25A
						if(EngineWeapon.m_bUseMicroAnim)
						{
							stAnim.nAnimToPlay = 'StandMicroHigh_nt';							
						}
						else
						{
							// End:0x286
							if((int(EngineWeapon.m_eWeaponType) == int(0)))
							{
								stAnim.nAnimToPlay = 'StandHandGunHigh_nt';								
							}
							else
							{
								stAnim.nAnimToPlay = 'StandSubGunHigh_nt';
							}
						}
					}					
				}
				else
				{
					// End:0x30D
					if((int(m_eDefCon) <= int(3)))
					{
						// End:0x2CE
						if(EngineWeapon.m_bUseMicroAnim)
						{
							stAnim.nAnimToPlay = 'StandMicroLow_nt';							
						}
						else
						{
							// End:0x2FA
							if((int(EngineWeapon.m_eWeaponType) == int(0)))
							{
								stAnim.nAnimToPlay = 'StandHandGunLow_nt';								
							}
							else
							{
								stAnim.nAnimToPlay = 'StandSubGunLow_nt';
							}
						}						
					}
					else
					{
						// End:0x391
						if((int(m_eDefCon) <= int(4)))
						{
							stAnim.nBlendName = 'R6 R Clavicle';
							// End:0x352
							if(EngineWeapon.m_bUseMicroAnim)
							{
								stAnim.nAnimToPlay = 'RelaxMicro_nt';								
							}
							else
							{
								// End:0x37E
								if((int(EngineWeapon.m_eWeaponType) == int(0)))
								{
									stAnim.nAnimToPlay = 'RelaxHandGun_nt';									
								}
								else
								{
									stAnim.nAnimToPlay = 'RelaxSubGun_nt';
								}
							}							
						}
						else
						{
							// End:0x3C9
							if((EngineWeapon.m_bUseMicroAnim || (int(EngineWeapon.m_eWeaponType) == int(0))))
							{
								m_ePlayerIsUsingHands = 3;								
							}
							else
							{
								stAnim.nAnimToPlay = 'RelaxSubGunShoulder_nt';
								stAnim.nBlendName = 'R6 R Clavicle';
								m_ePlayerIsUsingHands = 2;
							}
						}
					}
				}
			}
		}
	}
	return true;
	return;
}

//============================================================================
// function GetFireWeaponAnimation - 
//============================================================================
simulated function bool GetFireWeaponAnimation(out STWeaponAnim stAnim)
{
	local R6EngineWeapon.eWeaponType eWT;

	stAnim.bBackward = false;
	stAnim.bPlayOnce = (int(EngineWeapon.GetRateOfFire()) == int(0));
	stAnim.fRate = 1.0000000;
	stAnim.fTweenTime = 0.0500000;
	stAnim.nBlendName = 'R6 Spine';
	// End:0x98
	if(m_bIsProne)
	{
		// End:0x85
		if(m_bBoltActionRifle)
		{
			stAnim.nAnimToPlay = 'ProneFireAndBoltRifle';			
		}
		else
		{
			stAnim.nAnimToPlay = 'ProneFire';
		}		
	}
	else
	{
		// End:0xD5
		if(((EngineWeapon.m_bUseMicroAnim && m_bSprayFire) && (!bIsCrouched)))
		{
			stAnim.nAnimToPlay = 'StandSprayFireMicro';			
		}
		else
		{
			eWT = EngineWeapon.m_eWeaponType;
			// End:0x123
			if(EngineWeapon.m_bUseMicroAnim)
			{
				stAnim.fTweenTime = 0.1000000;
				stAnim.fRate = 3.0000000;
				eWT = 0;
			}
			// End:0x148
			if(((int(eWT) == int(4)) && (!m_bBoltActionRifle)))
			{
				eWT = 1;
			}
			switch(eWT)
			{
				// End:0x19F
				case 3:
					// End:0x170
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchFireShotgun';						
					}
					else
					{
						// End:0x18C
						if(m_bSprayFire)
						{
							stAnim.nAnimToPlay = 'StandSprayFireShotgun';							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandFireShotGun';
						}
					}
					// End:0x289
					break;
				// End:0x1D3
				case 0:
					// End:0x1C0
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchFireHandGun';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandFireHandGun';
					}
					// End:0x289
					break;
				// End:0x207
				case 5:
					// End:0x1F4
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchFireLmg';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandFireLmg';
					}
					// End:0x289
					break;
				// End:0x23B
				case 4:
					// End:0x228
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchFireAndBoltRifle';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandFireAndBoltRifle';
					}
					// End:0x289
					break;
				// End:0xFFFF
				default:
					// End:0x25A
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchFireSubGun';						
					}
					else
					{
						// End:0x276
						if(m_bSprayFire)
						{
							stAnim.nAnimToPlay = 'StandSprayFireSubGun';							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandFireSubGun';
						}
					}
					// End:0x289
					break;
					break;
			}
		}
	}
	return true;
	return;
}

//============================================================================
// function GetReloadAnimation - 
//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim)
{
	local R6EngineWeapon.eWeaponType eWT;

	m_bWeaponTransition = true;
	m_ePlayerIsUsingHands = 0;
	stAnim.bBackward = false;
	stAnim.bPlayOnce = true;
	stAnim.fRate = 1.0000000;
	stAnim.fTweenTime = 0.1000000;
	stAnim.nBlendName = 'R6 Spine2';
	// End:0x76
	if(m_bIsProne)
	{
		stAnim.nAnimToPlay = 'ProneReloadSubGun';		
	}
	else
	{
		eWT = EngineWeapon.m_eWeaponType;
		// End:0xA4
		if(EngineWeapon.m_bUseMicroAnim)
		{
			eWT = 0;
		}
		// End:0xD4
		if(((int(eWT) == int(3)) && (!EngineWeapon.IsA('R6PumpShotgun'))))
		{
			eWT = 1;
		}
		switch(eWT)
		{
			// End:0x10F
			case 0:
				// End:0xFC
				if(bIsCrouched)
				{
					stAnim.nAnimToPlay = 'CrouchReloadHandGun';					
				}
				else
				{
					stAnim.nAnimToPlay = 'StandReloadHandGun';
				}
				// End:0x175
				break;
			// End:0x143
			case 3:
				// End:0x130
				if(bIsCrouched)
				{
					stAnim.nAnimToPlay = 'CrouchReloadShotGun';					
				}
				else
				{
					stAnim.nAnimToPlay = 'StandReloadShotGun';
				}
				// End:0x175
				break;
			// End:0xFFFF
			default:
				// End:0x162
				if(bIsCrouched)
				{
					stAnim.nAnimToPlay = 'CrouchReloadSubGun';					
				}
				else
				{
					stAnim.nAnimToPlay = 'StandReloadSubGun';
				}
				// End:0x175
				break;
				break;
		}
	}
	return true;
	return;
}

//============================================================================
// vector EyePosition - 
//============================================================================
event Vector EyePosition()
{
	local Vector vEyeHeight;

	// End:0x1C
	if(bIsCrouched)
	{
		vEyeHeight.Z = 40.0000000;		
	}
	else
	{
		// End:0x38
		if(m_bIsProne)
		{
			vEyeHeight.Z = 0.0000000;			
		}
		else
		{
			// End:0x54
			if(m_bIsKneeling)
			{
				vEyeHeight.Z = 20.0000000;				
			}
			else
			{
				vEyeHeight.Z = 70.0000000;
			}
		}
	}
	return vEyeHeight;
	return;
}

//============================================================================
// StartCrouch - 
//============================================================================
event StartCrouch(float HeightAdjust)
{
	SetWalking(true);
	super.StartCrouch(HeightAdjust);
	return;
}

//============================================================================
// EndCrouch - 
//============================================================================
event EndCrouch(float fHeight)
{
	// End:0x17
	if((int(m_eMovementPace) == int(5)))
	{
		SetWalking(false);
	}
	super.EndCrouch(fHeight);
	return;
}

//============================================================================
// PlaySpecialPendingAction - Called from UpdateMovementAnimation to
//                            play special animation on all clients
//============================================================================
simulated event PlaySpecialPendingAction(R6Pawn.EPendingAction eAction, int iActionInt)
{
	switch(eAction)
	{
		// End:0x15
		case 2:
			StopCoughing();
			// End:0x98
			break;
		// End:0x23
		case 30:
			PlayThrowGrenade();
			// End:0x98
			break;
		// End:0x31
		case 31:
			PlaySurrender();
			// End:0x98
			break;
		// End:0x3F
		case 32:
			PlayKneeling();
			// End:0x98
			break;
		// End:0x4D
		case 33:
			PlayArrest();
			// End:0x98
			break;
		// End:0x5B
		case 34:
			PlayCallBackup();
			// End:0x98
			break;
		// End:0x69
		case 35:
			PlaySpecialAnim();
			// End:0x98
			break;
		// End:0x77
		case 36:
			LoopSpecialAnim();
			// End:0x98
			break;
		// End:0x85
		case 37:
			StopSpecialAnim();
			// End:0x98
			break;
		// End:0xFFFF
		default:
			super.PlaySpecialPendingAction(eAction, iActionInt);
			break;
	}
	return;
}

simulated function PlayCoughing()
{
	// End:0x0B
	if(m_bIsClimbingLadder)
	{
		return;
	}
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
	PlayAnim('StandGazed_c', 1.0000000, 0.5000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams((16 + 1), 1.0000000,,, 'R6 Spine2');
	LoopAnim('StandGazedWalkForward', 1.0000000, 0.5000000, (16 + 1));
	return;
}

simulated function StopCoughing()
{
	AnimBlendToAlpha((16 + 1), 0.0000000, 0.5000000);
	return;
}

simulated function PlayBlinded()
{
	// End:0x0B
	if(m_bIsClimbingLadder)
	{
		return;
	}
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
	// End:0x58
	if((bIsCrouched || m_bIsProne))
	{
		PlayAnim('CrouchBlinded', 1.0000000, 0.5000000, 16);		
	}
	else
	{
		PlayAnim('StandBlinded', 1.0000000, 0.5000000, 16);
	}
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlaySurrender()
{
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	ClearChannel(16);
	// End:0x52
	if(((m_bDroppedWeapon || (EngineWeapon == none)) || (int(m_eDefCon) > int(3))))
	{
		PlayAnim('RelaxToSurrender', 1.0000000, 0.2000000, 16);		
	}
	else
	{
		PlayAnim('StandToSurrender', 1.0000000, 0.2000000, 16);
	}
	AnimBlendToAlpha(16, 1.0000000, 0.1000000);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayKneeling()
{
	m_bIsKneeling = true;
	ClearChannel(16);
	PlayAnim('SurrenderToKneel', 1.0000000, 0.0000000, 16);
	AnimBlendToAlpha(16, 1.0000000, 0.1000000);
	m_bPawnSpecificAnimInProgress = true;
	PlayWaiting();
	PlayMoving();
	return;
}

simulated function PlayArrest()
{
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000);
	PlayAnim('KneelArrest', 1.0000000, 0.0000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	PlayWaiting();
	return;
}

simulated function PlayCallBackup()
{
	local name nAnimName;
	local bool bOldEngaged;

	switch(m_iPendingActionInt[int(m_iLocalCurrentActionIndex)])
	{
		// End:0x21
		case 0:
			nAnimName = 'StandYellAlarm';
			// End:0x36
			break;
		// End:0x33
		case 1:
			nAnimName = 'StandYellAlarm';
			// End:0x36
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0xB2
	if((m_iPendingActionInt[int(m_iLocalCurrentActionIndex)] == 0))
	{
		bOldEngaged = m_bEngaged;
		m_bEngaged = true;
		PlayWaiting();
		m_bEngaged = bOldEngaged;
		m_ePlayerIsUsingHands = 0;
		PlayWeaponAnimation();
		AnimBlendParams(16, 1.0000000,,, 'R6 Head');
		PlayAnim(nAnimName, 1.0000000, 0.5000000, 16);
		m_bPawnSpecificAnimInProgress = true;		
	}
	else
	{
		m_ePlayerIsUsingHands = 3;
		PlayWeaponAnimation();
		AnimBlendParams(16, 1.0000000);
		PlayAnim(nAnimName, 1.0000000, 0.5000000, 16);
		m_bPawnSpecificAnimInProgress = true;
	}
	return;
}

simulated function PlayThrowGrenade()
{
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000);
	PlayAnim('StandThrowGrenade', 1.0000000, 0.5000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayDoorAnim(R6IORotatingDoor Door)
{
	local bool bOpensTowardsPawn;
	local float fRate;

	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	ClearChannel(16);
	AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
	bOpensTowardsPawn = Door.DoorOpenTowardsActor(self);
	// End:0x88
	if((m_iPendingActionInt[int(m_iLocalCurrentActionIndex)] == 0))
	{
		// End:0x71
		if(bOpensTowardsPawn)
		{
			PlayAnim('StandDoorPull', 1.0000000, 0.1000000, 16);			
		}
		else
		{
			PlayAnim('StandDoorPush', 1.0000000, 0.1000000, 16);
		}		
	}
	else
	{
		PlayAnim('StandDoorUnlock', 1.0000000, 0.1000000, 16);
	}
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated event PlaySpecialAnim()
{
	// End:0x21
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eSpecialAnimValid = 1;
	}
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000);
	PlayAnim(m_szSpecialAnimName, 1.0000000, 0.5000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated event LoopSpecialAnim()
{
	// End:0x21
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eSpecialAnimValid = 2;
	}
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	AnimBlendParams(16, 1.0000000);
	LoopAnim(m_szSpecialAnimName, 1.0000000, 0.5000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated event StopSpecialAnim()
{
	// End:0x21
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eSpecialAnimValid = 0;
	}
	m_ePlayerIsUsingHands = 0;
	PlayWeaponAnimation();
	AnimBlendToAlpha(16, 0.0000000, 0.5000000);
	m_bPawnSpecificAnimInProgress = false;
	return;
}

function AffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	super.AffectedByGrenade(aGrenade, eType);
	// End:0x46
	if(((int(eType) == int(2)) && m_bHaveGasMask))
	{
		m_controller.m_VoicesManager.PlayTerroristVoices(self, 3);
	}
	return;
}

defaultproperties
{
	m_eDefCon=2
	m_ePersonality=2
	m_eStrategy=2
	m_iDiffLevel=2
	m_bPatrolForward=true
	m_szPrimaryWeapon="R63rdWeapons.NormalSubHKMP5A4"
	m_bCanClimbObject=true
	m_bAutoClimbLadders=true
	m_bAvoidFacingWalls=false
	m_bCanArmBomb=true
	m_bCanFireNeutrals=true
	m_fWalkingSpeed=120.0000000
	m_fWalkingBackwardStrafeSpeed=518.0000000
	m_fRunningSpeed=518.0000000
	m_fCrouchedWalkingSpeed=87.0000000
	m_fCrouchedWalkingBackwardStrafeSpeed=87.0000000
	m_fCrouchedRunningSpeed=518.0000000
	m_fCrouchedRunningBackwardStrafeSpeed=518.0000000
	m_standStairWalkUpName="StandStairWalkUp"
	m_standStairWalkUpBackName="StandWalkBack"
	m_standStairWalkUpRightName="StandWalkRight"
	m_standStairWalkDownName="StandStairWalkDown"
	m_standStairWalkDownBackName="StandWalkBack"
	m_standStairWalkDownRightName="StandWalkRight"
	m_standStairRunUpName="StandStairRunUp"
	m_standStairRunUpBackName="StandStairRunUp"
	m_standStairRunUpRightName="StandRunRight"
	m_standStairRunDownName="StandStairRunDown"
	m_standStairRunDownBackName="StandStairRunDown"
	m_standStairRunDownRightName="StandRunRight"
	m_crouchStairWalkDownName="CrouchWalkForward"
	m_crouchStairWalkDownBackName="CrouchWalkBack"
	m_crouchStairWalkDownRightName="CrouchWalkRight"
	m_crouchStairWalkUpName="CrouchWalkForward"
	m_crouchStairWalkUpBackName="CrouchWalkBack"
	m_crouchStairWalkUpRightName="CrouchWalkRight"
	m_standDefaultAnimName="Relax_nt"
	m_ePawnType=2
	m_iTeam=1
	m_bCanProne=false
	CrouchRadius=40.0000000
	m_fHeartBeatFrequency=65.0000000
	ControllerClass=Class'R6Engine.R6TerroristAI'
	m_wTickFrequency=2
	m_bReticuleInfo=false
	m_bSkipTick=true
	CollisionRadius=40.0000000
	CollisionHeight=85.0000000
	NetUpdateFrequency=10.0000000
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel22'
}
