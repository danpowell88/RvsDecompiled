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
	guard(AR6PlayerController::PlayVoicesPriority);

	if (m_PlayVoicesPriority.Num() > 0)
	{
		for (INT i = 0; i < m_PlayVoicesPriority.Num(); i++)
		{
			INT* Entry = (INT*)*(INT*)(*(INT*)((BYTE*)this + 0x900) + i * 4);

			// Entry[5] = bIsPlaying flag
			if (Entry[5] != 0)
			{
				AActor* SoundActor = SelectActorForSound((AR6SoundReplicationInfo*)Entry[0]);

				// Check if sound is still playing via audio subsystem vtable call
				INT iResult = (*(INT(__thiscall**)(AActor*, INT))
					(**(INT**)(*(INT*)g_pEngine + 0x48) + 0x8c))
					(SoundActor, Entry[1]);

				if (iResult == 0)
				{
					StopAndRemoveVoices(i);
				}
			}
		}

		if (m_PlayVoicesPriority.Num() > 0)
		{
			if (!PlayPriority(5))
			{
				if (!PlayPriority(10))
				{
					PlayPriority(15);
				}
			}
		}
	}

	unguard;
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

void AR6PlayerController::StopAndRemoveVoices(INT & Index)
{
	guard(AR6PlayerController::StopAndRemoveVoices);

	INT* Entry = (INT*)*(INT*)(*(INT*)((BYTE*)this + 0x900) + Index * 4);

	// If sound is playing, stop it via audio subsystem
	if (Entry[5] != 0)
	{
		AActor* SoundActor = SelectActorForSound((AR6SoundReplicationInfo*)Entry[0]);
		(*(void(__thiscall**)(AActor*, INT))
			(**(INT**)(*(INT*)g_pEngine + 0x48) + 0x100))
			(SoundActor, Entry[1]);
	}

	// Remove from the TArray and free the memory
	m_PlayVoicesPriority.Remove(Index, 1);
	GMalloc->Free(Entry);
	Index--;

	unguard;
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
	guard(AR6PlayerController::UpdateCircumstantialAction);

	// TODO: Extremely complex function (0x308c0, ~2000 bytes).
	// Queries the circumtstantial action system (m_CircumstantialAction at this+0x8b4):
	// 1. If Role==ROLE_Authority (this[0x2d]==4), clears action query state
	// 2. Fires a line trace from eye position along view direction (m_fCircumActionRange at this+0x848)
	// 3. Checks hit actor class hierarchy via IsA for various interactive/pawn types
	// 4. Extracts material info from hit (bone index, texture params) for reticule identification
	// 5. In capture-the-enemy mode, does secondary trace for pawn identification
	// 6. Calls eventR6QueryCircumstantialAction on the hit actor
	// 7. Updates reticule target position at (this+0x9bc, 0x9c0, 0x9c4)
	// Full implementation requires resolving PrivateStaticClass_exref comparisons,
	// FVector0_exref, and vtable dispatch patterns.

	unguard;
}

void AR6PlayerController::UpdateReticule(FLOAT DeltaTime)
{
	guard(AR6PlayerController::UpdateReticule);

	// TODO: Complex function (0x31010, ~1100 bytes).
	// Iterates all pawns in the level (XLevel->Actors at this+0x328+0x101c0),
	// checks if they are alive terrorists (type 0x2), gets bone positions via
	// USkeletalMeshInstance::GetBoneCoords for "R6 PonyTail1" bone,
	// projects them to screen via FUN_1002ff80, and finds the closest enemy
	// in screen-space within the reticule radius. Updates aim target info
	// at (this+0x8b0, 0x918, 0x91c, 0x920, 0x86c, 0x870).
	// When target changes, sets blend time at (this+0x87c) to 0.15f (0x3e19999a).
	// Smoothly interpolates reticule position using DeltaTime / blendTime.

	unguard;
}

void AR6PlayerController::UpdateReticuleIdentification(AActor * param_1)
{
	guard(AR6PlayerController::UpdateReticuleIdentification);

	FString InfoString;

	AR6EngineWeapon* Weapon = *(AR6EngineWeapon**)(*(INT*)((BYTE*)this + 0x8a8) + 0x4fc);

	DWORD bIdentify = 0;
	if (param_1 != NULL && (*(DWORD*)((BYTE*)param_1 + 0xa4) & 0x800) != 0 &&
		param_1 != *(AActor**)((BYTE*)this + 0x3d8))
	{
		bIdentify = param_1->eventGetReticuleInfo(*(APawn**)((BYTE*)this + 0x3d8), InfoString);
	}

	Weapon->eventSetIdentifyTarget(bIdentify, bIdentify, InfoString);

	unguard;
}

void AR6PlayerController::UpdateSpectatorReticule()
{
	guard(AR6PlayerController::UpdateSpectatorReticule);

	// TODO: Complex function (0x305f0, 656 bytes).
	// In spectator mode (Flags & 0x20000): uses own Rotation vector and Location.
	// Otherwise: uses ViewTarget's GetViewRotation and EyePosition.
	// Fires a line trace from eye to eye + viewDir * m_fCircumActionRange (this+0x848)
	// with trace flags 0x210bf. If hit actor has a Pawn owner, copies the pawn's
	// PlayerReplicationInfo->PlayerName (or Pawn's PlayerName at offset 0x630)
	// into (this+0xa68). Clears name to empty string if no valid target.

	unguard;
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
