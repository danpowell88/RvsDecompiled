//=============================================================================
//  R6WindowButtonSort.uc : Text buttons with triangle for type of sort
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/16 Created by Yannick Joly
//=============================================================================
class R6WindowButtonSort extends UWindowButton;

// --- Variables ---
// The region of the triangle -- representation of ascending--descending
var Region m_RSortIcon;
// pos in Y of the icon
var float m_fYSortIconPos;
// pos in X of the icon
var float m_fXSortIconPos;
var Font m_buttonFont;
// If the button have enought space to draw the sort icon
var bool m_bAbleToDrawSortIcon;
// Use to set the param in before paint one time
var bool m_bSetParam;
// The icon for sort
var Texture m_TSortIcon;
// This button have to draw the sort icon
var bool m_bDrawSortIcon;
// The selection is ascending or descending
var bool m_bAscending;
var bool m_bDrawSimpleBorder;
var float m_fLMarge;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function BeforePaint(Canvas C, float X, float Y) {}

defaultproperties
{
}
