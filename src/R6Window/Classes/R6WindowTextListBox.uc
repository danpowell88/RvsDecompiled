//=============================================================================
//  R6WindowTextListBox.uc : Text-rendering list box with R6's styled selection border.
//  Extends R6WindowListBox with text-based row drawing and a fixed selection border width.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2001/12/13 * Modified by Alexandre Dionne
//=============================================================================
class R6WindowTextListBox extends R6WindowListBox;

// --- Constants ---
const C_iSEL_BORDER_WIDTH =  2;

// --- Variables ---
// var ? m_font; // REMOVED IN 1.60
// BackGround texture Region under item when selected
var Region m_BGSelRegion;
// BackGround color when selected
var Color m_BGSelColor;
// color for disable text (item)
var Color m_DisableTextColor;
// BackGround texture under item when selected
var Texture m_BGSelTexture;
var ERenderStyle m_BGRenderStyle;
//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
// color for selected text
var Color m_SelTextColor;
//If we want the Separator to be displayed another color
var Color m_SeparatorTextColor;
var float m_fFontSpacing;
var Font m_Font;
// ^ NEW IN 1.60
// font for the separator
var Font m_FontSeparator;

// --- Functions ---
function DrawItem(Canvas C, float W, float Y, float X, UWindowList Item, float H) {}
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function Created() {}
function BeforePaint(float fMouseY, float fMouseX, Canvas C) {}
//=====================================================================================
// FindItemWithName: Find item depending is name
//=====================================================================================
function UWindowList FindItemWithName(string _ItemName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
