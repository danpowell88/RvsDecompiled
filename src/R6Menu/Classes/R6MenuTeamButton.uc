//=============================================================================
// R6MenuTeamButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTeamButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamButton extends R6WindowButton;

var int m_iTeamColor;
var Texture m_DotTexture;
var Region m_DotRegion;

function Created()
{
	bNoKeyboard = true;
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function Tick(float fDelta)
{
	return;
}

function Paint(Canvas C, float X, float Y)
{
	super.Paint(C, X, Y);
	// End:0x9F
	if(__NFUN_242__(m_bSelected, true))
	{
		C.__NFUN_2626__(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, float(m_DotRegion.X), float(m_DotRegion.Y), float(m_DotRegion.W), float(m_DotRegion.H), m_DotTexture);
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local float fGlobalX, fGlobalY;

	super(UWindowWindow).LMouseDown(X, Y);
	// End:0x67
	if(__NFUN_130__(__NFUN_129__(bDisabled), OwnerWindow.__NFUN_303__('R6MenuTeamBar')))
	{
		R6MenuTeamBar(OwnerWindow).SetTeamActive(m_iTeamColor);
		R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	}
	return;
}

defaultproperties
{
	m_DotTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_DotRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=51234,ZoneNumber=0)
	m_iDrawStyle=5
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=55586,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=55586,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=55586,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=55586,ZoneNumber=0)
}
