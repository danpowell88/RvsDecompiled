/*=============================================================================
	WinDrv.cpp: WinDrv package — Windows viewport driver and DirectInput.
	Reconstructed for Ravenshield decompilation project.

	Implements:
	  UWindowsViewport  — Win32 window + DirectInput input handling
	  UWindowsClient    — Viewport factory, DirectInput8 lifecycle
	  WWindowsViewportWindow — Non-UObject Win32 WNDCLASS host

	The viewport creates a Win32 window, initialises DirectInput8 devices
	for keyboard and mouse, and dispatches input events to the engine via
	CauseInputEvent → ExecInputCommands. The render device is loaded
	dynamically via TryRenderDevice.

	Divergences from retail byte parity:
	  - Static DirectInput device pointers (Keyboard, Mouse, Joystick,
	    DirectInput8, JoystickCaps) are exported as individual variables
	    rather than inlined into a static struct — this matches the retail
	    export names but the layout may differ by a few bytes.
	  - Joystick enumeration callbacks are minimal stubs (DIENUM_CONTINUE).
	  - Property registration in StaticConstructor is omitted because
	    UBoolProperty construction references non-exported UProperty vtable
	    entries from the retail Core.dll that no longer exist.
=============================================================================*/

#include "WinDrvPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(WinDrv)

/*-----------------------------------------------------------------------------
	Name/function registration.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) WINDRV_API FName WINDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "WinDrvClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UWindowsViewport)
IMPLEMENT_CLASS(UWindowsClient)

/*-----------------------------------------------------------------------------
	Static DirectInput device DATA members.
	Exported by name from retail WinDrv.dll at the following ordinals:
	  @30  ?DirectInput8@UWindowsViewport@@2PAUIDirectInput8W@@A
	  @53  ?Keyboard@UWindowsViewport@@2PAUIDirectInputDevice8W@@A
	  @58  ?Mouse@UWindowsViewport@@2PAUIDirectInputDevice8W@@A
	  @49  ?Joystick@UWindowsViewport@@2PAUIDirectInputDevice8W@@A
	  @50  ?JoystickCaps@UWindowsViewport@@2UDIDEVCAPS@@A
-----------------------------------------------------------------------------*/

IDirectInput8W*       UWindowsViewport::DirectInput8  = NULL;
IDirectInputDevice8W* UWindowsViewport::Keyboard      = NULL;
IDirectInputDevice8W* UWindowsViewport::Mouse         = NULL;
IDirectInputDevice8W* UWindowsViewport::Joystick      = NULL;
DIDEVCAPS             UWindowsViewport::JoystickCaps  = {};

/*-----------------------------------------------------------------------------
	DirectInputError — exported free function for DInput error reporting.
	Exported at ordinal @31: ?DirectInputError@@YAXVFString@@JH@Z
-----------------------------------------------------------------------------*/

WINDRV_API void DirectInputError(FString Msg, LONG hResult, INT Fatal)
{
	debugf(TEXT("DirectInput error: %s (hr=0x%08X)"), *Msg, (DWORD)hResult);
	if (Fatal)
		appUnwindf(TEXT("Fatal DirectInput error: %s (hr=0x%08X)"), *Msg, (DWORD)hResult);
}

/*-----------------------------------------------------------------------------
	UWindowsViewport — implementation.
-----------------------------------------------------------------------------*/

// Internal HWND storage. Not a class member in retail — stored as a static
// mapping from viewport pointer to HWND. For simplicity we use a single
// global since Ravenshield only creates one viewport.
static HWND GViewportHWnd = NULL;

UWindowsViewport::UWindowsViewport(const UWindowsViewport& Other)
	: UViewport(Other)
{
}

UWindowsViewport& UWindowsViewport::operator=(const UWindowsViewport& Other)
{
	if (this != &Other)
		UViewport::operator=(Other);
	return *this;
}

void UWindowsViewport::Destroy()
{
	guard(UWindowsViewport::Destroy);
	CloseWindow();
	Super::Destroy();
	unguard;
}

