//=============================================================================
// R6MenuMPInGameObj - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPInGameObj.uc : Window with the Objectives in-game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/26 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameObj extends R6MenuEscObjectives;

var R6WindowWrappedTextArea m_pGreenTeam;
var R6WindowWrappedTextArea m_pRedTeam;
var array<R6MenuObjectiveLabel> m_AObjectives;
var string m_AAdvLoc[2];

// overwrite the fct in R6MenuEscObjectives
function Created()
{
	local int ITemp;

	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fXTitleOffset, m_fYTitleOffset, (WinWidth - m_fXTitleOffset), m_fLabelHeight, self));
	m_Title.SetProperties(Localize("Briefing", "Objectives", "R6Menu"), 0, Root.Fonts[5], Root.Colors.BlueLight, false);
	ITemp = int(((m_Title.WinTop + m_Title.WinHeight) + m_fObjYOffset));
	ITemp = int((float(int((WinHeight - float(ITemp)))) * 0.5000000));
	m_pGreenTeam = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', m_fXTitleOffset, ((m_Title.WinTop + m_Title.WinHeight) + m_fObjYOffset), (WinWidth - m_fXTitleOffset), float(ITemp), self));
	m_pGreenTeam.m_HBorderTexture = none;
	m_pGreenTeam.m_VBorderTexture = none;
	m_pGreenTeam.SetScrollable(false);
	m_pGreenTeam.HideWindow();
	m_pRedTeam = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', m_fXTitleOffset, (m_pGreenTeam.WinTop + m_pGreenTeam.WinHeight), (WinWidth - m_fXTitleOffset), float(ITemp), self));
	m_pRedTeam.m_HBorderTexture = none;
	m_pRedTeam.m_VBorderTexture = none;
	m_pRedTeam.SetScrollable(false);
	m_pRedTeam.HideWindow();
	m_AAdvLoc[0] = (Localize("MPInGame", "AlphaTeam", "R6Menu") $ " : ");
	m_AAdvLoc[1] = (Localize("MPInGame", "BravoTeam", "R6Menu") $ " : ");
	return;
}

function CreateObjWindow()
{
	local int Y, iNbOfObj;

	iNbOfObj = m_AObjectives.Length;
	Y = int((((m_Title.WinTop + m_Title.WinHeight) + m_fObjYOffset) + (m_fObjHeight * float(iNbOfObj))));
	m_AObjectives[iNbOfObj] = R6MenuObjectiveLabel(CreateWindow(Class'R6Menu.R6MenuObjectiveLabel', m_fXTitleOffset, float(Y), (WinWidth - m_fXTitleOffset), m_fObjHeight, self));
	m_AObjectives[iNbOfObj].HideWindow();
	return;
}

function SetNewObjWindowSizes(float _X, float _Y, float _W, float _H, bool _bCoopType)
{
	local int i, iNbOfObj;

	m_Title.WinLeft = m_fXTitleOffset;
	m_Title.WinTop = m_fYTitleOffset;
	m_Title.WinWidth = _W;
	// End:0xE8
	if(_bCoopType)
	{
		iNbOfObj = m_AObjectives.Length;
		i = 0;
		J0x58:

		// End:0xE8 [Loop If]
		if((i < iNbOfObj))
		{
			m_AObjectives[i].WinLeft = m_fXTitleOffset;
			m_AObjectives[i].WinWidth = _W;
			m_AObjectives[i].WinHeight = _H;
			m_AObjectives[i].SetNewLabelWindowSizes(m_fXTitleOffset, _Y, _W, _H);
			(i++);
			// [Loop Continue]
			goto J0x58;
		}
	}
	return;
}

function UpdateObjectives()
{
	local string szObjectiveDesc, szLocalization;
	local int i;
	local GameReplicationInfo repInfo;
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x1DE
	if((int(r6Root.m_eCurrentGameMode) == int(GetLevel().3)))
	{
		m_pGreenTeam.Clear();
		m_pRedTeam.HideWindow();
		m_pGreenTeam.m_fXOffSet = 10.0000000;
		// End:0x177
		if(GetLevel().IsGameTypeTeamAdversarial(r6Root.m_szCurrentGameType))
		{
			m_pGreenTeam.AddText((m_AAdvLoc[0] $ GetLevel().GetGreenTeamObjective(r6Root.m_szCurrentGameType)), Root.Colors.White, Root.Fonts[5]);
			m_pRedTeam.Clear();
			m_pRedTeam.m_fXOffSet = 10.0000000;
			m_pRedTeam.AddText((m_AAdvLoc[1] $ GetLevel().GetRedTeamObjective(r6Root.m_szCurrentGameType)), Root.Colors.White, Root.Fonts[5]);
			m_pRedTeam.ShowWindow();			
		}
		else
		{
			m_pGreenTeam.AddText(GetLevel().GetGreenTeamObjective(r6Root.m_szCurrentGameType), Root.Colors.White, Root.Fonts[5]);
		}
		m_pGreenTeam.ShowWindow();		
	}
	else
	{
		repInfo = Root.Console.ViewportOwner.Actor.GameReplicationInfo;
		i = 0;
		J0x214:

		// End:0x243 [Loop If]
		if((i < m_AObjectives.Length))
		{
			m_AObjectives[i].HideWindow();
			(i++);
			// [Loop Continue]
			goto J0x214;
		}
		i = 0;
		J0x24A:

		// End:0x31A [Loop If]
		if((i < repInfo.GetRepMObjInfoArraySize()))
		{
			szObjectiveDesc = repInfo.GetRepMObjString(i);
			// End:0x28C
			if((szObjectiveDesc == ""))
			{
				// [Explicit Break]
				goto J0x31A;
			}
			szObjectiveDesc = Localize("Game", szObjectiveDesc, repInfo.GetRepMObjStringLocFile(i));
			// End:0x2CD
			if((i == m_AObjectives.Length))
			{
				CreateObjWindow();
			}
			m_AObjectives[i].SetProperties(szObjectiveDesc, repInfo.IsRepMObjCompleted(i));
			m_AObjectives[i].ShowWindow();
			(++i);
			// [Loop Continue]
			goto J0x24A;
		}
	}
	J0x31A:

	return;
}

defaultproperties
{
	m_fYTitleOffset=3.0000000
}
