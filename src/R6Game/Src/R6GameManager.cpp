/*=============================================================================
	R6GameManager.cpp
	UR6GameManager, UR6MissionRoster, UR6Operative, UR6PlayerCampaign,
	UR6PlayerCustomMission, UR6FileManagerCampaign, UR6FileManagerPlanning.
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6FileManagerCampaign)
IMPLEMENT_CLASS(UR6FileManagerPlanning)
IMPLEMENT_CLASS(UR6GameManager)
IMPLEMENT_CLASS(UR6MissionRoster)
IMPLEMENT_CLASS(UR6Operative)
IMPLEMENT_CLASS(UR6PlayerCampaign)
IMPLEMENT_CLASS(UR6PlayerCustomMission)

IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execLoadCampaign)
IMPLEMENT_FUNCTION(UR6FileManagerCampaign, -1, execSaveCampaign)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execGetNumberOfFiles)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execLoadPlanning)
IMPLEMENT_FUNCTION(UR6FileManagerPlanning, -1, execSavePlanning)

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

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
