//=============================================================================
// R6MenuTeamBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTeamBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamBar extends UWindowWindow;

const PosX2 = 2;
const ButtonWidth = 28;
const SmallWidth = 14;

var R6MenuTeamDisplayButton m_DisplayList[3];
var R6MenuTeamButton m_ActiveList[3];

function Created()
{
	local int i, xPosition;

	xPosition = 4;
	i = 0;
	J0x0F:

	// End:0xFA [Loop If]
	if((i < 3))
	{
		m_ActiveList[i] = R6MenuTeamButton(CreateWindow(Class'R6Menu.R6MenuTeamButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTeamButton'.default.UpRegion.W), 23.0000000, self));
		m_ActiveList[i].m_iTeamColor = i;
		m_ActiveList[i].ToolTipString = Localize("PlanningMenu", "TeamActive", "R6Menu");
		m_ActiveList[i].m_vButtonColor = Root.Colors.TeamColorLight[i];
		(xPosition += 14);
		(i++);
		// [Loop Continue]
		goto J0x0F;
	}
	i = 0;
	J0x101:

	// End:0x1F1 [Loop If]
	if((i < 3))
	{
		m_DisplayList[i] = R6MenuTeamDisplayButton(CreateWindow(Class'R6Menu.R6MenuTeamDisplayButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTeamDisplayButton'.default.UpRegion.W), 23.0000000, self));
		m_DisplayList[i].m_iTeamColor = i;
		m_DisplayList[i].m_vButtonColor = Root.Colors.TeamColorLight[i];
		m_DisplayList[i].ToolTipString = Localize("PlanningMenu", "TeamDisplay", "R6Menu");
		(xPosition += (28 - 2));
		(i++);
		// [Loop Continue]
		goto J0x101;
	}
	WinWidth = float((xPosition + 4));
	SetTeamActive(0);
	m_BorderColor = Root.Colors.GrayLight;
	return;
}

function Reset()
{
	local R6PlanningCtrl OwnerCtrl;

	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	m_ActiveList[0].m_bSelected = true;
	m_ActiveList[1].m_bSelected = false;
	m_ActiveList[2].m_bSelected = false;
	m_DisplayList[0].m_bSelected = true;
	m_DisplayList[1].m_bSelected = true;
	m_DisplayList[2].m_bSelected = true;
	// End:0xE2
	if((OwnerCtrl != none))
	{
		OwnerCtrl.m_pTeamInfo[0].SetPathDisplay(true);
		OwnerCtrl.m_pTeamInfo[1].SetPathDisplay(true);
		OwnerCtrl.m_pTeamInfo[2].SetPathDisplay(true);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

function EscClose()
{
	return;
}

function SetTeamActive(int iActive)
{
	local R6PlanningCtrl OwnerCtrl;

	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	m_ActiveList[0].m_bSelected = false;
	m_ActiveList[1].m_bSelected = false;
	m_ActiveList[2].m_bSelected = false;
	m_ActiveList[iActive].m_bSelected = true;
	// End:0xF7
	if((OwnerCtrl != none))
	{
		switch(iActive)
		{
			// End:0x9E
			case 0:
				OwnerCtrl.SwitchToRedTeam(true);
				m_DisplayList[0].m_bSelected = true;
				// End:0xF7
				break;
			// End:0xC8
			case 1:
				OwnerCtrl.SwitchToGreenTeam(true);
				m_DisplayList[1].m_bSelected = true;
				// End:0xF7
				break;
			// End:0xF4
			case 2:
				OwnerCtrl.SwitchToGoldTeam(true);
				m_DisplayList[2].m_bSelected = true;
				// End:0xF7
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

function ResetTeams(int iWhatToReset)
{
	local R6PlanningCtrl OwnerCtrl;

	OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
	// End:0xE3
	if(((iWhatToReset < 3) && (m_ActiveList[OwnerCtrl.m_iCurrentTeam].m_bSelected != true)))
	{
		m_ActiveList[0].m_bSelected = false;
		m_ActiveList[1].m_bSelected = false;
		m_ActiveList[2].m_bSelected = false;
		m_ActiveList[OwnerCtrl.m_iCurrentTeam].m_bSelected = true;
		// End:0xE0
		if((!m_DisplayList[OwnerCtrl.m_iCurrentTeam].m_bSelected))
		{
			m_DisplayList[OwnerCtrl.m_iCurrentTeam].m_bSelected = true;
		}		
	}
	else
	{
		// End:0x124
		if((iWhatToReset > 2))
		{
			m_DisplayList[(iWhatToReset - 3)].m_bSelected = (!m_DisplayList[(iWhatToReset - 3)].m_bSelected);
		}
	}
	return;
}

