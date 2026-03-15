//=============================================================================
// R6MenuDelNodeBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuDelNodeBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuDelNodeBar extends UWindowWindow;

const PosX = 4;

var R6WindowButton m_Button[3];

function Created()
{
	local int xPosition;

	xPosition = 1;
	m_Button[0] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuWPDeleteButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuWPDeleteButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[0].ToolTipString = Localize("PlanningMenu", "Delete", "R6Menu");
	(xPosition += int((m_Button[0].WinWidth - float(4))));
	m_Button[1] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuWPDeleteAllButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuWPDeleteAllButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[1].ToolTipString = Localize("PlanningMenu", "DeleteAll", "R6Menu");
	(xPosition += int((m_Button[1].WinWidth - float(4))));
	m_Button[2] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuWPDeleteAllTeamButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuWPDeleteAllTeamButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[2].ToolTipString = Localize("PlanningMenu", "DeleteAllTeam", "R6Menu");
	(xPosition += int(m_Button[1].WinWidth));
	WinWidth = float(xPosition);
	m_BorderColor = Root.Colors.GrayLight;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

