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
	if((m_bInitialized == false))
	{
		m_bInitialized = true;
		super.BeforePaint(C, X, Y);
		C.Font = Root.Fonts[8];
		TextSize(C, m_szWindowTitle, m_fTitleBarWidth, m_fTitleBarHeight);
		(m_fTitleBarHeight += 6.0000000);
		(m_fTitleBarWidth += 12.0000000);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local Region R, temp;
	local Color iColor;

	m_iTeamColor = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
	// End:0x1D2
	if((m_szWindowTitle != ""))
	{
		iColor = Root.Colors.TeamColor[m_iTeamColor];
		C.Style = 5;
		C.SetDrawColor(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), float(m_iTextureSize), ((WinWidth - float(m_iTextureSize)) - float(m_iTextureSize)), (m_fTitleBarHeight - float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
		C.Style = 5;
		iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.SetDrawColor(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), m_fTitleBarHeight, ((WinWidth - float(m_iTextureSize)) - float(m_iTextureSize)), ((WinHeight - m_fTitleBarHeight) - float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);		
	}
	else
	{
		C.Style = 5;
		iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.SetDrawColor(iColor.R, iColor.G, iColor.B, byte(Root.Colors.PopUpAlphaFactor));
		DrawStretchedTextureSegment(C, float(m_iTextureSize), float(m_iTextureSize), ((WinWidth - float(m_iTextureSize)) - float(m_iTextureSize)), ((WinHeight - float(m_iTextureSize)) - float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	}
	iColor = Root.Colors.TeamColor[m_iTeamColor];
	C.SetDrawColor(iColor.R, iColor.G, iColor.B);
	DrawStretchedTextureSegment(C, 0.0000000, 0.0000000, WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	// End:0x387
	if((m_szWindowTitle != ""))
	{
		DrawStretchedTextureSegment(C, 0.0000000, (m_fTitleBarHeight - float(1)), WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	}
	DrawStretchedTextureSegment(C, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), ((WinHeight - float(m_iTextureSize)) - float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	DrawStretchedTextureSegment(C, (WinWidth - float(m_iTextureSize)), float(m_iTextureSize), float(m_iTextureSize), ((WinHeight - float(m_iTextureSize)) - float(m_iTextureSize)), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	DrawStretchedTextureSegment(C, 0.0000000, (WinHeight - float(m_iTextureSize)), WinWidth, float(m_iTextureSize), 0.0000000, 0.0000000, float(m_iTextureSize), float(m_iTextureSize), m_Texture);
	C.Style = 5;
	C.Font = Root.Fonts[8];
	iColor = Root.Colors.White;
	C.SetDrawColor(iColor.R, iColor.G, iColor.B);
	ClipTextWidth(C, m_fTitleOffSet, 3.0000000, m_szWindowTitle, WinWidth);
	return;
}

function Resized()
{
	local float fHeight, fWidth;

	// End:0x5B
	if((m_fTitleBarWidth > m_ButtonList.WinWidth))
	{
		fWidth = (m_fTitleBarWidth + float((m_iFrameWidth * 2)));
		m_ButtonList.WinWidth = m_fTitleBarWidth;
		m_ButtonList.ChangeItemsSize(m_fTitleBarWidth);		
	}
	else
	{
		fWidth = (m_ButtonList.WinWidth + float((m_iFrameWidth * 2)));
	}
	fHeight = ((m_ButtonList.WinHeight + m_fTitleBarHeight) + float(m_iFrameWidth));
	// End:0x162
	if(((fWidth != WinWidth) || (fHeight != WinHeight)))
	{
		m_ButtonList.WinTop = m_fTitleBarHeight;
		m_ButtonList.WinLeft = float(m_iFrameWidth);
		super.Resized();
		// End:0x10F
		if((m_bDisplayLeft == true))
		{
			(WinLeft += (WinWidth - fWidth));
		}
		WinWidth = fWidth;
		m_fTitleOffSet = (((WinWidth - m_fTitleBarWidth) / float(2)) + float(6));
		// End:0x157
		if((m_bDisplayUp == true))
		{
			(WinTop += (WinHeight - fHeight));
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
	if((m_bDisplayLeft == true))
	{
		(WinLeft -= WinWidth);
	}
	// End:0x4A
	if((m_bDisplayUp == true))
	{
		(WinTop -= WinHeight);
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
