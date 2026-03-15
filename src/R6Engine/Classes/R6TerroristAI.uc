//=============================================================================
// R6TerroristAI - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TerroristAI.uc : This is the AI Controller class for all terrorists
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Rima Brek
//    2001/05/08   Added a basic default waiting state that cycles through 
//                 the 3 wait animations
//=============================================================================
class R6TerroristAI extends R6AIController
    native;

const C_MaxDistanceForActionSpot = 2000;
const C_DefaultSearchTime = 30;
const C_HostageReactionSearchTime = 15;
const C_HostageSearchTime = 15;
const C_WaitingForEnemyTime = 15;
const C_NumberOfNodeRemembered = 10;

enum EAttackMode
{
	ATTACK_NotEngaged,              // 0
	ATTACK_AimedFire,               // 1
	ATTACK_SprayFire,               // 2
	ATTACK_SprayFireNoStop,         // 3
	ATTACK_SprayFireMove            // 4
};

enum EReactionStatus
{
	REACTION_HearAndSeeAll,         // 0
	REACTION_SeeHostage,            // 1
	REACTION_HearBullet,            // 2
	REACTION_SeeRainbow,            // 3
	REACTION_Grenade,               // 4
	REACTION_HearAndSeeNothing      // 5
};

enum EEventState
{
	EVSTATE_DefaultState,           // 0
	EVSTATE_RunAway,                // 1
	EVSTATE_Attack,                 // 2
	EVSTATE_FindHostage,            // 3
	EVSTATE_AttackHostage           // 4
};

enum EFollowMode
{
	FMODE_Hostage,                  // 0
	FMODE_Path                      // 1
};

enum EEngageReaction
{
	EREACT_Random,                  // 0
	EREACT_AimedFire,               // 1
	EREACT_SprayFire,               // 2
	EREACT_RunAway,                 // 3
	EREACT_Surrender                // 4
};

// Variables used for threat reaction (SeePlayer and HearNoise)
var R6TerroristAI.EEngageReaction m_eEngageReaction;
var R6TerroristAI.EReactionStatus m_eReactionStatus;
var R6TerroristAI.EEventState m_eStateForEvent;
var R6TerroristAI.EAttackMode m_eAttackMode;  // In wich attack mode the terrorist is currently
var R6TerroristAI.EFollowMode m_eFollowMode;
var byte m_wBadMoveCount;
var int m_iCurrentGroupID;
// Variable internally used for AI
var int m_iTerroristInGroup;  // Number of terrorist in group, for reaction check
var int m_iRainbowInCombat;  // Number of Rainbow in combat, for reaction check
var int m_iChanceToDetectShooter;  // Chance that the terrorist detect from where come the bullet,
var int m_iRandomNumber;  // Used in any place where I need a temporary random number
var int m_iStateVariable;  // Variable that can be used inside a state but not used between state
var int m_iFollowYaw;
var bool m_bHearInvestigate;
var bool m_bSeeHostage;
var bool m_bHearThreat;
var bool m_bSeeRainbow;
var bool m_bHearGrenade;
var bool m_bPreciseMove;  // Set to true for the pawn to walk as close as possible to destination
var bool m_bCanFailMovingTo;
var bool m_bFireShort;
// Patrol path variable
var bool m_bInPathMode;
var bool m_bWaiting;
// Variable used for PlayVoices
var bool m_bAlreadyHeardSound;
var bool m_bHeardGrenade;
// For interrupted IO
var bool m_bCalledForBackup;
var float m_fWaitingTime;  // Used in patrol when waiting at a noode
var float m_fFacingTime;  // Used in patrol when waiting at a noode
var float m_fSearchTime;  // Time that the terrorist stay in engaged by sound
var float m_fPawnDistance;
var float m_fFollowDist;
var float m_fLastBumpedTime;
var R6TerroristAI m_TerroristLeader;
var R6Terrorist m_pawn;
var R6TerroristMgr m_Manager;
var R6TerroristVoices m_VoicesManager;
var R6ActionSpot m_pActionSpot;  // Current cover spot of the terrorist
// NEW IN 1.60
var NavigationPoint m_aLastNode[10]; // Last ten node used by the terrorist
var R6Pawn m_huntedPawn;  // hunted pawn
// Hostage interaction
var R6Hostage m_Hostage;
var R6HostageAI m_HostageAI;
var R6DeploymentZone m_ZoneToEscort;
// Follow pawn variable
var R6Pawn m_pawnToFollow;
// MovingTo variable
var Actor m_aMovingToDestination;
var R6Pawn m_LastBumped;
var R6DZonePath m_path;
var R6DZonePathNode m_currentNode;
var R6InteractiveObject m_TriggeredIO;
var name m_stateAfterMovingTo;
var name m_labelAfterMovingTo;
var name m_PatrolCurrentLabel;
var array<R6TerroristAI> m_listAvailableBackup;
                                                //   increase with each bullet detected
var Vector m_vThreatLocation;  // Where the terrorist think a threat is coming from
var Vector m_vHostageReactionDirection;  // hostage reaction direction
var Vector m_vMovingDestination;
var Rotator m_rStandRotation;
var Vector m_vSpawningPosition;
var Rotator m_rSpawningRotation;
var string m_sDebugString;

// Export UR6TerroristAI::execGetNextRandomNode(FFrame&, void* const)
native(1820) final function NavigationPoint GetNextRandomNode();

// Export UR6TerroristAI::execCallBackupForAttack(FFrame&, void* const)
native(1821) final function CallBackupForAttack(Vector vDestination, R6Pawn.eMovementPace ePace);

// Export UR6TerroristAI::execCallBackupForInvestigation(FFrame&, void* const)
native(1823) final function CallBackupForInvestigation(Vector vDestination, R6Pawn.eMovementPace ePace);

// Export UR6TerroristAI::execMakeBackupList(FFrame&, void* const)
native(1822) final function bool MakeBackupList();

// Export UR6TerroristAI::execFindBetterShotLocation(FFrame&, void* const)
native(1824) final function Vector FindBetterShotLocation(Pawn PTarget);

// Export UR6TerroristAI::execHaveAClearShot(FFrame&, void* const)
native(1827) final function bool HaveAClearShot(Vector vStart, Pawn PTarget);

// Export UR6TerroristAI::execCallVisibleTerrorist(FFrame&, void* const)
native(1828) final function bool CallVisibleTerrorist();

// Export UR6TerroristAI::execIsAttackSpotStillValid(FFrame&, void* const)
native(1829) final function bool IsAttackSpotStillValid();

event PostBeginPlay()
{
	super(Controller).PostBeginPlay();
	m_VoicesManager = R6TerroristVoices(R6AbstractGameInfo(Level.Game).GetTerroristVoicesMgr(Level.m_eTerroristVoices));
	return;
}

//============================================================================
// LogTerroState - 
//============================================================================
function LogTerroState()
{
	local R6PlayerController C;

	// End:0x4A
	foreach AllActors(Class'R6Engine.R6PlayerController', C)
	{
		// End:0x49
		if((C.CheatManager != none))
		{
			R6CheatManager(C.CheatManager).LogTerro(m_pawn);
			// End:0x4A
			break;
		}		
	}	
	return;
}

//============================================================================
// bool CanClimbLadders - 
//============================================================================
function bool CanClimbLadders(R6Ladder Ladder)
{
	local int i;
	local bool bResult;

	// End:0xAE
	if((m_pawn.m_bAutoClimbLadders && ((MoveTarget == Ladder) || (Pawn.Anchor == Ladder))))
	{
		J0x3D:

		// Scan up to 16 cached route nodes looking for the ladder's exit floor
		// End:0xAE [Loop If]
		if(((i < 16) && (RouteCache[i] != none)))
		{
			// End:0x82
			// Route passes through the other floor, so this ladder leads to our destination
			if((RouteCache[i] == Ladder.m_pOtherFloor))
			{
				bResult = true;
			}
			// End:0xA4
			// If the route re-enters the ladder node after reaching the other floor, climbing would loop — abort
			if((bResult && (RouteCache[i] == Ladder)))
			{
				return false;
			}
			(i++);
			// [Loop Continue]
			goto J0x3D;
		}
	}
	return bResult;
	return;
}

//============================================================================
// BOOL CanSafelyChangeState - 
//          Return true if a pawn can safely change state by event.
//          - Not in ladder
//          - Not in root motion
//          - Not with an uninterruptable interactive object
//============================================================================
function bool CanSafelyChangeState()
{
// Physics 12 = RootMotion (animation drives movement), Physics 11 = Ladder; both must complete before state can change
	return ((((Pawn.IsAlive() && (!m_bCantInterruptIO)) && (int(Pawn.Physics) != int(12))) && (int(Pawn.Physics) != int(11))) && (!m_pawn.m_bIsKneeling));
	return;
}

//============================================================================
// R6DamageAttitudeTo - 
//============================================================================
function R6DamageAttitudeTo(Pawn instigatedBy, Actor.eKillResult eKillFromTable, Actor.eStunResult eStunFromTable, Vector vBulletMomentum)
{
	// End:0x37
	if(IsAnEnemy(R6Pawn(instigatedBy)))
	{
		// Only escalate if not already in highest-alert reaction (REACTION_Grenade=4 or REACTION_HearAndSeeNothing=5 would skip)
		// End:0x37
		if((int(m_eReactionStatus) <= int(3)))
		{
			GotoStateEngageByThreat(instigatedBy.Location);
		}
	}
	// End:0x63
	if((m_pawn.EngineWeapon != none))
	{
		// Being hit degrades aim temporarily (flinch — accuracy penalty until stabilised)
		m_pawn.EngineWeapon.SetAccuracyOnHit();
	}
	return;
}

