//=============================================================================
// R6MenuHelpTextBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuHelpTextBar extends UWindowWindow;

var float m_fTextX;
var float m_fTextY;
var string m_szText;
var string m_szDefaultText;

function BeforePaint(Canvas C, float X, float Y)
{
	local float W, H;

	C.Font = Root.Fonts[5];
	m_szText = m_szDefaultText;
	// End:0x7A
	if(__NFUN_119__(Root.MouseWindow, none))
	{
		// End:0x7A
		if(__NFUN_123__(Root.MouseWindow.ToolTipString, ""))
		{
			m_szText = Root.MouseWindow.ToolTipString;
		}
	}
	// End:0xE7
	if(__NFUN_123__(m_szText, ""))
	{
		TextSize(C, m_szText, W, H);
		m_fTextX = __NFUN_172__(__NFUN_175__(WinWidth, W), float(2));
		m_fTextY = __NFUN_172__(__NFUN_175__(WinHeight, H), float(2));
		m_fTextY = float(int(__NFUN_174__(m_fTextY, 0.5000000)));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	C.Font = Root.Fonts[5];
	ClipText(C, m_fTextX, m_fTextY, m_szText);
	return;
}

