//=============================================================================
// R6WindowHScrollbar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowHScrollBar.uc : Horizontal scrollbar with possibility to add a text (for tooltip option)
//							This class is different than vertical scrollbar
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/27 * Created by Yannick Joly
//=============================================================================
class R6WindowHScrollbar extends UWindowDialogControl;

var R6WindowTextLabelExt m_pSBText;
var UWindowHScrollbar m_pScrollBar;

//================================================================
//	Create the horizontal scroll bar 
//================================================================
function CreateSB(int _iScrollBarID, float _fX, float _fY, float _fWidth, float _fHeight, UWindowDialogClientWindow _DialogClientW)
{
	m_pScrollBar = UWindowHScrollbar(CreateWindow(Class'UWindow.UWindowHScrollbar', (WinWidth - _fWidth), _fY, _fWidth, LookAndFeel.Size_ScrollbarWidth, self));
	m_pScrollBar.SetRange(0.0000000, 10.0000000, 2.0000000);
	m_pScrollBar.Register(_DialogClientW);
	m_pScrollBar.m_iScrollBarID = _iScrollBarID;
	return;
}

//================================================================
//	SetScrollBarValue: Set the scroll bar value 
//================================================================
function SetScrollBarValue(float _fNewValue)
{
	local float fScrollValue;

	// End:0x6E
	if((m_pScrollBar != none))
	{
		fScrollValue = (m_pScrollBar.MaxPos / (m_pScrollBar.MaxPos + m_pScrollBar.MaxVisible));
		(fScrollValue *= _fNewValue);
		m_pScrollBar.pos = fScrollValue;
		m_pScrollBar.CheckRange();
	}
	return;
}

//================================================================
//	SetScrollBarRange: Set the scroll bar range
//================================================================
function SetScrollBarRange(float _fMin, float _fMax, float _fStep)
{
	// End:0x29
	if((m_pScrollBar != none))
	{
		m_pScrollBar.SetRange(_fMin, _fMax, _fStep);
	}
	return;
}

//================================================================
//	GetScrollBarValue: Get the scroll bar value
//================================================================
function float GetScrollBarValue()
{
	local float fRealValue;

	// End:0x5A
	if((m_pScrollBar != none))
	{
		fRealValue = ((m_pScrollBar.MaxPos + m_pScrollBar.MaxVisible) / m_pScrollBar.MaxPos);
		(fRealValue *= m_pScrollBar.pos);
		return fRealValue;
	}
	return 0.0000000;
	return;
}

//================================================================
//	Create an associate text to the scroll bar 
//================================================================
function CreateSBTextLabel(string _szText, string _szToolTip)
{
	// End:0xD2
	if((m_pScrollBar != none))
	{
		m_pSBText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0000000, 0.0000000, (WinWidth - m_pScrollBar.WinWidth), WinHeight, self));
		m_pSBText.bAlwaysBehind = true;
		m_pSBText.SetNoBorder();
		m_pSBText.m_Font = Root.Fonts[5];
		m_pSBText.m_vTextColor = Root.Colors.White;
		m_pSBText.AddTextLabel(_szText, 0.0000000, 0.0000000, 150.0000000, 0, false);
	}
	ToolTipString = _szToolTip;
	return;
}

function MouseEnter()
{
	super.MouseEnter();
	// End:0x3B
	if((m_pSBText != none))
	{
		m_pSBText.ChangeColorLabel(Root.Colors.ButtonTextColor[2], 0);
	}
	return;
}

function MouseLeave()
{
	super.MouseLeave();
	// End:0x38
	if((m_pSBText != none))
	{
		m_pSBText.ChangeColorLabel(Root.Colors.White, 0);
	}
	return;
}

