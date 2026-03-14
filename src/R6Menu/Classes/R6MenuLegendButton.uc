//=============================================================================
// R6MenuLegendButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuLegendButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/15 * Created by Chaouky Garram
//=============================================================================
class R6MenuLegendButton extends R6WindowStayDownButton;

function Created()
{
	bNoKeyboard = true;
	ToolTipString = Localize("PlanningMenu", "Legend", "R6Menu");
	ImageX = __NFUN_172__(__NFUN_175__(WinWidth, float(UpRegion.W)), float(2));
	ImageY = __NFUN_172__(__NFUN_175__(WinHeight, float(UpRegion.H)), float(2));
	m_BorderColor = Root.Colors.GrayLight;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function Tick(float fDeltaTime)
{
	return;
}

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);
	R6MenuRootWindow(Root).m_bPlayerWantLegend = m_bSelected;
	R6MenuRootWindow(Root).m_PlanningWidget.m_LegendWindow.ToggleLegend();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.__NFUN_2626__(Root.Colors.GrayDark.R, Root.Colors.GrayDark.G, Root.Colors.GrayDark.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, WinWidth, WinHeight, Texture'R6MenuTextures.LaptopTileBG');
	C.__NFUN_2626__(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
	super.Paint(C, X, Y);
	DrawSimpleBorder(C);
	return;
}

defaultproperties
{
	m_iDrawStyle=5
	bStretched=true
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=59170,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=59170,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=59170,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=59170,ZoneNumber=0)
}
