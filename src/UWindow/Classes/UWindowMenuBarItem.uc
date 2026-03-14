//=============================================================================
// UWindowMenuBarItem - An Unreal menu bar item
//=============================================================================
class UWindowMenuBarItem extends UWindowList
    config;

// --- Variables ---
var UWindowPulldownMenu Menu;
var UWindowMenuBar Owner;
var float ItemLeft;
var bool bHelp;
var float ItemWidth;
var string Caption;
var byte HotKey;

// --- Functions ---
function UWindowPulldownMenu CreateMenu(class<UWindowPulldownMenu> MenuClass) {}
// ^ NEW IN 1.60
function SetHelp(bool B) {}
function SetCaption(string C) {}
function DeSelect() {}
function Select() {}
function CloseUp() {}
function UWindowMenuBar GetMenuBar() {}
// ^ NEW IN 1.60

defaultproperties
{
}
