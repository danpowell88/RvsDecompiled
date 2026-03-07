/*=============================================================================
	IpDrvPrivate.h: IpDrv private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_IPDRV_PRIVATE
#define _INC_IPDRV_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  IPDRV_API
#define IPDRV_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Winsock — must come before Engine.h because Engine.h → Core.h
	may pull in windows.h; winsock2.h must be included first to
	avoid winsock.h/winsock2.h conflicts.
----------------------------------------------------------------------------*/

#define WINDOWS_IGNORE_PACKING_MISMATCH
#include <winsock2.h>

/*----------------------------------------------------------------------------
	Engine / Core headers.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)

#include "Engine.h"

/*----------------------------------------------------------------------------
	Engine types not included by our local Engine.h.
	IpDrv references these in function signatures but our stub
	Engine.h omits the UT99 headers that define them.
----------------------------------------------------------------------------*/

class FNetworkNotify;
class FURL;
enum EConnectionState;

/*----------------------------------------------------------------------------
	Forward declarations.
----------------------------------------------------------------------------*/

class FResolveInfo;

/*----------------------------------------------------------------------------
	IpDrv class declarations.
----------------------------------------------------------------------------*/

#include "IpDrvClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS fix for MSVC 2019+ — same pattern as Core/Engine/Fire.
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
