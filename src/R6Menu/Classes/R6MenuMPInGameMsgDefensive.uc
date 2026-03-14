//=============================================================================
//  R6MenuMPInGameMsgDefensive.uc : Multi player menu to choose the order to be play
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/28 * Created by Serge Dore
//=============================================================================
class R6MenuMPInGameMsgDefensive extends R6MenuWidget;

// --- Variables ---
var R6WindowTextLabel m_TextDefensive[7];
var Region m_RMsgSize;
var R6WindowPopUpBox m_pInGameGiveOrderPopUp;
var float m_fOffsetTxtPos;
var bool m_bFirstTimePaint;

// --- Functions ---
function KeyDown(int Key, float X, float Y) {}
function Created() {}
function WindowEvent(Canvas C, WinMessage Msg, int Key, float Y, float X) {}
function BeforePaint(Canvas C, float X, float Y) {}
function Paint(Canvas C, float X, float Y) {}

defaultproperties
{
}
