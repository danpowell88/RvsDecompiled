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
IMPL_MATCH("Engine.dll", 0x1037eee0)
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

IMPL_MATCH("Engine.dll", 0x1037ef65)
void USound::PS2Convert()
{
	guard(USound::PS2Convert);
	// Retail 0x7ef80: calls FUN_1037efde() (PS2-format helper).
	typedef void (__cdecl *PS2Fn)();
	((PS2Fn)0x1037efde)();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10321190)
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
IMPL_MATCH("Engine.dll", 0x1037fe10)
void USound::Serialize(FArchive& Ar)
{
	// Retail: 0x1037fe10. Calls UObject::Serialize, then serializes FSoundData at +0x48.
	// FSoundData serialization uses internal helpers. Divergence: base class only;
	// raw sound data is loaded directly from the .u package stream.
	UObject::Serialize(Ar);
}
IMPL_MATCH("Engine.dll", 0x1037ee40)
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
IMPL_MATCH("Engine.dll", 0x103151f0)
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
IMPL_MATCH("Engine.dll", 0x1037f530)
void UI3DL2Listener::PostEditChange()
{
	// Retail: 30b. Call UObject::PostEditChange via import, then mark dirty flag at this+0x64.
	UObject::PostEditChange();
	*(INT*)((BYTE*)this + 0x64) = 1;
}


// --- USoundGen ---
IMPL_MATCH("Engine.dll", 0x10380100)
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


// ============================================================================
// FWaveModInfo / FSoundData implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0FWaveModInfo@@QAE@XZ
IMPL_MATCH("Engine.dll", 0x10315260)
FWaveModInfo::FWaveModInfo() : SampleLoopsNum(0), NoiseGate(0) {}

// ??4FWaveModInfo@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x10315280)
FWaveModInfo & FWaveModInfo::operator=(FWaveModInfo const & Other) { appMemcpy(this, &Other, 64); return *this; }

// ?ReadWaveInfo@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
IMPL_MATCH("Engine.dll", 0x1037f560)
INT FWaveModInfo::ReadWaveInfo(TArray<BYTE>& WavData) {
	guard(FWaveModInfo::ReadWaveInfo);

	BYTE* Start = &WavData(0);
	INT Len = WavData.Num();
	WaveDataEnd = Start + Len;

	if( *(DWORD*)(Start + 8) != 0x45564157 )
		return 0;
	pMasterSize = (DWORD*)(Start + 4);

	BYTE* Ptr;

	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x20746d66; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x20746d66 )
		return 0;

	BYTE* FmtData = Ptr + 8;
	pBitsPerSample  = (_WORD*)(Ptr + 0x16);
	pSamplesPerSec  = (DWORD*)(Ptr + 12);
	pAvgBytesPerSec = (DWORD*)(Ptr + 16);
	pBlockAlign     = (_WORD*)(Ptr + 20);
	pChannels       = (_WORD*)(Ptr + 10);

	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x61746164; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( *(DWORD*)Ptr != 0x61746164 )
		return 0;

	SampleDataStart = Ptr + 8;
	pWaveDataSize   = (DWORD*)(Ptr + 4);
	SampleDataSize  = *(DWORD*)(Ptr + 4);
	OldBitsPerSample = (DWORD)*(_WORD*)(FmtData + 0x0E);
	SampleDataEnd   = SampleDataStart + SampleDataSize;
	NewDataSize     = SampleDataSize;

	for( Ptr = Start + 12; Ptr + 8 < WaveDataEnd && *(DWORD*)Ptr != 0x6C706D73; Ptr += Pad16Bit(*(DWORD*)(Ptr+4)) + 8 ) {}
	if( Ptr + 4 < WaveDataEnd && *(DWORD*)Ptr == 0x6C706D73 )
	{
		BYTE SmplHeader[36];
		appMemcpy(SmplHeader, Ptr + 8, 36);
		SampleLoopsNum = *(INT*)(SmplHeader + 28);
		pSampleLoop    = (FSampleLoop*)(Ptr + 8 + 36);
	}

	return 1;
	unguard;
}

// ?UpdateWaveData@FWaveModInfo@@QAEHAAV?$TArray@E@@@Z
IMPL_MATCH("Engine.dll", 0x1037f7f0)
INT FWaveModInfo::UpdateWaveData(TArray<BYTE>& WavData)
{
	if (NewDataSize < SampleDataSize) {
		DWORD delta = Pad16Bit(SampleDataSize) - Pad16Bit(NewDataSize);
		*pWaveDataSize     = NewDataSize;
		*pMasterSize      -= delta;
		*pBlockAlign       = (_WORD)(*pChannels * (*pBitsPerSample >> 3));
		*pAvgBytesPerSec   = (DWORD)(*pBlockAlign) * *pSamplesPerSec;
		if (SampleLoopsNum > 0) {
			FSampleLoop* pLoop = pSampleLoop;
			DWORD scaleNum = (DWORD)*pBitsPerSample * SampleDataSize / NewDataSize;
			for (INT i = 0; i < SampleLoopsNum; i++, pLoop++) {
				pLoop->dwStart = (DWORD)((DWORD)pLoop->dwStart * OldBitsPerSample) / scaleNum;
				pLoop->dwEnd   = (DWORD)((DWORD)pLoop->dwEnd   * OldBitsPerSample) / scaleNum;
			}
		}
		INT afterSize = (INT)(WaveDataEnd - SampleDataEnd);
		for (INT i = 0; i < afterSize; i++)
			*(SampleDataEnd - delta + i) = *(SampleDataEnd + i);
		WavData.Remove(WavData.Num() - delta, delta);
	}
	return 1;
}

