//=============================================================================
// R6MenuMPJoinTeamWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuMPJoinTeamWidget.uc : The first in game multi player menu window
//  the size of the window is 800 * 600
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPJoinTeamWidget extends R6MenuWidget;

const C_iMIN_TIME_FOR_WELCOME_SCREEN = 10;

var int m_iYBetweenButtonPadding;  // Vertical padding between buttons
var int m_iButtonHeight;
// NEW IN 1.60
var int m_iButtonWidth;
var int m_iSingleCharXPos;  // Coordinates where these elements are displayed
// NEW IN 1.60
var int m_iSingleCharYPos;
// NEW IN 1.60
var int m_iLeftCharXPos;
// NEW IN 1.60
var int m_iLeftCharYPos;
// NEW IN 1.60
var int m_iRightCharXPos;
// NEW IN 1.60
var int m_iRightCharYPos;
// NEW IN 1.60
var int m_iBetweenCharXPos;
// NEW IN 1.60
var int m_iBetweenCharYPos;
var bool m_bIsTeamGame;
var float m_fTimeForRefresh;  // time before a refresh
var float m_fTimeAutoTeam;  // time before forcing auto team
var R6WindowButtonMPInGame m_pButAlphaTeam;
var R6WindowButtonMPInGame m_pButBravoTeam;
var R6WindowButtonMPInGame m_pButAutoTeam;
var R6WindowButtonMPInGame m_pButSpectator;
var R6WindowButtonMPInGame m_pButCurrentSelected;
var R6WindowTextLabelExt m_pInfoText;
var R6MenuHelpWindow m_pHelpTextWindow;
//Character Texture
var R6WindowBitMap m_SingleChar;
var R6WindowBitMap m_LeftChar;
var R6WindowBitMap m_RightChar;
var R6WindowBitMap m_BetweenCharIcon;
var Texture m_TBetweenChar;
var Texture m_TSpectatorChar;
var Texture m_TAlphaChar;
var Texture m_TBetaChar;
var array< Class > m_AArmorDescriptions;
var Region m_pHelpReg;
var Region m_RBetweenChar;
var Region m_RSpectatorChar;
var Region m_RAlphaChar;
var Region m_RBetaChar;
var string m_szMenuGreenTeamPawnClass;  // backup Class and check if they have changed (server can change them)
var string m_szMenuRedTeamPawnClass;

function Created()
{
	FillDescriptionArray();
	CreateTextLabels();
	CreateButtons();
	CreateBitmaps();
	m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(Class'R6Menu.R6MenuHelpWindow', float(m_pHelpReg.X), float(m_pHelpReg.Y), float(m_pHelpReg.W), float(m_pHelpReg.H), self));
	return;
}

//===============================================================================
// Fills the array with all R6ArmorDescription to retreive Level armor texture 
// and texture coordinates
//===============================================================================
function FillDescriptionArray()
{
	local Class<R6ArmorDescription> DescriptionClass;
	local int i;
	local R6Mod pCurrentMod;

	pCurrentMod = Class'Engine.Actor'.static.__NFUN_1524__().m_pCurrentMod;
	i = 0;
	J0x22:

	// End:0xA3 [Loop If]
	if(__NFUN_150__(i, pCurrentMod.m_aDescriptionPackage.Length))
	{
		DescriptionClass = Class<R6ArmorDescription>(__NFUN_1005__(__NFUN_112__(pCurrentMod.m_aDescriptionPackage[i], ".u"), Class'R6Description.R6ArmorDescription'));
		J0x68:

		// End:0x96 [Loop If]
		if(__NFUN_119__(DescriptionClass, none))
		{
			m_AArmorDescriptions[m_AArmorDescriptions.Length] = DescriptionClass;
			DescriptionClass = Class<R6ArmorDescription>(__NFUN_1006__());
			// [Loop Continue]
			goto J0x68;
		}
		__NFUN_1007__();
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x22;
	}
	return;
}

