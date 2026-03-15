//=============================================================================
// R6WindowLegend - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowLegend.uc : Planning phase legend window.  
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================
class R6WindowLegend extends R6MenuFramePopup;

var int m_iCurrentPage;
var int m_NavButtonSize;
var bool m_bDisplayWindow;
var bool m_bInitialized;
var R6MenuLegendPage m_LegendPages[5];
var UWindowButton m_PreviousPageButton;
var UWindowButton m_NextPageButton;
var R6WindowBitMap m_PrevBg;
var R6WindowBitMap m_NextBg;
var Region ButtonBg;

function Created()
{
	local Texture ButtonTexture;

	super(R6WindowFramedWindow).Created();
	ButtonTexture = R6WindowLookAndFeel(LookAndFeel).m_R6ScrollTexture;
	ToolTipString = Localize("PlanningLegend", "MainTip", "R6Menu");
	m_PreviousPageButton = R6LegendPreviousPageButton(CreateWindow(Class'R6Menu.R6LegendPreviousPageButton', float((m_iFrameWidth + 4)), float((m_iFrameWidth + 4)), float(m_NavButtonSize), float(m_NavButtonSize), self));
	m_NextPageButton = R6LegendNextPageButton(CreateWindow(Class'R6Menu.R6LegendNextPageButton', float((m_iFrameWidth + 4)), float((m_iFrameWidth + 4)), float(m_NavButtonSize), float(m_NavButtonSize), self));
	m_PrevBg = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float((m_iFrameWidth + 2)), float((m_iFrameWidth + 2)), float(ButtonBg.W), float(ButtonBg.H), self));
	m_PrevBg.bAlwaysBehind = true;
	m_PrevBg.m_bUseColor = true;
	m_PrevBg.m_iDrawStyle = 5;
	m_PrevBg.t = ButtonTexture;
	m_PrevBg.R = ButtonBg;
	m_PrevBg.SendToBack();
	m_NextBg = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float((m_iFrameWidth + 2)), float((m_iFrameWidth + 2)), float(ButtonBg.W), float(ButtonBg.H), self));
	m_NextBg.bAlwaysBehind = true;
	m_NextBg.m_bUseColor = true;
	m_NextBg.m_iDrawStyle = 5;
	m_NextBg.t = ButtonTexture;
	m_NextBg.R = ButtonBg;
	m_NextBg.SendToBack();
	m_LegendPages[0] = R6MenuLegendPageObject(CreateWindow(Class'R6Menu.R6MenuLegendPageObject', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	m_LegendPages[1] = R6MenuLegendPageInteractive(CreateWindow(Class'R6Menu.R6MenuLegendPageInteractive', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	m_LegendPages[1].HideWindow();
	m_LegendPages[2] = R6MenuLegendPageROE(CreateWindow(Class'R6Menu.R6MenuLegendPageROE', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	m_LegendPages[2].HideWindow();
	m_LegendPages[3] = R6MenuLegendPageWPDesc(CreateWindow(Class'R6Menu.R6MenuLegendPageWPDesc', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	m_LegendPages[3].HideWindow();
	m_LegendPages[4] = R6MenuLegendPageActions(CreateWindow(Class'R6Menu.R6MenuLegendPageActions', float(m_iFrameWidth), m_fTitleBarHeight, 100.0000000, 100.0000000, self));
	m_LegendPages[4].HideWindow();
	m_ButtonList = m_LegendPages[0];
	m_szWindowTitle = m_LegendPages[0].m_szPageTitle;
	return;
}

//Should be before created.  Or add a function to that only once.
function BeforePaint(Canvas C, float X, float Y)
{
	local int iTeamColor;

	// End:0x133
	if((m_bInitialized == false))
	{
		m_bInitialized = true;
		m_LegendPages[0].BeforePaint(C, X, Y);
		m_LegendPages[1].BeforePaint(C, X, Y);
		m_LegendPages[2].BeforePaint(C, X, Y);
		m_LegendPages[3].BeforePaint(C, X, Y);
		m_LegendPages[4].BeforePaint(C, X, Y);
		Resized();
		m_fTitleOffSet = ((WinWidth - R6MenuLegendPage(m_ButtonList).m_fTitleWidth) * 0.5000000);
		m_NextBg.WinLeft = (((WinWidth - float(m_iFrameWidth)) - float(m_NavButtonSize)) - float(2));
		m_NextPageButton.WinLeft = (m_NextBg.WinLeft + float(2));
	}
	iTeamColor = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
	m_PrevBg.m_TextureColor = Root.Colors.TeamColor[iTeamColor];
	m_NextBg.m_TextureColor = Root.Colors.TeamColor[iTeamColor];
	return;
}

function Resized()
{
	local float fHeight, fWidth, fBiggestButtonList;

	fBiggestButtonList = m_LegendPages[0].WinWidth;
	// End:0x46
	if((fBiggestButtonList < m_LegendPages[1].WinWidth))
	{
		fBiggestButtonList = m_LegendPages[1].WinWidth;
	}
	// End:0x78
	if((fBiggestButtonList < m_LegendPages[2].WinWidth))
	{
		fBiggestButtonList = m_LegendPages[2].WinWidth;
	}
	// End:0xAA
	if((fBiggestButtonList < m_LegendPages[3].WinWidth))
	{
		fBiggestButtonList = m_LegendPages[3].WinWidth;
	}
	// End:0xDC
	if((fBiggestButtonList < m_LegendPages[4].WinWidth))
	{
		fBiggestButtonList = m_LegendPages[4].WinWidth;
	}
	fWidth = (fBiggestButtonList + float((m_iFrameWidth * 2)));
	fHeight = ((m_ButtonList.WinHeight + m_fTitleBarHeight) + float((m_iFrameWidth * 2)));
	// End:0x1C0
	if(((fWidth != WinWidth) || (fHeight != WinHeight)))
	{
		m_ButtonList.WinTop = m_fTitleBarHeight;
		m_ButtonList.WinLeft = float(m_iFrameWidth);
		super.Resized();
		// End:0x18B
		if((m_bDisplayLeft == true))
		{
			(WinLeft += (WinWidth - fWidth));
		}
		WinWidth = fWidth;
		// End:0x1B5
		if((m_bDisplayUp == true))
		{
			(WinTop += (WinHeight - fHeight));
		}
		WinHeight = fHeight;
	}
	return;
}

function NextPage()
{
	(m_iCurrentPage++);
	// End:0x1A
	if((m_iCurrentPage == 5))
	{
		m_iCurrentPage = 0;
	}
	m_ButtonList.HideWindow();
	m_ButtonList = m_LegendPages[m_iCurrentPage];
	m_ButtonList.ShowWindow();
	m_szWindowTitle = m_LegendPages[m_iCurrentPage].m_szPageTitle;
	m_fTitleOffSet = ((WinWidth - m_LegendPages[m_iCurrentPage].m_fTitleWidth) * 0.5000000);
	return;
}

function PreviousPage()
{
	(m_iCurrentPage--);
	// End:0x1A
	if((m_iCurrentPage < 0))
	{
		m_iCurrentPage = 4;
	}
	m_ButtonList.HideWindow();
	m_ButtonList = m_LegendPages[m_iCurrentPage];
	m_ButtonList.ShowWindow();
	m_szWindowTitle = m_LegendPages[m_iCurrentPage].m_szPageTitle;
	m_fTitleOffSet = ((WinWidth - m_LegendPages[m_iCurrentPage].m_fTitleWidth) * 0.5000000);
	return;
}

function ToggleLegend()
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

function CloseLegendWindow()
{
	m_bDisplayWindow = false;
	HideWindow();
	return;
}

defaultproperties
{
	m_NavButtonSize=16
	ButtonBg=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61474,ZoneNumber=0)
	m_iNbButton=6
	m_bDisplayLeft=true
	m_fTitleBarHeight=22.0000000
}
