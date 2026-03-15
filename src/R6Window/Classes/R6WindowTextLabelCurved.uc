//=============================================================================
// R6WindowTextLabelCurved - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowTextLabelCurved.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/02 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextLabelCurved extends R6WindowTextLabel;

var float m_RightCurveLineWidth;
var float m_fVBorderOffset;
var float m_fRightCurveLineX;
// NEW IN 1.60
var float m_fLeftCurveLineX;
var Texture m_TLeftcurve;
// NEW IN 1.60
var Texture m_TBetweenCurveBG;
// NEW IN 1.60
var Texture m_TUnderLeftCurveBG;
var Texture m_topLeftCornerT;
var Region m_RLeftcurve;
// NEW IN 1.60
var Region m_RBetweenCurveBG;
// NEW IN 1.60
var Region m_RUnderLeftCurveBG;
var Region m_topLeftCornerR;

function Created()
{
	m_fRightCurveLineX = (((WinWidth - m_fVBorderWidth) - float(m_topLeftCornerR.W)) - m_RightCurveLineWidth);
	m_fLeftCurveLineX = ((m_fRightCurveLineX - float((2 * m_RLeftcurve.W))) - float(m_RBetweenCurveBG.W));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x266
	if((m_BGTexture != none))
	{
		C.Style = 4;
		DrawStretchedTextureSegment(C, m_fVBorderWidth, m_fHBorderHeight, (m_fLeftCurveLineX - m_fVBorderWidth), (WinHeight - (float(2) * m_fHBorderHeight)), float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		DrawStretchedTextureSegment(C, m_fRightCurveLineX, m_fHBorderHeight, ((WinWidth - m_fVBorderWidth) - m_fRightCurveLineX), (WinHeight - (float(2) * m_fHBorderHeight)), float(m_BGTextureRegion.X), float(m_BGTextureRegion.Y), float(m_BGTextureRegion.W), float(m_BGTextureRegion.H), m_BGTexture);
		DrawStretchedTextureSegment(C, ((m_fRightCurveLineX - float(m_RLeftcurve.W)) - float(m_RBetweenCurveBG.W)), float(m_RLeftcurve.H), float(m_RBetweenCurveBG.W), ((WinHeight - m_fHBorderHeight) - float(m_RLeftcurve.H)), float(m_RBetweenCurveBG.X), float(m_RBetweenCurveBG.Y), float(m_RBetweenCurveBG.W), float(m_RBetweenCurveBG.H), m_TBetweenCurveBG);
		DrawStretchedTextureSegment(C, m_fLeftCurveLineX, m_fHBorderHeight, float(m_RUnderLeftCurveBG.W), float(m_RUnderLeftCurveBG.H), float(m_RUnderLeftCurveBG.X), float(m_RUnderLeftCurveBG.Y), float(m_RUnderLeftCurveBG.W), float(m_RUnderLeftCurveBG.H), m_TUnderLeftCurveBG);
		DrawStretchedTextureSegment(C, (m_fRightCurveLineX - float(m_RLeftcurve.W)), m_fHBorderHeight, float(m_RUnderLeftCurveBG.W), float(m_RUnderLeftCurveBG.H), float((m_RUnderLeftCurveBG.X + m_RUnderLeftCurveBG.W)), float(m_RUnderLeftCurveBG.Y), float((-m_RUnderLeftCurveBG.W)), float(m_RUnderLeftCurveBG.H), m_TUnderLeftCurveBG);
	}
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	// End:0x44D
	if((m_HBorderTexture != none))
	{
		C.Style = 5;
		DrawStretchedTextureSegment(C, m_fHBorderPadding, 0.0000000, (m_fLeftCurveLineX - m_fHBorderPadding), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, m_fRightCurveLineX, 0.0000000, m_RightCurveLineWidth, m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, ((m_fRightCurveLineX - float(m_RLeftcurve.W)) - float(m_RBetweenCurveBG.W)), float((m_RLeftcurve.H - m_HBorderTextureRegion.H)), float(m_RBetweenCurveBG.W), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
		DrawStretchedTextureSegment(C, m_fVBorderOffset, (WinHeight - m_fHBorderHeight), (WinWidth - (float(2) * m_fVBorderOffset)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x569
	if((m_TLeftcurve != none))
	{
		C.Style = 5;
		DrawStretchedTextureSegment(C, (m_fRightCurveLineX - float(m_RLeftcurve.W)), 0.0000000, float(m_RLeftcurve.W), float(m_RLeftcurve.H), float((m_RLeftcurve.X + m_RLeftcurve.W)), float(m_RLeftcurve.Y), float((-m_RLeftcurve.W)), float(m_RLeftcurve.H), m_TLeftcurve);
		DrawStretchedTextureSegment(C, ((m_fRightCurveLineX - float((2 * m_RLeftcurve.W))) - float(m_RBetweenCurveBG.W)), 0.0000000, float(m_RLeftcurve.W), float(m_RLeftcurve.H), float(m_RLeftcurve.X), float(m_RLeftcurve.Y), float(m_RLeftcurve.W), float(m_RLeftcurve.H), m_TLeftcurve);
	}
	// End:0x671
	if((m_VBorderTexture != none))
	{
		C.Style = 5;
		DrawStretchedTextureSegment(C, m_fVBorderOffset, (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - m_fVBorderPadding), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		DrawStretchedTextureSegment(C, ((WinWidth - m_fVBorderWidth) - m_fVBorderOffset), (m_fHBorderHeight + m_fVBorderPadding), m_fVBorderWidth, ((WinHeight - (float(2) * m_fHBorderHeight)) - m_fVBorderPadding), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	// End:0x76D
	if((m_topLeftCornerT != none))
	{
		C.Style = 5;
		DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(m_topLeftCornerR.Y), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), m_topLeftCornerT);
		DrawStretchedTextureSegment(C, (WinWidth - float(m_topLeftCornerR.W)), 0.0000000, float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float((m_topLeftCornerR.X + m_topLeftCornerR.W)), float(m_topLeftCornerR.Y), float((-m_topLeftCornerR.W)), float(m_topLeftCornerR.H), m_topLeftCornerT);
	}
	// End:0x7F7
	if((Text != ""))
	{
		C.Style = 1;
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;
		C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		ClipText(C, TextX, TextY, Text, true);
	}
	return;
}

defaultproperties
{
	m_RightCurveLineWidth=11.0000000
	m_fVBorderOffset=1.0000000
	m_TLeftcurve=Texture'R6MenuTextures.Gui_BoxScroll'
	m_TBetweenCurveBG=Texture'R6MenuTextures.Gui_BoxScroll'
	m_TUnderLeftCurveBG=Texture'R6MenuTextures.Gui_BoxScroll'
	m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
	m_RLeftcurve=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=4642,ZoneNumber=0)
	m_RBetweenCurveBG=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=24866,ZoneNumber=0)
	m_RUnderLeftCurveBG=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=21538,ZoneNumber=0)
	m_topLeftCornerR=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=3106,ZoneNumber=0)
	m_fHBorderPadding=7.0000000
	m_fVBorderPadding=6.0000000
	m_BGTextureRegion=(Zone=Class'R6Window.R6WindowListServerItem',iLeaf=19746,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var G
// REMOVED IN 1.60: var X
