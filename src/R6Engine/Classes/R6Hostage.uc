//=============================================================================
// R6Hostage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Hostage.uc : This is the pawn class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/11 * Created by Rima Brek
//=============================================================================
class R6Hostage extends R6Pawn
    abstract
    native;

enum EHandsUpType
{
	HANDSUP_none,                   // 0
	HANDSUP_kneeling,               // 1
	HANDSUP_standing                // 2
};

enum EStartingPosition
{
	POS_Stand,                      // 0
	POS_Kneel,                      // 1
	POS_Prone,                      // 2
	POS_Foetus,                     // 3
	POS_Crouch,                     // 4
	POS_Random                      // 5
};

enum ECivPatrolType
{
	CIVPATROL_None,                 // 0
	CIVPATROL_Path,                 // 1
	CIVPATROL_Area,                 // 2
	CIVPATROL_Point                 // 3
};

enum EStandWalkingAnim
{
	eStandWalkingAnim_default,      // 0
	eStandWalkingAnim_scared        // 1
};

enum eHostageOrder
{
	HOrder_None,                    // 0
	HOrder_ComeWithMe,              // 1
	HOrder_StayHere,                // 2
	HOrder_Surrender,               // 3
	HOrder_GotoExtraction           // 4
};

struct STRepHostageAnim
{
	var R6Hostage.EStandWalkingAnim m_eRepStandWalkingAnim;
	var bool m_bRepPlayMoving;
};

var(Personality) R6Pawn.EHostagePersonality m_ePersonality;  // type of personality
var(StartingPosition) R6Hostage.EStartingPosition m_ePosition;  // kneel or standing
var R6Hostage.ECivPatrolType m_eCivPatrol;  // type of patrol in the depZone
var R6Hostage.EHandsUpType m_eHandsUpType;  // used to know if we have to play anim transition when hands are up/down
var byte m_bRepWaitAnimIndex;
var byte m_bSavedRepWaitAnimIndex;
var int m_iIndex;  // Used in the TerroristMgr to rapidely find an hostage already in the array
// NEW IN 1.60
var int m_iPrisonierTeam;
var bool m_bInitFinished;  // true when the initializing process of dzone is over
var bool m_bStartAsCivilian;  // start has a civilian
var bool m_bCivilian;  // true when civilian (faster than isInState('Civilian')
var bool m_bPatrolForward;  // when in CivPatrolPath
// MPF1
var bool m_bPoliceManMp1;  // policeMan for MissionPack1 (ignores SeePlayer, HearNoise and QueryAction=0)
var bool m_bPoliceManHasWeapon;
var bool m_bPoliceManCanSeeRainbows;
var bool m_bIsKneeling;
var bool m_bIsFoetus;
var bool m_bFrozen;  // frozen for kneeling/standing anim
var bool m_bReactionAnim;  // true when playing a reaction anim
var bool m_bCrouchToScaredStandBegin;  // true when play this anim
var bool m_bFreed;  // true when not guarded
var bool m_bEscorted;  // in escorte mode
var bool m_bExtracted;  // true when enter an extration zone
var bool m_bFeedbackExtracted;  // true when we process the feedback
// NEW IN 1.60
var bool m_bClassicMissionCivilian;
var R6DeploymentZone m_DZone;  // deployment zone
var R6DZonePathNode m_currentNode;  // when in CivPatrolPath
var R6HostageMgr m_mgr;  // quick reference
var R6HostageAI m_controller;  // quick reference
var R6Rainbow m_escortedByRainbow;
var name m_NocsWaitingName;  // MissionPack1
var name m_NocsSeeRainbowsName;  // MissionPack1
var name m_globalState;  // used to check if we are in the GotoState('')
// random time: keep a state
var(StayInThisState) RandomTweenNum m_stayInFoetusTime;
var(StayInThisState) RandomTweenNum m_stayFrozenTime;
var(StayInThisState) RandomTweenNum m_stayProneTime;
var(StayInThisState) RandomTweenNum m_stayCautiousGuardedStateTime;
var() RandomTweenNum m_patrolAreaWaitTween;
var() RandomTweenNum m_changeOrientationTween;
var() RandomTweenNum m_sightRadiusTween;
var() RandomTweenNum m_updatePaceTween;
var() RandomTweenNum m_waitingGoCrouchTween;
var STRepHostageAnim m_eSavedRepHostageAnim;
var STRepHostageAnim m_eCurrentRepHostageAnim;
// initialized by the template
var string m_szUsedTemplate;

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		m_bEscorted, m_bExtracted, 
		m_bFreed, m_bFrozen, 
		m_bIsFoetus, m_bIsKneeling, 
		m_bRepWaitAnimIndex, m_eCurrentRepHostageAnim, 
		m_eHandsUpType, m_ePosition, 
		m_escortedByRainbow;
}

