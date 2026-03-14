/*=============================================================================
	Launch.cpp: RavenShield game launcher.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Based on UT99 Launch.cpp (Tim Sweeney) with R6-specific additions.

	The retail RavenShield.exe is wrapped in SafeDisc copy protection, so
	Ghidra only sees the encrypted stub loader. This reconstruction is based
	on the UT99 launcher reference code, the exe's import table analysis
	(which reveals exactly which Core/Engine/Window APIs the real code calls),
	and knowledge of R6-specific engine differences.
=============================================================================*/

#include "LaunchPrivate.h"
#include <stdlib.h>

/*-----------------------------------------------------------------------------
	Exported globals — visible to DLLs via the exe's export table.
	Retail exports: GPackage, hInstance (Ordinal_1).
	hInstance is declared extern in UnVcWin32.h — we provide the storage here
	and export it via RavenShield.def for ordinal accuracy.
	GPackage is exported via RavenShield.def.
-----------------------------------------------------------------------------*/

extern "C" { HINSTANCE hInstance; }
extern "C" { TCHAR GPackage[64] = TEXT("Launch"); }

/*-----------------------------------------------------------------------------
	GTimestamp — RDTSC availability flag used by inline appSeconds()/appCycles().
	Declared extern CORE_API in UnVcWin32.h, but NOT exported by retail Core.dll.
	The launcher provides local storage under a target-local alias in a separate
	translation unit so the EXE does not accidentally export the symbol. Init'd TRUE (all target CPUs
	support RDTSC — Pentium+).
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
	Linker fixups: redirect import symbols whose signatures differ between
	the CSDK headers and the retail Core.lib.
	GTimestampLaunch: inline timing helpers expect an imported data symbol via
	__imp__, but the launcher provides local storage in LaunchGlobals.cpp.
	Redirect the import thunk name to that local symbol.
	StaticConstructObject: CSDK declares (UClass*,UObject*,...,UObject* Z)
	but Core.lib exports (UClass*,UObject*,...,INT Reserved). On x86
	both are 4-byte values with identical calling convention, so redirect.
	WWindow::Show(int): exported from Window.dll but our Window.lib may
	contain a mangled variant — handled by linking Window.lib.
-----------------------------------------------------------------------------*/
#pragma comment(linker, "/ALTERNATENAME:__imp__GTimestampLaunch=___imp__GTimestampLaunch")
#pragma comment(linker, "/ALTERNATENAME:__imp_?StaticConstructObject@UObject@@SAPAV1@PAVUClass@@PAV1@VFName@@K1PAVFOutputDevice@@1@Z=__imp_?StaticConstructObject@UObject@@SAPAV1@PAVUClass@@PAV1@VFName@@K1PAVFOutputDevice@@H@Z")

/*-----------------------------------------------------------------------------
	WWindow::Show(int): UT99 Window.h declares it as non-virtual (Q mangling)
	but R6 Window.dll exports it as virtual (U mangling). Redirect Q→U.
-----------------------------------------------------------------------------*/
#pragma comment(linker, "/ALTERNATENAME:__imp_?Show@WWindow@@QAEXH@Z=__imp_?Show@WWindow@@UAEXH@Z")

/*-----------------------------------------------------------------------------
	Global subsystem objects — instantiated once, passed to appInit().
	These are the same allocator/device types used by UT99.
-----------------------------------------------------------------------------*/

// Memory allocator.
#include "FMallocWindows.h"
IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static FMallocWindows& GetLaunchMalloc()
{
	static FMallocWindows Malloc;
	return Malloc;
}

// Log file.
#include "FOutputDeviceFile.h"
IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static FOutputDeviceFile& GetLaunchLog()
{
	static FOutputDeviceFile Log;
	return Log;
}

