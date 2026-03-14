//=============================================================================
//  R6MenuWidget.uc : Base class for our game menus
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWidget extends UWindowDialogClientWindow;

// --- Variables ---
var float m_fRightMouseYClipping;
var float m_fRightMouseXClipping;
var float m_fLeftMouseXClipping;
var float m_fLeftMouseYClipping;

// --- Functions ---
function KeyDown(int Key, float X, float Y) {}
function Reset() {}
function SetMousePos(float Y, float X) {}

defaultproperties
{
}
