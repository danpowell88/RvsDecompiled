//=============================================================================
//  R6MenuCampaignDescription.uc : In single player, show the status of the current 
//                                  selected campaign        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCampaignDescription extends UWindowWindow;

// --- Variables ---
var R6WindowTextLabel m_NameTitle;
// ^ NEW IN 1.60
var R6WindowTextLabel m_MissionTitle;
// ^ NEW IN 1.60
var R6WindowTextLabel m_DifficultyTitle;
var R6WindowTextLabel m_MissionValue;
// ^ NEW IN 1.60
var R6WindowTextLabel m_NameValue;
// ^ NEW IN 1.60
var R6WindowTextLabel m_DifficultyValue;
var float m_LabelHeight;
var float m_HPadding;
// ^ NEW IN 1.60
var float m_VSpaceBetweenElements;
// ^ NEW IN 1.60
var float m_VPadding;
// ^ NEW IN 1.60
var Color m_vBGColor;
var Texture m_BGTexture;
var Region m_BGTextureRegion;
var int m_DrawStyle;

// --- Functions ---
// function ? Paint(...); // REMOVED IN 1.60
function Created() {}

defaultproperties
{
}
