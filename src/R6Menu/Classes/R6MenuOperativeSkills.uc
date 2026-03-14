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
	W = __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fNLeftPadding));
	H = m_fTitleHeight;
	TotItemHeight = __NFUN_174__(__NFUN_174__(m_fTitleHeight, float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H)), __NFUN_171__(float(2), m_fYPaddingBetweenElements));
	m_TAssault = CreateTitle(X, Y, W, H, "Assault");
	__NFUN_184__(Y, TotItemHeight);
	m_TDemolitions = CreateTitle(X, Y, W, H, "Demolitions");
	__NFUN_184__(Y, TotItemHeight);
	m_TElectronics = CreateTitle(X, Y, W, H, "Electronics");
	__NFUN_184__(Y, TotItemHeight);
	m_TSniper = CreateTitle(X, Y, W, H, "Sniper");
	__NFUN_184__(Y, TotItemHeight);
	m_TStealth = CreateTitle(X, Y, W, H, "Stealth");
	__NFUN_184__(Y, TotItemHeight);
	m_TSelfControl = CreateTitle(X, Y, W, H, "SelfControl");
	__NFUN_184__(Y, TotItemHeight);
	m_TLeadership = CreateTitle(X, Y, W, H, "Leadership");
	__NFUN_184__(Y, TotItemHeight);
	m_TObservation = CreateTitle(X, Y, W, H, "Observation");
	m_fMaxChartWidth = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.W);
	offset = __NFUN_174__(m_fTitleHeight, m_fYPaddingBetweenElements);
	Y = __NFUN_174__(m_TAssault.WinTop, offset);
	H = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H);
	m_LCAssault = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TDemolitions.WinTop, offset);
	m_LCDemolitions = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TElectronics.WinTop, offset);
	m_LCElectronics = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TSniper.WinTop, offset);
	m_LCSniper = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TStealth.WinTop, offset);
	m_LCStealth = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TSelfControl.WinTop, offset);
	m_LCSelfControl = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TLeadership.WinTop, offset);
	m_LCLeadership = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = __NFUN_174__(m_TObservation.WinTop, offset);
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
	m_fAssault = __NFUN_244__(__NFUN_174__(m_fAssault, 0.5000000), 100.0000000);
	m_fDemolitions = __NFUN_244__(__NFUN_174__(m_fDemolitions, 0.5000000), 100.0000000);
	m_fElectronics = __NFUN_244__(__NFUN_174__(m_fElectronics, 0.5000000), 100.0000000);
	m_fSniper = __NFUN_244__(__NFUN_174__(m_fSniper, 0.5000000), 100.0000000);
	m_fStealth = __NFUN_244__(__NFUN_174__(m_fStealth, 0.5000000), 100.0000000);
	m_fSelfControl = __NFUN_244__(__NFUN_174__(m_fSelfControl, 0.5000000), 100.0000000);
	m_fLeadership = __NFUN_244__(__NFUN_174__(m_fLeadership, 0.5000000), 100.0000000);
	m_fObservation = __NFUN_244__(__NFUN_174__(m_fObservation, 0.5000000), 100.0000000);
	m_TAssault.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fAssault, 0.5000000)), int(m_fAssault));
	m_TDemolitions.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fDemolitions, 0.5000000)), int(m_fDemolitions));
	m_TElectronics.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fElectronics, 0.5000000)), int(m_fElectronics));
	m_TSniper.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fSniper, 0.5000000)), int(m_fSniper));
	m_TStealth.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fStealth, 0.5000000)), int(m_fStealth));
	m_TSelfControl.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fSelfControl, 0.5000000)), int(m_fSelfControl));
	m_TLeadership.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fLeadership, 0.5000000)), int(m_fLeadership));
	m_TObservation.SetNumericValue(int(__NFUN_174__(_CurrentOperative.default.m_fObservation, 0.5000000)), int(m_fObservation));
	m_LCAssault.WinWidth = __NFUN_172__(__NFUN_171__(m_fAssault, m_fMaxChartWidth), 100.0000000);
	m_LCDemolitions.WinWidth = __NFUN_172__(__NFUN_171__(m_fDemolitions, m_fMaxChartWidth), 100.0000000);
	m_LCElectronics.WinWidth = __NFUN_172__(__NFUN_171__(m_fElectronics, m_fMaxChartWidth), 100.0000000);
	m_LCSniper.WinWidth = __NFUN_172__(__NFUN_171__(m_fSniper, m_fMaxChartWidth), 100.0000000);
	m_LCStealth.WinWidth = __NFUN_172__(__NFUN_171__(m_fStealth, m_fMaxChartWidth), 100.0000000);
	m_LCSelfControl.WinWidth = __NFUN_172__(__NFUN_171__(m_fSelfControl, m_fMaxChartWidth), 100.0000000);
	m_LCLeadership.WinWidth = __NFUN_172__(__NFUN_171__(m_fLeadership, m_fMaxChartWidth), 100.0000000);
	m_LCObservation.WinWidth = __NFUN_172__(__NFUN_171__(m_fObservation, m_fMaxChartWidth), 100.0000000);
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
