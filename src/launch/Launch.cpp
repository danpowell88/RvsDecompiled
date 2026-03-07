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

	Virtual method calls on UEngine (Init, Tick, GetMaxTickRate) require
	correct vtable slot ordering. These are stubbed pending Phase 8C when
	the full UEngine class layout is reconstructed with accurate vtable order.
=============================================================================*/

#include "LaunchPrivate.h"

/*-----------------------------------------------------------------------------
	Exported globals — visible to DLLs via the exe's export table.
	Retail exports: GPackage, hInstance (Ordinal_1).
	hInstance is declared extern in UnVcWin32.h — we provide the storage here.
	GPackage is exported via __declspec(dllexport).
-----------------------------------------------------------------------------*/

extern "C" { HINSTANCE hInstance; }
extern "C" { __declspec(dllexport) TCHAR GPackage[64] = TEXT("Launch"); }

/*-----------------------------------------------------------------------------
	GTimestamp — RDTSC availability flag used by inline appSeconds()/appCycles().
	Declared extern CORE_API in UnVcWin32.h, but NOT exported by retail Core.dll.
	The launcher provides the actual storage. Init'd TRUE (all target CPUs
	support RDTSC — Pentium+).
-----------------------------------------------------------------------------*/
extern "C" { UBOOL GTimestamp = 1; }

/*-----------------------------------------------------------------------------
	Linker fixups: redirect import symbols whose signatures differ between
	the CSDK headers and the retail Core.lib.
	StaticConstructObject: CSDK declares (UClass*,UObject*,...,UObject* Z)
	but Core.lib exports (UClass*,UObject*,...,INT Reserved). On x86
	both are 4-byte values with identical calling convention, so redirect.
	WWindow::Show(int): exported from Window.dll but our Window.lib may
	contain a mangled variant — handled by linking Window.lib.
-----------------------------------------------------------------------------*/
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
FMallocWindows Malloc;

// Log file.
#include "FOutputDeviceFile.h"
FOutputDeviceFile Log;

// Error handler.
#include "FOutputDeviceWindowsError.h"
FOutputDeviceWindowsError Error;

// Feedback.
#include "FFeedbackContextWindows.h"
FFeedbackContextWindows Warn;

// File manager.
#include "FFileManagerWindows.h"
FFileManagerWindows FileManager;

// Config.
#include "FConfigCacheIni.h"

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
	Based on UT99 UnEngineWin.h. Commands that access UEngine/AActor
	member data (EditActor, Preferences) require full class layout
	reconstruction — stubbed pending Phase 8C.
-----------------------------------------------------------------------------*/

class FExecHook : public FExec, public FNotifyHook
{
private:
	void NotifyDestroy( void* Src )
	{
	}

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
			// TODO Phase 8C: requires UEngine::Client (member data at known offset)
			// to find active viewport and call SetForegroundWindow on it.
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("EditActor")) )
		{
			// TODO Phase 8C: requires AActor::Location, bDeleteMe, GetLevel()
			// to find nearest actor of a given class and open WObjectProperties.
			Ar.Logf( TEXT("EditActor: pending full class layout reconstruction") );
			return 1;
		}
		else if( ParseCommand(&Cmd, TEXT("Preferences")) )
		{
			// TODO Phase 8C: requires WConfigProperties with correct constructor args.
			return 1;
		}
		else return 0;

		unguard;
	}

public:
	FExecHook()
	{}
};

/*-----------------------------------------------------------------------------
	Splash screen — old-style Win32 dialog for fast startup display.
-----------------------------------------------------------------------------*/

BOOL CALLBACK SplashDialogProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	return uMsg == WM_INITDIALOG;
}

static HWND hWndSplash = NULL;

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

static void ExitSplash()
{
	if( hWndSplash )
		DestroyWindow( hWndSplash );
	hWndSplash = NULL;
}

/*-----------------------------------------------------------------------------
	Engine initialization — create the game engine object.
	Virtual method calls (Init, Tick) require correct vtable slot ordering.
	Pending Phase 8C when the full UEngine class layout is known.
-----------------------------------------------------------------------------*/

