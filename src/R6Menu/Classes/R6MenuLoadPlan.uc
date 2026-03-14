//=============================================================================
//  R6MenuLoadPlan.uc : Window that pops up with all plans that can be loaded
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuLoadPlan extends UWindowDialogClientWindow;

// --- Variables ---
// the save plan was displayed in this window
var R6WindowTextListBox m_pListOfSavedPlan;
var R6WindowButton m_BDeletePlan;
var int m_IBXPos;
// ^ NEW IN 1.60
// Button Position
var int m_IBYPos;

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
function Resized() {}
function Created() {}

defaultproperties
{
}
