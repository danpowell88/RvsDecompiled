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

	vSightDir = __NFUN_226__(__NFUN_216__(Pawn.Location, seen.Location));
	// End:0x53
	if(__NFUN_176__(__NFUN_219__(Vector(seen.GetViewRotation()), vSightDir), Pawn.PeripheralVision))
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
	if(__NFUN_129__(m_pawn.m_bIsSniping))
	{
		m_TeamManager.RainbowIsEngagingEnemy();
	}
	Enemy = newEnemy;
	LastSeenTime = Level.TimeSeconds;
	// End:0x61
	if(__NFUN_119__(Enemy, none))
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
	if(__NFUN_130__(__NFUN_129__(aTerro.m_bEnteringView), __NFUN_132__(m_TeamManager.m_bLeaderIsAPlayer, m_TeamManager.m_bPlayerHasFocus)))
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
	if(__NFUN_130__(m_pawn.IsEnemy(seen), __NFUN_119__(aPawn.EngineWeapon, none)))
	{
		// End:0x4A
		if(__NFUN_114__(m_TeamManager, none))
		{
			return;
		}
		// End:0xA1
		if(__NFUN_132__(aPawn.m_bIsKneeling, __NFUN_129__(aPawn.IsAlive())))
		{
			// End:0x9F
			if(__NFUN_129__(R6Terrorist(aPawn).m_bIsUnderArrest))
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
		if(__NFUN_154__(int(m_TeamManager.m_eMovementMode), int(2)))
		{
			// End:0xF0
			if(__NFUN_129__(CanBeSeen(seen)))
			{
				PlayVoiceTerroristSpotted(R6Terrorist(aPawn));
				return;
			}
			m_TeamManager.m_eMovementMode = 0;			
		}
		else
		{
			// End:0x16E
			if(__NFUN_154__(int(m_TeamManager.m_eMovementMode), int(1)))
			{
				// End:0x13F
				if(CanBeSeen(seen))
				{
					m_TeamManager.m_eMovementMode = 0;					
				}
				else
				{
					// End:0x16E
					if(__NFUN_129__(Pawn.EngineWeapon.m_bIsSilenced))
					{
						PlayVoiceTerroristSpotted(R6Terrorist(aPawn));
						return;
					}
				}
			}
		}
		// End:0x17B
		if(__NFUN_119__(Enemy, none))
		{
			return;
		}
		// End:0x186
		if(m_bWeaponsDry)
		{
			return;
		}
		// End:0x21B
		if(__NFUN_130__(__NFUN_2222__(seen, m_pawn.GetFiringStartPoint()), __NFUN_155__(int(Pawn.EngineWeapon.m_eWeaponType), int(6))))
		{
			// End:0x21B
			if(__NFUN_132__(__NFUN_129__(m_bIndividualAttacks), m_TeamManager.EngageEnemyIfNotAlreadyEngaged(m_pawn, aPawn)))
			{
				m_pawn.m_bEngaged = true;
				SetEnemy(seen);
				Target = Enemy;
				__NFUN_117__('EnemyNotVisible');
			}
		}		
	}
	else
	{
		// End:0x295
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(aPawn.m_ePawnType), int(3)), aPawn.IsAlive()), __NFUN_129__(R6Hostage(aPawn).m_bExtracted)), __NFUN_114__(R6Hostage(aPawn).m_escortedByRainbow, none)))
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
	if(__NFUN_114__(aPawn, none))
	{
		aPawn = aNoiseMaker.Instigator;
	}
	// End:0x3C
	if(__NFUN_114__(aPawn, none))
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
	if(__NFUN_114__(m_TeamManager, none))
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
	if(__NFUN_154__(int(m_TeamManager.m_eMovementMode), int(0)))
	{
		return;
	}
	// End:0xA6
	if(__NFUN_132__(__NFUN_154__(int(eType), int(2)), __NFUN_154__(int(eType), int(3))))
	{
		// End:0xA6
		if(__NFUN_155__(int(R6Pawn(aNoiseMaker.Owner).m_ePawnType), int(1)))
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
	if(__NFUN_176__(__NFUN_175__(Level.TimeSeconds, LastSeenTime), 0.5000000))
	{
		return;
	}
	StopFiring();
	EndAttack();
	__NFUN_118__('EnemyNotVisible');
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
		if(__NFUN_114__(Enemy, none))
		{
			m_pawn.ResetBoneRotation();
			Pawn.DesiredRotation = Rotator(__NFUN_216__(attacker.Location, Pawn.Location));
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
	if(__NFUN_114__(Enemy, none))
	{
		return false;
	}
	// End:0x41
	if(__NFUN_132__(R6Pawn(Enemy).m_bIsKneeling, __NFUN_129__(R6Pawn(Enemy).IsAlive())))
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
	if(__NFUN_119__(aTarget, none))
	{
		// End:0x2D
		if(__NFUN_114__(aTarget, self))
		{
			vTarget = aTarget.Location;			
		}
		else
		{
			// End:0x52
			if(__NFUN_114__(aTarget, Enemy))
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
		if(__NFUN_114__(aTarget, self))
		{
			rDirection = aTarget.Rotation;			
		}
		else
		{
			vDirection = __NFUN_216__(vTarget, m_pawn.GetFiringStartPoint());
			rDirection = Rotator(vDirection);
		}
		m_pawn.m_u8DesiredPitch = byte(__NFUN_145__(int(byte(__NFUN_156__(rDirection.Pitch, 65535))), 256));
		// End:0x14C
		if(__NFUN_114__(aTarget, Enemy))
		{
			m_pawn.m_u8DesiredYaw = byte(__NFUN_145__(int(byte(__NFUN_156__(int(byte(__NFUN_147__(rDirection.Yaw, Pawn.Rotation.Yaw))), 65535))), 256));			
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
		if(__NFUN_119__(MoveTarget, none))
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
	if(__NFUN_119__(Pawn.EngineWeapon, none))
	{
		// End:0x2A
		if(__NFUN_119__(Enemy, none))
		{
			Target = Enemy;
		}
		__NFUN_299__(Pawn.Rotation);
		bFire = 1;
		Pawn.EngineWeapon.__NFUN_113__('NormalFire');
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
	if(__NFUN_154__(int(m_TeamManager.m_eMovementMode), int(2)))
	{
		return false;
	}
	// End:0x4C
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		m_TeamManager.m_Door = m_pawn.m_Door;
	}
	// End:0x81
	if(__NFUN_132__(__NFUN_114__(m_TeamManager.m_Door, none), __NFUN_114__(m_TeamManager.m_Door.m_CorrespondingDoor, none)))
	{
		return false;
	}
	// End:0xAE
	if(__NFUN_154__(int(m_TeamManager.m_Door.m_CorrespondingDoor.m_eRoomLayout), int(3)))
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
	if(__NFUN_154__(int(m_TeamManager.m_eMovementMode), int(2)))
	{
		return false;
	}
	// End:0x4C
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		m_TeamManager.m_Door = m_pawn.m_Door;
	}
	// End:0x62
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		return false;
	}
	// End:0x86
	if(__NFUN_154__(int(m_TeamManager.m_Door.m_eRoomLayout), int(3)))
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

	fDelay = __NFUN_175__(2.0000000, __NFUN_171__(m_pawn.GetSkill(6), 2.0000000));
	fDelay = __NFUN_246__(fDelay, 0.0000000, 2.0000000);
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
	if(__NFUN_114__(aTarget, none))
	{
		return false;
	}
	vDir = __NFUN_226__(__NFUN_216__(Pawn.Location, aTarget.Location));
	vResult = __NFUN_220__(vDir, Vector(aTarget.Rotation));
	// End:0x67
	if(__NFUN_176__(vResult.Z, float(0)))
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

	vDir = __NFUN_226__(__NFUN_216__(Enemy.Location, Pawn.Location));
	// End:0x5D
	if(__NFUN_177__(__NFUN_219__(vDir, Vector(__NFUN_316__(Pawn.Rotation, m_pawn.m_rRotationOffset))), 0.5000000))
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
	if(__NFUN_151__(m_pawn.m_iCurrentWeapon, 2))
	{
		return;
	}
	m_pawn.m_bReloadToFullAmmo = false;
	// End:0x4A
	if(m_bWeaponsDry)
	{
		// End:0x48
		if(__NFUN_119__(Enemy, none))
		{
			StopFiring();
			EndAttack();
		}
		return;
	}
	// End:0x9D
	if(__NFUN_130__(__NFUN_129__(m_pawn.m_bChangingWeapon), __NFUN_154__(Pawn.EngineWeapon.NumberOfBulletsLeftInClip(), 0)))
	{
		RainbowReloadWeapon();
		// End:0x9D
		if(__NFUN_154__(int(bFire), 1))
		{
			StopFiring();
			EndAttack();
		}
	}
	// End:0xC5
	if(__NFUN_132__(m_pawn.m_bReloadingWeapon, m_pawn.m_bChangingWeapon))
	{
		return;
	}
	// End:0x10A
	if(__NFUN_130__(__NFUN_119__(Enemy, none), __NFUN_132__(R6Pawn(Enemy).m_bIsKneeling, __NFUN_129__(R6Pawn(Enemy).IsAlive()))))
	{
		EndAttack();
	}
	// End:0x18F
	if(__NFUN_154__(int(bFire), 0))
	{
		// End:0x18C
		if(__NFUN_119__(Enemy, none))
		{
			Focus = Enemy;
			Target = Enemy;
			// End:0x18C
			if(AimingAt(Enemy))
			{
				// End:0x16C
				if(__NFUN_130__(m_pawn.IsStationary(), __NFUN_129__(IsReadyToFire(Enemy))))
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
		if(__NFUN_129__(EnemyIsAThreat()))
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
	if(__NFUN_129__(EnemyIsAThreat()))
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
	if(__NFUN_114__(aDoor, none))
	{
		return;
	}
	// End:0x4B
	if(aDoor.m_bTreatDoorAsWindow)
	{
		__NFUN_267__(__NFUN_216__(aDoor.Location, __NFUN_213__(float(30), Vector(aDoor.Rotation))));		
	}
	else
	{
		__NFUN_267__(__NFUN_216__(aDoor.Location, __NFUN_213__(float(128), Vector(aDoor.Rotation))));
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
	if(__NFUN_114__(m_RotatingDoor, none))
	{
		return;
	}
	m_PostLockPickState = __NFUN_284__();
	m_TeamManager.SetTeamState(8);
	__NFUN_113__('LockPickDoor');
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
	__NFUN_113__('HoldPosition');
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
	if(__NFUN_129__(m_pawn.EngineWeapon.HasBulletType('R6FragGrenade')))
	{
		return true;
	}
	// End:0x6D
	if(__NFUN_217__(vTestTarget, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		vTarget = __NFUN_216__(aDoor.Location, __NFUN_213__(float(400), Vector(aDoor.Rotation)));		
	}
	else
	{
		vTarget = vTestTarget;
	}
	HitActor = __NFUN_277__(vHitLocation, vHitNormal, vTarget, __NFUN_216__(aDoor.Location, __NFUN_213__(float(96), Vector(aDoor.Rotation))), false, vect(20.0000000, 20.0000000, 40.0000000));
	// End:0xD1
	if(__NFUN_114__(HitActor, none))
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
	m_PostFindPathToState = __NFUN_284__();
	__NFUN_113__('FindPathToTarget');
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
	if(__NFUN_154__(f, m_pawn.m_iCurrentWeapon))
	{
		return;
	}
	Pawn.R6MakeNoise(11);
	NewWeapon = R6AbstractWeapon(m_pawn.GetWeaponInGroup(f));
	// End:0x105
	if(__NFUN_119__(NewWeapon, none))
	{
		// End:0x87
		if(__NFUN_154__(int(Level.NetMode), int(NM_Standalone)))
		{
			m_pawn.EngineWeapon.__NFUN_113__('None');
		}
		m_pawn.m_iCurrentWeapon = f;
		m_pawn.GetWeapon(NewWeapon);
		m_pawn.m_bChangingWeapon = true;
		// End:0xF6
		if(__NFUN_119__(m_pawn.m_SoundRepInfo, none))
		{
			m_pawn.m_SoundRepInfo.m_CurrentWeapon = byte(__NFUN_147__(f, 1));
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
	if(__NFUN_114__(weapon, none))
	{
		return false;
	}
	// End:0x4B
	if(__NFUN_176__(__NFUN_225__(__NFUN_216__(vPawnLocation, m_vLocationOnTarget)), weapon.GetSaveDistanceToThrow()))
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

	vDir = __NFUN_216__(m_vLocationOnTarget, vPawnLocation);
	fDist = __NFUN_225__(vDir);
	// End:0x32
	if(__NFUN_177__(fDist, float(1500)))
	{
		return false;
	}
	// End:0x4D
	if(__NFUN_130__(bCheckTooClose, TooCloseToThrowGrenade(vPawnLocation)))
	{
		return false;
	}
	vTargetLoc = m_vLocationOnTarget;
	__NFUN_184__(vTargetLoc.Z, float(15));
	// End:0x78
	if(bTraceActors)
	{
		iTraceFlags = 1;
	}
	iTraceFlags = __NFUN_158__(iTraceFlags, 4);
	HitActor = __NFUN_1806__(vHitLocation, vHitNormal, vTargetLoc, vPawnLocation, iTraceFlags, vect(20.0000000, 20.0000000, 10.0000000));
	// End:0xDC
	if(__NFUN_130__(__NFUN_119__(HitActor, none), __NFUN_177__(__NFUN_225__(__NFUN_216__(vHitLocation, vTargetLoc)), float(30))))
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

	HitActor = Pawn.__NFUN_1806__(vHitLocation, vHitNormal, __NFUN_215__(vTarget, vect(0.0000000, 0.0000000, 40.0000000)), Pawn.Location, __NFUN_158__(1, 4), vect(30.0000000, 30.0000000, 15.0000000));
	// End:0x5D
	if(__NFUN_114__(HitActor, none))
	{
		return true;
	}
	// End:0x73
	if(HitActor.__NFUN_303__('R6Pawn'))
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
	__NFUN_280__(0.0000000, false);
	// End:0x9E
	if(m_pawn.m_bInteractingWithDevice)
	{
		m_pawn.m_bInteractingWithDevice = false;
		m_pawn.m_bPostureTransition = false;
		m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
		m_pawn.m_ePlayerIsUsingHands = 0;
		// End:0x9E
		if(__NFUN_119__(R6IOObject(m_ActionTarget), none))
		{
			R6IOObject(m_ActionTarget).PerformSoundAction(1);
		}
	}
	// End:0xE6
	if(__NFUN_130__(m_pawn.m_bWeaponIsSecured, __NFUN_129__(m_pawn.m_bWeaponTransition)))
	{
		m_pawn.SetNextPendingAction(28);
		m_pawn.PlayWeaponAnimation();
	}
	m_pawn.m_iCurrentWeapon = int(__NFUN_246__(float(m_pawn.m_iCurrentWeapon), 1.0000000, 4.0000000));
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
	if(__NFUN_114__(nextActionPoint, none))
	{
		return false;
	}
	// End:0x23
	if(__NFUN_114__(m_pawn.m_Door, none))
	{
		return false;
	}
	// End:0x49
	if(m_pawn.m_Door.m_RotatingDoor.m_bTreatDoorAsWindow)
	{
		return false;
	}
	// End:0xAB
	if(__NFUN_177__(__NFUN_225__(__NFUN_216__(nextActionPoint.Location, m_pawn.m_Door.Location)), __NFUN_225__(__NFUN_216__(nextActionPoint.Location, m_pawn.m_Door.m_CorrespondingDoor.Location))))
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
	if(__NFUN_130__(__NFUN_154__(int(m_pawn.m_ePawnType), int(1)), __NFUN_154__(m_pawn.m_iID, 0)))
	{
		// End:0x56
		if(__NFUN_114__(Ladder, m_TeamManager.m_PlanActionPoint))
		{
			m_TeamManager.ActionPointReached();
		}
	}
	return;
}

function bool TargetIsLadderToClimb(R6Ladder Target)
{
	// End:0x23
	if(__NFUN_132__(__NFUN_114__(Target, none), __NFUN_114__(m_pawn.m_Ladder, none)))
	{
		return false;
	}
	// End:0x3D
	if(__NFUN_114__(m_pawn.m_Ladder, Target))
	{
		return false;
	}
	// End:0x69
	if(__NFUN_119__(Target.MyLadder, m_pawn.m_Ladder.MyLadder))
	{
		return false;
	}
	return true;
	return;
}

function DetonateBreach()
{
	m_iStateProgress = 3;
	__NFUN_113__('DetonateBreachingCharge');
	return;
}

function GotoStateLeadRoomEntry()
{
	ResetStateProgress();
	__NFUN_113__('LeadRoomEntry');
	return;
}

function ForceCurrentDoor(R6Door aDoor)
{
	// End:0x0D
	if(__NFUN_114__(aDoor, none))
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
	if(__NFUN_151__(m_pawn.m_iID, 1))
	{
		return 'FollowLeader';
	}
	// End:0x3B
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 512), 0))
	{
		return 'TeamClimbStartNoLeader';
	}
	// End:0x5C
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 1024), 0))
	{
		return 'TeamSecureTerrorist';
	}
	// End:0xB7
	if(__NFUN_132__(__NFUN_132__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 4096), 0), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 8192), 0)), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 256), 0)))
	{
		return 'TeamMoveTo';
	}
	// End:0x123
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 16), 0), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 32), 0)), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 128), 0)), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0)))
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
	if(__NFUN_114__(m_pawn.EngineWeapon, Pawn.m_WeaponsCarried[__NFUN_147__(m_pawn.m_iCurrentWeapon, 1)]))
	{
		return;
	}
	iWeapon = 0;
	J0x3C:

	// End:0x92 [Loop If]
	if(__NFUN_150__(iWeapon, 4))
	{
		// End:0x88
		if(__NFUN_114__(m_pawn.EngineWeapon, Pawn.m_WeaponsCarried[iWeapon]))
		{
			m_pawn.m_iCurrentWeapon = __NFUN_146__(iWeapon, 1);
			return;
		}
		__NFUN_165__(iWeapon);
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
	if(__NFUN_130__(m_pawn.m_bWeaponIsSecured, __NFUN_129__(m_pawn.m_bWeaponTransition)))
	{
		m_pawn.SetNextPendingAction(28);
		m_pawn.PlayWeaponAnimation();
		return true;
	}
	// End:0xAB
	if(__NFUN_151__(m_pawn.m_iCurrentWeapon, 2))
	{
		// End:0x9E
		if(__NFUN_130__(__NFUN_119__(Pawn.m_WeaponsCarried[0], none), Pawn.m_WeaponsCarried[0].HasAmmo()))
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
		if(__NFUN_154__(m_pawn.m_iCurrentWeapon, 2))
		{
			// End:0x124
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn.m_WeaponsCarried[0], none), __NFUN_155__(int(Pawn.m_WeaponsCarried[0].m_eWeaponType), int(4))), Pawn.m_WeaponsCarried[0].HasAmmo()))
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
	if(__NFUN_114__(Pawn.m_WeaponsCarried[0], none))
	{
		return false;
	}
	// End:0xB5
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn.EngineWeapon, none), __NFUN_129__(m_pawn.m_bChangingWeapon)), __NFUN_114__(Pawn.EngineWeapon, m_pawn.m_WeaponsCarried[1])), Pawn.m_WeaponsCarried[0].HasAmmo()), __NFUN_154__(int(Pawn.m_WeaponsCarried[0].m_eWeaponType), int(4))))
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
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(Pawn.EngineWeapon, none), __NFUN_129__(m_pawn.m_bChangingWeapon)), __NFUN_114__(Pawn.EngineWeapon, m_pawn.m_WeaponsCarried[0])), Pawn.m_WeaponsCarried[1].HasAmmo()), __NFUN_154__(int(Pawn.EngineWeapon.m_eWeaponType), int(4))))
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
	if(__NFUN_130__(__NFUN_154__(m_pawn.m_iID, 1), m_TeamManager.m_bTeamIsSeparatedFromLeader))
	{
		return;
	}
	// End:0x40
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		return;
	}
	// End:0x4D
	if(__NFUN_114__(m_TargetLadder, none))
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
	if(__NFUN_114__(LadderVolume, none))
	{
		return true;
	}
	bPaceMemberIsAtTopOfLadder = __NFUN_177__(aRainbow.Location.Z, LadderVolume.Location.Z);
	// End:0x74
	if(__NFUN_242__(bPaceMemberIsAtTopOfLadder, __NFUN_177__(m_pawn.Location.Z, LadderVolume.Location.Z)))
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
	if(__NFUN_119__(m_PaceMember, none))
	{
		// End:0x67
		if(__NFUN_132__(m_PaceMember.m_bIsProne, __NFUN_130__(__NFUN_119__(m_PaceMember.Controller, none), m_PaceMember.Controller.__NFUN_281__('SnipeUntilGoCode'))))
		{
			return float(__NFUN_144__(m_TeamManager.m_iFormationDistance, 2));
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
	if(__NFUN_176__(__NFUN_174__(m_fLastBump, 4.0000000), Level.TimeSeconds))
	{
		return true;
	}
	aBumpPawn = R6Pawn(m_BumpedBy);
	Focus = none;
	// End:0x71
	if(__NFUN_114__(m_TeamLeader, none))
	{
		return __NFUN_132__(__NFUN_177__(DistanceTo(m_BumpedBy), float(__NFUN_146__(c_iDistanceBumpBackUp, 60))), __NFUN_129__(IsMoving(aBumpPawn)));		
	}
	else
	{
		return __NFUN_132__(__NFUN_177__(DistanceTo(m_BumpedBy), float(__NFUN_146__(c_iDistanceBumpBackUp, 60))), __NFUN_130__(__NFUN_177__(DistanceTo(m_PaceMember), float(__NFUN_146__(c_iDistanceBumpBackUp, 60))), __NFUN_130__(IsMoving(m_PaceMember), __NFUN_129__(m_PaceMember.__NFUN_281__('BumpBackUp')))));
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
	__NFUN_113__('HoldPosition');
	return;
}

//------------------------------------------------------------------
// IsMoving()
//------------------------------------------------------------------
function bool IsMoving(Pawn P)
{
	// End:0x32
	if(__NFUN_132__(__NFUN_114__(P, none), __NFUN_217__(P.Velocity, vect(0.0000000, 0.0000000, 0.0000000))))
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
		__NFUN_267__(m_vNoiseFocalPoint);
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
	if(__NFUN_151__(m_pawn.m_iCurrentWeapon, 2))
	{
		return false;
	}
	// End:0x3E
	if(__NFUN_154__(int(m_TeamManager.m_eGoCode), int(4)))
	{
		fCutOff = 0.5000000;		
	}
	else
	{
		fCutOff = 0.7500000;
	}
	// End:0x92
	if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_114__(Pawn.EngineWeapon, none), m_bWeaponsDry), m_pawn.m_bChangingWeapon), m_pawn.m_bReloadingWeapon))
	{
		return false;
	}
	// End:0xEB
	if(__NFUN_154__(Pawn.EngineWeapon.NumberOfBulletsLeftInClip(), 0))
	{
		// End:0xE9
		if(__NFUN_130__(__NFUN_114__(Enemy, none), Pawn.EngineWeapon.IsPumpShotGun()))
		{
			m_pawn.m_bReloadToFullAmmo = true;
		}
		return true;
	}
	// End:0xF8
	if(__NFUN_119__(Enemy, none))
	{
		return false;
	}
	// End:0x1A3
	if(__NFUN_178__(float(Pawn.EngineWeapon.NumberOfBulletsLeftInClip()), __NFUN_171__(fCutOff, float(Pawn.EngineWeapon.GetClipCapacity()))))
	{
		// End:0x186
		if(__NFUN_130__(Pawn.EngineWeapon.IsPumpShotGun(), __NFUN_151__(Pawn.EngineWeapon.GetNbOfClips(), 0)))
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
	if(__NFUN_151__(Pawn.EngineWeapon.GetNbOfClips(), 0))
	{
		// End:0x54
		if(__NFUN_119__(Enemy, none))
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
		if(__NFUN_130__(__NFUN_154__(m_pawn.m_iCurrentWeapon, 1), Pawn.m_WeaponsCarried[1].HasAmmo()))
		{
			SwitchWeapon(2);			
		}
		else
		{
			// End:0x125
			if(__NFUN_130__(__NFUN_154__(m_pawn.m_iCurrentWeapon, 2), Pawn.m_WeaponsCarried[0].HasAmmo()))
			{
				SwitchWeapon(1);				
			}
			else
			{
				// End:0x17D
				if(__NFUN_129__(m_bWeaponsDry))
				{
					m_bWeaponsDry = true;
					// End:0x17D
					if(__NFUN_132__(m_TeamManager.m_bLeaderIsAPlayer, m_TeamManager.m_bPlayerHasFocus))
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
	if(__NFUN_130__(m_PaceMember.m_bIsProne, __NFUN_129__(m_PaceMember.m_bIsSniping)))
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
	if(__NFUN_155__(int(m_ePawnOrientation), int(5)))
	{
		__NFUN_2207__();		
	}
	else
	{
		// End:0x25
		if(m_bIsMovingBackwards)
		{
			__NFUN_2207__();			
		}
		else
		{
			__NFUN_2207__(0);
		}
	}
	return;
}

function ReorganizeTeamAsNeeded()
{
	// End:0x23
	if(__NFUN_155__(int(m_pawn.m_eHealth), int(1)))
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
	__NFUN_166__(m_pawn.m_iID);
	// End:0x83
	if(__NFUN_114__(m_TeamLeader, Pawn))
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
			__NFUN_113__('HoldPosition');			
		}
		else
		{
			__NFUN_113__('Patrol');
		}		
	}
	else
	{
		// End:0xC9
		if(__NFUN_130__(__NFUN_129__(m_pawn.m_bIsClimbingLadder), __NFUN_129__(__NFUN_281__('RoomEntry'))))
		{
			// End:0xC2
			if(m_TeamManager.m_bTeamIsHoldingPosition)
			{
				__NFUN_113__('HoldPosition');				
			}
			else
			{
				__NFUN_113__('FollowLeader');
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
	if(__NFUN_114__(Pawn, none))
	{
		return;
	}
	// End:0x31
	if(__NFUN_119__(Enemy, none))
	{
		SetGunDirection(Enemy);		
	}
	else
	{
		// End:0x59
		if(__NFUN_130__(m_bAimingWeaponAtEnemy, __NFUN_180__(m_pawn.m_fFiringTimer, float(0))))
		{
			SetGunDirection(none);
		}
	}
	// End:0xAD
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_TeamLeader, none), __NFUN_119__(m_TeamManager, none)), __NFUN_155__(m_pawn.m_iID, 0)))
	{
		m_PaceMember = m_TeamManager.m_Team[__NFUN_147__(m_pawn.m_iID, 1)];
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
		__NFUN_280__(0.0000000, false);
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

		vDir = __NFUN_226__(__NFUN_216__(Pawn.Location, m_vGrenadeLocation));
		vLocation = __NFUN_215__(m_vGrenadeLocation, __NFUN_213__(__NFUN_174__(m_fGrenadeDangerRadius, float(600)), vDir));
		vLocation.Z = Pawn.Location.Z;
		// End:0x6E
		if(__NFUN_521__(vLocation))
		{
			return vLocation;
		}
		vLocation = __NFUN_216__(m_vGrenadeLocation, __NFUN_213__(__NFUN_174__(m_fGrenadeDangerRadius, float(600)), vDir));
		vLocation.Z = Pawn.Location.Z;
		// End:0xBF
		if(__NFUN_521__(vLocation))
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
	if(__NFUN_218__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		goto 'RunToDirectly';
	}
FindPathAway:


	MoveTarget = __NFUN_2221__();
	// End:0x13A
	if(__NFUN_119__(MoveTarget, none))
	{
		// End:0xD2
		if(__NFUN_1509__(MoveTarget))
		{
			m_pawn.PlayDoorAnim(m_pawn.m_Door.m_RotatingDoor);
			__NFUN_256__(0.5000000);
			m_pawn.ServerPerformDoorAction(m_pawn.m_Door.m_RotatingDoor, int(m_pawn.m_Door.m_RotatingDoor.1));
		}
		R6PreMoveToward(MoveTarget, MoveTarget, 5);
		__NFUN_502__(MoveTarget);
		// End:0x104
		if(__NFUN_154__(int(m_eMoveToResult), int(2)))
		{
			__NFUN_256__(0.5000000);
		}
		// End:0x134
		if(__NFUN_177__(__NFUN_225__(__NFUN_216__(m_vGrenadeLocation, Pawn.Location)), __NFUN_174__(m_fGrenadeDangerRadius, float(300))))
		{
			goto 'Wait';
		}
		goto 'FindPathAway';
	}
	goto 'Wait';
RunToDirectly:


	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
	__NFUN_500__(m_vTargetPosition);
Wait:


	StopMoving();
	m_TeamManager.SetTeamState(2);
	__NFUN_256__(2.0000000);
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
		if(__NFUN_114__(thisPawn, none))
		{
			return false;
		}
		// End:0x57
		if(__NFUN_152__(thisPawn.m_iID, R6Pawn(m_BumpedBy).m_iID))
		{
			m_BumpedBy = thisPawn;
			__NFUN_113__('BumpBackUp');
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
		if(__NFUN_130__(bumpedBy.m_bIsClimbingLadder, __NFUN_177__(__NFUN_175__(bumpedBy.Location.Z, Pawn.Location.Z), float(100))))
		{
			return __NFUN_216__(Pawn.Location, __NFUN_213__(float(c_iDistanceBumpBackUp), bumpedBy.OnLadder.LookDir));
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
			return __NFUN_215__(Pawn.Location, __NFUN_213__(float(c_iDistanceBumpBackUp), Vector(__NFUN_316__(Rotator(m_vBumpedByVelocity), rOffset))));			
		}
		else
		{
			return __NFUN_215__(Pawn.Location, __NFUN_213__(float(c_iDistanceBumpBackUp), Vector(__NFUN_317__(Rotator(m_vBumpedByVelocity), rOffset))));
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
		HitActor = __NFUN_1806__(vHitLocation, vHitNormal, vTarget, Pawn.Location, 1, vExtent);
		// End:0xBC
		if(__NFUN_119__(HitActor, none))
		{
			vTarget = __NFUN_215__(vHitLocation, __NFUN_213__(float(c_iDistanceBumpBackUp), Vector(Rotator(m_vBumpedByVelocity))));
		}
		J0xBC:

		// End:0x118 [Loop If]
		if(__NFUN_130__(__NFUN_114__(__NFUN_1806__(vHitLocation, vHitNormal, __NFUN_216__(vTarget, vect(0.0000000, 0.0000000, 200.0000000)), vTarget, 1), none), __NFUN_150__(i, 6)))
		{
			__NFUN_165__(i);
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

	__NFUN_256__(1.0000000);
	// End:0x45
	if(__NFUN_176__(__NFUN_186__(__NFUN_175__(m_PaceMember.Location.Z, Pawn.Location.Z)), float(30)))
	{
		__NFUN_113__('FollowLeader');		
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
		if(__NFUN_130__(m_pawn.m_bWeaponIsSecured, __NFUN_129__(m_pawn.m_bWeaponTransition)))
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

	m_vTargetPosition = __NFUN_215__(m_pawn.m_Door.Location, __NFUN_213__(float(20), Vector(m_pawn.m_Door.Rotation)));
	__NFUN_267__(__NFUN_216__(m_RotatingDoor.Location, __NFUN_213__(float(128), Vector(m_RotatingDoor.Rotation))));
	__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, Pawn.Location)));
	Focus = self;
	__NFUN_508__();
	m_pawn.SetNextPendingAction(27);
	__NFUN_261__(m_pawn.14);
	m_pawn.SetNextPendingAction(19);
	m_pawn.m_bIsLockPicking = true;
	__NFUN_256__(0.1000000);
	m_RotatingDoor.PlayLockPickSound();
	// End:0x12D
	if(m_pawn.m_bHasLockPickKit)
	{
		__NFUN_256__(__NFUN_171__(__NFUN_175__(m_RotatingDoor.m_fUnlockBaseTime, 2.0000000), __NFUN_175__(2.0000000, m_pawn.ArmorSkillEffect())));		
	}
	else
	{
		__NFUN_256__(__NFUN_171__(m_RotatingDoor.m_fUnlockBaseTime, __NFUN_175__(2.0000000, m_pawn.ArmorSkillEffect())));
	}
	m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.13));
	m_pawn.m_bIsLockPicking = false;
	m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
	m_pawn.m_ePlayerIsUsingHands = 0;
	__NFUN_256__(1.0000000);
	m_pawn.SetNextPendingAction(28);
	__NFUN_261__(m_pawn.14);
End:


	__NFUN_113__(m_PostLockPickState);
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
		if(__NFUN_130__(__NFUN_119__(m_ActionTarget, none), m_ActionTarget.__NFUN_303__('R6Door')))
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
		if(__NFUN_154__(m_iStateProgress, 14))
		{
			m_iStateProgress = 0;
		}
		__NFUN_280__(0.0000000, false);
		m_pawn.m_u8DesiredYaw = 0;
		m_pawn.m_bThrowGrenadeWithLeftHand = false;
		m_pawn.m_bAvoidFacingWalls = true;
		m_bIgnoreBackupBump = false;
		m_bIndividualAttacks = true;
		return;
	}

	function Timer()
	{
		__NFUN_165__(m_iTurn);
		__NFUN_2219__(true);
		return;
	}

	function Vector FindFloorBelowActor(Actor Target)
	{
		local Vector vHitLocation, vHitNormal;

		__NFUN_277__(vHitLocation, vHitNormal, __NFUN_216__(Target.Location, vect(0.0000000, 0.0000000, 200.0000000)), Target.Location, false);
		__NFUN_184__(vHitLocation.Z, Pawn.CollisionHeight);
		return vHitLocation;
		return;
	}
Begin:

	StopMoving();
	m_pawn.ResetBoneRotation();
	__NFUN_256__(GetLeadershipReactionTime());
	// End:0x2F
	if(__NFUN_114__(m_ActionTarget, none))
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
	if(__NFUN_132__(__NFUN_1815__(m_ActionTarget.Location), __NFUN_520__(m_ActionTarget)))
	{
		goto 'MoveToActionTarget';
	}
	m_iStateProgress = 1;
FindActionTarget:


	// End:0x188
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_ActionTarget.Location)), __NFUN_129__(__NFUN_520__(m_ActionTarget))))
	{
		// End:0x16F
		if(__NFUN_130__(__NFUN_119__(m_RotatingDoor, none), m_RotatingDoor.m_bTreatDoorAsWindow))
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
	if(__NFUN_130__(__NFUN_129__(m_RotatingDoor.m_bIsDoorLocked), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0)))
	{
		SwitchWeapon(m_iActionUseGadgetGroup);
	}
	m_bIgnoreBackupBump = true;
	// End:0x329
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_RotatingDoor, none), __NFUN_154__(m_TeamManager.m_iTeamAction, 32)), m_RotatingDoor.DoorOpenTowardsActor(m_ActionTarget)), __NFUN_129__(PreEntryRoomIsAcceptablyLarge())))
	{
		// End:0x282
		if(m_RotatingDoor.m_bIsOpeningClockWise)
		{
			m_vTargetPosition = __NFUN_215__(__NFUN_216__(m_ActionTarget.Location, __NFUN_213__(float(85), Vector(m_ActionTarget.Rotation))), __NFUN_213__(float(85), Vector(__NFUN_316__(m_ActionTarget.Rotation, rot(0, 16384, 0)))));			
		}
		else
		{
			m_vTargetPosition = __NFUN_216__(__NFUN_216__(m_ActionTarget.Location, __NFUN_213__(float(85), Vector(m_ActionTarget.Rotation))), __NFUN_213__(float(85), Vector(__NFUN_316__(m_ActionTarget.Rotation, rot(0, 16384, 0)))));
		}
		R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.Location, 4);
		__NFUN_500__(m_vTargetPosition, m_RotatingDoor);
		__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_RotatingDoor.Location, Pawn.Location)));		
	}
	else
	{
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
		__NFUN_502__(m_ActionTarget);
		__NFUN_2201__(m_ActionTarget.Location, m_ActionTarget.Rotation);
	}
	StopMoving();
	__NFUN_256__(0.5000000);