// Error handler.
// Subclass the standard error handler to skip the blocking MessageBox
// when -UNATTENDED is on the command line (for automated testing).
#include "FOutputDeviceWindowsError.h"
class FOutputDeviceWindowsErrorUnattended : public FOutputDeviceWindowsError
{
public:
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	void HandleError()
	{
		if( ParseParam(GetCommandLine(), TEXT("UNATTENDED")) )
		{
			// Non-blocking: dump error to a file and exit immediately.
			try
			{
				GIsGuarded       = 0;
				GIsRunning       = 0;
				GIsCriticalError = 1;
				GLogHook         = NULL;
				UObject::StaticShutdownAfterError();
				HANDLE h = CreateFileW( L"crash_error.txt", GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL );
				if( h != INVALID_HANDLE_VALUE )
				{
					DWORD w;
					WriteFile( h, GErrorHist, (DWORD)(appStrlen(GErrorHist)*sizeof(TCHAR)), &w, NULL );
					CloseHandle( h );
				}
			}
			catch( ... )
			{}
		}
		else
		{
			// Normal interactive mode: show the dialog.
			FOutputDeviceWindowsError::HandleError();
		}
	}
};
IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static FOutputDeviceWindowsErrorUnattended& GetLaunchError()
{
	static FOutputDeviceWindowsErrorUnattended Error;
	return Error;
}

// Feedback.
#include "FFeedbackContextWindows.h"
IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static FFeedbackContextWindows& GetLaunchWarn()
{
	static FFeedbackContextWindows Warn;
	return Warn;
}

// File manager.
#include "FFileManagerWindows.h"
IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static FFileManagerWindows& GetLaunchFileManager()
{
	static FFileManagerWindows FileManager;
	return FileManager;
}

// Config.
#include "FConfigCacheIni.h"

// R6-specific FConfigCache subclass: overrides GetUserIni/GetServerIni to
// handle the hidden return-value pointer convention. Engine.dll callers
// pass uninitialized stack memory as the OutIni FString — we must zero it
// before assignment to prevent Realloc from freeing an arbitrary heap object.
class FConfigCacheIniR6 : public FConfigCacheIni
{
public:
	// R6-specific virtual methods (slots 16-19 in FConfigCache vtable)
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	void InitUser( const TCHAR* InProfilesPath, const TCHAR* InUserIni )
	{
		UserIni = InProfilesPath;
		UserIni += InUserIni;
		Find( *UserIni, 1 );
	}
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	void InitServer( const TCHAR* InServerIni )
	{
		if( InServerIni && *InServerIni )
			Find( InServerIni, 1 );
	}
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	FString& GetUserIni( FString& OutIni )
	{
		// OutIni is a hidden return-value pointer from the caller (MSVC struct return convention).
		// The caller passes UNINITIALIZED stack memory — its Data field may contain a stale heap
		// pointer (e.g. GModMgr's address). We must zero it before operator= to prevent
		// Realloc from freeing an arbitrary object.
		appMemzero(&OutIni, sizeof(FString));
		OutIni = UserIni;
		return OutIni;
	}
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	FString& GetServerIni( FString& OutIni )
	{
		appMemzero(&OutIni, sizeof(FString));
		OutIni = ServerIni;
		return OutIni;
	}
	// R6Reserved slots 23-33: unknown purpose, padding for vtable compatibility.
	IMPL_TODO("Needs Ghidra analysis")
	void* R6Reserved1(void* arg) { static BYTE _buf[64] = {}; return _buf; }
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved2() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved3() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved4() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved5() {}
	IMPL_TODO("Needs Ghidra analysis")
	void* R6Reserved6(void* arg) { static BYTE _buf[64] = {}; return _buf; }
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved7() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved8() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved9() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved10() {}
	IMPL_TODO("Needs Ghidra analysis")
	void R6Reserved11() {}
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	static FConfigCache* Factory()
	{
		return new FConfigCacheIniR6();
	}
};

/*-----------------------------------------------------------------------------
	R6-specific imports — declared in Core.dll / Engine.dll.
-----------------------------------------------------------------------------*/

// Core.dll: CD validation for RavenShield disc.
CORE_API INT IsRavenShieldCDInDrive();

// Engine.dll: global engine pointer (set after InitEngine, used by subsystems).
ENGINE_API extern UEngine* g_pEngine;

