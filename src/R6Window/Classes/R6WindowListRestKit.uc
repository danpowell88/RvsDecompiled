//=============================================================================
//  R6WindowListRestKit.uc : The list for restriction kit. This list is for the same type of button. Same
//							 width, same height, etc.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/18 * Created by Yannick Joly
//=============================================================================
class R6WindowListRestKit extends UWindowListControl;

// --- Variables ---
// var ? m_fYOffset; // REMOVED IN 1.60
var R6WindowVScrollbar m_VertSB;
// the item X offset pos
var float m_fXItemOffset;
var float m_fYOffSet;
// ^ NEW IN 1.60
// the size of each item
var float m_fItemHeight;
// the space in between item
var float m_fSpaceBetItem;
var class<R6WindowVScrollbar> m_SBClass;

// --- Functions ---
//=======================================================================================
// MouseWheelUp: advice scroll bar for mouse wheel up
//=======================================================================================
function MouseWheelUp(float X, float Y) {}
//=======================================================================================
// MouseWheelDown: advice scroll bar for mouse wheel down
//=======================================================================================
function MouseWheelDown(float X, float Y) {}
function float GetSizeOfAnItem() {}
// ^ NEW IN 1.60
function Paint(Canvas C, float fMouseY, float fMouseX) {}
function DrawItem(float W, UWindowList Item, float X, float Y, float H, Canvas C) {}
function Created() {}

defaultproperties
{
}