function Tick(float DeltaTime)
{
	local string szAutoSelection;

	// End:0x45
	if(__NFUN_132__(__NFUN_123__(m_szMenuGreenTeamPawnClass, GetLevel().GreenTeamPawnClass), __NFUN_130__(__NFUN_123__(m_szMenuRedTeamPawnClass, GetLevel().RedTeamPawnClass), m_bIsTeamGame)))
	{
		RefreshBitmaps();
	}
	// End:0x7D
	if(m_bIsTeamGame)
	{
		// End:0x71
		if(__NFUN_179__(m_fTimeForRefresh, 4.0000000))
		{
			RefreshButtonsStatus();
			m_fTimeForRefresh = 0.0000000;			
		}
		else
		{
			__NFUN_184__(m_fTimeForRefresh, DeltaTime);
		}
	}
	// End:0x1BF
	if(__NFUN_177__(m_fTimeAutoTeam, float(10)))
	{
		szAutoSelection = Class'Engine.Actor'.static.__NFUN_1009__().MPAutoSelection;
		// End:0xE6
		if(__NFUN_124__(szAutoSelection, "GREEN"))
		{
			m_pButAlphaTeam.Click(0.0000000, 0.0000000);
			Class'Engine.Actor'.static.__NFUN_1009__().__NFUN_536__();			
		}
		else
		{
			// End:0x12A
			if(__NFUN_124__(szAutoSelection, "SPECTATOR"))
			{
				m_pButSpectator.Click(0.0000000, 0.0000000);
				Class'Engine.Actor'.static.__NFUN_1009__().__NFUN_536__();				
			}
			else
			{
				// End:0x1B1
				if(m_bIsTeamGame)
				{
					// End:0x171
					if(__NFUN_124__(szAutoSelection, "RED"))
					{
						m_pButBravoTeam.Click(0.0000000, 0.0000000);
						Class'Engine.Actor'.static.__NFUN_1009__().__NFUN_536__();						
					}
					else
					{
						// End:0x1B1
						if(__NFUN_124__(szAutoSelection, "AUTOTEAM"))
						{
							m_pButAutoTeam.Click(0.0000000, 0.0000000);
							Class'Engine.Actor'.static.__NFUN_1009__().__NFUN_536__();
						}
					}
				}
			}
		}
		m_fTimeAutoTeam = 0.0000000;		
	}
	else
	{
		__NFUN_184__(m_fTimeAutoTeam, DeltaTime);
	}
	return;
}

//===============================================================================
//       Called by the root just after the showwindow()
//===============================================================================
function SetMenuToDisplay(string _szCurrentGameType)
{
	m_bIsTeamGame = GetLevel().IsGameTypeTeamAdversarial(_szCurrentGameType);
	RefreshServerInfo();
	RefreshButtons(_szCurrentGameType);
	RefreshBitmaps();
	RefreshButtonsStatus();
	m_fTimeAutoTeam = 0.0000000;
	return;
}

//===============================================================================
// Refresh server info after we display the menu page
//===============================================================================
function RefreshServerInfo()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x11A
	if(__NFUN_119__(r6Root.m_R6GameMenuCom.m_GameRepInfo, none))
	{
		m_pInfoText.ChangeTextLabel(__NFUN_112__(__NFUN_112__(Localize("MPInGame", "ServerName", "R6Menu"), " "), r6Root.m_R6GameMenuCom.m_GameRepInfo.ServerName), 0);
		m_pInfoText.ChangeTextLabel(__NFUN_112__(__NFUN_112__(Localize("MPInGame", "GameVersion", "R6Menu"), " "), Class'Engine.Actor'.static.__NFUN_1419__(true, __NFUN_129__(Class'Engine.Actor'.static.__NFUN_1524__().IsRavenShield()))), 1);
		m_pInfoText.ChangeTextLabel(r6Root.m_R6GameMenuCom.m_GameRepInfo.MOTDLine1, 3);
	}
	return;
}

