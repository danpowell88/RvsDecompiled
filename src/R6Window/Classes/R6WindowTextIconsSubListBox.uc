//=============================================================================
//  R6WindowTextIconsSubListBox.uc : This list is designed to be used
//                                      with th R6WindowDynTeamList
//                                   Instanciate this with the createControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/28 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextIconsSubListBox extends UWindowDialogControl;

// --- Variables ---
var R6WindowButton m_UpButton;
//Top Label
var R6WindowButton m_AddButton;
var R6WindowButton m_RemoveButton;
// ^ NEW IN 1.60
var R6WindowButton m_DownButton;
var R6WindowTextIconsListBox m_listBox;
var Region m_LabelRegionTop;
var R6WindowBitMap m_AddRemoveBg;
var Region m_LabelRegionBottom;
var R6WindowBitMap m_UpDownBg;
var R6WindowTextLabel m_Title;
var RegionButton m_UpReg;
// ^ NEW IN 1.60
var Region m_LabelRegionTile;
var Color m_LabelColor;
var RegionButton m_DownReg;
var Texture m_LabelTexture;
var Region m_AddRemoveBgReg;
var Region m_UpDownBgReg;
var int m_IAddRemoveXPos;
// ^ NEW IN 1.60
var int m_IAddRemoveYPos;
// ^ NEW IN 1.60
var int m_IUpDownYPos;
// ^ NEW IN 1.60
var int m_LabelDrawStyle;
var int m_IAddRemoveBgXPos;
// ^ NEW IN 1.60
var int m_IAddRemoveBgYPos;
var int m_IUpDownXPos;
// ^ NEW IN 1.60
//X pos from right side
var int m_IUpDownBgXPos;
var int m_IUpDownBgYPos;
var int m_IUpDownBetweenPadding;
var int m_maxItemsCount;

// --- Functions ---
function Created() {}
function Register(UWindowDialogClientWindow W) {}
function Paint(Canvas C, float Y, float X) {}
//===================================================
// SetTip : set the tip string for thoses window
//===================================================
function SetTip(string _szTip) {}
function UpdateButtons(optional int addButton) {}
function SetColor(Color NewColor) {}
function Resized() {}

defaultproperties
{
}
