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
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) WINDRV_API FName WINDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "WinDrvClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	WWindowsViewportWindow — Non-UObject Win32 window wrapper.
-----------------------------------------------------------------------------*/

IMPL_MATCH("WinDrv.dll", 0x11102370)
WWindowsViewportWindow::WWindowsViewportWindow()
	: Viewport(NULL)
{
}

IMPL_MATCH("WinDrv.dll", 0x11102370)
WWindowsViewportWindow::WWindowsViewportWindow(UWindowsViewport* InViewport)
	: Viewport(InViewport)
{
}

IMPL_MATCH("WinDrv.dll", 0x11102370)
WWindowsViewportWindow::WWindowsViewportWindow(const WWindowsViewportWindow& Other)
	: Viewport(Other.Viewport)
{
}

IMPL_TODO("found at 0x11102420; calls WWindow::operator= which requires WWindow inheritance absent from reconstructed headers")
WWindowsViewportWindow& WWindowsViewportWindow::operator=(const WWindowsViewportWindow& Other)
{
	if( this != &Other )
		Viewport = Other.Viewport;
	return *this;
}

IMPL_TODO("MaybeDestroy not called; WWindowsViewportWindow does not inherit WWindow in reconstructed headers")
WWindowsViewportWindow::~WWindowsViewportWindow()
{
	guard(WWindowsViewportWindow::~WWindowsViewportWindow);
	// DIVERGENCE: WWindow::MaybeDestroy() not called — WWindowsViewportWindow does not
	// yet inherit from WWindow in the reconstructed headers. The retail binary's
	// WWindowsViewportWindow inherits WWindow and calls MaybeDestroy() in the dtor.
	// GHIDRA REF: 0x2300 — single call to WWindow::MaybeDestroy on this.
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102360)
const TCHAR* WWindowsViewportWindow::GetPackageName()
{
	return TEXT("WinDrv");
}

IMPL_MATCH("WinDrv.dll", 0x111022e0)
void WWindowsViewportWindow::GetWindowClassName(TCHAR* OutName)
{
	appStrcpy(OutName, TEXT("WWindowsViewportWindow"));
}

IMPL_MATCH("WinDrv.dll", 0x111023e0)
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

IMPL_MATCH("WinDrv.dll", 0x11101000)
UWindowsClient::UWindowsClient(const UWindowsClient& Other)
	: UClient(Other)
{
	UseJoystick       = Other.UseJoystick;
	StartupFullscreen = Other.StartupFullscreen;
}

IMPL_MATCH("WinDrv.dll", 0x11101ea0)
UWindowsClient& UWindowsClient::operator=(const UWindowsClient& Other)
{
	UClient::operator=(Other);
	// FNotifyHook at +0x98 has no data members — copy is a no-op.
	// Copy 11 DWORDs (0x9c–0xc4) and 4 WORDs (0xc8–0xce) as one contiguous block.
	appMemcpy((BYTE*)this + 0x9c, (const BYTE*)&Other + 0x9c, 11 * sizeof(DWORD) + 4 * sizeof(WORD));
	return *this;
}

IMPL_DIVERGE("Retail registers UseJoystick/StartupFullscreen bool properties via UBoolProperty; omitted: UBoolProperty vtable layout differs from retail Core.dll")
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

IMPL_MATCH("WinDrv.dll", 0x111011a0)
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

IMPL_MATCH("WinDrv.dll", 0x111016f0)
void UWindowsClient::ShutdownAfterError()
{
	guard(UWindowsClient::ShutdownAfterError);
	Super::ShutdownAfterError();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11101320)
void UWindowsClient::PostEditChange()
{
	guard(UWindowsClient::PostEditChange);
	Super::PostEditChange();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11101770)
void UWindowsClient::NotifyDestroy(void* Src)
{
	guard(UWindowsClient::NotifyDestroy);
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x111015a0)
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

IMPL_MATCH("WinDrv.dll", 0x11101980)
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

IMPL_MATCH("WinDrv.dll", 0x111018d0)
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

IMPL_MATCH("WinDrv.dll", 0x11101b00)
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

IMPL_MATCH("WinDrv.dll", 0x11101290)
INT UWindowsClient::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UWindowsClient::Exec);
	return Super::Exec(Cmd, Ar) != 0;
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11101820)
UViewport* UWindowsClient::NewViewport(FName Name)
{
	guard(UWindowsClient::NewViewport);
	// Use the INT Reserved overload of StaticConstructObject (exported by Core.dll).
	return (UViewport*)UObject::StaticConstructObject(
		UWindowsViewport::StaticClass(), this, Name, 0, NULL, GError, (INT)0
	);
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11101a30)
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

