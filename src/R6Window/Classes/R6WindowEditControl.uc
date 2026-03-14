//=============================================================================
//  R6WindowEditControl.uc : Labeled text-entry control with optional custom paint and disabled state.
//  Composes an R6WindowTextLabel alongside UWindowEditControl for form-style input fields.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowEditControl extends UWindowEditControl;

// --- Variables ---
var R6WindowTextLabel m_pTextLabel;
// use this special paint
var bool m_bUseSpecialPaint;
// true, the control is disable
var bool m_bDisabled;

// --- Functions ---
//====================================================================
// SetEditBoxTip: set the tooltipstring, this string is return to the parent window when the mouse is over the edit box
//====================================================================
function SetEditBoxTip(string _szToolTip) {}
function CreateTextLabel(string _szTitle, float _fX, float _fY, float _fWidth, float _fHeight) {}
function ModifyEditBoxW(float _fX, float _fY, float _fWidth, float _fHeight) {}
function ForceCaps(bool choice) {}
function Paint(Canvas C, float X, float Y) {}
//=======================================================================================================
//=======================================================================================================
// DISPLAY
function BeforePaint(Canvas C, float X, float Y) {}
//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetEditControlStatus(bool _bDisable) {}
function Created() {}

defaultproperties
{
}
