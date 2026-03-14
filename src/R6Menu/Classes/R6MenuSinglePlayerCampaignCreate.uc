//=============================================================================
//  R6MenuSinglePlayerCampaignCreate.uc : Small group of control to create a
//											campaign		
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerCampaignCreate extends UWindowDialogClientWindow;

// --- Variables ---
// var ? bShowlog; // REMOVED IN 1.60
var R6WindowTextLabel m_Difficulty;
var R6WindowEditControl m_CampaignNameEdit;
var R6MenuDiffCustomMissionSelect m_pDiffSelection;
var R6WindowTextLabel m_CampaignName;
// ^ NEW IN 1.60
var bool bShowLog;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Difficulty1;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Difficulty2;
// ^ NEW IN 1.60
var R6WindowTextLabel m_Difficulty3;

// --- Functions ---
function KeyDown(int Key, float X, float Y) {}
function Notify(UWindowDialogControl C, byte E) {}
function bool CreateCampaign() {}
// ^ NEW IN 1.60
function Created() {}
function Paint(Canvas C, float X, float Y) {}
function Reset() {}

defaultproperties
{
}
