/*=============================================================================
	R6GameInfo.cpp
	AR6GameInfo, AR6MultiPlayerGameInfo — R6 game info and score submission.
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6GameInfo)
IMPLEMENT_CLASS(AR6MultiPlayerGameInfo)

IMPLEMENT_FUNCTION(AR6GameInfo, -1, execGetSystemUserName)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execInitScoreSubmission)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execLogoutUpdatePlayersCtrlInfo)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execNativeLogout)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSetController)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionNotifySendStartMatch)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundFinish)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionSrvRoundStart)
IMPLEMENT_FUNCTION(AR6GameInfo, -1, execSubmissionUpdateLadderStat)

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

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
