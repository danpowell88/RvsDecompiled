/*=============================================================================
	R6ServerList.cpp
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_CLASS(UR6ServerList)

IMPLEMENT_FUNCTION(UR6ServerList, -1, execGetDisplayListSize)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeGetMaxPlayers)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeGetMilliSeconds)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeGetOwnSvrPort)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeGetPingTime)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeGetPingTimeOut)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeInitFavorites)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execNativeUpdateFavorites)
IMPLEMENT_FUNCTION(UR6ServerList, -1, execSortServers)

// Module-level globals used by UR6ServerList methods.
// Addresses from Ghidra; zero-initialized in original binary's .data section.
static INT GsGroupID  = 0; // DAT_10093b18 — GetGroupID()
static INT GsLobbyID  = 0; // DAT_10093b34 — GetLobbyID()

// --- UR6ServerList ---

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::FillSvrContainer()
{
	guard(UR6ServerList::FillSvrContainer);
	unguard;
}

IMPL_MATCH("R6GameService.dll", 0x125e0)
INT UR6ServerList::GetGroupID()
{
	// 0x125e0  54  ?GetGroupID@UR6ServerList@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsGroupID;
}

IMPL_MATCH("R6GameService.dll", 0x125d0)
INT UR6ServerList::GetLobbyID()
{
	// 0x125d0  55  ?GetLobbyID@UR6ServerList@@UAEHXZ — size 6 bytes, no SEH frame.
	return GsLobbyID;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::InitFavorites()
{
	guard(UR6ServerList::InitFavorites);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::ResetSvrContainer()
{
	guard(UR6ServerList::ResetSvrContainer);
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::SetOwnSvrPort(INT)
{
	guard(UR6ServerList::SetOwnSvrPort);
	unguard;
}

IMPL_APPROX("Reconstructed from context; delegates to UnrealScript event")
void UR6ServerList::eventGetLobbyAndGroupID(INT &iLobbyID, INT &iGroupID)
{
	struct {
		INT iLobbyID;
		INT iGroupID;
	} Parms;
	Parms.iLobbyID = iLobbyID;
	Parms.iGroupID = iGroupID;
	ProcessEvent(FindFunctionChecked(R6GAMESERVICE_GetLobbyAndGroupID), &Parms);
	iLobbyID = Parms.iLobbyID;
	iGroupID = Parms.iGroupID;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execGetDisplayListSize(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execGetDisplayListSize);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeGetMaxPlayers(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeGetMaxPlayers);
	P_FINISH;
	*(INT*)Result = 16;
	unguard;
}

IMPL_APPROX("Reconstructed from context; returns GetTickCount")
void UR6ServerList::execNativeGetMilliSeconds(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeGetMilliSeconds);
	P_FINISH;
	*(INT*)Result = (INT)GetTickCount();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeGetOwnSvrPort(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeGetOwnSvrPort);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeGetPingTime(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeGetPingTime);
	P_GET_STR(szServerIP);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeGetPingTimeOut(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeGetPingTimeOut);
	P_FINISH;
	*(INT*)Result = 1000;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeInitFavorites(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeInitFavorites);
	P_FINISH;
	InitFavorites();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execNativeUpdateFavorites(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execNativeUpdateFavorites);
	P_FINISH;
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UR6ServerList::execSortServers(FFrame& Stack, RESULT_DECL)
{
	guard(UR6ServerList::execSortServers);
	P_FINISH;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
