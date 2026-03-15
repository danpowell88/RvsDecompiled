//=============================================================================
// R6RainbowAI - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6RainbowAI.uc : (Rainbow 6 Base Class) This is the AI Controller class for 
//                   all non player members of the Rainbow team.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/01 * Created by Rima Brek
//=============================================================================
class R6RainbowAI extends R6AIController
    native;

enum eFormation
{
	FORM_SingleFile,                // 0
	FORM_SingleFileWallBothSides,   // 1
	FORM_SingleFileWallRight,       // 2
	FORM_SingleFileWallLeft,        // 3
	FORM_SingleFileNoWalls,         // 4
	FORM_OrientedSingleFile,        // 5
	FORM_Diamond                    // 6
};

enum ePawnOrientation
{
	PO_Front,                       // 0
	PO_FrontRight,                  // 1
	PO_Right,                       // 2
	PO_Left,                        // 3
	PO_FrontLeft,                   // 4
	PO_Back,                        // 5
	PO_PeekLeft,                    // 6
	PO_PeekRight                    // 7
};

enum eCoverDirection
{
	COVER_Left,                     // 0
	COVER_Center,                   // 1
	COVER_Right,                    // 2
	COVER_None                      // 3
};

// NEW IN 1.60
var R6RainbowAI.eFormation m_eFormation;
// NEW IN 1.60
var R6RainbowAI.ePawnOrientation m_ePawnOrientation;
var R6Door.eRoomLayout m_eCurrentRoomLayout;
// NEW IN 1.60
var R6RainbowAI.eCoverDirection m_eCoverDirection;
var int m_iStateProgress;
// -- MOVEMENT attributes -- //
var int m_iTurn;  // used to allow a member walking backwards to turn around periodically
var int m_iWaitCounter;
var int m_iActionUseGadgetGroup;
var bool m_bTeamMateHasBeenKilled;
var bool m_bIsCatchingUp;
var bool m_bIsMovingBackwards;
var bool m_bSlowedPace;
var bool m_bAlreadyWaiting;
var bool m_bReactToNoise;
var bool m_bUseStaggeredFormation;
var bool m_bWeaponsDry;
var bool m_bAimingWeaponAtEnemy;
var bool m_bEnteredRoom;
var bool m_bIndividualAttacks;
var bool m_bStateFlag;  // for miscellaneous usage
var bool m_bReorganizationPending;
var float m_fLastReactionToGas;
var float m_fGrenadeDangerRadius;
var float m_fAttackTimerRate;  // Timer event, 0=no timer.
var float m_fAttackTimerCounter;  // Counts up until it reaches m_fAttackTimerRate.
var float m_fFiringAttackTimer;
var R6Rainbow m_pawn;
var R6RainbowTeam m_TeamManager;
var R6Rainbow m_TeamLeader;  // it might be sufficient to hold this info in the teamManager
var R6Rainbow m_PaceMember;  // this is the member that is directly ahead of this controller's pawn.
var Actor m_NextMoveTarget;
var R6IORotatingDoor m_RotatingDoor;
// -- INTERACTION attributes -- //
var Actor m_ActionTarget;
var Actor m_DesiredTarget;
var R6CommonRainbowVoices m_CommonMemberVoicesMgr;
var name m_PostFindPathToState;
var name m_PostLockPickState;
var Vector m_vLocationOnTarget;  // location on target to aim at
var Vector m_vGrenadeLocation;
var Vector m_vDesiredLocation;
var Vector m_vNoiseFocalPoint;
var Vector m_vPreEntryPositions[2];

// Export UR6RainbowAI::execGetTargetPosition(FFrame&, void* const)
native(2202) final function Vector GetTargetPosition();

// Export UR6RainbowAI::execGetLadderPosition(FFrame&, void* const)
native(2203) final function Vector GetLadderPosition();

// Export UR6RainbowAI::execGetGuardPosition(FFrame&, void* const)
native(2204) final function Vector GetGuardPosition();

// Export UR6RainbowAI::execGetEntryPosition(FFrame&, void* const)
native(2205) final function Vector GetEntryPosition(bool bInsideRoom);

// Export UR6RainbowAI::execCheckEnvironment(FFrame&, void* const)
native(2206) final function Vector CheckEnvironment();

// Export UR6RainbowAI::execSetOrientation(FFrame&, void* const)
native(2207) final function SetOrientation(optional R6RainbowAI.ePawnOrientation eOverrideOrientation);

// Export UR6RainbowAI::execLookAroundRoom(FFrame&, void* const)
native(2219) final function LookAroundRoom(bool bIsLeadingRoomEntry);

// Export UR6RainbowAI::execFindSafeSpot(FFrame&, void* const)
native(2221) final function Actor FindSafeSpot();

// Export UR6RainbowAI::execAClearShotIsAvailable(FFrame&, void* const)
native(2222) final function bool AClearShotIsAvailable(Pawn PTarget, Vector vStart);

// Export UR6RainbowAI::execClearToSnipe(FFrame&, void* const)
native(2223) final function bool ClearToSnipe(Vector vStart, Rotator rSnipingDir);

//------------------------------------------------------------------
// Possess()
//   BEWARE : could this cause a problem when changing pawns?
//------------------------------------------------------------------
function Possess(Pawn aPawn)
{
	super.Possess(aPawn);
	m_pawn = R6Rainbow(aPawn);
	m_pawn.bRotateToDesired = true;
	PlayerReplicationInfo = none;
	aPawn.PlayerReplicationInfo = none;
	return;
}

event PostBeginPlay()
{
	super(Controller).PostBeginPlay();
	// End:0x3E
	if((int(Role) == int(ROLE_Authority)))
	{
		m_CommonMemberVoicesMgr = R6CommonRainbowVoices(R6AbstractGameInfo(Level.Game).GetCommonRainbowMemberVoicesMgr());
	}
	return;
}

//------------------------------------------------------------------
// UpdatePosture()                                         
//------------------------------------------------------------------
function UpdatePosture()
{
	// End:0xF3
	if(((!m_PaceMember.m_bPostureTransition) && ((m_PaceMember.m_bIsProne != Pawn.m_bIsProne) || (m_PaceMember.bIsCrouched != Pawn.bIsCrouched))))
	{
		// End:0x9A
		if((m_PaceMember.m_bIsProne && (!m_PaceMember.m_bIsSniping)))
		{
			Pawn.m_bWantsToProne = true;			
		}
		else
		{
			// End:0xD1
			if(m_PaceMember.bIsCrouched)
			{
				Pawn.bWantsToCrouch = true;
				Pawn.m_bWantsToProne = false;				
			}
			else
			{
				Pawn.bWantsToCrouch = false;
				Pawn.m_bWantsToProne = false;
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// PostureHasChanged()                                         
//------------------------------------------------------------------
function bool PostureHasChanged()
{
	// End:0x25
	if((Pawn.m_bIsProne != Pawn.m_bWantsToProne))
	{
		return true;
	}
	// End:0x39
	if(Pawn.m_bIsProne)
	{
		return false;
	}
	// End:0x5E
	if((Pawn.bIsCrouched != Pawn.bWantsToCrouch))
	{
		return true;
	}
	return false;
	return;
}

// NEW IN 1.60
function FreeBackupPromote()
{
	return;
}

//------------------------------------------------------------------
// R6SetMovement()                                         
//------------------------------------------------------------------
function R6SetMovement(R6Pawn.eMovementPace ePace)
{
	local bool bIndependantPace;

	// End:0x55
	if((int(ePace) == 0))
	{
		bIndependantPace = false;
		// End:0x2F
		if(((m_PaceMember == none) || (m_TeamLeader == none)))
		{
			return;
		}
		UpdatePosture();
		m_pawn.m_eMovementPace = m_PaceMember.m_eMovementPace;		
	}
	else
	{
		bIndependantPace = true;
		// End:0x97
		if(((!Pawn.m_bIsProne) && (int(ePace) == int(1))))
		{
			Pawn.m_bWantsToProne = true;			
		}
		else
		{
			// End:0xE0
			if((Pawn.m_bIsProne && (int(ePace) != int(1))))
			{
				Pawn.m_bWantsToProne = false;
				Pawn.bWantsToCrouch = true;				
			}
			else
			{
				// End:0x128
				if(Pawn.bIsCrouched)
				{
					// End:0x125
					if(((int(ePace) == int(4)) || (int(ePace) == int(5))))
					{
						Pawn.bWantsToCrouch = false;
					}					
				}
				else
				{
					// End:0x15B
					if(((int(ePace) == int(2)) || (int(ePace) == int(3))))
					{
						Pawn.bWantsToCrouch = true;
					}
				}
			}
		}
		m_pawn.m_eMovementPace = ePace;
	}
	// End:0x212
	if(((m_TeamLeader == none) || bIndependantPace))
	{
		// End:0x1CC
		if(((int(m_pawn.m_eMovementPace) == int(4)) || (int(m_pawn.m_eMovementPace) == int(2))))
		{
			Pawn.SetWalking(true);			
		}
		else
		{
			// End:0x210
			if(((int(m_pawn.m_eMovementPace) == int(5)) || (int(m_pawn.m_eMovementPace) == int(3))))
			{
				Pawn.SetWalking(false);
			}
		}
		return;
	}
	// End:0x2A3
	if(((!m_PaceMember.IsMovingForward()) && (!Pawn.m_bIsProne)))
	{
		// End:0x259
		if(m_PaceMember.bIsWalking)
		{
			m_bSlowedPace = true;			
		}
		else
		{
			// End:0x287
			if(m_PaceMember.bIsCrouched)
			{
				m_bSlowedPace = true;
				m_pawn.m_eMovementPace = 2;				
			}
			else
			{
				m_bSlowedPace = false;
				m_pawn.m_eMovementPace = 4;
			}
		}		
	}
	else
	{
		m_bSlowedPace = false;
	}
	// End:0x2E4
	if(((int(m_pawn.m_eHealth) == int(1)) && (!m_bIsMovingBackwards)))
	{
		Pawn.SetWalking(true);		
	}
	else
	{
		// End:0x37D
		if(((int(m_pawn.m_eMovementPace) == int(4)) || (int(m_pawn.m_eMovementPace) == int(2))))
		{
			// End:0x36A
			if((((!m_bSlowedPace) && (DistanceTo(m_PaceMember) > (float(2) * GetFormationDistance()))) && (!m_TeamManager.m_bTeamIsSeparatedFromLeader)))
			{
				Pawn.SetWalking(false);				
			}
			else
			{
				Pawn.SetWalking(true);
			}			
		}
		else
		{
			// End:0x3C1
			if(((int(m_pawn.m_eMovementPace) == int(5)) || (int(m_pawn.m_eMovementPace) == int(3))))
			{
				Pawn.SetWalking(false);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// R6PreMoveTo()                                           
//   ePace is optional so for NPC members who's pace should be set  
//   according to team leader...                                    
//------------------------------------------------------------------
function R6PreMoveTo(Vector vTargetPosition, Vector vFocus, optional R6Pawn.eMovementPace ePace)
{
	// End:0x1D
	if(Pawn.m_bTryToUnProne)
	{
		ePace = 1;		
	}
	else
	{
		// End:0x37
		if(Pawn.bTryToUncrouch)
		{
			ePace = 2;
		}
	}
	R6SetMovement(ePace);
	Focus = none;
	FocalPoint = vFocus;
	Destination = vTargetPosition;
	return;
}

//------------------------------------------------------------------
// R6PreMoveToward()                                       
//   ePace is optional so for NPC members who's pace should be set  
//   according to team leader...                                    
//------------------------------------------------------------------
function R6PreMoveToward(Actor Target, Actor pFocus, optional R6Pawn.eMovementPace ePace)
{
	// End:0x1D
	if(Pawn.m_bTryToUnProne)
	{
		ePace = 1;		
	}
	else
	{
		// End:0x37
		if(Pawn.bTryToUncrouch)
		{
			ePace = 2;
		}
	}
	R6SetMovement(ePace);
	Focus = none;
	FocalPoint = pFocus.Location;
	Destination = Target.Location;
	return;
}

//------------------------------------------------------------------
// ResetStateProgress()                                       
//------------------------------------------------------------------
function ResetStateProgress()
{
	m_iStateProgress = 0;
	return;
}

//------------------------------------------------------------------
// CanClimbLadders()                                       
//------------------------------------------------------------------
function bool CanClimbLadders(R6Ladder Ladder)
{
	// End:0x17
	if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
	{
		return true;		
	}
	else
	{
		return R6Pawn(Pawn).m_bAutoClimbLadders;
	}
	return;
}

//------------------------------------------------------------------
// CanSeeGrenade()                                       
//------------------------------------------------------------------
function bool CanSeeGrenade(Vector vGrenadeLocation)
{
	local Vector vDir;

	vDir = (vGrenadeLocation - Pawn.Location);
	vDir.Z = 0.0000000;
	// End:0x3D
	if((VSize(vDir) < float(100)))
	{
		return true;
	}
	vDir = (vGrenadeLocation - Pawn.Location);
	// End:0xA4
	if(((Dot(Normal(vDir), Vector(Pawn.Rotation)) - Pawn.PeripheralVision) > float(0)))
	{
		// End:0xA4
		if(FastTrace(Pawn.Location, vGrenadeLocation))
		{
			return true;
		}
	}
	return false;
	return;
}

//------------------------------------------------------------------
// FragGrenadeInProximity()                                       
//------------------------------------------------------------------
function FragGrenadeInProximity(Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius)
{
	// End:0x21
	if((m_pawn.m_bIsClimbingLadder || IsInState('RunAwayFromGrenade')))
	{
		return;
	}
	// End:0x66
	if((m_pawn.IsAlive() && CanSeeGrenade(vGrenadeLocation)))
	{
		m_TeamManager.GrenadeInProximity(m_pawn, vGrenadeLocation, fTimeLeft, fGrenadeDangerRadius);
	}
	return;
}

//------------------------------------------------------------------
// ReactToFragGrenade()                                       
//------------------------------------------------------------------
function ReactToFragGrenade(Vector vGrenadeLocation, float fTimeLeft, float fGrenadeDangerRadius)
{
	// End:0x52
	if(((m_pawn.m_bIsClimbingLadder || (int(Pawn.Physics) == int(11))) || (VSize((vGrenadeLocation - Pawn.Location)) > fGrenadeDangerRadius)))
	{
		return;
	}
	m_vGrenadeLocation = vGrenadeLocation;
	m_fGrenadeDangerRadius = fGrenadeDangerRadius;
	GotoState('RunAwayFromGrenade');
	SetTimer(fTimeLeft, false);
	return;
}

//------------------------------------------------------------------
// PlaySoundAffectedByGrenade()                                       
//------------------------------------------------------------------
function PlaySoundAffectedByGrenade(Pawn.EGrenadeType eType)
{
	switch(eType)
	{
		// End:0x6D
		case 1:
			// End:0x4B
			if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
			{
				m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, 3);				
			}
			else
			{
				m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 19);
			}
			// End:0x167
			break;
		// End:0x164
		case 2:
			// End:0xB1
			if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
			{
				m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, 4);				
			}
			else
			{
				m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 20);
				// End:0x161
				if((m_TeamManager.m_bPlayerHasFocus || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
				{
					// End:0x161
					if(m_TeamManager.m_bFirstTimeInGas)
					{
						m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, 10);
						m_TeamManager.m_bFirstTimeInGas = false;
						m_TeamManager.SetTimer(60.0000000, false);
					}
				}
			}
			// End:0x167
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
	// End:0x94
	if((int(eType) == int(2)))
	{
		// End:0x39
		if(m_pawn.m_bPawnSpecificAnimInProgress)
		{
			m_fLastReactionToGas = Level.TimeSeconds;			
		}
		else
		{
			m_TeamManager.GasGrenadeInProximity(m_pawn);
			// End:0x91
			if((m_fLastReactionToGas < (Level.TimeSeconds - 2.0000000)))
			{
				m_fLastReactionToGas = Level.TimeSeconds;
				m_pawn.SetNextPendingAction(1);
			}
		}		
	}
	else
	{
		// End:0xD7
		if((int(eType) == int(3)))
		{
			// End:0xD7
			if((IsFacing(aGrenade) && m_pawn.IsStationary()))
			{
				m_pawn.SetNextPendingAction(3);
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// PlaySoundInflictedDamage()                                       
//------------------------------------------------------------------
function PlaySoundInflictedDamage(Pawn DeadPawn)
{
	switch(R6Pawn(DeadPawn).m_ePawnType)
	{
		// End:0xA3
		case 2:
			// End:0x59
			if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
			{
				m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, 0);				
			}
			else
			{
				// End:0xA0
				if(((m_TeamManager.m_OtherTeamVoicesMgr != none) && m_pawn.m_bIsSniping))
				{
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 2);
				}
			}
			// End:0xA6
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

//------------------------------------------------------------------
// PlaySoundActionCompleted()                                       
//------------------------------------------------------------------
function PlaySoundActionCompleted(R6Pawn.eDeviceAnimToPlay eAnimToPlay)
{
	// End:0xC2
	if((int(Level.NetMode) == int(NM_Standalone)))
	{
		// End:0xC2
		if(((!m_TeamManager.m_bLeaderIsAPlayer) && (!m_TeamManager.m_bPlayerHasFocus)))
		{
			switch(eAnimToPlay)
			{
				// End:0x71
				case 2:
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, 9);
					// End:0xC2
					break;
				// End:0x98
				case 3:
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, 1);
					// End:0xC2
					break;
				// End:0xBF
				case 4:
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, 3);
					// End:0xC2
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
		}/* !MISMATCHING REMOVE, tried If got Type:Else Position:0x0C2! */
		// End:0x16E
		if(((int(Level.NetMode) != int(NM_Standalone)) || m_TeamManager.m_bPlayerHasFocus))
		{
			switch(eAnimToPlay)
			{
				// End:0x11D
				case 2:
					m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, 9);
					// End:0x16E
					break;
				// End:0x144
				case 3:
					m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, 1);
					// End:0x16E
					break;
				// End:0x16B
				case 4:
					m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, 3);
					// End:0x16E
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
			return;
		}
	}/* !MISMATCHING REMOVE, tried Else got Type:If Position:0x000! */
}

//------------------------------------------------------------------
// PlaySoundCurrentAction()                                       
//------------------------------------------------------------------
function PlaySoundCurrentAction(Pawn.ERainbowTeamVoices eVoices)
{
	// End:0xBA
	if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
	{
		// End:0x88
		if((m_TeamManager.m_bPlayerHasFocus || Level.IsGameTypeCooperative(Level.Game.m_szGameTypeFlag)))
		{
			m_TeamManager.m_MultiCoopMemberVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);			
		}
		else
		{
			// End:0xB7
			if((int(eVoices) == int(5)))
			{
				m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 23);
			}
		}		
	}
	else
	{
		m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, eVoices);
	}
	return;
}

//------------------------------------------------------------------
// PlaySoundDamage()                                       
//------------------------------------------------------------------
function PlaySoundDamage(Pawn instigatedBy)
{
	m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, 1);
	// End:0x16B
	if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
	{
		switch(m_pawn.m_eHealth)
		{
			// End:0x51
			case 2:
			// End:0xEC
			case 3:
				// End:0xE9
				if((m_TeamManager.m_iMemberCount > 1))
				{
					m_CommonMemberVoicesMgr.PlayCommonRainbowVoices(m_pawn, 2);
					// End:0xBF
					if(m_TeamManager.m_bLeaderIsAPlayer)
					{
						m_TeamManager.m_PlayerVoicesMgr.PlayRainbowPlayerVoices(m_TeamManager.m_Team[0], 42);						
					}
					else
					{
						m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_TeamManager.m_Team[0], 13);
					}
				}
				// End:0x168
				break;
			// End:0x165
			case 1:
				// End:0x162
				if((instigatedBy != none))
				{
					switch(R6Pawn(instigatedBy).m_ePawnType)
					{
						// End:0x138
						case 1:
							m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 24);
							// End:0x162
							break;
						// End:0x15F
						case 2:
							m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 17);
							// End:0x162
							break;
						// End:0xFFFF
						default:
							break;
					}
				}
				else
				{
					// End:0x168
					break;/* !MISMATCHING REMOVE, tried Case got Type:Else Position:0x162! */
				// End:0xFFFF
				default:
					break;
			}/* !MISMATCHING REMOVE, tried Switch got Type:Case Position:0x0EC! */			
		}/* !MISMATCHING REMOVE, tried If got Type:Switch Position:0x03C! */
		else
		{
			switch(m_pawn.m_eHealth)
			{
				// End:0x180
				case 2:
				// End:0x1DC
				case 3:
					// End:0x1D9
					if(((m_TeamManager.m_OtherTeamVoicesMgr != none) && (m_TeamManager.m_iMemberCount > 0)))
					{
						m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_TeamManager.m_Team[0], 3);
					}
					// End:0x231
					break;
				// End:0x22E
				case 1:
					// End:0x22B
					if(((instigatedBy != none) && (int(R6Pawn(instigatedBy).m_ePawnType) == int(1))))
					{
						m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 4);
					}
					// End:0x231
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		return;
	}/* !MISMATCHING REMOVE, tried Else got Type:If Position:0x016! */
}

//------------------------------------------------------------------
// CanBeSeen()                                         
//------------------------------------------------------------------
function bool CanBeSeen(Pawn seen)
{
	local Vector vSightDir;

	vSightDir = Normal((Pawn.Location - seen.Location));
	// End:0x53
	if((Dot(Vector(seen.GetViewRotation()), vSightDir) < Pawn.PeripheralVision))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// SetEnemy()                                         
//------------------------------------------------------------------
function SetEnemy(Pawn newEnemy)
{
	// End:0x23
	if((!m_pawn.m_bIsSniping))
	{
		m_TeamManager.RainbowIsEngagingEnemy();
	}
	Enemy = newEnemy;
	LastSeenTime = Level.TimeSeconds;
	// End:0x61
	if((Enemy != none))
	{
		LastSeenPos = Enemy.Location;
	}
	return;
}

//------------------------------------------------------------------
// PlayVoiceTerroristSpotted()                                         
//------------------------------------------------------------------
function PlayVoiceTerroristSpotted(R6Terrorist aTerro)
{
	// End:0x97
	if(((!aTerro.m_bEnteringView) && (m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus)))
	{
		// End:0x67
		if(m_bIsMovingBackwards)
		{
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 1);			
		}
		else
		{
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 0);
		}
		aTerro.m_bEnteringView = true;
	}
	return;
}

