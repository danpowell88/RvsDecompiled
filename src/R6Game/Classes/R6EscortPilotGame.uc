//=============================================================================
// R6EscortPilotGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6EscortPilotGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================
class R6EscortPilotGame extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var config bool EnablePilotPrimaryWeapon;
var config bool EnablePilotSecondaryWeapon;
var config bool EnablePilotTertiaryWeapon;
var R6MObjGoToExtraction m_objGoToExtraction;
var R6PlayerController m_pilotController;
var R6PlayerController m_previousPilot;
var Sound m_sndPilot;

event PostBeginPlay()
{
	super.PostBeginPlay();
	LoadConfig("R6EscortPilotGame.ini");
	// End:0xA7
	if(bShowLog)
	{
		Log(("EnablePilotPrimaryWeapon   =" $ string(EnablePilotPrimaryWeapon)));
		Log(("EnablePilotSecondaryWeapon =" $ string(EnablePilotSecondaryWeapon)));
		Log(("EnablePilotTertiaryWeapon  =" $ string(EnablePilotTertiaryWeapon)));
	}
	return;
}

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local int iLength;

	m_objGoToExtraction = new (none) Class'R6Game.R6MObjGoToExtraction';
	m_objGoToExtraction.m_bIfCompletedMissionIsSuccessfull = true;
	m_objGoToExtraction.m_bIfFailedMissionIsAborted = true;
	m_objGoToExtraction.SetPawnToExtract(none);
	iLength = m_missionMgr.m_aMissionObjectives.Length;
	m_missionMgr.m_aMissionObjectives[iLength] = m_objGoToExtraction;
	(iLength++);
	m_objGoToExtraction.m_szDescriptionInMenu = "EscortPilotToExtraction";
	m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
	Level.m_bUseDefaultMoralityRules = false;
	super.InitObjectives();
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	// End:0x42
	if((R6Pawn(killedPawn) == m_objGoToExtraction.m_pawnToExtract))
	{
		BroadcastMissionObjMsg("", "", "PilotWasKilled");
	}
	super(R6GameInfo).PawnKilled(killedPawn);
	return;
}

