//=============================================================================
// R6Window3DButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6Window3DButton.uc : Window under the 3D view for planning, has to be a button
//                          to be able to click on it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/27/04 * Created by Joel Tremblay
//=============================================================================
class R6Window3DButton extends UWindowButton;

var int m_iDrawStyle;
var bool m_bDisplayWindow;
var bool m_bLMouseDown;
var Color m_cButtonColor;

function Created()
{
	m_cButtonColor = Root.Colors.GrayLight;
	ToolTipString = Localize("PlanningMenu", "3DWindow", "R6Menu");
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float tempSpace;
	local Color vBorderColor;

	C.Style = byte(m_iDrawStyle);
	C.SetDrawColor(m_cButtonColor.R, m_cButtonColor.G, m_cButtonColor.B);
	// End:0x9F
	if((UpTexture != none))
	{
		DrawStretchedTextureSegment(C, ImageX, ImageY, WinWidth, WinHeight, float(UpRegion.X), float(UpRegion.Y), float(UpRegion.W), float(UpRegion.H), UpTexture);
	}
	return;
}

function MouseLeave()
{
	// End:0x29
	if((m_bLMouseDown == true))
	{
		m_bLMouseDown = false;
		R6PlanningCtrl(GetPlayerOwner()).TurnOff3DMove();
	}
	super(UWindowDialogControl).MouseLeave();
	m_cButtonColor = Root.Colors.GrayLight;
	return;
}

function MouseEnter()
{
	super(UWindowDialogControl).MouseEnter();
	m_cButtonColor = Root.Colors.BlueLight;
	return;
}

function MouseMove(float X, float Y)
{
	// End:0x7C
	if((m_bLMouseDown == true))
	{
		R6PlanningCtrl(GetPlayerOwner()).Ajust3DRotation((WinLeft + X), (WinTop + Y));
		R6MenuRootWindow(Root).m_CurrentWidget.SetMousePos((WinLeft + (WinWidth * 0.5000000)), (WinTop + (WinHeight * 0.5000000)));
	}
	return;
}

function LMouseDown(float X, float Y)
{
	m_bLMouseDown = true;
	R6MenuRootWindow(Root).m_CurrentWidget.SetMousePos((WinLeft + (WinWidth * 0.5000000)), (WinTop + (WinHeight * 0.5000000)));
	R6PlanningCtrl(GetPlayerOwner()).TurnOn3DMove((WinLeft + (WinWidth * 0.5000000)), (WinTop + (WinHeight * 0.5000000)));
	return;
}

function LMouseUp(float X, float Y)
{
	m_bLMouseDown = false;
	R6PlanningCtrl(GetPlayerOwner()).TurnOff3DMove();
	return;
}

function Toggle3DWindow()
{
	m_bDisplayWindow = (!m_bDisplayWindow);
	// End:0x24
	if((m_bDisplayWindow == true))
	{
		ShowWindow();		
	}
	else
	{
		HideWindow();
	}
	return;
}

function Close3DWindow()
{
	m_bDisplayWindow = false;
	HideWindow();
	return;
}

function SetButtonColor(Color cButtonColor)
{
	m_cButtonColor = cButtonColor;
	return;
}

defaultproperties
{
	m_iDrawStyle=1
	m_cButtonColor=(R=255,G=255,B=255,A=0)
	UpTexture=Texture'R6Planning.Icons.PlanIcon_White'
}
