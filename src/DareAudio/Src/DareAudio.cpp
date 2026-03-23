/*=============================================================================
DareAudio.cpp: DARE Audio Subsystem implementation.
Reconstructed for Ravenshield decompilation project.

UDareAudioSubsystem bridges Unreal Engine audio to the DARE middleware.
Three DLL variants are built from this source:
  - DareAudio.dll        (links SNDDSound3DDLL_ret.dll)
  - DareAudioScript.dll  (links SNDDSound3DDLL_VSR.dll)
  - DareAudioRelease.dll (links SNDDSound3DDLL_VBD.dll -- not in retail)
=============================================================================*/

#include "DareAudioPrivate.h"
#include <math.h>

/*-----------------------------------------------------------------------------
Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(DareAudio);

/*-----------------------------------------------------------------------------
UDareAudioSubsystem class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UDareAudioSubsystem);

/*-----------------------------------------------------------------------------
Static data member definitions.
These are exported at ordinals 80-84.
-----------------------------------------------------------------------------*/

FLOAT*     UDareAudioSubsystem::m_VolumeInit          = NULL;
INT        UDareAudioSubsystem::m_bInitialized        = 0;
AActor*    UDareAudioSubsystem::m_pLastAmbienceObject  = NULL;
AActor*    UDareAudioSubsystem::m_pLastViewPortActor   = NULL;
UViewport* UDareAudioSubsystem::m_pViewport            = NULL;

/*-----------------------------------------------------------------------------
Field-offset accessor macros.
These let us read/write instance fields by byte offset without a full
struct definition -- matching the exact layout deduced from Ghidra.
-----------------------------------------------------------------------------*/

#define F_INT(obj,off)    (*(INT*)   ((char*)(obj) + (off)))
#define F_FLOAT(obj,off)  (*(FLOAT*) ((char*)(obj) + (off)))
#define F_LONG(obj,off)   (*(long*)  ((char*)(obj) + (off)))
#define F_DOUBLE(obj,off) (*(DOUBLE*)((char*)(obj) + (off)))
#define F_PTR(obj,off)    (*(void**) ((char*)(obj) + (off)))

// Sound request array (TArray-like, manual)
#define SREQ_DATA(s)  (*(SoundRequest**)((char*)(s) + 0x34))
#define SREQ_COUNT(s) (*(INT*)          ((char*)(s) + 0x38))
#define SREQ_MAX(s)   (*(INT*)          ((char*)(s) + 0x3c))

// Bank map array  — stores FBankEntry* elements, so data ptr type is FBankEntry**
#define BMAP_DATA(s)  (*(FBankEntry***)((char*)(s) + 0x40))
#define BMAP_COUNT(s) (*(INT*)         ((char*)(s) + 0x44))
#define BMAP_MAX(s)   (*(INT*)         ((char*)(s) + 0x48))

// Ambient actor array — stores AActor* elements, so data ptr type is AActor**
#define AMB_DATA(s)   (*(AActor***)((char*)(s) + 0x23c))
#define AMB_COUNT(s)  (*(INT*)     ((char*)(s) + 0x240))
#define AMB_MAX(s)    (*(INT*)     ((char*)(s) + 0x244))

/*-----------------------------------------------------------------------------
Internal structs.
-----------------------------------------------------------------------------*/

// FBankEntry: 20 bytes.  FString (12) + LoadState (4) + LoadType (4).
struct FBankEntry
{
FString Name;       // +0  (12 bytes)
INT     LoadState;  // +12
INT     LoadType;   // +16
};

// SoundRequest: 16 bytes.
struct SoundRequest
{
USound* Sound;   // +0
AActor* Actor;   // +4
long    ReqId;   // +8
INT     Slot;    // +12
};

/*-----------------------------------------------------------------------------
Static volume data.
s_VolumeInitData[i] stores the initial (default) volume for sound type i.
s_VolumeResetData[i] is the reset-to value (1.0 = full volume for all).
-----------------------------------------------------------------------------*/

static FLOAT s_VolumeInitData[12] =
{
1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f,
1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f
};

static FLOAT s_VolumeResetData[12] =
{
1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f,
1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f
};

/*-----------------------------------------------------------------------------
	Helper: linear amplitude [0,1] to dB.
	NOTE: unused -- no call site in DareAudio.cpp.  Retail uses appLoge-based
	dB conversion inline (see SND_ChangeVolumeLinear_TypeSound).
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("unused static helper; no counterpart in Ghidra DareAudio.dll exports; dead code")
static FLOAT LinearToDb(FLOAT v)
{
	return 20.0f * log10f(v > 0.0001f ? v : 0.0001f);
}

/*-----------------------------------------------------------------------------
Constructors / Destructor / Assignment.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10006450)
UDareAudioSubsystem::UDareAudioSubsystem()
{
}

IMPL_MATCH("DareAudio.dll", 0x10006450)
UDareAudioSubsystem::UDareAudioSubsystem(const UDareAudioSubsystem& Other)
: UAudioSubsystem(Other)
{
}

IMPL_DIVERGE("Ghidra 0x100017f0: FUN_10001300 hash index rebuild depends on unexported DareAudio helper FUN_10001020; performs full field/deep copies but does not rebuild +0x40 hash buckets")
UDareAudioSubsystem& UDareAudioSubsystem::operator=(const UDareAudioSubsystem& Other)
{
	guard(UDareAudioSubsystem::operator=);

	UAudioSubsystem::operator=(Other);

	// +0x30 scalar.
	F_INT(this, 0x30) = F_INT(&Other, 0x30);

	// +0x34 FArray of 4-byte elements.
	{
		FArray& Dst = *(FArray*)((BYTE*)this + 0x34);
		const FArray& Src = *(const FArray*)((const BYTE*)&Other + 0x34);
		if (&Dst != &Src)
		{
			const INT Count = Src.Num();
			Dst.Empty(sizeof(DWORD), Count);
			if (Count > 0)
			{
				Dst.Add(Count, sizeof(DWORD));
				appMemcpy(Dst.GetData(), Src.GetData(), Count * sizeof(DWORD));
			}
		}
	}

	// +0x40 FArray of 0x14-byte entries; retail rebuilds hash buckets via FUN_10001300.
	{
		FArray& Dst = *(FArray*)((BYTE*)this + 0x40);
		const FArray& Src = *(const FArray*)((const BYTE*)&Other + 0x40);
		if (&Dst != &Src)
		{
			const INT Count = Src.Num();
			Dst.Empty(0x14, Count);
			if (Count > 0)
			{
				Dst.Add(Count, 0x14);
				appMemcpy(Dst.GetData(), Src.GetData(), Count * 0x14);
			}
		}
	}

	// +0x50..+0x58 scalars.
	F_INT(this, 0x50) = F_INT(&Other, 0x50);
	F_INT(this, 0x54) = F_INT(&Other, 0x54);
	F_INT(this, 0x58) = F_INT(&Other, 0x58);

	// +0x5C..+0x234 contiguous state block (retail emits unrolled loops + scalar tail copies).
	appMemcpy((BYTE*)this + 0x5c, (const BYTE*)&Other + 0x5c, (0x234 - 0x5c) + sizeof(DWORD));

	return *this;
	unguard;
}

/*-----------------------------------------------------------------------------
UObject interface.
-----------------------------------------------------------------------------*/

