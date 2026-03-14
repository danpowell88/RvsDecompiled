//=============================================================================
// R6MenuViewCamBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuViewCamBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================
class R6MenuViewCamBar extends UWindowWindow;

const XPos = 8;
const ButtonSize = 33;

var R6WindowButton m_Button[6];

function Created()
{
	local int xPosition;

	xPosition = __NFUN_146__(8, 5);
	m_Button[0] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamTurnCounterClockwiseButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamTurnCounterClockwiseButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[0].ToolTipString = Localize("PlanningMenu", "RotateCClock", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 8));
	m_Button[1] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamTurnClockwiseButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamTurnClockwiseButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[1].ToolTipString = Localize("PlanningMenu", "RotateClock", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 8));
	m_Button[2] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamZoomInButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamZoomInButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[2].ToolTipString = Localize("PlanningMenu", "ZoomIn", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 8));
	m_Button[3] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamZoomOutButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamZoomOutButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[3].ToolTipString = Localize("PlanningMenu", "ZoomOut", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 8));
	m_Button[4] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamFloorUpButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamFloorUpButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[4].ToolTipString = Localize("PlanningMenu", "LevelUp", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 8));
	m_Button[5] = R6WindowButton(CreateWindow(Class'R6Menu.R6MenuCamFloorDownButton', float(xPosition), 1.0000000, float(Class'R6Menu.R6MenuCamFloorDownButton'.default.UpRegion.W), 23.0000000, self));
	m_Button[5].ToolTipString = Localize("PlanningMenu", "LevelDown", "R6Menu");
	__NFUN_161__(xPosition, __NFUN_146__(33, 2));
	WinWidth = float(xPosition);
	m_BorderColor = Root.Colors.GrayLight;
	return;
}

function KeepActive(int iActive)
{
	m_Button[0].m_bSelected = false;
	m_Button[1].m_bSelected = false;
	m_Button[2].m_bSelected = false;
	// End:0x6E
	if(__NFUN_130__(__NFUN_151__(iActive, -1), __NFUN_150__(iActive, 3)))
	{
		m_Button[iActive].m_bSelected = true;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