//============================================================================
// PlaySoundDamage - 
//============================================================================
function PlaySoundDamage(Pawn instigatedBy)
{
	m_VoicesManager.PlayTerroristVoices(m_pawn, 0);
	switch(m_pawn.m_eHealth)
	{
		// End:0x2B
		case 2:
		// End:0x64
		case 3:
			// End:0x61
			if((instigatedBy.Controller != none))
			{
				instigatedBy.Controller.PlaySoundInflictedDamage(m_pawn);
			}
			// End:0x67
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//============================================================================
// SetReactionStatus - 
//============================================================================
function SetReactionStatus(R6TerroristAI.EReactionStatus eNewStatus, R6TerroristAI.EEventState eState)
{
	m_bHearInvestigate = false;
	m_bSeeHostage = false;
	m_bHearThreat = false;
	m_bSeeRainbow = false;
	m_bHearGrenade = false;
	// End:0x42
	if((int(eNewStatus) < int(5)))
	{
		Enable('HearNoise');		
	}
	else
	{
		Disable('HearNoise');
	}
	// End:0x63
	if((int(eNewStatus) < int(4)))
	{
		Enable('SeePlayer');		
	}
	else
	{
		Disable('SeePlayer');
	}
	switch(eNewStatus)
	{
		// End:0x7E
		case 0:
			m_bHearInvestigate = true;
		// End:0x8B
		case 1:
			m_bSeeHostage = true;
		// End:0x98
		case 2:
			m_bHearThreat = true;
		// End:0xA5
		case 3:
			m_bSeeRainbow = true;
		// End:0xB2
		case 4:
			m_bHearGrenade = true;
		// End:0xBA
		case 5:
			// End:0xBD
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_eReactionStatus = eNewStatus;
	m_eStateForEvent = eState;
	// End:0xED
	if((int(m_eStateForEvent) != int(0)))
	{
		Enable('EnemyNotVisible');		
	}
	else
	{
		Disable('EnemyNotVisible');
	}
	return;
}

//============================================================================
// ChangeDefcon - 
//============================================================================
function ChangeDefCon(R6Terrorist.EDefCon eNewDefCon)
{
	switch(eNewDefCon)
	{
		// End:0x28
		// Turn speed decreases as DefCon rises — more relaxed = slower reaction turns (70000 UU/s at full alert)
		case 1:
			m_pawn.RotationRate.Yaw = 70000;
			// End:0xAF
			break;
		// End:0x49
		case 2:
			m_pawn.RotationRate.Yaw = 60000;
			// End:0xAF
			break;
		// End:0x6A
		case 3:
			m_pawn.RotationRate.Yaw = 50000;
			// End:0xAF
			break;
		// End:0x8B
		case 4:
			m_pawn.RotationRate.Yaw = 40000;
			// End:0xAF
			break;
		// End:0xAC
		// DefCon 5 = fully relaxed; turn speed 30000 UU/s (~165 deg/s)
		case 5:
			m_pawn.RotationRate.Yaw = 30000;
			// End:0xAF
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_pawn.m_eDefCon = eNewDefCon;
	// End:0xE7
	// DefCon 1-2 means combat/alert stance; DefCon 3+ is patrol so stand normally
	if((int(eNewDefCon) <= int(2)))
	{
		m_pawn.m_bWantsHighStance = true;		
	}
	else
	{
		m_pawn.m_bWantsHighStance = false;
	}
	m_pawn.PlayMoving();
	return;
}

//============================================================================
// SetActionSpot - 
//============================================================================
function SetActionSpot(R6ActionSpot pNewSpot)
{
	// End:0x1B
	if((m_pActionSpot != none))
	{
		m_pActionSpot.m_pCurrentUser = none;
	}
	m_pActionSpot = pNewSpot;
	// End:0x45
	if((m_pActionSpot != none))
	{
		m_pActionSpot.m_pCurrentUser = m_pawn;
	}
	return;
}

//============================================================================
// SetEnemy - 
//============================================================================
function SetEnemy(Pawn newEnemy)
{
	Enemy = newEnemy;
	LastSeenTime = Level.TimeSeconds;
	// End:0x3E
	if((Enemy != none))
	{
		LastSeenPos = Enemy.Location;
	}
	return;
}

//============================================================================
// INT GetKillingHostageChance - 
//============================================================================
function int GetKillingHostageChance()
{
	local int iChance;

	// End:0x14
	// Random-hostage mode uses a flat 40% base kill chance regardless of zone settings
	if(UseRandomHostage())
	{
		iChance = 40;		
	}
	else
	{
		iChance = m_pawn.m_DZone.m_HostageShootChance;
	}
	// End:0x4E
	// Easy difficulty reduces kill chance by 20%
	if((m_pawn.m_iDiffLevel == 1))
	{
		(iChance -= 20);
	}
	// End:0x6C
	// Hard difficulty increases kill chance by 20%
	if((m_pawn.m_iDiffLevel == 3))
	{
		(iChance += 20);
	}
	return iChance;
	return;
}

//============================================================================
// SeePlayer - 
//============================================================================
event SeePlayer(Pawn seen)
{
	local R6Pawn r6seen;
	local R6Hostage hostage;
	local R6HostageAI hostageAI;

	r6seen = R6Pawn(seen);
	// End:0x1D
	if((r6seen == none))
	{
		return;
	}
	// End:0x5D
	if((m_bSeeHostage && IsAnHostage(r6seen)))
	{
		hostage = R6Hostage(r6seen);
		// End:0x5D
		// Classic-mode civilians should be ignored entirely — they are not hostage targets
		if((hostage.m_bClassicMissionCivilian == true))
		{
			return;
		}
	}
	// End:0xA2
	// EVSTATE_AttackHostage (4): already hunting a hostage — if we see it alive, engage directly
	if((int(m_eStateForEvent) == int(4)))
	{
		// End:0xA0
		if((r6seen.IsAlive() && IsAnHostage(r6seen)))
		{
			SetEnemy(r6seen);
			GotoStateAimedFire();
		}
		return;
	}
	// End:0xF6
	if(((!m_pawn.m_bHearNothing) && (!r6seen.IsAlive())))
	{
		// End:0xD7
		if(CheckForInteraction())
		{
			return;
		}
		// End:0xF6
		if((!m_bAlreadyHeardSound))
		{
			GotoSeeADead(r6seen.Location);
		}
	}
	// End:0x12A
	if((m_bSeeRainbow && IsAnEnemy(r6seen)))
	{
		ReconThreatCheck(seen, 0);
		EngageBySight(r6seen);		
	}
	else
	{
		// End:0x27D
		if((m_bSeeHostage && IsAnHostage(r6seen)))
		{
			hostage = R6Hostage(r6seen);
			// End:0x16A
			if(UseRandomHostage())
			{
				m_Hostage = hostage;				
			}
			else
			{
				// End:0x1DA
				if((!IsAssigned(hostage)))
				{
					// End:0x1B6
					if(IsMyHostage(hostage))
					{
						m_Manager.AssignHostageTo(hostage, self);
						m_VoicesManager.PlayTerroristVoices(m_pawn, 9);						
					}
					else
					{
						m_VoicesManager.PlayTerroristVoices(m_pawn, 12);
						GotoStateFindHostage(hostage);
					}					
				}
				else
				{
					hostageAI = R6HostageAI(hostage.Controller);
					// End:0x27D
					// Hostage has fled in a direction another terrorist reported; take over the chase vector
					if(((hostageAI.m_vReactionDirection != vect(0.0000000, 0.0000000, 0.0000000)) && (m_vHostageReactionDirection == vect(0.0000000, 0.0000000, 0.0000000))))
					{
						m_vHostageReactionDirection = hostageAI.m_vReactionDirection;
						hostageAI.m_vReactionDirection = vect(0.0000000, 0.0000000, 0.0000000);
						GotoPointAndSearch(m_vHostageReactionDirection, 4, false, 15.0000000, m_pawn.m_eDefCon);
					}
				}
			}
		}
	}
	return;
}

//============================================================================
// ReconThreatCheck - 
//============================================================================
function ReconThreatCheck(Actor aThreat, Actor.ENoiseType eType)
{
	local R6Pawn aPawn;

	aPawn = R6Pawn(aThreat);
	// End:0x6E
	if((int(eType) == int(0)))
	{
		// End:0x6B
		if(((aPawn != none) && m_pawn.IsEnemy(aPawn)))
		{
			R6AbstractGameInfo(Level.Game).PawnSeen(aPawn, m_pawn);
		}		
	}
	else
	{
		// End:0xE6
		if(((int(eType) == int(2)) || (m_pawn.IsEnemy(aThreat.Instigator) && aThreat.IsA('R6Weapon'))))
		{
			R6AbstractGameInfo(Level.Game).PawnHeard(aThreat.Instigator, m_pawn);
		}
	}
	return;
}

//============================================================================
// BOOL UseRandomHostage - 
//============================================================================
function bool UseRandomHostage()
{
	return Level.GameTypeUseNbOfTerroristToSpawn(Level.Game.m_szGameTypeFlag);
	return;
}

//============================================================================
// AssignNearHostage - 
//============================================================================
function AssignNearHostage()
{
	local R6Hostage hostage;

	// End:0x2F
	foreach VisibleCollidingActors(Class'R6Engine.R6Hostage', hostage, 500.0000000, Pawn.Location)
	{
		m_Hostage = hostage;		
	}	
	return;
}

//============================================================================
// HearNoise - 
//============================================================================
event HearNoise(float Loudness, Actor NoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
{
	local R6Hostage hostage;
	local R6Pawn pPawn;

	// End:0x4A
	if((m_pawn.m_bHearNothing || (m_pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker.Instigator).m_bIsPlayer)))
	{
		return;
	}
	ReconThreatCheck(NoiseMaker, eType);
	// End:0xF3
	if((m_bHearInvestigate && (int(eType) == int(1))))
	{
		hostage = R6Hostage(NoiseMaker.Instigator);
		// End:0xA9
		if((hostage != none))
		{
			// End:0xA9
			if(IsAssigned(hostage))
			{
				return;
			}
		}
		// End:0xD2
		if((!m_bAlreadyHeardSound))
		{
			m_bAlreadyHeardSound = true;
			m_VoicesManager.PlayTerroristVoices(m_pawn, 13);
		}
		GotoPointAndSearch(NoiseMaker.Location, 4, true, 30.0000000, 2);		
	}
	else
	{
		// End:0x178
		if((m_bHearThreat && (int(eType) == int(2))))
		{
			// Capped at 80 (not 100) so there is always at least a 20% chance of failing to locate the shooter
			// End:0x123
			if((m_iChanceToDetectShooter < 80))
			{
				(m_iChanceToDetectShooter += 20);
			}
			// End:0x14B
			if(((Rand(100) + 1) < m_iChanceToDetectShooter))
			{
				EngageBySight(NoiseMaker.Instigator);				
			}
			else
			{
				// End:0x175
				if((!IsInState('EngageByThreat')))
				{
					GotoStateEngageByThreat(NoiseMaker.Instigator.Location);
				}
			}			
		}
		else
		{
			// End:0x268
			// 16000 UU ~= 88 degrees; only react to grenades roughly within the forward hemisphere
			if((m_bHearGrenade && (int(eType) == int(3))))
			{
				// End:0x265
				if(((ShortestAngle2D(Rotator((NoiseMaker.Location - Pawn.Location)).Yaw, Pawn.Rotation.Yaw) < 16000) || (ShortestAngle2D(Rotator((NoiseMaker.Instigator.Location - Pawn.Location)).Yaw, Pawn.Rotation.Yaw) < 16000)))
				{
					// End:0x251
					if((!m_bHeardGrenade))
					{
						m_VoicesManager.PlayTerroristVoices(m_pawn, 5);
						m_bHeardGrenade = true;
					}
					ReactToGrenade(NoiseMaker.Location);
				}				
			}
			else
			{
				// End:0x2F5
				if((m_bHearInvestigate && (int(eType) == int(4))))
				{
					pPawn = R6Pawn(NoiseMaker.Instigator);
					// End:0x2ED
					if(((pPawn != none) && (!pPawn.m_bTerroSawMeDead)))
					{
						pPawn.m_bTerroSawMeDead = true;
						GotoPointAndSearch(NoiseMaker.Location, 4, true, 30.0000000);						
					}
					else
					{
						ChangeDefCon(2);
					}
				}
			}
		}
	}
	return;
}

//============================================================================
// EnemyNotVisible - 
//============================================================================
event EnemyNotVisible()
{
	local Vector vDir, vTest;

	switch(m_eStateForEvent)
	{
		// End:0x0F
		case 0:
			// End:0x1EA
			break;
		// End:0x47
		case 1:
			// End:0x44
			// Wait 2 seconds before giving up on the enemy position — brief occlusion shouldn't break attack
			if((((Level.TimeSeconds - LastSeenTime) > float(2)) && CanSafelyChangeState()))
			{
				GotoState('WaitForEnemy');
			}
			// End:0x1EA
			break;
		// End:0x66
		case 3:
			FocalPoint = LastSeenPos;
			GotoState('FindHostage', 'Pursues');
			// End:0x1EA
			break;
		// End:0x1E0
		case 2:
			// End:0x7D
			if((int(m_eAttackMode) == int(4)))
			{
				return;
			}
			FocalPoint = LastSeenPos;
			Focus = none;
			// End:0x1AA
			// SprayFireNoStop (3): advance on last-seen position while firing
			if(((int(m_eAttackMode) == int(3)) && m_pawn.m_bAllowLeave))
			{
				m_vMovingDestination = LastSeenPos;
				// End:0x1A8
				if((VSize((Pawn.Location - m_vMovingDestination)) > (Pawn.CollisionRadius * float(2))))
				{
					// End:0x108
					if(pointReachable(m_vMovingDestination))
					{
						GotoState('Attack', 'SprayFireMove');						
					}
					else
					{
						vDir = Normal((m_vMovingDestination - m_pawn.Location));
						// Perpendicular offset 200 UU (~4m) to try to find a side path around the obstruction
						vTest = (Cross(vDir, vect(0.0000000, 0.0000000, 1.0000000)) * float(200));
						// End:0x178
						if(pointReachable((m_vMovingDestination + vTest)))
						{
							m_vMovingDestination = (m_vMovingDestination + vTest);
							GotoState('Attack', 'SprayFireMove');							
						}
						else
						{
							// End:0x1A8
							if(pointReachable((m_vMovingDestination - vTest)))
							{
								m_vMovingDestination = (m_vMovingDestination - vTest);
								GotoState('Attack', 'SprayFireMove');
							}
						}
					}
				}
				return;
			}
			// End:0x1D2
			if((int(m_pawn.m_ePersonality) == int(5)))
			{
				GotoState('Sniping', 'LostTrackOfEnemy');				
			}
			else
			{
				GotoStateLostSight(LastSeenPos);
			}
			// End:0x1EA
			break;
		// End:0xFFFF
		default:
			Disable('EnemyNotVisible');
			break;
	}
	return;
}

//============================================================================
// state BumpBackUp - set the pawn engagement status at beginning of state
//============================================================================
function GotoBumpBackUpState(name returnState)
{
	// End:0x23
	if(((!m_pawn.m_bIsKneeling) && (!CanSafelyChangeState())))
	{
		return;
	}
	super.GotoBumpBackUpState(returnState);
	return;
}

//============================================================================
// SetGunDirection - 
//============================================================================
function SetGunDirection(Actor aTarget)
{
	local Rotator rDirection;
	local Vector vDirection;
	local Coords cTarget;
	local Vector vTarget;

	// End:0xB4
	if((aTarget != none))
	{
		// End:0x28
		if((aTarget == Enemy))
		{
			vTarget = LastSeenPos;			
		}
		else
		{
			cTarget = aTarget.GetBoneCoords('R6 Spine');
			vTarget = cTarget.Origin;
		}
		vDirection = (vTarget - m_pawn.GetFiringStartPoint());
		rDirection = Rotator(vDirection);
		m_pawn.m_wWantedAimingPitch = byte((rDirection.Pitch / 256));
		m_pawn.m_rFiringRotation = rDirection;		
	}
	else
	{
		m_pawn.m_wWantedAimingPitch = 0;
		m_pawn.m_rFiringRotation = m_pawn.Rotation;
	}
	return;
}

//============================================================================
// IsAnEnemy - 
//============================================================================
function bool IsAnEnemy(R6Pawn Other)
{
	// End:0x28
	if((m_pawn.m_bDontSeePlayer && Other.m_bIsPlayer))
	{
		return false;
	}
	// End:0x55
	if((m_pawn.IsEnemy(Other) && Other.IsAlive()))
	{
		return true;
	}
	return false;
	return;
}

//============================================================================
// IsAnHostage - 
//============================================================================
function bool IsAnHostage(R6Pawn Other)
{
	// End:0x2D
	if((m_pawn.IsNeutral(Other) && Other.IsAlive()))
	{
		return true;
	}
	return false;
	return;
}

//============================================================================
// BOOL IsAssigned - 
//============================================================================
function bool IsAssigned(R6Hostage hostage)
{
	return m_Manager.IsHostageAssigned(hostage);
	return;
}

//============================================================================
// BOOL IsMyHostage - 
//============================================================================
function bool IsMyHostage(R6Hostage hostage)
{
	local bool bResult;
	local R6DZonePoint zonePoint;
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;

	zonePoint = R6DZonePoint(m_pawn.m_DZone);
	// End:0x7B
	if((zonePoint != none))
	{
		HitActor = m_pawn.R6Trace(vHitLocation, vHitNormal, hostage.Location, zonePoint.Location, (1 | 2));
		// End:0x78
		if((HitActor == hostage))
		{
			bResult = true;
		}		
	}
	else
	{
		bResult = (m_pawn.m_DZone.IsPointInZone(m_pawn.Location) && m_pawn.m_DZone.IsPointInZone(hostage.Location));
	}
	return bResult;
	return;
}

//============================================================================
// StartFiring - 
//============================================================================
function StartFiring()
{
	// End:0x80
	if(((!Pawn.m_bDroppedWeapon) && (Pawn.EngineWeapon != none)))
	{
		// End:0x49
		if((!Pawn.EngineWeapon.HasAmmo()))
		{
			return;
		}
		// End:0x5F
		if((Enemy != none))
		{
			Target = Enemy;
		}
		bFire = 1;
		Pawn.EngineWeapon.GotoState('NormalFire');
	}
	m_pawn.PlayWeaponAnimation();
	return;
}

//============================================================================
// StopFiring - 
//============================================================================
function StopFiring()
{
	bFire = 0;
	m_pawn.PlayWeaponAnimation();
	return;
}

//============================================================================
// ReloadWeapon - 
//============================================================================
function AIReloadWeapon()
{
	Pawn.EngineWeapon.GotoState('None');
	m_pawn.m_wWantedAimingPitch = 0;
	// End:0x67
	if((int(Pawn.EngineWeapon.m_eWeaponType) == int(5)))
	{
		Pawn.EngineWeapon.FullCurrentClip();		
	}
	else
	{
		m_pawn.m_ePlayerIsUsingHands = 0;
		m_pawn.ServerSwitchReloadingWeapon(true);
		m_pawn.ReloadWeapon();
	}
	m_pawn.PlayWeaponAnimation();
	return;
}

//============================================================================
// FLOAT GetMaxCoverDistance - Max distance that the pawn is willing to go
//                             to find a cover
//============================================================================
function float GetMaxCoverDistance()
{
	switch(m_pawn.m_ePersonality)
	{
		// End:0x1E
		case 0:
			return 2000.0000000;
			// End:0x67
			break;
		// End:0x2C
		case 1:
			return 1600.0000000;
			// End:0x67
			break;
		// End:0x3A
		case 2:
			return 1200.0000000;
			// End:0x67
			break;
		// End:0x48
		case 3:
			return 800.0000000;
			// End:0x67
			break;
		// End:0x56
		case 4:
			return 400.0000000;
			// End:0x67
			break;
		// End:0x64
		case 5:
			return 0.0000000;
			// End:0x67
			break;
		// End:0xFFFF
		default:
			break;
	}
	return 0.0000000;
	return;
}

//============================================================================
// BOOL SetLowestSnipingStance - 
//    - If aTarget != none, return true if we see the pawn from a position
//    - I have assumed that from or animation the offset on Z from the ground
//      for the start firing point is prone 15, crouch 70 and standing 135
//============================================================================
function bool SetLowestSnipingStance(optional Actor aTarget)
{
	local Vector vStart, vTarget;

	vStart = m_pawn.Location;
	// Prone eye height: floor + 15 UU above collision bottom
	vStart.Z = ((m_pawn.Location.Z - m_pawn.CollisionHeight) + float(15));
	// End:0x6A
	if((aTarget != none))
	{
		vTarget = aTarget.Location;		
	}
	else
	{
		vTarget = (vStart + (Vector(m_pawn.Rotation) * float(500)));
	}
	// End:0xC4
	if(FastTrace(vStart, vTarget))
	{
		m_pawn.m_bWantsToProne = true;
		m_pawn.bWantsToCrouch = false;
		return true;
	}
	// Crouch eye height: floor + 70 UU
	vStart.Z = ((m_pawn.Location.Z - m_pawn.CollisionHeight) + float(70));
	// End:0x11A
	if((aTarget != none))
	{
		vTarget = aTarget.Location;		
	}
	else
	{
		vTarget = (vStart + (Vector(m_pawn.Rotation) * float(500)));
	}
	// End:0x174
	if(FastTrace(vStart, vTarget))
	{
		m_pawn.m_bWantsToProne = false;
		m_pawn.bWantsToCrouch = true;
		return true;
	}
	// End:0x1FD
	if((aTarget != none))
	{
		// Standing eye height: floor + 135 UU; return false if even standing has no line of sight
		vStart.Z = ((m_pawn.Location.Z - m_pawn.CollisionHeight) + float(135));
		vTarget = aTarget.Location;
		// End:0x1FB
		if(FastTrace(vStart, vTarget))
		{
			m_pawn.m_bWantsToProne = false;
			m_pawn.bWantsToCrouch = false;
			return true;
		}
		return false;
	}
	m_pawn.m_bWantsToProne = false;
	m_pawn.bWantsToCrouch = false;
	return true;
	return;
}

//============================================================================
// ReactToGrenade - 
//============================================================================
function ReactToGrenade(Vector vGrenadeLocation)
{
	local Vector vDestination;
	local float fDistance, fTemp;
	local int i;
	local NavigationPoint aDest;

	ChangeDefCon(1);
	// Only flee if grenade is within 600 UU (~12m); further away it's safe to ignore
	// End:0x2D
	if((VSize((m_pawn.Location - vGrenadeLocation)) > float(600)))
	{
		return;
	}
	fDistance = RandRange(400.0000000, 1000.0000000);
	i = 0;
	J0x4A:

	// Clear recently-visited node history so the terrorist picks a fresh escape route
	// End:0x6D [Loop If]
	if((i < 10))
	{
		m_aLastNode[i] = none;
		(i++);
		// [Loop Continue]
		goto J0x4A;
	}
	aDest = GetNextRandomNode();
	i = 0;
	J0x7D:

	// Try up to 10 times to find a node far enough from the grenade (400-1000 UU random threshold)
	// End:0xBF [Loop If]
	if(((VSize((aDest.Location - vGrenadeLocation)) < fDistance) && (i < 10)))
	{
		(i++);
		aDest = GetNextRandomNode();
		// [Loop Continue]
		goto J0x7D;
	}
	SetReactionStatus(4, 0);
	m_aMovingToDestination = aDest;
	// End:0xED
	if((!IsInState('TransientStateCode')))
	{
		GotoState('TransientStateCode', 'RunFromGrenade');
	}
	return;
}

function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType)
{
	switch(eType)
	{
		// End:0x25
		case 2:
			m_VoicesManager.PlayTerroristVoices(m_pawn, 7);
			// End:0x46
			break;
		// End:0x43
		case 1:
			m_VoicesManager.PlayTerroristVoices(m_pawn, 6);
			// End:0x46
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//============================================================================
// AIAffectedByGrenade - 
//============================================================================
function AIAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
{
	ChangeDefCon(2);
	m_pawn.m_vGrenadeLocation = aGrenade.Location;
	// End:0x77
	if((int(eType) == int(2)))
	{
		// End:0x74
		if(CanSafelyChangeState())
		{
			m_pawn.bWantsToCrouch = false;
			m_pawn.SetNextPendingAction(1);
			ReactToGrenade(m_pawn.m_vGrenadeLocation);
		}		
	}
	else
	{
		// End:0xD3
		if(((int(eType) == int(3)) || (int(eType) == int(4))))
		{
			// End:0xB3
			if(((!m_bCantInterruptIO) && (!CanSafelyChangeState())))
			{
				return;
			}
			m_pawn.SetNextPendingAction(3);
			GotoState('TransientStateCode', 'RecoverFromFlash');			
		}
		else
		{
			// End:0xF0
			if(CanSafelyChangeState())
			{
				ReactToGrenade(m_pawn.m_vGrenadeLocation);
			}
		}
	}
	return;
}

//============================================================================
//  #####  #####  #####    ###    ####   #####   ###   ####    
//  ##     ##     ##      ##  #   ## ##  ##     ##  #  ## ##   
//  #####  ####   ####    #####   ##  #  ####   #####  ##  #   
//     ##  ##     ##      ##  #   ## ##  ##     ##  #  ## ##   
//  #####  #####  #####   ##  #   ####   #####  ##  #  ####    
//============================================================================
function GotoSeeADead(Vector vDeadLocation)
{
	m_vThreatLocation = vDeadLocation;
	GotoState('SeeADead');
	return;
}

//============================================================================
//  ####   ###   ####  #   #  #####    #####  #####   ###   ####   ####  ##  #   
//  ##  # ##  #   ##   ##  #   ##      ##     ##     ##  #  #   # ##     ##  #   
//  ####  ##  #   ##   # # #   ##      #####  ####   #####  ####  ##     #####   
//  ##    ##  #   ##   #  ##   ##         ##  ##     ##  #  ## #  ##     ##  #   
//  ##     ###   ####  #   #   ##      #####  #####  ##  #  ##  #  ####  ##  #   
//============================================================================
event GotoPointAndSearch(Vector vDestination, R6Pawn.eMovementPace ePace, bool bCallBackup, optional float fSearchTime, optional R6Terrorist.EDefCon eNewDefCon)
{
	// End:0x0D
	if((!CanSafelyChangeState()))
	{
		return;
	}
	// End:0x29
	if(bCallBackup)
	{
		// End:0x29
		if(MakeBackupList())
		{
			CallBackupForInvestigation(vDestination, ePace);
		}
	}
	// End:0x47
	if((int(eNewDefCon) != int(0)))
	{
		ChangeDefCon(eNewDefCon);		
	}
	else
	{
		ChangeDefCon(1);
	}
	// End:0x67
	if((fSearchTime == float(0)))
	{
		fSearchTime = 30.0000000;
	}
	GotoStateEngageBySound(vDestination, ePace, fSearchTime);
	return;
}

//============================================================================
// GotoPointAndAttack - 
//============================================================================
event GotoPointToAttack(Vector vDestination, Actor PTarget)
{
	// End:0x0D
	if((!CanSafelyChangeState()))
	{
		return;
	}
	// End:0x47
	if((m_InteractionObject != none))
	{
		m_bCalledForBackup = true;
		m_vThreatLocation = vDestination;
		Target = PTarget;
		m_InteractionObject.StopInteractionWithEndingActions();
		return;
	}
	// End:0x52
	if(CheckForInteraction())
	{
		return;
	}
	m_pawn.m_bPawnSpecificAnimInProgress = false;
	ChangeDefCon(1);
	m_vThreatLocation = vDestination;
	Target = PTarget;
	SetActionSpot(none);
	m_StateAfterInteraction = 'MovingToAttack';
	GotoState('MovingToAttack');
	return;
}

//============================================================================
// GotoStateLostSight - 
//============================================================================
function GotoStateLostSight(Vector vLastSeen)
{
	m_vThreatLocation = vLastSeen;
	GotoState('LostSight');
	return;
}

//============================================================================
//  ##### #   #   ####   ###    ####  #####    #####  ####   ####  ##  # #####   
//  ##    ##  #  ##     ##  #  ##     ##       ##      ##   ##     ##  #  ##     
//  ####  # # #  ## ##  #####  ## ##  ####     #####   ##   ## ##  #####  ##     
//  ##    #  ##  ##  #  ##  #  ##  #  ##          ##   ##   ##  #  ##  #  ##     
//  ##### #   #   ####  ##  #   ####  #####    #####  ####   ####  ##  #  ##     
//============================================================================
function EngageBySight(Pawn aPawn)
{
	SetEnemy(aPawn);
	Target = aPawn;
	GotoState('PrecombatAction');
	return;
}

function R6TerroristAI.EEngageReaction GetEngageReaction(Pawn pEnemy, int iNbTerro, int iNbRainbow)
{
	local bool bOutnumbered;

	// End:0x16
	// Designer has overridden random behaviour for this terrorist; return it directly
	if((int(m_eEngageReaction) != int(0)))
	{
		return m_eEngageReaction;
	}
	// End:0x41
	if((Pawn.m_bDroppedWeapon || (Pawn.EngineWeapon == none)))
	{
		return 4;
	}
	// End:0x5D
	if((int(m_pawn.m_ePersonality) == int(5)))
	{
		return 1;
	}
	m_iRandomNumber = (Rand(100) + 1);
	// Personality biases the roll: aggressive/bold (-40/-20) favour fighting; cautious/timid (+20/+40) favour fleeing
	switch(m_pawn.m_ePersonality)
	{
		// End:0x8B
		case 0:
			(m_iRandomNumber -= 40);
			// End:0xC9
			break;
		// End:0x9C
		case 1:
			(m_iRandomNumber -= 20);
			// End:0xC9
			break;
		// End:0xA4
		case 2:
			// End:0xC9
			break;
		// End:0xB5
		case 3:
			(m_iRandomNumber += 20);
			// End:0xC9
			break;
		// End:0xC6
		case 4:
			(m_iRandomNumber += 40);
			// End:0xC9
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0xE7
	// Outnumbered: (terrorists_in_group + 1) * 2 < rainbows_in_combat (+1 because self is not counted in group total)
	if((((m_iTerroristInGroup + 1) * 2) < m_iRainbowInCombat))
	{
		bOutnumbered = true;
	}
	// End:0x158
	if(bOutnumbered)
	{
		// End:0xFF
		// Outnumbered thresholds: >=81 aimed fire, >=41 spray, >=11 run, else surrender if close (<1000 UU) otherwise run
		if((m_iRandomNumber >= 81))
		{
			return 1;
		}
		// End:0x10E
		if((m_iRandomNumber >= 41))
		{
			return 2;
		}
		// End:0x120
		if((m_iRandomNumber >= 11))
		{
			return 3;			
		}
		else
		{
			// End:0x152
			if((VSize((Pawn.Location - pEnemy.Location)) < float(1000)))
			{
				return 4;				
			}
			else
			{
				return 3;
			}
		}		
	}
	else
	{
		// End:0x167
		// Even/winning thresholds: >=61 aimed fire, >=11 spray, else run
		if((m_iRandomNumber >= 61))
		{
			return 1;
		}
		// End:0x179
		if((m_iRandomNumber >= 11))
		{
			return 2;			
		}
		else
		{
			return 3;
		}
	}
	return 4;
	return;
}

function bool CheckForInteraction()
{
	local Actor aGoal;

	// End:0x82
	// A triggered interactive object (door, switch) takes priority — must complete it before engaging
	if((m_TriggeredIO != none))
	{
		m_bCantInterruptIO = true;
		SetReactionStatus(5, 0);
		// End:0x48
		if((m_TriggeredIO.m_Anchor != none))
		{
			aGoal = m_TriggeredIO.m_Anchor;			
		}
		else
		{
			aGoal = m_TriggeredIO;
		}
		GotoStateMovingTo("InteractionObject", 5, false, aGoal,, 'PrecombatAction', 'InteractiveObject', true);
		return true;
	}
	// End:0xAC
	if((Pawn.m_bDroppedWeapon || (m_pawn.EngineWeapon == none)))
	{
		return false;
	}
	// End:0xE0
	if((!UseRandomHostage()))
	{
		m_Hostage = m_pawn.m_DZone.GetClosestHostage(m_pawn.Location);
	}
	// End:0x11D
	if(((m_Hostage != none) && (!m_Hostage.m_bExtracted)))
	{
		// End:0x11D
		// Random chance to execute the hostage instead of fighting the enemy
		if((Rand(100) < GetKillingHostageChance()))
		{
			GotoStateAttackHostage(m_Hostage);
			return true;
		}
	}
	return false;
	return;
}

//============================================================================
// PlayAttackVoices - 
//============================================================================
function PlayAttackVoices()
{
	local int iAngle;

	// End:0x7B
	// 13000 UU ~= 71 degrees: enemy is facing roughly away; shout to alert them to our presence
	if((ShortestAngle2D(Enemy.Rotation.Yaw, m_pawn.Rotation.Yaw) > 13000))
	{
		// End:0x65
		if((int(m_pawn.m_eDefCon) >= int(3)))
		{
			m_VoicesManager.PlayTerroristVoices(m_pawn, 10);			
		}
		else
		{
			m_VoicesManager.PlayTerroristVoices(m_pawn, 11);
		}
	}
	return;
}

//------------------------------------------------------------------
// PawnDied: called when the pawn is declared dead 
//------------------------------------------------------------------
function PawnDied()
{
	// End:0x33
	if(((m_path != none) && (!Level.m_bIsResettingLevel)))
	{
		m_path.InformTerroTeam(5, self);
	}
	super.PawnDied();
	return;
}

//============================================================================
// AIPlayCallBackup - 
//   - Return true if we must wait for the end of the animation
//============================================================================
function bool AIPlayCallBackup(Actor pEnemy)
{
	local int iShootingChance, iAnimID;

	// End:0x37
	// Within 400 UU (~8m) the terrorist always fires while calling backup regardless of difficulty
	if((VSize((Pawn.Location - pEnemy.Location)) < float(400)))
	{
		iShootingChance = 100;		
	}
	else
	{
		switch(m_pawn.m_iDiffLevel)
		{
			// End:0x56
			// Easy = 50% shoot chance, medium = 70%, hard = 90%
			case 1:
				iShootingChance = 50;
				// End:0x79
				break;
			// End:0x66
			case 2:
				iShootingChance = 70;
				// End:0x79
				break;
			// End:0x76
			case 3:
				iShootingChance = 90;
				// End:0x79
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	// End:0x91
	// iAnimID 0 = shoot-and-call animation (both actions combined); 1 = stop-and-call-only animation
	if((Rand(100) < iShootingChance))
	{
		iAnimID = 0;		
	}
	else
	{
		iAnimID = 1;
	}
	m_pawn.SetNextPendingAction(34, iAnimID);
	m_VoicesManager.PlayTerroristVoices(m_pawn, 8);
	// End:0xD1
	if((iAnimID == 0))
	{
		return false;
	}
	return true;
	return;
}

//============================================================================
// DispatchOrder - 
//============================================================================
function DispatchOrder(int iOrder, R6Pawn pSource)
{
	switch(iOrder)
	{
		// End:0x25
		case int(m_pawn.1):
			SecureTerrorist(pSource);
			// End:0x2C
			break;
		// End:0xFFFF
		default:
			assert(false);
			break;
	}
	return;
}

//============================================================================
//   ####   ####    #####   #   #    ###    ####    #####   
//  ##      #   #   ##      ##  #   ##  #   ## ##   ##      
//  ## ##   ####    ####    # # #   #####   ##  #   ####    
//  ##  #   ## #    ##      #  ##   ##  #   ## ##   ##      
//   ####   ##  #   #####   #   #   ##  #   ####    #####   
//============================================================================
function GotoStateThrowingGrenade(name nNextState, name nNextLabel)
{
	NextState = nNextState;
	NextLabel = nNextLabel;
	GotoState('ThrowingGrenade');
	return;
}

//============================================================================
//  #   #    ###      #####   ##  #   ####    #####    ###    #####   
//  ##  #   ##  #      ##     ##  #   #   #   ##      ##  #    ##     
//  # # #   ##  #      ##     #####   ####    ####    #####    ##     
//  #  ##   ##  #      ##     ##  #   ## #    ##      ##  #    ##     
//  #   #    ###       ##     ##  #   ##  #   #####   ##  #    ##     
//============================================================================
function GotoStateNoThreat()
{
	// End:0x1C
	if(m_pawn.IsAlive())
	{
		GotoState('NoThreat');		
	}
	else
	{
		GotoState('Dead');
	}
	return;
}

//============================================================================
// GotoStateMoveToDestination - 
//============================================================================
function GotoStateMovingTo(string sDebugString, R6Pawn.eMovementPace ePace, bool bCanFail, optional Actor aMoveTarget, optional Vector vDestination, optional name stateAfter, optional name labelAfter, optional bool bDontCheckLeave, optional bool bPreciseMove)
{
	local Vector vHitNormal;

	// End:0x75
	if(((aMoveTarget == none) && (vDestination == vect(0.0000000, 0.0000000, 0.0000000))))
	{
		logX("Call to GotoStateMovingTo with no aMoveTarget or vDestination");
		GotoState(stateAfter, labelAfter);
	}
	CheckPaceForInjury(ePace);
	m_aMovingToDestination = aMoveTarget;
	// End:0xAD
	if((m_aMovingToDestination != none))
	{
		m_vMovingDestination = m_aMovingToDestination.Location;		
	}
	else
	{
		// Ground-snap: trace 200 UU down from destination, then raise 80 UU to place correctly on floor
		// End:0xEC
		if((Trace(m_vMovingDestination, vHitNormal, (vDestination - vect(0.0000000, 0.0000000, 200.0000000)), vDestination) != none))
		{
			(m_vMovingDestination.Z += float(80));			
		}
		else
		{
			m_vMovingDestination = vDestination;
		}
	}
	m_bCanFailMovingTo = bCanFail;
	m_pawn.m_eMovementPace = ePace;
	m_stateAfterMovingTo = stateAfter;
	m_labelAfterMovingTo = labelAfter;
	m_bPreciseMove = bPreciseMove;
	// End:0x207
	// If the pawn is not allowed to leave its zone and the destination is outside, clamp to zone boundary
	if((((!bDontCheckLeave) && (!m_pawn.m_bAllowLeave)) && (!m_pawn.m_DZone.IsPointInZone(m_vMovingDestination))))
	{
		// End:0x1B9
		if((R6DZoneRandomPoints(m_pawn.m_DZone) == none))
		{
			m_vMovingDestination = m_pawn.m_DZone.FindClosestPointTo(m_vMovingDestination);			
		}
		else
		{
			// End:0x1E7
			if(R6DZoneRandomPoints(m_pawn.m_DZone).m_bUseAllowLeave)
			{
				m_vMovingDestination = m_vSpawningPosition;				
			}
			else
			{
				m_vMovingDestination = m_pawn.m_DZone.FindClosestPointTo(m_vMovingDestination);
			}
		}
	}
	GotoState('MovingTo');
	m_sDebugString = sDebugString;
	return;
}

//============================================================================
//  #####   ##  #   ####    #####    ###    #####   
//   ##     ##  #   #   #   ##      ##  #    ##     
//   ##     #####   ####    ####    #####    ##     
//   ##     ##  #   ## #    ##      ##  #    ##     
//   ##     ##  #   ##  #   #####   ##  #    ##     
//============================================================================
event GotoStateEngageByThreat(Vector vThreathLocation)
{
	// End:0x0D
	if((!CanSafelyChangeState()))
	{
		return;
	}
	m_vThreatLocation = vThreathLocation;
	// Search timer stored as absolute game time so comparisons against Level.TimeSeconds work directly
	m_fSearchTime = (Level.TimeSeconds + float(20));
	GotoState('EngageByThreat');
	return;
}

//============================================================================
//  #####    ###    ##  #   #   #   ####    
//  ##      ##  #   ##  #   ##  #   ## ##   
//  #####   ##  #   ##  #   # # #   ##  #   
//     ##   ##  #   ##  #   #  ##   ## ##   
//  #####    ###    #####   #   #   ####    
//============================================================================
function GotoStateEngageBySound(Vector vInvestigateDestination, R6Pawn.eMovementPace ePace, float fSearchTime)
{
	m_vThreatLocation = vInvestigateDestination;
	m_pawn.m_eMovementPace = ePace;
	// Stored as absolute time (Level.TimeSeconds + duration) for direct comparison in state loops
	m_fSearchTime = (Level.TimeSeconds + fSearchTime);
	GotoState('EngageBySound');
	return;
}

//============================================================================
//  #####   ##  #   ####    ####    #####   #   #   ####    #####   ####    
//  ##      ##  #   #   #   #   #   ##      ##  #   ## ##   ##      #   #   
//  #####   ##  #   ####    ####    ####    # # #   ##  #   ####    ####    
//     ##   ##  #   ## #    ## #    ##      #  ##   ## ##   ##      ## #    
//  #####   #####   ##  #   ##  #   #####   #   #   ####    #####   ##  #   
//============================================================================
function SecureTerrorist(R6Pawn pOther)
{
	ChangeOrientationTo(Rotator((Pawn.Location - pOther.Location)));
	SetEnemy(pOther);
	GotoState('Surrender', 'Secure');
	return;
}

//============================================================================
//   ###    #####   #####    ###     ####   ##  #   
//  ##  #    ##      ##     ##  #   ##      ## #    
//  #####    ##      ##     #####   ##      ###     
//  ##  #    ##      ##     ##  #   ##      ## #    
//  ##  #    ##      ##     ##  #    ####   ##  #   
//============================================================================
function GotoStateAimedFire()
{
	m_eAttackMode = 1;
	m_pawn.m_bSprayFire = false;
	GotoState('Attack');
	return;
}

function GotoStateSprayFire()
{
	m_pawn.m_bSprayFire = true;
	// End:0x38
	if(((int(m_eAttackMode) == int(0)) && (Rand(2) == 0)))
	{
		m_eAttackMode = 3;		
	}
	else
	{
		m_eAttackMode = 2;
	}
	GotoState('Attack');
	return;
}

function GotoStateAttackHostage(R6Pawn hostage)
{
	SetEnemy(hostage);
	m_eAttackMode = 1;
	m_pawn.m_bSprayFire = false;
	GotoState('AttackHostage');
	return;
}

//============================================================================
// HostageSurrender - Called from an hostage AI when that AI surrender
//============================================================================
function HostageSurrender(R6HostageAI hostageAI)
{
	local Vector vDestination;

	// End:0x0B
	if(UseRandomHostage())
	{
		return;
	}
	m_HostageAI = hostageAI;
	m_Hostage = hostageAI.m_pawn;
	m_Manager.AssignHostageTo(m_Hostage, self);
	m_ZoneToEscort = m_Manager.FindNearestZoneForHostage(m_pawn);
	// End:0x75
	if((m_ZoneToEscort == none))
	{
		m_ZoneToEscort = m_pawn.m_DZone;
	}
	vDestination = m_ZoneToEscort.FindRandomPointInArea();
	m_HostageAI.SetStateEscorted(m_pawn, vDestination, true);
	GotoStateFollowPawn(R6Pawn(m_HostageAI.Pawn), 0, 100.0000000);
	return;
}

//============================================================================
// EscortIsOver - Called from the hostage AI when the escort is over
//============================================================================
function EscortIsOver(R6HostageAI hostageAI, bool bSuccess)
{
	// End:0x2B
	if(bSuccess)
	{
		m_Manager.AssignHostageToZone(m_Hostage, m_ZoneToEscort);
		GotoStateNoThreat();		
	}
	else
	{
		m_Manager.RemoveHostageAssignment(m_Hostage);
		GotoStateEngageBySound(m_Hostage.Location, 5, 10.0000000);
	}
	return;
}

//============================================================================
// GotoStateFindHostage - 
//============================================================================
function GotoStateFindHostage(R6Hostage hostage)
{
	m_Hostage = hostage;
	m_HostageAI = R6HostageAI(hostage.Controller);
	m_Manager.AssignHostageTo(hostage, self);
	GotoState('FindHostage');
	return;
}

//============================================================================
//  #####   ###   ##     ##      ###   #   #   
//  ##     ##  #  ##     ##     ##  #  #   #   
//  ####   ##  #  ##     ##     ##  #  # # #   
//  ##     ##  #  ##     ##     ##  #  #####   
//  ##      ###   #####  #####   ###    # #    
//
// if iYaw == 0, always approach the following pawn in straight line
//        in front : 32768
//        left : 16384 + 49151 : right
//            behind : 0
//============================================================================
function GotoStateFollowPawn(R6Pawn followedpawn, R6TerroristAI.EFollowMode eMode, float fDist, optional int iYaw)
{
	m_pawnToFollow = followedpawn;
	m_eFollowMode = eMode;
	m_fFollowDist = fDist;
	m_iFollowYaw = iYaw;
	GotoState('FollowPawn');
	return;
}

// Random decision function
function float GetWaitingTime()
{
	local float fTemp;

	switch(m_pawn.m_eDefCon)
	{
		// End:0x23
		case 1:
			fTemp = 1.0000000;
			// End:0x72
			break;
		// End:0x36
		case 2:
			fTemp = 2.0000000;
			// End:0x72
			break;
		// End:0x49
		case 3:
			fTemp = 3.0000000;
			// End:0x72
			break;
		// End:0x5C
		case 4:
			fTemp = 4.0000000;
			// End:0x72
			break;
		// End:0x6F
		case 5:
			fTemp = 5.0000000;
			// End:0x72
			break;
		// End:0xFFFF
		default:
			break;
	}
	return RandRange(fTemp, (fTemp + fTemp));
	return;
}

function float GetFacingTime()
{
	local int fTemp;

	switch(m_pawn.m_eDefCon)
	{
		// End:0x1F
		case 1:
			fTemp = 1;
			// End:0x62
			break;
		// End:0x2F
		case 2:
			fTemp = 2;
			// End:0x62
			break;
		// End:0x3F
		case 3:
			fTemp = 3;
			// End:0x62
			break;
		// End:0x4F
		case 4:
			fTemp = 4;
			// End:0x62
			break;
		// End:0x5F
		case 5:
			fTemp = 5;
			// End:0x62
			break;
		// End:0xFFFF
		default:
			break;
	}
	return RandRange(float(fTemp), float((fTemp + fTemp)));
	return;
}

function bool IsGoingBack()
{
	local int ITemp;

	switch(m_pawn.m_eDefCon)
	{
		// End:0x20
		case 1:
			ITemp = 30;
			// End:0x62
			break;
		// End:0x30
		case 2:
			ITemp = 25;
			// End:0x62
			break;
		// End:0x40
		case 3:
			ITemp = 20;
			// End:0x62
			break;
		// End:0x50
		case 4:
			ITemp = 10;
			// End:0x62
			break;
		// End:0x5F
		case 5:
			ITemp = 0;
			// End:0x62
			break;
		// End:0xFFFF
		default:
			break;
	}
	return ((Rand(100) + 1) < ITemp);
	return;
}

function Rotator ChooseRandomDirection(int iLookBackChance)
{
	local int ITemp;

	switch(m_pawn.m_eDefCon)
	{
		// End:0x20
		case 1:
			ITemp = 25;
			// End:0x63
			break;
		// End:0x30
		case 2:
			ITemp = 20;
			// End:0x63
			break;
		// End:0x40
		case 3:
			ITemp = 15;
			// End:0x63
			break;
		// End:0x50
		case 4:
			ITemp = 10;
			// End:0x63
			break;
		// End:0x60
		case 5:
			ITemp = 5;
			// End:0x63
			break;
		// End:0xFFFF
		default:
			break;
	}
	return super.ChooseRandomDirection(ITemp);
	return;
}

// Sent messages
function ReachedTheNode()
{
	m_bWaiting = true;
	m_path.InformTerroTeam(1, self);
	return;
}

function FinishedWaiting()
{
	m_bWaiting = true;
	m_path.InformTerroTeam(2, self);
	return;
}

// Callback
function GotoNode(Vector VPosition)
{
	m_bWaiting = false;
	GotoStateMovingTo("GotoNode", 4, true,, VPosition, 'PatrolPath', 'ReachedNode', true);
	return;
}

function FollowLeader(R6Terrorist Leader, Vector VOffset)
{
	m_bWaiting = false;
	GotoStateFollowPawn(Leader, 1, VSize(VOffset), Rotator(VOffset).Yaw);
	return;
}

function WaitAtNode(float fWaitingTime, float fFacingTime, Rotator rOrientation)
{
	m_bWaiting = false;
	m_fWaitingTime = fWaitingTime;
	m_fFacingTime = fFacingTime;
	m_rStandRotation = rOrientation;
	GotoState('PatrolPath', 'WaitingAtNode');
	return;
}

//===================================================================================================
//   ####              #                                       #      ##                            
//    ##              ##                                      ##                                    
//    ##    #####    #####   ####   ## ###   ####    ####    #####   ###     ####   #####    #####  
//    ##    ##  ##    ##    ##  ##   ### ##     ##  ##  ##    ##      ##    ##  ##  ##  ##  ##      
//    ##    ##  ##    ##    ######   ##  ##  #####  ##        ##      ##    ##  ##  ##  ##   ####   
//    ##    ##  ##    ## #  ##       ##     ##  ##  ##  ##    ## #    ##    ##  ##  ##  ##      ##  
//   ####   ##  ##     ##    ####   ####     ### ##  ####      ##    ####    ####   ##  ##  #####   
//===================================================================================================
function bool CanInteractWithObjects(R6InteractiveObject o)
{
	// End:0x76
	if(((((((m_InteractionObject == none) && (m_pawn != none)) && m_pawn.IsAlive()) && (int(m_eReactionStatus) == int(0))) && (int(m_pawn.m_eDefCon) >= int(3))) && (int(m_pawn.m_eStrategy) != int(3))))
	{
		return true;
	}
	return false;
	return;
}

function PerformAction_StopInteraction()
{
	// End:0x3D
	if(((m_bCalledForBackup || (m_InteractionObject.m_SeePlayerPawn != none)) || (m_InteractionObject.m_HearNoiseNoiseMaker != none)))
	{
		ChangeDefCon(2);
	}
	super.PerformAction_StopInteraction();
	// End:0x78
	if((m_bCalledForBackup && (!m_bCantInterruptIO)))
	{
		m_bCalledForBackup = false;
		m_InteractionObject = none;
		GotoPointToAttack(m_vThreatLocation, Target);
	}
	return;
}

state test
{Begin:

	SetReactionStatus(5, 0);
	m_rStandRotation = m_pawn.Rotation;
	goto 'RandomRotation';
RandomRotation:


	m_rStandRotation.Yaw = (Rand(32767) * 4);
	logX(("Yaw: " $ string(m_rStandRotation.Yaw)));
	ChangeOrientationTo(m_rStandRotation);
	Sleep(2.0000000);
	goto 'RandomRotation';
Sequence:


	Sleep(2.0000000);
	goto 'Sequence';
	stop;			
}

state BumpBackUp
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, m_eStateForEvent);
		super.BeginState();
		return;
	}

	function EndState()
	{
		Focus = none;
		super.EndState();
		return;
	}

	function bool GetReacheablePoint(out Vector vTarget, bool bNoFail)
	{
		local Actor HitActor;
		local Vector vHitLocation, vHitNormal, vExtent;

		// End:0x44
		if(MoveRight())
		{
			vTarget = (Pawn.Location + (float(c_iDistanceBumpBackUp) * Vector((Rotator(m_vBumpedByVelocity) + rot(0, 16384, 0)))));			
		}
		else
		{
			vTarget = (Pawn.Location + (float(c_iDistanceBumpBackUp) * Vector((Rotator(m_vBumpedByVelocity) - rot(0, 16384, 0)))));
		}
		vExtent.X = Pawn.CollisionRadius;
		vExtent.Y = vExtent.Y;
		vExtent.Z = Pawn.CollisionHeight;
		HitActor = R6Trace(vHitLocation, vHitNormal, vTarget, Pawn.Location, (1 | 2), vExtent);
		// End:0x11D
		if((HitActor != none))
		{
			vTarget = (vHitLocation + (float(c_iDistanceBumpBackUp) * Vector(Rotator(m_vBumpedByVelocity))));
		}
		return true;
		return;
	}
	stop;
}

state ApproachLadder
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, m_eStateForEvent);
		super.BeginState();
		return;
	}

	function EndState()
	{
		Focus = none;
		super.EndState();
		return;
	}
	stop;
}

state WaitToClimbLadder
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, m_eStateForEvent);
		super.BeginState();
		return;
	}

	function EndState()
	{
		Focus = none;
		super.EndState();
		return;
	}
	stop;
}

