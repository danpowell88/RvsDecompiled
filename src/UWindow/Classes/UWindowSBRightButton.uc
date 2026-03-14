//=============================================================================
// UWindowSBRightButton - Scrollbar right button
//=============================================================================
class UWindowSBRightButton extends UWindowButton;

// --- Variables ---
var float NextClickTime;
var bool m_bHideSBWhenDisable;

// --- Functions ---
// function ? BeforePaint(...); // REMOVED IN 1.60
function LMouseDown(float Y, float X) {}
function Paint(float Y, float X, Canvas C) {}
function MouseEnter() {}
function MouseLeave() {}
function Tick(float Delta) {}
function Created() {}

defaultproperties
{
}
