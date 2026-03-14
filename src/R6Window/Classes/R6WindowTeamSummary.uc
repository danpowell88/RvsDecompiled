//=============================================================================
// R6WindowTeamSummary - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTeamSummary.uc : Team summary in execute screen there is one for each team
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTeamSummary extends UWindowWindow;

var bool m_bIsSelected;
var float m_fSummaryHeight;
// NEW IN 1.60
var float m_fOperativeSummaryHeight;
// NEW IN 1.60
var float m_fYPaddingBetweenElements;
var R6Operative m_teamOperatives[4];
var R6WindowOperativePlanningSummary m_OperativeSummary[4];
var R6WindowTeamPlanningSummary m_TeamPlanningSummary;

function Created()
{
	m_TeamPlanningSummary = R6WindowTeamPlanningSummary(CreateWindow(Class'R6Window.R6WindowTeamPlanningSummary', 0.0000000, 0.0000000, WinWidth, m_fSummaryHeight, self));
	m_OperativeSummary[0] = R6WindowOperativePlanningSummary(CreateWindow(Class'R6Window.R6WindowOperativePlanningSummary', 0.0000000, __NFUN_174__(__NFUN_174__(m_TeamPlanningSummary.WinTop, m_TeamPlanningSummary.WinHeight), m_fYPaddingBetweenElements), WinWidth, m_fOperativeSummaryHeight, self));
	m_OperativeSummary[1] = R6WindowOperativePlanningSummary(CreateWindow(Class'R6Window.R6WindowOperativePlanningSummary', 0.0000000, __NFUN_174__(__NFUN_174__(m_OperativeSummary[0].WinTop, m_OperativeSummary[0].WinHeight), m_fYPaddingBetweenElements), WinWidth, m_fOperativeSummaryHeight, self));
	m_OperativeSummary[2] = R6WindowOperativePlanningSummary(CreateWindow(Class'R6Window.R6WindowOperativePlanningSummary', 0.0000000, __NFUN_174__(__NFUN_174__(m_OperativeSummary[1].WinTop, m_OperativeSummary[1].WinHeight), m_fYPaddingBetweenElements), WinWidth, m_fOperativeSummaryHeight, self));
	m_OperativeSummary[3] = R6WindowOperativePlanningSummary(CreateWindow(Class'R6Window.R6WindowOperativePlanningSummary', 0.0000000, __NFUN_174__(__NFUN_174__(m_OperativeSummary[2].WinTop, m_OperativeSummary[2].WinHeight), m_fYPaddingBetweenElements), WinWidth, m_fOperativeSummaryHeight, self));
	return;
}

function Init()
{
	m_teamOperatives[0] = none;
	m_teamOperatives[1] = none;
	m_teamOperatives[2] = none;
	m_teamOperatives[3] = none;
	m_OperativeSummary[0].HideWindow();
	m_OperativeSummary[1].HideWindow();
	m_OperativeSummary[2].HideWindow();
	m_OperativeSummary[3].HideWindow();
	return;
}

function AddOperative(R6Operative _Operative)
{
	local int addedOperative;
	local string szPrimaryWeapon, szArmor;
	local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
	local Class<R6ArmorDescription> ArmorDescriptionClass;
	local Region R;

	addedOperative = OperativeCount();
	// End:0x1A
	if(__NFUN_154__(addedOperative, 4))
	{
		return;
	}
	m_teamOperatives[addedOperative] = _Operative;
	m_OperativeSummary[addedOperative].ShowWindow();
	PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(_Operative.m_szPrimaryWeapon, Class'Core.Class'));
	szPrimaryWeapon = Localize(PrimaryWeaponClass.default.m_NameID, "ID_SHORTNAME", "R6Weapons", true);
	ArmorDescriptionClass = Class<R6ArmorDescription>(DynamicLoadObject(_Operative.m_szArmor, Class'Core.Class'));
	szArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor", true, true);
	R.X = _Operative.m_RMenuFaceSmallX;
	R.Y = _Operative.m_RMenuFaceSmallY;
	R.W = _Operative.m_RMenuFaceSmallW;
	R.H = _Operative.m_RMenuFaceSmallH;
	m_OperativeSummary[addedOperative].setLabels(szPrimaryWeapon, szArmor, _Operative.GetName());
	m_OperativeSummary[addedOperative].setFace(_Operative.m_TMenuFaceSmall, R);
	m_OperativeSummary[addedOperative].setHealth(GetOpHealth(_Operative));
	m_OperativeSummary[addedOperative].setSpeciality(GetSpeciality(_Operative));
	return;
}

