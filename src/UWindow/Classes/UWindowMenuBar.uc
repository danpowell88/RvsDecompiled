//=============================================================================
// UWindowMenuBar - A menu bar
//=============================================================================
class UWindowMenuBar extends UWindowListControl;

// --- Variables ---
var UWindowMenuBarItem Selected;
var int Spacing;
var UWindowMenuBarItem Over;
var bool bAltDown;

// --- Functions ---
function bool HotKeyUp(int Key, float Y, float X) {}
// ^ NEW IN 1.60
function DrawMenuBar(Canvas C) {}
function MouseMove(float X, float Y) {}
function LMouseDown(float X, float Y) {}
function KeyDown(int Key, float Y, float X) {}
function Paint(Canvas C, float MouseY, float MouseX) {}
function MenuCmd(int Menu, int Item) {}
function UWindowMenuBarItem AddHelpItem(string Caption) {}
// ^ NEW IN 1.60
function ResolutionChanged(float W, float H) {}
function bool HotKeyDown(int Key, float Y, float X) {}
// ^ NEW IN 1.60
function UWindowMenuBarItem AddItem(string Caption) {}
// ^ NEW IN 1.60
function DrawItem(Canvas C, float X, float W, UWindowList Item, float Y, float H) {}
function UWindowMenuBar GetMenuBar() {}
// ^ NEW IN 1.60
function Close(optional bool bByParent) {}
function CloseUp() {}
function Select(UWindowMenuBarItem i) {}
function MouseLeave() {}
function Created() {}

defaultproperties
{
}
