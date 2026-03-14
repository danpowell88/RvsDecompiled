//=============================================================================
//  R6MenuMPRestKitMain.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPRestKitMain extends UWindowDialogClientWindow;

// --- Constants ---
const K_HALFWINDOWWIDTH =  310;

// --- Variables ---
var R6MenuMPRestKitSub m_pCurrentSubKit;
var R6MenuMPRestKitSub m_pSubMachinesGunsTab;
var R6MenuMPRestKitSub m_pSniperRifleTab;
var R6MenuMPRestKitSub m_pMiscGadgetTab;
var R6MenuMPRestKitSub m_pSecWpnGadgetTab;
var R6MenuMPRestKitSub m_pPriWpnGadgetTab;
var R6MenuMPRestKitSub m_pMachineGunsTab;
var R6MenuMPRestKitSub m_pMachinePistolTab;
var R6MenuMPRestKitSub m_pPistolTab;
var R6MenuMPRestKitSub m_pShotgunsTab;
var R6MenuMPRestKitSub m_pAssaultRifleTab;
var string m_ATextBoxLoc[2];
// if the client can change the settings
var bool m_bImAnAdmin;
// RESTRICTION KIT
var R6WindowTextLabelExt m_pKitText;
// fake window to hide all access buttons
var R6MenuSimpleWindow m_pRestKitOptFakeW;
var R6WindowButtonBox m_pKitMisc;
var R6WindowButtonBox m_pKitSecWeapon;
var R6WindowButtonBox m_pKitPrimaryWeapon;
var R6WindowButtonBox m_pKitMachinePistols;
var R6WindowButtonBox m_pKitSubMachinesGuns;
var R6WindowButtonBox m_pKitShotGuns;
var R6WindowButtonBox m_pKitAssaultRifles;
var R6WindowButtonBox m_pKitMachinesGuns;
var R6WindowButtonBox m_pKitSniperRifles;
var R6WindowButtonBox m_pKitPistols;
var array<array> m_SrvRestMiscGadgetsACopy;
var array<array> m_SrvRestSecondaryACopy;
var array<array> m_SrvRestPrimaryACopy;
var array<array> m_SrvRestMachinePistolsACopy;
var array<array> m_SrvRestPistolsACopy;
var array<array> m_SrvRestSniperRiflesACopy;
var array<array> m_SrvRestMachineGunsACopy;
var array<array> m_SrvRestAssultRiflesACopy;
var array<array> m_SrvRestShotGunsACopy;
var array<array> m_SrvRestSubMachineGunsACopy;
var bool m_bUpdateGameProgress;
var bool m_bUpdateInBetRound;
var R6MenuButtonsDefines m_pButtonsDef;

// --- Functions ---
/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E) {}
//=====================================================================================
// KIT TAB
//=====================================================================================
function CreateKitRestriction() {}
//=================================================================================
// SendNewRestrictionsKit: Send the new restrictions kit settings to the server, only the change values.
//						   If no modification was made return false
//=================================================================================
function bool SendNewRestrictionsKit() {}
// ^ NEW IN 1.60
//=================================================================================
// RefreshKitRest: Refresh the kit restrictions according the value on the server side
//=================================================================================
function RefreshKitRest() {}
function bool CompareARestKit(out array<array> _ANextSrvRestriction, ERestKitID _eRestKitID, array<array> _ACurServerRestKit, R6WindowButtonBox _pAButtonBox, optional bool _bStringArray) {}
// ^ NEW IN 1.60
function InitRightPart() {}
//=======================================================================================
// Refresh : Verify is the client is now an admin only in-game
//=======================================================================================
function Refresh() {}
function CopyStaticAToDynA(out array<array> _ASrvRestCopy, string _ASrvRest) {}
/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify(UWindowDialogControl C) {}
function MouseWheelDown(float X, float Y) {}
function MouseWheelUp(float X, float Y) {}
function GetR6GameReplicationInfo(out R6GameReplicationInfo pGameRepInfo) {}
function Tick(float _fDelta) {}
function RefreshCreateGameKitRest() {}

defaultproperties
{
}
