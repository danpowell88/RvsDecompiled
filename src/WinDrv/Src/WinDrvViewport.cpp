/*=============================================================================
	WinDrvViewport.cpp: UWindowsViewport — Win32 window + DirectInput.
	Reconstructed for Ravenshield decompilation project.

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
	// DIVERGENCE: retail checks WWindowsViewportWindow (this+0x204+4), HoldCount
	// (this+0x214), and render resource flags before delegating. We test HWND validity only.
	if (GViewportHWnd && !IsWindow(GViewportHWnd))
		return 0;
	return Super::Lock(HitData, HitSize);
	unguard;
}

void UWindowsViewport::Unlock()
{
	guard(UWindowsViewport::Unlock);
	// DIVERGENCE: HoldCount is at raw offset 0x214 in UViewport; not exposed in local headers.
	check(*(INT*)((BYTE*)this + 0x214) == 0);
	Super::Unlock();
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
		SetWindowTextW( GViewportHWnd, GetName() );
	}
	unguard;
}

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
	// DIVERGENCE: HoldCount is at raw offset 0x214 in UViewport; not exposed in local headers.
	INT& HoldCount = *(INT*)((BYTE*)this + 0x214);
	if (Horiz) HoldCount++; else HoldCount--;
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
	The End.
-----------------------------------------------------------------------------*/
