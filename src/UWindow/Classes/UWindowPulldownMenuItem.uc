//=============================================================================
// UWindowPulldownMenuItem
//=============================================================================
class UWindowPulldownMenuItem extends UWindowList;

// --- Variables ---
var UWindowPulldownMenu SubMenu;
var UWindowPulldownMenu Owner;
var string Caption;
var bool bDisabled;
var byte HotKey;
var float ItemTop;
var Texture Graphic;
var bool bChecked;

// --- Functions ---
function UWindowPulldownMenu CreateSubMenu(class<UWindowPulldownMenu> MenuClass, optional UWindowWindow InOwnerWindow) {}
// ^ NEW IN 1.60
function SetCaption(string C) {}
function Select() {}
function DeSelect() {}
function CloseUp() {}
function UWindowMenuBar GetMenuBar() {}
// ^ NEW IN 1.60

defaultproperties
{
}
