//=============================================================================
//  R6WindowButton.uc : Ravenshield-styled push button control.
//  Extends UWindowButton with R6's typed button variants and look-and-feel skin.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowButton extends UWindowButton;

// --- Enums ---
enum eButtonType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var Color m_vButtonColor;
var Font m_buttonFont;
var bool m_bDrawBorders;
var int m_iDrawStyle;
//Usefull for text aligned left or to keep space at left of the text when we resize button to text
var float m_fLMarge;
var float m_fFontSpacing;
// Use to set the param in before paint one time
var bool m_bSetParam;
var bool m_bResizeToText;
//Font to downsize to if text doesn't fit
var Font m_DownSizeFont;
//Usefull for text aligned right or to keep space at right of the text when we resize button to text
var float m_fRMarge;
// When we ask a button to resize make sure he doesn't grow to big
var float m_fMaxWinWidth;
var eButtonType m_eButtonType;
// ^ NEW IN 1.60
var bool m_bDrawSimpleBorder;
//Switch to m_DownSizeFont is text doesn't fit the button
var bool m_bCheckForDownSizeFont;
// the button that store size of all buttons
var R6WindowButton m_pRefButtonPos;
var float m_fDownSizeFontSpacing;
var float m_textSize;
// this work with previous button pos
var float m_fTotalButtonsSize;
// When we ask for resize text with different text size and the align is not TA_left, use org winleft
var float m_fOrgWinLeft;
var bool m_bDefineBorderColor;
var bool m_bDrawSpecialBorder;
// The background texture when you selected the button
var Texture m_BGSelecTexture;
// If we have a previous button pos to positioning your current button
var R6WindowButton m_pPreviousButtonPos;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function SetButtonBorderColor(Color _vButtonBorderColor) {}
//This function Allow a button to to change to a fall back
//Font if the current text doesn't fit in it's size;
function CheckToDownSizeFont(Font _FallBackFont, float _FallBackFontSpacing) {}
function BeforePaint(Canvas C, float Y, float X) {}
//===========================================================================================================
// This function indicate if text fits in the button width
//===========================================================================================================
function bool IsFontDownSizingNeeded() {}
// ^ NEW IN 1.60
function int GetButtonType() {}
// ^ NEW IN 1.60
function ResizeToText() {}
function Created() {}

defaultproperties
{
}
