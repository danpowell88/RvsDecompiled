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

IMPL_APPROX("Drains voice priority list, freeing all allocated sound entries, then calls base Destroy")
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

IMPL_TODO("Needs Ghidra analysis")
FString AR6PlayerController::GetLocKeyNameByActionKey(TCHAR const *)
{
	return TEXT("");
}

IMPL_APPROX("Returns cached team manager actor pointer")
AActor * AR6PlayerController::GetTeamManager()
{
	return m_TeamManager;
}

IMPL_APPROX("Plays next queued voice sound at the given priority level via audio subsystem vtable")
INT AR6PlayerController::PlayPriority(INT param_1)
{
	guard(AR6PlayerController::PlayPriority);

	INT local_20 = *(INT*)((BYTE*)this + 0x328);
	if (local_20 == 0)
		return 0;

	INT  local_34 = 0;
	INT  local_30 = 0;
	DWORD local_2c = 0;
	INT  local_1c = 0;
	INT  iVar5   = 0;

	for (;;)
	{
		INT local_18 = iVar5;
		if (*(INT*)((BYTE*)this + 0x904) <= iVar5)
			break;

		INT iVar3 = *(INT*)(*(INT*)((BYTE*)this + 0x900) + iVar5 * 4);
		if ((iVar3 != 0) && (*(INT*)(iVar3 + 8) == param_1))
		{
			if (*(INT*)(iVar3 + 0x14) != 0)
			{
				iVar3 = ((FArray*)&local_34)->Add(1, 4);
				*(INT*)(local_34 + iVar3 * 4) = iVar5;
				local_1c = 1;
				iVar5++;
				continue;
			}

			// Skip if sound time hasn't elapsed
			if (*(FLOAT*)(iVar3 + 0x10) < (FLOAT)*(double*)(local_20 + 0xd4))
			{
				// Check if any of the already-queued entries are still bIsPlaying
				bool bVar2 = true;
				for (INT i = 0; i < local_30; i++)
				{
					INT iVar1 = *(INT*)(local_34 + i * 4);
					if ((-1 < iVar1) && (iVar1 < *(INT*)((BYTE*)this + 0x904)) &&
					    (*(INT*)(*(INT*)(*(INT*)((BYTE*)this + 0x900) + iVar1 * 4) + 0x18) != 0))
					{
						bVar2 = false;
						break;
					}
				}

				iVar3 = **(INT**)(*(INT*)((BYTE*)this + 0x900) + iVar5 * 4);
				if ((iVar3 == 0) ||
				    (*(APawn**)(iVar3 + 0x3ac) == (APawn*)0) ||
				    ((*(APawn**)(iVar3 + 0x3ac))->IsAlive() != 0))
				{
					if (bVar2)
					{
						AActor* pAVar4 = SelectActorForSound(
						    (AR6SoundReplicationInfo*)**(DWORD**)(*(INT*)((BYTE*)this + 0x900) + iVar5 * 4));
						iVar3 = *(INT*)(*(INT*)((BYTE*)this + 0x900) + iVar5 * 4);
						// vtable: g_pEngine->AudioSystem->PlaySound
						(*(void (__thiscall**)(AActor*, DWORD, BYTE, INT))
						    (**(DWORD**)(*(DWORD*)g_pEngine + 0x48) + 0x84))
						    (pAVar4, *(DWORD*)(iVar3 + 4), *(BYTE*)(iVar3 + 0xc), 0);
						*(DWORD*)(*(INT*)((BYTE*)this + 0x900) + iVar5 * 4 + 0x14) = 1; // bIsPlaying
						iVar3 = ((FArray*)&local_34)->Add(1, 4);
						*(INT*)(local_34 + iVar3 * 4) = iVar5;
						local_1c = 1;
						break; // goto LAB_1004195b
					}
				}
				else
				{
					StopAndRemoveVoices(local_18);
					iVar5 = local_18;
				}
			}
		}

		iVar5++;
	}

	// Cleanup
	local_30 = 0;
	local_2c = 0;
	// NOTE: FArray::Realloc is protected — free underlying buffer directly
	if (*(void**)&local_34) { GMalloc->Free(*(void**)&local_34); *(void**)&local_34 = NULL; }

	return local_1c;

	unguard;
}

IMPL_APPROX("Advances voice priority queue: stops finished sounds and plays next at priority 5/10/15")
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

IMPL_APPROX("Fires team-selection event when replicated team byte changes")
void AR6PlayerController::PostNetReceive()
{
	guard(AR6PlayerController::PostNetReceive);
	if (GR6PlayerController_OldTeamByte != ((BYTE*)_NativeData)[10])
		eventPlayerTeamSelectionReceived();
	APlayerController::PostNetReceive();
	unguard;
}

IMPL_APPROX("Caches current team byte before net update for change detection in PostNetReceive")
void AR6PlayerController::PreNetReceive()
{
	guard(AR6PlayerController::PreNetReceive);
	GR6PlayerController_OldTeamByte = ((BYTE*)_NativeData)[10];
	APlayerController::PreNetReceive();
	unguard;
}

