//=============================================================================
// R6Rainbow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Rainbow.uc : This is the base pawn class for all members of Rainbow
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/04 * Created by Rima Brek
//    Eric - May 7th, 2001 - Add More Basic Animations
//
//============================================================================//
class R6Rainbow extends R6Pawn
    abstract
    native;

enum eLadderSlide
{
	SLIDE_Start,                    // 0
	SLIDE_Sliding,                  // 1
	SLIDE_End,                      // 2
	SLIDE_None                      // 3
};

enum eComAnimation
{
	COM_None,                       // 0
	COM_FollowMe,                   // 1
	COM_Cover,                      // 2
	COM_Go,                         // 3
	COM_Regroup,                    // 4
	COM_Hold                        // 5
};

enum eEquipWeapon
{
	EQUIP_SecureWeapon,             // 0
	EQUIP_EquipWeapon,              // 1
	EQUIP_NoWeapon,                 // 2
	EQUIP_Armed                     // 3
};

enum eRainbowCircumstantialAction
{
	CAR_None,                       // 0
	CAR_Secure,                     // 1
	CAR_Free                        // 2
};

var byte m_u8DesiredPitch;  // desired pitch for rainbow NPCs
var byte m_u8CurrentPitch;
var byte m_u8DesiredYaw;  // desired yaw for rainbow NPCs
var byte m_u8CurrentYaw;
// NEW IN 1.60
var R6Rainbow.eLadderSlide m_eLadderSlide;
// NEW IN 1.60
var R6Rainbow.eEquipWeapon m_eEquipWeapon;
var int m_iOperativeID;  // Id operative for the campaign file
var int m_iCurrentWeapon;
var int m_iKills;
var int m_iBulletsFired;
var int m_iBulletsHit;
var int m_iExtraPrimaryClips;
var int m_iExtraSecondaryClips;
var int m_iRainbowFaceID;
// NEW IN 1.60
var bool m_bHasDataObject;
// NEW IN 1.60
var bool m_bIsTheIntruder;
var bool m_bTweenFirstTimeOnly;  // workaround the problem of tweening
var bool m_bHasLockPickKit;
var bool m_bHasDiffuseKit;
var bool m_bHasElectronicsKit;
var bool m_bWeaponIsSecured;
var bool m_bThrowGrenadeWithLeftHand;
var bool m_bIsLockPicking;
var bool m_bReloadToFullAmmo;
var bool m_bScaleGasMaskForFemale;
var bool m_bInitRainbow;
var bool m_bGettingOnLadder;  // set to false when getting off a ladder
// for multiplayer NPCs only
var bool m_bRainbowIsFemale;
var bool m_bIsSurrended;
var bool m_bIsUnderArrest;  // true when arrested
// MPF_Milan_7_1_2003 deprecated var bool	m_bSurrenderWait;
// MPF_Milan_7_12003 deprecated var bool	m_bArrestWait;
var bool m_bIsBeingArrestedOrFreed;  // true when transitioning from surrender to arrest or from arrest to free
var Material m_FaceTexture;
var R6GasMask m_GasMask;
var R6AbstractHelmet m_Helmet;
var R6NightVision m_NightVision;
// this var is being used in the switch weapon animation system (particularly in 1st person view or in MP)
var R6EngineWeapon m_preSwitchWeapon;
// escort
var R6Hostage m_aEscortedHostage[4];
var Class<R6GasMask> m_GasMaskClass;
var Class<R6NightVision> m_NightVisionClass;
var Rotator m_rFiringRotation;
var Plane m_FaceCoords;
var Vector m_vStartLocation;
var string m_szPrimaryWeapon;
var string m_szPrimaryGadget;
var string m_szPrimaryBulletType;
var string m_szSecondaryWeapon;
var string m_szSecondaryGadget;
var string m_szSecondaryBulletType;
var string m_szPrimaryItem;
var string m_szSecondaryItem;
var string m_szSpecialityID;  // specialty of the rainbow

replication
{
	// Pos:0x034
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientQuickResetPeeking;

	// Pos:0x000
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerSetComAnim, ServerToggleNightVision;

	// Pos:0x00D
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bHasDiffuseKit, m_bHasElectronicsKit, 
		m_bHasLockPickKit, m_bRainbowIsFemale, 
		m_iExtraPrimaryClips, m_iExtraSecondaryClips, 
		m_iRainbowFaceID, m_u8DesiredPitch, 
		m_u8DesiredYaw;

	// Pos:0x01A
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientFinishAnimation;

	// Pos:0x027
	reliable if((int(Role) == int(ROLE_Authority)))
		m_NightVision, m_bIsLockPicking;

	// Pos:0x041
	reliable if((int(Role) == int(ROLE_Authority)))
		ClientSetCrouch, m_bIsSurrended, 
		m_bIsUnderArrest;

	// Pos:0x04E
	reliable if((int(Role) < int(ROLE_Authority)))
		ServerSetCrouch;

	// Pos:0x05B
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bHasDataObject, m_bIsTheIntruder;
}

// ----MissionPack1
simulated function ResetOriginalData()
{
	super(Actor).ResetOriginalData();
	m_bIsSurrended = false;
	m_bIsUnderArrest = false;
	m_bIsBeingArrestedOrFreed = false;
	return;
}

//------------------------------------------------------------------
// GetReticuleInfo
//	
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(Pawn ownerReticule, out string szName)
{
	// End:0x57
	if(m_bIsPlayer)
	{
		// End:0x30
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			szName = m_CharacterName;			
		}
		else
		{
			// End:0x52
			if((PlayerReplicationInfo != none))
			{
				szName = PlayerReplicationInfo.PlayerName;				
			}
			else
			{
				return false;
			}
		}		
	}
	else
	{
		// End:0x79
		if((m_TeamMemberRepInfo != none))
		{
			szName = m_TeamMemberRepInfo.m_CharacterName;			
		}
		else
		{
			szName = m_CharacterName;
		}
	}
	// End:0x91
	if((ownerReticule == none))
	{
		return false;
	}
	return (ownerReticule.IsFriend(self) || ownerReticule.IsNeutral(self));
	return;
}

// the following three functions are to keep stats for Rainbow in Single Player Games
function IncrementKillCount()
{
	(m_iKills++);
	return;
}

function IncrementBulletsFired()
{
	(m_iBulletsFired++);
	return;
}

function IncrementRoundsHit()
{
	(m_iBulletsHit++);
	return;
}

simulated function StartSliding()
{
	m_eLadderSlide = 0;
	SendPlaySound(R6LadderVolume(m_Ladder.MyLadder).m_SlideSound, 3);
	m_eLadderSlide = 1;
	return;
}

simulated function EndSliding()
{
	m_eLadderSlide = 2;
	SendPlaySound(R6LadderVolume(m_Ladder.MyLadder).m_SlideSoundStop, 3);
	m_eLadderSlide = 3;
	return;
}

simulated event Destroyed()
{
	// End:0x4C
	if((IsLocallyControlled() && (Controller != none)))
	{
		ToggleHeatProperties(false, none, none);
		ToggleNightProperties(false, none, none);
		ToggleScopeProperties(false, none, none);
		// End:0x4C
		if((R6PlayerController(Controller) != none))
		{
			R6PlayerController(Controller).ResetBlur();
		}
	}
	super.Destroyed();
	// End:0x70
	if((m_Helmet != none))
	{
		m_Helmet.Destroy();
		m_Helmet = none;
	}
	// End:0x8E
	if((m_NightVision != none))
	{
		m_NightVision.Destroy();
		m_NightVision = none;
	}
	// End:0xAC
	if((m_GasMask != none))
	{
		m_GasMask.Destroy();
		m_GasMask = none;
	}
	return;
}

simulated function SetRainbowFaceTexture()
{
	return;
}

simulated function AttachNightVision()
{
	// End:0x1A
	if((m_NightVision == none))
	{
		m_NightVision = Spawn(m_NightVisionClass, self);
	}
	m_NightVision.bHidden = true;
	AttachToBone(m_NightVision, 'R6 Head');
	return;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetMovementPhysics();
	// End:0x33
	if((int(Level.NetMode) != int(NM_Client)))
	{
		AttachCollisionBox(2);
		AttachNightVision();
	}
	// End:0x4A
	if((m_Helmet != none))
	{
		m_Helmet.Destroy();
	}
	// End:0x6D
	if((m_bUseSpecialSkin == true))
	{
		m_Helmet = R6AbstractHelmet(Spawn(m_HelmetClass, self));		
	}
	else
	{
		// End:0xB4
		if(((m_iDefaultTeam == 3) && (int(Level.NetMode) != int(NM_Standalone))))
		{
			m_Helmet = R6AbstractHelmet(Spawn(Level.RedHelmet, self));			
		}
		else
		{
			m_Helmet = R6AbstractHelmet(Spawn(Level.GreenHelmet, self));
		}
	}
	// End:0xEC
	if((m_Helmet != none))
	{
		AttachToBone(m_Helmet, 'R6 Head');
	}
	return;
}

simulated event PostNetBeginPlay()
{
	// End:0x74
	if((int(Level.NetMode) == int(NM_Client)))
	{
		// End:0x5C
		if((m_bIsPlayer && (PlayerReplicationInfo != none)))
		{
			bIsFemale = PlayerReplicationInfo.bIsFemale;
			m_iOperativeID = PlayerReplicationInfo.iOperativeID;			
		}
		else
		{
			bIsFemale = m_bRainbowIsFemale;
			m_iOperativeID = m_iRainbowFaceID;
		}
	}
	// End:0xAE
	if(((int(Level.NetMode) == int(NM_Client)) || (int(Level.NetMode) == int(NM_Standalone))))
	{
		SetRainbowFaceTexture();
	}
	super.PostNetBeginPlay();
	// End:0x144
	if(((int(Level.NetMode) == int(NM_ListenServer)) || (int(Level.NetMode) == int(NM_DedicatedServer))))
	{
		m_TeamMemberRepInfo = Spawn(Class'R6Engine.R6TeamMemberReplicationInfo');
		m_TeamMemberRepInfo.m_iTeam = m_iTeam;
		m_TeamMemberRepInfo.Instigator = self;
		m_TeamMemberRepInfo.m_CharacterName = m_CharacterName;
		m_TeamMemberRepInfo.m_iTeamPosition = byte(m_iID);
	}
	InitializeRainbowAnimations();
	return;
}

simulated function InitializeRainbowAnimations()
{
	// End:0x2B
	if((int(Physics) == int(11)))
	{
		m_eEquipWeapon = 2;
		m_ePlayerIsUsingHands = 3;
		PlayAnim('StandLadder_nt');		
	}
	else
	{
		// End:0x3F
		if(m_bIsProne)
		{
			PlayAnim('ProneWaitBreathe');			
		}
		else
		{
			// End:0x53
			if(bIsCrouched)
			{
				PlayAnim('CrouchWaitBreathe01');				
			}
			else
			{
				PlayAnim('StandWaitBreathe');
			}
		}
	}
	PlayWeaponAnimation();
	// End:0x9D
	if((int(m_ePeekingMode) == int(1)))
	{
		// End:0x8D
		if(m_bPeekingLeft)
		{
			m_fPeeking = (m_fPeekingGoal + float(1));			
		}
		else
		{
			m_fPeeking = (m_fPeekingGoal - float(1));
		}
	}
	return;
}

function PossessedBy(Controller C)
{
	super.PossessedBy(C);
	// End:0x21
	if((!m_bIsPlayer))
	{
		bCanStrafe = false;		
	}
	else
	{
		// End:0x90
		if(((int(Level.NetMode) == int(NM_DedicatedServer)) || (int(Level.NetMode) == int(NM_ListenServer))))
		{
			// End:0x90
			if((PlayerReplicationInfo != none))
			{
				bIsFemale = PlayerReplicationInfo.bIsFemale;
				m_iOperativeID = PlayerReplicationInfo.iOperativeID;
				SetRainbowFaceTexture();
			}
		}
	}
	return;
}

function UnPossessed()
{
	// End:0x58
	if(((!m_bIsClimbingLadder) && (m_Ladder != none)))
	{
		R6LadderVolume(m_Ladder.MyLadder).RemoveClimber(self);
		R6LadderVolume(m_Ladder.MyLadder).DisableCollisions(m_Ladder);
	}
	super(Pawn).UnPossessed();
	return;
}

