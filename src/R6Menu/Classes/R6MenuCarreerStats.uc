//=============================================================================
//  R6MenuCarreerStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/08 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCarreerStats extends UWindowWindow;

// --- Variables ---
var R6WindowTextLabel m_LOpName;
// ^ NEW IN 1.60
var float m_fXOffSet;
// ^ NEW IN 1.60
var float m_fLabelHeight;
var R6WindowTextLabel m_LOpSpecility;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LOpHealthStatus;
var R6MenuCarreerOperative m_OperativeFace;
var float m_fTitleHeight;
// ^ NEW IN 1.60
var R6WindowBitMap m_RainBowLogo;
var Region m_RRainBowLogo;
var R6WindowTextLabel m_LShootPercent;
var R6WindowTextLabel m_LRoundsOnTarget;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LRoundsFired;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LTerroKilled;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LMissionServed;
// ^ NEW IN 1.60
var R6WindowTextLabel m_LTitle;
// ^ NEW IN 1.60
var int m_iPadding;
// ^ NEW IN 1.60
var int m_iHeight;
var Texture m_TRainBowLogo;
var float m_fLOpNameW;
var float m_fLOpNameX;
var float m_fYOffSet;
// ^ NEW IN 1.60

// --- Functions ---
//To change the current operative Carreer Stats
function UpdateStats(string _RoundsOnTarget, string _RoundsShot, string _ShootPercent, string _TerroKilled, string _MissionServed) {}
//To change the current Operative Face
function UpdateFace(Texture _Face, Region _FaceRegion) {}
function UpdateTeam(int _Team) {}
function UpdateName(string _szOpName) {}
function UpdateSpeciality(string _szOpSpeciality) {}
function UpdateHealthStatus(string _szHealthStatus) {}
function Paint(Canvas C, float X, float Y) {}
function Created() {}

defaultproperties
{
}