simulated function Tick(float fDeltaTime)
{
	// End:0x9B
	if((int(Role) < int(ROLE_Authority)))
	{
		// End:0x70
		if(((m_eSavedRepHostageAnim.m_bRepPlayMoving != m_eCurrentRepHostageAnim.m_bRepPlayMoving) || (int(m_eSavedRepHostageAnim.m_eRepStandWalkingAnim) != int(m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim))))
		{
			SetStandWalkingAnim(m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim, m_eCurrentRepHostageAnim.m_bRepPlayMoving);
			m_eSavedRepHostageAnim = m_eCurrentRepHostageAnim;
		}
		// End:0x9B
		if((int(m_bSavedRepWaitAnimIndex) != int(m_bRepWaitAnimIndex)))
		{
			m_bSavedRepWaitAnimIndex = m_bRepWaitAnimIndex;
			SetAnimInfo(int(m_bRepWaitAnimIndex));
		}
	}
	UpdateVisualEffects(fDeltaTime);
	return;
}

//------------------------------------------------------------------
// GetReticuleInfo
//	
//------------------------------------------------------------------
simulated event bool GetReticuleInfo(Pawn ownerReticule, out string szName)
{
	szName = "";
	return (ownerReticule.IsFriend(self) || ownerReticule.IsNeutral(self));
	return;
}

//============================================================================
// FinishInitialization - 
//============================================================================
event FinishInitialization()
{
	// End:0x11
	if((Controller != none))
	{
		UnPossessed();
	}
	Controller = Spawn(ControllerClass);
	Controller.Possess(self);
	Controller.m_PawnRepInfo.m_PawnType = m_ePawnType;
	Controller.m_PawnRepInfo.m_bSex = bIsFemale;
	// End:0x93
	if((m_SoundRepInfo != none))
	{
		m_SoundRepInfo.m_PawnRepInfo = Controller.m_PawnRepInfo;
	}
	m_controller = R6HostageAI(Controller);
	return;
}

//------------------------------------------------------------------
// logAnim: special log for anim
//------------------------------------------------------------------
function logAnim(string sz)
{
	return;
}

//------------------------------------------------------------------
// HasBumpPriority
//	
//------------------------------------------------------------------
function bool HasBumpPriority(R6Pawn bumpedBy)
{
	// End:0x3A
	if(((!bumpedBy.m_bIsPlayer) && R6AIController(bumpedBy.Controller).IsInState('BumpBackUp')))
	{
		return false;
	}
	// End:0x60
	if((IsFriend(bumpedBy) && (!bumpedBy.IsStationary())))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// AnimEnd
//	inherited to detect a modification m_bPostureTransition
//------------------------------------------------------------------
simulated event AnimEnd(int iChannel)
{
	local bool bPreviousPostureTransition;

	bPreviousPostureTransition = m_bPostureTransition;
	super.AnimEnd(iChannel);
	// End:0x88
	if((iChannel == 0))
	{
		// End:0x85
		if(((int(Physics) != int(12)) && (!m_bPawnSpecificAnimInProgress)))
		{
			// End:0x5B
			if((int(m_eEffectiveGrenade) == int(2)))
			{
				SetNextPendingAction(1);				
			}
			else
			{
				// End:0x85
				if(((int(m_eEffectiveGrenade) == int(3)) || (int(m_eEffectiveGrenade) == int(4))))
				{
					SetNextPendingAction(3);
				}
			}
		}		
	}
	else
	{
		// End:0xEC
		if(((iChannel == 16) && m_bPawnSpecificAnimInProgress))
		{
			m_bPawnSpecificAnimInProgress = false;
			// End:0xC2
			if((int(m_eEffectiveGrenade) == int(2)))
			{
				SetNextPendingAction(1);				
			}
			else
			{
				// End:0xEC
				if(((int(m_eEffectiveGrenade) == int(3)) || (int(m_eEffectiveGrenade) == int(4))))
				{
					SetNextPendingAction(3);
				}
			}
		}
	}
	// End:0x134
	if((bPreviousPostureTransition && (!m_bPostureTransition)))
	{
		// End:0x111
		if(m_bCrouchToScaredStandBegin)
		{
			AnimNotify_CrouchToScaredStandEnd();
		}
		m_bPostureTransition = false;
		m_bReactionAnim = false;
		R6ResetAnimBlendParams(1);
		PlayMoving();
		PlayWaiting();
	}
	return;
}

simulated event PlaySpecialPendingAction(R6Pawn.EPendingAction eAction, int iActionInt)
{
	// End:0x36
	if((int(eAction) == int(38)))
	{
		// End:0x33
		if((int(Role) != int(ROLE_Authority)))
		{
			SetAnimInfo(m_iPendingActionInt[int(m_iLocalCurrentActionIndex)]);
		}		
	}
	else
	{
		super.PlaySpecialPendingAction(eAction, iActionInt);
	}
	return;
}

//------------------------------------------------------------------
// SetAnimInfo: set the current anim to play based on his
//	properties. 
//------------------------------------------------------------------
simulated event SetAnimInfo(int ID)
{
	local AnimInfo AnimInfo;

	// End:0x0D
	if((m_mgr == none))
	{
		return;
	}
	AnimInfo = m_mgr.GetAnimInfo(ID);
	// End:0x4A
	if(((int(AnimInfo.m_eGroupAnim) == int(1)) && m_bReactionAnim))
	{		
	}
	else
	{
		// End:0x90
		if((m_bPostureTransition && (int(AnimInfo.m_eGroupAnim) != int(1))))
		{
			// End:0x8E
			if((int(Level.NetMode) == int(NM_Client)))
			{
				m_bPostureTransition = false;				
			}
			else
			{
				return;
			}
		}
	}
	// End:0xED
	if(((int(Role) == int(ROLE_Authority)) && (int(Level.NetMode) != int(NM_Standalone))))
	{
		// End:0xE0
		if((int(AnimInfo.m_eGroupAnim) == int(2)))
		{
			m_bRepWaitAnimIndex = byte(ID);			
		}
		else
		{
			SetNextPendingAction(38, ID);
		}
	}
	// End:0x16B
	if(((int(AnimInfo.m_eGroupAnim) == int(3)) || (int(AnimInfo.m_eGroupAnim) == int(1))))
	{
		m_bPostureTransition = true;
		AnimBlendParams(1, 1.0000000, 0.3000000, 0.0000000);
		PlayAnim(AnimInfo.m_name, 1.0000000, 0.2000000, 1);
		m_bReactionAnim = (int(AnimInfo.m_eGroupAnim) == int(3));		
	}
	else
	{
		R6LoopAnim(AnimInfo.m_name);
	}
	return;
}

//------------------------------------------------------------------
// SetAnimTransition: set the transition anim to play and to the next pawn 
// 	state to go when the transition is over.
// - First it looks if the transition exist in the Manager. This 
//   can be used we want to customize the anim transition. 
// - If not in the mgr, it check if it's anim of type transition.
//   If so, it will blend the current anim with the transition one.
// - If option 1 and 2 failed, it will set the anim and set the new pawn state   
//------------------------------------------------------------------
simulated function SetAnimTransition(int iAnimToPlay, name pawnStateToGo)
{
	local AnimInfo AnimInfo;

	SetAnimInfo(iAnimToPlay);
	// End:0x1D
	if((!m_bUseRagdoll))
	{
		GotoState(pawnStateToGo);
	}
	return;
}

//------------------------------------------------------------------
// Initialize the default value 
//------------------------------------------------------------------
simulated event PostBeginPlay()
{
	local int i;

	// End:0x36
	if((Level.Game != none))
	{
		assert((default.m_iTeam == R6AbstractGameInfo(Level.Game).0));
	}
	m_globalState = GetStateName();
	super.PostBeginPlay();
	SetPhysics(1);
	AttachCollisionBox(1);
	m_mgr = R6HostageMgr(Level.GetHostageMgr());
	return;
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	switch(m_ePosition)
	{
		// End:0x1B
		case 4:
			GotoCrouch();
			// End:0x51
			break;
		// End:0x29
		case 1:
			GotoKneel();
			// End:0x51
			break;
		// End:0x37
		case 3:
			GotoFoetus();
			// End:0x51
			break;
		// End:0x45
		case 2:
			GotoProne();
			// End:0x51
			break;
		// End:0xFFFF
		default:
			GotoStand();
			// End:0x51
			break;
			break;
	}
	return;
}

//------------------------------------------------------------------
// may freeze when the hostage see a new terrorist or rainbow
//------------------------------------------------------------------
function setFrozen(bool bFreeze)
{
	m_bFrozen = bFreeze;
	return;
}

//------------------------------------------------------------------
// setCrouch
//------------------------------------------------------------------
function setCrouch(bool bIsCrouch)
{
	bWantsToCrouch = bIsCrouch;
	// End:0x37
	if(bWantsToCrouch)
	{
		// End:0x37
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_eHandsUpType = 0;
		}
	}
	return;
}