void UWindowsViewport::ShutdownAfterError()
{
	guard(UWindowsViewport::ShutdownAfterError);
	if( GViewportHWnd )
		DestroyWindow( GViewportHWnd );
	GViewportHWnd = NULL;
	Super::ShutdownAfterError();
	unguard;
}

INT UWindowsViewport::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UWindowsViewport::Exec);
	if( ParseCommand(&Cmd, TEXT("GetCurrentRes")) )
	{
		Ar.Logf( TEXT("%ix%i"), SizeX, SizeY );
		return 1;
	}
	else if( ParseCommand(&Cmd, TEXT("GetCurrentColorDepth")) )
	{
		Ar.Logf( TEXT("%i"), ColorBytes * 8 );
		return 1;
	}
	return 0;
	unguard;
}

INT UWindowsViewport::Lock(BYTE* HitData, INT* HitSize)
{
	guard(UWindowsViewport::Lock);
	return 1;
	unguard;
}

void UWindowsViewport::Unlock()
{
	guard(UWindowsViewport::Unlock);
	unguard;
}

INT UWindowsViewport::IsFullscreen()
{
	guard(UWindowsViewport::IsFullscreen);
	return (BlitFlags & BLIT_Fullscreen) ? 1 : 0;
	unguard;
}

INT UWindowsViewport::ResizeViewport(DWORD NewBlitFlags, INT NewX, INT NewY)
{
	guard(UWindowsViewport::ResizeViewport);

	// Store new blit flags.
	BlitFlags = NewBlitFlags;

	// Determine size.
	if( NewX != INDEX_NONE )
		SizeX = NewX;
	if( NewY != INDEX_NONE )
		SizeY = NewY;
	ColorBytes = 4;

	// Resize the Win32 window to match.
	if( GViewportHWnd && !(BlitFlags & BLIT_Fullscreen) )
	{
		RECT rc = {0, 0, SizeX, SizeY};
		AdjustWindowRect( &rc, GetWindowLong(GViewportHWnd, GWL_STYLE), FALSE );
		SetWindowPos( GViewportHWnd, NULL, 0, 0, rc.right-rc.left, rc.bottom-rc.top, SWP_NOMOVE|SWP_NOZORDER );
	}

	return 1;
	unguard;
}

void UWindowsViewport::SetModeCursor()
{
	guard(UWindowsViewport::SetModeCursor);
	SetCursor( LoadCursor(NULL, IDC_ARROW) );
	unguard;
}

void UWindowsViewport::UpdateWindowFrame()
{
	guard(UWindowsViewport::UpdateWindowFrame);
	if( GViewportHWnd )
	{
		SetWindowTextW( GViewportHWnd, *GetName() );
	}
	unguard;
}

