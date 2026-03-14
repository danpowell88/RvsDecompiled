//=============================================================================
// UWindowDialogControl - a control which notifies a dialog control group
//=============================================================================
class UWindowDialogControl extends UWindowWindow;

// --- Variables ---
var Color TextColor;
var float TextX;
// ^ NEW IN 1.60
var string Text;
var int Font;
// changed by BeforePaint functions
var float TextY;
var UWindowDialogControl TabNext;
var bool bNoKeyboard;
var bool bHasKeyboardFocus;
var TextAlign Align;
var UWindowDialogClientWindow NotifyWindow;
var string HelpText;
var UWindowDialogControl TabPrev;
var bool bAcceptExternalDragDrop;
var float MinWidth;
// ^ NEW IN 1.60
// minimum heights for layout control
var float MinHeight;

// --- Functions ---
function BeforePaint(Canvas C, float X, float Y) {}
function Created() {}
function MouseLeave() {}
function MouseMove(float X, float Y) {}
function MouseEnter() {}
function KeyDown(int Key, float X, float Y) {}
function SetFont(int NewFont) {}
function Notify(byte E) {}
function KeyFocusEnter() {}
function KeyFocusExit() {}
function SetHelpText(string NewHelpText) {}
function Register(UWindowDialogClientWindow W) {}
function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y) {}
// ^ NEW IN 1.60
function SetTextColor(Color NewColor) {}
function SetText(string NewText) {}
function UWindowDialogControl CheckExternalDrag(float Y, float X) {}
// ^ NEW IN 1.60

defaultproperties
{
}
