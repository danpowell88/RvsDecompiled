/*=============================================================================
	WinDrv.cpp: WinDrv package — Windows viewport driver and DirectInput.
	Reconstructed for Ravenshield decompilation project.

	Implements:
	  UWindowsViewport  — Win32 window + DirectInput input handling
	  UWindowsClient    — Viewport factory, DirectInput8 lifecycle
	  WWindowsViewportWindow — Non-UObject Win32 WNDCLASS host

	All method bodies are stubs; full logic involves the DirectInput8 device
	acquisition path (Ghidra-analysed), Win32 window creation, and the Unreal
	input event dispatch system (CauseInputEvent → ExecInputCommands).

	Divergences from retail byte parity:
	  - Static DirectInput device pointers (Keyboard, Mouse, Joystick,
	    DirectInput8, JoystickCaps) are exported as individual variables
	    rather than inlined into a static struct — this matches the retail
	    export names but the layout may differ by a few bytes.
	  - All virtual method bodies are stub returns; no functional code.
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
	UWindowsViewport — implementation stubs.
-----------------------------------------------------------------------------*/

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
	Super::Destroy();
	unguard;
}

void UWindowsViewport::ShutdownAfterError()
{
	guard(UWindowsViewport::ShutdownAfterError);
	Super::ShutdownAfterError();
	unguard;
}

INT UWindowsViewport::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	guard(UWindowsViewport::Exec);
	return 0;
	unguard;
}

INT UWindowsViewport::Lock(BYTE* HitData, INT* HitSize)
{
	guard(UWindowsViewport::Lock);
	return 0;
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
	return 0;
	unguard;
}

INT UWindowsViewport::ResizeViewport(DWORD Caps, INT NewX, INT NewY)
{
	guard(UWindowsViewport::ResizeViewport);
	return 0;
	unguard;
}

void UWindowsViewport::SetModeCursor()
{
	guard(UWindowsViewport::SetModeCursor);
	unguard;
}

void UWindowsViewport::UpdateWindowFrame()
{
	guard(UWindowsViewport::UpdateWindowFrame);
	unguard;
}

void UWindowsViewport::OpenWindow(DWORD ParentWindow, INT IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY)
{
	guard(UWindowsViewport::OpenWindow);
	unguard;
}

void UWindowsViewport::CloseWindow()
{
	guard(UWindowsViewport::CloseWindow);
	unguard;
}

void UWindowsViewport::UpdateInput(INT Reset, FLOAT DeltaSeconds)
{
	guard(UWindowsViewport::UpdateInput);
	unguard;
}

void* UWindowsViewport::GetWindow()
{
	guard(UWindowsViewport::GetWindow);
	return NULL;
	unguard;
}

void UWindowsViewport::SetMouseCapture(INT Capture, INT Clip, INT FocusOnly)
{
	guard(UWindowsViewport::SetMouseCapture);
	unguard;
}

void UWindowsViewport::Repaint(INT Blit)
{
	guard(UWindowsViewport::Repaint);
	unguard;
}

void UWindowsViewport::TryRenderDevice(const TCHAR* ClassName, INT NewX, INT NewY, INT Fullscreen)
{
	guard(UWindowsViewport::TryRenderDevice);
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
	unguard;
}

void UWindowsViewport::Maximize()
{
	guard(UWindowsViewport::Maximize);
	unguard;
}

void UWindowsViewport::Restore()
{
	guard(UWindowsViewport::Restore);
	unguard;
}

void UWindowsViewport::CheckCD()
{
	guard(UWindowsViewport::CheckCD);
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
	return 0;
	unguard;
}

void UWindowsViewport::ToggleFullscreen()
{
	guard(UWindowsViewport::ToggleFullscreen);
	unguard;
}

void UWindowsViewport::EndFullscreen()
{
	guard(UWindowsViewport::EndFullscreen);
	unguard;
}

INT UWindowsViewport::CauseInputEvent(INT iKey, EInputAction Action, FLOAT Delta)
{
	guard(UWindowsViewport::CauseInputEvent);
	return 0;
	unguard;
}

void UWindowsViewport::SetTopness()
{
	guard(UWindowsViewport::SetTopness);
	unguard;
}

DWORD UWindowsViewport::GetViewportButtonFlags(DWORD Buttons)
{
	guard(UWindowsViewport::GetViewportButtonFlags);
	return 0;
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
	UWindowsClient — implementation stubs.
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
	// BITFIELD config properties here. Registration is omitted in this stub
	// because UBoolProperty construction references non-exported UProperty
	// vtable entries (2-param CopyCompleteValue/SerializeBin overloads that
	// were removed before retail Core.dll was finalised).
	// The config values will not be read from .ini in this build.
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
	unguard;
}

void UWindowsClient::EnableViewportWindows(DWORD ShowFlags, INT DoEnable)
{
	guard(UWindowsClient::EnableViewportWindows);
	unguard;
}

void UWindowsClient::Tick()
{
	guard(UWindowsClient::Tick);
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
	unguard;
}

UViewport* UWindowsClient::GetLastCurrent()
{
	guard(UWindowsClient::GetLastCurrent);
	return NULL;
	unguard;
}

/*-----------------------------------------------------------------------------
	WWindowsViewportWindow — Non-UObject Win32 window wrapper.
-----------------------------------------------------------------------------*/

WWindowsViewportWindow::WWindowsViewportWindow()
{
}

WWindowsViewportWindow::WWindowsViewportWindow(UWindowsViewport* InViewport)
{
}

WWindowsViewportWindow::WWindowsViewportWindow(const WWindowsViewportWindow& Other)
{
}

WWindowsViewportWindow& WWindowsViewportWindow::operator=(const WWindowsViewportWindow& Other)
{
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
	return 0;
}

// DllMain is defined by the IMPLEMENT_PACKAGE(WinDrv) expansion above.