//------------------------------------------------------------------
// SeePlayer()                                             
//------------------------------------------------------------------
event SeePlayer(Pawn seen)
{
	local R6Pawn aPawn;

	aPawn = R6Pawn(seen);
	// End:0x21E
	if((m_pawn.IsEnemy(seen) && (aPawn.EngineWeapon != none)))
	{
		// End:0x4A
		if((m_TeamManager == none))
		{
			return;
		}
		// End:0xA1
		if((aPawn.m_bIsKneeling || (!aPawn.IsAlive())))
		{
			// End:0x9F
			if((!R6Terrorist(aPawn).m_bIsUnderArrest))
			{
				m_TeamManager.TeamSpottedSurrenderedTerrorist(aPawn);
			}
			return;
		}
		// End:0xB5
		if(aPawn.m_bDontKill)
		{
			return;
		}
		// End:0x104
		if((int(m_TeamManager.m_eMovementMode) == int(2)))
		{
			// End:0xF0
			if((!CanBeSeen(seen)))
			{
				PlayVoiceTerroristSpotted(R6Terrorist(aPawn));
				return;
			}
			m_TeamManager.m_eMovementMode = 0;			
		}
		else
		{
			// End:0x16E
			if((int(m_TeamManager.m_eMovementMode) == int(1)))
			{
				// End:0x13F
				if(CanBeSeen(seen))
				{
					m_TeamManager.m_eMovementMode = 0;					
				}
				else
				{
					// End:0x16E
					if((!Pawn.EngineWeapon.m_bIsSilenced))
					{
						PlayVoiceTerroristSpotted(R6Terrorist(aPawn));
						return;
					}
				}
			}
		}
		// End:0x17B
		if((Enemy != none))
		{
			return;
		}
		// End:0x186
		if(m_bWeaponsDry)
		{
			return;
		}
		// End:0x21B
		if((AClearShotIsAvailable(seen, m_pawn.GetFiringStartPoint()) && (int(Pawn.EngineWeapon.m_eWeaponType) != int(6))))
		{
			// End:0x21B
			if(((!m_bIndividualAttacks) || m_TeamManager.EngageEnemyIfNotAlreadyEngaged(m_pawn, aPawn)))
			{
				m_pawn.m_bEngaged = true;
				SetEnemy(seen);
				Target = Enemy;
				Enable('EnemyNotVisible');
			}
		}		
	}
	else
	{
		// End:0x295
		if(((((int(aPawn.m_ePawnType) == int(3)) && aPawn.IsAlive()) && (!R6Hostage(aPawn).m_bExtracted)) && (R6Hostage(aPawn).m_escortedByRainbow == none)))
		{
			m_TeamManager.m_HostageToRescue = aPawn;
		}
	}
	return;
}

//------------------------------------------------------------------
// IsANeutralPawnNoise()                                         
//------------------------------------------------------------------
function bool IsANeutralPawnNoise(Actor aNoiseMaker)
{
	local Pawn aPawn;

	aPawn = Pawn(aNoiseMaker);
	// End:0x2F
	if((aPawn == none))
	{
		aPawn = aNoiseMaker.Instigator;
	}
	// End:0x3C
	if((aPawn == none))
	{
		return false;
	}
	return m_pawn.IsNeutral(aPawn);
	return;
}

//------------------------------------------------------------------
// HearNoise()                                             
//------------------------------------------------------------------
event HearNoise(float Loudness, Actor aNoiseMaker, Actor.ENoiseType eType, optional Actor.ESoundType ESoundType)
{
	// End:0x0D
	if((m_TeamManager == none))
	{
		return;
	}
	// End:0x1D
	if(IsANeutralPawnNoise(aNoiseMaker))
	{
		return;
	}
	m_TeamManager.TeamHearNoise(aNoiseMaker);
	// End:0x4C
	if((int(m_TeamManager.m_eMovementMode) == int(0)))
	{
		return;
	}
	// End:0xA6
	if(((int(eType) == int(2)) || (int(eType) == int(3))))
	{
		// End:0xA6
		if((int(R6Pawn(aNoiseMaker.Owner).m_ePawnType) != int(1)))
		{
			m_TeamManager.m_eMovementMode = 0;
		}
	}
	return;
}

//------------------------------------------------------------------
// EnemyNotVisible()                                       
//------------------------------------------------------------------
event EnemyNotVisible()
{
	// End:0x21
	if(((Level.TimeSeconds - LastSeenTime) < 0.5000000))
	{
		return;
	}
	StopFiring();
	EndAttack();
	Disable('EnemyNotVisible');
	return;
}

//------------------------------------------------------------------
// IsBeingAttacked()                                       
//------------------------------------------------------------------
function IsBeingAttacked(Pawn attacker)
{
	// End:0x76
	if(m_pawn.IsEnemy(attacker))
	{
		// End:0x76
		if((Enemy == none))
		{
			m_pawn.ResetBoneRotation();
			Pawn.DesiredRotation = Rotator((attacker.Location - Pawn.Location));
			Focus = attacker;
			Enemy = attacker;
		}
	}
	return;
}

