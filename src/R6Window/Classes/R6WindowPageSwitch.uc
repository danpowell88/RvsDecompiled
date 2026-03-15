//=============================================================================
// R6WindowPageSwitch - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowPageSwitch extends UWindowDialogClientWindow;

var int m_iTotalPages;
var int m_iCurrentPages;
var int m_iButtonWidth;
var int m_iButtonHeight;
var R6WindowButton m_pNextButton;
var R6WindowButton m_pPreviousButton;
var R6WindowTextLabel m_pPageInfo;

function Created()
{
	m_iTotalPages = 1;
	m_iCurrentPages = 1;
	CreateButtons();
	m_pPageInfo = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', (m_pPreviousButton.WinLeft + m_pPreviousButton.WinWidth), 0.0000000, ((WinWidth - m_pPreviousButton.WinWidth) - m_pNextButton.WinWidth), WinHeight, self));
	m_pPageInfo.bAlwaysBehind = true;
	SetTotalPages(m_iTotalPages);
	SetCurrentPage(m_iCurrentPages);
	return;
}

//===============================================================
// Set the text label param
//===============================================================
function SetLabelText(string _szText, Font _TextFont, Color _vTextColor)
{
	// End:0x7A
	if((m_pPageInfo != none))
	{
		m_pPageInfo.m_Font = _TextFont;
		m_pPageInfo.TextColor = _vTextColor;
		m_pPageInfo.m_bDrawBorders = false;
		m_pPageInfo.Align = 2;
		m_pPageInfo.m_BGTexture = none;
		m_pPageInfo.SetNewText(_szText, true);
	}
	return;
}

//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons()
{
	m_pPreviousButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 0.0000000, 0.0000000, float(m_iButtonWidth), float(m_iButtonHeight)));
	m_pPreviousButton.m_bDrawBorders = false;
	m_pPreviousButton.SetButtonBorderColor(Root.Colors.White);
	m_pPreviousButton.TextColor = Root.Colors.White;
	m_pPreviousButton.m_OverTextColor = Root.Colors.BlueLight;
	m_pPreviousButton.m_DisabledTextColor = Root.Colors.Black;
	m_pPreviousButton.Text = "<<<";
	m_pPreviousButton.m_buttonFont = Root.Fonts[5];
	m_pNextButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', (WinWidth - float(m_iButtonWidth)), 0.0000000, float(m_iButtonWidth), float(m_iButtonHeight)));
	m_pNextButton.m_bDrawBorders = false;
	m_pNextButton.SetButtonBorderColor(Root.Colors.White);
	m_pNextButton.TextColor = Root.Colors.White;
	m_pNextButton.m_OverTextColor = Root.Colors.BlueLight;
	m_pNextButton.m_DisabledTextColor = Root.Colors.Black;
	m_pNextButton.Text = ">>>";
	m_pNextButton.m_buttonFont = Root.Fonts[5];
	return;
}

//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip(string _szLeftToolTip, string _szRightToolTip)
{
	// End:0x1F
	if((m_pNextButton != none))
	{
		m_pNextButton.ToolTipString = _szLeftToolTip;
	}
	// End:0x3E
	if((m_pPreviousButton != none))
	{
		m_pPreviousButton.ToolTipString = _szRightToolTip;
	}
	return;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function SetTotalPages(int iPage)
{
	m_iTotalPages = iPage;
	UpdatePageNb();
	return;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function SetCurrentPage(int iPage)
{
	m_iCurrentPages = iPage;
	UpdatePageNb();
	return;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function UpdatePageNb()
{
	local string szText;

	// End:0x26
	if((m_iCurrentPages <= 1))
	{
		m_pPreviousButton.bDisabled = true;
		m_iCurrentPages = 1;		
	}
	else
	{
		// End:0x54
		if((m_iCurrentPages >= m_iTotalPages))
		{
			m_pPreviousButton.bDisabled = false;
			m_iCurrentPages = m_iTotalPages;			
		}
		else
		{
			m_pPreviousButton.bDisabled = false;
		}
	}
	// End:0x8B
	if((m_iTotalPages <= 1))
	{
		m_iTotalPages = 1;
		m_pNextButton.bDisabled = true;		
	}
	else
	{
		// End:0xAE
		if((m_iCurrentPages == m_iTotalPages))
		{
			m_pNextButton.bDisabled = true;			
		}
		else
		{
			m_pNextButton.bDisabled = false;
		}
	}
	szText = ((string(m_iCurrentPages) $ " / ") $ string(m_iTotalPages));
	SetLabelText(szText, Root.Fonts[5], Root.Colors.White);
	return;
}

function NextPage()
{
	SetCurrentPage((m_iCurrentPages + 1));
	return;
}

function PreviousPage()
{
	SetCurrentPage((m_iCurrentPages - 1));
	return;
}

//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x8A
	if((int(E) == 2))
	{
		switch(C)
		{
			// End:0x4E
			case m_pNextButton:
				// End:0x4B
				if((UWindowDialogClientWindow(OwnerWindow) != none))
				{
					UWindowDialogClientWindow(OwnerWindow).Notify(C, E);
				}
				// End:0x8A
				break;
			// End:0x87
			case m_pPreviousButton:
				// End:0x84
				if((UWindowDialogClientWindow(OwnerWindow) != none))
				{
					UWindowDialogClientWindow(OwnerWindow).Notify(C, E);
				}
				// End:0x8A
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		return;
	}
}

defaultproperties
{
	m_iButtonWidth=20
	m_iButtonHeight=25
}
