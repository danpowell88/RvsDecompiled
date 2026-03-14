/*=============================================================================
	Window.cpp: Unreal Window subsystem — package registration and stubs.
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "WindowPrivate.h"

/*-----------------------------------------------------------------------------
	__FUNC_NAME__ compatibility shims.
	MSVC 7.1 emitted externally visible function-name string data while modern
	MSVC keeps them internal. Mirror the Core/Engine pattern: redirect each
	.def export to a named wide-string blob containing the function name.
-----------------------------------------------------------------------------*/
extern "C" {
__declspec(dllexport) const unsigned short _gfn_WPropertiesCtor[]    = {'W','P','r','o','p','e','r','t','i','e','s',':',':','W','P','r','o','p','e','r','t','i','e','s',0};
__declspec(dllexport) const unsigned short _gfn_FTreeItemDtor[]      = {'F','T','r','e','e','I','t','e','m',':',':','~','F','T','r','e','e','I','t','e','m',0};
__declspec(dllexport) const unsigned short _gfn_LoadLocalizedMenu[]  = {'L','o','a','d','L','o','c','a','l','i','z','e','d','M','e','n','u',0};
}
static volatile const void* _gfnWindowRefs[] = {_gfn_WPropertiesCtor, _gfn_FTreeItemDtor, _gfn_LoadLocalizedMenu};

#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???0WProperties@@QAE@VFName@@PAVWWindow@@@Z@4QBGB=__gfn_WPropertiesCtor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2???1FTreeItem@@UAE@XZ@4QBGB=__gfn_FTreeItemDtor")
#pragma comment(linker, "/alternatename:?__FUNC_NAME__@?2??LoadLocalizedMenu@@YAPAUHMENU__@@PAUHINSTANCE__@@HPBG1@Z@4QBGB=__gfn_LoadLocalizedMenu")

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(Window)

/*-----------------------------------------------------------------------------
	UWindowManager — Ravenshield-specific UObject.
	Only the autoclass pointer is exported; methods are internal.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UWindowManager)

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
void UWindowManager::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);
}

IMPL_MATCH("Window.dll", 0x11022780)
void UWindowManager::Destroy()
{
	Super::Destroy();
}

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
void UWindowManager::Tick(FLOAT DeltaTime)
{
	guard(UWindowManager::Tick);
	// Retail: advances the window manager's state each frame.
	// Divergence: not fully reconstructed from Ghidra.
	unguard;
}

/*-----------------------------------------------------------------------------
	Global variables — UT99 globals.
-----------------------------------------------------------------------------*/

WINDOW_API HBRUSH hBrushWhite     = NULL;
WINDOW_API HBRUSH hBrushOffWhite  = NULL;
WINDOW_API HBRUSH hBrushHeadline  = NULL;
WINDOW_API HBRUSH hBrushBlack     = NULL;
WINDOW_API HBRUSH hBrushStipple   = NULL;
WINDOW_API HBRUSH hBrushCurrent   = NULL;
WINDOW_API HBRUSH hBrushDark      = NULL;
WINDOW_API HBRUSH hBrushGrey      = NULL;
WINDOW_API HFONT  hFontText       = NULL;
WINDOW_API HFONT  hFontUrl        = NULL;
WINDOW_API HFONT  hFontHeadline   = NULL;
WINDOW_API WLog*  GLogWindow      = NULL;
WINDOW_API HINSTANCE hInstanceWindow = NULL;
WINDOW_API UBOOL  GNotify         = 0;
WINDOW_API UINT   WindowMessageOpen       = 0;
WINDOW_API UINT   WindowMessageMouseWheel = 0;
WINDOW_API NOTIFYICONDATA NID;
#if UNICODE
WINDOW_API NOTIFYICONDATAA NIDA;
#endif

/*-----------------------------------------------------------------------------
	Global variables — Ravenshield additions.
-----------------------------------------------------------------------------*/

WINDOW_API HBRUSH hBrushCyanHighlight = NULL;
WINDOW_API HBRUSH hBrushCyanLow      = NULL;
WINDOW_API HBRUSH hBrushDarkGrey     = NULL;
WINDOW_API HBRUSH hBrushGrey160      = NULL;
WINDOW_API HBRUSH hBrushGrey180      = NULL;
WINDOW_API HBRUSH hBrushGrey197      = NULL;
WINDOW_API HBRUSH hBrushGreyWindow   = NULL;