UnlockDoor:


	// End:0x38D
	if(m_RotatingDoor.m_bIsDoorLocked)
	{
		GotoLockPickState(m_RotatingDoor);
	}
	m_TeamManager.SetTeamState(3);
	// End:0x3C4
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0))
	{
		SwitchWeapon(m_iActionUseGadgetGroup);		
	}
	else
	{
		EnsureRainbowIsArmed();
	}
	J0x3CA:

	// End:0x3E9 [Loop If]
	if(__NFUN_129__(m_TeamManager.LastMemberIsStationary()))
	{
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0x3CA;
	}
	m_bIgnoreBackupBump = false;
	m_iStateProgress = 3;
PreEntry:


	// End:0x455
	if(__NFUN_130__(__NFUN_114__(m_pawn.m_Door, m_ActionTarget), m_RotatingDoor.m_bTreatDoorAsWindow))
	{
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		m_iStateProgress = 4;
		goto 'WaitForZuluGoCode';
	}
	// End:0x492
	if(__NFUN_119__(m_RotatingDoor, none))
	{
		ForceCurrentDoor(R6Door(m_ActionTarget));
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	}
	// End:0x516
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = __NFUN_2205__(false);
		// End:0x516
		if(__NFUN_218__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			R6PreMoveTo(m_vTargetPosition, m_RotatingDoor.Location, 4);
			__NFUN_500__(m_vTargetPosition);
			__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_TeamManager.m_Door.m_CorrespondingDoor.Location, m_vTargetPosition)));
			StopMoving();
		}
	}
	m_iStateProgress = 4;
