//=============================================================================
//  R6WindowListMODS.uc : List of all MODS
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/20 * Created by Yannick Joly
//=============================================================================
class R6WindowListMODS extends R6WindowTextListBox;

// --- Enums ---
enum eItemState
{
	eIS_Normal,				// item was displaying without any attributes
	eIS_Disable,			// item was displaying but it was disabled
	eIS_Selected,			// this item was the selection in the list, highlight was apply on this item
	eIS_CurrentChoice		// this item was the current choice
};

// --- Variables ---
// color for current choice text (item)
var Color m_CurrentChoiceColor;

// --- Functions ---
function DrawItem(Canvas C, float Y, float H, float W, float X, UWindowList Item) {}
//=====================================================================================
// SetItemState: Set the item state, return true when succeed operation
//=====================================================================================
function bool SetItemState(UWindowListBoxItem _NewItem, optional bool _bForceSelection, eItemState _eISState) {}
// ^ NEW IN 1.60
function Paint(Canvas C, float fMouseX, float fMouseY) {}
//=====================================================================================
// FindCurrentMOD: Find item of the current MOD
//=====================================================================================
function UWindowList FindCurrentMOD() {}
// ^ NEW IN 1.60
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
//=====================================================================================
// ActivateMOD: Activate the current selection to be the current choice
//=====================================================================================
function ActivateMOD() {}
// For not rewrite the class R6WindowListBox with the new system of item properties, hack the value
// over here
function float GetSizeOfAnItem(UWindowList _pItem) {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
