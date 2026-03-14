//=============================================================================
//  R6WindowTextLabelCurved.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/02 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextLabelCurved extends R6WindowTextLabel;

// --- Variables ---
// var ? m_TopLeftCornerR; // REMOVED IN 1.60
// var ? m_TopLeftCornerT; // REMOVED IN 1.60
var Region m_RLeftcurve;
// ^ NEW IN 1.60
var Region m_topLeftCornerR;
// ^ NEW IN 1.60
var Region m_RUnderLeftCurveBG;
var float m_fRightCurveLineX;
// ^ NEW IN 1.60
var Region m_RBetweenCurveBG;
// ^ NEW IN 1.60
var float m_fVBorderOffset;
var float m_fLeftCurveLineX;
var Texture m_topLeftCornerT;
// ^ NEW IN 1.60
var Texture m_TLeftcurve;
// ^ NEW IN 1.60
var float m_RightCurveLineWidth;
var Texture m_TUnderLeftCurveBG;
var Texture m_TBetweenCurveBG;
// ^ NEW IN 1.60

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
