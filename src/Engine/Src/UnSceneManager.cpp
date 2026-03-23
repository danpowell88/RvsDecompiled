/*=============================================================================
	UnSceneManager.cpp: Matinee scene manager and sub-action system
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#if _MSC_VER > 1310
#include <intrin.h>
#endif
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "ImplSource.h"
#include "EngineDecls.h"

static void RegisterSceneManager(ASceneManager* Scene)
{
	for (INT i = 0; i < GSceneManagers.Num(); ++i)
	{
		if (GSceneManagers(i) == Scene)
			return;
	}

	GSceneManagers.AddItem(Scene);
}

// --- ASceneManager ---
IMPL_MATCH("Engine.dll", 0x1041f6d0)
void ASceneManager::UpdateViewerFromPct(float Pct)
{
	guard(ASceneManager::UpdateViewerFromPct);
	// Retail: 0x11f6d0, ordinal 4956. Clamps Pct to [0.0001, 100.0].
	// If Pct <= 1.0: gets current action via GetActionFromPct, fires ActionStart event
	// if action changed, updates all sub-actions via their Update vtable slot.
	if (Pct < 0.0001f) Pct = 0.0001f;
	else if (Pct > 100.0f) Pct = 100.0f;
	// Save previous action
	*(DWORD*)((BYTE*)this + 0x3D4) = *(DWORD*)((BYTE*)this + 0x3D8);
	if (Pct > 1.0f)
		return;
	// Update current action
	UMatAction* prevAction = *(UMatAction**)((BYTE*)this + 0x3D4);
	UMatAction* curAction  = GetActionFromPct(Pct);
	*(UMatAction**)((BYTE*)this + 0x3D8) = curAction;
	if (prevAction != curAction)
		curAction->eventActionStart(*(AActor**)((BYTE*)this + 0x3DC));
	// In editor, refresh sub-actions
	if (GIsEditor)
		RefreshSubActions(Pct);
	// Update all sub-actions in the 0x3F0 TArray (vtable offset 0x64 = virtual Update)
	TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)this + 0x3F0);
	for (INT i = 0; i < SubActions.Num(); i++)
	{
		UMatSubAction* sub = SubActions(i);
		if (*(BYTE*)((BYTE*)sub + 0x2C) != 3)  // not done
		{
			typedef INT (__thiscall* UpdateFn)(UMatSubAction*, FLOAT, ASceneManager*);
			((UpdateFn)(*(void***)sub)[0x64 / 4])(sub, Pct, this);
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041db90)
int ASceneManager::VerifyIntPoints()
{
	// Retail: 0x11db90, ordinal 4965. Returns 0 if playing (bit 2 of state byte at this+0x398 set).
	// Otherwise walks Actions TArray at this+0x3A8; returns 0 if any action's int-point
	// pointer at action+0x40 is NULL. Returns 1 if all int-points are valid.
	if (*(BYTE*)((BYTE*)this + 0x398) & 4)
		return 1;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
	INT count = Actions.Num();
	for (INT i = 0; i < count; i++)
	{
		if (*(INT*)((BYTE*)Actions(i) + 0x40) == 0)
			return 0;
		count = Actions.Num();
	}
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041dcb0)
void ASceneManager::RefreshSubActions(float Pct)
{
	// Retail: 0x11dcb0, ordinal 4269. For each action in Actions TArray (this+0x3A8),
	// iterate its sub-actions TArray (action+0x48) and set each sub-action's state
	// (BYTE at sub+0x2C) based on where Pct falls relative to sub.StartPct (+0x4C)
	// and sub.EndPct (+0x50): 0=before, 1=in-range, 3=past-end.
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
	INT actionCount = Actions.Num();
	for (INT i = 0; i < actionCount; i++)
	{
		BYTE* action = (BYTE*)Actions(i);
		TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)(action + 0x48);
		INT subCount = SubActions.Num();
		for (INT j = 0; j < subCount; j++)
		{
			BYTE* sub = (BYTE*)SubActions(j);
			FLOAT subStart = *(FLOAT*)(sub + 0x4C);
			FLOAT subEnd   = *(FLOAT*)(sub + 0x50);
			if (Pct < subStart)
				*(BYTE*)(sub + 0x2C) = 0;  // before
			else if (Pct < subEnd)
				*(BYTE*)(sub + 0x2C) = 1;  // in range
			else
				*(BYTE*)(sub + 0x2C) = 3;  // past end
			subCount = SubActions.Num();   // re-fetch (retail does this)
		}
		actionCount = Actions.Num();   // re-fetch
	}
}

IMPL_MATCH("Engine.dll", 0x1041f2d0)
void ASceneManager::SceneEnded()
{
	guard(ASceneManager::SceneEnded);
	// Retail: 0x11f2d0, ordinal 4353. Clears playing/hasPC flags (bits 1+2) of state at this+0x3C0,
	// zeros this+0x448, fires SceneEnded script event, empties PathSamples TArray at this+0x3E4,
	// decrements global scene counter at 0x1061b80c, clears PC fade if applicable,
	// then calls all registered scene listeners.
	extern ENGINE_API INT GNumActiveScenes;
	*(DWORD*)((BYTE*)this + 0x3C0) &= ~0x00000006u;
	*(DWORD*)((BYTE*)this + 0x448) = 0;
	eventSceneEnded();
	((TArray<FVector>*)((BYTE*)this + 0x3E4))->Empty();
	--GNumActiveScenes;
	// Clear PC fade state
	UObject* actor = *(UObject**)((BYTE*)this + 0x3DC);
	if (actor && actor->IsA(APlayerController::StaticClass()))
	{
		if ((*(BYTE*)((BYTE*)this + 0x398) & 2) != 0)
		{
			UObject* viewport = *(UObject**)((BYTE*)actor + 0x5B4);
			if (viewport && viewport->IsA(UViewport::StaticClass()))
				*(DWORD*)((BYTE*)viewport + 0x138) = 0;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041fcd0)
void ASceneManager::SceneStarted()
{
	guard(ASceneManager::SceneStarted);
	// Retail: 0x11fcd0, ordinal 4354. Calls InitializeActions, sets bit 1 (flag 2) of
	// this+0x3C0 (playing), calls SetSceneStartTime, fires SceneStarted script event,
	// sets scene-speed this+0x3C8=1.0 and clears cached action ptr this+0x3D8.
	// Calls ChangeOrientation with a zero FOrientation, increments global scene counter,
	// and if PC is valid via IsA check, enables the viewport rendering flag.
	extern ENGINE_API INT GNumActiveScenes;
	InitializeActions();
	*(DWORD*)((BYTE*)this + 0x3C0) |= 2;
	SetSceneStartTime();
	eventSceneStarted();
	if (*(INT*)((BYTE*)this + 0x3DC) == 0)
		return;
	*(FLOAT*)((BYTE*)this + 0x3C8) = 1.0f;
	*(DWORD*)((BYTE*)this + 0x3D8) = 0;
	// Zero out initial FOrientation and latch it via ChangeOrientation
	FOrientation zeroOrient;
	appMemzero(&zeroOrient, sizeof(zeroOrient));
	ChangeOrientation(zeroOrient);
	++GNumActiveScenes;
	// Enable viewport if PC has one and bit 1 (flag 2) of state set
	UObject* actor = *(UObject**)((BYTE*)this + 0x3DC);
	if (actor && actor->IsA(APlayerController::StaticClass()) &&
		((*(BYTE*)((BYTE*)this + 0x398) & 2) != 0))
	{
		UObject* viewport = *(UObject**)((BYTE*)actor + 0x5B4);
		if (viewport && viewport->IsA(UViewport::StaticClass()))
			*(DWORD*)((BYTE*)viewport + 0x138) = 1;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041f970)
void ASceneManager::PreparePath()
{
	// Retail: 0x11f970, ordinal 3984. Empties global PathSamples (this+0x3E4).
	// For each action in Actions TArray (this+0x3A8):
	//   - Empties action's local samples TArray at action+0x84
	//   - Calls GMatineeTools.GetSamples(this, prevAction, &PathSamples) to fill globals
	//   - Calls GMatineeTools.GetSamples(this, prevAction2, &action.Samples) to fill local
	//   - If flag bit 1 of action+0x30 is set and action+0x38 != 0, computes speed:
	//     action+0x34 = action+0x3C / action+0x38
	// If in editor, calls SetSceneStartTime.
	extern ENGINE_API FMatineeTools GMatineeTools;
	((TArray<FVector>*)((BYTE*)this + 0x3E4))->Empty();
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
	INT i = 0;
	INT count = Actions.Num();
	if (count > 0)
	{
		do
		{
			UMatAction* action = Actions(i);
			// Empty action's own sample TArray at action+0x84
			((TArray<FVector>*)((BYTE*)action + 0x84))->Empty();
			// Fill global PathSamples from previous action's spline
			UMatAction* prevAction = GMatineeTools.GetPrevAction(this, action);
			GMatineeTools.GetSamples(this, prevAction, (TArray<FVector>*)((BYTE*)this + 0x3E4));
			// Fill action's local samples from prev action's spline
			UMatAction* prevAction2 = GMatineeTools.GetPrevAction(this, action);
			GMatineeTools.GetSamples(this, prevAction2, (TArray<FVector>*)((BYTE*)action + 0x84));
			// Compute speed ratio if flag set and divisor non-zero
			if ((*(BYTE*)((BYTE*)action + 0x30) & 2) != 0)
			{
				FLOAT totalDist = *(FLOAT*)((BYTE*)action + 0x38);
				if (totalDist != 0.0f)
					*(FLOAT*)((BYTE*)action + 0x34) = *(FLOAT*)((BYTE*)action + 0x3C) / totalDist;
			}
			i++;
			count = Actions.Num();
		} while (i < count);
	}
	// if (GIsEditor)
	//     SetSceneStartTime(this);
	if (GIsEditor)
		SetSceneStartTime();
}

IMPL_MATCH("Engine.dll", 0x1041e1e0)
void ASceneManager::ChangeOrientation(FOrientation orient)
{
	// Retail: 0x11e1e0, ordinal 2349. Copies the passed FOrientation (13 DWORDs = 52 bytes)
	// to this+0x3FC (cached orientation), then snapshot current actor rotation from
	// active actor (this+0x3DC) at offsets +0x240/+0x244/+0x248, stores in this+0x424/+0x428/+0x42C.
	// Calls FUN_1041db30 (likely an orientation matrix rebuild) via a local continuation.
	*(FOrientation*)((BYTE*)this + 0x3FC) = orient;
	INT actor = *(INT*)((BYTE*)this + 0x3DC);
	*(DWORD*)((BYTE*)this + 0x424) = *(DWORD*)(actor + 0x240);
	*(DWORD*)((BYTE*)this + 0x428) = *(DWORD*)(actor + 0x244);
	*(DWORD*)((BYTE*)this + 0x42C) = *(DWORD*)(actor + 0x248);
}

IMPL_MATCH("Engine.dll", 0x1041f070)
void ASceneManager::DeletePathSamples()
{
	// Retail: 17b. Empties the PathSamples TArray at this+0x3E4 (FVector elements, 12b each).
	// Sequence: push 0 (Extra), add ecx 0x3E4, push 0x0C (ElementSize), call TArray::Empty IAT.
	((TArray<FVector>*)((BYTE*)this + 0x3E4))->Empty();
}

IMPL_MATCH("Engine.dll", 0x1041dbe0)
UMatAction * ASceneManager::GetActionFromPct(float Pct)
{
	guard(ASceneManager::GetActionFromPct);
	// Retail: 0x11dbe0, ordinal 2878. Walks Actions TArray at this+0x3A8 (TArray<UMatAction*>)
	// until it finds the first action whose EndPct (action+0x7C) >= Pct. Calls
	// appFailAssert if the array is exhausted (should not happen in normal use).
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
	for (INT i = 0; i < Actions.Num(); i++)
	{
		UMatAction* action = Actions(i);
		if (Pct <= *(FLOAT*)((BYTE*)action + 0x7C))
			return action;
	}
	appFailAssert("0", ".\\UnSceneManager.cpp", 0xa8);
	return NULL;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041ddd0)
float ASceneManager::GetActionPctFromScenePct(float Pct)
{
	guard(ASceneManager::GetActionPctFromScenePct);
	// Retail: 0x11ddd0, ordinal 2881. Uses cached current action at this+0x3D8;
	// if NULL, calls GetActionFromPct to populate it. Then computes local pct within
	// the action: (Pct - action.StartPct) / action.Duration. Clamped to [0.0001, 100.0].
	// action.StartPct at action+0x78, action.Duration at action+0x80.
	if (*(INT*)((BYTE*)this + 0x3D8) == 0)
		*(UMatAction**)((BYTE*)this + 0x3D8) = GetActionFromPct(Pct);
	UMatAction* action = *(UMatAction**)((BYTE*)this + 0x3D8);
	FLOAT duration = *(FLOAT*)((BYTE*)action + 0x80);
	FLOAT startPct = *(FLOAT*)((BYTE*)action + 0x78);
	FLOAT t;
	if (duration == 0.0f)
		t = 1.0f;
	else
		t = (Pct - startPct) / duration;
	if (t < 0.0001f)
		return 0.0001f;
	if (t > 100.0f)
		return 100.0f;
	return t;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041e030)
FVector ASceneManager::GetLocation(TArray<FVector> *,float)
{
	guard(ASceneManager::GetLocation);
	// Retail: 102b SEH. Returns the current action's cached location if the scene is playing.
	// Bit 2 (mask 4) of the state byte at this+0x398 indicates "playing".
	// When playing, dereferences the action pointer at this+0x3DC and reads FVector at +0x234.
	if (!(*(BYTE*)((BYTE*)this + 0x398) & 4))
		return FVector(0,0,0);
	BYTE* action = *(BYTE**)((BYTE*)this + 0x3DC);
	return *(FVector*)(action + 0x234);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041e9e0)
FRotator ASceneManager::GetRotation(TArray<FVector> *,float,FVector,FRotator,UMatAction *,int)
{
	guard(ASceneManager::GetRotation);
	// Retail: 106b SEH. Same guard as GetLocation: bit 2 of state byte at this+0x398.
	// When playing, reads FRotator from action data pointer (this+0x3DC) at offset +0x240.
	// The extra parameters (FVector, FRotator, UMatAction*, INT) are accepted but unused here.
	if (!(*(BYTE*)((BYTE*)this + 0x398) & 4))
		return FRotator(0,0,0);
	BYTE* action = *(BYTE**)((BYTE*)this + 0x3DC);
	return *(FRotator*)(action + 0x240);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041dda0)
void ASceneManager::InitializeActions()
{
	// Retail: 48b. Calls Initialize() on each action in the Actions TArray at this+0x3A8.
	// Count is re-checked each iteration (retail re-fetches via IAT) in case Initialize()
	// modifies the array.
	BYTE* actionsBase = (BYTE*)this + 0x3A8;
	INT count = *(INT*)(actionsBase + 4);
	for (INT i = 0; i < count; i++)
	{
		UMatAction* action = (*(UMatAction***)(actionsBase))[i];
		action->Initialize();
		count = *(INT*)(actionsBase + 4);
	}
}


// --- FR6MatineePreviewProxy ---
IMPL_EMPTY("preview proxy end-sequence notify no-op")
void FR6MatineePreviewProxy::OnEndSequenceNotify(ASceneManager *)
{
}

IMPL_EMPTY("preview proxy scroll-bar update no-op")
void FR6MatineePreviewProxy::OnScrollBarUpdate()
{
}

IMPL_EMPTY("preview proxy copy constructor no-op")
FR6MatineePreviewProxy::FR6MatineePreviewProxy(FR6MatineePreviewProxy const &)
{
}

IMPL_EMPTY("preview proxy default constructor no-op")
FR6MatineePreviewProxy::FR6MatineePreviewProxy()
{
}

IMPL_EMPTY("preview proxy destructor no-op")
FR6MatineePreviewProxy::~FR6MatineePreviewProxy()
{
}

IMPL_MATCH("Engine.dll", 0x10311630)
FR6MatineePreviewProxy& FR6MatineePreviewProxy::operator=(const FR6MatineePreviewProxy&)
{
	// Ghidra 0x11630: no data members to copy; shares address with FBezier/FHitObserver/FNetworkNotify op=
	return *this;
}


// --- UMatAction ---
IMPL_MATCH("Engine.dll", 0x1041fad0)
void UMatAction::PostEditChange()
{
	guard(UMatAction::PostEditChange);
	UObject::PostEditChange();
	{
		extern ENGINE_API FMatineeTools GMatineeTools;
		ASceneManager* SM = GMatineeTools.GetCurrent(); // Ghidra: DAT_1061b7e8
		if (SM)
			SM->PreparePath();
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041d750)
void UMatAction::PostLoad()
{
	guard(UMatAction::PostLoad);
	Super::PostLoad();
	if (*(INT*)((BYTE*)this + 0x40) != 0 && *(SBYTE*)(*(INT*)((BYTE*)this + 0x40) + 0xa0) < 0)
		*(INT*)((BYTE*)this + 0x40) = 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041e880)
void UMatAction::Initialize()
{
	// Retail: 0x11e880, 74b. Fire the UScript Initialize event then forward to all sub-actions.
	eventInitialize();
	FArray* subActions = (FArray*)((BYTE*)this + 0x48);
	INT i     = 0;
	INT count = subActions->Num();
	while (i < count)
	{
		UMatSubAction* sub = *(UMatSubAction**)(*(INT*)subActions + i * 4);
		typedef void (__thiscall* InitFn)(UMatSubAction*);
		((InitFn)(*(void***)sub)[0x74/4])(sub);
		i++;
		count = subActions->Num();
	}
}


// --- UMatSubAction ---
IMPL_MATCH("Engine.dll", 0x1041d920)
int UMatSubAction::Update(float Pct, ASceneManager*)
{
	// Retail: 0x11d920, 64b. State machine at this+0x2C (BYTE):
	// 0=not started, 1=running, 2=ending, 3=done.
	// If ending (2): transition to done (3) and return 0.
	// Else if Pct in [StartPct, EndPct): set running (1) and return 1.
	// Else if Pct >= EndPct: set ending (2), return 1.
	// StartPct at this+0x4C, EndPct at this+0x50.
	BYTE state = *(BYTE*)((BYTE*)this + 0x2C);
	if (state == 2) {
		*(BYTE*)((BYTE*)this + 0x2C) = 3;
		return 0;
	}
	FLOAT StartPct = *(FLOAT*)((BYTE*)this + 0x4C);
	FLOAT EndPct   = *(FLOAT*)((BYTE*)this + 0x50);
	if (StartPct < Pct && Pct < EndPct) {
		*(BYTE*)((BYTE*)this + 0x2C) = 1;
		return 1;
	}
	if (EndPct < Pct || EndPct == Pct) {
		*(BYTE*)((BYTE*)this + 0x2C) = 2;
	}
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041fb50)
void UMatSubAction::PostEditChange()
{
	guard(UMatSubAction::PostEditChange);
	UObject::PostEditChange();
	{
		extern ENGINE_API FMatineeTools GMatineeTools;
		ASceneManager* SM = GMatineeTools.GetCurrent(); // Ghidra: DAT_1061b7e8
		if (SM)
			SM->PreparePath();
	}
	unguard;
}

IMPL_EMPTY("sub-action pre-begin-preview no-op")
void UMatSubAction::PreBeginPreview()
{
}

IMPL_MATCH("Engine.dll", 0x1041e240)
FString UMatSubAction::GetStatString()
{
	FString status = GetStatusDesc();
	return FString::Printf(
		TEXT("TYPE : %s, Status : %s, Delay : %1.1f, Duration : %1.1f"),
		*(FString*)((BYTE*)this + 0x40),
		*status,
		*(FLOAT*)((BYTE*)this + 0x30),
		*(FLOAT*)((BYTE*)this + 0x34));
}

IMPL_MATCH("Engine.dll", 0x1041d980)
FString UMatSubAction::GetStatusDesc()
{
	BYTE state = *(BYTE*)((BYTE*)this + 0x2C);
	switch (state)
	{
		case 0: return FString(TEXT("SASTATUS_Waiting"));
		case 1: return FString(TEXT("SASTATUS_Running"));
		case 2: return FString(TEXT("SASTATUS_Ending"));
		case 3: return FString(TEXT("SASTATUS_Expired"));
		default:
			appFailAssert("0", ".\\UnSceneManager.cpp", 0x400);
			return FString(TEXT("Unknown"));
	}
}

IMPL_MATCH("Engine.dll", 0x1030ce50)
void UMatSubAction::Initialize()
{
	// Retail: 0xce50, 33b. Fire the UScript Initialize event for this sub-action.
	eventInitialize();
}

IMPL_MATCH("Engine.dll", 0x1041da30)
int UMatSubAction::IsEnding()
{
	// Retail: 12b. Returns 1 if status byte at this+0x2C == 2 (SETE pattern).
	return *(BYTE*)((BYTE*)this + 0x2C) == 2 ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x1041da40)
int UMatSubAction::IsRunning()
{
	// Retail: 14b. Returns 1 if status byte at this+0x2C is 1 (started) or 2 (ending).
	BYTE status = *(BYTE*)((BYTE*)this + 0x2C);
	return (status == 1 || status == 2) ? 1 : 0;
}


// --- USubActionCameraEffect ---
IMPL_MATCH("Engine.dll", 0x10386800)
int USubActionCameraEffect::Update(float Pct, ASceneManager* SceneMgr)
{
	guard(USubActionCameraEffect::Update);
	// Retail: 0x86800, ordinal 4914. Calls parent Update; if not running returns 0.
	// Gets scene manager via vtable+0x6C. If manager has a valid actor (IsA PlayerController)
	// and the camera effect at this+0x58 exists:
	//   If duration (this+0x54) == 0: snap alpha directly from this+0x60 -> effect+0x2C.
	//   Else lerp: ((endAlpha - startAlpha) / duration) * (Pct - startPct) + startAlpha.
	// If effect alpha <= 0 and state != ending or bReversed==0: AddCameraEffect.
	// Else RemoveCameraEffect.
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionCameraEffect*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	UObject* actor = *(UObject**)((BYTE*)mgr + 0x3DC);
	if (!actor || !actor->IsA(APlayerController::StaticClass()))
		return 1;
	INT effectPtr = *(INT*)((BYTE*)this + 0x58);
	if (!effectPtr)
		return 1;
	FLOAT duration = *(FLOAT*)((BYTE*)this + 0x54);
	if (duration <= 0.0f)
	{
		*(FLOAT*)(effectPtr + 0x2C) = *(FLOAT*)((BYTE*)this + 0x60);
	}
	else
	{
		FLOAT endAlpha   = *(FLOAT*)((BYTE*)this + 0x60);
		FLOAT startAlpha = *(FLOAT*)((BYTE*)this + 0x5C);
		FLOAT startPct   = *(FLOAT*)((BYTE*)this + 0x4C);
		*(FLOAT*)(effectPtr + 0x2C) = ((endAlpha - startAlpha) / duration) * (Pct - startPct) + startAlpha;
	}
	FLOAT alpha = *(FLOAT*)(effectPtr + 0x2C);
	INT ending   = (*(BYTE*)((BYTE*)this + 0x2C) == 2) ? 1 : 0;
	INT reversed = ((*(BYTE*)((BYTE*)this + 0x64) & 1) != 0) ? 1 : 0;
	if (alpha <= 0.0f && (!ending || !reversed))
	{
		((APlayerController*)actor)->eventAddCameraEffect((UCameraEffect*)effectPtr, 1);
	}
	else
	{
		((APlayerController*)actor)->eventRemoveCameraEffect((UCameraEffect*)effectPtr);
	}
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103862a0)
FString USubActionCameraEffect::GetStatString()
{
	guard(USubActionCameraEffect::GetStatString);
	return FString(TEXT(""));
	unguard;
}


// --- USubActionCameraShake ---
IMPL_MATCH("Engine.dll", 0x1041da60)
int USubActionCameraShake::Update(float Pct, ASceneManager* SceneMgr)
{
	INT ran = UMatSubAction::Update(Pct, SceneMgr);
	if (!ran)
		return 0;
	typedef ASceneManager* (__thiscall* GetMgrFn)(USubActionCameraShake*);
	ASceneManager* mgr = ((GetMgrFn)(*(void***)this)[0x6c/4])(this);
	if (mgr != NULL)
	{
		FVector shake = ((FRangeVector*)((BYTE*)this + 0x58))->GetRand();
		*(FLOAT*)((BYTE*)SceneMgr + 0x47c) += shake.X;
		*(FLOAT*)((BYTE*)SceneMgr + 0x480) += shake.Y;
		*(FLOAT*)((BYTE*)SceneMgr + 0x484) += shake.Z;
	}
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041dae0)
FString USubActionCameraShake::GetStatString()
{
	return FString();
}


// --- USubActionFOV ---
IMPL_MATCH("Engine.dll", 0x1041f0e0)
int USubActionFOV::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11f0e0, 245b. If running and active actor is an APlayerController,
	// saves current FOV (PC+0x3B0) to this+0x58 on first tick (if still 0),
	// then lerps FOV from saved (this+0x58) to end (this+0x5C) over the duration.
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionFOV*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	FLOAT* SavedFOV = (FLOAT*)((BYTE*)this + 0x58);
	FLOAT* EndFOV   = (FLOAT*)((BYTE*)this + 0x5C);
	FLOAT  Duration  = *(FLOAT*)((BYTE*)this + 0x54);
	FLOAT  StartPct  = *(FLOAT*)((BYTE*)this + 0x4C);
	// SceneMgr+0x3DC = active actor
	UObject* actor = *(UObject**)((BYTE*)mgr + 0x3DC);
	// Save current FOV on first active tick
	if (*SavedFOV == 0.0f && actor && actor->IsA(APlayerController::StaticClass()))
		*SavedFOV = *(FLOAT*)((BYTE*)actor + 0x3B0);
	FLOAT t = (Pct - StartPct) / Duration;
	if (t < 0.0001f) t = 0.0001f;
	if (t > 1.0f)    t = 1.0f;
	if (*(BYTE*)((BYTE*)this + 0x2C) == 2) t = 1.0f;
	// Apply FOV lerp to PlayerController
	if (actor && actor->IsA(APlayerController::StaticClass()))
		*(FLOAT*)((BYTE*)actor + 0x3B0) = (*EndFOV - *SavedFOV) * t + *SavedFOV;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041e3c0)
FString USubActionFOV::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	FString extra = FString::Printf(TEXT(", Start : %1.1f, End : %1.1f\n"),
		*(FLOAT*)((BYTE*)this + 0x58),
		*(FLOAT*)((BYTE*)this + 0x5c));
	result += *extra;
	return result;
}


// --- USubActionFade ---
IMPL_MATCH("Engine.dll", 0x1041f1e0)
int USubActionFade::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11f1e0, 232b. Gets PlayerController from SceneMgr+0x3DC;
	// if running and PC is an APlayerController, converts FColor at this+0x5C to FVector
	// and stores in PC+0x5F8..+0x600 (FadeColor FVector), then updates fade alpha at PC+0x5EC.
	// The alpha is a lerp t value, optionally inverted by a bReversed flag at this+0x58 bit 0.
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionFade*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	// SceneMgr+0x3DC = active actor (typically APlayerController)
	UObject* actor = *(UObject**)((BYTE*)mgr + 0x3DC);
	if (!actor)
		return 0;
	if (!actor->IsA(APlayerController::StaticClass()))
		return 0;
	// Convert FColor at this+0x5C to FVector (normalised 0..1 RGB) and store at actor+0x5F8.
	FColor& fadeColor = *(FColor*)((BYTE*)this + 0x5C);
	FVector colorVec = (FVector)fadeColor;
	*(FVector*)((BYTE*)actor + 0x5F8) = colorVec;
	// Compute interpolation t.
	FLOAT StartPct  = *(FLOAT*)((BYTE*)this + 0x4C);
	FLOAT Duration  = *(FLOAT*)((BYTE*)this + 0x54);
	FLOAT t = (Pct - StartPct) / Duration;
	if (t < 0.0001f) t = 0.0001f;
	if (t > 1.0f)    t = 1.0f;
	if (*(BYTE*)((BYTE*)this + 0x2C) == 2) t = 1.0f;
	// bReversed: bit 0 of BYTE at this+0x58 inverts alpha
	if (*(BYTE*)((BYTE*)this + 0x58) & 1) t = 1.0f - t;
	*(FLOAT*)((BYTE*)actor + 0x5EC) = t;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x1041e7b0)
FString USubActionFade::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	const TCHAR* dir = (*(BYTE*)((BYTE*)this + 0x58) & 1) ? TEXT("In") : TEXT("Out");
	FString extra = FString::Printf(TEXT("Fade [%s], Color : %d,%d,%d\n"),
		dir,
		(DWORD)((BYTE*)this)[0x5e],
		(DWORD)((BYTE*)this)[0x5d],
		(DWORD)((BYTE*)this)[0x5c]);
	result += *extra;
	return result;
}


// --- USubActionGameSpeed ---
IMPL_MATCH("Engine.dll", 0x1041e640)
int USubActionGameSpeed::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11e640, 189b. Calls parent update; if running and manager available,
	// lerps SceneMgr's game-speed multiplier (SceneMgr+0x458 in LevelInfo at SceneMgr+0x144)
	// from saved start value (this+0x58) to end value (this+0x5C) over the sub-action duration.
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionGameSpeed*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	// Save start speed on first call (0.0 means not yet saved).
	FLOAT* SavedStart = (FLOAT*)((BYTE*)this + 0x58);
	FLOAT* EndSpeed   = (FLOAT*)((BYTE*)this + 0x5C);
	FLOAT  Duration   = *(FLOAT*)((BYTE*)this + 0x54);
	FLOAT  StartPct   = *(FLOAT*)((BYTE*)this + 0x4C);
	ALevelInfo* LI = *(ALevelInfo**)((BYTE*)mgr + 0x144);
	if (*SavedStart == 0.0f)
		*SavedStart = *(FLOAT*)((BYTE*)LI + 0x458);
	FLOAT t = (Pct - StartPct) / Duration;
	if (t < 0.0001f) t = 0.0001f;
	if (t > 1.0f)    t = 1.0f;
	if (*(BYTE*)((BYTE*)this + 0x2C) == 2) t = 1.0f; // ending: snap to end
	*(FLOAT*)((BYTE*)LI + 0x458) = (*EndSpeed - *SavedStart) * t + *SavedStart;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041e3c0)
FString USubActionGameSpeed::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	FString extra = FString::Printf(TEXT(", Start : %1.1f, End : %1.1f\n"),
		*(FLOAT*)((BYTE*)this + 0x58),
		*(FLOAT*)((BYTE*)this + 0x5c));
	result += *extra;
	return result;
}


// --- USubActionOrientation ---
IMPL_MATCH("Engine.dll", 0x1041e480)
int USubActionOrientation::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11e480, 4919. Calls parent; if running, gets scene manager via vtable+0x6C and
	// calls ASceneManager::ChangeOrientation with 0xD DWORDs (52b FOrientation) from this+0x58.
	// Immediately sets state=3 (done) to fire only once.
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionOrientation*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	// Copy 52 bytes (0xD DWORDs) from this+0x58 as the FOrientation struct and pass to ChangeOrientation.
	// FOrientation is forward-declared; pass by value via stack copy.
	struct { DWORD data[13]; } orient;
	appMemcpy(&orient, (BYTE*)this + 0x58, sizeof(orient));
	mgr->ChangeOrientation(*(FOrientation*)&orient);
	// Transition state to done (3) so this fires once.
	*(BYTE*)((BYTE*)this + 0x2C) = 3;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x1041d7e0)
void USubActionOrientation::PostLoad()
{
	guard(USubActionOrientation::PostLoad);
	// Retail: 0x11d7e0, 89b. Clear stale (pending-kill) UObject reference at +0x5c.
	UObject::PostLoad();
	if (*(INT*)((BYTE*)this + 0x5c) != 0 &&
	    *(char*)(*(INT*)((BYTE*)this + 0x5c) + 0xa0) < 0)
	{
		*(INT*)((BYTE*)this + 0x5c) = 0;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041e4e0)
FString USubActionOrientation::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	FString actorStr;
	if (*(INT*)((BYTE*)this + 0x58) == 1)
	{
		const TCHAR* actorName = TEXT("");
		UObject* actor = *(UObject**)((BYTE*)this + 0x5c);
		if (actor)
			actorName = actor->GetName();
		actorStr = FString::Printf(TEXT(" Actor : %s,"), actorName);
	}
	extern ENGINE_API FMatineeTools GMatineeTools;
	FString orientDesc = GMatineeTools.GetOrientationDesc(*(INT*)((BYTE*)this + 0x58));
	FString extra = FString::Printf(TEXT(", Orientation : %s,%s EaseInTime : %1.1f\n"),
		*orientDesc, *actorStr, *(FLOAT*)((BYTE*)this + 0x60));
	result += *extra;
	return result;
}

IMPL_MATCH("Engine.dll", 0x1041db10)
int USubActionOrientation::IsRunning()
{
	// Retail: 0x11db10, 20b. Returns 1 if not in editor AND state (this+0x2C) is 1 or 2 (running or ending).
	if (!GIsEditor) {
		BYTE state = *(BYTE*)((BYTE*)this + 0x2C);
		if (state == 1 || state == 2)
			return 1;
	}
	return 0;
}


// --- USubActionSceneSpeed ---
IMPL_MATCH("Engine.dll", 0x1041e700)
int USubActionSceneSpeed::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11e700, 173b. Same pattern as USubActionGameSpeed::Update but targets
	// SceneMgr's scene-speed multiplier at SceneMgr+0x3C8 (instead of LevelInfo+0x458).
	if (!UMatSubAction::Update(Pct, SceneMgr))
		return 0;
	typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionSceneSpeed*);
	ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
	if (!mgr)
		return 1;
	FLOAT* SavedStart = (FLOAT*)((BYTE*)this + 0x58);
	FLOAT* EndSpeed   = (FLOAT*)((BYTE*)this + 0x5C);
	FLOAT  Duration   = *(FLOAT*)((BYTE*)this + 0x54);
	FLOAT  StartPct   = *(FLOAT*)((BYTE*)this + 0x4C);
	if (*SavedStart == 0.0f)
		*SavedStart = *(FLOAT*)((BYTE*)mgr + 0x3C8);
	FLOAT t = (Pct - StartPct) / Duration;
	if (t < 0.0001f) t = 0.0001f;
	if (t > 1.0f)    t = 1.0f;
	if (*(BYTE*)((BYTE*)this + 0x2C) == 2) t = 1.0f;
	*(FLOAT*)((BYTE*)mgr + 0x3C8) = (*EndSpeed - *SavedStart) * t + *SavedStart;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1041e3c0)
FString USubActionSceneSpeed::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	FString extra = FString::Printf(TEXT(", Start : %1.1f, End : %1.1f\n"),
		*(FLOAT*)((BYTE*)this + 0x58),
		*(FLOAT*)((BYTE*)this + 0x5c));
	result += *extra;
	return result;
}


// --- USubActionTrigger ---
IMPL_MATCH("Engine.dll", 0x1041f090)
int USubActionTrigger::Update(float Pct, ASceneManager* SceneMgr)
{
	// Retail: 0x11f090, ordinal 4921 (74b). Calls base Update; if not running returns 0.
	// Gets scene manager via vtable+0x6C slot 27. If manager non-null, fires eventTriggerEvent
	// on the scene manager with trigger name (this+0x58), active actor pointer (mgr+0x3DC), and
	// a second name from mgr+0x3E0.
	INT ran = UMatSubAction::Update(Pct, SceneMgr);
	if (ran)
	{
		typedef ASceneManager* (__thiscall* GetSceneMgrFn)(USubActionTrigger*);
		ASceneManager* mgr = ((GetSceneMgrFn)(*(void***)this)[0x6C / 4])(this);
		if (!mgr)
			return 1;
		// eventTriggerEvent(FName, AActor*, APawn*)
		// mgr+0x3DC = active actor, mgr+0x3E0 = instigator (APawn*)
		((AActor*)SceneMgr)->eventTriggerEvent(
			*(FName*)((BYTE*)this + 0x58),
			*(AActor**)((BYTE*)mgr + 0x3DC),
			*(APawn**)((BYTE*)mgr + 0x3E0));
	}
	return 0;
}

IMPL_MATCH("Engine.dll", 0x1041e300)
FString USubActionTrigger::GetStatString()
{
	FString result = UMatSubAction::GetStatString();
	FString extra = FString::Printf(TEXT(", Event : %s\n"),
		**(FName*)((BYTE*)this + 0x58));
	result += *extra;
	return result;
}


// =============================================================================
// ASceneManager (moved from EngineClassImpl.cpp)
// =============================================================================

// ASceneManager
// =============================================================================

IMPL_MATCH("Engine.dll", 0x1041fa50)
void ASceneManager::PostEditChange()
{
	guard(ASceneManager::PostEditChange);
	Super::PostEditChange();
	PreparePath();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041fee0)
INT ASceneManager::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(ASceneManager::Tick);
	unsigned __int64 tsc = __rdtsc();
	INT tsc_lo = (INT)(tsc & 0xFFFFFFFF);

	INT result = AActor::Tick(DeltaTime, TickType);
	if (result == 0 && !(*(DWORD*)((BYTE*)this + 0x3c0) & 2))
		return 0;

	DWORD flags = *(DWORD*)((BYTE*)this + 0x3c0);
	if (flags & 2)
	{
		if (!(flags & 4))
		{
			*(DWORD*)((BYTE*)this + 0x3c0) = flags | 4;
			SceneStarted();
			if (*(INT*)((BYTE*)this + 0x3dc) == 0)
				return 1;

			BYTE* actionsBase = (BYTE*)this + 0x3a8;
			INT count = *(INT*)(actionsBase + 4);
			if (count != 0 && !(*(BYTE*)((BYTE*)this + 0x398) & 4))
			{
				INT firstAction = *(INT*)(*(INT*)actionsBase);
				if (*(INT*)(firstAction + 0x40) == 0)
					appFailAssert("Actions(0)->IntPoint", ".\\UnSceneManager.cpp", 0x19d);
				typedef void (__cdecl *Fn1)(DWORD, DWORD);
				((Fn1)0x1035a3d0)(0x3f800000, 0);
				INT iPoint = *(INT*)(firstAction + 0x40);
				BYTE checkBuf[48] = {};
				typedef void (__cdecl *MoveFn)(INT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, void*, INT, INT, INT, INT, INT);
				((MoveFn)(*(INT*)(*(INT*)((BYTE*)this + 0x328) + 0x98)))(
					*(INT*)((BYTE*)this + 0x3dc),
					0.0f, 0.0f, 0.0f,
					*(FLOAT*)(iPoint + 0x240), *(FLOAT*)(iPoint + 0x244), *(FLOAT*)(iPoint + 0x248),
					checkBuf, 0, 0, 0, 0, 0);
			}
		}
		else
		{
			if (*(INT*)((BYTE*)this + 0x464) == 0)
			{
				typedef void (__cdecl *Fn2)(FLOAT);
				((Fn2)0x1041e8d0)(DeltaTime);
			}
			*(FLOAT*)((BYTE*)this + 0x3d0) += DeltaTime * *(FLOAT*)((BYTE*)this + 0x3c8);
		}

		FLOAT pct = *(FLOAT*)((BYTE*)this + 0x3d0) / *(FLOAT*)((BYTE*)this + 0x3cc);
		*(FLOAT*)((BYTE*)this + 0x3c4) = pct;

		if (pct <= 1.0f)
		{
			INT actor = *(INT*)((BYTE*)this + 0x3dc);
			FLOAT oldX = *(FLOAT*)(actor + 0x234);
			FLOAT oldY = *(FLOAT*)(actor + 0x238);
			FLOAT oldZ = *(FLOAT*)(actor + 0x23c);
			UpdateViewerFromPct(pct);
			if (DeltaTime > 0.0f)
			{
				actor = *(INT*)((BYTE*)this + 0x3dc);
				FVector vel(
					(*(FLOAT*)(actor + 0x234) - oldX) / DeltaTime,
					(*(FLOAT*)(actor + 0x238) - oldY) / DeltaTime,
					(*(FLOAT*)(actor + 0x23c) - oldZ) / DeltaTime);
				*(FLOAT*)(actor + 0x24c) = vel.X;
				*(FLOAT*)(actor + 0x250) = vel.Y;
				*(FLOAT*)(actor + 0x254) = vel.Z;
			}
		}
		else
		{
			SceneEnded();
			FName emptyName(NAME_None);
			if (*(FName*)((BYTE*)this + 0x3a4) != emptyName)
			{
				eventTriggerEvent(*(FName*)((BYTE*)this + 0x3a4),
					*(AActor**)((BYTE*)this + 0x3dc),
					*(APawn**)((BYTE*)this + 0x3e0));
			}
			else
			{
				if (*(BYTE*)((BYTE*)this + 0x398) & 1)
				{
					eventTriggerEvent(*(FName*)((BYTE*)this + 0x19c),
						*(AActor**)((BYTE*)this + 0x3dc),
						*(APawn**)((BYTE*)this + 0x3e0));
				}
			}
		}
	}
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041fe20)
void ASceneManager::PostBeginPlay()
{
	guard(ASceneManager::PostBeginPlay);
	Super::PostBeginPlay();
	*(DWORD*)((BYTE*)this + 0x3DC) = 0;
	RegisterSceneManager(this);
	InitializeActions();
	PreparePath();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041e930)
void ASceneManager::CheckForErrors()
{
	guard(ASceneManager::CheckForErrors);
	if (*(BYTE*)((BYTE*)this + 0x398) & 4)
		return;
	BYTE* actionsBase = (BYTE*)this + 0x3a8;
	INT count = *(INT*)(actionsBase + 4);
	for (INT i = 0; i < count; i++)
	{
		INT action = *(INT*)(*(INT*)actionsBase + i * 4);
		if (*(INT*)(action + 0x40) == 0)
			GWarn->Logf(TEXT("Action found with NULL InterpolationPoint"));
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041ded0)
FLOAT ASceneManager::GetTotalSceneTime()
{
	guard(ASceneManager::GetTotalSceneTime);
	FLOAT total = 0.0f;
	BYTE* actionsBase = (BYTE*)this + 0x3a8;
	INT count = *(INT*)(actionsBase + 4);
	for (INT i = 0; i < count; i++)
	{
		INT action = *(INT*)(*(INT*)actionsBase + i * 4);
		total += *(FLOAT*)(action + 0x34);
	}
	return total;
	unguard;
}

// =============================================================================

// ASceneManager extra methods (from EngineClassImpl.cpp)

IMPL_EMPTY("close video no-op")
void AReplicationInfo::CloseVideo(UCanvas* Canvas)
{
}
IMPL_MATCH("Engine.dll", 0x1041dd70)
void ASceneManager::SetCurrentTime( FLOAT NewTime ) {
	// Retail: 42b. Stores raw time at this+0x3D0, clears reset counter at this+0x448,
	// then calls RefreshSubActions with time normalized by TotalSceneTime at this+0x3CC.
	*(FLOAT*)((BYTE*)this + 0x3D0) = NewTime;
	*(INT*)((BYTE*)this + 0x448) = 0;
	RefreshSubActions( NewTime / *(FLOAT*)((BYTE*)this + 0x3CC) );
}
IMPL_MATCH("Engine.dll", 0x1041f400)
void ASceneManager::SetSceneStartTime()
{
	guard(ASceneManager::SetSceneStartTime);
	RegisterSceneManager(this);

	FLOAT totalSceneTime = GetTotalSceneTime();
	*(FLOAT*)((BYTE*)this + 0x3CC) = totalSceneTime;
	if (!GIsEditor)
		*(FLOAT*)((BYTE*)this + 0x3D0) = 0.0f;

	TArray<UMatSubAction*>& SceneSubActions = *(TArray<UMatSubAction*>*)((BYTE*)this + 0x3F0);
	SceneSubActions.Empty();

	FLOAT actionTime = 0.0f;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)this + 0x3A8);
	for (INT actionIndex = 0; actionIndex < Actions.Num(); ++actionIndex)
	{
		UMatAction* Action = Actions(actionIndex);
		*(FLOAT*)((BYTE*)Action + 0x78) = actionTime / totalSceneTime;

		FLOAT actionEndPct = (actionTime + *(FLOAT*)((BYTE*)Action + 0x34)) / totalSceneTime;
		*(FLOAT*)((BYTE*)Action + 0x7C) = actionEndPct;
		*(FLOAT*)((BYTE*)Action + 0x80) = actionEndPct - *(FLOAT*)((BYTE*)Action + 0x78);

		TArray<UMatSubAction*>& ActionSubActions = *(TArray<UMatSubAction*>*)((BYTE*)Action + 0x48);
		for (INT subIndex = 0; subIndex < ActionSubActions.Num(); ++subIndex)
		{
			UMatSubAction* SubAction = ActionSubActions(subIndex);
			*(ASceneManager**)((BYTE*)SubAction + 0x3C) = this;

			if (GIsEditor)
				SubAction->PreBeginPreview();

			*(BYTE*)((BYTE*)SubAction + 0x2C) = 0;
			*(FLOAT*)((BYTE*)SubAction + 0x4C) =
				(actionTime + *(FLOAT*)((BYTE*)SubAction + 0x30)) / totalSceneTime;

			FLOAT subEndPct =
				(actionTime + *(FLOAT*)((BYTE*)SubAction + 0x30) + *(FLOAT*)((BYTE*)SubAction + 0x34)) /
				totalSceneTime;
			*(FLOAT*)((BYTE*)SubAction + 0x50) = subEndPct;
			*(FLOAT*)((BYTE*)SubAction + 0x54) = subEndPct - *(FLOAT*)((BYTE*)SubAction + 0x4C);

			if (SubAction->IsA(USubActionOrientation::StaticClass()))
			{
				*(UMatSubAction**)((BYTE*)SubAction + 0x70) = SubAction;
				*(FLOAT*)((BYTE*)SubAction + 0x74) = *(FLOAT*)((BYTE*)SubAction + 0x4C);

				FLOAT easeInEndPct =
					*(FLOAT*)((BYTE*)SubAction + 0x4C) + (*(FLOAT*)((BYTE*)SubAction + 0x60) / totalSceneTime);
				*(FLOAT*)((BYTE*)SubAction + 0x78) = easeInEndPct;
				*(FLOAT*)((BYTE*)SubAction + 0x7C) = easeInEndPct - *(FLOAT*)((BYTE*)SubAction + 0x74);
			}

			SceneSubActions.AddItem(SubAction);
		}

		actionTime += *(FLOAT*)((BYTE*)Action + 0x34);
	}
	unguard;
}

// =============================================================================
// --- AInterpolationPoint ---
IMPL_MATCH("Engine.dll", 0x1040ba00)
void AInterpolationPoint::RenderEditorSelected(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AInterpolationPoint::RenderEditorSelected);
	// Retail 0x1040ba00 (2837 bytes, ordinal 4303): draws an editor-only wireframe
	// frustum in front of the interpolation point.  The near face sits 24 units
	// down the local X axis with 32-unit half-extent; the far face sits 128 units
	// down local X with 64-unit half-extent.

	FLineBatcher Lines(RI, 1, 0);

	FCoords Coords = GMath.UnitCoords / Rotation;
	FVector XAxis = Coords.XAxis;
	FVector YAxis = Coords.YAxis;
	FVector ZAxis = Coords.ZAxis;
	FVector NegY  = FVector(-YAxis.X, -YAxis.Y, -YAxis.Z);
	FVector NegZ  = FVector(-ZAxis.X, -ZAxis.Y, -ZAxis.Z);
	FVector NearCenter = Location + XAxis * 24.0f;
	FVector FarCenter  = Location + XAxis * 128.0f;

	FVector Dir0 = (ZAxis + NegY).SafeNormal(); // Z - Y
	FVector Dir1 = (ZAxis - NegY).SafeNormal(); // Z + Y
	FVector Dir2 = (NegZ - NegY).SafeNormal();  // -Z + Y
	FVector Dir3 = (NegZ + NegY).SafeNormal();  // -Z - Y

	FVector V0 = NearCenter + Dir0 * 32.0f;
	FVector V1 = NearCenter + Dir1 * 32.0f;
	FVector V2 = NearCenter + Dir2 * 32.0f;
	FVector V3 = NearCenter + Dir3 * 32.0f;
	FVector V4 = FarCenter + Dir0 * 64.0f;
	FVector V5 = FarCenter + Dir1 * 64.0f;
	FVector V6 = FarCenter + Dir2 * 64.0f;
	FVector V7 = FarCenter + Dir3 * 64.0f;

	FColor White(0xFFFFFFFF);

	// Inner face
	Lines.DrawLine(V0, V1, White);
	Lines.DrawLine(V1, V2, White);
	Lines.DrawLine(V2, V3, White);
	Lines.DrawLine(V3, V0, White);

	// Outer face
	Lines.DrawLine(V4, V5, White);
	Lines.DrawLine(V5, V6, White);
	Lines.DrawLine(V6, V7, White);
	Lines.DrawLine(V7, V4, White);

	// Connecting edges
	Lines.DrawLine(V0, V4, White);
	Lines.DrawLine(V1, V5, White);
	Lines.DrawLine(V2, V6, White);
	Lines.DrawLine(V3, V7, White);

	AActor::RenderEditorSelected(SceneNode, RI, DA);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041fbd0)
void AInterpolationPoint::PostEditChange()
{
	guard(AInterpolationPoint::PostEditChange);
	// Ghidra 0x11fbd0: notify parent and scene manager of property change
	AActor::PostEditChange();
	extern ENGINE_API FMatineeTools GMatineeTools;
	ASceneManager* SM = GMatineeTools.GetCurrent();
	if (SM)
		SM->PreparePath();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1041fc50)
void AInterpolationPoint::PostEditMove()
{
	guard(AInterpolationPoint::PostEditMove);
	// Ghidra 0x11fc50: notify scene manager when interpolation point is moved
	extern ENGINE_API FMatineeTools GMatineeTools;
	ASceneManager* SM = GMatineeTools.GetCurrent();
	if (SM)
		SM->PreparePath();
	unguard;
}



// ============================================================================
// FMatineeTools simple implementations / ECLipSynchData
// (moved from EngineStubs.cpp)
// ============================================================================

// ??1FMatineeTools@@UAE@XZ
IMPL_EMPTY("FMatineeTools destructor no-op")
FMatineeTools::~FMatineeTools() {}

// ?GetCurrent@FMatineeTools@@QAEPAVASceneManager@@XZ
IMPL_MATCH("Engine.dll", 0x10316710)
ASceneManager * FMatineeTools::GetCurrent() { return CurrentScene; }

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@PAV2@@Z
IMPL_MATCH("Engine.dll", 0x103ca220)
ASceneManager * FMatineeTools::SetCurrent(UEngine * Engine, ULevel * Level, ASceneManager * Scene)
{
	guard(FMatineeTools::SetCurrent);
	CurrentScene = Scene;
	if (Scene)
	{
		TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
		if (Actions.Num() > 0)
			SetCurrentAction(Actions(0));
		else
		{
			CurrentAction = NULL;
			CurrentSubAction = NULL;
		}
	}
	else
	{
		CurrentAction = NULL;
		CurrentSubAction = NULL;
	}
	return Scene;
	unguard;
}

// ?SetCurrent@FMatineeTools@@QAEPAVASceneManager@@PAVUEngine@@PAVULevel@@VFString@@@Z
IMPL_MATCH("Engine.dll", 0x103ca220)
ASceneManager * FMatineeTools::SetCurrent(UEngine * Engine, ULevel * Level, FString Name)
{
	guard(FMatineeTools::SetCurrent);
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* Actor = Level->Actors(i);
		if (Actor && Actor->IsA(ASceneManager::StaticClass()))
		{
			if (FString(Actor->GetName()) == Name)
				return SetCurrent(Engine, Level, (ASceneManager*)Actor);
		}
	}
	return SetCurrent(Engine, Level, (ASceneManager*)NULL);
	unguard;
}

// ?GetOrientationDesc@FMatineeTools@@QAE?AVFString@@H@Z
IMPL_MATCH("Engine.dll", 0x103c98a0)
FString FMatineeTools::GetOrientationDesc(int p0)
{
	const TCHAR* desc;
	if      (p0 == 1) desc = TEXT("Look at Actor");
	else if (p0 == 2) desc = TEXT("Face Path");
	else if (p0 == 3) desc = TEXT("Interpolation");
	else if (p0 == 4) desc = TEXT("Dolly");
	else              desc = TEXT("None");
	return FString(desc);
}

// ??4ECLipSynchData@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x10303890)
ECLipSynchData & ECLipSynchData::operator=(ECLipSynchData const & Other) {
	// Ghidra 0x3890: copies 6 DWORDs (24 bytes); shares address with FCanvasVertex/FStaticMeshVertex op=
	appMemcpy(this, &Other, 24);
	return *this;
}

// --- Moved from EngineStubs.cpp ---
// ?GetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@XZ
// Ghidra 0x10316720: returns *(this+0x44).
IMPL_MATCH("Engine.dll", 0x10316720)
UMatAction * FMatineeTools::GetCurrentAction() { return CurrentAction; }

// ?GetNextAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx+1] wrapping to [0].
IMPL_MATCH("Engine.dll", 0x103c9ac0)
UMatAction * FMatineeTools::GetNextAction(ASceneManager * Scene, UMatAction * Current)
{
	guard(FMatineeTools::GetNextAction);
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	return Actions((Idx + 1) % Count);
	unguard;
}

// ?GetNextMovementAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: calls GetNextAction in a loop until the action IsA(UActionMoveCamera).
IMPL_MATCH("Engine.dll", 0x103ca080)
UMatAction * FMatineeTools::GetNextMovementAction(ASceneManager * Scene, UMatAction * Current)
{
	guard(FMatineeTools::GetNextMovementAction);
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	UMatAction* Candidate = GetNextAction(Scene, Current);
	INT Guard = Count; // prevent infinite loop if no move action exists
	while (Guard-- > 0 && Candidate && Candidate != Current)
	{
		if (Candidate->IsA(UActionMoveCamera::StaticClass()))
			return Candidate;
		Candidate = GetNextAction(Scene, Candidate);
	}
	return NULL;
	unguard;
}

// ?GetPrevAction@FMatineeTools@@QAEPAVUMatAction@@PAVASceneManager@@PAV2@@Z
// Ghidra: GetActionIdx, return [idx-1] wrapping to [last].
IMPL_MATCH("Engine.dll", 0x103c9b90)
UMatAction * FMatineeTools::GetPrevAction(ASceneManager * Scene, UMatAction * Current)
{
	guard(FMatineeTools::GetPrevAction);
	if (!Scene) return NULL;
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)Scene + 0x3A8);
	INT Count = Actions.Num();
	if (Count == 0) return NULL;
	INT Idx = GetActionIdx(Scene, Current);
	INT Prev = (Idx <= 0) ? Count - 1 : Idx - 1;
	return Actions(Prev);
	unguard;
}

// ?SetCurrentAction@FMatineeTools@@QAEPAVUMatAction@@PAV2@@Z
// Ghidra: sets CurrentAction, primes CurrentSubAction from SubActions[0] if available.
IMPL_MATCH("Engine.dll", 0x1031ca40)
UMatAction * FMatineeTools::SetCurrentAction(UMatAction * Action)
{
	CurrentAction = Action;
	if (Action)
	{
		TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)Action + 0x48);
		CurrentSubAction = SubActions.Num() > 0 ? SubActions(0) : NULL;
	}
	else
	{
		CurrentSubAction = NULL;
	}
	return CurrentAction;
}

// ?GetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@XZ
// Ghidra 0x10316740: returns *(this+0x48).
IMPL_MATCH("Engine.dll", 0x10316740)
UMatSubAction * FMatineeTools::GetCurrentSubAction() { return CurrentSubAction; }

// ?SetCurrentSubAction@FMatineeTools@@QAEPAVUMatSubAction@@PAV2@@Z
// Ghidra: stores SubAction at this+0x48 and returns it.
IMPL_MATCH("Engine.dll", 0x10316730)
UMatSubAction * FMatineeTools::SetCurrentSubAction(UMatSubAction * SubAction)
{
	CurrentSubAction = SubAction;
	return SubAction;
}


// ?GetActionIdx@FMatineeTools@@QAEHPAVASceneManager@@PAVUMatAction@@@Z
IMPL_MATCH("Engine.dll", 0x103c9960)
int FMatineeTools::GetActionIdx(ASceneManager* SM, UMatAction* Action)
{
	guard(FMatineeTools::GetActionIdx);
	if (!SM)
		return -1;
	// ASceneManager + 0x3A8 = TArray<UMatAction*> Actions
	TArray<UMatAction*>& Actions = *(TArray<UMatAction*>*)((BYTE*)SM + 0x3A8);
	for (INT i = 0; i < Actions.Num(); i++)
	{
		if (Actions(i) == Action)
			return i;
	}
	return -1;
	unguard;
}

// ?GetPathStyle@FMatineeTools@@QAEHPAVUMatAction@@@Z
IMPL_MATCH("Engine.dll", 0x103ca030)
int FMatineeTools::GetPathStyle(UMatAction* Action)
{
	if (Action)
	{
		if (Action->IsA(UActionPause::StaticClass()))
			return 0;
		if (Action->IsA(UActionMoveCamera::StaticClass()))
			return *((BYTE*)Action + 0x90);
	}
	return *((BYTE*)Action + 0x90);
}

// ?GetSubActionIdx@FMatineeTools@@QAEHPAVUMatSubAction@@@Z
IMPL_MATCH("Engine.dll", 0x103c9a10)
int FMatineeTools::GetSubActionIdx(UMatSubAction* SubAction)
{
	guard(FMatineeTools::GetSubActionIdx);
	if (!CurrentAction)
		return -1;
	// UMatAction + 0x48 = TArray<UMatSubAction*> SubActions
	TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)CurrentAction + 0x48);
	for (INT i = 0; i < SubActions.Num(); i++)
	{
		if (SubActions(i) == SubAction)
			return i;
	}
	return -1;
	unguard;
}
// ?m_vStartLipsynch@ECLipSynchData@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x10354bd0)
void ECLipSynchData::m_vStartLipsynch()
{
	bPlaying = 1;
}

// ?m_vStopLipsynch@ECLipSynchData@@QAEXXZ
IMPL_EMPTY("lip sync stop no-op")
void ECLipSynchData::m_vStopLipsynch() {}

// ?m_vUpdateBonesCompressed@ECLipSynchData@@QAEXH@Z
IMPL_EMPTY("compressed bone update no-op")
void ECLipSynchData::m_vUpdateBonesCompressed(int p0) {}

// ?m_vUpdateBonesCompressed_BoneView@ECLipSynchData@@QAEXH@Z
IMPL_EMPTY("bone-view compressed update no-op")
void ECLipSynchData::m_vUpdateBonesCompressed_BoneView(int p0) {}

// ?m_vUpdateBonesCompressed_PhonemsSeq@ECLipSynchData@@QAEXH@Z
IMPL_EMPTY("phonemes-sequence compressed update no-op")
void ECLipSynchData::m_vUpdateBonesCompressed_PhonemsSeq(int p0) {}

// ?m_vUpdateLipSynch@ECLipSynchData@@QAEXM@Z
IMPL_EMPTY("lip sync per-frame update no-op")
void ECLipSynchData::m_vUpdateLipSynch(float p0) {}
// ?GetSamples@FMatineeTools@@QAEXPAVASceneManager@@PAVUMatAction@@PAV?$TArray@VFVector@@@@@Z
IMPL_EMPTY("path samples collection no-op")
void FMatineeTools::GetSamples(ASceneManager * p0, UMatAction * p1, TArray<FVector> * p2) {}

// ?Init@FMatineeTools@@QAEXXZ
IMPL_EMPTY("FMatineeTools initialization no-op")
void FMatineeTools::Init() {}
