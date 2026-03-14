//=============================================================================
//  R6Window3DButton.uc : Window under the 3D view for planning, has to be a button
//                          to be able to click on it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/27/04 * Created by Joel Tremblay
//=============================================================================
class R6Window3DButton extends UWindowButton;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

// --- Variables ---
var Color m_cButtonColor;
var bool m_bLMouseDown;
var bool m_bDisplayWindow;
var int m_iDrawStyle;

// --- Functions ---
function SetButtonColor(Color cButtonColor) {}
function MouseMove(float X, float Y) {}
function Paint(Canvas C, float Y, float X) {}
function Close3DWindow() {}
function Toggle3DWindow() {}
function LMouseUp(float Y, float X) {}
function LMouseDown(float Y, float X) {}
function MouseEnter() {}
function MouseLeave() {}
function BeforePaint(float Y, float X, Canvas C) {}
function Created() {}

defaultproperties
{
}
