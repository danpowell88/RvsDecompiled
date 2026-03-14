//=============================================================================
//  R6WindowListBoxCreditsItem.uc : list box credits item
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================
class R6WindowListBoxCreditsItem extends UWindowList;

// --- Variables ---
var float m_fHeight;
var string m_szName;
// a int because we not have access to root to specify the font
var int m_iFont;
// a int because we not have access to root to specify the color
var int m_iColor;
var bool m_bDrawALineUnderText;
var Font m_Font;
var Color m_TextColor;
// the offset of the text in this item
var int m_iXPosOffset;
// the offset of the text in this item
var int m_iYPosOffset;
var bool m_bConvertItemValue;

// --- Functions ---
function Init(string _szCreditsLine) {}

defaultproperties
{
}
