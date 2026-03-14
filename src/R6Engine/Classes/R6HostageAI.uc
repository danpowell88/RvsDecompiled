//=============================================================================
// R6HostageAI - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6HostageAI.uc : This is the AI Controller class for all hostages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//=============================================================================
class R6HostageAI extends R6AIController
 native;

const C_iKeepDistanceFromPawn = 105;

struct OrderInfo
{
    // **** if modified, update this struct in r6engine.h ****
	var bool m_bOrderedByRainbow;
	var R6Pawn m_pawn1;  // the pawn involved in the order
	var R6Hostage.eHostageOrder m_eOrder;  // the order
	var float m_fTime;  // the game level time
	var Actor m_actor;
};

struct PlaySndInfo
{
	var int m_iLastTime;  // last time the sound was played
	var int m_iInBetweenTime;  // time to wait before playing again the sound
};

var R6Hostage.EStartingPosition m_eTransitionPosition;  // position to go when doing a transition
var int m_iNotGuardedSince;  // time since the hostage is no longer guarded
var int m_iLastHearNoiseTime;  // last hear noise detected
var const int c_iDistanceMax;  // distance max from someone before catching up
var const int c_iDistanceCatchUp;  // when catching up, the hostage will stop at this min distance
var const int c_iDistanceToStartToRun;  // if far from the group, start to run to catch up
var int m_iPlayReaction1;  // play reaction: used to desynchronis hostage reaction to threat
var int m_iPlayReaction2;
var int m_iWaitingTime;  // Used in patrol when waiting at a node or when freed
var int m_iFacingTime;  // Used in patrol when waiting at a node
var int m_lastUpdatePaceTime;  // Used in following pawn
var int m_iNbOrder;  // number of order in the queue
var const int c_iCowardModifier;  // personnality modifier
var const int c_iNormalModifier;  // personnality modifier
var const int c_iBraveModifier;  // personnality modifier
var const int c_iWoundedModifier;  // personnality modifier
var const int c_iGasModifier;  // personnality modifier
var const int c_iEnemyNotVisibleTime;  // min time before stopping when running away from an enemy
var const int c_iCautiousLastHearNoiseTime;  // if no noise is hear, stay cautious for this length of time
var const int c_iRunForCoverOfGrenadeMinDist;
var int m_iDbgRoll;
// NEW IN 1.60
var int m_iRandomNumber;
var bool m_bForceToStayHere;  // true when the rainbow tell him to stay here
var bool m_bRunningToward;  // true if running toward the group. used in FollowingPawn state
var bool m_bRunToRainbowSuccess;  // true when in succeeded (used in Guarded_runTowardRainbow)
var bool m_bStopDoTransition;  // in follow mode, we may have to stop completly to do a transition
var bool m_bNeedToRunToCatchUp;  // set to true when c_iDistanceToStartToRun is reached
var bool m_bSlowedPace;  // true when following someone walking in reverse
var bool m_bFollowIncreaseDistance;
var bool m_bLatentFnStopped;  // used in state code: true when the we manually stop the latent function
var bool m_bDbgIgnoreThreat;  // debug: ignore threat
var bool m_bDbgIgnoreRainbow;
var bool m_bDbgRoll;
var bool m_bool;
var bool bThreatShowLog;
var bool m_bFirstTimeClarkComment;
var float m_float;
var R6Hostage m_pawn;  // to get away from copyinh R6Hostage(pawn)
var R6HostageMgr m_mgr;
var R6HostageVoices m_VoicesManager;
var R6Pawn m_pawnToFollow;  // run toward, follow this pawn
var R6Pawn m_lastSeenPawn;
var Actor m_runAwayOfGrenade;  // used when Enemy can't be used (ie: for grenade)
var R6Terrorist m_terrorist;  // terroriste with who's interacting with
var R6Pawn m_escort;  // pawn who escortedvar
var Actor m_pGotoToExtractionZone;
var R6EngineWeapon DefaultWeapon;
// NEW IN 1.60
var PathNode m_pCoverNode;
var name m_threatGroupName;  // group name used for the processing threat
var name m_runForCoverStateToGoOnFailure;
var name m_runForCoverStateToGoOnSuccess;
var name m_reactToGrenadeStateToReturn;
var name m_name;
//MissionPack1 // MPF1
var Class<R6EngineWeapon> DefaultWeaponClass;
// NEW IN 1.60
var array<PathNode> m_pListOfCoverNodes;
var RandomTweenNum m_AITickTime;  // frequence to tick the AI Timer. m_fMin is used for quick AI update in the state code
var ThreatInfo m_threatInfo;  // info on the current threat of the civilian
var Vector m_vReactionDirection;  // 3d point where the hostage looked/focused when reacted to SeePlayer in Guarded state
var OrderInfo m_aOrderInfo[2];  // list of order queued (used by the order system
var RandomTweenNum m_RunForCoverMinTween;  // time allowed to run for cover before starting to be aware of what's going on
var RandomTweenNum m_scareToDeathTween;
var RandomTweenNum m_stayBlindedTweenTime;
var Vector m_vMoveToDest;  // destination
// used in state code 
var Rotator m_rotator;
var Vector m_vectorTemp;
var PlaySndInfo m_aPlaySndInfo[12];

event PostBeginPlay()
{
	local int i;

	super(Controller).PostBeginPlay();
	m_mgr = R6HostageMgr(Level.GetHostageMgr());
	assert(__NFUN_153__(12, m_mgr.11));
	i = 0;
	J0x39:

	// End:0x61 [Loop If]
	if(__NFUN_150__(i, 12))
	{
		m_aPlaySndInfo[i].m_iInBetweenTime = 1;
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x39;
	}
	m_aPlaySndInfo[m_mgr.6].m_iInBetweenTime = 5;
	m_aPlaySndInfo[m_mgr.1].m_iInBetweenTime = 2;
	return;
}

/////////////////////////////////////////////////////////////////////////
// Possess: once the pawn is possed, initialized the controller 
// - inherited
function Possess(Pawn aPawn)
{
	local int i;

	super.Possess(aPawn);
	m_pawn = R6Hostage(Pawn);
	m_VoicesManager = R6HostageVoices(R6AbstractGameInfo(Level.Game).GetHostageVoicesMgr(Level.m_eHostageVoices, m_pawn.bIsFemale));
	// End:0x74
	if(__NFUN_255__(__NFUN_284__(), 'Configuration'))
	{
		__NFUN_113__('Configuration');
	}
	return;
}

//------------------------------------------------------------------
// Tick
//	
//------------------------------------------------------------------
function Tick(float fDeltaTime)
{
	super.Tick(fDeltaTime);
	// End:0x1C
	if(__NFUN_151__(m_iNbOrder, 0))
	{
		Order_Process();
	}
	return;
}

//------------------------------------------------------------------
// Died: called when the pawn is declared dead 
//------------------------------------------------------------------
function PawnDied()
{
	StopFollowingPawn(false);
	// End:0x20
	if(__NFUN_151__(m_pListOfCoverNodes.Length, 0))
	{
		m_pListOfCoverNodes.Remove(0, m_pListOfCoverNodes.Length);
	}
	super.PawnDied();
	return;
}

//------------------------------------------------------------------
// setFreed: freed an hostage. If he was a bait, he'll become a PERSO_Normal
//	
//------------------------------------------------------------------
function SetFreed(bool bFreed)
{
	m_pawn.m_bFreed = bFreed;
	m_bIgnoreBackupBump = false;
	// End:0x51
	if(m_pawn.m_bFreed)
	{
		m_pawn.setFrozen(false);
		m_iNotGuardedSince = 0;
		m_iLastHearNoiseTime = 0;		
	}
	// End:0x8F
	if(__NFUN_130__(m_pawn.m_bFreed, __NFUN_154__(int(m_pawn.m_ePersonality), int(3))))
	{
		m_pawn.m_ePersonality = 1;
	}
	return;
}

//------------------------------------------------------------------
// SetPawnPosition
//	
//------------------------------------------------------------------
function SetPawnPosition(R6Hostage.EStartingPosition ePos)
{
	// End:0x2E
	if(__NFUN_154__(int(ePos), int(5)))
	{
		// End:0x26
		if(__NFUN_152__(__NFUN_167__(100), 50))
		{
			ePos = 1;			
		}
		else
		{
			ePos = 0;
		}
	}
	m_pawn.m_ePosition = ePos;
	switch(ePos)
	{
		// End:0x60
		case 4:
			m_pawn.GotoCrouch();
			// End:0xB7
			break;
		// End:0x77
		case 1:
			m_pawn.GotoKneel();
			// End:0xB7
			break;
		// End:0x8E
		case 3:
			m_pawn.GotoFoetus();
			// End:0xB7
			break;
		// End:0xA5
		case 2:
			m_pawn.GotoProne();
			// End:0xB7
			break;
		// End:0xFFFF
		default:
			m_pawn.GotoStand();
			break;
	}
	return;
}

//------------------------------------------------------------------
// SetPace: set the pace and adjust it if wounded
//	
//------------------------------------------------------------------
function SetPace(R6Pawn.eMovementPace ePace)
{
	// End:0x1D
	if(Pawn.m_bTryToUnProne)
	{
		ePace = 1;		
	}
	else
	{
		// End:0x6D
		if(Pawn.bTryToUncrouch)
		{
			// End:0x65
			if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(3)), __NFUN_154__(int(ePace), int(3))))
			{
				ePace = 3;				
			}
			else
			{
				ePace = 2;
			}
		}
	}
	m_pawn.m_eMovementPace = ePace;
	CheckPaceForInjury(m_pawn.m_eMovementPace);
	return;
}

//==============================================================
// SetStateGuarded: set the default value, his starting position 
//                  (kneel, foetus) of the pawn and set to Guarded
//                  state
function SetStateGuarded(R6Hostage.EStartingPosition ePos, int iHstSndEvent)
{
	// End:0x1F
	if(__NFUN_155__(iHstSndEvent, m_mgr.0))
	{
		ProcessPlaySndInfo(iHstSndEvent);
	}
	ResetThreatInfo("SetStateGuarded");
	m_pawn.setFrozen(false);
	m_eTransitionPosition = ePos;
	__NFUN_113__('Guarded');
	return;
}

//------------------------------------------------------------------
// SetStateFollowingPawn: set values for SetStateFollowingPawn and go
//	to that state
//------------------------------------------------------------------
function SetStateFollowingPawn(R6Pawn runTo, bool bFreed, int iHstSndEvent)
{
	// End:0x1F
	if(__NFUN_155__(iHstSndEvent, m_mgr.0))
	{
		ProcessPlaySndInfo(iHstSndEvent);
	}
	SetFreed(bFreed);
	m_pawnToFollow = R6Rainbow(runTo).Escort_GetPawnToFollow(true);
	m_bRunningToward = true;
	SetThreatState('FollowingPawn');
	__NFUN_113__(m_threatInfo.m_state);
	return;
}

///////////////////////////////////////////////////////////////////////////
// Roll a random number adjusted by the personnality
function int Roll(int iMax)
{
	local int iRoll;

	iRoll = __NFUN_146__(__NFUN_167__(iMax), 1);
	switch(m_pawn.m_ePersonality)
	{
		// End:0x34
		case 0:
			__NFUN_161__(iRoll, c_iCowardModifier);
			// End:0x5F
			break;
		// End:0x48
		case 1:
			__NFUN_161__(iRoll, c_iNormalModifier);
			// End:0x5F
			break;
		// End:0x5C
		case 2:
			__NFUN_161__(iRoll, c_iBraveModifier);
			// End:0x5F
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x84
	if(__NFUN_154__(int(m_pawn.m_eHealth), int(1)))
	{
		__NFUN_162__(iRoll, c_iWoundedModifier);
	}
	// End:0xC4
	if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eEffectiveGrenade), int(2)), __NFUN_154__(int(m_pawn.m_eEffectiveGrenade), int(3))))
	{
		__NFUN_162__(iRoll, c_iGasModifier);
	}
	// End:0xF1
	if(m_bDbgRoll)
	{
		__NFUN_231__(__NFUN_112__("m_bDbgRoll: ", string(m_iDbgRoll)));
		iRoll = m_iDbgRoll;
	}
	iRoll = int(__NFUN_246__(float(iRoll), 0.0000000, 100.0000000));
	return iRoll;
	return;
}

//------------------------------------------------------------------
// GetRandomTurn90: return a random turn left or right 90'
//	
//------------------------------------------------------------------
function Rotator GetRandomTurn90()
{
	local Rotator rRot;

	rRot = Pawn.Rotation;
	// End:0x33
	if(__NFUN_150__(__NFUN_167__(100), 50))
	{
		__NFUN_162__(rRot.Yaw, 16383);		
	}
	else
	{
		__NFUN_161__(rRot.Yaw, 16383);
	}
	return rRot;
	return;
}

