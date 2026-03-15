//=============================================================================
// R6MenuOperativeHistory - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuOperativeHistory.uc : Page wich contains Operative 2d face, flag and
//                              history text
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeHistory extends UWindowWindow;

var R6WindowWrappedTextArea m_OperativeText;
var R6WindowTextLabel m_Title;

function Created()
{
	m_Title = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 0.0000000, WinWidth, 17.0000000, self));
	m_Title.Text = Localize("GearRoom", "History", "R6Menu");
	m_Title.Align = 2;
	m_Title.m_Font = Root.Fonts[6];
	m_Title.m_BGTexture = none;
	m_Title.m_bDrawBorders = false;
	m_OperativeText = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', 0.0000000, (m_Title.WinTop + m_Title.WinHeight), WinWidth, (WinHeight - m_Title.WinHeight), self));
	m_OperativeText.m_HBorderTexture = none;
	m_OperativeText.m_VBorderTexture = none;
	m_OperativeText.m_fHBorderHeight = 0.0000000;
	m_OperativeText.m_fVBorderWidth = 0.0000000;
	m_OperativeText.SetScrollable(true);
	m_OperativeText.VertSB.SetEffect(true);
	return;
}

function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	m_Title.m_BorderColor = _NewColor;
	m_OperativeText.SetBorderColor(_NewColor);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	R6WindowLookAndFeel(LookAndFeel).DrawBGShading(self, C, m_OperativeText.WinLeft, m_OperativeText.WinTop, m_OperativeText.WinWidth, m_OperativeText.WinHeight);
	C.Style = 5;
	C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
	DrawStretchedTexture(C, 0.0000000, m_OperativeText.WinTop, WinWidth, 1.0000000, Texture'UWindow.WhiteTexture');
	return;
}

function SetText(Canvas C, string NewText)
{
	m_OperativeText.Clear();
	m_OperativeText.AddTextWithCanvas(C, 5.0000000, 5.0000000, NewText, Root.Fonts[6], Root.Colors.White);
	return;
}