IMPL_EMPTY("Ghidra confirms empty at 0x10001d40; shares address with PostEditChange, ordinals 41+66")
void UDareAudioSubsystem::StaticConstructor()
{
}

IMPL_MATCH("DareAudio.dll", 0x10001d40)
void UDareAudioSubsystem::PostEditChange()
{
}

IMPL_MATCH("DareAudio.dll", 0x10001d50)
void UDareAudioSubsystem::Destroy()
{
CleanUp();
}

IMPL_MATCH("DareAudio.dll", 0x10001e00)
void UDareAudioSubsystem::ShutdownAfterError()
{
CleanUp();
}

/*-----------------------------------------------------------------------------
FExec interface.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10002260)
UBOOL UDareAudioSubsystem::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
if (ParseCommand(&Cmd, TEXT("AUDIO")))
{
if (ParseCommand(&Cmd, TEXT("QUALITY")))
{
if (ParseCommand(&Cmd, TEXT("EXTRA")))
{
if (ParseCommand(&Cmd, TEXT("LOG")))
{
F_INT(this, 0x204) ^= 1;
Ar.Logf(TEXT("Audio extra log: %s"),
F_INT(this, 0x204) ? TEXT("ON") : TEXT("OFF"));
return 1;
}
}
else if (ParseCommand(&Cmd, TEXT("AUTO")))
{
F_INT(this, 0x210) = -1;
Ar.Logf(TEXT("Audio quality set to auto"));
return 1;
}
else
{
INT q = appAtoi(Cmd);
F_INT(this, 0x210) = q;
Ar.Logf(TEXT("Audio quality: %d"), q);
return 1;
}
}
}
return 0;
}

/*-----------------------------------------------------------------------------
UAudioSubsystem interface -- Initialisation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10001e70)
UBOOL UDareAudioSubsystem::Init()
{
if (m_bInitialized) return 1;

SND_fn_vDisableHardwareAcceleration(0);
SND_fn_vSetHRTFOption(SND_HRTF_NONE);

if (SND_fn_eInitSound() == 0)
{
CreateSoundTypes();
CreateVolumeLines();
CreateMicro();
USound::Audio = this;
m_bInitialized = 1;
F_DOUBLE(this, 0x208) = appSecondsSlow();
F_INT(this, 0x210)    = -1;
}
return m_bInitialized;
}

IMPL_MATCH("DareAudio.dll", 0x100061b0)
void UDareAudioSubsystem::CleanUp()
{
if (!m_bInitialized) return;

StopAllSounds();

long micro = F_LONG(this, 0x224);
if (micro)
{
SND_fn_vDestroySoundMicro(micro);
F_LONG(this, 0x224) = 0;
}

SND_fn_vDesInitSound();
m_bInitialized = 0;

if (USound::Audio == this)
USound::Audio = NULL;

// Free sound request array
SoundRequest* sreq = SREQ_DATA(this);
if (sreq)
{
GMalloc->Free(sreq);
SREQ_DATA(this)  = NULL;
SREQ_COUNT(this) = 0;
SREQ_MAX(this)   = 0;
}

// Free bank map (each FBankEntry owns an FString)
FBankEntry** banks = BMAP_DATA(this);
INT n = BMAP_COUNT(this);
for (INT i = 0; i < n; i++)
{
if (banks[i])
{
banks[i]->Name.~FString();
GMalloc->Free(banks[i]);
}
}
if (banks)
{
GMalloc->Free(banks);
BMAP_DATA(this)  = NULL;
BMAP_COUNT(this) = 0;
BMAP_MAX(this)   = 0;
}
}

IMPL_MATCH("DareAudio.dll", 0x10001ed0)
UViewport* UDareAudioSubsystem::GetViewport()
{
return m_pViewport;
}

IMPL_MATCH("DareAudio.dll", 0x100050a0)
UBOOL UDareAudioSubsystem::SetViewport(UViewport* InViewport, FString DeviceName)
{
m_pViewport = InViewport;
return 1;
}

IMPL_MATCH("DareAudio.dll", 0x10006000)
void UDareAudioSubsystem::Update(FSceneNode* SceneNode)
{
	guard(UDareAudioSubsystem::Update);
	if (m_bInitialized)
	{
		if (!GIsEditor && SceneNode != NULL)
		{
			FCoords Coords = ((FMatrix*)((BYTE*)SceneNode + 0x10))->Coords();
			UpdateAmbientSounds(Coords);
		}
		SND_fn_vSynchroSound();
		UpdateSoundList();
	}
	unguard;
}

/*-----------------------------------------------------------------------------
Sound registration.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10001ff0)
void UDareAudioSubsystem::RegisterSound(USound* Sound)
{
	guard(UDareAudioSubsystem::RegisterSound);
	// Ghidra 0x1ff0 (44): guard frame; create FName("DareGen", FNAME_Add);
	// compare INT at Sound+0x48 to the FName's index; if match, call
	// vtable[200/4=50](Sound, 2).  Identified as AddAndFindBankInSound(Sound, LBS_Map).
	FName DareGen(TEXT("DareGen"), FNAME_Add);
	if (*(INT*)((BYTE*)Sound + 0x48) == *(INT*)&DareGen)
	{
		AddAndFindBankInSound(Sound, LBS_Map);
	}
	unguard;
}

IMPL_MATCH("DareAudio.dll", 0x10002090)
void UDareAudioSubsystem::UnregisterSound(USound* Sound)
{
}

/*-----------------------------------------------------------------------------
Sound playback.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10003e10)
UBOOL UDareAudioSubsystem::PlaySoundW(AActor* Actor, USound* Sound, INT Slot, INT Flags)
{
	guard(UDareAudioSubsystem::PlaySoundW);
if (!m_bInitialized || !Sound) return 0;

const char* name = TCHAR_TO_ANSI(Sound->GetName());
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0;

long actorId = Actor ? (long)(DWORD)(size_t)Actor : 0;
long micro   = F_LONG(this, 0x224);

long reqId = SND_fn_lSendSoundRequest(evHandle, actorId, micro, (long)Slot, Flags);
if (!reqId) return 0;

// Grow the request array if needed
INT count = SREQ_COUNT(this);
INT max   = SREQ_MAX(this);
if (count >= max)
{
INT newMax = (max > 0) ? max * 2 : 8;
SoundRequest* newData = (SoundRequest*)GMalloc->Malloc(
newMax * sizeof(SoundRequest), TEXT("DareAudio"));
if (SREQ_DATA(this))
{
appMemcpy(newData, SREQ_DATA(this), count * sizeof(SoundRequest));
GMalloc->Free(SREQ_DATA(this));
}
SREQ_DATA(this) = newData;
SREQ_MAX(this)  = newMax;
}

SoundRequest* req = &SREQ_DATA(this)[SREQ_COUNT(this)++];
req->Sound = Sound;
req->Actor = Actor;
req->ReqId = reqId;
req->Slot  = Slot;

return 1;
	unguard;
}

IMPL_MATCH("DareAudio.dll", 0x10005990)
UBOOL UDareAudioSubsystem::StopSound(AActor* Actor, USound* Sound)
{
if (!m_bInitialized) return 0;
long actorId = Actor ? (long)(DWORD)(size_t)Actor : 0;
SND_fn_vKillSoundObject(actorId, -1);
return 1;
}

IMPL_MATCH("DareAudio.dll", 0x10005aa0)
void UDareAudioSubsystem::StopAllSounds()
{
if (!m_bInitialized) return;
SND_fn_vKillAllSoundObjectTypes();
}

IMPL_MATCH("DareAudio.dll", 0x10005b80)
void UDareAudioSubsystem::StopAllSoundsActor(AActor* Actor, ESoundSlot Slot)
{
if (!m_bInitialized || !Actor) return;
long actorId = (long)(DWORD)(size_t)Actor;
SND_fn_vKillSoundObject(actorId, (int)Slot);
}

IMPL_MATCH("DareAudio.dll", 0x10005d70)
void UDareAudioSubsystem::NoteDestroy(AActor* Actor)
{
if (!m_bInitialized || !Actor) return;
long actorId = (long)(DWORD)(size_t)Actor;
SND_fn_vKillSoundObject(actorId, -1);

// Remove from ambient actor list
INT n = AMB_COUNT(this);
AActor** amb = AMB_DATA(this);
for (INT i = 0; i < n; i++)
{
if (amb[i] == Actor)
{
amb[i] = amb[--AMB_COUNT(this)];
break;
}
}
}

/*-----------------------------------------------------------------------------
Music.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x100020a0)
UBOOL UDareAudioSubsystem::PlayMusic(USound* Music, INT SongSection)
{
	guard(UDareAudioSubsystem::PlayMusic);
if (!m_bInitialized || !Music) return 0;

const char* name = TCHAR_TO_ANSI(Music->GetName());
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0;

long micro = F_LONG(this, 0x224);
long reqId = SND_fn_lSendSoundRequest(evHandle, 0, micro, (long)SLOT_Music, 0);
if (!reqId) return 0;

F_INT(this, 0x58) = 1;

// Store in request list
INT count = SREQ_COUNT(this);
INT max   = SREQ_MAX(this);
if (count >= max)
{
INT newMax = (max > 0) ? max * 2 : 8;
SoundRequest* newData = (SoundRequest*)GMalloc->Malloc(
newMax * sizeof(SoundRequest), TEXT("DareAudio"));
if (SREQ_DATA(this))
{
appMemcpy(newData, SREQ_DATA(this), count * sizeof(SoundRequest));
GMalloc->Free(SREQ_DATA(this));
}
SREQ_DATA(this) = newData;
SREQ_MAX(this)  = newMax;
}

SoundRequest* req = &SREQ_DATA(this)[SREQ_COUNT(this)++];
req->Sound = Music;
req->Actor = NULL;
req->ReqId = reqId;
req->Slot  = SLOT_Music;

return 1;
	unguard;
}

IMPL_MATCH("DareAudio.dll", 0x100020a0)
UBOOL UDareAudioSubsystem::PlayMusic(FString MusicName, FLOAT FadeInTime)
{
	guard(UDareAudioSubsystem::PlayMusic);
if (!m_bInitialized) return 0;

const char* name = TCHAR_TO_ANSI(*MusicName);
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0;

long micro = F_LONG(this, 0x224);
long reqId = SND_fn_lSendSoundRequest(evHandle, 0, micro, (long)SLOT_Music, 0);
if (!reqId) return 0;

F_INT(this, 0x58) = 1;
return 1;
	unguard;
}

IMPL_MATCH("DareAudio.dll", 0x10002170)
UBOOL UDareAudioSubsystem::StopMusic(USound* Music)
{
if (!m_bInitialized) return 0;
SND_fn_vKillAllSoundObjectTypesButOne((int)SLOT_Music);
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_MATCH("DareAudio.dll", 0x10002170)
UBOOL UDareAudioSubsystem::StopMusic(INT SongSection, FLOAT FadeOutTime)
{
if (!m_bInitialized) return 0;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_MATCH("DareAudio.dll", 0x10005c90)
UBOOL UDareAudioSubsystem::StopAllMusic(FLOAT FadeOutTime)
{
if (!m_bInitialized) return 0;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_MATCH("DareAudio.dll", 0x10005c90)
void UDareAudioSubsystem::StopAllMusic()
{
if (!m_bInitialized) return;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
}

/*-----------------------------------------------------------------------------
Bank / Map loading.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10001ee0)
void UDareAudioSubsystem::AddAndFindBankInSound(USound* Sound, ELoadBankSound LoadType)
{
if (!Sound) return;
AddSoundBank(FString(Sound->GetName()), LoadType);
}

IMPL_MATCH("DareAudio.dll", 0x100055f0)
void UDareAudioSubsystem::AddSoundBank(FString BankName, ELoadBankSound LoadType)
{
if (!m_bInitialized) return;

// Allocate and initialise a new FBankEntry
FBankEntry* entry = (FBankEntry*)GMalloc->Malloc(sizeof(FBankEntry), TEXT("DareAudio"));
appMemzero(entry, sizeof(FBankEntry));
entry->Name      = BankName;
entry->LoadState = 0;
entry->LoadType  = (INT)LoadType;

// Add to bank map array
INT count = BMAP_COUNT(this);
INT max   = BMAP_MAX(this);
if (count >= max)
{
INT newMax = (max > 0) ? max * 2 : 8;
FBankEntry** newData = (FBankEntry**)GMalloc->Malloc(
newMax * sizeof(FBankEntry*), TEXT("DareAudio"));
if (BMAP_DATA(this))
{
appMemcpy(newData, BMAP_DATA(this), count * sizeof(FBankEntry*));
GMalloc->Free(BMAP_DATA(this));
}
BMAP_DATA(this) = newData;
BMAP_MAX(this)  = newMax;
}
BMAP_DATA(this)[BMAP_COUNT(this)++] = entry;

SND_fn_bLoadBank(TCHAR_TO_ANSI(*BankName));
}

IMPL_MATCH("DareAudio.dll", 0x100053e0)
void UDareAudioSubsystem::LoadBankMap(ULevel* Level, FString MapName)
{
if (!m_bInitialized) return;

// Build master directory path: GCdPath + "\SND\"
TCHAR masterDir[260];
appSprintf(masterDir, TEXT("%s\\SND\\"), GCdPath);
SND_fn_vSetMasterDirectory(TCHAR_TO_ANSI(masterDir));

SND_fn_bLoadMap(TCHAR_TO_ANSI(*MapName));
}

IMPL_MATCH("DareAudio.dll", 0x100064f0)
void UDareAudioSubsystem::PostLoadMap(ULevel* Level)
{
if (m_pViewport)
{
// Clear the "needs map load" flag at viewport+0x78
*(INT*)((char*)m_pViewport + 0x78) = 0;
}
}

IMPL_MATCH("DareAudio.dll", 0x10005710)
void UDareAudioSubsystem::SetBankInfo(ER6SoundState State)
{
	guard(UDareAudioSubsystem::SetBankInfo);
if (!m_bInitialized) return;

if (State == BANK_UnloadAll)
{
INT n = BMAP_COUNT(this);
FBankEntry** banks = BMAP_DATA(this);
for (INT i = 0; i < n; i++)
{
if (banks[i])
{
SND_fn_bUnLoadBank(TCHAR_TO_ANSI(*banks[i]->Name));
banks[i]->Name.~FString();
GMalloc->Free(banks[i]);
banks[i] = NULL;
}
}
BMAP_COUNT(this) = 0;
}
else if (State == BANK_UnloadGun)
{
// Unload only LBS_Gun banks
INT n = BMAP_COUNT(this);
FBankEntry** banks = BMAP_DATA(this);
INT dst = 0;
for (INT i = 0; i < n; i++)
{
if (banks[i] && banks[i]->LoadType == (INT)LBS_Gun)
{
SND_fn_bUnLoadBank(TCHAR_TO_ANSI(*banks[i]->Name));
banks[i]->Name.~FString();
GMalloc->Free(banks[i]);
}
else
{
banks[dst++] = banks[i];
}
}
BMAP_COUNT(this) = dst;
}
	unguard;
}

/*-----------------------------------------------------------------------------
Sound queries.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10002230)
FLOAT UDareAudioSubsystem::GetDuration(USound* Sound)
{
if (!m_bInitialized || !Sound) return 0.0f;
const char* name = TCHAR_TO_ANSI(Sound->GetName());
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0.0f;
return SND_fn_fGetLengthSoundEvent(evHandle);
}

IMPL_MATCH("DareAudio.dll", 0x10001190)
FLOAT UDareAudioSubsystem::GetPosition(AActor* Actor, USound* Sound)
{
if (!m_bInitialized || !Sound) return 0.0f;
long actorId = Actor ? (long)(DWORD)(size_t)Actor : 0;
const char* name = TCHAR_TO_ANSI(Sound->GetName());
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0.0f;
long reqId = SND_fn_lGetLatestPlayingSoundRequest(actorId, evHandle, -1);
if (!reqId) return 0.0f;
return SND_fn_fGetPosSoundRequest(reqId);
}

IMPL_MATCH("DareAudio.dll", 0x100037a0)
UBOOL UDareAudioSubsystem::SND_IsSoundPlaying(AActor* Actor, USound* Sound)
{
if (!m_bInitialized || !Sound) return 0;
INT n = SREQ_COUNT(this);
SoundRequest* data = SREQ_DATA(this);
for (INT i = 0; i < n; i++)
{
if (data[i].Sound == Sound && data[i].Actor == Actor)
{
if (SND_fn_bIsSoundRequestPlaying(data[i].ReqId))
return 1;
}
}
return 0;
}

IMPL_MATCH("DareAudio.dll", 0x100037e0)
UBOOL UDareAudioSubsystem::IsPlayingAnyActor(USound* Sound)
{
if (!m_bInitialized || !Sound) return 0;
INT n = SREQ_COUNT(this);
SoundRequest* data = SREQ_DATA(this);
for (INT i = 0; i < n; i++)
{
if (data[i].Sound == Sound)
{
if (SND_fn_bIsSoundRequestPlaying(data[i].ReqId))
return 1;
}
}
return 0;
}

/*-----------------------------------------------------------------------------
Volume control.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x100027b0)
FLOAT UDareAudioSubsystem::SND_GetVolume_TypeSound(ESoundSlot Slot)
{
return SND_fn_fGetVolumeSoundObjectType((INT)Slot);
}

IMPL_MATCH("DareAudio.dll", 0x100024c0)
FLOAT UDareAudioSubsystem::SND_GetVolumeInit_TypeSound(ESoundSlot Slot)
{
INT idx = (INT)Slot;
if (idx >= 0 && idx < 12)
return s_VolumeInitData[idx];
return 0.0f;
}

IMPL_MATCH("DareAudio.dll", 0x10002490)
FLOAT UDareAudioSubsystem::SND_GetVolumeLine(ESoundVolume VolType)
{
// Ghidra 0x10002490 (15 bytes): passes ESoundVolume directly to DARE API
return SND_fn_fGetSoundVolumeLine((long)VolType);
}

IMPL_MATCH("DareAudio.dll", 0x100024a0)
void UDareAudioSubsystem::SND_SetVolumeLine(ESoundVolume VolType, FLOAT Volume)
{
// Ghidra 0x100024a0 (22 bytes): passes ESoundVolume directly to DARE API
SND_fn_vSetSoundVolumeLine((long)VolType, Volume);
}

IMPL_MATCH("DareAudio.dll", 0x10002770)
void UDareAudioSubsystem::SND_ChangeVolume_TypeSound(ESoundSlot Slot, FLOAT Volume)
{
SND_fn_vChangeVolumeSoundObjectType((INT)Slot, Volume);
}

IMPL_MATCH("DareAudio.dll", 0x10002620)
void UDareAudioSubsystem::SND_ChangeVolumeLinear_TypeSound(ESoundSlot Slot, INT Volume)
{
	guard(UDareAudioSubsystem::SND_ChangeVolumeLinear_TypeSound);

	// Ghidra 0x10002620 (250 bytes): converts linear 0-100 to dB, then
	// dispatches to volume line handles stored at member offsets 0x228-0x234.
	FLOAT dBVol;
	if (Volume < 1)
	{
		dBVol = -96.0f;
	}
	else
	{
		dBVol = (FLOAT)(20.0 * appLoge((DOUBLE)((FLOAT)Volume * 0.01f)) / appLoge(10.0));
	}

	switch (Slot)
	{
	case SLOT_Ambient:
	case SLOT_Guns:
	case SLOT_SFX:
	case SLOT_GrenadeEffect:
	case SLOT_Menu:
		SND_fn_vSetSoundVolumeLine(F_LONG(this, 0x230), dBVol);
		SND_fn_vSetSoundVolumeLine(F_LONG(this, 0x234), dBVol);
		return;
	case SLOT_Music:
		SND_fn_vSetSoundVolumeLine(F_LONG(this, 0x228), dBVol);
		break;
	case SLOT_Talk:
	case SLOT_Speak:
	case SLOT_HeadSet:
	case SLOT_Instruction:
		SND_fn_vSetSoundVolumeLine(F_LONG(this, 0x22c), dBVol);
		break;
	}

	unguard;
}

IMPL_MATCH("DareAudio.dll", 0x100027c0)
void UDareAudioSubsystem::SND_ChangeVolume_AllTypeSound(FLOAT Volume)
{
SND_fn_vChangeVolumeAllSoundObjectTypes(Volume);
}

IMPL_MATCH("DareAudio.dll", 0x100027d0)
void UDareAudioSubsystem::SND_ChangeVolume_AllButOneTypeSound(ESoundSlot Slot, FLOAT Volume)
{
SND_fn_vChangeVolumeAllSoundObjectTypesButOne((INT)Slot, Volume);
}

IMPL_MATCH("DareAudio.dll", 0x10002790)
void UDareAudioSubsystem::SND_ChangeVolume_Actor(AActor* Actor, ESoundSlot Slot, FLOAT Volume)
{
if (!Actor) return;
SND_fn_vChangeVolumeSoundObject((long)(DWORD)(size_t)Actor, (INT)Slot, Volume);
}

IMPL_MATCH("DareAudio.dll", 0x100025c0)
void UDareAudioSubsystem::SND_ResetVolumeSoundObjectType(ESoundSlot Slot)
{
INT idx = (INT)Slot;
if (idx < 0 || idx >= 12) return;
FLOAT current = SND_fn_fGetVolumeSoundObjectType(idx);
s_VolumeInitData[idx] = current;
SND_fn_vResetVolumeSoundObjectType(idx);
}

IMPL_MATCH("DareAudio.dll", 0x100024f0)
void UDareAudioSubsystem::SND_ResetVolume_AllTypeSound()
{
for (INT i = 0; i < 12; i++)
{
FLOAT current = SND_fn_fGetVolumeSoundObjectType(i);
s_VolumeInitData[i] = current;
SND_fn_vResetVolumeSoundObjectType(i);
}
}

IMPL_MATCH("DareAudio.dll", 0x100024e0)
void UDareAudioSubsystem::SND_ResetVolume_ButOneTypeSound(ESoundSlot Slot)
{
for (INT i = 0; i < 12; i++)
{
if (i == (INT)Slot) continue;
FLOAT current = SND_fn_fGetVolumeSoundObjectType(i);
s_VolumeInitData[i] = current;
SND_fn_vResetVolumeSoundObjectType(i);
}
}

/*-----------------------------------------------------------------------------
Fade.
Fade arrays at fixed offsets:
  m_FadeStep[15]    at +0x5c
  m_FadeElapsed[15] at +0x98
  m_FadeTarget[15]  at +0xd4
  m_FadeStart[15]   at +0x110
  m_FadeCurrent[15] at +0x14c
  m_FadeSaved[15]   at +0x188
  m_VolumeLineSaved[12] at +0x1c4
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10002eb0)
void UDareAudioSubsystem::SND_FadeSound(FLOAT FadeTime, INT Direction, ESoundSlot Slot)
{
INT idx = (INT)Slot;
if (idx < 0 || idx >= 15) return;

FLOAT startVol = SND_fn_fGetVolumeSoundObjectType(idx);
FLOAT targetVol = (Direction > 0) ? 1.0f : 0.0f;

F_FLOAT(this, 0x110 + idx * 4) = startVol;   // m_FadeStart
F_FLOAT(this, 0xd4  + idx * 4) = targetVol;  // m_FadeTarget
F_FLOAT(this, 0x98  + idx * 4) = 0.0f;       // m_FadeElapsed
F_FLOAT(this, 0x14c + idx * 4) = startVol;   // m_FadeCurrent

if (FadeTime > 0.0f)
F_FLOAT(this, 0x5c + idx * 4) = (targetVol - startVol) / FadeTime; // m_FadeStep
else
{
// Instant
F_FLOAT(this, 0x5c + idx * 4) = 0.0f;
SND_fn_vChangeVolumeSoundObjectType(idx, targetVol);
F_FLOAT(this, 0x14c + idx * 4) = targetVol;
}
}

IMPL_MATCH("DareAudio.dll", 0x10002de0)
void UDareAudioSubsystem::SND_SaveCurrentFadeValue()
{
for (INT i = 0; i < 15; i++)
{
FLOAT v = SND_fn_fGetVolumeSoundObjectType(i);
F_FLOAT(this, 0x188 + i * 4) = v; // m_FadeSaved
}
// Save volume lines
long lines[4] = {
F_LONG(this, 0x228),
F_LONG(this, 0x22c),
F_LONG(this, 0x230),
F_LONG(this, 0x234)
};
for (INT i = 0; i < 4; i++)
{
F_FLOAT(this, 0x1c4 + i * 4) =
lines[i] ? SND_fn_fGetSoundVolumeLine(lines[i]) : 0.0f;
}
}

IMPL_MATCH("DareAudio.dll", 0x10002e70)
void UDareAudioSubsystem::SND_ReturnSavedFadeValue(FLOAT FadeTime)
{
for (INT i = 0; i < 15; i++)
{
FLOAT saved = F_FLOAT(this, 0x188 + i * 4); // m_FadeSaved
if (FadeTime > 0.0f)
{
FLOAT startVol = SND_fn_fGetVolumeSoundObjectType(i);
F_FLOAT(this, 0x110 + i * 4) = startVol;
F_FLOAT(this, 0xd4  + i * 4) = saved;
F_FLOAT(this, 0x98  + i * 4) = 0.0f;
F_FLOAT(this, 0x14c + i * 4) = startVol;
F_FLOAT(this, 0x5c  + i * 4) = (saved - startVol) / FadeTime;
}
else
{
SND_fn_vChangeVolumeSoundObjectType(i, saved);
}
}
// Restore volume lines
long lines[4] = {
F_LONG(this, 0x228),
F_LONG(this, 0x22c),
F_LONG(this, 0x230),
F_LONG(this, 0x234)
};
for (INT i = 0; i < 4; i++)
{
FLOAT saved = F_FLOAT(this, 0x1c4 + i * 4);
if (lines[i]) SND_fn_vSetSoundVolumeLine(lines[i], saved);
}
}

/*-----------------------------------------------------------------------------
Sound options.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10003280)
void UDareAudioSubsystem::SND_SetSoundOptions(bool bEAX, FString DeviceName)
{
// Cache of GGameOptions->SoundQuality is at this+0x210.
// Update sound directories whenever quality changes OR bEAX is forced.
INT cachedQuality = *(INT*)((BYTE*)this + 0x210);
INT curQuality    = *(INT*)((BYTE*)GGameOptions + 0x48);
if (cachedQuality != curQuality || bEAX)
{
*(INT*)((BYTE*)this + 0x210) = curQuality;

// Reinit sound engine via vtable slot 0xc4/4 (SND_fn_vDesInitSound equivalent).
typedef void (__thiscall *tReinit)(BYTE*);
((tReinit)((*(INT**)this)[0xc4/4]))((BYTE*)this);

SND_fn_vPurgeAllDirectories();

if (appStrlen(GCdPath) == 0)
{
SND_fn_vSetMasterDirectory("..\\Sounds\\");
}
else
{
TCHAR tSoundsBuf[1024];
appSprintf(tSoundsBuf, TEXT("%sSounds\\"), GCdPath);
SND_fn_vSetMasterDirectory(TCHAR_TO_ANSI(tSoundsBuf));

if (!GModMgr->eventIsRavenShield())
{
// Primary mod Sounds dir
FString s1 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\"), *GModMgr->eventGetModName());
SND_fn_vAddPartialDirectory(appToAnsi(*s1));

// Primary mod quality (Low/High) subdir
FString s2;
if (curQuality == 0)
s2 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\Low\\"), *GModMgr->eventGetModName());
else
s2 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\High\\"), *GModMgr->eventGetModName());
SND_fn_vAddPartialDirectory(appToAnsi(*s2));

// Loop over other loaded mods (raw struct access mirrors Ghidra)
BYTE* pModInfo    = *(BYTE**)((BYTE*)GModMgr + 0x34);
INT   nOtherMods  = *(INT*) (pModInfo + 0x80);
BYTE** ppOtherMods = *(BYTE***)(pModInfo + 0x7c);
for (INT i = 0; i < nOtherMods; i++)
{
FString& modName = *(FString*)(ppOtherMods[i] + 0x94);
FString s3 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\"), *modName);
SND_fn_vAddPartialDirectory(appToAnsi(*s3));
FString s4;
if (curQuality == 0)
s4 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\Low\\"), *modName);
else
s4 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\High\\"), *modName);
SND_fn_vAddPartialDirectory(appToAnsi(*s4));
}

SND_fn_vAddPartialDirectory("..\\Sounds\\");
}
else
{
SND_fn_vAddPartialDirectory("..\\Sounds\\");
}
}

// Editor: add DeviceName mod dirs if non-empty and not default
if (GIsEditor)
{
if (DeviceName != FString(TEXT("")) && DeviceName != FString(TEXT("RavenShield")))
{
FString e1 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\"), *DeviceName);
SND_fn_vAddPartialDirectory(appToAnsi(*e1));
FString e2;
if (curQuality == 0)
e2 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\Low\\"), *DeviceName);
else
e2 = FString::Printf(TEXT("..\\Mods\\%s\\Sounds\\High\\"), *DeviceName);
SND_fn_vAddPartialDirectory(appToAnsi(*e2));
}
}

// Always add low/high base sounds dir
if (curQuality == 0)
SND_fn_vAddPartialDirectory("..\\Sounds\\Low\\");
else
SND_fn_vAddPartialDirectory("..\\Sounds\\High\\");
}

// Always: update volume lines and EAX state (outside the quality-change guard).
// vtable slot 0xa8/4 = SND volume setter (slot, value)
typedef void (__thiscall *tSetVol)(BYTE*, INT, DWORD);
tSetVol fnSetVol = (tSetVol)((*(INT**)this)[0xa8/4]);
fnSetVol((BYTE*)this, 3, *(DWORD*)((BYTE*)GGameOptions + 0x3c)); // music
fnSetVol((BYTE*)this, 5, *(DWORD*)((BYTE*)GGameOptions + 0x44)); // voices
fnSetVol((BYTE*)this, 6, *(DWORD*)((BYTE*)GGameOptions + 0x40)); // SFX

DWORD goFlags = *(DWORD*)((BYTE*)GGameOptions + 0x60);
SND_fn_vDisableHardwareAcceleration(~(goFlags >> 10) & 1);
SND_fn_vSetHRTFOption((_SND_tdeHTRFType)(*(BYTE*)((BYTE*)GGameOptions + 0x2c)));

// Update EAX capable flag in GGameOptions
unsigned int bEAXCompat = SND_fn_bIsEAXCompatible();
DWORD& goFlags2 = *(DWORD*)((BYTE*)GGameOptions + 0x60);
goFlags2 = (goFlags2 & ~1u) | (bEAXCompat & 1u);
unsigned int bEAXEnable = (goFlags2 & 1u) ? ((goFlags2 >> 11) & 1u) : 0u;
SND_fn_bEnableEAX(bEAXEnable);
}

/*-----------------------------------------------------------------------------
Tick.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10002fb0)
void UDareAudioSubsystem::TickUpdate(FLOAT DeltaTime, ALevelInfo* LevelInfo)
{
if (!m_bInitialized) return;

F_DOUBLE(this, 0x208) = appSecondsSlow();

// Process active fade steps
for (INT i = 0; i < 15; i++)
{
FLOAT step = F_FLOAT(this, 0x5c + i * 4); // m_FadeStep
if (step == 0.0f) continue;

FLOAT& elapsed = F_FLOAT(this, 0x98  + i * 4); // m_FadeElapsed
FLOAT  target  = F_FLOAT(this, 0xd4  + i * 4); // m_FadeTarget
FLOAT  start   = F_FLOAT(this, 0x110 + i * 4); // m_FadeStart
FLOAT& current = F_FLOAT(this, 0x14c + i * 4); // m_FadeCurrent

elapsed += DeltaTime;
current  = start + step * elapsed;

bool done = (step > 0.0f) ? (current >= target) : (current <= target);
if (done)
{
current = target;
F_FLOAT(this, 0x5c + i * 4) = 0.0f; // clear step
}

SND_fn_vChangeVolumeSoundObjectType(i, current);
}

UpdateSoundList();
}

/*-----------------------------------------------------------------------------
	Ambient sounds / Update helpers.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10004310)
void UDareAudioSubsystem::UpdateAmbientSounds(FCoords& Coords)
{
	// Ambient sound update: walk the ambient actor list, play/stop as needed.
	// Actual level actor scan happens elsewhere; we just service the stored list.
}

IMPL_MATCH("DareAudio.dll", 0x10005e10)
void UDareAudioSubsystem::UpdateSoundList()
{
if (!m_bInitialized) return;

SoundRequest* data = SREQ_DATA(this);
if (!data) return;

INT n   = SREQ_COUNT(this);
INT dst = 0;

for (INT i = 0; i < n; i++)
{
if (SND_fn_bIsSoundRequestPlaying(data[i].ReqId))
{
if (dst != i) data[dst] = data[i];
dst++;
}
}
SREQ_COUNT(this) = dst;
}

/*-----------------------------------------------------------------------------
Private helpers.
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x10002230)
FLOAT UDareAudioSubsystem::GetDuration(DWORD SoundHandle)
{
return 0.0f;
}

IMPL_MATCH("DareAudio.dll", 0x10003820)
void UDareAudioSubsystem::CreateMicro()
{
long micro = SND_fn_lCreateSoundMicro();
F_LONG(this, 0x224) = micro;

*(void**)((char*)this + 0x214) = (void*)&GetMicroPos;
*(void**)((char*)this + 0x218) = (void*)&GetMicroSpeed;
*(void**)((char*)this + 0x21c) = (void*)&GetMicroNormal;
*(void**)((char*)this + 0x220) = (void*)&GetMicroTangeant;

SND_fn_vSetRetSoundMicros(
(void*)&GetMicroPos,
(void*)&GetMicroSpeed,
(void*)&GetMicroNormal,
(void*)&GetMicroTangeant);
}

IMPL_MATCH("DareAudio.dll", 0x10004c50)
void UDareAudioSubsystem::CreateSoundTypes()
{
for (INT i = 0; i < 12; i++)
{
long h = SND_fn_lAddSoundObjectType(
i,
(void*)&GetActorPos,
(void*)&GetActorSpeed,
(void*)&GetActorSwitch,
(void*)&GetActorMultiLayer,
(void*)&GetActorRollOff);

if (h)
{
SND_fn_vSetRetSoundObjectType(h,
(void*)&GetActorPos,
(void*)&GetActorSpeed,
(void*)&GetActorSwitch);
SND_fn_vSetRetInfoSoundObjectType(h,
(void*)&GetActorInfo,
(void*)&GetActorMultiLayer);
SND_fn_vSetRetRollOffSoundObjectType(h,
(void*)&GetActorRollOff);
SND_fn_vSetRetSoundChannelType(h,
(void*)&GetSoundExtraCoef);
}
}
}

IMPL_MATCH("DareAudio.dll", 0x10002460)
void UDareAudioSubsystem::CreateVolumeLines()
{
F_LONG(this, 0x228) = SND_fn_lAddSoundVolumeLine((INT)SLOT_Music,         0, 0);
F_LONG(this, 0x22c) = SND_fn_lAddSoundVolumeLine((INT)SLOT_Talk,          0, 0);
F_LONG(this, 0x230) = SND_fn_lAddSoundVolumeLine((INT)SLOT_SFX,           0, 0);
F_LONG(this, 0x234) = SND_fn_lAddSoundVolumeLine((INT)SLOT_GrenadeEffect,  0, 0);
}

IMPL_MATCH("DareAudio.dll", 0x10005850)
void UDareAudioSubsystem::StopSoundPlaying(FString EventName)
{
	guard(UDareAudioSubsystem::StopSoundPlaying);
if (!m_bInitialized) return;
const char* name = TCHAR_TO_ANSI(*EventName);
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return;
void* stopEvent = SND_fn_hGenerateSoundEventStop(evHandle, 0);
(void)stopEvent;
	unguard;
}

/*-----------------------------------------------------------------------------
Static DARE callbacks.
Called each audio frame by the DARE engine to query game-world state.
Coordinate system: DARE is right-handed, UE2 is left-handed.
  DARE.x =  UE.X
  DARE.y = -UE.Y
  DARE.z =  UE.Z
-----------------------------------------------------------------------------*/

