/*=============================================================================
	R6PlayerController.cpp
	AR6PlayerController — player controller with voice priority, reticule,
	circumtstantial action, and net replication.
=============================================================================*/

#include "R6EnginePrivate.h"

// External engine globals
extern ENGINE_API UEngine* g_pEngine;

IMPLEMENT_CLASS(AR6PlayerController)

IMPLEMENT_FUNCTION(AR6PlayerController, -1, execDebugFunction)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execFindPlayer)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execGetLocStringWithActionKey)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execLocalizeTraining)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execPlayVoicesPriority)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateCircumstantialAction)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateReticule)
IMPLEMENT_FUNCTION(AR6PlayerController, -1, execUpdateSpectatorReticule)

// Statics used by AR6PlayerController PreNetReceive/PostNetReceive.
static BYTE GR6PlayerController_OldTeamByte;

// --- AR6PlayerController ---

void AR6PlayerController::Destroy()
{
	guard(AR6PlayerController::Destroy);
	while (m_PlayVoicesPriority.Num() > 0)
	{
		INT Ptr = m_PlayVoicesPriority(0).Ptr;
		for (INT i = 0; i < m_PlayVoicesPriority.Num(); i++)
		{
			if (m_PlayVoicesPriority(i).Ptr == Ptr)
			{
				m_PlayVoicesPriority.Remove(i, 1);
				i--;
			}
		}
		GMalloc->Free((void*)Ptr);
	}
	AActor::Destroy();
	unguard;
}

FString AR6PlayerController::GetLocKeyNameByActionKey(TCHAR const *)
{
	return TEXT("");
}

AActor * AR6PlayerController::GetTeamManager()
{
	return m_TeamManager;
}

INT AR6PlayerController::PlayPriority(INT)
{
	return 0;
}

void AR6PlayerController::PlayVoicesPriority()
{
}

void AR6PlayerController::PostNetReceive()
{
	guard(AR6PlayerController::PostNetReceive);
	if (GR6PlayerController_OldTeamByte != ((BYTE*)_NativeData)[10])
		eventPlayerTeamSelectionReceived();
	APlayerController::PostNetReceive();
	unguard;
}

void AR6PlayerController::PreNetReceive()
{
	guard(AR6PlayerController::PreNetReceive);
	GR6PlayerController_OldTeamByte = ((BYTE*)_NativeData)[10];
	APlayerController::PreNetReceive();
	unguard;
}

AActor * AR6PlayerController::SelectActorForSound(AR6SoundReplicationInfo * SoundRepInfo)
{
	if (!SoundRepInfo)
	{
		SoundRepInfo = (AR6SoundReplicationInfo*)Pawn;
		if (!SoundRepInfo)
			return this;
	}
	return (AActor*)SoundRepInfo;
}

void AR6PlayerController::StopAndRemoveVoices(INT &)
{
}

INT AR6PlayerController::Tick(FLOAT DeltaTime, enum ELevelTick TickType)
{
	guard(AR6PlayerController::Tick);
	if (*(INT*)((BYTE*)g_pEngine + 0x48) != 0)
	{
		PlayVoicesPriority();
	}
	return APlayerController::Tick(DeltaTime, TickType);
	unguard;
}

void AR6PlayerController::UpdateCircumstantialAction()
{
}

void AR6PlayerController::UpdateReticule(FLOAT)
{
}

void AR6PlayerController::UpdateReticuleIdentification(AActor *)
{
}

void AR6PlayerController::UpdateSpectatorReticule()
{
}

void AR6PlayerController::eventClientNotifySendMatchResults()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendMatchResults), NULL);
}

void AR6PlayerController::eventClientNotifySendStartMatch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendStartMatch), NULL);
}

void AR6PlayerController::eventClientPlayVoices(AR6SoundReplicationInfo * A, USound * B, BYTE C, INT D, DWORD E, FLOAT F)
{
	struct { 
		AR6SoundReplicationInfo * A;
		USound * B;
		BYTE C;
		INT D;
		DWORD E;
		FLOAT F;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	Parms.E = E;
	Parms.F = F;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientPlayVoices), &Parms);
}

void AR6PlayerController::eventClientUpdateLadderStat(FString const & A, INT B, INT C, FLOAT D)
{
	struct { 
		FString A;
		INT B;
		INT C;
		FLOAT D;
	} Parms;
	Parms.A = A;
	Parms.B = B;
	Parms.C = C;
	Parms.D = D;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientUpdateLadderStat), &Parms);
}

void AR6PlayerController::eventClientVoteSessionAbort(FString const & A)
{
	struct { FString A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientVoteSessionAbort), &Parms);
}

FLOAT AR6PlayerController::eventGetZoomMultiplyFactor(FLOAT A)
{
	struct {
		FLOAT A;
		FLOAT ReturnValue;
	} Parms;
	Parms.ReturnValue = 0.f;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_GetZoomMultiplyFactor), &Parms);
	return Parms.ReturnValue;
}

void AR6PlayerController::eventPlayerTeamSelectionReceived()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayerTeamSelectionReceived), NULL);
}

void AR6PlayerController::eventPostRender(UCanvas * A)
{
	struct { UCanvas * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PostRender), &Parms);
}

void AR6PlayerController::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

void AR6PlayerController::execDebugFunction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

void AR6PlayerController::execFindPlayer(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(inPlayerIdent);
	P_GET_UBOOL(bIsIdInt);
	P_FINISH;
	*(UObject**)Result = NULL;
}

void AR6PlayerController::execGetLocStringWithActionKey(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(szText);
	P_GET_STR(szActionKey);
	P_FINISH;
	*(FString*)Result = TEXT("");
}

void AR6PlayerController::execLocalizeTraining(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(SectionName);
	P_GET_STR(KeyName);
	P_GET_STR(PackageName);
	P_GET_INT(iBox);
	P_GET_INT(iParagraph);
	P_FINISH;
	*(FString*)Result = TEXT("");
}

void AR6PlayerController::execPlayVoicesPriority(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6SoundReplicationInfo, aAudioRepInfo);
	P_GET_OBJECT(USound, sndPlayVoice);
	P_GET_BYTE(eSlotUse);
	P_GET_INT(iPriority);
	P_GET_UBOOL(bWaitToFinishSound);
	P_GET_FLOAT(fTime);
	P_FINISH;
	// TODO: manages m_PlayVoicesPriority list, allocates FstSoundPriorityPtr,
	// routes through SelectActorForSound and per-slot stop/play logic (see Ghidra)
}

void AR6PlayerController::execUpdateCircumstantialAction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateCircumstantialAction();
}

void AR6PlayerController::execUpdateReticule(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fDeltaTime);
	P_FINISH;
	UpdateReticule(fDeltaTime);
}

void AR6PlayerController::execUpdateSpectatorReticule(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateSpectatorReticule();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