/////////////////////////////////////////////////////////////////////////////
// CanReturnToNormalState: return true if the hostage can return to a normal 
//                         state. 
function bool CanReturnToNormalState()
{
	local R6Rainbow aR6Rainbow;
	local R6Pawn P;
	local int numFriend, numEnemy;

	numFriend = 0;
	numEnemy = 0;
	// End:0xDD
	foreach __NFUN_312__(Class'R6Engine.R6Pawn', P, Pawn.SightRadius, m_pawn.Location)
	{
		// End:0x95
		if(__NFUN_130__(m_pawn.IsEnemy(P), P.IsAlive()))
		{
			// End:0x8E
			if(__NFUN_132__(P.IsFighting(), P.m_bIsKneeling))
			{				
				return false;
			}
			__NFUN_165__(numEnemy);
		}
		// End:0xDC
		if(__NFUN_130__(m_pawn.IsFriend(P), P.IsAlive()))
		{
			// End:0xD5
			if(P.IsFighting())
			{				
				return false;
			}
			__NFUN_165__(numFriend);
		}		
	}	
	// End:0x101
	if(__NFUN_176__(Level.TimeSeconds, float(__NFUN_146__(m_iLastHearNoiseTime, c_iCautiousLastHearNoiseTime))))
	{
		return false;
	}
	// End:0x11B
	if(__NFUN_132__(__NFUN_154__(numFriend, 0), __NFUN_154__(numEnemy, 0)))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// ReturnToNormalState: when return to normal state he still could
//	be guarded or not
//------------------------------------------------------------------
function ReturnToNormalState(optional bool bNoTimer)
{
	// End:0x24
	if(IsGuarded(bNoTimer))
	{
		SetStateGuarded(1, m_mgr.0);		
	}
	else
	{
		__NFUN_113__('Freed');
	}
	return;
}

//------------------------------------------------------------------
// SeePlayer: 
//	- inherited
//------------------------------------------------------------------
function SeePlayer(Pawn P)
{
	local R6Pawn seen;

	// End:0x0B
	if(m_bDbgIgnoreThreat)
	{
		return;
	}
	seen = R6Pawn(P);
	// End:0x27
	if(__NFUN_154__(__NFUN_167__(2), 0))
	{
		return;
	}
	// End:0x34
	if(__NFUN_114__(seen, none))
	{
		return;
	}
	// End:0x5E
	if(__NFUN_132__(__NFUN_129__(seen.IsAlive()), seen.m_bIsKneeling))
	{
		return;
	}
	// End:0x7C
	if(m_pawn.m_bCivilian)
	{
		m_lastSeenPawn = none;
		return;		
	}
	else
	{
		// End:0xE5
		if(m_pawn.m_bFreed)
		{
			// End:0xC0
			if(__NFUN_130__(m_pawn.IsFriend(seen), __NFUN_114__(m_lastSeenPawn, none)))
			{
				m_lastSeenPawn = seen;				
			}
			else
			{
				// End:0xE2
				if(m_pawn.IsEnemy(seen))
				{
					m_lastSeenPawn = seen;
				}
			}			
		}
		else
		{
			// End:0x121
			if(__NFUN_130__(__NFUN_119__(m_lastSeenPawn, seen), m_pawn.IsFriend(seen)))
			{
				m_vReactionDirection = seen.Location;
			}
			m_lastSeenPawn = seen;
		}
	}
	return;
}

//------------------------------------------------------------------
// SeePlayerMgr: called once in a while to manage the lastSeenPawn
//	This mgr allows to have some delay in the AI behavior of hostage.
//  So they don't react all at the same time on a SeePlayer
//------------------------------------------------------------------
function SeePlayerMgr()
{
	// End:0x16
	if(__NFUN_129__(m_lastSeenPawn.IsAlive()))
	{
		return;
	}
	ProcessThreat(m_lastSeenPawn, 0);
	m_lastSeenPawn = none;
	return;
}

//------------------------------------------------------------------
// HearNoise: HearNoise used when the hostage is freed, civilian and 
//  guarded by terro.
//	- inherited
//------------------------------------------------------------------
event HearNoise(float fLoudness, Actor NoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
{
	local Actor aGrenade;

	// End:0x36
	if(__NFUN_130__(m_pawn.m_bDontHearPlayer, R6Pawn(NoiseMaker.Instigator).m_bIsPlayer))
	{
		return;
	}
	// End:0x41
	if(m_bDbgIgnoreThreat)
	{
		return;
	}
	// End:0xB2
	if(m_pawn.m_bClassicMissionCivilian)
	{
		// End:0xAF
		if(__NFUN_129__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(eType), int(2)), __NFUN_154__(int(eType), int(3))), __NFUN_154__(int(eType), int(4))), __NFUN_130__(__NFUN_154__(int(eType), int(1)), __NFUN_154__(int(ESoundType), int(1))))))
		{
			return;
		}		
	}
	else
	{
		// End:0xEA
		if(__NFUN_129__(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(eType), int(2)), __NFUN_154__(int(eType), int(3))), __NFUN_154__(int(eType), int(4)))))
		{
			return;
		}
	}
	// End:0xF5
	if(IsInTemporaryState())
	{
		return;
	}
	m_iLastHearNoiseTime = int(Level.TimeSeconds);
	ProcessThreat(NoiseMaker, eType);
	return;
}

//------------------------------------------------------------------
// CanConsiderThreat: once a threat is detected and may have
//	an exception, this is where we check if the threat can be
//  consired by the R6hostageMgr::GetThreatInfoFromThreat
//------------------------------------------------------------------
function bool CanConsiderThreat(R6Pawn aPawn, Actor aThreat, name considerThreat)
{
	// End:0x27
	if(__NFUN_254__(considerThreat, 'IsEnemySound'))
	{
		return m_pawn.IsEnemy(aPawn);		
	}
	else
	{
		// End:0x3F
		if(__NFUN_254__(considerThreat, 'CanSeeFriend'))
		{
			return __NFUN_129__(m_bForceToStayHere);
		}
	}
	m_pawn.logWarning(__NFUN_112__("CanConsiderThreat: failed to find the threat=", string(considerThreat)));
	return false;
	return;
}

//------------------------------------------------------------------
// GetRainbowWhoEscortThisPawn: get the rainbow who will escort
//------------------------------------------------------------------
function R6Rainbow GetRainbowWhoEscortThisPawn(R6Pawn follow)
{
	// End:0x32
	if(__NFUN_154__(int(follow.m_ePawnType), int(1)))
	{
		return R6Rainbow(follow).Escort_GetPawnToFollow(false);		
	}
	else
	{
		// End:0x5F
		if(__NFUN_154__(int(follow.m_ePawnType), int(3)))
		{
			return R6Hostage(follow).m_escortedByRainbow;
		}
	}
	m_pawn.logWarning(__NFUN_112__("GetRainbowTeamFromPawn unknow type of pawn", string(follow)));
	return none;
	return;
}

//------------------------------------------------------------------
// Order_GotoExtraction
//	
//------------------------------------------------------------------
function Order_ProcessGotoExtraction(Actor aZone)
{
	// End:0x2A
	if(__NFUN_132__(m_pawn.m_bExtracted, __NFUN_129__(m_pawn.IsAlive())))
	{
		return;
	}
	ResetThreatInfo("GotoExtraction");
	m_pGotoToExtractionZone = aZone;
	m_vMoveToDest = aZone.Location;
	SetFreed(true);
	m_bIgnoreBackupBump = true;
	__NFUN_113__('GotoExtraction');
	return;
}

//------------------------------------------------------------------
// Order_ProcessFollowMe: informs the team or has received the order to follow
//  the rainbow team. The hostage is added in the escorted team
//  which will set is m_pawnToFollow. 
//------------------------------------------------------------------
function Order_ProcessFollowMe(R6Pawn follow, bool bOrderedByRainbow)
{
	local R6Rainbow rainbowToFollow;

	ResetThreatInfo("ProcessFollowMe");
	m_pawn.SetStandWalkingAnim(1, true);
	// End:0x49
	if(__NFUN_154__(int(m_pawn.m_ePersonality), int(3)))
	{
		SetFreed(true);
	}
	rainbowToFollow = GetRainbowWhoEscortThisPawn(follow);
	// End:0xA6
	if(__NFUN_130__(__NFUN_119__(m_pawn.m_escortedByRainbow, none), __NFUN_119__(rainbowToFollow, m_pawn.m_escortedByRainbow)))
	{
		m_pawn.m_escortedByRainbow.Escort_RemoveHostage(m_pawn, true);
	}
	m_pawn.m_escortedByRainbow = rainbowToFollow;
	// End:0xEB
	if(m_pawn.m_escortedByRainbow.Escort_AddHostage(m_pawn, false, bOrderedByRainbow))
	{
		__NFUN_113__('FollowingPawn');		
	}
	else
	{
		Order_ProcessStayHere(false);
	}
	return;
}

//------------------------------------------------------------------
// StopFollowingPawn: reset all info regarding following a pawn
//	
//------------------------------------------------------------------
function StopFollowingPawn(bool bOrderedByRainbow)
{
	m_pawn.SetStandWalkingAnim(0, false);
	// End:0x28
	if(__NFUN_114__(m_pawn.m_escortedByRainbow, none))
	{
		return;
	}
	m_pawn.m_escortedByRainbow.Escort_RemoveHostage(m_pawn, __NFUN_129__(m_pawn.IsAlive()), bOrderedByRainbow);
	m_pawnToFollow = none;
	m_bRunningToward = false;
	return;
}

//------------------------------------------------------------------
// Order_ProcessStayHere: the hostage received the order to stay
//  here, or it informs the team that he'll stay here
//------------------------------------------------------------------
function Order_ProcessStayHere(bool bOrderedByRainbow)
{
	ResetThreatInfo("ProcessStayHere");
	StopMoving();
	m_bForceToStayHere = true;
	StopFollowingPawn(bOrderedByRainbow);
	__NFUN_113__('Freed');
	return;
}

//------------------------------------------------------------------
// DispatchOrder: dispatch order for a eHostageCircumstantialAction
//------------------------------------------------------------------
function DispatchOrder(int iOrder, optional R6Pawn orderFrom)
{
	switch(iOrder)
	{
		// End:0x26
		case int(m_pawn.1):
			Order_FollowMe(orderFrom, true);
			// End:0x81
			break;
		// End:0x40
		case int(m_pawn.2):
			Order_StayHere(true);
			// End:0x81
			break;
		// End:0xFFFF
		default:
			m_pawn.logWarning(__NFUN_112__("unknow eHostageCircumstantialAction ", string(iOrder)));
			break;
	}
	return;
}

