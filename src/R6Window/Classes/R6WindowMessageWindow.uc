//=============================================================================
//  R6WindowMessageWindow.uc : Modal framed window that displays a single styled text message.
//  Extends R6WindowFramedWindow with a positioned, coloured message string.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowMessageWindow extends R6WindowFramedWindow;

// --- Variables ---
var float m_fMessageX;
// ^ NEW IN 1.60
var string m_szMessage;
var Color m_MessageColor;
var float m_fMessageY;
var TextAlign m_MessageAlign;
var TextAlign m_MessageAlignY;
var float m_fMessageTab;

// --- Functions ---
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
