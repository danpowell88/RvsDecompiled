/*=============================================================================
	DareAudioPrivate.h: DARE Audio Subsystem private header.
	Reconstructed for Ravenshield decompilation project.

	UDareAudioSubsystem is the Unreal Engine bridge to the DARE (Digital Audio
	Rendering Engine) middleware by Ubi Soft Montreal's audio team.
	87 exports. 3 DLL variants (DareAudio, DareAudioRelease, DareAudioScript)
	share identical export tables but link different SNDDSound3D backends.
=============================================================================*/

#ifndef _INC_DAREAUDIO_PRIVATE
#define _INC_DAREAUDIO_PRIVATE

#pragma pack(push, 4)

/*----------------------------------------------------------------------------
	API macros.
----------------------------------------------------------------------------*/

#undef  DAREAUDIO_API
#define DAREAUDIO_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Engine includes.
----------------------------------------------------------------------------*/

#include "Engine.h"

/*----------------------------------------------------------------------------
	DARE sound engine forward declarations.
	These structs are defined in the DARE middleware headers. We only need
	pointers to them for the callback signatures.
----------------------------------------------------------------------------*/

struct _SND_tdstVectorFloat;
struct _SND_tdstRollOffParam;
struct _SND_tdstBlockEvent;

/*----------------------------------------------------------------------------
	Enums used by DareAudioSubsystem.
	These are Unreal-side enums that map to DARE sound object types.
	Values from sdk/Raven_Shield_C_SDK/inc/EngineClasses.h and confirmed
	against Ghidra switch tables in DareAudio.dll.
----------------------------------------------------------------------------*/

enum ESoundSlot
{
	SLOT_None           = 0,
	SLOT_Ambient        = 1,
	SLOT_Guns           = 2,
	SLOT_SFX            = 3,
	SLOT_GrenadeEffect  = 4,
	SLOT_Music          = 5,
	SLOT_Talk           = 6,
	SLOT_Speak          = 7,
	SLOT_HeadSet        = 8,
	SLOT_Menu           = 9,
	SLOT_Instruction    = 10,
	SLOT_StartingSound  = 11,
};

enum ESoundVolume
{
	VOLUME_Music    = 0,
	VOLUME_Voices   = 1,
	VOLUME_FX       = 2,
	VOLUME_Grenade  = 3,
};

enum ELoadBankSound
{
	LBS_Fix = 0,
	LBS_UC  = 1,
	LBS_Map = 2,
	LBS_Gun = 3,
};

enum ER6SoundState
{
	BANK_UnloadGun = 0,
	BANK_UnloadAll = 1,
};

/*----------------------------------------------------------------------------
	Forward declarations for types used in method signatures.
----------------------------------------------------------------------------*/

class FSceneNode;
class FCoords;

/*----------------------------------------------------------------------------
	DARE Sound Engine API declarations.
	Three groups by calling convention:
	  1. C++ name-mangled (no extern "C")
	  2. __stdcall with extern "C"
	  3. __cdecl  with extern "C"
	Stubs live in SNDDSound3DDLL_ret.lib; cdecl stubs have no declared params
	but cdecl caller-cleans-stack so calling with args works regardless.
----------------------------------------------------------------------------*/

// Group 1 -- C++ name-mangled exports
enum _SND_tdeHTRFType { SND_HRTF_NONE = 0 };
void SND_fn_vDisableHardwareAcceleration(int bDisable);
void SND_fn_vSetHRTFOption(_SND_tdeHTRFType eType);

// Group 2 -- __stdcall exports (extern "C", decorated _Name@N)
extern "C" {
int   __stdcall SND_fn_eInitSxd(const char* p0);
void  __stdcall SND_fn_vDesInitSxd(void);
long  __stdcall SND_fn_lCreateMicroSxd(long dummy);
void  __stdcall SND_fn_vDestroyMicroSxd(long handle);
void  __stdcall SND_fn_vSetMicroParamSxd(long handle, void* param);
void  __stdcall SND_fn_vSetMasterDirectory(const char* dir);
void  __stdcall SND_fn_vSetCurrentLangDirectory(const char* dir);
void  __stdcall SND_fn_vSetCurrentLanguage(const char* lang);
int   __stdcall SND_fn_bLoadMap(const char* mapName);
int   __stdcall SND_fn_bLoadBank(const char* bankName);
int   __stdcall SND_fn_bUnLoadBank(const char* bankName);
int   __stdcall SND_fn_bGetMasterDirectory(char* buf, int size);
void* __stdcall SND_fn_hGetSoundEventHandleFromSectionName(const char* name);
void  __stdcall SND_fn_vPurgeAllDirectories(void);
void  __stdcall SND_fn_vAddPartialDirectory(const char* dir);
}