//------------------------------------------------------------------
// CanStopMoving: return true if I should stop moving. When moving
//	the hostage will try to catch up the group 
// bCheckIfShouldMove: when true, the pawn is asking if he needs to move
//------------------------------------------------------------------
function bool CanStopMoving(bool bCheckIfShouldMove)
{
	local R6HostageAI hostageAI;
	local int iDistance;

	// End:0x0D
	if(__NFUN_114__(m_pawnToFollow, none))
	{
		return true;
	}
	// End:0x24
	if(bCheckIfShouldMove)
	{
		iDistance = c_iDistanceMax;		
	}
	else
	{
		iDistance = c_iDistanceCatchUp;
	}
	// End:0x67
	if(__NFUN_132__(__NFUN_132__(m_bFollowIncreaseDistance, m_bSlowedPace), m_pawnToFollow.m_bIsClimbingLadder))
	{
		__NFUN_161__(iDistance, __NFUN_145__(iDistance, 2));
	}
	// End:0x95
	if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_pawnToFollow.Location, Pawn.Location)), float(iDistance)))
	{
		return true;
	}
	// End:0xE5
	if(__NFUN_154__(int(m_pawnToFollow.m_eMovementPace), int(1)))
	{
		// End:0xE5
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_pawnToFollow.m_collisionBox.Location, Pawn.Location)), float(iDistance)))
		{
			return true;
		}
	}
	// End:0x16E
	if(__NFUN_130__(__NFUN_119__(m_pawn.m_escortedByRainbow, none), __NFUN_114__(m_pawn.m_escortedByRainbow.m_aEscortedHostage[0], m_pawn)))
	{
		// End:0x16C
		if(bCheckIfShouldMove)
		{
			m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
			// End:0x167
			if(__NFUN_114__(m_pawn.m_escortedByRainbow.m_aEscortedHostage[0], m_pawn))
			{
				return false;				
			}
			else
			{
				return true;
			}			
		}
		else
		{
			return false;
		}
	}
	hostageAI = R6HostageAI(m_pawnToFollow.Controller);
	// End:0x1C5
	if(__NFUN_132__(__NFUN_130__(__NFUN_119__(hostageAI, none), __NFUN_119__(hostageAI.MoveTarget, none)), __NFUN_130__(bCheckIfShouldMove, __NFUN_129__(m_bRunningToward))))
	{
		return false;		
	}
	else
	{
		// End:0x204
		if(__NFUN_130__(__NFUN_119__(m_pawn.m_escortedByRainbow, none), m_pawn.m_escortedByRainbow.Escort_IsPawnCloseToMe(m_pawn, float(iDistance))))
		{
			return true;
		}
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsInCrouchedPosture: return truen so a crouchwalk anim will be played
//	when the pawn is bumped
//------------------------------------------------------------------
function bool IsInCrouchedPosture()
{
	return __NFUN_132__(__NFUN_132__(super.IsInCrouchedPosture(), __NFUN_154__(int(m_pawn.m_ePosition), int(1))), __NFUN_154__(int(m_pawn.m_ePosition), int(3)));
	return;
}

/////////////////////////////////////////////////////////////////////////
// IsGuarded: return true if the hostage is or can be guarded
//            Guarded here means that the hostage can see a terrorist. 
//            
//            *** costly function ***
function bool IsGuarded(optional bool bNoTimer, optional bool bMustSeeMe)
{
	local R6Pawn P;

	// End:0x1B
	if(__NFUN_154__(int(m_pawn.m_ePersonality), int(3)))
	{
		return true;
	}
	// End:0xFC
	foreach __NFUN_312__(Class'R6Engine.R6Pawn', P, Pawn.SightRadius, m_pawn.Location)
	{
		// End:0xFB
		if(__NFUN_130__(__NFUN_130__(m_pawn.IsEnemy(P), P.IsAlive()), __NFUN_129__(P.m_bIsKneeling)))
		{
			// End:0xF1
			if(bMustSeeMe)
			{
				// End:0xD9
				if(__NFUN_119__(R6AIController(P.Controller), none))
				{
					// End:0xD6
					if(R6AIController(P.Controller).__NFUN_533__(Pawn))
					{
						m_iNotGuardedSince = 0;						
						return true;
					}					
				}
				else
				{
					// End:0xEE
					if(__NFUN_533__(P))
					{
						m_iNotGuardedSince = 0;						
						return true;
					}
				}
				// End:0xFB
				continue;
			}
			m_iNotGuardedSince = 0;			
			return true;
		}		
	}	
	// End:0x108
	if(bNoTimer)
	{
		return false;
	}
	// End:0x140
	if(__NFUN_154__(m_iNotGuardedSince, 0))
	{
		m_iNotGuardedSince = int(Level.TimeSeconds);
		GetRandomTweenNum(m_pawn.m_stayCautiousGuardedStateTime);		
	}
	else
	{
		// End:0x171
		if(__NFUN_176__(__NFUN_174__(float(m_iNotGuardedSince), m_pawn.m_stayCautiousGuardedStateTime.m_fResult), Level.TimeSeconds))
		{
			return false;
		}
	}
	return true;
	return;
}

//------------------------------------------------------------------
// SetStateFollowingPaceTransition: set the default value, his starting position 
//	
//------------------------------------------------------------------
function SetStatePaceTransition(R6Hostage.EStartingPosition ePos)
{
	m_eTransitionPosition = ePos;
	__NFUN_113__('FollowingPaceTransition');
	return;
}

//------------------------------------------------------------------
// SetMovementPace: set the current pace to be when following someone
// return true if are doing a transition thats requires to stop moving
//------------------------------------------------------------------
function bool SetMovementPace(bool bStartingToMove)
{
	local R6Pawn.eMovementPace eOldMovementPace, eNewMovementPace;
	local R6Pawn follow;
	local bool bStopMoving;

	// End:0x21
	if(__NFUN_132__(__NFUN_114__(m_pawnToFollow, none), m_pawn.m_bPostureTransition))
	{
		return false;
	}
	// End:0xFB
	if(m_bNeedToRunToCatchUp)
	{
		// End:0xD8
		if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)), __NFUN_154__(int(m_pawn.m_eMovementPace), int(3))))
		{
			// End:0xB4
			if(__NFUN_130__(__NFUN_129__(m_pawnToFollow.bIsCrouched), __NFUN_129__(m_pawnToFollow.m_bIsProne)))
			{
				m_pawn.m_ePosition = 0;
				m_pawn.setCrouch(false);
				SetPace(5);				
			}
			else
			{
				// End:0xD5
				if(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)))
				{
					SetPace(3);
				}
			}			
		}
		else
		{
			// End:0xF9
			if(__NFUN_154__(int(m_pawn.m_eMovementPace), int(4)))
			{
				SetPace(5);
			}
		}
		return false;
	}
	// End:0x10E
	if(m_bRunningToward)
	{
		SetPace(5);
		return false;
	}
	eOldMovementPace = m_pawn.m_eMovementPace;
	// End:0x1DD
	if(__NFUN_132__(__NFUN_119__(MoveTarget, none), bStartingToMove))
	{
		follow = m_pawnToFollow;
		m_iWaitingTime = 0;
		// End:0x1D2
		if(__NFUN_130__(__NFUN_129__(m_pawnToFollow.IsMovingForward()), __NFUN_129__(m_pawn.m_bIsProne)))
		{
			// End:0x191
			if(m_pawnToFollow.bIsWalking)
			{
				m_bSlowedPace = true;				
			}
			else
			{
				follow = none;
				// End:0x1BD
				if(m_pawnToFollow.bIsCrouched)
				{
					m_bSlowedPace = true;
					SetPace(2);					
				}
				else
				{
					m_bSlowedPace = false;
					SetPace(4);
				}
				return false;
			}			
		}
		else
		{
			m_bSlowedPace = false;
		}		
	}
	else
	{
		// End:0x27F
		if(__NFUN_130__(__NFUN_119__(m_pawn.m_escortedByRainbow, none), __NFUN_119__(m_pawn.m_escortedByRainbow.m_aEscortedHostage[0], none)))
		{
			follow = m_pawnToFollow;
			__NFUN_165__(m_iWaitingTime);
			// End:0x27C
			if(__NFUN_179__(float(m_iWaitingTime), m_pawn.m_waitingGoCrouchTween.m_fResult))
			{
				follow = none;
				// End:0x27C
				if(__NFUN_130__(__NFUN_129__(m_pawn.bIsCrouched), __NFUN_129__(m_pawn.m_bIsProne)))
				{
					SetPawnPosition(4);
				}
			}			
		}
		else
		{
			return false;
		}
	}
	// End:0x2A0
	if(__NFUN_119__(follow, none))
	{
		SetPace(follow.m_eMovementPace);
	}
	// End:0x4DA
	if(__NFUN_155__(int(eOldMovementPace), int(m_pawn.m_eMovementPace)))
	{
		// End:0x303
		if(__NFUN_130__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(1)), __NFUN_129__(m_pawn.m_bIsProne)))
		{
			SetPace(eOldMovementPace);
			SetStatePaceTransition(2);
			return true;			
		}
		else
		{
			// End:0x38F
			if(__NFUN_130__(m_pawn.m_bIsProne, __NFUN_155__(int(m_pawn.m_eMovementPace), int(1))))
			{
				// End:0x37A
				if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(3)), __NFUN_154__(int(m_pawn.m_eMovementPace), int(2))))
				{
					SetPace(eOldMovementPace);
					SetStatePaceTransition(4);					
				}
				else
				{
					SetPace(eOldMovementPace);
					SetStatePaceTransition(0);
				}
				return true;
			}
		}
		// End:0x3D6
		if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)), __NFUN_154__(int(m_pawn.m_eMovementPace), int(3))))
		{
			SetPawnPosition(4);
			bStopMoving = true;			
		}
		else
		{
			// End:0x410
			if(__NFUN_155__(int(m_pawn.m_eMovementPace), int(1)))
			{
				m_pawn.m_ePosition = 0;
				m_pawn.setCrouch(false);
			}
		}
		// End:0x4BF
		if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)), __NFUN_154__(int(m_pawn.m_eMovementPace), int(4))))
		{
			// End:0x4BF
			if(__NFUN_130__(__NFUN_177__(__NFUN_225__(__NFUN_216__(m_pawnToFollow.Location, Pawn.Location)), float(c_iDistanceToStartToRun)), __NFUN_155__(int(m_pawn.m_eHealth), int(1))))
			{
				m_bNeedToRunToCatchUp = true;
				// End:0x4B7
				if(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)))
				{
					SetPace(3);					
				}
				else
				{
					SetPace(5);
				}
			}
		}
		R6SetMovement(m_pawn.m_eMovementPace);
		return bStopMoving;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// FollowPawnFailed
//	
//------------------------------------------------------------------
function FollowPawnFailed()
{
	ResetThreatInfo("FollowPawnFailed");
	Order_StayHere(false);
	ReturnToNormalState(true);
	return;
}

//------------------------------------------------------------------
// CanOpenDoor: check if the pawn has the ability to open the door
//	ie: in case it's locked.
//------------------------------------------------------------------
event bool CanOpenDoor(R6IORotatingDoor Door)
{
	return __NFUN_129__(Door.m_bIsDoorLocked);
	return;
}

event OpenDoorFailed()
{
	// End:0x1C
	if(m_pawn.m_bCivilian)
	{
		__NFUN_113__('CivStayHere');		
	}
	else
	{
		// End:0x37
		if(m_pawn.m_bFreed)
		{
			FollowPawnFailed();			
		}
		else
		{
			SetStateGuarded(1, m_mgr.0);
		}
	}
	return;
}

//------------------------------------------------------------------
// SetStateRunForCover
//	
//------------------------------------------------------------------
function SetStateRunForCover(Pawn runAwayOfPawn, name successState, name failureState, Actor Grenade)
{
	Enemy = runAwayOfPawn;
	m_runAwayOfGrenade = Grenade;
	m_runForCoverStateToGoOnSuccess = successState;
	m_runForCoverStateToGoOnFailure = failureState;
	// End:0x65
	if(IsRunForCoverPossible(Enemy))
	{
		ProcessPlaySndInfo(m_mgr.3);
		SetThreatState('RunForCover');
		__NFUN_113__(m_threatInfo.m_state);		
	}
	else
	{
		ResetThreatInfo("run for cover failed ");
		m_runAwayOfGrenade = none;
		__NFUN_113__(m_runForCoverStateToGoOnFailure);
	}
	return;
}

//------------------------------------------------------------------
// IsAwayOfGrenade: return true if away and approximatively safe of 
//   the grenade.
//------------------------------------------------------------------
function bool IsAwayOfGrenade(Actor Grenade)
{
	// End:0x2E
	if(__NFUN_177__(__NFUN_225__(__NFUN_216__(Pawn.Location, Grenade.Location)), float(c_iRunForCoverOfGrenadeMinDist)))
	{
		return true;
	}
	// End:0x47
	if(__NFUN_548__(Grenade.Location))
	{
		return false;		
	}
	else
	{
		return true;
	}
	return;
}

//------------------------------------------------------------------
// IsRunForCoverPossible: return true if the hostage can run away and 
//  generate a path to run away of this enemy
//------------------------------------------------------------------
function bool IsRunForCoverPossible(Pawn runAwayOf)
{
	local Pawn aPreviousEnemy;
	local bool bResult;

	aPreviousEnemy = Enemy;
	Enemy = runAwayOf;
	bResult = __NFUN_1810__();
	Enemy = aPreviousEnemy;
	return bResult;
	return;
}

//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
	local R6Pawn aBumpPawn;

	aBumpPawn = R6Pawn(m_BumpedBy);
	// End:0x31
	if(__NFUN_176__(__NFUN_174__(m_fLastBump, 4.0000000), Level.TimeSeconds))
	{
		return true;
	}
	Focus = none;
	// End:0x5A
	if(__NFUN_217__(aBumpPawn.Velocity, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		return true;
	}
	// End:0x73
	if(__NFUN_177__(DistanceTo(m_BumpedBy), float(c_iDistanceBumpBackUp)))
	{
		return true;
	}
	// End:0x99
	if(__NFUN_130__(__NFUN_119__(m_pawnToFollow, none), __NFUN_177__(DistanceTo(m_pawnToFollow), float(c_iDistanceCatchUp))))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
	SetStateGuarded(1, m_mgr.0);
	return;
}

//------------------------------------------------------------------
// CivInit: initialization for the civilian
//------------------------------------------------------------------
function CivInit()
{
	local int i;

	// End:0x1B
	if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
	{
		StopFollowingPawn(false);
	}
	m_pawn.SetStandWalkingAnim(0, true);
	m_pawn.m_eHandsUpType = 0;
	m_pawn.m_bCivilian = true;
	m_pawn.m_bClassicMissionCivilian = m_pawn.m_DZone.m_bClassicMissionCivilian;
	i = 0;
	J0x7E:

	// End:0xD3 [Loop If]
	if(__NFUN_150__(i, m_pawn.m_DZone.m_pListOfCoverNodes.Length))
	{
		m_pListOfCoverNodes[i] = m_pawn.m_DZone.m_pListOfCoverNodes[i];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x7E;
	}
	m_pawn.setFrozen(false);
	SetPawnPosition(m_pawn.m_ePosition);
	switch(m_pawn.m_eCivPatrol)
	{
		// End:0x116
		case 1:
			__NFUN_113__('CivPatrolPath');
			// End:0x12F
			break;
		// End:0x125
		case 2:
			__NFUN_113__('CivPatrolArea');
			// End:0x12F
			break;
		// End:0xFFFF
		default:
			__NFUN_113__('CivGuardPoint');
			break;
	}
	return;
}

//------------------------------------------------------------------
// ResetThreatInfo
//	
//------------------------------------------------------------------
function ResetThreatInfo(string sz)
{
	m_threatInfo = m_mgr.getDefaulThreatInfo();
	return;
}

//------------------------------------------------------------------
// SetThreatState:
//	
//------------------------------------------------------------------
function SetThreatState(name threatState)
{
	m_threatInfo.m_state = threatState;
	return;
}