/*-----------------------------------------------------------------------------
	WWindow statics.
-----------------------------------------------------------------------------*/

INT              WWindow::ModalCount = 0;
TArray<WWindow*> WWindow::_Windows;
TArray<WWindow*> WWindow::_DeleteWindows;

/*-----------------------------------------------------------------------------
	WPropertiesBase helpers.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Window.dll", 0x110127e0)
FTreeItem* WPropertiesBase::GetListItem( INT i )
{
	guard(WProperties::GetListItem);
	FTreeItem* Result = (FTreeItem*)List.GetItemData(i);
	check(Result);
	return Result;
	unguard;
}

/*-----------------------------------------------------------------------------
	WNDPROC statics for DECLARE_WINDOWSUBCLASS classes.
	Each subclass that uses DECLARE_WINDOWSUBCLASS needs a static SuperProc.
-----------------------------------------------------------------------------*/

WNDPROC WButton::SuperProc       = NULL;
WNDPROC WEdit::SuperProc         = NULL;
WNDPROC WRichEdit::SuperProc     = NULL;
WNDPROC WListBox::SuperProc      = NULL;
WNDPROC WCheckListBox::SuperProc = NULL;
WNDPROC WComboBox::SuperProc     = NULL;
WNDPROC WScrollBar::SuperProc    = NULL;
WNDPROC WTreeView::SuperProc     = NULL;
WNDPROC WTabControl::SuperProc   = NULL;
WNDPROC WTrackBar::SuperProc     = NULL;
WNDPROC WProgressBar::SuperProc  = NULL;
WNDPROC WListView::SuperProc     = NULL;
WNDPROC WUrlButton::SuperProc    = NULL;
WNDPROC WLabel::SuperProc        = NULL;
WNDPROC WToolTip::SuperProc      = NULL;
WNDPROC WHeaderCtrl::SuperProc   = NULL;
// Additional UT99 subclasses that use DECLARE_WINDOWSUBCLASS.
WNDPROC WCheckBox::SuperProc     = NULL;
WNDPROC WCoolButton::SuperProc   = NULL;
WNDPROC WCustomLabel::SuperProc  = NULL;

/*-----------------------------------------------------------------------------
	Additional statics for DECLARE_WINDOWSUBCLASS classes.
-----------------------------------------------------------------------------*/

WNDPROC WVScrollBar::SuperProc    = NULL;

/*-----------------------------------------------------------------------------
	Other static members used by UT99 Window.h classes.
-----------------------------------------------------------------------------*/

WCoolButton* WCoolButton::GlobalCoolButton = NULL;
TArray<WProperties*> WProperties::PropertiesWindows;
// WPictureButton uses DECLARE_WINDOWCLASS (not SUBCLASS) in UT99 Window.h.
// R6 added SuperProc but we can't modify the existing class. The .def
// still exports it; the linker will emit a warning but the symbol is provided
// by the standalone global below, matching the retail mangled name.
// NOTE: Not byte-accurate as this is a global rather than a static member.

/*-----------------------------------------------------------------------------
	Shell_NotifyIconWX / SHGetSpecialFolderPathWX — Unicode helpers.
-----------------------------------------------------------------------------*/

#if UNICODE
WINDOW_API BOOL (WINAPI* Shell_NotifyIconWX)( DWORD dwMessage, PNOTIFYICONDATAW pnid ) = NULL;
WINDOW_API BOOL (WINAPI* SHGetSpecialFolderPathWX)( HWND hwndOwner, LPTSTR lpszPath, INT nFolder, BOOL fCreate ) = NULL;
#endif

/*-----------------------------------------------------------------------------
	FDelegate copy constructor (declared but not inline in Window.h).
-----------------------------------------------------------------------------*/

IMPL_MATCH("Window.dll", 0x11001300)
FDelegate::FDelegate(const FDelegate& Other)
: TargetObject(Other.TargetObject)
, TargetInvoke(Other.TargetInvoke)
{}