//============================================================================
// TransientStateCode
//      State used when the AI want to execute some latent function
//      but doesn't need a new state
//============================================================================
state TransientStateCode
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, 0);
		return;
	}
RunFromGrenade:

	StopMoving();
	switch(m_pawn.m_iDiffLevel)
	{
		// End:0x25
		case 1:
			Sleep(1.0000000);
			// End:0x40
			break;
		// End:0x35
		case 2:
			Sleep(0.5000000);
			// End:0x40
			break;
		// End:0x3D
		case 3:
			// End:0x40
			break;
		// End:0xFFFF
		default:
			break;
	}
	GotoStateMovingTo("RunFromGrenade", 5, true, m_aMovingToDestination,, 'TransientStateCode', 'AfterRunFromGrenade', true);
AfterRunFromGrenade:


	m_bHeardGrenade = false;
	// End:0x85
	if((Enemy == none))
	{
		Sleep(3.0000000);
	}
	goto 'ResumeAction';
RecoverFromFlash:


	// Disable all perception for 5 seconds to simulate flash-bang disorientation
	Disable('HearNoise');
	Disable('SeePlayer');
	StopMoving();
	Sleep(5.0000000);
	// End:0xB6
	if(m_bCantInterruptIO)
	{
		CheckForInteraction();
	}