//------------------------------------------------------------------
// EnemyIsStillAThreat()                                   
//------------------------------------------------------------------
function bool EnemyIsAThreat()
{
	// End:0x0D
	if((Enemy == none))
	{
		return false;
	}
	// End:0x41
	if((R6Pawn(Enemy).m_bIsKneeling || (!R6Pawn(Enemy).IsAlive())))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// SetGunDirection - 
//------------------------------------------------------------------
function SetGunDirection(Actor aTarget)
{
	local Rotator rDirection;
	local Vector vDirection;
	local Coords cTarget;
	local Vector vTarget;

	// End:0x174
	if((aTarget != none))
	{
		// End:0x2D
		if((aTarget == self))
		{
			vTarget = aTarget.Location;			
		}
		else
		{
			// End:0x52
			if((aTarget == Enemy))
			{
				vTarget = LastSeenPos;
				m_bAimingWeaponAtEnemy = true;				
			}
			else
			{
				cTarget = aTarget.GetBoneCoords('R6 Spine');
				vTarget = cTarget.Origin;
			}
		}
		// End:0x9E
		if((aTarget == self))
		{
			rDirection = aTarget.Rotation;			
		}
		else
		{
			vDirection = (vTarget - m_pawn.GetFiringStartPoint());
			rDirection = Rotator(vDirection);
		}
		m_pawn.m_u8DesiredPitch = byte((int(byte((rDirection.Pitch & 65535))) / 256));
		// End:0x14C
		if((aTarget == Enemy))
		{
			m_pawn.m_u8DesiredYaw = byte((int(byte((int(byte((rDirection.Yaw - Pawn.Rotation.Yaw))) & 65535))) / 256));			
		}
		else
		{
			m_pawn.m_u8DesiredYaw = 0;
		}
		m_pawn.m_rFiringRotation = rDirection;		
	}
	else
	{
		m_bAimingWeaponAtEnemy = false;
		m_pawn.m_u8DesiredPitch = 0;
		m_pawn.m_u8DesiredYaw = 0;
		m_pawn.m_rFiringRotation = m_pawn.Rotation;
	}
	return;
}

//------------------------------------------------------------------
// EndAttack()                                             
//------------------------------------------------------------------
function EndAttack()
{
	m_pawn.m_bEngaged = false;
	m_TeamManager.DisEngageEnemy(Pawn, Enemy);
	Enemy = none;
	Target = none;
	// End:0x5C
	if(IsMoving(Pawn))
	{
		// End:0x5C
		if((MoveTarget != none))
		{
			Focus = MoveTarget;
		}
	}
	return;
}

//------------------------------------------------------------------
// StartFiring()                                           
//------------------------------------------------------------------
function StartFiring()
{
	// End:0x5C
	if((Pawn.EngineWeapon != none))
	{
		// End:0x2A
		if((Enemy != none))
		{
			Target = Enemy;
		}
		SetRotation(Pawn.Rotation);
		bFire = 1;
		Pawn.EngineWeapon.GotoState('NormalFire');
	}
	return;
}

//------------------------------------------------------------------
// StopFiring()                                            
//------------------------------------------------------------------
function StopFiring()
{
	bFire = 0;
	return;
}

//------------------------------------------------------------------
// PreEntryRoomIsAcceptablyLarge()                                         
//------------------------------------------------------------------
function bool PreEntryRoomIsAcceptablyLarge()
{
	// End:0x1B
	if((int(m_TeamManager.m_eMovementMode) == int(2)))
	{
		return false;
	}
	// End:0x4C
	if((m_TeamManager.m_Door == none))
	{
		m_TeamManager.m_Door = m_pawn.m_Door;
	}
	// End:0x81
	if(((m_TeamManager.m_Door == none) || (m_TeamManager.m_Door.m_CorrespondingDoor == none)))
	{
		return false;
	}
	// End:0xAE
	if((int(m_TeamManager.m_Door.m_CorrespondingDoor.m_eRoomLayout) == int(3)))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// PostEntryRoomIsAcceptablyLarge()                                         
//------------------------------------------------------------------
function bool PostEntryRoomIsAcceptablyLarge()
{
	// End:0x1B
	if((int(m_TeamManager.m_eMovementMode) == int(2)))
	{
		return false;
	}
	// End:0x4C
	if((m_TeamManager.m_Door == none))
	{
		m_TeamManager.m_Door = m_pawn.m_Door;
	}
	// End:0x62
	if((m_TeamManager.m_Door == none))
	{
		return false;
	}
	// End:0x86
	if((int(m_TeamManager.m_Door.m_eRoomLayout) == int(3)))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// GetLeadershipReactionTime()                                         
//------------------------------------------------------------------
function float GetLeadershipReactionTime()
{
	local float fDelay;

	fDelay = (2.0000000 - (m_pawn.GetSkill(6) * 2.0000000));
	fDelay = FClamp(fDelay, 0.0000000, 2.0000000);
	return fDelay;
	return;
}

//------------------------------------------------------------------
// OnRightSideOfDoor()                                         
//------------------------------------------------------------------
function bool OnRightSideOfDoor(Actor aTarget)
{
	local Vector vDir, vResult;

	// End:0x0D
	if((aTarget == none))
	{
		return false;
	}
	vDir = Normal((Pawn.Location - aTarget.Location));
	vResult = Cross(vDir, Vector(aTarget.Rotation));
	// End:0x67
	if((vResult.Z < float(0)))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

//------------------------------------------------------------------
//  ResetGadgetGroup()
//------------------------------------------------------------------
function ResetGadgetGroup()
{
	m_iActionUseGadgetGroup = 0;
	return;
}

//------------------------------------------------------------------
// AimingAt()                                         
//------------------------------------------------------------------
function bool AimingAt(Pawn Enemy)
{
	local Vector vDir;

	vDir = Normal((Enemy.Location - Pawn.Location));
	// End:0x5D
	if((Dot(vDir, Vector((Pawn.Rotation + m_pawn.m_rRotationOffset))) > 0.5000000))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

//------------------------------------------------------------------
// AttackTimer()                                         
//------------------------------------------------------------------
event AttackTimer()
{
	// End:0x17
	if((m_pawn.m_iCurrentWeapon > 2))
	{
		return;
	}
	m_pawn.m_bReloadToFullAmmo = false;
	// End:0x4A
	if(m_bWeaponsDry)
	{
		// End:0x48
		if((Enemy != none))
		{
			StopFiring();
			EndAttack();
		}
		return;
	}
	// End:0x9D
	if(((!m_pawn.m_bChangingWeapon) && (Pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0)))
	{
		RainbowReloadWeapon();
		// End:0x9D
		if((int(bFire) == 1))
		{
			StopFiring();
			EndAttack();
		}
	}
	// End:0xC5
	if((m_pawn.m_bReloadingWeapon || m_pawn.m_bChangingWeapon))
	{
		return;
	}
	// End:0x10A
	if(((Enemy != none) && (R6Pawn(Enemy).m_bIsKneeling || (!R6Pawn(Enemy).IsAlive()))))
	{
		EndAttack();
	}
	// End:0x18F
	if((int(bFire) == 0))
	{
		// End:0x18C
		if((Enemy != none))
		{
			Focus = Enemy;
			Target = Enemy;
			// End:0x18C
			if(AimingAt(Enemy))
			{
				// End:0x16C
				if((m_pawn.IsStationary() && (!IsReadyToFire(Enemy))))
				{
					return;
				}
				Pawn.EngineWeapon.SetRateOfFire(2);
				StartFiring();
			}
		}		
	}
	else
	{
		StopFiring();
		// End:0x1A6
		if((!EnemyIsAThreat()))
		{
			EndAttack();
		}
	}
	return;
}

//------------------------------------------------------------------
// StopAttack()                                         
//------------------------------------------------------------------
event StopAttack()
{
	StopFiring();
	// End:0x17
	if((!EnemyIsAThreat()))
	{
		EndAttack();
	}
	return;
}

//------------------------------------------------------------------
// SetFocusToDoorKnob()                                         
//------------------------------------------------------------------
function SetFocusToDoorKnob(R6IORotatingDoor aDoor)
{
	// End:0x0D
	if((aDoor == none))
	{
		return;
	}
	// End:0x4B
	if(aDoor.m_bTreatDoorAsWindow)
	{
		SetLocation((aDoor.Location - (float(30) * Vector(aDoor.Rotation))));		
	}
	else
	{
		SetLocation((aDoor.Location - (float(128) * Vector(aDoor.Rotation))));
	}
	Focus = self;
	return;
}

//------------------------------------------------------------------
// GotoLockPickState()                                         
//------------------------------------------------------------------
function GotoLockPickState(R6IORotatingDoor Door)
{
	m_RotatingDoor = Door;
	// End:0x18
	if((m_RotatingDoor == none))
	{
		return;
	}
	m_PostLockPickState = GetStateName();
	m_TeamManager.SetTeamState(8);
	GotoState('LockPickDoor');
	return;
}

//------------------------------------------------------------------
// RainbowCannotCompleteOrders()                                         
//------------------------------------------------------------------
function RainbowCannotCompleteOrders()
{
	m_TeamManager.ActionCompleted(false);
	m_iStateProgress = 0;
	NextState = 'None';
	GotoState('HoldPosition');
	return;
}

//------------------------------------------------------------------
// CanThrowGrenadeIntoRoom()                                         
//------------------------------------------------------------------
function bool CanThrowGrenadeIntoRoom(R6Door aDoor, optional Vector vTestTarget)
{
	local Vector vTarget, vHitLocation, vHitNormal;
	local Actor HitActor;

	// End:0x24
	if((!m_pawn.EngineWeapon.HasBulletType('R6FragGrenade')))
	{
		return true;
	}
	// End:0x6D
	if((vTestTarget == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		vTarget = (aDoor.Location - (float(400) * Vector(aDoor.Rotation)));		
	}
	else
	{
		vTarget = vTestTarget;
	}
	HitActor = Trace(vHitLocation, vHitNormal, vTarget, (aDoor.Location - (float(96) * Vector(aDoor.Rotation))), false, vect(20.0000000, 20.0000000, 40.0000000));
	// End:0xD1
	if((HitActor == none))
	{
		return true;
	}
	return false;
	return;
}

function FindPathToTargetLocation(Vector vTarget, optional Actor aTarget)
{
	m_TeamManager.SetTeamState(3);
	m_DesiredTarget = aTarget;
	m_vDesiredLocation = vTarget;
	m_PostFindPathToState = GetStateName();
	GotoState('FindPathToTarget');
	return;
}

function ReInitEntryPositions()
{
	m_vPreEntryPositions[0] = vect(0.0000000, 0.0000000, 0.0000000);
	m_vPreEntryPositions[1] = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

function SwitchWeapon(int f)
{
	local R6AbstractWeapon NewWeapon;

	// End:0x1A
	if((f == m_pawn.m_iCurrentWeapon))
	{
		return;
	}
	Pawn.R6MakeNoise(11);
	NewWeapon = R6AbstractWeapon(m_pawn.GetWeaponInGroup(f));
	// End:0x105
	if((NewWeapon != none))
	{
		// End:0x87
		if((int(Level.NetMode) == int(NM_Standalone)))
		{
			m_pawn.EngineWeapon.GotoState('None');
		}
		m_pawn.m_iCurrentWeapon = f;
		m_pawn.GetWeapon(NewWeapon);
		m_pawn.m_bChangingWeapon = true;
		// End:0xF6
		if((m_pawn.m_SoundRepInfo != none))
		{
			m_pawn.m_SoundRepInfo.m_CurrentWeapon = byte((f - 1));
		}
		m_pawn.PlayWeaponAnimation();
	}
	return;
}

//------------------------------------------------------------------
// TooCloseToThrowGrenade: check if we are too close to throw the grenade
//	the distance decrease when it's taking too much time
//------------------------------------------------------------------
function bool TooCloseToThrowGrenade(Vector vPawnLocation)
{
	local R6EngineWeapon weapon;
	local float fKillRadius, fExplosionRadius;

	weapon = m_pawn.GetWeaponInGroup(m_iActionUseGadgetGroup);
	// End:0x27
	if((weapon == none))
	{
		return false;
	}
	// End:0x4B
	if((VSize((vPawnLocation - m_vLocationOnTarget)) < weapon.GetSaveDistanceToThrow()))
	{
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// CanThrowGrenade: if all conditions are okay, returns true if the 
//  rainbow can throw a grenade from vPawnLocation.
// bTest: used to evaluate if the rainbow is gonna be damaged 
//                 by the grenade
//------------------------------------------------------------------
function bool CanThrowGrenade(Vector vPawnLocation, bool bTraceActors, bool bCheckTooClose)
{
	local Vector vDir, vTargetLoc;
	local float fDist;
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;
	local int iTraceFlags;

	vDir = (m_vLocationOnTarget - vPawnLocation);
	fDist = VSize(vDir);
	// End:0x32
	if((fDist > float(1500)))
	{
		return false;
	}
	// End:0x4D
	if((bCheckTooClose && TooCloseToThrowGrenade(vPawnLocation)))
	{
		return false;
	}
	vTargetLoc = m_vLocationOnTarget;
	(vTargetLoc.Z += float(15));
	// End:0x78
	if(bTraceActors)
	{
		iTraceFlags = 1;
	}
	iTraceFlags = (iTraceFlags | 4);
	HitActor = R6Trace(vHitLocation, vHitNormal, vTargetLoc, vPawnLocation, iTraceFlags, vect(20.0000000, 20.0000000, 10.0000000));
	// End:0xDC
	if(((HitActor != none) && (VSize((vHitLocation - vTargetLoc)) > float(30))))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// ClearThrowIsAvailable()
//------------------------------------------------------------------
function bool ClearThrowIsAvailable(Vector vTarget)
{
	local Actor HitActor;
	local Vector vHitLocation, vHitNormal;

	HitActor = Pawn.R6Trace(vHitLocation, vHitNormal, (vTarget + vect(0.0000000, 0.0000000, 40.0000000)), Pawn.Location, (1 | 4), vect(30.0000000, 30.0000000, 15.0000000));
	// End:0x5D
	if((HitActor == none))
	{
		return true;
	}
	// End:0x73
	if(HitActor.IsA('R6Pawn'))
	{
		return false;
	}
	return true;
	return;
}

//------------------------------------------------------------------
// ResetTeamMoveTo()
//------------------------------------------------------------------
function ResetTeamMoveTo()
{
	local int iWeapon;

	m_iStateProgress = 0;
	SetTimer(0.0000000, false);
	// End:0x9E
	if(m_pawn.m_bInteractingWithDevice)
	{
		m_pawn.m_bInteractingWithDevice = false;
		m_pawn.m_bPostureTransition = false;
		m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
		m_pawn.m_ePlayerIsUsingHands = 0;
		// End:0x9E
		if((R6IOObject(m_ActionTarget) != none))
		{
			R6IOObject(m_ActionTarget).PerformSoundAction(1);
		}
	}
	// End:0xE6
	if((m_pawn.m_bWeaponIsSecured && (!m_pawn.m_bWeaponTransition)))
	{
		m_pawn.SetNextPendingAction(28);
		m_pawn.PlayWeaponAnimation();
	}
	m_pawn.m_iCurrentWeapon = int(FClamp(float(m_pawn.m_iCurrentWeapon), 1.0000000, 4.0000000));
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	return;
}

function R6Pawn.eMovementPace GetTeamPace()
{
	local R6Pawn.eMovementPace ePace;

	switch(m_TeamManager.m_eMovementSpeed)
	{
		// End:0x3D
		case 0:
			// End:0x32
			if(m_TeamManager.AtLeastOneMemberIsWounded())
			{
				ePace = 4;				
			}
			else
			{
				ePace = 5;
			}
			// End:0x68
			break;
		// End:0x4D
		case 1:
			ePace = 4;
			// End:0x68
			break;
		// End:0x5D
		case 2:
			ePace = 2;
			// End:0x68
			break;
		// End:0xFFFF
		default:
			ePace = 4;
			break;
	}
	m_pawn.m_eMovementPace = ePace;
	return ePace;
	return;
}

function bool NextActionPointIsThroughDoor(Actor nextActionPoint)
{
	local Vector vDir;
	local float fResult;

	// End:0x0D
	if((nextActionPoint == none))
	{
		return false;
	}
	// End:0x23
	if((m_pawn.m_Door == none))
	{
		return false;
	}
	// End:0x49
	if(m_pawn.m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		return false;
	}
	// End:0xAB
	if((VSize((nextActionPoint.Location - m_pawn.m_Door.Location)) > VSize((nextActionPoint.Location - m_pawn.m_Door.m_CorrespondingDoor.Location))))
	{
		return true;
	}
	return false;
	return;
}

function SetGrenadeParameters(bool bPeeking, optional bool bThrowOverhand)
{
	// End:0x83
	if(bPeeking)
	{
		// End:0x4D
		if(OnRightSideOfDoor(m_ActionTarget))
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = true;
			m_pawn.m_eGrenadeThrow = 4;
			m_pawn.m_eRepGrenadeThrow = 4;			
		}
		else
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = 5;
			m_pawn.m_eRepGrenadeThrow = 5;
		}		
	}
	else
	{
		// End:0xC2
		if(bThrowOverhand)
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = 1;
			m_pawn.m_eRepGrenadeThrow = 1;			
		}
		else
		{
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = 2;
			m_pawn.m_eRepGrenadeThrow = 2;
		}
	}
	return;
}

function ConfirmLadderActionPointWasReached(R6Ladder Ladder)
{
	// End:0x56
	if(((int(m_pawn.m_ePawnType) == int(1)) && (m_pawn.m_iID == 0)))
	{
		// End:0x56
		if((Ladder == m_TeamManager.m_PlanActionPoint))
		{
			m_TeamManager.ActionPointReached();
		}
	}
	return;
}

function bool TargetIsLadderToClimb(R6Ladder Target)
{
	// End:0x23
	if(((Target == none) || (m_pawn.m_Ladder == none)))
	{
		return false;
	}
	// End:0x3D
	if((m_pawn.m_Ladder == Target))
	{
		return false;
	}
	// End:0x69
	if((Target.MyLadder != m_pawn.m_Ladder.MyLadder))
	{
		return false;
	}
	return true;
	return;
}

function DetonateBreach()
{
	m_iStateProgress = 3;
	GotoState('DetonateBreachingCharge');
	return;
}

function GotoStateLeadRoomEntry()
{
	ResetStateProgress();
	GotoState('LeadRoomEntry');
	return;
}

function ForceCurrentDoor(R6Door aDoor)
{
	// End:0x0D
	if((aDoor == none))
	{
		return;
	}
	m_pawn.m_Door = aDoor;
	m_pawn.m_potentialActionActor = aDoor.m_RotatingDoor;
	return;
}

// NEW IN 1.60
function DispatchOrder(int iOrder, optional R6RainbowTeam teamManager)
{
	return;
}

//------------------------------------------------------------------
// GetNextTeamActionState()                                       
//------------------------------------------------------------------
function name GetNextTeamActionState()
{
	// End:0x1A
	if((m_pawn.m_iID > 1))
	{
		return 'FollowLeader';
	}
	// End:0x3B
	if(((m_TeamManager.m_iTeamAction & 512) > 0))
	{
		return 'TeamClimbStartNoLeader';
	}
	// End:0x5C
	if(((m_TeamManager.m_iTeamAction & 1024) > 0))
	{
		return 'TeamSecureTerrorist';
	}
	// End:0xB7
	if(((((m_TeamManager.m_iTeamAction & 4096) > 0) || ((m_TeamManager.m_iTeamAction & 8192) > 0)) || ((m_TeamManager.m_iTeamAction & 256) > 0)))
	{
		return 'TeamMoveTo';
	}
	// End:0x123
	if((((((m_TeamManager.m_iTeamAction & 16) > 0) || ((m_TeamManager.m_iTeamAction & 32) > 0)) || ((m_TeamManager.m_iTeamAction & 128) > 0)) || ((m_TeamManager.m_iTeamAction & 64) > 0)))
	{
		return 'PerformAction';
	}
	return 'FollowLeader';
	return;
}

//------------------------------------------------------------------
// VerifyWeaponInventory()
//------------------------------------------------------------------
function VerifyWeaponInventory()
{
	local int iWeapon;

	// End:0x35
	if((m_pawn.EngineWeapon == Pawn.m_WeaponsCarried[(m_pawn.m_iCurrentWeapon - 1)]))
	{
		return;
	}
	iWeapon = 0;
	J0x3C:

	// End:0x92 [Loop If]
	if((iWeapon < 4))
	{
		// End:0x88
		if((m_pawn.EngineWeapon == Pawn.m_WeaponsCarried[iWeapon]))
		{
			m_pawn.m_iCurrentWeapon = (iWeapon + 1);
			return;
		}
		(iWeapon++);
		// [Loop Continue]
		goto J0x3C;
	}
	return;
}

//------------------------------------------------------------------
// EnsureRainbowIsArmed()                                       
//------------------------------------------------------------------
function bool EnsureRainbowIsArmed()
{
	// End:0x4A
	if((m_pawn.m_bWeaponIsSecured && (!m_pawn.m_bWeaponTransition)))
	{
		m_pawn.SetNextPendingAction(28);
		m_pawn.PlayWeaponAnimation();
		return true;
	}
	// End:0xAB
	if((m_pawn.m_iCurrentWeapon > 2))
	{
		// End:0x9E
		if(((Pawn.m_WeaponsCarried[0] != none) && Pawn.m_WeaponsCarried[0].HasAmmo()))
		{
			SwitchWeapon(1);			
		}
		else
		{
			SwitchWeapon(2);
		}
		return true;		
	}
	else
	{
		// End:0x124
		if((m_pawn.m_iCurrentWeapon == 2))
		{
			// End:0x124
			if((((Pawn.m_WeaponsCarried[0] != none) && (int(Pawn.m_WeaponsCarried[0].m_eWeaponType) != int(4))) && Pawn.m_WeaponsCarried[0].HasAmmo()))
			{
				SwitchWeapon(1);
				return true;
			}
		}
	}
	return false;
	return;
}

//------------------------------------------------------------------
// SniperChangeToPrimaryWeapon()                                       
//------------------------------------------------------------------
function bool SniperChangeToPrimaryWeapon()
{
	// End:0x18
	if((Pawn.m_WeaponsCarried[0] == none))
	{
		return false;
	}
	// End:0xB5
	if((((((Pawn.EngineWeapon != none) && (!m_pawn.m_bChangingWeapon)) && (Pawn.EngineWeapon == m_pawn.m_WeaponsCarried[1])) && Pawn.m_WeaponsCarried[0].HasAmmo()) && (int(Pawn.m_WeaponsCarried[0].m_eWeaponType) == int(4))))
	{
		SwitchWeapon(1);
		return true;
	}
	return false;
	return;
}

//------------------------------------------------------------------
// SniperChangeToSecondaryWeapon()                                       
//------------------------------------------------------------------
function bool SniperChangeToSecondaryWeapon()
{
	// End:0x9C
	if((((((Pawn.EngineWeapon != none) && (!m_pawn.m_bChangingWeapon)) && (Pawn.EngineWeapon == m_pawn.m_WeaponsCarried[0])) && Pawn.m_WeaponsCarried[1].HasAmmo()) && (int(Pawn.EngineWeapon.m_eWeaponType) == int(4))))
	{
		SwitchWeapon(2);
		return true;
	}
	return false;
	return;
}

function CheckNeedToClimbLadder()
{
	// End:0x2A
	if(((m_pawn.m_iID == 1) && m_TeamManager.m_bTeamIsSeparatedFromLeader))
	{
		return;
	}
	// End:0x40
	if((m_pawn.m_iID == 0))
	{
		return;
	}
	// End:0x4D
	if((m_TargetLadder == none))
	{
		return;
	}
	// End:0x82
	if(PawnIsOnTheSameEndOfLadderAsMember(m_PaceMember, R6LadderVolume(m_TargetLadder.MyLadder)))
	{
		m_TeamManager.MemberFinishedClimbingLadder(m_pawn);
	}
	return;
}

function bool PawnIsOnTheSameEndOfLadderAsMember(R6Rainbow aRainbow, R6LadderVolume LadderVolume)
{
	local bool bPaceMemberIsAtTopOfLadder;

	// End:0x0D
	if((LadderVolume == none))
	{
		return true;
	}
	bPaceMemberIsAtTopOfLadder = (aRainbow.Location.Z > LadderVolume.Location.Z);
	// End:0x74
	if((bPaceMemberIsAtTopOfLadder == (m_pawn.Location.Z > LadderVolume.Location.Z)))
	{
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

//------------------------------------------------------------------
// GetFormationDistance()
//------------------------------------------------------------------
function float GetFormationDistance()
{
	// End:0x67
	if((m_PaceMember != none))
	{
		// End:0x67
		if((m_PaceMember.m_bIsProne || ((m_PaceMember.Controller != none) && m_PaceMember.Controller.IsInState('SnipeUntilGoCode'))))
		{
			return float((m_TeamManager.m_iFormationDistance * 2));
		}
	}
	return float(m_TeamManager.m_iFormationDistance);
	return;
}

//------------------------------------------------------------------
// IsBumpBackUpStateFinish: return true if the condition to end the
// state BumpBackUp are reached.
// - inherited
// c_iDistanceBumpBackUp depends on m_TeamManager.m_iFormationDistance
//------------------------------------------------------------------
function bool IsBumpBackUpStateFinish()
{
	local R6Pawn aBumpPawn;

	// End:0x21
	if(((m_fLastBump + 4.0000000) < Level.TimeSeconds))
	{
		return true;
	}
	aBumpPawn = R6Pawn(m_BumpedBy);
	Focus = none;
	// End:0x71
	if((m_TeamLeader == none))
	{
		return ((DistanceTo(m_BumpedBy) > float((c_iDistanceBumpBackUp + 60))) || (!IsMoving(aBumpPawn)));		
	}
	else
	{
		return ((DistanceTo(m_BumpedBy) > float((c_iDistanceBumpBackUp + 60))) || ((DistanceTo(m_PaceMember) > float((c_iDistanceBumpBackUp + 60))) && (IsMoving(m_PaceMember) && (!m_PaceMember.IsInState('BumpBackUp')))));
	}
	return;
}

//------------------------------------------------------------------
// BumpBackUpStateFinished: function fired if there is not a 
//	return state (in m_bumpBackUpState_nextState)
// - inherited
//------------------------------------------------------------------
function BumpBackUpStateFinished()
{
	GotoState('HoldPosition');
	return;
}

//------------------------------------------------------------------
// IsMoving()
//------------------------------------------------------------------
function bool IsMoving(Pawn P)
{
	// End:0x32
	if(((P == none) || (P.Velocity == vect(0.0000000, 0.0000000, 0.0000000))))
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
// SetNoiseFocus()
//------------------------------------------------------------------
function SetNoiseFocus(Vector vSource)
{
	m_vNoiseFocalPoint = vSource;
	// End:0x23
	if(m_bReactToNoise)
	{
		SetLocation(m_vNoiseFocalPoint);
		Focus = self;
	}
	return;
}

//------------------------------------------------------------------
// ResetNoiseFocus()
//------------------------------------------------------------------
function ResetNoiseFocus()
{
	m_vNoiseFocalPoint = vect(0.0000000, 0.0000000, 0.0000000);
	return;
}

//------------------------------------------------------------------
// NeedToReload()
//------------------------------------------------------------------
function bool NeedToReload()
{
	local float fCutOff;

	// End:0x17
	if((m_pawn.m_iCurrentWeapon > 2))
	{
		return false;
	}
	// End:0x3E
	if((int(m_TeamManager.m_eGoCode) == int(4)))
	{
		fCutOff = 0.5000000;		
	}
	else
	{
		fCutOff = 0.7500000;
	}
	// End:0x92
	if(((((Pawn.EngineWeapon == none) || m_bWeaponsDry) || m_pawn.m_bChangingWeapon) || m_pawn.m_bReloadingWeapon))
	{
		return false;
	}
	// End:0xEB
	if((Pawn.EngineWeapon.NumberOfBulletsLeftInClip() == 0))
	{
		// End:0xE9
		if(((Enemy == none) && Pawn.EngineWeapon.IsPumpShotGun()))
		{
			m_pawn.m_bReloadToFullAmmo = true;
		}
		return true;
	}
	// End:0xF8
	if((Enemy != none))
	{
		return false;
	}
	// End:0x1A3
	if((float(Pawn.EngineWeapon.NumberOfBulletsLeftInClip()) <= (fCutOff * float(Pawn.EngineWeapon.GetClipCapacity()))))
	{
		// End:0x186
		if((Pawn.EngineWeapon.IsPumpShotGun() && (Pawn.EngineWeapon.GetNbOfClips() > 0)))
		{
			m_pawn.m_bReloadToFullAmmo = true;
			return true;
		}
		// End:0x1A3
		if(Pawn.EngineWeapon.HasAtLeastOneFullClip())
		{
			return true;
		}
	}
	return false;
	return;
}

//------------------------------------------------------------------
// RainbowReloadWeapon()
//------------------------------------------------------------------
function RainbowReloadWeapon()
{
	// End:0x0B
	if(m_bWeaponsDry)
	{
		return;
	}
	// End:0x1F
	if(m_pawn.m_bReloadingWeapon)
	{
		return;
	}
	// End:0xA9
	if((Pawn.EngineWeapon.GetNbOfClips() > 0))
	{
		// End:0x54
		if((Enemy != none))
		{
			StopFiring();
			EndAttack();
		}
		m_pawn.m_u8DesiredYaw = 0;
		m_pawn.m_u8DesiredPitch = 0;
		m_pawn.m_ePlayerIsUsingHands = 0;
		m_pawn.ServerSwitchReloadingWeapon(true);
		m_pawn.ReloadWeapon();		
	}
	else
	{
		// End:0xE7
		if(((m_pawn.m_iCurrentWeapon == 1) && Pawn.m_WeaponsCarried[1].HasAmmo()))
		{
			SwitchWeapon(2);			
		}
		else
		{
			// End:0x125
			if(((m_pawn.m_iCurrentWeapon == 2) && Pawn.m_WeaponsCarried[0].HasAmmo()))
			{
				SwitchWeapon(1);				
			}
			else
			{
				// End:0x17D
				if((!m_bWeaponsDry))
				{
					m_bWeaponsDry = true;
					// End:0x17D
					if((m_TeamManager.m_bLeaderIsAPlayer || m_TeamManager.m_bPlayerHasFocus))
					{
						m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 14);
					}
				}
			}
		}
	}
	return;
}

function R6Pawn.eMovementPace GetPace(bool bRun)
{
	// End:0x2E
	if((m_PaceMember.m_bIsProne && (!m_PaceMember.m_bIsSniping)))
	{
		return 1;		
	}
	else
	{
		// End:0x55
		if(m_PaceMember.bIsCrouched)
		{
			// End:0x4F
			if(bRun)
			{
				return 3;				
			}
			else
			{
				return 2;
			}			
		}
		else
		{
			// End:0x64
			if(bRun)
			{
				return 5;				
			}
			else
			{
				return 4;
			}
		}
	}
	return;
}

function SetRainbowOrientation()
{
	// End:0x16
	if((int(m_ePawnOrientation) != int(5)))
	{
		SetOrientation();		
	}
	else
	{
		// End:0x25
		if(m_bIsMovingBackwards)
		{
			SetOrientation();			
		}
		else
		{
			SetOrientation(0);
		}
	}
	return;
}

function ReorganizeTeamAsNeeded()
{
	// End:0x23
	if((int(m_pawn.m_eHealth) != int(1)))
	{
		m_bReorganizationPending = false;
		return;
	}
	m_TeamManager.ReOrganizeWoundedMembers();
	return;
}

// Right now this is being used when the player decides to relinquish control of the squad 
// to his number 2...also used when the current leader of the squad has been killed...
function Promote()
{
	m_TeamLeader = m_TeamManager.m_TeamLeader;
	(m_pawn.m_iID--);
	// End:0x83
	if((m_TeamLeader == Pawn))
	{
		m_pawn.ResetBoneRotation();
		m_TeamLeader = none;
		// End:0x5D
		if(m_pawn.m_bIsClimbingLadder)
		{
			return;
		}
		// End:0x79
		if(m_TeamManager.m_bTeamIsHoldingPosition)
		{
			GotoState('HoldPosition');			
		}
		else
		{
			GotoState('Patrol');
		}		
	}
	else
	{
		// End:0xC9
		if(((!m_pawn.m_bIsClimbingLadder) && (!IsInState('RoomEntry'))))
		{
			// End:0xC2
			if(m_TeamManager.m_bTeamIsHoldingPosition)
			{
				GotoState('HoldPosition');				
			}
			else
			{
				GotoState('FollowLeader');
			}
		}
	}
	return;
}

function Tick(float fDeltaTime)
{
	local Vector vDirection;
	local Rotator rDirection;

	super.Tick(fDeltaTime);
	// End:0x18
	if((Pawn == none))
	{
		return;
	}
	// End:0x31
	if((Enemy != none))
	{
		SetGunDirection(Enemy);		
	}
	else
	{
		// End:0x59
		if((m_bAimingWeaponAtEnemy && (m_pawn.m_fFiringTimer == float(0))))
		{
			SetGunDirection(none);
		}
	}
	// End:0xAD
	if((((m_TeamLeader != none) && (m_TeamManager != none)) && (m_pawn.m_iID != 0)))
	{
		m_PaceMember = m_TeamManager.m_Team[(m_pawn.m_iID - 1)];
	}
	return;
}

state RunAwayFromGrenade
{
	function BeginState()
	{
		m_bIgnoreBackupBump = true;
		return;
	}

	function EndState()
	{
		m_TeamManager.m_bGrenadeInProximity = false;
		SetTimer(0.0000000, false);
		StopMoving();
		m_bIgnoreBackupBump = false;
		return;
	}

	event Timer()
	{
		m_TeamManager.GrenadeThreatIsOver();
		return;
	}

	function Vector SafeLocation()
	{
		local Vector vDir, vLocation;

		vDir = Normal((Pawn.Location - m_vGrenadeLocation));
		vLocation = (m_vGrenadeLocation + ((m_fGrenadeDangerRadius + float(600)) * vDir));
		vLocation.Z = Pawn.Location.Z;
		// End:0x6E
		if(pointReachable(vLocation))
		{
			return vLocation;
		}
		vLocation = (m_vGrenadeLocation - ((m_fGrenadeDangerRadius + float(600)) * vDir));
		vLocation.Z = Pawn.Location.Z;
		// End:0xBF
		if(pointReachable(vLocation))
		{
			return vLocation;
		}
		return vect(0.0000000, 0.0000000, 0.0000000);
		return;
	}
Begin:

	m_TeamManager.SetTeamState(3);
	m_vTargetPosition = SafeLocation();
	EnsureRainbowIsArmed();
	// End:0x40
	if((m_vTargetPosition != vect(0.0000000, 0.0000000, 0.0000000)))
	{
		goto 'RunToDirectly';
	}
FindPathAway:


	MoveTarget = FindSafeSpot();
	// End:0x13A
	if((MoveTarget != none))
	{
		// End:0xD2
		if(NeedToOpenDoor(MoveTarget))
		{
			m_pawn.PlayDoorAnim(m_pawn.m_Door.m_RotatingDoor);
			Sleep(0.5000000);
			m_pawn.ServerPerformDoorAction(m_pawn.m_Door.m_RotatingDoor, int(m_pawn.m_Door.m_RotatingDoor.1));
		}
		R6PreMoveToward(MoveTarget, MoveTarget, 5);
		MoveToward(MoveTarget);
		// End:0x104
		if((int(m_eMoveToResult) == int(2)))
		{
			Sleep(0.5000000);
		}
		// End:0x134
		if((VSize((m_vGrenadeLocation - Pawn.Location)) > (m_fGrenadeDangerRadius + float(300))))
		{
			goto 'Wait';
		}
		goto 'FindPathAway';
	}
	goto 'Wait';
RunToDirectly:


	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
	MoveTo(m_vTargetPosition);
Wait:


	StopMoving();
	m_TeamManager.SetTeamState(2);
	Sleep(2.0000000);
	goto 'Wait';
	stop;				
}

state BumpBackUp
{
	event bool NotifyBump(Actor Other)
	{
		local R6Pawn thisPawn;

		thisPawn = R6Pawn(Other);
		// End:0x1D
		if((thisPawn == none))
		{
			return false;
		}
		// End:0x57
		if((thisPawn.m_iID <= R6Pawn(m_BumpedBy).m_iID))
		{
			m_BumpedBy = thisPawn;
			GotoState('BumpBackUp');
			return true;
		}
		return false;
		return;
	}

	function Vector GetTargetLocation(bool bRight, optional int iTry)
	{
		local Rotator rOffset;
		local R6Pawn bumpedBy;

		bumpedBy = R6Pawn(m_BumpedBy);
		// End:0x86
		if((bumpedBy.m_bIsClimbingLadder && ((bumpedBy.Location.Z - Pawn.Location.Z) > float(100))))
		{
			return (Pawn.Location - (float(c_iDistanceBumpBackUp) * bumpedBy.OnLadder.LookDir));
		}
		switch(iTry)
		{
			// End:0xA7
			case 0:
				rOffset = rot(0, 16384, 0);
				// End:0x14B
				break;
			// End:0xC1
			case 1:
				rOffset = rot(0, 8192, 0);
				// End:0x14B
				break;
			// End:0xDC
			case 2:
				rOffset = rot(0, 4096, 0);
				// End:0x14B
				break;
			// End:0xF7
			case 3:
				rOffset = rot(0, 0, 0);
				// End:0x14B
				break;
			// End:0x112
			case 4:
				rOffset = rot(0, -4096, 0);
				// End:0x14B
				break;
			// End:0x12D
			case 5:
				rOffset = rot(0, -8192, 0);
				// End:0x14B
				break;
			// End:0x148
			case 6:
				rOffset = rot(0, -16384, 0);
				// End:0x14B
				break;
			// End:0xFFFF
			default:
				break;
		}
		// End:0x182
		if(bRight)
		{
			return (Pawn.Location + (float(c_iDistanceBumpBackUp) * Vector((Rotator(m_vBumpedByVelocity) + rOffset))));			
		}
		else
		{
			return (Pawn.Location + (float(c_iDistanceBumpBackUp) * Vector((Rotator(m_vBumpedByVelocity) - rOffset))));
		}
		return;
	}

	function bool GetReacheablePoint(out Vector vTarget, bool bNoFail)
	{
		local Actor HitActor;
		local Vector vHitLocation, vHitNormal, vExtent;
		local bool bMoveRight;
		local int i;

		bMoveRight = MoveRight();
		vTarget = GetTargetLocation(bMoveRight);
		vExtent.X = Pawn.CollisionRadius;
		vExtent.Y = vExtent.X;
		vExtent.Z = Pawn.CollisionHeight;
		HitActor = R6Trace(vHitLocation, vHitNormal, vTarget, Pawn.Location, 1, vExtent);
		// End:0xBC
		if((HitActor != none))
		{
			vTarget = (vHitLocation + (float(c_iDistanceBumpBackUp) * Vector(Rotator(m_vBumpedByVelocity))));
		}
		J0xBC:

		// End:0x118 [Loop If]
		if(((R6Trace(vHitLocation, vHitNormal, (vTarget - vect(0.0000000, 0.0000000, 200.0000000)), vTarget, 1) == none) && (i < 6)))
		{
			(i++);
			vTarget = GetTargetLocation(bMoveRight, i);
			// [Loop Continue]
			goto J0xBC;
		}
		return true;
		return;
	}
	stop;
}

state WaitForPaceMember
{Begin:

	Sleep(1.0000000);
	// End:0x45
	if((Abs((m_PaceMember.Location.Z - Pawn.Location.Z)) < float(30)))
	{
		GotoState('FollowLeader');		
	}
	else
	{
		goto 'Begin';
	}
	stop;				
}

state LockPickDoor
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump = true;
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = true;
		m_bIgnoreBackupBump = false;
		// End:0x81
		if(m_pawn.m_bIsLockPicking)
		{
			m_pawn.m_bIsLockPicking = false;
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_pawn.m_ePlayerIsUsingHands = 0;
		}
		// End:0xC9
		if((m_pawn.m_bWeaponIsSecured && (!m_pawn.m_bWeaponTransition)))
		{
			m_pawn.m_eEquipWeapon = 1;
			m_pawn.PlayWeaponAnimation();
		}
		// End:0xFC
		if(m_RotatingDoor.m_bIsDoorLocked)
		{
			m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.15));
		}
		return;
	}
Begin:

	m_vTargetPosition = (m_pawn.m_Door.Location + (float(20) * Vector(m_pawn.m_Door.Rotation)));
	SetLocation((m_RotatingDoor.Location - (float(128) * Vector(m_RotatingDoor.Rotation))));
	MoveToPosition(m_vTargetPosition, Rotator((Location - Pawn.Location)));
	Focus = self;
	FinishRotation();
	m_pawn.SetNextPendingAction(27);
	FinishAnim(m_pawn.14);
	m_pawn.SetNextPendingAction(19);
	m_pawn.m_bIsLockPicking = true;
	Sleep(0.1000000);
	m_RotatingDoor.PlayLockPickSound();
	// End:0x12D
	if(m_pawn.m_bHasLockPickKit)
	{
		Sleep(((m_RotatingDoor.m_fUnlockBaseTime - 2.0000000) * (2.0000000 - m_pawn.ArmorSkillEffect())));		
	}
	else
	{
		Sleep((m_RotatingDoor.m_fUnlockBaseTime * (2.0000000 - m_pawn.ArmorSkillEffect())));
	}
	m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.13));
	m_pawn.m_bIsLockPicking = false;
	m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
	m_pawn.m_ePlayerIsUsingHands = 0;
	Sleep(1.0000000);
	m_pawn.SetNextPendingAction(28);
	FinishAnim(m_pawn.14);
End:


	GotoState(m_PostLockPickState);
	stop;	
}

state PerformAction
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		m_bEnteredRoom = false;
		// End:0x82
		if(((m_ActionTarget != none) && m_ActionTarget.IsA('R6Door')))
		{
			m_TeamManager.m_Door = R6Door(m_ActionTarget);
			m_RotatingDoor = m_TeamManager.m_Door.m_RotatingDoor;			
		}
		else
		{
			m_RotatingDoor = none;
		}
		return;
	}

	function EndState()
	{
		// End:0x13
		if((m_iStateProgress == 14))
		{
			m_iStateProgress = 0;
		}
		SetTimer(0.0000000, false);
		m_pawn.m_u8DesiredYaw = 0;
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_pawn.m_bAvoidFacingWalls = true;
		m_bIgnoreBackupBump = false;
		m_bIndividualAttacks = true;
		return;
	}

	function Timer()
	{
		(m_iTurn++);
		LookAroundRoom(true);
		return;
	}

	function Vector FindFloorBelowActor(Actor Target)
	{
		local Vector vHitLocation, vHitNormal;

		Trace(vHitLocation, vHitNormal, (Target.Location - vect(0.0000000, 0.0000000, 200.0000000)), Target.Location, false);
		(vHitLocation.Z += Pawn.CollisionHeight);
		return vHitLocation;
		return;
	}
Begin:

	StopMoving();
	m_pawn.ResetBoneRotation();
	Sleep(GetLeadershipReactionTime());
	// End:0x2F
	if((m_ActionTarget == none))
	{
		goto 'ReinitAction';
	}
	switch(m_iStateProgress)
	{
		// End:0x43
		case 0:
			goto 'PrepareForAction';
			// End:0xD8
			break;
		// End:0x50
		case 1:
			goto 'FindActionTarget';
			// End:0xD8
			break;
		// End:0x5E
		case 2:
			goto 'MoveToActionTarget';
			// End:0xD8
			break;
		// End:0x6C
		case 3:
			goto 'PreEntry';
			// End:0xD8
			break;
		// End:0x7A
		case 4:
			goto 'WaitForZuluGoCode';
			// End:0xD8
			break;
		// End:0x7F
		case 5:
		// End:0x8D
		case 6:
			goto 'performDoorAction';
			// End:0xD8
			break;
		// End:0x92
		case 7:
		// End:0xA0
		case 8:
			goto 'PerformGrenadeAction';
			// End:0xD8
			break;
		// End:0xA5
		case 9:
		// End:0xB3
		case 10:
			goto 'PerformClearAction';
			// End:0xD8
			break;
		// End:0xC1
		case 11:
			goto 'UpdateStatus';
			// End:0xD8
			break;
		// End:0xCF
		case 12:
			goto 'ReinitAction';
			// End:0xD8
			break;
		// End:0xFFFF
		default:
			goto 'WaitForTeamAI';
			break;
	}
	J0xD8:

	m_TeamManager.SetTeamState(3);
	// End:0x110
	if((CanWalkTo(m_ActionTarget.Location) || actorReachable(m_ActionTarget)))
	{
		goto 'MoveToActionTarget';
	}
	m_iStateProgress = 1;
FindActionTarget:


	// End:0x188
	if(((!CanWalkTo(m_ActionTarget.Location)) && (!actorReachable(m_ActionTarget))))
	{
		// End:0x16F
		if(((m_RotatingDoor != none) && m_RotatingDoor.m_bTreatDoorAsWindow))
		{
			FindPathToTargetLocation(FindFloorBelowActor(m_ActionTarget));			
		}
		else
		{
			FindPathToTargetLocation(m_ActionTarget.Location, m_ActionTarget);
		}
	}
	m_iStateProgress = 2;
MoveToActionTarget:


	// End:0x1C9
	if(((!m_RotatingDoor.m_bIsDoorLocked) && ((m_TeamManager.m_iTeamAction & 64) > 0)))
	{
		SwitchWeapon(m_iActionUseGadgetGroup);
	}
	m_bIgnoreBackupBump = true;
	// End:0x329
	if(((((m_RotatingDoor != none) && (m_TeamManager.m_iTeamAction == 32)) && m_RotatingDoor.DoorOpenTowardsActor(m_ActionTarget)) && (!PreEntryRoomIsAcceptablyLarge())))
	{
		// End:0x282
		if(m_RotatingDoor.m_bIsOpeningClockWise)
		{
			m_vTargetPosition = ((m_ActionTarget.Location - (float(85) * Vector(m_ActionTarget.Rotation))) + (float(85) * Vector((m_ActionTarget.Rotation + rot(0, 16384, 0)))));			
		}
		else
		{
			m_vTargetPosition = ((m_ActionTarget.Location - (float(85) * Vector(m_ActionTarget.Rotation))) - (float(85) * Vector((m_ActionTarget.Rotation + rot(0, 16384, 0)))));
		}
		R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.Location, 4);
		MoveTo(m_vTargetPosition, m_RotatingDoor);
		MoveToPosition(m_vTargetPosition, Rotator((m_RotatingDoor.Location - Pawn.Location)));		
	}
	else
	{
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
		MoveToward(m_ActionTarget);
		MoveToPosition(m_ActionTarget.Location, m_ActionTarget.Rotation);
	}
	StopMoving();
	Sleep(0.5000000);
UnlockDoor:


	// End:0x38D
	if(m_RotatingDoor.m_bIsDoorLocked)
	{
		GotoLockPickState(m_RotatingDoor);
	}
	m_TeamManager.SetTeamState(3);
	// End:0x3C4
	if(((m_TeamManager.m_iTeamAction & 64) > 0))
	{
		SwitchWeapon(m_iActionUseGadgetGroup);		
	}
	else
	{
		EnsureRainbowIsArmed();
	}
	J0x3CA:

	// End:0x3E9 [Loop If]
	if((!m_TeamManager.LastMemberIsStationary()))
	{
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x3CA;
	}
	m_bIgnoreBackupBump = false;
	m_iStateProgress = 3;
PreEntry:


	// End:0x455
	if(((m_pawn.m_Door == m_ActionTarget) && m_RotatingDoor.m_bTreatDoorAsWindow))
	{
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		m_iStateProgress = 4;
		goto 'WaitForZuluGoCode';
	}
	// End:0x492
	if((m_RotatingDoor != none))
	{
		ForceCurrentDoor(R6Door(m_ActionTarget));
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	}
	// End:0x516
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = GetEntryPosition(false);
		// End:0x516
		if((m_vTargetPosition != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.Location, 4);
			MoveTo(m_vTargetPosition);
			MoveToPosition(m_vTargetPosition, Rotator((m_TeamManager.m_Door.m_CorrespondingDoor.Location - m_vTargetPosition)));
			StopMoving();
		}
	}
	m_iStateProgress = 4;
