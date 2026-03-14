//=============================================================================
// UWindowListBox - a listbox
//=============================================================================
class UWindowListBox extends UWindowListControl;

// --- Variables ---
var UWindowListBoxItem SelectedItem;
var UWindowVScrollbar VertSB;
var float ItemHeight;
var bool bDragging;
var float DragY;
var bool bCanDragExternal;
var bool bCanDrag;
// list to send items to on double-click
var UWindowListBox DoubleClickList;
var string DefaultHelpText;

// --- Functions ---
function DoubleClick(float X, float Y) {}
function SetHelpText(string t) {}
function DoubleClickItem(UWindowListBoxItem i) {}
function Paint(Canvas C, float MouseY, float MouseX) {}
function UWindowListBoxItem GetItemAt(float MouseY, float MouseX) {}
// ^ NEW IN 1.60
function bool ExternalDragOver(float Y, UWindowDialogControl ExternalControl, float X) {}
// ^ NEW IN 1.60
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function SetSelected(float X, float Y) {}
function LMouseDown(float Y, float X) {}
function ReceiveDoubleClickItem(UWindowListBoxItem i, UWindowListBox L) {}
function MakeSelectedVisible() {}
function MouseMove(float Y, float X) {}
function BeforePaint(float MouseY, float MouseX, Canvas C) {}
function Resized() {}
function Sort() {}
function Created() {}

defaultproperties
{
}
