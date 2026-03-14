//=============================================================================
//  R6MenuOperativeSkillsLabel.uc : Set Default Properties for the labels on the 
//                                  skills page
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeSkillsLabel extends R6WindowTextLabel;

// --- Variables ---
// the numeric value
var string m_szNumericValue;
// use a fix area width for the numeric value
var float m_fWidthOfFixArea;
// the color of the numeric value
var Color m_NumericValueColor;

// --- Functions ---
function DrawNumericValue(Canvas C) {}
function Paint(Canvas C, float X, float Y) {}
function SetNumericValue(int _iOriginalValue, int _iLastValue) {}
function Created() {}

defaultproperties
{
}
