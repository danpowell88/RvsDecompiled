//=============================================================================
//  R6WindowButtonAndEditBox.uc : This class works like its parent class,
//                                with The addition of a text edit box.
//                                Regular Text .... Edit Box .... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/23 * Created by John Bennett
//=============================================================================
class R6WindowButtonAndEditBox extends R6WindowButtonBox;

// --- Variables ---
                                // true if the player selected the button
var R6WindowEditControl m_pEditBox;
var string m_szEditTextHistory;

// --- Functions ---
function CreateEditBox(float fWidth) {}
function Paint(Canvas C, float X, float Y) {}
function SetEditBoxTip(string _szToolTip) {}
//====================================================================
// SetDisableButton: if the button is disable, set all the classes to disable -- ex. menu options in/out game
//====================================================================
function SetDisableButtonAndEditBox(bool _bDisable) {}

defaultproperties
{
}
