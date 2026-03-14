// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowComboList extends UWindowListControl;

// --- Variables ---
var UWindowVScrollbar VertSB;
var UWindowComboControl Owner;
var UWindowComboListItem Selected;
var int ItemHeight;
var int MaxVisible;
var int HBorder;
var int VBorder;
var int TextBorder;

// --- Functions ---
// function ? SetupScrollBar(...); // REMOVED IN 1.60
function DrawMenuBackground(Canvas C) {}
function SetBorderColor(Color _NewColor) {}
function MouseWheelDown(float Y, float X) {}
function MouseWheelUp(float Y, float X) {}
function KeyDown(int Key, float Y, float X) {}
function ExecuteItem(UWindowComboListItem i) {}
function DrawItem(UWindowList Item, float H, float W, float Y, float X, Canvas C) {}
function LMouseUp(float Y, float X) {}
function Paint(Canvas C, float Y, float X) {}
//=================================================================================
// GetItem: Get the item with is Value
//=================================================================================
function UWindowComboListItem GetItem(string Value) {}
// ^ NEW IN 1.60
function SetSelected(float Y, float X) {}
function int FindItemIndex2(string Value2, optional bool bIgnoreCase) {}
// ^ NEW IN 1.60
function int FindItemIndex(string Value, optional bool bIgnoreCase) {}
// ^ NEW IN 1.60
function BeforePaint(Canvas C, float Y, float X) {}
//=================================================================================
// DisableAllItem: This fct disable all the items, but there still displaying
//=================================================================================
function DisableAllItems() {}
function string GetItemValue2(int Index) {}
// ^ NEW IN 1.60
function RemoveItem(int Index) {}
function string GetItemValue(int Index) {}
// ^ NEW IN 1.60
function AddItem(optional int SortWeight, optional string Value2, string Value) {}
function InsertItem(optional int SortWeight, optional string Value2, string Value) {}
function MouseMove(float Y, float X) {}
function FocusOtherWindow(UWindowWindow W) {}
function CloseUp() {}
function LMouseDown(float Y, float X) {}
function Created() {}
function Setup() {}
function Texture GetLookAndFeelTexture() {}
// ^ NEW IN 1.60
function Clear() {}
function WindowShown() {}
function Sort() {}

defaultproperties
{
}