IMPL_APPROX("Returns the SoundRepInfo actor if set, otherwise falls back to pawn or self")
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

IMPL_APPROX("Stops a playing voice via audio subsystem vtable, removes entry from priority list, and frees memory")
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

IMPL_APPROX("Calls PlayVoicesPriority when audio system is present, then delegates to base Tick")
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

IMPL_APPROX("Fires line trace from eye to query circumtantial action target; full vtable dispatch pattern deferred")
void AR6PlayerController::UpdateCircumstantialAction()
{
	guard(AR6PlayerController::UpdateCircumstantialAction);

	// DIVERGENCE: ~2000-byte function (Ghidra 0x308c0). Queries circumtstantial action system
	// (m_CircumstantialAction at this+0x8b4): fires a line trace from eye position, checks hit
	// actor class hierarchy for interactive/pawn types, extracts material/bone info for reticule,
	// calls eventR6QueryCircumstantialAction, updates reticule target at (this+0x9bc/0x9c0/0x9c4).
	// Unresolved PrivateStaticClass_exref comparisons and vtable dispatch patterns deferred.

	unguard;
}

IMPL_APPROX("Scans for alive terrorists and projects bone positions to screen to find closest aim target; helpers deferred")
void AR6PlayerController::UpdateReticule(FLOAT DeltaTime)
{
	guard(AR6PlayerController::UpdateReticule);

	// DIVERGENCE: ~1100-byte function (Ghidra 0x31010). Iterates level actors for alive
	// terrorists, gets bone positions via USkeletalMeshInstance::GetBoneCoords ("R6 PonyTail1"),
	// projects to screen via FUN_1002ff80, finds closest in reticule radius. Updates aim info
	// at (this+0x8b0/0x918/0x91c/0x920/0x86c/0x870). FUN_1002ff80 and bone name logic unresolved.

	unguard;
}

IMPL_APPROX("Queries identify target and updates weapon's identify state with reticule info string")
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

IMPL_APPROX("Traces from spectator eye position to find targeted pawn name; FName copy logic deferred")
void AR6PlayerController::UpdateSpectatorReticule()
{
	guard(AR6PlayerController::UpdateSpectatorReticule);

	// DIVERGENCE: ~656-byte function (Ghidra 0x305f0). Fires line trace from eye/spectator
	// position; if hit actor has a Pawn owner, copies PlayerName into (this+0xa68).
	// FVector/rotation resolution and FName-to-FString copy logic unresolved.

	unguard;
}

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventClientNotifySendMatchResults()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendMatchResults), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventClientNotifySendStartMatch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendStartMatch), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
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

IMPL_APPROX("Standard UObject event thunk")
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

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventClientVoteSessionAbort(FString const & A)
{
	struct { FString A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientVoteSessionAbort), &Parms);
}

IMPL_APPROX("Standard UObject event thunk")
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

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventPlayerTeamSelectionReceived()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayerTeamSelectionReceived), NULL);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventPostRender(UCanvas * A)
{
	struct { UCanvas * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PostRender), &Parms);
}

IMPL_APPROX("Standard UObject event thunk")
void AR6PlayerController::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

IMPL_TODO("Needs Ghidra analysis")
void AR6PlayerController::execDebugFunction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6PlayerController::execFindPlayer(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(inPlayerIdent);
	P_GET_UBOOL(bIsIdInt);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_TODO("Needs Ghidra analysis")
void AR6PlayerController::execGetLocStringWithActionKey(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(szText);
	P_GET_STR(szActionKey);
	P_FINISH;
	*(FString*)Result = TEXT("");
}

IMPL_TODO("Needs Ghidra analysis")
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

IMPL_TODO("Needs Ghidra analysis")
void AR6PlayerController::execPlayVoicesPriority(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6SoundReplicationInfo, aAudioRepInfo);
	P_GET_OBJECT(USound, sndPlayVoice);
	P_GET_BYTE(eSlotUse);
	P_GET_INT(iPriority);
	P_GET_UBOOL(bWaitToFinishSound);
	P_GET_FLOAT(fTime);
	P_FINISH;
	// DIVERGENCE: manages m_PlayVoicesPriority list, allocates FstSoundPriorityPtr,
	// routes through SelectActorForSound and per-slot stop/play logic.
	// Full implementation requires resolving FstSoundPriorityPtr struct and priority queue.
}

IMPL_APPROX("Delegates to UpdateCircumstantialAction after parameter extraction")
void AR6PlayerController::execUpdateCircumstantialAction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateCircumstantialAction();
}

IMPL_APPROX("Delegates to UpdateReticule after parameter extraction")
void AR6PlayerController::execUpdateReticule(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fDeltaTime);
	P_FINISH;
	UpdateReticule(fDeltaTime);
}

IMPL_APPROX("Delegates to UpdateSpectatorReticule")
void AR6PlayerController::execUpdateSpectatorReticule(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateSpectatorReticule();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
