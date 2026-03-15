//=============================================================================
// R6HostageRescueGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6HostageRescueGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Aristomenis Kolokathis
//=============================================================================
class R6HostageRescueGame extends R6CoOpMode
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function InitObjectives()
{
	local int Index;
	local R6MObjNeutralizeTerrorist missionObjTerro;
	local R6MObjGroupMission groupMission;
	local R6MObjRescueHostage objRescueHostage;

	m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjGroupMission';
	groupMission = R6MObjGroupMission(m_missionMgr.m_aMissionObjectives[Index]);
	groupMission.m_bIfCompletedMissionIsSuccessfull = true;
	groupMission.m_szDescription = "Rescue all hostage to the extraction zone or neutralize all terrorist";
	missionObjTerro = new (none) Class'R6Game.R6MObjNeutralizeTerrorist';
	groupMission.m_bIfCompletedMissionIsSuccessfull = true;
	missionObjTerro.m_bVisibleInMenu = false;
	missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized";
	groupMission.m_aSubMissionObjectives[Index] = missionObjTerro;
	(Index++);
	objRescueHostage = new (none) Class'R6Game.R6MObjRescueHostage';
	objRescueHostage.m_bIfCompletedMissionIsSuccessfull = true;
	objRescueHostage.m_bVisibleInMenu = true;
	objRescueHostage.m_szFeedbackOnCompletion = "AllHostagesHaveBeenRescued";
	groupMission.m_aSubMissionObjectives[Index] = objRescueHostage;
	(Index++);
	groupMission.m_szDescriptionInMenu = objRescueHostage.GetDescriptionBasedOnNbOfHostages(Level);
	super(R6MultiPlayerGameInfo).InitObjectives();
	return;
}

defaultproperties
{
	m_szDefaultActionPlan="_HOSTAGE_ACTION"
	m_szGameTypeFlag="RGM_HostageRescueMode"
}
