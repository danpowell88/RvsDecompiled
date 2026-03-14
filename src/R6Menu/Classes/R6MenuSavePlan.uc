//=============================================================================
//  R6MenuSavePlan.uc : This is the class where you manage the save plan. You have an edit box to edit
//						the name of the save file and a text list box where we displaying the other save files
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by Yannick Joly
//=============================================================================
class R6MenuSavePlan extends UWindowDialogClientWindow;

// --- Constants ---
const C_iEDITBOX_HEIGHT =  24;

// --- Variables ---
// the save plan was displayed in this window
var R6WindowTextListBox m_pListOfSavedPlan;
// the edit box to edit the save name
var R6WindowEditBox m_pEditSaveNameBox;
var R6WindowButton m_BDeletePlan;
var int m_IBXPos;
// ^ NEW IN 1.60
// Button Position
var int m_IBYPos;

// --- Functions ---
function Notify(UWindowDialogControl C, byte E) {}
function Paint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