//------------------------------------------------------------------
// GetThreatGroupName
//	
//------------------------------------------------------------------
function name GetThreatGroupName()
{
	// End:0x48
	if(m_pawn.m_bCivilian)
	{
		// End:0x36
		if(m_pawn.m_bClassicMissionCivilian)
		{
			return m_mgr.c_ThreatGroup_Civ;			
		}
		else
		{
			return m_mgr.c_ThreatGroup_HstBait;
		}		
	}
	else
	{
		// End:0x82
		if(__NFUN_130__(m_pawn.m_bFreed, __NFUN_119__(m_pawn.m_escortedByRainbow, none)))
		{
			return m_mgr.c_ThreatGroup_HstEscorted;			
		}
		else
		{
			// End:0xAD
			if(__NFUN_154__(int(m_pawn.m_ePersonality), int(3)))
			{
				return m_mgr.c_ThreatGroup_HstBait;				
			}
			else
			{
				// End:0xD1
				if(m_pawn.m_bFreed)
				{
					return m_mgr.c_ThreatGroup_HstFreed;					
				}
				else
				{
					return m_mgr.c_ThreatGroup_HstGuarded;
				}
			}
		}
	}
	return;
}

function ProcessThreat(Actor P, Actor.ENoiseType eType)
{
	local R6Pawn R6Pawn;
	local int iDistanceFromThreat;
	local ThreatInfo ThreatInfo;
	local bool bNewThreat;
	local name stateName, GroupName;

	GroupName = GetThreatGroupName();
	// End:0x49
	if(__NFUN_255__(GroupName, m_threatGroupName))
	{
		ResetThreatInfo(__NFUN_112__("new threat group: ", string(GroupName)));
		m_threatGroupName = GroupName;
	}
	// End:0x9C
	if(m_pawn.m_bClassicMissionCivilian)
	{
		// End:0x99
		if(m_mgr.GetThreatInfoFromThreat(GroupName, m_pawn, P, eType, ThreatInfo))
		{
			m_threatInfo = ThreatInfo;
			bNewThreat = true;
		}		
	}
	else
	{
		bNewThreat = false;
		// End:0xFB
		if(m_mgr.GetThreatInfoFromThreat(GroupName, m_pawn, P, eType, ThreatInfo))
		{
			// End:0xFB
			if(__NFUN_151__(ThreatInfo.m_iThreatLevel, m_threatInfo.m_iThreatLevel))
			{
				m_threatInfo = ThreatInfo;
				bNewThreat = true;
			}
		}
	}
	// End:0x21F
	if(bNewThreat)
	{
		stateName = m_mgr.GetReaction(GroupName, m_threatInfo.m_iThreatLevel, Roll(100));
		// End:0x16B
		if(__NFUN_254__('BaitPlayReaction', stateName))
		{
			ProcessPlaySndInfo(m_mgr.6);
			ResetThreatInfo("BaitPlayReaction");			
		}
		else
		{
			// End:0x1C2
			if(__NFUN_254__('GuardedPlayReaction', stateName))
			{
				// End:0x1A4
				if(__NFUN_154__(m_iPlayReaction1, 0))
				{
					m_iPlayReaction1 = 1;
					m_iPlayReaction2 = int(RandRange(0.0000000, 2.0000000));
				}
				ResetThreatInfo("GuardedPlayReaction");				
			}
			else
			{
				// End:0x200
				if(__NFUN_254__('HearShootingReaction', stateName))
				{
					ProcessPlaySndInfo(m_mgr.1);
					ResetThreatInfo("HearShootingReaction");					
				}
				else
				{
					// End:0x21F
					if(__NFUN_255__(stateName, m_mgr.m_noReactionName))
					{
						__NFUN_113__(stateName);
					}
				}
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// Order_ProcessSurrender: process the surrender order. Should not
//	be call externally of Order_Process
//------------------------------------------------------------------
function Order_ProcessSurrender(Pawn terro)
{
	local name stateName;

	m_terrorist = R6Terrorist(terro);
	// End:0x39
	if(__NFUN_132__(m_pawn.m_bCivilian, m_pawn.m_bPoliceManMp1))
	{		
	}
	else
	{
		// End:0x7C
		if(__NFUN_114__(m_pawn.m_escortedByRainbow, none))
		{
			ProcessPlaySndInfo(m_mgr.2);
			R6TerroristAI(m_terrorist.Controller).HostageSurrender(self);
		}
	}
	return;
}

//------------------------------------------------------------------
// SetStateEscorted
//	
//------------------------------------------------------------------
function SetStateEscorted(R6Pawn escort, Vector Destination, bool bSurrender)
{
	m_escort = escort;
	m_vMoveToDest = Destination;
	m_pawn.setFrozen(false);
	// End:0x41
	if(bSurrender)
	{
		SetThreatState('EscortedByEnemy');
		SetFreed(false);
	}
	m_bForceToStayHere = false;
	SetPace(4);
	m_pawn.m_bEscorted = true;
	__NFUN_113__('EscortedByEnemy');
	return;
}

// NEW IN 1.60
function bool CivCheckCoverNode()
{
	local int i;

	// End:0x46
	if(__NFUN_155__(m_pListOfCoverNodes.Length, 0))
	{
		i = __NFUN_167__(m_pListOfCoverNodes.Length);
		m_pCoverNode = m_pListOfCoverNodes[i];
		m_pListOfCoverNodes.Remove(i, 1);
		CivGotoStateMovingTo(5, m_pCoverNode);
		return true;
	}
	__NFUN_113__('CMCivStayKneel');
	return false;
	return;
}

// NEW IN 1.60
function CivGotoStateMovingTo(R6Pawn.eMovementPace ePace, optional Actor aMoveTarget)
{
	local Vector vHitNormal;

	// End:0x12
	if(__NFUN_114__(aMoveTarget, none))
	{
		__NFUN_113__('CMCivStayHere');
	}
	m_vMoveToDest = aMoveTarget.Location;
	m_pawn.m_eMovementPace = ePace;
	__NFUN_113__('CivMovingTo');
	return;
}

//------------------------------------------------------------------
// Order_GetLog
//	
//------------------------------------------------------------------
function string Order_GetLog(OrderInfo Info)
{
	local string szOutput, szOrder, szPawn;

	switch(Info.m_eOrder)
	{
		// End:0x22
		case 1:
			szOrder = "follow";
			// End:0x7B
			break;
		// End:0x36
		case 2:
			szOrder = "stay";
			// End:0x7B
			break;
		// End:0x4F
		case 3:
			szOrder = "surrender";
			// End:0x7B
			break;
		// End:0x69
		case 4:
			szOrder = "extraction";
			// End:0x7B
			break;
		// End:0xFFFF
		default:
			szOrder = "none";
			// End:0x7B
			break;
			break;
	}
	// End:0xAD
	if(__NFUN_119__(Info.m_pawn1, none))
	{
		szPawn = __NFUN_112__("", string(Info.m_pawn1.Name));		
	}
	else
	{
		szPawn = "none";
	}
	szOutput = __NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Order: ", szOrder), " pawn: "), szPawn), " time: "), string(Info.m_fTime));
	return szOutput;
	return;
}

//------------------------------------------------------------------
// Order_Pop: pop the first element and shift all the rest (FIFO queue)
//	
//------------------------------------------------------------------
function OrderInfo Order_Pop()
{
	local int i, LastIndex;
	local OrderInfo OrderInfo;

	// End:0x11
	if(__NFUN_154__(m_iNbOrder, 0))
	{
		return OrderInfo;
	}
	OrderInfo = m_aOrderInfo[0];
	LastIndex = __NFUN_147__(2, 1);
	i = 0;
	J0x30:

	// End:0x63 [Loop If]
	if(__NFUN_150__(i, LastIndex))
	{
		m_aOrderInfo[i] = m_aOrderInfo[__NFUN_146__(i, 1)];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x30;
	}
	m_aOrderInfo[LastIndex].m_eOrder = m_pawn.0;
	m_aOrderInfo[LastIndex].m_fTime = 0.0000000;
	m_aOrderInfo[LastIndex].m_pawn1 = none;
	__NFUN_166__(m_iNbOrder);
	return OrderInfo;
	return;
}

//------------------------------------------------------------------
// Order_Add: Add an order (FIFO). 
//  If there's one only
//	        
//------------------------------------------------------------------
function Order_Add(R6Hostage.eHostageOrder eOrder, R6Pawn aPawn, optional bool bOrderedByRainbow, optional Actor anActor)
{
	local OrderInfo OrderInfo;

	J0x00:
	// End:0x1B [Loop If]
	if(__NFUN_153__(m_iNbOrder, 2))
	{
		OrderInfo = Order_Pop();
		// [Loop Continue]
		goto J0x00;
	}
	m_aOrderInfo[m_iNbOrder].m_eOrder = eOrder;
	m_aOrderInfo[m_iNbOrder].m_pawn1 = aPawn;
	m_aOrderInfo[m_iNbOrder].m_fTime = Level.TimeSeconds;
	m_aOrderInfo[m_iNbOrder].m_bOrderedByRainbow = bOrderedByRainbow;
	m_aOrderInfo[m_iNbOrder].m_actor = anActor;
	__NFUN_165__(m_iNbOrder);
	// End:0xB5
	if(__NFUN_129__(m_pawn.m_bPostureTransition))
	{
		Order_Process();
	}
	return;
}

//------------------------------------------------------------------
// IsInTemporaryState: temporary state are states that need to be
//	over before doing anything else
//------------------------------------------------------------------
function bool IsInTemporaryState()
{
	return __NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(m_pawn.m_bPostureTransition, m_r6pawn.m_bIsClimbingLadder), __NFUN_154__(int(Physics), int(2))), __NFUN_154__(int(Physics), int(12))), __NFUN_281__('BumpBackUp')), __NFUN_281__('OpenDoor'));
	return;
}

