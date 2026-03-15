//=============================================================================
// R6MissionRoster - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MissionRoster.uc : The operatives and their specific 
//							details for a mission
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================
class R6MissionRoster extends Object
    native;

//var string missionID
var array<R6Operative> m_MissionOperatives;

