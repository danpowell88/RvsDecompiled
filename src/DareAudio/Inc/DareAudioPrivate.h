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

#endif
