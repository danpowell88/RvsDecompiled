//=============================================================================
//  R6WindowFramedWindow.uc : Resizable, closeable framed dialog window.
//  Hosts a client sub-area and close button, and enforces configurable minimum dimensions.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowFramedWindow extends UWindowWindow;

// --- Variables ---
var UWindowWindow m_ClientArea;
var UWindowButton m_CloseBoxButton;
var float m_fMinWinWidth;
// ^ NEW IN 1.60
var float m_fMinWinHeight;
var bool m_bMoving;
var float m_fTitleOffSet;
var bool m_bTLSizing;
var bool m_bTSizing;
var bool m_bTRSizing;
var bool m_bLSizing;
var bool m_bRSizing;
var bool m_bBLSizing;
var bool m_bBSizing;
var bool m_bBRSizing;
var bool m_bSizable;
var bool m_bDisplayClose;
var localized string m_szWindowTitle;
var float m_fMoveX;
// ^ NEW IN 1.60
// co-ordinates where the move was requested
var float m_fMoveY;
var bool m_bMovable;
var class<UWindowWindow> m_ClientClass;
var string m_szStatusBarText;
var TextAlign m_TitleAlign;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function BeforePaint(Canvas C, float X, float Y) {}
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int iKey) {}
function LMouseDown(float X, float Y) {}
function MouseMove(float X, float Y) {}
function Resized() {}
function ToolTip(string strTip) {}
function SetDisplayClose(bool bNewDisplay) {}
function WindowHidden() {}
function bool IsActive() {}
// ^ NEW IN 1.60
function Texture GetLookAndFeelTexture() {}
// ^ NEW IN 1.60
function Created() {}

defaultproperties
{
}
