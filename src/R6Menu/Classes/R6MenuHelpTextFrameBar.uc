//=============================================================================
// R6MenuHelpTextFrameBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuHelpTextFrameBar extends UWindowWindow;

var R6MenuHelpTextBar m_HelpTextBar;

function Created()
{
	m_HelpTextBar = R6MenuHelpTextBar(CreateWindow(Class'R6Menu.R6MenuHelpTextBar', 0.0000000, 1.0000000, WinWidth, __NFUN_175__(WinHeight, float(2)), self));
	m_BorderColor = Root.Colors.BlueLight;
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawSimpleBorder(C);
	return;
}