WaitForZuluGoCode:


	// End:0x54F
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		Sleep(0.5000000);
		goto 'WaitForZuluGoCode';
	}
	m_iStateProgress = 5;
performDoorAction:


	// End:0x7F4
	if((((m_TeamManager.m_iTeamAction & 16) > 0) || ((m_TeamManager.m_iTeamAction & 32) > 0)))
	{
		// End:0x7DE
		if((m_RotatingDoor != none))
		{
			// End:0x5F1
			if(m_RotatingDoor.m_bIsDoorClosed)
			{
				Focus = m_RotatingDoor;
				// End:0x5DE
				if((m_TeamManager.m_Door == none))
				{
					m_TeamManager.m_Door = R6Door(m_ActionTarget);
				}
				SetFocusToDoorKnob(m_RotatingDoor);
				Sleep(1.5000000);
			}
			J0x5F1:

			// End:0x610 [Loop If]
			if((!m_TeamManager.LastMemberIsStationary()))
			{
				Sleep(0.5000000);
				// [Loop Continue]
				goto J0x5F1;
			}
			// End:0x6FD
			if((((m_TeamManager.m_iTeamAction & 16) > 0) && m_RotatingDoor.m_bIsDoorClosed))
			{
				m_iStateProgress = 6;
				// End:0x66A
				if(m_RotatingDoor.m_bTreatDoorAsWindow)
				{
					m_TeamManager.SetTeamState(11);					
				}
				else
				{
					m_TeamManager.SetTeamState(9);
				}
				m_pawn.PlayDoorAnim(m_RotatingDoor);
				Sleep(0.5000000);
				m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.1));
				J0x6B8:

				// End:0x6FA [Loop If]
				if(m_RotatingDoor.m_bIsDoorClosed)
				{
					// End:0x6EF
					if((!m_RotatingDoor.m_bInProcessOfOpening))
					{
						Sleep(1.0000000);
						goto 'performDoorAction';						
					}
					else
					{
						Sleep(0.2000000);
					}
					// [Loop Continue]
					goto J0x6B8;
				}				
			}
			else
			{
				// End:0x7C9
				if((((m_TeamManager.m_iTeamAction & 32) > 0) && (!m_RotatingDoor.m_bIsDoorClosed)))
				{
					m_iStateProgress = 6;
					// End:0x759
					if(m_RotatingDoor.m_bTreatDoorAsWindow)
					{
						m_TeamManager.SetTeamState(12);						
					}
					else
					{
						m_TeamManager.SetTeamState(10);
					}
					m_pawn.PlayDoorAnim(m_RotatingDoor);
					Sleep(0.5000000);
					m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.5));
					J0x7A7:

					// End:0x7C6 [Loop If]
					if((m_RotatingDoor.m_iCurrentOpening != 0))
					{
						Sleep(0.5000000);
						// [Loop Continue]
						goto J0x7A7;
					}					
				}
				else
				{
					// End:0x7DB
					if((m_iStateProgress < 6))
					{
						RainbowCannotCompleteOrders();
					}
				}
			}			
		}
		else
		{
			m_TeamManager.ActionCompleted(false);
			goto 'ReinitAction';
		}
	}
	m_iStateProgress = 7;
PerformGrenadeAction:


	// End:0x81E
	if((m_iStateProgress == 8))
	{
		Sleep(1.0000000);
		m_iStateProgress = 9;
		goto 'PerformClearAction';
	}
	// End:0x98D
	if(((m_TeamManager.m_iTeamAction & 64) > 0))
	{
		m_TeamManager.SetTeamState(14);
		Disable('NotifyBump');
		m_vLocationOnTarget = (m_ActionTarget.Location + (float(450) * Vector(m_ActionTarget.Rotation)));
		SetLocation(m_vLocationOnTarget);
		// End:0x8EE
		if((!CanThrowGrenadeIntoRoom(R6Door(m_ActionTarget).m_CorrespondingDoor)))
		{
			m_TeamManager.ResetGrenadeAction();
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 7);
			SwitchWeapon(1);
			Sleep(1.0000000);
			m_iStateProgress = 9;
			goto 'PerformClearAction';
		}
		Focus = self;
		Target = self;
		FinishRotation();
		SetRotation(m_ActionTarget.Rotation);
		SetGunDirection(Target);
		SetGrenadeParameters(PreEntryRoomIsAcceptablyLarge());
		m_pawn.PlayWeaponAnimation();
		FinishAnim(m_pawn.14);
		m_pawn.m_eRepGrenadeThrow = 0;
		SetGunDirection(none);
		Enable('NotifyBump');
		m_iStateProgress = 8;
		SwitchWeapon(1);
		Sleep(m_pawn.EngineWeapon.GetExplosionDelay());
	}
	m_iStateProgress = 9;
PerformClearAction:


	// End:0xBD2
	if(((m_TeamManager.m_iTeamAction & 128) > 0))
	{
		m_TeamManager.SetTeamState(13);
		// End:0x9EB
		if((m_TeamManager.m_Door == none))
		{
			m_TeamManager.m_Door = R6Door(m_ActionTarget);
		}
		m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
		// End:0xADB
		if((m_iStateProgress == 9))
		{
			m_vTargetPosition = m_TeamManager.m_Door.Location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
			MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
			m_TeamManager.EnteredRoom(m_pawn);
			m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
			MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
			StopMoving();
			m_iStateProgress = 10;
		}
		// End:0xB22
		if((m_pawn.m_iID == (m_TeamManager.m_iMemberCount - 1)))
		{
			m_iStateProgress = 11;
			SetTimer(1.0000000, true);
			LookAroundRoom(true);
			Sleep(1.5000000);
			goto 'UpdateStatus';
		}
		// End:0xB40
		if(PostEntryRoomIsAcceptablyLarge())
		{
			m_vTargetPosition = GetEntryPosition(true);
			SetLocation(FocalPoint);			
		}
		else
		{
			FindNearbyWaitSpot(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition);
			SetLocation((m_vTargetPosition + (float(60) * (m_vTargetPosition - Pawn.Location))));
		}
		R6PreMoveTo(m_vTargetPosition, Location, 5);
		MoveToPosition(m_vTargetPosition, Rotator((Location - m_vTargetPosition)));
		StopMoving();
		SetTimer(1.0000000, true);
		LookAroundRoom(true);
		m_iStateProgress = 11;
		Sleep(3.0000000);		
	}
	else
	{
		m_iStateProgress = 11;
	}
	J0xBDA:

	// End:0xBFA
	if(m_TeamManager.RainbowIsEngaging())
	{
		Sleep(0.5000000);
		goto 'UpdateStatus';
	}
	// End:0xD0D
	if(((m_TeamManager.m_iTeamAction & 128) > 0))
	{
		m_TeamManager.ActionCompleted(true);
		m_iStateProgress = 12;
		// End:0xD0A
		if(((m_TeamManager.m_Door != none) && (m_pawn.m_iID == (m_TeamManager.m_iMemberCount - 1))))
		{
			m_vTargetPosition = (m_TeamManager.m_Door.m_CorrespondingDoor.Location - (float(96) * Vector(m_TeamManager.m_Door.m_CorrespondingDoor.Rotation)));
			SetLocation((m_TeamManager.m_Door.Location + (float(200) * Vector(m_TeamManager.m_Door.Rotation))));
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
			MoveTo(m_vTargetPosition, self);
		}		
	}
	else
	{
		m_TeamManager.ActionCompleted(true);
		m_iStateProgress = 12;
	}
	J0xD25:

	m_ActionTarget = none;
	m_iStateProgress = 13;
WaitForTeamAI:


	Sleep(1.0000000);
	// End:0xD5A
	if((NextState != 'None'))
	{
		m_iStateProgress = 14;
		GotoState(NextState);
	}
	GotoState('HoldPosition');
	stop;		
}

state FindPathToTarget
{
	function EndState()
	{
		SetTimer(0.0000000, false);
		return;
	}

	function Timer()
	{
		// End:0x34
		if(CanThrowGrenade(Pawn.Location, true, false))
		{
			SetTimer(0.0000000, false);
			StopMoving();
			GotoState('TeamMoveTo', 'Action');
		}
		return;
	}
Begin:

	// End:0x21
	if((m_TeamManager.m_iTeamAction == 320))
	{
		SetTimer(0.3000000, true);
	}
	// End:0x3E
	if((m_DesiredTarget != none))
	{
		MoveTarget = FindPathToward(m_DesiredTarget, true);		
	}
	else
	{
		MoveTarget = FindPathTo(m_vDesiredLocation, true);
	}
	// End:0x1D5
	if((MoveTarget != none))
	{
		// End:0xFD
		if(NeedToOpenDoor(MoveTarget))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
			MoveToPosition(m_pawn.m_Door.Location, m_pawn.m_Door.Rotation);
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			Sleep(1.0000000);
			GotoStateLeadRoomEntry();
		}
		m_TargetLadder = R6Ladder(MoveTarget);
		// End:0x182
		if((((m_pawn.m_Ladder != none) && (m_TargetLadder != none)) && (m_pawn.m_Ladder != m_TargetLadder)))
		{
			m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_pawn.m_Ladder.MyLadder), true, m_pawn.m_iID);
		}
		R6PreMoveToward(MoveTarget, MoveTarget, 4);
		MoveToward(MoveTarget);
		// End:0x1BB
		if((m_DesiredTarget != none))
		{
			// End:0x1B8
			if(actorReachable(m_DesiredTarget))
			{
				goto 'End';
			}			
		}
		else
		{
			// End:0x1CC
			if(pointReachable(m_vDesiredLocation))
			{
				goto 'End';
			}
		}
		goto 'Begin';		
	}
	else
	{
		// End:0x203
		if((m_TeamManager.m_iTeamAction != 0))
		{
			// End:0x203
			if((!m_TeamManager.m_bGrenadeInProximity))
			{
				RainbowCannotCompleteOrders();
			}
		}
	}
	J0x203:

	R6PreMoveTo(m_vDesiredLocation, m_vDesiredLocation, 4);
	MoveTo(m_vDesiredLocation);
	GotoState(m_PostFindPathToState);
	stop;			
}

