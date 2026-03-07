/*=============================================================================
	R6AbstractPrivate.h: R6Abstract private header file.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_R6ABSTRACT_PRIVATE
#define _INC_R6ABSTRACT_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  R6ABSTRACT_API
#define R6ABSTRACT_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Engine / Core headers.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

#include "Engine.h"

/*----------------------------------------------------------------------------
	Forward declarations for R6Engine types used as base classes.
	R6Engine depends on R6Abstract, not vice-versa. We stub the
	base classes here so R6Abstract can compile standalone.
----------------------------------------------------------------------------*/

// Defined inline in R6AbstractClasses.h via the #ifndef R6ENGINE_API guard.

/*----------------------------------------------------------------------------
	R6Abstract class declarations.
----------------------------------------------------------------------------*/

#include "R6AbstractClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS macro — same pattern as Fire/IpDrv/Window/WinDrv/D3DDrv.
	Generates PrivateStaticClass, autoclass export, and StaticClass().
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
