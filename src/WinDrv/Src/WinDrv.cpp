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
