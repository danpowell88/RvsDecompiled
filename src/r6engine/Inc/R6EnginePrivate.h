/*=============================================================================
	R6EnginePrivate.h: R6Engine private header file.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_R6ENGINE_PRIVATE
#define _INC_R6ENGINE_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  R6ENGINE_API
#define R6ENGINE_API DLL_EXPORT

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
	Engine / Core / R6Abstract headers.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

#include "Engine.h"
#include "R6AbstractClasses.h"
#include "R6EngineClasses.h"

// R6 overload: appMsgf(INT Type, const TCHAR* Fmt, ...)
// Original UT signature was void(const TCHAR*,...); R6 changed to int(int,...).
// Exported from Core.dll; declared here for R6Engine use.
CORE_API const INT appMsgf(INT Type, const TCHAR* Fmt, ...);

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