ResumeAction:


	// End:0xCB
	if((Enemy != none))
	{
		GotoState('Attack');		
	}
	else
	{
		GotoStateNoThreat();
	}
	stop;		
}

state SeeADead
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}

	function EndState()
	{
		m_pawn.m_wWantedHeadYaw = 0;
		return;
	}
Begin:

	ChangeDefCon(2);
	SetActionSpot(FindPlaceToFire(none, m_vThreatLocation, 2000.0000000));
	// End:0x53
	if((m_pActionSpot != none))
	{
		GotoStateMovingTo("SeeADead:FireSpot", 5, true, m_pActionSpot,, 'SeeADead', 'AtSpot');
	}
AtSpot:


	StopMoving();
	// End:0x7B
	if((m_pActionSpot != none))
	{
		ChangeOrientationTo(m_pActionSpot.Rotation);		
	}
	else
	{
		Focus = none;
		FocalPoint = m_vThreatLocation;
	}
	// End:0xC4
	if(((m_pActionSpot == none) || (int(m_pActionSpot.m_eFire) == int(2))))
	{
		Pawn.bWantsToCrouch = true;
	}
	m_fSearchTime = (Level.TimeSeconds + float(30));
Wait:


	// End:0x108
	if((m_fSearchTime < Level.TimeSeconds))
	{
		GotoStateEngageBySound(m_vThreatLocation, 4, 30.0000000);
	}
	Sleep(RandRange(1.0000000, 3.0000000));
	m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, 10000.0000000) / float(256)));
	Sleep(RandRange(0.5000000, 1.5000000));
	m_pawn.m_wWantedHeadYaw = 0;
	goto 'Wait';
	stop;				
}