void UWindowsViewport::OpenWindow(DWORD ParentWindow, INT IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY)
{
	guard(UWindowsViewport::OpenWindow);

	check(googGetOuterUWindowsClient());

	// Set initial size.
	SizeX = NewX ? NewX : 640;
	SizeY = NewY ? NewY : 480;
	ColorBytes = 4;

	// Register window class.
	WNDCLASSW wc;
	appMemzero( &wc, sizeof(wc) );
	wc.style         = CS_OWNDC;
	wc.lpfnWndProc   = DefWindowProcW;
	wc.hInstance      = GetModuleHandle(NULL);
	wc.hCursor        = LoadCursor(NULL, IDC_ARROW);
	wc.lpszClassName  = TEXT("RavenShieldViewport");
	RegisterClassW( &wc );

	// Create the viewport window.
	DWORD Style = WS_OVERLAPPEDWINDOW;
	RECT rc = {0, 0, SizeX, SizeY};
	AdjustWindowRect( &rc, Style, FALSE );

	GViewportHWnd = CreateWindowW(
		TEXT("RavenShieldViewport"),
		*GetName(),
		Style,
		CW_USEDEFAULT, CW_USEDEFAULT,
		rc.right - rc.left, rc.bottom - rc.top,
		(HWND)ParentWindow,
		NULL,
		GetModuleHandle(NULL),
		NULL
	);

	if( GViewportHWnd )
	{
		ShowWindow( GViewportHWnd, SW_SHOW );
		UpdateWindow( GViewportHWnd );
	}

	// Acquire DirectInput keyboard and mouse.
	if( UWindowsViewport::DirectInput8 && !UWindowsViewport::Keyboard )
	{
		HRESULT hr;

		// Keyboard.
		hr = UWindowsViewport::DirectInput8->CreateDevice(
			GUID_SysKeyboard, &UWindowsViewport::Keyboard, NULL
		);
		if( SUCCEEDED(hr) )
		{
			UWindowsViewport::Keyboard->SetDataFormat( &c_dfDIKeyboard );
			UWindowsViewport::Keyboard->SetCooperativeLevel( GViewportHWnd, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE );
			UWindowsViewport::Keyboard->Acquire();
		}
		else
		{
			DirectInputError( TEXT("CreateDevice(Keyboard)"), hr, 0 );
		}

		// Mouse.
		hr = UWindowsViewport::DirectInput8->CreateDevice(
			GUID_SysMouse, &UWindowsViewport::Mouse, NULL
		);
		if( SUCCEEDED(hr) )
		{
			UWindowsViewport::Mouse->SetDataFormat( &c_dfDIMouse );
			UWindowsViewport::Mouse->SetCooperativeLevel( GViewportHWnd, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE );
			UWindowsViewport::Mouse->Acquire();
		}
		else
		{
			DirectInputError( TEXT("CreateDevice(Mouse)"), hr, 0 );
		}
	}

	unguard;
}

void UWindowsViewport::CloseWindow()
{
	guard(UWindowsViewport::CloseWindow);
	if( GViewportHWnd )
	{
		DestroyWindow( GViewportHWnd );
		GViewportHWnd = NULL;
	}
	unguard;
}

void UWindowsViewport::UpdateInput(INT Reset, FLOAT DeltaSeconds)
{
	guard(UWindowsViewport::UpdateInput);

	// Poll keyboard.
	if( UWindowsViewport::Keyboard )
	{
		BYTE KeyStates[256];
		HRESULT hr = UWindowsViewport::Keyboard->GetDeviceState( sizeof(KeyStates), KeyStates );
		if( hr == DIERR_INPUTLOST || hr == DIERR_NOTACQUIRED )
		{
			UWindowsViewport::Keyboard->Acquire();
			hr = UWindowsViewport::Keyboard->GetDeviceState( sizeof(KeyStates), KeyStates );
		}
		if( SUCCEEDED(hr) )
		{
			for( INT i=0; i<256; i++ )
			{
				if( KeyStates[i] & 0x80 )
					CauseInputEvent( i, IST_Hold, 1.0f );
			}
		}
	}

	// Poll mouse.
	if( UWindowsViewport::Mouse )
	{
		DIMOUSESTATE MouseState;
		HRESULT hr = UWindowsViewport::Mouse->GetDeviceState( sizeof(DIMOUSESTATE), &MouseState );
		if( hr == DIERR_INPUTLOST || hr == DIERR_NOTACQUIRED )
		{
			UWindowsViewport::Mouse->Acquire();
			hr = UWindowsViewport::Mouse->GetDeviceState( sizeof(DIMOUSESTATE), &MouseState );
		}
		if( SUCCEEDED(hr) )
		{
			if( MouseState.lX ) CauseInputEvent( IK_MouseX, IST_Axis, (FLOAT)MouseState.lX );
			if( MouseState.lY ) CauseInputEvent( IK_MouseY, IST_Axis, (FLOAT)MouseState.lY );
			if( MouseState.lZ ) CauseInputEvent( IK_MouseW, IST_Axis, (FLOAT)MouseState.lZ );
		}
	}

	unguard;
}

void* UWindowsViewport::GetWindow()
{
	guard(UWindowsViewport::GetWindow);
	return (void*)GViewportHWnd;
	unguard;
}

