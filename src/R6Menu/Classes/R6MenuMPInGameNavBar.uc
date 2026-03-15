//=============================================================================
// R6MenuMPInGameNavBar - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6MenuMPInGameNavBar extends UWindowDialogClientWindow;

const C_fHEIGHT_HELPTEXTBAR = 20;

var int m_iXNavBarLoc[4];  // X pos of each nav bar icon
var int m_iYNavBarLoc[4];  // Y pos of each nav bar icon
var float m_fPlayerButWidth;  // the width of the player button
var R6MenuMPInGameHelpBar m_HelpTextBar;
var R6WindowButton m_SelectTeamButton;
// NEW IN 1.60
var R6WindowButton m_ServerOptButton;
// NEW IN 1.60
var R6WindowButton m_KitRestrictionButton;
// NEW IN 1.60
var R6WindowButton m_GearButton;
var R6WindowButtonBox m_pPlayerReady;
var Texture m_TSelectTeamButton;
// NEW IN 1.60
var Texture m_TServerOptButton;
// NEW IN 1.60
var Texture m_TKitRestrictionButton;
// NEW IN 1.60
var Texture m_TGearButton;
var Region m_RSelectTeamButtonUp;
// NEW IN 1.60
var Region m_RSelectTeamButtonDown;
// NEW IN 1.60
var Region m_RSelectTeamButtonDisabled;
// NEW IN 1.60
var Region m_RSelectTeamButtonOver;
var Region m_RServerOptButtonUp;
// NEW IN 1.60
var Region m_RServerOptButtonDown;
// NEW IN 1.60
var Region m_RServerOptButtonDisabled;
// NEW IN 1.60
var Region m_RServerOptButtonOver;
var Region m_RKitRestrictionButtonUp;
// NEW IN 1.60
var Region m_RKitRestrictionButtonDown;
// NEW IN 1.60
var Region m_RKitRestrictionButtonDisabled;
// NEW IN 1.60
var Region m_RKitRestrictionButtonOver;
var Region m_RGearButtonUp;
// NEW IN 1.60
var Region m_RGearButtonDown;
// NEW IN 1.60
var Region m_RGearButtonDisabled;
// NEW IN 1.60
var Region m_RGearButtonOver;

