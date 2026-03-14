//=============================================================================
// R6PlayerCampaign - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlayerCampaign.uc : A player campaing keeps tacks of the evolution of a 
//							user specific saved campaign, allow reloading and 
//							resuming of a player campaign
//						  
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6PlayerCampaign extends Object
    native;

var byte m_bCampaignCompleted;
var int m_iDifficultyLevel;
var int m_iNoMission;
var R6MissionRoster m_OperativesMissionDetails;
var string m_FileName;
var string m_CampaignFileName;

