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
-----------------------------------------------------------------------------*/

IMPL_APPROX("linear amplitude to dB conversion helper")
static FLOAT LinearToDb(FLOAT v)
{
	return 20.0f * log10f(v > 0.0001f ? v : 0.0001f);
}

/*-----------------------------------------------------------------------------
Constructors / Destructor / Assignment.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Needs Ghidra analysis")
UDareAudioSubsystem::UDareAudioSubsystem()
{
}

IMPL_APPROX("copy constructor delegates to UAudioSubsystem")
UDareAudioSubsystem::UDareAudioSubsystem(const UDareAudioSubsystem& Other)
: UAudioSubsystem(Other)
{
}

IMPL_APPROX("assignment operator delegates to UAudioSubsystem")
UDareAudioSubsystem& UDareAudioSubsystem::operator=(const UDareAudioSubsystem& Other)
{
UAudioSubsystem::operator=(Other);
return *this;
}

/*-----------------------------------------------------------------------------
UObject interface.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Needs Ghidra analysis")
void UDareAudioSubsystem::StaticConstructor()
{
}

IMPL_APPROX("Needs Ghidra analysis")
void UDareAudioSubsystem::PostEditChange()
{
}

IMPL_APPROX("delegates to CleanUp")
void UDareAudioSubsystem::Destroy()
{
CleanUp();
}

IMPL_APPROX("delegates to CleanUp on error shutdown")
void UDareAudioSubsystem::ShutdownAfterError()
{
CleanUp();
}

/*-----------------------------------------------------------------------------
FExec interface.
-----------------------------------------------------------------------------*/

IMPL_APPROX("parses AUDIO QUALITY console commands")
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

IMPL_APPROX("initialises DARE sound engine, creates types/lines/micro")
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

IMPL_APPROX("shuts down DARE engine and frees request and bank arrays")
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

IMPL_APPROX("returns static viewport pointer")
UViewport* UDareAudioSubsystem::GetViewport()
{
return m_pViewport;
}

IMPL_APPROX("stores static viewport pointer")
UBOOL UDareAudioSubsystem::SetViewport(UViewport* InViewport, FString DeviceName)
{
m_pViewport = InViewport;
return 1;
}