//------------------------------------------------------------------
// Order_Process: process the queued Order (FIFO)
//	
//------------------------------------------------------------------
function Order_Process()
{
	local OrderInfo OrderInfo;

	// End:0x40
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_154__(m_iNbOrder, 0), IsInTemporaryState()), m_pawn.m_bExtracted), m_pawn.m_bCivilian))
	{
		return;
	}
	OrderInfo = Order_Pop();
	switch(OrderInfo.m_eOrder)
	{
		// End:0x7B
		case 1:
			Order_ProcessFollowMe(OrderInfo.m_pawn1, OrderInfo.m_bOrderedByRainbow);
			// End:0xCC
			break;
		// End:0x94
		case 2:
			Order_ProcessStayHere(OrderInfo.m_bOrderedByRainbow);
			// End:0xCC
			break;
		// End:0xB1
		case 3:
			Order_ProcessSurrender(R6Terrorist(OrderInfo.m_pawn1));
			// End:0xCC
			break;
		// End:0xC9
		case 4:
			Order_ProcessGotoExtraction(OrderInfo.m_actor);
			// End:0xCC
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------
// Order_GotoExtraction: order hostage to go to the extraction Zone
//	
//------------------------------------------------------------------
function Order_GotoExtraction(Actor aZone)
{
	Order_Add(4, none, false, aZone);
	return;
}

//------------------------------------------------------------------
// Order_StayHere: Rainbow orders the hostage to stay here
//	
//------------------------------------------------------------------
function Order_StayHere(bool bOrderedByRainbow)
{
	Order_Add(2, none, bOrderedByRainbow);
	return;
}

//------------------------------------------------------------------
// Order_canFollowMe: return true if the hostage can follow
//	
//------------------------------------------------------------------
function bool Order_canFollowMe()
{
	return __NFUN_114__(m_pawn.m_escortedByRainbow, none);
	return;
}

//------------------------------------------------------------------
// Order_FollowMe: Rainbows order to follow this pawn
//	
//------------------------------------------------------------------
function Order_FollowMe(R6Pawn aPawn, bool bOrderedByRainbow)
{
	Order_Add(1, aPawn, bOrderedByRainbow);
	return;
}

//------------------------------------------------------------------
// Order_Surrender: Terrorist orders to surrender
//	
//------------------------------------------------------------------
function Order_Surrender(R6Pawn aPawn)
{
	Order_Add(3, aPawn);
	return;
}

//------------------------------------------------------------------
// RouteCacheWithOtherLadder
//	return true if the route cache has a the other r6ladder nav point
//------------------------------------------------------------------
function bool RouteCacheWithOtherLadder(R6Ladder Ladder)
{
	local int i;
	local R6Ladder testLadder;

	J0x00:
	// End:0x66 [Loop If]
	if(__NFUN_130__(__NFUN_150__(i, 16), __NFUN_119__(RouteCache[i], none)))
	{
		testLadder = R6Ladder(RouteCache[i]);
		// End:0x5C
		if(__NFUN_130__(__NFUN_119__(testLadder, none), __NFUN_114__(Ladder.m_pOtherFloor, testLadder)))
		{
			return true;
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x00;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// CheckNeedToClimbLadder
//	
//------------------------------------------------------------------
function CheckNeedToClimbLadder()
{
	// End:0x0D
	if(__NFUN_114__(m_pawnToFollow, none))
	{
		return;
	}
	__NFUN_517__(m_pawnToFollow, true);
	// End:0x6E
	if(__NFUN_132__(__NFUN_130__(__NFUN_119__(m_pawn.m_Ladder, none), __NFUN_129__(RouteCacheWithOtherLadder(m_pawn.m_Ladder))), __NFUN_520__(m_pawnToFollow)))
	{
		m_pawn.m_Ladder = none;
		__NFUN_113__(NextState, NextLabel);
	}
	return;
}

//------------------------------------------------------------------
// CanClimbLadder
//	
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder)
{
	local int i;

	// End:0x29
	if(__NFUN_129__(R6LadderVolume(Ladder.MyLadder).IsAvailable(Pawn)))
	{
		return false;
	}
	// End:0x95
	if(__NFUN_130__(m_pawn.m_bAutoClimbLadders, __NFUN_114__(MoveTarget, Ladder)))
	{
		J0x4C:

		// End:0x95 [Loop If]
		if(__NFUN_130__(__NFUN_150__(i, 16), __NFUN_119__(RouteCache[i], none)))
		{
			// End:0x8B
			if(__NFUN_114__(RouteCache[i], Ladder.m_pOtherFloor))
			{
				return true;
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x4C;
		}
	}
	return false;
	return;
}

function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType)
{
	switch(eType)
	{
		// End:0x25
		case 2:
			m_VoicesManager.PlayHostageVoices(m_pawn, 8);
			// End:0x46
			break;
		// End:0x43
		case 1:
			m_VoicesManager.PlayHostageVoices(m_pawn, 7);
			// End:0x46
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------
// AIAffectedByGrenade()                                       
//------------------------------------------------------------------
function AIAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	// End:0x13
	if(__NFUN_154__(int(eType), int(1)))
	{		
	}
	else
	{
		// End:0x37
		if(__NFUN_154__(int(eType), int(2)))
		{
			m_pawn.SetNextPendingAction(1);			
		}
		else
		{
			// End:0x62
			if(__NFUN_132__(__NFUN_154__(int(eType), int(3)), __NFUN_154__(int(eType), int(4))))
			{
				SetStateReactToGrenade(__NFUN_284__());
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// PlaySoundDamage()                                       
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy)
{
	// End:0x40
	if(__NFUN_130__(__NFUN_152__(int(m_pawn.m_eHealth), int(1)), __NFUN_129__(m_pawn.m_bPoliceManMp1)))
	{
		ProcessPlaySndInfo(m_mgr.10);
	}
	// End:0xA1
	if(__NFUN_130__(m_pawn.IsFriend(instigatedBy), m_bFirstTimeClarkComment))
	{
		// End:0x9E
		if(__NFUN_152__(int(m_pawn.m_eHealth), int(1)))
		{
			m_bFirstTimeClarkComment = false;
			m_VoicesManager.PlayHostageVoices(R6Pawn(instigatedBy), 9);
		}		
	}
	else
	{
		// End:0xD2
		if(__NFUN_119__(instigatedBy.Controller, none))
		{
			instigatedBy.Controller.PlaySoundInflictedDamage(m_pawn);
		}
	}
	return;
}

//------------------------------------------------------------------
// SetStateReactToGrenade: set the default value
//	
//------------------------------------------------------------------
function SetStateReactToGrenade(name stateToReturn)
{
	// End:0x1A
	if(__NFUN_255__(stateToReturn, 'ReactToGrenade'))
	{
		m_reactToGrenadeStateToReturn = stateToReturn;
	}
	__NFUN_113__('ReactToGrenade');
	return;
}

//------------------------------------------------------------------
// SetStateExtracted: set the hostage in extracted state. no more or
//	- reset threat, orders
//------------------------------------------------------------------
function SetStateExtracted()
{
	m_pawn.m_bExtracted = true;
	m_iNbOrder = 0;
	ResetThreatInfo("extracted");
	// End:0x52
	if(__NFUN_132__(__NFUN_154__(__NFUN_167__(2), 1), m_pawn.m_bCivilian))
	{
		SetPawnPosition(0);		
	}
	else
	{
		SetPawnPosition(4);
	}
	__NFUN_113__('Extracted');
	return;
}

//------------------------------------------------------------------
// ProcessPlaySndInfo
//	
//------------------------------------------------------------------
function bool ProcessPlaySndInfo(int iSndEvent)
{
	local int i, iSndIndex;
	local bool bPlay;

	// End:0x3B
	if(__NFUN_130__(m_pawn.m_bCivilian, __NFUN_154__(iSndEvent, 6)))
	{
		// End:0x34
		if(m_pawn.m_bPoliceManMp1)
		{
			return true;
		}
		iSndEvent = 1;
	}
	i = iSndEvent;
	// End:0x67
	if(__NFUN_154__(m_aPlaySndInfo[i].m_iLastTime, 0))
	{
		bPlay = true;		
	}
	else
	{
		// End:0xA8
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, float(m_aPlaySndInfo[i].m_iLastTime)), float(m_aPlaySndInfo[i].m_iInBetweenTime)))
		{
			bPlay = true;
		}
	}
	// End:0x11C
	if(bPlay)
	{
		m_aPlaySndInfo[i].m_iLastTime = int(Level.TimeSeconds);
		iSndIndex = m_mgr.GetHostageSndEvent(iSndEvent, m_pawn);
		m_VoicesManager.PlayHostageVoices(m_pawn, m_mgr.GetHostageVoices(iSndIndex));		
	}
	return bPlay;
	return;
}

auto state Configuration
{
	function BeginState()
	{
		return;
	}

	function EndState()
	{
		m_threatGroupName = GetThreatGroupName();
		m_iNotGuardedSince = 0;
		return;
	}
	J0x00:
	// End:0x1F [Loop If]
	if(__NFUN_129__(m_pawn.m_bInitFinished))
	{
		__NFUN_256__(1.0000000);
		// [Loop Continue]
		goto J0x00;
	}
	GetRandomTweenNum(m_pawn.m_waitingGoCrouchTween);
	GetRandomTweenNum(m_AITickTime);
	// End:0x82
	if(m_pawn.m_bPoliceManMp1)
	{
		m_pawn.m_sightRadiusTween.m_fMin = 500.0000000;
		m_pawn.m_sightRadiusTween.m_fMax = 1000.0000000;
	}
	Pawn.SightRadius = GetRandomTweenNum(m_pawn.m_sightRadiusTween);
	GetRandomTweenNum(m_pawn.m_updatePaceTween);
	GetRandomTweenNum(m_RunForCoverMinTween);
	FocalPoint = __NFUN_215__(m_pawn.Location, Vector(m_pawn.Rotation));
	// End:0x105
	if(m_pawn.m_bStartAsCivilian)
	{
		CivInit();		
	}
	else
	{
		m_pawn.SetStandWalkingAnim(1, true);
		// End:0x17E
		if(IsGuarded(true))
		{
			SetPawnPosition(m_pawn.m_ePosition);
			J0x135:

			// End:0x15D [Loop If]
			if(__NFUN_129__(Level.Game.m_bGameStarted))
			{
				__NFUN_256__(0.5000000);
				// [Loop Continue]
				goto J0x135;
			}
			SetStateGuarded(m_pawn.m_ePosition, m_mgr.0);			
		}
		else
		{
			SetFreed(true);
			SetPawnPosition(4);
			J0x18D:

			// End:0x1B5 [Loop If]
			if(__NFUN_129__(Level.Game.m_bGameStarted))
			{
				__NFUN_256__(0.5000000);
				// [Loop Continue]
				goto J0x18D;
			}
			__NFUN_113__('Freed');
		}
	}
	stop;			
}

state Guarded
{
	function BeginState()
	{
		// End:0x1B
		if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
		{
			StopFollowingPawn(false);
		}
		StopMoving();
		Focus = none;
		FocalPoint = __NFUN_215__(m_pawn.Location, Vector(m_pawn.Rotation));
		m_vReactionDirection = vect(0.0000000, 0.0000000, 0.0000000);
		m_iNotGuardedSince = 0;
		m_iWaitingTime = 0;
		SetFreed(false);
		m_pawn.setFrozen(false);
		// End:0xB9
		if(__NFUN_129__(__NFUN_132__(m_pawn.isKneeling(), m_pawn.isStandingHandUp())))
		{
			SetPawnPosition(m_eTransitionPosition);
		}
		__NFUN_280__(0.1000000, true);
		// End:0x100
		if(__NFUN_130__(__NFUN_154__(int(m_pawn.m_ePosition), int(0)), __NFUN_129__(m_pawn.isStandingHandUp())))
		{
			m_pawn.PlayWaiting();
		}
		m_iPlayReaction1 = 0;
		m_lastSeenPawn = none;
		m_bForceToStayHere = false;
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		return;
	}

	function Timer()
	{
		// End:0x25
		if(__NFUN_153__(m_iWaitingTime, 20))
		{
			// End:0x1E
			if(__NFUN_129__(IsGuarded()))
			{
				__NFUN_113__('Freed');
			}
			m_iWaitingTime = 0;
		}
		__NFUN_165__(m_iWaitingTime);
		// End:0x3D
		if(__NFUN_119__(m_lastSeenPawn, none))
		{
			SeePlayerMgr();
		}
		// End:0x8E
		if(__NFUN_155__(m_iPlayReaction1, 0))
		{
			// End:0x87
			if(__NFUN_153__(m_iPlayReaction1, m_iPlayReaction2))
			{
				ProcessPlaySndInfo(m_mgr.1);
				m_pawn.PlayReaction();
				m_iPlayReaction1 = 0;
				m_iPlayReaction2 = 0;				
			}
			else
			{
				__NFUN_165__(m_iPlayReaction1);
			}
		}
		return;
	}
	stop;
}

state GoGuarded_Foetus
{
	function BeginState()
	{
		SetThreatState('Guarded_foetus');
		ProcessPlaySndInfo(m_mgr.7);
		__NFUN_113__(m_threatInfo.m_state);
		return;
	}
	stop;
}

state Guarded_foetus extends Guarded
{
	function BeginState()
	{
		Focus = none;
		StopMoving();
		// End:0x23
		if(__NFUN_255__(m_pawn.__NFUN_284__(), 'Foetus'))
		{
		}
		SetPawnPosition(3);
		return;
	}

	function Timer()
	{
		// End:0x18
		if(CanReturnToNormalState())
		{
			__NFUN_113__('Guarded_foetus', 'End');			
		}
		else
		{
			__NFUN_113__('Guarded_foetus', 'Begin');
		}
		return;
	}
End:

	ResetThreatInfo("foetus end");
	__NFUN_280__(0.0000000, false);
	ReturnToNormalState(true);
Begin:


	__NFUN_280__(GetRandomTweenNum(m_pawn.m_stayInFoetusTime), true);
	stop;	
}

state GoGuarded_frozen
{
	function BeginState()
	{
		ProcessPlaySndInfo(m_mgr.6);
		__NFUN_113__('Guarded_frozen');
		return;
	}
	stop;
}

state Guarded_frozen extends Guarded
{
	function BeginState()
	{
		StopMoving();
		Focus = none;
		// End:0x30
		if(__NFUN_129__(m_pawn.m_bFrozen))
		{
			m_pawn.GotoFrozen();
		}
		return;
	}

	function Timer()
	{
		m_pawn.setFrozen(false);
		__NFUN_113__('Guarded_foetus');
		return;
	}
End:

	m_pawn.setFrozen(false);
	__NFUN_280__(0.0000000, false);
	// End:0x2B
	if(CanReturnToNormalState())
	{
		ReturnToNormalState();		
	}
	else
	{
		__NFUN_113__('Guarded_foetus');
	}
	J0x32:

	__NFUN_280__(GetRandomTweenNum(m_pawn.m_stayFrozenTime), true);
	stop;	
}

state Freed
{
	function BeginState()
	{
		StopMoving();
		SetFreed(true);
		m_lastSeenPawn = none;
		m_pawn.m_bAvoidFacingWalls = true;
		SetPawnPosition(4);
		m_iWaitingTime = int(GetRandomTweenNum(m_pawn.m_changeOrientationTween));
		m_iFacingTime = int(Level.TimeSeconds);
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		m_lastSeenPawn = none;
		m_iWaitingTime = 0;
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		return;
	}

	function Timer()
	{
		// End:0x75
		if(__NFUN_130__(__NFUN_176__(float(__NFUN_146__(m_iFacingTime, m_iWaitingTime)), Level.TimeSeconds), __NFUN_129__(m_pawn.m_bPostureTransition)))
		{
			m_iFacingTime = int(Level.TimeSeconds);
			m_iWaitingTime = int(GetRandomTweenNum(m_pawn.m_changeOrientationTween));
			ChangeOrientationTo(GetRandomTurn90());
		}
		// End:0x86
		if(__NFUN_119__(m_lastSeenPawn, none))
		{
			SeePlayerMgr();
		}
		return;
	}
	J0x00:
	// End:0x33 [Loop If]
	if(__NFUN_129__(__NFUN_130__(m_pawn.bWantsToCrouch, m_pawn.bIsCrouched)))
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x00;
	}
	__NFUN_280__(m_AITickTime.m_fResult, true);
	stop;		
}

state FollowingPaceTransition
{
	function BeginState()
	{
		StopMoving();
		return;
	}
Begin:

	// End:0x55
	if(m_pawn.m_bIsProne)
	{
		SetPawnPosition(4);
		__NFUN_256__(0.3000000);
		SetPace(2);
		// End:0x52
		if(__NFUN_154__(int(m_eTransitionPosition), int(0)))
		{
			SetPawnPosition(0);
			__NFUN_256__(0.3000000);
			SetPace(4);
		}		
	}
	else
	{
		// End:0xBA
		if(__NFUN_130__(__NFUN_154__(int(m_eTransitionPosition), int(2)), __NFUN_129__(m_pawn.m_bIsProne)))
		{
			// End:0x9F
			if(__NFUN_129__(m_pawn.bIsCrouched))
			{
				SetPawnPosition(4);
				__NFUN_256__(0.3000000);
			}
			SetPawnPosition(2);
			__NFUN_256__(0.4000000);
			SetPace(1);			
		}
		else
		{
			SetPawnPosition(m_eTransitionPosition);
		}
	}
	R6SetMovement(m_pawn.m_eMovementPace);
	__NFUN_113__('FollowingPawn');
	stop;			
}

state FollowingPawn
{
	function BeginState()
	{
		// End:0x2F
		if(__NFUN_132__(m_pawn.m_bCivilian, m_pawn.m_bPoliceManMp1))
		{
			CivInit();			
		}
		else
		{
			MoveTarget = none;
			Focus = none;
			m_lastSeenPawn = none;
			SetFreed(true);
			m_bSlowedPace = false;
		}
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		Focus = none;
		return;
	}

    /////////////////////////////////////////////////////////////////////////
	event bool NotifyBump(Actor Other)
	{
		m_lastUpdatePaceTime = 0;
		m_bFollowIncreaseDistance = true;
		return super(R6AIController).NotifyBump(Other);
		return;
	}

	function Timer()
	{
		local bool bUpdateMove, bFound;
		local R6Pawn P;
		local R6RainbowTeam Team;
		local float fSleep;
		local bool bCanWalkTo;

		// End:0x11
		if(__NFUN_119__(m_lastSeenPawn, none))
		{
			SeePlayerMgr();
		}
		// End:0x68
		if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_132__(m_bStopDoTransition, m_pawn.m_bPostureTransition), m_r6pawn.m_bIsClimbingLadder), __NFUN_154__(int(Physics), int(2))), __NFUN_154__(int(Physics), int(12))))
		{
			return;
		}
		// End:0xE5
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, float(m_lastUpdatePaceTime)), m_pawn.m_updatePaceTween.m_fResult))
		{
			// End:0xBB
			if(SetMovementPace(false))
			{
				m_bStopDoTransition = true;
				StopMoving();
				Focus = none;
				return;				
			}
			else
			{
				m_lastUpdatePaceTime = int(Level.TimeSeconds);
				GetRandomTweenNum(m_pawn.m_updatePaceTween);
			}
		}
		// End:0xFF
		if(__NFUN_132__(__NFUN_114__(m_pawnToFollow, none), __NFUN_114__(MoveTarget, none)))
		{
			return;
		}
		bUpdateMove = false;
		// End:0x181
		if(__NFUN_130__(m_bRunningToward, __NFUN_129__(m_pawnToFollow.IsAlive())))
		{
			m_pawnToFollow = R6Rainbow(m_pawnToFollow).Escort_FindRainbow(m_pawn);
			// End:0x15B
			if(__NFUN_114__(m_pawnToFollow, none))
			{
				m_bLatentFnStopped = true;				
			}
			else
			{
				m_pawnToFollow = R6Rainbow(m_pawnToFollow).Escort_GetPawnToFollow(true);
			}
			bUpdateMove = true;			
		}
		else
		{
			// End:0x1CD
			if(CanStopMoving(false))
			{
				bUpdateMove = true;
				m_bLatentFnStopped = true;
				m_lastUpdatePaceTime = int(Level.TimeSeconds);
				m_bNeedToRunToCatchUp = false;
				// End:0x1CA
				if(m_bRunningToward)
				{
					m_bRunToRainbowSuccess = true;
				}				
			}
			else
			{
				// End:0x1FA
				if(__NFUN_130__(MoveTarget.__NFUN_303__('R6Pawn'), __NFUN_119__(MoveTarget, m_pawnToFollow)))
				{
					bUpdateMove = true;
				}
			}
		}
		// End:0x20A
		if(bUpdateMove)
		{
			MoveTarget = none;
		}
		return;
	}
