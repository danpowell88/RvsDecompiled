//=============================================================================
// R6WindowTeamPlanningSummary - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowTeamPlanningSummary.uc : Top of each team summary in Execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTeamPlanningSummary extends UWindowWindow;

var byte m_BTopAlpha;
var byte m_BBottomAlpha;
var float m_fTopBGHeight;
var float m_fLabelXOffset;
// NEW IN 1.60
var float m_fVlabelWidth;
var R6WindowTextLabel m_Team;
// NEW IN 1.60
var R6WindowTextLabel m_GoCode;
// NEW IN 1.60
var R6WindowTextLabel m_Waypoint;
// NEW IN 1.60
var R6WindowTextLabel m_GoCodeVal;
// NEW IN 1.60
var R6WindowTextLabel m_WayPointVal;
var Texture m_TTopBG;
var Region m_RTopBG;
var Color m_CDarkTeamColor;

function Created()
{
	local float labelWidth, RightLabelXPos, fLabelHeight;

	labelWidth = ((WinWidth - (float(2) * m_fLabelXOffset)) - m_fVlabelWidth);
	RightLabelXPos = (WinWidth - m_fVlabelWidth);
	fLabelHeight = ((WinHeight - m_fTopBGHeight) / float(2));
	m_Team = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, m_fTopBGHeight, self));
	m_Team.m_bDrawBorders = false;
	m_Team.Align = 2;
	m_Team.TextColor = Root.Colors.White;
	m_Team.m_Font = Root.Fonts[15];
	m_Team.m_BGTexture = none;
	m_Team.m_bFixedYPos = true;
	m_Team.TextY = 2.0000000;
	m_GoCode = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fLabelXOffset, m_fTopBGHeight, labelWidth, fLabelHeight, self));
	m_GoCode.m_bDrawBorders = false;
	m_GoCode.Align = 0;
	m_GoCode.TextColor = Root.Colors.White;
	m_GoCode.m_Font = Root.Fonts[5];
	m_GoCode.m_BGTexture = none;
	m_GoCode.Text = Localize("ExecuteMenu", "GOCODE", "R6Menu");
	m_GoCode.m_fLMarge = 2.0000000;
	m_Waypoint = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', m_fLabelXOffset, (m_GoCode.WinTop + m_GoCode.WinHeight), labelWidth, fLabelHeight, self));
	m_Waypoint.m_bDrawBorders = false;
	m_Waypoint.Align = 0;
	m_Waypoint.TextColor = Root.Colors.White;
	m_Waypoint.m_Font = Root.Fonts[5];
	m_Waypoint.m_BGTexture = none;
	m_Waypoint.Text = Localize("ExecuteMenu", "WAYPOINT", "R6Menu");
	m_Waypoint.m_fLMarge = m_GoCode.m_fLMarge;
	m_GoCodeVal = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', RightLabelXPos, m_GoCode.WinTop, m_fVlabelWidth, fLabelHeight, self));
	m_GoCodeVal.m_bDrawBorders = false;
	m_GoCodeVal.Align = 2;
	m_GoCodeVal.TextColor = Root.Colors.White;
	m_GoCodeVal.m_Font = Root.Fonts[5];
	m_GoCodeVal.m_BGTexture = none;
	m_WayPointVal = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', RightLabelXPos, m_Waypoint.WinTop, m_fVlabelWidth, fLabelHeight, self));
	m_WayPointVal.m_bDrawBorders = false;
	m_WayPointVal.Align = 2;
	m_WayPointVal.TextColor = Root.Colors.White;
	m_WayPointVal.m_Font = Root.Fonts[5];
	m_WayPointVal.m_BGTexture = none;
	return;
}

function SetTeamColor(Color _c, Color _DarkColor)
{
	m_Team.TextColor = _c;
	m_GoCode.TextColor = _c;
	m_Waypoint.TextColor = _c;
	m_GoCodeVal.TextColor = _c;
	m_WayPointVal.TextColor = _c;
	m_BorderColor = _c;
	m_CDarkTeamColor = _DarkColor;
	return;
}

function SetPlanningValues(string szWayPoint, string szGoCode)
{
	m_WayPointVal.SetNewText(szWayPoint, true);
	m_GoCodeVal.SetNewText(szGoCode, true);
	return;
}

function SetTeamName(string szTeamName)
{
	m_Team.SetNewText(szTeamName, true);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 5;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BTopAlpha);
	DrawStretchedTexture(C, 0.0000000, 0.0000000, WinWidth, m_fTopBGHeight, m_TTopBG);
	C.SetDrawColor(m_CDarkTeamColor.R, m_CDarkTeamColor.G, m_CDarkTeamColor.B, m_BBottomAlpha);
	DrawStretchedTexture(C, 0.0000000, m_fTopBGHeight, WinWidth, (WinHeight - m_fTopBGHeight), m_TTopBG);
	C.Style = 1;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BorderColor.A);
	DrawStretchedTexture(C, 0.0000000, m_fTopBGHeight, WinWidth, 1.0000000, m_TTopBG);
	DrawSimpleBorder(C);
	return;
}

defaultproperties
{
	m_BTopAlpha=51
	m_BBottomAlpha=128
	m_fTopBGHeight=18.0000000
	m_fLabelXOffset=2.0000000
	m_fVlabelWidth=35.0000000
	m_TTopBG=Texture'UWindow.WhiteTexture'
	m_RTopBG=(Zone=StructProperty'R6Window.R6WindowSimpleFramedWindow.m_topLeftCornerR',iLeaf=2594,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: var h
