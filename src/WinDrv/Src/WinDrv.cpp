/*=============================================================================
	WinDrv.cpp: WinDrv package init and WWindowsViewportWindow.
	Reconstructed for Ravenshield decompilation project.
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
	WWindowsViewportWindow — Non-UObject Win32 window wrapper.
-----------------------------------------------------------------------------*/

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
WWindowsViewportWindow::WWindowsViewportWindow()
	: Viewport(NULL)
{
}

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
WWindowsViewportWindow::WWindowsViewportWindow(UWindowsViewport* InViewport)
	: Viewport(InViewport)
{
}

IMPL_INFERRED("Reconstructed from context")
WWindowsViewportWindow::WWindowsViewportWindow(const WWindowsViewportWindow& Other)
	: Viewport(Other.Viewport)
{
}

IMPL_INFERRED("Reconstructed from context")
WWindowsViewportWindow& WWindowsViewportWindow::operator=(const WWindowsViewportWindow& Other)
{
	if( this != &Other )
		Viewport = Other.Viewport;
	return *this;
}

IMPL_GHIDRA_APPROX("WinDrv.dll", 0x2300, "MaybeDestroy not called; WWindowsViewportWindow does not inherit WWindow in reconstructed headers")
WWindowsViewportWindow::~WWindowsViewportWindow()
{
	guard(WWindowsViewportWindow::~WWindowsViewportWindow);
	// DIVERGENCE: WWindow::MaybeDestroy() not called — WWindowsViewportWindow does not
	// yet inherit from WWindow in the reconstructed headers. The retail binary's
	// WWindowsViewportWindow inherits WWindow and calls MaybeDestroy() in the dtor.
	// GHIDRA REF: 0x2300 — single call to WWindow::MaybeDestroy on this.
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
const TCHAR* WWindowsViewportWindow::GetPackageName()
{
	return TEXT("WinDrv");
}

IMPL_INFERRED("Reconstructed from context")
void WWindowsViewportWindow::GetWindowClassName(TCHAR* OutName)
{
	appStrcpy(OutName, TEXT("WWindowsViewportWindow"));
}

IMPL_INFERRED("Reconstructed from context")
LONG WWindowsViewportWindow::WndProc(UINT Message, UINT wParam, LONG lParam)
{
	// Forward to the owning UWindowsViewport.
	if( Viewport )
		return Viewport->ViewportWndProc( Message, wParam, lParam );
	return 0;
}

// DllMain is defined by the IMPLEMENT_PACKAGE(WinDrv) expansion above.

// Defined in WinDrvViewport.cpp — exported free function for DInput error reporting.
extern WINDRV_API void DirectInputError(FString Msg, LONG hResult, INT Fatal);

IMPLEMENT_CLASS(UWindowsClient)

// --- UWindowsClient ---

IMPL_INFERRED("Reconstructed from context")
UWindowsClient::UWindowsClient(const UWindowsClient& Other)
	: UClient(Other)
{
	UseJoystick       = Other.UseJoystick;
	StartupFullscreen = Other.StartupFullscreen;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_TODO("Needs Ghidra analysis")
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

IMPL_INFERRED("Releases DirectInput devices then delegates to Super")
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

IMPL_INFERRED("Delegates to Super")
void UWindowsClient::ShutdownAfterError()
{
	guard(UWindowsClient::ShutdownAfterError);
	Super::ShutdownAfterError();
	unguard;
}

IMPL_INFERRED("Delegates to Super")
void UWindowsClient::PostEditChange()
{
	guard(UWindowsClient::PostEditChange);
	Super::PostEditChange();
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
void UWindowsClient::NotifyDestroy(void* Src)
{
	guard(UWindowsClient::NotifyDestroy);
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
INT UWindowsClient::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UWindowsClient::Exec);
	return Super::Exec(Cmd, Ar) != 0;
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
UViewport* UWindowsClient::NewViewport(FName Name)
{
	guard(UWindowsClient::NewViewport);
	// Use the INT Reserved overload of StaticConstructObject (exported by Core.dll).
	return (UViewport*)UObject::StaticConstructObject(
		UWindowsViewport::StaticClass(), this, Name, 0, NULL, GError, (INT)0
	);
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

// ImmAssociateContext — used by ViewportWndProc to disable IME on the game window.
#pragma comment(lib, "imm32.lib")
IMPLEMENT_CLASS(UWindowsViewport)

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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
UWindowsViewport::UWindowsViewport(const UWindowsViewport& Other)
	: UViewport(Other)
{
}

IMPL_INFERRED("Reconstructed from context")
UWindowsViewport& UWindowsViewport::operator=(const UWindowsViewport& Other)
{
	if (this != &Other)
		UViewport::operator=(Other);
	return *this;
}

IMPL_INFERRED("Closes window then delegates to Super")
void UWindowsViewport::Destroy()
{
	guard(UWindowsViewport::Destroy);
	CloseWindow();
	Super::Destroy();
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::ShutdownAfterError()
{
	guard(UWindowsViewport::ShutdownAfterError);
	if( GViewportHWnd )
		DestroyWindow( GViewportHWnd );
	GViewportHWnd = NULL;
	Super::ShutdownAfterError();
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("DIVERGENCE: simplified HWND validity check; retail checks WWindowsViewportWindow and HoldCount")
INT UWindowsViewport::Lock(BYTE* HitData, INT* HitSize)
{
	guard(UWindowsViewport::Lock);
	// DIVERGENCE: retail checks WWindowsViewportWindow (this+0x204+4), HoldCount
	// (this+0x214), and render resource flags before delegating. We test HWND validity only.
	if (GViewportHWnd && !IsWindow(GViewportHWnd))
		return 0;
	return Super::Lock(HitData, HitSize);
	unguard;
}

IMPL_INFERRED("DIVERGENCE: HoldCount accessed via raw offset 0x214")
void UWindowsViewport::Unlock()
{
	guard(UWindowsViewport::Unlock);
	// DIVERGENCE: HoldCount is at raw offset 0x214 in UViewport; not exposed in local headers.
	check(*(INT*)((BYTE*)this + 0x214) == 0);
	Super::Unlock();
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
INT UWindowsViewport::IsFullscreen()
{
	guard(UWindowsViewport::IsFullscreen);
	return (BlitFlags & BLIT_Fullscreen) ? 1 : 0;
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::SetModeCursor()
{
	guard(UWindowsViewport::SetModeCursor);
	SetCursor( LoadCursor(NULL, IDC_ARROW) );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::UpdateWindowFrame()
{
	guard(UWindowsViewport::UpdateWindowFrame);
	if( GViewportHWnd )
	{
		SetWindowTextW( GViewportHWnd, GetName() );
	}
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::OpenWindow(DWORD ParentWindow, INT IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY)
{
	guard(UWindowsViewport::OpenWindow);

	check(GetOuterUWindowsClient());

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
		GetName(),
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
void* UWindowsViewport::GetWindow()
{
	guard(UWindowsViewport::GetWindow);
	return (void*)GViewportHWnd;
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::Repaint(INT Blit)
{
	guard(UWindowsViewport::Repaint);
	if( GViewportHWnd )
		InvalidateRect( GViewportHWnd, NULL, FALSE );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("DIVERGENCE: HoldCount accessed via raw offset 0x214")
IMPL_INFERRED("DIVERGENCE: HoldCount accessed via raw offset 0x214")
void UWindowsViewport::Hold(INT Horiz)
{
	guard(UWindowsViewport::Hold);
	// DIVERGENCE: HoldCount is at raw offset 0x214 in UViewport; not exposed in local headers.
	INT& HoldCount = *(INT*)((BYTE*)this + 0x214);
	if (Horiz) HoldCount++; else HoldCount--;
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::Minimize()
{
	guard(UWindowsViewport::Minimize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MINIMIZE );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::Maximize()
{
	guard(UWindowsViewport::Maximize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MAXIMIZE );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::Restore()
{
	guard(UWindowsViewport::Restore);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_RESTORE );
	unguard;
}

IMPL_TODO("Needs Ghidra analysis")
IMPL_TODO("Needs Ghidra analysis")
void UWindowsViewport::CheckCD()
{
	guard(UWindowsViewport::CheckCD);
	// CD check disabled in rebuilt binary.
	unguard;
}

IMPL_INFERRED("DIVERGENCE: uses GViewportHWnd instead of m_Window->hWnd")
void UWindowsViewport::AcquireKeyboard()
{
	guard(UWindowsViewport::AcquireKeyboard);
	if (DirectInput8 && !Keyboard)
	{
		HRESULT hr = DirectInput8->CreateDevice(GUID_SysKeyboard, &Keyboard, NULL);
		if (SUCCEEDED(hr) && Keyboard)
		{
			hr = Keyboard->SetDataFormat(&c_dfDIKeyboard);
			if (SUCCEEDED(hr))
			{
				// DIVERGENCE: retail uses m_Window->hWnd (this+0x204+4); we use GViewportHWnd.
				hr = Keyboard->SetCooperativeLevel(GViewportHWnd, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE);
				if (SUCCEEDED(hr))
					Keyboard->Acquire();
			}
		}
	}
	else if (Keyboard)
	{
		Keyboard->Acquire();
	}
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::ReleaseKeyboard()
{
	guard(UWindowsViewport::ReleaseKeyboard);
	if (UWindowsViewport::Keyboard)
		UWindowsViewport::Keyboard->Unacquire();
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::ToggleFullscreen()
{
	guard(UWindowsViewport::ToggleFullscreen);
	if( IsFullscreen() )
		EndFullscreen();
	else if( RenDev )
		RenDev->SetRes( SizeX, SizeY, ColorBytes, 1 );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
INT UWindowsViewport::CauseInputEvent(INT iKey, EInputAction Action, FLOAT Delta)
{
	guard(UWindowsViewport::CauseInputEvent);
	// Dispatch the input event through the standard Unreal input pipeline.
	if( Input )
		return Input->Process( *this, (EInputKey)iKey, Action, Delta );
	return 0;
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
void UWindowsViewport::SetTopness()
{
	guard(UWindowsViewport::SetTopness);
	if( GViewportHWnd )
		SetWindowPos( GViewportHWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE );
	unguard;
}

IMPL_INFERRED("Reconstructed from context")
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

IMPL_INFERRED("Reconstructed from context")
INT UWindowsViewport::JoystickInputEvent(FLOAT DeltaSeconds, EInputKey Key, FLOAT Delta, INT Abs)
{
	guard(UWindowsViewport::JoystickInputEvent);
	// Normalise raw axis value from DirectInput range [-32767, 32767] to [-1, 1].
	// 3.0517578e-05 == 1.0 / 32768.0
	FLOAT fAxis = DeltaSeconds * 3.0517578e-05f;
	if( Abs )
	{
		// Apply ±0.2 deadzone then remap remaining range to full scale.
		if( fAxis > 0.2f )
			fAxis = (fAxis - 0.2f) * 1.25f;
		else if( fAxis < -0.2f )
			fAxis = (fAxis + 0.2f) * 1.25f;
		else
			fAxis = 0.0f;
	}
	return CauseInputEvent( Key, IST_Axis, fAxis * Delta );
	unguard;
}

IMPL_INFERRED("DIVERGENCE: uses GViewportHWnd directly, omits HoldCount check and editor code paths")
LONG UWindowsViewport::ViewportWndProc(UINT Message, UINT wParam, LONG lParam)
{
	guard(UWindowsViewport::ViewportWndProc);
	// DIVERGENCE: Retail uses WWindowsViewportWindow (stored at this+0x204) to obtain the
	// real HWND, and checks HoldCount (this+0x214) to fast-path to DefWindowProc when the
	// viewport is held (e.g. during dialog display). It also walks the UWindowsClient's
	// viewport list to validate "this" before processing. We use GViewportHWnd directly,
	// omit editor-mode (GIsEditor) code paths entirely, and skip the HoldCount check.
	// Input is primarily handled by DirectInput polling in UpdateInput(); this proc only
	// manages device acquisition state.

	switch (Message)
	{
	case WM_ERASEBKGND:
		// Retail returns 0 to suppress background erasure (avoids flicker).
		return 0;

	case WM_CREATE:
		// Retail: MakeCurrent(this), disable IME, SetFocus.
		// DIVERGENCE: no GetOuterUClient()->MakeCurrent() call (vtable+0x8c path).
		if (GViewportHWnd)
		{
			ImmAssociateContext(GViewportHWnd, (HIMC)0); // disable IME for gameplay
			SetFocus(GViewportHWnd);
		}
		return 0;

	case WM_DESTROY:
		// Retail: EndFullscreen if fullscreen, then reparents, calls Close, logs.
		if (BlitFlags & BLIT_Fullscreen)
			EndFullscreen();
		return 0;

	case WM_SIZE:
		// Retail: calls a vtable repaint function, optionally sets IsRealtime flag.
		// We update SizeX/SizeY so the render device uses the new dimensions.
		if (wParam != SIZE_MINIMIZED && lParam != 0)
		{
			SizeX = LOWORD(lParam);
			SizeY = HIWORD(lParam);
		}
		return 0;

	case WM_ACTIVATE:
		// Retail: on WA_INACTIVE calls CloseWindow (vtable+0x74), then DefWindowProc.
		// DIVERGENCE: we only unacquire devices on deactivation to avoid destroying
		// the window. Acquiring back happens on WM_SETFOCUS.
		if (LOWORD(wParam) == WA_INACTIVE)
		{
			if (Mouse)    Mouse->Unacquire();
			if (Joystick) Joystick->Unacquire();
		}
		break; // fall through to DefWindowProc

	case WM_SETFOCUS:
		// Retail: ResetInput (vtable+0x9c), UInput::Flush (Input+0x7c),
		//         Mouse->Acquire, Joystick->Acquire, MakeCurrent(this),
		//         ImmAssociateContext to disable IME.
		// DIVERGENCE: vtable-indirected calls are omitted; we do the device work.
		if (Mouse)    Mouse->Acquire();
		if (Joystick) Joystick->Acquire();
		if (GViewportHWnd)
			ImmAssociateContext(GViewportHWnd, (HIMC)0);
		return 0;

	case WM_KILLFOCUS:
		// Retail: Joystick->Unacquire if focus went to another process, release
		//         capture (vtable+0x9c), call CloseCapture (vtable+0x74),
		//         UInput::Reset if non-editor, MakeCurrent(NULL).
		// DIVERGENCE: we release all pointer devices simply.
		if (Mouse)    Mouse->Unacquire();
		if (Joystick) Joystick->Unacquire();
		ClipCursor(NULL);
		ReleaseCapture();
		return 0;

	case WM_PAINT:
		// Retail: if render-target flags are set (BLIT_Fullscreen | BLIT_DirtyWindow etc.)
		//         ValidateRect+return 0; otherwise return 1.
		if (GViewportHWnd)
			ValidateRect(GViewportHWnd, NULL);
		return 1;

	case WM_ENTERMENULOOP: // 0x211
		// Retail: unacquire mouse/joystick while a menu is open.
		if (Mouse)    Mouse->Unacquire();
		if (Joystick) Joystick->Unacquire();
		return 0;

	case WM_EXITMENULOOP: // 0x212
		// Retail: re-acquire mouse/joystick after the menu closes.
		if (Mouse)    Mouse->Acquire();
		if (Joystick) Joystick->Acquire();
		return 0;

	default:
		break;
	}

	if (GViewportHWnd)
		return DefWindowProcW(GViewportHWnd, Message, wParam, lParam);
	return 0;
	unguard;
}

// GetOuterUWindowsClient is provided inline by DECLARE_WITHIN(UWindowsClient)
// in the class declaration — no out-of-line definition needed.

IMPL_TODO("Needs Ghidra analysis")
INT STDCALL UWindowsViewport::EnumAxesCallback(const DIDEVICEOBJECTINSTANCEW* pdidoi, void* pContext)
{
	return DIENUM_CONTINUE;
}

IMPL_TODO("Needs Ghidra analysis")
INT STDCALL UWindowsViewport::EnumJoysticksCallback(const DIDEVICEINSTANCEW* pdidi, void* pContext)
{
	return DIENUM_CONTINUE;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
