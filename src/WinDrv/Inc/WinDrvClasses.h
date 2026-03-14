/*=============================================================================
	WinDrvClasses.h: WinDrv class declarations for Ravenshield.

	Declares:
	  UWindowsViewport  — Windows platform viewport (keyboard, mouse, DInput)
	  UWindowsClient    — Viewport factory and client lifecycle manager
	  WWindowsViewportWindow — Non-UObject Win32 window wrapper

	The retail WinDrv.dll has 89 exports, all from these three classes plus
	a few package-level globals (GPackage, autoclass pointers, vtables).
=============================================================================*/

#ifndef _INC_WINDRV_CLASSES
#define _INC_WINDRV_CLASSES

#ifndef WINDRV_API
#define WINDRV_API DLL_IMPORT
#endif

#pragma pack(push, 4)

/*----------------------------------------------------------------------------
	AUTOGENERATE macros — used in WinDrv.cpp to register FName tokens.
----------------------------------------------------------------------------*/

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern WINDRV_API FName WINDRV_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

// Forward declaration needed by DECLARE_WITHIN(UWindowsClient) inside
// UWindowsViewport — UWindowsClient is declared later in this header.
class UWindowsClient;

// ---------------------------------------------------------------------------
// UWindowsViewport — Windows platform viewport.
//
// Manages a Win32 window for rendering, plus DirectInput devices for
// keyboard, mouse, and optional joystick. The static members (DirectInput8,
// Keyboard, Mouse, Joystick, JoystickCaps) are shared across all viewports.
// ---------------------------------------------------------------------------
class WINDRV_API UWindowsViewport : public UViewport
{
	DECLARE_CLASS(UWindowsViewport, UViewport, CLASS_Transient, WinDrv)
	// Default ctor: public, exported at ordinal @4 by retail WinDrv.dll.
	UWindowsViewport() {}

	// UObject overrides
	virtual void Destroy();
	virtual void ShutdownAfterError();

	// URenderTarget overrides
	virtual INT Lock(BYTE* HitData, INT* HitSize);
	virtual void Unlock();

	// UViewport overrides
	virtual INT Exec(const TCHAR* Cmd, FOutputDevice& Ar);
	virtual INT IsFullscreen();
	virtual INT ResizeViewport(DWORD Caps, INT NewX, INT NewY);
	virtual void SetModeCursor();
	virtual void UpdateWindowFrame();
	virtual void OpenWindow(DWORD ParentWindow, INT IsTemporary, INT NewX, INT NewY, INT OpenX, INT OpenY);
	virtual void CloseWindow();
	virtual void UpdateInput(INT Reset, FLOAT DeltaSeconds);
	virtual void* GetWindow();
	virtual void SetMouseCapture(INT Capture, INT Clip, INT FocusOnly);
	virtual void Repaint(INT Blit);
	virtual void TryRenderDevice(const TCHAR* ClassName, INT NewX, INT NewY, INT Fullscreen);
	virtual void Hold(INT Horiz);
	virtual void Minimize();
	virtual void Maximize();
	virtual void Restore();
	virtual void CheckCD();
	virtual void AcquireKeyboard();
	virtual void ReleaseKeyboard();
	virtual INT KeyPressed(INT Key);
	// Non-virtual in retail WinDrv.dll (QAEXXZ mangling, not UAEXXZ).
	void ToggleFullscreen();
	void EndFullscreen();

	// WinDrv-specific
	INT CauseInputEvent(INT iKey, EInputAction Action, FLOAT Delta);
	void SetTopness();
	DWORD GetViewportButtonFlags(DWORD Buttons);
	INT JoystickInputEvent(FLOAT DeltaSeconds, EInputKey Key, FLOAT Delta, INT Abs);
	LONG ViewportWndProc(UINT Message, UINT wParam, LONG lParam);
	DECLARE_WITHIN(UWindowsClient)

	// Static DirectInput device DATA members (exported by ordinal from retail DLL).
	// Shared across all viewport instances for the process lifetime.
	static IDirectInput8W*       DirectInput8;
	static IDirectInputDevice8W* Keyboard;
	static IDirectInputDevice8W* Mouse;
	static IDirectInputDevice8W* Joystick;
	static DIDEVCAPS             JoystickCaps;

	// DirectInput enum callbacks
	static INT STDCALL EnumAxesCallback(const DIDEVICEOBJECTINSTANCEW* pdidoi, void* pContext);
	static INT STDCALL EnumJoysticksCallback(const DIDEVICEINSTANCEW* pdidi, void* pContext);

	// Copy ctor and operator= (exported by retail DLL)
	UWindowsViewport(const UWindowsViewport&);
	UWindowsViewport& operator=(const UWindowsViewport&);
};

// ---------------------------------------------------------------------------
// UWindowsClient — viewport factory and client lifecycle manager.
//
// Created by the engine on startup; creates UWindowsViewport instances on
// demand. Manages the DirectInput8 device lifetime for the process.
// ---------------------------------------------------------------------------
class WINDRV_API UWindowsClient : public UClient
{
	DECLARE_CLASS(UWindowsClient, UClient, CLASS_Config, WinDrv)
	// Default ctor: public, exported at ordinal @2 by retail WinDrv.dll.
	UWindowsClient() {}

	// Config properties
	BITFIELD UseJoystick     : 1; // CPF_Config
	BITFIELD StartupFullscreen : 1; // CPF_Config

	// UObject overrides
	virtual void Destroy();
	virtual void ShutdownAfterError();
	virtual void PostEditChange();
	virtual void NotifyDestroy(void* Src);

	// UClient overrides
	virtual void Init(UEngine* InEngine);
	virtual void ShowViewportWindows(DWORD ShowFlags, INT DoShow);
	virtual void EnableViewportWindows(DWORD ShowFlags, INT DoEnable);
	virtual void Tick();
	virtual INT Exec(const TCHAR* Cmd, FOutputDevice& Ar);
	virtual UViewport* NewViewport(FName Name);
	virtual void MakeCurrent(UViewport* InViewport);
	virtual UViewport* GetLastCurrent();

	// Lifecycle
	void StaticConstructor();

	// Copy ctor and operator= (exported by retail DLL)
	UWindowsClient(const UWindowsClient&);
	UWindowsClient& operator=(const UWindowsClient&);
};

// ---------------------------------------------------------------------------
// WWindowsViewportWindow — non-UObject Win32 window wrapper.
//
// Hosts the rendering surface. Receives Win32 messages and dispatches them
// to the owning UWindowsViewport via ViewportWndProc.
// ---------------------------------------------------------------------------
class WINDRV_API WWindowsViewportWindow
{
public:
	UWindowsViewport* Viewport;

	virtual ~WWindowsViewportWindow();
	virtual const TCHAR* GetPackageName();
	virtual void GetWindowClassName(TCHAR* OutName);
	virtual LONG WndProc(UINT Message, UINT wParam, LONG lParam);

	WWindowsViewportWindow(UWindowsViewport* InViewport);
	WWindowsViewportWindow(const WWindowsViewportWindow&);
	WWindowsViewportWindow();
	WWindowsViewportWindow& operator=(const WWindowsViewportWindow&);
};

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#pragma pack(pop)

#endif // _INC_WINDRV_CLASSES
