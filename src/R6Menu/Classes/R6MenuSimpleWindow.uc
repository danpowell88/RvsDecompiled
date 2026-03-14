//=============================================================================
//  R6WindowSimpleWindow.uc : Draw a simple window (opportunity to create a empty box)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Yannick Joly
//=============================================================================
class R6MenuSimpleWindow extends UWindowWindow;

// --- Variables ---
var UWindowWindow pAdviceParent;
var bool m_bDrawSimpleBorder;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function MouseWheelDown(float X, float Y) {}
function MouseWheelUp(float X, float Y) {}

defaultproperties
{
}
