//=============================================================================
// R6MenuOperativeStats - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuOperativeStats.uc : This class will provode us with an 
//                              view of an operative stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeStats extends UWindowWindow;

//Debug
var bool bShowLog;
//Display settings
var float m_fHSidePadding;  // Horizontal padding where we start drawing from left and right
var float m_fTileLabelWidth;
var float m_fTopYPadding;  // Vertical Padding from the top of the window
var float m_fTitleHeight;  // Titles Height
var float m_fValueLabelWidth;
var float m_fYPaddingBetweenElements;  // Vertical Padding Between Lines
//Titles
var R6MenuOperativeSkillsLabel m_TNbMissions;
var R6MenuOperativeSkillsLabel m_TTerroKilled;
var R6MenuOperativeSkillsLabel m_TRoundsFired;
var R6MenuOperativeSkillsLabel m_TRoundsOnTarget;
var R6MenuOperativeSkillsLabel m_TShootPercent;
var R6MenuOperativeSkillsLabel m_TGender;
//Values Labels
var R6MenuOperativeSkillsLabel m_NNbMissions;
var R6MenuOperativeSkillsLabel m_NTerroKilled;
var R6MenuOperativeSkillsLabel m_NRoundsFired;
var R6MenuOperativeSkillsLabel m_NRoundsOnTarget;
var R6MenuOperativeSkillsLabel m_NShootPercent;
var R6MenuOperativeSkillsLabel m_NGender;

function Created()
{
	local float Y, X, TitlesHeight, ValuesHeight;

	TitlesHeight = (m_fTitleHeight + m_fYPaddingBetweenElements);
	ValuesHeight = float(Class'R6Menu.R6MenuOperativeSkillsLabel'.default.m_BGTextureRegion.H);
	m_TNbMissions = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, m_fTopYPadding, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TNbMissions.Text = Localize("R6Operative", "NbMissions", "R6Menu");
	m_TNbMissions.m_BGTexture = none;
	Y = (m_TNbMissions.WinTop + TitlesHeight);
	m_TTerroKilled = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TTerroKilled.Text = Localize("R6Operative", "TerroKilled", "R6Menu");
	m_TTerroKilled.m_BGTexture = none;
	Y = (m_TTerroKilled.WinTop + TitlesHeight);
	m_TRoundsFired = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TRoundsFired.Text = Localize("R6Operative", "RoundsFired", "R6Menu");
	m_TRoundsFired.m_BGTexture = none;
	Y = (m_TRoundsFired.WinTop + TitlesHeight);
	m_TRoundsOnTarget = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TRoundsOnTarget.Text = Localize("R6Operative", "RoundsOnTarget", "R6Menu");
	m_TRoundsOnTarget.m_BGTexture = none;
	Y = (m_TRoundsOnTarget.WinTop + TitlesHeight);
	m_TShootPercent = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TShootPercent.Text = Localize("R6Operative", "ShootPercent", "R6Menu");
	m_TShootPercent.m_BGTexture = none;
	X = ((WinWidth - m_fValueLabelWidth) - m_fHSidePadding);
	Y = m_TNbMissions.WinTop;
	m_NNbMissions = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NNbMissions.Align = 1;
	Y = m_TTerroKilled.WinTop;
	m_NTerroKilled = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NTerroKilled.Align = 1;
	Y = m_TRoundsFired.WinTop;
	m_NRoundsFired = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NRoundsFired.Align = 1;
	Y = m_TRoundsOnTarget.WinTop;
	m_NRoundsOnTarget = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NRoundsOnTarget.Align = 1;
	Y = m_TShootPercent.WinTop;
	m_NShootPercent = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NShootPercent.Align = 1;
	return;
}

function SetNbMissions(string _szNbMissions)
{
	m_NNbMissions.SetNewText(_szNbMissions, true);
	return;
}

function SeTTerroKilled(string _szTerroKilled)
{
	m_NTerroKilled.SetNewText(_szTerroKilled, true);
	return;
}

function SetRoundsFired(string _szRoundsFired)
{
	m_NRoundsFired.SetNewText(_szRoundsFired, true);
	return;
}

function SetRoundsOnTarget(string _szRoundsOnTarget)
{
	m_NRoundsOnTarget.SetNewText(_szRoundsOnTarget, true);
	return;
}

function SetShootPercent(string _szShootPercent)
{
	m_NShootPercent.SetNewText(_szShootPercent, true);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, 0.0000000, 0.0000000, WinWidth, WinHeight);
	return;
}

defaultproperties
{
	m_fHSidePadding=5.0000000
	m_fTileLabelWidth=148.0000000
	m_fTopYPadding=7.0000000
	m_fTitleHeight=12.0000000
	m_fValueLabelWidth=32.0000000
	m_fYPaddingBetweenElements=3.0000000
}