WaitForZuluGoCode:


	// End:0x54F
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		__NFUN_256__(0.5000000);
		goto 'WaitForZuluGoCode';
	}
	m_iStateProgress = 5;
performDoorAction:


	// End:0x7F4
	if(__NFUN_132__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 16), 0), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 32), 0)))
	{
		// End:0x7DE
		if(__NFUN_119__(m_RotatingDoor, none))
		{
			// End:0x5F1
			if(m_RotatingDoor.m_bIsDoorClosed)
			{
				Focus = m_RotatingDoor;
				// End:0x5DE
				if(__NFUN_114__(m_TeamManager.m_Door, none))
				{
					m_TeamManager.m_Door = R6Door(m_ActionTarget);
				}
				SetFocusToDoorKnob(m_RotatingDoor);
				__NFUN_256__(1.5000000);
			}
			J0x5F1:

			// End:0x610 [Loop If]
			if(__NFUN_129__(m_TeamManager.LastMemberIsStationary()))
			{
				__NFUN_256__(0.5000000);
				// [Loop Continue]
				goto J0x5F1;
			}
			// End:0x6FD
			if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 16), 0), m_RotatingDoor.m_bIsDoorClosed))
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
				__NFUN_256__(0.5000000);
				m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.1));
				J0x6B8:

				// End:0x6FA [Loop If]
				if(m_RotatingDoor.m_bIsDoorClosed)
				{
					// End:0x6EF
					if(__NFUN_129__(m_RotatingDoor.m_bInProcessOfOpening))
					{
						__NFUN_256__(1.0000000);
						goto 'performDoorAction';						
					}
					else
					{
						__NFUN_256__(0.2000000);
					}
					// [Loop Continue]
					goto J0x6B8;
				}				
			}
			else
			{
				// End:0x7C9
				if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 32), 0), __NFUN_129__(m_RotatingDoor.m_bIsDoorClosed)))
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
					__NFUN_256__(0.5000000);
					m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.5));
					J0x7A7:

					// End:0x7C6 [Loop If]
					if(__NFUN_155__(m_RotatingDoor.m_iCurrentOpening, 0))
					{
						__NFUN_256__(0.5000000);
						// [Loop Continue]
						goto J0x7A7;
					}					
				}
				else
				{
					// End:0x7DB
					if(__NFUN_150__(m_iStateProgress, 6))
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
	if(__NFUN_154__(m_iStateProgress, 8))
	{
		__NFUN_256__(1.0000000);
		m_iStateProgress = 9;
		goto 'PerformClearAction';
	}
	// End:0x98D
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0))
	{
		m_TeamManager.SetTeamState(14);
		__NFUN_118__('NotifyBump');
		m_vLocationOnTarget = __NFUN_215__(m_ActionTarget.Location, __NFUN_213__(float(450), Vector(m_ActionTarget.Rotation)));
		__NFUN_267__(m_vLocationOnTarget);
		// End:0x8EE
		if(__NFUN_129__(CanThrowGrenadeIntoRoom(R6Door(m_ActionTarget).m_CorrespondingDoor)))
		{
			m_TeamManager.ResetGrenadeAction();
			m_TeamManager.m_MemberVoicesMgr.PlayRainbowMemberVoices(m_pawn, 7);
			SwitchWeapon(1);
			__NFUN_256__(1.0000000);
			m_iStateProgress = 9;
			goto 'PerformClearAction';
		}
		Focus = self;
		Target = self;
		__NFUN_508__();
		__NFUN_299__(m_ActionTarget.Rotation);
		SetGunDirection(Target);
		SetGrenadeParameters(PreEntryRoomIsAcceptablyLarge());
		m_pawn.PlayWeaponAnimation();
		__NFUN_261__(m_pawn.14);
		m_pawn.m_eRepGrenadeThrow = 0;
		SetGunDirection(none);
		__NFUN_117__('NotifyBump');
		m_iStateProgress = 8;
		SwitchWeapon(1);
		__NFUN_256__(m_pawn.EngineWeapon.GetExplosionDelay());
	}
	m_iStateProgress = 9;
PerformClearAction:


	// End:0xBD2
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 128), 0))
	{
		m_TeamManager.SetTeamState(13);
		// End:0x9EB
		if(__NFUN_114__(m_TeamManager.m_Door, none))
		{
			m_TeamManager.m_Door = R6Door(m_ActionTarget);
		}
		m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
		// End:0xADB
		if(__NFUN_154__(m_iStateProgress, 9))
		{
			m_vTargetPosition = m_TeamManager.m_Door.Location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
			__NFUN_2201__(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
			m_TeamManager.EnteredRoom(m_pawn);
			m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 5);
			__NFUN_2201__(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
			StopMoving();
			m_iStateProgress = 10;
		}
		// End:0xB22
		if(__NFUN_154__(m_pawn.m_iID, __NFUN_147__(m_TeamManager.m_iMemberCount, 1)))
		{
			m_iStateProgress = 11;
			__NFUN_280__(1.0000000, true);
			__NFUN_2219__(true);
			__NFUN_256__(1.5000000);
			goto 'UpdateStatus';
		}
		// End:0xB40
		if(PostEntryRoomIsAcceptablyLarge())
		{
			m_vTargetPosition = __NFUN_2205__(true);
			__NFUN_267__(FocalPoint);			
		}
		else
		{
			__NFUN_2209__(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition);
			__NFUN_267__(__NFUN_215__(m_vTargetPosition, __NFUN_213__(float(60), __NFUN_216__(m_vTargetPosition, Pawn.Location))));
		}
		R6PreMoveTo(m_vTargetPosition, Location, 5);
		__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));
		StopMoving();
		__NFUN_280__(1.0000000, true);
		__NFUN_2219__(true);
		m_iStateProgress = 11;
		__NFUN_256__(3.0000000);		
	}
	else
	{
		m_iStateProgress = 11;
	}
	J0xBDA:

	// End:0xBFA
	if(m_TeamManager.RainbowIsEngaging())
	{
		__NFUN_256__(0.5000000);
		goto 'UpdateStatus';
	}
	// End:0xD0D
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 128), 0))
	{
		m_TeamManager.ActionCompleted(true);
		m_iStateProgress = 12;
		// End:0xD0A
		if(__NFUN_130__(__NFUN_119__(m_TeamManager.m_Door, none), __NFUN_154__(m_pawn.m_iID, __NFUN_147__(m_TeamManager.m_iMemberCount, 1))))
		{
			m_vTargetPosition = __NFUN_216__(m_TeamManager.m_Door.m_CorrespondingDoor.Location, __NFUN_213__(float(96), Vector(m_TeamManager.m_Door.m_CorrespondingDoor.Rotation)));
			__NFUN_267__(__NFUN_215__(m_TeamManager.m_Door.Location, __NFUN_213__(float(200), Vector(m_TeamManager.m_Door.Rotation))));
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
			__NFUN_500__(m_vTargetPosition, self);
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


	__NFUN_256__(1.0000000);
	// End:0xD5A
	if(__NFUN_255__(NextState, 'None'))
	{
		m_iStateProgress = 14;
		__NFUN_113__(NextState);
	}
	__NFUN_113__('HoldPosition');
	stop;		
}

state FindPathToTarget
{
	function EndState()
	{
		__NFUN_280__(0.0000000, false);
		return;
	}

	function Timer()
	{
		// End:0x34
		if(CanThrowGrenade(Pawn.Location, true, false))
		{
			__NFUN_280__(0.0000000, false);
			StopMoving();
			__NFUN_113__('TeamMoveTo', 'Action');
		}
		return;
	}
Begin:

	// End:0x21
	if(__NFUN_154__(m_TeamManager.m_iTeamAction, 320))
	{
		__NFUN_280__(0.3000000, true);
	}
	// End:0x3E
	if(__NFUN_119__(m_DesiredTarget, none))
	{
		MoveTarget = __NFUN_517__(m_DesiredTarget, true);		
	}
	else
	{
		MoveTarget = __NFUN_518__(m_vDesiredLocation, true);
	}
	// End:0x1D5
	if(__NFUN_119__(MoveTarget, none))
	{
		// End:0xFD
		if(__NFUN_1509__(MoveTarget))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
			__NFUN_2201__(m_pawn.m_Door.Location, m_pawn.m_Door.Rotation);
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			__NFUN_256__(1.0000000);
			GotoStateLeadRoomEntry();
		}
		m_TargetLadder = R6Ladder(MoveTarget);
		// End:0x182
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_pawn.m_Ladder, none), __NFUN_119__(m_TargetLadder, none)), __NFUN_119__(m_pawn.m_Ladder, m_TargetLadder)))
		{
			m_TeamManager.InstructTeamToClimbLadder(R6LadderVolume(m_pawn.m_Ladder.MyLadder), true, m_pawn.m_iID);
		}
		R6PreMoveToward(MoveTarget, MoveTarget, 4);
		__NFUN_502__(MoveTarget);
		// End:0x1BB
		if(__NFUN_119__(m_DesiredTarget, none))
		{
			// End:0x1B8
			if(__NFUN_520__(m_DesiredTarget))
			{
				goto 'End';
			}			
		}
		else
		{
			// End:0x1CC
			if(__NFUN_521__(m_vDesiredLocation))
			{
				goto 'End';
			}
		}
		goto 'Begin';		
	}
	else
	{
		// End:0x203
		if(__NFUN_155__(m_TeamManager.m_iTeamAction, 0))
		{
			// End:0x203
			if(__NFUN_129__(m_TeamManager.m_bGrenadeInProximity))
			{
				RainbowCannotCompleteOrders();
			}
		}
	}
	J0x203:

	R6PreMoveTo(m_vDesiredLocation, m_vDesiredLocation, 4);
	__NFUN_500__(m_vDesiredLocation);
	__NFUN_113__(m_PostFindPathToState);
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
		if(__NFUN_154__(m_iStateProgress, 5))
		{
			m_iStateProgress = 0;
		}
		m_bIndividualAttacks = true;
		__NFUN_280__(0.0000000, false);
		m_pawn.m_u8DesiredYaw = 0;
		return;
	}

	function Timer()
	{
		__NFUN_165__(m_iTurn);
		__NFUN_2219__(false);
		return;
	}

	function bool HasEnteredRoom(R6Pawn member)
	{
		// End:0x65
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(member.Location, m_TeamManager.m_Door.Location)), __NFUN_225__(__NFUN_216__(member.Location, m_TeamManager.m_Door.m_CorrespondingDoor.Location))))
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
			if(__NFUN_154__(m_pawn.m_iID, 3))
			{
				// End:0x68
				if(m_TeamManager.m_bTeamIsSeparatedFromLeader)
				{
					__NFUN_267__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(300), Vector(m_TeamManager.m_Door.Rotation))));					
				}
				else
				{
					__NFUN_267__(__NFUN_216__(m_TeamManager.m_Door.Location, __NFUN_213__(float(300), Vector(m_TeamManager.m_Door.Rotation))));
				}
				Focus = self;				
			}
			else
			{
				// End:0x175
				if(__NFUN_130__(__NFUN_154__(m_pawn.m_iID, 2), __NFUN_132__(__NFUN_129__(m_TeamLeader.m_bIsPlayer), __NFUN_130__(m_TeamLeader.m_bIsPlayer, __NFUN_129__(m_TeamManager.m_bTeamIsSeparatedFromLeader)))))
				{
					__NFUN_267__(__NFUN_216__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(300), __NFUN_226__(__NFUN_216__(m_TeamManager.m_Door.Location, Pawn.Location)))), __NFUN_213__(float(200), Vector(m_TeamManager.m_Door.Rotation))));
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
			if(__NFUN_154__(m_pawn.m_iID, __NFUN_147__(m_TeamManager.m_iMemberCount, 1)))
			{
				__NFUN_267__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(200), __NFUN_226__(__NFUN_216__(m_TeamManager.m_Door.Location, Pawn.Location)))));
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

		vDir = __NFUN_216__(m_PaceMember.Location, Pawn.Location);
		return __NFUN_216__(m_PaceMember.Location, __NFUN_213__(GetFormationDistance(), __NFUN_226__(vDir)));
		return;
	}

	function CoverRear()
	{
		// End:0x43
		if(__NFUN_154__(m_TeamManager.m_iTeamAction, 0))
		{
			__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_216__(Pawn.Location, FocalPoint)));
			Focus = self;
		}
		return;
	}

	function float DistanceToLocation(Vector vTarget)
	{
		return __NFUN_225__(__NFUN_216__(Pawn.Location, vTarget));
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
			bCrouchedEntry = __NFUN_154__(int(m_TeamManager.m_eMovementSpeed), int(2));
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
	if(__NFUN_114__(m_TeamManager.m_Door.m_RotatingDoor, none))
	{
		__NFUN_113__('FollowLeader');
	}
	// End:0x8E
	if(__NFUN_114__(m_TeamManager.m_Door.m_CorrespondingDoor, none))
	{
		__NFUN_113__('FollowLeader');
	}
	// End:0x283
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = __NFUN_2205__(false);
		// End:0x283
		if(__NFUN_218__(m_vTargetPosition, Pawn.Location))
		{
			// End:0xE3
			if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_vTargetPosition)), __NFUN_129__(__NFUN_521__(m_vTargetPosition))))
			{
				FindPathToTargetLocation(m_vTargetPosition);				
			}
			else
			{
				// End:0x1BB
				if(__NFUN_130__(__NFUN_218__(m_vPreEntryPositions[0], vect(0.0000000, 0.0000000, 0.0000000)), __NFUN_176__(DistanceToLocation(m_vPreEntryPositions[0]), DistanceToLocation(m_vTargetPosition))))
				{
					// End:0x170
					if(__NFUN_132__(__NFUN_217__(m_vPreEntryPositions[1], vect(0.0000000, 0.0000000, 0.0000000)), __NFUN_176__(DistanceToLocation(m_vPreEntryPositions[0]), DistanceToLocation(m_vPreEntryPositions[1]))))
					{
						R6PreMoveTo(m_vPreEntryPositions[0], m_vPreEntryPositions[0], GetRoomEntryPace(false));
					}
					__NFUN_500__(m_vPreEntryPositions[0]);
					// End:0x1B8
					if(__NFUN_218__(m_vPreEntryPositions[1], vect(0.0000000, 0.0000000, 0.0000000)))
					{
						R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
						__NFUN_500__(m_vPreEntryPositions[1]);
					}					
				}
				else
				{
					// End:0x218
					if(__NFUN_130__(__NFUN_218__(m_vPreEntryPositions[1], vect(0.0000000, 0.0000000, 0.0000000)), __NFUN_176__(DistanceToLocation(m_vPreEntryPositions[1]), DistanceToLocation(m_vTargetPosition))))
					{
						R6PreMoveTo(m_vPreEntryPositions[1], m_vPreEntryPositions[1], GetRoomEntryPace(false));
						__NFUN_500__(m_vPreEntryPositions[1]);
					}
				}
				R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.Location, GetRoomEntryPace(false));
				__NFUN_500__(m_vTargetPosition);
				__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_TeamManager.m_Door.m_CorrespondingDoor.Location, m_vTargetPosition)));
			}
		}
	}
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	m_iStateProgress = 1;
WaitForGo:


	SetMemberFocus();
	StopMoving();
	// End:0x3CE
	if(__NFUN_132__(__NFUN_130__(m_TeamLeader.m_bIsPlayer, __NFUN_129__(HasEnteredRoom(m_PaceMember))), __NFUN_130__(__NFUN_129__(m_TeamLeader.m_bIsPlayer), __NFUN_129__(R6RainbowAI(m_PaceMember.Controller).m_bEnteredRoom))))
	{
		// End:0x387
		if(__NFUN_130__(__NFUN_129__(PreEntryRoomIsAcceptablyLarge()), __NFUN_177__(DistanceTo(m_PaceMember), GetFormationDistance())))
		{
			m_vTargetPosition = GetSingleFilePosition();
			// End:0x365
			if(__NFUN_129__(__NFUN_521__(m_vTargetPosition)))
			{
				FindPathToTargetLocation(m_PaceMember.Location, m_PaceMember);
			}
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(false));
			__NFUN_500__(m_vTargetPosition);			
		}
		else
		{
			// End:0x3C0
			if(__NFUN_130__(__NFUN_154__(m_pawn.m_iID, 2), HasEnteredRoom(m_TeamLeader)))
			{
				Focus = m_TeamManager.m_Door;
			}
			__NFUN_256__(0.5000000);
		}
		goto 'WaitForGo';
	}
	m_iStateProgress = 2;