state MovingToAttack
{
	function BeginState()
	{
		SetReactionStatus(3, 0);
		return;
	}
Begin:

	// End:0x23
	if((m_pActionSpot == none))
	{
		SetActionSpot(FindPlaceToFire(Target, m_vThreatLocation, 2000.0000000));
	}
	// End:0x78
	if((m_pActionSpot != none))
	{
		m_pActionSpot.m_pCurrentUser = m_pawn;
		GotoStateMovingTo("MovingToAttackActionSpot", 5, true, m_pActionSpot,, 'MovingToAttack', 'AtActionSpot');		
	}
	else
	{
		GotoStateMovingTo("MovingToAttackThreat", 5, true,, m_vThreatLocation, 'MovingToAttack', 'AtPosition');
	}
	J0xA7:

	MoveToPosition(m_pActionSpot.Location, Rotator((Target.Location - m_pActionSpot.Location)));
	// End:0x105
	if((int(m_pActionSpot.m_eFire) == int(2)))
	{
		m_pawn.bWantsToCrouch = true;		
	}
	else
	{
		m_pawn.bWantsToCrouch = false;
	}
	goto 'Wait';
AtPosition:


	FocalPoint = Target.Location;
Wait:


	Sleep(30.0000000);
	Sleep(RandRange(1.0000000, 3.0000000));
	GotoStateEngageBySound(m_vThreatLocation, 4, 30.0000000);
	stop;		
}

state LostSight
{
	function BeginState()
	{
		SetReactionStatus(3, 0);
		return;
	}
Begin:

	// End:0x62
	if((Enemy != none))
	{
		// Use native FindBetterShotLocation to find a position with line of sight to the enemy
		m_vTargetPosition = FindBetterShotLocation(Enemy);
		R6PreMoveTo(m_vTargetPosition, Enemy.Location, 5);
		MoveTo(m_vTargetPosition, Enemy);
		Focus = none;
		FocalPoint = Enemy.Location;
		goto 'AtBetterLocation';
	}
Grenade:


	// End:0x9F
	if(m_pawn.m_bHaveAGrenade)
	{
		// End:0x9F
		if(m_pawn.m_DZone.m_bUseGrenade)
		{
			GotoStateThrowingGrenade('LostSight', 'EndThrowingGrenade');
		}
	}
EndThrowingGrenade:


	// After grenade throw, look for a cover action spot within 2000 UU
	SetActionSpot(FindPlaceToFire(none, m_vThreatLocation, 2000.0000000));
	// End:0x100
	if((m_pActionSpot != none))
	{
		m_pActionSpot.m_pCurrentUser = m_pawn;
		GotoStateMovingTo("LostSightActionSpot", 5, true, m_pActionSpot,, 'LostSight', 'AtActionSpot');
	}
	m_pawn.bWantsToCrouch = true;
	FocalPoint = m_vThreatLocation;
	goto 'Waiting';
AtActionSpot:


	MoveToPosition(m_pActionSpot.Location, Rotator((m_pActionSpot.Location - m_vThreatLocation)));
	// End:0x192
	if(((int(m_pActionSpot.m_eFire) == int(2)) || (int(m_pActionSpot.m_eCover) == int(2))))
	{
		m_pawn.bWantsToCrouch = true;		
	}
	else
	{
		m_pawn.bWantsToCrouch = false;
	}
	J0x1A3:

	Sleep(RandRange(0.0000000, 3.0000000));
	// End:0x22D
	if((float(Pawn.EngineWeapon.NumberOfBulletsLeftInClip()) < (0.5000000 * float(Pawn.EngineWeapon.GetClipCapacity()))))
	{
		SetReactionStatus(5, 0);
		AIReloadWeapon();
		J0x206:

		// End:0x223 [Loop If]
		if(m_pawn.m_bReloadingWeapon)
		{
			Sleep(0.1000000);
			// [Loop Continue]
			goto J0x206;
		}
		SetReactionStatus(0, 0);
	}
	GotoStateEngageBySound(m_vThreatLocation, 5, 30.0000000);
	stop;				
}

state PrecombatAction
{
	function BeginState()
	{
		SetReactionStatus(5, 0);
		return;
	}
Begin:

	m_pawn.m_bSkipTick = false;
	ChangeDefCon(1);
	CheckForInteraction();
	goto 'AfterInteraction';
InteractiveObject:


	StopMoving();
	J0x2B:

	// End:0x83 [Loop If]
	if((m_TriggeredIO.m_InteractionOwner != none))
	{
		// End:0x78
		if((!m_TriggeredIO.m_InteractionOwner.Pawn.IsAlive()))
		{
			m_TriggeredIO.m_InteractionOwner = none;			
		}
		else
		{
			Sleep(0.5000000);
		}
		// [Loop Continue]
		goto J0x2B;
	}
	m_TriggeredIO.PerformAction(m_pawn);
	m_TriggeredIO = none;
	Sleep(1.0000000);
	// End:0xB7
	if((Enemy == none))
	{
		GotoStateNoThreat();
	}
AfterInteraction:


	// End:0xE4
	if((m_pawn.m_bIsKneeling || m_pawn.m_bIsUnderArrest))
	{
		GotoState('Surrender');
	}
	StopMoving();
	LastSeenTime = Level.TimeSeconds;
	LastSeenPos = Enemy.Location;
	// End:0x16B
	if(((!Pawn.m_bDroppedWeapon) && (Pawn.EngineWeapon != none)))
	{
		// End:0x16B
		if((int(m_eAttackMode) != int(0)))
		{
			// End:0x164
			if((int(m_eAttackMode) == int(4)))
			{
				m_eAttackMode = 3;
			}
			GotoState('Attack');
		}
	}
	// End:0x1BE
	if(MakeBackupList())
	{
		// End:0x1AB
		if(AIPlayCallBackup(Enemy))
		{
			Sleep(1.0000000);
			CallBackupForAttack(Enemy.Location, 5);
			FinishAnim(m_pawn.16);			
		}
		else
		{
			CallBackupForAttack(Enemy.Location, 5);
		}
	}
	J0x1BE:

	// End:0x21E
	if(m_pawn.m_bHaveAGrenade)
	{
		// End:0x21E
		if(m_pawn.m_DZone.m_bUseGrenade)
		{
			// End:0x21E
			if(((Rand(100) + 1) < m_pawn.m_DZone.m_iChanceToUseGrenadeAtFirstReaction))
			{
				GotoStateThrowingGrenade('PrecombatAction', 'Reaction');
			}
		}
	}
Reaction:


	// End:0x265
	if((R6RainbowAI(Enemy.Controller) != none))
	{
		m_iRainbowInCombat = R6RainbowAI(Enemy.Controller).m_TeamManager.m_iMemberCount;		
	}
	else
	{
		// End:0x2A9
		if((R6PlayerController(Enemy.Controller) != none))
		{
			m_iRainbowInCombat = R6PlayerController(Enemy.Controller).m_TeamManager.m_iMemberCount;
		}
	}
	switch(GetEngageReaction(Enemy, m_iTerroristInGroup, m_iRainbowInCombat))
	{
		// End:0x2D4
		case 1:
			PlayAttackVoices();
			GotoStateAimedFire();
			// End:0x335
			break;
		// End:0x2E8
		case 2:
			PlayAttackVoices();
			GotoStateSprayFire();
			// End:0x335
			break;
		// End:0x30D
		case 3:
			m_VoicesManager.PlayTerroristVoices(m_pawn, 4);
			GotoState('RunAway');
			// End:0x335
			break;
		// End:0x332
		case 4:
			m_VoicesManager.PlayTerroristVoices(m_pawn, 2);
			GotoState('Surrender');
			// End:0x335
			break;
		// End:0xFFFF
		default:
			break;
	}
	stop;		
}

auto state Configuration
{Begin:

	m_pawn = R6Terrorist(Pawn);
	m_pawn.m_controller = self;
	m_Manager = R6TerroristMgr(Level.GetTerroristMgr());
	J0x3A:

	// End:0x59 [Loop If]
	if((!m_pawn.m_bInitFinished))
	{
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x3A;
	}
	m_vSpawningPosition = m_pawn.Location;
	m_rSpawningRotation = m_pawn.Rotation;
	m_eEngageReaction = m_pawn.m_DZone.m_eEngageReaction;
	ChangeDefCon(m_pawn.m_eDefCon);
	// End:0x116
	// Patrol strategy 0 requires a path; if path has fewer than 2 nodes, fall back to GuardPoint (strategy 2)
	if((int(m_pawn.m_eStrategy) == int(0)))
	{
		m_path = R6DZonePath(m_pawn.m_DZone);
		assert((m_path != none));
		// End:0x116
		if((m_path.m_aNode.Length < 2))
		{
			m_pawn.m_eStrategy = 2;
		}
	}
	// End:0x125
	if(UseRandomHostage())
	{
		AssignNearHostage();
	}
	m_TriggeredIO = m_pawn.m_DZone.m_InteractiveObject;
	GotoStateNoThreat();
	stop;			
}

state ThrowingGrenade
{
	function BeginState()
	{
		SetReactionStatus(5, 0);
		Focus = Enemy;
		return;
	}

	function EndState()
	{
		Focus = none;
		FocalPoint = Enemy.Location;
		return;
	}

	function CheckDistance()
	{
		local Vector vDir;
		local float fDist;

		vDir = (Enemy.Location - m_pawn.Location);
		fDist = VSize(vDir);
		// End:0xA4
		if((fDist > float(1500)))
		{
			vDir = Normal(vDir);
			vDir = (m_pawn.Location + (vDir * (fDist - float(1400))));
			GotoStateMovingTo("ThrowingGrenade", 5, true,, vDir, 'ThrowingGrenade', 'Throw');
		}
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		return true;
		return;
	}
Begin:

	CheckDistance();
Throw:


	// End:0x38
	if((VSize((Enemy.Location - m_pawn.Location)) > float(1500)))
	{
		goto 'Exit';
	}
	Target = Enemy;
	StopMoving();
	// End:0x74
	if(m_pawn.bIsCrouched)
	{
		m_pawn.bWantsToCrouch = false;
		Sleep(0.1000000);
	}
	FinishRotation();
	m_pawn.SetToGrenade();
	m_pawn.PlayWeaponAnimation();
	m_pawn.SetNextPendingAction(30);
	FinishAnim(m_pawn.16);
	m_pawn.SetToNormalWeapon();
	m_pawn.PlayWeaponAnimation();
	Sleep(2.0000000);
Exit:


	GotoState(NextState, NextLabel);
	stop;	
}

state NoThreat
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}
Begin:

	// End:0x2D
	if((m_pawn.m_bIsKneeling || m_pawn.m_bIsUnderArrest))
	{
		GotoState('Surrender');
	}
	Pawn.SetMovementPhysics();
	m_eAttackMode = 0;
	m_pawn.m_bSprayFire = false;
	StopMoving();
	// End:0x99
	if((int(m_pawn.m_ePersonality) != int(5)))
	{
		m_pawn.bWantsToCrouch = false;
		m_pawn.m_bIsSniping = false;		
	}
	else
	{
		m_pawn.m_bIsSniping = true;
		m_pawn.m_bCanProne = true;
		m_pawn.m_bAllowLeave = false;
	}
	m_pawn.m_bSkipTick = true;
	m_pawn.m_bIsKneeling = false;
	m_pawn.m_bIsUnderArrest = false;
	m_bAlreadyHeardSound = false;
	m_TerroristLeader = none;
	m_iCurrentGroupID = 0;
	m_HostageAI = none;
	SetEnemy(none);
	m_iChanceToDetectShooter = 0;
	SetActionSpot(none);
	// End:0x143
	if((!UseRandomHostage()))
	{
		m_Hostage = none;
	}
	// End:0x164
	// NoThreat never drops below DefCon 2 — fully relaxed (5) only happens outside active gameplay
	if((int(m_pawn.m_eDefCon) <= int(2)))
	{
		ChangeDefCon(2);
	}
	m_iRandomNumber = 0;
	J0x16B:

	// Clear recently-visited node history (10 entries) to reset path memory on each NoThreat entry
	// End:0x18E [Loop If]
	if((m_iRandomNumber < 10))
	{
		m_aLastNode[m_iRandomNumber] = none;
		(m_iRandomNumber++);
		// [Loop Continue]
		goto J0x16B;
	}
	J0x18E:

	// Wait for the game to actually start before doing anything
	// End:0x1B6 [Loop If]
	if((!Level.Game.m_bGameStarted))
	{
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x18E;
	}
	// End:0x201
	if(((Pawn.m_bDroppedWeapon || (Pawn.EngineWeapon == none)) || Pawn.EngineWeapon.GunIsFull()))
	{
		goto 'ChooseState';
	}
Reload:


	SetReactionStatus(5, 0);
	J0x20B:

	// End:0x256 [Loop If]
	if((!Pawn.EngineWeapon.GunIsFull()))
	{
		Sleep(0.1000000);
		AIReloadWeapon();
		J0x236:

		// End:0x253 [Loop If]
		if(m_pawn.m_bReloadingWeapon)
		{
			Sleep(0.1000000);
			// [Loop Continue]
			goto J0x236;
		}
		// [Loop Continue]
		goto J0x20B;
	}
	SetReactionStatus(0, 0);
ChooseState:


	switch(m_pawn.m_eStrategy)
	{
		// End:0x27F
		case 0:
			GotoState('PatrolPath');
			// End:0x2BB
			break;
		// End:0x28E
		case 1:
			GotoState('PatrolArea');
			// End:0x2BB
			break;
		// End:0x29D
		case 2:
			GotoState('GuardPoint');
			// End:0x2BB
			break;
		// End:0x2AC
		case 3:
			GotoState('HuntRainbow');
			// End:0x2BB
			break;
		// End:0x2B8
		case 4:
			GotoState('test');
		// End:0xFFFF
		default:
			break;
	}
	stop;				
}

