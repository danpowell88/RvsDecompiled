//=============================================================================
// UWindowPulldownMenu
//=============================================================================
class UWindowPulldownMenu extends UWindowListControl;

#exec TEXTURE IMPORT NAME=MenuTick FILE=Textures\MenuTick.bmp GROUP="Icons" FLAGS=2 MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuDivider FILE=Textures\MenuDivider.bmp GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=MenuSubArrow FILE=Textures\MenuSubArrow.bmp GROUP="Icons" FLAGS=2 MIPS=OFF

// --- Variables ---
var UWindowPulldownMenuItem Selected;
// Owner is either a UWindowMenuBarItem or UWindowPulldownMenuItem
var UWindowList Owner;
var int HBorder;
var int VBorder;
var int ItemHeight;
var int TextBorder;

// --- Functions ---
function Created() {}
function CloseUp(optional bool bByOwner) {}
function DrawMenuBackground(Canvas C) {}
function LMouseUp(float X, float Y) {}
function SetSelected(float Y, float X) {}
function MouseMove(float X, float Y) {}
function DrawItem(UWindowList Item, Canvas C, float X, float Y, float W, float H) {}
function KeyDown(int Key, float Y, float X) {}
function KeyUp(int Key, float Y, float X) {}
function MenuCmd(int Item) {}
function BeforePaint(Canvas C, float Y, float X) {}
function PerformSelect(UWindowPulldownMenuItem NewSelected) {}
function Paint(Canvas C, float Y, float X) {}
// External functions
function UWindowPulldownMenuItem AddMenuItem(string C, Texture G) {}
// ^ NEW IN 1.60
function FocusOtherWindow(UWindowWindow W) {}
function UWindowMenuBar GetMenuBar() {}
// ^ NEW IN 1.60
function ExecuteItem(UWindowPulldownMenuItem i) {}
function BeforeExecuteItem(UWindowPulldownMenuItem i) {}
function LMouseDown(float Y, float X) {}
function ShowWindow() {}
function Select(UWindowPulldownMenuItem i) {}
function DeSelect() {}
function Clear() {}

defaultproperties
{
}
