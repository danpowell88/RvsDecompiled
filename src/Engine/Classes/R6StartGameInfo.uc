// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6StartGameInfo extends Actor
    native;

// --- Variables ---
var string m_MapName;
var int m_DifficultyLevel;
var int m_CurrentMenu;
var string m_GameMode;
// Once the map is in memory, start directly whithout planning
var bool m_SkipPlanningPhase;
// Once the map is in memory, load backup/backup.pln
var bool m_ReloadPlanning;
// when loading backup plan, do not load operatives
var bool m_ReloadActionPointOnly;
// This is for terro hunt
var int m_iNbTerro;
var Object m_CurrentMission;
var config R6TeamStartInfo m_TeamInfo[3];
var bool m_bIsPlaying;
var int m_iTeamStart;

// --- Functions ---
function Save() {}
function Load() {}

defaultproperties
{
}
