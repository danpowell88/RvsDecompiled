/*=============================================================================
	WinDrvPrivate.h: WinDrv private header — Windows viewport and DirectInput.
	Copyright 1997-2004 Epic Games, Inc. / Ubisoft Montreal. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_WINDRV_PRIVATE
#define _INC_WINDRV_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

#undef  WINDRV_API
#define WINDRV_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif
#ifndef WINDOW_API
#define WINDOW_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Win32 system headers.
----------------------------------------------------------------------------*/

#define WINDOWS_IGNORE_PACKING_MISMATCH

// The DX8 SDK ships its own basetsd.h (with the same _BASETSD_H_ guard) that
// lacks POINTER_64. Win10 SDK winnt.h(417) uses POINTER_64 to define PVOID64.
// If the DX8 version runs first in the include path, POINTER_64 is undefined
// and winnt.h fails with C2146. Define it here before windows.h is included.
#ifndef POINTER_64
#  define POINTER_64 __ptr64
#endif

#include <windows.h>

/*----------------------------------------------------------------------------
	DirectInput 8 — used by UWindowsViewport for keyboard, mouse, joystick.
----------------------------------------------------------------------------*/

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>

/*----------------------------------------------------------------------------
	Core / Engine.
----------------------------------------------------------------------------*/

#pragma pack(push, 4)
#include "Engine.h"

/*----------------------------------------------------------------------------
	WinDrv class declarations.
----------------------------------------------------------------------------*/

#include "WinDrvClasses.h"

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS override — same MSVC 2019+ fix used by all modules.
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

#endif // _INC_WINDRV_PRIVATE
