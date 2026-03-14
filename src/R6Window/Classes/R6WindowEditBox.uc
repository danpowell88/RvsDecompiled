//=============================================================================
//  R6WindowEditBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowEditBox extends UWindowEditBox;

// --- Variables ---
// var ? m_bDisplayEditBoxProperties; // REMOVED IN 1.60
// var ? m_bOldAllSelected; // REMOVED IN 1.60
// var ? m_bOldCanEdit; // REMOVED IN 1.60
// var ? m_bOldCurrentlyEditing; // REMOVED IN 1.60
// var ? m_bOldHasKeyboardFocus; // REMOVED IN 1.60
// var ? m_bOldShowCaret; // REMOVED IN 1.60
// BackGround texture Region
var Region m_RBGEditTexture;
var float m_fYBGPos;
// the position of the text in y
var float m_fYTextPos;
// what's displaying
var string m_szValueToDisplay;
var bool bCaps;
var float m_fTextHeight;
// the current value equal to value of the edit box
var string m_szCurValue;
var Texture m_TBGEditTexture;

// --- Functions ---
function PaintEditBoxBG(Canvas C) {}
function Paint(Canvas C, float Y, float X) {}
function BeforePaint(Canvas C, float X, float Y) {}

defaultproperties
{
}
