//=============================================================================
// R6MenuOperativeBio - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuOperativeBio.uc : This Class Should Provide us with a window displaying
//                              an operative bio details in a R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeBio extends UWindowWindow;

//Debug
var bool bShowLog;
//Display settings
var float m_fHSidePadding;  // Horizontal padding where we start drawing from left and right
var float m_fTileLabelWidth;
var float m_fTopYPadding;  // Vertical Padding from the top of the window
var float m_fTitleHeight;  // Titles Height
var float m_fValueLabelWidth;
var float m_fYPaddingBetweenElements;  // Vertical Padding Between Lines
var float m_fHealthHeight;
//Titles
var R6MenuOperativeSkillsLabel m_TDateBirth;
var R6MenuOperativeSkillsLabel m_THeight;
var R6MenuOperativeSkillsLabel m_TWeight;
var R6MenuOperativeSkillsLabel m_THair;
var R6MenuOperativeSkillsLabel m_TEyes;
var R6MenuOperativeSkillsLabel m_TGender;
var R6WindowTextLabel m_TStatus;
//Values Labels
var R6MenuOperativeSkillsLabel m_NDateBirth;
var R6MenuOperativeSkillsLabel m_NHeight;
var R6MenuOperativeSkillsLabel m_NWeight;
var R6MenuOperativeSkillsLabel m_NHair;
var R6MenuOperativeSkillsLabel m_NEyes;
var R6MenuOperativeSkillsLabel m_NGender;

function Created()
{
	local float Y, X, TitlesHeight, ValuesHeight;

	TitlesHeight = __NFUN_174__(m_fTitleHeight, m_fYPaddingBetweenElements);
	ValuesHeight = float(Class'R6Menu.R6MenuOperativeSkillsLabel'.default.m_BGTextureRegion.H);
	m_TDateBirth = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, m_fTopYPadding, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TDateBirth.Text = Localize("R6Operative", "DateBirth", "R6Menu");
	m_TDateBirth.m_BGTexture = none;
	Y = __NFUN_174__(m_TDateBirth.WinTop, TitlesHeight);
	m_THeight = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_THeight.Text = Localize("R6Operative", "Height", "R6Menu");
	m_THeight.m_BGTexture = none;
	Y = __NFUN_174__(m_THeight.WinTop, TitlesHeight);
	m_TWeight = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TWeight.Text = Localize("R6Operative", "Weight", "R6Menu");
	m_TWeight.m_BGTexture = none;
	Y = __NFUN_174__(m_TWeight.WinTop, TitlesHeight);
	m_THair = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_THair.Text = Localize("R6Operative", "Hair", "R6Menu");
	m_THair.m_BGTexture = none;
	Y = __NFUN_174__(m_THair.WinTop, TitlesHeight);
	m_TEyes = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TEyes.Text = Localize("R6Operative", "Eyes", "R6Menu");
	m_TEyes.m_BGTexture = none;
	Y = __NFUN_174__(m_TEyes.WinTop, TitlesHeight);
	m_TGender = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', m_fHSidePadding, Y, m_fTileLabelWidth, m_fTitleHeight, self));
	m_TGender.Text = Localize("R6Operative", "Gender", "R6Menu");
	m_TGender.m_BGTexture = none;
	X = __NFUN_175__(__NFUN_175__(WinWidth, m_fValueLabelWidth), m_fHSidePadding);
	Y = m_TDateBirth.WinTop;
	m_NDateBirth = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NDateBirth.Align = 0;
	Y = m_THeight.WinTop;
	m_NHeight = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NHeight.Align = 0;
	Y = m_TWeight.WinTop;
	m_NWeight = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NWeight.Align = 0;
	Y = m_THair.WinTop;
	m_NHair = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NHair.Align = 0;
	Y = m_TEyes.WinTop;
	m_NEyes = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NEyes.Align = 0;
	Y = m_TGender.WinTop;
	m_NGender = R6MenuOperativeSkillsLabel(CreateWindow(Class'R6Menu.R6MenuOperativeSkillsLabel', X, Y, m_fValueLabelWidth, ValuesHeight, self));
	m_NGender.Align = 0;
	m_TStatus = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, __NFUN_175__(WinHeight, m_fHealthHeight), WinWidth, m_fHealthHeight, self));
	m_TStatus.m_bDrawBorders = true;
	m_TStatus.m_BGTexture = none;
	m_TStatus.Align = 2;
	m_TStatus.m_Font = Root.Fonts[5];
	m_TStatus.m_BorderColor = m_BorderColor;
	m_TStatus.TextColor = Root.Colors.White;
	return;
}

function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	m_TStatus.m_BorderColor = _NewColor;
	return;
}

function SetBirthDate(string _szBirthDate)
{
	m_NDateBirth.Text = _szBirthDate;
	return;
}

function SetHeight(string _szHeight)
{
	m_NHeight.Text = _szHeight;
	return;
}

function SetWeight(string _szWeight)
{
	m_NWeight.Text = _szWeight;
	return;
}

function SetHairColor(string _szHair)
{
	m_NHair.Text = _szHair;
	return;
}

function SetEyesColor(string _szEyes)
{
	m_NEyes.Text = _szEyes;
	return;
}

function SetGender(string _szGender)
{
	m_NGender.Text = _szGender;
	return;
}

function SetHealthStatus(string _Health)
{
	m_TStatus.SetNewText(_Health, true);
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
	m_fTileLabelWidth=90.0000000
	m_fTopYPadding=7.0000000
	m_fTitleHeight=12.0000000
	m_fValueLabelWidth=84.0000000
	m_fYPaddingBetweenElements=3.0000000
	m_fHealthHeight=20.0000000
}