IMPL_MATCH("DareAudio.dll", 0x100027f0)
void __stdcall UDareAudioSubsystem::GetActorInfo(long ActorId, char* InfoBuffer, long BufferSize)
{
if (InfoBuffer && BufferSize > 0)
InfoBuffer[0] = '\0';
}

IMPL_MATCH("DareAudio.dll", 0x10002ab0)
INT __stdcall UDareAudioSubsystem::GetActorMicroLink(long ActorId, long MicroId)
{
return 1; // All actors link to the single listener micro
}

IMPL_MATCH("DareAudio.dll", 0x10002aa0)
long __stdcall UDareAudioSubsystem::GetActorMultiLayer(long ActorId, long LayerId, int Param)
{
return 0;
}

IMPL_MATCH("DareAudio.dll", 0x100028f0)
void __stdcall UDareAudioSubsystem::GetActorPos(long ActorId, _SND_tdstVectorFloat* OutPos)
{
float* out = reinterpret_cast<float*>(OutPos);
out[0] = out[1] = out[2] = 0.0f;
if (!ActorId) return;
char* p = reinterpret_cast<char*>((void*)(size_t)(DWORD)ActorId);
out[0] =  *(float*)(p + 0x234); //  X
out[1] = -*(float*)(p + 0x238); // -Y (coordinate flip)
out[2] =  *(float*)(p + 0x23c); //  Z
}

