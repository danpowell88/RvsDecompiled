/*=============================================================================
	LaunchPrivate.h: RavenShield game launcher private header.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Based on UT99 Launch module with R6-specific additions.
=============================================================================*/

#ifndef _INC_LAUNCH_PRIVATE
#define _INC_LAUNCH_PRIVATE

/*----------------------------------------------------------------------------
	System headers.
----------------------------------------------------------------------------*/

#pragma warning( disable : 4201 )
#define STRICT
#define WINDOWS_IGNORE_PACKING_MISMATCH
#include <windows.h>
#include <commctrl.h>
#include <shlobj.h>
#include <malloc.h>
#include <io.h>
#include <direct.h>
#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>

/*----------------------------------------------------------------------------
	API linkage — launcher is an EXE, imports from all DLLs.
----------------------------------------------------------------------------*/

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
	MSVC 2019 conformant for-loop scoping breaks MSVC 7.1-era code.
----------------------------------------------------------------------------*/

#pragma conform(forScope, off)

/*----------------------------------------------------------------------------
	Engine & Core includes.
----------------------------------------------------------------------------*/

#include "Engine.h"

/*----------------------------------------------------------------------------
	R6 compatibility shims — must come AFTER Engine.h, BEFORE Window.h.
	Same shims as WindowPrivate.h (appMsgf overload, FPreferencesInfo move).
----------------------------------------------------------------------------*/

CORE_API const int appMsgf(int Type, const TCHAR* Fmt, ...);
#if _MSC_VER > 1310
#define appMsgf(...) appMsgf(0, __VA_ARGS__)
#endif

#pragma comment(linker, "/ALTERNATENAME:__imp_??0FPreferencesInfo@@QAE@$$QAV0@@Z=__imp_??0FPreferencesInfo@@QAE@ABV0@@Z")
#pragma comment(linker, "/ALTERNATENAME:__imp_??4FPreferencesInfo@@QAEAAV0@$$QAV0@@Z=__imp_??4FPreferencesInfo@@QAEAAV0@ABV0@@Z")

/*----------------------------------------------------------------------------
	Window class framework — provides WLog, WWizardDialog, etc.
	Window.h has relative includes (..\Src\Res\WindowRes.h) resolved
	by CMake include path pointing at sdk/Ut99PubSrc/Window/Inc.
----------------------------------------------------------------------------*/

#pragma warning(push)
#pragma warning(disable: 4716)

#include "Window.h"

#pragma warning(pop)

/*----------------------------------------------------------------------------
	Resource IDs for the launcher — splash dialog and icon.
----------------------------------------------------------------------------*/

#include "Res/LaunchRes.h"

#include "ImplSource.h"

#endif // _INC_LAUNCH_PRIVATE