state RoomEntry
{
	function BeginState()
	{
		m_pawn.ResetBoneRotation();
		m_pawn.m_bAvoidFacingWalls = false;
		m_bReactToNoise = true;
		m_bEnteredRoom = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		ReInitEntryPositions();
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = true;
		m_bReactToNoise = false;
		// End:0x2C
		if((m_iStateProgress == 5))
		{
			m_iStateProgress = 0;
		}
		m_bIndividualAttacks = true;
		SetTimer(0.0000000, false);
		m_pawn.m_u8DesiredYaw = 0;
		return;
	}

	function Timer()
	{
		(m_iTurn++);
		LookAroundRoom(false);
		return;
	}

	function bool HasEnteredRoom(R6Pawn member)
	{
		// End:0x65
		if((VSize((member.Location - m_TeamManager.m_Door.Location)) < VSize((member.Location - m_TeamManager.m_Door.m_CorrespondingDoor.Location))))
		{
			return false;			
		}
		else
		{
			return true;
		}
		return;
	}

	function SetMemberFocus()
	{
		// End:0x195
		if(PreEntryRoomIsAcceptablyLarge())
		{
			// End:0xB0
			if((m_pawn.m_iID == 3))
			{
				// End:0x68
				if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
				{
					SetLocation((Pawn.Location - (float(300) * Vector(m_TeamManager.m_Door.Rotation))));					
				}
				else
				{
					SetLocation((m_TeamManager.m_Door.Location - (float(300) * Vector(m_TeamManager.m_Door.Rotation))));
				}
				Focus = self;				
			}
			else
			{
				// End:0x175
				if(((m_pawn.m_iID == 2) && ((!m_TeamLeader.m_bIsPlayer) || (m_TeamLeader.m_bIsPlayer && (!m_TeamManager.m_bTeamIsSeparatedFromLeader)))))
				{
					SetLocation(((Pawn.Location - (float(300) * Normal((m_TeamManager.m_Door.Location - Pawn.Location)))) - (float(200) * Vector(m_TeamManager.m_Door.Rotation))));
					Focus = self;					
				}
				else
				{
					SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
				}
			}			
		}
		else
		{
			// End:0x205
			if((m_pawn.m_iID == (m_TeamManager.m_iMemberCount - 1)))
			{
				SetLocation((Pawn.Location - (float(200) * Normal((m_TeamManager.m_Door.Location - Pawn.Location)))));
				Focus = self;				
			}
			else
			{
				SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
			}
		}
		return;
	}

	function Vector GetSingleFilePosition()
	{
		local Vector vDir;

		vDir = (m_PaceMember.Location - Pawn.Location);
		return (m_PaceMember.Location - (GetFormationDistance() * Normal(vDir)));
		return;
	}

	function CoverRear()
	{
		// End:0x43
		if((m_TeamManager.m_iTeamAction == 0))
		{
			SetLocation((Pawn.Location + (Pawn.Location - FocalPoint)));
			Focus = self;
		}
		return;
	}

	function float DistanceToLocation(Vector vTarget)
	{
		return VSize((Pawn.Location - vTarget));
		return;
	}

	function R6Pawn.eMovementPace GetRoomEntryPace(bool bRun)
	{
		local R6Pawn.eMovementPace ePace;
		local bool bCrouchedEntry;

		// End:0x56
		if(m_TeamLeader.m_bIsPlayer)
		{
			// End:0x3D
			if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
			{
				bCrouchedEntry = m_PaceMember.bIsCrouched;				
			}
			else
			{
				bCrouchedEntry = m_TeamLeader.bIsCrouched;
			}			
		}
		else
		{
			bCrouchedEntry = (int(m_TeamManager.m_eMovementSpeed) == int(2));
		}
		// End:0x9B
		if(bCrouchedEntry)
		{
			// End:0x90
			if(bRun)
			{
				ePace = 3;				
			}
			else
			{
				ePace = 2;
			}			
		}
		else
		{
			// End:0xAF
			if(bRun)
			{
				ePace = 5;				
			}
			else
			{
				ePace = 4;
			}
		}
		return ePace;
		return;
	}
Begin:

	switch(m_iStateProgress)
	{
		// End:0x14
		case 0:
			goto 'GetIntoPosition';
			// End:0x46
			break;
		// End:0x21
		case 1:
			goto 'WaitForGo';
			// End:0x46
			break;
		// End:0x2F
		case 2:
			goto 'PassDoor';
			// End:0x46
			break;
		// End:0x3D
		case 3:
			goto 'EnterRoom';
			// End:0x46
			break;
		// End:0xFFFF
		default:
			goto 'WaitOnLeader';
			break;
	}
	J0x46:

	// End:0x6A
	if((m_TeamManager.m_Door.m_RotatingDoor == none))
	{
		GotoState('FollowLeader');
	}
	// End:0x8E
	if((m_TeamManager.m_Door.m_CorrespondingDoor == none))
	{
		GotoState('FollowLeader');
	}
	// End:0x283
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = GetEntryPosition(false);
		// End:0x283
		if((m_vTargetPosition != Pawn.Location))
		{
			// End:0xE3
			if(((!CanWalkTo(m_vTargetPosition)) && (!pointReachable(m_vTargetPosition))))
			{
				FindPathToTargetLocation(m_vTargetPosition);				
			}
			else
			{
				// End:0x1BB
				if(((m_vPreEntryPositions[0] != vect(0.0000000, 0.0000000, 0.0000000)) && (DistanceToLocation(m_vPreEntryPositions[0]) < DistanceToLocation(m_vTargetPosition))))
				{
					// End:0x170
					if(((m_vPreEntryPositions[1] == vect(0.0000000, 0.0000000, 0.0000000)) || (DistanceToLocation(m_vPreEntryPositions[0]) < DistanceToLocation(m_vPreEntryPositions[1]))))
					{
						R6PreMoveTo(m_vPreEntryPositions[0], m_vPreEntryPositions[0], GetRoomEntryPace(false));
					}
					MoveTo(m_vPreEntryPositions[0]);
					// End:0x1B8
					if((m_vPreEntryPositions[1] != vect(0.0000000, 0.0000000, 0.0000000)))
					{
						R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
						MoveTo(m_vPreEntryPositions[1]);
					}					
				}
				else
				{
					// End:0x218
					if(((m_vPreEntryPositions[1] != vect(0.0000000, 0.0000000, 0.0000000)) && (DistanceToLocation(m_vPreEntryPositions[1]) < DistanceToLocation(m_vTargetPosition))))
					{
						R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
						MoveTo(m_vPreEntryPositions[1]);
					}
				}
				R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.Location, GetRoomEntryPace(false));
				MoveTo(m_vTargetPosition);
				MoveToPosition(m_vTargetPosition, Rotator((m_TeamManager.m_Door.m_CorrespondingDoor.Location - m_vTargetPosition)));
			}
		}
	}
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	m_iStateProgress = 1;
WaitForGo:


	SetMemberFocus();
	StopMoving();
	// End:0x3CE
	if(((m_TeamLeader.m_bIsPlayer && (!HasEnteredRoom(m_PaceMember))) || ((!m_TeamLeader.m_bIsPlayer) && (!R6RainbowAI(m_PaceMember.Controller).m_bEnteredRoom))))
	{
		// End:0x387
		if(((!PreEntryRoomIsAcceptablyLarge()) && (DistanceTo(m_PaceMember) > GetFormationDistance())))
		{
			m_vTargetPosition = GetSingleFilePosition();
			// End:0x365
			if((!pointReachable(m_vTargetPosition)))
			{
				FindPathToTargetLocation(m_PaceMember.Location, m_PaceMember);
			}
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(false));
			MoveTo(m_vTargetPosition);			
		}
		else
		{
			// End:0x3C0
			if(((m_pawn.m_iID == 2) && HasEnteredRoom(m_TeamLeader)))
			{
				Focus = m_TeamManager.m_Door;
			}
			Sleep(0.5000000);
		}
		goto 'WaitForGo';
	}
	m_iStateProgress = 2;
PassDoor:


	Sleep(0.2000000);
	// End:0x3FF
	if((!PostEntryRoomIsAcceptablyLarge()))
	{
		m_TeamManager.EndRoomEntry();
		GotoState('FollowLeader');
	}
	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
	m_vTargetPosition = m_TeamManager.m_Door.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	MoveToPosition(m_vTargetPosition, Rotator((m_vTargetPosition - Pawn.Location)));
	m_TeamManager.EnteredRoom(m_pawn);
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	MoveToPosition(m_vTargetPosition, Rotator((m_vTargetPosition - Pawn.Location)));
	m_iStateProgress = 3;
	// End:0x508
	if(m_PaceMember.m_bIsPlayer)
	{
		m_TeamManager.GetPlayerDirection();
	}
EnterRoom:


	m_vTargetPosition = GetEntryPosition(true);
	SetLocation(FocalPoint);
	R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
	MoveToPosition(m_vTargetPosition, Rotator((Location - m_vTargetPosition)));
	SetTimer(1.0000000, true);
	LookAroundRoom(false);
	m_iStateProgress = 4;
	Sleep(0.5000000);
WaitOnLeader:


	StopMoving();
	Sleep(0.5000000);
	// End:0x588
	if((int(m_eCoverDirection) == int(3)))
	{
		CoverRear();
	}
	// End:0x5ED
	if(((IsMoving(m_PaceMember) && (DistanceTo(m_PaceMember) > float(200))) || (DistanceTo(m_PaceMember) > float(300))))
	{
		// End:0x5DB
		if((int(m_eCoverDirection) == int(3)))
		{
			CoverRear();
		}
		m_iStateProgress = 5;
		GotoState('FollowLeader');		
	}
	else
	{
		goto 'WaitOnLeader';
	}
	stop;				
}

state HoldPosition
{
	function BeginState()
	{
		m_bReactToNoise = true;
		return;
	}

	function EndState()
	{
		m_bReactToNoise = false;
		SetTimer(0.0000000, false);
		return;
	}

	function Timer()
	{
		(m_iWaitCounter++);
		return;
	}
Begin:

	m_TeamManager.SetTeamState(2);
	Focus = none;
	m_iWaitCounter = 0;
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	SetTimer(1.0000000, true);
	Sleep(1.0000000);
Hold:


	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0xAE
	if((((!Pawn.bIsCrouched) && (!Pawn.m_bIsProne)) && (float(m_iWaitCounter) > 8.0000000)))
	{
		Pawn.bWantsToCrouch = true;
		Sleep(0.5000000);
	}
	// End:0xBD
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	Sleep(1.0000000);
	// End:0xDB
	if((NextState != 'None'))
	{
		GotoState(NextState);
	}
	goto 'Hold';
	stop;		
}

state TeamSecureTerrorist
{
	function BeginState()
	{
		m_pawn.ResetBoneRotation();
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump = true;
		m_bStateFlag = false;
		return;
	}

	function EndState()
	{
		m_bIgnoreBackupBump = false;
		// End:0x7B
		if((!m_bStateFlag))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_pawn.m_ePlayerIsUsingHands = 0;
			m_pawn.PlayWeaponAnimation();
			R6Terrorist(m_ActionTarget).ResetArrest();
		}
		// End:0xB4
		if((m_pawn.m_bWeaponIsSecured && (!m_pawn.m_bWeaponTransition)))
		{
			m_pawn.SetNextPendingAction(28);
		}
		return;
	}
Begin:

	// End:0x1F
	if((!R6Pawn(m_ActionTarget).IsAlive()))
	{
		goto 'End';
	}
	// End:0x3C
	if((m_pawn.m_iID == 1))
	{
		Sleep(GetLeadershipReactionTime());
	}
	m_TeamManager.SetTeamState(3);
	// End:0x8B
	if(((!CanWalkTo(m_ActionTarget.Location)) && (!actorReachable(m_ActionTarget))))
	{
		FindPathToTargetLocation(m_ActionTarget.Location, m_ActionTarget);
	}
DirectMove:


	R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
	MoveToward(m_ActionTarget);
	// End:0xBF
	if((DistanceTo(m_ActionTarget) > float(100)))
	{
		goto 'Begin';
	}
	Focus = m_ActionTarget;
	StopMoving();
	Sleep(0.5000000);
	J0xD8:

	// End:0x106 [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0xD8;
	}
Secure:


	Disable('SeePlayer');
	// End:0x12A
	if(R6Terrorist(m_ActionTarget).m_bIsUnderArrest)
	{
		RainbowCannotCompleteOrders();
	}
	m_TeamManager.SetTeamState(17);
	m_pawn.SetNextPendingAction(27);
	FinishAnim(m_pawn.14);
	R6Terrorist(m_ActionTarget).m_controller.DispatchOrder(int(R6Terrorist(m_ActionTarget).1), m_pawn);
	J0x18E:

	// End:0x1B2 [Loop If]
	if((!R6Terrorist(m_ActionTarget).PawnHaveFinishedRotation()))
	{
		Sleep(0.1000000);
		// [Loop Continue]
		goto J0x18E;
	}
	m_pawn.SetNextPendingAction(29);
	FinishAnim(m_pawn.1);
	m_bStateFlag = true;
	m_pawn.SetNextPendingAction(28);
	FinishAnim(m_pawn.14);
End:


	// End:0x225
	if((m_pawn.m_iID == 0))
	{
		m_TeamManager.m_SurrenderedTerrorist = none;
		GotoState('Patrol');		
	}
	else
	{
		m_TeamManager.MoveTeamToCompleted(true);
	}
	stop;		
}

state TeamMoveTo
{
	function BeginState()
	{
		m_pawn.ResetBoneRotation();
		m_pawn.m_bAvoidFacingWalls = false;
		m_iStateProgress = 0;
		return;
	}

	// this code was moved into a function because the BeginState() is not called again when a GotoState() is done on the current state.
	function SetUpTeamMoveTo()
	{
		SetTimer(0.0000000, false);
		m_vTargetPosition = m_TeamManager.m_vActionLocation;
		// End:0xD6
		if((((m_TeamManager.m_iTeamAction & 64) > 0) && (m_iStateProgress == 0)))
		{
			m_iStateProgress = 1;
			// End:0xC2
			if((!CanThrowGrenade(Pawn.Location, false, true)))
			{
				// End:0x91
				if((TooCloseToThrowGrenade(Pawn.Location) && FindRandomNavPointToThrowGrenade()))
				{
					m_iStateProgress = 2;					
				}
				else
				{
					m_vTargetPosition = m_vLocationOnTarget;
					(m_vTargetPosition.Z += Pawn.CollisionHeight);
					SetTimer(0.3000000, true);
				}				
			}
			else
			{
				m_vTargetPosition = Pawn.Location;
			}
		}
		return;
	}

	function EndState()
	{
		SetTimer(0.0000000, false);
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		ResetTeamMoveTo();
		return;
	}

    //------------------------------------------------------------------
    // FindRandomNavPointToThrowGrenade:
    //	try to find a spot to throw a grenade. Not too far from where he's
    //  standing.
    //------------------------------------------------------------------
	function bool FindRandomNavPointToThrowGrenade()
	{
		local Actor Actor;
		local int i, iSize;
		local Vector vLocationList[10];
		local int iLocationListIndex, iDistance;

		J0x00:
		// End:0xD8 [Loop If]
		if((i < 10))
		{
			Actor = FindRandomDest(true);
			// End:0xCE
			if(((!Actor.IsA('R6Ladder')) && (Abs((Actor.Location.Z - Pawn.Location.Z)) < float(400))))
			{
				// End:0x96
				if(CanThrowGrenade(Actor.Location, false, true))
				{
					m_vTargetPosition = Actor.Location;
					return true;
					// [Explicit Continue]
					goto J0xCE;
				}
				// End:0xCE
				if(TooCloseToThrowGrenade(Actor.Location))
				{
					vLocationList[iLocationListIndex] = Actor.Location;
					(iLocationListIndex++);
				}
			}
			J0xCE:

			(i++);
			// [Loop Continue]
			goto J0x00;
		}
		// End:0x181
		if((iLocationListIndex > 0))
		{
			i = 0;
			i = 0;
			J0xF1:

			// End:0x17F [Loop If]
			if((i < iLocationListIndex))
			{
				// End:0x175
				if((VSize((vLocationList[i] - Pawn.Location)) > float(iDistance)))
				{
					// End:0x175
					if(CanThrowGrenade(vLocationList[i], false, false))
					{
						iDistance = int(VSize((vLocationList[i] - Pawn.Location)));
						m_vTargetPosition = vLocationList[i];
					}
				}
				(++i);
				// [Loop Continue]
				goto J0xF1;
			}
			return true;
		}
		return false;
		return;
	}

	function Timer()
	{
		// End:0x4C
		if(((m_TeamManager.m_iTeamAction & 64) > 0))
		{
			// End:0x4C
			if(CanThrowGrenade(Pawn.Location, true, false))
			{
				SetTimer(0.0000000, false);
				StopMoving();
				GotoState('TeamMoveTo', 'Action');
			}
		}
		return;
	}
Begin:

	// End:0x37
	if((((m_TeamManager.m_iTeamAction & 64) > 0) && (m_vLocationOnTarget == vect(0.0000000, 0.0000000, 0.0000000))))
	{
		goto 'End';
	}
	StopMoving();
	J0x3D:

	// End:0x6B [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x3D;
	}
	SetUpTeamMoveTo();
	Sleep(GetLeadershipReactionTime());
MoveTowardTarget:


	m_TeamManager.SetTeamState(3);
	// End:0xCF
	if(((m_TeamManager.m_iTeamAction & 2048) > 0))
	{
		// End:0xCC
		if((!actorReachable(m_ActionTarget)))
		{
			FindPathToTargetLocation(m_ActionTarget.Location, m_ActionTarget);
		}		
	}
	else
	{
		// End:0xE7
		if((!pointReachable(m_vTargetPosition)))
		{
			FindPathToTargetLocation(m_vTargetPosition);
		}
	}
	J0xE7:

	// End:0x136
	if(((m_TeamManager.m_iTeamAction & 2048) > 0))
	{
		J0x102:

		// End:0x133 [Loop If]
		if((DistanceTo(m_ActionTarget) > float(100)))
		{
			R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
			MoveToward(m_ActionTarget);
			// [Loop Continue]
			goto J0x102;
		}		
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		MoveTo(m_vTargetPosition);
		// End:0x18C
		if(((m_TeamManager.m_iTeamAction != 0) && (int(m_eMoveToResult) == int(2))))
		{
			m_TeamManager.MoveTeamToCompleted(false);
			RainbowCannotCompleteOrders();
		}
	}
	J0x18C:

	// End:0x378
	if(((m_TeamManager.m_iTeamAction & 64) > 0))
	{
		m_TeamManager.SetTeamState(14);
		// End:0x331
		if(CanThrowGrenade(Pawn.Location, false, false))
		{
			// End:0x22E
			if((!ClearThrowIsAvailable(m_vLocationOnTarget)))
			{
				m_vTargetPosition = (Pawn.Location + (float(300) * Normal((m_vLocationOnTarget - Pawn.Location))));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				MoveTo(m_vTargetPosition);
			}
			SetTimer(0.0000000, false);
			Disable('NotifyBump');
			StopMoving();
			Sleep(0.2000000);
			SetLocation(m_vLocationOnTarget);
			Focus = self;
			Target = self;
			SwitchWeapon(m_iActionUseGadgetGroup);
			FinishAnim(m_pawn.14);
			SetRotation(Pawn.Rotation);
			SetGunDirection(Target);
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = 1;
			m_pawn.m_eRepGrenadeThrow = 1;
			m_pawn.PlayWeaponAnimation();
			FinishAnim(m_pawn.14);
			m_pawn.m_eRepGrenadeThrow = 0;
			m_vLocationOnTarget = vect(0.0000000, 0.0000000, 0.0000000);
			m_iStateProgress = 0;
			Enable('NotifyBump');
			SwitchWeapon(1);
			FinishAnim(m_pawn.14);			
		}
		else
		{
			SetTimer(0.3000000, true);
			m_vTargetPosition = m_vLocationOnTarget;
			(m_vTargetPosition.Z += Pawn.CollisionHeight);
			Sleep(0.2000000);
			goto 'Begin';
		}
		Sleep(1.0000000);		
	}
	else
	{
		// End:0x60E
		if((((m_TeamManager.m_iTeamAction & 4096) > 0) || ((m_TeamManager.m_iTeamAction & 8192) > 0)))
		{
			// End:0x605
			if((int(m_eMoveToResult) == int(1)))
			{
				// End:0x40E
				if(((m_TeamManager.m_iTeamAction & 4096) > 0))
				{
					// End:0x3FA
					if((!R6IOObject(m_ActionTarget).m_bIsActivated))
					{
						RainbowCannotCompleteOrders();
					}
					m_TeamManager.SetTeamState(15);					
				}
				else
				{
					m_TeamManager.SetTeamState(16);
				}
				m_vTargetPosition = (m_ActionTarget.Location - (((Pawn.CollisionRadius + m_ActionTarget.CollisionRadius) + float(10)) * Vector(m_ActionTarget.Rotation)));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				MoveToPosition(m_vTargetPosition, Rotator((m_ActionTarget.Location - m_vTargetPosition)));
				Focus = m_ActionTarget;
				FinishRotation();
				m_pawn.SetNextPendingAction(27);
				FinishAnim(m_pawn.14);
				m_pawn.m_eDeviceAnim = R6IOObject(m_ActionTarget).m_eAnimToPlay;
				m_pawn.SetNextPendingAction(18);
				R6IOObject(m_ActionTarget).PerformSoundAction(0);
				m_pawn.m_bInteractingWithDevice = true;
				Sleep(R6IOObject(m_ActionTarget).GetTimeRequired(m_pawn));
				R6IOObject(m_ActionTarget).ToggleDevice(m_pawn);
				R6IOObject(m_ActionTarget).PerformSoundAction(2);
				PlaySoundActionCompleted(R6IOObject(m_ActionTarget).m_eAnimToPlay);
				m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
				m_pawn.m_bInteractingWithDevice = false;
				m_pawn.m_ePlayerIsUsingHands = 0;
				m_pawn.PlayWeaponAnimation();
				Sleep(1.0000000);
				m_pawn.SetNextPendingAction(28);
				FinishAnim(m_pawn.14);				
			}
			else
			{
				RainbowCannotCompleteOrders();
			}			
		}
		else
		{
			// End:0x6A8
			if(((m_TeamManager.m_iTeamAction & 2048) > 0))
			{
				// End:0x674
				if((R6Hostage(m_ActionTarget).m_escortedByRainbow != none))
				{
					R6Hostage(m_ActionTarget).m_controller.DispatchOrder(int(R6Hostage(m_ActionTarget).2));					
				}
				else
				{
					R6Hostage(m_ActionTarget).m_controller.DispatchOrder(int(R6Hostage(m_ActionTarget).1), m_pawn);
				}
			}
			Sleep(1.0000000);
		}
	}
	// End:0x6D4
	if((m_pawn.m_iID == 0))
	{
		m_TeamManager.ActionCompleted(true);
	}
	m_TeamManager.RestoreTeamOrder();
End:


	// End:0x701
	if((m_pawn.m_iID == 0))
	{
		GotoState('Patrol');		
	}
	else
	{
		m_TeamManager.MoveTeamToCompleted(true);
		NextState = 'None';
		GotoState('HoldPosition');
	}
	stop;				
}