PassDoor:


	__NFUN_256__(0.2000000);
	// End:0x3FF
	if(__NFUN_129__(PostEntryRoomIsAcceptablyLarge()))
	{
		m_TeamManager.EndRoomEntry();
		__NFUN_113__('FollowLeader');
	}
	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
	m_vTargetPosition = m_TeamManager.m_Door.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_vTargetPosition, Pawn.Location)));
	m_TeamManager.EnteredRoom(m_pawn);
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_vTargetPosition, Pawn.Location)));
	m_iStateProgress = 3;
	// End:0x508
	if(m_PaceMember.m_bIsPlayer)
	{
		m_TeamManager.GetPlayerDirection();
	}
EnterRoom:


	m_vTargetPosition = __NFUN_2205__(true);
	__NFUN_267__(FocalPoint);
	R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
	__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));
	__NFUN_280__(1.0000000, true);
	__NFUN_2219__(false);
	m_iStateProgress = 4;
	__NFUN_256__(0.5000000);
WaitOnLeader:


	StopMoving();
	__NFUN_256__(0.5000000);
	// End:0x588
	if(__NFUN_154__(int(m_eCoverDirection), int(3)))
	{
		CoverRear();
	}
	// End:0x5ED
	if(__NFUN_132__(__NFUN_130__(IsMoving(m_PaceMember), __NFUN_177__(DistanceTo(m_PaceMember), float(200))), __NFUN_177__(DistanceTo(m_PaceMember), float(300))))
	{
		// End:0x5DB
		if(__NFUN_154__(int(m_eCoverDirection), int(3)))
		{
			CoverRear();
		}
		m_iStateProgress = 5;
		__NFUN_113__('FollowLeader');		
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
		__NFUN_280__(0.0000000, false);
		return;
	}

	function Timer()
	{
		__NFUN_165__(m_iWaitCounter);
		return;
	}
Begin:

	m_TeamManager.SetTeamState(2);
	Focus = none;
	m_iWaitCounter = 0;
	Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	__NFUN_280__(1.0000000, true);
	__NFUN_256__(1.0000000);
Hold:


	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0xAE
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(Pawn.bIsCrouched), __NFUN_129__(Pawn.m_bIsProne)), __NFUN_177__(float(m_iWaitCounter), 8.0000000)))
	{
		Pawn.bWantsToCrouch = true;
		__NFUN_256__(0.5000000);
	}
	// End:0xBD
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	__NFUN_256__(1.0000000);
	// End:0xDB
	if(__NFUN_255__(NextState, 'None'))
	{
		__NFUN_113__(NextState);
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
		if(__NFUN_129__(m_bStateFlag))
		{
			m_pawn.m_bPostureTransition = false;
			m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
			m_pawn.m_ePlayerIsUsingHands = 0;
			m_pawn.PlayWeaponAnimation();
			R6Terrorist(m_ActionTarget).ResetArrest();
		}
		// End:0xB4
		if(__NFUN_130__(m_pawn.m_bWeaponIsSecured, __NFUN_129__(m_pawn.m_bWeaponTransition)))
		{
			m_pawn.SetNextPendingAction(28);
		}
		return;
	}
Begin:

	// End:0x1F
	if(__NFUN_129__(R6Pawn(m_ActionTarget).IsAlive()))
	{
		goto 'End';
	}
	// End:0x3C
	if(__NFUN_154__(m_pawn.m_iID, 1))
	{
		__NFUN_256__(GetLeadershipReactionTime());
	}
	m_TeamManager.SetTeamState(3);
	// End:0x8B
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_ActionTarget.Location)), __NFUN_129__(__NFUN_520__(m_ActionTarget))))
	{
		FindPathToTargetLocation(m_ActionTarget.Location, m_ActionTarget);
	}
DirectMove:


	R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
	__NFUN_502__(m_ActionTarget);
	// End:0xBF
	if(__NFUN_177__(DistanceTo(m_ActionTarget), float(100)))
	{
		goto 'Begin';
	}
	Focus = m_ActionTarget;
	StopMoving();
	__NFUN_256__(0.5000000);
	J0xD8:

	// End:0x106 [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0xD8;
	}
Secure:


	__NFUN_118__('SeePlayer');
	// End:0x12A
	if(R6Terrorist(m_ActionTarget).m_bIsUnderArrest)
	{
		RainbowCannotCompleteOrders();
	}
	m_TeamManager.SetTeamState(17);
	m_pawn.SetNextPendingAction(27);
	__NFUN_261__(m_pawn.14);
	R6Terrorist(m_ActionTarget).m_controller.DispatchOrder(int(R6Terrorist(m_ActionTarget).1), m_pawn);
	J0x18E:

	// End:0x1B2 [Loop If]
	if(__NFUN_129__(R6Terrorist(m_ActionTarget).PawnHaveFinishedRotation()))
	{
		__NFUN_256__(0.1000000);
		// [Loop Continue]
		goto J0x18E;
	}
	m_pawn.SetNextPendingAction(29);
	__NFUN_261__(m_pawn.1);
	m_bStateFlag = true;
	m_pawn.SetNextPendingAction(28);
	__NFUN_261__(m_pawn.14);
End:


	// End:0x225
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		m_TeamManager.m_SurrenderedTerrorist = none;
		__NFUN_113__('Patrol');		
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
		__NFUN_280__(0.0000000, false);
		m_vTargetPosition = m_TeamManager.m_vActionLocation;
		// End:0xD6
		if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0), __NFUN_154__(m_iStateProgress, 0)))
		{
			m_iStateProgress = 1;
			// End:0xC2
			if(__NFUN_129__(CanThrowGrenade(Pawn.Location, false, true)))
			{
				// End:0x91
				if(__NFUN_130__(TooCloseToThrowGrenade(Pawn.Location), FindRandomNavPointToThrowGrenade()))
				{
					m_iStateProgress = 2;					
				}
				else
				{
					m_vTargetPosition = m_vLocationOnTarget;
					__NFUN_184__(m_vTargetPosition.Z, Pawn.CollisionHeight);
					__NFUN_280__(0.3000000, true);
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
		__NFUN_280__(0.0000000, false);
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
		if(__NFUN_150__(i, 10))
		{
			Actor = __NFUN_525__(true);
			// End:0xCE
			if(__NFUN_130__(__NFUN_129__(Actor.__NFUN_303__('R6Ladder')), __NFUN_176__(__NFUN_186__(__NFUN_175__(Actor.Location.Z, Pawn.Location.Z)), float(400))))
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
					__NFUN_165__(iLocationListIndex);
				}
			}
			J0xCE:

			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x00;
		}
		// End:0x181
		if(__NFUN_151__(iLocationListIndex, 0))
		{
			i = 0;
			i = 0;
			J0xF1:

			// End:0x17F [Loop If]
			if(__NFUN_150__(i, iLocationListIndex))
			{
				// End:0x175
				if(__NFUN_177__(__NFUN_225__(__NFUN_216__(vLocationList[i], Pawn.Location)), float(iDistance)))
				{
					// End:0x175
					if(CanThrowGrenade(vLocationList[i], false, false))
					{
						iDistance = int(__NFUN_225__(__NFUN_216__(vLocationList[i], Pawn.Location)));
						m_vTargetPosition = vLocationList[i];
					}
				}
				__NFUN_163__(i);
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
		if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0))
		{
			// End:0x4C
			if(CanThrowGrenade(Pawn.Location, true, false))
			{
				__NFUN_280__(0.0000000, false);
				StopMoving();
				__NFUN_113__('TeamMoveTo', 'Action');
			}
		}
		return;
	}
Begin:

	// End:0x37
	if(__NFUN_130__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0), __NFUN_217__(m_vLocationOnTarget, vect(0.0000000, 0.0000000, 0.0000000))))
	{
		goto 'End';
	}
	StopMoving();
	J0x3D:

	// End:0x6B [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0x3D;
	}
	SetUpTeamMoveTo();
	__NFUN_256__(GetLeadershipReactionTime());
