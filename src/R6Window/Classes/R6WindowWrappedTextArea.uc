//=============================================================================
//  R6WindowWrappedTextArea.uc : Word-wrapping text area with R6-styled decorative borders.
//  Extends UWindowWrappedTextArea and adds skinned vertical and horizontal border regions.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Alexandre Dionne
//=============================================================================
class R6WindowWrappedTextArea extends UWindowWrappedTextArea;

// --- Variables ---
var Region m_VBorderTextureRegion;
var Region m_HBorderTextureRegion;
// ^ NEW IN 1.60
var float m_fHBorderHeight;
// ^ NEW IN 1.60
var bool m_bDrawBorders;
var float m_fHBorderPadding;
// ^ NEW IN 1.60
var float m_fVBorderPadding;
var Region m_BGRegion;
var Color m_BGColor;
var float m_fVBorderWidth;
var Texture m_HBorderTexture;
// ^ NEW IN 1.60
var Texture m_VBorderTexture;
//var R6WindowVScrollBar VertSB;
var class<UWindowVScrollbar> m_SBClass;
/////////////// BACK GROUND /////////////////////
var Texture m_BGTexture;
var int m_BGDrawStyle;
var bool m_bUseBGColor;
var bool m_bUseBGTexture;

// --- Functions ---
function MouseWheelUp(float X, float Y) {}
function MouseWheelDown(float X, float Y) {}
function SetBorderColor(Color _NewColor) {}
function SetScrollable(bool newScrollable) {}
function Paint(Canvas C, float X, float Y) {}
function Resize() {}

defaultproperties
{
}
