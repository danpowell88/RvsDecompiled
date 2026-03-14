/*=============================================================================
	UnScript.cpp: Engine-side animation notify system (UAnimNotify*)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
IMPL_INFERRED("Reconstructed from context")
inline void* operator new(size_t, void* p) noexcept { return p; }
IMPL_INFERRED("Reconstructed from context")
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- UAnimNotify ---
IMPL_APPROX("Needs Ghidra analysis")
void UAnimNotify::Notify(UMeshInstance *,AActor *)
{
}

IMPL_INFERRED("Reconstructed from context")
void UAnimNotify::PostEditChange()
{
	// Retail: FF 41 2C C3 = INC [ECX+0x2C]; RET — increments Revision counter
	Revision++;
}


// DIVERGENCE: UAnimNotify_DestroyEffect::Notify — bExpireParticles path calls DestroyActor instead of AEmitter vtable[0x63] (cannot safely cast without full AEmitter vtable layout).
// GHIDRA REF: 0x136ec0 — iterates XLevel->Actors, destroys/expires particle actors
// owned by Owner whose Tag matches DestroyTag. Complex actor iteration + conditional
// ULevel::DestroyActor / UParticleEmitter::expire dispatch not yet reconstructed.
IMPL_INFERRED("Reconstructed from context")
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
IMPL_APPROX("Needs Ghidra analysis")
void UAnimNotify_Effect::Notify(UMeshInstance* /*MI*/, AActor* /*Owner*/)
{
	guard(UAnimNotify_Effect::Notify);
	// TODO: implement UAnimNotify_Effect::Notify (retail 0x136b20, 875 bytes: spawns Effect actor at Owner's location using FCoords rotation + SpawnActor)
	// GHIDRA REF: 0x136b20 — 875 bytes. Spawns the Effect actor (this->Effect at +0x40)
	// at Owner's location/rotation using FCoords rotation math and SpawnActor.
	// Full reconstruction requires FCoords helpers not yet available.
	unguard;
}


// TODO: implement UAnimNotify_MatSubAction::Notify (retail 0x136fe0: finds live ASceneManager in XLevel->Actors, starts SubAction)
// GHIDRA REF: 0x136fe0 — finds a live ASceneManager in XLevel->Actors and starts
// the SubAction on it, adjusting start/end times from scene manager position.
IMPL_APPROX("Needs Ghidra analysis")
void UAnimNotify_MatSubAction::Notify(UMeshInstance* /*MI*/, AActor* /*Owner*/)
{
	guard(UAnimNotify_MatSubAction::Notify);
	// TODO: see TODO above
	unguard;
}


// --- UAnimNotify_Script ---
// 0x130120 — calls a named UnrealScript function (NotifyName) on the
// owning actor via FindFunction / ProcessEvent.  Skipped in editor.
IMPL_INFERRED("Reconstructed from context")
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
IMPL_INFERRED("Reconstructed from context")
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
IMPL_INFERRED("Reconstructed from context")
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
IMPL_APPROX("Needs Ghidra analysis")
void UAnimation::Serialize(FArchive &)
{
}