MoveTowardTarget:


	m_TeamManager.SetTeamState(3);
	// End:0xCF
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 2048), 0))
	{
		// End:0xCC
		if(__NFUN_129__(__NFUN_520__(m_ActionTarget)))
		{
			FindPathToTargetLocation(m_ActionTarget.Location, m_ActionTarget);
		}		
	}
	else
	{
		// End:0xE7
		if(__NFUN_129__(__NFUN_521__(m_vTargetPosition)))
		{
			FindPathToTargetLocation(m_vTargetPosition);
		}
	}
	J0xE7:

	// End:0x136
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 2048), 0))
	{
		J0x102:

		// End:0x133 [Loop If]
		if(__NFUN_177__(DistanceTo(m_ActionTarget), float(100)))
		{
			R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
			__NFUN_502__(m_ActionTarget);
			// [Loop Continue]
			goto J0x102;
		}		
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		__NFUN_500__(m_vTargetPosition);
		// End:0x18C
		if(__NFUN_130__(__NFUN_155__(m_TeamManager.m_iTeamAction, 0), __NFUN_154__(int(m_eMoveToResult), int(2))))
		{
			m_TeamManager.MoveTeamToCompleted(false);
			RainbowCannotCompleteOrders();
		}
	}
	J0x18C:

	// End:0x378
	if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 64), 0))
	{
		m_TeamManager.SetTeamState(14);
		// End:0x331
		if(CanThrowGrenade(Pawn.Location, false, false))
		{
			// End:0x22E
			if(__NFUN_129__(ClearThrowIsAvailable(m_vLocationOnTarget)))
			{
				m_vTargetPosition = __NFUN_215__(Pawn.Location, __NFUN_213__(float(300), __NFUN_226__(__NFUN_216__(m_vLocationOnTarget, Pawn.Location))));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				__NFUN_500__(m_vTargetPosition);
			}
			__NFUN_280__(0.0000000, false);
			__NFUN_118__('NotifyBump');
			StopMoving();
			__NFUN_256__(0.2000000);
			__NFUN_267__(m_vLocationOnTarget);
			Focus = self;
			Target = self;
			SwitchWeapon(m_iActionUseGadgetGroup);
			__NFUN_261__(m_pawn.14);
			__NFUN_299__(Pawn.Rotation);
			SetGunDirection(Target);
			m_pawn.m_bThrowGrenadeWithLeftHand = false;
			m_pawn.m_eGrenadeThrow = 1;
			m_pawn.m_eRepGrenadeThrow = 1;
			m_pawn.PlayWeaponAnimation();
			__NFUN_261__(m_pawn.14);
			m_pawn.m_eRepGrenadeThrow = 0;
			m_vLocationOnTarget = vect(0.0000000, 0.0000000, 0.0000000);
			m_iStateProgress = 0;
			__NFUN_117__('NotifyBump');
			SwitchWeapon(1);
			__NFUN_261__(m_pawn.14);			
		}
		else
		{
			__NFUN_280__(0.3000000, true);
			m_vTargetPosition = m_vLocationOnTarget;
			__NFUN_184__(m_vTargetPosition.Z, Pawn.CollisionHeight);
			__NFUN_256__(0.2000000);
			goto 'Begin';
		}
		__NFUN_256__(1.0000000);		
	}
	else
	{
		// End:0x60E
		if(__NFUN_132__(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 4096), 0), __NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 8192), 0)))
		{
			// End:0x605
			if(__NFUN_154__(int(m_eMoveToResult), int(1)))
			{
				// End:0x40E
				if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 4096), 0))
				{
					// End:0x3FA
					if(__NFUN_129__(R6IOObject(m_ActionTarget).m_bIsActivated))
					{
						RainbowCannotCompleteOrders();
					}
					m_TeamManager.SetTeamState(15);					
				}
				else
				{
					m_TeamManager.SetTeamState(16);
				}
				m_vTargetPosition = __NFUN_216__(m_ActionTarget.Location, __NFUN_213__(__NFUN_174__(__NFUN_174__(Pawn.CollisionRadius, m_ActionTarget.CollisionRadius), float(10)), Vector(m_ActionTarget.Rotation)));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_ActionTarget.Location, m_vTargetPosition)));
				Focus = m_ActionTarget;
				__NFUN_508__();
				m_pawn.SetNextPendingAction(27);
				__NFUN_261__(m_pawn.14);
				m_pawn.m_eDeviceAnim = R6IOObject(m_ActionTarget).m_eAnimToPlay;
				m_pawn.SetNextPendingAction(18);
				R6IOObject(m_ActionTarget).PerformSoundAction(0);
				m_pawn.m_bInteractingWithDevice = true;
				__NFUN_256__(R6IOObject(m_ActionTarget).GetTimeRequired(m_pawn));
				R6IOObject(m_ActionTarget).ToggleDevice(m_pawn);
				R6IOObject(m_ActionTarget).PerformSoundAction(2);
				PlaySoundActionCompleted(R6IOObject(m_ActionTarget).m_eAnimToPlay);
				m_pawn.AnimBlendToAlpha(m_pawn.1, 0.0000000, 0.5000000);
				m_pawn.m_bInteractingWithDevice = false;
				m_pawn.m_ePlayerIsUsingHands = 0;
				m_pawn.PlayWeaponAnimation();
				__NFUN_256__(1.0000000);
				m_pawn.SetNextPendingAction(28);
				__NFUN_261__(m_pawn.14);				
			}
			else
			{
				RainbowCannotCompleteOrders();
			}			
		}
		else
		{
			// End:0x6A8
			if(__NFUN_151__(__NFUN_156__(m_TeamManager.m_iTeamAction, 2048), 0))
			{
				// End:0x674
				if(__NFUN_119__(R6Hostage(m_ActionTarget).m_escortedByRainbow, none))
				{
					R6Hostage(m_ActionTarget).m_controller.DispatchOrder(int(R6Hostage(m_ActionTarget).2));					
				}
				else
				{
					R6Hostage(m_ActionTarget).m_controller.DispatchOrder(int(R6Hostage(m_ActionTarget).1), m_pawn);
				}
			}
			__NFUN_256__(1.0000000);
		}
	}
	// End:0x6D4
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		m_TeamManager.ActionCompleted(true);
	}
	m_TeamManager.RestoreTeamOrder();
End:


	// End:0x701
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		__NFUN_113__('Patrol');		
	}
	else
	{
		m_TeamManager.MoveTeamToCompleted(true);
		NextState = 'None';
		__NFUN_113__('HoldPosition');
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
	if(__NFUN_154__(m_TeamManager.m_iMemberCount, 1))
	{
		goto 'Wait';
	}
	// End:0x1B3
	if(__NFUN_119__(m_TeamManager.m_PlanActionPoint, none))
	{
		m_vTargetPosition = m_pawn.m_Ladder.Location;
		// End:0x7B
		if(__NFUN_114__(m_TeamManager.m_PlanActionPoint, m_pawn.m_Ladder))
		{
			m_TeamManager.ActionPointReached();
		}
		J0x7B:

		// End:0x1B0 [Loop If]
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_vTargetPosition, Pawn.Location)), float(300)))
		{
			// End:0xB5
			if(__NFUN_114__(m_TeamManager.m_PlanActionPoint, none))
			{
				// [Explicit Break]
				goto J0x1B0;
			}
			// End:0x10B
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed), NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint)))
			{
				// [Explicit Break]
				goto J0x1B0;
			}
			// End:0x165
			if(__NFUN_132__(__NFUN_132__(__NFUN_114__(m_TeamManager.m_PlanActionPoint, m_pawn.m_Ladder), __NFUN_129__(__NFUN_520__(m_TeamManager.m_PlanActionPoint))), __NFUN_155__(int(m_TeamManager.m_eNextAPAction), int(0))))
			{
				goto 'FindNearbySpot';
			}
			R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
			__NFUN_502__(m_TeamManager.m_PlanActionPoint);
			m_TeamManager.ActionPointReached();
			// [Loop Continue]
			goto J0x7B;
		}
		J0x1B0:
		
	}
	else
	{
FindNearbySpot:


		__NFUN_2209__(m_pawn.m_Ladder, m_vTargetPosition);
		// End:0x1FE
		if(__NFUN_218__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetTeamPace());
			__NFUN_500__(m_vTargetPosition);
		}
	}
	J0x1FE:

	__NFUN_256__(1.0000000);
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
			__NFUN_113__('Patrol');
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
		__NFUN_280__(0.0000000, false);
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

		PathA = __NFUN_226__(__NFUN_216__(MoveTarget.Location, Pawn.Location));
		PathB = __NFUN_226__(__NFUN_216__(m_NextMoveTarget.Location, MoveTarget.Location));
		// End:0x64
		if(__NFUN_176__(__NFUN_219__(PathA, PathB), 0.7070000))
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
		if(__NFUN_119__(actionTarget, none))
		{
			// End:0x86
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(MoveTarget, none), __NFUN_176__(__NFUN_225__(__NFUN_216__(MoveTarget.Location, actionTarget.Location)), __NFUN_225__(__NFUN_216__(Pawn.Location, actionTarget.Location)))), __NFUN_2220__(actionTarget, MoveTarget.Location)))
			{
				return;
			}
			// End:0xB6
			if(actionTarget.__NFUN_303__('R6IOBomb'))
			{
				m_TeamManager.ReorganizeTeamToInteractWithDevice(4096, actionTarget);				
			}
			else
			{
				// End:0xE6
				if(actionTarget.__NFUN_303__('R6IODevice'))
				{
					m_TeamManager.ReorganizeTeamToInteractWithDevice(8192, actionTarget);					
				}
				else
				{
					// End:0x10F
					if(actionTarget.__NFUN_303__('R6Terrorist'))
					{
						m_ActionTarget = actionTarget;
						__NFUN_113__('TeamSecureTerrorist');						
					}
					else
					{
						// End:0x1CC
						if(actionTarget.__NFUN_303__('R6Hostage'))
						{
							// End:0x1BC
							if(__NFUN_130__(R6Hostage(actionTarget).IsAlive(), __NFUN_129__(R6Hostage(actionTarget).m_bCivilian)))
							{
								// End:0x188
								if(__NFUN_129__(m_TeamManager.m_bLeaderIsAPlayer))
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
		__NFUN_165__(m_iWaitCounter);
		// End:0x90
		if(__NFUN_130__(__NFUN_130__(__NFUN_119__(MoveTarget, none), __NFUN_119__(m_NextMoveTarget, none)), __NFUN_129__(ActionIsGrenade(m_TeamManager.m_ePlanAction))))
		{
			// End:0x90
			if(__NFUN_130__(__NFUN_114__(Enemy, none), __NFUN_176__(DistanceTo(MoveTarget), float(200))))
			{
				// End:0x90
				if(__NFUN_130__(CornerMovement(), __NFUN_119__(m_NextMoveTarget, none)))
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
			__NFUN_113__('HoldPosition');
			return;
		}
		// End:0xEC
		if(__NFUN_180__(__NFUN_173__(float(m_iWaitCounter), float(10)), float(0)))
		{
			DispatchInteractions();
		}
		return;
	}

	function bool ConfirmActionPointReached()
	{
		// End:0x2B
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(MoveTarget.Location, Pawn.Location)), float(100)))
		{
			return true;
		}
		return false;
		return;
	}

	function bool IsCloseEnoughToInteractWith(Actor actionTarget)
	{
		// End:0x0D
		if(__NFUN_114__(actionTarget, none))
		{
			return false;
		}
		// End:0x5B
		if(__NFUN_130__(__NFUN_176__(DistanceTo(actionTarget), float(500)), __NFUN_176__(__NFUN_186__(__NFUN_175__(Pawn.Location.Z, actionTarget.Location.Z)), float(100))))
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
		if(__NFUN_150__(i, m_TeamManager.m_InteractiveObjectList.Length))
		{
			aIntActor = m_TeamManager.m_InteractiveObjectList[i];
			// End:0x72
			if(__NFUN_119__(aIntActor, none))
			{
				// End:0x72
				if(__NFUN_130__(R6IOObject(aIntActor).m_bIsActivated, IsCloseEnoughToInteractWith(aIntActor)))
				{
					return aIntActor;
				}
			}
			__NFUN_165__(i);
			// [Loop Continue]
			goto J0x07;
		}
		// End:0xB6
		if(__NFUN_119__(m_TeamManager.m_HostageToRescue, none))
		{
			// End:0xB6
			if(IsCloseEnoughToInteractWith(m_TeamManager.m_HostageToRescue))
			{
				return m_TeamManager.m_HostageToRescue;
			}
		}
		// End:0x10D
		if(__NFUN_119__(m_TeamManager.m_SurrenderedTerrorist, none))
		{
			terro = R6Terrorist(m_TeamManager.m_SurrenderedTerrorist);
			// End:0x10D
			if(__NFUN_130__(IsCloseEnoughToInteractWith(terro), __NFUN_129__(terro.m_bIsUnderArrest)))
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
		if(__NFUN_132__(__NFUN_132__(__NFUN_132__(__NFUN_154__(int(eAPAction), int(1)), __NFUN_154__(int(eAPAction), int(2))), __NFUN_154__(int(eAPAction), int(3))), __NFUN_154__(int(eAPAction), int(4))))
		{
			return true;
		}
		return false;
		return;
	}

	function Actor GetFocus()
	{
		// End:0x11
		if(__NFUN_114__(Enemy, none))
		{
			return MoveTarget;
		}
		return Enemy;
		return;
	}
Begin:

	__NFUN_280__(0.1000000, true);
	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x42
	if(__NFUN_130__(__NFUN_119__(MoveTarget, none), ConfirmActionPointReached()))
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
		__NFUN_256__(1.0000000);
	}
	// End:0xD3
	if(__NFUN_130__(__NFUN_129__(m_pawn.IsStationary()), SniperChangeToSecondaryWeapon()))
	{
		__NFUN_256__(0.5000000);
	}
PickActionPoint:


	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0x130
	if(__NFUN_151__(m_TeamManager.m_iMemberCount, 1))
	{
		J0xF3:

		// End:0x130 [Loop If]
		if(__NFUN_177__(DistanceTo(m_TeamManager.m_Team[__NFUN_147__(m_TeamManager.m_iMemberCount, 1)]), float(800)))
		{
			__NFUN_256__(0.5000000);
			// [Loop Continue]
			goto J0xF3;
		}
	}
	MoveTarget = m_TeamManager.m_PlanActionPoint;
	// End:0x1A4
	if(__NFUN_132__(__NFUN_119__(MoveTarget, none), __NFUN_155__(int(m_TeamManager.m_ePlanAction), int(0))))
	{
		DispatchInteractions();
		m_iWaitCounter = 0;
		// End:0x1A1
		if(__NFUN_155__(int(m_TeamManager.m_ePlanAction), int(5)))
		{
			// End:0x1A1
			if(SniperChangeToSecondaryWeapon())
			{
				__NFUN_256__(0.5000000);
			}
		}		
	}
	else
	{
		// End:0x1FE
		if(__NFUN_151__(m_iWaitCounter, 30))
		{
			SniperChangeToPrimaryWeapon();
			// End:0x1FE
			if(__NFUN_130__(__NFUN_129__(Pawn.bIsCrouched), __NFUN_154__(int(m_TeamManager.m_eGoCode), int(4))))
			{
				Pawn.bWantsToCrouch = true;
				__NFUN_256__(0.5000000);
			}
		}
	}
	// End:0x255
	if(NeedToReload())
	{
		// End:0x22C
		if(__NFUN_129__(Pawn.bIsCrouched))
		{
			Pawn.bWantsToCrouch = true;
		}
		RainbowReloadWeapon();
		StopMoving();
		J0x238:

		// End:0x255 [Loop If]
		if(m_pawn.m_bReloadingWeapon)
		{
			__NFUN_256__(0.2000000);
			// [Loop Continue]
			goto J0x238;
		}
	}
	// End:0x296
	if(__NFUN_114__(MoveTarget, none))
	{
		// End:0x288
		if(__NFUN_154__(int(m_TeamManager.m_ePlanAction), int(5)))
		{
			m_TeamManager.SnipeUntilGoCode();
		}
		__NFUN_256__(0.1000000);
		goto 'FormationAroundDoor';
	}
	// End:0x2C7
	if(__NFUN_154__(int(m_TeamManager.m_eNextAPAction), int(0)))
	{
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();		
	}
	else
	{
		m_NextMoveTarget = none;
		// End:0x2F9
		if(__NFUN_154__(int(m_TeamManager.m_eNextAPAction), int(6)))
		{
			m_TeamManager.ReOrganizeTeamForBreachDoor();			
		}
		else
		{
			// End:0x324
			if(__NFUN_154__(int(m_TeamManager.m_eNextAPAction), int(5)))
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
	if(__NFUN_114__(MoveTarget, m_pawn.m_Door))
	{
		m_TeamManager.ActionPointReached();
		goto 'DoorsAndLadders';
	}
	m_TeamManager.SetTeamState(3);
	// End:0x3FA
	if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed), NextActionPointIsThroughDoor(MoveTarget)))
	{
		goto 'DoorsAndLadders';
	}
	// End:0x413
	if(TargetIsLadderToClimb(R6Ladder(MoveTarget)))
	{
		goto 'DoorsAndLadders';
	}
	// End:0x43E
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(MoveTarget.Location)), __NFUN_129__(__NFUN_520__(MoveTarget))))
	{
		goto 'BlockedFindPath';
	}
	R6PreMoveToward(MoveTarget, GetFocus(), GetTeamPace());
	__NFUN_502__(MoveTarget, GetFocus());
	// End:0x4A8
	if(ConfirmActionPointReached())
	{
		// End:0x490
		if(MoveTarget.__NFUN_303__('R6Door'))
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

	MoveTarget = __NFUN_517__(m_TeamManager.m_PlanActionPoint, true);
	// End:0x52E
	if(__NFUN_119__(MoveTarget, none))
	{
		R6PreMoveToward(MoveTarget, GetFocus(), GetTeamPace());
		__NFUN_502__(MoveTarget, GetFocus());
		// End:0x525
		if(__NFUN_130__(ConfirmActionPointReached(), MoveTarget.__NFUN_303__('R6Door')))
		{
			ForceCurrentDoor(R6Door(MoveTarget));
		}
		goto 'DoorsAndLadders';		
	}
	else
	{
		R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetTeamPace());
		__NFUN_502__(m_TeamManager.m_PlanActionPoint);
		__NFUN_256__(1.0000000);
	}
	J0x56F:

	m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
	// End:0x701
	if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(m_TeamManager.m_ePlanAction), int(0)), __NFUN_119__(m_pawn.m_Door, none)), __NFUN_132__(NextActionPointIsThroughDoor(m_NextMoveTarget), NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint))), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
	{
		// End:0x685
		if(__NFUN_132__(__NFUN_114__(m_TeamManager.m_PlanActionPoint, m_pawn.m_Door), __NFUN_114__(m_NextMoveTarget, m_pawn.m_Door)))
		{
			R6PreMoveToward(m_pawn.m_Door, m_pawn.m_Door, GetTeamPace());
			__NFUN_502__(m_pawn.m_Door);
			m_TeamManager.ActionPointReached();
		}
		// End:0x6DE
		if(__NFUN_132__(__NFUN_129__(m_TeamManager.m_bEntryInProgress), __NFUN_119__(m_TeamManager.m_Door, m_pawn.m_Door)))
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
		__NFUN_113__('ApproachLadder');
	}
