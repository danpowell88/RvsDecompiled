//=============================================================================
//  R6WindowButtonBox.uc : This class create a window with differents buttons region that
//                         you can specify and return to the parent a msg when a region is click
//                         Possibility to have a text in front and a tooltip associate with it
//                         Is like : TEXT ...... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================
class R6WindowButtonBox extends UWindowButton;

// --- Constants ---
const C_fWIDTH_OF_MSG_BOX =  90;

// --- Enums ---
enum eButtonBoxType
{
    BBT_Normal,         // seleted or not
    BBT_DeathCam,       // previous button have to change state (DeathCamera: swap state between button sel)
    BBT_ResKit          // Button used for restriction kit menu
};

// --- Variables ---
// true if the player selected the button
var bool m_bSelected;
var float m_fXBox;
// the region of the button background
var Region m_RButtonBG;
// the color of the button border
var Color m_vBorder;
// the text color (only one text color for all the buttons)
var Color m_vTextColor;
// the text font (only one text font for all the buttons)
var Font m_TextFont;
var float m_fYTextPos;
// to know if the mouse is on text or on the check box
var bool m_bMouseIsOver;
var float m_fYBox;
// the message box text
var string m_szMsgBoxText;
var float m_fXText;
var float m_fHMsgBoxText;
// the type of the button
var eButtonBoxType m_eButtonType;
// advice this window when a mouse wheel is down
var UWindowWindow m_AdviceWindow;
var bool m_bRefresh;
// to know is the mouse in on the window
var bool m_bMouseOnButton;
var bool m_bAutomaticResizeFont;
// ^ NEW IN 1.60
// Resize the button to the box + text size
var bool m_bResizeToText;
// force to display a disable tooltip
var string m_szToolTipWhenDisable;
var float m_fXMsgBoxText;
/////// we can find this in the R6WindowLookAndFeel
// the texture button
var Texture m_TButtonBG;
// use to store any information useful for treatment
var string m_szMiscText;
var Texture m_TDownTexture;

// --- Functions ---
// draw all the button
function Paint(Canvas C, float Y, float X) {}
//===============================================================
// SetNewWidth: set the new width of the button
//===============================================================
function SetNewWidth(float _fWidth) {}
function bool InRange(float _fTestValue, float _fMin, float _fMax) {}
// ^ NEW IN 1.60
//*********************************
//      DISPLAY FUNCTIONS
//*********************************
function BeforePaint(Canvas C, float Y, float X) {}
//*********************************
//      CHECK
//*********************************
function bool CheckText_Box_Region() {}
// ^ NEW IN 1.60
function DrawResKitBotton(Canvas C, float _fXBox, bool _bMouseOverButton, float _fYBox) {}
function float AlignText(out string _szTextToAlign, float _fXStartPos, Canvas C, float _fWidth, TextAlign _eTextAlign) {}
// ^ NEW IN 1.60
//*********************************
//      Create the button
//*********************************
function CreateTextAndBox(string _szText, string _szToolTip, float _fXText, int _iButtonID, optional bool _bTextAfterBox, optional bool _bUseAutomaticResizeFont) {}
function CreateTextAndMsgBox(string _szText, string _szToolTip, string _szTextBox, float _fXText, int _iButtonID) {}
function DrawCheckBox(Canvas C, float _fYBox, float _fXBox, bool _bMouseOverButton) {}
//=============================================================================
// ModifyMsgBox: Modify the text inside the msg box depending if you're are in-game or not
//=============================================================================
function ModifyMsgBox(string _szTextBox) {}
//=============================================================================
// SetButtonBox: Set the regular param for this type of button,
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetButtonBox(bool _bSelected) {}
//=======================================================================================
// MouseWheelDown: advice a window of your choice for mouse wheel down
//=======================================================================================
function MouseWheelDown(float X, float Y) {}
//=======================================================================================
// MouseWheelUp: advice a window of your choice for mouse wheel up
//=======================================================================================
function MouseWheelUp(float X, float Y) {}
simulated function Click(float Y, float X) {}
//*********************************
//      Get the selected status (change where you create the button by Notify)
//*********************************
function bool GetSelectStatus() {}
// ^ NEW IN 1.60
// overwrite uwindowwindow fct
function MouseLeave() {}
//*********************************
//      MOUSE FUNCTIONS OVERLOADED
//*********************************
// Why overwrite this 2 functions, because the tooltip have to be on the text or the check box only
// not on all the window. We force it in Paint()
// overwrite uwindowwindow fct
function MouseEnter() {}

defaultproperties
{
}
