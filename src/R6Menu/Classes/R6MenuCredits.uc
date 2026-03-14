//=============================================================================
//  R6MenuCredits.uc : Auto-scroll and display of the credits
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================
class R6MenuCredits extends UWindowListControl;

// --- Variables ---
var UWindowList m_FirstItemOnScreen;
var float m_fScrollSpeed;
var float m_fScrollIndex;
var float m_fYScrollEffect;
// The index of the scroll
var int m_iScrollIndex;
var bool m_bStopScroll;
var float m_fDelta;
var int m_iScrollStep;
var float m_fTexScrollSpeed;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function Tick(float fDelta) {}
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float H, float W) {}
function bool ConvertItemValue(out R6WindowListBoxCreditsItem _pItemToConvert, Canvas C) {}
// ^ NEW IN 1.60
function PaintCredits(Canvas C) {}
function PaintTexEffect(Canvas C) {}
function ResetCredits() {}

defaultproperties
{
}