simulated event AnimEnd(int iChannel)
{
	// End:0x53
	if((((int(m_bIsFiringWeapon) > 0) && ((EngineWeapon != none) && (!EngineWeapon.IsA('R6GrenadeWeapon')))) && (int(m_ePlayerIsUsingHands) != int(0))))
	{
		// End:0x53
		if(m_bNightVisionAnimation)
		{
			SecureNightVisionGoggles();
		}
	}
	// End:0x9B
	if((iChannel == 0))
	{
		m_bInitRainbow = false;
		// End:0x82
		if((m_bIsPlayer && m_bSlideEnd))
		{
			m_bSlideEnd = false;
		}
		// End:0x98
		if((int(Physics) != int(12)))
		{
			PlayWaiting();
		}		
	}
	else
	{
		// End:0x110
		if((iChannel == 1))
		{
			// End:0xFE
			if(((m_bPostureTransition && (!m_bInteractingWithDevice)) && (!m_bIsLockPicking)))
			{
				// End:0xD8
				if(m_bNightVisionAnimation)
				{
					SecureNightVisionGoggles();
				}
				m_bSoundChangePosture = false;
				m_bIsLanding = false;
				m_bPostureTransition = false;
				m_ePlayerIsUsingHands = 0;
				PlayWeaponAnimation();
			}
			// End:0x10D
			if(bIsCrouched)
			{
				BlendKneeOnGround();
			}			
		}
		else
		{
			// End:0x132
			if(((iChannel == 16) && m_bPawnSpecificAnimInProgress))
			{
				m_bPawnSpecificAnimInProgress = false;				
			}
			else
			{
				// End:0x1A7
				if((iChannel == 15))
				{
					// End:0x15A
					if(((!m_bIsPlayer) && m_bReloadToFullAmmo))
					{
						FinishedReloadingWeapon();
					}
					// End:0x1A4
					if((m_bPlayingComAnimation || m_bNightVisionAnimation))
					{
						m_bPlayingComAnimation = false;
						// End:0x196
						if(m_bNightVisionAnimation)
						{
							// End:0x190
							if(IsUsingHeartBeatSensor())
							{
								R6ResetAnimBlendParams(15);
							}
							SecureNightVisionGoggles();
						}
						m_ePlayerIsUsingHands = 0;
						PlayWeaponAnimation();
					}					
				}
				else
				{
					// End:0x211
					if(((iChannel == 14) && m_bWeaponTransition))
					{
						m_bWeaponTransition = false;
						// End:0x20B
						if((int(Role) == int(ROLE_Authority)))
						{
							// End:0x1EC
							if((int(m_eGrenadeThrow) != int(3)))
							{
								PlayWeaponAnimation();
							}
							// End:0x20B
							if((int(Level.NetMode) != int(NM_Standalone)))
							{
								ClientFinishAnimation();
							}
						}
						PlayWeaponAnimation();
					}
				}
			}
		}
	}
	return;
}

// this is used as a backup - to make sure if the activation or deactivation of the night vision was
// interrupted, the final state of the goggles is correct.
simulated function SecureNightVisionGoggles()
{
	m_bNightVisionAnimation = false;
	// End:0x55
	if(m_bActivateNightVision)
	{
		m_NightVision.bHidden = false;
		AttachToBone(m_NightVision, 'R6 Head');
		// End:0x52
		if((int(m_eArmorType) == int(3)))
		{
			m_Helmet.SetHelmetStaticMesh(true);
		}		
	}
	else
	{
		m_NightVision.bHidden = true;
		// End:0x93
		if(((int(m_eArmorType) == int(3)) && (!m_bHaveGasMask)))
		{
			m_Helmet.SetHelmetStaticMesh(false);
		}
	}
	m_ePlayerIsUsingHands = 0;
	PlayWeaponAnimation();
	return;
}

simulated function PlayActivateNightVisionAnimation()
{
	m_ePlayerIsUsingHands = 2;
	PlayWeaponAnimation();
	m_bActivateNightVision = true;
	AnimBlendParams(15, 1.0000000,,, 'R6 L Clavicle');
	m_bNightVisionAnimation = true;
	// End:0x52
	if(m_bIsProne)
	{
		PlayAnim('ProneNightVision', 1.0000000, 0.2000000, 15);		
	}
	else
	{
		PlayAnim('CrouchNightVision', 1.0000000, 0.2000000, 15);
	}
	return;
}

simulated function PlayDeactivateNightVisionAnimation()
{
	m_ePlayerIsUsingHands = 2;
	PlayWeaponAnimation();
	m_bActivateNightVision = false;
	AnimBlendParams(15, 1.0000000,,, 'R6 L Clavicle');
	m_bNightVisionAnimation = true;
	// End:0x53
	if(m_bIsProne)
	{
		PlayAnim('ProneNightVision', 1.0000000, 0.2000000, 15, true);		
	}
	else
	{
		PlayAnim('CrouchNightVision', 1.0000000, 0.2000000, 15, true);
	}
	return;
}

simulated function GetNightVision()
{
	// End:0x0D
	if((!m_bActivateNightVision))
	{
		return;
	}
	AttachToBone(m_NightVision, 'TagNightVision');
	m_NightVision.bHidden = false;
	return;
}

simulated function RaiseHelmetVisor()
{
	// End:0x0D
	if((!m_bActivateNightVision))
	{
		return;
	}
	// End:0x2D
	if((int(m_eArmorType) == int(3)))
	{
		m_Helmet.SetHelmetStaticMesh(true);
	}
	return;
}

simulated function ActivateNightVision()
{
	// End:0x0D
	if((!m_bActivateNightVision))
	{
		return;
	}
	AttachToBone(m_NightVision, 'R6 Head');
	return;
}

simulated function RemoveNightVision()
{
	// End:0x0B
	if(m_bActivateNightVision)
	{
		return;
	}
	AttachToBone(m_NightVision, 'TagNightVision');
	m_NightVision.bHidden = false;
	return;
}

simulated function DeactivateNightVision()
{
	// End:0x0B
	if(m_bActivateNightVision)
	{
		return;
	}
	// End:0x38
	if(((int(m_eArmorType) == int(3)) && (!m_bHaveGasMask)))
	{
		m_Helmet.SetHelmetStaticMesh(false);
	}
	m_NightVision.bHidden = true;
	return;
}

exec function ToggleNightVision()
{
	// End:0x28
	if((((int(Physics) != int(1)) || m_bIsLanding) || m_bPostureTransition))
	{
		return;
	}
	// End:0x37
	if(m_bNightVisionAnimation)
	{
		SecureNightVisionGoggles();
	}
	super.ToggleNightVision();
	return;
}

// NEW IN 1.60
function MandatoryToggleNightVision()
{
	ToggleNightVision();
	return;
}

function ServerToggleNightVision(bool bActivateNightVision)
{
	m_bActivateNightVision = bActivateNightVision;
	// End:0x21
	if(bActivateNightVision)
	{
		SetNextPendingAction(25);		
	}
	else
	{
		SetNextPendingAction(26);
	}
	return;
}

function ClientFinishAnimation()
{
	m_bWeaponTransition = false;
	// End:0x1E
	if((int(m_eGrenadeThrow) != int(3)))
	{
		PlayWeaponAnimation();
	}
	return;
}

simulated function float ArmorSkillEffect()
{
	// End:0x19
	if((int(m_eArmorType) == int(3)))
	{
		return 0.6000000;		
	}
	else
	{
		// End:0x2F
		if((int(m_eArmorType) == int(2)))
		{
			return 0.8000000;
		}
	}
	return 1.0000000;
	return;
}

function Vector GetHandLocation()
{
	// End:0x1D
	if(m_bThrowGrenadeWithLeftHand)
	{
		return GetBoneCoords('R6 L Hand').Origin;		
	}
	else
	{
		return GetBoneCoords('R6 R Hand').Origin;
	}
	return;
}

event EndOfGrenadeEffect(Pawn.EGrenadeType eType)
{
	// End:0x0B
	if(m_bIsPlayer)
	{
		return;
	}
	// End:0x3C
	if((int(eType) == int(2)))
	{
		R6RainbowAI(Controller).m_TeamManager.GasGrenadeCleared(self);		
	}
	else
	{
		// End:0x4C
		if((int(eType) == int(3)))
		{
		}
	}
	return;
}

function TurnAwayFromNearbyWalls()
{
	// End:0x1F
	if(((Controller == none) || (R6RainbowAI(Controller) == none)))
	{
		return;
	}
	// End:0x5D
	if((((!m_bIsProne) && (!m_bIsClimbingStairs)) && (int(R6RainbowAI(Controller).m_eFormation) != int(1))))
	{
		super.TurnAwayFromNearbyWalls();
	}
	return;
}

simulated function PlayStartClimbing()
{
	m_bGettingOnLadder = true;
	super.PlayStartClimbing();
	return;
}

simulated function PlayEndClimbing()
{
	m_bGettingOnLadder = false;
	super.PlayEndClimbing();
	return;
}

//===================================================================================================
// ClimbStairs()
//===================================================================================================
simulated function ClimbStairs(Vector vStairDirection)
{
	// End:0x2E
	if(((!m_bIsPlayer) && (Controller != none)))
	{
		R6RainbowAI(Controller).m_bUseStaggeredFormation = false;
	}
	super.ClimbStairs(vStairDirection);
	return;
}

//===================================================================================================
// EndClimbStairs()
//===================================================================================================
simulated function EndClimbStairs()
{
	// End:0x2E
	if(((!m_bIsPlayer) && (Controller != none)))
	{
		R6RainbowAI(Controller).m_bUseStaggeredFormation = true;
	}
	super.EndClimbStairs();
	return;
}

simulated function PlaySecureTerrorist()
{
	R6ResetAnimBlendParams(13);
	m_ePlayerIsUsingHands = 3;
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	PlayAnim('StandArrest', 1.0000000, 0.2000000, 1);
	return;
}

