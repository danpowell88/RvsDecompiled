//=============================================================================
// R6MenuPlanningBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuPlanningBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================
class R6MenuPlanningBar extends UWindowWindow;

var R6MenuTeamBar m_TeamBar;
var R6MenuDelNodeBar m_DelNodeBar;
var R6MenuViewCamBar m_ViewCamBar;
var R6MenuTimeLineBar m_TimeLine;
var Color m_iColor;

function Created()
{
	local int i;
	local float fCurrentW;

	fCurrentW = 0.0000000;
	m_TeamBar = R6MenuTeamBar(CreateWindow(Class'R6Menu.R6MenuTeamBar', fCurrentW, 0.0000000, 10.0000000, 25.0000000, self));
	(fCurrentW += (m_TeamBar.WinWidth - float(1)));
	m_DelNodeBar = R6MenuDelNodeBar(CreateWindow(Class'R6Menu.R6MenuDelNodeBar', fCurrentW, 0.0000000, 10.0000000, 25.0000000, self));
	(fCurrentW += (m_DelNodeBar.WinWidth - float(1)));
	m_ViewCamBar = R6MenuViewCamBar(CreateWindow(Class'R6Menu.R6MenuViewCamBar', fCurrentW, 0.0000000, 10.0000000, 25.0000000, self));
	(fCurrentW += (m_ViewCamBar.WinWidth - float(1)));
	m_TimeLine = R6MenuTimeLineBar(CreateWindow(Class'R6Menu.R6MenuTimeLineBar', fCurrentW, 0.0000000, 10.0000000, 25.0000000, self));
	return;
}

function Reset()
{
	m_TeamBar.Reset();
	m_TimeLine.Reset();
	return;
}

function ResetTeams(int iWhatToReset)
{
	m_TeamBar.ResetTeams(iWhatToReset);
	return;
}

defaultproperties
{
	m_iColor=(R=129,G=209,B=238,A=0)
}