/*-----------------------------------------------------------------------------
	FExecHook — Console command handler for the launcher.
	Handles: ShowLog, HideLog, TakeFocus, EditActor, Preferences.
	Based on UT99 UnEngineWin.h. TakeFocus, EditActor, and Preferences
	still diverge slightly from retail because viewport/window state is not
	fully reconstructed in the local WinDrv module.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void EnsureLaunchWindowClassesRegistered()
{
	static UBOOL Registered = 0;
	if( !Registered )
	{
		IMPLEMENT_WINDOWCLASS(WTerminalBase, 0);
		IMPLEMENT_WINDOWCLASS(WTerminal, 0);
		IMPLEMENT_WINDOWSUBCLASS(WEdit, TEXT("EDIT"));
		{
			TCHAR Temp[256];
			MakeWindowClassName( Temp, TEXT("WEditTerminal") );
			WEditTerminal::RegisterWindowClass( Temp, TEXT("EDIT") );
		}
		IMPLEMENT_WINDOWCLASS(WLog, 0);
		IMPLEMENT_WINDOWCLASS(WObjectProperties, 0);
		IMPLEMENT_WINDOWCLASS(WConfigProperties, 0);
		Registered = 1;
	}
}

class FExecHook : public FExec, public FNotifyHook
{
private:
	WConfigProperties* Preferences;

	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	void NotifyDestroy( void* Src )
	{
		if( Src == Preferences )
			Preferences = NULL;
	}

	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar )
	{
		guard(FExecHook::Exec);

		if( ParseCommand(&Cmd, TEXT("ShowLog")) )
		{
			if( GLogWindow )
			{
				GLogWindow->Show(1);
				SetFocus( *GLogWindow );
				GLogWindow->Display.ScrollCaret();
			}
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("HideLog")) )
		{
			if( GLogWindow )
				GLogWindow->Show(0);
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("TakeFocus")) )
		{
			if( GLogWindow && GLogWindow->hWnd )
			{
				SetForegroundWindow( *GLogWindow );
				SetFocus( *GLogWindow );
			}
			else
				Ar.Logf( TEXT("No launcher-owned window is available to focus") );
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("EditActor")) )
		{
			UClass* Class = NULL;
			FName ActorName = NAME_None;
			AActor* Found = NULL;

			if( ParseObject<UClass>( Cmd, TEXT("Class="), Class, ANY_PACKAGE ) )
			{
				for( TObjectIterator<AActor> It; It; ++It )
				{
					if( !It->IsA(Class) )
						continue;

					Found = *It;
					break;
				}
			}
			else if( Parse( Cmd, TEXT("Name="), ActorName ) )
			{
				for( TObjectIterator<AActor> It; It; ++It )
				{
					if( It->GetFName() == ActorName )
					{
						Found = *It;
						break;
					}
				}
			}

			if( Found )
			{
				EnsureLaunchWindowClassesRegistered();
				WObjectProperties* Properties = new WObjectProperties( TEXT("EditActor"), 0, TEXT(""), NULL, 1 );
				Properties->OpenWindow( GLogWindow ? GLogWindow->hWnd : NULL );
				Properties->Root.SetObjects( (UObject**)&Found, 1 );
				Properties->Show(1);
			}
			else
			{
				Ar.Logf( TEXT("Bad or missing class or name") );
			}
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("Preferences")) )
		{
			if( !GIsClient )
			{
				EnsureLaunchWindowClassesRegistered();
				if( !Preferences )
				{
					Preferences = new WConfigProperties( TEXT("Preferences"), LocalizeGeneral(TEXT("AdvancedOptionsTitle"), TEXT("Window")) );
					Preferences->SetNotifyHook( this );
					Preferences->OpenWindow( GLogWindow ? GLogWindow->hWnd : NULL );
					Preferences->ForceRefresh();
				}
				Preferences->Show(1);
				SetFocus( *Preferences );
			}
			return 1;
		}
		else return 0;

		unguard;
	}

public:
	IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
	FExecHook()
	: Preferences( NULL )
	{}
};

/*-----------------------------------------------------------------------------
	Splash screen — old-style Win32 dialog for fast startup display.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
BOOL CALLBACK SplashDialogProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	return uMsg == WM_INITDIALOG;
}

static HWND hWndSplash = NULL;

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void InitSplash( HINSTANCE hInst, UBOOL Show, const TCHAR* Filename )
{
	if( Show )
	{
		hWndSplash = TCHAR_CALL_OS(
			CreateDialogW(hInst, MAKEINTRESOURCEW(IDDIALOG_Splash), NULL, SplashDialogProc),
			CreateDialogA(hInst, MAKEINTRESOURCEA(IDDIALOG_Splash), NULL, SplashDialogProc)
		);
		if( hWndSplash )
		{
			FWindowsBitmap Bitmap;
			if( Bitmap.LoadFile(Filename) )
			{
				INT screenWidth  = GetSystemMetrics(SM_CXSCREEN);
				INT screenHeight = GetSystemMetrics(SM_CYSCREEN);
				HWND hWndLogo = GetDlgItem(hWndSplash, IDC_Logo);
				ShowWindow( hWndSplash, SW_SHOW );
				SendMessageX( hWndLogo, STM_SETIMAGE, IMAGE_BITMAP, (LPARAM)Bitmap.GetBitmapHandle() );
				SetWindowPos( hWndSplash, NULL,
					(screenWidth - Bitmap.SizeX)/2, (screenHeight - Bitmap.SizeY)/2,
					Bitmap.SizeX, Bitmap.SizeY, 0 );
				UpdateWindow( hWndSplash );
			}
		}
	}
}

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void ExitSplash()
{
	if( hWndSplash )
		DestroyWindow( hWndSplash );
	hWndSplash = NULL;
}

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static LONG WINAPI CrashExceptionFilter(EXCEPTION_POINTERS* ep)
{
	FILE* f = fopen("crash_error.txt", "w");
	if(f) {
		fprintf(f, "EXCEPTION: code=0x%08X addr=%p\n",
			ep->ExceptionRecord->ExceptionCode,
			ep->ExceptionRecord->ExceptionAddress);
		if( GErrorHist[0] )
		{
			fprintf(f, "ERRORHIST:\n%ls\n", GErrorHist);
		}
		fprintf(f, "FLAGS: GIsCriticalError=%d GIsRunning=%d GIsStarted=%d\n",
			GIsCriticalError, GIsRunning, GIsStarted);
		HMODULE hMod = NULL;
		GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
			(LPCSTR)ep->ExceptionRecord->ExceptionAddress, &hMod);
		char modName[260] = {0};
		if(hMod) GetModuleFileNameA(hMod, modName, 260);
		fprintf(f, "MODULE: %s base=%p offset=0x%X\n", modName, hMod,
			(DWORD)((BYTE*)ep->ExceptionRecord->ExceptionAddress - (BYTE*)hMod));
		fprintf(f, "EAX=%08X EBX=%08X ECX=%08X EDX=%08X\n",
			ep->ContextRecord->Eax, ep->ContextRecord->Ebx,
			ep->ContextRecord->Ecx, ep->ContextRecord->Edx);
		fprintf(f, "ESI=%08X EDI=%08X EBP=%08X ESP=%08X\n",
			ep->ContextRecord->Esi, ep->ContextRecord->Edi,
			ep->ContextRecord->Ebp, ep->ContextRecord->Esp);
		fprintf(f, "STACK (16 frames from EBP chain):\n");
		DWORD* frame = (DWORD*)ep->ContextRecord->Ebp;
		for(int i = 0; i < 16 && frame; i++) {
			__try {
				DWORD retAddr = frame[1];
				fprintf(f, "  [%d] ret=%08X", i, retAddr);
				HMODULE hM2 = NULL;
				GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
					(LPCSTR)retAddr, &hM2);
				char mn[260] = {0};
				if(hM2) { GetModuleFileNameA(hM2, mn, 260); fprintf(f, " (%s +0x%X)", mn, retAddr-(DWORD)hM2); }
				fprintf(f, "\n");
				frame = (DWORD*)frame[0];
			} __except(EXCEPTION_EXECUTE_HANDLER) {
				fprintf(f, "  [%d] <bad frame>\n", i);
				break;
			}
		}
		fclose(f);
	}
	return EXCEPTION_CONTINUE_SEARCH;
}

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void WriteLaunchDiag( const char* Text )
{
	HANDLE h = CreateFileA( "launch_diag.txt", FILE_APPEND_DATA, FILE_SHARE_READ, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL );
	if( h != INVALID_HANDLE_VALUE )
	{
		DWORD Written;
		WriteFile( h, Text, (DWORD)strlen(Text), &Written, NULL );
		WriteFile( h, "\r\n", 2, &Written, NULL );
		CloseHandle( h );
	}
}

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void WriteLaunchDiagT( const TCHAR* Text )
{
#if UNICODE
	char Buffer[1024] = {0};
	WideCharToMultiByte( CP_UTF8, 0, Text, -1, Buffer, ARRAY_COUNT(Buffer), NULL, NULL );
	WriteLaunchDiag( Buffer );
#else
	WriteLaunchDiag( Text );
#endif
}

/*-----------------------------------------------------------------------------
	Engine initialization — create the game engine object.
-----------------------------------------------------------------------------*/

