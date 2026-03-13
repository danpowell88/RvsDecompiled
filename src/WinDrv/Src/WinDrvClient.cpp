/*=============================================================================
	WinDrvClient.cpp: UWindowsClient — viewport factory, DirectInput lifecycle.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "WinDrvPrivate.h"

// Defined in WinDrvViewport.cpp — exported free function for DInput error reporting.
extern WINDRV_API void DirectInputError(FString Msg, LONG hResult, INT Fatal);

IMPLEMENT_CLASS(UWindowsClient)

// --- UWindowsClient ---

UWindowsClient::UWindowsClient(const UWindowsClient& Other)
	: UClient(Other)
{
	UseJoystick       = Other.UseJoystick;
	StartupFullscreen = Other.StartupFullscreen;
}

UWindowsClient& UWindowsClient::operator=(const UWindowsClient& Other)
{
	if (this != &Other)
	{
		UClient::operator=(Other);
		UseJoystick      = Other.UseJoystick;
		StartupFullscreen = Other.StartupFullscreen;
	}
	return *this;
}

void UWindowsClient::StaticConstructor()
{
	guard(UWindowsClient::StaticConstructor);
	// NOTE: Retail binary registers UseJoystick and StartupFullscreen as
	// BITFIELD config properties here. Registration is omitted because
	// UBoolProperty construction references non-exported UProperty vtable
	// entries (2-param CopyCompleteValue/SerializeBin overloads removed
	// before retail Core.dll was finalised).
	unguard;
}

void UWindowsClient::Destroy()
{
	guard(UWindowsClient::Destroy);
	// Release DirectInput devices before superclass cleanup.
	if (UWindowsViewport::Joystick)   { UWindowsViewport::Joystick->Release();   UWindowsViewport::Joystick   = NULL; }
	if (UWindowsViewport::Mouse)      { UWindowsViewport::Mouse->Release();      UWindowsViewport::Mouse      = NULL; }
	if (UWindowsViewport::Keyboard)   { UWindowsViewport::Keyboard->Release();   UWindowsViewport::Keyboard   = NULL; }
	if (UWindowsViewport::DirectInput8){ UWindowsViewport::DirectInput8->Release(); UWindowsViewport::DirectInput8 = NULL; }
	Super::Destroy();
	unguard;
}

void UWindowsClient::ShutdownAfterError()
{
	guard(UWindowsClient::ShutdownAfterError);
	Super::ShutdownAfterError();
	unguard;
}

void UWindowsClient::PostEditChange()
{
	guard(UWindowsClient::PostEditChange);
	Super::PostEditChange();
	unguard;
}

void UWindowsClient::NotifyDestroy(void* Src)
{
	guard(UWindowsClient::NotifyDestroy);
	unguard;
}

void UWindowsClient::Init(UEngine* InEngine)
{
	guard(UWindowsClient::Init);
	Super::Init( InEngine );

	// Initialize DirectInput8 for the process.
	HRESULT hr = DirectInput8Create(
		GetModuleHandle(NULL),
		DIRECTINPUT_VERSION,
		IID_IDirectInput8W,
		(void**)&UWindowsViewport::DirectInput8,
		NULL
	);
	if (FAILED(hr))
		DirectInputError(TEXT("DirectInput8Create"), hr, 0);
	unguard;
}

void UWindowsClient::ShowViewportWindows(DWORD ShowFlags, INT DoShow)
{
	guard(UWindowsClient::ShowViewportWindows);
	for( INT i=0; i<Viewports.Num(); i++ )
	{
		HWND hWnd = (HWND)Viewports(i)->GetWindow();
		if( hWnd )
			ShowWindow( hWnd, DoShow ? SW_SHOW : SW_HIDE );
	}
	unguard;
}

void UWindowsClient::EnableViewportWindows(DWORD ShowFlags, INT DoEnable)
{
	guard(UWindowsClient::EnableViewportWindows);
	for( INT i=0; i<Viewports.Num(); i++ )
	{
		HWND hWnd = (HWND)Viewports(i)->GetWindow();
		if( hWnd )
			EnableWindow( hWnd, DoEnable );
	}
	unguard;
}

void UWindowsClient::Tick()
{
	guard(UWindowsClient::Tick);
	// Pump the Win32 message queue.
	MSG Msg;
	while( PeekMessage(&Msg, NULL, 0, 0, PM_REMOVE) )
	{
		TranslateMessage( &Msg );
		DispatchMessage( &Msg );
	}
	unguard;
}

INT UWindowsClient::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UWindowsClient::Exec);
	return Super::Exec(Cmd, Ar) != 0;
	unguard;
}

UViewport* UWindowsClient::NewViewport(FName Name)
{
	guard(UWindowsClient::NewViewport);
	// Use the INT Reserved overload of StaticConstructObject (exported by Core.dll).
	return (UViewport*)UObject::StaticConstructObject(
		UWindowsViewport::StaticClass(), this, Name, 0, NULL, GError, (INT)0
	);
	unguard;
}

void UWindowsClient::MakeCurrent(UViewport* InViewport)
{
	guard(UWindowsClient::MakeCurrent);
	// Set this viewport as the engine's current rendering target.
	if( InViewport )
	{
		HWND hWnd = (HWND)InViewport->GetWindow();
		if( hWnd )
		{
			SetFocus( hWnd );
			SetForegroundWindow( hWnd );
		}
	}
	unguard;
}

UViewport* UWindowsClient::GetLastCurrent()
{
	guard(UWindowsClient::GetLastCurrent);
	if( Viewports.Num() > 0 )
		return Viewports(0);
	return NULL;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
