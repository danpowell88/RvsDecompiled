//=============================================================================
// R6ReconGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ReconGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/14 * Created by Aristomenis Kolokathis
//=============================================================================
class R6ReconGame extends R6CoOpMode
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function InitObjectives()
{
	local int Index;
	local R6MObjNeutralizeTerrorist missionObjTerro;
	local R6MObjGroupMission groupMission;
	local R6MObjRecon reconObj;

	m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjGroupMission';
	groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[Index]);
	groupMission.m_bIfCompletedMissionIsSuccessfull = true;
	groupMission.m_szDescription = "Go to extraction zone and don't get caugh";
	groupMission.m_szDescriptionInMenu = "GotoExtractionInReconMode";
	groupMission.m_aSubMissionObjectives[Index] = new (none) Class'R6Game.R6MObjRecon';
	groupMission.m_aSubMissionObjectives[Index].m_bIfCompletedMissionIsSuccessfull = true;
	reconObj = R6MObjRecon(groupMission.m_aSubMissionObjectives[Index]);
	reconObj.m_bVisibleInMenu = false;
	(Index++);
	groupMission.m_aSubMissionObjectives[Index] = new (none) Class'R6Game.R6MObjCompleteAllAndGoToExtraction';
	groupMission.m_aSubMissionObjectives[Index].m_bIfCompletedMissionIsSuccessfull = true;
	missionObjTerro.m_bVisibleInMenu = false;
	(Index++);
	super(R6MultiPlayerGameInfo).InitObjectives();
	return;
}

defaultproperties
{
	m_szGameTypeFlag="RGM_ReconMode"
}
