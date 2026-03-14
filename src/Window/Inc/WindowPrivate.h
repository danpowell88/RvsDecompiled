/*=============================================================================
	WindowPrivate.h: Unreal Window subsystem private header file.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#ifndef _INC_WINDOW_PRIVATE
#define _INC_WINDOW_PRIVATE

/*----------------------------------------------------------------------------
	API linkage.
----------------------------------------------------------------------------*/

// We are building (exporting) Window.dll.
#undef  WINDOW_API
#define WINDOW_API DLL_EXPORT

#ifndef CORE_API
#define CORE_API DLL_IMPORT
#endif
#ifndef ENGINE_API
#define ENGINE_API DLL_IMPORT
#endif

/*----------------------------------------------------------------------------
	Win32 system headers — must come before Engine.h / Core.h.
	WINDOWS_IGNORE_PACKING_MISMATCH suppresses the winnt.h static_assert
	about non-default struct packing.
----------------------------------------------------------------------------*/

#define WINDOWS_IGNORE_PACKING_MISMATCH
#include <windows.h>
#include <commctrl.h>
#include <shlobj.h>

/*----------------------------------------------------------------------------
	Engine / Core headers (provides FName, TArray, UObject, etc.)
----------------------------------------------------------------------------*/

#include "Engine.h"

/*----------------------------------------------------------------------------
	R6 compatibility shims — must come AFTER Core/Engine includes,
	BEFORE Window.h so UT99 code compiles against R6 Core.lib.
----------------------------------------------------------------------------*/

// appMsgf: R6 changed signature from void(TCHAR*,...) → int(int,TCHAR*,...).
// UT99 Window.h calls appMsgf(TEXT("..."), ...) without the int Type param.
// Declare the R6 overload, then use a macro to insert Type=0 for call sites.
CORE_API const int appMsgf(int Type, const TCHAR* Fmt, ...);
#if _MSC_VER > 1310
// Variadic macros (__VA_ARGS__) require MSVC 8.0+; only define on modern compiler.
#define appMsgf(...) appMsgf(0, __VA_ARGS__)
#endif

// FPreferencesInfo: MSVC 2019 generates move ctor/assignment that MSVC 7.1
// didn't have. Core.lib only exports copy versions. Redirect move → copy
// via linker so the implicit move ctor/assignment resolve correctly.
#pragma comment(linker, "/ALTERNATENAME:__imp_??0FPreferencesInfo@@QAE@$$QAV0@@Z=__imp_??0FPreferencesInfo@@QAE@ABV0@@Z")
#pragma comment(linker, "/ALTERNATENAME:__imp_??4FPreferencesInfo@@QAEAAV0@$$QAV0@@Z=__imp_??4FPreferencesInfo@@QAEAAV0@ABV0@@Z")

/*----------------------------------------------------------------------------
	UT99 Window.h — the full window class framework.
	Include paths configured in CMake so its relative includes resolve:
	  ..\Src\Res\WindowRes.h  →  sdk/Ut99PubSrc/Window/Src/Res/WindowRes.h
	  ..\..\core\inc\unmsg.h  →  sdk/Ut99PubSrc/Core/Inc/UnMsg.h
	  <richedit.h>            →  system header
----------------------------------------------------------------------------*/

// Suppress C4716 (must return a value) — UT99 Window.h FDelegate::operator=
// has a missing return statement that compiled fine under MSVC 7.1.
#pragma warning(push)
#pragma warning(disable: 4716)

#include "Window.h"

#pragma warning(pop)

/*----------------------------------------------------------------------------
	Ravenshield additions not present in UT99 Window.h.
----------------------------------------------------------------------------*/

// Additional HBRUSH globals used by Ravenshield's UI (not in UT99).
extern WINDOW_API HBRUSH hBrushCyanHighlight;
extern WINDOW_API HBRUSH hBrushCyanLow;
extern WINDOW_API HBRUSH hBrushDarkGrey;
extern WINDOW_API HBRUSH hBrushGrey160;
extern WINDOW_API HBRUSH hBrushGrey180;
extern WINDOW_API HBRUSH hBrushGrey197;
extern WINDOW_API HBRUSH hBrushGreyWindow;

/*----------------------------------------------------------------------------
	Ravenshield-specific W* subclasses not present in UT99 Window.h.
	These use DECLARE_WINDOWSUBCLASS which gives them a SuperProc static.
----------------------------------------------------------------------------*/

class WINDOW_API WScrollBar : public WControl
{
	DECLARE_WINDOWSUBCLASS(WScrollBar,WControl,Window)
	WScrollBar() {}
	WScrollBar( WWindow* InOwner ) : WControl( InOwner, 0, NULL ) {}
};

class WINDOW_API WListView : public WControl
{
	DECLARE_WINDOWSUBCLASS(WListView,WControl,Window)
	WListView() {}
	WListView( WWindow* InOwner ) : WControl( InOwner, 0, NULL ) {}
};

class WINDOW_API WHeaderCtrl : public WControl
{
	DECLARE_WINDOWSUBCLASS(WHeaderCtrl,WControl,Window)
	WHeaderCtrl() {}
	WHeaderCtrl( WWindow* InOwner ) : WControl( InOwner, 0, NULL ) {}
};

/*----------------------------------------------------------------------------
	UWindowManager — Ravenshield-specific UObject for managing W* windows.
	Not present in UT99 at all; only its autoclass pointer is exported.
----------------------------------------------------------------------------*/

class WINDOW_API UWindowManager : public UObject
{
	DECLARE_CLASS(UWindowManager, UObject, CLASS_Transient, Window)
	NO_DEFAULT_CONSTRUCTOR(UWindowManager)

	// UObject interface overrides found in Ghidra analysis.
	void Serialize(FArchive& Ar);
	void Destroy();
	void Tick(FLOAT DeltaTime);
};

/*----------------------------------------------------------------------------
	IMPLEMENT_CLASS fix for MSVC 2019+ — same pattern as Engine / Fire.
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

#include "ImplSource.h"

#endif
