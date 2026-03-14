//=============================================================================
//  R6MenuMPMenuTab.uc : All the tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/5  * Create by Yannick Joly
//=============================================================================
class R6MenuMPMenuTab extends UWindowDialogClientWindow;

// --- Constants ---
const C_fXPOS_LASTPOS =  419;
const C_fGM_COLUMNSWIDTH =  155;
const K_FSECOND_WINDOWHEIGHT =  90;
const K_HALFWINDOWWIDTH =  310;

// --- Variables ---
var R6WindowComboControl m_pFilterFasterThan;
// SERVER INFO TAB
var R6WindowTextLabelExt m_pServerInfo;
// FILTER TAB
var R6WindowTextLabelExt m_pFilterText;
// GAME MODE TAB
var R6WindowTextLabelExt m_pGameModeText;
var R6WindowButtonBox m_pFilterResponding;
var R6WindowButtonBox m_pGameTypeDeadMatch;
var R6WindowButtonBox m_pGameTypeTDeadMatch;
var R6WindowButtonBox m_pGameTypeDisarmBomb;
var R6WindowButtonBox m_pGameTypeHostageAdv;
var R6WindowButtonBox m_pGameTypeEscort;
var R6WindowButtonBox m_pGameTypeMission;
var R6WindowButtonBox m_pGameTypeTerroHunt;
var R6WindowButtonBox m_pGameTypeHostageCoop;
var R6WindowButtonBox m_pFilterUnlock;
var R6WindowButtonBox m_pFilterFavorites;
var R6WindowButtonBox m_pFilterDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonBox m_pFilterPunkBuster;
//#endif
var R6WindowButtonBox m_pFilterNotEmpty;
var R6WindowButtonBox m_pFilterNotFull;
var R6WindowButtonBox m_pFilterSameVersion;

// --- Functions ---
//*******************************************************************************************
// SERVER INFO TAB
//*******************************************************************************************
function InitServerTab() {}
//*******************************************************************************************
// FILTER TAB
//*******************************************************************************************
function InitFilterTab() {}
//*******************************************************************************************
// GAME MODE TAB
//*******************************************************************************************
function UpdateGameTypeFilter() {}
function InitGameModeTab() {}
//-------------------------------------------------------------------------
// ManageR6ComboControlNotify - Notify function for classes of
// type 'R6WindowComboControl'
//-------------------------------------------------------------------------
function ManageR6ComboControlNotify(UWindowDialogControl C, byte E) {}
//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function ManageR6ButtonBoxNotify(UWindowDialogControl C, byte E) {}
function Notify(UWindowDialogControl C, byte E) {}

defaultproperties
{
}
