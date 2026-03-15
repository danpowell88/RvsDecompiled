//=============================================================================
// R6MenuEscObjectives - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuEscObjectives.uc : Objectives window in the esc menu of single player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================
class R6MenuEscObjectives extends UWindowWindow;

const C_MAXOBJ = 10;

var float m_fXTitleOffset;
// NEW IN 1.60
var float m_fYTitleOffset;
// NEW IN 1.60
var float m_fLabelHeight;
var float m_fObjHeight;
// NEW IN 1.60
var float m_fObjYOffset;
var R6WindowTextLabel m_Title;
// NEW IN 1.60
var R6WindowTextLabel m_NoObj;
// NEW IN 1.60
var R6MenuObjectiveLabel m_Objectives[10];
var string m_szTextFailed;

function Created()
{
	local int i, Y;

	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXTitleOffset, m_fYTitleOffset, (WinWidth - m_fXTitleOffset), m_fLabelHeight, self));
	m_Title.SetProperties(Localize("ESCMENUS", "MISSIONOBJ", "R6Menu"), 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	Y = int(((m_Title.WinTop + m_Title.WinHeight) + m_fObjYOffset));
	m_NoObj = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXTitleOffset, float(Y), (WinWidth - m_fXTitleOffset), m_fObjHeight, self));
	m_NoObj.SetProperties(Localize("ESCMENUS", "NOMISSIONOBJ", "R6Menu"), 0, Root.Fonts[0], Root.Colors.White, false);
	m_NoObj.HideWindow();
	i = 0;
	J0x166:

	// End:0x1D9 [Loop If]
	if((i < 10))
	{
		m_Objectives[i] = R6MenuObjectiveLabel(CreateWindow(Class'R6Menu.R6MenuObjectiveLabel', m_fXTitleOffset, float(Y), (WinWidth - m_fXTitleOffset), m_fObjHeight, self));
		m_Objectives[i].HideWindow();
		(Y += int(m_fObjHeight));
		(i++);
		// [Loop Continue]
		goto J0x166;
	}
	m_szTextFailed = ((" (", Localize("OBJECTIVES", "FAILED", "R6Menu")) $ ")" $ ???);
	return;
}

function UpdateObjectives()
{
	local R6MissionObjectiveMgr moMgr;
	local R6GameOptions pGameOptions;
	local string szTemp;
	local int i, j;

	pGameOptions = Class'Engine.Actor'.static.GetGameOptions();
	moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
	i = 0;
	J0x5F:

	// End:0x8A [Loop If]
	if((i < 10))
	{
		m_Objectives[i].HideWindow();
		(i++);
		// [Loop Continue]
		goto J0x5F;
	}
	// End:0xB1
	if((moMgr.m_aMissionObjectives.Length <= 0))
	{
		m_NoObj.ShowWindow();		
	}
	else
	{
		m_NoObj.HideWindow();
		j = 0;
		i = 0;
		J0xCE:

		// End:0x24C [Loop If]
		if(((i < moMgr.m_aMissionObjectives.Length) && (i < 10)))
		{
			// End:0x242
			if(((!moMgr.m_aMissionObjectives[i].m_bMoralityObjective) && moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
			{
				szTemp = Localize("Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile(moMgr.m_aMissionObjectives[i]));
				// End:0x1EE
				if((pGameOptions.UnlimitedPractice && moMgr.m_aMissionObjectives[i].isFailed()))
				{
					m_Objectives[j].SetProperties(szTemp, false, m_szTextFailed);					
				}
				else
				{
					m_Objectives[j].SetProperties(szTemp, moMgr.m_aMissionObjectives[i].isCompleted());
				}
				m_Objectives[j].ShowWindow();
				(j++);
			}
			(++i);
			// [Loop Continue]
			goto J0xCE;
		}
	}
	return;
}

defaultproperties
{
	m_fXTitleOffset=10.0000000
	m_fYTitleOffset=10.0000000
	m_fLabelHeight=15.0000000
	m_fObjHeight=15.0000000
	m_fObjYOffset=2.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var j
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var m_ObjectivesC_MAXOBJ
