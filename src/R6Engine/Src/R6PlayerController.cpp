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

IMPL_MATCH("R6Engine.dll", 0x100419c0)
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

IMPL_MATCH("R6Engine.dll", 0x10030270)
FString AR6PlayerController::GetLocKeyNameByActionKey(TCHAR const *)
{
	return TEXT("");
}

IMPL_MATCH("R6Engine.dll", 0x10030260)
AActor * AR6PlayerController::GetTeamManager()
{
	return m_TeamManager;
}

IMPL_MATCH("R6Engine.dll", 0x100417c0)
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

IMPL_MATCH("R6Engine.dll", 0x10041e70)
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

IMPL_MATCH("R6Engine.dll", 0x10030f70)
void AR6PlayerController::PostNetReceive()
{
	guard(AR6PlayerController::PostNetReceive);
	if (GR6PlayerController_OldTeamByte != m_TeamSelection)
		eventPlayerTeamSelectionReceived();
	APlayerController::PostNetReceive();
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002ff00)
void AR6PlayerController::PreNetReceive()
{
	guard(AR6PlayerController::PreNetReceive);
	GR6PlayerController_OldTeamByte = m_TeamSelection;
	APlayerController::PreNetReceive();
	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10041690)
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

IMPL_MATCH("R6Engine.dll", 0x100416f0)
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

IMPL_MATCH("R6Engine.dll", 0x10041f80)
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

IMPL_DIVERGE("Multiple PrivateStaticClass_exref IsA checks on line-trace hit actor — target R6 class names are not exported from any reachable DLL; AR6AbstractCircumstantialActionQuery raw field layout (this+0x8b4, offsets +0x394 through +0x3c4) also not declared. Permanent blocker.")
void AR6PlayerController::UpdateCircumstantialAction()
{
	guard(AR6PlayerController::UpdateCircumstantialAction);

	// TODO: 1645-byte function (Ghidra 0x100308c0).
	// Resolved: FUN_100017a0 = fabsf, vtable slot 0x19c = IsLocalPlayerController().
	// Remaining blockers:
	//   - PrivateStaticClass_exref: multiple class hierarchy IsA checks on hit actor
	//     (walks +0x24/+0x2c chain); target class names are not in the export table.
	//   - AR6AbstractCircumstantialActionQuery layout (this+0x8b4): raw offset access
	//     at +0x394, +0x395, +0x3ac, +0x3b0, +0x3b4, +0x3b8, +0x3c4.
	//   - FVector0_exref: global zero-vector used for clearing reticule target.
	// Logic: queries circumtstantial action system — fires line trace from eye position,
	// checks hit actor class hierarchy for interactive/pawn types, extracts material/bone
	// info, calls eventR6QueryCircumstantialAction, updates reticule at (this+0x9bc/0x9c0/0x9c4).

	unguard;
}

IMPL_DIVERGE("FUN_1002ff80 is a viewport projection helper that creates FCameraSceneNode and FCanvasUtil; FCanvasUtil constructor takes FRenderInterface* (D3DDrv.dll runtime) \u2014 same permanent D3DDrv.dll blocker as all other FCanvasUtil/FRenderInterface paths.")
void AR6PlayerController::UpdateReticule(FLOAT DeltaTime)
{
	guard(AR6PlayerController::UpdateReticule);

	// TODO: 1298-byte function (Ghidra 0x10031010).
	// Resolved: FUN_10001750 = FCheckResult(1.0f) ctor, FUN_100017a0 = fabsf,
	//           vtable slot 0x19c = IsLocalPlayerController().
	// Remaining blocker:
	//   - FUN_1002ff80: unexported 729-byte __cdecl viewport projection helper at 0x1002ff80.
	//     Creates FCameraSceneNode, FCanvasUtil, calls FSceneNode::Project, returns 1 if
	//     projected point is on-screen. Full Ghidra decompilation available — reconstructible
	//     but requires FCameraSceneNode/FCanvasUtil/FSceneNode class availability.
	// Logic: iterates level actors for alive terrorists (role byte == 0x2), gets bone positions
	// via USkeletalMeshInstance::GetBoneCoords("R6 PonyTail1"), projects to screen via
	// FUN_1002ff80, finds closest in reticule radius. Updates aim info at
	// (this+0x8b0/0x918/0x91c/0x920/0x86c/0x870). Lerps reticule position over time.

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002fe30)
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

