//=============================================================================
// R6LoneWolfGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6LoneWolfGame.uc : Lone wolf game mode
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/12 * Created by S�bastien Lussier
//=============================================================================
class R6LoneWolfGame extends R6GameInfo
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var Sound m_sndTeamWipedOut;

function InitObjectives()
{
	local int Index;
	local R6MObjNeutralizeTerrorist missionObjTerro;
	local R6MObjGroupMission groupMission;
	local R6MObjGoToExtraction missionObjGotoExtraction;
	local R6Rainbow aRainbow;

	m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjGroupMission';
	groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[Index]);
	groupMission.m_bIfCompletedMissionIsSuccessfull = true;
	groupMission.m_szDescription = "Get to the extraction zone or neutralize all terrorist";
	groupMission.m_szDescriptionInMenu = "GetToExtractionZone";
	groupMission.m_aSubMissionObjectives[Index] = new (none) Class'R6Game.R6MObjNeutralizeTerrorist';
	groupMission.m_aSubMissionObjectives[Index].m_bIfCompletedMissionIsSuccessfull = true;
	missionObjTerro = R6MObjNeutralizeTerrorist(groupMission.m_aSubMissionObjectives[Index]);
	missionObjTerro.m_iNeutralizePercentage = 100;
	missionObjTerro.m_bVisibleInMenu = false;
	missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized";
	__NFUN_165__(Index);
	missionObjGotoExtraction = new (none) Class'R6Game.R6MObjGoToExtraction';
	groupMission.m_aSubMissionObjectives[Index] = missionObjGotoExtraction;
	groupMission.m_aSubMissionObjectives[Index].m_bIfCompletedMissionIsSuccessfull = true;
	missionObjGotoExtraction.m_sndSoundFailure = m_sndTeamWipedOut;
	missionObjGotoExtraction.m_bVisibleInMenu = false;
	// End:0x205
	foreach __NFUN_313__(Class'R6Engine.R6Rainbow', aRainbow)
	{
		missionObjGotoExtraction.SetPawnToExtract(aRainbow);
		// End:0x205
		break;		
	}	
	__NFUN_165__(Index);
	super.InitObjectives();
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
	// End:0x74
	if(__NFUN_154__(int(m_missionMgr.m_eMissionObjectiveStatus), int(1)))
	{
		BroadcastMissionObjMsg("", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndMissionComplete);		
	}
	else
	{
		obj = m_missionMgr.GetMObjFailed();
		BroadcastMissionObjMsg("", "", "MissionFailed");
		// End:0xEF
		if(__NFUN_119__(obj, none))
		{
			BroadcastMissionObjMsg(Level.GetMissionObjLocFile(obj), "", obj.GetDescriptionFailure(), obj.GetSoundFailure(), int(GetGameMsgLifeTime()));
		}
	}
	super.EndGame(Winner, Reason);
	return;
}

defaultproperties
{
	m_sndTeamWipedOut=Sound'Voices_Control_MissionFailed.Play_TeamWipedOut'
	m_iMaxOperatives=1
	m_szDefaultActionPlan="_LONE_ACTION"
	m_szGameTypeFlag="RGM_LoneWolfMode"
}
