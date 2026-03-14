//=============================================================================
//  R6WindowListBox.uc : Base list-box control with R6-skinned corner styles.
//  Extends UWindowListControl and provides the foundation for all R6 list variants.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListBox extends UWindowListControl;

// --- Enums ---
enum eCornerType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var UWindowListBoxItem m_SelectedItem;
var R6WindowVScrollbar m_VertSB;
// the size of each item
var float m_fItemHeight;
// the number of items displayed on the window
var int m_iTotItemsDisplayed;
// the item X offset pos
var float m_fXItemOffset;
var bool m_bDragging;
// the space in between item
var float m_fSpaceBetItem;
// If you only want the code to determine selected elements
var bool m_bIgnoreUserClicks;
var float m_fDragY;
// force to capital letter in draw item
var bool m_bForceCaps;
var bool m_bActiveOverEffect;
var bool m_bCanDragExternal;
var bool m_bCanDrag;
var eCornerType m_eCornerType;
// ^ NEW IN 1.60
// the initial border color (use setbordercolor fct)
var Color m_vInitBorderColor;
// on double click send info to this specific client
var UWindowWindow m_DoubleClickClient;
// list to send items to on double-click
var R6WindowListBox m_DoubleClickList;
// Padding on the right of an item
var float m_fXItemRightPadding;
// where are the icon tex
var Texture m_TIcon;
var class<R6WindowVScrollbar> m_SBClass;
// the mouseover window border color
var Color m_vMouseOverWindow;
var string m_szDefaultHelpText;
var bool m_bSkipDrawBorders;

// --- Functions ---
function Created() {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function float GetSizeOfAnItem(UWindowList _pItem) {}
// ^ NEW IN 1.60
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
// overwrite UWindowWindow Mouse Leave
function MouseLeave() {}
function MouseMove(float Y, float X) {}
function SetCornerType(eCornerType _NewCornerType) {}
function DoubleClick(float Y, float X) {}
function MouseWheelDown(float Y, float X) {}
function MouseWheelUp(float Y, float X) {}
//=======================================================================================================
// GetCenterXPos: return the center pos of the region according the text size
//=======================================================================================================
function int GetCenterXPos(float _fTextWidth, float _fTagWidth) {}
// ^ NEW IN 1.60
//=======================================================================
// Set the border color
// Why use a fct for this, because we need to initialize the intial color too
// for mouveenter and mouse leave effect when you go on this window
//=======================================================================
function SetOverBorderColorEffect(Color _vBorderColor) {}
function DoubleClickItem(UWindowListBoxItem i) {}
function SetHelpText(string t) {}
//=======================================================================================================
// KeyDown: manage key down for list (movements in the list...)
//=======================================================================================================
function KeyDown(int Key, float Y, float X) {}
function UWindowListBoxItem GetItemAt(float fMouseY, float fMouseX) {}
// ^ NEW IN 1.60
//===================================================================================
// CheckForPrevItem: check for the prev valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPrevItem(UWindowListBoxItem _StartItem) {}
// ^ NEW IN 1.60
//===================================================================================
// CheckForNextItem: check for the next valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForNextItem(UWindowListBoxItem _StartItem) {}
// ^ NEW IN 1.60
//===================================================================================
// SwapItem: Move an item in the list, by default is to the next element.
//			 Restrictions: Can apply swap on disable/separator item
//===================================================================================
function bool SwapItem(UWindowListBoxItem _pItem, bool _bUp) {}
// ^ NEW IN 1.60
//===================================================================================
// CheckForPageUp: check for the next page up valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageUp(UWindowListBoxItem _StartItem) {}
// ^ NEW IN 1.60
//===================================================================================
// CheckForPageDown: check for the next page down valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageDown(UWindowListBoxItem _StartItem) {}
// ^ NEW IN 1.60
function bool ExternalDragOver(float Y, float X, UWindowDialogControl ExternalControl) {}
// ^ NEW IN 1.60
function MakeSelectedVisible() {}
//===================================================================================
// CheckForLastItem: check for the last valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForLastItem(UWindowListBoxItem _LastItem) {}
// ^ NEW IN 1.60
function SetSelected(float Y, float X) {}
function LMouseDown(float Y, float X) {}
function ReceiveDoubleClickItem(UWindowListBoxItem i, R6WindowListBox L) {}
//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox(Region _RIconRegion, float _fHeight, float _fWidth, float _fY, float _fX) {}
// ^ NEW IN 1.60
function Sort() {}
function float GetSizeOfList() {}
// ^ NEW IN 1.60
function Resized() {}
// overwrite UWindowWindow Mouse Enter
function MouseEnter() {}
function DropSelection() {}
//=======================================================================
// Get the selected item
// return None if no item was selected
//=======================================================================
function UWindowListBoxItem GetSelectedItem() {}
// ^ NEW IN 1.60
function Clear() {}
function KeyFocusExit() {}
function KeyFocusEnter() {}
//===================================================================================
// IsASeparatorItem: check if item have separator
//===================================================================================
function bool IsASeparatorItem() {}
// ^ NEW IN 1.60

defaultproperties
{
}
