//=============================================================================
//  R6MenuInGameInstructionWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6MenuInGameInstructionWidget extends R6MenuWidget;

// --- Variables ---
var R6WindowSimpleFramedWindow m_InstructionText;
var R6InstructionSoundVolume m_pLastIntructionVolume;
var bool bIsChangingText;
var Region m_RMsgSize;
var float m_fYInstructionTextPos;
var string m_szText;
var int m_iArrayHudStep[3];

// --- Functions ---
function ResolutionChanged(float W, float H) {}
function ChangeText(R6InstructionSoundVolume pISV, int iBox, int iParagraph) {}
function Paint(Canvas C, float X, float Y) {}
function Created() {}
function WindowEvent(Canvas C, WinMessage Msg, int Key, float X, float Y) {}
function BeforePaint(Canvas C, float X, float Y) {}

defaultproperties
{
}