//===============================================================================
//       INIT SECTION Called after we display the page
//===============================================================================
//===============================================================================
//       Initial Creation of the buttons
//===============================================================================
function CreateButtons()
{
	local Font ButtonFont;
	local float fXOffset, fYOffset;

	fXOffset = float(__NFUN_146__(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.X, 100));
	fYOffset = float(__NFUN_146__(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.Y, 100));
	ButtonFont = Root.Fonts[16];
	m_pButAlphaTeam = R6WindowButtonMPInGame(CreateControl(Class'R6Menu.R6WindowButtonMPInGame', fXOffset, fYOffset, float(m_iButtonWidth), float(m_iButtonHeight), self));
	m_pButAlphaTeam.Text = Localize("MPInGame", "AlphaTeam", "R6Menu");
	m_pButAlphaTeam.m_eButInGame_Action = 0;
	m_pButAlphaTeam.Align = 0;
	m_pButAlphaTeam.m_fFontSpacing = 2.0000000;
	m_pButAlphaTeam.m_buttonFont = ButtonFont;
	m_pButAlphaTeam.ResizeToText();
	__NFUN_184__(fYOffset, float(__NFUN_146__(m_iButtonHeight, m_iYBetweenButtonPadding)));
	m_pButBravoTeam = R6WindowButtonMPInGame(CreateControl(Class'R6Menu.R6WindowButtonMPInGame', fXOffset, fYOffset, float(m_iButtonWidth), float(m_iButtonHeight), self));
	m_pButBravoTeam.Text = Localize("MPInGame", "BravoTeam", "R6Menu");
	m_pButBravoTeam.m_eButInGame_Action = 1;
	m_pButBravoTeam.Align = 0;
	m_pButBravoTeam.m_fFontSpacing = 2.0000000;
	m_pButBravoTeam.m_buttonFont = ButtonFont;
	m_pButBravoTeam.ResizeToText();
	__NFUN_184__(fYOffset, float(__NFUN_146__(m_iButtonHeight, m_iYBetweenButtonPadding)));
	m_pButAutoTeam = R6WindowButtonMPInGame(CreateControl(Class'R6Menu.R6WindowButtonMPInGame', fXOffset, fYOffset, float(m_iButtonWidth), float(m_iButtonHeight), self));
	m_pButAutoTeam.ToolTipString = Localize("Tip", "AutoTeam", "R6Menu");
	m_pButAutoTeam.Text = Localize("MPInGame", "AutoTeam", "R6Menu");
	m_pButAutoTeam.m_eButInGame_Action = 2;
	m_pButAutoTeam.Align = 0;
	m_pButAutoTeam.m_fFontSpacing = 2.0000000;
	m_pButAutoTeam.m_buttonFont = ButtonFont;
	m_pButAutoTeam.ResizeToText();
	__NFUN_184__(fYOffset, float(__NFUN_146__(m_iButtonHeight, m_iYBetweenButtonPadding)));
	m_pButSpectator = R6WindowButtonMPInGame(CreateControl(Class'R6Menu.R6WindowButtonMPInGame', fXOffset, fYOffset, float(m_iButtonWidth), float(m_iButtonHeight), self));
	m_pButSpectator.ToolTipString = Localize("Tip", "Spectator", "R6Menu");
	m_pButSpectator.Text = Localize("MPInGame", "Spectator", "R6Menu");
	m_pButSpectator.m_eButInGame_Action = 3;
	m_pButSpectator.Align = 0;
	m_pButSpectator.m_fFontSpacing = 2.0000000;
	m_pButSpectator.m_buttonFont = ButtonFont;
	m_pButSpectator.ResizeToText();
	return;
}

function RefreshButtons(string _szCurrentGameType)
{
	local float fSpectatorYPos;

	// End:0xCA
	if(__NFUN_129__(m_bIsTeamGame))
	{
		m_pButAlphaTeam.ToolTipString = GetLevel().GetGreenTeamObjective(_szCurrentGameType);
		m_pButAlphaTeam.Text = Localize("MPInGame", "Play", "R6Menu");
		m_pButAlphaTeam.m_eButInGame_Action = 4;
		m_pButAlphaTeam.ResizeToText();
		m_pButBravoTeam.HideWindow();
		m_pButAutoTeam.HideWindow();
		fSpectatorYPos = __NFUN_174__(__NFUN_174__(m_pButAlphaTeam.WinTop, m_pButAlphaTeam.WinHeight), float(m_iYBetweenButtonPadding));		
	}
	else
	{
		m_pButAlphaTeam.ToolTipString = GetLevel().GetGreenTeamObjective(_szCurrentGameType);
		m_pButAlphaTeam.Text = Localize("MPInGame", "AlphaTeam", "R6Menu");
		m_pButAlphaTeam.m_eButInGame_Action = 0;
		m_pButAlphaTeam.ResizeToText();
		m_pButBravoTeam.ShowWindow();
		m_pButBravoTeam.ToolTipString = GetLevel().GetRedTeamObjective(_szCurrentGameType);
		m_pButAutoTeam.ShowWindow();
		fSpectatorYPos = __NFUN_174__(__NFUN_174__(m_pButAutoTeam.WinTop, m_pButAutoTeam.WinHeight), float(m_iYBetweenButtonPadding));
	}
	m_pButSpectator.WinTop = fSpectatorYPos;
	return;
}

