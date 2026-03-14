//=============================================================================
//  R6WindowTextLabelExt.uc : An array of textlabel with each individual parameters
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================
class R6WindowTextLabelExt extends R6WindowSimpleFramedWindowExt;

// --- Constants ---
const iNumberOfLabelMax =  20;
const C_iMAX_SIZE_OF_TEXT_LABEL =  596;

// --- Structs ---
struct TextLabel
{
    var Font      TextFont;
    var Color     TextColorFont;
    var string    m_szTextLabel;
    var FLOAT     X;
    var FLOAT     XTextPos;
    var FLOAT     Y;
    var FLOAT     fWidth;
	var FLOAT     fHeight;
    var FLOAT     fXLine;
    var TextAlign Align;
    var bool      bDrawLineAtEnd;
    var bool      bUpDownBG;
	var BOOL	  bResizeToText;
};

// --- Variables ---
// var ? TextColorFont; // REMOVED IN 1.60
// var ? TextFont; // REMOVED IN 1.60
// var ? X; // REMOVED IN 1.60
// var ? XTextPos; // REMOVED IN 1.60
// var ? Y; // REMOVED IN 1.60
// var ? bDrawLineAtEnd; // REMOVED IN 1.60
// var ? bResizeToText; // REMOVED IN 1.60
// var ? bUpDownBG; // REMOVED IN 1.60
// var ? fHeight; // REMOVED IN 1.60
// var ? fWidth; // REMOVED IN 1.60
// var ? fXLine; // REMOVED IN 1.60
// var ? m_Drawstyle; // REMOVED IN 1.60
// var ? m_szTextLabel; // REMOVED IN 1.60
var TextLabel m_sTextLabelArray[20];
var int m_iNumberOfLabel;
var Color m_vTextColor;
var Font m_Font;
var bool m_bRefresh;
// center the text to the center of the window
var bool m_bTextCenterToWindow;
var Color m_vLineColor;
var bool m_bCheckToDrawLine;
var int m_TextDrawstyle;
// OffSet for the draw line after text
var float m_fYLineOffset;
// Space between characters
var float m_fFontSpacing;
// set to true if you want a background of editbox type behind your text
var bool m_bUpDownBG;
var int m_DrawStyle;
// ^ NEW IN 1.60
// Left Text Margin
var float m_fLMarge;
var string Text;
var TextAlign Align;
var float m_fTextX;
// ^ NEW IN 1.60
var float m_fTextY;
// ^ NEW IN 1.60
// Put = None when no background is needed
var Texture m_BGTexture;

// --- Functions ---
//===============================================================================
// According the index value, change the string. No check was done is the index is valid or not
//===============================================================================
function ChangeTextLabel(int _iIndex, string _szNewStringLabel) {}
//===============================================================================
// According the index value, change the color of the font. No check was done is the index is valid or not
//===============================================================================
function ChangeColorLabel(int _iIndex, Color _vNewColorText) {}
function string GetTextLabel(int _iIndex) {}
// ^ NEW IN 1.60
function Color GetTextColor(int _iIndex) {}
// ^ NEW IN 1.60
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float Y, float X) {}
//===============================================================================
// DrawUpDownBG: Draw the editbox background effect under the text if the bUpDownBG is true
//===============================================================================
function DrawUpDownBG(Canvas C, float _fH, float _fW, float _fY, float _fX) {}
// use at create only
function int AddTextLabel(optional float _fHeight, float _X, optional bool _bResizeToText, bool _bDrawLineAtEnd, TextAlign _Align, float _fWidth, float _Y, string _szTextToAdd) {}
// ^ NEW IN 1.60
function Clear() {}
function Created() {}

defaultproperties
{
}