// MPF_Milan2 - changed all channels to specific
simulated function PlayStartSurrender()
{
	R6ResetAnimBlendParams(16);
	ClearChannel(16);
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim('RelaxToSurrender', 1.0000000, 0.2000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlaySurrender()
{
	m_ePlayerIsUsingHands = 3;
	AnimBlendParams(16, 1.0000000);
	PlayAnim('SurrenderWaitBreathe', 1.0000000, 0.0000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayEndSurrender()
{
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 0;
	PlayAnim('RelaxToSurrender', 1.0000000, 0.2000000, 16, true);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayArrest()
{
	ClearChannel(16);
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim('SurrenderToKneel', 1.0000000, 0.2000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayArrestKneel()
{
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim('KneelArrest', 1.0000000, 0.2000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

// MPF_Milan_7_1_2003 - changed to specific channel, not loop
simulated function PlayArrestWaiting()
{
	local name Anim;

	SetRandomWaiting(4);
	switch(m_bRepPlayWaitAnim)
	{
		// End:0x22
		case 0:
			Anim = 'KneelArrestWait01';
			// End:0x30
			break;
		// End:0xFFFF
		default:
			Anim = 'KneelArrestWait02';
			break;
	}
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim(Anim, 1.0000000, 0.2000000, 16);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

// NEW
simulated function PlayEndArrest()
{
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim('KneelArrest', 1.0000000, 0.2000000, 16, true);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlaySetFree()
{
	AnimBlendParams(16, 1.0000000);
	m_ePlayerIsUsingHands = 3;
	PlayAnim('SurrenderToKneel', 1.0000000, 0.2000000, 16, true);
	m_bPawnSpecificAnimInProgress = true;
	return;
}

simulated function PlayPostEndSurrender()
{
	m_ePlayerIsUsingHands = 0;
	return;
}

simulated function PlayLockPickDoorAnim()
{
	m_ePlayerIsUsingHands = 3;
	R6ResetAnimBlendParams(13);
	PlayWeaponAnimation();
	m_bPostureTransition = true;
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000);
	// End:0x53
	if(bIsCrouched)
	{
		LoopAnim('CrouchLockPick_c', 2.0000000, 0.2000000, 1);		
	}
	else
	{
		LoopAnim('StandLockPick_c', 2.0000000, 0.2000000, 1);
	}
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
		case 15:
			PlayRemoteChargeAnimation();
			// End:0x166
			break;
		// End:0x23
		case 17:
			PlayClaymoreAnimation();
			// End:0x166
			break;
		// End:0x31
		case 16:
			PlayBreachDoorAnimation();
			// End:0x166
			break;
		// End:0x3F
		case 19:
			PlayLockPickDoorAnim();
			// End:0x166
			break;
		// End:0x4F
		case 20:
			PlayCommunicationAnimation(1);
			// End:0x166
			break;
		// End:0x5F
		case 21:
			PlayCommunicationAnimation(2);
			// End:0x166
			break;
		// End:0x6F
		case 22:
			PlayCommunicationAnimation(3);
			// End:0x166
			break;
		// End:0x7F
		case 23:
			PlayCommunicationAnimation(4);
			// End:0x166
			break;
		// End:0x8F
		case 24:
			PlayCommunicationAnimation(5);
			// End:0x166
			break;
		// End:0x9D
		case 25:
			PlayActivateNightVisionAnimation();
			// End:0x166
			break;
		// End:0xAB
		case 26:
			PlayDeactivateNightVisionAnimation();
			// End:0x166
			break;
		// End:0xB9
		case 27:
			RainbowSecureWeapon();
			// End:0x166
			break;
		// End:0xC7
		case 28:
			RainbowEquipWeapon();
			// End:0x166
			break;
		// End:0xD5
		case 29:
			PlaySecureTerrorist();
			// End:0x166
			break;
		// End:0xE3
		case 40:
			PlayStartSurrender();
			// End:0x166
			break;
		// End:0xF1
		case 31:
			PlaySurrender();
			// End:0x166
			break;
		// End:0xFF
		case 39:
			PlayEndSurrender();
			// End:0x166
			break;
		// End:0x10D
		case 33:
			PlayArrest();
			// End:0x166
			break;
		// End:0x11B
		case 43:
			PlayArrestKneel();
			// End:0x166
			break;
		// End:0x129
		case 44:
			PlayArrestWaiting();
			// End:0x166
			break;
		// End:0x137
		case 45:
			PlayEndArrest();
			// End:0x166
			break;
		// End:0x145
		case 42:
			PlaySetFree();
			// End:0x166
			break;
		// End:0x153
		case 41:
			PlayPostEndSurrender();
			// End:0x166
			break;
		// End:0xFFFF
		default:
			super.PlaySpecialPendingAction(eAction, iActionInt);
			break;
	}
	return;
}

simulated function ResetPawnSpecificAnimation()
{
	m_ePlayerIsUsingHands = 0;
	m_bPawnSpecificAnimInProgress = false;
	R6ResetAnimBlendParams(16);
	return;
}

simulated function PlayCoughing()
{
	// End:0x16
	if((m_bIsClimbingLadder || m_bWeaponTransition))
	{
		return;
	}
	m_ePlayerIsUsingHands = 3;
	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams(16, 1.0000000, 0.5000000, 0.0000000, 'R6 Spine');
	// End:0x62
	if(m_bIsProne)
	{
		PlayAnim('ProneGazed', 1.0000000, 0.0000000, 16);		
	}
	else
	{
		// End:0x82
		if(bIsCrouched)
		{
			PlayAnim('CrouchGazed', 1.0000000, 0.0000000, 16);			
		}
		else
		{
			PlayAnim('StandGazed', 1.0000000, 0.0000000, 16);
		}
	}
	return;
}

simulated function PlayBlinded()
{
	// End:0x16
	if((m_bIsClimbingLadder || m_bWeaponTransition))
	{
		return;
	}
	m_ePlayerIsUsingHands = 3;
	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams(16, 1.0000000, 0.5000000, 0.0000000, 'R6 Spine');
	// End:0x62
	if(m_bIsProne)
	{
		PlayAnim('ProneBlinded', 1.0000000, 0.0000000, 16);		
	}
	else
	{
		// End:0x82
		if(bIsCrouched)
		{
			PlayAnim('CrouchBlinded', 1.0000000, 0.0000000, 16);			
		}
		else
		{
			PlayAnim('StandBlinded', 1.0000000, 0.0000000, 16);
		}
	}
	return;
}

simulated function SetCommunicationAnimation(R6Rainbow.eComAnimation eComAnim)
{
	ServerSetComAnim(eComAnim);
	return;
}

simulated function ServerSetComAnim(R6Rainbow.eComAnimation eComAnim)
{
	switch(eComAnim)
	{
		// End:0x17
		case 1:
			SetNextPendingAction(20);
			// End:0x5A
			break;
		// End:0x27
		case 2:
			SetNextPendingAction(21);
			// End:0x5A
			break;
		// End:0x37
		case 3:
			SetNextPendingAction(22);
			// End:0x5A
			break;
		// End:0x47
		case 4:
			SetNextPendingAction(23);
			// End:0x5A
			break;
		// End:0x57
		case 5:
			SetNextPendingAction(24);
			// End:0x5A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

simulated function PlayCommunicationAnimation(R6Rainbow.eComAnimation eComAnim)
{
	// End:0x16
	if((m_bReloadingWeapon || m_bChangingWeapon))
	{
		return;
	}
	m_ePlayerIsUsingHands = 2;
	PlayWeaponAnimation();
	AnimBlendParams(15, 1.0000000,,, 'R6 L Clavicle');
	m_bPlayingComAnimation = true;
	switch(eComAnim)
	{
		// End:0x83
		case 1:
			// End:0x6C
			if(m_bIsProne)
			{
				PlayAnim('ProneComFollowMe', 1.0000000, 0.2000000, 15);				
			}
			else
			{
				PlayAnim('StandComFollowMe', 1.0000000, 0.2000000, 15);
			}
			// End:0x176
			break;
		// End:0xBF
		case 2:
			// End:0xA8
			if(m_bIsProne)
			{
				PlayAnim('ProneComCover', 1.0000000, 0.2000000, 15);				
			}
			else
			{
				PlayAnim('StandComCover', 1.0000000, 0.2000000, 15);
			}
			// End:0x176
			break;
		// End:0xFB
		case 3:
			// End:0xE4
			if(m_bIsProne)
			{
				PlayAnim('ProneComGo', 1.0000000, 0.2000000, 15);				
			}
			else
			{
				PlayAnim('StandComGo', 1.0000000, 0.2000000, 15);
			}
			// End:0x176
			break;
		// End:0x137
		case 4:
			// End:0x120
			if(m_bIsProne)
			{
				PlayAnim('ProneComRegroup', 1.0000000, 0.2000000, 15);				
			}
			else
			{
				PlayAnim('StandComRegroup', 1.0000000, 0.2000000, 15);
			}
			// End:0x176
			break;
		// End:0x173
		case 5:
			// End:0x15C
			if(m_bIsProne)
			{
				PlayAnim('ProneComHold', 1.0000000, 0.2000000, 15);				
			}
			else
			{
				PlayAnim('StandComHold', 1.0000000, 0.2000000, 15);
			}
			// End:0x176
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

simulated function RainbowSecureWeapon()
{
	// End:0x28
	if(((!m_bIsPlayer) && (EngineWeapon != none)))
	{
		EngineWeapon.GotoState('PutWeaponDown');
	}
	m_eEquipWeapon = 0;
	PlayWeaponAnimation();
	return;
}

simulated function RainbowEquipWeapon()
{
	// End:0x28
	if(((!m_bIsPlayer) && (EngineWeapon != none)))
	{
		EngineWeapon.GotoState('BringWeaponUp');
	}
	m_eEquipWeapon = 1;
	PlayWeaponAnimation();
	return;
}

simulated function bool CheckForPassiveGadget(string aClassName)
{
	// End:0x23
	if((aClassName == "PRIMARYMAGS"))
	{
		(m_iExtraPrimaryClips++);
		return true;		
	}
	else
	{
		// End:0x48
		if((aClassName == "SECONDARYMAGS"))
		{
			(m_iExtraSecondaryClips++);
			return true;			
		}
		else
		{
			// End:0x6C
			if((aClassName == "LOCKPICKKIT"))
			{
				m_bHasLockPickKit = true;
				return true;				
			}
			else
			{
				// End:0x8F
				if((aClassName == "DIFFUSEKIT"))
				{
					m_bHasDiffuseKit = true;
					return true;					
				}
				else
				{
					// End:0xB5
					if((aClassName == "ELECTRONICKIT"))
					{
						m_bHasElectronicsKit = true;
						return true;						
					}
					else
					{
						// End:0xD5
						if((aClassName == "GASMASK"))
						{
							m_bHaveGasMask = true;
							return true;							
						}
						else
						{
							// End:0x10F
							if((aClassName == "DoubleGadget"))
							{
								// End:0x10D
								if((GetWeaponInGroup(3) != none))
								{
									GetWeaponInGroup(3).GiveMoreAmmo();
								}
								return true;
							}
						}
					}
				}
			}
		}
	}
	return false;
	return;
}

simulated function GiveDefaultWeapon()
{
	local int iLastAllocated, i;
	local string szCurrentGadget, caps_szPrimaryWeapon, caps_szSecondaryWeapon, caps_szCurrentGadget;

	// End:0x2B8
	if(((int(Level.NetMode) == int(NM_Standalone)) || (!m_bIsPlayer)))
	{
		caps_szPrimaryWeapon = Caps(m_szPrimaryWeapon);
		// End:0x71
		if(((caps_szPrimaryWeapon != "R6WEAPONS.NONE") && (caps_szPrimaryWeapon != "")))
		{
			ServerGivesWeaponToClient(m_szPrimaryWeapon, 1, m_szPrimaryBulletType, m_szPrimaryGadget);
		}
		caps_szSecondaryWeapon = Caps(m_szSecondaryWeapon);
		// End:0xBD
		if(((caps_szSecondaryWeapon != "R6WEAPONS.NONE") && (caps_szSecondaryWeapon != "")))
		{
			ServerGivesWeaponToClient(m_szSecondaryWeapon, 2, m_szSecondaryBulletType, m_szSecondaryGadget);
		}
		iLastAllocated = 3;
		i = 0;
		J0xCC:

		// End:0x26B [Loop If]
		if((i < 2))
		{
			// End:0xF1
			if((i == 0))
			{
				szCurrentGadget = m_szPrimaryItem;				
			}
			else
			{
				szCurrentGadget = m_szSecondaryItem;
			}
			caps_szCurrentGadget = Caps(szCurrentGadget);
			// End:0x261
			if(((caps_szCurrentGadget != "R6WEAPONGADGETS.NONE") && (caps_szCurrentGadget != "")))
			{
				// End:0x162
				if((caps_szCurrentGadget == "PRIMARYMAGS"))
				{
					GetWeaponInGroup(1).AddExtraClip();
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x190
				if((caps_szCurrentGadget == "SECONDARYMAGS"))
				{
					GetWeaponInGroup(2).AddExtraClip();
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x1B2
				if((caps_szCurrentGadget == "LOCKPICKKIT"))
				{
					m_bHasLockPickKit = true;
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x1D3
				if((caps_szCurrentGadget == "DIFFUSEKIT"))
				{
					m_bHasDiffuseKit = true;
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x1F7
				if((caps_szCurrentGadget == "ELECTRONICKIT"))
				{
					m_bHasElectronicsKit = true;
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x215
				if((caps_szCurrentGadget == "GASMASK"))
				{
					m_bHaveGasMask = true;
					// [Explicit Continue]
					goto J0x261;
				}
				// End:0x24A
				if(((i == 1) && (Caps(m_szPrimaryItem) == Caps(m_szSecondaryItem))))
				{
					GetWeaponInGroup(3).GiveMoreAmmo();
					// [Explicit Continue]
					goto J0x261;
				}
				ServerGivesWeaponToClient(szCurrentGadget, iLastAllocated);
				(iLastAllocated++);
			}
			J0x261:

			(i++);
			// [Loop Continue]
			goto J0xCC;
		}
		// End:0x2B2
		if((Controller != none))
		{
			Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
			Controller.m_PawnRepInfo.m_bSex = bIsFemale;
		}
		ReceivedWeapons();
	}
	// End:0x2C7
	if(m_bHaveGasMask)
	{
		AttachGasMask();
	}
	return;
}

simulated function AttachGasMask()
{
	// End:0x2B
	if((m_Helmet != none))
	{
		// End:0x2B
		if((int(m_eArmorType) == int(3)))
		{
			m_Helmet.SetHelmetStaticMesh(true);
		}
	}
	// End:0x54
	if((m_GasMask == none))
	{
		m_GasMask = Spawn(m_GasMaskClass);
		AttachToBone(m_GasMask, 'R6 Head');
	}
	// End:0x7C
	if((bIsFemale && m_bScaleGasMaskForFemale))
	{
		m_GasMask.DrawScale = 1.0000000;
	}
	return;
}

simulated event ReceivedEngineWeapon()
{
	AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	PlayWeaponAnimation();
	return;
}

simulated event PlayWeaponAnimation()
{
	// End:0x4B
	if((m_bPawnSpecificAnimInProgress && (((m_bReloadingWeapon || m_bChangingWeapon) || EngineWeapon.bFiredABullet) || (int(m_eGrenadeThrow) != int(0)))))
	{
		ResetPawnSpecificAnimation();
	}
	super.PlayWeaponAnimation();
	return;
}

simulated event ReceivedWeapons()
{
	local int i;
	local R6EngineWeapon AWeapon;

	// End:0x2A
	if(((int(Level.NetMode) != int(NM_Standalone)) && m_bHaveGasMask))
	{
		AttachGasMask();
	}
	i = 1;
	J0x31:

	// End:0x153 [Loop If]
	if((i <= 4))
	{
		AWeapon = GetWeaponInGroup(i);
		// End:0x149
		if((AWeapon != none))
		{
			// End:0x82
			if((i == 4))
			{
				AWeapon.m_HoldAttachPoint = AWeapon.m_HoldAttachPoint2;
			}
			AttachWeapon(AWeapon, AWeapon.m_HoldAttachPoint);
			AWeapon.WeaponInitialization(self);
			// End:0x149
			if(IsLocallyControlled())
			{
				// End:0xD0
				if(m_bIsPlayer)
				{
					AWeapon.LoadFirstPersonWeapon(self);					
				}
				else
				{
					AWeapon.RemoteRole = ROLE_SimulatedProxy;
				}
				// End:0x119
				if((i == 1))
				{
					// End:0x119
					if(m_bIsPlayer)
					{
						J0xF5:

						// End:0x119 [Loop If]
						if((m_iExtraPrimaryClips > 0))
						{
							AWeapon.AddExtraClip();
							(m_iExtraPrimaryClips--);
							// [Loop Continue]
							goto J0xF5;
						}
					}
				}
				// End:0x149
				if((i == 2))
				{
					J0x125:

					// End:0x149 [Loop If]
					if((m_iExtraSecondaryClips > 0))
					{
						AWeapon.AddExtraClip();
						(m_iExtraSecondaryClips--);
						// [Loop Continue]
						goto J0x125;
					}
				}
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x31;
	}
	// End:0x20C
	if(IsLocallyControlled())
	{
		EngineWeapon = GetWeaponInGroup(1);
		m_iCurrentWeapon = 1;
		// End:0x18C
		if((m_SoundRepInfo != none))
		{
			m_SoundRepInfo.m_CurrentWeapon = 0;
		}
		// End:0x1C9
		if((EngineWeapon == none))
		{
			EngineWeapon = GetWeaponInGroup(2);
			// End:0x1C1
			if((m_SoundRepInfo != none))
			{
				m_SoundRepInfo.m_CurrentWeapon = 1;
			}
			m_iCurrentWeapon = 2;
		}
		// End:0x20C
		if((EngineWeapon != none))
		{
			ServerChangedWeapon(none, EngineWeapon);
			// End:0x1FC
			if(m_bIsPlayer)
			{
				EngineWeapon.GotoState('RaiseWeapon');				
			}
			else
			{
				EngineWeapon.GotoState('None');
			}
		}
	}
	// End:0x230
	if((EngineWeapon != none))
	{
		AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);
	}
	PlayWeaponAnimation();
	return;
}

function SetMovementPhysics()
{
	SetPhysics(1);
	return;
}

// choose a random wait animation to play; this overrides the function in R6Pawn.uc
simulated function PlayWaiting()
{
	// End:0x0B
	if(m_bSlideEnd)
	{
		return;
	}
	// End:0x16
	if(m_bInitRainbow)
	{
		return;
	}
	// End:0x2E
	if((int(Physics) == int(2)))
	{
		PlayFalling();
		return;
	}
	// End:0x3F
	if(m_bIsClimbingLadder)
	{
		AnimateStoppedOnLadder();
		return;
	}
	// End:0x50
	if(bIsCrouched)
	{
		PlayCrouchWaiting();
		return;
	}
	// End:0x61
	if(m_bIsProne)
	{
		PlayProneWaiting();
		return;
	}
	// End:0x74
	if((!m_bNightVisionAnimation))
	{
		m_ePlayerIsUsingHands = 0;
	}
	// End:0xE6
	if((((m_fPeeking != 1000.0000000) || IsPeeking()) || (int(m_u8CurrentYaw) != 0)))
	{
		// End:0xB6
		if((bIsCrouched != bWasCrouched))
		{
			m_bTweenFirstTimeOnly = true;
		}
		// End:0xDC
		if(m_bTweenFirstTimeOnly)
		{
			PlayPeekingAnim(true);
			m_bTweenFirstTimeOnly = false;
			R6PlayAnim('StandWaitBreathe');			
		}
		else
		{
			PlayAnim('StandWaitBreathe');
		}
		return;
	}
	// End:0x12D
	if(((m_bIsPlayer || (m_TrackActor != none)) || m_bIsSniping))
	{
		// End:0x120
		if((EngineWeapon != none))
		{
			R6PlayAnim('StandWaitBreathe');			
		}
		else
		{
			R6PlayAnim('StandSubGunHigh_nt');
		}
		return;
	}
	SetRandomWaiting(12);
	switch(m_bRepPlayWaitAnim)
	{
		// End:0x14F
		case 0:
			R6PlayAnim('StandWaitBreathe');
			// End:0x21E
			break;
		// End:0x162
		case 1:
			R6PlayAnim('StandWaitCrackNeck');
			// End:0x21E
			break;
		// End:0x175
		case 2:
			R6PlayAnim('StandWaitLookAround01');
			// End:0x21E
			break;
		// End:0x188
		case 3:
			R6PlayAnim('StandWaitLookAround02');
			// End:0x21E
			break;
		// End:0x19B
		case 4:
			R6PlayAnim('StandWaitLookBack01');
			// End:0x21E
			break;
		// End:0x1AE
		case 5:
			R6PlayAnim('StandWaitLookBack02');
			// End:0x21E
			break;
		// End:0x1C1
		case 6:
			R6PlayAnim('StandWaitLookWatch');
			// End:0x21E
			break;
		// End:0x1D4
		case 7:
			R6PlayAnim('StandWaitScratchNose');
			// End:0x21E
			break;
		// End:0x1E7
		case 8:
			R6PlayAnim('StandWaitShiftWeight');
			// End:0x21E
			break;
		// End:0x1FA
		case 9:
			R6PlayAnim('StandWaitUpDown01');
			// End:0x21E
			break;
		// End:0x20D
		case 10:
			R6PlayAnim('StandWaitUpDown02');
			// End:0x21E
			break;
		// End:0xFFFF
		default:
			R6PlayAnim('StandWaitWipeFace');
			// End:0x21E
			break;
			break;
	}
	return;
}

simulated event SetAnimAction(name NewAction)
{
	AnimAction = NewAction;
	AnimBlendParams(14, 1.0000000, 0.2000000, 0.0000000, 'R6 Spine2');
	PlayAnim(NewAction, 1.0000000, 0.0000000, 14);
	return;
}

simulated function StopPeeking()
{
	// End:0x1D
	if((int(m_ePeekingMode) == int(1)))
	{
		SetPeekingInfo(0, 1000.0000000);
	}
	return;
}

simulated function ClientQuickResetPeeking()
{
	SetPeekingInfo(0, 1000.0000000);
	SetCrouchBlend(0.0000000);
	return;
}

event EndCrouch(float fHeight)
{
	super.EndCrouch(fHeight);
	EndKneeDown();
	return;
}

simulated function PlayDuck()
{
	PlayCrouchWaiting();
	return;
}

simulated function BlendKneeOnGround()
{
	// End:0x0B
	if(m_bPostureTransition)
	{
		return;
	}
	AnimBlendParams(1, 1.0000000, 0.0000000, 0.0000000, 'R6 R Thigh');
	LoopAnim('Kneel_nt', 1.0000000, 0.2000000, 1);
	return;
}

simulated function EndKneeDown()
{
	PlayAnim('CrouchSubGunLow_nt', 1.0000000, 0.2000000, 1);
	AnimBlendToAlpha(1, 0.0000000, 0.5000000);
	return;
}

event StartCrouch(float HeightAdjust)
{
	super.StartCrouch(HeightAdjust);
	return;
}

simulated function PlayCrouchWaiting()
{
	// End:0x18
	if((int(Physics) == int(2)))
	{
		PlayFalling();
		return;
	}
	// End:0x2B
	if((!m_bNightVisionAnimation))
	{
		m_ePlayerIsUsingHands = 0;
	}
	// End:0x8E
	if(((m_fPeeking != 1000.0000000) || IsPeeking()))
	{
		// End:0x5E
		if((bIsCrouched != bWasCrouched))
		{
			m_bTweenFirstTimeOnly = true;
		}
		// End:0x84
		if(m_bTweenFirstTimeOnly)
		{
			PlayPeekingAnim(true);
			m_bTweenFirstTimeOnly = false;
			R6PlayAnim('CrouchWaitBreathe01');			
		}
		else
		{
			PlayAnim('CrouchWaitBreathe01');
		}
		return;
	}
	// End:0xBD
	if(((m_bIsPlayer || (m_TrackActor != none)) || m_bIsSniping))
	{
		R6PlayAnim('CrouchWaitBreathe01');		
	}
	else
	{
		SetRandomWaiting(5);
		switch(m_bRepPlayWaitAnim)
		{
			// End:0xDF
			case 0:
				R6PlayAnim('CrouchWaitBreathe01');
				// End:0x126
				break;
			// End:0xF2
			case 1:
				R6PlayAnim('CrouchWaitBreathe02');
				// End:0x126
				break;
			// End:0x105
			case 2:
				R6PlayAnim('CrouchWaitCrackNeck');
				// End:0x126
				break;
			// End:0x118
			case 3:
				R6PlayAnim('CrouchWaitLookWatch');
				// End:0x126
				break;
			// End:0xFFFF
			default:
				R6PlayAnim('CrouchWaitLookUp');
				break;
		}
	}
	// End:0x14E
	if(((int(Physics) != int(12)) && (int(m_eEquipWeapon) != int(2))))
	{
		BlendKneeOnGround();
	}
	return;
}

simulated function PlayProneWaiting()
{
	// End:0x96
	if(((m_bIsPlayer || (m_TrackActor != none)) || m_bIsSniping))
	{
		// End:0x3A
		if((EngineWeapon == none))
		{
			R6LoopAnim('ProneWaitBreathe');			
		}
		else
		{
			// End:0x61
			if((int(EngineWeapon.m_eWeaponType) == int(5)))
			{
				R6LoopAnim('ProneBipodLMGBreathe');				
			}
			else
			{
				// End:0x88
				if((int(EngineWeapon.m_eWeaponType) == int(4)))
				{
					R6LoopAnim('ProneBipodSniperBreathe');					
				}
				else
				{
					R6LoopAnim('ProneWaitBreathe');
				}
			}
		}		
	}
	else
	{
		SetRandomWaiting(3);
		switch(m_bRepPlayWaitAnim)
		{
			// End:0x11F
			case 0:
				// End:0xC3
				if((EngineWeapon == none))
				{
					R6LoopAnim('ProneWaitBreathe');					
				}
				else
				{
					// End:0xEA
					if((int(EngineWeapon.m_eWeaponType) == int(5)))
					{
						R6LoopAnim('ProneBipodLMGBreathe');						
					}
					else
					{
						// End:0x111
						if((int(EngineWeapon.m_eWeaponType) == int(4)))
						{
							R6LoopAnim('ProneBipodSniperBreathe');							
						}
						else
						{
							R6LoopAnim('ProneWaitBreathe');
						}
					}
				}
				// End:0x140
				break;
			// End:0x132
			case 1:
				R6LoopAnim('ProneWaitCrackNeck');
				// End:0x140
				break;
			// End:0xFFFF
			default:
				R6LoopAnim('ProneWaitLookAround');
				break;
		}
	}
	return;
}

function Rotator GetFiringRotation()
{
	local R6RainbowAI AI;

	// End:0x10
	if(m_bIsPlayer)
	{
		return GetViewRotation();
	}
	AI = R6RainbowAI(Controller);
	// End:0x8A
	if((int(EngineWeapon.m_eWeaponType) == int(6)))
	{
		// End:0x7B
		if((AI.m_vLocationOnTarget != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			return AI.GetGrenadeDirection(none, AI.m_vLocationOnTarget);			
		}
		else
		{
			return Controller.Rotation;
		}
	}
	return m_rFiringRotation;
	return;
}

simulated function bool HasPawnSpecificWeaponAnimation()
{
	// End:0x24
	if(((int(m_eEquipWeapon) == int(1)) || (int(m_eEquipWeapon) == int(0))))
	{
		return true;
	}
	return false;
	return;
}

/////////////////////////////////////////////////////////////////////////////
//							NOTIFICATIONS
/////////////////////////////////////////////////////////////////////////////
simulated function BoltActionSwitchToLeft()
{
	m_bReAttachToRightHand = true;
	AttachWeapon(EngineWeapon, 'TagBoltRifle');
	return;
}

simulated function BoltActionSwitchToLeftProne()
{
	m_bReAttachToRightHand = true;
	AttachWeapon(EngineWeapon, 'TagBipodBoltRifle');
	return;
}

simulated function BoltActionSwitchToRight()
{
	m_bReAttachToRightHand = false;
	AttachWeapon(EngineWeapon, 'TagRightHand');
	return;
}

simulated function SecureWeapon()
{
	m_bWeaponTransition = false;
	// End:0x28
	if((int(m_eEquipWeapon) == int(1)))
	{
		m_eEquipWeapon = 3;
		PlayWeaponAnimation();
		return;
	}
	// End:0x4C
	if((EngineWeapon != none))
	{
		AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
	}
	m_eEquipWeapon = 2;
	return;
}

simulated function EquipWeapon()
{
	// End:0x12
	if((int(m_eEquipWeapon) == int(0)))
	{
		return;
	}
	// End:0x62
	if(((int(EngineWeapon.m_eWeaponType) == int(0)) || (int(EngineWeapon.m_eWeaponType) == int(7))))
	{
		AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);		
	}
	else
	{
		AttachWeapon(EngineWeapon, 'TagLeftHand');
	}
	return;
}

// this notification is only called for all weapons except handguns, and gadgets
simulated function EquipHands()
{
	// End:0x2C
	if((int(m_eEquipWeapon) == int(1)))
	{
		AttachWeapon(EngineWeapon, EngineWeapon.m_AttachPoint);		
	}
	else
	{
		// End:0x4C
		if((int(m_eEquipWeapon) == int(0)))
		{
			AttachWeapon(EngineWeapon, 'TagLeftHand');
		}
	}
	return;
}

function FinishedReloadingWeapon()
{
	// End:0x0D
	if((Controller == none))
	{
		return;
	}
	// End:0x79
	if((((EngineWeapon.IsPumpShotGun() && (Controller.Enemy == none)) && (!EngineWeapon.GunIsFull())) && (EngineWeapon.GetNbOfClips() > 0)))
	{
		R6RainbowAI(Controller).RainbowReloadWeapon();		
	}
	else
	{
		m_bReloadToFullAmmo = false;
	}
	return;
}

simulated function bool GetNormalWeaponAnimation(out STWeaponAnim stAnim)
{
	// End:0x0B
	if(m_bPlayingComAnimation)
	{
		return false;
	}
	stAnim.bBackward = false;
	stAnim.bPlayOnce = false;
	// End:0x45
	if((int(m_bIsFiringWeapon) > 0))
	{
		stAnim.fTweenTime = 0.0000000;		
	}
	else
	{
		stAnim.fTweenTime = 0.1000000;
	}
	stAnim.fRate = 1.0000000;
	// End:0x81
	if(IsUsingHeartBeatSensor())
	{
		stAnim.nBlendName = 'R6 Spine2';		
	}
	else
	{
		stAnim.nBlendName = 'R6 R Clavicle';
	}
	// End:0xEA
	if(m_bIsProne)
	{
		// End:0xDD
		if(((EngineWeapon != none) && (R6AbstractWeapon(EngineWeapon).m_BipodGadget == none)))
		{
			stAnim.nAnimToPlay = EngineWeapon.GetProneWaitAnimName();			
		}
		else
		{
			m_ePlayerIsUsingHands = 3;
			return false;
		}		
	}
	else
	{
		// End:0x11A
		if(((int(m_eEquipWeapon) == int(2)) || (EngineWeapon == none)))
		{
			stAnim.nAnimToPlay = 'StandNoGun_nt';			
		}
		else
		{
			// End:0x140
			if(m_bUseHighStance)
			{
				stAnim.nAnimToPlay = EngineWeapon.GetHighWaitAnimName();				
			}
			else
			{
				stAnim.nAnimToPlay = EngineWeapon.GetWaitAnimName();
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
	stAnim.bBackward = false;
	stAnim.bPlayOnce = true;
	stAnim.fRate = 1.5000000;
	stAnim.fTweenTime = 0.0500000;
	stAnim.nBlendName = 'R6 R Clavicle';
	// End:0x70
	if(m_bIsProne)
	{
		stAnim.nAnimToPlay = EngineWeapon.GetProneFiringAnimName();		
	}
	else
	{
		stAnim.nAnimToPlay = EngineWeapon.GetFiringAnimName();
	}
	return true;
	return;
}

//============================================================================
// function GetReloadAnimation - 
//============================================================================
simulated function bool GetReloadWeaponAnimation(out STWeaponAnim stAnim)
{
	// End:0x58
	if(m_bIsProne)
	{
		// End:0x3B
		if((EngineWeapon.NumberOfBulletsLeftInClip() != 0))
		{
			stAnim.nAnimToPlay = EngineWeapon.GetProneReloadAnimTacticalName();			
		}
		else
		{
			stAnim.nAnimToPlay = EngineWeapon.GetProneReloadAnimName();
		}		
	}
	else
	{
		// End:0x8A
		if((EngineWeapon.NumberOfBulletsLeftInClip() != 0))
		{
			stAnim.nAnimToPlay = EngineWeapon.GetReloadAnimTacticalName();			
		}
		else
		{
			stAnim.nAnimToPlay = EngineWeapon.GetReloadAnimName();
		}
	}
	// End:0xBA
	if((stAnim.nAnimToPlay == m_WeaponAnimPlaying))
	{
		return false;
	}
	m_bWeaponTransition = true;
	m_ePlayerIsUsingHands = 0;
	stAnim.bBackward = false;
	stAnim.bPlayOnce = true;
	stAnim.fRate = m_fReloadSpeedMultiplier;
	stAnim.fTweenTime = 0.1000000;
	stAnim.nBlendName = 'R6 Spine2';
	return true;
	return;
}

//============================================================================
// function GetChangeWeaponAnimation - 
//============================================================================
simulated function bool GetChangeWeaponAnimation(out STWeaponAnim stAnim)
{
	m_bWeaponTransition = true;
	m_WeaponAnimPlaying = 'None';
	stAnim.bBackward = false;
	stAnim.bPlayOnce = true;
	stAnim.fRate = ((ArmorSkillEffect() * 2.5000000) * m_fGunswitchSpeedMultiplier);
	stAnim.fTweenTime = 0.1000000;
	stAnim.nBlendName = 'R6 Spine2';
	// End:0x79
	if((EngineWeapon == none))
	{
		return false;
	}
	// End:0xA9
	if((PendingWeapon == none))
	{
		m_bPreviousAnimPlayOnce = false;
		stAnim.nAnimToPlay = m_WeaponAnimPlaying;
		m_eLastUsingHands = m_ePlayerIsUsingHands;
		return true;
	}
	SendPlaySound(EngineWeapon.m_UnEquipSnd, 3, true);
	switch(EngineWeapon.m_eWeaponType)
	{
		// End:0xD2
		case 6:
		// End:0x1F8
		case 7:
			switch(PendingWeapon.m_eWeaponType)
			{
				// End:0xEC
				case 1:
				// End:0xF1
				case 4:
				// End:0xF6
				case 5:
				// End:0xFB
				case 3:
				// End:0x17D
				case 2:
					// End:0x11C
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchSubGunToGrenade';						
					}
					else
					{
						// End:0x15D
						if(m_bIsProne)
						{
							// End:0x14A
							if(PendingWeapon.GotBipod())
							{
								stAnim.nAnimToPlay = 'ProneBipodSubGunToGrenade';								
							}
							else
							{
								stAnim.nAnimToPlay = 'ProneSubGunToGrenade';
							}							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandSubGunToGrenade';
						}
					}
					stAnim.bBackward = true;
					// End:0x1F5
					break;
				// End:0x1BE
				case 0:
					// End:0x19E
					if(m_bIsProne)
					{
						stAnim.nAnimToPlay = 'ProneHandGunToGrenade';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandHandGunToGrenade';
					}
					stAnim.bBackward = true;
					// End:0x1F5
					break;
				// End:0x1C3
				case 7:
				// End:0xFFFF
				default:
					// End:0x1E2
					if(m_bIsProne)
					{
						stAnim.nAnimToPlay = 'ProneGrenadeChange';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandGrenadeChange';
					}
					// End:0x1F5
					break;
					break;
			}
			// End:0x44E
			break;
		// End:0x2FE
		case 0:
			switch(PendingWeapon.m_eWeaponType)
			{
				// End:0x212
				case 1:
				// End:0x217
				case 4:
				// End:0x21C
				case 5:
				// End:0x221
				case 3:
				// End:0x2A3
				case 2:
					// End:0x242
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchSubGunToHandGun';						
					}
					else
					{
						// End:0x283
						if(m_bIsProne)
						{
							// End:0x270
							if(PendingWeapon.GotBipod())
							{
								stAnim.nAnimToPlay = 'ProneBipodSubGunToHandGun';								
							}
							else
							{
								stAnim.nAnimToPlay = 'ProneSubGunToHandGun';
							}							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandSubGunToHandGun';
						}
					}
					stAnim.bBackward = true;
					// End:0x2FB
					break;
				// End:0x2A8
				case 6:
				// End:0x2F8
				case 7:
					// End:0x2C9
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchHandGunToGrenade';						
					}
					else
					{
						// End:0x2E5
						if(m_bIsProne)
						{
							stAnim.nAnimToPlay = 'ProneHandGunToGrenade';							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandHandGunToGrenade';
						}
					}
					// End:0x2FB
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x44E
			break;
		// End:0x303
		case 1:
		// End:0x308
		case 4:
		// End:0x30D
		case 5:
		// End:0x312
		case 3:
		// End:0x44B
		case 2:
			switch(PendingWeapon.m_eWeaponType)
			{
				// End:0x39C
				case 0:
					// End:0x348
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchSubGunToHandGun';						
					}
					else
					{
						// End:0x389
						if(m_bIsProne)
						{
							// End:0x376
							if(EngineWeapon.GotBipod())
							{
								stAnim.nAnimToPlay = 'ProneBipodSubGunToHandGun';								
							}
							else
							{
								stAnim.nAnimToPlay = 'ProneSubGunToHandGun';
							}							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandSubGunToHandGun';
						}
					}
					// End:0x448
					break;
				// End:0x3A1
				case 6:
				// End:0x416
				case 7:
					// End:0x3C2
					if(bIsCrouched)
					{
						stAnim.nAnimToPlay = 'CrouchSubGunToGrenade';						
					}
					else
					{
						// End:0x403
						if(m_bIsProne)
						{
							// End:0x3F0
							if(EngineWeapon.GotBipod())
							{
								stAnim.nAnimToPlay = 'ProneBipodSubGunToGrenade';								
							}
							else
							{
								stAnim.nAnimToPlay = 'ProneSubGunToGrenade';
							}							
						}
						else
						{
							stAnim.nAnimToPlay = 'StandSubGunToGrenade';
						}
					}
					// End:0x448
					break;
				// End:0xFFFF
				default:
					// End:0x435
					if(m_bIsProne)
					{
						stAnim.nAnimToPlay = 'ProneGrenadeChange';						
					}
					else
					{
						stAnim.nAnimToPlay = 'StandGrenadeChange';
					}
					// End:0x448
					break;
					break;
			}
			// End:0x44E
			break;
		// End:0xFFFF
		default:
			break;
	}
	return true;
	return;
}

//============================================================================
// function GetThrowGrenadeAnimation - 
//  . for grenade animations that play on clavicle (except for PullPin) we 
//    don't want to play the animation on both arms because this will result
//    in the animation notifications being called twice
//============================================================================
simulated function bool GetThrowGrenadeAnimation(out STWeaponAnim stAnim)
{
	m_bWeaponTransition = true;
	stAnim.bBackward = false;
	stAnim.bPlayOnce = true;
	stAnim.fRate = ArmorSkillEffect();
	stAnim.fTweenTime = 0.1000000;
	stAnim.nBlendName = 'R6 R Clavicle';
	m_bThrowGrenadeWithLeftHand = false;
	// End:0xE3
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		// End:0xE3
		if(((R6PlayerController(Controller) == none) || (!R6PlayerController(Controller).Player.IsA('Viewport'))))
		{
			// End:0xD0
			if((int(m_eGrenadeThrow) == int(3)))
			{
				PlaySound(EngineWeapon.m_ReloadSnd, 3);				
			}
			else
			{
				PlaySound(EngineWeapon.m_BurstFireStereoSnd, 3);
			}
		}
	}
	switch(m_eGrenadeThrow)
	{
		// End:0x11E
		case 1:
			// End:0x10B
			if(m_bIsProne)
			{
				stAnim.nAnimToPlay = 'ProneThrowGrenade';				
			}
			else
			{
				stAnim.nAnimToPlay = 'StandThrowGrenade';
			}
			// End:0x2A5
			break;
		// End:0x152
		case 2:
			// End:0x13F
			if(m_bIsProne)
			{
				stAnim.nAnimToPlay = 'ProneRollGrenade';				
			}
			else
			{
				stAnim.nAnimToPlay = 'StandRollGrenade';
			}
			// End:0x2A5
			break;
		// End:0x186
		case 3:
			// End:0x173
			if(m_bIsProne)
			{
				stAnim.nAnimToPlay = 'PronePullPin';				
			}
			else
			{
				stAnim.nAnimToPlay = 'StandPullPin';
			}
			// End:0x2A5
			break;
		// End:0x1D1
		case 4:
			// End:0x1B6
			if((!m_bIsPlayer))
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5000000;
			}
			m_bThrowGrenadeWithLeftHand = true;
			stAnim.nAnimToPlay = 'PeekLeftRollGrenade';
			// End:0x2A5
			break;
		// End:0x21C
		case 6:
			// End:0x201
			if((!m_bIsPlayer))
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5000000;
			}
			m_bThrowGrenadeWithLeftHand = true;
			stAnim.nAnimToPlay = 'PeekLeftThrowGrenade';
			// End:0x2A5
			break;
		// End:0x25F
		case 5:
			// End:0x24C
			if((!m_bIsPlayer))
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5000000;
			}
			stAnim.nAnimToPlay = 'PeekRightRollGrenade';
			// End:0x2A5
			break;
		// End:0x2A2
		case 7:
			// End:0x28F
			if((!m_bIsPlayer))
			{
				stAnim.nBlendName = 'R6 Spine';
				stAnim.fTweenTime = 0.5000000;
			}
			stAnim.nAnimToPlay = 'PeekRightThrowGrenade';
			// End:0x2A5
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x2BB
	if((stAnim.nAnimToPlay == m_WeaponAnimPlaying))
	{
		return false;
	}
	m_eGrenadeThrow = 0;
	return true;
	return;
}

//============================================================================
// function GetPawnSpecificAnimation - 
//============================================================================
simulated function bool GetPawnSpecificAnimation(out STWeaponAnim stAnim)
{
	m_bWeaponTransition = true;
	m_bWeaponIsSecured = false;
	m_WeaponAnimPlaying = 'None';
	stAnim.bPlayOnce = true;
	stAnim.fRate = (ArmorSkillEffect() * 1.5000000);
	stAnim.fTweenTime = 0.1000000;
	stAnim.nBlendName = 'R6 Spine2';
	stAnim.bBackward = false;
	m_ePlayerIsUsingHands = 0;
	switch(EngineWeapon.m_eWeaponType)
	{
		// End:0x8A
		case 1:
		// End:0x8F
		case 4:
		// End:0x94
		case 5:
		// End:0x99
		case 3:
		// End:0xB1
		case 2:
			stAnim.nAnimToPlay = 'StandSubGun_b';
			// End:0xE4
			break;
		// End:0xC9
		case 0:
			stAnim.nAnimToPlay = 'StandHandGun_b';
			// End:0xE4
			break;
		// End:0xCE
		case 7:
		// End:0xFFFF
		default:
			stAnim.nAnimToPlay = 'StandGrenade_b';
			// End:0xE4
			break;
			break;
	}
	// End:0x120
	if((int(m_eEquipWeapon) == int(0)))
	{
		SendPlaySound(EngineWeapon.m_UnEquipSnd, 3, true);
		m_bWeaponIsSecured = true;
		stAnim.bBackward = true;		
	}
	else
	{
		SendPlaySound(EngineWeapon.m_EquipSnd, 3, true);
	}
	return true;
	return;
}

simulated function GetWeapon(R6AbstractWeapon NewWeapon)
{
	// End:0xA6
	if((NewWeapon != EngineWeapon))
	{
		// End:0x3C
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_pBulletManager.SetBulletParameter(NewWeapon);
		}
		// End:0xA6
		if((EngineWeapon != none))
		{
			EngineWeapon.DisableWeaponOrGadget();
			// End:0x88
			if((m_bWeaponGadgetActivated == true))
			{
				m_bWeaponGadgetActivated = false;
				R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(false);
			}
			PendingWeapon = NewWeapon;
			// End:0xA6
			if((!m_bIsPlayer))
			{
				m_bChangingWeapon = true;
			}
		}
	}
	return;
}

// The same animation is use for both "SubGun to HandGun" and "HandGun to Subgun" transition
// We have to check the current weapon state to know which transition we are doing
simulated function SubToHand_Step1()
{
	m_preSwitchWeapon = EngineWeapon;
	// End:0x18
	if((EngineWeapon == none))
	{
		return;
	}
	// End:0x40
	if(R6AbstractWeapon(EngineWeapon).m_bHiddenWhenNotInUse)
	{
		EngineWeapon.bHidden = true;
	}
	switch(EngineWeapon.m_eWeaponType)
	{
		// End:0x55
		case 0:
		// End:0x5A
		case 7:
		// End:0xCC
		case 6:
			AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
			switch(PendingWeapon.m_eWeaponType)
			{
				// End:0x8D
				case 0:
				// End:0x92
				case 7:
				// End:0x9A
				case 6:
					// End:0xC9
					break;
				// End:0x9F
				case 1:
				// End:0xA4
				case 2:
				// End:0xA9
				case 3:
				// End:0xAE
				case 4:
				// End:0xC6
				case 5:
					AttachWeapon(PendingWeapon, 'TagLeftHand');
					// End:0xC9
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0xFB
			break;
		// End:0xD1
		case 1:
		// End:0xD6
		case 2:
		// End:0xDB
		case 3:
		// End:0xE0
		case 4:
		// End:0xF8
		case 5:
			AttachWeapon(EngineWeapon, 'TagLeftHand');
			// End:0xFB
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

simulated function SubToHand_Step2()
{
	// End:0x0D
	if((EngineWeapon == none))
	{
		return;
	}
	PendingWeapon.bHidden = false;
	SendPlaySound(PendingWeapon.m_EquipSnd, 3, true);
	// End:0x89
	if((m_preSwitchWeapon != none))
	{
		AttachWeapon(m_preSwitchWeapon, m_preSwitchWeapon.m_HoldAttachPoint);
		// End:0x7F
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			m_preSwitchWeapon.TurnOffEmitters(true);
		}
		m_preSwitchWeapon = none;		
	}
	else
	{
		AttachWeapon(EngineWeapon, EngineWeapon.m_HoldAttachPoint);
		// End:0xCB
		if((int(Level.NetMode) != int(NM_DedicatedServer)))
		{
			EngineWeapon.TurnOffEmitters(true);
		}
	}
	AttachWeapon(PendingWeapon, PendingWeapon.m_AttachPoint);
	// End:0x10D
	if((int(Level.NetMode) != int(NM_DedicatedServer)))
	{
		PendingWeapon.TurnOffEmitters(false);
	}
	return;
}

// this function must be move in R6Pawn.
function ChangingWeaponEnd()
{
	// End:0x0D
	if((EngineWeapon == none))
	{
		return;
	}
	// End:0x47
	if((((int(Level.NetMode) != int(NM_Standalone)) && (!bNetOwner)) && (int(Role) != int(ROLE_Authority))))
	{
		return;
	}
	m_bChangingWeapon = false;
	// End:0x9C
	if(((Controller.IsA('R6PlayerController') && (R6PlayerController(Controller).bBehindView == false)) && (int(Level.NetMode) == int(NM_Standalone))))
	{
		return;
	}
	EngineWeapon = PendingWeapon;
	// End:0xC7
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		PendingWeapon = none;
	}
	return;
}

function ChangeProneAttach()
{
	// End:0x9A
	if((m_WeaponsCarried[0] != none))
	{
		// End:0x4B
		if((m_WeaponsCarried[0].m_HoldAttachPoint == m_WeaponsCarried[0].default.m_HoldAttachPoint))
		{
			m_WeaponsCarried[0].m_HoldAttachPoint = 'TagBackProne';			
		}
		else
		{
			m_WeaponsCarried[0].m_HoldAttachPoint = m_WeaponsCarried[0].default.m_HoldAttachPoint;
		}
		// End:0x9A
		if((m_WeaponsCarried[0] != EngineWeapon))
		{
			AttachWeapon(m_WeaponsCarried[0], m_WeaponsCarried[0].m_HoldAttachPoint);
		}
	}
	return;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	local R6Rainbow pInteractor;

	// End:0x393
	if(Class'Engine.Actor'.static.GetModMgr().IsMissionPack())
	{
		// End:0x390
		if(((Query.aQueryOwner.IsA('R6PlayerController') && Query.aQueryTarget.IsA('R6Rainbow')) && IsAlive()))
		{
			pInteractor = R6PlayerController(Query.aQueryOwner).m_pawn;
			// End:0x212
			if(((((m_bIsSurrended && (!m_bIsUnderArrest)) && (pInteractor.m_iTeam != R6Rainbow(Query.aQueryTarget).m_iTeam)) && (!pInteractor.m_bIsSurrended)) && (!pInteractor.m_bIsClimbingLadder)))
			{
				Query.iHasAction = 1;
				// End:0x155
				if(((fDistance < m_fCircumstantialActionRange) && (Abs((Location.Z - pInteractor.Location.Z)) < float(110))))
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
				// End:0x37F
				if(((m_bIsUnderArrest && (pInteractor.m_iTeam == R6Rainbow(Query.aQueryTarget).m_iTeam)) && (!pInteractor.m_bIsClimbingLadder)))
				{
					Query.iHasAction = 1;
					// End:0x2C2
					if(((fDistance < m_fCircumstantialActionRange) && (Abs((Location.Z - pInteractor.Location.Z)) < float(110))))
					{
						Query.iInRange = 1;						
					}
					else
					{
						Query.iInRange = 0;
					}
					Query.textureIcon = Texture'R6ActionIcons.FreeRainbow';
					Query.fPlayerActionTimeRequired = 0.0000000;
					Query.bCanBeInterrupted = true;
					Query.iPlayerActionID = 2;
					Query.iTeamActionID = 2;
					Query.iTeamActionIDList[0] = 2;
					Query.iTeamActionIDList[1] = 0;
					Query.iTeamActionIDList[2] = 0;
					Query.iTeamActionIDList[3] = 0;					
				}
				else
				{
					Query.iHasAction = 0;
				}
			}
		}		
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
		// End:0x63
		case int(2):
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
	return;
}

//============================================================================
// ResetArrest - 
//============================================================================
function ResetArrest()
{
	AnimBlendToAlpha(16, 0.0000000, 0.5000000);
	m_ePlayerIsUsingHands = 3;
	m_bIsUnderArrest = false;
	// End:0x4F
	if((int(Level.NetMode) == int(NM_Client)))
	{
		R6PlayerController(Controller).ServerStartSurrended();
	}
	R6PlayerController(Controller).GotoState('PlayerSurrended');
	R6PlayerController(Controller).m_fStartSurrenderTime = Level.TimeSeconds;
	m_bIsBeingArrestedOrFreed = false;
	PlayWaiting();
	return;
}

function ServerSetCrouch(bool bCrouch)
{
	bWantsToCrouch = bCrouch;
	return;
}

function ClientSetCrouch(bool bCrouch)
{
	bWantsToCrouch = bCrouch;
	return;
}

//--------------- End MissionPack1
function bool HasBumpPriority(R6Pawn bumpedBy)
{
	// End:0x22
	if(R6RainbowAI(Controller).m_TeamManager.m_bGrenadeInProximity)
	{
		return true;
	}
	// End:0x52
	if(((m_iTeam != bumpedBy.m_iTeam) && (!bumpedBy.m_bIsPlayer)))
	{
		return true;
	}
	// End:0x82
	if(((bumpedBy.m_iID <= m_iID) && (!bumpedBy.IsStationary())))
	{
		return false;
	}
	return true;
	return;
}

//-----------------------------------------------------------------//
// --                 Rainbow Skill Advancement                 -- //
// --   called at the end of a mission to update skill levels   -- //
// -- TODO : (x.5) add special clause for members that did not  -- //
// --        participate in this mission and were in training   -- //
// --        MOVE THIS TO NATIVE CODE LATER                     -- //
//-----------------------------------------------------------------//
function UpdateRainbowSkills()
{
	local int iD5, iD2;

	// End:0x0D
	if((!IsAlive()))
	{
		return;
	}
	// End:0x1B
	if((m_szSpecialityID == ""))
	{
		return;
	}
	iD5 = (Rand(5) + 1);
	iD2 = (Rand(2) + 1);
	// End:0x73
	if((m_szSpecialityID == "ID_ASSAULT"))
	{
		(m_fSkillAssault += ((float((iD5 + 5)) / 100.0000000) * (float(1) - m_fSkillAssault)));		
	}
	else
	{
		(m_fSkillAssault += ((float((iD2 + 2)) / 100.0000000) * (float(1) - m_fSkillAssault)));
	}
	// End:0xDA
	if((m_szSpecialityID == "ID_DEMOLITIONS"))
	{
		(m_fSkillDemolitions += ((float((iD5 + 5)) / 100.0000000) * (float(1) - m_fSkillDemolitions)));		
	}
	else
	{
		// End:0xFE
		if((FRand() <= 0.2000000))
		{
			(m_fSkillDemolitions += (0.0200000 * (float(1) - m_fSkillDemolitions)));
		}
	}
	// End:0x140
	if((m_szSpecialityID == "ID_ELECTRONICS"))
	{
		(m_fSkillElectronics += ((float((iD5 + 5)) / 100.0000000) * (float(1) - m_fSkillElectronics)));		
	}
	else
	{
		// End:0x164
		if((FRand() <= 0.2000000))
		{
			(m_fSkillElectronics += (0.0200000 * (float(1) - m_fSkillElectronics)));
		}
	}
	// End:0x1A0
	if((m_szSpecialityID == "ID_RECON"))
	{
		(m_fSkillStealth += ((float((iD5 + 5)) / 100.0000000) * (float(1) - m_fSkillStealth)));		
	}
	else
	{
		// End:0x1C4
		if((FRand() <= 0.2000000))
		{
			(m_fSkillStealth += (0.0200000 * (float(1) - m_fSkillStealth)));
		}
	}
	// End:0x201
	if((m_szSpecialityID == "ID_SNIPER"))
	{
		(m_fSkillSniper += ((float((iD5 + 5)) / 100.0000000) * (float(1) - m_fSkillSniper)));		
	}
	else
	{
		// End:0x225
		if((FRand() <= 0.2000000))
		{
			(m_fSkillSniper += (0.0200000 * (float(1) - m_fSkillSniper)));
		}
	}
	// End:0x249
	if((FRand() <= 0.2000000))
	{
		(m_fSkillSelfControl += (0.0200000 * (float(1) - m_fSkillSelfControl)));
	}
	// End:0x26D
	if((FRand() <= 0.2000000))
	{
		(m_fSkillLeadership += (0.0200000 * (float(1) - m_fSkillLeadership)));
	}
	// End:0x291
	if((FRand() <= 0.2000000))
	{
		(m_fSkillObservation += (0.0200000 * (float(1) - m_fSkillObservation)));
	}
	return;
}

//============================================================================
// IsFighting: return true when the pawn is fighting
// - inherited
//============================================================================
function bool IsFighting()
{
	// End:0x0D
	if((!IsAlive()))
	{
		return false;
	}
	// End:0x1C
	if((int(m_bIsFiringWeapon) == 1))
	{
		return true;
	}
	// End:0x32
	if((Controller.Enemy != none))
	{
		return true;
	}
	return false;
	return;
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
//									GRENADE FUNCTIONS
/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
function GrenadeThrow()
{
	local int iChannel;

	iChannel = GetNotifyChannel();
	// End:0x1A
	if((iChannel == 15))
	{
		return;
	}
	// End:0x39
	if((int(Role) == int(ROLE_Authority)))
	{
		EngineWeapon.ThrowGrenade();
	}
	EngineWeapon.bHidden = true;
	return;
}

function GrenadeAnimEnd()
{
	EngineWeapon.bHidden = false;
	m_eGrenadeThrow = 0;
	PlayWeaponAnimation();
	return;
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	// End:0x4E
	if(((m_bIsClimbingLadder && (!bIsWalking)) && (Acceleration.Z < float(0))))
	{
		// End:0x4B
		if((int(m_eLadderSlide) == int(3)))
		{
			StartSliding();
		}		
	}
	else
	{
		// End:0x64
		if((int(m_eLadderSlide) != int(3)))
		{
			EndSliding();
		}
	}
	return;
}

//------------------------------------------------------------------
// GetTeamMgr
//	
//------------------------------------------------------------------
function R6RainbowTeam GetTeamMgr()
{
	// End:0x0D
	if((Controller == none))
	{
		return none;
	}
	// End:0x2D
	if(m_bIsPlayer)
	{
		return R6PlayerController(Controller).m_TeamManager;		
	}
	else
	{
		return R6RainbowAI(Controller).m_TeamManager;
	}
	return;
}

//------------------------------------------------------------------
// Escort_GetPawnToFollow
//	
//------------------------------------------------------------------
function R6Rainbow Escort_GetPawnToFollow(optional bool bRunningTowardMe)
{
	local R6RainbowTeam Team;

	Team = GetTeamMgr();
	// End:0x2E
	if((Team != none))
	{
		return Team.Escort_GetPawnToFollow(self, bRunningTowardMe);
	}
	return;
}

//------------------------------------------------------------------
// Escort_AddHostage
//	
//------------------------------------------------------------------
function bool Escort_AddHostage(R6Hostage hostage, optional bool bNoFeedbackByHostage, optional bool bOrderedByRainbow)
{
	local int i, totalR6, r6index, iSndIndex;

	// End:0x14
	if(hostage.m_bCivilian)
	{
		return false;
	}
	i = 0;
	J0x1B:

	// End:0x5C [Loop If]
	if(((i < 4) && (m_aEscortedHostage[i] != none)))
	{
		// End:0x52
		if((m_aEscortedHostage[i] == hostage))
		{
			// [Explicit Break]
			goto J0x5C;
		}
		(i++);
		// [Loop Continue]
		goto J0x1B;
	}
	J0x5C:

	// End:0x6A
	if((i >= 4))
	{
		return false;
	}
	m_aEscortedHostage[i] = hostage;
	hostage.m_escortedByRainbow = self;
	Escort_UpdateTeamSpeed();
	Escort_UpdateList();
	// End:0x1FA
	if(((!bNoFeedbackByHostage) && hostage.IsAlive()))
	{
		// End:0x14C
		if(m_bIsPlayer)
		{
			// End:0xFC
			if(bOrderedByRainbow)
			{
				// End:0xF9
				if((GetTeamMgr().m_PlayerVoicesMgr != none))
				{
					GetTeamMgr().m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, 38);
				}				
			}
			else
			{
				// End:0x12D
				if((GetTeamMgr().m_PlayerVoicesMgr != none))
				{
					GetTeamMgr().m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, 40);
				}
			}
			// End:0x149
			if((Controller != none))
			{
				Controller.PlaySoundCurrentAction(4);
			}			
		}
		else
		{
			// End:0x189
			if(bOrderedByRainbow)
			{
				// End:0x186
				if((GetTeamMgr().m_MemberVoicesMgr != none))
				{
					GetTeamMgr().m_MemberVoicesMgr.PlayRainbowMemberVoices(self, 20);
				}				
			}
			else
			{
				// End:0x1BA
				if((GetTeamMgr().m_MemberVoicesMgr != none))
				{
					GetTeamMgr().m_MemberVoicesMgr.PlayRainbowMemberVoices(self, 22);
				}
			}
		}
		// End:0x1FA
		if((hostage.m_controller != none))
		{
			hostage.m_controller.ProcessPlaySndInfo(hostage.m_mgr.8);
		}
	}
	return true;
	return;
}

//------------------------------------------------------------------
// RemoveEscortedHostage: remove an hostage from the escort list,
//  update the escort list and call UpdateEscortList
//  return true is succesfull
//------------------------------------------------------------------
function bool Escort_RemoveHostage(R6Hostage hostage, optional bool bNoFeedbackByHostage, optional bool bOrderedByRainbow)
{
	local int removeIndex, escortIndex, r6index, iSndIndex;
	local R6RainbowTeam teamMgr;

	// End:0x16
	if((hostage.m_escortedByRainbow == none))
	{
		return false;
	}
	removeIndex = 0;
	J0x1D:

	// End:0x5E [Loop If]
	if(((removeIndex < 4) && (m_aEscortedHostage[removeIndex] != none)))
	{
		// End:0x54
		if((m_aEscortedHostage[removeIndex] == hostage))
		{
			// [Explicit Break]
			goto J0x5E;
		}
		(++removeIndex);
		// [Loop Continue]
		goto J0x1D;
	}
	J0x5E:

	hostage.m_escortedByRainbow = none;
	// End:0x93
	if(((removeIndex >= 4) || (m_aEscortedHostage[removeIndex] != hostage)))
	{
		return false;
	}
	escortIndex = removeIndex;
	J0x9E:

	// End:0x100 [Loop If]
	if(((escortIndex < 4) && (m_aEscortedHostage[escortIndex] != none)))
	{
		// End:0xDC
		if((escortIndex == (4 - 1)))
		{
			m_aEscortedHostage[escortIndex] = none;
			// [Explicit Continue]
			goto J0xF6;
		}
		m_aEscortedHostage[escortIndex] = m_aEscortedHostage[(escortIndex + 1)];
		J0xF6:

		(++escortIndex);
		// [Loop Continue]
		goto J0x9E;
	}
	Escort_UpdateTeamSpeed();
	Escort_UpdateList();
	// End:0x21D
	if((hostage.IsAlive() && (!bNoFeedbackByHostage)))
	{
		teamMgr = GetTeamMgr();
		// End:0x201
		if((!hostage.m_bExtracted))
		{
			// End:0x1BE
			if(bOrderedByRainbow)
			{
				// End:0x18F
				if(m_bIsPlayer)
				{
					// End:0x18C
					if((teamMgr.m_PlayerVoicesMgr != none))
					{
						teamMgr.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(self, 39);
					}					
				}
				else
				{
					// End:0x1BE
					if((teamMgr.m_MemberVoicesMgr != none))
					{
						teamMgr.m_MemberVoicesMgr.PlayRainbowMemberVoices(self, 21);
					}
				}
			}
			// End:0x1FE
			if((hostage.m_controller != none))
			{
				hostage.m_controller.ProcessPlaySndInfo(hostage.m_mgr.9);
			}			
		}
		else
		{
			// End:0x21D
			if((Controller != none))
			{
				Controller.PlaySoundCurrentAction(5);
			}
		}
	}
	return true;
	return;
}

//------------------------------------------------------------------
// Escort_UpdateCloserToLead
//	
//------------------------------------------------------------------
function Escort_UpdateCloserToLead()
{
	local R6HostageAI closerAI, hostageAI;
	local int Index, searchIndex, nbEscortedHostage;
	local R6Hostage hostage, aNewList;
	local float fShortestDistance, fDistance;
	local R6Hostage closerToLead;

	closerToLead = m_aEscortedHostage[0];
	// End:0xF3
	if((closerToLead != none))
	{
		closerAI = R6HostageAI(closerToLead.Controller);
		// End:0xF3
		if((closerAI.m_pawnToFollow != none))
		{
			// End:0x88
			if((VSize((closerAI.m_pawnToFollow.Location - closerToLead.Location)) <= float(closerAI.c_iDistanceMax)))
			{
				return;				
			}
			else
			{
				// End:0xF3
				if((int(closerAI.m_pawnToFollow.m_eMovementPace) == int(1)))
				{
					// End:0xF3
					if((VSize((closerAI.m_pawnToFollow.m_collisionBox.Location - closerToLead.Location)) <= float(closerAI.c_iDistanceMax)))
					{
						return;
					}
				}
			}
		}
	}
	// End:0x102
	if((m_aEscortedHostage[0] == none))
	{
		return;
	}
	closerToLead = none;
	fShortestDistance = 999999.0000000;
	Index = 0;
	J0x11B:

	// End:0x1B6 [Loop If]
	if(((Index < 4) && (m_aEscortedHostage[Index] != none)))
	{
		fDistance = VSize((m_aEscortedHostage[Index].Location - Location));
		// End:0x188
		if((fDistance < fShortestDistance))
		{
			fShortestDistance = fDistance;
			closerToLead = m_aEscortedHostage[Index];
		}
		R6HostageAI(m_aEscortedHostage[Index].Controller).m_pawnToFollow = none;
		(Index++);
		// [Loop Continue]
		goto J0x11B;
	}
	nbEscortedHostage = Index;
	aNewList[0] = closerToLead;
	R6HostageAI(closerToLead.Controller).m_pawnToFollow = self;
	Index = 0;
	J0x1F3:

	// End:0x334 [Loop If]
	if((Index < (nbEscortedHostage - 1)))
	{
		hostage = none;
		fShortestDistance = 999999.0000000;
		searchIndex = 0;
		J0x21E:

		// End:0x2E3 [Loop If]
		if((searchIndex < nbEscortedHostage))
		{
			// End:0x24E
			if((m_aEscortedHostage[searchIndex] == aNewList[Index]))
			{
				// [Explicit Continue]
				goto J0x2D9;
				// [Explicit Continue]
				goto J0x2D9;
			}
			// End:0x27C
			if((R6HostageAI(m_aEscortedHostage[searchIndex].Controller).m_pawnToFollow != none))
			{
				// [Explicit Continue]
				goto J0x2D9;
				// [Explicit Continue]
				goto J0x2D9;
			}
			fDistance = VSize((m_aEscortedHostage[searchIndex].Location - aNewList[Index].Location));
			// End:0x2D9
			if((fDistance < fShortestDistance))
			{
				fShortestDistance = fDistance;
				hostage = m_aEscortedHostage[searchIndex];
			}
			J0x2D9:

			(searchIndex++);
			// [Loop Continue]
			goto J0x21E;
		}
		// End:0x32A
		if((hostage != none))
		{
			R6HostageAI(hostage.Controller).m_pawnToFollow = aNewList[Index];
			aNewList[(Index + 1)] = hostage;
		}
		(Index++);
		// [Loop Continue]
		goto J0x1F3;
	}
	Index = 0;
	J0x33B:

	// End:0x36B [Loop If]
	if((Index < nbEscortedHostage))
	{
		m_aEscortedHostage[Index] = aNewList[Index];
		(Index++);
		// [Loop Continue]
		goto J0x33B;
	}
	return;
}

//------------------------------------------------------------------
// Escort_UpdateList
//	- if leader is dead, it finds someone else to escort the hostage
//  - 
//------------------------------------------------------------------
function Escort_UpdateList()
{
	local int i, j;
	local R6HostageAI hostageAI;
	local R6Hostage hostage;
	local R6Rainbow newLeadRainbow;
	local R6RainbowTeam teamMgr;

	// End:0x0F
	if((m_aEscortedHostage[0] == none))
	{
		return;
	}
	// End:0x114
	if((!IsAlive()))
	{
		newLeadRainbow = Escort_FindRainbow(m_aEscortedHostage[0]);
		// End:0x9A
		if((newLeadRainbow == none))
		{
			i = 0;
			J0x3F:

			// End:0x97 [Loop If]
			if(((i < 4) && (m_aEscortedHostage[i] != none)))
			{
				hostageAI = R6HostageAI(m_aEscortedHostage[i].Controller);
				hostageAI.Order_StayHere(false);
				(++i);
				// [Loop Continue]
				goto J0x3F;
			}			
		}
		else
		{
			newLeadRainbow = newLeadRainbow.Escort_GetPawnToFollow();
			i = 0;
			J0xB6:

			// End:0x112 [Loop If]
			if(((i < 4) && (m_aEscortedHostage[i] != none)))
			{
				hostage = m_aEscortedHostage[i];
				newLeadRainbow.Escort_AddHostage(hostage, true);
				m_aEscortedHostage[i] = none;
				(++i);
				// [Loop Continue]
				goto J0xB6;
			}
		}
		return;
	}
	i = 0;
	J0x11B:

	// End:0x1AC [Loop If]
	if(((i < 4) && (m_aEscortedHostage[i] != none)))
	{
		// End:0x1A2
		if((!m_aEscortedHostage[i].IsAlive()))
		{
			j = i;
			J0x15F:

			// End:0x192 [Loop If]
			if(((j + 1) < 4))
			{
				m_aEscortedHostage[j] = m_aEscortedHostage[(j + 1)];
				(j++);
				// [Loop Continue]
				goto J0x15F;
			}
			m_aEscortedHostage[j] = none;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x11B;
	}
	Escort_UpdateCloserToLead();
	i = 0;
	J0x1B9:

	// End:0x23C [Loop If]
	if(((i < 4) && (m_aEscortedHostage[i] != none)))
	{
		hostageAI = R6HostageAI(m_aEscortedHostage[i].Controller);
		// End:0x215
		if((i == 0))
		{
			hostageAI.m_pawnToFollow = self;
			// [Explicit Continue]
			goto J0x232;
		}
		hostageAI.m_pawnToFollow = m_aEscortedHostage[(i - 1)];
		J0x232:

		(++i);
		// [Loop Continue]
		goto J0x1B9;
	}
	return;
}

//------------------------------------------------------------------
// Escort_IsPawnCloseToMe: return true if there's a pawn in my radius
//
//------------------------------------------------------------------
function bool Escort_IsPawnCloseToMe(R6Hostage me, float fMyRadius)
{
	local int Index;
	local R6Hostage H;
	local R6Rainbow Rainbow;
	local bool bSeparated;
	local R6RainbowTeam Team;

	Index = 0;
	J0x07:

	// End:0xCF [Loop If]
	if(((Index < 4) && (m_aEscortedHostage[Index] != none)))
	{
		H = m_aEscortedHostage[Index];
		// End:0x77
		if(((me != H) && (VSize((H.Location - me.Location)) < fMyRadius)))
		{
			return true;
			// [Explicit Continue]
			goto J0xC5;
		}
		// End:0xC5
		if((int(H.m_eMovementPace) == int(1)))
		{
			// End:0xC5
			if((VSize((H.m_collisionBox.Location - me.Location)) < fMyRadius))
			{
				return true;
			}
		}
		J0xC5:

		(Index++);
		// [Loop Continue]
		goto J0x07;
	}
	Team = GetTeamMgr();
	// End:0xE8
	if((Team == none))
	{
		return true;
	}
	bSeparated = Team.m_bTeamIsSeparatedFromLeader;
	Index = 0;
	J0x105:

	// End:0x1EE [Loop If]
	if(((Index < 4) && (Team.m_Team[Index] != none)))
	{
		Rainbow = Team.m_Team[Index];
		// End:0x167
		if((bSeparated && (Rainbow != self)))
		{
			(Index++);			
		}
		else
		{
			// End:0x196
			if((VSize((Rainbow.Location - me.Location)) < fMyRadius))
			{
				return true;
				// [Explicit Continue]
				goto J0x1E4;
			}
			// End:0x1E4
			if((int(Rainbow.m_eMovementPace) == int(1)))
			{
				// End:0x1E4
				if((VSize((Rainbow.m_collisionBox.Location - me.Location)) < fMyRadius))
				{
					return true;
				}
			}
			J0x1E4:

			(Index++);
		}
		// [Loop Continue]
		goto J0x105;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// Escort_UpdateTeamSpeed
//	
//------------------------------------------------------------------
function Escort_UpdateTeamSpeed()
{
	local R6RainbowTeam Team;

	Team = GetTeamMgr();
	// End:0x26
	if((Team != none))
	{
		Team.Escort_UpdateTeamSpeed();
	}
	return;
}

//------------------------------------------------------------------
// Escort_FindRainbow
//	find a rainbow who is visible and close to me
//------------------------------------------------------------------
function R6Rainbow Escort_FindRainbow(R6Hostage hostage)
{
	local R6Pawn P;
	local R6Hostage H;

	// End:0xE0
	foreach VisibleActors(Class'R6Engine.R6Pawn', P, hostage.SightRadius, hostage.Location)
	{
		// End:0x5D
		if((!(hostage.IsFriend(P) && P.IsAlive())))
		{
			continue;			
		}
		// End:0x85
		if((int(P.m_ePawnType) == int(1)))
		{			
			return R6Rainbow(P);
			// End:0xDF
			continue;
		}
		// End:0xDF
		if((int(P.m_ePawnType) == int(3)))
		{
			// End:0xDF
			if(((H.m_escortedByRainbow != none) && H.m_escortedByRainbow.IsAlive()))
			{				
				return H.m_escortedByRainbow;
			}
		}		
	}	
	return none;
	return;
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//	return true if the build death msg can be build by "static BuildDeathMessage"
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName)
{
	// End:0x62
	if((int(Level.NetMode) != int(NM_Standalone)))
	{
		// End:0x3A
		if((int(Killer.m_ePawnType) == int(2)))
		{
			m_bSuicideType = 8;
		}
		// End:0x62
		if(((int(Killer.m_ePawnType) == int(1)) && (!m_bIsPlayer)))
		{
			return false;
		}
	}
	return super.ProcessBuildDeathMessage(Killer, szPlayerName);
	return;
}

//------------------------------------------------------------------
// CanInteractWithObjects
//	MPF_Milan_7_1_2003 - ovverridden from R6Pawn for Mission pack - capture the enemy
//------------------------------------------------------------------
function bool CanInteractWithObjects()
{
	// End:0x4B
	if((((((m_bIsProne || m_bChangingWeapon) || m_bReloadingWeapon) || m_bIsFiringState) || m_bIsSurrended) || Level.m_bInGamePlanningActive))
	{
		return false;
	}
	return true;
	return;
}

defaultproperties
{
	m_eLadderSlide=3
	m_eEquipWeapon=3
	m_iCurrentWeapon=1
	m_bTweenFirstTimeOnly=true
	m_bScaleGasMaskForFemale=true
	m_bInitRainbow=true
	m_GasMaskClass=Class'R6Engine.R6GasMask'
	m_NightVisionClass=Class'R6Engine.R6NightVision'
	m_szSpecialityID="ID_ASSAULT"
	m_eArmorType=3
	m_bCanDisarmBomb=true
	m_bHasArmPatches=true
	m_fSkillAssault=0.8500000
	m_fSkillDemolitions=0.8500000
	m_fSkillElectronics=0.8500000
	m_fSkillSniper=0.8500000
	m_fSkillStealth=0.8500000
	m_fSkillSelfControl=0.8500000
	m_fSkillLeadership=0.8500000
	m_fSkillObservation=0.8500000
	m_fWalkingSpeed=250.0000000
	m_fWalkingBackwardStrafeSpeed=100.0000000
	m_fRunningSpeed=400.0000000
	m_fRunningBackwardStrafeSpeed=250.0000000
	m_fCrouchedWalkingSpeed=125.0000000
	m_fCrouchedWalkingBackwardStrafeSpeed=50.0000000
	m_fCrouchedRunningSpeed=250.0000000
	m_fCrouchedRunningBackwardStrafeSpeed=100.0000000
	m_fProneSpeed=65.0000000
	m_fProneStrafeSpeed=35.0000000
	m_fPeekingGoalModifier=0.3500000
	m_ePawnType=1
	m_iTeam=2
	bCanStrafe=true
	m_bMakesTrailsWhenProning=true
	PeripheralVision=0.1700000
	MeleeRange=30.0000000
	CrouchRadius=38.0000000
	ControllerClass=Class'R6Engine.R6RainbowAI'
	CollisionRadius=38.0000000
	CollisionHeight=80.0000000
	m_fAttachFactor=0.9090910
	KParams=KarmaParamsSkel'R6Engine.R6RainbowRagDoll'
	Skins=/* Array type was not detected. */
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eLadderSlide
// REMOVED IN 1.60: var eEquipWeapon
// REMOVED IN 1.60: function PlayStartArrest
