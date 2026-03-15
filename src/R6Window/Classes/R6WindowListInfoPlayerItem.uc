//=============================================================================
// R6WindowListInfoPlayerItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of players in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowListInfoPlayerItem extends UWindowListBoxItem;

var int iSkills;
var int iPing;  // Ping time to players computer
var int iRank;  // Player Rank
var float fNameXOff;
var float fSkillsXOff;
var float fTimeXOff;
var float fPingXOff;
var float fNameWidth;
var string szPlName;  // Player Name
var string szTime;  // Total time the player has been playing at this server

defaultproperties
{
	fNameXOff=5.0000000
	fSkillsXOff=91.0000000
	fTimeXOff=50.0000000
	fPingXOff=50.0000000
	fNameWidth=86.0000000
}