//------------------------------------------------------------------
// setProne
//------------------------------------------------------------------
function setProne(bool bIsProne)
{
	m_bWantsToProne = bIsProne;
	return;
}

//=============================================================================
// isStanding: return true if hostage is standing
//=============================================================================
function bool isStanding()
{
	return (GetStateName() == m_globalState);
	return;
}

//=============================================================================
// isStandingHandUp: return true if hostage is standing with hands up 
//=============================================================================
function bool isStandingHandUp()
{
	return (int(m_eHandsUpType) == int(2));
	return;
}

//=============================================================================
// isFoetus: return true if hostage is in foetus position
//=============================================================================
function bool isFoetus()
{
	return m_bIsFoetus;
	return;
}

//=============================================================================
// isKneeling: return true if hostage is kneeling
//=============================================================================
function bool isKneeling()
{
	return m_bIsKneeling;
	return;
}

//------------------------------------------------------------------
// R6TakeDamage: when wounded, will sets the HurtAnim
//	- inherited
//------------------------------------------------------------------
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	local Pawn.eHealth ePreviousHealth;
	local int iResult, iSndIndex;

	// End:0x0B
	if(m_bExtracted)
	{
		return 0;
	}
	ePreviousHealth = m_eHealth;
	iResult = super.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	// End:0xA5
	if(((int(ePreviousHealth) != int(m_eHealth)) && (int(1) <= int(m_eHealth))))
	{
		// End:0x85
		if((m_controller != none))
		{
			m_controller.SetMovementPace(false);
		}
		// End:0x9F
		if((m_escortedByRainbow != none))
		{
			m_escortedByRainbow.Escort_UpdateTeamSpeed();
		}
		PlayMoving();
	}
	return iResult;
	return;
}

//------------------------------------------------------------------
// PlayWeaponAnimation
//	- inherited to avoid Access None and Wrong 
//------------------------------------------------------------------
function PlayWeaponAnimation()
{
	// End:0x0F
	if(m_bPoliceManMp1)
	{
		super.PlayWeaponAnimation();
	}
	return;
}

