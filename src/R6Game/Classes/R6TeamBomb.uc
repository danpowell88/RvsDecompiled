//=============================================================================
// R6TeamBomb - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6TeamBomb.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Aristomenis Kolokathis
//=============================================================================
class R6TeamBomb extends R6AdversarialTeamGame
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//------------------------------------------------------------------
// IsBombArmedOrExploded
//	
//------------------------------------------------------------------
function bool IsBombArmedOrExploded()
{
	local R6IOBomb ioBomb;

	// End:0x3A
	foreach __NFUN_313__(Class'R6Engine.R6IOBomb', ioBomb)
	{
		// End:0x39
		if(__NFUN_132__(ioBomb.m_bIsActivated, ioBomb.m_bExploded))
		{			
			return true;
		}		
	}	
	return false;
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	local bool bCheckEndGame;
	local R6IOBomb ioBomb;
	local float fTimeLeft;
	local bool bForceFailNow;
	local float fTimeToExplode;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	m_objDeathmatch.Reset();
	super(R6GameInfo).PawnKilled(killedPawn);
	// End:0x78
	if(m_objDeathmatch.m_bCompleted)
	{
		// End:0x75
		if(__NFUN_132__(__NFUN_129__(IsBombArmedOrExploded()), __NFUN_154__(m_objDeathmatch.m_iWinningTeam, 3)))
		{
			m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = true;
			bCheckEndGame = true;			
		}		
	}
	else
	{
		// End:0x18B
		if(m_objDeathmatch.m_bFailed)
		{
			// End:0xB1
			if(__NFUN_129__(IsBombArmedOrExploded()))
			{
				m_objDeathmatch.m_bIfFailedMissionIsAborted = true;
				bCheckEndGame = true;				
			}
			else
			{
				fTimeLeft = __NFUN_175__(m_fEndingTime, Level.TimeSeconds);
				// End:0xE4
				if(__NFUN_176__(fTimeLeft, float(0)))
				{
					bForceFailNow = true;					
				}
				else
				{
					bForceFailNow = true;
					fTimeToExplode = 3.0000000;
					// End:0x168
					foreach __NFUN_313__(Class'R6Engine.R6IOBomb', ioBomb)
					{
						// End:0x167
						if(__NFUN_130__(ioBomb.m_bIsActivated, __NFUN_178__(ioBomb.m_fTimeLeft, fTimeLeft)))
						{
							// End:0x15F
							if(__NFUN_177__(ioBomb.m_fTimeLeft, fTimeToExplode))
							{
								ioBomb.ForceTimeLeft(fTimeToExplode);
							}
							bForceFailNow = false;
						}						
					}					
				}
				// End:0x18B
				if(bForceFailNow)
				{
					bCheckEndGame = true;
					m_objDeathmatch.m_bIfFailedMissionIsAborted = true;
				}
			}
		}
	}
	// End:0x1A9
	if(bCheckEndGame)
	{
		// End:0x1A9
		if(CheckEndGame(none, ""))
		{
			EndGame(none, "");
		}
	}
	return;
}

//------------------------------------------------------------------
// RestartPlayer
//	set the disarming/arming bomb
//------------------------------------------------------------------
function RestartPlayer(Controller aPlayer)
{
	local R6PlayerController PController;

	super(R6GameInfo).RestartPlayer(aPlayer);
	PController = R6PlayerController(aPlayer);
	// End:0x65
	if(IsPlayerInTeam(PController, c_iAlphaTeam))
	{
		PController.m_pawn.m_bCanArmBomb = false;
		PController.m_pawn.m_bCanDisarmBomb = true;		
	}
	else
	{
		// End:0xAC
		if(IsPlayerInTeam(PController, c_iBravoTeam))
		{
			PController.m_pawn.m_bCanArmBomb = true;
			PController.m_pawn.m_bCanDisarmBomb = false;
		}
	}
	return;
}

//------------------------------------------------------------------
// NotifyMatchStart
//	
//------------------------------------------------------------------
function NotifyMatchStart()
{
	local R6IOBomb ioBomb;

	super(R6AbstractGameInfo).NotifyMatchStart();
	m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = false;
	m_objDeathmatch.m_bIfFailedMissionIsAborted = false;
	// End:0x83
	foreach __NFUN_313__(Class'R6Engine.R6IOBomb', ioBomb)
	{
		ioBomb.m_fTimeLeft = m_fBombTime;
		ioBomb.m_fTimeOfExplosion = m_fBombTime;
		// End:0x82
		if(ioBomb.m_bIsActivated)
		{
			ioBomb.ArmBomb(none);
		}		
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
	local bool bBombExist;
	local R6IOBomb ioBomb;
	local R6MObjPreventBombDetonation objBombDetonation;

	iLength = m_missionMgr.m_aMissionObjectives.Length;
	// End:0x157
	foreach __NFUN_304__(Class'R6Engine.R6IOBomb', ioBomb)
	{
		objBombDetonation = new (none) Class'R6Game.R6MObjPreventBombDetonation';
		objBombDetonation.m_r6IOObject = ioBomb;
		m_missionMgr.m_aMissionObjectives[iLength] = objBombDetonation;
		__NFUN_165__(iLength);
		objBombDetonation.m_bIfFailedMissionIsAborted = true;
		objBombDetonation.m_bIfDetonateObjectiveIsFailed = true;
		objBombDetonation.m_bIfDeviceIsActivatedObjectiveIsCompleted = false;
		objBombDetonation.m_bIfDeviceIsActivatedObjectiveIsFailed = false;
		objBombDetonation.m_bIfDeviceIsDeactivatedObjectiveIsCompleted = false;
		objBombDetonation.m_bIfDeviceIsDeactivatedObjectiveIsFailed = false;
		objBombDetonation.m_bIfDestroyedObjectiveIsCompleted = false;
		objBombDetonation.m_bIfDestroyedObjectiveIsFailed = false;
		bBombExist = true;
		// End:0x156
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__("Bomb Added: ", string(ioBomb)), " armedMsg"), ioBomb.m_szMsgArmedID), " disarmed="), ioBomb.m_szMsgDisarmedID));
		}		
	}	
	// End:0x1AC
	if(__NFUN_130__(__NFUN_129__(bBombExist), m_missionMgr.m_bEnableCheckForErrors))
	{
		__NFUN_231__(__NFUN_112__("WARNING: there is no bomb in the game type: ", string(self)));
	}
	m_missionMgr.m_bOnSuccessAllObjectivesAreCompleted = false;
	Level.m_bUseDefaultMoralityRules = false;
	super.InitObjectives();
	return;
}

