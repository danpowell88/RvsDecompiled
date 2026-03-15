//=============================================================================
// R6MenuWeaponStats - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuWeaponStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWeaponStats extends UWindowWindow;

var bool m_bDrawBorders;
var bool m_bDrawBG;
//Debug
var bool bShowLog;
//Stats
var float m_fInitRangePercent;
var float m_fInitDamagePercent;
var float m_fInitAccuracyPercent;
var float m_fInitRecoilPercent;
var float m_fInitRecoveryPercent;
var float m_fRangePercent;
var float m_fDamagePercent;
var float m_fAccuracyPercent;
var float m_fRecoilPercent;
var float m_fRecoveryPercent;
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
var R6MenuOperativeSkillsLabel m_TRange;
var R6MenuOperativeSkillsLabel m_TDamage;
var R6MenuOperativeSkillsLabel m_TAccuracy;
var R6MenuOperativeSkillsLabel m_TRecoil;
var R6MenuOperativeSkillsLabel m_TRecovery;
//LineCharts
var R6MenuOperativeSkillsBitmap m_LCRange;
var R6MenuOperativeSkillsBitmap m_LCDamage;
var R6MenuOperativeSkillsBitmap m_LCAccuracy;
var R6MenuOperativeSkillsBitmap m_LCRecoil;
var R6MenuOperativeSkillsBitmap m_LCRecovery;

function Created()
{
	local float X, Y, W, H, TotItemHeight, offset;

	X = m_fNLeftPadding;
	Y = m_fTopYPadding;
	W = (WinWidth - (float(2) * m_fNLeftPadding));
	H = m_fTitleHeight;
	TotItemHeight = ((m_fTitleHeight + float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H)) + (float(2) * m_fYPaddingBetweenElements));
	m_TRange = CreateTitle(X, Y, W, H, "Range");
	(Y += TotItemHeight);
	m_TDamage = CreateTitle(X, Y, W, H, "Damage");
	(Y += TotItemHeight);
	m_TAccuracy = CreateTitle(X, Y, W, H, "Accuracy");
	(Y += TotItemHeight);
	m_TRecoil = CreateTitle(X, Y, W, H, "Recoil");
	(Y += TotItemHeight);
	m_TRecovery = CreateTitle(X, Y, W, H, "Recovery");
	m_fMaxChartWidth = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.W);
	offset = (m_fTitleHeight + m_fYPaddingBetweenElements);
	Y = (m_TRange.WinTop + offset);
	H = float(Class'R6Menu.R6MenuOperativeSkillsBitmap'.default.R.H);
	m_LCRange = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TDamage.WinTop + offset);
	m_LCDamage = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TAccuracy.WinTop + offset);
	m_LCAccuracy = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TRecoil.WinTop + offset);
	m_LCRecoil = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	Y = (m_TRecovery.WinTop + offset);
	m_LCRecovery = R6MenuOperativeSkillsBitmap(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
	return;
}

function R6MenuOperativeSkillsLabel CreateTitle(float _fX, float _fY, float _fW, float _fH, string _szTitle)
{
	local R6MenuOperativeSkillsLabel pWSkillLabel;

	pWSkillLabel = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', _fX, _fY, _fW, _fH, self));
	pWSkillLabel.Text = Localize("GearRoom", _szTitle, "R6Menu");
	pWSkillLabel.m_fWidthOfFixArea = 60.0000000;
	pWSkillLabel.m_NumericValueColor = Root.Colors.BlueLight;
	return pWSkillLabel;
	return;
}

function ResizeCharts()
{
	// End:0x15D
	if(bShowLog)
	{
		Log("////////////////////////////////////////////");
		Log("///////  ResizeCharts() Before Fmin  ///////");
		Log("////////////////////////////////////////////");
		Log(("m_fRangePercent" @ string(m_fRangePercent)));
		Log(("m_fDamagePercent" @ string(m_fDamagePercent)));
		Log(("m_fAccuracyPercent" @ string(m_fAccuracyPercent)));
		Log(("m_fRecoilPercent" @ string(m_fRecoilPercent)));
		Log(("m_fRecoveryPercent" @ string(m_fRecoveryPercent)));
		Log("////////////////////////////////////////////");
	}
	m_fRangePercent = FMin(m_fRangePercent, 100.0000000);
	m_fDamagePercent = FMin(m_fDamagePercent, 100.0000000);
	m_fAccuracyPercent = FMin(m_fAccuracyPercent, 100.0000000);
	m_fRecoilPercent = FMin(m_fRecoilPercent, 100.0000000);
	m_fRecoveryPercent = FMin(m_fRecoveryPercent, 100.0000000);
	m_TRange.SetNumericValue(int(m_fInitRangePercent), int(m_fRangePercent));
	m_TDamage.SetNumericValue(int(m_fInitDamagePercent), int(m_fDamagePercent));
	m_TAccuracy.SetNumericValue(int(m_fInitAccuracyPercent), int(m_fAccuracyPercent));
	m_TRecoil.SetNumericValue(int(m_fInitRecoilPercent), int(m_fRecoilPercent));
	m_TRecovery.SetNumericValue(int(m_fInitRecoveryPercent), int(m_fRecoveryPercent));
	m_LCRange.WinWidth = ((m_fRangePercent * m_fMaxChartWidth) / 100.0000000);
	m_LCDamage.WinWidth = ((m_fDamagePercent * m_fMaxChartWidth) / 100.0000000);
	m_LCAccuracy.WinWidth = ((m_fAccuracyPercent * m_fMaxChartWidth) / 100.0000000);
	m_LCRecoil.WinWidth = ((m_fRecoilPercent * m_fMaxChartWidth) / 100.0000000);
	m_LCRecovery.WinWidth = ((m_fRecoveryPercent * m_fMaxChartWidth) / 100.0000000);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x37
	if(m_bDrawBG)
	{
		R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, 0.0000000, 0.0000000, WinWidth, WinHeight);
	}
	// End:0x4B
	if(m_bDrawBorders)
	{
		DrawSimpleBorder(C);
	}
	return;
}

defaultproperties
{
	m_bDrawBorders=true
	m_bDrawBG=true
	m_fRangePercent=100.0000000
	m_fDamagePercent=100.0000000
	m_fAccuracyPercent=100.0000000
	m_fRecoilPercent=100.0000000
	m_fRecoveryPercent=100.0000000
	m_fNLeftPadding=7.0000000
	m_fBetweenLabelPadding=7.0000000
	m_fTopYPadding=7.0000000
	m_fTitleHeight=12.0000000
	m_fYPaddingBetweenElements=6.0000000
	m_fNumericLabelWidth=30.0000000
}