function RefreshButtonsStatus()
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	m_pButAlphaTeam.bDisabled = false;
	m_pButBravoTeam.bDisabled = false;
	// End:0x7C
	if(__NFUN_153__(r6Root.m_R6GameMenuCom.GetNbOfTeamPlayer(true), 8))
	{
		// End:0x7C
		if(__NFUN_154__(int(m_pButAlphaTeam.m_eButInGame_Action), int(0)))
		{
			m_pButAlphaTeam.bDisabled = true;
		}
	}
	// End:0xAD
	if(__NFUN_153__(r6Root.m_R6GameMenuCom.GetNbOfTeamPlayer(false), 8))
	{
		m_pButBravoTeam.bDisabled = true;
	}
	return;
}

//===============================================================================
//       Initial Creation of the text labels
//===============================================================================
function CreateTextLabels()
{
	local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
		fSizeOfCounter;

	fXOffset = float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.X);
	fYOffset = float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.Y);
	fWidth = float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.W);
	fHeight = float(R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.H);
	m_pInfoText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', fXOffset, fYOffset, fWidth, fHeight, self));
	m_pInfoText.bAlwaysBehind = true;
	m_pInfoText.SetNoBorder();
	m_pInfoText.m_Font = Root.Fonts[6];
	m_pInfoText.m_vTextColor = Root.Colors.White;
	fXOffset = 4.0000000;
	fYOffset = __NFUN_174__(R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(3));
	fWidth = __NFUN_171__(fWidth, 0.5000000);
	m_pInfoText.AddTextLabel(Localize("MPInGame", "ServerName", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = __NFUN_174__(fWidth, float(4));
	fYOffset = __NFUN_174__(R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize(), float(3));
	m_pInfoText.AddTextLabel(Localize("MPInGame", "GameVersion", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	fXOffset = 4.0000000;
	fYOffset = __NFUN_175__(fHeight, float(40));
	fWidth = fWidth;
	m_pInfoText.m_Font = Root.Fonts[5];
	m_pInfoText.AddTextLabel(Localize("MPInGame", "PleaseNote", "R6Menu"), fXOffset, fYOffset, fWidth, 0, false);
	m_pInfoText.m_Font = Root.Fonts[6];
	fXOffset = 4.0000000;
	fYOffset = __NFUN_175__(fHeight, float(20));
	fWidth = fWidth;
	m_pInfoText.AddTextLabel("", fXOffset, fYOffset, fWidth, 0, false);
	return;
}

//===============================================================================
//       Initial Creation of the Bitmaps
//===============================================================================
function CreateBitmaps()
{
	m_SingleChar = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_iSingleCharXPos), float(m_iSingleCharYPos), float(m_RSpectatorChar.W), float(m_RSpectatorChar.H), self));
	m_SingleChar.m_iDrawStyle = 5;
	m_SingleChar.HideWindow();
	m_LeftChar = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_iLeftCharXPos), float(m_iLeftCharYPos), float(m_RSpectatorChar.W), float(m_RSpectatorChar.H), self));
	m_LeftChar.m_iDrawStyle = 5;
	m_LeftChar.HideWindow();
	m_LeftChar.m_bHorizontalFlip = true;
	m_RightChar = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_iRightCharXPos), float(m_iRightCharYPos), float(m_RSpectatorChar.W), float(m_RSpectatorChar.H), self));
	m_RightChar.m_iDrawStyle = 5;
	m_RightChar.HideWindow();
	m_BetweenCharIcon = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', float(m_iBetweenCharXPos), float(m_iBetweenCharYPos), float(m_RBetweenChar.W), float(m_RBetweenChar.H), self));
	m_BetweenCharIcon.m_iDrawStyle = 5;
	m_BetweenCharIcon.HideWindow();
	m_BetweenCharIcon.t = m_TBetweenChar;
	m_BetweenCharIcon.R = m_RBetweenChar;
	return;
}