Begin:

	__NFUN_256__(RandRange(0.1000000, 0.5000000));
	J0x13:

	// End:0x30 [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x13;
	}
	// End:0xDD
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_130__(m_bRunningToward, __NFUN_129__(m_pawn.isStanding())), __NFUN_154__(int(m_pawn.m_ePosition), int(3))), __NFUN_154__(int(m_pawn.m_ePosition), int(1))), m_pawn.isStandingHandUp()))
	{
		SetPawnPosition(0);
		J0xA1:

		// End:0xC0 [Loop If]
		if(__NFUN_129__(m_pawn.m_bPostureTransition))
		{
			__NFUN_256__(0.1000000);
			// [Loop Continue]
			goto J0xA1;
		}
		J0xC0:

		// End:0xDD [Loop If]
		if(m_pawn.m_bPostureTransition)
		{
			__NFUN_256__(0.1000000);
			// [Loop Continue]
			goto J0xC0;
		}
	}
	// End:0x100
	if(m_bRunningToward)
	{
		m_pawn.m_escortedByRainbow = GetRainbowWhoEscortThisPawn(m_pawnToFollow);
	}
	m_bRunToRainbowSuccess = false;
	m_bNeedToRunToCatchUp = false;
	m_bStopDoTransition = false;
MovingSetDefault:


	m_lastUpdatePaceTime = int(Level.TimeSeconds);
	__NFUN_280__(m_AITickTime.m_fMin, true);
	m_pawn.bCanWalkOffLedges = m_pawn.default.bCanWalkOffLedges;
Moving:


	// End:0x196
	if(m_bStopDoTransition)
	{
		Focus = none;
		StopMoving();
		m_bStopDoTransition = false;
		J0x179:

		// End:0x196 [Loop If]
		if(m_pawn.m_bPostureTransition)
		{
			__NFUN_256__(0.1000000);
			// [Loop Continue]
			goto J0x179;
		}
	}
WaitForClimbing:


	// End:0x424
	if(__NFUN_119__(m_pawn.m_Ladder, none))
	{
		StopMoving();
		__NFUN_118__('Timer');
		// End:0x263
		if(__NFUN_132__(__NFUN_176__(__NFUN_186__(__NFUN_175__(m_pawnToFollow.Location.Z, Pawn.Location.Z)), float(80)), m_pawnToFollow.m_bIsClimbingLadder))
		{
			__NFUN_256__(0.5000000);
			// End:0x232
			if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
			{
				m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
			}
			// End:0x25A
			if(__NFUN_520__(m_pawnToFollow))
			{
				m_pawn.m_Ladder = none;
				__NFUN_117__('Timer');
				goto 'EndClimbLadder';
			}
			goto 'WaitForClimbing';			
		}
		else
		{
			__NFUN_517__(m_pawnToFollow, true);
			// End:0x2AF
			if(__NFUN_132__(__NFUN_129__(RouteCacheWithOtherLadder(m_pawn.m_Ladder)), __NFUN_520__(m_pawnToFollow)))
			{
				m_pawn.m_Ladder = none;
				__NFUN_117__('Timer');
				goto 'EndClimbLadder';
			}
			NextLabel = 'None';
			MoveTarget = m_pawn.m_Ladder;
			R6PreMoveToward(MoveTarget, MoveTarget, 4);
			__NFUN_502__(MoveTarget);
			// End:0x416
			if(__NFUN_154__(int(m_eMoveToResult), int(1)))
			{
				// End:0x3DB
				if(__NFUN_130__(__NFUN_119__(m_pawn.m_Ladder, none), __NFUN_129__(R6LadderVolume(m_pawn.m_Ladder.MyLadder).IsAvailable(Pawn))))
				{
					__NFUN_2209__(m_pawn.m_Ladder, m_vTargetPosition);
					m_pawn.m_Ladder = none;
					// End:0x39F
					if(__NFUN_132__(m_pawn.bIsCrouched, m_pawn.m_bIsProne))
					{
						R6PreMoveTo(m_vTargetPosition, Location, 2);						
					}
					else
					{
						R6PreMoveTo(m_vTargetPosition, Location, 4);
					}
					__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));
					StopMoving();
					__NFUN_256__(0.5000000);
					goto 'WaitForClimbing';
				}
				MoveTarget = m_pawn.m_Ladder;
				// End:0x416
				if(CanClimbLadders(m_pawn.m_Ladder))
				{
					NextState = __NFUN_284__();
					__NFUN_113__('ApproachLadder');
				}
			}
			__NFUN_256__(0.5000000);
			goto 'WaitForClimbing';
		}
	}
	J0x424:

	// End:0x49F
	if(__NFUN_129__(CanStopMoving(true)))
	{
		m_bFollowIncreaseDistance = false;
		m_lastUpdatePaceTime = int(Level.TimeSeconds);
		// End:0x473
		if(SetMovementPace(true))
		{
			m_bStopDoTransition = true;
			StopMoving();
			Focus = none;
			goto 'Moving';
		}
		m_bLatentFnStopped = false;
		// End:0x491
		if(__NFUN_129__(__NFUN_520__(m_pawnToFollow)))
		{
			goto 'bLocked';			
		}
		else
		{
			MoveTarget = m_pawnToFollow;
		}		
	}
	else
	{
		// End:0x4B6
		if(m_bRunningToward)
		{
			m_bRunToRainbowSuccess = true;
			goto 'endRunning';
		}
	}
	// End:0x55B
	if(__NFUN_119__(MoveTarget, none))
	{
		MoveTarget = m_pawnToFollow;
		Destination = __NFUN_215__(MoveTarget.Location, __NFUN_212__(__NFUN_226__(__NFUN_216__(MoveTarget.Location, Pawn.Location)), float(__NFUN_143__(105))));
		Focus = none;
		FocalPoint = MoveTarget.Location;
		__NFUN_500__(Destination);
		// End:0x558
		if(m_bLatentFnStopped)
		{
			// End:0x552
			if(__NFUN_132__(__NFUN_114__(m_pawnToFollow, none), m_bRunToRainbowSuccess))
			{
				goto 'endRunning';
			}
			StopMoving();
		}		
	}
	else
	{
		// End:0x5A1
		if(m_pawnToFollow.m_bIsClimbingLadder)
		{
			// End:0x599
			if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
			{
				m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
			}
			__NFUN_256__(0.5000000);
		}
		// End:0x5ED
		if(__NFUN_129__(m_pawn.IsStationary()))
		{
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			Pawn.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		}
		__NFUN_256__(m_AITickTime.m_fMin);
	}
	goto 'Moving';
bLocked:


	// End:0x665
	if(__NFUN_176__(33.0000000, __NFUN_186__(__NFUN_175__(__NFUN_175__(m_pawnToFollow.Location.Z, m_pawnToFollow.CollisionHeight), __NFUN_175__(m_pawn.Location.Z, m_pawn.CollisionHeight)))))
	{
		m_pawn.bCanWalkOffLedges = true;
	}
	MoveTarget = none;
	// End:0x7E5
	if(FindBestPathToward(m_pawnToFollow, true))
	{
		// End:0x70F
		if(__NFUN_114__(MoveTarget, m_pawnToFollow))
		{
			Destination = __NFUN_215__(MoveTarget.Location, __NFUN_212__(__NFUN_226__(__NFUN_216__(MoveTarget.Location, Pawn.Location)), float(__NFUN_143__(105))));
			// End:0x706
			if(__NFUN_521__(Destination))
			{
				Focus = none;
				FocalPoint = MoveTarget.Location;
				__NFUN_500__(Destination);
				StopMoving();
				MoveTarget = none;				
			}
			else
			{
				goto 'UseMoveToward';
			}			
		}
		else
		{
UseMoveToward:


			__NFUN_280__(0.0000000, false);
			R6PreMoveToward(MoveTarget, MoveTarget, m_pawn.m_eMovementPace);
			// End:0x7DD
			if(__NFUN_130__(__NFUN_177__(__NFUN_225__(__NFUN_216__(m_pawnToFollow.Location, Pawn.Location)), float(c_iDistanceToStartToRun)), __NFUN_155__(int(m_pawn.m_eHealth), int(1))))
			{
				// End:0x7A1
				if(__NFUN_154__(int(m_pawn.m_eMovementPace), int(4)))
				{
					SetPace(5);					
				}
				else
				{
					// End:0x7DD
					if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eMovementPace), int(2)), __NFUN_154__(int(m_pawn.m_eMovementPace), int(1))))
					{
						SetPace(3);
					}
				}
			}
			__NFUN_502__(MoveTarget);
		}
	}
	// End:0x814
	if(__NFUN_119__(m_pawn.m_Ladder, none))
	{
		m_bool = __NFUN_520__(m_pawn.m_Ladder);		
	}
	else
	{
		m_bool = __NFUN_520__(m_pawnToFollow);
	}
	// End:0x8CF
	if(__NFUN_130__(__NFUN_114__(MoveTarget, none), __NFUN_114__(m_pawn.m_Ladder, none)))
	{
		Destination = __NFUN_215__(m_pawnToFollow.Location, __NFUN_212__(__NFUN_226__(__NFUN_216__(m_pawnToFollow.Location, Pawn.Location)), float(__NFUN_143__(105))));
		__NFUN_500__(Destination);
		StopMoving();
		__NFUN_256__(0.5000000);
		// End:0x8C6
		if(__NFUN_130__(__NFUN_129__(m_bool), __NFUN_114__(__NFUN_518__(m_pawnToFollow.Location, true), none)))
		{
			goto 'bLocked';			
		}
		else
		{
			goto 'MovingSetDefault';
		}		
	}
	else
	{
		// End:0xA0A
		if(__NFUN_129__(m_bool))
		{
			// End:0xA01
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(MoveTarget, none), __NFUN_114__(m_pawn.m_Ladder, none)), MoveTarget.__NFUN_303__('R6Ladder')))
			{
				// End:0xA01
				if(__NFUN_130__(__NFUN_176__(DistanceTo(MoveTarget), float(50)), __NFUN_177__(__NFUN_186__(__NFUN_175__(MoveTarget.Location.Z, Pawn.Location.Z)), float(40))))
				{
					m_pawn.m_Ladder = R6Ladder(MoveTarget).m_pOtherFloor;
					__NFUN_2209__(R6Ladder(MoveTarget).m_pOtherFloor, m_vTargetPosition);
					m_pawn.m_Ladder = none;
					R6PreMoveTo(m_vTargetPosition, Location, 4);
					__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));
					StopMoving();
					// End:0xA01
					if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
					{
						m_pawn.m_escortedByRainbow.Escort_UpdateCloserToLead();
					}
				}
			}
			goto 'bLocked';			
		}
		else
		{
			MoveTarget = m_pawnToFollow;
			goto 'MovingSetDefault';
		}
	}
	J0xA1B:

	// End:0xA8A
	if(m_bRunningToward)
	{
		StopMoving();
		m_bRunningToward = false;
		// End:0xA67
		if(m_bRunToRainbowSuccess)
		{
			ResetThreatInfo("runningToward success");
			Order_FollowMe(m_pawnToFollow, false);			
		}
		else
		{
			ResetThreatInfo("runningToward failed");
			ReturnToNormalState(true);
		}
	}
	stop;	
}