static UEngine* InitEngine()
{
	guard(InitEngine);
	FTime LoadTime = appSeconds();

	// Set exec hook for console commands.
	static FExecHook GLocalHook;
	GExec = &GLocalHook;

	// Create mutex so external tools know we're running.
	CreateMutexX( NULL, 0, TEXT("UnrealIsRunning") );

	// First-run configuration check.
	INT FirstRun = 0;
	GConfig->GetInt( TEXT("FirstRun"), TEXT("FirstRun"), FirstRun );
	if( ParseParam(appCmdLine(), TEXT("FirstRun")) )
		FirstRun = 0;

	if( FirstRun < ENGINE_VERSION && !GIsEditor && GIsClient )
	{
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
	UEngine* Engine = ConstructObject<UEngine>( EngineClass );

	// TODO Phase 8C: Engine->Init() requires correct vtable layout.
	// UEngine::Init() is virtual (mangled: ?Init@UEngine@@UAEXXZ).
	// The vtable slot depends on the full inheritance chain's virtual
	// method declaration order. Deferred until full class layout is known.

	// R6-specific: set the global engine pointer for subsystem access.
	g_pEngine = Engine;

	debugf( TEXT("Startup time: %f seconds"), (appSeconds() - LoadTime) );
	return Engine;

	unguard;
}

/*-----------------------------------------------------------------------------
	Main loop — engine tick + Windows message pump.
	Engine->Tick() requires the UGameEngine vtable to be correctly laid out.
	Pending Phase 8C for full virtual method ordering.
-----------------------------------------------------------------------------*/

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
		// TODO Phase 8C: Engine->Tick(DeltaTime) requires correct vtable layout.
		guard(UpdateWorld);
		FTime NewTime  = appSeconds();
		FLOAT DeltaTime = NewTime - OldTime;
		(void)DeltaTime; // Suppress unused warning until Tick is enabled.
		if( GWindowManager )
			GWindowManager->Tick( DeltaTime );
		OldTime = NewTime;
		unguard;

		// Enforce optional maximum tick rate.
		guard(EnforceTickRate);
		// TODO Phase 8C: Engine->GetMaxTickRate() requires correct vtable layout.
		FLOAT MaxTickRate = 60.0f; // Placeholder — retail reads from engine config.
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

INT WINAPI WinMain( HINSTANCE hInInstance, HINSTANCE hPrevInstance, char*, INT nCmdShow )
{
	// Remember instance info.
	INT ErrorLevel = 0;
	GIsStarted     = 1;
	hInstance      = hInInstance;
	const TCHAR* CmdLine = GetCommandLine();
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
				CD.cbData = (appStrlen(CmdLine) + 1) * sizeof(TCHAR*);
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
		appInit( GPackage, CmdLine, &Malloc, &Log, &Error, &Warn, &FileManager, FConfigCacheIni::Factory, 1 );

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

		// Init windowing subsystem.
		InitWindowing();

		// Create log window, optionally shown.
		GLogWindow = new WLog( Log.Filename, Log.LogAr, TEXT("GameLog") );
		GLogWindow->OpenWindow( ShowLog, 0 );
		GLogWindow->Log( NAME_Title, LocalizeGeneral(TEXT("Start")) );
		if( GIsClient )
			SetPropX( *GLogWindow, TEXT("IsBrowser"), (HANDLE)1 );

		// Init engine.
		UEngine* Engine = InitEngine();
		GLogWindow->Log( NAME_Title, LocalizeGeneral(TEXT("Run")) );

		// Hide splash screen.
		ExitSplash();

		// Optionally exec a startup script.
		FString Temp;
		if( Parse(CmdLine, TEXT("EXEC="), Temp) )
		{
			Temp = FString(TEXT("exec ")) + Temp;
			// TODO Phase 8C: Engine->Client->Viewports(0)->Exec() requires
			// UEngine::Client member at known offset.
		}

		// Start main engine loop.
		if( !GIsRequestingExit )
			MainLoop( Engine );

		// Clean shutdown.
		RemovePropX( *GLogWindow, TEXT("IsBrowser") );
		GLogWindow->Log( NAME_Title, LocalizeGeneral(TEXT("Exit")) );
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
