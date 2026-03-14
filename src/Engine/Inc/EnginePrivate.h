/*=============================================================================
	EnginePrivate.h: Unreal engine private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_ENGINE_PRIVATE
#define _INC_ENGINE_PRIVATE

/*----------------------------------------------------------------------------
	Engine public includes.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

// We are building (exporting) Engine.dll — override the DLL_IMPORT in SDK headers.
#undef  ENGINE_API
#define ENGINE_API DLL_EXPORT

// Local Engine.h → Core.h (no UnPrim.h) → UnPrim.h (DECLARE_CLASS) → EngineClasses.h (DECLARE_CLASS).
#include "Engine.h"

// Fix IMPLEMENT_CLASS for MSVC 2019+ and CSDK private members.
// 1. C3867: needs & for pointer-to-member (CSDK macro was for MSVC 7.1)
// 2. UObject::WithinClass and GUID1-4 are private in CSDK — hardcode the
//    values since all Engine classes use UObject as WithinClass and zero GUIDs.
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

// Forward declarations for Engine types used in virtual function signatures.
class UViewport;
class FSceneNode;

#pragma pack(pop)

// Function source attribution macros (IMPL_GHIDRA, IMPL_TODO, etc.)
// Sourced from src/Core/Inc/ImplSource.h — zero compile-time overhead.
#include "ImplSource.h"

/*----------------------------------------------------------------------------
    Missing Core.dll exports not declared in the community SDK headers.
    Verified against retail Core.dll via Ghidra / dumpbin.
    (The SDK is a community project and may omit or misrepresent symbols.)
----------------------------------------------------------------------------*/

// GScriptEntryTag — script call depth counter (Core.dll export ?GScriptEntryTag@@3HA).
// Used together with GScriptCycles to track script execution entry/exit.
// GScriptCycles is declared in Core.h; this companion variable was omitted from the SDK.
CORE_API extern INT GScriptEntryTag;

// g_pEngine — Ravenshield-specific engine pointer (Engine.dll export ?g_pEngine@@3PAVUEngine@@A).
// Set in UGameEngine::Init() and read by camera/rendering code.
// Distinct from GEngine (the standard UE2 global). Defined in UnCamera.cpp.
ENGINE_API extern UEngine* g_pEngine;

#endif