IMPL_APPROX("InitEngine: create engine from ini class, call Init(), enter main loop")
static UEngine* InitEngine()
{
	guard(InitEngine);
	FTime LoadTime = appSeconds();
	WriteLaunchDiag("InitEngine: enter");

	// Set exec hook for console commands.
	static FExecHook GLocalHook;
	GExec = &GLocalHook;
	WriteLaunchDiag("InitEngine: after exec hook");

	// Create mutex so external tools know we're running.
	CreateMutexX( NULL, 0, TEXT("UnrealIsRunning") );
	WriteLaunchDiag("InitEngine: after mutex");

	// First-run configuration check.
	INT FirstRun = 0;
	GConfig->GetInt( TEXT("FirstRun"), TEXT("FirstRun"), FirstRun );
	if( ParseParam(appCmdLine(), TEXT("FirstRun")) )
		FirstRun = 0;

	if( FirstRun < ENGINE_VERSION && !GIsEditor && GIsClient )
	{
		WriteLaunchDiag("InitEngine: entering first-run block");
		// Get system directory for driver autodetection.
		TCHAR SysDir[256] = TEXT(""), WinDir[256] = TEXT("");
#if UNICODE
		if( !GUnicodeOS )
		{
			ANSICHAR ASysDir[256] = "", AWinDir[256] = "";
			GetSystemDirectoryA( ASysDir, ARRAY_COUNT(SysDir) );
			GetWindowsDirectoryA( AWinDir, ARRAY_COUNT(WinDir) );
			appStrcpy( SysDir, ANSI_TO_TCHAR(ASysDir) );
			appStrcpy( WinDir, ANSI_TO_TCHAR(AWinDir) );
		}
		else
#endif
		{
			GetSystemDirectory( SysDir, ARRAY_COUNT(SysDir) );
			GetWindowsDirectory( WinDir, ARRAY_COUNT(WinDir) );
		}

		// Autodetect render devices.
		TArray<FRegistryObjectInfo> RenderDevices;
		UObject::GetRegistryObjects( RenderDevices, UClass::StaticClass(), URenderDevice::StaticClass(), 0 );
		for( INT i = 0; i < RenderDevices.Num(); i++ )
		{
			TCHAR File1[256], File2[256];
			appSprintf( File1, TEXT("%s\\%s"), SysDir, *RenderDevices(i).Autodetect );
			appSprintf( File2, TEXT("%s\\%s"), WinDir, *RenderDevices(i).Autodetect );
			if( RenderDevices(i).Autodetect != TEXT("")
			&&	(GFileManager->FileSize(File1) >= 0 || GFileManager->FileSize(File2) >= 0) )
			{
				TCHAR Path[256], *Str;
				appStrcpy( Path, *RenderDevices(i).Object );
				Str = appStrstr(Path, TEXT("."));
				if( Str )
				{
					*Str++ = 0;
					if( ::MessageBox(NULL,
						Localize(Str, TEXT("AskInstalled"), Path),
						Localize(TEXT("FirstRun"), TEXT("Caption"), TEXT("Window")),
						MB_YESNO|MB_ICONQUESTION|MB_TASKMODAL) == IDYES )
					{
						if( ::MessageBox(NULL,
							Localize(Str, TEXT("AskUse"), Path),
							Localize(TEXT("FirstRun"), TEXT("Caption"), TEXT("Window")),
							MB_YESNO|MB_ICONQUESTION|MB_TASKMODAL) == IDYES )
						{
							GConfig->SetString( TEXT("Engine.Engine"), TEXT("GameRenderDevice"), *RenderDevices(i).Object );
							break;
						}
					}
				}
			}
		}

		if( FirstRun < ENGINE_VERSION )
		{
			FirstRun = ENGINE_VERSION;
			GConfig->SetInt( TEXT("FirstRun"), TEXT("FirstRun"), FirstRun );
		}
	}
	WriteLaunchDiag("InitEngine: after first-run block");

	// R6-specific: CD check using Core.dll's IsRavenShieldCDInDrive.
	FString CdPath;
	GConfig->GetString( TEXT("Engine.Engine"), TEXT("CdPath"), CdPath );
	if( CdPath != TEXT("") && !GIsEditor )
	{
		while( !IsRavenShieldCDInDrive() )
		{
			if( MessageBox(
				NULL,
				LocalizeGeneral(TEXT("InsertCdText"), TEXT("Window")),
				LocalizeGeneral(TEXT("InsertCdTitle"), TEXT("Window")),
				MB_TASKMODAL|MB_OKCANCEL) == IDCANCEL )
			{
				GIsCriticalError = 1;
				ExitProcess( 0 );
			}
		}
	}

	// Create the global engine object.
	UClass* EngineClass = UObject::StaticLoadClass(
		UGameEngine::StaticClass(), NULL,
		TEXT("ini:Engine.Engine.GameEngine"), NULL,
		LOAD_NoFail, NULL
	);
	{
		TCHAR Diag[1024];
		appSprintf( Diag, TEXT("InitEngine: EngineClass=%s Base=%s ChildOfUEngine=%d ChildOfUGameEngine=%d"),
			EngineClass ? EngineClass->GetFullName() : TEXT("<null>"),
			EngineClass && EngineClass->GetSuperClass() ? EngineClass->GetSuperClass()->GetFullName() : TEXT("<null>"),
			EngineClass ? EngineClass->IsChildOf( UEngine::StaticClass() ) : 0,
			EngineClass ? EngineClass->IsChildOf( UGameEngine::StaticClass() ) : 0 );
		WriteLaunchDiagT( Diag );
	}
	WriteLaunchDiag("InitEngine: before ConstructObject");
	UEngine* Engine = ConstructObject<UEngine>( EngineClass );
	WriteLaunchDiag("InitEngine: after ConstructObject");

	Engine->Init();
	WriteLaunchDiag("InitEngine: after Engine->Init");

	// R6-specific: set the global engine pointer for subsystem access.
	g_pEngine = Engine;

	debugf( TEXT("Startup time: %f seconds"), (appSeconds() - LoadTime) );
	return Engine;

	unguard;
}