//------------------------------------------------------------------
// UnselectPilot
//	
//------------------------------------------------------------------
function UnselectPilot()
{
	// End:0x6C
	if((m_pilotController != none))
	{
		m_pilotController.PlayerReplicationInfo.m_bIsEscortedPilot = false;
		m_previousPilot = m_pilotController;
		// End:0x6C
		if(((m_previousPilot.m_pawn != none) && (int(m_previousPilot.m_pawn.m_bSuicideType) == 1)))
		{
			m_previousPilot = none;
		}
	}
	m_pilotController = none;
	return;
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
	// End:0xB7
	if(m_objGoToExtraction.m_bCompleted)
	{
		// End:0x5B
		if(bShowLog)
		{
			Log("** Game : the pilot was extracted");
		}
		BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
		BroadcastMissionObjMsg("", "", "PilotHasEscaped", none, int(GetGameMsgLifeTime()));
		AddTeamWonRound(c_iAlphaTeam);		
	}
	else
	{
		// End:0x131
		if(m_objGoToExtraction.m_bFailed)
		{
			// End:0xF5
			if(bShowLog)
			{
				Log("** Game : the pilot was killed ");
			}
			BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
			AddTeamWonRound(c_iBravoTeam);
			UnselectPilot();			
		}
		else
		{
			// End:0x193
			if(m_objDeathmatch.m_bFailed)
			{
				// End:0x165
				if(bShowLog)
				{
					Log("** Game : it's a draw");
				}
				BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));
				UnselectPilot();				
			}
			else
			{
				// End:0x2ED
				if(m_objDeathmatch.m_bCompleted)
				{
					// End:0x247
					if((m_objDeathmatch.m_iWinningTeam == 2))
					{
						// End:0x1E7
						if(bShowLog)
						{
							Log("** Game : alpha eleminated bravo");
						}
						BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
						BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
						AddTeamWonRound(c_iAlphaTeam);						
					}
					else
					{
						// End:0x2EA
						if((m_objDeathmatch.m_iWinningTeam == 3))
						{
							// End:0x289
							if(bShowLog)
							{
								Log("** Game : bravo eleminated alpha");
							}
							BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
							BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
							AddTeamWonRound(c_iBravoTeam);
							UnselectPilot();
						}
					}					
				}
				else
				{
					// End:0x32C
					if(bShowLog)
					{
						Log("** Game : bravo prevented the escape of the pilot ");
					}
					BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
					BroadcastMissionObjMsg("", "", "PilotHasNotEscaped", none, int(GetGameMsgLifeTime()));
					AddTeamWonRound(c_iBravoTeam);
					UnselectPilot();
				}
			}
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

//------------------------------------------------------------------
// CanAutoBalancePlayer
//	
//------------------------------------------------------------------
function bool CanAutoBalancePlayer(R6PlayerController pCtrl)
{
	// End:0x1D
	if(pCtrl.PlayerReplicationInfo.m_bIsEscortedPilot)
	{
		return false;
	}
	return true;
	return;
}

// NEW IN 1.60
function R6SetPilotClassInMultiPlayer(Controller PlayerController)
{
	local R6ModMgr pModManager;

	pModManager = Class'Engine.Actor'.static.GetModMgr();
	R6PlayerController(PlayerController).PawnClass = pModManager.GetDefaultPilotPawn();
	return;
}

//------------------------------------------------------------------
// R6SetPawnClassInMultiPlayer
//	
//------------------------------------------------------------------
function R6SetPawnClassInMultiPlayer(Controller PlayerController)
{
	// End:0x1D
	if((PlayerController == m_pilotController))
	{
		R6SetPilotClassInMultiPlayer(PlayerController);		
	}
	else
	{
		super(R6GameInfo).R6SetPawnClassInMultiPlayer(PlayerController);
	}
	return;
}

//------------------------------------------------------------------
// RestartPlayer
//	
//------------------------------------------------------------------
function RestartPlayer(Controller aPlayer)
{
	super(R6GameInfo).RestartPlayer(aPlayer);
	// End:0x3C
	if((aPlayer == m_pilotController))
	{
		m_objGoToExtraction.SetPawnToExtract(R6Pawn(m_pilotController.Pawn));
	}
	return;
}

//------------------------------------------------------------------
// IsPrimaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsPrimaryWeaponRestrictedToPawn(Pawn aPawn)
{
	// End:0x21
	if((m_objGoToExtraction.m_pawnToExtract == aPawn))
	{
		return (!EnablePilotPrimaryWeapon);
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsSecondaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsSecondaryWeaponRestrictedToPawn(Pawn aPawn)
{
	// End:0x21
	if((m_objGoToExtraction.m_pawnToExtract == aPawn))
	{
		return (!EnablePilotSecondaryWeapon);
	}
	return false;
	return;
}

//------------------------------------------------------------------
// IsTertiaryWeaponRestrictedToPawn
//	restriction for the pilot
//------------------------------------------------------------------
function bool IsTertiaryWeaponRestrictedToPawn(Pawn aPawn)
{
	// End:0x21
	if((m_objGoToExtraction.m_pawnToExtract == aPawn))
	{
		return (!EnablePilotTertiaryWeapon);
	}
	return false;
	return;
}

//------------------------------------------------------------------
// BroadcastGameTypeDescription
//	
//------------------------------------------------------------------
function BroadcastGameTypeDescription()
{
	local Controller P;
	local R6PlayerController PlayerController;

	super(R6GameInfo).BroadcastGameTypeDescription();
	// End:0x13
	if((m_pilotController == none))
	{
		return;
	}
	// End:0x29
	if((m_pilotController.PlayerReplicationInfo == none))
	{
		return;
	}
	m_pilotController.ClientPlaySound(m_sndPilot, 7);
	P = Level.ControllerList;
	J0x53:

	// End:0xE5 [Loop If]
	if((P != none))
	{
		PlayerController = R6PlayerController(P);
		// End:0xCE
		if(((PlayerController != none) && (int(PlayerController.m_TeamSelection) == int(2))))
		{
			PlayerController.ClientMissionObjMsg("", m_pilotController.PlayerReplicationInfo.PlayerName, "PlayerIsThePilot");
		}
		P = P.nextController;
		// [Loop Continue]
		goto J0x53;
	}
	return;
}

auto state InBetweenRoundMenu
{
	function EndState()
	{
		local Controller P;
		local int iTeamACount, iNewGen, i, iTotalPilot;

		P = Level.ControllerList;
		J0x14:

		// End:0xEF [Loop If]
		if((P != none))
		{
			// End:0x38
			if((!P.IsA('PlayerController')))
			{				
			}
			else
			{
				// End:0xBE
				if((((int(R6PlayerController(P).m_TeamSelection) == int(2)) && P.PlayerReplicationInfo.m_bIsEscortedPilot) && (iTotalPilot < 1)))
				{
					// End:0xB4
					if(R6PlayerController(P).m_bPenaltyBox)
					{
						P.PlayerReplicationInfo.m_bIsEscortedPilot = false;						
					}
					else
					{
						(iTotalPilot++);
					}					
				}
				else
				{
					P.PlayerReplicationInfo.m_bIsEscortedPilot = false;
				}
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x14;
		}
		ProcessAutoBalanceTeam();
		m_pilotController = none;
		P = Level.ControllerList;
		J0x110:

		// End:0x1F9 [Loop If]
		if((P != none))
		{
			// End:0x134
			if((!P.IsA('PlayerController')))
			{				
			}
			else
			{
				// End:0x1E2
				if((int(R6PlayerController(P).m_TeamSelection) == int(2)))
				{
					// End:0x1C2
					if(((m_pilotController == none) && P.PlayerReplicationInfo.m_bIsEscortedPilot))
					{
						// End:0x1AF
						if(bShowLog)
						{
							Log("InBetweenRoundMenu: still the same pilot");
						}
						m_pilotController = R6PlayerController(P);						
					}
					else
					{
						// End:0x1E2
						if((!R6PlayerController(P).m_bPenaltyBox))
						{
							(iTeamACount++);
						}
					}
				}
			}
			P = P.nextController;
			// [Loop Continue]
			goto J0x110;
		}
		// End:0x3A4
		if((m_pilotController == none))
		{
			iNewGen = Rand(iTeamACount);
			i = 0;
			P = Level.ControllerList;
			J0x22C:

			// End:0x3A4 [Loop If]
			if((P != none))
			{
				// End:0x382
				if((P.IsA('PlayerController') && ((int(R6PlayerController(P).m_TeamSelection) == int(2)) && (!R6PlayerController(P).m_bPenaltyBox))))
				{
					// End:0x37B
					if((i == iNewGen))
					{
						// End:0x307
						if((m_previousPilot == R6PlayerController(P)))
						{
							// End:0x2C7
							if((iTeamACount == 1))
							{
								m_pilotController = R6PlayerController(P);								
							}
							else
							{
								J0x2C7:

								// End:0x2E6 [Loop If]
								if((iNewGen == i))
								{
									iNewGen = Rand(iTeamACount);
									// [Loop Continue]
									goto J0x2C7;
								}
								i = 0;
								P = Level.ControllerList;
								goto J0x3A1;
							}							
						}
						else
						{
							m_pilotController = R6PlayerController(P);
						}
						// End:0x378
						if((m_pilotController != none))
						{
							// End:0x350
							if(bShowLog)
							{
								Log("InBetweenRoundMenu: set new pilot");
							}
							R6SetPilotClassInMultiPlayer(P);
							m_pilotController.PlayerReplicationInfo.m_bIsEscortedPilot = true;
							// [Explicit Break]
							goto J0x3A4;
						}						
					}
					else
					{
						(i++);
					}
				}
				// End:0x3A1
				if((P != none))
				{
					P = P.nextController;
				}
				J0x3A1:

				// [Loop Continue]
				goto J0x22C;
			}
		}
		J0x3A4:

		m_previousPilot = none;
		super.EndState();
		return;
	}
	stop;
}

defaultproperties
{
	m_sndPilot=Sound'Voices_Control_Multiplayer.Play_YouAreThePilot'
	m_iUbiComGameMode=5
	m_szGameTypeFlag="RGM_EscortAdvMode"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_szPilotSkin
