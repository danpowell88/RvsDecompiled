//=============================================================================
//  R6WindowButtonExt.uc : This class give the following type of button... 
//						   DESC TEXT                 BOX desc BOX desc BOX desc
//						   minimum of 1 box and max of 3
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonExt extends UWindowButton;

// --- Structs ---
struct CheckBox
{
	var string	szText;
	var FLOAT	fXBoxPos;
	var bool    bSelected;
	var INT		iIndex;
};

// --- Variables ---
// var ? bSelected; // REMOVED IN 1.60
// var ? fXBoxPos; // REMOVED IN 1.60
// var ? iIndex; // REMOVED IN 1.60
// var ? m_pButtonBox1; // REMOVED IN 1.60
// var ? m_pButtonBox2; // REMOVED IN 1.60
// var ? m_pButtonBox3; // REMOVED IN 1.60
// var ? m_pCurrentSelection; // REMOVED IN 1.60
// var ? m_pParent; // REMOVED IN 1.60
// var ? m_pTextLabel; // REMOVED IN 1.60
// var ? szText; // REMOVED IN 1.60
var CheckBox m_stCheckBox[3];
// the region of the button background
var Region m_RButtonBG;
// the text color (only one text color for all the buttons)
var Color m_vTextColor;
// to know if the mouse is on text or on the check box
var bool m_bMouseIsOver;
var float m_fYTextPos;
var int m_iCurSelectedBox;
// the color of the button border
var Color m_vBorder;
// the number of check box for this button
var int m_iNumberOfCheckBox;
// the check box over index
var int m_iCheckBoxOver;
// to know is the mouse in on the window
var bool m_bMouseOnButton;
var float m_fYBox;
// the text font (only one text font for all the buttons)
var Font m_TextFont;
var float m_fXText;
var bool m_bOneTime;
/////// we can find this in the R6WindowLookAndFeel
// the texture button
var Texture m_TButtonBG;
// true if the player selected the button
var bool m_bSelected;
var float m_fTextWidth;
var Texture m_TDownTexture;

// --- Functions ---
// function ? CreatedMultipleButtons(...); // REMOVED IN 1.60
// function ? Notify(...); // REMOVED IN 1.60
//===============================================
// SetCheckBoxStatus: Change the check box status depending the state in .ini
//					  this function is specific, the selected state is store in int,
//					  so we have to switch to a bool before displaying it
//===============================================
function SetCheckBoxStatus(int _iSelected) {}
function bool InRange(float _fTestValue, float _fMax, float _fMin) {}
// ^ NEW IN 1.60
//=================================
//      DISPLAY FUNCTIONS
//=================================
function BeforePaint(Canvas C, float Y, float X) {}
// draw all the button
function Paint(Canvas C, float Y, float X) {}
function DrawCheckBox(Canvas C, bool _bMouseOverButton) {}
//*********************************
//      CHECK
//*********************************
function bool CheckText_Box_Region() {}
// ^ NEW IN 1.60
//*********************************
//      Create the button
//*********************************
function CreateTextAndBox(int _iNumberOfCheckBox, int _iButtonID, float _fXText, string _szToolTip, string _szText) {}
//=============================================================================
// SetButtonBox: Set the regular param for this type of button,
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetCheckBox(int _iIndex, bool _bSelected, float _fXBoxPos, string _szText) {}
// overwrite uwindowwindow fct
function MouseLeave() {}
//*********************************
//      MOUSE FUNCTIONS OVERLOADED
//*********************************
// Why overwrite this 2 functions, because the tooltip have to be on the text or the check box only
// not on all the window. We force it in Paint()
// overwrite uwindowwindow fct
function MouseEnter() {}
//*********************************
//      Get the selected status (change where you create the button by Notify)
//*********************************
function bool GetSelectStatus() {}
// ^ NEW IN 1.60
//===============================================
// Change the check box status
//===============================================
function ChangeCheckBoxStatus() {}
//===============================================
// GetCheckBoxStatus: Return the selected button index
//===============================================
function int GetCheckBoxStatus() {}
// ^ NEW IN 1.60

defaultproperties
{
}
