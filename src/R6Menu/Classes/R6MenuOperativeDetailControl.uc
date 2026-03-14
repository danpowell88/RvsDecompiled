//=============================================================================
// R6MenuOperativeDetailControl - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuOperativeDetailControl.uc : This will provide fonctionalities
//                                      to get operative descriptions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeDetailControl extends UWindowDialogClientWindow;

var int m_ITopLineYPos;
// NEW IN 1.60
var int m_IBottomLineYPos;
var bool m_bUpdateOperativeText;
var R6MenuOperativeDetailRadioArea m_TopButtons;
var R6MenuOperativeHistory m_HistoryPage;
var R6MenuOperativeSkills m_SkillsPage;
var R6MenuOperativeBio m_BioPage;
var R6MenuOperativeStats m_StatsPage;
var R6WindowBitMap m_OperativeFace;
var UWindowWindow m_CurrentPage;

function Created()
{
	local float fYOffset, fHeight;

	m_BorderColor = Root.Colors.GrayLight;
	m_TopButtons = R6MenuOperativeDetailRadioArea(CreateWindow(Class'R6Menu.R6MenuOperativeDetailRadioArea', 0.0000000, 0.0000000, WinWidth, 23.0000000, self));
	m_TopButtons.m_BorderColor = m_BorderColor;
	fYOffset = __NFUN_174__(m_TopButtons.WinTop, m_TopButtons.WinHeight);
	m_OperativeFace = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', 0.0000000, fYOffset, WinWidth, 81.0000000, self));
	m_OperativeFace.m_BorderColor = m_BorderColor;
	m_OperativeFace.m_bDrawBorder = false;
	m_OperativeFace.bCenter = true;
	fYOffset = __NFUN_174__(m_OperativeFace.WinTop, m_OperativeFace.WinHeight);
	fHeight = __NFUN_175__(WinHeight, __NFUN_174__(m_TopButtons.WinHeight, m_OperativeFace.WinHeight));
	m_HistoryPage = R6MenuOperativeHistory(CreateWindow(Class'R6Menu.R6MenuOperativeHistory', 0.0000000, fYOffset, WinWidth, fHeight, self));
	m_HistoryPage.SetBorderColor(m_BorderColor);
	m_HistoryPage.HideWindow();
	m_SkillsPage = R6MenuOperativeSkills(CreateWindow(Class'R6Menu.R6MenuOperativeSkills', 0.0000000, fYOffset, WinWidth, fHeight, self));
	m_SkillsPage.m_BorderColor = m_BorderColor;
	m_SkillsPage.HideWindow();
	m_BioPage = R6MenuOperativeBio(CreateWindow(Class'R6Menu.R6MenuOperativeBio', 0.0000000, fYOffset, WinWidth, fHeight, self));
	m_BioPage.SetBorderColor(m_BorderColor);
	m_BioPage.HideWindow();
	m_StatsPage = R6MenuOperativeStats(CreateWindow(Class'R6Menu.R6MenuOperativeStats', 0.0000000, fYOffset, WinWidth, fHeight, self));
	m_StatsPage.m_BorderColor = m_BorderColor;
	m_StatsPage.HideWindow();
	m_CurrentPage = m_SkillsPage;
	m_CurrentPage.ShowWindow();
	m_ITopLineYPos = int(__NFUN_174__(m_TopButtons.WinTop, m_TopButtons.WinHeight));
	m_IBottomLineYPos = int(__NFUN_175__(__NFUN_174__(m_OperativeFace.WinTop, m_OperativeFace.WinHeight), float(1)));
	return;
}

function UpdateDetails()
{
	local R6Operative currentOperative;
	local Region RMenuFace;

	currentOperative = R6MenuGearWidget(OwnerWindow).m_currentOperative;
	RMenuFace.X = currentOperative.m_RMenuFaceX;
	RMenuFace.Y = currentOperative.m_RMenuFaceY;
	RMenuFace.W = currentOperative.m_RMenuFaceW;
	RMenuFace.H = currentOperative.m_RMenuFaceH;
	setFace(currentOperative.m_TMenuFace, RMenuFace);
	m_bUpdateOperativeText = true;
	m_SkillsPage.m_fAssault = currentOperative.m_fAssault;
	m_SkillsPage.m_fDemolitions = currentOperative.m_fDemolitions;
	m_SkillsPage.m_fElectronics = currentOperative.m_fElectronics;
	m_SkillsPage.m_fSniper = currentOperative.m_fSniper;
	m_SkillsPage.m_fStealth = currentOperative.m_fStealth;
	m_SkillsPage.m_fSelfControl = currentOperative.m_fSelfControl;
	m_SkillsPage.m_fLeadership = currentOperative.m_fLeadership;
	m_SkillsPage.m_fObservation = currentOperative.m_fObservation;
	m_SkillsPage.ResizeCharts(currentOperative);
	m_BioPage.SetBirthDate(currentOperative.GetBirthDate());
	m_BioPage.SetHeight(currentOperative.GetHeight());
	m_BioPage.SetWeight(currentOperative.GetWeight());
	m_BioPage.SetHairColor(currentOperative.GetHairColor());
	m_BioPage.SetEyesColor(currentOperative.GetEyesColor());
	m_BioPage.SetGender(currentOperative.GetGender());
	m_BioPage.SetHealthStatus(currentOperative.GetHealthStatus());
	m_StatsPage.SetNbMissions(currentOperative.GetNbMissionPlayed());
	m_StatsPage.SeTTerroKilled(currentOperative.GetNbTerrokilled());
	m_StatsPage.SetRoundsFired(currentOperative.GetNbRoundsfired());
	m_StatsPage.SetRoundsOnTarget(currentOperative.GetNbRoundsOnTarget());
	m_StatsPage.SetShootPercent(currentOperative.GetShootPercent());
	return;
}

function ChangePage(int ButtonID)
{
	m_CurrentPage.HideWindow();
	switch(ButtonID)
	{
		// End:0x28
		case 1:
			m_CurrentPage = m_HistoryPage;
			// End:0x64
			break;
		// End:0x3B
		case 2:
			m_CurrentPage = m_SkillsPage;
			// End:0x64
			break;
		// End:0x4E
		case 3:
			m_CurrentPage = m_BioPage;
			// End:0x64
			break;
		// End:0x61
		case 4:
			m_CurrentPage = m_StatsPage;
			// End:0x64
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_CurrentPage.ShowWindow();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local R6Operative currentOperative;

	currentOperative = R6MenuGearWidget(OwnerWindow).m_currentOperative;
	// End:0x4D
	if(m_bUpdateOperativeText)
	{
		m_HistoryPage.SetText(C, currentOperative.GetHistory());
		m_bUpdateOperativeText = false;
	}
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	C.Style = 5;
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTexture(C, 0.0000000, float(m_ITopLineYPos), WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	DrawStretchedTexture(C, 0.0000000, float(m_IBottomLineYPos), WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function setFace(Texture newFace, Region _R)
{
	m_OperativeFace.t = newFace;
	m_OperativeFace.R = _R;
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var s
