//=============================================================================
//  R6WindowTextLabel.uc : Simple text label with optional horizontal decorative border strip.
//  Extends UWindowWindow with a configurable text colour and skinned border region.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextLabel extends UWindowWindow;

// --- Variables ---
// var ? m_Drawstyle; // REMOVED IN 1.60
var Color TextColor;
var float m_fHBorderHeight;
// ^ NEW IN 1.60
var Region m_HBorderTextureRegion;
// ^ NEW IN 1.60
//Put = None when no background is needed
var Texture m_BGTexture;
var string Text;
var Font m_Font;
var TextAlign Align;
var Region m_BGTextureRegion;
var Region m_VBorderTextureRegion;
// ^ NEW IN 1.60
// Draw the borders?
var bool m_bDrawBorders;
var float m_fVBorderWidth;
// ^ NEW IN 1.60
var Texture m_HBorderTexture;
// ^ NEW IN 1.60
// Left Text Margin
var float m_fLMarge;
// use extremeties region (left and rigth arre the same)
var Region m_BGExtRegion;
var Texture m_VBorderTexture;
// ^ NEW IN 1.60
var float TextY;
// ^ NEW IN 1.60
var float m_fVBorderPadding;
// ^ NEW IN 1.60
var float TextX;
// ^ NEW IN 1.60
var float m_fHBorderPadding;
// ^ NEW IN 1.60
var int m_TextDrawstyle;
//To force the y pos of the text
var bool m_bFixedYPos;
// Space between characters
var float m_fFontSpacing;
var Color m_BGColor;
var bool m_bRefresh;
// Resize the window to the text
var bool m_bResizeToText;
// use extremeties region for the background with m_BGTextureRegion
var bool m_bUseExtRegion;
// Draw the backGround??
var bool m_bDrawBG;
// Color BG texture
var bool m_bUseBGColor;
var int m_DrawStyle;
// ^ NEW IN 1.60

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function SetProperties(bool _bDrawBorders, Color _TextColor, Font _TypeOfFont, TextAlign _Align, string _text) {}
/////////////////////////////////////////////////////////////////
// set a new text and update the position or not depending of _bRefresh
/////////////////////////////////////////////////////////////////
function SetNewText(bool _bRefresh, string _szNewText) {}
function BeforePaint(Canvas C, float X, float Y) {}

defaultproperties
{
}