function TexRegion GetOpHealth(R6Operative _Operative)
{
	local TexRegion Result;

	switch(_Operative.m_iHealth)
	{
		// End:0x4B
		case 0:
			Result.X = 31;
			Result.Y = 29;
			Result.W = 10;
			Result.H = 10;
			// End:0xCA
			break;
		// End:0x86
		case 1:
			Result.X = 42;
			Result.Y = 29;
			Result.W = 10;
			Result.H = 10;
			// End:0xCA
			break;
		// End:0x8B
		case 2:
		// End:0xC7
		case 3:
			Result.X = 53;
			Result.Y = 29;
			Result.W = 10;
			Result.H = 10;
			// End:0xCA
			break;
		// End:0xFFFF
		default:
			break;
	}
	Result.t = Texture'R6MenuTextures.Credits.TeamBarIcon';
	return Result;
	return;
}

function TexRegion GetSpeciality(R6Operative _Operative)
{
	local TexRegion Result;

	// End:0x56
	if(__NFUN_122__(_Operative.m_szSpecialityID, "ID_ASSAULT"))
	{
		Result.X = 229;
		Result.Y = 10;
		Result.W = 9;
		Result.H = 9;		
	}
	else
	{
		// End:0xAB
		if(__NFUN_122__(_Operative.m_szSpecialityID, "ID_SNIPER"))
		{
			Result.X = 229;
			Result.Y = 50;
			Result.W = 9;
			Result.H = 9;			
		}
		else
		{
			// End:0x105
			if(__NFUN_122__(_Operative.m_szSpecialityID, "ID_DEMOLITIONS"))
			{
				Result.X = 239;
				Result.Y = 10;
				Result.W = 9;
				Result.H = 9;				
			}
			else
			{
				// End:0x15F
				if(__NFUN_122__(_Operative.m_szSpecialityID, "ID_ELECTRONICS"))
				{
					Result.X = 229;
					Result.Y = 30;
					Result.W = 9;
					Result.H = 9;					
				}
				else
				{
					Result.X = 239;
					Result.Y = 30;
					Result.W = 9;
					Result.H = 9;
				}
			}
		}
	}
	Result.t = Texture'R6MenuTextures.Tab_Icon00';
	return Result;
	return;
}

function SetSelected(bool _IsSelected)
{
	m_bIsSelected = _IsSelected;
	m_OperativeSummary[0].SetSelected(_IsSelected);
	m_OperativeSummary[1].SetSelected(_IsSelected);
	m_OperativeSummary[2].SetSelected(_IsSelected);
	m_OperativeSummary[3].SetSelected(_IsSelected);
	return;
}

function SetTeam(int _Team)
{
	switch(_Team)
	{
		// End:0x3C
		case 0:
			m_TeamPlanningSummary.SetTeamName(Localize("GearRoom", "team1", "R6Menu"));
			// End:0xAA
			break;
		// End:0x71
		case 1:
			m_TeamPlanningSummary.SetTeamName(Localize("GearRoom", "team2", "R6Menu"));
			// End:0xAA
			break;
		// End:0xA7
		case 2:
			m_TeamPlanningSummary.SetTeamName(Localize("GearRoom", "team3", "R6Menu"));
			// End:0xAA
			break;
		// End:0xFFFF
		default:
			break;
	}
	m_TeamPlanningSummary.SetTeamColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
	m_OperativeSummary[0].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
	m_OperativeSummary[1].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
	m_OperativeSummary[2].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
	m_OperativeSummary[3].SetColor(Root.Colors.TeamColor[_Team], Root.Colors.TeamColorDark[_Team]);
	return;
}

function int OperativeCount()
{
	local int addedOperative;

	addedOperative = 0;
	J0x07:

	// End:0x30 [Loop If]
	if(__NFUN_130__(__NFUN_150__(addedOperative, 4), __NFUN_119__(m_teamOperatives[addedOperative], none)))
	{
		__NFUN_165__(addedOperative);
		// [Loop Continue]
		goto J0x07;
	}
	return addedOperative;
	return;
}

function SetPlanningDetails(string szWayPoint, string szGoCode)
{
	m_TeamPlanningSummary.SetPlanningValues(szWayPoint, szGoCode);
	return;
}

defaultproperties
{
	m_fSummaryHeight=53.0000000
	m_fOperativeSummaryHeight=44.0000000
	m_fYPaddingBetweenElements=2.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var s
