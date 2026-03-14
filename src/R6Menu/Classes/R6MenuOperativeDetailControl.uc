//=============================================================================
//  R6MenuOperativeDetailControl.uc : This will provide fonctionalities
//                                      to get operative descriptions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeDetailControl extends UWindowDialogClientWindow;

// --- Variables ---
var R6MenuOperativeSkills m_SkillsPage;
var R6WindowBitMap m_OperativeFace;
var R6MenuOperativeBio m_BioPage;
var R6MenuOperativeStats m_StatsPage;
var UWindowWindow m_CurrentPage;
var R6MenuOperativeDetailRadioArea m_TopButtons;
var R6MenuOperativeHistory m_HistoryPage;
var bool m_bUpdateOperativeText;
var int m_ITopLineYPos;
// ^ NEW IN 1.60
var int m_IBottomLineYPos;

// --- Functions ---
// function ? SetFace(...); // REMOVED IN 1.60
function Paint(Canvas C, float X, float Y) {}
function UpdateDetails() {}
function Created() {}
function AfterPaint(Canvas C, float X, float Y) {}
function setFace(Region _R, Texture newFace) {}
// ^ NEW IN 1.60
function ChangePage(int ButtonID) {}

defaultproperties
{
}
