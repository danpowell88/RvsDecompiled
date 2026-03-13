/*=============================================================================
	R6GameManager.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6GameManager)

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

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