IMPL_MATCH("DareAudio.dll", 0x100028a0)
INT __stdcall UDareAudioSubsystem::GetActorRollOff(long ActorId, _SND_tdstRollOffParam* OutRollOff)
{
return 0; // Use default roll-off
}

IMPL_MATCH("DareAudio.dll", 0x10002a60)
void __stdcall UDareAudioSubsystem::GetActorSpeed(long ActorId, _SND_tdstVectorFloat* OutSpeed)
{
float* out = reinterpret_cast<float*>(OutSpeed);
out[0] = out[1] = out[2] = 0.0f;
if (!ActorId) return;
char* p = reinterpret_cast<char*>((void*)(size_t)(DWORD)ActorId);
out[0] =  *(float*)(p + 0x24c); //  Velocity.X
out[1] = -*(float*)(p + 0x250); // -Velocity.Y (coordinate flip)
out[2] =  *(float*)(p + 0x254); //  Velocity.Z
}

IMPL_MATCH("DareAudio.dll", 0x10003880)
long __stdcall UDareAudioSubsystem::GetActorSwitch(long ActorId, long SwitchId)
{
return 0;
}

IMPL_MATCH("DareAudio.dll", 0x10002ac0)
void __stdcall UDareAudioSubsystem::GetMicroPos(long MicroId, _SND_tdstVectorFloat* OutPos)
{
float* out = reinterpret_cast<float*>(OutPos);
out[0] = out[1] = out[2] = 0.0f;

UViewport* vp = UDareAudioSubsystem::m_pViewport;
if (!vp) return;

// Viewport+0x34 = controller pointer
char* vpData = reinterpret_cast<char*>(vp);
void* ctrl = *(void**)(vpData + 0x34);
if (!ctrl) return;

// Controller+0x5b8 = pawn pointer
char* ctrlData = reinterpret_cast<char*>(ctrl);
void* pawn = *(void**)(ctrlData + 0x5b8);
if (!pawn) return;

char* p = reinterpret_cast<char*>(pawn);
out[0] =  *(float*)(p + 0x234); //  Location.X
out[1] = -*(float*)(p + 0x238); // -Location.Y
out[2] =  *(float*)(p + 0x23c); //  Location.Z
}