state RunForCover
{
	function BeginState()
	{
		// End:0x1C
		if(__NFUN_129__(m_pawn.isStanding()))
		{
			SetPawnPosition(0);
		}
		__NFUN_280__(m_AITickTime.m_fResult, true);
		m_lastSeenPawn = none;
		Focus = none;
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		m_runAwayOfGrenade = none;
		return;
	}

	function Timer()
	{
		// End:0x11
		if(__NFUN_119__(m_lastSeenPawn, none))
		{
			SeePlayerMgr();
		}
		return;
	}

	function StopRunForCover()
	{
		StopMoving();
		Enemy = none;
		m_runAwayOfGrenade = none;
		ResetThreatInfo("StopRunForCover");
		return;
	}

	function EnemyNotVisible()
	{
		// End:0x28
		if(__NFUN_119__(m_runAwayOfGrenade, none))
		{
			// End:0x26
			if(IsAwayOfGrenade(m_runAwayOfGrenade))
			{
				StopRunForCover();
				__NFUN_113__(m_runForCoverStateToGoOnSuccess);
			}
			return;
		}
		// End:0xBB
		if(__NFUN_177__(__NFUN_175__(Level.TimeSeconds, LastSeenTime), float(c_iEnemyNotVisibleTime)))
		{
			// End:0xAE
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(R6Pawn(Enemy), none), __NFUN_119__(R6Pawn(Enemy).Controller, none)), R6Pawn(Enemy).Controller.__NFUN_533__(Pawn)))
			{
				LastSeenTime = Level.TimeSeconds;
				return;
			}
			StopRunForCover();
			__NFUN_113__(m_runForCoverStateToGoOnSuccess);
		}
		return;
	}

	function bool IsRunForCoverSuccessfull()
	{
		local bool bResult;

		// End:0x20
		if(__NFUN_119__(m_runAwayOfGrenade, none))
		{
			bResult = IsAwayOfGrenade(m_runAwayOfGrenade);			
		}
		else
		{
			// End:0x56
			if(__NFUN_119__(Enemy, none))
			{
				bResult = __NFUN_129__(R6Pawn(Enemy).Controller.__NFUN_533__(Pawn));				
			}
			else
			{
				bResult = true;
			}
		}
		return bResult;
		return;
	}

	event OpenDoorFailed()
	{
		StopRunForCover();
		__NFUN_113__(m_runForCoverStateToGoOnFailure);
		return;
	}
	J0x00:
	// End:0x1D [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x00;
	}
	SetPace(5);
ChooseDestination:


	// End:0x3D
	if(__NFUN_114__(Enemy, none))
	{
		StopRunForCover();
		__NFUN_113__(m_runForCoverStateToGoOnSuccess);
	}
	// End:0x73
	if(__NFUN_129__(IsRunForCoverPossible(Enemy)))
	{
		// End:0x66
		if(IsRunForCoverSuccessfull())
		{
			StopRunForCover();
			__NFUN_113__(m_runForCoverStateToGoOnSuccess);			
		}
		else
		{
			StopRunForCover();
			__NFUN_113__(m_runForCoverStateToGoOnFailure);
		}
	}
	J0x73:

	__NFUN_1812__(m_pawn.m_eMovementPace, 'ReturnToPath', false);
	goto 'ChooseDestination';
ReturnToPath:


	__NFUN_1812__(m_pawn.m_eMovementPace, 'ReturnToPath', true);
	goto 'ChooseDestination';
	stop;		
}

state Civilian
{
	ignores SeePlayerMgr;

	function BeginState()
	{
		// End:0x19
		if(m_pawn.m_bClassicMissionCivilian)
		{
			__NFUN_117__('HearNoise');
		}
		return;
	}

	function EndState()
	{
		StopMoving();
		return;
	}
	stop;
}

state CivPatrolArea extends Civilian
{
	function BeginState()
	{
		return;
	}
Begin:

	SetPace(4);
AtDestination:


	m_vTargetPosition = m_pawn.m_DZone.__NFUN_1831__();
	MoveTarget = __NFUN_518__(m_vTargetPosition, true);
	// End:0x53
	if(__NFUN_119__(MoveTarget, none))
	{
		__NFUN_1814__(m_vTargetPosition, m_pawn.m_eMovementPace);
	}
	__NFUN_256__(GetRandomTweenNum(m_pawn.m_patrolAreaWaitTween));
	__NFUN_261__();
	goto 'AtDestination';
	stop;				
}

state CivGuardPoint extends Civilian
{
	function BeginState()
	{
		// End:0xB3
		if(__NFUN_130__(m_pawn.m_bPoliceManMp1, m_pawn.m_bPoliceManHasWeapon))
		{
			m_pawn.ServerGivesWeaponToClient("R63rdWeapons.NormalSubMP5A4", 1);
			m_pawn.SetToNormalWeapon();
			// End:0x8B
			if(__NFUN_114__(m_pawn.EngineWeapon, none))
			{
				logX("No weapon!!!!");
			}
			m_pawn.EngineWeapon.__NFUN_113__('BringWeaponUp');
			m_pawn.PlayWeaponAnimation();
		}
		return;
	}

//------------------------------------------------------------------
// SeePlayer: 
//	- inherited
//------------------------------------------------------------------
	function SeePlayer(Pawn P)
	{
		local R6Pawn seen;

		// End:0x7D
		if(__NFUN_130__(m_pawn.m_bPoliceManMp1, m_pawn.m_bPoliceManCanSeeRainbows))
		{
			seen = R6Pawn(P);
			// End:0x43
			if(__NFUN_114__(seen, none))
			{
				return;
			}
			// End:0x7D
			if(__NFUN_154__(int(P.m_ePawnType), int(1)))
			{
				m_pawn.__NFUN_259__(m_pawn.m_NocsSeeRainbowsName);
				__NFUN_113__('WaitForSomeTime');
			}
		}
		return;
	}
Begin:

	ChangeOrientationTo(m_pawn.m_DZone.Rotation);
	__NFUN_508__();
	stop;			
}

state WaitForSomeTime
{Begin:

	__NFUN_256__(RandRange(5.0000000, 10.0000000));
	__NFUN_113__('CivGuardPoint');
	stop;	
}

state CivPatrolPath extends Civilian
{
	function BeginState()
	{
		// End:0x20
		if(__NFUN_114__(R6DZonePath(m_pawn.m_DZone), none))
		{
			__NFUN_113__('CivGuardPoint');
		}
		return;
	}

	function int GetWaitingTime()
	{
		local int ITemp;

		ITemp = int(GetRandomTweenNum(m_pawn.m_patrolAreaWaitTween));
		return __NFUN_146__(__NFUN_167__(__NFUN_146__(ITemp, 1)), ITemp);
		return;
	}

	function int GetFacingTime()
	{
		local int ITemp;

		ITemp = int(GetRandomTweenNum(m_pawn.m_changeOrientationTween));
		return __NFUN_146__(__NFUN_167__(__NFUN_146__(ITemp, 1)), ITemp);
		return;
	}

	function bool IsGoingBack()
	{
		return false;
		return;
	}

	function PickDestination()
	{
		local Rotator R;
		local int iDistance;

		R.Yaw = __NFUN_144__(__NFUN_167__(32767), 2);
		iDistance = __NFUN_167__(int(m_pawn.m_currentNode.m_fRadius));
		m_vTargetPosition = __NFUN_215__(m_pawn.m_currentNode.Location, __NFUN_212__(Vector(R), float(iDistance)));
		return;
	}

	event OpenDoorFailed()
	{
		m_pawn.m_currentNode = none;
		__NFUN_113__('CivPatrolPath');
		return;
	}

	function SetToNextNode()
	{
		local R6DZonePathNode firstnode;
		local R6DZonePath Path;
		local int Index;

		MoveTarget = none;
		firstnode = m_pawn.m_currentNode;
		Path = R6DZonePath(m_pawn.m_DZone);
		J0x34:

		// End:0x168 [Loop If]
		if(__NFUN_114__(MoveTarget, none))
		{
			// End:0xBF
			if(__NFUN_129__(Path.m_bCycle))
			{
				Index = Path.GetNodeIndex(m_pawn.m_currentNode);
				// End:0x92
				if(__NFUN_154__(Index, 0))
				{
					m_pawn.m_bPatrolForward = true;
				}
				// End:0xBF
				if(__NFUN_154__(Index, __NFUN_147__(Path.m_aNode.Length, 1)))
				{
					m_pawn.m_bPatrolForward = false;
				}
			}
			// End:0x100
			if(m_pawn.m_bPatrolForward)
			{
				m_pawn.m_currentNode = Path.GetNextNode(m_pawn.m_currentNode);				
			}
			else
			{
				m_pawn.m_currentNode = Path.GetPreviousNode(m_pawn.m_currentNode);
			}
			// End:0x14D
			if(__NFUN_114__(firstnode, m_pawn.m_currentNode))
			{
				__NFUN_113__('CivGuardPoint');
				return;
			}
			MoveTarget = __NFUN_517__(m_pawn.m_currentNode, true);
			// [Loop Continue]
			goto J0x34;
		}
		return;
	}
Begin:

	// End:0x89
	if(__NFUN_114__(m_pawn.m_currentNode, none))
	{
		m_pawn.m_currentNode = R6DZonePath(m_pawn.m_DZone).FindNearestNode(Pawn);
		// End:0x60
		if(__NFUN_114__(m_pawn.m_currentNode, none))
		{
			__NFUN_113__('CivGuardPoint');
		}
		MoveTarget = __NFUN_517__(m_pawn.m_currentNode, true);
		// End:0x89
		if(__NFUN_114__(MoveTarget, none))
		{
			SetToNextNode();
		}
	}
	SetPace(4);
FindPathToNode:


	PickDestination();
	__NFUN_1814__(m_vTargetPosition, m_pawn.m_eMovementPace);
ReachedTheNode:


	// End:0xD7
	if(m_pawn.m_currentNode.bDirectional)
	{
		ChangeOrientationTo(GetRandomTurn90());
		__NFUN_508__();
	}
	// End:0x17A
	if(m_pawn.m_currentNode.m_bWait)
	{
		m_iWaitingTime = GetWaitingTime();
		m_iFacingTime = GetFacingTime();
		// End:0x146
		if(__NFUN_150__(m_iFacingTime, m_iWaitingTime))
		{
			__NFUN_256__(float(m_iFacingTime));
			ChangeOrientationTo(GetRandomTurn90());
			__NFUN_256__(float(__NFUN_147__(m_iWaitingTime, m_iFacingTime)));
			__NFUN_508__();			
		}
		else
		{
			__NFUN_256__(float(m_iWaitingTime));
		}
		// End:0x17A
		if(IsGoingBack())
		{
			m_pawn.m_bPatrolForward = __NFUN_129__(m_pawn.m_bPatrolForward);
		}
	}
	SetToNextNode();
	Focus = m_pawn.m_currentNode;
	__NFUN_261__();
	__NFUN_508__();
	goto 'FindPathToNode';
	stop;			
}

