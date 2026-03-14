//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class UWindowListControl extends UWindowDialogControl;

// --- Variables ---
var UWindowList Items;
var class<UWindowList> ListClass;

// --- Functions ---
function Created() {}
function DrawItem(float H, float W, float Y, float X, UWindowList Item, Canvas C) {}
function UWindowList GetItemAtIndex(int _iIndex) {}
// ^ NEW IN 1.60
function ClearListOfItems() {}
function UWindowList GetNextItem(UWindowList prevItem, int _iIndex) {}
// ^ NEW IN 1.60

defaultproperties
{
}
