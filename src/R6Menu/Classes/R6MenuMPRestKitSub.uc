//=============================================================================
//  R6MenuMPRestKitSub.uc : Restriction kit tab menus
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/20/6  * Create by John Bennett
//=============================================================================
class R6MenuMPRestKitSub extends UWindowDialogClientWindow;

// --- Constants ---
const K_X_BUTTON_OFF =  30;
const K_Y_BUTTON_OFF =  4;
const K_Y_LIST_OFF =  23;
const K_MAX_WINDOWBUTTONBOX =  20;
const K_BOX_HEIGHT =  16;
const K_X_BORDER_OFF =  5;
const K_HALFWINDOWWIDTH =  310;

// --- Variables ---
var array<array> m_ASelected;
var R6WindowListRestKit m_pRestKitButList;
var R6WindowButton m_pSelectAll;
var R6WindowButton m_pUnSelectAll;
var array<array> m_AMachinePistol;
var array<array> m_ASubMachineGuns;
var array<array> m_AShotguns;
var array<array> m_AAssaultRifle;
var array<array> m_AMachineGuns;
var array<array> m_ASniperRifle;
var array<array> m_APistol;
var array<array> m_APriWpnGadget;
var array<array> m_ASecWpnGadget;
var array<array> m_AMiscGadget;
// Pistols
var R6WindowButtonBox m_pPistol[20];
// Primary Weapon
var R6WindowButtonBox m_pPriWpnGadget[20];
// Secondary weapon
var R6WindowButtonBox m_pSecWpnGadget[20];
// Misc
var R6WindowButtonBox m_pMiscGadget[20];
// Machine pistols
var R6WindowButtonBox m_pMachinePistol[20];
// Sniper rifle
var R6WindowButtonBox m_pSniperRifle[20];
// Machine guns
var R6WindowButtonBox m_pMachineGuns[20];
// Assault rifle
var R6WindowButtonBox m_pAssaultRifle[20];
// Shotguns
var R6WindowButtonBox m_pShotguns[20];
// Sub machine guns
var R6WindowButtonBox m_pSubMachineGuns[20];
var bool m_bIsInGame;

// --- Functions ---
function Paint(Canvas C, float fMouseY, float fMouseX) {}
function Notify(UWindowDialogControl C, byte E) {}
function array<bool> GetGadgetRestrictionKit(array<array> _pInitialRest, class<Object> pClassRestriction, R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction, optional bool _bSecWeaponGadget) {}
// ^ NEW IN 1.60
function array<bool> GetRestrictionKit(array<array> _pInitialRest, class<Object> pClassRestriction, R6GameReplicationInfo _pR6GameRepInfo, optional string _szInGameRestriction) {}
// ^ NEW IN 1.60
function CreateRestKitButtons(array<array> pRestKitClass, array<array> pRestKitSelect, string _szLocFile, out R6WindowButtonBox _ButtonsBox) {}
//=============================================================================
// Simple bubble sort to list restriction kit in alphabetical order of name
//=============================================================================
function array<bool> SortRestrictionKit(array<array> _pAToSort) {}
// ^ NEW IN 1.60
function UpdateRestKitButtonSel(out R6WindowButtonBox _ButtonsBox, array<array> pRestKitSelect) {}
function InitSelectButtons(bool _bInGame) {}
function SelectAllPistol(bool bSelected) {}
function SelectAllMiscGadget(bool bSelected) {}
function SelectAllSecWpnGadget(bool bSelected) {}
function SelectAllPriWpnGadget(bool bSelected) {}
function SelectAllMachinePistol(bool bSelected) {}
function SelectAllSniperRifle(bool bSelected) {}
function SelectAllMachineGuns(bool bSelected) {}
function SelectAllAssaultRifle(bool bSelected) {}
function SelectAllShotguns(bool bSelected) {}
function SelectAllSubMachineGuns(bool bSelected) {}
function UpdateMiscGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= MISC GADGETS =====================================================
//=================================================================================================
function InitMiscGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateSecWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= SECONDARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitSecWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdatePriWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= PRIMARY WEAPON GADGETS =====================================================
//=================================================================================================
function InitPriWpnGadgetTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateMachinePistolTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= MACHINE PISTOLS =====================================================
//=================================================================================================
function InitMachinePistolTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdatePistolsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= PISTOLS =====================================================
//=================================================================================================
function InitPistolTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateSniperRifleTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= SNIPER RIFLE =====================================================
//=================================================================================================
function InitSniperRifleTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= MACHINE GUNS =====================================================
//=================================================================================================
function InitMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateAssaultRifleTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= ASSAULT RIFLES =====================================================
//=================================================================================================
function InitAssaultRifleTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateShotGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= SHOT GUNS =====================================================
//=================================================================================================
function InitShotGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
function UpdateSubMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=================================================================================================
//========================= SUB MACHINES GUNS =====================================================
//=================================================================================================
function InitSubMachineGunsTab(R6GameReplicationInfo _pR6GameRepInfo) {}
//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function RefreshSubKit(bool _bAdmin) {}
function Created() {}

defaultproperties
{
}
