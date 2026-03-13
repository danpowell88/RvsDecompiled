/*=============================================================================
	R6GameService.cpp: R6GameService package init and UR6ServerList.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "R6GameServicePrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6GameService)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6GAMESERVICE_API FName R6GAMESERVICE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameServiceClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	UR6LanServers — no methods, just registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UR6LanServers)

/*-----------------------------------------------------------------------------
	UR6ServerList — server list base.
-----------------------------------------------------------------------------*/

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

// --- UR6ServerList ---

void UR6ServerList::FillSvrContainer()
{
}

INT UR6ServerList::GetGroupID()
{
	return 0;
}

INT UR6ServerList::GetLobbyID()
{
	return 0;
}

void UR6ServerList::InitFavorites()
{
}

void UR6ServerList::ResetSvrContainer()
{
}

void UR6ServerList::SetOwnSvrPort(INT)
{
}

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

void UR6ServerList::execGetDisplayListSize(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeGetMaxPlayers(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeGetMilliSeconds(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeGetOwnSvrPort(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeGetPingTime(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeGetPingTimeOut(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeInitFavorites(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execNativeUpdateFavorites(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void UR6ServerList::execSortServers(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