state WaitForTeam
{
	function BeginState()
	{
		m_bReactToNoise = true;
		return;
	}

	function EndState()
	{
		m_bReactToNoise = false;
		return;
	}
Begin:

	// End:0x1A
	if((m_TeamManager.m_iMemberCount == 1))
	{
		goto 'Wait';
	}
	// End:0x1B3
	if((m_TeamManager.m_PlanActionPoint != none))
	{
		m_vTargetPosition = m_pawn.m_Ladder.Location;
		// End:0x7B
		if((m_TeamManager.m_PlanActionPoint == m_pawn.m_Ladder))
		{
			m_TeamManager.ActionPointReached();
		}
		J0x7B:

		// End:0x1B0 [Loop If]
		if((VSize((m_vTargetPosition - Pawn.Location)) < float(300)))
		{
			// End:0xB5
			if((m_TeamManager.m_PlanActionPoint == none))
			{
				// [Explicit Break]
				goto J0x1B0;
			}
			// End:0x10B
			if((((m_pawn.m_Door != none) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed) && NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint)))
			{
				// [Explicit Break]
				goto J0x1B0;
			}
			// End:0x165
			if((((m_TeamManager.m_PlanActionPoint == m_pawn.m_Ladder) || (!actorReachable(m_TeamManager.m_PlanActionPoint))) || (int(m_TeamManager.m_eNextAPAction) != int(0))))
			{
				goto 'FindNearbySpot';
			}
			R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
			MoveToward(m_TeamManager.m_PlanActionPoint);
			m_TeamManager.ActionPointReached();
			// [Loop Continue]
			goto J0x7B;
		}
		J0x1B0:
		
	}
	else
	{
FindNearbySpot:


		FindNearbyWaitSpot(m_pawn.m_Ladder, m_vTargetPosition);
		// End:0x1FE
		if((m_vTargetPosition != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetTeamPace());
			MoveTo(m_vTargetPosition);
		}
	}
	J0x1FE:

	Sleep(1.0000000);
	// End:0x256
	if(m_TeamManager.TeamHasFinishedClimbingLadder())
	{
		m_pawn.m_Ladder = none;
		// End:0x24C
		if(m_TeamManager.m_bAllTeamsHold)
		{
			m_TeamManager.AITeamHoldPosition();			
		}
		else
		{
			GotoState('Patrol');
		}		
	}
	else
	{
		goto 'Wait';
	}
	stop;			
}

state Patrol
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_iWaitCounter = 0;
		m_pawn.m_bCanProne = false;
		m_bReactToNoise = true;
		m_bStateFlag = false;
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		SetTimer(0.0000000, false);
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_bIgnoreBackupBump = false;
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
		m_bReactToNoise = false;
		// End:0x80
		if(m_bStateFlag)
		{
			m_TeamManager.ActionNodeCompleted();
		}
		return;
	}

	function bool CornerMovement()
	{
		local Vector PathA, PathB;

		PathA = Normal((MoveTarget.Location - Pawn.Location));
		PathB = Normal((m_NextMoveTarget.Location - MoveTarget.Location));
		// End:0x64
		if((Dot(PathA, PathB) < 0.7070000))
		{
			return true;
		}
		return false;
		return;
	}

	function DispatchInteractions()
	{
		local Actor actionTarget;

		actionTarget = CheckForPossibleInteractions();
		// End:0x1CC
		if((actionTarget != none))
		{
			// End:0x86
			if((((MoveTarget != none) && (VSize((MoveTarget.Location - actionTarget.Location)) < VSize((Pawn.Location - actionTarget.Location)))) && ActorReachableFromLocation(actionTarget, MoveTarget.Location)))
			{
				return;
			}
			// End:0xB6
			if(actionTarget.IsA('R6IOBomb'))
			{
				m_TeamManager.ReorganizeTeamToInteractWithDevice(4096, actionTarget);				
			}
			else
			{
				// End:0xE6
				if(actionTarget.IsA('R6IODevice'))
				{
					m_TeamManager.ReorganizeTeamToInteractWithDevice(8192, actionTarget);					
				}
				else
				{
					// End:0x10F
					if(actionTarget.IsA('R6Terrorist'))
					{
						m_ActionTarget = actionTarget;
						GotoState('TeamSecureTerrorist');						
					}
					else
					{
						// End:0x1CC
						if(actionTarget.IsA('R6Hostage'))
						{
							// End:0x1BC
							if((R6Hostage(actionTarget).IsAlive() && (!R6Hostage(actionTarget).m_bCivilian)))
							{
								// End:0x188
								if((!m_TeamManager.m_bLeaderIsAPlayer))
								{
									m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowTeamVoices(m_pawn, 4);
								}
								R6Hostage(actionTarget).m_controller.DispatchOrder(int(R6Hostage(actionTarget).1), m_pawn);
							}
							m_TeamManager.m_HostageToRescue = none;
						}
					}
				}
			}
		}
		return;
	}

	function Timer()
	{
		(m_iWaitCounter++);
		// End:0x90
		if((((MoveTarget != none) && (m_NextMoveTarget != none)) && (!ActionIsGrenade(m_TeamManager.m_ePlanAction))))
		{
			// End:0x90
			if(((Enemy == none) && (DistanceTo(MoveTarget) < float(200))))
			{
				// End:0x90
				if((CornerMovement() && (m_NextMoveTarget != none)))
				{
					Focus = m_NextMoveTarget;
					FocalPoint = m_NextMoveTarget.Location;
				}
			}
		}
		// End:0xD1
		if(m_bTeamMateHasBeenKilled)
		{
			m_bTeamMateHasBeenKilled = false;
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			NextState = 'Patrol';
			GotoState('HoldPosition');
			return;
		}
		// End:0xEC
		if(((float(m_iWaitCounter) % float(10)) == float(0)))
		{
			DispatchInteractions();
		}
		return;
	}

	function bool ConfirmActionPointReached()
	{
		// End:0x2B
		if((VSize((MoveTarget.Location - Pawn.Location)) < float(100)))
		{
			return true;
		}
		return false;
		return;
	}

	function bool IsCloseEnoughToInteractWith(Actor actionTarget)
	{
		// End:0x0D
		if((actionTarget == none))
		{
			return false;
		}
		// End:0x5B
		if(((DistanceTo(actionTarget) < float(500)) && (Abs((Pawn.Location.Z - actionTarget.Location.Z)) < float(100))))
		{
			return true;
		}
		return false;
		return;
	}

	function Actor CheckForPossibleInteractions()
	{
		local int i;
		local R6InteractiveObject aIntActor;
		local R6Terrorist terro;

		i = 0;
		J0x07:

		// End:0x7C [Loop If]
		if((i < m_TeamManager.m_InteractiveObjectList.Length))
		{
			aIntActor = m_TeamManager.m_InteractiveObjectList[i];
			// End:0x72
			if((aIntActor != none))
			{
				// End:0x72
				if((R6IOObject(aIntActor).m_bIsActivated && IsCloseEnoughToInteractWith(aIntActor)))
				{
					return aIntActor;
				}
			}
			(i++);
			// [Loop Continue]
			goto J0x07;
		}
		// End:0xB6
		if((m_TeamManager.m_HostageToRescue != none))
		{
			// End:0xB6
			if(IsCloseEnoughToInteractWith(m_TeamManager.m_HostageToRescue))
			{
				return m_TeamManager.m_HostageToRescue;
			}
		}
		// End:0x10D
		if((m_TeamManager.m_SurrenderedTerrorist != none))
		{
			terro = R6Terrorist(m_TeamManager.m_SurrenderedTerrorist);
			// End:0x10D
			if((IsCloseEnoughToInteractWith(terro) && (!terro.m_bIsUnderArrest)))
			{
				return terro;
			}
		}
		return none;
		return;
	}

	function bool ActionIsGrenade(Object.EPlanAction eAPAction)
	{
		// End:0x48
		if(((((int(eAPAction) == int(1)) || (int(eAPAction) == int(2))) || (int(eAPAction) == int(3))) || (int(eAPAction) == int(4))))
		{
			return true;
		}
		return false;
		return;
	}

	function Actor GetFocus()
	{
		// End:0x11
		if((Enemy == none))
		{
			return MoveTarget;
		}
		return Enemy;
		return;
	}
Begin:

	SetTimer(0.1000000, true);
	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x42
	if(((MoveTarget != none) && ConfirmActionPointReached()))
	{
		m_TeamManager.ActionPointReached();
	}
	// End:0x72
	if(m_TeamManager.m_bPendingSnipeUntilGoCode)
	{
		m_TeamManager.ReOrganizeTeamForSniping();
		m_TeamManager.SnipeUntilGoCode();
	}
	// End:0x81
	if(m_bReorganizationPending)
	{
		ReorganizeTeamAsNeeded();
	}
	// End:0xAC
	if(Pawn.m_bIsProne)
	{
		Pawn.m_bWantsToProne = false;
		Sleep(1.0000000);
	}
	// End:0xD3
	if(((!m_pawn.IsStationary()) && SniperChangeToSecondaryWeapon()))
	{
		Sleep(0.5000000);
	}
PickActionPoint:


	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0x130
	if((m_TeamManager.m_iMemberCount > 1))
	{
		J0xF3:

		// End:0x130 [Loop If]
		if((DistanceTo(m_TeamManager.m_Team[(m_TeamManager.m_iMemberCount - 1)]) > float(800)))
		{
			Sleep(0.5000000);
			// [Loop Continue]
			goto J0xF3;
		}
	}
	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x1A4
	if(((MoveTarget != none) || (int(m_TeamManager.m_ePlanAction) != int(0))))
	{
		DispatchInteractions();
		m_iWaitCounter = 0;
		// End:0x1A1
		if((int(m_TeamManager.m_ePlanAction) != int(5)))
		{
			// End:0x1A1
			if(SniperChangeToSecondaryWeapon())
			{
				Sleep(0.5000000);
			}
		}		
	}
	else
	{
		// End:0x1FE
		if((m_iWaitCounter > 30))
		{
			SniperChangeToPrimaryWeapon();
			// End:0x1FE
			if(((!Pawn.bIsCrouched) && (int(m_TeamManager.m_eGoCode) == int(4))))
			{
				Pawn.bWantsToCrouch = true;
				Sleep(0.5000000);
			}
		}
	}
	// End:0x255
	if(NeedToReload())
	{
		// End:0x22C
		if((!Pawn.bIsCrouched))
		{
			Pawn.bWantsToCrouch = true;
		}
		RainbowReloadWeapon();
		StopMoving();
		J0x238:

		// End:0x255 [Loop If]
		if(m_pawn.m_bReloadingWeapon)
		{
			Sleep(0.2000000);
			// [Loop Continue]
			goto J0x238;
		}
	}
	// End:0x296
	if((MoveTarget == none))
	{
		// End:0x288
		if((int(m_TeamManager.m_ePlanAction) == int(5)))
		{
			m_TeamManager.SnipeUntilGoCode();
		}
		Sleep(0.1000000);
		goto 'FormationAroundDoor';
	}
	// End:0x2C7
	if((int(m_TeamManager.m_eNextAPAction) == int(0)))
	{
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();		
	}
	else
	{
		m_NextMoveTarget = none;
		// End:0x2F9
		if((int(m_TeamManager.m_eNextAPAction) == int(6)))
		{
			m_TeamManager.ReOrganizeTeamForBreachDoor();			
		}
		else
		{
			// End:0x324
			if((int(m_TeamManager.m_eNextAPAction) == int(5)))
			{
				m_TeamManager.ReOrganizeTeamForSniping();				
			}
			else
			{
				// End:0x358
				if(ActionIsGrenade(m_TeamManager.m_eNextAPAction))
				{
					m_TeamManager.ReOrganizeTeamForGrenade(m_TeamManager.m_eNextAPAction);
				}
			}
		}
	}
	J0x358:

	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x399
	if((MoveTarget == m_pawn.m_Door))
	{
		m_TeamManager.ActionPointReached();
		goto 'DoorsAndLadders';
	}
	m_TeamManager.SetTeamState(3);
	// End:0x3FA
	if((((m_pawn.m_Door != none) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed) && NextActionPointIsThroughDoor(MoveTarget)))
	{
		goto 'DoorsAndLadders';
	}
	// End:0x413
	if(TargetIsLadderToClimb(R6Ladder(MoveTarget)))
	{
		goto 'DoorsAndLadders';
	}
	// End:0x43E
	if(((!CanWalkTo(MoveTarget.Location)) && (!actorReachable(MoveTarget))))
	{
		goto 'BlockedFindPath';
	}
	R6PreMoveToward(MoveTarget, GetFocus(), GetTeamPace());
	MoveToward(MoveTarget, GetFocus());
	// End:0x4A8
	if(ConfirmActionPointReached())
	{
		// End:0x490
		if(MoveTarget.IsA('R6Door'))
		{
			ForceCurrentDoor(R6Door(MoveTarget));
		}
		m_TeamManager.ActionPointReached();
		goto 'DoorsAndLadders';		
	}
	else
	{
		goto 'MoveToActionPoint';
	}
	J0x4AE:

	MoveTarget = FindPathToward(m_TeamManager.m_PlanActionPoint, true);
	// End:0x52E
	if((MoveTarget != none))
	{
		R6PreMoveToward(MoveTarget, GetFocus(), GetTeamPace());
		MoveToward(MoveTarget, GetFocus());
		// End:0x525
		if((ConfirmActionPointReached() && MoveTarget.IsA('R6Door')))
		{
			ForceCurrentDoor(R6Door(MoveTarget));
		}
		goto 'DoorsAndLadders';		
	}
	else
	{
		R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
		MoveToward(m_TeamManager.m_PlanActionPoint);
		Sleep(1.0000000);
	}
	J0x56F:

	m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
	// End:0x701
	if(((((int(m_TeamManager.m_ePlanAction) == int(0)) && (m_pawn.m_Door != none)) && (NextActionPointIsThroughDoor(m_NextMoveTarget) || NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint))) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
	{
		// End:0x685
		if(((m_TeamManager.m_PlanActionPoint == m_pawn.m_Door) || (m_NextMoveTarget == m_pawn.m_Door)))
		{
			R6PreMoveToward(m_pawn.m_Door, m_pawn.m_Door, GetTeamPace());
			MoveToward(m_pawn.m_Door);
			m_TeamManager.ActionPointReached();
		}
		// End:0x6DE
		if(((!m_TeamManager.m_bEntryInProgress) || (m_TeamManager.m_Door != m_pawn.m_Door)))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		}
		SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
		GotoStateLeadRoomEntry();
	}
	m_TargetLadder = R6Ladder(MoveTarget);
	// End:0x754
	if(TargetIsLadderToClimb(m_TargetLadder))
	{
		MoveTarget = m_pawn.m_Ladder;
		NextState = 'WaitForTeam';
		m_TeamManager.TeamLeaderIsClimbingLadder();
		GotoState('ApproachLadder');
	}
FormationAroundDoor:


	// End:0x78E
	if(((int(m_TeamManager.m_ePlanAction) == int(0)) && (int(m_TeamManager.m_eGoCode) == int(4))))
	{
		goto 'PerformPlanningAction';
	}
	// End:0x918
	if((((!m_TeamManager.m_bEntryInProgress) && (m_pawn.m_Door != none)) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
	{
		// End:0x81F
		if(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
		{
			GotoLockPickState(m_pawn.m_Door.m_RotatingDoor);
		}
		Sleep(1.0000000);
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		// End:0x8F2
		if(PreEntryRoomIsAcceptablyLarge())
		{
			m_vTargetPosition = GetEntryPosition(false);
			// End:0x8F2
			if((m_vTargetPosition != vect(0.0000000, 0.0000000, 0.0000000)))
			{
				R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, GetTeamPace());
				MoveTo(m_vTargetPosition);
				MoveToPosition(m_vTargetPosition, Rotator((m_pawn.m_Door.m_CorrespondingDoor.Location - m_vTargetPosition)));
			}
		}
		StopMoving();
		SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
		FinishRotation();
	}
PerformPlanningAction:


	// End:0xE34
	if(ActionIsGrenade(m_TeamManager.m_ePlanAction))
	{
		// End:0x9EE
		if(m_TeamManager.m_bSkipAction)
		{
			m_TeamManager.ActionNodeCompleted();
			// End:0x9E8
			if((((m_pawn.m_Door != none) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed) && NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint)))
			{
				m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
				SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
				GotoStateLeadRoomEntry();
			}
			goto 'PickActionPoint';
		}
		// End:0xA16
		if((m_iActionUseGadgetGroup == 0))
		{
			m_TeamManager.ReOrganizeTeamForGrenade(m_TeamManager.m_ePlanAction);
		}
		// End:0xA47
		if((m_pawn.m_iCurrentWeapon != m_iActionUseGadgetGroup))
		{
			SwitchWeapon(m_iActionUseGadgetGroup);
			FinishAnim(m_pawn.14);
		}
		m_bIgnoreBackupBump = true;
		m_ActionTarget = m_pawn.m_Door;
		// End:0xB47
		if(((m_pawn.m_Door != none) && m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
		{
			m_RotatingDoor = m_pawn.m_Door.m_RotatingDoor;
			SetFocusToDoorKnob(m_RotatingDoor);
			FinishRotation();
			m_pawn.PlayDoorAnim(m_RotatingDoor);
			Sleep(0.5000000);
			m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.1));
			J0xB05:

			// End:0xB47 [Loop If]
			if(m_RotatingDoor.m_bIsDoorClosed)
			{
				// End:0xB3C
				if((!m_RotatingDoor.m_bInProcessOfOpening))
				{
					Sleep(1.0000000);
					goto 'PerformPlanningAction';					
				}
				else
				{
					Sleep(0.1000000);
				}
				// [Loop Continue]
				goto J0xB05;
			}
		}
		// End:0xBF2
		if((m_ActionTarget != none))
		{
			// End:0xBAA
			if((!PreEntryRoomIsAcceptablyLarge()))
			{
				R6PreMoveToward(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor, GetTeamPace());
				MoveToward(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor);
				StopMoving();
			}
			// End:0xBEF
			if((!CanThrowGrenadeIntoRoom(m_pawn.m_Door.m_CorrespondingDoor, m_TeamManager.m_vPlanActionLocation)))
			{
				m_TeamManager.ActionNodeCompleted();
				goto 'PostThrowGrenade';
			}			
		}
		else
		{
			// End:0xC72
			if((!ClearThrowIsAvailable(m_TeamManager.m_vPlanActionLocation)))
			{
				m_vTargetPosition = (Pawn.Location + (float(300) * Normal((m_TeamManager.m_vPlanActionLocation - Pawn.Location))));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				MoveTo(m_vTargetPosition);
				StopMoving();
				Sleep(1.0000000);
			}
		}
		// End:0xCB1
		if((m_TeamManager.m_vPlanActionLocation != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			m_vLocationOnTarget = m_TeamManager.m_vPlanActionLocation;
			SetLocation(m_vLocationOnTarget);			
		}
		else
		{
			SetLocation((Pawn.Location + (float(100) * Vector(Pawn.Rotation))));
		}
		Target = self;
		Focus = self;
		FinishRotation();
		SetRotation(Pawn.Rotation);
		SetGunDirection(Target);
		SetGrenadeParameters(((m_ActionTarget != none) && PreEntryRoomIsAcceptablyLarge()), true);
		m_bStateFlag = true;
		m_pawn.PlayWeaponAnimation();
		FinishAnim(m_pawn.14);
		m_pawn.m_eRepGrenadeThrow = 0;
		ResetGadgetGroup();
		m_TeamManager.ActionNodeCompleted();
		m_bStateFlag = false;
		SetGunDirection(none);
PostThrowGrenade:


		m_bIgnoreBackupBump = false;
		SwitchWeapon(1);
		FinishAnim(m_pawn.14);
		Sleep(m_pawn.EngineWeapon.GetExplosionDelay());
		// End:0xE31
		if(((m_pawn.m_Door != none) && (NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint) || ((m_TeamManager.m_PlanActionPoint == m_pawn.m_Door) && NextActionPointIsThroughDoor(m_TeamManager.PreviewNextActionPoint())))))
		{
			m_iStateProgress = 3;
			GotoState('LeadRoomEntry', 'EnterRoomBegin');
		}		
	}
	else
	{
		// End:0xE8B
		if((MoveTarget == none))
		{
			// End:0xE6C
			if((int(m_TeamManager.m_eGoCode) == int(4)))
			{
				m_TeamManager.SetTeamState(2);				
			}
			else
			{
				m_TeamManager.SetTeamState(1);
			}
			StopMoving();
			Sleep(1.0000000);
		}
	}
	// End:0xEE2
	if(((m_TeamManager.m_bEntryInProgress && (int(m_TeamManager.m_eGoCode) == int(4))) && (m_TeamManager.m_PlanActionPoint != none)))
	{
		m_TeamManager.RainbowHasLeftDoor(m_pawn);
	}
	// End:0xF0A
	if((int(m_TeamManager.m_eNextAPAction) == int(0)))
	{
		m_TeamManager.RestoreTeamOrder();
	}
	goto 'PickActionPoint';
	stop;			
}

state PlaceBreachingCharge
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		Focus = m_TeamManager.m_BreachingDoor;
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		m_bIgnoreBackupBump = false;
		// End:0x49
		if((m_iStateProgress == 3))
		{
			m_TeamManager.ActionNodeCompleted();
			m_iStateProgress = 0;
		}
		return;
	}

	function R6Door GetDoorPathNode()
	{
		local float fDistA, fDistB;

		fDistA = VSize((m_TeamManager.m_BreachingDoor.m_DoorActorA.Location - Pawn.Location));
		fDistB = VSize((m_TeamManager.m_BreachingDoor.m_DoorActorB.Location - Pawn.Location));
		// End:0x9A
		if((fDistA < fDistB))
		{
			return m_TeamManager.m_BreachingDoor.m_DoorActorA;			
		}
		else
		{
			return m_TeamManager.m_BreachingDoor.m_DoorActorB;
		}
		return;
	}

	function DetonateBreach()
	{
		// End:0x0D
		if((m_iStateProgress < 1))
		{
			return;
		}
		global.DetonateBreach();
		return;
	}
