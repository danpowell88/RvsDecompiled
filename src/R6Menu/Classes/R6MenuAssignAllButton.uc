//=============================================================================
// R6MenuAssignAllButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuAssignAllButton.uc : This button should assign it's associated item
//                              to all team members
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuAssignAllButton extends R6WindowButton;

var bool m_bDrawLeftBorder;  // draw the left broder
var bool m_bDrawRightBorder;
var bool m_bDrawTopBorder;
var bool m_bDrawDownBorder;
var Color m_DisableColor;
var Color m_EnableColor;

function Created()
{
	m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor = Root.Colors.White;
	m_vButtonColor = m_DisableColor;
	m_BorderColor = m_DisableColor;
	m_bDrawBorders = true;
	m_bDrawSimpleBorder = true;
	return;
}

function RMouseDown(float X, float Y)
{
	bRMouseDown = true;
	return;
}

function MMouseDown(float X, float Y)
{
	bMMouseDown = true;
	return;
}

function LMouseDown(float X, float Y)
{
	bMouseDown = true;
	return;
}

function DrawSimpleBorder(Canvas C)
{
	C.Style = byte(m_BorderStyle);
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	// End:0xA4
	if(m_bDrawTopBorder)
	{
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	}
	// End:0x116
	if(m_bDrawDownBorder)
	{
		DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_BorderTextureRegion.H)), WinWidth, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	}
	// End:0x193
	if(m_bDrawLeftBorder)
	{
		DrawStretchedTextureSegment(C, 0.0000000, float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	}
	// End:0x21E
	if(m_bDrawRightBorder)
	{
		DrawStretchedTextureSegment(C, (WinWidth - float(m_BorderTextureRegion.W)), float(m_BorderTextureRegion.H), float(m_BorderTextureRegion.W), (WinHeight - float((2 * m_BorderTextureRegion.H))), float(m_BorderTextureRegion.X), float(m_BorderTextureRegion.Y), float(m_BorderTextureRegion.W), float(m_BorderTextureRegion.H), m_BorderTexture);
	}
	return;
}

//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonStatus(bool _bDisable)
{
	bDisabled = _bDisable;
	// End:0x24
	if(_bDisable)
	{
		m_vButtonColor = m_DisableColor;		
	}
	else
	{
		m_vButtonColor = m_EnableColor;
	}
	return;
}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	return;
}

function SetCompleteAssignAllButton()
{
	m_bDrawLeftBorder = true;
	m_bDrawRightBorder = true;
	m_bDrawTopBorder = true;
	m_bDrawDownBorder = true;
	UpRegion = NewRegion(172.0000000, 0.0000000, 30.0000000, 13.0000000);
	OverRegion = NewRegion(172.0000000, 13.0000000, 30.0000000, 13.0000000);
	DownRegion = NewRegion(172.0000000, 26.0000000, 30.0000000, 13.0000000);
	DisabledRegion = NewRegion(172.0000000, 0.0000000, 30.0000000, 13.0000000);
	ImageX = ((WinWidth - float(UpRegion.W)) / float(2));
	ImageY = 0.0000000;
	return;
}

defaultproperties
{
	m_bDrawLeftBorder=true
	m_iDrawStyle=5
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DisabledTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	OverTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
	DisabledRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=44066,ZoneNumber=0)
}
