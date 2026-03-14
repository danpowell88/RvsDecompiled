//=============================================================================
//  R6PlayerCustomMission.uc : Will be in a file to keep a status of what map
//                             you have unlock in the campaign.
//						  
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6PlayerCustomMission extends Object
    native;

// --- Variables ---
var array<array> m_aCampaignFileName;
var array<array> m_iNbMapUnlock;

defaultproperties
{
}
