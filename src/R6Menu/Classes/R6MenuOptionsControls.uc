//=============================================================================
//  R6MenuOptionsControls.uc : For mapping key, this class is specific, work with R6MenuOptionsTab
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/13 * Created by Yannick Joly
//============================================================================
class R6MenuOptionsControls extends R6MenuOptionsTab;

// --- Variables ---
// var ? m_iLastKeyPressed; // REMOVED IN 1.60
// var ? m_pCancelButton; // REMOVED IN 1.60
var R6WindowListControls m_pListControls;
// ^ NEW IN 1.60
var R6WindowPopUpBox m_pPopUpKeyBG;
// ^ NEW IN 1.60
var R6WindowPopUpBox m_pKeyMenuReAssignPopUp;
// ^ NEW IN 1.60
var int m_iKeyToAssign;
// ^ NEW IN 1.60
var R6MenuOptionsMapKeys m_pOptControls;
// ^ NEW IN 1.60
var UWindowListBoxItem m_pCurItem;
// ^ NEW IN 1.60
var string m_szOldActionKey;
// ^ NEW IN 1.60

// --- Functions ---
// function ? Created(...); // REMOVED IN 1.60
// function ? HideWindow(...); // REMOVED IN 1.60
// function ? KeyDown(...); // REMOVED IN 1.60
// function ? LMouseDown(...); // REMOVED IN 1.60
// function ? MMouseDown(...); // REMOVED IN 1.60
// function ? MouseWheelDown(...); // REMOVED IN 1.60
// function ? MouseWheelUp(...); // REMOVED IN 1.60
// function ? RMouseDown(...); // REMOVED IN 1.60
// function ? Register(...); // REMOVED IN 1.60
// function ? ShowWindow(...); // REMOVED IN 1.60
function CreateKeyPopUp() {}
// ^ NEW IN 1.60
function AddKeyItem(string _szActionKey, R6WindowListControls _pR6WindowListControls, optional bool _bPlanningInput, string _szToolTip, string _szTitle) {}
// ^ NEW IN 1.60
function UpdateOptionsInPage() {}
// ^ NEW IN 1.60
function bool IsKeyValid(int _Key) {}
// ^ NEW IN 1.60
function RefreshKeyItem(string _szNewKeyValue) {}
// ^ NEW IN 1.60
function RestoreDefaultValue() {}
// ^ NEW IN 1.60
function Notify(UWindowDialogControl C, byte E) {}
// ^ NEW IN 1.60
function CloseAllKeyPopUp(optional bool _bCloseKeyControlTo) {}
// ^ NEW IN 1.60
function InitPageOptions() {}
// ^ NEW IN 1.60
function AddLineItem(R6WindowListControls _pR6WindowListControls) {}
// ^ NEW IN 1.60
function ManagePopUpKey(UWindowDialogControl C) {}
// ^ NEW IN 1.60
function KeyPressed(int Key) {}
// ^ NEW IN 1.60
function string GetLocKeyNameByActionKey(optional bool _bPlanningInput, string _szActionKey) {}
// ^ NEW IN 1.60
function AddTitleItem(R6WindowListControls _pR6WindowListControls, string _szTitle) {}
// ^ NEW IN 1.60
function UWindowListBoxItem GetCurrentKeyItem() {}
// ^ NEW IN 1.60
function string GetCurActionKey() {}
// ^ NEW IN 1.60
function string GetCurKeyName() {}
// ^ NEW IN 1.60
function int GetCurKeyInputClass() {}
// ^ NEW IN 1.60

defaultproperties
{
}