function ResetWeaponAnimation()
{
	return;
}

simulated function SetStandWalkingAnim(R6Hostage.EStandWalkingAnim eAnim, bool bUpdatePlayMoving)
{
	m_eCurrentRepHostageAnim.m_eRepStandWalkingAnim = eAnim;
	m_eCurrentRepHostageAnim.m_bRepPlayMoving = bUpdatePlayMoving;
	// End:0x46
	if((int(eAnim) == int(0)))
	{
		SetDefaultWalkAnim();
		m_fWalkingSpeed = 134.0000000;		
	}
	else
	{
		m_standWalkForwardName = 'ScaredStandWalkForward';
		m_standWalkBackName = 'ScaredStandWalkBack';
		m_standWalkLeftName = 'ScaredStandWalkLeft';
		m_standWalkRightName = 'ScaredStandWalkRight';
		m_standTurnLeftName = 'ScaredStandTurnLeft';
		m_standTurnRightName = 'ScaredStandTurnRight';
		m_standDefaultAnimName = 'ScaredStand_nt';
		m_standClimb64DefaultAnimName = 'ScaredStandClimb64Up';
		m_standClimb96DefaultAnimName = 'ScaredStandClimb96Up';
		m_fWalkingSpeed = default.m_fWalkingSpeed;
	}
	m_hurtStandWalkLeftName = m_standWalkLeftName;
	m_hurtStandWalkRightName = m_standWalkRightName;
	// End:0xD9
	if(bUpdatePlayMoving)
	{
		PlayMoving();
	}
	return;
}

