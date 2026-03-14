//=============================================================================
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of players in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowListInfoPlayerItem extends UWindowListBoxItem;

// --- Variables ---
var float fNameWidth;
var float fPingXOff;
var float fTimeXOff;
var float fSkillsXOff;
var float fNameXOff;
// Ping time to players computer
var int iPing;
// Total time the player has been playing at this server
var string szTime;
//
var int iSkills;
// Player Name
var string szPlName;
// Player Rank
var int iRank;

defaultproperties
{
}
