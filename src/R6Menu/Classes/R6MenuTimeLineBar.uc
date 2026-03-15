//=============================================================================
// R6MenuTimeLineBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTimeLineBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuTimeLineBar extends UWindowWindow;

var R6WindowButton m_Button[6];

function Created()
{
	local int xPosition;

	xPosition = 2;
	m_Button[0] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLineGotoFirst', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLineGotoFirst'.default.UpRegion.W), 23.0000000, self));
	m_Button[0].ToolTipString = Localize("PlanningMenu", "GotoFirst", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLineGotoFirst'.default.UpRegion.W);
	m_Button[1] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLinePrevious', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLinePrevious'.default.UpRegion.W), 23.0000000, self));
	m_Button[1].ToolTipString = Localize("PlanningMenu", "Previous", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLinePrevious'.default.UpRegion.W);
	m_Button[2] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLinePlay', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLinePlay'.default.UpRegion.W), 23.0000000, self));
	m_Button[2].ToolTipString = Localize("PlanningMenu", "PlayStop", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLinePlay'.default.UpRegion.W);
	m_Button[3] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLineNext', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLineNext'.default.UpRegion.W), 23.0000000, self));
	m_Button[3].ToolTipString = Localize("PlanningMenu", "Next", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLineNext'.default.UpRegion.W);
	m_Button[4] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLineGotoLast', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLineGotoLast'.default.UpRegion.W), 23.0000000, self));
	m_Button[4].ToolTipString = Localize("PlanningMenu", "GotoLast", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLineGotoLast'.default.UpRegion.W);
	m_Button[5] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuTimeLineLock', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuTimeLineLock'.default.UpRegion.W), 23.0000000, self));
	m_Button[5].ToolTipString = Localize("PlanningMenu", "Lock", "R6Menu");
	(xPosition += Class'R6Menu.R6MenuTimeLineLock'.default.UpRegion.W);
	WinWidth = float((xPosition + 1));
	m_BorderColor = Root.Colors.GrayLight;
	return;
}

function Reset()
{
	// End:0x43
	if((R6PlanningCtrl(GetPlayerOwner()) != none))
	{
		R6PlanningCtrl(GetPlayerOwner()).m_bPlayMode = false;
		R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();
		StopPlayMode();
	}
	R6MenuTimeLineLock(m_Button[5]).ResetCameraLock();
	return;
}

function ActivatePlayMode()
{
	local R6MenuPlanningBar PlanningBarWindow;

	PlanningBarWindow = R6MenuPlanningBar(OwnerWindow);
	m_Button[0].bDisabled = true;
	m_Button[1].bDisabled = true;
	m_Button[3].bDisabled = true;
	m_Button[4].bDisabled = true;
	PlanningBarWindow.m_ViewCamBar.m_Button[4].bDisabled = true;
	PlanningBarWindow.m_ViewCamBar.m_Button[5].bDisabled = true;
	PlanningBarWindow.m_DelNodeBar.m_Button[0].bDisabled = true;
	PlanningBarWindow.m_DelNodeBar.m_Button[1].bDisabled = true;
	PlanningBarWindow.m_DelNodeBar.m_Button[2].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_DisplayList[0].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_ActiveList[0].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_DisplayList[1].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_ActiveList[1].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_DisplayList[2].bDisabled = true;
	PlanningBarWindow.m_TeamBar.m_ActiveList[2].bDisabled = true;
	return;
}

function StopPlayMode()
{
	local R6MenuPlanningBar PlanningBarWindow;

	PlanningBarWindow = R6MenuPlanningBar(OwnerWindow);
	m_Button[0].bDisabled = false;
	m_Button[1].bDisabled = false;
	m_Button[3].bDisabled = false;
	m_Button[4].bDisabled = false;
	PlanningBarWindow.m_ViewCamBar.m_Button[4].bDisabled = false;
	PlanningBarWindow.m_ViewCamBar.m_Button[5].bDisabled = false;
	PlanningBarWindow.m_DelNodeBar.m_Button[0].bDisabled = false;
	PlanningBarWindow.m_DelNodeBar.m_Button[1].bDisabled = false;
	PlanningBarWindow.m_DelNodeBar.m_Button[2].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_DisplayList[0].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_ActiveList[0].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_DisplayList[1].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_ActiveList[1].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_DisplayList[2].bDisabled = false;
	PlanningBarWindow.m_TeamBar.m_ActiveList[2].bDisabled = false;
	R6MenuTimeLinePlay(m_Button[2]).m_bPlaying = false;
	// End:0x239
	if((R6PlanningCtrl(GetPlayerOwner()) != none))
	{
		R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