// ?Pad16Bit@FWaveModInfo@@QAEKK@Z
IMPL_MATCH("Engine.dll", 0x10315270)
DWORD FWaveModInfo::Pad16Bit(DWORD InVal) { return (InVal + 1) & ~1; }

// ?HalveData@FWaveModInfo@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x1037f2c0)
void FWaveModInfo::HalveData()
{
	if (*pBitsPerSample == 16)
	{
		DWORD DataSize = SampleDataSize;
		short* Data = (short*)SampleDataStart;
		INT Accum = 0;
		INT Prev = Data[0];
		for (DWORD i = 0; i < DataSize >> 2; i++)
		{
			INT Cur = Data[i * 2 + 1];
			Accum = Accum + Prev + 0x20000 + Data[i * 2] * 2 + Cur;
			DWORD Val = (Accum + 2) & 0x3FFFC;
			if (Val > 0x3FFFC) Val = 0x3FFFC;
			Data[i] = (short)((INT)Val >> 2) - 0x8000;
			Accum = Accum - Val;
			Prev = Cur;
		}
		NewDataSize = (DataSize >> 2) << 1;
		*pSamplesPerSec >>= 1;
	}
	else if (*pBitsPerSample == 8)
	{
		DWORD DataSize = SampleDataSize;
		BYTE* Data = SampleDataStart;
		INT Accum = 0;
		DWORD Prev = Data[0];
		for (DWORD i = 0; i < DataSize >> 1; i++)
		{
			BYTE Next = Data[i * 2 + 1];
			Accum = Accum + Prev + Data[i * 2] * 2 + Next;
			DWORD Val = (Accum + 2) & 0x3FC;
			if (Val > 0x3FC) Val = 0x3FC;
			Data[i] = (BYTE)(Val >> 2);
			Accum = Accum - Val;
			Prev = Next;
		}
		NewDataSize = DataSize >> 1;
		*pSamplesPerSec >>= 1;
	}
}

// ?HalveReduce16to8@FWaveModInfo@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x1037f000)
void FWaveModInfo::HalveReduce16to8()
{
	DWORD DataSize = SampleDataSize;
	short* Data16 = (short*)SampleDataStart;
	BYTE* Data8 = SampleDataStart;
	INT Accum = 0;
	INT Prev = Data16[0];
	for (DWORD i = 0; i < DataSize >> 2; i++)
	{
		INT Cur = Data16[i * 2 + 1];
		Accum = Accum + Prev + 0x20000 + Data16[i * 2] * 2 + Cur;
		DWORD Val = (Accum + 0x200) & 0xFFFFFC00;
		if ((INT)Val > 0x3FC00) Val = 0x3FC00;
		Data8[i] = (BYTE)(Val >> 10);
		Accum = Accum - Val;
		Prev = Cur;
	}
	NewDataSize = DataSize >> 2;
	*pBitsPerSample = 8;
	*pSamplesPerSec >>= 1;
	NoiseGate = 1;
}

// ?NoiseGateFilter@FWaveModInfo@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x1037fa00)
void FWaveModInfo::NoiseGateFilter()
{
	BYTE* Data = SampleDataStart;
	INT TotalSamples = *pWaveDataSize;
	DWORD Rate = *pSamplesPerSec;
	INT SilenceStart = 0;
	for (INT i = 0; i < TotalSamples; i++)
	{
		INT Amp = (INT)Data[i] - 0x80;
		if (Amp < 0) Amp = -Amp;
		UBOOL IsLoud = (Amp >= 0x12);
		if (IsLoud && SilenceStart > 0 && (i - SilenceStart) < (INT)((Rate / 0x2B11) << 5))
			IsLoud = 0;
		if (SilenceStart == 0)
		{
			if (!IsLoud)
				SilenceStart = i;
		}
		else if (IsLoud || i == TotalSamples - 1)
		{
			if ((i - SilenceStart) >= (INT)((Rate / 0x2B11) * 0x35C))
			{
				for (INT j = SilenceStart; j < i; j++)
					Data[j] = 0x80;
			}
			SilenceStart = 0;
		}
	}
}

// ?Reduce16to8@FWaveModInfo@@QAEXXZ
IMPL_MATCH("Engine.dll", 0x1037f190)
void FWaveModInfo::Reduce16to8()
{
	DWORD DataSize = SampleDataSize;
	short* Data16 = (short*)SampleDataStart;
	BYTE* Data8 = SampleDataStart;
	INT Error = 0;
	for (DWORD i = 0; i < DataSize >> 1; i++)
	{
		Error = Error + 0x8000 + (INT)Data16[i];
		INT Quantized = (Error + 0x7F) & 0xFFFFFF00;
		if (Quantized > 0xFF00)
			Quantized = 0xFF00;
		Data8[i] = (BYTE)(Quantized >> 8);
		Error = Error - Quantized;
	}
	NewDataSize = DataSize >> 1;
	*pBitsPerSample = 8;
	NoiseGate = 1;
}

// ============================================================================
// FSoundData
// ============================================================================
IMPL_MATCH("Engine.dll", 0x10321030)
FSoundData::FSoundData(USound*) { appMemzero(this, sizeof(*this)); }
IMPL_EMPTY("Ghidra VA 0x10321070 (RVA 0x21070) confirms retail body is trivial (5 bytes)")
FSoundData::~FSoundData() {}
IMPL_MATCH("Engine.dll", 0x103801c0)
void FSoundData::Load() {}
IMPL_MATCH("Engine.dll", 0x1037fcd0)
FLOAT FSoundData::GetPeriod() { return 0.0f; }
