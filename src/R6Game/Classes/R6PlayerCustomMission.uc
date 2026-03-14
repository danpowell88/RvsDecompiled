//=============================================================================
// R6PlayerCustomMission - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlayerCustomMission.uc : Will be in a file to keep a status of what map
//                             you have unlock in the campaign.
//						  
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6PlayerCustomMission extends Object
    native;

var array<string> m_aCampaignFileName;
var array<int> m_iNbMapUnlock;