//------------------------------------------------------------------
// PlayReaction: if not frozen, play a reaction animation 
//	
//------------------------------------------------------------------
function PlayReaction()
{
	local int Result;

	// End:0x16
	if((m_bFrozen || m_bReactionAnim))
	{
		return;
	}
	// End:0x83
	if(isStandingHandUp())
	{
		Result = Rand(100);
		// End:0x4C
		if((Result < 33))
		{
			SetAnimInfo(m_mgr.ANIM_eStandHandUpReact01);			
		}
		else
		{
			// End:0x6F
			if((Result < 66))
			{
				SetAnimInfo(m_mgr.ANIM_eStandHandUpReact02);				
			}
			else
			{
				SetAnimInfo(m_mgr.ANIM_eStandHandUpReact03);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// PlayWaiting: play waiting animation randomly
//  - inherited
//------------------------------------------------------------------
simulated function PlayWaiting()
{
	local int animIndex, Result;

	// End:0x0B
	if(m_bPostureTransition)
	{
		return;
	}
	// End:0x23
	if((int(Physics) == int(2)))
	{
		PlayFalling();
		return;
	}
	// End:0x34
	if(m_bIsClimbingLadder)
	{
		AnimateStoppedOnLadder();
		return;
	}
	// End:0x120
	if(m_bIsKneeling)
	{
		Result = Rand(100);
		// End:0x67
		if(m_bFrozen)
		{
			SetAnimInfo(m_mgr.ANIM_eKneelFreeze);			
		}
		else
		{
			// End:0xC1
			if(m_bCivilian)
			{
				// End:0x87
				if(m_bPoliceManMp1)
				{
					R6LoopAnim(m_NocsWaitingName);					
				}
				else
				{
					// End:0xAA
					if((Result < 50))
					{
						SetAnimInfo(m_mgr.ANIM_eFoetusWait01);						
					}
					else
					{
						SetAnimInfo(m_mgr.ANIM_eFoetusWait02);
					}
				}				
			}
			else
			{
				// End:0xE4
				if((Result < 33))
				{
					SetAnimInfo(m_mgr.ANIM_eKneelWait01);					
				}
				else
				{
					// End:0x107
					if((Result < 66))
					{
						SetAnimInfo(m_mgr.ANIM_eKneelWait02);						
					}
					else
					{
						SetAnimInfo(m_mgr.ANIM_eKneelWait03);
					}
				}
			}
		}
		return;		
	}
	else
	{
		// End:0x16F
		if(m_bIsFoetus)
		{
			Result = Rand(100);
			// End:0x156
			if((Result < 50))
			{
				SetAnimInfo(m_mgr.ANIM_eFoetusWait01);				
			}
			else
			{
				SetAnimInfo(m_mgr.ANIM_eFoetusWait02);
			}
			return;			
		}
		else
		{
			// End:0x191
			if(m_bIsProne)
			{
				SetAnimInfo(m_mgr.ANIM_eProneWaitBreathe);
				return;				
			}
			else
			{
				// End:0x1F0
				if((bWantsToCrouch || bIsCrouched))
				{
					// End:0x1EE
					if((bWantsToCrouch && bIsCrouched))
					{
						// End:0x1DA
						if((Rand(5) < 1))
						{
							SetAnimInfo(m_mgr.ANIM_eCrouchWait02);							
						}
						else
						{
							SetAnimInfo(m_mgr.ANIM_eCrouchWait01);
						}
					}
					return;
				}
			}
		}
	}
	// End:0x390
	if((!m_bFreed))
	{
		// End:0x23C
		if(m_bFrozen)
		{
			SetAnimInfo(m_mgr.ANIM_eStandHandUpFreeze);
			// End:0x239
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_eHandsUpType = 2;
			}			
		}
		else
		{
			// End:0x273
			if(m_bEscorted)
			{
				// End:0x25C
				if(m_bPoliceManMp1)
				{
					R6LoopAnim(m_NocsWaitingName);					
				}
				else
				{
					SetAnimInfo(m_mgr.ANIM_eStandWaitShiftWeight);
				}				
			}
			else
			{
				// End:0x2E5
				if((int(m_eHandsUpType) == int(0)))
				{
					// End:0x2A8
					if(m_bClassicMissionCivilian)
					{
						SetAnimTransition(m_mgr.ANIM_eScaredStandWait01, 'None');						
					}
					else
					{
						SetAnimTransition(m_mgr.ANIM_eStandHandDownToUp, 'None');
					}
					// End:0x2E2
					if((int(Level.NetMode) != int(NM_Client)))
					{
						m_eHandsUpType = 2;
					}					
				}
				else
				{
					// End:0x38D
					if((int(m_eHandsUpType) == int(2)))
					{
						// End:0x379
						if(m_bCivilian)
						{
							// End:0x340
							if(m_bClassicMissionCivilian)
							{
								// End:0x329
								if((Rand(100) < 50))
								{
									SetAnimInfo(m_mgr.ANIM_eStandWaitCough);									
								}
								else
								{
									SetAnimInfo(m_mgr.ANIM_eStandWaitShiftWeight);
								}								
							}
							else
							{
								// End:0x362
								if((Rand(100) < 60))
								{
									SetAnimInfo(m_mgr.ANIM_eScaredStandWait02);									
								}
								else
								{
									SetAnimInfo(m_mgr.ANIM_eScaredStandWait01);
								}
							}							
						}
						else
						{
							SetAnimInfo(m_mgr.ANIM_eStandHandUpWait01);
						}
					}
				}
			}
		}		
	}
	else
	{
		// End:0x3DD
		if((int(m_eHandsUpType) == int(2)))
		{
			SetAnimTransition(m_mgr.ANIM_eStandHandUpToDown, 'None');
			// End:0x3DA
			if((int(Level.NetMode) != int(NM_Client)))
			{
				m_eHandsUpType = 0;
			}			
		}
		else
		{
			// End:0x451
			if((m_escortedByRainbow != none))
			{
				// End:0x40F
				if((int(Physics) == int(11)))
				{
					SetAnimInfo(m_mgr.ANIM_eStandWaitShiftWeight);					
				}
				else
				{
					// End:0x435
					if((Rand(5) < 1))
					{
						SetAnimTransition(m_mgr.ANIM_eScaredStandWait02, 'None');						
					}
					else
					{
						SetAnimTransition(m_mgr.ANIM_eScaredStandWait01, 'None');
					}
				}				
			}
			else
			{
				// End:0x473
				if((Rand(100) < 75))
				{
					SetAnimInfo(m_mgr.ANIM_eStandWaitShiftWeight);					
				}
				else
				{
					SetAnimInfo(m_mgr.ANIM_eStandWaitCough);
				}
			}
		}
	}
	return;
}

//////////////////////////////////////////////
simulated event GotoStand()
{
	setCrouch(false);
	GotoState('None');
	return;
}

///////////////////////////////////////////////
simulated event GotoCrouch()
{
	GotoState('Crouching');
	return;
}

//////////////////////////////////////////////
simulated event GotoKneel()
{
	setCrouch(false);
	// End:0x28
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eHandsUpType = 1;
	}
	// End:0x3B
	if(m_bPoliceManMp1)
	{
		GotoState('Kneeling');		
	}
	else
	{
		SetAnimTransition(m_mgr.ANIM_eStandToKneel, 'Kneeling');
	}
	return;
}

//////////////////////////////////////////////
simulated event GotoFoetus()
{
	setCrouch(false);
	// End:0x28
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eHandsUpType = 0;
	}
	SetAnimTransition(m_mgr.ANIM_eStandToFoetus, 'Foetus');
	return;
}

//////////////////////////////////////////////
simulated event GotoProne()
{
	GotoState('Prone');
	return;
}

/////////////////////////////////////////////
function GotoFrozen()
{
	setFrozen(true);
	SetAnimInfo(m_mgr.ANIM_eStandHandUpFreeze);
	// End:0x3C
	if((int(Level.NetMode) != int(NM_Client)))
	{
		m_eHandsUpType = 2;
	}
	return;
}

//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandEnd
//	
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandEnd()
{
	m_bCrouchToScaredStandBegin = false;
	setCrouch(false);
	return;
}

//------------------------------------------------------------------
// AnimNotify_CrouchToScaredStandBegin
//	
//------------------------------------------------------------------
function AnimNotify_CrouchToScaredStandBegin()
{
	m_bCrouchToScaredStandBegin = true;
	return;
}

//------------------------------------------------------------------
// PlayDuck
//	- inherited
//------------------------------------------------------------------
function PlayDuck()
{
	return;
}

//------------------------------------------------------------------
// PlayCrouchToProne
//	- inherited
//------------------------------------------------------------------
simulated function PlayCrouchToProne(optional bool bForcedByClient)
{
	SetAnimInfo(m_mgr.ANIM_eCrouchToProne);
	return;
}

//------------------------------------------------------------------
// PlayProneToCrouch
//	- inherited
//------------------------------------------------------------------
simulated function PlayProneToCrouch(optional bool bForcedByClient)
{
	SetAnimInfo(m_mgr.ANIM_eProneToCrouch);
	// End:0x3D
	if((int(Level.NetMode) == int(NM_Client)))
	{
		m_bWantsToProne = false;
		bWantsToCrouch = true;
	}
	return;
}

simulated function PlayCoughing()
{
	local name animName;

	// End:0x0B
	if(m_bIsClimbingLadder)
	{
		return;
	}
	m_bPawnSpecificAnimInProgress = true;
	// End:0x3E
	if(m_bIsProne)
	{
		AnimBlendParams(16, 1.0000000,,, 'R6 Pelvis');
		animName = 'ProneGazed';		
	}
	else
	{
		AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
		animName = 'Gazed';
	}
	PlayAnim(animName, 1.0000000, 0.5000000, 16);
	return;
}

simulated function PlayBlinded()
{
	local name animName;

	// End:0x0B
	if(m_bIsClimbingLadder)
	{
		return;
	}
	m_bPawnSpecificAnimInProgress = true;
	// End:0x3E
	if(m_bIsProne)
	{
		AnimBlendParams(16, 1.0000000,,, 'R6 Pelvis');
		animName = 'ProneBlinded';		
	}
	else
	{
		AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
		animName = 'Blinded';
	}
	PlayAnim(animName, 1.0000000, 0.5000000, 16);
	return;
}

//------------------------------------------------------------------
// CanBeAffectedByGrenade: return true if can be affected by the grenade 
//   at this moment
//------------------------------------------------------------------
simulated function bool CanBeAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	local bool bAffected;

	bAffected = super.CanBeAffectedByGrenade(aGrenade, eType);
	// End:0x24
	if((!bAffected))
	{
		return false;
	}
	// End:0x3C
	if((IsInState('Foetus') || m_bPostureTransition))
	{
		return false;
	}
	return true;
	return;
}

