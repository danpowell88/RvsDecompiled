//=============================================================================
//  R6WindowSimpleCurvedFramedWindow.uc : This provides a simple frame for a window
//										 with the curved style
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================
class R6WindowSimpleCurvedFramedWindow extends R6WindowSimpleFramedWindow;

// --- Variables ---
// var ? m_title; // REMOVED IN 1.60
var R6WindowTextLabelCurved m_topLabel;
var string m_Title;
// ^ NEW IN 1.60
var TextAlign m_TitleAlign;
var Font m_Font;
var Color m_TextColor;
//Space between characters
var float m_fFontSpacing;
// Left Text Margin
var float m_fLMarge;

// --- Functions ---
//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(class<UWindowWindow> ClientClass) {}
function SetCornerType(eCornerType _eCornerType) {}
function AfterPaint(Canvas C, float X, float Y) {}
function Created() {}
function BeforePaint(Canvas C, float X, float Y) {}

defaultproperties
{
}
