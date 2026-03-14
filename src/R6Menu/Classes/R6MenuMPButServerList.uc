//=============================================================================
//  R6MenuMPButServerList.uc : manage buttons for server list
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/19  * Create by Yannick Joly
//=============================================================================
class R6MenuMPButServerList extends UWindowDialogClientWindow;

// --- Constants ---
const C_fW_PLAYERS =  63;
const C_fW_MAP =  100;
const C_fW_GAMETYPE =  100;
const C_fW_GAMEMODE =  100;
const C_fW_PING =  40;
const C_fW_NAME =  155;
const C_fW_PUNKBUSTER =  15;
const C_fW_DEDICATED =  15;
const C_fW_LOCKED =  15;
const C_fW_FAVORITES =  15;
const C_fX_FAVORITES =  0;

// --- Variables ---
var R6WindowButtonSort m_pLastButtonClick;
//#endif
var R6WindowButtonSort m_pButPingTime;
var R6WindowButtonSort m_pButFavorites;
var R6WindowButtonSort m_pButLocked;
var R6WindowButtonSort m_pButDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonSort m_pButPunkBuster;
var R6WindowButtonSort m_pButName;
var R6WindowButtonSort m_pButGameType;
var R6WindowButtonSort m_pButGameMode;
var R6WindowButtonSort m_pButMap;
var R6WindowButtonSort m_pButNumPlayers;

// --- Functions ---
function Created() {}
function CreateServerListButton(out R6WindowButtonSort _R6Button, int _iButtonID, string _szName, string _szTip, float _fX, float _fWidth) {}
function Notify(UWindowDialogControl C, byte E) {}

defaultproperties
{
}