simulated function PlayDoorAnim(R6IORotatingDoor Door)
{
	local bool bOpensTowardsPawn;

	m_bPawnSpecificAnimInProgress = true;
	AnimBlendParams(16, 1.0000000,,, 'R6 Spine2');
	bOpensTowardsPawn = Door.DoorOpenTowardsActor(self);
	// End:0x53
	if(bOpensTowardsPawn)
	{
		PlayAnim('StandDoorPull', 1.0000000, 0.2000000, 16);		
	}
	else
	{
		PlayAnim('StandDoorPush', 1.0000000, 0.2000000, 16);
	}
	return;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	// End:0x4E
	if(((((!IsAlive()) || m_bExtracted) || IsEnemy(PlayerController.Pawn)) || m_bClassicMissionCivilian))
	{
		Query.iHasAction = 0;		
	}
	else
	{
		Query.iHasAction = 1;
		// End:0x82
		if((fDistance < m_fCircumstantialActionRange))
		{
			Query.iInRange = 1;			
		}
		else
		{
			Query.iInRange = 0;
		}
		// End:0x24F
		if((PlayerController.GameReplicationInfo.m_szGameTypeFlagRep == "RGM_LimitSeatsAdvMode"))
		{
			// End:0x197
			if(m_controller.Order_canFollowMe())
			{
				// End:0x183
				if((R6PlayerController(PlayerController).m_pawn.m_aEscortedHostage[0] == none))
				{
					Query.textureIcon = Texture'R6ActionIcons.HostageFollowMe';
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
			}
			else
			{
				// End:0x1C8
				if((m_escortedByRainbow != R6PlayerController(PlayerController).m_pawn))
				{
					Query.iHasAction = 0;					
				}
				else
				{
					Query.textureIcon = Texture'R6ActionIcons.HostageStayHere';
					Query.iPlayerActionID = 2;
					Query.iTeamActionID = 2;
					Query.iTeamActionIDList[0] = 2;
					Query.iTeamActionIDList[1] = 0;
					Query.iTeamActionIDList[2] = 0;
					Query.iTeamActionIDList[3] = 0;
				}
			}			
		}
		else
		{
			// End:0x2AD
			if(m_controller.Order_canFollowMe())
			{
				Query.textureIcon = Texture'R6ActionIcons.HostageFollowMe';
				Query.iPlayerActionID = 1;
				Query.iTeamActionID = 1;
				Query.iTeamActionIDList[0] = 1;				
			}
			else
			{
				Query.textureIcon = Texture'R6ActionIcons.HostageStayHere';
				Query.iPlayerActionID = 2;
				Query.iTeamActionID = 2;
				Query.iTeamActionIDList[0] = 2;
			}
			Query.iTeamActionIDList[1] = 0;
			Query.iTeamActionIDList[2] = 0;
			Query.iTeamActionIDList[3] = 0;
		}
	}
	return;
}

simulated function string R6GetCircumstantialActionString(int iAction)
{
	switch(iAction)
	{
		// End:0x37
		case int(1):
			return Localize("RDVOrder", "Order_FollowMe", "R6Menu");
		// End:0x67
		case int(2):
			return Localize("RDVOrder", "Order_StayHere", "R6Menu");
		// End:0xFFFF
		default:
			return "";
			break;
	}
	return;
}

//------------------------------------------------------------------
// EnteredExtractionZone
//	
//------------------------------------------------------------------
function EnteredExtractionZone(R6AbstractExtractionZone Zone)
{
	// End:0x32
	if(((!m_bCivilian) && (!m_bPoliceManMp1)))
	{
		// End:0x32
		if((m_controller != none))
		{
			m_controller.SetStateExtracted();
		}
	}
	return;
}

//------------------------------------------------------------------
// ProcessBuildDeathMessage
//	
//------------------------------------------------------------------
function bool ProcessBuildDeathMessage(Pawn Killer, out string szPlayerName)
{
	// End:0x83
	if((int(Killer.m_ePawnType) == int(1)))
	{
		// End:0x78
		if((Level.Game != none))
		{
			// End:0x6D
			if((!(Level.Game.m_szGameTypeFlag == "RGM_LimitSeatsAdvMode")))
			{
				m_bSuicideType = 6;				
			}
			else
			{
				m_bSuicideType = 10;
			}			
		}
		else
		{
			m_bSuicideType = 6;
		}		
	}
	else
	{
		// End:0xA7
		if((int(Killer.m_ePawnType) == int(2)))
		{
			m_bSuicideType = 7;			
		}
		else
		{
			m_bSuicideType = 5;
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
		vEyeHeight.Z = 30.0000000;		
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
				vEyeHeight.Z = 25.0000000;				
			}
			else
			{
				// End:0x70
				if(m_bIsFoetus)
				{
					vEyeHeight.Z = -60.0000000;					
				}
				else
				{
					vEyeHeight.Z = 65.0000000;
				}
			}
		}
	}
	return vEyeHeight;
	return;
}

 // MPF1
