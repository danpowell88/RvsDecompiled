//=============================================================================
// R6MenuHelpWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuHelpWindow.uc : This is the help window where the tooltip is suppose to be display
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6MenuHelpWindow extends R6WindowSimpleFramedWindowExt;

var bool m_bForceRefreshOnSameTip;  // force to clear wrapped text area for a same tip

function Created()
{
	local UWindowWrappedTextArea pHelpZone;
	local float fWidth;

	fWidth = 1.0000000;
	m_ClientArea = CreateWindow(Class'UWindow.UWindowWrappedTextArea', 0.0000000, 0.0000000, WinWidth, WinHeight, OwnerWindow);
	SetBorderParam(0, 7.0000000, 0.0000000, fWidth, Root.Colors.White);
	SetBorderParam(1, 7.0000000, 0.0000000, fWidth, Root.Colors.White);
	ActiveBorder(2, false);
	ActiveBorder(3, false);
	ActiveBackGround(true, Root.Colors.Black);
	m_eCornerType = 3;
	SetCornerColor(3, Root.Colors.White);
	pHelpZone = UWindowWrappedTextArea(m_ClientArea);
	pHelpZone.SetScrollable(false);
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip)
{
	// End:0xB8
	if(((strTip != ToolTipString) || m_bForceRefreshOnSameTip))
	{
		ToolTipString = strTip;
		UWindowWrappedTextArea(m_ClientArea).Clear();
		// End:0xB8
		if((ToolTipString != ""))
		{
			UWindowWrappedTextArea(m_ClientArea).m_fXOffSet = 5.0000000;
			UWindowWrappedTextArea(m_ClientArea).m_fYOffSet = 5.0000000;
			UWindowWrappedTextArea(m_ClientArea).AddText(ToolTipString, Root.Colors.ToolTipColor, Root.Fonts[12]);
		}
	}
	return;
}

//==========================================================================
// AddTipText: Call this after a new tooltip. Force to put the next on the next line
//==========================================================================
function AddTipText(string _szNewText)
{
	UWindowWrappedTextArea(m_ClientArea).AddText(_szNewText, Root.Colors.ToolTipColor, Root.Fonts[12]);
	return;
}

