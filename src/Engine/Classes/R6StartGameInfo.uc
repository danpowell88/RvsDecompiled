//=============================================================================
// R6StartGameInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
/********************************************************************
	created:	2001/06/19
	filename: 	R6StartGameInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set in the menu are stored here before
                the game/mission is launched.
                Used only by the menu,
                Has no influence once the game is started
	
	Modification:

*********************************************************************/
class R6StartGameInfo extends Actor
    native
    config
    notplaceable;

var int m_DifficultyLevel;
var int m_CurrentMenu;
var int m_iNbTerro;  // This is for terro hunt
var int m_iTeamStart;
var bool m_SkipPlanningPhase;  // Once the map is in memory, start directly whithout planning
var bool m_ReloadPlanning;  // Once the map is in memory, load backup/backup.pln
var bool m_ReloadActionPointOnly;  // when loading backup plan, do not load operatives
var bool m_bIsPlaying;
var Object m_CurrentMission;
var config R6TeamStartInfo m_TeamInfo[3];
var string m_MapName;
var string m_GameMode;

function Save()
{
	return;
}

function Load()
{
	return;
}

defaultproperties
{
	m_iNbTerro=35
}