IMPL_MATCH("DareAudio.dll", 0x10002b50)
void __stdcall UDareAudioSubsystem::GetMicroSpeed(long MicroId, _SND_tdstVectorFloat* OutSpeed)
{
float* out = reinterpret_cast<float*>(OutSpeed);
out[0] = out[1] = out[2] = 0.0f;

UViewport* vp = UDareAudioSubsystem::m_pViewport;
if (!vp) return;

char* vpData = reinterpret_cast<char*>(vp);
void* ctrl = *(void**)(vpData + 0x34);
if (!ctrl) return;

char* ctrlData = reinterpret_cast<char*>(ctrl);
void* pawn = *(void**)(ctrlData + 0x5b8);
if (!pawn) return;

char* p = reinterpret_cast<char*>(pawn);
out[0] =  *(float*)(p + 0x24c);
out[1] = -*(float*)(p + 0x250);
out[2] =  *(float*)(p + 0x254);
}

IMPL_MATCH("DareAudio.dll", 0x10002be0)
void __stdcall UDareAudioSubsystem::GetMicroNormal(long MicroId, _SND_tdstVectorFloat* OutNormal)
{
float* out = reinterpret_cast<float*>(OutNormal);
out[0] = 1.0f; out[1] = 0.0f; out[2] = 0.0f; // default: facing +X

UViewport* vp = UDareAudioSubsystem::m_pViewport;
if (!vp) return;

char* vpData = reinterpret_cast<char*>(vp);
void* ctrl = *(void**)(vpData + 0x34);
if (!ctrl) return;

char* ctrlData = reinterpret_cast<char*>(ctrl);
void* pawn = *(void**)(ctrlData + 0x5b8);
if (!pawn) return;

char* p = reinterpret_cast<char*>(pawn);
INT pitch = *(INT*)(p + 0x240);
INT yaw   = *(INT*)(p + 0x244);
INT roll  = *(INT*)(p + 0x248);

// FRotatorF converts UE2 int rotation units to float and computes
// the forward (normal) vector.
FRotatorF rot((FLOAT)pitch, (FLOAT)yaw, (FLOAT)roll);
FVector fwd = rot.Vector();

out[0] =  fwd.X;
out[1] = -fwd.Y; // coordinate flip
out[2] =  fwd.Z;
}

