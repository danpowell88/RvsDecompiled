//=============================================================================
// R6MObjDeathmatch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MObjDeathmatch.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//
// success: if there's one pawn alive or one team
//
//=============================================================================
class R6MObjDeathmatch extends R6MissionObjectiveBase
	editinlinenew
    hidecategories(Object);

var int m_iWinningTeam;  // -1 no winning team
var int m_aLivingPlayerInTeam[48];  // must be bigger than 32...
var bool m_bTeamDeathmatch;
var PlayerController m_winnerCtrl;  // in deathmatch

function Reset()
{
	super.Reset();
	m_iWinningTeam = default.m_iWinningTeam;
	m_winnerCtrl = none;
	ResetLivingPlayerInTeam();
	return;
}

//------------------------------------------------------------------
// ResetLivingPlayer
//	
//------------------------------------------------------------------
function ResetLivingPlayerInTeam()
{
	local int i;

	i = 0;
	J0x07:

	// End:0x2A [Loop If]
	if((i < 48))
	{
		m_aLivingPlayerInTeam[i] = 0;
		(++i);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

//------------------------------------------------------------------
// GetWinningTeam: look the last team alive
//	return -1 is none
//------------------------------------------------------------------
function int GetWinningTeam()
{
	local int i, iPotentialWinner, iNbTeamAlive;

	// End:0x32
	if((R6GameInfo(m_mgr.Level.Game).m_bCompilingStats == false))
	{
		return -1;
	}
	i = 0;
	J0x39:

	// End:0x72 [Loop If]
	if((i < 48))
	{
		// End:0x68
		if((m_aLivingPlayerInTeam[i] != 0))
		{
			iPotentialWinner = i;
			(iNbTeamAlive++);
		}
		(++i);
		// [Loop Continue]
		goto J0x39;
	}
	// End:0x83
	if((iNbTeamAlive == 1))
	{
		return iPotentialWinner;
	}
	return -1;
	return;
}

//------------------------------------------------------------------
// PawnKilled
//	
//------------------------------------------------------------------
function PawnKilled(Pawn killedPawn)
{
	local R6Rainbow pPawn;
	local int aPlayerAliveInTeam[2], iNbAlive;

	ResetLivingPlayerInTeam();
	// End:0x21E
	foreach m_mgr.DynamicActors(Class'R6Engine.R6Rainbow', pPawn)
	{
		// End:0x14E
		if(pPawn.IsAlive())
		{
			(++iNbAlive);
			// End:0x6C
			if(m_bTeamDeathmatch)
			{
				// End:0x6C
				if((pPawn.m_iTeam < 48))
				{
					(++m_aLivingPlayerInTeam[pPawn.m_iTeam]);
				}
			}
			// End:0x132
			if(m_bShowLog)
			{
				// End:0xEE
				if((PlayerController(pPawn.Controller).PlayerReplicationInfo != none))
				{
					logX(((PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName $ " is alive in teamID") $ string(pPawn.m_iTeam)));					
				}
				else
				{
					logX(((string(PlayerController(pPawn.Controller)) $ " is alive in teamID") $ string(pPawn.m_iTeam)));
				}
			}
			m_winnerCtrl = PlayerController(pPawn.Controller);			
		}
		else
		{
			// End:0x1DA
			if(m_bShowLog)
			{
				// End:0x1B3
				if((PlayerController(pPawn.Controller).PlayerReplicationInfo != none))
				{
					logX((PlayerController(pPawn.Controller).PlayerReplicationInfo.PlayerName $ " is dead"));					
				}
				else
				{
					logX((string(PlayerController(pPawn.Controller)) $ " is dead"));
				}
			}
		}
		// End:0x21D
		if((!m_bTeamDeathmatch))
		{
			// End:0x21D
			if((iNbAlive > 1))
			{
				// End:0x21A
				if(m_bShowLog)
				{
					logX("more than 1 player alive ");
				}
				// End:0x21E
				break;
			}
		}		
	}	
	// End:0x26D
	if((iNbAlive == 0))
	{
		// End:0x254
		if(m_bShowLog)
		{
			logX("failed: zero man standing");
		}
		R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
		return;
	}
	// End:0x30B
	if(m_bTeamDeathmatch)
	{
		m_iWinningTeam = GetWinningTeam();
		// End:0x2EA
		if((m_iWinningTeam != -1))
		{
			// End:0x2D0
			if(m_bShowLog)
			{
				logX(("completed $ last team standing teamID="));
			}
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);			
		}
		else
		{
			// End:0x308
			if(m_bShowLog)
			{
				logX("no winner yet");
			}
		}		
	}
	else
	{
		// End:0x35C
		if((iNbAlive == 1))
		{
			// End:0x342
			if(m_bShowLog)
			{
				logX("completed, one man standing");
			}
			R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);			
		}
		else
		{
			// End:0x37A
			if(m_bShowLog)
			{
				logX("no winner yet");
			}
			m_winnerCtrl = none;
		}
	}
	return;
}

defaultproperties
{
	m_iWinningTeam=-1
	m_bIfCompletedMissionIsSuccessfull=true
	m_bIfFailedMissionIsAborted=true
	m_szDescription="Deathmatch: eleminate enemies"
}