FormationAroundDoor:


	// End:0x78E
	if(__NFUN_130__(__NFUN_154__(int(m_TeamManager.m_ePlanAction), int(0)), __NFUN_154__(int(m_TeamManager.m_eGoCode), int(4))))
	{
		goto 'PerformPlanningAction';
	}
	// End:0x918
	if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_TeamManager.m_bEntryInProgress), __NFUN_119__(m_pawn.m_Door, none)), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
	{
		// End:0x81F
		if(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorLocked)
		{
			GotoLockPickState(m_pawn.m_Door.m_RotatingDoor);
		}
		__NFUN_256__(1.0000000);
		m_NextMoveTarget = m_TeamManager.PreviewNextActionPoint();
		m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
		// End:0x8F2
		if(PreEntryRoomIsAcceptablyLarge())
		{
			m_vTargetPosition = __NFUN_2205__(false);
			// End:0x8F2
			if(__NFUN_218__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000)))
			{
				R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, GetTeamPace());
				__NFUN_500__(m_vTargetPosition);
				__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_pawn.m_Door.m_CorrespondingDoor.Location, m_vTargetPosition)));
			}
		}
		StopMoving();
		SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
		__NFUN_508__();
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
			if(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed), NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint)))
			{
				m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
				SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
				GotoStateLeadRoomEntry();
			}
			goto 'PickActionPoint';
		}
		// End:0xA16
		if(__NFUN_154__(m_iActionUseGadgetGroup, 0))
		{
			m_TeamManager.ReOrganizeTeamForGrenade(m_TeamManager.m_ePlanAction);
		}
		// End:0xA47
		if(__NFUN_155__(m_pawn.m_iCurrentWeapon, m_iActionUseGadgetGroup))
		{
			SwitchWeapon(m_iActionUseGadgetGroup);
			__NFUN_261__(m_pawn.14);
		}
		m_bIgnoreBackupBump = true;
		m_ActionTarget = m_pawn.m_Door;
		// End:0xB47
		if(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))
		{
			m_RotatingDoor = m_pawn.m_Door.m_RotatingDoor;
			SetFocusToDoorKnob(m_RotatingDoor);
			__NFUN_508__();
			m_pawn.PlayDoorAnim(m_RotatingDoor);
			__NFUN_256__(0.5000000);
			m_pawn.ServerPerformDoorAction(m_RotatingDoor, int(m_RotatingDoor.1));
			J0xB05:

			// End:0xB47 [Loop If]
			if(m_RotatingDoor.m_bIsDoorClosed)
			{
				// End:0xB3C
				if(__NFUN_129__(m_RotatingDoor.m_bInProcessOfOpening))
				{
					__NFUN_256__(1.0000000);
					goto 'PerformPlanningAction';					
				}
				else
				{
					__NFUN_256__(0.1000000);
				}
				// [Loop Continue]
				goto J0xB05;
			}
		}
		// End:0xBF2
		if(__NFUN_119__(m_ActionTarget, none))
		{
			// End:0xBAA
			if(__NFUN_129__(PreEntryRoomIsAcceptablyLarge()))
			{
				R6PreMoveToward(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor, GetTeamPace());
				__NFUN_502__(m_ActionTarget, m_pawn.m_Door.m_CorrespondingDoor);
				StopMoving();
			}
			// End:0xBEF
			if(__NFUN_129__(CanThrowGrenadeIntoRoom(m_pawn.m_Door.m_CorrespondingDoor, m_TeamManager.m_vPlanActionLocation)))
			{
				m_TeamManager.ActionNodeCompleted();
				goto 'PostThrowGrenade';
			}			
		}
		else
		{
			// End:0xC72
			if(__NFUN_129__(ClearThrowIsAvailable(m_TeamManager.m_vPlanActionLocation)))
			{
				m_vTargetPosition = __NFUN_215__(Pawn.Location, __NFUN_213__(float(300), __NFUN_226__(__NFUN_216__(m_TeamManager.m_vPlanActionLocation, Pawn.Location))));
				R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
				__NFUN_500__(m_vTargetPosition);
				StopMoving();
				__NFUN_256__(1.0000000);
			}
		}
		// End:0xCB1
		if(__NFUN_218__(m_TeamManager.m_vPlanActionLocation, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			m_vLocationOnTarget = m_TeamManager.m_vPlanActionLocation;
			__NFUN_267__(m_vLocationOnTarget);			
		}
		else
		{
			__NFUN_267__(__NFUN_215__(Pawn.Location, __NFUN_213__(float(100), Vector(Pawn.Rotation))));
		}
		Target = self;
		Focus = self;
		__NFUN_508__();
		__NFUN_299__(Pawn.Rotation);
		SetGunDirection(Target);
		SetGrenadeParameters(__NFUN_130__(__NFUN_119__(m_ActionTarget, none), PreEntryRoomIsAcceptablyLarge()), true);
		m_bStateFlag = true;
		m_pawn.PlayWeaponAnimation();
		__NFUN_261__(m_pawn.14);
		m_pawn.m_eRepGrenadeThrow = 0;
		ResetGadgetGroup();
		m_TeamManager.ActionNodeCompleted();
		m_bStateFlag = false;
		SetGunDirection(none);
PostThrowGrenade:


		m_bIgnoreBackupBump = false;
		SwitchWeapon(1);
		__NFUN_261__(m_pawn.14);
		__NFUN_256__(m_pawn.EngineWeapon.GetExplosionDelay());
		// End:0xE31
		if(__NFUN_130__(__NFUN_119__(m_pawn.m_Door, none), __NFUN_132__(NextActionPointIsThroughDoor(m_TeamManager.m_PlanActionPoint), __NFUN_130__(__NFUN_114__(m_TeamManager.m_PlanActionPoint, m_pawn.m_Door), NextActionPointIsThroughDoor(m_TeamManager.PreviewNextActionPoint())))))
		{
			m_iStateProgress = 3;
			__NFUN_113__('LeadRoomEntry', 'EnterRoomBegin');
		}		
	}
	else
	{
		// End:0xE8B
		if(__NFUN_114__(MoveTarget, none))
		{
			// End:0xE6C
			if(__NFUN_154__(int(m_TeamManager.m_eGoCode), int(4)))
			{
				m_TeamManager.SetTeamState(2);				
			}
			else
			{
				m_TeamManager.SetTeamState(1);
			}
			StopMoving();
			__NFUN_256__(1.0000000);
		}
	}
	// End:0xEE2
	if(__NFUN_130__(__NFUN_130__(m_TeamManager.m_bEntryInProgress, __NFUN_154__(int(m_TeamManager.m_eGoCode), int(4))), __NFUN_119__(m_TeamManager.m_PlanActionPoint, none)))
	{
		m_TeamManager.RainbowHasLeftDoor(m_pawn);
	}
	// End:0xF0A
	if(__NFUN_154__(int(m_TeamManager.m_eNextAPAction), int(0)))
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
		if(__NFUN_154__(m_iStateProgress, 3))
		{
			m_TeamManager.ActionNodeCompleted();
			m_iStateProgress = 0;
		}
		return;
	}

	function R6Door GetDoorPathNode()
	{
		local float fDistA, fDistB;

		fDistA = __NFUN_225__(__NFUN_216__(m_TeamManager.m_BreachingDoor.m_DoorActorA.Location, Pawn.Location));
		fDistB = __NFUN_225__(__NFUN_216__(m_TeamManager.m_BreachingDoor.m_DoorActorB.Location, Pawn.Location));
		// End:0x9A
		if(__NFUN_176__(fDistA, fDistB))
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
		if(__NFUN_150__(m_iStateProgress, 1))
		{
			return;
		}
		global.DetonateBreach();
		return;
	}
Begin:

	// End:0x1A
	if(__NFUN_114__(m_TeamManager.m_BreachingDoor, none))
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
	__NFUN_502__(m_ActionTarget, m_TeamManager.m_BreachingDoor);
	ForceCurrentDoor(R6Door(m_ActionTarget));
	StopMoving();
	Focus = m_pawn.m_Door.m_CorrespondingDoor;
	__NFUN_256__(0.5000000);
	// End:0x159
	if(__NFUN_177__(DistanceTo(m_ActionTarget), float(30)))
	{
		m_vTargetPosition = __NFUN_216__(Pawn.Location, __NFUN_213__(float(60), Vector(Pawn.Rotation)));
		R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_BreachingDoor.Location, 4);
		__NFUN_500__(m_vTargetPosition, m_TeamManager.m_BreachingDoor);
		__NFUN_256__(0.5000000);
		goto 'GetIntoPosition';
	}
	m_bIgnoreBackupBump = true;
	m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
	m_TeamManager.SetTeamState(20);
	SwitchWeapon(m_iActionUseGadgetGroup);
	__NFUN_256__(0.2000000);
	__NFUN_261__(m_pawn.14);
	m_pawn.PlayBreachDoorAnimation();
	__NFUN_261__(m_pawn.1);
	Pawn.EngineWeapon.NPCPlaceCharge(m_TeamManager.m_BreachingDoor);
	m_iStateProgress = 1;
	PlaySoundCurrentAction(7);
	__NFUN_256__(2.5000000);
	m_bIgnoreBackupBump = false;
MoveAwayFromDoor:


	m_vTargetPosition = __NFUN_2205__(false);
	// End:0x2EC
	if(__NFUN_218__(m_vTargetPosition, m_pawn.m_Door.Location))
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
		__NFUN_500__(m_vTargetPosition);
		__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_pawn.m_Door.m_CorrespondingDoor.Location, m_vTargetPosition)));		
	}
	else
	{
		m_vTargetPosition = __NFUN_216__(m_pawn.m_Door.Location, __NFUN_213__(float(100), Vector(m_pawn.m_Door.Rotation)));
		// End:0x36C
		if(m_pawn.bIsCrouched)
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 2);			
		}
		else
		{
			R6PreMoveTo(m_vTargetPosition, m_pawn.m_Door.m_RotatingDoor.Location, 4);
		}
		__NFUN_500__(m_vTargetPosition);
	}
	StopMoving();
	SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
	__NFUN_508__();
	// End:0x3EE
	if(__NFUN_154__(int(m_TeamManager.m_eGoCode), int(4)))
	{
		__NFUN_256__(1.0000000);
		DetonateBreach();
	}
	m_TeamManager.PlayWaitingGoCode(m_TeamManager.m_eGoCode);
	m_iStateProgress = 2;
WaitToDetonate:


	m_TeamManager.SetTeamState(1);
	__NFUN_256__(0.2000000);
	goto 'WaitToDetonate';
	stop;	
}

state DetonateBreachingCharge
{Begin:

	ResetStateProgress();
	// End:0x3F
	if(__NFUN_132__(__NFUN_114__(m_TeamManager.m_BreachingDoor, none), __NFUN_129__(m_TeamManager.m_BreachingDoor.ShouldBeBreached())))
	{
		goto 'End';
	}
	J0x3F:

	// End:0x5C [Loop If]
	if(m_TeamManager.m_bTeamIsHoldingPosition)
	{
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0x3F;
	}
	Pawn.EngineWeapon.NPCDetonateCharge();
End:


	SwitchWeapon(1);
	__NFUN_256__(0.5000000);
	__NFUN_261__(m_pawn.14);
	// End:0xB8
	if(__NFUN_114__(m_TeamManager.m_PlanActionPoint, m_ActionTarget))
	{
		m_TeamManager.ActionPointReached();
	}
	m_TeamManager.m_BreachingDoor = none;
	ResetGadgetGroup();
	// End:0xE7
	if(m_TeamManager.m_bTeamIsHoldingPosition)
	{
		__NFUN_113__('HoldPosition');
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
		__NFUN_113__('Patrol');
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
		__NFUN_280__(0.0000000, false);
		// End:0x54
		if(__NFUN_154__(m_iStateProgress, 7))
		{
			m_iStateProgress = 0;
		}
		m_bIndividualAttacks = true;
		return;
	}

	function Timer()
	{
		// End:0x1A
		if(__NFUN_153__(m_iStateProgress, 5))
		{
			__NFUN_165__(m_iTurn);
			__NFUN_2219__(true);			
		}
		else
		{
			// End:0x5A
			if(__NFUN_154__(m_pawn.m_iID, 0))
			{
				// End:0x5A
				if(__NFUN_176__(DistanceTo(m_TeamManager.m_PlanActionPoint), float(150)))
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
		if(__NFUN_130__(__NFUN_119__(m_TeamLeader, none), m_TeamLeader.m_bIsPlayer))
		{
			bCrouchedEntry = false;			
		}
		else
		{
			bCrouchedEntry = __NFUN_154__(int(m_TeamManager.m_eMovementSpeed), int(2));
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
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		m_TeamManager.RainbowHasLeftDoor(m_pawn);
		goto 'Completed';
	}
	// End:0x60
	if(__NFUN_129__(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed))
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
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		goto 'EntryFinished';
	}
	// End:0x121
	if(__NFUN_129__(PreEntryRoomIsAcceptablyLarge()))
	{
		R6PreMoveToward(m_TeamManager.m_Door, m_TeamManager.m_Door, GetRoomEntryPace(false));
		__NFUN_502__(m_TeamManager.m_Door);
	}
	// End:0x162
	if(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorLocked)
	{
		GotoLockPickState(m_TeamManager.m_Door.m_RotatingDoor);
	}
	StopMoving();
	J0x168:

	// End:0x187 [Loop If]
	if(__NFUN_129__(m_TeamManager.LastMemberIsStationary()))
	{
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0x168;
	}
	// End:0x244
	if(PreEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = __NFUN_2205__(false);
		// End:0x244
		if(__NFUN_130__(__NFUN_177__(__NFUN_225__(__NFUN_216__(m_vTargetPosition, Pawn.Location)), float(30)), __NFUN_218__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000))))
		{
			R6PreMoveTo(m_vTargetPosition, m_TeamManager.m_Door.m_RotatingDoor.Location, GetRoomEntryPace(false));
			__NFUN_500__(m_vTargetPosition);
			__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(m_TeamManager.m_Door.m_CorrespondingDoor.Location, m_vTargetPosition)));
			StopMoving();
		}
	}
	m_iStateProgress = 1;
OpenDoor:


	// End:0x2C3
	if(__NFUN_129__(m_TeamManager.m_bLeaderIsAPlayer))
	{
		J0x25F:

		// End:0x2C3 [Loop If]
		if(__NFUN_155__(int(m_TeamManager.m_eGoCode), int(4)))
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
					__NFUN_256__(0.2000000);
					// [Loop Continue]
					goto J0x298;
				}				
			}
			else
			{
				__NFUN_256__(0.5000000);
			}
			// [Loop Continue]
			goto J0x25F;
		}
	}
	m_TeamManager.SetTeamState(9);
	SetFocusToDoorKnob(m_TeamManager.m_Door.m_RotatingDoor);
	__NFUN_256__(0.5000000);
	m_pawn.PlayDoorAnim(m_TeamManager.m_Door.m_RotatingDoor);
	__NFUN_256__(0.5000000);
	m_pawn.ServerPerformDoorAction(m_TeamManager.m_Door.m_RotatingDoor, int(m_TeamManager.m_Door.m_RotatingDoor.1));
	m_iStateProgress = 2;
	J0x374:

	// End:0x3DA [Loop If]
	if(m_TeamManager.m_Door.m_RotatingDoor.m_bIsDoorClosed)
	{
		// End:0x3CF
		if(__NFUN_129__(m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening))
		{
			__NFUN_256__(1.0000000);
			goto 'OpenDoor';			
		}
		else
		{
			__NFUN_256__(0.1000000);
		}
		// [Loop Continue]
		goto J0x374;
	}
	// End:0x407
	if(__NFUN_114__(m_TeamManager.m_Door, none))
	{
		m_TeamManager.m_Door = R6Door(m_ActionTarget);
	}
	m_iStateProgress = 3;
