//=============================================================================
//  R6MenuMPInGameRecMessages.uc : Multi player menu to choose the pre-recorded messages
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameRecMessages extends R6MenuWidget;

// --- Variables ---
var R6WindowTextLabel m_TextPreRecMessages[5];
var Region m_RRecMsg;
var R6WindowPopUpBox m_pInGameRecMessagesPopUp;
var float m_fOffsetTxtPos;
var bool m_bFirstTimePaint;

// --- Functions ---
function KeyDown(int Key, float Y, float X) {}
function WindowEvent(Canvas C, WinMessage Msg, float X, float Y, int Key) {}
function Created() {}
function BeforePaint(Canvas C, float Y, float X) {}
function Paint(float Y, float X, Canvas C) {}

defaultproperties
{
}