Begin:

	// End:0x1A
	if((m_TeamManager.m_BreachingDoor == none))
	{
		goto 'WaitToDetonate';
	}
	m_ActionTarget = GetDoorPathNode();
	switch(m_iStateProgress)
	{
		// End:0x3A
		case 0:
			goto 'GetIntoPosition';
			// End:0x50
			break;
		// End:0x47
		case 1:
			goto 'MoveAwayFromDoor';
			// End:0x50
			break;
		// End:0xFFFF
		default:
			goto 'WaitToDetonate';
			break;
	}
	J0x50:

	m_TeamManager.SetTeamState(3);
	R6PreMoveToward(m_ActionTarget, m_TeamManager.m_BreachingDoor, GetTeamPace());
	MoveToward(m_ActionTarget, m_TeamManager.m_BreachingDoor);
	ForceCurrentDoor(R6Door(m_ActionTarget));
	StopMoving();
	Focus = m_pawn.m_Door.m_CorrespondingDoor;
	Sleep(0.5000000);
	// End:0x159
	if((DistanceTo(m_ActionTarget) > float(30)))
	{
		m_vTargetPosition = (Pawn.Location - (float(60) * Vector(Pawn.Rotation)));
		R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_BreachingDoor.Location, 4);
		MoveTo(m_vTargetPosition, m_TeamManager.m_BreachingDoor);
		Sleep(0.5000000);
		goto 'GetIntoPosition';
	}
	m_bIgnoreBackupBump = true;
	m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	m_TeamManager.SetTeamState(20);
	SwitchWeapon(m_iActionUseGadgetGroup);
	Sleep(0.2000000);
	FinishAnim(m_pawn.14);
	m_pawn.PlayBreachDoorAnimation();
	FinishAnim(m_pawn.1);
	Pawn.EngineWeapon.NPCPlaceCharge(m_TeamManager.m_BreachingDoor);
	m_iStateProgress = 1;
	PlaySoundCurrentAction(7);
	Sleep(2.5000000);
	m_bIgnoreBackupBump = false;
MoveAwayFromDoor:


	m_vTargetPosition = GetEntryPosition(false);
	// End:0x2EC
	if((m_vTargetPosition != m_pawn.m_Door.Location))
	{
		// End:0x283
		if(m_pawn.bIsCrouched)
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 2);			
		}
		else
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 4);
		}
		MoveTo(m_vTargetPosition);
		MoveToPosition(m_vTargetPosition, Rotator((m_pawn.m_Door.m_CorrespondingDoor.Location - m_vTargetPosition)));		
	}
	else
	{
		m_vTargetPosition = (m_pawn.m_Door.Location - (float(100) * Vector(m_pawn.m_Door.Rotation)));
		// End:0x36C
		if(m_pawn.bIsCrouched)
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 2);			
		}
		else
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 4);
		}
		MoveTo(m_vTargetPosition);
	}
	StopMoving();
	SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
	FinishRotation();
	// End:0x3EE
	if((int(m_TeamManager.m_eGoCode) == int(4)))
	{
		Sleep(1.0000000);
		DetonateBreach();
	}
	m_TeamManager.PlayWaitingGoCode(m_TeamManager.m_eGoCode);
	m_iStateProgress = 2;
WaitToDetonate:


	m_TeamManager.SetTeamState(1);
	Sleep(0.2000000);
	goto 'WaitToDetonate';
	stop;	
}

state DetonateBreachingCharge
{Begin:

	ResetStateProgress();
	// End:0x3F
	if(((m_TeamManager.m_BreachingDoor == none) || (!m_TeamManager.m_BreachingDoor.ShouldBeBreached())))
	{
		goto 'End';
	}
	J0x3F:

	// End:0x5C [Loop If]
	if(m_TeamManager.m_bTeamIsHoldingPosition)
	{
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x3F;
	}
	Pawn.EngineWeapon.NPCDetonateCharge();
End:


	SwitchWeapon(1);
	Sleep(0.5000000);
	FinishAnim(m_pawn.14);
	// End:0xB8
	if((m_TeamManager.m_PlanActionPoint == m_ActionTarget))
	{
		m_TeamManager.ActionPointReached();
	}
	m_TeamManager.m_BreachingDoor = none;
	ResetGadgetGroup();
	// End:0xE7
	if(m_TeamManager.m_bTeamIsHoldingPosition)
	{
		GotoState('HoldPosition');
	}
	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x134
	if(NextActionPointIsThroughDoor(MoveTarget))
	{
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		GotoStateLeadRoomEntry();		
	}
	else
	{
		m_TeamManager.EndRoomEntry();
		GotoState('Patrol');
	}
	stop;	
}

state LeadRoomEntry
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_bIgnoreBackupBump = true;
		m_bEnteredRoom = false;
		m_bIndividualAttacks = false;
		m_iTurn = 0;
		m_bStateFlag = false;
		return;
	}

	function EndState()
	{
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		m_bIgnoreBackupBump = false;
		m_pawn.m_u8DesiredYaw = 0;
		SetTimer(0.0000000, false);
		// End:0x54
		if((m_iStateProgress == 7))
		{
			m_iStateProgress = 0;
		}
		m_bIndividualAttacks = true;
		return;
	}

	function Timer()
	{
		// End:0x1A
		if((m_iStateProgress >= 5))
		{
			(m_iTurn++);
			LookAroundRoom(true);			
		}
		else
		{
			// End:0x5A
			if((m_pawn.m_iID == 0))
			{
				// End:0x5A
				if((DistanceTo(m_TeamManager.m_PlanActionPoint) < float(150)))
				{
					m_TeamManager.ActionPointReached();
				}
			}
		}
		return;
	}

	function R6Pawn.eMovementPace GetRoomEntryPace(bool bRun)
	{
		local R6Pawn.eMovementPace ePace;
		local bool bCrouchedEntry;

		// End:0x2A
		if(((m_TeamLeader != none) && m_TeamLeader.m_bIsPlayer))
		{
			bCrouchedEntry = false;			
		}
		else
		{
			bCrouchedEntry = (int(m_TeamManager.m_eMovementSpeed) == int(2));
		}
		// End:0x6F
		if(bCrouchedEntry)
		{
			// End:0x64
			if(bRun)
			{
				ePace = 3;				
			}
			else
			{
				ePace = 2;
			}			
		}
		else
		{
			// End:0x83
			if(bRun)
			{
				ePace = 5;				
			}
			else
			{
				ePace = 4;
			}
		}
		return ePace;
		return;
	}
Begin:

	StopMoving();
	// End:0x34
	if((m_TeamManager.m_Door == none))
	{
		m_TeamManager.RainbowHasLeftDoor(m_pawn);
		goto 'Completed';
	}
	// End:0x60
	if((!m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed))
	{
		goto 'EnterRoomBegin';
	}
	switch(m_iStateProgress)
	{
		// End:0x74
		case 0:
			goto 'PrepareForRoomEntry';
			// End:0xC2
			break;
		// End:0x81
		case 1:
			goto 'OpenDoor';
			// End:0xC2
			break;
		// End:0x8F
		case 2:
			goto 'PreEnterRoom';
			// End:0xC2
			break;
		// End:0x9D
		case 3:
			goto 'EnterRoomBegin';
			// End:0xC2
			break;
		// End:0xAB
		case 4:
			goto 'InsideRoom';
			// End:0xC2
			break;
		// End:0xB9
		case 5:
			goto 'EntryFinished';
			// End:0xC2
			break;
		// End:0xFFFF
		default:
			goto 'Completed';
			break;
	}
	J0xC2:

	// End:0xDC
	if((m_TeamManager.m_Door == none))
	{
		goto 'EntryFinished';
	}
	// End:0x121
	if((!PreEntryRoomIsAcceptablyLarge()))
	{
		R6PreMoveToward(m_TeamManager.m_Door, m_TeamManager.m_Door, GetRoomEntryPace(false));
		MoveToward(m_TeamManager.m_Door);
	}
	// End:0x162
	if(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorLocked)
	{
		GotoLockPickState(m_TeamManager.m_Door.m_RotatingDoor);
	}
	StopMoving();
	J0x168:

	// End:0x187 [Loop If]
	if((!m_TeamManager.LastMemberIsStationary()))
	{
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x168;
	}
	// End:0x244
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = GetEntryPosition(false);
		// End:0x244
		if(((VSize((m_vTargetPosition - Pawn.Location)) > float(30)) && (m_vTargetPosition != vect(0.0000000, 0.0000000, 0.0000000))))
		{
			R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.Location, GetRoomEntryPace(false));
			MoveTo(m_vTargetPosition);
			MoveToPosition(m_vTargetPosition, Rotator((m_TeamManager.m_Door.m_CorrespondingDoor.Location - m_vTargetPosition)));
			StopMoving();
		}
	}
	m_iStateProgress = 1;
OpenDoor:


	// End:0x2C3
	if((!m_TeamManager.m_bLeaderIsAPlayer))
	{
		J0x25F:

		// End:0x2C3 [Loop If]
		if((int(m_TeamManager.m_eGoCode) != int(4)))
		{
			m_TeamManager.SetTeamState(1);
			// End:0x2B8
			if(NeedToReload())
			{
				RainbowReloadWeapon();
				J0x298:

				// End:0x2B5 [Loop If]
				if(m_pawn.m_bReloadingWeapon)
				{
					Sleep(0.2000000);
					// [Loop Continue]
					goto J0x298;
				}				
			}
			else
			{
				Sleep(0.5000000);
			}
			// [Loop Continue]
			goto J0x25F;
		}
	}
	m_TeamManager.SetTeamState(9);
	SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
	Sleep(0.5000000);
	m_pawn.PlayDoorAnim(m_TeamManager.m_Door.m_RotatingDoor);
	Sleep(0.5000000);
	m_pawn.ServerPerformDoorAction(m_TeamManager.m_Door.m_RotatingDoor, int(m_TeamManager.m_Door.m_RotatingDoor.1));
	m_iStateProgress = 2;
	J0x374:

	// End:0x3DA [Loop If]
	if(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed)
	{
		// End:0x3CF
		if((!m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening))
		{
			Sleep(1.0000000);
			goto 'OpenDoor';			
		}
		else
		{
			Sleep(0.1000000);
		}
		// [Loop Continue]
		goto J0x374;
	}
	// End:0x407
	if((m_TeamManager.m_Door == none))
	{
		m_TeamManager.m_Door = R6Door(m_ActionTarget);
	}
	m_iStateProgress = 3;
EnterRoomBegin:


	SetTimer(0.2000000, true);
	m_TeamManager.SetTeamState(13);
	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
	m_vTargetPosition = m_TeamManager.m_Door.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
	m_TeamManager.EnteredRoom(m_pawn);
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	MoveToPosition(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
	m_iStateProgress = 4;
InsideRoom:


	// End:0x543
	if((m_pawn.m_iID == (m_TeamManager.m_iMemberCount - 1)))
	{
		m_iStateProgress = 5;
		goto 'EntryFinished';
	}
	// End:0x58E
	if(PostEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = GetEntryPosition(true);
		SetLocation(FocalPoint);
		R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
		MoveToPosition(m_vTargetPosition, Rotator((Location - m_vTargetPosition)));		
	}
	else
	{
		m_bStateFlag = true;
		// End:0x749
		if(((m_pawn.m_iID == 0) && (m_TeamManager.m_PlanActionPoint != none)))
		{
			SetTimer(0.0000000, false);
			// End:0x61E
			if((!m_TeamManager.m_Door.m_RotatingDoor.m_bBroken))
			{
				J0x5EF:

				// End:0x61E [Loop If]
				if(m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening)
				{
					Sleep(0.1000000);
					// [Loop Continue]
					goto J0x5EF;
				}
			}
			J0x61E:

			// End:0x746 [Loop If]
			if(((((m_TeamManager.m_PlanActionPoint != none) && (DistanceTo(m_TeamManager.m_Door) < float(400))) && ((m_pawn.m_Door == none) || (!m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))) && (int(m_TeamManager.m_ePlanAction) == int(0))))
			{
				// End:0x6C6
				if((!actorReachable(m_TeamManager.m_PlanActionPoint)))
				{
					// [Explicit Break]
					goto J0x746;
				}
				R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetRoomEntryPace(false));
				MoveToward(m_TeamManager.m_PlanActionPoint);
				// End:0x720
				if((DistanceTo(m_TeamManager.m_PlanActionPoint) > float(100)))
				{
					// [Explicit Break]
					goto J0x746;
				}
				m_TeamManager.ActionPointReached();
				Focus = m_TeamManager.m_PlanActionPoint;
				// [Loop Continue]
				goto J0x61E;
			}
			J0x746:
			
		}
		else
		{
			FindNearbyWaitSpot(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition);
			SetLocation((m_vTargetPosition + (float(60) * (m_vTargetPosition - Pawn.Location))));
			R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
			MoveToPosition(m_vTargetPosition, Rotator((Location - m_vTargetPosition)));
		}
	}
	m_iStateProgress = 5;
EntryFinished:


	SetTimer(1.0000000, true);
	LookAroundRoom(true);
	m_TeamManager.RainbowHasLeftDoor(m_pawn);
	m_iStateProgress = 6;
	// End:0x81A
	if((m_pawn.m_iID == (m_TeamManager.m_iMemberCount - 1)))
	{
		Sleep(1.5000000);		
	}
	else
	{
		Sleep(3.0000000);
	}
	J0x822:

	m_iStateProgress = 7;
	// End:0x862
	if((m_pawn.m_iID == 0))
	{
		// End:0x858
		if((!m_bStateFlag))
		{
			m_TeamManager.RestoreTeamOrder();
		}
		GotoState('Patrol');		
	}
	else
	{
		// End:0x881
		if((m_TeamManager.m_iTeamAction != 0))
		{
			GotoState(GetNextTeamActionState());			
		}
		else
		{
			GotoState('FollowLeader');
		}
	}
	stop;			
}

state SnipeUntilGoCode
{
	function BeginState()
	{
		m_pawn.m_bIsSniping = true;
		m_pawn.m_bAvoidFacingWalls = false;
		m_bStateFlag = false;
		return;
	}

	function EndState()
	{
		m_bIgnoreBackupBump = false;
		m_pawn.m_bIsSniping = false;
		m_pawn.m_bAvoidFacingWalls = true;
		m_TeamManager.CheckTeamEngagingStatus();
		return;
	}

//------------------------------------------------------------------
// SeePlayer()                                             
//------------------------------------------------------------------
	event SeePlayer(Pawn seen)
	{
		local R6Pawn aPawn;

		// End:0x18
		if((!m_bStateFlag))
		{
			global.SeePlayer(seen);
			return;
		}
		// End:0x112
		if(m_pawn.IsEnemy(seen))
		{
			aPawn = R6Pawn(seen);
			// End:0x83
			if((((aPawn.m_bIsKneeling || (!aPawn.IsAlive())) || (m_TeamManager == none)) || (Enemy != none)))
			{
				return;
			}
			// End:0x112
			if(AClearShotIsAvailable(seen, m_pawn.GetFiringStartPoint()))
			{
				// End:0xE4
				if((m_TeamManager.m_bSniperHold && (m_TeamManager.m_OtherTeamVoicesMgr != none)))
				{
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 0);
				}
				m_pawn.m_bEngaged = true;
				SetEnemy(seen);
				Target = Enemy;
				Enable('EnemyNotVisible');
			}
		}
		return;
	}

//------------------------------------------------------------------
// EnemyNotVisible()                                       
//------------------------------------------------------------------
	event EnemyNotVisible()
	{
		// End:0x21
		if(((Level.TimeSeconds - LastSeenTime) < 0.5000000))
		{
			return;
		}
		// End:0x68
		if((m_TeamManager.m_bSniperHold && (m_TeamManager.m_OtherTeamVoicesMgr != none)))
		{
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 1);
		}
		StopFiring();
		EndAttack();
		Disable('EnemyNotVisible');
		return;
	}

	function bool NoiseSourceIsVisible()
	{
		// End:0x22
		if((VSize((m_vNoiseFocalPoint - Pawn.Location)) < float(200)))
		{
			return false;
		}
		// End:0x57
		if((Dot(Normal((m_vNoiseFocalPoint - Pawn.Location)), Vector(Pawn.Rotation)) > 0.3000000))
		{
			return true;
		}
		return false;
		return;
	}

	event Timer()
	{
		// End:0x0D
		if((Enemy != none))
		{
			return;
		}
		// End:0x7D
		if((m_vNoiseFocalPoint != vect(0.0000000, 0.0000000, 0.0000000)))
		{
			// End:0x6A
			if((((m_TeamManager.m_iMemberCount == 1) && (!NoiseSourceIsVisible())) && FastTrace(Pawn.Location, m_vNoiseFocalPoint)))
			{
				GotoState('PauseSniping');				
			}
			else
			{
				m_vNoiseFocalPoint = vect(0.0000000, 0.0000000, 0.0000000);
			}
		}
		return;
	}
Begin:

	SetTimer(0.5000000, true);
	Enemy = none;
	Target = Enemy;
	m_TeamManager.CheckTeamEngagingStatus();
	// End:0x58
	if((DistanceTo(m_ActionTarget) > float(300)))
	{
		// End:0x58
		if(SniperChangeToSecondaryWeapon())
		{
			FinishAnim(m_pawn.14);
		}
	}
	J0x58:

	// End:0x8F [Loop If]
	if((DistanceTo(m_ActionTarget) > float(40)))
	{
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
		MoveToward(m_ActionTarget);
		StopMoving();
		// [Loop Continue]
		goto J0x58;
	}
	ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
	FinishRotation();
TakePosition:


	// End:0xBD
	if(SniperChangeToPrimaryWeapon())
	{
		FinishAnim(m_pawn.14);
	}
	// End:0xDD
	if(Pawn.m_bIsProne)
	{
		m_bIgnoreBackupBump = true;
		goto 'LocateEnemy';
	}
	m_vTargetPosition = (Pawn.Location - vect(0.0000000, 0.0000000, 60.0000000));
	// End:0x14E
	if(ClearToSnipe(m_vTargetPosition, m_TeamManager.m_rSnipingDir))
	{
		Pawn.bWantsToCrouch = true;
		Sleep(0.5000000);
		Pawn.m_bWantsToProne = true;
		Sleep(1.5000000);		
	}
	else
	{
		// End:0x18C
		if(ClearToSnipe(Pawn.Location, m_TeamManager.m_rSnipingDir))
		{
			Pawn.bWantsToCrouch = true;
			Sleep(1.0000000);			
		}
		else
		{
			Pawn.bWantsToCrouch = false;
			Pawn.m_bWantsToProne = false;
			Sleep(0.5000000);
		}
	}
	m_pawn.ResetBoneRotation();
	ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
	m_bIgnoreBackupBump = true;
	m_bStateFlag = true;
	Enemy = none;
	m_TeamManager.PlayWaitingGoCode(m_TeamManager.m_eGoCode, true);
LocateEnemy:


	// End:0x233
	if((!m_TeamManager.m_bCAWaitingForZuluGoCode))
	{
		m_TeamManager.SetTeamState(7);
	}
	// End:0x260
	if((Enemy == none))
	{
		ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
		Sleep(0.1000000);
		goto 'LocateEnemy';
	}
EngageEnemy:


	m_TeamManager.CheckTeamEngagingStatus();
	// End:0x301
	if(((!m_TeamManager.m_bSniperHold) && (Enemy != none)))
	{
		Pawn.EngineWeapon.SetRateOfFire(0);
		Focus = Enemy;
		Target = Enemy;
		FinishRotation();
		J0x2C3:

		// End:0x2DE [Loop If]
		if((!IsReadyToFire(Enemy)))
		{
			Sleep(0.2000000);
			// [Loop Continue]
			goto J0x2C3;
		}
		m_TeamManager.RainbowIsEngagingEnemy();
		StartFiring();
		Sleep(0.2000000);
		StopFiring();
	}
	// End:0x310
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	// End:0x321
	if((Enemy == none))
	{
		goto 'LocateEnemy';
	}
	// End:0x3B6
	if((!R6Pawn(Enemy).IsAlive()))
	{
		// End:0x381
		if((m_TeamManager.m_bSniperHold && (m_TeamManager.m_OtherTeamVoicesMgr != none)))
		{
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 1);
		}
		m_TeamManager.DisEngageEnemy(Pawn, Enemy);
		Enemy = none;
		m_pawn.ResetBoneRotation();
		goto 'LocateEnemy';
	}
	Sleep(1.0000000);
	goto 'EngageEnemy';
EndSniping:


	m_pawn.ResetBoneRotation();
	m_bIgnoreBackupBump = false;
	// End:0x406
	if(Pawn.m_bWantsToProne)
	{
		Pawn.m_bWantsToProne = false;
		Sleep(1.0000000);
	}
	Pawn.bWantsToCrouch = false;
WaitForGoCode:


	Sleep(1.0000000);
	goto 'WaitForGoCode';
Finish:


	// End:0x443
	if((m_pawn.m_iID == 0))
	{
		GotoState('Patrol');		
	}
	else
	{
		GotoState('FollowLeader');
	}
	stop;	
}

state PauseSniping
{Begin:

	StopMoving();
	m_vTargetPosition = m_vNoiseFocalPoint;
	m_vNoiseFocalPoint = vect(0.0000000, 0.0000000, 0.0000000);
	// End:0x4F
	if(Pawn.m_bWantsToProne)
	{
		Pawn.m_bWantsToProne = false;
		Sleep(1.0000000);
	}
	Pawn.bWantsToCrouch = false;
LookAround:


	SetLocation(m_vTargetPosition);
	Focus = self;
	FinishRotation();
Wait:


	Sleep(2.5000000);
	// End:0x8B
	if((Enemy != none))
	{
		goto 'Wait';
	}
	GotoState('SnipeUntilGoCode');
	stop;	
}

state TeamClimbStartNoLeader
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_pawn.m_bCanProne = false;
		return;
	}

	function EndState()
	{
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
		return;
	}
Begin:

	m_TeamManager.SetTeamState(3);
	MoveTarget = m_TeamManager.m_TeamLadder;
	// End:0x4F
	if(((MoveTarget == none) || (!MoveTarget.IsA('R6Ladder'))))
	{
		GotoState('HoldPosition');
	}
	m_TargetLadder = R6Ladder(MoveTarget);
	// End:0x9D
	if(((!CanWalkTo(m_TargetLadder.Location)) && (!actorReachable(m_TargetLadder))))
	{
		FindPathToTargetLocation(m_TargetLadder.Location, m_TargetLadder);
	}
	// End:0xF8
	if(m_TargetLadder.m_bIsTopOfLadder)
	{
		m_vTargetPosition = (m_TargetLadder.Location + (float(70) * Vector(m_TargetLadder.Rotation)));
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		MoveTo(m_vTargetPosition);		
	}
	else
	{
		MoveTarget = m_TargetLadder;
		R6PreMoveToward(MoveTarget, MoveTarget, 4);
		MoveToward(MoveTarget);
	}
	J0x11D:

	// End:0x14B [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		Sleep(0.5000000);
		// [Loop Continue]
		goto J0x11D;
	}
	MoveTarget = m_TargetLadder;
