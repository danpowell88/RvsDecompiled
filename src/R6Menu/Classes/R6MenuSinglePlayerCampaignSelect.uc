//=============================================================================
//  R6MenuSinglePlayerCampaignSelect.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerCampaignSelect extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowTextListBox m_CampaignListBox;
var R6WindowTextLabelCurved m_LCampaignTitle;
var Texture m_BGTexture;

// --- Functions ---
// function ? Paint(...); // REMOVED IN 1.60
function DeleteCampaign() {}
function bool SetupCampaign() {}
// ^ NEW IN 1.60
function Notify(UWindowDialogControl C, byte E) {}
function LoadCampaign(string szCampaignName) {}
function RefreshListBox() {}
function Created() {}

defaultproperties
{
}
