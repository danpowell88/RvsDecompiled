//=============================================================================
//  R6WindowComboControl.uc : A combo box with or without a text left of the combo box
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2002/07/23 * Modifications by Yannick Joly
//=============================================================================
class R6WindowComboControl extends UWindowComboControl;

// --- Variables ---
// the text of the combo
var R6WindowTextLabel m_pComboTextLabel;
var int m_iButtonID;

// --- Functions ---
function Created() {}
//===========================================================================================
// AdjustEditBoxW: Adjust the edit box window in the combocontrol -- the edit box is place at the end of the combo control
//===========================================================================================
function AdjustEditBoxW(float _fWidth, float _fHeight, float _fY) {}
//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButton(bool _bDisable) {}
//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip(string _szToolTip) {}
//===========================================================================================
// AdjustTextW: Adjust the text window in the combocontrol
//===========================================================================================
function AdjustTextW(float _fHeight, float _fWidth, float _fY, float _fX, string _szTitle) {}
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