IMPL_MATCH("WinDrv.dll", 0x11101390)
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

IMPL_TODO("found at 0x11101c80; implementation uses internal exception-handling not replicated here")
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

IMPL_MATCH("WinDrv.dll", 0x11102040)
UWindowsViewport::UWindowsViewport(const UWindowsViewport& Other)
	: UViewport(Other)
{
}

IMPL_MATCH("WinDrv.dll", 0x11102130)
UWindowsViewport& UWindowsViewport::operator=(const UWindowsViewport& Other)
{
	UViewport::operator=(Other);
	// Copy 25 contiguous DWORDs at offsets 0x204–0x264.
	appMemcpy((BYTE*)this + 0x204, (const BYTE*)&Other + 0x204, 25 * sizeof(DWORD));
	return *this;
}

IMPL_MATCH("WinDrv.dll", 0x111024a0)
void UWindowsViewport::Destroy()
{
	guard(UWindowsViewport::Destroy);
	CloseWindow();
	Super::Destroy();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102580)
void UWindowsViewport::ShutdownAfterError()
{
	guard(UWindowsViewport::ShutdownAfterError);
	if( GViewportHWnd )
		DestroyWindow( GViewportHWnd );
	GViewportHWnd = NULL;
	Super::ShutdownAfterError();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x111054a0)
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

IMPL_MATCH("WinDrv.dll", 0x11102940)
INT UWindowsViewport::Lock(BYTE* HitData, INT* HitSize)
{
	guard(UWindowsViewport::Lock);
	// m_Window is a WWindowsViewportWindow* at this+0x204; hWnd is at offset +4 in WWindow.
	HWND hWnd = *(HWND*)(*(DWORD**)((BYTE*)this + 0x204) + 1);
	if (hWnd && !IsWindow(hWnd))
		return 0;
	// HoldCount @ +0x214; viewport dims @ +0xa4/+0xa8; RenDev @ +0x8c
	if (*(INT*)((BYTE*)this + 0x214) == 0
		&& *(INT*)((BYTE*)this + 0xa4) != 0
		&& *(INT*)((BYTE*)this + 0xa8) != 0
		&& *(INT*)((BYTE*)this + 0x8c) != 0)
	{
		*(INT*)((BYTE*)this + 0x160) = *(INT*)((BYTE*)this + 0xa4);
		return Super::Lock(HitData, HitSize);
	}
	return 0;
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102a20)
void UWindowsViewport::Unlock()
{
	guard(UWindowsViewport::Unlock);
	// HoldCount is at raw offset 0x214; assert it's zero before unlocking.
	if (*(INT*)((BYTE*)this + 0x214) != 0)
		appFailAssert("!HoldCount", __FILE__, __LINE__);
	Super::Unlock();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102630)
INT UWindowsViewport::IsFullscreen()
{
	guard(UWindowsViewport::IsFullscreen);
	return (BlitFlags & BLIT_Fullscreen) ? 1 : 0;
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11104d00)
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

IMPL_MATCH("WinDrv.dll", 0x11103900)
void UWindowsViewport::SetModeCursor()
{
	guard(UWindowsViewport::SetModeCursor);
	SetCursor( LoadCursor(NULL, IDC_ARROW) );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102640)
void UWindowsViewport::UpdateWindowFrame()
{
	guard(UWindowsViewport::UpdateWindowFrame);
	if( GViewportHWnd )
	{
		SetWindowTextW( GViewportHWnd, GetName() );
	}
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11103300)
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

IMPL_MATCH("WinDrv.dll", 0x111025a0)
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

IMPL_MATCH("WinDrv.dll", 0x11104310)
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

IMPL_MATCH("WinDrv.dll", 0x111028b0)
void* UWindowsViewport::GetWindow()
{
	guard(UWindowsViewport::GetWindow);
	return (void*)GViewportHWnd;
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11103fd0)
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

IMPL_MATCH("WinDrv.dll", 0x11103870)
void UWindowsViewport::Repaint(INT Blit)
{
	guard(UWindowsViewport::Repaint);
	if( GViewportHWnd )
		InvalidateRect( GViewportHWnd, NULL, FALSE );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x111047d0)
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

