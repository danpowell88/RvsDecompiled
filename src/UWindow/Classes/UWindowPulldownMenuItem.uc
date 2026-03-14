//=============================================================================
// UWindowPulldownMenuItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowPulldownMenuItem
//=============================================================================
class UWindowPulldownMenuItem extends UWindowList;

var byte HotKey;
var bool bChecked;
var bool bDisabled;
var float ItemTop;
var Texture Graphic;
var UWindowPulldownMenu SubMenu;
var UWindowPulldownMenu Owner;
var string Caption;

function UWindowPulldownMenu CreateSubMenu(Class<UWindowPulldownMenu> MenuClass, optional UWindowWindow InOwnerWindow)
{
	SubMenu = UWindowPulldownMenu(Owner.ParentWindow.CreateWindow(MenuClass, 0.0000000, 0.0000000, 100.0000000, 100.0000000, InOwnerWindow));
	SubMenu.HideWindow();
	SubMenu.Owner = self;
	return SubMenu;
	return;
}

function Select()
{
	// End:0x7F
	if(__NFUN_119__(SubMenu, none))
	{
		SubMenu.WinLeft = __NFUN_175__(__NFUN_174__(Owner.WinLeft, Owner.WinWidth), float(Owner.HBorder));
		SubMenu.WinTop = __NFUN_175__(ItemTop, float(Owner.VBorder));
		SubMenu.ShowWindow();
	}
	return;
}

function SetCaption(string C)
{
	local string Junk, Junk2;

	Caption = C;
	HotKey = Owner.ParseAmpersand(C, Junk, Junk2, false);
	return;
}

function DeSelect()
{
	// End:0x29
	if(__NFUN_119__(SubMenu, none))
	{
		SubMenu.DeSelect();
		SubMenu.HideWindow();
	}
	return;
}

function CloseUp()
{
	Owner.CloseUp();
	return;
}

function UWindowMenuBar GetMenuBar()
{
	return Owner.GetMenuBar();
	return;
}

