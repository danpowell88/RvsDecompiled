//=============================================================================
// R6MenuTeamDisplayButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuTeamDisplayButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6MenuTeamDisplayButton extends R6WindowButton;

var int m_iTeamColor;
var Texture m_ActiveTexture;
var Region m_ActiveRegion;

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
	if((m_bSelected == true))
	{
		C.SetDrawColor(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, float(m_ActiveRegion.X), float(m_ActiveRegion.Y), float(m_ActiveRegion.W), float(m_ActiveRegion.H), m_ActiveTexture);
	}
	return;
}

function LMouseDown(float X, float Y)
{
	local float fGlobalX, fGlobalY;

	// End:0x91
	if(((!bDisabled) && (m_iTeamColor != R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam)))
	{
		super(UWindowWindow).LMouseDown(X, Y);
		m_bSelected = (!m_bSelected);
		R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[m_iTeamColor].SetPathDisplay(m_bSelected);
		R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
	}
	return;
}

defaultproperties
{
	m_ActiveTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ActiveRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
	m_iDrawStyle=5
	bUseRegion=true
	m_bSelected=true
	UpTexture=Texture'R6MenuTextures.Gui_03'
	DownTexture=Texture'R6MenuTextures.Gui_03'
	DisabledTexture=Texture'R6MenuTextures.Gui_03'
	OverTexture=Texture'R6MenuTextures.Gui_03'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48418,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48418,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48418,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48418,ZoneNumber=0)
}
