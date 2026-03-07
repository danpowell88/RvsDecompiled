/*=============================================================================
	R6GameServicePrivate.h: R6GameService private header file.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_R6GAMESERVICE_PRIVATE
#define _INC_R6GAMESERVICE_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  R6GAMESERVICE_API
#define R6GAMESERVICE_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif
#ifndef R6ABSTRACT_API
#define R6ABSTRACT_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Engine / Core / R6 headers.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

#include "Engine.h"
#include "R6AbstractClasses.h"
#include "R6GameServiceClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS macro.
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
