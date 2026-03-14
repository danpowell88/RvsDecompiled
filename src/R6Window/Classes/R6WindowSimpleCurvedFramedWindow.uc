//=============================================================================
// R6WindowSimpleCurvedFramedWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowSimpleCurvedFramedWindow.uc : This provides a simple frame for a window
//										 with the curved style
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================
class R6WindowSimpleCurvedFramedWindow extends R6WindowSimpleFramedWindow;

var UWindowBase.TextAlign m_TitleAlign;
var float m_fFontSpacing;  // Space between characters
var float m_fLMarge;  // Left Text Margin
var R6WindowTextLabelCurved m_topLabel;
var Font m_Font;
var Color m_TextColor;
var string m_Title;

function Created()
{
	m_topLabel = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 0.0000000, 0.0000000, WinWidth, 31.0000000, self));
	m_fVBorderOffset = m_topLabel.m_fVBorderOffset;
	m_fHBorderPadding = float(__NFUN_146__(m_topLabel.m_topLeftCornerR.W, 1));
	m_fVBorderPadding = float(__NFUN_146__(m_topLabel.m_topLeftCornerR.H, 1));
	return;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow(Class<UWindowWindow> ClientClass)
{
	m_ClientClass = ClientClass;
	m_ClientArea = CreateWindow(m_ClientClass, __NFUN_174__(m_fVBorderWidth, m_fVBorderOffset), __NFUN_174__(__NFUN_174__(m_fHBorderHeight, m_fHBorderOffset), m_topLabel.WinHeight), __NFUN_175__(__NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fVBorderWidth)), __NFUN_171__(float(2), m_fVBorderOffset)), __NFUN_175__(__NFUN_175__(__NFUN_175__(WinHeight, __NFUN_171__(float(2), m_fHBorderHeight)), __NFUN_171__(float(2), m_fHBorderOffset)), m_topLabel.WinHeight), OwnerWindow);
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	m_topLabel.Text = m_Title;
	m_topLabel.Align = m_TitleAlign;
	m_topLabel.m_Font = m_Font;
	m_topLabel.TextColor = m_TextColor;
	m_topLabel.m_fFontSpacing = m_fFontSpacing;
	m_topLabel.m_fLMarge = m_fLMarge;
	m_topLabel.m_BorderColor = m_BorderColor;
	return;
}

function SetCornerType(R6WindowSimpleFramedWindow.eCornerType _eCornerType)
{
	switch(_eCornerType)
	{
		// End:0x30
		case 1:
			m_fHBorderOffset = 0.0000000;
			m_fHBorderPadding = m_fVBorderOffset;
			m_fVBorderPadding = m_fHBorderHeight;
			// End:0x5E
			break;
		// End:0x35
		case 2:
		// End:0x5B
		case 3:
			m_fHBorderOffset = default.m_fHBorderOffset;
			m_fHBorderPadding = default.m_fHBorderPadding;
			m_fVBorderPadding = default.m_fVBorderPadding;
		// End:0xFFFF
		default:
			break;
	}
	m_eCornerType = _eCornerType;
	return;
}

function AfterPaint(Canvas C, float X, float Y)
{
	local float tempSpace;

	C.__NFUN_2626__(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	C.Style = byte(m_DrawStyle);
	// End:0xBA
	if(__NFUN_119__(m_HBorderTexture, none))
	{
		DrawStretchedTextureSegment(C, m_fHBorderPadding, __NFUN_175__(__NFUN_175__(WinHeight, m_fHBorderHeight), m_fHBorderOffset), __NFUN_175__(WinWidth, __NFUN_171__(float(2), m_fHBorderPadding)), m_fHBorderHeight, float(m_HBorderTextureRegion.X), float(m_HBorderTextureRegion.Y), float(m_HBorderTextureRegion.W), float(m_HBorderTextureRegion.H), m_HBorderTexture);
	}
	// End:0x1BB
	if(__NFUN_119__(m_VBorderTexture, none))
	{
		DrawStretchedTextureSegment(C, m_fVBorderOffset, m_topLabel.WinHeight, m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, m_fVBorderPadding), m_topLabel.WinHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
		DrawStretchedTextureSegment(C, __NFUN_175__(__NFUN_175__(WinWidth, m_fVBorderWidth), m_fVBorderOffset), m_topLabel.WinHeight, m_fVBorderWidth, __NFUN_175__(__NFUN_175__(WinHeight, m_fVBorderPadding), m_topLabel.WinHeight), float(m_VBorderTextureRegion.X), float(m_VBorderTextureRegion.Y), float(m_VBorderTextureRegion.W), float(m_VBorderTextureRegion.H), m_VBorderTexture);
	}
	switch(m_eCornerType)
	{
		// End:0x1CA
		case 1:
			// End:0x2F2
			break;
		// End:0x1CF
		case 2:
		// End:0x2EF
		case 3:
			DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(m_topLeftCornerR.X), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
			DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_topLeftCornerR.W)), __NFUN_175__(WinHeight, float(m_topLeftCornerR.H)), float(m_topLeftCornerR.W), float(m_topLeftCornerR.H), float(__NFUN_146__(m_topLeftCornerR.X, m_topLeftCornerR.W)), float(__NFUN_146__(m_topLeftCornerR.Y, m_topLeftCornerR.H)), float(__NFUN_143__(m_topLeftCornerR.W)), float(__NFUN_143__(m_topLeftCornerR.H)), m_topLeftCornerT);
			// End:0x2F2
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

defaultproperties
{
	m_fLMarge=2.0000000
}
