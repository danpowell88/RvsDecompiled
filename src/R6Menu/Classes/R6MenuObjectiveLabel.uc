//=============================================================================
//  R6MenuObjectiveLabel.uc : A check box plus the objective description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/05 * Created by Alexandre Dionne
//=============================================================================
class R6MenuObjectiveLabel extends UWindowWindow;

// --- Variables ---
var Region m_RCheckBoxBorder;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Objective;
var Region m_RCheckBoxMark;
var R6WindowTextLabel m_ObjectiveFailed;
var float m_fYPaddingBetweenElements;
var bool m_bObjectiveCompleted;
var Texture m_TCheckBoxBorder;
// ^ NEW IN 1.60
var Texture m_TCheckBoxMark;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function SetProperties(string _Objective, bool _completed, optional string _szFailed) {}
function SetNewLabelWindowSizes(float _W, float _X, float _Y, float _H) {}
function Created() {}

defaultproperties
{
}
