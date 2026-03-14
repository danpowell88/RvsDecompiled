//=============================================================================
// R6WindowButtonMultiMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowButtonMultiMenu extends R6WindowButton;

var UWindowBase.EButtonName m_eButton_Action;
var bool m_bButtonIsReady;
var Texture m_TOverButton;
var Region m_ROverButtonFade;
var Region m_ROverButton;

function BeforePaint(Canvas C, float X, float Y)
{
	// End:0x6C
	if(__NFUN_119__(m_pPreviousButtonPos, none))
	{
		// End:0x69
		if(__NFUN_129__(m_bSetParam))
		{
			WinLeft = __NFUN_174__(__NFUN_174__(m_pPreviousButtonPos.WinLeft, m_pPreviousButtonPos.m_textSize), __NFUN_171__(__NFUN_175__(float(620), m_pRefButtonPos.m_fTotalButtonsSize), 0.2500000));
			m_pPreviousButtonPos = none;
			m_bButtonIsReady = true;
		}		
	}
	else
	{
		m_bButtonIsReady = true;
	}
	super.BeforePaint(C, X, Y);
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x1E
	if(m_bButtonIsReady)
	{
		super.Paint(C, X, Y);
	}
	return;
}

//=================================================================================
// Process the click
//=================================================================================
simulated function Click(float X, float Y)
{
	local R6MenuMPCreateGameTabOptions pCreateTabOptions;
	local R6MenuRootWindow r6Root;
	local R6MenuMPManageTab pFirstTabManager;
	local R6LanServers pLanServers;
	local R6GSServers pGameService;
	local R6WindowListGeneral pListGen;
	local R6MenuMPCreateGameWidget pCreateGW;
	local bool bInternetServer;
	local R6ServerInfo _ServerSettings;

	super(UWindowButton).Click(X, Y);
	r6Root = R6MenuRootWindow(Root);
	// End:0x2B
	if(bDisabled)
	{
		return;
	}
	switch(m_eButton_Action)
	{
		// End:0x7A
		case 30:
			R6MenuMultiPlayerWidget(OwnerWindow).m_LoginSuccessAction = 6;
			R6MenuMultiPlayerWidget(OwnerWindow).m_pLoginWindow.StartLogInProcedure(OwnerWindow);
			SetButLogInOutState(31);
			// End:0x782
			break;
		// End:0x18D
		case 31:
			R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.__NFUN_3510__();
			pFirstTabManager = R6MenuMultiPlayerWidget(OwnerWindow).m_pFirstTabManager;
			pFirstTabManager.m_pMainTabControl.GotoTab(pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
			R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GameServerList.Remove(0, R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GameServerList.Length);
			R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GSLSortIdx.Remove(0, R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GSLSortIdx.Length);
			SetButLogInOutState(30);
			// End:0x782
			break;
		// End:0x1A9
		case 32:
			R6MenuMultiPlayerWidget(OwnerWindow).JoinSelectedServerRequested();
			// End:0x782
			break;
		// End:0x1F8
		case 33:
			R6MenuMultiPlayerWidget(OwnerWindow).m_pJoinIPWindow.StartJoinIPProcedure(self, R6MenuMultiPlayerWidget(OwnerWindow).m_szPopUpIP);
			R6MenuMultiPlayerWidget(OwnerWindow).m_bJoinIPInProgress = true;
			// End:0x782
			break;
		// End:0x215
		case 34:
			R6MenuMultiPlayerWidget(OwnerWindow).Refresh(true);
			// End:0x782
			break;
		// End:0x22E
		case 35:
			r6Root.ChangeCurrentWidget(19);
			// End:0x782
			break;
		// End:0x27B
		case 36:
			// End:0x267
			if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
			{
				r6Root.ChangeCurrentWidget(38);				
			}
			else
			{
				r6Root.ChangeCurrentWidget(15);
			}
			// End:0x782
			break;
		// End:0x738
		case 37:
			pCreateGW = R6MenuMPCreateGameWidget(OwnerWindow);
			pCreateTabOptions = pCreateGW.m_pCreateTabOptions;
			pListGen = R6WindowListGeneral(pCreateTabOptions.GetList(pCreateTabOptions.GetCurrentGameMode(), pCreateTabOptions.1));
			// End:0x3C9
			if(R6Console(Root.Console).m_bStartedByGSClient)
			{
				_ServerSettings = Class'Engine.Actor'.static.__NFUN_1273__();
				// End:0x3C9
				if(__NFUN_130__(__NFUN_151__(_ServerSettings.MaxPlayers, 8), __NFUN_154__(int(pCreateTabOptions.GetCurrentGameMode()), int(GetLevel().2))))
				{
					r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_InvalidGSCoOpMaxPlayer", "R6Menu"), 37, int(2));
					return;
				}
			}
			// End:0x45B
			if(__NFUN_129__(pCreateTabOptions.IsAdminPasswordValid()))
			{
				r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_InvalidAdminPwrd", "R6Menu"), 27, int(2));
				return;
			}
			pCreateTabOptions.FillSelectedMapList();
			// End:0x4FB
			if(__NFUN_152__(pCreateTabOptions.m_SelectedMapList.Length, 0))
			{
				r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoMapSelected", "R6Menu"), 27, int(2));				
			}
			else
			{
				// End:0x5B9
				if(__NFUN_130__(__NFUN_129__(R6Console(Root.Console).m_bStartedByGSClient), __NFUN_122__(pCreateTabOptions.m_pServerNameEdit.GetValue(), "")))
				{
					r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoServerName", "R6Menu"), 27, int(2));					
				}
				else
				{
					// End:0x616
					if(__NFUN_132__(R6Console(Root.Console).m_bStartedByGSClient, R6Console(Root.Console).m_bNonUbiMatchMakingHost))
					{
						r6Root.m_pMenuCDKeyManager.StartCDKeyProcess();						
					}
					else
					{
						// End:0x6D3
						if(__NFUN_130__(bool(pCreateTabOptions.m_pButtonsDef.GetButtonComboValue(int(pCreateTabOptions.9), pListGen)), __NFUN_129__(pCreateTabOptions.m_pButtonsDef.GetButtonBoxValue(int(pCreateTabOptions.10), pListGen))))
						{
							R6Console(Root.Console).szStoreGamePassWd = pCreateTabOptions.GetCreateGamePassword();
							pCreateGW.m_pLoginWindow.StartLogInProcedure(OwnerWindow);
							pCreateGW.m_bLoginInProgress = true;							
						}
						else
						{
							// End:0x71D
							if(__NFUN_129__(pCreateTabOptions.m_pButtonsDef.GetButtonBoxValue(int(pCreateTabOptions.10), pListGen)))
							{
								r6Root.m_pMenuCDKeyManager.StartCDKeyProcess();								
							}
							else
							{
								r6Root.m_pMenuCDKeyManager.LaunchServer();
							}
						}
					}
				}
			}
			// End:0x782
			break;
		// End:0x764
		case 39:
			r6Root.ChangeCurrentWidget(20);
			Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1290__();
			// End:0x782
			break;
		// End:0xFFFF
		default:
			__NFUN_231__("Button not supported");
			// End:0x782
			break;
			break;
	}
	return;
}

function SetButLogInOutState(UWindowBase.EButtonName _eNewButtonState)
{
	Text = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines)).GetButtonLoc(int(_eNewButtonState));
	ToolTipString = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines)).GetButtonLoc(int(_eNewButtonState), true);
	m_eButton_Action = _eNewButtonState;
	ResizeToText();
	return;
}

defaultproperties
{
	m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ROverButtonFade=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=63522,ZoneNumber=0)
	m_ROverButton=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=64802,ZoneNumber=0)
	bStretched=true
}