state MovingTo
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, m_eStateForEvent);
		// End:0x49
		if((int(m_pawn.m_eMovementPace) == int(5)))
		{
			m_pawn.m_ePlayerIsUsingHands = 3;
			m_pawn.PlayWeaponAnimation();
		}
		return;
	}

	function EndState()
	{
		// End:0x39
		if((int(m_pawn.m_eMovementPace) == int(5)))
		{
			m_pawn.m_ePlayerIsUsingHands = 0;
			m_pawn.PlayWeaponAnimation();
		}
		SetTimer(0.0000000, false);
		m_pawn.m_wWantedHeadYaw = 0;
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		local R6Pawn aPawn;

		aPawn = R6Pawn(Other);
		// End:0x15C
		if((aPawn != none))
		{
			// End:0x43
			// Pawn type 1 = Rainbow (enemy): immediately exit MovingTo on collision
			if((int(aPawn.m_ePawnType) == int(1)))
			{
				GotoState('MovingTo', 'Exit');				
			}
			else
			{
				// End:0x15C
				// Pawn type 2 = Terrorist (friendly): debounce and handle bump carefully
				if((int(aPawn.m_ePawnType) == int(2)))
				{
					// End:0x8D
					if((aPawn != m_LastBumped))
					{
						m_LastBumped = aPawn;
						m_fLastBumpedTime = Level.TimeSeconds;						
					}
					else
					{
						// End:0x15C
						// Extra 0.1-0.3s random delay before reacting to repeated bumps avoids oscillation
						if((Level.TimeSeconds > ((m_fLastBumpedTime + 0.3000000) + RandRange(0.1000000, 0.3000000))))
						{
							// End:0xF8
							// Bumped pawn is stationary and move can fail: just exit without pushing
							if((m_bCanFailMovingTo && (m_LastBumped.Velocity == vect(0.0000000, 0.0000000, 0.0000000))))
							{
								GotoState('MovingTo', 'Exit');								
							}
							else
							{
								// End:0x14E
								if((m_bCantInterruptIO && (R6TerroristAI(aPawn.Controller) != none)))
								{
									R6TerroristAI(aPawn.Controller).GotoBumpBackUpState(aPawn.Controller.GetStateName());
								}
								GotoState('MovingTo', 'WaitLastBumped');
							}
							return true;
						}
					}
				}
			}
		}
		return false;
		return;
	}

	function bool GetReacheablePoint(out Vector vTarget)
	{
		local Vector vDirection;
		local float fTemp;

		vDirection = (Pawn.Location - m_LastBumped.Location);
		vDirection.Z = 0.0000000;
		// Move away 4× collision radius to clear the blocking pawn
		vDirection = ((Normal(vDirection) * Pawn.CollisionRadius) * float(4));
		vTarget = (Pawn.Location + vDirection);
		// End:0x7F
		if(pointReachable(vTarget))
		{
			return true;
		}
		// Rotate direction 90° left to try a side step
		fTemp = (-vDirection.X);
		vDirection.X = vDirection.Y;
		vDirection.Y = fTemp;
		vTarget = (Pawn.Location + vDirection);
		// End:0xDE
		if(pointReachable(vTarget))
		{
			return true;
		}
		// Rotate 90° right (negate previous left rotation) for the other side
		vDirection.X = (-vDirection.X);
		vDirection.Y = (-vDirection.Y);
		vTarget = (Pawn.Location + vDirection);
		// End:0x134
		if(pointReachable(vTarget))
		{
			return true;
		}
		return false;
		return;
	}

	event Timer()
	{
		(m_iStateVariable++);
		// Cycles 0→1→2→3→0: 0/2=face forward, 1=look right, 3=look left — natural head scan while walking
		switch(m_iStateVariable)
		{
			// End:0x1A
			case 4:
				m_iStateVariable = 0;
			// End:0x1E
			case 0:
			// End:0x4B
			case 2:
				m_pawn.m_wWantedHeadYaw = 0;
				SetTimer(RandRange(1.0000000, 2.0000000), false);
				// End:0xD9
				break;
			// End:0x90
			case 1:
				m_pawn.m_wWantedHeadYaw = byte((RandRange(3500.0000000, 10000.0000000) / float(256)));
				SetTimer(RandRange(0.5000000, 1.5000000), false);
				// End:0xD9
				break;
			// End:0xD6
			case 3:
				m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -3500.0000000) / float(256)));
				SetTimer(RandRange(0.5000000, 1.5000000), false);
				// End:0xD9
				break;
			// End:0xFFFF
			default:
				break;
		}
		return;
	}
Begin:

	m_iRandomNumber = 0;
	m_wBadMoveCount = 0;
	// End:0x36
	// Already at destination; skip movement entirely
	if((VSize((m_vMovingDestination - Pawn.Location)) < 10.0000000))
	{
		goto 'Exit';
	}
	// End:0x7F
	// Only start the head-scan timer when walking (DefCon > 2); sprinting terrorists don't look around
	if((int(m_pawn.m_eMovementPace) == int(4)))
	{
		// End:0x63
		if((Rand(2) == 0))
		{
			m_iStateVariable = 0;			
		}
		else
		{
			m_iStateVariable = 2;
		}
		SetTimer(RandRange(1.0000000, 2.0000000), false);
	}
	// End:0xAA
	if(m_pawn.bWantsToCrouch)
	{
		m_pawn.bWantsToCrouch = false;
		Sleep(0.1000000);
	}
	m_iRandomNumber = 0;
PathFinding:


	// End:0xDC
	if((((m_aMovingToDestination != none) && actorReachable(m_aMovingToDestination)) || pointReachable(m_vMovingDestination)))
	{
		goto 'EndPath';
	}
	// End:0xF8
	if((m_aMovingToDestination != none))
	{
		MoveTarget = FindPathToward(m_aMovingToDestination);		
	}
	else
	{
		MoveTarget = FindPathTo(m_vMovingDestination, true);
	}
	// End:0x120
	if((MoveTarget == none))
	{
		Sleep(0.5000000);
		goto 'Exit';
	}
	// End:0x164
	if(((m_iRandomNumber == 0) && (int(m_pawn.m_eDefCon) > int(2))))
	{
		m_iRandomNumber = 1;
		FocalPoint = MoveTarget.Location;
		FinishRotation();
	}
	R6PreMoveTo(MoveTarget.Location, MoveTarget.Location, m_pawn.m_eMovementPace);
	MoveToward(MoveTarget);
	// End:0x1D5
	if((int(m_eMoveToResult) == int(2)))
	{
		(m_wBadMoveCount++);
		// End:0x1D2
		if((m_bCanFailMovingTo && (int(m_wBadMoveCount) > 2)))
		{
			goto 'Exit';
		}		
	}
	else
	{
		m_wBadMoveCount = 0;
	}
	goto 'PathFinding';
EndPath:


	// End:0x21E
	if(((m_iRandomNumber == 0) && (int(m_pawn.m_eDefCon) > int(2))))
	{
		m_iRandomNumber = 1;
		FocalPoint = m_vMovingDestination;
		FinishRotation();
	}
	R6PreMoveTo(m_vMovingDestination, m_vMovingDestination, m_pawn.m_eMovementPace);
	// End:0x252
	if((m_aMovingToDestination != none))
	{
		MoveToward(m_aMovingToDestination);		
	}
	else
	{
		MoveTo(m_vMovingDestination);
	}
	J0x25A:

	// End:0x2F1
	if((!m_bCanFailMovingTo))
	{
		// End:0x2BA
		if((m_aMovingToDestination != none))
		{
			// End:0x2B7
			if((VSize((m_vMovingDestination - Pawn.Location)) > ((Pawn.CollisionRadius + m_aMovingToDestination.CollisionRadius) + 10.0000000)))
			{
				goto 'Begin';
			}			
		}
		else
		{
			// End:0x2F1
			if((VSize((m_vMovingDestination - Pawn.Location)) > (Pawn.CollisionRadius * 2.0000000)))
			{
				goto 'Begin';
			}
		}
	}
	StopMoving();
	GotoState(m_stateAfterMovingTo, m_labelAfterMovingTo);
WaitLastBumped:


	// End:0x34A
	if(GetReacheablePoint(m_vTargetPosition))
	{
		m_sDebugString = "Bumped away";
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, m_pawn.m_eMovementPace);
		MoveTo(m_vTargetPosition);
	}
	StopMoving();
	// End:0x36F
	if((MoveTarget != none))
	{
		FocalPoint = MoveTarget.Location;
	}
	m_sDebugString = "WaitLastBumped";
	// End:0x3A1
	if(m_bCanFailMovingTo)
	{
		Sleep(RandRange(0.0000000, 2.0000000));
	}
	m_LastBumped = none;
	m_sDebugString = "";
	goto 'Begin';
	stop;	
}

state EngageByThreat
{
	function BeginState()
	{
		SetReactionStatus(3, 0);
		return;
	}

	function EndState()
	{
		m_pawn.bRotateToDesired = true;
		m_pawn.bPhysicsAnimUpdate = true;
		m_pawn.m_wWantedHeadYaw = 0;
		return;
	}
Begin:

	Sleep(RandRange(0.1000000, 0.2000000));
	ChangeDefCon(1);
	SetActionSpot(FindPlaceToTakeCover(m_vThreatLocation, 2000.0000000));
	// End:0x67
	if((m_pActionSpot != none))
	{
		GotoStateMovingTo("ThreatActionSpot", 5, true, m_pActionSpot,, 'EngageByThreat', 'ReachedCover');		
	}
	else
	{
		// End:0x8C
		if((!m_pawn.m_bPreventCrouching))
		{
			Pawn.bWantsToCrouch = true;
		}
		Focus = none;
		FocalPoint = m_vThreatLocation;
		StopMoving();
		SetReactionStatus(2, 0);
		goto 'Wait';
	}
	J0xB4:

	// End:0x10E
	if((int(m_pActionSpot.m_eCover) != int(0)))
	{
		// End:0xFA
		if((int(m_pActionSpot.m_eCover) == int(1)))
		{
			m_r6pawn.bWantsToCrouch = false;			
		}
		else
		{
			m_r6pawn.bWantsToCrouch = true;
		}		
	}
	else
	{
		// End:0x13B
		if((int(m_pActionSpot.m_eFire) == int(1)))
		{
			m_r6pawn.bWantsToCrouch = false;			
		}
		else
		{
			m_r6pawn.bWantsToCrouch = true;
		}
	}
	MoveToPosition(m_pActionSpot.Location, m_pActionSpot.Rotation);
	Focus = none;
	FocalPoint = m_vThreatLocation;
	StopMoving();
	SetReactionStatus(2, 0);
Wait:


	// End:0x1AB
	if((m_fSearchTime < Level.TimeSeconds))
	{
		GotoStateNoThreat();
	}
	// End:0x1F2
	// 1-in-3 chance each cycle to do a random head sweep while waiting at cover
	if((Rand(3) == 0))
	{
		m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, 10000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));
	}
	m_pawn.m_wWantedHeadYaw = 0;
	Sleep(RandRange(1.0000000, 5.0000000));
	goto 'Wait';
	stop;			
}

state EngageBySound
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		m_pawn.m_bAvoidFacingWalls = true;
		return;
	}

	function EndState()
	{
		m_vHostageReactionDirection = vect(0.0000000, 0.0000000, 0.0000000);
		m_pawn.m_wWantedHeadYaw = 0;
		m_pawn.m_bAvoidFacingWalls = false;
		return;
	}

	function Vector ChooseARandomPoint()
	{
		SetActionSpot(FindInvestigationPoint(m_iCurrentGroupID, 2000.0000000));
		// End:0x2B
		if((m_pActionSpot == none))
		{
			return GetNextRandomNode().Location;
		}
		m_pActionSpot.m_iLastInvestigateID = m_iCurrentGroupID;
		return m_pActionSpot.Location;
		return;
	}
Begin:

	StopMoving();
	Focus = none;
	// Face the threat location first, then wait a moment before moving — realistic alert response
	FocalPoint = m_vThreatLocation;
	FinishRotation();
	Sleep(RandRange(0.2500000, 0.5000000));
	m_pawn.TurnAwayFromNearbyWalls();
	Sleep(RandRange(0.2500000, 1.0000000));
	// End:0x6E
	if((m_fSearchTime < Level.TimeSeconds))
	{
		goto 'Exit';
	}
	// End:0x88
	// If not allowed to leave the zone, go directly to the threat location instead of finding an investigation point
	if((!m_pawn.m_bAllowLeave))
	{
		goto 'GoCloserAndLook';
	}
	SetActionSpot(FindInvestigationPoint(m_iCurrentGroupID, 2000.0000000, true, m_vThreatLocation));
	// End:0xF9
	if((m_pActionSpot != none))
	{
		m_pActionSpot.m_iLastInvestigateID = m_iCurrentGroupID;
		GotoStateMovingTo("SoundActionSpot", m_pawn.m_eMovementPace, true, m_pActionSpot,, 'EngageBySound', 'AtDestination');		
	}
	else
	{
		GotoStateMovingTo("SoundThreatLocation", m_pawn.m_eMovementPace, true,, m_vThreatLocation, 'EngageBySound', 'AtDestination');
	}
	J0x133:

	m_pawn.m_eMovementPace = 4;
	goto 'AtRandomPoint';
WaitHere:


	// End:0x168
	if((m_fSearchTime < Level.TimeSeconds))
	{
		goto 'Exit';
	}
	// End:0x193
	if((Rand(4) == 0))
	{
		ChangeOrientationTo(ChooseRandomDirection(50));
		Sleep(RandRange(2.0000000, 4.0000000));
	}
	// End:0x1EB
	if((Rand(2) == 0))
	{
		m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, 10000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));
		m_pawn.m_wWantedHeadYaw = 0;
	}
	Sleep(RandRange(1.0000000, 4.0000000));
	goto 'WaitHere';
ChooseDestination:


	// End:0x222
	if((m_fSearchTime < Level.TimeSeconds))
	{
		goto 'Exit';
	}
	Destination = ChooseARandomPoint();
	GotoStateMovingTo("EBSRndPoint", m_pawn.m_eMovementPace, true,, Destination, 'EngageBySound', 'AtRandomPoint');
AtRandomPoint:


	// End:0x27F
	if((m_pActionSpot != none))
	{
		ChangeOrientationTo(m_pActionSpot.Rotation);
	}
	// End:0x306
	// Alternates head-left / head-right sweep to simulate searching while standing still
	if((Rand(2) == 0))
	{
		m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));
		m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));		
	}
	else
	{
		m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));
		m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
		Sleep(RandRange(1.0000000, 2.5000000));
	}
	m_pawn.m_wWantedHeadYaw = 0;
	goto 'ChooseDestination';
GoCloserAndLook:


	GotoStateMovingTo("EBSThreatLoc", m_pawn.m_eMovementPace, true,, m_vThreatLocation, 'EngageBySound', 'AtClosest');
AtClosest:


	FocalPoint = m_vThreatLocation;
	FinishRotation();
	Sleep(RandRange(3.0000000, 5.0000000));
Exit:


	GotoStateNoThreat();
	stop;		
}

state Surrender
{
	function BeginState()
	{
		SetReactionStatus(5, 0);
		return;
	}

	function EscortIsOver(R6HostageAI hostageAI, bool bSuccess)
	{
		m_Manager.RemoveHostageAssignment(m_Hostage);
		return;
	}

//============================================================================
// AIAffectedByGrenade - 
//============================================================================
	function AIAffectedByGrenade(Actor aGrenade, Pawn.EGrenadeType eType)
	{
		return;
	}
Begin:

	StopMoving();
	FinishRotation();
	// End:0x30
	if((m_pawn.m_bIsUnderArrest || m_pawn.m_bIsKneeling))
	{
		stop;
	}
	m_pawn.m_bPreventWeaponAnimation = true;
	m_pawn.SetNextPendingAction(31);
	Sleep(0.3330000);
	m_pawn.SetNextPendingAction(9);
	FinishAnim(m_pawn.16);
	m_pawn.SetNextPendingAction(32);
	J0x8A:

	// End:0xA9 [Loop If]
	if((!m_pawn.m_bIsKneeling))
	{
		Sleep(1.0000000);
		// [Loop Continue]
		goto J0x8A;
	}
	R6AbstractGameInfo(Level.Game).RemoveTerroFromList(m_pawn);
	R6AbstractGameInfo(Level.Game).PawnSecure(m_pawn);
	stop;
Secure:


	FinishRotation();
	m_pawn.m_bIsUnderArrest = true;
	R6AbstractGameInfo(Level.Game).PawnSecure(m_pawn);
	m_pawn.SetCollision(false, false, false);
	m_pawn.SetNextPendingAction(33);
	stop;			
}

state RunAway
{
	function BeginState()
	{
		SetReactionStatus(5, 1);
		return;
	}

//============================================================================
// GotoPointAndAttack - 
//============================================================================
	event GotoPointToAttack(Vector vDestination, Actor PTarget)
	{
		return;
	}
Begin:

	// End:0x2B
	if(Pawn.bIsCrouched)
	{
		m_pawn.bWantsToCrouch = false;
		Sleep(0.1000000);
	}
ChooseDestination:


	// End:0x46
	if(((!MakePathToRun()) || (RouteGoal == none)))
	{
		GotoStateSprayFire();
	}
	GotoStateMovingTo("AttackReloadCover", 5, true, RouteGoal,, 'RunAway', 'ChooseDestination');
	goto 'ChooseDestination';
	stop;			
}

state WaitForEnemy
{
	function BeginState()
	{
		SetReactionStatus(3, 0);
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		Focus = none;
		FocalPoint = Enemy.Location;
		return;
	}

//============================================================================
// SeePlayer - 
//============================================================================
	function SeePlayer(Pawn seen)
	{
		// End:0x37
		if(IsAnEnemy(R6Pawn(seen)))
		{
			SetEnemy(seen);
			// End:0x31
			// 50/50 chance between spray fire and aimed fire when enemy reappears
			if((Rand(2) == 0))
			{
				GotoStateSprayFire();				
			}
			else
			{
				GotoStateAimedFire();
			}
		}
		return;
	}

	function Timer()
	{
		// 10-second timer expires; give up waiting and return to NoThreat
		GotoStateNoThreat();
		return;
	}
Begin:

	Focus = Enemy;
	FocalPoint = LastSeenPos;
	StopMoving();
	// End:0x41
	if((!m_pawn.m_bPreventCrouching))
	{
		Pawn.bWantsToCrouch = true;
	}
	// 10-second countdown before returning to NoThreat if enemy doesn't reappear
	SetTimer(10.0000000, false);
	m_pawn.m_bAvoidFacingWalls = true;
Wait:


	stop;				
}

