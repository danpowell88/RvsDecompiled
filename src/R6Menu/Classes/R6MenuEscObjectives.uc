//=============================================================================
//  R6MenuEscObjectives.uc : Objectives window in the esc menu of single player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEscObjectives extends UWindowWindow;

// --- Constants ---
const C_MAXOBJ =  10;

// --- Variables ---
var float m_fXTitleOffset;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Title;
// ^ NEW IN 1.60
var R6MenuObjectiveLabel m_Objectives[10];
var float m_fObjHeight;
// ^ NEW IN 1.60
var R6WindowTextLabel m_NoObj;
var float m_fObjYOffset;
var float m_fYTitleOffset;
// ^ NEW IN 1.60
var float m_fLabelHeight;
var string m_szTextFailed;

// --- Functions ---
function UpdateObjectives() {}
function Created() {}

defaultproperties
{
}