function Created()
{
	local float fXOffset, fHeight;

	m_HelpTextBar = R6MenuMPInGameHelpBar(CreateWindow(Class'R6Menu.R6MenuMPInGameHelpBar', 1.0000000, 0.0000000, (WinWidth - float(2)), 20.0000000, self));
	m_HelpTextBar.m_bUseExternSetTip = true;
	m_SelectTeamButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iXNavBarLoc[0]), float(m_iYNavBarLoc[0]), float(m_RSelectTeamButtonUp.W), float(m_RSelectTeamButtonUp.H), self));
	m_SelectTeamButton.UpTexture = m_TSelectTeamButton;
	m_SelectTeamButton.OverTexture = m_TSelectTeamButton;
	m_SelectTeamButton.DownTexture = m_TSelectTeamButton;
	m_SelectTeamButton.DisabledTexture = m_TSelectTeamButton;
	m_SelectTeamButton.UpRegion = m_RSelectTeamButtonUp;
	m_SelectTeamButton.DownRegion = m_RSelectTeamButtonDown;
	m_SelectTeamButton.DisabledRegion = m_RSelectTeamButtonDisabled;
	m_SelectTeamButton.OverRegion = m_RSelectTeamButtonOver;
	m_SelectTeamButton.bUseRegion = true;
	m_SelectTeamButton.ToolTipString = Localize("MPInGame", "SelectTeam", "R6Menu");
	m_SelectTeamButton.m_iDrawStyle = 5;
	m_ServerOptButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iXNavBarLoc[1]), float(m_iYNavBarLoc[1]), float(m_RServerOptButtonUp.W), float(m_RServerOptButtonUp.H), self));
	m_ServerOptButton.UpTexture = m_TServerOptButton;
	m_ServerOptButton.OverTexture = m_TServerOptButton;
	m_ServerOptButton.DownTexture = m_TServerOptButton;
	m_ServerOptButton.DisabledTexture = m_TServerOptButton;
	m_ServerOptButton.UpRegion = m_RServerOptButtonUp;
	m_ServerOptButton.OverRegion = m_RServerOptButtonOver;
	m_ServerOptButton.DownRegion = m_RServerOptButtonDown;
	m_ServerOptButton.DisabledRegion = m_RServerOptButtonDisabled;
	m_ServerOptButton.bUseRegion = true;
	m_ServerOptButton.ToolTipString = Localize("Tip", "ServerOpt", "R6Menu");
	m_ServerOptButton.m_iDrawStyle = 5;
	m_KitRestrictionButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iXNavBarLoc[2]), float(m_iYNavBarLoc[2]), float(m_RKitRestrictionButtonUp.W), float(m_RKitRestrictionButtonUp.H), self));
	m_KitRestrictionButton.UpTexture = m_TKitRestrictionButton;
	m_KitRestrictionButton.OverTexture = m_TKitRestrictionButton;
	m_KitRestrictionButton.DownTexture = m_TKitRestrictionButton;
	m_KitRestrictionButton.DisabledTexture = m_TKitRestrictionButton;
	m_KitRestrictionButton.UpRegion = m_RKitRestrictionButtonUp;
	m_KitRestrictionButton.OverRegion = m_RKitRestrictionButtonOver;
	m_KitRestrictionButton.DownRegion = m_RKitRestrictionButtonDown;
	m_KitRestrictionButton.DisabledRegion = m_RKitRestrictionButtonDisabled;
	m_KitRestrictionButton.bUseRegion = true;
	m_KitRestrictionButton.ToolTipString = Localize("Tip", "KitRestriction", "R6Menu");
	m_KitRestrictionButton.m_iDrawStyle = 5;
	m_GearButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', float(m_iXNavBarLoc[3]), float(m_iYNavBarLoc[3]), float(m_RGearButtonUp.W), float(m_RGearButtonUp.H), self));
	m_GearButton.UpTexture = m_TGearButton;
	m_GearButton.OverTexture = m_TGearButton;
	m_GearButton.DownTexture = m_TGearButton;
	m_GearButton.DisabledTexture = m_TGearButton;
	m_GearButton.UpRegion = m_RGearButtonUp;
	m_GearButton.OverRegion = m_RGearButtonOver;
	m_GearButton.DownRegion = m_RGearButtonDown;
	m_GearButton.DisabledRegion = m_RGearButtonDisabled;
	m_GearButton.bUseRegion = true;
	m_GearButton.ToolTipString = Localize("Tip", "Gear", "R6Menu");
	m_GearButton.m_iDrawStyle = 5;
	fXOffset = float(((m_iXNavBarLoc[3] + m_RGearButtonUp.W) + 30));
	fHeight = 15.0000000;
	m_pPlayerReady = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, 30.0000000, 80.0000000, fHeight, self));
	m_pPlayerReady.m_TextFont = Root.Fonts[5];
	m_pPlayerReady.m_vTextColor = Root.Colors.White;
	m_pPlayerReady.m_vBorder = Root.Colors.White;
	m_pPlayerReady.m_eButtonType = 0;
	m_pPlayerReady.CreateTextAndBox(Localize("MPInGame", "PlayerReady", "R6Menu"), Localize("Tip", "PlayerReady", "R6Menu"), 0.0000000, 0);
	m_pPlayerReady.bDisabled = true;
	m_pPlayerReady.m_bResizeToText = true;
	m_BorderColor = Root.Colors.BlueLight;
	AlignButtons();
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	// End:0xBE
	if((m_fPlayerButWidth != m_pPlayerReady.WinWidth))
	{
		// End:0x34
		if((m_SelectTeamButton != none))
		{
			m_SelectTeamButton.m_bPreCalculatePos = true;
		}
		// End:0x50
		if((m_ServerOptButton != none))
		{
			m_ServerOptButton.m_bPreCalculatePos = true;
		}
		// End:0x6C
		if((m_KitRestrictionButton != none))
		{
			m_KitRestrictionButton.m_bPreCalculatePos = true;
		}
		// End:0x88
		if((m_GearButton != none))
		{
			m_GearButton.m_bPreCalculatePos = true;
		}
		// End:0xA4
		if((m_pPlayerReady != none))
		{
			m_pPlayerReady.m_bPreCalculatePos = true;
		}
		AlignButtons();
		m_fPlayerButWidth = m_pPlayerReady.WinWidth;
	}
	CheckForNavBarState();
	return;
}

function CheckForNavBarState()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x6D
	if((((!m_pPlayerReady.bDisabled) && (r6Root.m_R6GameMenuCom != none)) && r6Root.m_R6GameMenuCom.IsInBetweenRoundMenu()))
	{
		SetNavBarState(m_pPlayerReady.m_bSelected, true);
	}
	return;
}