//===============================================================================
//       Called after the menu is displayed
//===============================================================================
function RefreshBitmaps()
{
	m_TAlphaChar = Texture(GetLevel().GreenMenuSkin);
	m_RAlphaChar = GetLevel().GreenMenuRegion;
	m_TBetaChar = Texture(GetLevel().RedMenuSkin);
	m_RBetaChar = GetLevel().RedMenuRegion;
	m_LeftChar.t = m_TAlphaChar;
	m_LeftChar.R = m_RAlphaChar;
	m_RightChar.t = m_TBetaChar;
	m_RightChar.R = m_RBetaChar;
	m_SingleChar.HideWindow();
	m_LeftChar.HideWindow();
	m_RightChar.HideWindow();
	m_BetweenCharIcon.HideWindow();
	// End:0x102
	if(__NFUN_119__(m_pButCurrentSelected, none))
	{
		Notify(m_pButCurrentSelected, 12);
	}
	return;
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip)
{
	m_pHelpTextWindow.ToolTip(strTip);
	return;
}

//===============================================================================
//       This allow us to switch the right bitmap accordingly
//===============================================================================
function Notify(UWindowDialogControl C, byte E)
{
	// End:0x15E
	if(__NFUN_154__(int(E), 12))
	{
		// End:0x27
		if(R6WindowButtonMPInGame(C).bDisabled)
		{
			return;
		}
		switch(C)
		{
			// End:0x7B
			case m_pButAlphaTeam:
				m_SingleChar.ShowWindow();
				m_SingleChar.t = m_TAlphaChar;
				m_SingleChar.R = m_RAlphaChar;
				m_pButCurrentSelected = m_pButAlphaTeam;
				// End:0x15B
				break;
			// End:0xC8
			case m_pButBravoTeam:
				m_SingleChar.ShowWindow();
				m_SingleChar.t = m_TBetaChar;
				m_SingleChar.R = m_RBetaChar;
				m_pButCurrentSelected = m_pButBravoTeam;
				// End:0x15B
				break;
			// End:0x10B
			case m_pButAutoTeam:
				m_LeftChar.ShowWindow();
				m_RightChar.ShowWindow();
				m_BetweenCharIcon.ShowWindow();
				m_pButCurrentSelected = m_pButAutoTeam;
				// End:0x15B
				break;
			// End:0x158
			case m_pButSpectator:
				m_SingleChar.ShowWindow();
				m_SingleChar.t = m_TSpectatorChar;
				m_SingleChar.R = m_RSpectatorChar;
				m_pButCurrentSelected = m_pButSpectator;
				// End:0x15B
				break;
			// End:0xFFFF
			default:
				break;
		}		
	}
	else
	{
		// End:0x1FF
		if(__NFUN_154__(int(E), 9))
		{
			// End:0x185
			if(R6WindowButtonMPInGame(C).bDisabled)
			{
				return;
			}
			switch(C)
			{
				// End:0x194
				case m_pButAlphaTeam:
				// End:0x19C
				case m_pButBravoTeam:
				// End:0x1BD
				case m_pButSpectator:
					m_SingleChar.HideWindow();
					m_pButCurrentSelected = none;
					// End:0x1FF
					break;
				// End:0x1FC
				case m_pButAutoTeam:
					m_LeftChar.HideWindow();
					m_RightChar.HideWindow();
					m_BetweenCharIcon.HideWindow();
					m_pButCurrentSelected = none;
					// End:0x1FF
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
		}
		return;
	}
}

function HideWindow()
{
	super(UWindowWindow).HideWindow();
	m_pButCurrentSelected = none;
	return;
}

defaultproperties
{
	m_iYBetweenButtonPadding=20
	m_iButtonHeight=25
	m_iButtonWidth=220
	m_iSingleCharXPos=420
	m_iSingleCharYPos=120
	m_iLeftCharXPos=340
	m_iLeftCharYPos=120
	m_iRightCharXPos=491
	m_iRightCharYPos=120
	m_iBetweenCharXPos=453
	m_iBetweenCharYPos=170
	m_TBetweenChar=Texture'R6MenuTextures.Gui_BoxScroll'
	m_TSpectatorChar=Texture'R6MenuTextures.Gui_BoxScroll'
	m_pHelpReg=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=11554,ZoneNumber=0)
	m_RBetweenChar=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=48162,ZoneNumber=0)
	m_RSpectatorChar=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=28706,ZoneNumber=0)
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
