/*=============================================================================
	UnScript.cpp: Engine-side animation notify system (UAnimNotify*)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- UAnimNotify ---
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

void UAnimNotify::PostEditChange()
{
	// Retail: FF 41 2C C3 = INC [ECX+0x2C]; RET — increments Revision counter
	Revision++;
}


// --- UAnimNotify_DestroyEffect ---
// GHIDRA REF: 0x136ec0 (~120 bytes)
// Iterates XLevel->Actors in reverse; for each actor whose Owner == Owner and
// Tag == DestroyTag: if bExpireParticles, tries to expire via AEmitter vtable;
// otherwise calls ULevel::DestroyActor(actor, 0).
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

		if (bExpireParticles)
		{
			// DIVERGENCE: retail casts to AEmitter (FUN_1037a3e0) and calls
			// vtable[0x63] to let the emitter finish its cycle.  We fall back to
			// immediate DestroyActor because we cannot safely cast without the full
			// AEmitter vtable layout.
			Level->DestroyActor(Actor, 0);
		}
		else
		{
			Level->DestroyActor(Actor, 0);
		}
	}

	unguard;
}


// --- UAnimNotify_Effect ---
// GHIDRA REF: 0x136b20 (~875 bytes)
// Spawns EffectClass at Owner's location/rotation, optionally attached to a
// bone.  Body involves FCoords rotation construction from bone transform,
// bone-relative offsets, and SpawnActor — complex enough that reconstruction
// risks subtle divergence in coordinate-frame math.
// DIVERGENCE: spawn omitted; the effect simply doesn't play.
void UAnimNotify_Effect::Notify(UMeshInstance* /*MI*/, AActor* /*Owner*/)
{
	guard(UAnimNotify_Effect::Notify);
	// DIVERGENCE: see comment above.
	unguard;
}


// --- UAnimNotify_MatSubAction ---
// GHIDRA REF: 0x136fe0
// Finds the first live ASceneManager in XLevel->Actors and calls
// SubAction->Start() on it, adjusting start/end times relative to the scene
// manager's current play position and total duration.
// DIVERGENCE: ASceneManager vtable layout not fully reconstructed; omitted.
void UAnimNotify_MatSubAction::Notify(UMeshInstance* /*MI*/, AActor* /*Owner*/)
{
	guard(UAnimNotify_MatSubAction::Notify);
	// DIVERGENCE: see comment above.
	unguard;
}


// --- UAnimNotify_Script ---
// 0x130120 — calls a named UnrealScript function (NotifyName) on the
// owning actor via FindFunction / ProcessEvent.  Skipped in editor.
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
void UAnimation::Serialize(FArchive &)
{
}