function AlignButtons()
{
	local float fFreeSpace, fDistanceBetEachBut;

	fFreeSpace = (WinWidth - float(4));
	(fFreeSpace -= ((((m_SelectTeamButton.WinWidth + m_ServerOptButton.WinWidth) + m_KitRestrictionButton.WinWidth) + m_GearButton.WinWidth) + m_pPlayerReady.WinWidth));
	// End:0x80
	if((fFreeSpace > WinWidth))
	{
		fFreeSpace = WinWidth;
	}
	fDistanceBetEachBut = (fFreeSpace / float(6));
	m_SelectTeamButton.WinLeft = fDistanceBetEachBut;
	m_ServerOptButton.WinLeft = ((m_SelectTeamButton.WinLeft + m_SelectTeamButton.WinWidth) + fDistanceBetEachBut);
	m_KitRestrictionButton.WinLeft = ((m_ServerOptButton.WinLeft + m_ServerOptButton.WinWidth) + fDistanceBetEachBut);
	m_GearButton.WinLeft = ((m_KitRestrictionButton.WinLeft + m_KitRestrictionButton.WinWidth) + fDistanceBetEachBut);
	m_pPlayerReady.WinLeft = ((m_GearButton.WinLeft + m_GearButton.WinWidth) + fDistanceBetEachBut);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	// End:0x154
	if((int(E) == 2))
	{
		r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
		switch(C)
		{
			// End:0x59
			case m_SelectTeamButton:
				r6Root.m_R6GameMenuCom.SelectTeam();
				r6Root.ChangeCurrentWidget(24);
				// End:0x154
				break;
			// End:0x90
			case m_ServerOptButton:
				// End:0x8D
				if((r6Root.m_pIntermissionMenuWidget != none))
				{
					r6Root.m_pIntermissionMenuWidget.PopUpServerOptMenu();
				}
				// End:0x154
				break;
			// End:0xC7
			case m_KitRestrictionButton:
				// End:0xC4
				if((r6Root.m_pIntermissionMenuWidget != none))
				{
					r6Root.m_pIntermissionMenuWidget.PopUpKitRestMenu();
				}
				// End:0x154
				break;
			// End:0xFE
			case m_GearButton:
				// End:0xFB
				if((r6Root.m_pIntermissionMenuWidget != none))
				{
					r6Root.m_pIntermissionMenuWidget.PopUpGearMenu();
				}
				// End:0x154
				break;
			// End:0x14E
			case m_pPlayerReady:
				// End:0x14B
				if(R6WindowButtonBox(C).GetSelectStatus())
				{
					r6Root.m_R6GameMenuCom.SetPlayerReadyStatus((!R6WindowButtonBox(C).m_bSelected));
				}
				// End:0x154
				break;
			// End:0xFFFF
			default:
				// End:0x154
				break;
				break;
		}
	}
	return;
}

function ToolTip(string strTip)
{
	m_HelpTextBar.SetToolTip(strTip);
	return;
}

function SetNavBarState(bool _bDisable, optional bool _bDisableAllExceptReadyBut)
{
	m_SelectTeamButton.bDisabled = _bDisable;
	m_ServerOptButton.bDisabled = _bDisable;
	m_KitRestrictionButton.bDisabled = _bDisable;
	m_GearButton.bDisabled = _bDisable;
	// End:0x79
	if((!_bDisableAllExceptReadyBut))
	{
		m_pPlayerReady.bDisabled = _bDisable;
	}
	return;
}

function SetNavBarButtonsStatus(bool _bDisplay)
{
	// End:0x57
	if(_bDisplay)
	{
		m_SelectTeamButton.ShowWindow();
		m_ServerOptButton.ShowWindow();
		m_KitRestrictionButton.ShowWindow();
		m_GearButton.ShowWindow();
		m_pPlayerReady.ShowWindow();		
	}
	else
	{
		m_SelectTeamButton.HideWindow();
		m_ServerOptButton.HideWindow();
		m_KitRestrictionButton.HideWindow();
		m_GearButton.HideWindow();
		m_pPlayerReady.HideWindow();
	}
	return;
}

defaultproperties
{
	m_iXNavBarLoc[0]=160
	m_iXNavBarLoc[1]=250
	m_iXNavBarLoc[2]=340
	m_iXNavBarLoc[3]=430
	m_iYNavBarLoc[0]=23
	m_iYNavBarLoc[1]=24
	m_iYNavBarLoc[2]=24
	m_iYNavBarLoc[3]=22
	m_TSelectTeamButton=Texture'R6MenuTextures.Gui_02'
	m_TServerOptButton=Texture'R6MenuTextures.Gui_01'
	m_TKitRestrictionButton=Texture'R6MenuTextures.Gui_02'
	m_TGearButton=Texture'R6MenuTextures.Gui_01'
	m_RSelectTeamButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=10018,ZoneNumber=0)
	m_RSelectTeamButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=10018,ZoneNumber=0)
	m_RSelectTeamButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=10018,ZoneNumber=0)
	m_RSelectTeamButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=10018,ZoneNumber=0)
	m_RServerOptButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=47650,ZoneNumber=0)
	m_RServerOptButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=47650,ZoneNumber=0)
	m_RServerOptButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=47650,ZoneNumber=0)
	m_RServerOptButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=47650,ZoneNumber=0)
	m_RKitRestrictionButtonUp=(Zone=Class'R6Menu.R6MenuRootWindow',iLeaf=9762,ZoneNumber=0)
	m_RKitRestrictionButtonDown=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=15394,ZoneNumber=0)
	m_RKitRestrictionButtonDisabled=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=23074,ZoneNumber=0)
	m_RKitRestrictionButtonOver=(Zone=ObjectProperty'R6Menu.R6MenuMPCreateGameTab.m_pButtonsDef',iLeaf=7714,ZoneNumber=0)
	m_RGearButtonUp=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57122,ZoneNumber=0)
	m_RGearButtonDown=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57122,ZoneNumber=0)
	m_RGearButtonDisabled=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57122,ZoneNumber=0)
	m_RGearButtonOver=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=57122,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var n
// REMOVED IN 1.60: var d
// REMOVED IN 1.60: var r
