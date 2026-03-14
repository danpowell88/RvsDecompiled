//=============================================================================
//  R6MenuMPInGameVote.uc : Multi player menu vote screen
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/7 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameVote extends R6MenuWidget;

// --- Constants ---
const C_iNUMBER_OF_CHOICES =  3;

// --- Variables ---
var R6WindowTextLabel m_AVoteText[4];
var Region m_RVote;
var float m_fOffsetTxtPos;
var R6WindowPopUpBox m_pPopUpBG;
var bool m_bFirstTimePaint;
var string m_szPlayerNameToKick;

// --- Functions ---
function WindowEvent(Canvas C, WinMessage Msg, float X, float Y, int Key) {}
function KeyDown(int Key, float Y, float X) {}
function BeforePaint(Canvas C, float Y, float X) {}
function Created() {}

defaultproperties
{
}
