//=============================================================================
//  R6WindowServerListBox.uc : Class used to manage the "list box" of servers.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================
class R6WindowServerListBox extends R6WindowListBox;

// --- Variables ---
// BackGround color when selected
var Color m_BGSelColor;
// BackGround texture Region under item when selected
var Region m_BGSelRegion;
// color for selected text
var Color m_SelTextColor;
var ERenderStyle m_BGRenderStyle;
// BackGround texture under item when selected
var Texture m_BGSelTexture;
// Time at which the ping time times out
var int m_iPingTimeOut;
// draw the border and the background
var bool m_bDrawBorderAndBkg;
var Font m_Font;

// --- Functions ---
function Paint(Canvas C, float fMouseX, float fMouseY) {}
function BeforePaint(Canvas C, float fMouseX, float fMouseY) {}
function DrawItem(Canvas C, float H, float Y, UWindowList Item, float X, float W) {}
function DrawIcon(int _iPlayerStats, Canvas C, float _fX, float _fY, float _fWidth, float _fHeight) {}
//=============================================================================
// RMouseDown - If the user right clicks on a server, we call the notify
// function so that the right-click menu can be displayed.
//=============================================================================
function RMouseDown(float Y, float X) {}
//=============================================================================
// SetSelectedItem - We were getting recursion problems caused by
// the Notify(DE_Click) function, so this function was overloaded and the
// call to Notify(DE_Click) was removed (not needed in this application).
//=============================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected) {}
function Created() {}

defaultproperties
{
}