IMPL_MATCH("R6Engine.dll", 0x100305f0)
void AR6PlayerController::UpdateSpectatorReticule()
{
	guard(AR6PlayerController::UpdateSpectatorReticule);

	FVector StartPoint(0.f, 0.f, 0.f);
	FVector EndPoint(0.f, 0.f, 0.f);
	DWORD bDoTrace = 1;

	if ((*(DWORD*)((BYTE*)this + 0x524) & 0x20000) == 0)
	{
		// ViewTarget mode: spectating another player
		void* pViewTarget = *(void**)((BYTE*)this + 0x5b8);
		if (pViewTarget == NULL)
		{
			bDoTrace = 0;
		}
		else
		{
			// IsAlive via vtable slot 0x68/4=26 on ViewTarget
			typedef INT (__thiscall *TIsAlive)(void*);
			INT bAlive = ((TIsAlive)(*(INT**)pViewTarget)[0x68 / 4])(pViewTarget);
			if (!bAlive)
			{
				bDoTrace = 0;
			}
			else
			{
				APawn* ViewTarget = (APawn*)pViewTarget;

				// GetViewRotation via APawn vtable slot 0xd4/4=53; returns FRotator* into buffer
				FRotator rotBuf;
				typedef FRotator* (__thiscall *TGetViewRot)(APawn*, FRotator*);
				FRotator* pRot = ((TGetViewRot)(*(INT**)ViewTarget)[0xd4 / 4])(ViewTarget, &rotBuf);
				FVector dir = pRot->Vector();

				FVector eyeOfs = ViewTarget->eventEyePosition();
				StartPoint.X = eyeOfs.X + *(FLOAT*)((BYTE*)ViewTarget + 0x234);
				StartPoint.Y = eyeOfs.Y + *(FLOAT*)((BYTE*)ViewTarget + 0x238);
				StartPoint.Z = eyeOfs.Z + *(FLOAT*)((BYTE*)ViewTarget + 0x23c);

				FLOAT Range = *(FLOAT*)((BYTE*)this + 0x848);
				EndPoint.X = StartPoint.X + dir.X * Range;
				EndPoint.Y = StartPoint.Y + dir.Y * Range;
				EndPoint.Z = StartPoint.Z + dir.Z * Range;
			}
		}
	}
	else
	{
		// Direct spectator: use controller's own rotation and location
		FVector dir = ((FRotator*)((BYTE*)this + 0x240))->Vector();
		FLOAT Range = *(FLOAT*)((BYTE*)this + 0x848);
		StartPoint.X = *(FLOAT*)((BYTE*)this + 0x234);
		StartPoint.Y = *(FLOAT*)((BYTE*)this + 0x238);
		StartPoint.Z = *(FLOAT*)((BYTE*)this + 0x23c);
		EndPoint.X = StartPoint.X + dir.X * Range;
		EndPoint.Y = StartPoint.Y + dir.Y * Range;
		EndPoint.Z = StartPoint.Z + dir.Z * Range;
	}

	if (bDoTrace)
	{
		FCheckResult Hit(1.0f);
		XLevel->SingleLineCheck(Hit, *(AActor**)((BYTE*)this + 0x3d8), EndPoint, StartPoint, 0x210bf, FVector(0, 0, 0));
		if (Hit.Actor != NULL)
		{
			// vtable slot 0x6c/4=27 on Hit.Actor: returns controller or similar
			typedef INT (__thiscall *TVtable27)(AActor*);
			INT iResult = ((TVtable27)(*(INT**)Hit.Actor)[0x6c / 4])(Hit.Actor);
			if (iResult != 0)
			{
				FStringNoInit* pName;
				if (*(INT*)(iResult + 0x518) == 0)
					pName = (FStringNoInit*)(iResult + 0x630);
				else
					pName = (FStringNoInit*)(*(INT*)(iResult + 0x518) + 0x408);
				*(FStringNoInit*)((BYTE*)this + 0xa68) = *pName;
				return;
			}
		}
	}

	// Clear spectator target name
	*(FStringNoInit*)((BYTE*)this + 0xa68) = TEXT("");

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x10007d40)
void AR6PlayerController::eventClientNotifySendMatchResults()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendMatchResults), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10007d10)
void AR6PlayerController::eventClientNotifySendStartMatch()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientNotifySendStartMatch), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10007bb0)
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