state Attack
{
	function BeginState()
	{
		SetReactionStatus(4, 2);
		// End:0x91
		// An unarmed terrorist cannot fight; force-kill it so it doesn't block the AI
		if((Pawn.IsAlive() && (Pawn.m_bDroppedWeapon || (Pawn.EngineWeapon == none))))
		{
			m_pawn.ServerForceKillResult(4);
			m_pawn.R6TakeDamage(1000, 1000, m_pawn, m_pawn.Location, vect(0.0000000, 0.0000000, 0.0000000), 0);
		}
		// End:0xA9
		if((int(m_eAttackMode) == int(0)))
		{
			GotoStateNoThreat();
			return;
		}
		m_pawn.m_bEngaged = true;
		m_pawn.PlayWaiting();
		Focus = Enemy;
		m_sDebugString = "";
		return;
	}

	function EndState()
	{
		m_pawn.m_bEngaged = false;
		m_pawn.m_wWantedAimingPitch = 0;
		StopFiring();
		Focus = none;
		// End:0x4E
		if((Enemy != none))
		{
			FocalPoint = Enemy.Location;
		}
		m_sDebugString = "";
		return;
	}

	function bool NeedToReload()
	{
		// End:0x20
		if((Pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0))
		{
			return true;
		}
		// End:0x7F
		// Weapon type 5 = grenade launcher: needs reload if more than 50 rounds below full clip
		if(((int(Pawn.EngineWeapon.m_eWeaponType) == int(5)) && (Pawn.EngineWeapon.NumberOfBulletsLeftInClip() < (Pawn.EngineWeapon.GetClipCapacity() - 50))))
		{
			return true;
		}
		return false;
		return;
	}

	function FindNextEnemy()
	{
		local R6Pawn aPawn;

		// End:0x1F
		if((Enemy != none))
		{
			FocalPoint = Enemy.Location;
		}
		SetEnemy(none);
		// End:0x8E
		foreach VisibleCollidingActors(Class'R6Engine.R6Pawn', aPawn, 5000.0000000, m_pawn.Location)
		{
			// End:0x8D
			if((m_pawn.IsEnemy(aPawn) && aPawn.IsAlive()))
			{
				SetEnemy(aPawn);
				Focus = Enemy;				
				return;
			}			
		}		
		// End:0xC4
		if((int(m_eAttackMode) == int(3)))
		{
			// End:0xC1
			if(pointReachable(LastSeenPos))
			{
				m_vMovingDestination = LastSeenPos;
				GotoState('Attack', 'SprayFireMove');
			}			
		}
		else
		{
			GotoStateLostSight(LastSeenPos);
		}
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		return true;
		return;
	}
Begin:

	// End:0x2D
	if((int(m_pawn.m_eEffectiveGrenade) != int(0)))
	{
		ReactToGrenade(m_pawn.m_vGrenadeLocation);
	}
	m_sDebugString = "Begin";
	StopMoving();
	m_bFireShort = false;
	// End:0x90
	if((m_pActionSpot != none))
	{
		m_iRandomNumber = Rand(100);
		// End:0x74
		// 60% chance: take a short peek (fire briefly then retreat); 20%: clear action spot; 20%: move to fire spot
		if((m_iRandomNumber < 60))
		{
			m_bFireShort = true;			
		}
		else
		{
			// End:0x8A
			if((m_iRandomNumber < 80))
			{
				SetActionSpot(none);				
			}
			else
			{
				goto 'MoveToFireSpot';
			}
		}
	}
	// End:0xDF
	// 1-in-3 random chance to crouch before shooting (not forced if crouching is disabled)
	if((((!m_pawn.m_bPreventCrouching) && (!Pawn.bIsCrouched)) && (Rand(3) == 0)))
	{
		Pawn.bWantsToCrouch = true;
		Sleep(0.1000000);
	}
	Target = Enemy;
	m_sDebugString = "FinishRotation2";
	FinishRotation();
ReactionTime:


	// Reaction delay scales with difficulty: easy=1s pause, medium=0.5s, hard=0s (fires immediately)
	switch(m_pawn.m_iDiffLevel)
	{
		// End:0x123
		case 1:
			Sleep(1.0000000);
			// End:0x13E
			break;
		// End:0x133
		case 2:
			Sleep(0.5000000);
			// End:0x13E
			break;
		// End:0x13B
		case 3:
			// End:0x13E
			break;
		// End:0xFFFF
		default:
			break;
	}
	CallVisibleTerrorist();
Fire:


	// End:0x169
	if(((int(m_eAttackMode) != int(3)) || CanSee(Enemy)))
	{
		Focus = Enemy;
	}
	m_sDebugString = "Fire";
	// End:0x184
	if(NeedToReload())
	{
		goto 'Reload';
	}
	// End:0x1DC
	if((int(m_eAttackMode) == int(4)))
	{
		SetGunDirection(none);
		// End:0x1D9
		if((VSize((Pawn.Location - Destination)) < (Pawn.CollisionRadius * float(2))))
		{
			StopMoving();
			m_eAttackMode = 3;
		}		
	}
	else
	{
		// End:0x22A
		if(((Enemy == none) || (!R6Pawn(Enemy).IsAlive())))
		{
			// End:0x224
			if((int(m_pawn.m_ePersonality) == int(5)))
			{
				GotoStateNoThreat();				
			}
			else
			{
				FindNextEnemy();
			}
		}
		m_sDebugString = "CheckLineOfSight";
		// End:0x2F0
		if(((Enemy != none) && (!HaveAClearShot(m_pawn.GetFiringStartPoint(), Enemy))))
		{
			// End:0x2A0
			if((int(m_pawn.m_ePersonality) == int(5)))
			{
				SetLowestSnipingStance(Enemy);
				Sleep(0.2000000);
				goto 'Fire';				
			}
			else
			{
				m_vTargetPosition = FindBetterShotLocation(Enemy);
				R6PreMoveTo(m_vTargetPosition, Enemy.Location, 5);
				MoveTo(m_vTargetPosition, Enemy);
				FocalPoint = Enemy.Location;
				goto 'Fire';
			}
		}
		SetGunDirection(Enemy);
		J0x2FB:

		// Poll until the barrel pitch matches the desired angle (byte-precision: pitch & 0xFFFF / 256 gives upper byte)
		// End:0x36C [Loop If]
		if((((Enemy != none) && Enemy.IsAlive()) && (int(m_pawn.m_wWantedAimingPitch) != ((m_pawn.m_iCurrentAimingPitch & 65535) / 256))))
		{
			m_sDebugString = "SettingPitch";
			Sleep(0.0500000);
			// [Loop Continue]
			goto J0x2FB;
		}
	}
	// End:0x3AA
	if((int(m_eAttackMode) == int(1)))
	{
		J0x37C:

		// End:0x3AA [Loop If]
		if((!IsReadyToFire(Enemy)))
		{
			m_sDebugString = "ReadyToFire";
			Sleep(0.2000000);
			// [Loop Continue]
			goto J0x37C;
		}
	}
	// End:0x407
	if((((int(m_pawn.m_eEffectiveGrenade) == int(3)) || (int(m_pawn.m_eEffectiveGrenade) == int(4))) || (int(m_pawn.m_eEffectiveGrenade) == int(2))))
	{
		Sleep(0.5000000);
		goto 'ReactionTime';
	}
	m_sDebugString = "FinishRotation";
	FinishRotation();
	// End:0x493
	if((int(m_eAttackMode) == int(1)))
	{
		StartFiring();
		m_sDebugString = "AimedFiring";
		// End:0x482
		// Automatic weapon (rate 2): fire for 0.4-1.0s; semi-auto/single: fire for 0.2s flat
		if((int(Pawn.EngineWeapon.GetRateOfFire()) == int(2)))
		{
			Sleep(RandRange(0.4000000, 1.0000000));			
		}
		else
		{
			Sleep(0.2000000);
		}
		StopFiring();		
	}
	else
	{
		// End:0x51A
		// Spray fire with automatic weapon: fire 0.2-1.5s burst then pause up to 0.5s
		if((int(Pawn.EngineWeapon.GetRateOfFire()) == int(2)))
		{
			StartFiring();
			m_sDebugString = "FiringAuto";
			Sleep(RandRange(0.2000000, 1.5000000));
			StopFiring();
			SetGunDirection(Target);
			m_sDebugString = "StopFiring";
			Sleep(RandRange(0.0000000, 0.5000000));			
		}
		else
		{
			// Semi-auto/single shot: fire Rand(4)+2 individual shots with small pauses between each
			m_iRandomNumber = (Rand(4) + 2);
			J0x528:

			// End:0x57B [Loop If]
			if((m_iRandomNumber > 0))
			{
				StartFiring();
				m_sDebugString = "FiringSingle";
				Sleep(RandRange(0.1000000, 0.2000000));
				StopFiring();
				SetGunDirection(Target);
				(m_iRandomNumber--);
				// [Loop Continue]
				goto J0x528;
			}
			m_sDebugString = "StopFiring2";
			Sleep(RandRange(0.0000000, 0.5000000));
		}
	}
	// End:0x5B8
	if(m_bFireShort)
	{
		m_bFireShort = false;
		goto 'MoveToFireSpot';
	}
	goto 'ReactionTime';
Reload:


	m_sDebugString = "Reload";
	SetReactionStatus(5, 0);
	// End:0x5EE
	if((int(m_eAttackMode) > int(2)))
	{
		m_eAttackMode = 2;
	}
	// End:0x6FD
	if(((int(m_pawn.m_ePersonality) != int(5)) && (Enemy != none)))
	{
		SetActionSpot(FindPlaceToTakeCover(Enemy.Location, GetMaxCoverDistance()));
		// End:0x6B6
		if((m_pActionSpot != none))
		{
			GotoStateMovingTo("AttackReloadCover", 5, true, m_pActionSpot,, 'Attack', 'AtCover');
AtCover:


			SetReactionStatus(5, 0);
			MoveToPosition(m_pActionSpot.Location, m_pActionSpot.Rotation);
			Focus = Enemy;
			m_sDebugString = "FinishRotation3";
			FinishRotation();
		}
		// End:0x6FD
		if((((!m_pawn.m_bPreventCrouching) && (!Pawn.bIsCrouched)) && (Rand(2) == 0)))
		{
			Pawn.bWantsToCrouch = true;
		}
	}
	Target = none;
	StopMoving();
	AIReloadWeapon();
	J0x710:

	// End:0x73E [Loop If]
	if(m_pawn.m_bReloadingWeapon)
	{
		m_sDebugString = "Reloading";
		Sleep(0.1000000);
		// [Loop Continue]
		goto J0x710;
	}
	Target = Enemy;
	SetGunDirection(Target);
	m_sDebugString = "EndReloading";
	Sleep(0.4000000);
	SetReactionStatus(4, 2);
	goto 'Fire';
SprayFireMove:


	m_sDebugString = "SprayFireMove";
	SetReactionStatus(3, 2);
	m_eAttackMode = 4;
	// End:0x829
	if((VSize((m_vMovingDestination - m_pawn.Location)) > 100.0000000))
	{
		R6PreMoveTo(m_vMovingDestination, m_vMovingDestination, 4);
		// Switch to PHYS_Walking (1) and manually set acceleration so the pawn sprints while firing
		Pawn.SetPhysics(1);
		Destination = m_vMovingDestination;
		Pawn.Acceleration = (Normal((Destination - Pawn.Location)) * m_pawn.m_fWalkingSpeed);
	}
	goto 'Fire';
MoveToFireSpot:


	// End:0x865
	if(IsAttackSpotStillValid())
	{
		GotoStateMovingTo("AttackFireSpot", 5, true, m_pActionSpot, m_vThreatLocation, 'Attack', 'AtFireSpot');		
	}
	else
	{
		goto 'Fire';
	}
	J0x86B:

	// Orient to the fire spot facing away from enemy, then keep eyes on enemy throughout the peek
	MoveToPosition(m_pActionSpot.Location, Rotator((m_pActionSpot.Location - Enemy.Location)));
	Focus = Enemy;
	// End:0x8D1
	if((int(m_pActionSpot.m_eFire) == int(2)))
	{
		m_pawn.bWantsToCrouch = true;
	}
	goto 'Fire';
	stop;				
}

state AttackHostage extends Attack
{Begin:

	// End:0x2F
	if(((R6Hostage(Enemy) == none) || R6Hostage(Enemy).m_bExtracted))
	{
		FindNextEnemy();
	}
	// End:0x5B
	if(((!R6Pawn(Enemy).IsAlive()) || CanSee(Enemy)))
	{
		GotoStateAimedFire();
	}
	SetReactionStatus(3, 4);
	GotoStateMovingTo("Chase hostage", 5, true, Enemy,, 'AttackHostage', 'Begin');
	stop;		
}

state GuardPoint
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}

	function EndState()
	{
		m_pawn.m_wWantedHeadYaw = 0;
		return;
	}
Begin:

	GotoStateMovingTo("GuardPoint", 4, true,, m_vSpawningPosition, 'GuardPoint', 'StartWaiting',, true);
StartWaiting:


	StopMoving();
	ChangeOrientationTo(m_rSpawningRotation);
	FinishRotation();
	// End:0x5B
	// Personality 5 = sniper; immediately transition to Sniping state upon reaching the guard position
	if((int(m_pawn.m_ePersonality) == int(5)))
	{
		GotoState('Sniping');
	}
	// End:0x9E
	// Starting stance 2 = crouch; honour the designer's pre-configured crouch request
	if(((!m_pawn.m_bPreventCrouching) && (int(m_pawn.m_eStartingStance) == int(2))))
	{
		Pawn.bWantsToCrouch = true;		
	}
	else
	{
		Pawn.bWantsToCrouch = false;
	}
	J0xAF:

	// End:0x188
	// 1-in-3 chance to do a full left-right head sweep; otherwise glance only one way
	if((Rand(3) == 0))
	{
		m_iRandomNumber = Rand(2);
		// End:0xD9
		if((m_iRandomNumber == 0))
		{
			m_iRandomNumber = -1;
		}
		m_pawn.m_wWantedHeadYaw = byte((RandRange(float((m_iRandomNumber * 5000)), float((m_iRandomNumber * 10000))) / float(256)));
		Sleep(RandRange(1.0000000, 1.5000000));
		(m_iRandomNumber *= float(-1));
		m_pawn.m_wWantedHeadYaw = byte((RandRange(float((m_iRandomNumber * 5000)), float((m_iRandomNumber * 10000))) / float(256)));
		Sleep(RandRange(1.2500000, 1.7500000));		
	}
	else
	{
		m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
		// End:0x1DF
		if((Rand(2) == 0))
		{
			m_pawn.m_wWantedHeadYaw = byte((-int(m_pawn.m_wWantedHeadYaw)));
		}
		Sleep(RandRange(1.0000000, 1.5000000));
	}
	m_pawn.m_wWantedHeadYaw = 0;
	Sleep(RandRange(2.0000000, 6.0000000));
	goto 'Waiting';
	stop;			
}

state Sniping
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}

//============================================================================
// SeePlayer - 
//============================================================================
	event SeePlayer(Pawn seen)
	{
		local R6Pawn r6seen;

		r6seen = R6Pawn(seen);
		// End:0x1D
		if((r6seen == none))
		{
			return;
		}
		// End:0xEE
		if((m_bSeeRainbow && IsAnEnemy(r6seen)))
		{
			ReconThreatCheck(r6seen, 0);
			// End:0xB1
			// Within 500 UU (~10m) enemy is too close for prone sniping; prefer crouched stance (3-in-4 chance)
			if((VSize((seen.Location - m_pawn.Location)) < float(500)))
			{
				m_pawn.m_bWantsToProne = false;
				// End:0xB1
				if(((!m_pawn.m_bPreventCrouching) && (Rand(4) != 0)))
				{
					m_pawn.bWantsToCrouch = true;
				}
			}
			SetEnemy(r6seen);
			Target = Enemy;
			// End:0xE0
			// Call nearby terrorists to back up this sniper when sighting an enemy
			if(MakeBackupList())
			{
				CallBackupForAttack(Enemy.Location, 5);
			}
			ChangeDefCon(1);
			GotoStateAimedFire();
		}
		return;
	}

