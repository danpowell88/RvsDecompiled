// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UWindow.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class UWindowComboControl extends UWindowDialogControl;

// --- Variables ---
var UWindowComboList List;
var UWindowEditBox EditBox;
var UWindowComboButton Button;
var bool bListVisible;
var float EditBoxWidth;
var float EditAreaDrawX;
// ^ NEW IN 1.60
var UWindowComboLeftButton LeftButton;
var UWindowComboRightButton RightButton;
var bool bCanEdit;
var bool m_bSelectedByUser;
var bool bButtons;
var bool m_bDisabled;
var class<UWindowComboList> ListClass;
var float EditAreaDrawY;

// --- Functions ---
// get an item, none if not exist
function UWindowComboListItem GetItem(string S) {}
// ^ NEW IN 1.60
function InsertItem(string S, optional string S2, optional int SortWeight) {}
function AddItem(string S, optional string S2, optional int SortWeight) {}
function Paint(Canvas C, float Y, float X) {}
function SetMaxLength(int MaxLength) {}
function SetValue(string NewValue, optional string NewValue2) {}
function BeforePaint(Canvas C, float X, float Y) {}
function SetEditable(bool bNewCanEdit) {}
function SetSelectedIndex(int Index) {}
function SetEditTextColor(Color NewColor) {}
function SetFont(int NewFont) {}
function Close(optional bool bByParent) {}
function Notify(byte E) {}
function SetButtons(bool bInButtons) {}
function SetNumericFloat(bool bNumericFloat) {}
function SetNumericOnly(bool bNumericOnly) {}
function int FindItemIndex2(string v2, optional bool bIgnoreCase) {}
// ^ NEW IN 1.60
function RemoveItem(int Index) {}
function int FindItemIndex(optional bool bIgnoreCase, string V) {}
// ^ NEW IN 1.60
function FocusOtherWindow(UWindowWindow W) {}
function Clear() {}
function ClearValue() {}
function Sort() {}
function DropDown() {}
function CloseUp() {}
// Disable all the item on the list, still displaying
function DisableAllItems() {}
function string GetValue2() {}
// ^ NEW IN 1.60
function string GetValue() {}
// ^ NEW IN 1.60
function int GetSelectedIndex() {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