//------------------------------------------------------------------
// IObjectInteract
//	
//------------------------------------------------------------------
function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
	local R6IOBomb ioBomb;
	local R6GameReplicationInfo gameRepInfo;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	super(R6AbstractGameInfo).IObjectInteract(aPawn, anInteractiveObject);
	ioBomb = R6IOBomb(anInteractiveObject);
	// End:0xAA
	if(ioBomb.m_bIsActivated)
	{
		// End:0x82
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(" R6TeamBomb: ", Localize("Game", ioBomb.m_szMsgArmedID, ioBomb.GetMissionObjLocFile())));
		}
		BroadcastMissionObjMsg(ioBomb.GetMissionObjLocFile(), "", ioBomb.m_szMsgArmedID);		
	}
	else
	{
		// End:0xEF
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__(" R6TeamBomb: ", Localize("Game", ioBomb.m_szMsgDisarmedID, ioBomb.GetMissionObjLocFile())));
		}
		BroadcastMissionObjMsg(ioBomb.GetMissionObjLocFile(), "", ioBomb.m_szMsgDisarmedID);
	}
	// End:0x157
	if(m_objDeathmatch.m_bCompleted)
	{
		// End:0x157
		if(__NFUN_129__(IsBombArmedOrExploded()))
		{
			m_objDeathmatch.m_bIfCompletedMissionIsSuccessfull = true;
			// End:0x157
			if(CheckEndGame(none, ""))
			{
				EndGame(none, "");
			}
		}
	}
	return;
}

//------------------------------------------------------------------
// EndGame
//	
//------------------------------------------------------------------
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;
	local R6IOBomb ioBomb;
	local bool bBombExploded;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
	bBombExploded = false;
	// End:0x51
	foreach __NFUN_304__(Class'R6Engine.R6IOBomb', ioBomb)
	{
		// End:0x50
		if(ioBomb.m_bExploded)
		{
			bBombExploded = true;
			// End:0x51
			break;
		}		
	}	
	// End:0xF2
	if(bBombExploded)
	{
		// End:0x8A
		if(bShowLog)
		{
			__NFUN_231__("** Game : bravo win: bomb exploded");
		}
		BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
		BroadcastMissionObjMsg(ioBomb.GetMissionObjLocFile(), "", "BombHasDetonated", none, int(GetGameMsgLifeTime()));
		AddTeamWonRound(c_iBravoTeam);		
	}
	else
	{
		// End:0x14E
		if(m_objDeathmatch.m_bFailed)
		{
			// End:0x126
			if(bShowLog)
			{
				__NFUN_231__("** Game : it's a draw");
			}
			BroadcastGameMsg("", "", "RoundIsADraw", m_sndRoundIsADraw, int(GetGameMsgLifeTime()));			
		}
		else
		{
			// End:0x2A2
			if(m_objDeathmatch.m_bCompleted)
			{
				// End:0x202
				if(__NFUN_154__(m_objDeathmatch.m_iWinningTeam, 2))
				{
					// End:0x1A2
					if(bShowLog)
					{
						__NFUN_231__("** Game : alpha eleminated bravo");
					}
					BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
					BroadcastMissionObjMsg("", "", "GreenNeutralizedRed", none, int(GetGameMsgLifeTime()));
					AddTeamWonRound(c_iAlphaTeam);					
				}
				else
				{
					// End:0x29F
					if(__NFUN_154__(m_objDeathmatch.m_iWinningTeam, 3))
					{
						// End:0x244
						if(bShowLog)
						{
							__NFUN_231__("** Game : bravo eleminated alpha");
						}
						BroadcastGameMsg("", "", "RedTeamWonRound", m_sndRedTeamWonRound, int(GetGameMsgLifeTime()));
						BroadcastMissionObjMsg("", "", "RedNeutralizedGreen", none, int(GetGameMsgLifeTime()));
						AddTeamWonRound(c_iBravoTeam);
					}
				}				
			}
			else
			{
				// End:0x2D8
				if(bShowLog)
				{
					__NFUN_231__("** Game : alpha prevented bomb detonation");
				}
				BroadcastGameMsg("", "", "GreenTeamWonRound", m_sndGreenTeamWonRound, int(GetGameMsgLifeTime()));
				BroadcastMissionObjMsg("", "", "NoBombsDetonated", none, int(GetGameMsgLifeTime()));
				AddTeamWonRound(c_iAlphaTeam);
			}
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

defaultproperties
{
	m_iUbiComGameMode=3
	m_szGameTypeFlag="RGM_BombAdvMode"
}
