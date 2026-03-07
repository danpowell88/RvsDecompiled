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
	Actual values would come from UnrealScript enum definitions.
----------------------------------------------------------------------------*/

enum ESoundSlot
{
	SLOT_None    = 0,
	SLOT_MAX     = 0xFF
};

enum ESoundVolume
{
	SNDVOL_Default = 0,
	SNDVOL_MAX     = 0xFF
};

enum ELoadBankSound
{
	LOADBANK_Default = 0,
	LOADBANK_MAX     = 0xFF
};

enum ER6SoundState
{
	R6SS_Default = 0,
	R6SS_MAX     = 0xFF
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
