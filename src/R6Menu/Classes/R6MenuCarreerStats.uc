//=============================================================================
// R6MenuCarreerStats - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCarreerStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/08 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCarreerStats extends UWindowWindow;

var int m_iPadding;
// NEW IN 1.60
var int m_iHeight;
var float m_fTitleHeight;
// NEW IN 1.60
var float m_fYOffSet;
// NEW IN 1.60
var float m_fXOffSet;
// NEW IN 1.60
var float m_fLabelHeight;
var float m_fLOpNameX;
var float m_fLOpNameW;
var R6WindowTextLabel m_LTitle;
// NEW IN 1.60
var R6WindowTextLabel m_LMissionServed;
// NEW IN 1.60
var R6WindowTextLabel m_LTerroKilled;
// NEW IN 1.60
var R6WindowTextLabel m_LRoundsFired;
// NEW IN 1.60
var R6WindowTextLabel m_LRoundsOnTarget;
// NEW IN 1.60
var R6WindowTextLabel m_LShootPercent;
var R6WindowTextLabel m_LOpName;
// NEW IN 1.60
var R6WindowTextLabel m_LOpSpecility;
// NEW IN 1.60
var R6WindowTextLabel m_LOpHealthStatus;
var R6WindowBitMap m_RainBowLogo;
var Texture m_TRainBowLogo;
var R6MenuCarreerOperative m_OperativeFace;
var Region m_RRainBowLogo;

function Created()
{
	local int YPos, XPos;

	m_LTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, m_fTitleHeight, self));
	m_LTitle.SetProperties(Localize("DebriefingMenu", "CARREERSTATS", "R6Menu"), 2, Root.Fonts[8], Root.Colors.BlueLight, false);
	YPos = int(m_fYOffSet);
	m_LMissionServed = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXOffSet, float(YPos), (WinWidth - m_fXOffSet), m_fLabelHeight, self));
	m_LMissionServed.SetProperties("", 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	(YPos += int(m_fLabelHeight));
	m_LTerroKilled = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXOffSet, float(YPos), (WinWidth - m_fXOffSet), m_fLabelHeight, self));
	m_LTerroKilled.SetProperties("", 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	(YPos += int(m_fLabelHeight));
	m_LRoundsFired = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXOffSet, float(YPos), (WinWidth - m_fXOffSet), m_fLabelHeight, self));
	m_LRoundsFired.SetProperties("", 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	(YPos += int(m_fLabelHeight));
	m_LRoundsOnTarget = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXOffSet, float(YPos), (WinWidth - m_fXOffSet), m_fLabelHeight, self));
	m_LRoundsOnTarget.SetProperties("", 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	(YPos += int(m_fLabelHeight));
	m_LShootPercent = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXOffSet, float(YPos), (WinWidth - m_fXOffSet), m_fLabelHeight, self));
	m_LShootPercent.SetProperties("", 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	m_RainBowLogo = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', 204.0000000, 31.0000000, float(m_RRainBowLogo.W), float(m_RRainBowLogo.H), self));
	m_RainBowLogo.t = m_TRainBowLogo;
	m_RainBowLogo.R = m_RRainBowLogo;
	m_RainBowLogo.m_iDrawStyle = 5;
	m_BorderColor = Root.Colors.GrayLight;
	m_OperativeFace = R6MenuCarreerOperative(CreateWindow(Class'R6Menu.R6MenuCarreerOperative', float(m_iPadding), 138.0000000, (WinWidth - float((2 * m_iPadding))), float(m_iHeight), self));
	m_LOpName = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fLOpNameX, m_OperativeFace.WinTop, m_fLOpNameW, (m_OperativeFace.WinHeight / float(3)), self));
	m_LOpName.m_bFixedYPos = true;
	m_LOpName.TextY = 16.0000000;
	m_LOpName.SetProperties("", 1, Root.Fonts[6], Root.Colors.White, false);
	m_LOpName.bAlwaysOnTop = true;
	m_LOpSpecility = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_LOpName.WinLeft, (m_LOpName.WinTop + m_LOpName.WinHeight), m_LOpName.WinWidth, m_LOpName.WinHeight, self));
	m_LOpSpecility.SetProperties("", 1, Root.Fonts[6], Root.Colors.White, false);
	m_LOpSpecility.bAlwaysOnTop = true;
	m_LOpHealthStatus = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_LOpName.WinLeft, (m_LOpSpecility.WinTop + m_LOpSpecility.WinHeight), m_LOpName.WinWidth, ((m_OperativeFace.WinHeight - m_LOpName.WinHeight) - m_LOpSpecility.WinHeight), self));
	m_LOpHealthStatus.m_bFixedYPos = true;
	m_LOpHealthStatus.TextY = 2.0000000;
	m_LOpHealthStatus.SetProperties("", 1, Root.Fonts[6], Root.Colors.White, false);
	m_LOpHealthStatus.bAlwaysOnTop = true;
	return;
}

//To change the current operative Carreer Stats
function UpdateStats(string _MissionServed, string _TerroKilled, string _RoundsShot, string _RoundsOnTarget, string _ShootPercent)
{
	m_LMissionServed.SetNewText((Localize("R6Operative", "NbMissions", "R6Menu") @ _MissionServed), true);
	m_LTerroKilled.SetNewText((Localize("R6Operative", "TerroKilled", "R6Menu") @ _TerroKilled), true);
	m_LRoundsFired.SetNewText((Localize("R6Operative", "RoundsFired", "R6Menu") @ _RoundsShot), true);
	m_LRoundsOnTarget.SetNewText((Localize("R6Operative", "RoundsOnTarget", "R6Menu") @ _RoundsOnTarget), true);
	m_LShootPercent.SetNewText((Localize("R6Operative", "ShootPercent", "R6Menu") @ _ShootPercent), true);
	return;
}

//To change the current Operative Face
function UpdateFace(Texture _Face, Region _FaceRegion)
{
	m_OperativeFace.setFace(_Face, _FaceRegion);
	return;
}

function UpdateTeam(int _Team)
{
	m_OperativeFace.SetTeam(_Team);
	return;
}

function UpdateName(string _szOpName)
{
	m_LOpName.SetNewText(_szOpName, true);
	return;
}

function UpdateSpeciality(string _szOpSpeciality)
{
	m_LOpSpecility.SetNewText(_szOpSpeciality, true);
	return;
}

function UpdateHealthStatus(string _szHealthStatus)
{
	m_LOpHealthStatus.SetNewText(_szHealthStatus, true);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, 0.0000000, m_fTitleHeight, WinWidth, (WinHeight - m_fTitleHeight));
	DrawSimpleBorder(C);
	DrawStretchedTextureSegment(C, 0.0000000, m_fTitleHeight, WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	return;
}

defaultproperties
{
	m_iPadding=2
	m_iHeight=85
	m_fTitleHeight=16.0000000
	m_fYOffSet=21.0000000
	m_fXOffSet=3.0000000
	m_fLabelHeight=18.0000000
	m_fLOpNameX=133.0000000
	m_fLOpNameW=140.0000000
	m_TRainBowLogo=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RRainBowLogo=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var y
// REMOVED IN 1.60: var s
