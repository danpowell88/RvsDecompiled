//=============================================================================
// R6Menu3DViewOnOffButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Menu3DViewOnOffButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/15 * Created by 
//=============================================================================
class R6Menu3DViewOnOffButton extends R6WindowStayDownButton;

function Created()
{
	bNoKeyboard = true;
	ToolTipString = Localize("PlanningMenu", "3DView", "R6Menu");
	ImageX = ((WinWidth - float(UpRegion.W)) / float(2));
	ImageY = ((WinHeight - float(UpRegion.H)) / float(2));
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
	local R6MenuRootWindow r6Root;

	super.LMouseDown(X, Y);
	r6Root = R6MenuRootWindow(Root);
	r6Root.Set3dView((!m_bSelected));
	r6Root.m_PlanningWidget.m_3DWindow.Toggle3DWindow();
	r6Root.m_PlanningWidget.CloseAllPopup();
	R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.SetDrawColor(Root.Colors.GrayDark.R, Root.Colors.GrayDark.G, Root.Colors.GrayDark.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, 0.0000000, 0.0000000, WinWidth, WinHeight, Texture'R6MenuTextures.LaptopTileBG');
	C.SetDrawColor(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);
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
	UpRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=47138,ZoneNumber=0)
	DownRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=54306,ZoneNumber=0)
	DisabledRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=57890,ZoneNumber=0)
	OverRegion=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=50722,ZoneNumber=0)
}
