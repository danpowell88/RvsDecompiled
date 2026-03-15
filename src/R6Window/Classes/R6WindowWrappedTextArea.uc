//=============================================================================
// R6WindowWrappedTextArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowWrappedTextArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Alexandre Dionne
//=============================================================================
class R6WindowWrappedTextArea extends UWindowWrappedTextArea;

var int m_BGDrawStyle;
var bool m_bDrawBorders;
var bool m_bUseBGColor;
var bool m_bUseBGTexture;
var float m_fHBorderHeight;
// NEW IN 1.60
var float m_fVBorderWidth;
var float m_fHBorderPadding;
// NEW IN 1.60
var float m_fVBorderPadding;
var Texture m_HBorderTexture;
// NEW IN 1.60
var Texture m_VBorderTexture;
/////////////// BACK GROUND /////////////////////
var Texture m_BGTexture;
//var R6WindowVScrollBar VertSB;
var Class<UWindowVScrollbar> m_SBClass;
var Region m_HBorderTextureRegion;
// NEW IN 1.60
var Region m_VBorderTextureRegion;
var Region m_BGRegion;
var Color m_BGColor;

function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	// End:0x2A
	if((VertSB != none))
	{
		VertSB.SetBorderColor(_NewColor);
	}
	return;
}

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	// End:0x91
	if(newScrollable)
	{
		VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, (WinWidth - LookAndFeel.Size_ScrollbarWidth), 0.0000000, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		VertSB.bAlwaysOnTop = true;
		VertSB.SetHideWhenDisable(true);
		VertSB.m_BorderColor = m_BorderColor;		
	}
	else
	{
		// End:0xB2
		if((VertSB != none))
		{
			VertSB.Close();
			VertSB = none;
		}
	}
	return;
}

function Resize()
{
	// End:0x74
	if((VertSB != none))
	{
		VertSB.WinLeft = (WinWidth - LookAndFeel.Size_ScrollbarWidth);
		VertSB.WinTop = 0.0000000;
		VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinHeight = WinHeight;
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0xB0
	if(m_bUseBGTexture)
	{
		// End:0x46
		if(m_bUseBGColor)
		{
			C.SetDrawColor(m_BGColor.R, m_BGColor.G, m_BGColor.B, m_BGColor.A);
		}
		C.Style = byte(m_BGDrawStyle);
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, WinHeight, float(m_BGRegion.X), float(m_BGRegion.Y), float(m_BGRegion.W), float(m_BGRegion.H), m_BGTexture);
	}
	super.Paint(C, X, Y);
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	C.Style = byte(m_BorderStyle);
	// End:0x2DE
	if(m_bDrawBorders)
	{
		// End:0x1E2
		if((m_HBorderTexture != none))
		{
			DrawStretchedTextureSegment(C, m_fHBorderPadding, 0.0000000, (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
			DrawStretchedTextureSegment(C, m_fHBorderPadding, (WinHeight - m_fHBorderHeight), (WinWidth - (float(2) * m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		}
		// End:0x2DE
		if((m_VBorderTexture != none))
		{
			DrawStretchedTextureSegment(C, 0.0000000, (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
			DrawStretchedTextureSegment(C, (WinWidth - m_fVBorderWidth), (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - (float(2) * m_fVBorderPadding)), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		}
	}
	return;
}

function MouseWheelDown(float X, float Y)
{
	// End:0x24
	if((VertSB != none))
	{
		VertSB.MouseWheelDown(X, Y);
	}
	return;
}

function MouseWheelUp(float X, float Y)
{
	// End:0x24
	if((VertSB != none))
	{
		VertSB.MouseWheelUp(X, Y);
	}
	return;
}

defaultproperties
{
	m_BGDrawStyle=5
	m_bDrawBorders=true
	m_fHBorderHeight=1.0000000
	m_fVBorderWidth=1.0000000
	m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	m_SBClass=Class'R6Window.R6WindowVScrollbar'
	m_HBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=7714,ZoneNumber=0)
	m_VBorderTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=7714,ZoneNumber=0)
	m_BGRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=24866,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var e
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var g