///////////////////////////////
/////MissionPack1
//============================================================================
// SetToNormalWeapon - 
//============================================================================
function SetToNormalWeapon()
{
	EngineWeapon = GetWeaponInGroup(1);
	// End:0x4C
	if((EngineWeapon == none))
	{
		logX("SetToNormalWeapon-No weapon!!!");
		EngineWeapon = GetWeaponInGroup(2);
	}
	EngineWeapon.RemoteRole = ROLE_SimulatedProxy;
	// End:0x9C
	if((EngineWeapon != none))
	{
		AttachWeapon(EngineWeapon, 'TagRightHand');
		EngineWeapon.WeaponInitialization(self);
		m_pBulletManager.SetBulletParameter(EngineWeapon);
	}
	return;
}

simulated state Crouching
{
	simulated function BeginState()
	{
		// End:0x10
		if(m_bIsProne)
		{
			setProne(false);
		}
		// End:0x2F
		if(((!bWantsToCrouch) || (!bIsCrouched)))
		{
			setCrouch(true);
		}
		return;
	}

///////////////////////////////////////////////
	simulated event GotoCrouch()
	{
		return;
	}

//////////////////////////////////////////////
	simulated event GotoFoetus()
	{
		SetAnimTransition(m_mgr.ANIM_eFoetus_nt, 'Foetus');
		setCrouch(false);
		return;
	}

//////////////////////////////////////////////
	simulated event GotoStand()
	{
		SetAnimTransition(m_mgr.ANIM_eCrouchToScaredStand, 'None');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoProne()
	{
		GotoState('Prone');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoKneel()
	{
		SetAnimTransition(m_mgr.ANIM_eKneelWait01, 'Kneeling');
		return;
	}
	stop;
}

simulated state Kneeling
{
	simulated function BeginState()
	{
		m_bIsKneeling = true;
		// End:0x29
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_eHandsUpType = 1;
		}
		setCrouch(false);
		return;
	}

	simulated function EndState()
	{
		// End:0x21
		if((int(Level.NetMode) != int(NM_Client)))
		{
			m_eHandsUpType = 0;
		}
		m_bIsKneeling = false;
		return;
	}

//------------------------------------------------------------------
// PlayReaction: if not frozen, play a reaction animation 
//	
//------------------------------------------------------------------
	simulated function PlayReaction()
	{
		local int Result;

		// End:0x16
		if((m_bFrozen || m_bReactionAnim))
		{
			return;
		}
		Result = Rand(100);
		// End:0x43
		if((Result < 33))
		{
			SetAnimInfo(m_mgr.ANIM_eKneelReact01);			
		}
		else
		{
			// End:0x66
			if((Result < 66))
			{
				SetAnimInfo(m_mgr.ANIM_eKneelReact02);				
			}
			else
			{
				SetAnimInfo(m_mgr.ANIM_eKneelReact03);
			}
		}
		return;
	}

/////////////////////////////////////////////
	simulated function GotoFrozen()
	{
		setFrozen(true);
		SetAnimInfo(m_mgr.ANIM_eKneelFreeze);
		return;
	}

//////////////////////////////////////////////
	simulated event GotoStand()
	{
		SetAnimTransition(m_mgr.ANIM_eKneelToStand, 'None');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoKneel()
	{
		return;
	}

//////////////////////////////////////////////
	simulated event GotoFoetus()
	{
		SetAnimTransition(m_mgr.ANIM_eKneelToFoetus, 'Foetus');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoProne()
	{
		SetAnimTransition(m_mgr.ANIM_eKneelToProne, 'Prone');
		return;
	}

///////////////////////////////////////////////
	simulated event GotoCrouch()
	{
		SetAnimTransition(m_mgr.ANIM_eKneelToCrouch, 'Crouching');
		return;
	}
	stop;
}

simulated state Prone
{
	simulated function BeginState()
	{
		// End:0x1F
		if(((!m_bWantsToProne) || (!m_bIsProne)))
		{
			setProne(true);
		}
		return;
	}

//////////////////////////////////////////////
	simulated event GotoStand()
	{
		SetAnimTransition(m_mgr.ANIM_eProneToCrouch, 'Crouching');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoKneel()
	{
		return;
	}

//////////////////////////////////////////////
	simulated event GotoFoetus()
	{
		return;
	}

//////////////////////////////////////////////
	simulated event GotoProne()
	{
		return;
	}

///////////////////////////////////////////////
	simulated event GotoCrouch()
	{
		GotoState('Crouching');
		return;
	}
	stop;
}

simulated state Foetus
{
//////////////////////////////////////////////
	simulated event GotoStand()
	{
		SetAnimTransition(m_mgr.ANIM_eFoetusToStand, 'None');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoKneel()
	{
		SetAnimTransition(m_mgr.ANIM_eFoetusToKneel, 'Kneeling');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoFoetus()
	{
		return;
	}

///////////////////////////////////////////////
	simulated event GotoCrouch()
	{
		SetAnimTransition(m_mgr.ANIM_eFoetusToCrouch, 'Crouching');
		return;
	}

//////////////////////////////////////////////
	simulated event GotoProne()
	{
		SetAnimTransition(m_mgr.ANIM_eFoetusToProne, 'Prone');
		return;
	}

	simulated function BeginState()
	{
		m_bIsFoetus = true;
		return;
	}

	simulated function EndState()
	{
		m_bIsFoetus = false;
		return;
	}
	stop;
}

defaultproperties
{
	m_ePersonality=1
	m_iIndex=-1
	m_bPatrolForward=true
	m_stayInFoetusTime=(m_fMin=5.0000000,m_fMax=8.0000000)
	m_stayFrozenTime=(m_fMin=1.0000000,m_fMax=3.0000000)
	m_stayProneTime=(m_fMin=3.0000000,m_fMax=4.0000000)
	m_stayCautiousGuardedStateTime=(m_fMin=7.0000000,m_fMax=10.0000000)
	m_patrolAreaWaitTween=(m_fMin=2.0000000,m_fMax=4.0000000)
	m_changeOrientationTween=(m_fMin=5.0000000,m_fMax=15.0000000)
	m_sightRadiusTween=(m_fMin=4000.0000000,m_fMax=5000.0000000)
	m_updatePaceTween=(m_fMin=1.5000000,m_fMax=2.6000000)
	m_waitingGoCrouchTween=(m_fMin=2.5000000,m_fMax=4.0000000)
	m_bAutoClimbLadders=true
	m_bAvoidFacingWalls=false
	m_fWalkingSpeed=250.0000000
	m_fWalkingBackwardStrafeSpeed=100.0000000
	m_fRunningSpeed=400.0000000
	m_fRunningBackwardStrafeSpeed=320.0000000
	m_fCrouchedWalkingSpeed=125.0000000
	m_fCrouchedWalkingBackwardStrafeSpeed=100.0000000
	m_fCrouchedRunningSpeed=250.0000000
	m_fCrouchedRunningBackwardStrafeSpeed=250.0000000
	m_standRunBackName="ScaredStandWalkBack"
	m_standWalkBackName="ScaredStandWalkBack"
	m_standFallName="ScaredStandFall"
	m_standLandName="ScaredStandLand"
	m_crouchFallName="crouchFall"
	m_crouchWalkForwardName="CrouchRunForward"
	m_standStairWalkUpName="StandStairWalkUp"
	m_standStairWalkUpBackName="StandStairWalkUp"
	m_standStairWalkDownName="StandStairWalkDown"
	m_standStairWalkDownBackName="StandStairWalkDown"
	m_standStairWalkDownRightName="StandWalkRight"
	m_standStairRunUpName="StandStairRunUp"
	m_standStairRunUpBackName="StandStairRunUp"
	m_standStairRunUpRightName="StandWalkRight"
	m_standStairRunDownName="StandStairRunDown"
	m_standStairRunDownBackName="StandStairRunDown"
	m_standStairRunDownRightName="StandWalkRight"
	m_crouchStairWalkDownName="CrouchStairWalkDown"
	m_crouchStairWalkDownBackName="CrouchStairWalkUp"
	m_crouchStairWalkDownRightName="CrouchWalkRight"
	m_crouchStairWalkUpName="CrouchStairWalkUp"
	m_crouchStairWalkUpBackName="CrouchStairWalkDown"
	m_crouchStairWalkUpRightName="CrouchWalkRight"
	m_crouchStairRunUpName="CrouchStairWalkUp"
	m_crouchStairRunDownName="CrouchStairWalkDown"
	m_crouchDefaultAnimName="Crouch_nt"
	m_standDefaultAnimName="Stand_nt"
	m_ePawnType=3
	m_bMakesTrailsWhenProning=true
	ControllerClass=Class'R6Engine.R6HostageAI'
	CollisionHeight=80.0000000
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel17'
	RotationRate=(Pitch=4096,Yaw=45000,Roll=0)
}