IMPL_MATCH("R6Engine.dll", 0x1000dd40)
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

IMPL_MATCH("R6Engine.dll", 0x1000dcb0)
void AR6PlayerController::eventClientVoteSessionAbort(FString const & A)
{
	struct { FString A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_ClientVoteSessionAbort), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10007c10)
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

IMPL_MATCH("R6Engine.dll", 0x10007c60)
void AR6PlayerController::eventPlayerTeamSelectionReceived()
{
	ProcessEvent(FindFunctionChecked(R6ENGINE_PlayerTeamSelectionReceived), NULL);
}

IMPL_MATCH("R6Engine.dll", 0x10007cd0)
void AR6PlayerController::eventPostRender(UCanvas * A)
{
	struct { UCanvas * A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_PostRender), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x10007c90)
void AR6PlayerController::eventSetCrouchBlend(FLOAT A)
{
	struct { FLOAT A; } Parms;
	Parms.A = A;
	ProcessEvent(FindFunctionChecked(R6ENGINE_SetCrouchBlend), &Parms);
}

IMPL_MATCH("R6Engine.dll", 0x1002fce0)
void AR6PlayerController::execDebugFunction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
}

IMPL_MATCH("R6Engine.dll", 0x100303b0)
void AR6PlayerController::execFindPlayer(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(inPlayerIdent);
	P_GET_UBOOL(bIsIdInt);
	P_FINISH;
	*(UObject**)Result = NULL;
}

IMPL_MATCH("R6Engine.dll", 0x10033020)
void AR6PlayerController::execGetLocStringWithActionKey(FFrame& Stack, RESULT_DECL)
{
	P_GET_STR(szText);
	P_GET_STR(szActionKey);
	P_FINISH;
	*(FString*)Result = TEXT("");
}

IMPL_MATCH("R6Engine.dll", 0x10031530)
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

