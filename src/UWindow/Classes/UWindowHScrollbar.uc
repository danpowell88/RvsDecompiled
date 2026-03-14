//=============================================================================
// UWindowHScrollBar - A horizontal scrollbar
//=============================================================================
class UWindowHScrollbar extends UWindowDialogControl;

// --- Variables ---
// var ? Pos; // REMOVED IN 1.60
var float ThumbStart;
// ^ NEW IN 1.60
var float pos;
// ^ NEW IN 1.60
var float ThumbWidth;
var float MaxVisible;
var float NextClickTime;
var float MaxPos;
var float MinPos;
var bool bDisabled;
var UWindowSBLeftButton LeftButton;
var UWindowSBRightButton RightButton;
var float ScrollAmount;
var bool bDragging;
var float DragX;
var Color m_NormalColor;
var Color m_SelectedColor;
var bool m_bHideSBWhenDisable;
// the ID of the scroll bar
var int m_iScrollBarID;

// --- Functions ---
function bool Scroll(float Delta) {}
// ^ NEW IN 1.60
function MouseMove(float X, float Y) {}
function SetRange(optional float NewScrollAmount, float NewMaxVisible, float NewMinPos, float NewMaxPos) {}
function Register(UWindowDialogClientWindow W) {}
function SetHideWhenDisable(bool _bHideWhenDisable) {}
function SetBorderColor(Color C) {}
function LMouseDown(float X, float Y) {}
function Paint(Canvas C, float Y, float X) {}
function Show(float P) {}
function Tick(float Delta) {}
function AdviceParent(bool _bMouseEnter) {}
function MouseLeave() {}
function MouseEnter() {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}
function CheckRange() {}

defaultproperties
{
}
