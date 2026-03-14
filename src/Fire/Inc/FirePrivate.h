/*=============================================================================
	FirePrivate.h: Unreal fire effects private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_FIRE_PRIVATE
#define _INC_FIRE_PRIVATE

/*----------------------------------------------------------------------------
	Fire public includes.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

// We are building (exporting) Fire.dll.
#undef  FIRE_API
#define FIRE_API DLL_EXPORT

// Core and Engine are imported.
#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

#include "Engine.h"
#include "FireClasses.h"

// Fix IMPLEMENT_CLASS for MSVC 2019+ and CSDK private members.
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
