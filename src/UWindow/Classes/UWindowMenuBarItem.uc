//=============================================================================
// UWindowMenuBarItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// UWindowMenuBarItem - An Unreal menu bar item
//=============================================================================
class UWindowMenuBarItem extends UWindowList;

var byte HotKey;
var bool bHelp;
var float ItemLeft;
var float ItemWidth;
var UWindowMenuBar Owner;
var UWindowPulldownMenu Menu;
var string Caption;

function SetHelp(bool B)
{
	bHelp = B;
	return;
}

function SetCaption(string C)
{
	local string Junk, Junk2;

	Caption = C;
	HotKey = Owner.ParseAmpersand(C, Junk, Junk2, false);
	return;
}

function UWindowPulldownMenu CreateMenu(Class<UWindowPulldownMenu> MenuClass)
{
	Menu = UWindowPulldownMenu(Owner.ParentWindow.CreateWindow(MenuClass, 0.0000000, 0.0000000, 100.0000000, 100.0000000));
	Menu.HideWindow();
	Menu.Owner = self;
	return Menu;
	return;
}

function DeSelect()
{
	Owner.LookAndFeel.PlayMenuSound(Owner, 1);
	Menu.DeSelect();
	Menu.HideWindow();
	return;
}

function Select()
{
	Owner.LookAndFeel.PlayMenuSound(Owner, 0);
	Menu.ShowWindow();
	Menu.WinLeft = (ItemLeft + Owner.WinLeft);
	Menu.WinTop = 14.0000000;
	Menu.WinWidth = 100.0000000;
	Menu.WinHeight = 100.0000000;
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

