/*=============================================================================
	R6Game.cpp: R6Game package.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_PACKAGE(R6Game)

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6GAME_API FName R6GAME_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

IMPLEMENT_CLASS(AR6ActionPoint)
IMPLEMENT_CLASS(AR6GameInfo)
IMPLEMENT_CLASS(AR6HUD)
IMPLEMENT_CLASS(AR6InstructionSoundVolume)
IMPLEMENT_CLASS(AR6MultiPlayerGameInfo)
IMPLEMENT_CLASS(AR6PlanningCtrl)
IMPLEMENT_CLASS(AR6SoundVolume)
IMPLEMENT_CLASS(AR6WaterVolume)
IMPLEMENT_CLASS(UR6FileManagerCampaign)
IMPLEMENT_CLASS(UR6FileManagerPlanning)
IMPLEMENT_CLASS(UR6GameManager)
IMPLEMENT_CLASS(UR6MissionRoster)
IMPLEMENT_CLASS(UR6Operative)
IMPLEMENT_CLASS(UR6PlanningInfo)
IMPLEMENT_CLASS(UR6PlayerCampaign)
IMPLEMENT_CLASS(UR6PlayerCustomMission)

IMPLEMENT_FUNCTION(AR6GameInfo, -1, execGetSystemUserName)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execInitScoreSubmission)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execLogoutUpdatePlayersCtrlInfo)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execNativeLogout)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSetController)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionNotifySendStartMatch)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundFinish)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundStart)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionUpdateLadderStat)
IMPLEMENT_FUNCTION(AR6HUD, -1, execDrawNativeHUD)
IMPLEMENT_FUNCTION(AR6HUD, -1, execHudStep)
IMPLEMENT_FUNCTION(AR6InstructionSoundVolume, -1, execUseSound)
IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execGetClickResult)
IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execGetXYPoint)
IMPLEMENT_FUNCTION(AR6PlanningCtrl, -1, execPlanningTrace)
IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execLoadCampaign)
IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execSaveCampaign)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execGetNumberOfFiles)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execLoadPlanning)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execSavePlanning)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execAddToTeam)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execDeletePoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execFindPathToNextPoint)
IMPLEMENT_FUNCTION(UR6PlanningInfo, -1, execInsertToTeam)

/*-----------------------------------------------------------------------------
	Method stubs.
-----------------------------------------------------------------------------*/

// --- AR6ActionPoint ---

void AR6ActionPoint::SetRotationToward(FVector)
{
}

void AR6ActionPoint::TransferFile(FArchive &)
{
}

// --- AR6GameInfo ---

void AR6GameInfo::AbortScoreSubmission()
{
}

void AR6GameInfo::InitGameInfoGameService()
{
}

void AR6GameInfo::MasterServerManager()
{
}

void AR6GameInfo::PostBeginPlay()
{
}

void AR6GameInfo::execGetSystemUserName(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execInitScoreSubmission(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execLogoutUpdatePlayersCtrlInfo(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execNativeLogout(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execSetController(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execSubmissionNotifySendStartMatch(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execSubmissionSrvRoundFinish(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execSubmissionSrvRoundStart(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6GameInfo::execSubmissionUpdateLadderStat(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6HUD ---

void AR6HUD::Destroy()
{
}

void AR6HUD::DisplayOtherTeamInfo(FCanvasUtil &, UCanvas *, INT, AR6RainbowTeam *, FColor &, INT)
{
}

void AR6HUD::DrawCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
}

void AR6HUD::DrawInGameMap(FCameraSceneNode *, UViewport *)
{
}

void AR6HUD::DrawRadar(FCameraSceneNode *, UViewport *)
{
}

void AR6HUD::DrawSingleCharacterInfo(AR6Rainbow *, FLOAT, FLOAT, FColor &, FCanvasUtil *, UCanvas *)
{
}

void AR6HUD::Serialize(FArchive &)
{
}

void AR6HUD::Spawned()
{
}

void AR6HUD::UpdateHUDColors(FColor)
{
}

void AR6HUD::execDrawNativeHUD(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6HUD::execHudStep(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6InstructionSoundVolume ---

void AR6InstructionSoundVolume::execUseSound(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- AR6PlanningCtrl ---

void AR6PlanningCtrl::execGetClickResult(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlanningCtrl::execGetXYPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlanningCtrl::execPlanningTrace(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- UR6FileManagerCampaign ---

void UR6FileManagerCampaign::execLoadCampaign(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6FileManagerCampaign::execSaveCampaign(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- UR6FileManagerPlanning ---

void UR6FileManagerPlanning::execGetNumberOfFiles(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6FileManagerPlanning::execLoadPlanning(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6FileManagerPlanning::execSavePlanning(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

// --- UR6GameManager ---

void UR6GameManager::ClientLeaveServer()
{
}

void UR6GameManager::ConnectionInterrupted(INT)
{
}

void UR6GameManager::DoConsoleCommand(FString, UConsole *)
{
}

void UR6GameManager::GSClientManager(UConsole *)
{
}

void UR6GameManager::GameServiceTick(UConsole *)
{
}

INT UR6GameManager::GetGSCreateUbiServer()
{
	return 0;
}

void UR6GameManager::InitializeGSClient()
{
}

void UR6GameManager::InitializeGameService(UConsole *)
{
}

void UR6GameManager::LaunchListenSrv(FString, FString)
{
}

void UR6GameManager::MSClientManager(UConsole *)
{
}

void UR6GameManager::MinimizeAndPauseMusic(UConsole *)
{
}

void UR6GameManager::SetGSCreateUbiServer(INT)
{
}

void UR6GameManager::StartJoinServer(FString, FString, INT)
{
}

INT UR6GameManager::StartLogInProcedure()
{
	return 0;
}

void UR6GameManager::StartPreJoinProcedure(INT)
{
}

void UR6GameManager::UnInitialize()
{
}

// --- UR6MissionRoster ---

void UR6MissionRoster::TransferFile(FArchive &)
{
}

// --- UR6Operative ---

void UR6Operative::TransferFile(FArchive &)
{
}

// --- UR6PlanningInfo ---

void UR6PlanningInfo::AddPoint(AActor *)
{
}

AActor * UR6PlanningInfo::GetTeamLeader()
{
	return NULL;
}

INT UR6PlanningInfo::NoStairsBetweenPoints(AActor *)
{
	return 0;
}

void UR6PlanningInfo::TransferFile(FArchive &)
{
}

void UR6PlanningInfo::execAddToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execDeletePoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execFindPathToNextPoint(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6PlanningInfo::execInsertToTeam(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

