/*=============================================================================
	UnScript.cpp: Engine-side animation notify system (UAnimNotify*)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- UAnimNotify ---
IMPL_EMPTY("UAnimNotify base Notify — retail body is empty; subclasses override")
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

IMPL_MATCH("Engine.dll", 0x10430110)
void UAnimNotify::PostEditChange()
{
	// Retail: FF 41 2C C3 = INC [ECX+0x2C]; RET — increments Revision counter
	Revision++;
}


// Ghidra 0x10436EC0 — iterates XLevel->Actors, destroys/expires particle actors owned
// by Owner whose Tag matches DestroyTag.  bExpireParticles path: retail uses
// FUN_1037a3e0 to cast to AEmitter* then calls vtable[0x18C/4] to let the emitter
// expire naturally.  We replicate using IsA(AEmitter) + raw vtable dispatch, which
// is semantically identical but differs at the machine-code level.
IMPL_DIVERGE("permanent: FUN_1037a3e0 is an unexported type-cast helper; we use IsA(AEmitter::StaticClass()) as equivalent type check — functionally identical but different bytecode")
void UAnimNotify_DestroyEffect::Notify(UMeshInstance* /*MI*/, AActor* Owner)
{
	guard(UAnimNotify_DestroyEffect::Notify);

	if (DestroyTag == NAME_None)
		return;
	if (!Owner || !Owner->XLevel)
		return;

	ULevel* Level = Owner->XLevel;

	for (INT i = Level->Actors.Num() - 1; i >= 0; i--)
	{
		AActor* Actor = Level->Actors(i);
		if (!Actor) continue;
		if (Actor->Owner != Owner) continue;
		if (Actor->Tag != DestroyTag) continue;

		if (bExpireParticles && Actor->IsA(AEmitter::StaticClass()))
		{
			// Retail: FUN_1037a3e0(actor) casts to AEmitter*, then calls vtable[0x18C/4]
			// (expire method) to let the emitter finish its cycle rather than destroying it.
			typedef void (__thiscall* EmitterExpireFn)(AActor*);
			void** vtbl = *(void***)Actor;
			EmitterExpireFn fn = (EmitterExpireFn)(vtbl[0x18C / sizeof(void*)]);
			fn(Actor);
			continue;
		}
		Level->DestroyActor(Actor, 0);
	}

	unguard;
}


// Retail 0x10436B20 (875 bytes): spawns Effect actor at owner's location,
// optionally offset through a bone FCoords transform.
// If Bone != NAME_None and MI is a USkeletalMeshInstance and !bAttach,
// transforms OffsetLocation through the bone's world FCoords (inverted).
// Otherwise (Bone==None): transforms through GMath.UnitCoords/SpawnRot.
// Goto path (Bone!=None, no MI, or bAttach): spawn at Owner location/rotation unchanged.
// After spawn: copies Tag, DrawScale, DrawScale3D; if bAttach calls AttachToBone.
IMPL_MATCH("Engine.dll", 0x10436b20)
void UAnimNotify_Effect::Notify(UMeshInstance* MI, AActor* Owner)
{
	guard(UAnimNotify_Effect::Notify);

	// Ghidra: early out if EffectClass == null (this+0x40)
	if (!EffectClass)
		return;

	// In editor: log effect class name
	if (GIsEditor)
	{
		GLog->Logf(TEXT("%s"), EffectClass->GetName());
	}

	// Copy Owner location/rotation as spawn base
	FVector  SpawnLoc = Owner->Location;
	FRotator SpawnRot = Owner->Rotation;

	// Check if MI is a USkeletalMeshInstance
	UBOOL bSkelMesh = MI && MI->IsA(USkeletalMeshInstance::StaticClass());

	if (Bone == NAME_None)
	{
		// No bone: transform OffsetLocation through (UnitCoords / SpawnRot)
		FCoords Coords = GMath.UnitCoords / SpawnRot;
		SpawnLoc += OffsetLocation.TransformVectorBy(Coords);
		SpawnRot = Coords.OrthoRotation();
	}
	else if (bSkelMesh && !bAttach)
	{
		// Bone specified, skeletal mesh, not attaching: get bone world FCoords
		INT BoneIdx = ((USkeletalMeshInstance*)MI)->MatchRefBone(Bone);
		FCoords BoneCoords = ((USkeletalMeshInstance*)MI)->GetBoneCoords((DWORD)BoneIdx, 0);
		BoneCoords = BoneCoords.Inverse();
		SpawnLoc += OffsetLocation.TransformVectorBy(BoneCoords);
		SpawnRot = BoneCoords.OrthoRotation();
	}
	// else: Bone!=None but no MI or bAttach — SpawnLoc/SpawnRot unchanged (goto LAB_10436d52)

	// SpawnActor at the computed position
	AActor* Spawned = NULL;
	if (Owner && Owner->XLevel)
	{
		Spawned = Owner->XLevel->SpawnActor(EffectClass, NAME_None, SpawnLoc, SpawnRot);
	}

	if (Spawned)
	{
		// Copy Tag if not NAME_None (Ghidra: iVar3+0x19c)
		if (Tag != NAME_None)
			*(FName*)((BYTE*)Spawned + 0x19c) = Tag;

		// Copy DrawScale and DrawScale3D (Ghidra: +0xe0, +700, +0x2c0, +0x2c4)
		*(FLOAT*)((BYTE*)Spawned + 0xe0)  = DrawScale;
		*(FLOAT*)((BYTE*)Spawned + 700)   = DrawScale3D.X;
		*(FLOAT*)((BYTE*)Spawned + 0x2c0) = DrawScale3D.Y;
		*(FLOAT*)((BYTE*)Spawned + 0x2c4) = DrawScale3D.Z;

		// Bone attachment: if bAttach AND MI has a valid bone
		if (bAttach && MI)
		{
			if (Bone != NAME_None)
			{
				Owner->AttachToBone(Spawned, Bone);
				// Copy RelativeLocation and RelativeRotation (Ghidra: +0x264/0x270)
				*(FVector*)((BYTE*)Spawned + 0x264) = OffsetLocation;
				*(FRotator*)((BYTE*)Spawned + 0x270) = OffsetRotation;
			}
		}

		if (GIsEditor)
			LastSpawnedEffect = Spawned;
	}

	unguard;
}