// Group 3 -- __cdecl exports (extern "C", undecorated names)
// Stubs have no params but cdecl linking is by undecorated name only.
extern "C" {
int   SND_fn_eInitSound(void);
void  SND_fn_vDesInitSound(void);
long  SND_fn_lCreateSoundMicro(void);
void  SND_fn_vDestroySoundMicro(long handle);
long  SND_fn_lAddSoundObjectType(int slotId, void* pos, void* speed, void* sw, void* ml, void* ro);
long  SND_fn_lAddSoundVolumeLine(int id, int unused, int unused2);
void  SND_fn_vSetSoundVolumeLine(long lineHandle, float vol);
float SND_fn_fGetSoundVolumeLine(long lineHandle);
void  SND_fn_vChangeVolumeSoundObjectType(int slotId, float vol);
void  SND_fn_vChangeVolumeAllSoundObjectTypes(float vol);
void  SND_fn_vChangeVolumeAllSoundObjectTypesButOne(int slotId, float vol);
void  SND_fn_vChangeVolumeSoundObject(long actorId, int slotId, float vol);
float SND_fn_fGetVolumeSoundObjectType(int slotId);
void  SND_fn_vResetVolumeSoundObjectType(int slotId);
void  SND_fn_vKillAllSoundObjectTypes(void);
void  SND_fn_vKillAllSoundObjectTypesButOne(int slotId);
void  SND_fn_vKillSoundObject(long actorId, int slotId);
void  SND_fn_vKillSoundObjectWithFade(long actorId, int slotId, float fadeTime);
void  SND_fn_vSetRetSoundObjectType(long handle, void* pos, void* speed, void* sw);
void  SND_fn_vSetRetSoundMicros(void* pos, void* speed, void* normal, void* tangent);
void  SND_fn_vSetRetInfoSoundObjectType(long handle, void* info, void* ml);
void  SND_fn_vSetRetRollOffSoundObjectType(long handle, void* ro);
void  SND_fn_vSetRetSoundChannelType(long handle, void* coef);
long  SND_fn_lSendSoundRequest(void* evHandle, long actorId, long microHandle, long typeHandle, int flags);
int   SND_fn_bIsSoundRequestPlaying(long reqId);
long  SND_fn_lGetLatestPlayingSoundRequest(long actorId, void* evHandle, int slot);
void  SND_fn_vKillSoundChannel(long reqId, float fadeTime);
float SND_fn_fGetLengthSoundEvent(void* evHandle);
float SND_fn_fGetPosSoundRequest(long reqId);
void* SND_fn_hGenerateSoundEventPlay(void* evHandle, long actorId, long micro);
void* SND_fn_hGenerateSoundEventStop(void* evHandle, long actorId);
void* SND_fn_hGetLastSoundEventOfSoundObjectType(long actorId, int slot);
void  SND_fn_vSynchroSound(void);
int   SND_fn_bIsEAXCompatible(void);
void  SND_fn_bEnableEAX(unsigned int bEnable);
}

/*----------------------------------------------------------------------------
	DareAudio classes.
----------------------------------------------------------------------------*/

#include "DareAudioClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS override for MSVC 2019+ and CSDK private members.
----------------------------------------------------------------------------*/

#undef IMPLEMENT_CLASS
#define IMPLEMENT_CLASS(TClass) \
	UClass TClass::PrivateStaticClass \
	( \
		EC_NativeConstructor, \
		sizeof(TClass), \
		TClass::StaticClassFlags, \
		TClass::Super::StaticClass(), \
		UObject::StaticClass(), \
		FGuid(0,0,0,0), \
		TEXT(#TClass)+1, \
		GPackage, \
		StaticConfigName(), \
		RF_Public | RF_Standalone | RF_Transient | RF_Native, \
		(void(*)(void*))TClass::InternalConstructor, \
		(void(UObject::*)())&TClass::StaticConstructor \
	); \
	extern "C" DLL_EXPORT UClass* autoclass##TClass;\
	DLL_EXPORT UClass* autoclass##TClass = TClass::StaticClass();

#pragma pack(pop)

#include "ImplSource.h"

#endif