WaitAtEndForLeader:


	m_TeamManager.SetTeamState(18);
	NextState = 'TeamClimbEndNoLeader';
	GotoState('ApproachLadder');
	stop;		
}

state TeamClimbEndNoLeader
{Begin:

	// End:0x1D
	if((m_pawn.m_iID == 1))
	{
		Sleep(GetLeadershipReactionTime());
	}
PickDest:


	FindNearbyWaitSpot(m_pawn.m_Ladder, m_vTargetPosition);
	// End:0x53
	if((m_vTargetPosition == vect(0.0000000, 0.0000000, 0.0000000)))
	{
		goto 'WaitAtEndForTeam';		
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		MoveTo(m_vTargetPosition);
	}
	StopMoving();
WaitAtEndForTeam:


	m_pawn.m_Ladder = none;
	Sleep(1.0000000);
	NextState = 'None';
	// End:0xEF
	if((!m_TeamManager.m_bTeamIsClimbingLadder))
	{
		// End:0xC9
		if((m_TeamManager.m_iTeamAction != 0))
		{
			GotoState(GetNextTeamActionState());			
		}
		else
		{
			// End:0xE5
			if(m_TeamManager.m_bTeamIsRegrouping)
			{
				GotoState('FollowLeader');				
			}
			else
			{
				GotoState('HoldPosition');
			}
		}		
	}
	else
	{
		goto 'WaitAtEndForTeam';
	}
	stop;		
}

state TeamClimbLadder
{
	function BeginState()
	{
		m_pawn.m_bAvoidFacingWalls = false;
		m_pawn.ResetBoneRotation();
		m_pawn.m_bCanProne = false;
		return;
	}

	function EndState()
	{
		// End:0x13
		if((m_iStateProgress == 5))
		{
			m_iStateProgress = 0;
		}
		m_pawn.ResetBoneRotation();
		m_pawn.m_bCanProne = m_pawn.default.m_bCanProne;
		return;
	}

	function SetPawnFocus()
	{
		local int iMember;
		local Rotator rOffset;

		// End:0x2C
		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
		{
			iMember = (m_pawn.m_iID - 1);			
		}
		else
		{
			iMember = m_pawn.m_iID;
		}
		switch(iMember)
		{
			// End:0x9E
			case 1:
				// End:0x78
				if(m_pawn.m_Ladder.m_bIsTopOfLadder)
				{
					m_pawn.AimDown();					
				}
				else
				{
					m_pawn.AimUp();
				}
				Focus = m_pawn.m_Ladder;
				// End:0x159
				break;
			// End:0xDB
			case 2:
				SetLocation((m_vTargetPosition + (float(100) * (m_vTargetPosition - m_pawn.m_Ladder.Location))));
				Focus = self;
				// End:0x159
				break;
			// End:0x13C
			case 3:
				rOffset = Rotator((m_vTargetPosition - m_pawn.m_Ladder.Location));
				(rOffset += rot(0, 8192, 0));
				SetLocation((m_vTargetPosition + (float(100) * Vector(rOffset))));
				Focus = self;
				// End:0x159
				break;
			// End:0xFFFF
			default:
				SetLocation(m_pawn.m_Ladder.Location);
				break;
		}
		return;
	}

	function bool LeadHasStartedClimbing()
	{
		// End:0x30
		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
		{
			return m_TeamManager.m_Team[1].m_bIsClimbingLadder;			
		}
		else
		{
			return m_TeamLeader.m_bIsClimbingLadder;
		}
		return;
	}

	function bool NeedToFollowTeam()
	{
		local R6Rainbow aRainbow;

		// End:0x2B
		if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
		{
			aRainbow = m_TeamManager.m_Team[1];			
		}
		else
		{
			aRainbow = m_TeamLeader;
		}
		// End:0x7A
		if(((m_TeamManager.m_TeamLadder != none) && (!PawnIsOnTheSameEndOfLadderAsMember(aRainbow, R6LadderVolume(m_TeamManager.m_TeamLadder.MyLadder)))))
		{
			return false;
		}
		return (IsMoving(aRainbow) && (!aRainbow.m_bIsClimbingLadder));
		return;
	}

	function R6Ladder GetLadderMoveTarget()
	{
		// End:0x66
		if((Pawn.Location.Z > m_TeamManager.m_TeamLadder.MyLadder.Location.Z))
		{
			return R6LadderVolume(m_TeamManager.m_TeamLadder.MyLadder).m_TopLadder;			
		}
		else
		{
			return R6LadderVolume(m_TeamManager.m_TeamLadder.MyLadder).m_BottomLadder;
		}
		return;
	}
Begin:

	switch(m_iStateProgress)
	{
		// End:0x14
		case 0:
			goto 'FollowTeam';
			// End:0x46
			break;
		// End:0x21
		case 1:
			goto 'WaitForLeadToStartClimbing';
			// End:0x46
			break;
		// End:0x2F
		case 2:
			goto 'FormationAroundLadder';
			// End:0x46
			break;
		// End:0x3D
		case 3:
			goto 'WaitForTurnToClimb';
			// End:0x46
			break;
		// End:0xFFFF
		default:
			goto 'ClimbLadder';
			break;
	}
	J0x46:

	// End:0xE3
	if((DistanceTo(m_PaceMember) > (GetFormationDistance() + float(35))))
	{
		m_vTargetPosition = (m_PaceMember.Location + (GetFormationDistance() * Normal((Pawn.Location - m_PaceMember.Location))));
		// End:0xC6
		if((!actorReachable(m_PaceMember)))
		{
			FindPathToTargetLocation(m_PaceMember.Location, m_PaceMember);
		}
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		MoveTo(m_vTargetPosition);		
	}
	else
	{
		Sleep(0.5000000);
	}
	StopMoving();
	// End:0x100
	if(NeedToFollowTeam())
	{
		goto 'FollowTeam';
	}
	m_iStateProgress = 1;
WaitForLeadToStartClimbing:


	// End:0x148
	if((Abs((m_PaceMember.Location.Z - Pawn.Location.Z)) < float(80)))
	{
		m_iStateProgress = 2;
		goto 'FormationAroundLadder';
	}
	// End:0x161
	if((!LeadHasStartedClimbing()))
	{
		Sleep(1.0000000);
		goto 'WaitForLeadToStartClimbing';
	}
	m_iStateProgress = 2;
FormationAroundLadder:


	// End:0x190
	if(m_pawn.m_Ladder.m_bSingleFileFormationOnly)
	{
		StopMoving();
		goto 'WaitForTurnToClimb';
	}
	// End:0x1D5
	if((!m_TeamManager.m_bTeamIsSeparatedFromLeader))
	{
		// End:0x1D5
		if((m_pawn.m_Ladder == none))
		{
			m_pawn.m_Ladder = m_TeamLeader.m_Ladder;
		}
	}
	// End:0x21D
	if((m_pawn.m_Ladder != none))
	{
		m_vTargetPosition = GetLadderPosition();
		// End:0x21D
		if(pointReachable(m_vTargetPosition))
		{
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
			MoveTo(m_vTargetPosition);
			StopMoving();
		}
	}
	SetPawnFocus();
	m_iStateProgress = 3;
WaitForTurnToClimb:


	// End:0x280
	if(((Abs((m_PaceMember.Location.Z - Pawn.Location.Z)) < float(80)) || m_PaceMember.m_bIsClimbingLadder))
	{
		Sleep(1.0000000);
		goto 'WaitForTurnToClimb';
	}
	m_iStateProgress = 4;
ClimbLadder:


	Sleep(0.5000000);
	m_pawn.ResetBoneRotation();
	MoveTarget = GetLadderMoveTarget();
	// End:0x2E9
	if(((!CanWalkTo(MoveTarget.Location)) && (!actorReachable(MoveTarget))))
	{
		FindPathToTargetLocation(MoveTarget.Location, MoveTarget);
	}
	R6PreMoveToward(MoveTarget, MoveTarget, 4);
	MoveToward(MoveTarget);
	m_iStateProgress = 5;
	// End:0x33C
	if(MoveTarget.IsA('R6Ladder'))
	{
		NextState = 'FollowLeader';
		NextLabel = 'Begin';
		GotoState('ApproachLadder');
	}
	stop;			
}

state FollowLeader
{
	function BeginState()
	{
		m_iWaitCounter = 0;
		m_bIsMovingBackwards = false;
		m_ePawnOrientation = 0;
		m_bAlreadyWaiting = false;
		m_vPreviousPosition = vect(0.0000000, 0.0000000, 0.0000000);
		m_bIgnoreBackupBump = false;
		m_iStateProgress = 0;
		m_bReactToNoise = true;
		m_pawn.m_bAvoidFacingWalls = m_pawn.default.m_bAvoidFacingWalls;
		return;
	}

	function EndState()
	{
		m_bIgnoreBackupBump = false;
		m_bReactToNoise = false;
		// End:0x2D
		if((!m_TeamManager.m_bGrenadeInProximity))
		{
			SetTimer(0.0000000, false);
		}
		m_pawn.StopPeeking();
		m_pawn.m_u8DesiredYaw = 0;
		// End:0x96
		if((((!m_TeamManager.m_bLeaderIsAPlayer) && m_TeamManager.m_bTeamIsRegrouping) && (m_PaceMember == m_TeamLeader)))
		{
			m_TeamManager.TeamIsRegroupingOnLead(false);
		}
		return;
	}

	function Timer()
	{
		(m_iWaitCounter++);
		(m_iTurn++);
		// End:0x21
		if((m_iTurn == 6))
		{
			m_iTurn = 0;
		}
		// End:0x71
		if(((((m_pawn.m_iID == 1) || (m_pawn.m_iID == 2)) && IsMoving(Pawn)) && (int(m_ePawnOrientation) != int(5))))
		{
			CheckEnvironment();
		}
		// End:0x8C
		if(m_bIsCatchingUp)
		{
			m_pawn.ResetBoneRotation();			
		}
		else
		{
			SetRainbowOrientation();
		}
		return;
	}

	function bool RainbowShouldWait()
	{
		local float fDistance;

		// End:0x49
		if(((((!m_bSlowedPace) && IsMoving(m_PaceMember)) && (!Pawn.m_bIsProne)) && (!Pawn.bIsCrouched)))
		{
			return false;
		}
		// End:0x5A
		if((m_vTargetPosition == m_vPreviousPosition))
		{
			return true;
		}
		fDistance = GetFormationDistance();
		// End:0x7A
		if(m_bSlowedPace)
		{
			(fDistance *= float(2));
		}
		// End:0x9A
		if(m_pawn.m_bIsProne)
		{
			(fDistance += float(60));			
		}
		else
		{
			// End:0xB9
			if((!m_pawn.m_bIsClimbingStairs))
			{
				(fDistance += float(35));
			}
		}
		// End:0xD1
		if((DistanceTo(m_PaceMember, true) < fDistance))
		{
			return true;
		}
		return false;
		return;
	}

	function Vector GetNextTargetPosition()
	{
		local Vector vDir;
		local Rotator rDir, rOffset;

		// End:0x1A
		if((m_PaceMember == none))
		{
			return Pawn.Location;
		}
		// End:0x183
		if(((((m_bUseStaggeredFormation && (int(m_TeamManager.m_eFormation) == int(m_eFormation))) && (int(m_ePawnOrientation) != int(5))) && (!Pawn.m_bIsProne)) && (!m_bSlowedPace)))
		{
			rDir = Rotator((m_PaceMember.Location - Pawn.Location));
			rOffset = rot(0, 2000, 0);
			// End:0x122
			if(((int(m_eFormation) == int(4)) || (int(m_eFormation) == int(2))))
			{
				// End:0xF5
				if((m_pawn.m_iID == 1))
				{
					(rDir += rOffset);					
				}
				else
				{
					(rDir -= rOffset);
				}
				return (m_PaceMember.Location - (GetFormationDistance() * Vector(rDir)));
			}
			// End:0x183
			if((int(m_eFormation) == int(3)))
			{
				// End:0x156
				if((m_pawn.m_iID == 1))
				{
					(rDir -= rOffset);					
				}
				else
				{
					(rDir += rOffset);
				}
				return (m_PaceMember.Location - (GetFormationDistance() * Vector(rDir)));
			}
		}
		return (m_PaceMember.Location + (GetFormationDistance() * Normal((Pawn.Location - m_PaceMember.Location))));
		return;
	}

	function EngageLadderIfNeeded(R6LadderVolume aVolume)
	{
		// End:0x0D
		if((m_TargetLadder == none))
		{
			return;
		}
		// End:0x45
		if((!PawnIsOnTheSameEndOfLadderAsMember(m_PaceMember, aVolume)))
		{
			m_TeamManager.InstructTeamToClimbLadder(aVolume, true, m_pawn.m_iID);
		}
		return;
	}
Begin:

	// End:0x49
	if((m_PaceMember == none))
	{
		// End:0x49
		if(((m_TeamLeader != none) && (m_TeamManager != none)))
		{
			m_PaceMember = m_TeamManager.m_Team[(m_pawn.m_iID - 1)];
		}
	}
	m_TeamManager.SetFormation(self);
	SetTimer(1.0000000, true);
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0x95
	if(((!m_pawn.IsStationary()) && SniperChangeToSecondaryWeapon()))
	{
		Sleep(0.5000000);
	}
Moving:


	// End:0xA4
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	// End:0xB5
	if(m_bIsCatchingUp)
	{
		m_bIsCatchingUp = false;
	}
	// End:0xE9
	if(((m_PaceMember == m_TeamLeader) && m_TeamLeader.m_bIsPlayer))
	{
		m_TeamManager.SetTeamState(4);
	}
	// End:0xF8
	if(m_bReorganizationPending)
	{
		ReorganizeTeamAsNeeded();
	}
	m_vTargetPosition = GetNextTargetPosition();
	// End:0x299
	if(RainbowShouldWait())
	{
		Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
		// End:0x1E8
		if((!m_bAlreadyWaiting))
		{
			m_iWaitCounter = 0;
			m_pawn.ResetBoneRotation();
			m_pawn.StopPeeking();
			EnsureRainbowIsArmed();
			// End:0x1E0
			if((((int(m_ePawnOrientation) == int(5)) && (!m_bIsMovingBackwards)) && (!Pawn.m_bIsProne)))
			{
				Sleep(0.2000000);
				m_bIsMovingBackwards = true;
				SetLocation((Pawn.Location - (float(2) * (m_PaceMember.Location - Pawn.Location))));
				Focus = self;
			}
			m_bAlreadyWaiting = true;
		}
		// End:0x28B
		if((VSize(m_TeamLeader.Velocity) == float(0)))
		{
			// End:0x28B
			if(((m_iWaitCounter > 6) && (!m_TeamManager.m_bTeamIsClimbingLadder)))
			{
				// End:0x239
				if(SniperChangeToPrimaryWeapon())
				{
					FinishAnim(m_pawn.14);
				}
				// End:0x28B
				if(((!Pawn.bIsCrouched) && (!Pawn.m_bIsProne)))
				{
					m_pawn.StopPeeking();
					Pawn.bWantsToCrouch = true;
					Sleep(0.2000000);
				}
			}
		}
		Sleep(0.2000000);
		goto 'Moving';
	}
	m_vPreviousPosition = m_vTargetPosition;
	// End:0x2D5
	if(m_bAlreadyWaiting)
	{
		m_pawn.StopPeeking();
		Sleep(0.2000000);
		// End:0x2D5
		if(SniperChangeToSecondaryWeapon())
		{
			Sleep(0.5000000);
		}
	}
	m_bAlreadyWaiting = false;
	// End:0x2FF
	if(((!CanWalkTo(m_vTargetPosition)) && (!pointReachable(m_vTargetPosition))))
	{
		goto 'bLocked';
	}
	// End:0x32E
	if((m_PaceMember == m_TeamLeader))
	{
		m_TeamManager.TeamIsSeparatedFromLead(false);
		m_TeamManager.TeamIsRegroupingOnLead(false);
	}
	// End:0x389
	if((((int(m_ePawnOrientation) != int(5)) || Pawn.m_bIsProne) || m_PaceMember.m_bIsProne))
	{
		m_bIsMovingBackwards = false;
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
		SetLocation(m_vTargetPosition);		
	}
	else
	{
		// End:0x420
		if(((m_PaceMember.IsWalking() && (m_iTurn > 2)) && (DistanceTo(m_PaceMember) < (GetFormationDistance() + float(120)))))
		{
			m_bIsMovingBackwards = true;
			SetLocation((Pawn.Location - (float(2) * (m_PaceMember.Location - Pawn.Location))));
			R6PreMoveTo(m_vTargetPosition, Location, GetPace(true));			
		}
		else
		{
			m_bIsMovingBackwards = false;
			SetLocation(m_vTargetPosition);
			// End:0x475
			if((m_PaceMember.bIsCrouched && (DistanceTo(m_PaceMember) > (GetFormationDistance() + float(40)))))
			{
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 3);				
			}
			else
			{
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
			}
		}
	}
	// End:0x4B3
	if(PostureHasChanged())
	{
		Sleep(0.5000000);
		J0x496:

		// End:0x4B3 [Loop If]
		if(m_pawn.m_bPostureTransition)
		{
			Sleep(0.5000000);
			// [Loop Continue]
			goto J0x496;
		}
	}
	MoveTo(m_vTargetPosition, self);
	// End:0x4D5
	if((int(m_eMoveToResult) == int(2)))
	{
		goto 'bLocked';		
	}
	else
	{
		goto 'Moving';
	}
	J0x4DB:

	m_bIsCatchingUp = true;
	// End:0x53F
	if((m_PaceMember == m_TeamLeader))
	{
		m_TeamManager.TeamIsRegroupingOnLead(true);
		J0x502:

		// End:0x53F [Loop If]
		if((DistanceTo(m_TeamManager.m_Team[(m_TeamManager.m_iMemberCount - 1)]) > float(600)))
		{
			Sleep(0.5000000);
			// [Loop Continue]
			goto J0x502;
		}
	}
	m_pawn.StopPeeking();
	m_ePawnOrientation = 0;
	// End:0x565
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	MoveTarget = FindPathToward(m_PaceMember, true);
	// End:0x62D
	if((MoveTarget == none))
	{
		m_pawn.logWarning((("is at location " $ string(Pawn.Location)) $ " and there appear to be insufficient pathnodes..."));
		MoveTo((Pawn.Location + (Normal((m_PaceMember.Location - Pawn.Location)) * float(100))));
		Sleep(1.0000000);
		goto 'bLocked';
	}
	// End:0x672
	if((MoveTarget == m_PaceMember))
	{
		J0x63C:

		// End:0x659 [Loop If]
		if(m_PaceMember.m_bIsClimbingLadder)
		{
			Sleep(1.0000000);
			// [Loop Continue]
			goto J0x63C;
		}
		EngageLadderIfNeeded(R6LadderVolume(m_TargetLadder.MyLadder));
	}
	m_TargetLadder = R6Ladder(MoveTarget);
	// End:0x6E1
	if(TargetIsLadderToClimb(m_TargetLadder))
	{
		m_pawn.m_potentialActionActor = m_TargetLadder.MyLadder;
		m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_TargetLadder.MyLadder), true, m_pawn.m_iID);		
	}
	else
	{
		// End:0x786
		if(NeedToOpenDoor(MoveTarget))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
			MoveToPosition(m_pawn.m_Door.Location, m_pawn.m_Door.Rotation);
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			Sleep(1.0000000);
			GotoStateLeadRoomEntry();
		}
	}
	// End:0x7AD
	if(m_PaceMember.bIsCrouched)
	{
		R6PreMoveToward(MoveTarget, MoveTarget, 3);		
	}
	else
	{
		// End:0x7DB
		if((int(m_pawn.m_eHealth) == int(1)))
		{
			R6PreMoveToward(MoveTarget, MoveTarget, 4);			
		}
		else
		{
			R6PreMoveToward(MoveTarget, MoveTarget, 5);
		}
	}
	// End:0x812
	if(MoveTarget.IsA('R6Ladder'))
	{
		Pawn.bIsWalking = true;
	}
	MoveToward(MoveTarget);
	// End:0x848
	if(((!CanWalkTo(m_PaceMember.Location)) && (!actorReachable(m_PaceMember))))
	{
		goto 'bLocked';		
	}
	else
	{
		goto 'Moving';
	}
	stop;	
}

auto state WaitForGameToStart
{Begin:

	Sleep(0.5000000);
	// End:0x5A
	if((Level.Game.m_bGameStarted && (NextState != 'None')))
	{
		// End:0x50
		if((m_pawn.m_iID == 0))
		{
			Sleep(1.0000000);
		}
		GotoState(NextState);		
	}
	else
	{
		goto 'Begin';
	}
	stop;			
}

state TestBoneRotation
{Begin:

	Sleep(3.0000000);
	goto 'Begin';
	stop;	
}

state WatchPlayer
{
	function BeginState()
	{
		Focus = none;
		return;
	}

	function EndState()
	{
		m_pawn.R6ResetLookDirection();
		Enable('SeePlayer');
		return;
	}
Begin:

	m_pawn.R6LoopAnim('StandSubGunHigh_nt');
Wait:


	Sleep(1.0000000);
	goto 'Wait';
	stop;	
}

defaultproperties
{
	m_bUseStaggeredFormation=true
	m_bIndividualAttacks=true
	m_fAttackTimerRate=0.5000000
	m_fFiringAttackTimer=0.2000000
	bIsPlayer=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eFormation
// REMOVED IN 1.60: var ePawnOrientation
// REMOVED IN 1.60: var eCoverDirection
// REMOVED IN 1.60: function CanClimbObject