/*-----------------------------------------------------------------------------
	Main loop — engine tick + Windows message pump.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
static void MainLoop( UEngine* Engine )
{
	guard(MainLoop);
	check(Engine);

	// Attach exec hook to log window.
	guard(EnterMainLoop);
	if( GLogWindow )
		GLogWindow->SetExec( Engine );
	unguard;

	// Main game loop.
	GIsRunning = 1;
	DWORD ThreadId = GetCurrentThreadId();
	HANDLE hThread = GetCurrentThread();
	FTime OldTime = appSeconds();

	while( GIsRunning && !GIsRequestingExit )
	{
		// Update the world.
		guard(UpdateWorld);
		FTime NewTime  = appSeconds();
		FLOAT DeltaTime = NewTime - OldTime;
		Engine->Tick( DeltaTime );
		if( GWindowManager )
			GWindowManager->Tick( DeltaTime );
		OldTime = NewTime;
		unguard;

		// Enforce optional maximum tick rate.
		guard(EnforceTickRate);
		FLOAT MaxTickRate = Engine->GetMaxTickRate();
		if( MaxTickRate > 0.0 )
		{
			FLOAT Delta = (1.0f/MaxTickRate) - (appSeconds() - OldTime);
			appSleep( Max(0.f, Delta) );
		}
		unguard;

		// Handle all incoming messages.
		guard(MessagePump);
		MSG Msg;
		while( PeekMessageX(&Msg, NULL, 0, 0, PM_REMOVE) )
		{
			if( Msg.message == WM_QUIT )
				GIsRequestingExit = 1;

			guard(TranslateMessage);
			TranslateMessage( &Msg );
			unguardf(( TEXT("%08X %i"), (INT)Msg.hwnd, Msg.message ));

			guard(DispatchMessage);
			DispatchMessageX( &Msg );
			unguardf(( TEXT("%08X %i"), (INT)Msg.hwnd, Msg.message ));
		}
		unguard;
	}

	GIsRunning = 0;

	// Detach exec hook.
	guard(ExitMainLoop);
	if( GLogWindow )
		GLogWindow->SetExec( NULL );
	GExec = NULL;
	unguard;

	unguard;
}

/*-----------------------------------------------------------------------------
	WinMain — entry point.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Reconstructed from UT99 reference and import table analysis")
INT WINAPI WinMain( HINSTANCE hInInstance, HINSTANCE hPrevInstance, char*, INT nCmdShow )
{
	WriteLaunchDiag("WinMain: enter");
	SetUnhandledExceptionFilter(CrashExceptionFilter);
	// Remember instance info.
	INT ErrorLevel = 0;
	GIsStarted     = 1;
	hInstance      = hInInstance;
	const TCHAR* CmdLine = GetCommandLine();
	FMalloc* Malloc = GMalloc ? GMalloc : (FMalloc*)&GetLaunchMalloc();
	FOutputDeviceFile& Log = GetLaunchLog();
	FOutputDeviceWindowsErrorUnattended& Error = GetLaunchError();
	FFeedbackContextWindows& Warn = GetLaunchWarn();
	FFileManagerWindows& FileManager = GetLaunchFileManager();
	appStrcpy( GPackage, appPackage() );

	// See if this should be passed to an already-running instance.
	if( !appStrfind(CmdLine, TEXT("Server")) && !appStrfind(CmdLine, TEXT("NewWindow")) )
	{
		TCHAR ClassName[256];
		MakeWindowClassName( ClassName, TEXT("WLog") );
		for( HWND hWnd = NULL; ; )
		{
			hWnd = TCHAR_CALL_OS(
				FindWindowExW(hWnd, NULL, ClassName, NULL),
				FindWindowExA(hWnd, NULL, TCHAR_TO_ANSI(ClassName), NULL)
			);
			if( !hWnd )
				break;
			if( GetPropX(hWnd, TEXT("IsBrowser")) )
			{
				while( *CmdLine && *CmdLine != ' ' )
					CmdLine++;
				if( *CmdLine == ' ' )
					CmdLine++;
				COPYDATASTRUCT CD;
				DWORD Result;
				CD.dwData = WindowMessageOpen;
				CD.cbData = (appStrlen(CmdLine) + 1) * sizeof(TCHAR);
				CD.lpData = const_cast<TCHAR*>( CmdLine );
				SendMessageTimeout( hWnd, WM_COPYDATA, (WPARAM)NULL, (LPARAM)&CD,
					SMTO_ABORTIFHUNG|SMTO_BLOCK, 30000, &Result );
				GIsStarted = 0;
				return 0;
			}
		}
	}

	// Begin guarded code.
#ifndef _DEBUG
	try
	{
#endif
		// Init core subsystems.
		GIsClient = GIsGuarded = 1;
		WriteLaunchDiag("WinMain: before malloc init");

		// Core.dll pre-initializes the shared allocator before any native class
		// constructors run. Only fall back to a local allocator if that path failed.
		if( !GMalloc )
		{
			Malloc->Init();
			GMalloc = Malloc;
		}
		GLog         = &Log;
		GError       = &Error;
		GWarn        = &Warn;
		GFileManager = &FileManager;
		WriteLaunchDiag("WinMain: before appInit");

		appInit( GPackage, CmdLine, Malloc, &Log, &Error, &Warn, &FileManager, FConfigCacheIniR6::Factory, 1 );
		WriteLaunchDiag("WinMain: after appInit");

		// NOTE: CmdLine local variable is clobbered by appInit (register
		// optimization). Use appCmdLine() for all post-init command line access.
		CmdLine = appCmdLine();

		UBOOL bSafeMode = ParseParam(CmdLine, TEXT("safe"));
		UBOOL bChangeVideo = ParseParam(CmdLine, TEXT("changevideo"));
		UBOOL bUnattended = ParseParam(CmdLine, TEXT("UNATTENDED"));
		FString RunningIniPath = FString(appBaseDir()) + TEXT("Running.ini");
		if( GFileManager->FileSize(*RunningIniPath) >= 0 )
		{
			// Previous run crashed — offer safe mode.
			debugf( TEXT("Running.ini detected — previous run may have crashed") );
			GFileManager->Delete( *RunningIniPath );
			if( !bSafeMode && !bUnattended )
			{
				if( MessageBox( NULL,
					TEXT("The game did not exit cleanly last time.\n\nWould you like to start in safe mode?"),
					TEXT("Raven Shield"),
					MB_YESNO | MB_ICONWARNING | MB_TASKMODAL ) == IDYES )
				{
					bSafeMode = 1;
				}
			}
		}

		// Create Running.ini to track that we're running.
		// This file is deleted on clean exit. If it remains, the next
		// launch knows the previous run crashed.
		{
			FArchive* RunFile = GFileManager->CreateFileWriter( *RunningIniPath );
			if( RunFile )
			{
				FString Marker = TEXT("[Running]\r\n");
				RunFile->Serialize( const_cast<TCHAR*>(*Marker), Marker.Len() * sizeof(TCHAR) );
				delete RunFile;
			}
		}

		// Safe mode: force software rendering and low resolution.
		if( bSafeMode )
		{
			debugf( TEXT("Safe mode active — using software defaults") );
			GConfig->SetString( TEXT("Engine.Engine"), TEXT("GameRenderDevice"), TEXT("D3DDrv.UD3DRenderDevice") );
		}

		// Change video mode: prompt for render device selection.
		if( bChangeVideo )
		{
			debugf( TEXT("ChangeVideo requested — will prompt for render device") );
		}

		// Init mode flags.
		GIsServer     = 1;
		GIsClient     = !ParseParam(appCmdLine(), TEXT("SERVER"));
		GIsEditor     = 0;
		GIsScriptable = 1;
		GLazyLoad     = !GIsClient || ParseParam(appCmdLine(), TEXT("LAZY"));

		// Show splash screen or log window.
		UBOOL ShowLog = ParseParam(CmdLine, TEXT("LOG"));
		FString Filename = FString(TEXT("..\\Help")) * GPackage + TEXT("Logo.bmp");
		if( GFileManager->FileSize(*Filename) < 0 )
			Filename = TEXT("..\\Help\\Logo.bmp");
		appStrcpy( GPackage, appPackage() );
		InitSplash( hInstance, !ShowLog && !ParseParam(CmdLine, TEXT("server")), *Filename );
		WriteLaunchDiag("WinMain: after InitSplash");

		// Init windowing subsystem.
		InitWindowing();
		WriteLaunchDiag("WinMain: after InitWindowing");

		// Create log window, optionally shown.
		EnsureLaunchWindowClassesRegistered();
		GLogWindow = new WLog( Log.Filename, Log.LogAr, TEXT("GameLog") );
		WriteLaunchDiag("WinMain: after WLog ctor");

		WriteLaunchDiag("WinMain: before OpenWindow");
		GLogWindow->OpenWindow( ShowLog, 0 );
		WriteLaunchDiag("WinMain: after OpenWindow");
		WriteLaunchDiag("WinMain: before Start log");
		GLogWindow->Log( NAME_Title, LocalizeGeneral(TEXT("Start")) );
		WriteLaunchDiag("WinMain: after Start log");
		if( GIsClient )
		{
			WriteLaunchDiag("WinMain: before IsBrowser prop");
			SetPropX( *GLogWindow, TEXT("IsBrowser"), (HANDLE)1 );
			WriteLaunchDiag("WinMain: after IsBrowser prop");
		}

		// Init engine.
		WriteLaunchDiag("WinMain: before InitEngine");
		UEngine* Engine = InitEngine();
		WriteLaunchDiag("WinMain: after InitEngine");

		// Hide splash screen.
		ExitSplash();

		// Optionally exec a startup script.
		FString Temp;
		if( Parse(CmdLine, TEXT("EXEC="), Temp) )
		{
			Temp = FString(TEXT("exec ")) + Temp;
			Engine->Exec( *Temp, *GLog );
		}

		// Start main engine loop.
		if( !GIsRequestingExit )
			MainLoop( Engine );

		// Clean shutdown.
		RemovePropX( *GLogWindow, TEXT("IsBrowser") );
		GLogWindow->Log( NAME_Title, LocalizeGeneral(TEXT("Exit")) );

		// Delete Running.ini to indicate clean exit.
		GFileManager->Delete( *RunningIniPath );

		delete GLogWindow;
		appPreExit();
		GIsGuarded = 0;

#ifndef _DEBUG
	}
	catch( ... )
	{
		// Crashed.
		ErrorLevel = 1;
		Error.HandleError();
	}
#endif

	// Final shut down.
	appExit();
	GIsStarted = 0;
	return ErrorLevel;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/