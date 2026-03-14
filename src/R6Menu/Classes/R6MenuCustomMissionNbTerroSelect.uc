//=============================================================================
// R6MenuCustomMissionNbTerroSelect - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuCustomMissionNbTerroSelect.uc : Select Terro Count
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/24 * Created by Alexandre Dionne
//=============================================================================
class R6MenuCustomMissionNbTerroSelect extends UWindowDialogClientWindow
 config(User);

var const int c_iNbTerroMax;
var const int c_iNbTerroMin;
var config int CustomMissionNbTerro;
var float m_fLabelHeight;
var R6WindowTextLabel m_TitleNbTerro;
var R6WindowCounter m_TerroCounter;

function Created()
{
	m_TitleNbTerro = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, m_fLabelHeight, self));
	m_TitleNbTerro.Text = Localize("CustomMission", "NbTerro", "R6Menu");
	m_TitleNbTerro.Align = 2;
	m_TitleNbTerro.m_Font = Root.Fonts[8];
	m_TitleNbTerro.TextColor = Root.Colors.White;
	m_TitleNbTerro.m_bDrawBorders = false;
	m_TerroCounter = R6WindowCounter(CreateWindow(Class'R6Window.R6WindowCounter', 0.0000000, __NFUN_174__(__NFUN_174__(m_TitleNbTerro.WinTop, m_TitleNbTerro.WinHeight), float(9)), WinWidth, 15.0000000, self));
	m_TerroCounter.bAlwaysBehind = true;
	m_TerroCounter.ToolTipString = Localize("Tip", "Custom_NbTerro", "R6Menu");
	m_TerroCounter.m_iButtonID = 0;
	m_TerroCounter.SetAdviceParent(false);
	m_TerroCounter.CreateButtons(__NFUN_175__(__NFUN_172__(m_TerroCounter.WinWidth, float(2)), float(30)), 0.0000000, 60.0000000);
	m_TerroCounter.SetDefaultValues(c_iNbTerroMin, c_iNbTerroMax, CustomMissionNbTerro);
	m_TerroCounter.SetButtonToolTip(Localize("Tip", "Custom_NbTerro", "R6Menu"), Localize("Tip", "Custom_NbTerro", "R6Menu"));
	return;
}

function int GetNbTerro()
{
	// End:0x2F
	if(__NFUN_155__(m_TerroCounter.m_iCounter, CustomMissionNbTerro))
	{
		CustomMissionNbTerro = m_TerroCounter.m_iCounter;
		__NFUN_536__();
	}
	return m_TerroCounter.m_iCounter;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Style = 4;
	DrawStretchedTextureSegment(C, m_TitleNbTerro.WinLeft, m_TitleNbTerro.WinTop, m_TitleNbTerro.WinWidth, m_TitleNbTerro.WinHeight, 77.0000000, 0.0000000, 4.0000000, 29.0000000, Texture'R6MenuTextures.Gui_BoxScroll');
	C.Style = 5;
	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTexture(C, 0.0000000, __NFUN_174__(m_TitleNbTerro.WinTop, m_TitleNbTerro.WinHeight), WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	return;
}

defaultproperties
{
	c_iNbTerroMax=35
	c_iNbTerroMin=5
	CustomMissionNbTerro=20
	m_fLabelHeight=29.0000000
}
