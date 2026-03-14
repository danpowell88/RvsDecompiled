//=============================================================================
//  R6WindowComboList.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowComboList extends UWindowComboList;

// --- Variables ---
// BackGround color
var Color m_BGColor;
// color for disable text (item)
var Color m_DisableTextColor;
//var color   TextColor;			// color for text            N.B. var already define in class UWindowDialogControl
// color for selected text (item)
var Color m_SelTextColor;
// BackGround texture Region under item when selected
var Region m_BGSelRegion;
// BackGround color when selected
var Color m_BGSelColor;
var ERenderStyle m_BGSelRenderStyle;
var ERenderStyle m_BGRenderStyle;
var class<UWindowVScrollbar> m_SBClass;
// BackGround texture under item when selected
var Texture m_BGSelTexture;

// --- Functions ---
function DrawItem(Canvas C, float Y, float X, UWindowList Item, float W, float H) {}
//-----------------------------------------------------------------------------
// There was a bug in the paint in the parent class (UWindowComboList), to
// avoid an ugly merge, overload the Paint() function here and correct the bug.
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y) {}
function BeforePaint(Canvas C, float X, float Y) {}
function DrawMenuBackground(Canvas C) {}
function Created() {}
function Setup() {}

defaultproperties
{
}