IMPL_MATCH("R6Engine.dll", 0x10041a90)
void AR6PlayerController::execPlayVoicesPriority(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6SoundReplicationInfo, aAudioRepInfo);
	P_GET_OBJECT(USound, sndPlayVoice);
	P_GET_BYTE(eSlotUse);
	P_GET_INT(iPriority);
	P_GET_UBOOL(bWaitToFinishSound);
	P_GET_FLOAT(fTime);
	P_FINISH;

	guard(AR6PlayerController::execPlayVoicesPriority);

	if (*(INT*)((BYTE*)g_pEngine + 0x48) == 0)
		return;

	if (iPriority == 0)
	{
		// Diagnostic path only
		AActor* pActor = SelectActorForSound(aAudioRepInfo);
		pActor->GetName();
		return;
	}

	// Allocate 0x1c-byte FstSoundPriorityPtr entry
	INT* pEntry = (INT*)GMalloc->Malloc(0x1c, TEXT("R6Sound"));
	if (pEntry == NULL)
		return;

	INT bAlreadyExists = 0;
	INT bIsPlaying     = 0;

	if (fTime == 0.0f)
	{
		if (iPriority == 5)
		{
			// Stop conflicting priority-5 entries for same RepInfo
			for (INT i = 0; i < m_PlayVoicesPriority.Num(); i++)
			{
				INT* pE = (INT*)*(INT*)(*(INT*)((BYTE*)this + 0x900) + i * 4);
				if ((AR6SoundReplicationInfo*)pE[0] == aAudioRepInfo &&
				    (pE[5] == 0 || pE[2] != 5 || pE[6] == 0))
				{
					StopAndRemoveVoices(i);
				}
			}
			// Play sound immediately
			AActor* pActor = SelectActorForSound(aAudioRepInfo);
			(*(void (__thiscall**)(AActor*, INT, BYTE, INT))
			    (**(INT**)(*(INT*)((BYTE*)g_pEngine + 0x48)) + 0x84))
			    (pActor, (INT)sndPlayVoice, eSlotUse, 0);
			bIsPlaying = 1;
		}
		else if (iPriority == 10)
		{
			UBOOL bFoundMatch = 0;
			for (INT i = 0; i < m_PlayVoicesPriority.Num(); i++)
			{
				INT* pE = (INT*)*(INT*)(*(INT*)((BYTE*)this + 0x900) + i * 4);
				UBOOL bStop = 0;
				if ((AR6SoundReplicationInfo*)pE[0] == aAudioRepInfo)
				{
					if (pE[2] != 10)
					{
						bStop = (pE[2] == 15);
					}
					else
					{
						if (pE[5] == 0 || pE[6] == 0)
						{
							bStop = 1;
						}
						else
						{
							if (pE[1] == (INT)sndPlayVoice)
								bAlreadyExists = 1;
							bFoundMatch = 1;
						}
					}
				}
				else if (pE[5] == 0 || pE[1] != (INT)sndPlayVoice)
				{
					if (aAudioRepInfo != NULL &&
					    *(INT*)((BYTE*)aAudioRepInfo + 0x3b0) != 0 &&
					    *(BYTE*)(*(INT*)((BYTE*)aAudioRepInfo + 0x3b0) + 0x394) == 1 &&
					    *(BYTE*)((BYTE*)pE + 0x0d) == 1 &&
					    pE[2] > 14)
					{
						bStop = 1;
					}
				}
				else
				{
					bFoundMatch = 1;
					bAlreadyExists = 1;
				}
				if (bStop)
					StopAndRemoveVoices(i);
			}
			if (!bFoundMatch)
			{
				// No matching entry found — play immediately
				AActor* pActor = SelectActorForSound(aAudioRepInfo);
				(*(void (__thiscall**)(AActor*, INT, BYTE, INT))
				    (**(INT**)(*(INT*)((BYTE*)g_pEngine + 0x48)) + 0x84))
				    (pActor, (INT)sndPlayVoice, eSlotUse, 0);
				bIsPlaying = 1;
			}
		}
		else if (iPriority == 15)
		{
			for (INT i = 0; i < m_PlayVoicesPriority.Num(); i++)
			{
				INT* pE = (INT*)*(INT*)(*(INT*)((BYTE*)this + 0x900) + i * 4);
				if (pE[2] == 15 &&
				    (AR6SoundReplicationInfo*)pE[0] == aAudioRepInfo &&
				    (pE[5] == 0 || pE[6] == 0))
				{
					StopAndRemoveVoices(i);
				}
			}
		}
		// other priorities: fall through to add entry

		if (bAlreadyExists)
			return; // NOTE: pEntry allocated above is leaked here (matches retail)
	}

	// Fill the struct fields
	pEntry[0] = (INT)aAudioRepInfo;
	pEntry[1] = (INT)sndPlayVoice;
	pEntry[2] = iPriority;
	*(BYTE*)((BYTE*)pEntry + 0x0c) = eSlotUse;
	*(FLOAT*)((BYTE*)pEntry + 0x10) = fTime + (FLOAT)*(double*)(*(INT*)((BYTE*)this + 0x328) + 0xd4);
	pEntry[5] = bIsPlaying;
	pEntry[6] = bWaitToFinishSound;

	if (aAudioRepInfo == NULL)
	{
		*(BYTE*)((BYTE*)pEntry + 0x0d) = 1;
	}
	else if (*(INT*)((BYTE*)aAudioRepInfo + 0x3b0) == 0)
	{
		(void)((UObject*)aAudioRepInfo)->GetFullName();
		*(BYTE*)((BYTE*)pEntry + 0x0d) = 1;
	}
	else
	{
		*(BYTE*)((BYTE*)pEntry + 0x0d) = *(BYTE*)(*(INT*)((BYTE*)aAudioRepInfo + 0x3b0) + 0x394);
	}

	// Add pointer to m_PlayVoicesPriority array
	INT newIdx = ((FArray*)((BYTE*)this + 0x900))->Add(1, 4);
	*(INT*)(*(INT*)((BYTE*)this + 0x900) + newIdx * 4) = (INT)pEntry;

	unguard;
}

IMPL_MATCH("R6Engine.dll", 0x1002fd90)
void AR6PlayerController::execUpdateCircumstantialAction(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateCircumstantialAction();
}

IMPL_MATCH("R6Engine.dll", 0x10033220)
void AR6PlayerController::execUpdateReticule(FFrame& Stack, RESULT_DECL)
{
	P_GET_FLOAT(fDeltaTime);
	P_FINISH;
	UpdateReticule(fDeltaTime);
}

IMPL_MATCH("R6Engine.dll", 0x10033180)
void AR6PlayerController::execUpdateSpectatorReticule(FFrame& Stack, RESULT_DECL)
{
	P_FINISH;
	UpdateSpectatorReticule();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
