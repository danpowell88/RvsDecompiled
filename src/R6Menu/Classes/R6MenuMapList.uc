//=============================================================================
//  R6MenuMapList.uc : This menu display the map and the map list window and manage
//                     all the operations between the two window (+ the button in center)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/02  * Create by Yannick Joly
//=============================================================================
class R6MenuMapList extends UWindowDialogClientWindow;

// --- Constants ---
const C_iMAX_MAPLIST_SIZE =  32;
const C_fY_ButPos =  67;
const C_fX_ButPos =  148;
const C_fHEIGHT_OF_MAPLIST =  115;
const C_fWIDTH_OF_MAPLIST =  135;
const C_fY_START_MAPLIST =  16;
const C_fX_START_MAPLIST =  7;
const C_fX_START_TEXT =  5;

// --- Variables ---
var R6WindowTextListBoxExt m_pFinalMapList;
// the combo control for game type
var R6WindowComboControl m_pGameTypeCombo;
var R6WindowTextListBoxExt m_pStartMapList;
var UWindowButton m_pSelectButton;
// the adding button
var UWindowButton m_pPlusButton;
// the substract button
var UWindowButton m_pSubButton;
// the text info in background
var R6WindowTextLabelExt m_pTextInfo;
// the game mode of the map list
var EGameModeInfo m_eMyGameMode;
var Texture m_pButtonTexture;
// the game mode selected (Adversarial, Cooperative, etc)v
var string m_szLocGameMode;
// only to refresh game mode
var int m_iTextIndex;
// you come from Start list -- for color effect window!
var bool m_bFromStartList;
var bool m_bInGame;
// the region of the arrow button for map list
var Region m_RArrowUp;
// the region of the arrow button for map list
var Region m_RArrowDown;
// the region of the arrow button for map list
var Region m_RArrowDisabled;
// the region of the arrow button for map list
var Region m_RArrowOver;

// --- Functions ---
//===================================================================================
// Notify : Receive msg from UWindowDialogControl window
//===================================================================================
function Notify(UWindowDialogControl C, byte E) {}
//===================================================================================================
// FillFinalMapList: Fill the map list according the list give by the serveroptions --> from "server".ini
//===================================================================================================
function string FillFinalMapList() {}
// ^ NEW IN 1.60
function ManageAvailableGameTypes(UWindowList _pSelectItem, optional bool _bKeepItemGameType) {}
//===================================================================================
// Copy an item and add it in a specfic list
//===================================================================================
function CopyAndAddItemInList(UWindowListControl _ListAddItem, UWindowListBoxItem _ItemToAdd) {}
/////////////////////////////////////////////////////////////////
// ManageComboChange: Manage the DE_Change combo control message
/////////////////////////////////////////////////////////////////
function ManageComboChange() {}
/////////////////////////////////////////////////////////////////
// Fill the map window text list box
/////////////////////////////////////////////////////////////////
function FillMapListItem() {}
function Created() {}
function byte FillGameTypeMapArray(out array<array> _SelectedMapList, out array<array> _SelectedGameTypeList) {}
// ^ NEW IN 1.60
function SetOrderButtons(bool _bDisable) {}
//===================================================================================================
//
//===================================================================================================
function SetGameModeToDisplay(string _szIndex) {}
function WindowStateChange() {}
/////////////////////////////////////////////////////////////////
// ManageTextListBox: Manage the operation between the two map list
/////////////////////////////////////////////////////////////////
function ManageTextListBox() {}
function CreateButtons() {}
//===================================================================================================
// FillFinalMapListInGame: Fill the map list according the list give by the server -- in-game only
//===================================================================================================
function string FillFinalMapListInGame() {}
// ^ NEW IN 1.60
//===================================================================================================
//
//===================================================================================================
function InitMode(string _szIndex) {}
function bool FindMapInStartMapList(string _szMapName) {}
// ^ NEW IN 1.60
function SetButtonRegion(bool _bInverseTex) {}
//===================================================================================================
// GetNewServerProfileGameMode:
//===================================================================================================
function string GetNewServerProfileGameMode(optional bool _bInGame) {}
// ^ NEW IN 1.60
function string GetGameModeFromList(string _szGameType) {}
// ^ NEW IN 1.60
function bool IsFinalMapListEmpty() {}
// ^ NEW IN 1.60

defaultproperties
{
}