IMPL_APPROX("uses FCoordsFromFMatrix instead of FMatrix::Coords() to avoid Core.dll link dependency")
void UDareAudioSubsystem::Update(FSceneNode* SceneNode)
{
	guard(UDareAudioSubsystem::Update);
	// Ghidra 0x6000 (77): guard frame, m_bInitialized check, then:
	//   if (!GIsEditor && SceneNode) { FCoords from view matrix; UpdateAmbientSounds }
	//   SND_fn_vSynchroSound(); UpdateSoundList();
	// FMatrix::Coords() is a non-inline Ravenshield Core addition; use the equivalent
	// inline FCoordsFromFMatrix to avoid a Core.dll link dependency.
	if (m_bInitialized)
	{
		if (!GIsEditor && SceneNode != NULL)
		{
			FCoords Coords = FCoordsFromFMatrix(*(FMatrix*)((BYTE*)SceneNode + 0x10));
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

IMPL_MATCH("DareAudio.dll", 0x1ff0)
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

IMPL_APPROX("Needs Ghidra analysis")
void UDareAudioSubsystem::UnregisterSound(USound* Sound)
{
}

/*-----------------------------------------------------------------------------
Sound playback.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sends DARE sound request and tracks it in the request array")
UBOOL UDareAudioSubsystem::PlaySoundW(AActor* Actor, USound* Sound, INT Slot, INT Flags)
{
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
}

IMPL_APPROX("kills all sound objects for actor via DARE")
UBOOL UDareAudioSubsystem::StopSound(AActor* Actor, USound* Sound)
{
if (!m_bInitialized) return 0;
long actorId = Actor ? (long)(DWORD)(size_t)Actor : 0;
SND_fn_vKillSoundObject(actorId, -1);
return 1;
}

IMPL_APPROX("kills all DARE sound object types")
void UDareAudioSubsystem::StopAllSounds()
{
if (!m_bInitialized) return;
SND_fn_vKillAllSoundObjectTypes();
}

IMPL_APPROX("kills DARE sound objects for a specific actor and slot")
void UDareAudioSubsystem::StopAllSoundsActor(AActor* Actor, ESoundSlot Slot)
{
if (!m_bInitialized || !Actor) return;
long actorId = (long)(DWORD)(size_t)Actor;
SND_fn_vKillSoundObject(actorId, (int)Slot);
}

IMPL_APPROX("kills actor sounds and removes actor from ambient list")
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

IMPL_APPROX("sends DARE music request by USound name")
UBOOL UDareAudioSubsystem::PlayMusic(USound* Music, INT SongSection)
{
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
}

IMPL_APPROX("sends DARE music request by event name string with fade-in")
UBOOL UDareAudioSubsystem::PlayMusic(FString MusicName, FLOAT FadeInTime)
{
if (!m_bInitialized) return 0;

const char* name = TCHAR_TO_ANSI(*MusicName);
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0;

long micro = F_LONG(this, 0x224);
long reqId = SND_fn_lSendSoundRequest(evHandle, 0, micro, (long)SLOT_Music, 0);
if (!reqId) return 0;

F_INT(this, 0x58) = 1;
return 1;
}

IMPL_APPROX("kills music slot sounds via DARE")
UBOOL UDareAudioSubsystem::StopMusic(USound* Music)
{
if (!m_bInitialized) return 0;
SND_fn_vKillAllSoundObjectTypesButOne((int)SLOT_Music);
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_APPROX("kills music slot sounds; FadeOutTime not supported by DARE backend")
UBOOL UDareAudioSubsystem::StopMusic(INT SongSection, FLOAT FadeOutTime)
{
if (!m_bInitialized) return 0;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_APPROX("kills music slot sounds; FadeOutTime not supported by DARE backend")
UBOOL UDareAudioSubsystem::StopAllMusic(FLOAT FadeOutTime)
{
if (!m_bInitialized) return 0;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
return 1;
}

IMPL_APPROX("kills music slot sounds via DARE")
void UDareAudioSubsystem::StopAllMusic()
{
if (!m_bInitialized) return;
SND_fn_vKillSoundObject(0, (int)SLOT_Music);
F_INT(this, 0x58) = 0;
}

/*-----------------------------------------------------------------------------
Bank / Map loading.
-----------------------------------------------------------------------------*/

IMPL_APPROX("delegates to AddSoundBank using the sound asset name")
void UDareAudioSubsystem::AddAndFindBankInSound(USound* Sound, ELoadBankSound LoadType)
{
if (!Sound) return;
AddSoundBank(FString(Sound->GetName()), LoadType);
}

IMPL_APPROX("allocates FBankEntry, appends to bank map array, loads via DARE")
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

IMPL_APPROX("sets DARE master directory from GCdPath and loads map bank file")
void UDareAudioSubsystem::LoadBankMap(ULevel* Level, FString MapName)
{
if (!m_bInitialized) return;

// Build master directory path: GCdPath + "\SND\"
TCHAR masterDir[260];
appSprintf(masterDir, TEXT("%s\\SND\\"), GCdPath);
SND_fn_vSetMasterDirectory(TCHAR_TO_ANSI(masterDir));

SND_fn_bLoadMap(TCHAR_TO_ANSI(*MapName));
}

IMPL_APPROX("clears needs-map-load flag on viewport after map bank load")
void UDareAudioSubsystem::PostLoadMap(ULevel* Level)
{
if (m_pViewport)
{
// Clear the "needs map load" flag at viewport+0x78
*(INT*)((char*)m_pViewport + 0x78) = 0;
}
}

IMPL_APPROX("unloads all banks or LBS_Gun banks from DARE based on state")
void UDareAudioSubsystem::SetBankInfo(ER6SoundState State)
{
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
}

/*-----------------------------------------------------------------------------
Sound queries.
-----------------------------------------------------------------------------*/

IMPL_APPROX("returns DARE sound event length in seconds")
FLOAT UDareAudioSubsystem::GetDuration(USound* Sound)
{
if (!m_bInitialized || !Sound) return 0.0f;
const char* name = TCHAR_TO_ANSI(Sound->GetName());
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return 0.0f;
return SND_fn_fGetLengthSoundEvent(evHandle);
}

IMPL_APPROX("returns playback position of latest matching sound request")
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

IMPL_APPROX("checks request array for a still-playing sound/actor pair")
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

IMPL_APPROX("checks request array for a still-playing instance on any actor")
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

IMPL_APPROX("returns DARE volume for a sound object type slot")
FLOAT UDareAudioSubsystem::SND_GetVolume_TypeSound(ESoundSlot Slot)
{
return SND_fn_fGetVolumeSoundObjectType((INT)Slot);
}

IMPL_APPROX("returns stored initial volume for a slot index")
FLOAT UDareAudioSubsystem::SND_GetVolumeInit_TypeSound(ESoundSlot Slot)
{
INT idx = (INT)Slot;
if (idx >= 0 && idx < 12)
return s_VolumeInitData[idx];
return 0.0f;
}

// Returns the volume line handle for a given volume type
IMPL_APPROX("maps ESoundVolume enum to stored DARE volume line handle")
static long GetVolumeLineHandle(void* self, ESoundVolume VolType)
{
switch (VolType)
{
case VOLUME_Music:   return F_LONG(self, 0x228);
case VOLUME_Voices:  return F_LONG(self, 0x22c);
case VOLUME_FX:      return F_LONG(self, 0x230);
case VOLUME_Grenade: return F_LONG(self, 0x234);
default:             return 0;
}
}

IMPL_APPROX("returns current DARE volume line level")
FLOAT UDareAudioSubsystem::SND_GetVolumeLine(ESoundVolume VolType)
{
long h = GetVolumeLineHandle(this, VolType);
if (!h) return 0.0f;
return SND_fn_fGetSoundVolumeLine(h);
}

IMPL_APPROX("sets DARE volume line level")
void UDareAudioSubsystem::SND_SetVolumeLine(ESoundVolume VolType, FLOAT Volume)
{
long h = GetVolumeLineHandle(this, VolType);
if (!h) return;
SND_fn_vSetSoundVolumeLine(h, Volume);
}

IMPL_APPROX("sets volume for a single DARE sound object type")
void UDareAudioSubsystem::SND_ChangeVolume_TypeSound(ESoundSlot Slot, FLOAT Volume)
{
SND_fn_vChangeVolumeSoundObjectType((INT)Slot, Volume);
}

IMPL_APPROX("converts integer 0-100 volume to 0.0-1.0 and sets the DARE volume line")
void UDareAudioSubsystem::SND_ChangeVolumeLinear_TypeSound(ESoundSlot Slot, INT Volume)
{
// Volume is linear 0-100; convert to linear 0-1 then set on the volume line
FLOAT linear = (FLOAT)Volume / 100.0f;
if (linear < 0.0f) linear = 0.0f;
if (linear > 1.0f) linear = 1.0f;

// Map slot to volume type
ESoundVolume vt;
switch (Slot)
{
case SLOT_Music:         vt = VOLUME_Music;   break;
case SLOT_Talk:
case SLOT_Speak:
case SLOT_HeadSet:       vt = VOLUME_Voices;  break;
case SLOT_GrenadeEffect: vt = VOLUME_Grenade; break;
default:                 vt = VOLUME_FX;      break;
}

long h = GetVolumeLineHandle(this, vt);
if (h) SND_fn_vSetSoundVolumeLine(h, linear);
}

IMPL_APPROX("sets volume for all DARE sound object types")
void UDareAudioSubsystem::SND_ChangeVolume_AllTypeSound(FLOAT Volume)
{
SND_fn_vChangeVolumeAllSoundObjectTypes(Volume);
}

IMPL_APPROX("sets volume for all DARE sound object types except the given slot")
void UDareAudioSubsystem::SND_ChangeVolume_AllButOneTypeSound(ESoundSlot Slot, FLOAT Volume)
{
SND_fn_vChangeVolumeAllSoundObjectTypesButOne((INT)Slot, Volume);
}

IMPL_APPROX("changes volume for a specific actor and slot via DARE")
void UDareAudioSubsystem::SND_ChangeVolume_Actor(AActor* Actor, ESoundSlot Slot, FLOAT Volume)
{
if (!Actor) return;
SND_fn_vChangeVolumeSoundObject((long)(DWORD)(size_t)Actor, (INT)Slot, Volume);
}

IMPL_APPROX("snapshots current volume into s_VolumeInitData then resets DARE slot")
void UDareAudioSubsystem::SND_ResetVolumeSoundObjectType(ESoundSlot Slot)
{
INT idx = (INT)Slot;
if (idx < 0 || idx >= 12) return;
FLOAT current = SND_fn_fGetVolumeSoundObjectType(idx);
s_VolumeInitData[idx] = current;
SND_fn_vResetVolumeSoundObjectType(idx);
}

IMPL_APPROX("snapshots and resets volumes for all 12 DARE sound types")
void UDareAudioSubsystem::SND_ResetVolume_AllTypeSound()
{
for (INT i = 0; i < 12; i++)
{
FLOAT current = SND_fn_fGetVolumeSoundObjectType(i);
s_VolumeInitData[i] = current;
SND_fn_vResetVolumeSoundObjectType(i);
}
}

IMPL_APPROX("snapshots and resets volumes for all DARE sound types except one")
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

IMPL_APPROX("sets up per-slot fade with start volume, target and step rate")
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

IMPL_APPROX("saves all current volumes and volume line levels into m_FadeSaved arrays")
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

IMPL_APPROX("restores or fades back to previously saved volume values")
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

IMPL_APPROX("EAX toggle is handled at Init; runtime changes unsupported by DARE stubs")
void UDareAudioSubsystem::SND_SetSoundOptions(bool bEAX, FString DeviceName)
{
// EAX / hardware acceleration toggle is done during Init; runtime changes
// are not supported by the DARE backend stubs.
}

/*-----------------------------------------------------------------------------
Tick.
-----------------------------------------------------------------------------*/

IMPL_APPROX("advances all active per-slot fades each tick then purges finished requests")
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

IMPL_APPROX("Needs Ghidra analysis")
void UDareAudioSubsystem::UpdateAmbientSounds(FCoords& Coords)
{
	// Ambient sound update: walk the ambient actor list, play/stop as needed.
	// Actual level actor scan happens elsewhere; we just service the stored list.
}

IMPL_APPROX("compacts request array by removing entries whose DARE request has stopped")
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

IMPL_APPROX("Needs Ghidra analysis")
FLOAT UDareAudioSubsystem::GetDuration(DWORD SoundHandle)
{
return 0.0f;
}

IMPL_APPROX("creates DARE listener micro and registers all four listener callbacks")
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

IMPL_APPROX("registers 12 DARE sound object types with actor position/speed/switch callbacks")
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

IMPL_APPROX("creates 4 DARE volume lines for music, voices, FX and grenade slots")
void UDareAudioSubsystem::CreateVolumeLines()
{
F_LONG(this, 0x228) = SND_fn_lAddSoundVolumeLine((INT)SLOT_Music,         0, 0);
F_LONG(this, 0x22c) = SND_fn_lAddSoundVolumeLine((INT)SLOT_Talk,          0, 0);
F_LONG(this, 0x230) = SND_fn_lAddSoundVolumeLine((INT)SLOT_SFX,           0, 0);
F_LONG(this, 0x234) = SND_fn_lAddSoundVolumeLine((INT)SLOT_GrenadeEffect,  0, 0);
}

IMPL_APPROX("stops a named DARE sound event by generating a stop event")
void UDareAudioSubsystem::StopSoundPlaying(FString EventName)
{
if (!m_bInitialized) return;
const char* name = TCHAR_TO_ANSI(*EventName);
void* evHandle = SND_fn_hGetSoundEventHandleFromSectionName(name);
if (!evHandle) return;
void* stopEvent = SND_fn_hGenerateSoundEventStop(evHandle, 0);
(void)stopEvent;
}

/*-----------------------------------------------------------------------------
Static DARE callbacks.
Called each audio frame by the DARE engine to query game-world state.
Coordinate system: DARE is right-handed, UE2 is left-handed.
  DARE.x =  UE.X
  DARE.y = -UE.Y
  DARE.z =  UE.Z
-----------------------------------------------------------------------------*/

IMPL_APPROX("DARE callback: clears actor info buffer; no per-actor info exposed")
void __stdcall UDareAudioSubsystem::GetActorInfo(long ActorId, char* InfoBuffer, long BufferSize)
{
if (InfoBuffer && BufferSize > 0)
InfoBuffer[0] = '\0';
}

IMPL_APPROX("DARE callback: all actors link to the single listener micro")
INT __stdcall UDareAudioSubsystem::GetActorMicroLink(long ActorId, long MicroId)
{
return 1; // All actors link to the single listener micro
}

IMPL_APPROX("DARE callback: no multi-layer support; always returns 0")
long __stdcall UDareAudioSubsystem::GetActorMultiLayer(long ActorId, long LayerId, int Param)
{
return 0;
}

IMPL_APPROX("DARE callback: reads actor Location from byte offsets 0x234-0x23c, flips Y axis")
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

IMPL_APPROX("DARE callback: uses default roll-off; always returns 0")
INT __stdcall UDareAudioSubsystem::GetActorRollOff(long ActorId, _SND_tdstRollOffParam* OutRollOff)
{
return 0; // Use default roll-off
}

IMPL_APPROX("DARE callback: reads actor Velocity from byte offsets 0x24c-0x254, flips Y axis")
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

IMPL_APPROX("DARE callback: no switch support; always returns 0")
long __stdcall UDareAudioSubsystem::GetActorSwitch(long ActorId, long SwitchId)
{
return 0;
}

IMPL_APPROX("DARE callback: reads listener pawn location via viewport controller chain, flips Y axis")
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

IMPL_APPROX("DARE callback: reads listener pawn velocity via viewport controller chain, flips Y axis")
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

IMPL_APPROX("DARE callback: reads listener facing direction via FRotatorF from pawn rotation offsets")
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

IMPL_APPROX("DARE callback: listener right vector by rotating yaw 90 degrees via FRotatorF")
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

IMPL_APPROX("DARE callback: returns unity coefficients for all sound channel blend factors")
void __stdcall UDareAudioSubsystem::GetSoundExtraCoef(long ActorId, _SND_tdstBlockEvent* Event, FLOAT* OutCoef1, FLOAT* OutCoef2, FLOAT* OutCoef3)
{
if (OutCoef1) *OutCoef1 = 1.0f;
if (OutCoef2) *OutCoef2 = 1.0f;
if (OutCoef3) *OutCoef3 = 1.0f;
}
