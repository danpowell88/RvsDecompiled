//=============================================================================
// R6MenuFramePopup - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuFramePopup extends R6WindowFramedWindow;

var const int m_iNbButton;
var int m_iTeamColor;
var int m_iFrameWidth;  // default width and height for popups windows
var int m_iTextureSize;
var bool m_bDisplayUp;
var bool m_bDisplayLeft;
var bool m_bInitialized;
var float m_fTitleBarHeight;
var float m_fTitleBarWidth;
var R6WindowListRadioButton m_ButtonList;
var Texture m_Texture;

//Should be before created.  Or add a function to that only once.
function BeforePaint(Canvas C, float X, float Y)
{
	// End:0x7C
	if(__NFUN_242__(m_bInitialized, false))
	{
		m_bInitialized = true;
		super.BeforePaint(C, X, Y);
		C.Font = Root.Fonts[8];
		TextSize(C, m_szWindowTitle, m_fTitleBarWidth, m_fTitleBarHeight);
		__NFUN_184__(m_fTitleBarHeight, 6.0000000);
		__NFUN_184__(m_fTitleBarWidth, 12.0000000);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Region R, temp;
	local Color iColor;

	m_iTeamColor = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
	// End:0x1D2
	if(__NFUN_123__(m_szWindowTitle, ""))
	{
		iColor = Root.Colors.TeamColor[m_iTeamColor];
		C.Style = 5;
		C.__NFUN_2626__(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), float(m_iTextureSize), __NFUN_175__(__NFUN_175__(WinWidth, float(m_iTextureSize)), float(m_iTextureSize)), __NFUN_175__(m_fTitleBarHeight, float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
		C.Style = 5;
		iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.__NFUN_2626__(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), m_fTitleBarHeight, __NFUN_175__(__NFUN_175__(WinWidth, float(m_iTextureSize)), float(m_iTextureSize)), __NFUN_175__(__NFUN_175__(WinHeight, m_fTitleBarHeight), float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);		
	}
	else
	{
		C.Style = 5;
		iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.__NFUN_2626__(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), float(m_iTextureSize), __NFUN_175__(__NFUN_175__(WinWidth, float(m_iTextureSize)), float(m_iTextureSize)), __NFUN_175__(__NFUN_175__(WinHeight, float(m_iTextureSize)), float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	}
	iColor = Root.Colors.TeamColor[m_iTeamColor];
	C.__NFUN_2626__(iColor.R, iColor.G, iColor.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	// End:0x387
	if(__NFUN_123__(m_szWindowTitle, ""))
	{
		DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(m_fTitleBarHeight, float(1)), WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	}
	DrawStretchedTextureSegment(C, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), __NFUN_175__(__NFUN_175__(WinHeight, float(m_iTextureSize)), float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	DrawStretchedTextureSegment(C, __NFUN_175__(WinWidth, float(m_iTextureSize)), float(m_iTextureSize), float(m_iTextureSize), __NFUN_175__(__NFUN_175__(WinHeight, float(m_iTextureSize)), float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	DrawStretchedTextureSegment(C, 0.0000000, __NFUN_175__(WinHeight, float(m_iTextureSize)), WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	C.Style = 5;
	C.Font = Root.Fonts[8];
	iColor = Root.Colors.White;
	C.__NFUN_2626__(iColor.R, iColor.G, iColor.B);
	ClipTextWidth(C, m_fTitleOffSet, 3.0000000, m_szWindowTitle, WinWidth);
	return;
}

function Resized()
{
	local float fHeight, fWidth;

	// End:0x5B
	if(__NFUN_177__(m_fTitleBarWidth, m_ButtonList.WinWidth))
	{
		fWidth = __NFUN_174__(m_fTitleBarWidth, float(__NFUN_144__(m_iFrameWidth, 2)));
		m_ButtonList.WinWidth = m_fTitleBarWidth;
		m_ButtonList.ChangeItemsSize(m_fTitleBarWidth);		
	}
	else
	{
		fWidth = __NFUN_174__(m_ButtonList.WinWidth, float(__NFUN_144__(m_iFrameWidth, 2)));
	}
	fHeight = __NFUN_174__(__NFUN_174__(m_ButtonList.WinHeight, m_fTitleBarHeight), float(m_iFrameWidth));
	// End:0x162
	if(__NFUN_132__(__NFUN_181__(fWidth, WinWidth), __NFUN_181__(fHeight, WinHeight)))
	{
		m_ButtonList.WinTop = m_fTitleBarHeight;
		m_ButtonList.WinLeft = float(m_iFrameWidth);
		super.Resized();
		// End:0x10F
		if(__NFUN_242__(m_bDisplayLeft, true))
		{
			__NFUN_184__(WinLeft, __NFUN_175__(WinWidth, fWidth));
		}
		WinWidth = fWidth;
		m_fTitleOffSet = __NFUN_174__(__NFUN_172__(__NFUN_175__(WinWidth, m_fTitleBarWidth), float(2)), float(6));
		// End:0x157
		if(__NFUN_242__(m_bDisplayUp, true))
		{
			__NFUN_184__(WinTop, __NFUN_175__(WinHeight, fHeight));
		}
		WinHeight = fHeight;
	}
	return;
}

function ShowWindow()
{
	super(UWindowWindow).ShowWindow();
	m_ButtonList.ShowWindow();
	return;
}

function AjustPosition(bool bDisplayUp, bool bDisplayLeft)
{
	m_bDisplayUp = bDisplayUp;
	m_bDisplayLeft = bDisplayLeft;
	// End:0x32
	if(__NFUN_242__(m_bDisplayLeft, true))
	{
		__NFUN_185__(WinLeft, WinWidth);
	}
	// End:0x4A
	if(__NFUN_242__(m_bDisplayUp, true))
	{
		__NFUN_185__(WinTop, WinHeight);
	}
	return;
}

defaultproperties
{
	m_iFrameWidth=1
	m_iTextureSize=1
	m_fTitleBarHeight=17.0000000
	m_Texture=Texture'Color.Color.White'
	m_TitleAlign=2
	m_bDisplayClose=false
}
