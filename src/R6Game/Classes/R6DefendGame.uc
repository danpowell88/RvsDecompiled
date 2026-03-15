//=============================================================================
// R6DefendGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DefendGame.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Aristomenis Kolokathis
//=============================================================================
class R6DefendGame extends R6CoOpMode
    config
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//------------------------------------------------------------------
// InitObjectives
//	
//------------------------------------------------------------------
function InitObjectives()
{
	local int Index;
	local R6MObjNeutralizeTerrorist missionObjTerro;
	local R6MObjRescueHostage misionObjVIP;
	local R6Hostage H, huntedPawn;
	local R6TerroristAI terroAI;

	m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjNeutralizeTerrorist';
	m_missionMgr.m_aMissionObjectives[Index].m_bIfCompletedMissionIsSuccessfull = true;
	missionObjTerro = R6MObjNeutralizeTerrorist(m_missionMgr.m_aMissionObjectives[Index]);
	missionObjTerro.m_iNeutralizePercentage = 100;
	missionObjTerro.m_bVisibleInMenu = true;
	missionObjTerro.m_szDescription = "Neutralize all terro and protect the VIP at all cost";
	missionObjTerro.m_szDescriptionInMenu = "NeutralizeTerroAndDefendVIP";
	(Index++);
	// End:0x1FF
	foreach DynamicActors(Class'R6Engine.R6Hostage', H)
	{
		m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjRescueHostage';
		misionObjVIP = R6MObjRescueHostage(m_missionMgr.m_aMissionObjectives[Index]);
		misionObjVIP.m_bIfFailedMissionIsAborted = true;
		misionObjVIP.m_bVisibleInMenu = false;
		misionObjVIP.m_iRescuePercentage = 100;
		misionObjVIP.m_depZone = H.m_DZone;
		// End:0x1EC
		if((huntedPawn != none))
		{
			Log(("Warning: there's more than one hostage in the game mode " $ string(self.Name)));
			// End:0x1FF
			break;
		}
		huntedPawn = H;
		(Index++);		
	}	
	// End:0x25F
	if(((huntedPawn == none) && m_missionMgr.m_bEnableCheckForErrors))
	{
		Log(("Warning: there is no hostage in the game mode " $ string(self.Name)));
	}
	m_missionMgr.m_aMissionObjectives[Index] = new (none) Class'R6Game.R6MObjAcceptableRainbowLosses';
	// End:0x2C1
	foreach DynamicActors(Class'R6Engine.R6TerroristAI', terroAI)
	{
		terroAI.m_huntedPawn = huntedPawn;
		R6Terrorist(terroAI.Pawn).m_eStrategy = 3;		
	}	
	Level.m_bUseDefaultMoralityRules = false;
	super(R6MultiPlayerGameInfo).InitObjectives();
	return;
}

//------------------------------------------------------------------
// SetPawnTeamFriendlies
//	
//------------------------------------------------------------------
function SetPawnTeamFriendlies(Pawn aPawn)
{
	super.SetPawnTeamFriendlies(aPawn);
	switch(aPawn.m_iTeam)
	{
		// End:0x39
		case 1:
			(aPawn.m_iEnemyTeams += GetTeamNumBit(0));
			// End:0x3C
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_szGameTypeFlag="RGM_DefendMode"
}
