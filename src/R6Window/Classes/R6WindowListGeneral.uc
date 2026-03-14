//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class R6WindowListGeneral extends UWindowListControl;

// --- Variables ---
var float m_fItemWidth;
var float m_fItemHeight;
var float m_fStepBetweenItem;

// --- Functions ---
function DrawItem(float H, float Y, float X, UWindowList Item, Canvas C, float W) {}
function ChangeVisualItems(bool _bVisible) {}
function RemoveAllItems() {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
