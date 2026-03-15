//=============================================================================
// R6MenuOperativeSkills - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuOperativeSkills.uc : This Window Will display the skills of an operative
//                              and is created by R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeSkills extends UWindowWindow;

//Debug
var bool bShowLog;
//Skills
var float m_fAssault;
var float m_fDemolitions;
var float m_fElectronics;
var float m_fSniper;
var float m_fStealth;
var float m_fSelfControl;
var float m_fLeadership;
var float m_fObservation;
//Maximum Width for line charts
var float m_fMaxChartWidth;
//Display settings
var float m_fNLeftPadding;  // Horizontal padding where we start drawing from left
var float m_fBetweenLabelPadding;  // Horizontal Padding Between the numeric values and the charts
var float m_fTopYPadding;  // Vertical Padding from the top of the window
var float m_fTitleHeight;  // Titles Height
var float m_fYPaddingBetweenElements;  // Vertical Padding Between Lines
var float m_fNumericLabelWidth;
//Titles
var R6MenuOperativeSkillsLabel m_TAssault;
var R6MenuOperativeSkillsLabel m_TDemolitions;
var R6MenuOperativeSkillsLabel m_TElectronics;
var R6MenuOperativeSkillsLabel m_TSniper;
var R6MenuOperativeSkillsLabel m_TStealth;
var R6MenuOperativeSkillsLabel m_TSelfControl;
var R6MenuOperativeSkillsLabel m_TLeadership;
var R6MenuOperativeSkillsLabel m_TObservation;
//LineCharts
var R6MenuOperativeSkillsBitmap m_LCAssault;
var R6MenuOperativeSkillsBitmap m_LCDemolitions;
var R6MenuOperativeSkillsBitmap m_LCElectronics;
var R6MenuOperativeSkillsBitmap m_LCSniper;
var R6MenuOperativeSkillsBitmap m_LCStealth;
var R6MenuOperativeSkillsBitmap m_LCSelfControl;
var R6MenuOperativeSkillsBitmap m_LCLeadership;
var R6MenuOperativeSkillsBitmap m_LCObservation;

function Created()
{
	local float X, Y, W, H, TotItemHeight, offset;

	X = m_fNLeftPadding;
	Y = m_fTopYPadding;
	W = (WinWidth - (float(2) * m_fNLeftPadding));
	H = m_fTitleHeight;
	TotItemHeight = ((m_fTitleHeight + float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H)) + (float(2) * m_fYPaddingBetweenElements));
	m_TAssault = CreateTitle(X, Y, W, H, "Assault");
	(Y += TotItemHeight);
	m_TDemolitions = CreateTitle(X, Y, W, H, "Demolitions");
	(Y += TotItemHeight);
	m_TElectronics = CreateTitle(X, Y, W, H, "Electronics");
	(Y += TotItemHeight);
	m_TSniper = CreateTitle(X, Y, W, H, "Sniper");
	(Y += TotItemHeight);
	m_TStealth = CreateTitle(X, Y, W, H, "Stealth");
	(Y += TotItemHeight);
	m_TSelfControl = CreateTitle(X, Y, W, H, "SelfControl");
	(Y += TotItemHeight);
	m_TLeadership = CreateTitle(X, Y, W, H, "Leadership");
	(Y += TotItemHeight);
	m_TObservation = CreateTitle(X, Y, W, H, "Observation");
	m_fMaxChartWidth = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.W);
	offset = (m_fTitleHeight + m_fYPaddingBetweenElements);
	Y = (m_TAssault.WinTop + offset);
	H = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H);
	m_LCAssault = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TDemolitions.WinTop + offset);
	m_LCDemolitions = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TElectronics.WinTop + offset);
	m_LCElectronics = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TSniper.WinTop + offset);
	m_LCSniper = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TStealth.WinTop + offset);
	m_LCStealth = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TSelfControl.WinTop + offset);
	m_LCSelfControl = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TLeadership.WinTop + offset);
	m_LCLeadership = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TObservation.WinTop + offset);
	m_LCObservation = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	return;
}

