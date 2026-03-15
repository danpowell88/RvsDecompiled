//=============================================================================
// R6MenuMPInGameHelpBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPInGameHelpBar.uc : The help text bar for in game menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/28 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameHelpBar extends R6MenuHelpTextBar;

var bool m_bUseExternSetTip;
var string m_szExternTip;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	C.Font = Root.Fonts[5];
	// End:0x4F
	if(m_bUseExternSetTip)
	{
		m_szText = GetToolTip();
		// End:0x4C
		if((m_szText == ""))
		{
			m_szText = m_szDefaultText;
		}		
	}
	else
	{
		m_szText = m_szDefaultText;
		// End:0xA9
		if((Root.MouseWindow != none))
		{
			// End:0xA9
			if((Root.MouseWindow.ToolTipString != ""))
			{
				m_szText = Root.MouseWindow.ToolTipString;
			}
		}
	}
	// End:0x116
	if((m_szText != ""))
	{
		TextSize(C, m_szText, W, H);
		m_fTextX = ((WinWidth - W) / float(2));
		m_fTextY = ((WinHeight - H) / float(2));
		m_fTextY = float(int((m_fTextY + 0.5000000)));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	C.Style = 5;
	C.Font = Root.Fonts[5];
	ClipText(C, m_fTextX, m_fTextY, m_szText);
	return;
}

function SetToolTip(string _szToolTip)
{
	m_szExternTip = _szToolTip;
	return;
}

function string GetToolTip()
{
	return m_szExternTip;
	return;
}