/*-----------------------------------------------------------------------------
	Global functions.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
WINDOW_API void InitWindowing()
{
	guard(InitWindowing);

	hInstanceWindow = hInstance;

	// Register "UnrealOpen" message for inter-process communication.
	WindowMessageOpen       = RegisterWindowMessageX( TEXT("UnrealOpen") );
	WindowMessageMouseWheel = RegisterWindowMessageX( TEXT("MSWHEEL_ROLLMSG") );

	// Load common controls.
	InitCommonControls();

	// Load RichEdit control library.
	static HINSTANCE hRichEdit = LoadLibraryX( TEXT("RICHED32.DLL") );
	if( !hRichEdit )
		hRichEdit = LoadLibraryX( TEXT("RICHED20.DLL") );

	// Unicode shell helpers.
#if UNICODE
	{
		HMODULE hModShell32 = GetModuleHandleA("SHELL32.DLL");
		if( hModShell32 )
		{
			*(FARPROC*)&Shell_NotifyIconWX       = GetProcAddress( hModShell32, "Shell_NotifyIconW" );
			*(FARPROC*)&SHGetSpecialFolderPathWX = GetProcAddress( hModShell32, "SHGetSpecialFolderPathW" );
		}
	}
#endif

	// Create standard brushes.
	hBrushWhite     = CreateSolidBrush( RGB(255,255,255) );
	hBrushOffWhite  = CreateSolidBrush( RGB(240,240,240) );
	hBrushHeadline  = CreateSolidBrush( RGB(  0, 60,120) );
	hBrushBlack     = CreateSolidBrush( RGB(  0,  0,  0) );
	hBrushDark      = CreateSolidBrush( RGB( 64, 64, 64) );
	hBrushGrey      = CreateSolidBrush( RGB(128,128,128) );
	hBrushCurrent   = CreateSolidBrush( RGB(  0,  0,128) );

	// Ravenshield additions.
	hBrushCyanHighlight = CreateSolidBrush( RGB(  0,255,255) );
	hBrushCyanLow       = CreateSolidBrush( RGB(  0,128,128) );
	hBrushDarkGrey      = CreateSolidBrush( RGB( 96, 96, 96) );
	hBrushGrey160       = CreateSolidBrush( RGB(160,160,160) );
	hBrushGrey180       = CreateSolidBrush( RGB(180,180,180) );
	hBrushGrey197       = CreateSolidBrush( RGB(197,197,197) );
	hBrushGreyWindow    = CreateSolidBrush( GetSysColor(COLOR_BTNFACE) );

	// Stipple brush.
	{
		WORD hatchBits[8] = { 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55 };
		HBITMAP hBmp = CreateBitmap( 8, 8, 1, 1, hatchBits );
		hBrushStipple = CreatePatternBrush( hBmp );
		DeleteObject( hBmp );
	}

	// Create standard fonts.
	hFontText     = CreateFont( -11, 0, 0, 0, FW_NORMAL, 0, 0, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("MS Sans Serif") );
	hFontUrl      = CreateFont( -11, 0, 0, 0, FW_NORMAL, 0, 1, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("MS Sans Serif") );
	hFontHeadline = CreateFont( -14, 0, 0, 0, FW_BOLD,   0, 0, 0, ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH, TEXT("MS Sans Serif") );

	unguard;
}

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
WINDOW_API HBITMAP LoadFileToBitmap( const TCHAR* Filename, INT& SizeX, INT& SizeY )
{
	guard(LoadFileToBitmap);
	TArray<BYTE> Data;
	if( appLoadFileToArray( Data, Filename ) )
	{
		// Create bitmap from BMP file data.
		BITMAPFILEHEADER* Header = (BITMAPFILEHEADER*)&Data(0);
		BITMAPINFO* Info = (BITMAPINFO*)(&Data(0) + sizeof(BITMAPFILEHEADER));
		if( Data.Num() > sizeof(BITMAPFILEHEADER) )
		{
			HDC hDC = GetDC(NULL);
			HBITMAP hBitmap = CreateDIBitmap(
				hDC,
				&Info->bmiHeader,
				CBM_INIT,
				&Data(0) + Header->bfOffBits,
				Info,
				DIB_RGB_COLORS
			);
			ReleaseDC( NULL, hDC );
			SizeX = Info->bmiHeader.biWidth;
			SizeY = Info->bmiHeader.biHeight;
			return hBitmap;
		}
	}
	SizeX = SizeY = 0;
	return NULL;
	unguard;
}
