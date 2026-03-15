//=============================================================================
// R6CoOpMode - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CoOpMode.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CoOpMode extends R6MultiPlayerGameInfo
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var bool bTerroristLeft;
var bool bRainbowLeft;

// NEW IN 1.60
event InitGame(string Options, out string Error)
{
	super(R6GameInfo).InitGame(Options, Error);
	MaxPlayers = Min(8, MaxPlayers);
	return;
}

function int GetRainbowTeamColourIndex(int eTeamName)
{
	return 1;
	return;
}

function int GetSpawnPointNum(string Options)
{
	return 0;
	return;
}

function SetPawnTeamFriendlies(Pawn aPawn)
{
	SetDefaultTeamFriendlies(aPawn);
	return;
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame(PlayerReplicationInfo Winner, string Reason)
{
	local R6GameReplicationInfo gameRepInfo;
	local R6MissionObjectiveBase obj;

	// End:0x0B
	if(m_bGameOver)
	{
		return;
	}
	gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
	// End:0x7C
	if((int(m_missionMgr.m_eMissionObjectiveStatus) == int(1)))
	{
		BroadcastMissionObjMsg("", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndMissionComplete, int(GetGameMsgLifeTime()));		
	}
	else
	{
		obj = m_missionMgr.GetMObjFailed();
		BroadcastMissionObjMsg("", "", "MissionFailed", none, int(GetGameMsgLifeTime()));
		// End:0x100
		if((obj != none))
		{
			BroadcastMissionObjMsg(Level.GetMissionObjLocFile(obj), "", obj.GetDescriptionFailure(), obj.GetSoundFailure(), int(GetGameMsgLifeTime()));
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

function PlayerReadySelected(PlayerController _Controller)
{
	local Controller _aController;
	local int iHumanCount;

	// End:0x1F
	if(((R6PlayerController(_Controller) == none) || IsInState('InBetweenRoundMenu')))
	{
		return;
	}
	_aController = Level.ControllerList;
	J0x33:

	// End:0x8C [Loop If]
	if((_aController != none))
	{
		// End:0x75
		if(((R6PlayerController(_aController) != none) && (int(R6PlayerController(_aController).m_TeamSelection) == int(2))))
		{
			(iHumanCount++);
		}
		_aController = _aController.nextController;
		// [Loop Continue]
		goto J0x33;
	}
	// End:0xB8
	if(((!R6PlayerController(_Controller).IsPlayerPassiveSpectator()) && (iHumanCount <= 1)))
	{
		ResetRound();
	}
	return;
}

