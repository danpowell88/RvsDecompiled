/*=============================================================================
	UnAudio.cpp: UAudioSubsystem, USound class registration.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() for audio-related classes so the Unreal
	class/property system can find them at load time. Currently just
	registrations — decompiled method bodies will be added here as the
	audio subsystem is reverse-engineered.

	This file is permanent and will grow as audio code is decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UAudioSubsystem);
IMPLEMENT_CLASS(USound);
IMPLEMENT_CLASS(UMusic);

// =============================================================================
// Stubs imported from EngineStubs.cpp during file reorganization.
// These will be replaced with full implementations as decompilation progresses.
// =============================================================================
#pragma optimize("", off)

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- USound ---
void USound::PostLoad()
{
	// Ghidra 0x7eee0: UObject::PostLoad, then if Audio exists call vtable[0x70/4] to
	// register the sound with the audio subsystem, then a small cleanup helper.
	UObject::PostLoad();
	if (Audio != NULL)
	{
		INT vt = *(INT*)(void*)Audio;
		typedef void (__thiscall *RegisterFn)(UAudioSubsystem*, USound*);
		((RegisterFn)(*(INT*)(vt + 0x70)))(Audio, this);
	}
	// NOTE: Divergence — FUN_1037ef65() cleanup helper skipped (not identified).
}

void USound::PS2Convert()
{
	guard(USound::PS2Convert);
	// Retail 0x7ef80: calls FUN_1037efde() (PS2-format helper).
	typedef void (__cdecl *PS2Fn)();
	((PS2Fn)0x1037efde)();
	unguard;
}

USound::USound(const TCHAR* InName, INT InFlags)
{
	guard(USound::USound);
	// Retail 0x21220: named-sound constructor (170 bytes).
	// Initialises FSoundData vtable at +0x2c, FArray at +0x38,
	// FName at +0x48, FStrings at +0x4c/+0x70; copies InName to +0x4c,
	// stores InFlags|4 at +0x64, clears +0x60, sets +0x5c = 1.0f.
	// Divergence: fields not declared in stripped header; raw init omitted.
	unguard;
}

// (merged from earlier occurrence)
void USound::Serialize(FArchive& Ar)
{
	// Retail: 0x1037fe10. Calls UObject::Serialize, then serializes FSoundData at +0x48.
	// FSoundData serialization uses internal helpers. Divergence: base class only;
	// raw sound data is loaded directly from the .u package stream.
	UObject::Serialize(Ar);
}
void USound::Destroy()
{
	// Retail: 0x1037ee40. Notifies global audio subsystem (at 0x10666b58) to release
	// any cached/playing references to this sound, via vtbl[0x1D](audioSys, this).
	// Then calls UObject::Destroy.
	void* audioSys = *(void**)0x10666b58;
	if (audioSys)
	{
		typedef void (__thiscall *SoundDestroyedFn)(void*, USound*);
		SoundDestroyedFn fn = (SoundDestroyedFn)((*(void***)audioSys)[0x74 / 4]);
		fn(audioSys, this);
	}
	UObject::Destroy();
}
float USound::GetDuration()
{
	// Ghidra: Duration at offset 0x5C, FSoundData at offset 0x2C.
	// Lazy-init: if Duration < 0, compute via FSoundData::GetPeriod.
	FLOAT& Duration = *(FLOAT*)((BYTE*)this + 0x5C);
	if (Duration < 0.0f)
	{
		FSoundData* SoundData = (FSoundData*)((BYTE*)this + 0x2C);
		Duration = SoundData->GetPeriod();
	}
	return Duration;
}


// --- UI3DL2Listener ---
void UI3DL2Listener::PostEditChange()
{
	// Retail: 30b. Call UObject::PostEditChange via import, then mark dirty flag at this+0x64.
	UObject::PostEditChange();
	*(INT*)((BYTE*)this + 0x64) = 1;
}


// --- USoundGen ---
void USoundGen::Serialize(FArchive &Ar)
{
	guard(USoundGen::Serialize);
	// Retail 0x80100: USound::Serialize, then serializes five 4-byte fields
	// at +0xa0..+0xb0 via FUN_10301310, an array at +0xb4 via FUN_1037fbd0,
	// and an FString at +0xc0.
	USound::Serialize(Ar);
	// Five scalar fields (type unknown — raw offset access).
	typedef void (__cdecl *ScalarSerFn)(FArchive*, void*);
	ScalarSerFn scalarSer = reinterpret_cast<ScalarSerFn>(0x10301310);
	scalarSer(&Ar, reinterpret_cast<BYTE*>(this) + 0xa0);
	scalarSer(&Ar, reinterpret_cast<BYTE*>(this) + 0xa4);
	scalarSer(&Ar, reinterpret_cast<BYTE*>(this) + 0xa8);
	scalarSer(&Ar, reinterpret_cast<BYTE*>(this) + 0xac);
	scalarSer(&Ar, reinterpret_cast<BYTE*>(this) + 0xb0);
	// Array/struct field at +0xb4 (FUN_1037fbd0).
	typedef void (__cdecl *ArrSerFn)(FArchive*, void*);
	reinterpret_cast<ArrSerFn>(0x1037fbd0)(&Ar, reinterpret_cast<BYTE*>(this) + 0xb4);
	// FString at +0xc0.
	Ar << *reinterpret_cast<FString*>(reinterpret_cast<BYTE*>(this) + 0xc0);
	unguard;
}