//============================================================================
// HearNoise - 
//============================================================================
	event HearNoise(float Loudness, Actor NoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
	{
		// End:0x36
		if((m_pawn.m_bDontHearPlayer && R6Pawn(NoiseMaker.Instigator).m_bIsPlayer))
		{
			return;
		}
		ReconThreatCheck(NoiseMaker, eType);
		// End:0x68
		if(m_pawn.IsNeutral(NoiseMaker.Instigator))
		{
			return;
		}
		// End:0x1CD
		if(((m_bHearInvestigate && (int(eType) == int(1))) || (m_bHearThreat && (int(eType) == int(2)))))
		{
			GotoPointAndSearch(NoiseMaker.Location, 4, true, 30.0000000, 2);
			// End:0x13C
			if((m_bHearThreat && (int(eType) == int(2))))
			{
				// End:0xEE
				if((m_iChanceToDetectShooter < 80))
				{
					(m_iChanceToDetectShooter += 20);
				}
				// End:0x139
				if(m_pawn.IsEnemy(NoiseMaker.Instigator))
				{
					// End:0x139
					if(((Rand(100) + 1) < m_iChanceToDetectShooter))
					{
						SetEnemy(NoiseMaker.Instigator);
						GotoStateAimedFire();
					}
				}				
			}
			else
			{
				// End:0x1CA
				if((VSize((NoiseMaker.Location - m_pawn.Location)) < float(500)))
				{
					m_pawn.m_bWantsToProne = false;
					// End:0x1AA
					if(((!m_pawn.m_bPreventCrouching) && (Rand(4) != 0)))
					{
						m_pawn.bWantsToCrouch = true;
					}
					FocalPoint = NoiseMaker.Location;
					GotoState('Sniping', 'CheckBehind');
				}
			}			
		}
		else
		{
			// End:0x225
			if((m_bHearGrenade && (int(eType) == int(3))))
			{
				// End:0x211
				if((!m_bHeardGrenade))
				{
					m_VoicesManager.PlayTerroristVoices(m_pawn, 5);
					m_bHeardGrenade = true;
				}
				ReactToGrenade(NoiseMaker.Location);
			}
		}
		return;
	}
Begin:

	// End:0x22
	if((R6DZonePoint(m_pawn.m_DZone) == none))
	{
		SetLowestSnipingStance();		
	}
	else
	{
		switch(R6DZonePoint(m_pawn.m_DZone).m_eStance)
		{
			// End:0x6A
			case 1:
				m_pawn.m_bWantsToProne = false;
				m_pawn.bWantsToCrouch = false;
				// End:0xC1
				break;
			// End:0x94
			case 2:
				m_pawn.m_bWantsToProne = false;
				m_pawn.bWantsToCrouch = true;
				// End:0xC1
				break;
			// End:0xBE
			case 3:
				m_pawn.m_bWantsToProne = true;
				m_pawn.bWantsToCrouch = false;
				// End:0xC1
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	stop;
LostTrackOfEnemy:


	Sleep(RandRange(3.0000000, 7.0000000));
	ChangeOrientationTo(m_pawn.m_DZone.Rotation);
	FinishRotation();
	GotoStateNoThreat();
CheckBehind:


	FinishRotation();
	Sleep(RandRange(1.0000000, 3.0000000));
	ChangeOrientationTo((m_pawn.Rotation + rot(0, 10000, 0)));
	Sleep(RandRange(1.0000000, 2.0000000));
	ChangeOrientationTo((m_pawn.Rotation + rot(0, -20000, 0)));
	Sleep(RandRange(1.0000000, 2.0000000));
	ChangeOrientationTo(m_pawn.m_DZone.Rotation);
	FinishRotation();
	GotoStateNoThreat();
	stop;		
}

// Terrorist have seen a freed hostage or civilian
state FindHostage
{
	function BeginState()
	{
		SetReactionStatus(2, 3);
		return;
	}

	function EndState()
	{
		Focus = none;
		FocalPoint = Enemy.Location;
		return;
	}

	event bool NotifyBump(Actor Other)
	{
		// End:0x1B
		if((Other == Enemy))
		{
			GotoState('FindHostage', 'Begin');
		}
		return global.NotifyBump(Other);
		return;
	}
Begin:

	StopMoving();
	SetEnemy(m_Hostage);
	LastSeenTime = Level.TimeSeconds;
	LastSeenPos = Enemy.Location;
	Focus = m_Hostage;
AskToSurrender:


	m_HostageAI.Order_Surrender(m_pawn);
	// Play a yell animation while ordering the hostage to surrender
	Pawn.PlayAnim('StandYellAlarm');
	FinishAnim();
	m_iRandomNumber = Rand(100);
	// End:0x93
	// 50% chance to re-ask, 40% chance to pursue (Rand < 90), 10% chance to shoot
	if((m_iRandomNumber < 50))
	{
		Sleep(2.0000000);
		goto 'AskToSurrender';		
	}
	else
	{
		// End:0xA8
		if((m_iRandomNumber < 90))
		{
			goto 'Pursues';			
		}
		else
		{
			goto 'AimedFire';
		}
	}
	J0xAE:

	// End:0x13F
	if((CanSee(m_Hostage) && m_Hostage.IsAlive()))
	{
		// End:0xE6
		if(actorReachable(Enemy))
		{
			MoveTarget = Enemy;			
		}
		else
		{
			MoveTarget = FindPathToward(Enemy);
		}
		// End:0x10A
		if((MoveTarget == none))
		{
			Sleep(1.0000000);			
		}
		else
		{
			R6PreMoveTo(MoveTarget.Location, MoveTarget.Location, 5);
			MoveToward(MoveTarget);
		}
		goto 'Pursues';		
	}
	else
	{
		// End:0x158
		if(pointReachable(LastSeenPos))
		{
			Destination = LastSeenPos;			
		}
		else
		{
			MoveTarget = FindPathTo(LastSeenPos);
			Destination = MoveTarget.Location;
		}
		R6PreMoveTo(Destination, Destination, 5);
		MoveTo(Destination);
		GotoStateEngageBySound(LastSeenPos, 5, 15.0000000);
	}
	J0x1A6:

	GotoStateAimedFire();
	stop;			
}

state FollowPawn
{
	function BeginState()
	{
		SetReactionStatus(m_eReactionStatus, m_eStateForEvent);
		return;
	}

	function EndState()
	{
		Focus = none;
		return;
	}

	function Vector GetFollowDestination()
	{
		local float fDist;
		local Vector vDir, vTargetPos;
		local Rotator rOrientation;

		// End:0x4B
		// iFollowYaw == 0: walk directly in line behind the followed pawn
		if((m_iFollowYaw == 0))
		{
			vTargetPos = (m_pawnToFollow.Location + (Normal((Pawn.Location - m_pawnToFollow.Location)) * m_fFollowDist));			
		}
		else
		{
			// Offset by iFollowYaw angle (e.g. 16384 = 90° left, 49152 = 90° right in Unreal rotation units)
			rOrientation.Yaw = (m_pawnToFollow.Rotation.Yaw + m_iFollowYaw);
			vTargetPos = (m_pawnToFollow.Location - (Vector(rOrientation) * m_fFollowDist));
		}
		FindSpot(vTargetPos);
		return vTargetPos;
		return;
	}
Moving:

	// End:0x1A
	if((!m_pawnToFollow.IsAlive()))
	{
		GotoStateNoThreat();
	}
	m_fPawnDistance = DistanceTo(m_pawnToFollow);
	// End:0x9C
	if((m_fPawnDistance < (m_fFollowDist + Pawn.CollisionRadius)))
	{
		StopMoving();
		// End:0x8E
		if(((int(m_eFollowMode) == int(1)) && R6Terrorist(m_pawnToFollow).m_controller.m_bWaiting))
		{
			GotoState('PatrolPath', 'ReachedNode');
		}
		Sleep(0.2000000);
		goto 'Moving';
	}
	m_vMovingDestination = GetFollowDestination();
	m_pawn.m_eMovementPace = 4;
	// End:0xF3
	if((!pointReachable(m_vMovingDestination)))
	{
		MoveTarget = FindPathTo(m_vMovingDestination);
		// End:0xF3
		if((MoveTarget != none))
		{
			m_vMovingDestination = MoveTarget.Location;
		}
	}
	// End:0x113
	if((m_fPawnDistance > 500.0000000))
	{
		m_pawn.m_eMovementPace = 5;
	}
	R6PreMoveTo(m_vMovingDestination, m_vMovingDestination, m_pawn.m_eMovementPace);
	MoveTo(m_vMovingDestination);
	goto 'Moving';
	stop;				
}

state PatrolArea
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		m_pawn.m_bAvoidFacingWalls = true;
		return;
	}

	function EndState()
	{
		m_pawn.m_wWantedHeadYaw = 0;
		m_pawn.m_bAvoidFacingWalls = false;
		return;
	}
Begin:

	m_pawn.m_eMovementPace = 4;
ChooseDestination:


	m_vTargetPosition = m_pawn.m_DZone.FindRandomPointInArea();
	GotoStateMovingTo("PatrolArea", 4, true,, m_vTargetPosition, 'PatrolArea', 'AtDestination');
AtDestination:


	// End:0x16D
	if((Rand(3) != 0))
	{
		// End:0xE2
		if((Rand(2) == 0))
		{
			m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
			Sleep(RandRange(1.0000000, 2.5000000));
			m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
			Sleep(RandRange(1.0000000, 2.5000000));			
		}
		else
		{
			m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
			Sleep(RandRange(1.0000000, 2.5000000));
			m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
			Sleep(RandRange(1.0000000, 2.5000000));
		}
		m_pawn.m_wWantedHeadYaw = 0;
	}
	Sleep(RandRange(1.0000000, 2.0000000));
	goto 'ChooseDestination';
	stop;	
}

state PatrolPath
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}

	function EndState()
	{
		m_pawn.m_wWantedHeadYaw = 0;
		m_pawn.m_bAvoidFacingWalls = false;
		m_pawn.ClearChannel(m_pawn.16);
		return;
	}
Begin:

	// End:0x15
	if((m_PatrolCurrentLabel != 'None'))
	{
		goto m_PatrolCurrentLabel;
	}
	FinishedWaiting();
	stop;
ReachedNode:


	m_PatrolCurrentLabel = 'ReachedNode';
	ReachedTheNode();
	stop;
WaitingAtNode:


	m_PatrolCurrentLabel = 'WaitingAtNode';
	StopMoving();
	ChangeOrientationTo(m_rStandRotation);
	FinishRotation();
	// End:0x8D
	if(m_currentNode.bDirectional)
	{
		m_pawn.m_wWantedAimingPitch = byte((m_currentNode.Rotation.Pitch / 256));		
	}
	else
	{
		m_pawn.m_bAvoidFacingWalls = true;
	}
	// End:0x13B
	if((m_currentNode.m_AnimToPlay != 'None'))
	{
		// End:0x13B
		if((Rand(100) < m_currentNode.m_AnimChance))
		{
			// End:0xFF
			if((m_currentNode.m_SoundToPlay != none))
			{
				m_pawn.PlayVoices(m_currentNode.m_SoundToPlay, 6, 15);
			}
			m_pawn.m_szSpecialAnimName = m_currentNode.m_AnimToPlay;
			m_pawn.SetNextPendingAction(35);
			FinishAnim(m_pawn.16);
		}
	}
	// End:0x194
	if(((m_fWaitingTime > float(0)) && (int(m_pawn.m_eDefCon) <= int(2))))
	{
		// End:0x194
		if(((!m_pawn.m_bPreventCrouching) && (Rand(2) == 0)))
		{
			m_pawn.bWantsToCrouch = true;
		}
	}
	// End:0x1E2
	if((m_fFacingTime < m_fWaitingTime))
	{
		Sleep(m_fFacingTime);
		m_pawn.m_wWantedAimingPitch = 0;
		ChangeOrientationTo(ChooseRandomDirection(-1));
		Sleep((m_fWaitingTime - m_fFacingTime));
		FinishRotation();		
	}
	else
	{
		// End:0x311
		if(((!m_currentNode.bDirectional) && (Rand(3) != 0)))
		{
			// End:0x27F
			if((Rand(2) == 0))
			{
				m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
				Sleep((m_fWaitingTime / float(3)));
				m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
				Sleep((m_fWaitingTime / float(3)));				
			}
			else
			{
				m_pawn.m_wWantedHeadYaw = byte((RandRange(-10000.0000000, -5000.0000000) / float(256)));
				Sleep((m_fWaitingTime / float(3)));
				m_pawn.m_wWantedHeadYaw = byte((RandRange(5000.0000000, 10000.0000000) / float(256)));
				Sleep((m_fWaitingTime / float(3)));
			}
			m_pawn.m_wWantedHeadYaw = 0;
			Sleep((m_fWaitingTime / float(3)));			
		}
		else
		{
			Sleep(m_fWaitingTime);
		}
		m_pawn.m_wWantedAimingPitch = 0;
	}
	FinishedWaiting();
	m_pawn.m_bAvoidFacingWalls = false;
	m_pawn.bWantsToCrouch = false;
	stop;	
}

state HuntRainbow
{
	function BeginState()
	{
		SetReactionStatus(0, 0);
		return;
	}

	function R6Pawn GetClosestEnemy()
	{
		local R6Pawn aEnemy, aClosestEnemy;
		local float fDist, fBestDist;

		// End:0x96
		foreach DynamicActors(Class'R6Engine.R6Pawn', aEnemy)
		{
			// End:0x95
			if((m_pawn.IsEnemy(aEnemy) && aEnemy.IsAlive()))
			{
				fDist = VSize((aEnemy.Location - Pawn.Location));
				// End:0x95
				if(((fDist < fBestDist) || (fBestDist == float(0))))
				{
					fBestDist = fDist;
					aClosestEnemy = aEnemy;
				}
			}			
		}		
		return aClosestEnemy;
		return;
	}
FindNewEnemy:

	// End:0x28
	if(((m_huntedPawn != none) && (!m_huntedPawn.IsAlive())))
	{
		m_huntedPawn = none;
	}
	// End:0x42
	if((m_huntedPawn == none))
	{
		SetEnemy(GetClosestEnemy());		
	}
	else
	{
		SetEnemy(m_huntedPawn);
	}
	J0x4D:

	// End:0xB6
	if(((R6Pawn(Enemy) != none) && R6Pawn(Enemy).IsAlive()))
	{
		MoveTarget = FindPathToward(Enemy);
		// End:0xB6
		if((MoveTarget != none))
		{
			GotoStateMovingTo("HuntRainbow", 4, true, MoveTarget,, 'HuntRainbow', 'nextNode', true);
		}
	}
	Sleep(1.0000000);
	goto 'FindNewEnemy';
	stop;			
}

state PA_PlayAnim
{
	function EndState()
	{
		m_pawn.SetNextPendingAction(37);
		super(PA_Interaction).EndState();
		return;
	}
Begin:

	m_pawn.m_szSpecialAnimName = m_AnimName;
	m_pawn.SetNextPendingAction(35);
	FinishAnim(m_pawn.16);
	AnimBlendToAlpha(m_pawn.16, 0.0000000, 0.5000000);
	m_pawn.m_ePlayerIsUsingHands = 0;
	m_pawn.PlayWeaponAnimation();
	m_pawn.m_bPawnSpecificAnimInProgress = false;
	m_InteractionObject.FinishAction();
	stop;	
}

state PA_LoopAnim
{
	function BeginState()
	{
		m_fSearchTime = (Level.TimeSeconds + m_fLoopAnimTime);
		super(Object).BeginState();
		return;
	}

	function EndState()
	{
		m_pawn.SetNextPendingAction(37);
		super(PA_Interaction).EndState();
		return;
	}
Begin:

	m_pawn.m_szSpecialAnimName = m_AnimName;
	m_pawn.SetNextPendingAction(36);
	// End:0x3F
	if((m_fLoopAnimTime != 0.0000000))
	{
		Sleep(m_fLoopAnimTime);		
	}
	else
	{
		stop;
	}
	m_InteractionObject.FinishAction();
	stop;				
}

defaultproperties
{
	bIsPlayer=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_aLastNodeC_NumberOfNodeRemembered
// REMOVED IN 1.60: function SetView
// REMOVED IN 1.60: function GetEngageReaction
