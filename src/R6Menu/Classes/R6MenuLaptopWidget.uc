//=============================================================================
//  R6MenuLaptopWidget.uc : Class to be derived in order to get the laptop borders
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuLaptopWidget extends R6MenuWidget;

// --- Variables ---
var UWindowWindow m_Top;
var UWindowWindow m_Left;
var UWindowWindow m_Right;
var R6MenuNavigationBar m_NavBar;
var Texture m_TBackGround;
var UWindowWindow m_Bottom;
var R6MenuHelpTextFrameBar m_HelpTextBar;
var float m_fLaptopPadding;
var R6MenuSimpleWindow m_EmptyBox2;
var R6MenuSimpleWindow m_EmptyBox1;
var Region m_RBackGround;

// --- Functions ---
function Created() {}
function Paint(Canvas C, float X, float Y) {}
//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(float Y, float X) {}
function DrawLaptopFrame(Canvas C) {}

defaultproperties
{
}
