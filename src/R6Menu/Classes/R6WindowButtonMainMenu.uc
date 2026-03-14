//=============================================================================
//  R6WindowButtonMainMenu.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  This is the class for main men button
//  Because of it's fancy (Thanks to Adrian) look
//  It will not rely on the look and feel to display
//	And will be very specific
//
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6WindowButtonMainMenu extends UWindowButton;

// --- Enums ---
enum eButtonActionType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var Region m_OverAlphaRegion;
// ^ NEW IN 1.60
var Font m_buttonFont;
var eButtonActionType m_eButton_Action;
// ^ NEW IN 1.60
var Region m_OverScrollingRegion;
var float m_fProgressTime;
// ^ NEW IN 1.60
var int m_iTextRightPadding;
var int m_iMinXPos;
// ^ NEW IN 1.60
var int m_iTotalScroll;
var float m_fLMarge;
var Texture m_OverAlphaTexture;
// ^ NEW IN 1.60
var int m_iMaxXPos;
// ^ NEW IN 1.60
var float m_fFontSpacing;
var bool m_bResizeToText;
var Color m_DownTextColor;
var Texture m_OverScrollingTexture;
var float m_TextWidth;

// --- Functions ---
function Tick(float DeltaTime) {}
function Paint(Canvas C, float Y, float X) {}
function DrawButtonScrollEffect(Canvas C, Color currentDrawColor, int currentStyle) {}
simulated function Click(float X, float Y) {}
function DrawButtonText(Canvas C, Color currentTextColor, int currentStyle) {}
function DrawButtonBackGround(Canvas C, Color currentDrawColor, int currentStyle) {}
function BeforePaint(Canvas C, float Y, float X) {}
function ResizeToText() {}
function Created() {}

defaultproperties
{
}