function R6MenuOperativeSkillsLabel CreateTitle(float _fX, float _fY, float _fW, float _fH, string _szTitle)
{
	local R6MenuOperativeSkillsLabel pWSkillLabel;

	pWSkillLabel = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', _fX, _fY, _fW, _fH, self));
	pWSkillLabel.Text = Localize("R6Operative", _szTitle, "R6Menu");
	pWSkillLabel.m_fWidthOfFixArea = 60.0000000;
	pWSkillLabel.m_NumericValueColor = Root.Colors.BlueLight;
	return pWSkillLabel;
	return;
}

function ResizeCharts(R6Operative _CurrentOperative)
{
	m_fAssault = FMin((m_fAssault + 0.5000000), 100.0000000);
	m_fDemolitions = FMin((m_fDemolitions + 0.5000000), 100.0000000);
	m_fElectronics = FMin((m_fElectronics + 0.5000000), 100.0000000);
	m_fSniper = FMin((m_fSniper + 0.5000000), 100.0000000);
	m_fStealth = FMin((m_fStealth + 0.5000000), 100.0000000);
	m_fSelfControl = FMin((m_fSelfControl + 0.5000000), 100.0000000);
	m_fLeadership = FMin((m_fLeadership + 0.5000000), 100.0000000);
	m_fObservation = FMin((m_fObservation + 0.5000000), 100.0000000);
	m_TAssault.SetNumericValue(int((_CurrentOperative.default.m_fAssault + 0.5000000)), int(m_fAssault));
	m_TDemolitions.SetNumericValue(int((_CurrentOperative.default.m_fDemolitions + 0.5000000)), int(m_fDemolitions));
	m_TElectronics.SetNumericValue(int((_CurrentOperative.default.m_fElectronics + 0.5000000)), int(m_fElectronics));
	m_TSniper.SetNumericValue(int((_CurrentOperative.default.m_fSniper + 0.5000000)), int(m_fSniper));
	m_TStealth.SetNumericValue(int((_CurrentOperative.default.m_fStealth + 0.5000000)), int(m_fStealth));
	m_TSelfControl.SetNumericValue(int((_CurrentOperative.default.m_fSelfControl + 0.5000000)), int(m_fSelfControl));
	m_TLeadership.SetNumericValue(int((_CurrentOperative.default.m_fLeadership + 0.5000000)), int(m_fLeadership));
	m_TObservation.SetNumericValue(int((_CurrentOperative.default.m_fObservation + 0.5000000)), int(m_fObservation));
	m_LCAssault.WinWidth = ((m_fAssault * m_fMaxChartWidth) / 100.0000000);
	m_LCDemolitions.WinWidth = ((m_fDemolitions * m_fMaxChartWidth) / 100.0000000);
	m_LCElectronics.WinWidth = ((m_fElectronics * m_fMaxChartWidth) / 100.0000000);
	m_LCSniper.WinWidth = ((m_fSniper * m_fMaxChartWidth) / 100.0000000);
	m_LCStealth.WinWidth = ((m_fStealth * m_fMaxChartWidth) / 100.0000000);
	m_LCSelfControl.WinWidth = ((m_fSelfControl * m_fMaxChartWidth) / 100.0000000);
	m_LCLeadership.WinWidth = ((m_fLeadership * m_fMaxChartWidth) / 100.0000000);
	m_LCObservation.WinWidth = ((m_fObservation * m_fMaxChartWidth) / 100.0000000);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, 0.0000000, 0.0000000, WinWidth, WinHeight);
	return;
}

defaultproperties
{
	m_fAssault=100.0000000
	m_fDemolitions=100.0000000
	m_fElectronics=100.0000000
	m_fSniper=100.0000000
	m_fStealth=100.0000000
	m_fSelfControl=100.0000000
	m_fLeadership=100.0000000
	m_fObservation=100.0000000
	m_fNLeftPadding=7.0000000
	m_fBetweenLabelPadding=7.0000000
	m_fTopYPadding=7.0000000
	m_fTitleHeight=12.0000000
	m_fYPaddingBetweenElements=6.0000000
	m_fNumericLabelWidth=30.0000000
}
