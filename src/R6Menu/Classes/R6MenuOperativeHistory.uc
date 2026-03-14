//=============================================================================
//  R6MenuOperativeHistory.uc : Page wich contains Operative 2d face, flag and
//                              history text
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeHistory extends UWindowWindow;

// --- Variables ---
var R6WindowWrappedTextArea m_OperativeText;
var R6WindowTextLabel m_Title;

// --- Functions ---
function SetBorderColor(Color _NewColor) {}
function SetText(Canvas C, string NewText) {}
function Paint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