void UWindowsViewport::SetMouseCapture(INT Capture, INT Clip, INT FocusOnly)
{
	guard(UWindowsViewport::SetMouseCapture);
	if( GViewportHWnd )
	{
		if( Capture )
		{
			SetCapture( GViewportHWnd );
			if( Clip )
			{
				RECT rc;
				GetClientRect( GViewportHWnd, &rc );
				ClientToScreen( GViewportHWnd, (POINT*)&rc.left );
				ClientToScreen( GViewportHWnd, (POINT*)&rc.right );
				ClipCursor( &rc );
			}
		}
		else
		{
			ClipCursor( NULL );
			ReleaseCapture();
		}
	}
	unguard;
}

void UWindowsViewport::Repaint(INT Blit)
{
	guard(UWindowsViewport::Repaint);
	if( GViewportHWnd )
		InvalidateRect( GViewportHWnd, NULL, FALSE );
	unguard;
}

void UWindowsViewport::TryRenderDevice(const TCHAR* ClassName, INT NewX, INT NewY, INT Fullscreen)
{
	guard(UWindowsViewport::TryRenderDevice);

	// Construct the render device object.
	UClass* RenderClass = UObject::StaticLoadClass( URenderDevice::StaticClass(), NULL, ClassName, NULL, 0, NULL );
	if( RenderClass )
	{
		RenDev = ConstructObject<URenderDevice>( RenderClass, this );
		if( RenDev )
		{
			if( RenDev->Init() )
			{
				if( NewX && NewY )
					RenDev->SetRes( NewX, NewY, ColorBytes, Fullscreen );
			}
			else
			{
				debugf( NAME_Warning, TEXT("Failed to init render device %s"), ClassName );
				delete RenDev;
				RenDev = NULL;
			}
		}
	}
	unguard;
}

void UWindowsViewport::Hold(INT Horiz)
{
	guard(UWindowsViewport::Hold);
	unguard;
}

void UWindowsViewport::Minimize()
{
	guard(UWindowsViewport::Minimize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MINIMIZE );
	unguard;
}

void UWindowsViewport::Maximize()
{
	guard(UWindowsViewport::Maximize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MAXIMIZE );
	unguard;
}

void UWindowsViewport::Restore()
{
	guard(UWindowsViewport::Restore);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_RESTORE );
	unguard;
}

void UWindowsViewport::CheckCD()
{
	guard(UWindowsViewport::CheckCD);
	// CD check disabled in rebuilt binary.
	unguard;
}

void UWindowsViewport::AcquireKeyboard()
{
	guard(UWindowsViewport::AcquireKeyboard);
	if (UWindowsViewport::Keyboard)
		UWindowsViewport::Keyboard->Acquire();
	unguard;
}

void UWindowsViewport::ReleaseKeyboard()
{
	guard(UWindowsViewport::ReleaseKeyboard);
	if (UWindowsViewport::Keyboard)
		UWindowsViewport::Keyboard->Unacquire();
	unguard;
}

INT UWindowsViewport::KeyPressed(INT Key)
{
	guard(UWindowsViewport::KeyPressed);
	if( UWindowsViewport::Keyboard )
	{
		BYTE KeyStates[256];
		HRESULT hr = UWindowsViewport::Keyboard->GetDeviceState( sizeof(KeyStates), KeyStates );
		if( SUCCEEDED(hr) && Key >= 0 && Key < 256 )
			return (KeyStates[Key] & 0x80) ? 1 : 0;
	}
	return 0;
	unguard;
}

void UWindowsViewport::ToggleFullscreen()
{
	guard(UWindowsViewport::ToggleFullscreen);
	if( IsFullscreen() )
		EndFullscreen();
	else if( RenDev )
		RenDev->SetRes( SizeX, SizeY, ColorBytes, 1 );
	unguard;
}

void UWindowsViewport::EndFullscreen()
{
	guard(UWindowsViewport::EndFullscreen);
	if( RenDev && (BlitFlags & BLIT_Fullscreen) )
	{
		BlitFlags &= ~BLIT_Fullscreen;
		RenDev->SetRes( SizeX, SizeY, ColorBytes, 0 );
	}
	unguard;
}

