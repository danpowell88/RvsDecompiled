//=============================================================================
//  R6WindowCounter.uc : This class permit to create a window with a - and + button
//                       and display the counter in the middle
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//  16/04/2002 Created by Yannick Joly
//=============================================================================
class R6WindowCounter extends UWindowDialogClientWindow;

// --- Constants ---
const C_fBUTTONS_CHECK_TIME =  1;

// --- Enums ---
enum eAssociateButCase
{
	EABC_Down,
	EABC_Up
};

// --- Variables ---
// the Counter
var int m_iCounter;
// the adding button
var R6WindowButton m_pPlusButton;
// the substract button
var R6WindowButton m_pSubButton;
// display the number of the counter
var R6WindowTextLabel m_pNbOfCounter;
// display the info text
var R6WindowTextLabel m_pTextInfo;
// the associate button, perform and action with this button
var R6WindowCounter m_pAssociateButton;
// the +/- buttons are pressed
var bool m_bButPressed;
// The minimum for the counter
var int m_iMinCounter;
// timer
var float m_fTimeCheckBut;
// advice the parent window (for tool tip effect and stuff like that)
var bool m_bAdviceParent;
// the -/+ step that each time you press the button
var int m_iStepCounter;
// The maximum for the counter
var int m_iMaxCounter;
// the time to wait, by default C_fBUTTONS_CHECK_TIME
var float m_fTimeToWait;
// this counter is unlimited when the value is 0
var bool m_bUnlimitedCounterOnZero;
var int m_iAssociateButCase;
// this is a fake button.
var bool m_bNotAcceptClick;
var int m_iButtonID;

// --- Functions ---
//===============================================================
// advice parent window that you are on one of the button
//===============================================================
function SetAdviceParent(bool _bAdviceParent) {}
//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip(string _szLeftToolTip, string _szRightToolTip) {}
//===============================================================
// Set the text label param
//===============================================================
function SetLabelText(string _szText, Font _TextFont, Color _vTextColor) {}
//===============================================================
// Create the text label window
//===============================================================
function CreateLabelText(float _fX, float _fY, float _fWidth, float _fHeight) {}
//===============================================================
// set the counter values, min max and default
//===============================================================
function SetDefaultValues(int _iDefaultValue, int _iMin, int _iMax) {}
function SetCounterValue(int _iNewValue) {}
function bool CheckValueForUnlimitedCounter(int _iValue, bool _bDefaultValue) {}
// ^ NEW IN 1.60
//=============================================================
// Tick: check for mousedown on +/- buttons and simulate click on thoses buttons to +/- the counter
//=============================================================
function Tick(float DeltaTime) {}
//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons(float _fX, float _fY, float _fSizeOfCounter) {}
//=============================================================
// IsMouseDown: Check if the +/- buttons are pressed ant the player keep the mouse cursor on it
//=============================================================
function bool IsMouseDown(UWindowDialogControl _pButton) {}
// ^ NEW IN 1.60
function bool CheckSubButton() {}
// ^ NEW IN 1.60
function int CheckValue(int _iValue) {}
// ^ NEW IN 1.60
//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(byte E, UWindowDialogControl C) {}
function bool CheckAddButton() {}
// ^ NEW IN 1.60

defaultproperties
{
}