// --- UAnimNotify_MatSubAction ---
// Retail 0x10436FE0 (418 bytes): skips in editor.  Finds the first live, active
// ASceneManager in XLevel->Actors (forward scan: skips null / bDeleteMe / !IsA /
// !bActive actors).  If found, appends SubAction to SceneMgr->SubActions (at +0x3F0),
// then sets SubAction startPct (+0x4C), endPct (+0x50) and length (+0x54) from
// SceneMgr->curTime (+0x3D0) and SceneMgr->duration (+0x3CC), and marks
// SubAction->state (+0x2C) = 1.  Retail also calls GetName three times and logs via
// Logf with a format string stored at binary offset 0x2F8 — permanently omitted.
// DIVERGE: retail also doesn't null-check param_2 (Owner) before accessing XLevel;
// we add a null-safety check. Log calls omitted (binary-specific format string).
IMPL_DIVERGE("retail Logf at binary offset 0x2F8 permanently absent; null-safety check on Owner added (Ghidra 0x10436fe0)")
void UAnimNotify_MatSubAction::Notify(UMeshInstance* /*MI*/, AActor* Owner)
{
	guard(UAnimNotify_MatSubAction::Notify);

	if (GIsEditor)
		return;
	if (!SubAction || !Owner || !Owner->XLevel)
		return;

	ULevel* Level = Owner->XLevel;

	// Forward scan: find first live, active ASceneManager.
	ASceneManager* SceneMgr = NULL;
	for (INT i = 0; i < Level->Actors.Num(); i++)
	{
		AActor* a = Level->Actors(i);
		if (!a) continue;
		if (*(BYTE*)((BYTE*)a + 0xa0) & 0x80) continue;          // bDeleteMe
		if (!a->IsA(ASceneManager::StaticClass())) continue;
		if (!(*(BYTE*)((BYTE*)a + 0x3c0) & 0x02)) continue;      // !bActive
		SceneMgr = (ASceneManager*)a;
		break;
	}

	if (SceneMgr)
	{
		TArray<UMatSubAction*>& SubActions = *(TArray<UMatSubAction*>*)((BYTE*)SceneMgr + 0x3F0);
		INT idx = SubActions.Add(1);
		SubActions(idx) = SubAction;

		FLOAT curTime  = *(FLOAT*)((BYTE*)SceneMgr + 0x3D0);   // SceneMgr->curTime
		FLOAT duration = *(FLOAT*)((BYTE*)SceneMgr + 0x3CC);   // SceneMgr->duration
		FLOAT subDur   = *(FLOAT*)((BYTE*)SubAction + 0x34);   // SubAction->duration

		*(FLOAT*)((BYTE*)SubAction + 0x4C) = curTime / duration;
		*(FLOAT*)((BYTE*)SubAction + 0x50) = (subDur + curTime) / duration;
		*(FLOAT*)((BYTE*)SubAction + 0x54) = *(FLOAT*)((BYTE*)SubAction + 0x50)
		                                   - *(FLOAT*)((BYTE*)SubAction + 0x4C);
		*(BYTE*) ((BYTE*)SubAction + 0x2C) = 1;                // state = in-range
	}

	unguard;
}


