/*=============================================================================
	WindowClasses.h: Minimal Window class declarations for Ravenshield.

	Replaces the full UT99 Window.h (6000+ lines) which has extensive
	incompatibilities with the Ravenshield CSDK headers (packing mismatches,
	UObject signature differences, missing shell API types, editor-only code).

	Only the declarations needed to compile and link Window.dll are here:
	forward declarations, FDelegate, WWindow statics, and 17 W* subclasses
	with their SuperProc statics.
=============================================================================*/

#ifndef _INC_WINDOWCLASSES
#define _INC_WINDOWCLASSES

/*----------------------------------------------------------------------------
	Unicode helper macros (from UT99 Window.h lines 24-55).
----------------------------------------------------------------------------*/

#define RegisterWindowMessageX(a)  TCHAR_CALL_OS(RegisterWindowMessageW(a),RegisterWindowMessageA(TCHAR_TO_ANSI(a)))
#define LoadLibraryX(a)            TCHAR_CALL_OS(LoadLibraryW(a),LoadLibraryA(TCHAR_TO_ANSI(a)))

/*----------------------------------------------------------------------------
	Forward declarations.
----------------------------------------------------------------------------*/

class WWindow;
class WControl;
class WLog;

/*----------------------------------------------------------------------------
	FCommandTarget — base for anything that can receive delegates.
----------------------------------------------------------------------------*/

class WINDOW_API FCommandTarget
{
public:
	virtual void Unused() {}
};

typedef void (FCommandTarget::*TDelegate)();
typedef void (FCommandTarget::*TDelegateInt)(INT);

/*----------------------------------------------------------------------------
	FDelegate — simple binding of object + member function.
----------------------------------------------------------------------------*/

struct WINDOW_API FDelegate
{
	FCommandTarget* TargetObject;
	void (FCommandTarget::*TargetInvoke)();

	FDelegate( FCommandTarget* InTargetObject=NULL, TDelegate InTargetInvoke=NULL )
	:	TargetObject( InTargetObject )
	,	TargetInvoke( InTargetInvoke )
	{}

	FDelegate( const FDelegate& );

	virtual void operator()()
	{
		if( TargetObject )
			(TargetObject->*TargetInvoke)();
	}
};

/*----------------------------------------------------------------------------
	WWindow — base window class.
	Only static members needed by Window.cpp are declared here.
	WIN_OBJ is 0, so WWindow does NOT inherit from UObject.
----------------------------------------------------------------------------*/

class WINDOW_API WWindow : public FCommandTarget
{
public:
	// Static members exported by Window.dll.
	static INT              ModalCount;
	static TArray<WWindow*> _Windows;
	static TArray<WWindow*> _DeleteWindows;
};

/*----------------------------------------------------------------------------
	WControl — base for Win32 control wrappers.
----------------------------------------------------------------------------*/

class WINDOW_API WControl : public WWindow
{
public:
};

/*----------------------------------------------------------------------------
	W* subclasses — each with a static WNDPROC SuperProc.
	DECLARE_WINDOWSUBCLASS in the original code adds SuperProc.
	Classes marked (R6) are Ravenshield additions not in UT99 Window.h.
----------------------------------------------------------------------------*/

#define DECLARE_WINDOW_STUB(cls, parentcls) \
	class WINDOW_API cls : public parentcls { \
	public: \
		static WNDPROC SuperProc; \
	};

DECLARE_WINDOW_STUB(WButton,      WControl)
DECLARE_WINDOW_STUB(WEdit,        WControl)
DECLARE_WINDOW_STUB(WRichEdit,    WControl)
DECLARE_WINDOW_STUB(WListBox,     WControl)
DECLARE_WINDOW_STUB(WCheckListBox,WControl)
DECLARE_WINDOW_STUB(WComboBox,    WControl)
DECLARE_WINDOW_STUB(WScrollBar,   WControl)   // (R6)
DECLARE_WINDOW_STUB(WTreeView,    WControl)
DECLARE_WINDOW_STUB(WTabControl,  WControl)
DECLARE_WINDOW_STUB(WTrackBar,    WControl)
DECLARE_WINDOW_STUB(WProgressBar, WControl)
DECLARE_WINDOW_STUB(WListView,    WControl)   // (R6)
DECLARE_WINDOW_STUB(WUrlButton,   WControl)
DECLARE_WINDOW_STUB(WLabel,       WControl)
DECLARE_WINDOW_STUB(WToolTip,     WControl)
DECLARE_WINDOW_STUB(WHeaderCtrl,  WControl)   // (R6)
DECLARE_WINDOW_STUB(WPictureButton, WWindow)  // (R6 - SuperProc added by R6)

#undef DECLARE_WINDOW_STUB

/*----------------------------------------------------------------------------
	Global functions.
----------------------------------------------------------------------------*/

WINDOW_API void    InitWindowing();
WINDOW_API HBITMAP LoadFileToBitmap( const TCHAR* Filename, INT& SizeX, INT& SizeY );

/*----------------------------------------------------------------------------
	Global variables — UT99 originals.
----------------------------------------------------------------------------*/

extern WINDOW_API HBRUSH    hBrushWhite;
extern WINDOW_API HBRUSH    hBrushOffWhite;
extern WINDOW_API HBRUSH    hBrushHeadline;
extern WINDOW_API HBRUSH    hBrushBlack;
extern WINDOW_API HBRUSH    hBrushStipple;
extern WINDOW_API HBRUSH    hBrushCurrent;
extern WINDOW_API HBRUSH    hBrushDark;
extern WINDOW_API HBRUSH    hBrushGrey;
extern WINDOW_API HFONT     hFontText;
extern WINDOW_API HFONT     hFontUrl;
extern WINDOW_API HFONT     hFontHeadline;
extern WINDOW_API WLog*     GLogWindow;
extern WINDOW_API HINSTANCE hInstanceWindow;
extern WINDOW_API UBOOL     GNotify;
extern WINDOW_API UINT      WindowMessageOpen;
extern WINDOW_API UINT      WindowMessageMouseWheel;
extern WINDOW_API NOTIFYICONDATA NID;
#if UNICODE
extern WINDOW_API NOTIFYICONDATAA NIDA;
#endif

#endif
