//=============================================================================
// R6TerroristHuntGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6TerroristHuntGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/19 * Created by Aristomenis Kolokathis Co-Op version
//=============================================================================
class R6TerroristHuntGame extends R6CoOpMode
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local R6MObjNeutralizeTerrorist missionObjTerro;

	m_missionMgr.m_aMissionObjectives[0] = new (none) Class'R6Game.R6MObjNeutralizeTerrorist';
	m_missionMgr.m_aMissionObjectives[0].m_bIfCompletedMissionIsSuccessfull = true;
	missionObjTerro = R6MObjNeutralizeTerrorist(m_missionMgr.m_aMissionObjectives[0]);
	missionObjTerro.m_iNeutralizePercentage = 100;
	missionObjTerro.m_bVisibleInMenu = true;
	missionObjTerro.m_szFeedbackOnCompletion = "AllTerroristHaveBeenNeutralized";
	super(R6MultiPlayerGameInfo).InitObjectives();
	return;
}

defaultproperties
{
	m_szDefaultActionPlan="_TERRORIST_ACTION"
	m_szGameTypeFlag="RGM_TerroristHuntMode"
}
