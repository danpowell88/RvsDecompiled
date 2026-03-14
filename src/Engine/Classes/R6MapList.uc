//=============================================================================
//  R6MapList.uc : Map List
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//  Used to create a list of maps to cycyle through in adversarial mode.
//
//  Revision history:
//    2002/04/22 * Created by John Bennett
//=============================================================================
class R6MapList extends MapList
    native;

// --- Variables ---
var config string GameType[32];
var bool m_bInit;

// --- Functions ---
function string CheckNextGameTypeIndex(int iMapIndex) {}
// ^ NEW IN 1.60
function string CheckNextMapIndex(int iMapIndex) {}
// ^ NEW IN 1.60
event PreBeginPlay() {}
//------------------------------------------------------------------
// GetNextMapIndex: Get the next map, increase the counter and save
//	the setting
//------------------------------------------------------------------
function string GetNextMap(int iNextMapNum) {}
// ^ NEW IN 1.60
//function int GetNextMapIndex(OPTIONAL int iNextMapNum)
function int GetNextMapIndex(int iNextMapNum) {}
// ^ NEW IN 1.60
function string CheckCurrentGameType() {}
// ^ NEW IN 1.60
function string CheckCurrentMap() {}
// ^ NEW IN 1.60
function string CheckNextGameType() {}
// ^ NEW IN 1.60
function string CheckNextMap() {}
// ^ NEW IN 1.60

defaultproperties
{
}
