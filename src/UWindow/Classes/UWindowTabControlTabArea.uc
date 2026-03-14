// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowTabControlTabArea extends UWindowWindow;

// --- Enums ---
enum eTabCase
{
    eTab_Left,
    eTab_Middle,
    eTab_Right,
    eTab_Left_RightCut,
    eTab_Middle_RightCut
};

// --- Variables ---
var int TabOffset;
var int TabRows;
var UWindowTabControlItem FirstShown;
var eTabCase m_eTabCase;
var bool bFlashShown;
var UWindowTabControlItem DragTab;
var bool bDragging;
var bool bShowSelected;
var float UnFlashTime;
var int m_iTotalTab;
var Color m_vEffectColor;
// display a tool tip for a item
var bool m_bDisplayToolTip;
var config globalconfig bool bArrangeRowsLikeTimHates;

// --- Functions ---
function bool CheckMousePassThrough(float Y, float X) {}
// ^ NEW IN 1.60
function LayoutTabs(Canvas C) {}
function SizeTabsMultiLine(Canvas C) {}
function SizeTabsSingleLine(Canvas C) {}
//===================================================================
// check if the mouse is over an item
//===================================================================
function UWindowTabControlItem CheckMouseOverOnItem(float _fY, float _fX) {}
// ^ NEW IN 1.60
function Paint(Canvas C, float X, float Y) {}
function LMouseDown(float X, float Y) {}
function RMouseDown(float X, float Y) {}
//===================================================================
// draw the tab-item
//===================================================================
function DrawItem(UWindowList Item, bool bShowText, float H, float W, float Y, float X, Canvas C) {}
function MouseMove(float X, float Y) {}
//===================================================================
// put all the mouseoveritem bool at false
//===================================================================
function ResetMouseOverOnItem() {}
//===================================================================
// check if the mouse is over an item and display a tool tip when is required
//===================================================================
function CheckToolTip(float _fY, float _fX) {}
function Created() {}
function MouseLeave() {}

defaultproperties
{
}