EnterRoomBegin:


	__NFUN_280__(0.2000000, true);
	m_TeamManager.SetTeamState(13);
	m_eCurrentRoomLayout = m_TeamManager.m_Door.m_eRoomLayout;
	m_vTargetPosition = m_TeamManager.m_Door.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	__NFUN_2201__(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
	m_TeamManager.EnteredRoom(m_pawn);
	m_vTargetPosition = m_TeamManager.m_Door.m_CorrespondingDoor.Location;
	R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, GetRoomEntryPace(true));
	__NFUN_2201__(m_vTargetPosition, m_TeamManager.m_Door.Rotation);
	m_iStateProgress = 4;
InsideRoom:


	// End:0x543
	if(__NFUN_154__(m_pawn.m_iID, __NFUN_147__(m_TeamManager.m_iMemberCount, 1)))
	{
		m_iStateProgress = 5;
		goto 'EntryFinished';
	}
	// End:0x58E
	if(PostEntryRoomIsAcceptablyLarge())
	{
		m_vTargetPosition = __NFUN_2205__(true);
		__NFUN_267__(FocalPoint);
		R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
		__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));		
	}
	else
	{
		m_bStateFlag = true;
		// End:0x749
		if(__NFUN_130__(__NFUN_154__(m_pawn.m_iID, 0), __NFUN_119__(m_TeamManager.m_PlanActionPoint, none)))
		{
			__NFUN_280__(0.0000000, false);
			// End:0x61E
			if(__NFUN_129__(m_TeamManager.m_Door.m_RotatingDoor.m_bBroken))
			{
				J0x5EF:

				// End:0x61E [Loop If]
				if(m_TeamManager.m_Door.m_RotatingDoor.m_bInProcessOfOpening)
				{
					__NFUN_256__(0.1000000);
					// [Loop Continue]
					goto J0x5EF;
				}
			}
			J0x61E:

			// End:0x746 [Loop If]
			if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_119__(m_TeamManager.m_PlanActionPoint, none), __NFUN_176__(DistanceTo(m_TeamManager.m_Door), float(400))), __NFUN_132__(__NFUN_114__(m_pawn.m_Door, none), __NFUN_129__(m_pawn.m_Door.m_RotatingDoor.m_bIsDoorClosed))), __NFUN_154__(int(m_TeamManager.m_ePlanAction), int(0))))
			{
				// End:0x6C6
				if(__NFUN_129__(__NFUN_520__(m_TeamManager.m_PlanActionPoint)))
				{
					// [Explicit Break]
					goto J0x746;
				}
				R6PreMoveToward(m_TeamManager.m_PlanActionPoint, m_TeamManager.m_PlanActionPoint, GetRoomEntryPace(false));
				__NFUN_502__(m_TeamManager.m_PlanActionPoint);
				// End:0x720
				if(__NFUN_177__(DistanceTo(m_TeamManager.m_PlanActionPoint), float(100)))
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
			__NFUN_2209__(m_TeamManager.m_Door.m_CorrespondingDoor, m_vTargetPosition);
			__NFUN_267__(__NFUN_215__(m_vTargetPosition, __NFUN_213__(float(60), __NFUN_216__(m_vTargetPosition, Pawn.Location))));
			R6PreMoveTo(m_vTargetPosition, Location, GetRoomEntryPace(true));
			__NFUN_2201__(m_vTargetPosition, Rotator(__NFUN_216__(Location, m_vTargetPosition)));
		}
	}
	m_iStateProgress = 5;
EntryFinished:


	__NFUN_280__(1.0000000, true);
	__NFUN_2219__(true);
	m_TeamManager.RainbowHasLeftDoor(m_pawn);
	m_iStateProgress = 6;
	// End:0x81A
	if(__NFUN_154__(m_pawn.m_iID, __NFUN_147__(m_TeamManager.m_iMemberCount, 1)))
	{
		__NFUN_256__(1.5000000);		
	}
	else
	{
		__NFUN_256__(3.0000000);
	}
	J0x822:

	m_iStateProgress = 7;
	// End:0x862
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		// End:0x858
		if(__NFUN_129__(m_bStateFlag))
		{
			m_TeamManager.RestoreTeamOrder();
		}
		__NFUN_113__('Patrol');		
	}
	else
	{
		// End:0x881
		if(__NFUN_155__(m_TeamManager.m_iTeamAction, 0))
		{
			__NFUN_113__(GetNextTeamActionState());			
		}
		else
		{
			__NFUN_113__('FollowLeader');
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
		if(__NFUN_129__(m_bStateFlag))
		{
			global.SeePlayer(seen);
			return;
		}
		// End:0x112
		if(m_pawn.IsEnemy(seen))
		{
			aPawn = R6Pawn(seen);
			// End:0x83
			if(__NFUN_132__(__NFUN_132__(__NFUN_132__(aPawn.m_bIsKneeling, __NFUN_129__(aPawn.IsAlive())), __NFUN_114__(m_TeamManager, none)), __NFUN_119__(Enemy, none)))
			{
				return;
			}
			// End:0x112
			if(__NFUN_2222__(seen, m_pawn.GetFiringStartPoint()))
			{
				// End:0xE4
				if(__NFUN_130__(m_TeamManager.m_bSniperHold, __NFUN_119__(m_TeamManager.m_OtherTeamVoicesMgr, none)))
				{
					m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 0);
				}
				m_pawn.m_bEngaged = true;
				SetEnemy(seen);
				Target = Enemy;
				__NFUN_117__('EnemyNotVisible');
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
		if(__NFUN_176__(__NFUN_175__(Level.TimeSeconds, LastSeenTime), 0.5000000))
		{
			return;
		}
		// End:0x68
		if(__NFUN_130__(m_TeamManager.m_bSniperHold, __NFUN_119__(m_TeamManager.m_OtherTeamVoicesMgr, none)))
		{
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 1);
		}
		StopFiring();
		EndAttack();
		__NFUN_118__('EnemyNotVisible');
		return;
	}

	function bool NoiseSourceIsVisible()
	{
		// End:0x22
		if(__NFUN_176__(__NFUN_225__(__NFUN_216__(m_vNoiseFocalPoint, Pawn.Location)), float(200)))
		{
			return false;
		}
		// End:0x57
		if(__NFUN_177__(__NFUN_219__(__NFUN_226__(__NFUN_216__(m_vNoiseFocalPoint, Pawn.Location)), Vector(Pawn.Rotation)), 0.3000000))
		{
			return true;
		}
		return false;
		return;
	}

	event Timer()
	{
		// End:0x0D
		if(__NFUN_119__(Enemy, none))
		{
			return;
		}
		// End:0x7D
		if(__NFUN_218__(m_vNoiseFocalPoint, vect(0.0000000, 0.0000000, 0.0000000)))
		{
			// End:0x6A
			if(__NFUN_130__(__NFUN_130__(__NFUN_154__(m_TeamManager.m_iMemberCount, 1), __NFUN_129__(NoiseSourceIsVisible())), __NFUN_548__(Pawn.Location, m_vNoiseFocalPoint)))
			{
				__NFUN_113__('PauseSniping');				
			}
			else
			{
				m_vNoiseFocalPoint = vect(0.0000000, 0.0000000, 0.0000000);
			}
		}
		return;
	}
Begin:

	__NFUN_280__(0.5000000, true);
	Enemy = none;
	Target = Enemy;
	m_TeamManager.CheckTeamEngagingStatus();
	// End:0x58
	if(__NFUN_177__(DistanceTo(m_ActionTarget), float(300)))
	{
		// End:0x58
		if(SniperChangeToSecondaryWeapon())
		{
			__NFUN_261__(m_pawn.14);
		}
	}
	J0x58:

	// End:0x8F [Loop If]
	if(__NFUN_177__(DistanceTo(m_ActionTarget), float(40)))
	{
		R6PreMoveToward(m_ActionTarget, m_ActionTarget, 4);
		__NFUN_502__(m_ActionTarget);
		StopMoving();
		// [Loop Continue]
		goto J0x58;
	}
	ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
	__NFUN_508__();
TakePosition:


	// End:0xBD
	if(SniperChangeToPrimaryWeapon())
	{
		__NFUN_261__(m_pawn.14);
	}
	// End:0xDD
	if(Pawn.m_bIsProne)
	{
		m_bIgnoreBackupBump = true;
		goto 'LocateEnemy';
	}
	m_vTargetPosition = __NFUN_216__(Pawn.Location, vect(0.0000000, 0.0000000, 60.0000000));
	// End:0x14E
	if(__NFUN_2223__(m_vTargetPosition, m_TeamManager.m_rSnipingDir))
	{
		Pawn.bWantsToCrouch = true;
		__NFUN_256__(0.5000000);
		Pawn.m_bWantsToProne = true;
		__NFUN_256__(1.5000000);		
	}
	else
	{
		// End:0x18C
		if(__NFUN_2223__(Pawn.Location, m_TeamManager.m_rSnipingDir))
		{
			Pawn.bWantsToCrouch = true;
			__NFUN_256__(1.0000000);			
		}
		else
		{
			Pawn.bWantsToCrouch = false;
			Pawn.m_bWantsToProne = false;
			__NFUN_256__(0.5000000);
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
	if(__NFUN_129__(m_TeamManager.m_bCAWaitingForZuluGoCode))
	{
		m_TeamManager.SetTeamState(7);
	}
	// End:0x260
	if(__NFUN_114__(Enemy, none))
	{
		ChangeOrientationTo(m_TeamManager.m_rSnipingDir);
		__NFUN_256__(0.1000000);
		goto 'LocateEnemy';
	}
EngageEnemy:


	m_TeamManager.CheckTeamEngagingStatus();
	// End:0x301
	if(__NFUN_130__(__NFUN_129__(m_TeamManager.m_bSniperHold), __NFUN_119__(Enemy, none)))
	{
		Pawn.EngineWeapon.SetRateOfFire(0);
		Focus = Enemy;
		Target = Enemy;
		__NFUN_508__();
		J0x2C3:

		// End:0x2DE [Loop If]
		if(__NFUN_129__(IsReadyToFire(Enemy)))
		{
			__NFUN_256__(0.2000000);
			// [Loop Continue]
			goto J0x2C3;
		}
		m_TeamManager.RainbowIsEngagingEnemy();
		StartFiring();
		__NFUN_256__(0.2000000);
		StopFiring();
	}
	// End:0x310
	if(NeedToReload())
	{
		RainbowReloadWeapon();
	}
	// End:0x321
	if(__NFUN_114__(Enemy, none))
	{
		goto 'LocateEnemy';
	}
	// End:0x3B6
	if(__NFUN_129__(R6Pawn(Enemy).IsAlive()))
	{
		// End:0x381
		if(__NFUN_130__(m_TeamManager.m_bSniperHold, __NFUN_119__(m_TeamManager.m_OtherTeamVoicesMgr, none)))
		{
			m_TeamManager.m_OtherTeamVoicesMgr.PlayRainbowOtherTeamVoices(m_pawn, 1);
		}
		m_TeamManager.DisEngageEnemy(Pawn, Enemy);
		Enemy = none;
		m_pawn.ResetBoneRotation();
		goto 'LocateEnemy';
	}
	__NFUN_256__(1.0000000);
	goto 'EngageEnemy';
EndSniping:


	m_pawn.ResetBoneRotation();
	m_bIgnoreBackupBump = false;
	// End:0x406
	if(Pawn.m_bWantsToProne)
	{
		Pawn.m_bWantsToProne = false;
		__NFUN_256__(1.0000000);
	}
	Pawn.bWantsToCrouch = false;
WaitForGoCode:


	__NFUN_256__(1.0000000);
	goto 'WaitForGoCode';
Finish:


	// End:0x443
	if(__NFUN_154__(m_pawn.m_iID, 0))
	{
		__NFUN_113__('Patrol');		
	}
	else
	{
		__NFUN_113__('FollowLeader');
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
		__NFUN_256__(1.0000000);
	}
	Pawn.bWantsToCrouch = false;
LookAround:


	__NFUN_267__(m_vTargetPosition);
	Focus = self;
	__NFUN_508__();
Wait:


	__NFUN_256__(2.5000000);
	// End:0x8B
	if(__NFUN_119__(Enemy, none))
	{
		goto 'Wait';
	}
	__NFUN_113__('SnipeUntilGoCode');
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
	if(__NFUN_132__(__NFUN_114__(MoveTarget, none), __NFUN_129__(MoveTarget.__NFUN_303__('R6Ladder'))))
	{
		__NFUN_113__('HoldPosition');
	}
	m_TargetLadder = R6Ladder(MoveTarget);
	// End:0x9D
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_TargetLadder.Location)), __NFUN_129__(__NFUN_520__(m_TargetLadder))))
	{
		FindPathToTargetLocation(m_TargetLadder.Location, m_TargetLadder);
	}
	// End:0xF8
	if(m_TargetLadder.m_bIsTopOfLadder)
	{
		m_vTargetPosition = __NFUN_215__(m_TargetLadder.Location, __NFUN_213__(float(70), Vector(m_TargetLadder.Rotation)));
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		__NFUN_500__(m_vTargetPosition);		
	}
	else
	{
		MoveTarget = m_TargetLadder;
		R6PreMoveToward(MoveTarget, MoveTarget, 4);
		__NFUN_502__(MoveTarget);
	}
	J0x11D:

	// End:0x14B [Loop If]
	if(m_TeamManager.m_bCAWaitingForZuluGoCode)
	{
		m_TeamManager.SetTeamState(1);
		__NFUN_256__(0.5000000);
		// [Loop Continue]
		goto J0x11D;
	}
	MoveTarget = m_TargetLadder;
WaitAtEndForLeader:


	m_TeamManager.SetTeamState(18);
	NextState = 'TeamClimbEndNoLeader';
	__NFUN_113__('ApproachLadder');
	stop;		
}