IMPL_MATCH("DareAudio.dll", 0x10002ce0)
void __stdcall UDareAudioSubsystem::GetMicroTangeant(long MicroId, _SND_tdstVectorFloat* OutTangent)
{
float* out = reinterpret_cast<float*>(OutTangent);
out[0] = 0.0f; out[1] = 1.0f; out[2] = 0.0f; // default: right

UViewport* vp = UDareAudioSubsystem::m_pViewport;
if (!vp) return;

char* vpData = reinterpret_cast<char*>(vp);
void* ctrl = *(void**)(vpData + 0x34);
if (!ctrl) return;

char* ctrlData = reinterpret_cast<char*>(ctrl);
void* pawn = *(void**)(ctrlData + 0x5b8);
if (!pawn) return;

char* p = reinterpret_cast<char*>(pawn);
INT yaw = *(INT*)(p + 0x244);

// Rotate yaw +16384 (90 deg in UE2 units) to get the right vector
FRotatorF rightRot(0.0f, (FLOAT)(yaw + 16384), 0.0f);
FVector right = rightRot.Vector();

out[0] =  right.X;
out[1] = -right.Y;
out[2] =  right.Z;
}

IMPL_MATCH("DareAudio.dll", 0x10002a50)
void __stdcall UDareAudioSubsystem::GetSoundExtraCoef(long ActorId, _SND_tdstBlockEvent* Event, FLOAT* OutCoef1, FLOAT* OutCoef2, FLOAT* OutCoef3)
{
if (OutCoef1) *OutCoef1 = 1.0f;
if (OutCoef2) *OutCoef2 = 1.0f;
if (OutCoef3) *OutCoef3 = 1.0f;
}