// --- UAnimNotify_Script ---
// 0x130120 — calls a named UnrealScript function (NotifyName) on the
// owning actor via FindFunction / ProcessEvent.  Skipped in editor.
IMPL_MATCH("Engine.dll", 0x10430120)
void UAnimNotify_Script::Notify(UMeshInstance* /*MI*/, AActor* Owner)
{
	guard(UAnimNotify_Script::Notify);

	if (NotifyName != NAME_None)
	{
		if (!GIsEditor)
		{
			UFunction* Func = Owner->FindFunction(NotifyName, 0);
			if (Func != NULL)
			{
				Owner->ProcessEvent(Func, NULL, NULL);
				return;
			}
		}
		else
		{
			// Editor mode: just log that the notify fired.
			GLog->Logf(NAME_Log, TEXT("%s"), *NotifyName);
		}
	}

	unguard;
}


// --- UAnimNotify_Scripted ---
// 0x135380 — calls the UnrealScript "Notify" event on the UAnimNotify_Scripted
// object itself, passing Owner as the parameter.  Logs and skips in editor.
IMPL_MATCH("Engine.dll", 0x10435380)
void UAnimNotify_Scripted::Notify(UMeshInstance* /*MI*/, AActor* Owner)
{
	guard(UAnimNotify_Scripted::Notify);

	if (GIsEditor)
	{
		// Editor mode: log the notify object's name and return.
		GLog->Logf(NAME_Log, TEXT("%s"), *GetName());
		return;
	}

	// FindFunctionChecked will assert if "Notify" doesn't exist.
	UFunction* Func = FindFunctionChecked(ENGINE_Notify, 0);
	// Call ProcessEvent on *this*, passing &Owner as the params struct.
	// The UnrealScript Notify event signature is: function Notify(Actor Owner).
	ProcessEvent(Func, &Owner, NULL);

	unguard;
}


// --- UAnimNotify_Sound ---
// 0x135270 — plays Sound on Owner via the audio device obtained from
// Owner->XLevel->Engine.  The editor path logs the sound name and runs
// a short audio-device preview (vtable slots 0xC8 / 0xE0 — purpose unknown).
IMPL_MATCH("Engine.dll", 0x10435270)
void UAnimNotify_Sound::Notify(UMeshInstance* /*MI*/, AActor* Owner)
{
	guard(UAnimNotify_Sound::Notify);

	if (GIsEditor && Sound != NULL)
	{
		// Log the sound name.
		GLog->Logf(NAME_Log, TEXT("%s"), *Sound->GetName());

		// Audio-device preview calls — exact purpose unknown; raw vtable
		// dispatch preserved from Ghidra at offsets 0xC8 and 0xE0.
		// Chain: Owner->XLevel (0x328) -> Engine (0x44) -> AudioDevice (0x48)
		INT*  LevelPtr  = *(INT**)((BYTE*)Owner  + 0x328); // XLevel
		INT*  EnginePtr = *(INT**)((BYTE*)LevelPtr  + 0x44); // Engine
		INT** AudioDev  = *(INT***)((BYTE*)EnginePtr + 0x48); // AudioDevice
		if (AudioDev != NULL)
		{
			// vtable[0xC8/4] — editor preview start (arg: Sound)
			(*(void(__cdecl**)(USound*))((BYTE*)*AudioDev + 0xC8))(Sound);
			// vtable[0xE0/4] — editor preview stop (no args)
			(*(void(__cdecl**)())((BYTE*)*AudioDev + 0xE0))();
		}
	}

	// Runtime path: play through audio device (PlayActorSound at vtable 0x84).
	if (Sound != NULL && Owner != NULL)
	{
		INT*  LevelPtr  = *(INT**)((BYTE*)Owner  + 0x328); // XLevel
		INT*  EnginePtr = *(INT**)((BYTE*)LevelPtr  + 0x44); // Engine
		INT** AudioDev  = *(INT***)((BYTE*)EnginePtr + 0x48); // AudioDevice
		if (AudioDev != NULL)
		{
			// vtable[0x84/4] — PlayActorSound(Owner, Sound, slot=3, flags=0)
			(*(void(__cdecl**)(AActor*, USound*, INT, INT))((BYTE*)*AudioDev + 0x84))(Owner, Sound, 3, 0);
		}
	}

	unguard;
}


// --- UAnimation ---
IMPL_EMPTY("Ghidra lookup: UAnimation::Serialize not found in export — retail appears trivial")
void UAnimation::Serialize(FArchive &)
{
}