INT UWindowsViewport::CauseInputEvent(INT iKey, EInputAction Action, FLOAT Delta)
{
	guard(UWindowsViewport::CauseInputEvent);
	// Dispatch the input event through the standard Unreal input pipeline.
	if( Input )
		return Input->Process( *this, (EInputKey)iKey, Action, Delta );
	return 0;
	unguard;
}

void UWindowsViewport::SetTopness()
{
	guard(UWindowsViewport::SetTopness);
	if( GViewportHWnd )
		SetWindowPos( GViewportHWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE );
	unguard;
}

DWORD UWindowsViewport::GetViewportButtonFlags(DWORD Buttons)
{
	guard(UWindowsViewport::GetViewportButtonFlags);
	// Map Win32 mouse button state to Unreal viewport button flags.
	DWORD Result = 0;
	if( GetAsyncKeyState(VK_LBUTTON) & 0x8000 ) Result |= MOUSE_Left;
	if( GetAsyncKeyState(VK_RBUTTON) & 0x8000 ) Result |= MOUSE_Right;
	if( GetAsyncKeyState(VK_MBUTTON) & 0x8000 ) Result |= MOUSE_Middle;
	return Result;
	unguard;
}

INT UWindowsViewport::JoystickInputEvent(FLOAT DeltaSeconds, EInputKey Key, FLOAT Delta, INT Abs)
{
	guard(UWindowsViewport::JoystickInputEvent);
	return 0;
	unguard;
}

LONG UWindowsViewport::ViewportWndProc(UINT Message, UINT wParam, LONG lParam)
{
	guard(UWindowsViewport::ViewportWndProc);
	// Dispatch to the default Win32 handler.
	if( GViewportHWnd )
		return DefWindowProcW( GViewportHWnd, Message, wParam, lParam );
	return 0;
	unguard;
}

// GetOuterUWindowsClient is provided inline by DECLARE_WITHIN(UWindowsClient)
// in the class declaration — no out-of-line definition needed.

INT STDCALL UWindowsViewport::EnumAxesCallback(const DIDEVICEOBJECTINSTANCEW* pdidoi, void* pContext)
{
	return DIENUM_CONTINUE;
}

INT STDCALL UWindowsViewport::EnumJoysticksCallback(const DIDEVICEINSTANCEW* pdidi, void* pContext)
{
	return DIENUM_CONTINUE;
}

/*-----------------------------------------------------------------------------
	UWindowsClient — implementation.
	Note: default ctor provided by DECLARE_CLASS / InternalConstructor path.
-----------------------------------------------------------------------------*/

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
	return 0;
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
	WWindowsViewportWindow — Non-UObject Win32 window wrapper.
-----------------------------------------------------------------------------*/

WWindowsViewportWindow::WWindowsViewportWindow()
	: Viewport(NULL)
{
}

WWindowsViewportWindow::WWindowsViewportWindow(UWindowsViewport* InViewport)
	: Viewport(InViewport)
{
}

WWindowsViewportWindow::WWindowsViewportWindow(const WWindowsViewportWindow& Other)
	: Viewport(Other.Viewport)
{
}

WWindowsViewportWindow& WWindowsViewportWindow::operator=(const WWindowsViewportWindow& Other)
{
	if( this != &Other )
		Viewport = Other.Viewport;
	return *this;
}

WWindowsViewportWindow::~WWindowsViewportWindow()
{
}

const TCHAR* WWindowsViewportWindow::GetPackageName()
{
	return TEXT("WinDrv");
}

void WWindowsViewportWindow::GetWindowClassName(TCHAR* OutName)
{
	// Build the window class name: e.g. "WinDrvUnreal" or "WinDrvUnrealChild"
	appSprintf(OutName, TEXT("%sUnreal"), appPackage());
}

LONG WWindowsViewportWindow::WndProc(UINT Message, UINT wParam, LONG lParam)
{
	// Forward to the owning UWindowsViewport.
	if( Viewport )
		return Viewport->ViewportWndProc( Message, wParam, lParam );
	return 0;
}

// DllMain is defined by the IMPLEMENT_PACKAGE(WinDrv) expansion above.
