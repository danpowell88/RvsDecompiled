//=============================================================================
//  R6MenuButtonsDefines.uc : This is the definiton of all the buttons and some function to create it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuButtonsDefines extends UWindowWindow;

// --- Enums ---
enum eButLocalizationExt
{
	eBLE_None,
	eBLE_DisableToolTip
};

// --- Structs ---
struct STButton
{
	var string		szButtonName;
	var string		szTip;
	var FLOAT		fWidth;
	var FLOAT		fHeight;
	var INT			iButtonID;
};

// --- Variables ---
// var ? fHeight; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? iButtonID; // REMOVED IN 1.60
// var ? szButtonName; // REMOVED IN 1.60
// var ? szTip; // REMOVED IN 1.60
var float m_fHeight;
// buttons parameters
var float m_fWidth;

// --- Functions ---
function SetButtonsSizes(float _fWidth, float _fHeight) {}
function string GetButtonLoc(optional eButLocalizationExt _eBLE, int _iButtonID, optional bool _bTip) {}
// ^ NEW IN 1.60
//===============================================================================================================
//
//===============================================================================================================
function AddCounterButton(STButton _stButton, R6WindowListGeneral _R6WindowListGeneral, int _iMinValue, int _iMaxValue, int _iDefaultValue, UWindowWindow _pParentWindow) {}
//===============================================================================================================
//
//===============================================================================================================
function AddCombo(STButton _stButton, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow) {}
function GetCounterTipLoc(out string _szLeftTip, out string _szRightTip, int _iButtonID) {}
function AddFakeButton(R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow) {}
// ^ NEW IN 1.60
//===============================================================================================================
//
//===============================================================================================================
function ChangeButtonComboValue(int _iButtonID, string _szNewValue, R6WindowListGeneral _pListToUse, optional bool _bDisabled) {}
//===============================================================================================================
//
//===============================================================================================================
function AddButtonBox(STButton _stButton, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow, bool _bSelected) {}
//===============================================================================================================
//
//===============================================================================================================
function AssociateButtons(R6WindowListGeneral _R6WindowListGeneral, int _iAssociateButCase, int _iButtonID2, int _iButtonID1) {}
function UWindowList FindButtonItem(R6WindowListGeneral _pListToUse, int _iButtonID) {}
// ^ NEW IN 1.60
//===============================================================================================================
// ChangeButtonBoxValue: Change the value of the button box
//===============================================================================================================
function ChangeButtonBoxValue(int _iButtonID, optional bool _bDisabled, R6WindowListGeneral _pListToUse, bool _bNewValue) {}
//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonBool(int _iButtonID, R6WindowListGeneral _R6WindowListGeneral, bool _bInitialValue, optional UWindowWindow _OwnerWindow) {}
//===============================================================================================================
//
//===============================================================================================================
function ChangeButtonCounterValue(int _iButtonID, int _iNewValue, R6WindowListGeneral _pListToUse, optional bool _bNotAcceptClick) {}
//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonInt(int _iButtonID, R6WindowListGeneral _R6WindowListGeneral, int _iMin, int _iMax, int _iInitialValue, optional UWindowWindow _OwnerWindow) {}
//===============================================================
// AddButtonCombo: Add a buttoncombo with item values in a list
//===============================================================
function AddButtonCombo(int _iButtonID, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow) {}
//===============================================================================================================
// SetButtonCounterUnlimited: set a counter button to use unlimited value
//===============================================================================================================
function SetButtonCounterUnlimited(int _iButtonID, bool _bUnlimitedCounterOnZero, R6WindowListGeneral _pListToUse) {}
//===============================================================================================================
//
//===============================================================================================================
function int GetButtonCounterValue(int _iButtonID, R6WindowListGeneral _pListToUse) {}
// ^ NEW IN 1.60
//===============================================================================================================
// GetButtonComboValue: get the value of the combo
//===============================================================================================================
function string GetButtonComboValue(int _iButtonID, R6WindowListGeneral _pListToUse) {}
// ^ NEW IN 1.60
//===============================================================================================================
//
//===============================================================================================================
function AddItemInComboButton(int _iButtonID, string _NewItem, string _SecondValue, R6WindowListGeneral _pListToUse) {}
//===============================================================================================================
// GetButtonBoxValue: Get the value of a button box
//===============================================================================================================
function bool GetButtonBoxValue(R6WindowListGeneral _pListToUse, int _iButtonID) {}
// ^ NEW IN 1.60
//===============================================================================================================
// IsButtonBoxDisabled: The button is disable?
//===============================================================================================================
function bool IsButtonBoxDisabled(R6WindowListGeneral _pListToUse, int _iButtonID) {}
// ^ NEW IN 1.60

defaultproperties
{
}
