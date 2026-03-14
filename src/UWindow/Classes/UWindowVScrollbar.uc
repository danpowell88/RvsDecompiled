//=============================================================================
// UWindowVScrollBar - A vertical scrollbar
//=============================================================================
class UWindowVScrollbar extends UWindowWindow;

// --- Variables ---
// var ? Pos; // REMOVED IN 1.60
var float pos;
// ^ NEW IN 1.60
var float ThumbStart;
// ^ NEW IN 1.60
var float MaxPos;
var float MaxVisible;
var float NextClickTime;
var float ThumbHeight;
var UWindowSBUpButton UpButton;
var UWindowSBDownButton DownButton;
var bool bDisabled;
var float MinPos;
var float ScrollAmount;
var bool bDragging;
var float DragY;
var bool m_bHideSBWhenDisable;
//For look and feel effecs
var bool m_bUseSpecialEffect;

// --- Functions ---
function SetEffect(bool _effect) {}
function Paint(Canvas C, float X, float Y) {}
function MouseMove(float Y, float X) {}
function bool Scroll(float Delta) {}
// ^ NEW IN 1.60
function SetHideWhenDisable(bool _bHideWhenDisable) {}
function SetBorderColor(Color C) {}
function SetRange(optional float NewScrollAmount, float NewMaxVisible, float NewMaxPos, float NewMinPos) {}
function LMouseDown(float Y, float X) {}
function Tick(float Delta) {}
function Show(float P) {}
function CheckRange() {}
function Created() {}
function BeforePaint(Canvas C, float X, float Y) {}
function bool isHidden() {}
// ^ NEW IN 1.60
function MouseWheelDown(float X, float Y) {}
function MouseWheelUp(float X, float Y) {}

defaultproperties
{
}