state EscortedByEnemy
{
	function BeginState()
	{
		return;
	}

	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		m_pawn.SetStandWalkingAnim(1, false);
		return;
	}

	function EscortIsOver(bool bSuccess)
	{
		m_pawn.m_bEscorted = false;
		m_escort = none;
		// End:0x4E
		if(__NFUN_119__(m_terrorist, none))
		{
			R6TerroristAI(m_terrorist.Controller).EscortIsOver(self, bSuccess);
			m_terrorist = none;
		}
		ResetThreatInfo("EscortIsOver");
		// End:0x7E
		if(m_pawn.m_bFreed)
		{
			__NFUN_113__('Freed');			
		}
		else
		{
			// End:0x9C
			if(IsInCrouchedPosture())
			{
				SetStateGuarded(1, m_mgr.0);				
			}
			else
			{
				SetStateGuarded(0, m_mgr.0);
			}
		}
		return;
	}
	J0x00:
	// End:0x1D [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x00;
	}
	// End:0x65
	if(m_pawn.isStandingHandUp())
	{
		m_pawn.m_eHandsUpType = 0;
		m_pawn.SetAnimTransition(m_mgr.ANIM_eStandHandUpToDown, 'None');		
	}
	else
	{
		// End:0x81
		if(__NFUN_129__(m_pawn.isStanding()))
		{
			SetPawnPosition(0);
		}
	}
	J0x81:

	// End:0x9E [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x81;
	}
	// End:0xBC
	if(__NFUN_217__(m_vMoveToDest, Pawn.Location))
	{
		goto 'StartWaiting';
	}
	// End:0xEA
	if(__NFUN_154__(int(m_escort.m_ePawnType), int(2)))
	{
		m_pawn.SetStandWalkingAnim(0, true);		
	}
	else
	{
		m_pawn.SetStandWalkingAnim(1, true);
	}
	MoveTarget = __NFUN_518__(m_vMoveToDest, true);
	// End:0x11D
	if(__NFUN_114__(MoveTarget, none))
	{
		EscortIsOver(false);
	}
	__NFUN_1814__(m_vMoveToDest, m_pawn.m_eMovementPace);
StartWaiting:


	StopMoving();
	EscortIsOver(true);
	stop;			
}

state CivStayHere extends Civilian
{
	function BeginState()
	{
		StopMoving();
		ResetThreatInfo("CivStayHere");
		return;
	}
	stop;
}

state GoCivScareToDeath
{
	function BeginState()
	{
		StopMoving();
		SetPawnPosition(3);
		m_bForceToStayHere = true;
		ProcessPlaySndInfo(m_mgr.7);
		SetThreatState('CivScareToDeath');
		__NFUN_113__(m_threatInfo.m_state);
		return;
	}
	stop;
}

state CivScareToDeath extends Civilian
{
	function BeginState()
	{
		return;
	}
Begin:

	__NFUN_256__(GetRandomTweenNum(m_scareToDeathTween));
	ResetThreatInfo("CivScareToDeath is over");
	m_bForceToStayHere = false;
	SetPawnPosition(1);
	__NFUN_113__('CivStayHere');
	stop;			
}

state CivRunForCover
{
	function BeginState()
	{
		// End:0x1C
		if(m_pawn.m_bPoliceManMp1)
		{
			__NFUN_113__('CivGuardPoint');			
		}
		else
		{
			// End:0x37
			if(m_pawn.m_bClassicMissionCivilian)
			{
				CivCheckCoverNode();				
			}
			else
			{
				__NFUN_113__('GoCivScareToDeath');
			}
		}
		return;
	}
	stop;
}

state CivMovingTo
{
	function BeginState()
	{
		return;
	}
Begin:

	m_iRandomNumber = 0;
	// End:0x2E
	if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_vMoveToDest, Pawn.Location)), 10.0000000))
	{
		goto 'Exit';
	}
	Focus = none;
	// End:0x51
	if(__NFUN_129__(m_pawn.isStanding()))
	{
		SetPawnPosition(0);
	}
	J0x51:

	// End:0x6E [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x51;
	}
PathFinding:


	// End:0x99
	if(__NFUN_132__(__NFUN_130__(__NFUN_119__(m_pCoverNode, none), __NFUN_520__(m_pCoverNode)), __NFUN_521__(m_vMoveToDest)))
	{
		goto 'EndPath';
	}
	// End:0xB5
	if(__NFUN_119__(m_pCoverNode, none))
	{
		MoveTarget = __NFUN_517__(m_pCoverNode);		
	}
	else
	{
		MoveTarget = __NFUN_518__(m_vMoveToDest, true);
	}
	// End:0xDD
	if(__NFUN_114__(MoveTarget, none))
	{
		__NFUN_256__(0.5000000);
		goto 'Exit';
	}
	// End:0x106
	if(__NFUN_154__(m_iRandomNumber, 0))
	{
		m_iRandomNumber = 1;
		FocalPoint = MoveTarget.Location;
		__NFUN_508__();
	}
	Focus = none;
	R6PreMoveTo(MoveTarget.Location, MoveTarget.Location, m_pawn.m_eMovementPace);
	__NFUN_502__(MoveTarget);
	// End:0x15B
	if(__NFUN_154__(int(m_eMoveToResult), int(2)))
	{
		goto 'Exit';
	}
	goto 'PathFinding';
EndPath:


	// End:0x181
	if(__NFUN_154__(m_iRandomNumber, 0))
	{
		m_iRandomNumber = 1;
		FocalPoint = m_vMoveToDest;
		__NFUN_508__();
	}
	Focus = none;
	R6PreMoveTo(m_vMoveToDest, m_vMoveToDest, m_pawn.m_eMovementPace);
	// End:0x1BC
	if(__NFUN_119__(m_pCoverNode, none))
	{
		__NFUN_502__(m_pCoverNode);		
	}
	else
	{
		__NFUN_500__(m_vMoveToDest);
	}
	J0x1C4:

	StopMoving();
	__NFUN_113__('CMCivStayHere');
	stop;		
}

state CMCivStayKneel extends Civilian
{
	function BeginState()
	{
		StopMoving();
		m_pawn.m_bAvoidFacingWalls = true;
		SetPawnPosition(1);
		ResetThreatInfo("CivStayHere");
		return;
	}
	stop;
}

state CMCivStayHere extends Civilian
{
	function BeginState()
	{
		StopMoving();
		m_pawn.m_bAvoidFacingWalls = true;
		SetPawnPosition(4);
		ResetThreatInfo("CivStayHere");
		return;
	}
	stop;
}

state CivRunTowardRainbow
{
	function BeginState()
	{
		// End:0x2F
		if(__NFUN_132__(m_pawn.m_bCivilian, m_pawn.m_bPoliceManMp1))
		{
			CivInit();			
		}
		else
		{
			SetStateFollowingPawn(R6Pawn(m_threatInfo.m_pawn), true, m_mgr.4);
		}
		return;
	}
	stop;
}

state CivSurrender
{
	function BeginState()
	{
		// End:0x2F
		if(__NFUN_132__(m_pawn.m_bCivilian, m_pawn.m_bPoliceManMp1))
		{
			CivInit();			
		}
		else
		{
			// End:0x6C
			if(__NFUN_119__(m_terrorist, none))
			{
				ProcessPlaySndInfo(m_mgr.2);
				R6TerroristAI(m_terrorist.Controller).HostageSurrender(self);				
			}
			else
			{
				SetStateGuarded(5, m_mgr.2);
			}
		}
		return;
	}
	stop;
}

state OpenDoor
{	stop;
}

state ReactToGrenade
{
	function BeginState()
	{
		return;
	}
Begin:

	__NFUN_256__(RandRange(0.1000000, 0.3000000));
	// End:0x7C
	if(__NFUN_132__(__NFUN_154__(int(m_pawn.m_eEffectiveGrenade), int(3)), __NFUN_154__(int(m_pawn.m_eEffectiveGrenade), int(4))))
	{
		StopMoving();
		m_pawn.SetNextPendingAction(3);
		GetRandomTweenNum(m_stayBlindedTweenTime);
		__NFUN_256__(m_stayBlindedTweenTime.m_fResult);
		goto 'End';
	}
End:


	__NFUN_113__(m_reactToGrenadeStateToReturn);
	stop;				
}

state GoHstFreedButSeeEnemy
{
	function BeginState()
	{
		// End:0x1F
		if(IsInCrouchedPosture())
		{
			SetStateGuarded(1, m_mgr.2);			
		}
		else
		{
			SetStateGuarded(0, m_mgr.2);
		}
		ResetThreatInfo("GoHstFreedButSeeEnemy");
		return;
	}
	stop;
}

state GoHstRunTowardRainbow
{
	function BeginState()
	{
		SetStateFollowingPawn(R6Pawn(m_threatInfo.m_pawn), true, m_mgr.5);
		return;
	}
	stop;
}

state GoHstRunForCover
{
	function BeginState()
	{
		// End:0x1B
		if(m_pawn.m_bPoliceManMp1)
		{
			CivInit();			
		}
		else
		{
			SetFreed(true);
			SetStateRunForCover(m_threatInfo.m_pawn, 'Freed', 'Guarded_foetus', m_threatInfo.m_actorExt);
		}
		return;
	}
	stop;
}

state DbgHostage
{
	function BeginState()
	{
		StopMoving();
		return;
	}
	stop;
}

state GotoExtraction
{
	function BeginState()
	{
		// End:0x1C
		if(__NFUN_129__(m_pawn.isStanding()))
		{
			SetPawnPosition(0);
		}
		Focus = none;
		return;
	}
	J0x00:
	// End:0x1D [Loop If]
	if(m_pawn.m_bPostureTransition)
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x00;
	}
	// End:0x52
	if(__NFUN_119__(m_pawn.m_escortedByRainbow, none))
	{
		__NFUN_256__(0.3000000);
		StopFollowingPawn(false);
		m_pawn.SetStandWalkingAnim(1, true);
	}
RunToDestination:


	Focus = none;
	// End:0x85
	if(__NFUN_218__(m_vMoveToDest, m_pGotoToExtractionZone.Location))
	{
		m_vMoveToDest = m_pGotoToExtractionZone.Location;
	}
	// End:0xB2
	if(__NFUN_176__(__NFUN_225__(__NFUN_216__(Pawn.Location, m_vMoveToDest)), float(100)))
	{
		StopMoving();
		__NFUN_113__('Freed');
	}
	SetPace(5);
	m_vTargetPosition = m_vMoveToDest;
	// End:0xFA
	if(__NFUN_521__(m_vTargetPosition))
	{
		Focus = none;
		FocalPoint = m_vTargetPosition;
		__NFUN_500__(m_vTargetPosition);
		StopMoving();
		MoveTarget = none;		
	}
	else
	{
		MoveTarget = __NFUN_518__(m_vTargetPosition, true);
		// End:0x12E
		if(__NFUN_119__(MoveTarget, none))
		{
			__NFUN_1812__(m_pawn.m_eMovementPace, 'ReturnToPath', false);			
		}
		else
		{
			R6PreMoveToward(m_pGotoToExtractionZone, m_pGotoToExtractionZone, m_pawn.m_eMovementPace);
			__NFUN_502__(m_pGotoToExtractionZone);
			__NFUN_256__(1.0000000);
		}
	}
	goto 'RunToDestination';
ReturnToPath:


	__NFUN_1812__(m_pawn.m_eMovementPace, 'ReturnToPath', true);
	goto 'RunToDestination';
	stop;				
}

state Extracted
{
	ignores R6DamageAttitudeTo;

	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = true;
		Focus = none;
		m_bIgnoreBackupBump = false;
		return;
	}

//------------------------------------------------------------------
// AIAffectedByGrenade()                                       
//------------------------------------------------------------------
	function AIAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
	{
		return;
	}

	function Timer()
	{
		m_iWaitingTime = int(GetRandomTweenNum(m_pawn.m_changeOrientationTween));
		__NFUN_280__(float(m_iWaitingTime), false);
		ChangeOrientationTo(GetRandomTurn90());
		return;
	}
Begin:

	__NFUN_256__(float(__NFUN_167__(2)));
	StopMoving();
	m_bForceToStayHere = true;
	StopFollowingPawn(false);
	m_iWaitingTime = int(GetRandomTweenNum(m_pawn.m_changeOrientationTween));
	__NFUN_280__(float(m_iWaitingTime), false);
	stop;		
}

defaultproperties
{
	c_iDistanceMax=190
	c_iDistanceCatchUp=160
	c_iDistanceToStartToRun=350
	c_iCowardModifier=-40
	c_iBraveModifier=40
	c_iWoundedModifier=20
	c_iGasModifier=20
	c_iEnemyNotVisibleTime=5
	c_iCautiousLastHearNoiseTime=5
	c_iRunForCoverOfGrenadeMinDist=500
	m_bFirstTimeClarkComment=true
	m_AITickTime=(m_fMin=0.1000000,m_fMax=0.5000000)
	m_RunForCoverMinTween=(m_fMin=4.0000000,m_fMax=6.0000000)
	m_scareToDeathTween=(m_fMin=10.0000000,m_fMax=14.0000000)
	m_stayBlindedTweenTime=(m_fMin=2.8000000,m_fMax=3.3000000)
	c_iDistanceBumpBackUp=90
	bIsPlayer=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function CanClimbObject