state TeamClimbEndNoLeader
{Begin:

	// End:0x1D
	if(__NFUN_154__(m_pawn.m_iID, 1))
	{
		__NFUN_256__(GetLeadershipReactionTime());
	}
PickDest:


	__NFUN_2209__(m_pawn.m_Ladder, m_vTargetPosition);
	// End:0x53
	if(__NFUN_217__(m_vTargetPosition, vect(0.0000000, 0.0000000, 0.0000000)))
	{
		goto 'WaitAtEndForTeam';		
	}
	else
	{
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		__NFUN_500__(m_vTargetPosition);
	}
	StopMoving();
WaitAtEndForTeam:


	m_pawn.m_Ladder = none;
	__NFUN_256__(1.0000000);
	NextState = 'None';
	// End:0xEF
	if(__NFUN_129__(m_TeamManager.m_bTeamIsClimbingLadder))
	{
		// End:0xC9
		if(__NFUN_155__(m_TeamManager.m_iTeamAction, 0))
		{
			__NFUN_113__(GetNextTeamActionState());			
		}
		else
		{
			// End:0xE5
			if(m_TeamManager.m_bTeamIsRegrouping)
			{
				__NFUN_113__('FollowLeader');				
			}
			else
			{
				__NFUN_113__('HoldPosition');
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
		if(__NFUN_154__(m_iStateProgress, 5))
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
			iMember = __NFUN_147__(m_pawn.m_iID, 1);			
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
				__NFUN_267__(__NFUN_215__(m_vTargetPosition, __NFUN_213__(float(100), __NFUN_216__(m_vTargetPosition, m_pawn.m_Ladder.Location))));
				Focus = self;
				// End:0x159
				break;
			// End:0x13C
			case 3:
				rOffset = Rotator(__NFUN_216__(m_vTargetPosition, m_pawn.m_Ladder.Location));
				__NFUN_318__(rOffset, rot(0, 8192, 0));
				__NFUN_267__(__NFUN_215__(m_vTargetPosition, __NFUN_213__(float(100), Vector(rOffset))));
				Focus = self;
				// End:0x159
				break;
			// End:0xFFFF
			default:
				__NFUN_267__(m_pawn.m_Ladder.Location);
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
		if(__NFUN_130__(__NFUN_119__(m_TeamManager.m_TeamLadder, none), __NFUN_129__(PawnIsOnTheSameEndOfLadderAsMember(aRainbow, R6LadderVolume(m_TeamManager.m_TeamLadder.MyLadder)))))
		{
			return false;
		}
		return __NFUN_130__(IsMoving(aRainbow), __NFUN_129__(aRainbow.m_bIsClimbingLadder));
		return;
	}

	function R6Ladder GetLadderMoveTarget()
	{
		// End:0x66
		if(__NFUN_177__(Pawn.Location.Z, m_TeamManager.m_TeamLadder.MyLadder.Location.Z))
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
	if(__NFUN_177__(DistanceTo(m_PaceMember), __NFUN_174__(GetFormationDistance(), float(35))))
	{
		m_vTargetPosition = __NFUN_215__(m_PaceMember.Location, __NFUN_213__(GetFormationDistance(), __NFUN_226__(__NFUN_216__(Pawn.Location, m_PaceMember.Location))));
		// End:0xC6
		if(__NFUN_129__(__NFUN_520__(m_PaceMember)))
		{
			FindPathToTargetLocation(m_PaceMember.Location, m_PaceMember);
		}
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
		__NFUN_500__(m_vTargetPosition);		
	}
	else
	{
		__NFUN_256__(0.5000000);
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
	if(__NFUN_176__(__NFUN_186__(__NFUN_175__(m_PaceMember.Location.Z, Pawn.Location.Z)), float(80)))
	{
		m_iStateProgress = 2;
		goto 'FormationAroundLadder';
	}
	// End:0x161
	if(__NFUN_129__(LeadHasStartedClimbing()))
	{
		__NFUN_256__(1.0000000);
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
	if(__NFUN_129__(m_TeamManager.m_bTeamIsSeparatedFromLeader))
	{
		// End:0x1D5
		if(__NFUN_114__(m_pawn.m_Ladder, none))
		{
			m_pawn.m_Ladder = m_TeamLeader.m_Ladder;
		}
	}
	// End:0x21D
	if(__NFUN_119__(m_pawn.m_Ladder, none))
	{
		m_vTargetPosition = __NFUN_2203__();
		// End:0x21D
		if(__NFUN_521__(m_vTargetPosition))
		{
			R6PreMoveTo(m_vTargetPosition, m_vTargetPosition, 4);
			__NFUN_500__(m_vTargetPosition);
			StopMoving();
		}
	}
	SetPawnFocus();
	m_iStateProgress = 3;
WaitForTurnToClimb:


	// End:0x280
	if(__NFUN_132__(__NFUN_176__(__NFUN_186__(__NFUN_175__(m_PaceMember.Location.Z, Pawn.Location.Z)), float(80)), m_PaceMember.m_bIsClimbingLadder))
	{
		__NFUN_256__(1.0000000);
		goto 'WaitForTurnToClimb';
	}
	m_iStateProgress = 4;
ClimbLadder:


	__NFUN_256__(0.5000000);
	m_pawn.ResetBoneRotation();
	MoveTarget = GetLadderMoveTarget();
	// End:0x2E9
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(MoveTarget.Location)), __NFUN_129__(__NFUN_520__(MoveTarget))))
	{
		FindPathToTargetLocation(MoveTarget.Location, MoveTarget);
	}
	R6PreMoveToward(MoveTarget, MoveTarget, 4);
	__NFUN_502__(MoveTarget);
	m_iStateProgress = 5;
	// End:0x33C
	if(MoveTarget.__NFUN_303__('R6Ladder'))
	{
		NextState = 'FollowLeader';
		NextLabel = 'Begin';
		__NFUN_113__('ApproachLadder');
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
		if(__NFUN_129__(m_TeamManager.m_bGrenadeInProximity))
		{
			__NFUN_280__(0.0000000, false);
		}
		m_pawn.StopPeeking();
		m_pawn.m_u8DesiredYaw = 0;
		// End:0x96
		if(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_TeamManager.m_bLeaderIsAPlayer), m_TeamManager.m_bTeamIsRegrouping), __NFUN_114__(m_PaceMember, m_TeamLeader)))
		{
			m_TeamManager.TeamIsRegroupingOnLead(false);
		}
		return;
	}

	function Timer()
	{
		__NFUN_165__(m_iWaitCounter);
		__NFUN_165__(m_iTurn);
		// End:0x21
		if(__NFUN_154__(m_iTurn, 6))
		{
			m_iTurn = 0;
		}
		// End:0x71
		if(__NFUN_130__(__NFUN_130__(__NFUN_132__(__NFUN_154__(m_pawn.m_iID, 1), __NFUN_154__(m_pawn.m_iID, 2)), IsMoving(Pawn)), __NFUN_155__(int(m_ePawnOrientation), int(5))))
		{
			__NFUN_2206__();
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
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_129__(m_bSlowedPace), IsMoving(m_PaceMember)), __NFUN_129__(Pawn.m_bIsProne)), __NFUN_129__(Pawn.bIsCrouched)))
		{
			return false;
		}
		// End:0x5A
		if(__NFUN_217__(m_vTargetPosition, m_vPreviousPosition))
		{
			return true;
		}
		fDistance = GetFormationDistance();
		// End:0x7A
		if(m_bSlowedPace)
		{
			__NFUN_182__(fDistance, float(2));
		}
		// End:0x9A
		if(m_pawn.m_bIsProne)
		{
			__NFUN_184__(fDistance, float(60));			
		}
		else
		{
			// End:0xB9
			if(__NFUN_129__(m_pawn.m_bIsClimbingStairs))
			{
				__NFUN_184__(fDistance, float(35));
			}
		}
		// End:0xD1
		if(__NFUN_176__(DistanceTo(m_PaceMember, true), fDistance))
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
		if(__NFUN_114__(m_PaceMember, none))
		{
			return Pawn.Location;
		}
		// End:0x183
		if(__NFUN_130__(__NFUN_130__(__NFUN_130__(__NFUN_130__(m_bUseStaggeredFormation, __NFUN_154__(int(m_TeamManager.m_eFormation), int(m_eFormation))), __NFUN_155__(int(m_ePawnOrientation), int(5))), __NFUN_129__(Pawn.m_bIsProne)), __NFUN_129__(m_bSlowedPace)))
		{
			rDir = Rotator(__NFUN_216__(m_PaceMember.Location, Pawn.Location));
			rOffset = rot(0, 2000, 0);
			// End:0x122
			if(__NFUN_132__(__NFUN_154__(int(m_eFormation), int(4)), __NFUN_154__(int(m_eFormation), int(2))))
			{
				// End:0xF5
				if(__NFUN_154__(m_pawn.m_iID, 1))
				{
					__NFUN_318__(rDir, rOffset);					
				}
				else
				{
					__NFUN_319__(rDir, rOffset);
				}
				return __NFUN_216__(m_PaceMember.Location, __NFUN_213__(GetFormationDistance(), Vector(rDir)));
			}
			// End:0x183
			if(__NFUN_154__(int(m_eFormation), int(3)))
			{
				// End:0x156
				if(__NFUN_154__(m_pawn.m_iID, 1))
				{
					__NFUN_319__(rDir, rOffset);					
				}
				else
				{
					__NFUN_318__(rDir, rOffset);
				}
				return __NFUN_216__(m_PaceMember.Location, __NFUN_213__(GetFormationDistance(), Vector(rDir)));
			}
		}
		return __NFUN_215__(m_PaceMember.Location, __NFUN_213__(GetFormationDistance(), __NFUN_226__(__NFUN_216__(Pawn.Location, m_PaceMember.Location))));
		return;
	}

	function EngageLadderIfNeeded(R6LadderVolume aVolume)
	{
		// End:0x0D
		if(__NFUN_114__(m_TargetLadder, none))
		{
			return;
		}
		// End:0x45
		if(__NFUN_129__(PawnIsOnTheSameEndOfLadderAsMember(m_PaceMember, aVolume)))
		{
			m_TeamManager.InstructTeamToClimbLadder(aVolume, true, m_pawn.m_iID);
		}
		return;
	}
Begin:

	// End:0x49
	if(__NFUN_114__(m_PaceMember, none))
	{
		// End:0x49
		if(__NFUN_130__(__NFUN_119__(m_TeamLeader, none), __NFUN_119__(m_TeamManager, none)))
		{
			m_PaceMember = m_TeamManager.m_Team[__NFUN_147__(m_pawn.m_iID, 1)];
		}
	}
	m_TeamManager.SetFormation(self);
	__NFUN_280__(1.0000000, true);
	VerifyWeaponInventory();
	EnsureRainbowIsArmed();
	// End:0x95
	if(__NFUN_130__(__NFUN_129__(m_pawn.IsStationary()), SniperChangeToSecondaryWeapon()))
	{
		__NFUN_256__(0.5000000);
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
	if(__NFUN_130__(__NFUN_114__(m_PaceMember, m_TeamLeader), m_TeamLeader.m_bIsPlayer))
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
		if(__NFUN_129__(m_bAlreadyWaiting))
		{
			m_iWaitCounter = 0;
			m_pawn.ResetBoneRotation();
			m_pawn.StopPeeking();
			EnsureRainbowIsArmed();
			// End:0x1E0
			if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(m_ePawnOrientation), int(5)), __NFUN_129__(m_bIsMovingBackwards)), __NFUN_129__(Pawn.m_bIsProne)))
			{
				__NFUN_256__(0.2000000);
				m_bIsMovingBackwards = true;
				__NFUN_267__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(2), __NFUN_216__(m_PaceMember.Location, Pawn.Location))));
				Focus = self;
			}
			m_bAlreadyWaiting = true;
		}
		// End:0x28B
		if(__NFUN_180__(__NFUN_225__(m_TeamLeader.Velocity), float(0)))
		{
			// End:0x28B
			if(__NFUN_130__(__NFUN_151__(m_iWaitCounter, 6), __NFUN_129__(m_TeamManager.m_bTeamIsClimbingLadder)))
			{
				// End:0x239
				if(SniperChangeToPrimaryWeapon())
				{
					__NFUN_261__(m_pawn.14);
				}
				// End:0x28B
				if(__NFUN_130__(__NFUN_129__(Pawn.bIsCrouched), __NFUN_129__(Pawn.m_bIsProne)))
				{
					m_pawn.StopPeeking();
					Pawn.bWantsToCrouch = true;
					__NFUN_256__(0.2000000);
				}
			}
		}
		__NFUN_256__(0.2000000);
		goto 'Moving';
	}
	m_vPreviousPosition = m_vTargetPosition;
	// End:0x2D5
	if(m_bAlreadyWaiting)
	{
		m_pawn.StopPeeking();
		__NFUN_256__(0.2000000);
		// End:0x2D5
		if(SniperChangeToSecondaryWeapon())
		{
			__NFUN_256__(0.5000000);
		}
	}
	m_bAlreadyWaiting = false;
	// End:0x2FF
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_vTargetPosition)), __NFUN_129__(__NFUN_521__(m_vTargetPosition))))
	{
		goto 'bLocked';
	}
	// End:0x32E
	if(__NFUN_114__(m_PaceMember, m_TeamLeader))
	{
		m_TeamManager.TeamIsSeparatedFromLead(false);
		m_TeamManager.TeamIsRegroupingOnLead(false);
	}
	// End:0x389
	if(__NFUN_132__(__NFUN_132__(__NFUN_155__(int(m_ePawnOrientation), int(5)), Pawn.m_bIsProne), m_PaceMember.m_bIsProne))
	{
		m_bIsMovingBackwards = false;
		R6PreMoveTo(m_vTargetPosition, m_vTargetPosition);
		__NFUN_267__(m_vTargetPosition);		
	}
	else
	{
		// End:0x420
		if(__NFUN_130__(__NFUN_130__(m_PaceMember.IsWalking(), __NFUN_151__(m_iTurn, 2)), __NFUN_176__(DistanceTo(m_PaceMember), __NFUN_174__(GetFormationDistance(), float(120)))))
		{
			m_bIsMovingBackwards = true;
			__NFUN_267__(__NFUN_216__(Pawn.Location, __NFUN_213__(float(2), __NFUN_216__(m_PaceMember.Location, Pawn.Location))));
			R6PreMoveTo(m_vTargetPosition, Location, GetPace(true));			
		}
		else
		{
			m_bIsMovingBackwards = false;
			__NFUN_267__(m_vTargetPosition);
			// End:0x475
			if(__NFUN_130__(m_PaceMember.bIsCrouched, __NFUN_177__(DistanceTo(m_PaceMember), __NFUN_174__(GetFormationDistance(), float(40)))))
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
		__NFUN_256__(0.5000000);
		J0x496:

		// End:0x4B3 [Loop If]
		if(m_pawn.m_bPostureTransition)
		{
			__NFUN_256__(0.5000000);
			// [Loop Continue]
			goto J0x496;
		}
	}
	__NFUN_500__(m_vTargetPosition, self);
	// End:0x4D5
	if(__NFUN_154__(int(m_eMoveToResult), int(2)))
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
	if(__NFUN_114__(m_PaceMember, m_TeamLeader))
	{
		m_TeamManager.TeamIsRegroupingOnLead(true);
		J0x502:

		// End:0x53F [Loop If]
		if(__NFUN_177__(DistanceTo(m_TeamManager.m_Team[__NFUN_147__(m_TeamManager.m_iMemberCount, 1)]), float(600)))
		{
			__NFUN_256__(0.5000000);
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
	MoveTarget = __NFUN_517__(m_PaceMember, true);
	// End:0x62D
	if(__NFUN_114__(MoveTarget, none))
	{
		m_pawn.logWarning(__NFUN_112__(__NFUN_112__("is at location ", string(Pawn.Location)), " and there appear to be insufficient pathnodes..."));
		__NFUN_500__(__NFUN_215__(Pawn.Location, __NFUN_212__(__NFUN_226__(__NFUN_216__(m_PaceMember.Location, Pawn.Location)), float(100))));
		__NFUN_256__(1.0000000);
		goto 'bLocked';
	}
	// End:0x672
	if(__NFUN_114__(MoveTarget, m_PaceMember))
	{
		J0x63C:

		// End:0x659 [Loop If]
		if(m_PaceMember.m_bIsClimbingLadder)
		{
			__NFUN_256__(1.0000000);
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
		if(__NFUN_1509__(MoveTarget))
		{
			m_TeamManager.RainbowIsInFrontOfAClosedDoor(m_pawn, m_pawn.m_Door);
			__NFUN_2201__(m_pawn.m_Door.Location, m_pawn.m_Door.Rotation);
			Pawn.Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
			SetFocusToDoorKnob(m_pawn.m_Door.m_RotatingDoor);
			__NFUN_256__(1.0000000);
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
		if(__NFUN_154__(int(m_pawn.m_eHealth), int(1)))
		{
			R6PreMoveToward(MoveTarget, MoveTarget, 4);			
		}
		else
		{
			R6PreMoveToward(MoveTarget, MoveTarget, 5);
		}
	}
	// End:0x812
	if(MoveTarget.__NFUN_303__('R6Ladder'))
	{
		Pawn.bIsWalking = true;
	}
	__NFUN_502__(MoveTarget);
	// End:0x848
	if(__NFUN_130__(__NFUN_129__(__NFUN_1815__(m_PaceMember.Location)), __NFUN_129__(__NFUN_520__(m_PaceMember))))
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

	__NFUN_256__(0.5000000);
	// End:0x5A
	if(__NFUN_130__(Level.Game.m_bGameStarted, __NFUN_255__(NextState, 'None')))
	{
		// End:0x50
		if(__NFUN_154__(m_pawn.m_iID, 0))
		{
			__NFUN_256__(1.0000000);
		}
		__NFUN_113__(NextState);		
	}
	else
	{
		goto 'Begin';
	}
	stop;			
}

state TestBoneRotation
{Begin:

	__NFUN_256__(3.0000000);
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
		__NFUN_117__('SeePlayer');
		return;
	}
Begin:

	m_pawn.R6LoopAnim('StandSubGunHigh_nt');
Wait:


	__NFUN_256__(1.0000000);
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