IMPL_MATCH("WinDrv.dll", 0x11102010)
void UWindowsViewport::Hold(INT Horiz)
{
	// Ghidra: no guard/unguard (34-byte function, no SEH frame). HoldCount at raw offset 0x214.
	if (Horiz)
		*(INT*)((BYTE*)this + 0x214) += 1;
	else
		*(INT*)((BYTE*)this + 0x214) -= 1;
}

IMPL_MATCH("WinDrv.dll", 0x11102b60)
void UWindowsViewport::Minimize()
{
	guard(UWindowsViewport::Minimize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MINIMIZE );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102b90)
void UWindowsViewport::Maximize()
{
	guard(UWindowsViewport::Maximize);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_MAXIMIZE );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102bc0)
void UWindowsViewport::Restore()
{
	guard(UWindowsViewport::Restore);
	if( GViewportHWnd )
		ShowWindow( GViewportHWnd, SW_RESTORE );
	unguard;
}

IMPL_DIVERGE("Retail performs CD key validation; intentionally disabled in rebuild - no CD required")
void UWindowsViewport::CheckCD()
{
	guard(UWindowsViewport::CheckCD);
	// CD check disabled in rebuilt binary.
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102cb0)
void UWindowsViewport::AcquireKeyboard()
{
	guard(UWindowsViewport::AcquireKeyboard);
	// Retail always calls ReleaseKeyboard first, then creates a fresh device.
	ReleaseKeyboard();
	if (!DirectInput8)
		return;
	HRESULT hr = DirectInput8->CreateDevice(GUID_SysKeyboard, &Keyboard, NULL);
	if (hr < 0 || !Keyboard)
	{
		ReleaseKeyboard();
		return;
	}
	hr = Keyboard->SetDataFormat(&c_dfDIKeyboard);
	if (hr < 0)
	{
		ReleaseKeyboard();
		return;
	}
	// m_Window->hWnd: WWindowsViewportWindow* at this+0x204, hWnd is at +4 in WWindow.
	HWND hWnd = *(HWND*)(*(DWORD**)((BYTE*)this + 0x204) + 1);
	hr = Keyboard->SetCooperativeLevel(hWnd, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE);
	if (hr < 0)
	{
		ReleaseKeyboard();
		return;
	}
	hr = Keyboard->Acquire();
	if (hr < 0)
		ReleaseKeyboard();
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102d40)
void UWindowsViewport::ReleaseKeyboard()
{
	guard(UWindowsViewport::ReleaseKeyboard);
	if (UWindowsViewport::Keyboard)
	{
		UWindowsViewport::Keyboard->Unacquire();
		UWindowsViewport::Keyboard->Release();
		UWindowsViewport::Keyboard = NULL;
	}
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11102d70)
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

IMPL_MATCH("WinDrv.dll", 0x11104c20)
void UWindowsViewport::ToggleFullscreen()
{
	guard(UWindowsViewport::ToggleFullscreen);
	if( IsFullscreen() )
		EndFullscreen();
	else if( RenDev )
		RenDev->SetRes( SizeX, SizeY, ColorBytes, 1 );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x11104b30)
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

IMPL_MATCH("WinDrv.dll", 0x11103f40)
INT UWindowsViewport::CauseInputEvent(INT iKey, EInputAction Action, FLOAT Delta)
{
	guard(UWindowsViewport::CauseInputEvent);
	// Dispatch the input event through the standard Unreal input pipeline.
	if( Input )
		return Input->Process( *this, (EInputKey)iKey, Action, Delta );
	return 0;
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x111025d0)
void UWindowsViewport::SetTopness()
{
	guard(UWindowsViewport::SetTopness);
	if( GViewportHWnd )
		SetWindowPos( GViewportHWnd, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE|SWP_NOSIZE );
	unguard;
}

IMPL_MATCH("WinDrv.dll", 0x111028c0)
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

IMPL_MATCH("WinDrv.dll", 0x11104240)
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

IMPL_TODO("DIVERGENCE: uses GViewportHWnd directly, omits HoldCount check and editor code paths")
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

IMPL_MATCH("WinDrv.dll", 0x11102b00)
INT STDCALL UWindowsViewport::EnumAxesCallback(const DIDEVICEOBJECTINSTANCEW* pdidoi, void* pContext)
{
	return DIENUM_CONTINUE;
}

IMPL_MATCH("WinDrv.dll", 0x11102ac0)
INT STDCALL UWindowsViewport::EnumJoysticksCallback(const DIDEVICEINSTANCEW* pdidi, void* pContext)
{
	return DIENUM_CONTINUE;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
