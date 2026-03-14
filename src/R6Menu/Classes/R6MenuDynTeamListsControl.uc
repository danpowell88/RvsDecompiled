//=============================================================================
//  R6MenuDynTeamListsControl.uc : Control that will allow
//                                  Dynamic Selections of Team Rosters
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuDynTeamListsControl extends UWindowDialogClientWindow;

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
// var ? m_AssaultButton; // REMOVED IN 1.60
// var ? m_ListBox; // REMOVED IN 1.60
// var ? m_SniperButton; // REMOVED IN 1.60
var R6WindowTextIconsSubListBox m_GreenListBox;
// ^ NEW IN 1.60
var R6WindowTextIconsSubListBox m_RedListBox;
// ^ NEW IN 1.60
var R6WindowTextIconsListBox m_listBox;
// ^ NEW IN 1.60
var R6WindowTextIconsSubListBox m_GoldListBox;
var R6WindowListBoxAnchorButton m_ASSAULTButton;
// ^ NEW IN 1.60
var Region m_BorderRegion;
var R6WindowListBoxAnchorButton m_ElectronicButton;
var R6WindowListBoxAnchorButton m_DemolitionButton;
var R6WindowListBoxAnchorButton m_SNIPERButton;
// ^ NEW IN 1.60
var R6WindowListBoxAnchorButton m_ReconButton;
var bool bShowLog;
// ^ NEW IN 1.60
var Texture m_BorderTexture;
//Vertical Padding Between Controls
var float m_fVPadding;
//For size calculations == Top label and offset
var int m_SubListTopHeight;
var float m_SubListByItemHeight;
// ^ NEW IN 1.60
var float m_fHButtonPadding;
// ^ NEW IN 1.60
var float m_fHButtonOffset;
var int m_iMaxOperativeCount;
var float TotalSublistsHeight;
var Region m_RASSAULTUp;
// ^ NEW IN 1.60
var Region m_RASSAULTOver;
// ^ NEW IN 1.60
var Region m_RASSAULTDown;
// ^ NEW IN 1.60
var Region m_RAssaultDisabled;
// ^ NEW IN 1.60
var Region m_RReconUp;
// ^ NEW IN 1.60
var Region m_RReconOver;
// ^ NEW IN 1.60
var Region m_RReconDown;
// ^ NEW IN 1.60
var Region m_RReconDisabled;
// ^ NEW IN 1.60
var Region m_RSNIPERUp;
// ^ NEW IN 1.60
var Region m_RSNIPEROver;
// ^ NEW IN 1.60
var Region m_RSNIPERDown;
// ^ NEW IN 1.60
var Region m_RSniperDisabled;
// ^ NEW IN 1.60
var Region m_RDemolitionUp;
// ^ NEW IN 1.60
var Region m_RDemolitionOver;
// ^ NEW IN 1.60
var Region m_RDemolitionDown;
// ^ NEW IN 1.60
var Region m_RDemolitionDisabled;
// ^ NEW IN 1.60
var Region m_RElectronicUp;
// ^ NEW IN 1.60
var Region m_RElectronicOver;
// ^ NEW IN 1.60
var Region m_RElectronicDown;
// ^ NEW IN 1.60
var Region m_RElectronicDisabled;
// ^ NEW IN 1.60
var float m_fButtonTabWidth;
// ^ NEW IN 1.60
var float m_fButtonTabHeight;
var Region RAssault;
// ^ NEW IN 1.60
var Region RRecon;
// ^ NEW IN 1.60
var Region RSniper;
// ^ NEW IN 1.60
var Region RDemo;
// ^ NEW IN 1.60
//Small icons in the list
var Region RElectro;
var Region RSAssault;
// ^ NEW IN 1.60
var Region RSRecon;
// ^ NEW IN 1.60
var Region RSSniper;
// ^ NEW IN 1.60
var Region RSDemo;
// ^ NEW IN 1.60
var Region RSElectro;
var float m_fFirsButtonOffset;
// ^ NEW IN 1.60
var float m_MinSubListHeight;
// ^ NEW IN 1.60
var Texture m_TButtonTexture;

// --- Functions ---
function FillRosterList() {}
function Notify(UWindowDialogControl C, byte E) {}
//Adding an item to a sub list
function AddOperativeToSubList(R6WindowTextIconsSubListBox _SubListBox) {}
function ResizeSubLists() {}
//Remove an Item from a SubList
function RemoveOperativeInSubList(R6WindowTextIconsSubListBox _SubListBox) {}
function Paint(Canvas C, float Y, float X) {}
function RefreshButtons() {}
function int DistributeSpaces(out int _iHList, int _iMaxListHeigth, int _iSpaceToAdd) {}
// ^ NEW IN 1.60
function CreateRosterListBox() {}
function EmptyRosterList() {}
function CreateAnchoredButtons() {}
function Created() {}

defaultproperties
{
}
