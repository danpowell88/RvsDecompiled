//=============================================================================
//  R6MenuMPCreateGameTabOptions.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/11  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTabOptions extends R6MenuMPCreateGameTab;

// OPTIONS TAB
var R6WindowTextLabelExt                m_pOptionsText;  

var R6WindowComboControl                m_pOptionsGameMode;			// the current game mode selection

var R6WindowEditControl                 m_pServerNameEdit;

var R6WindowButton						m_pOptionsWelcomeMsg;

var R6WindowPopUpBox                    m_pMsgOfTheDayPopUp;        // The msg of the day pop-up

var array<string>                       m_SelectedMapList;			// List of maps selected by the user
var array<string>			            m_SelectedModeList;			// List of game modes selected by the user

var string								m_szMsgOfTheDay;

var BOOL								m_bBkpCamFadeToBk;
var BOOL								m_bBkpCamFirstPerson;
var BOOL								m_bBkpCamThirdPerson;
var BOOL								m_bBkpCamFreeThirdP;
var BOOL								m_bBkpCamGhost;
var BOOL								m_bBkpCamTeamOnly;
var BOOL								m_bBkpTKPenalty;

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	Super.Created();
}

function InitOptionsTab( optional BOOL _bInGame)
{
	local stServerGameOpt stNewSGOItem;
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fSizeOfCounter;
	local INT i;

	m_bInGame = _bInGame;

	// =======================================================================================================
	// TEXT PART
    // it's a text label ext because you want to draw the line in the middle (small hack)
    m_pOptionsText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, 2*K_HALFWINDOWWIDTH, WinHeight, self));
    m_pOptionsText.bAlwaysBehind = true;
    // draw middle line
    m_pOptionsText.ActiveBorder( 0, false);                                         // Top border
    m_pOptionsText.ActiveBorder( 1, false);                                         // Bottom border
    m_pOptionsText.SetBorderParam( 2, K_HALFWINDOWWIDTH, 1, 1, Root.Colors.White);  // Left border
    m_pOptionsText.ActiveBorder( 3, false);                                         // Rigth border

    m_pOptionsText.m_Font = Root.Fonts[F_SmallTitle]; 
    m_pOptionsText.m_vTextColor = Root.Colors.White;

    fXOffset = 5;
    fYOffset = 5;
    fWidth = K_HALFWINDOWWIDTH;
    fYStep = 17;

    m_pOptionsText.AddTextLabel( Localize("MPCreateGame","Options_GameMode","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = K_HALFWINDOWWIDTH + 5;
    fYOffset = 165;
    m_pOptionsText.AddTextLabel( Localize("MPCreateGame","Options_DeathCam","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

	// =======================================================================================================
	// GAME MODE
    fXOffset = (K_HALFWINDOWWIDTH * 0.5) + 10;
    fYOffset = 5;
    fWidth = (K_HALFWINDOWWIDTH * 0.5) - 20;//10 + 10(fXOffSet) substract small value to distance the check box from middle line
    
    m_pOptionsGameMode = R6WindowComboControl(CreateControl( class'R6WindowComboControl', fXOffset, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
    m_pOptionsGameMode.SetEditBoxTip(Localize("Tip","Options_GameMode","R6Menu"));
    m_pOptionsGameMode.EditBoxWidth = m_pOptionsGameMode.WinWidth - m_pOptionsGameMode.Button.WinWidth;
    m_pOptionsGameMode.SetFont( F_VerySmallTitle);
	m_pOptionsGameMode.AddItem( Caps(m_ALocGameMode[0]), string(m_ANbOfGameMode[0]));
#ifndefMPDEMO
	m_pOptionsGameMode.AddItem( Caps(m_ALocGameMode[1]), string(m_ANbOfGameMode[1]));
#endif

	// =======================================================================================================
    // create edit box for server name, and password

    // If the server was launched by the ubi.com client application,
    // the server name and game password have already been set in the ubi.com client, no need
    // for the user to enter a name or a password.

    fXOffset = 5;
    fWidth = K_HALFWINDOWWIDTH - fXOffset - 10; //10 substract small value to distance the check box from middle line
    fHeight = 15;

    if ( !R6Console(Root.console).m_bStartedByGSClient )
    {
        fYOffset += fYStep;
        // SERVER NAME
	    m_pServerNameEdit = R6WindowEditControl(CreateControl(class'R6WindowEditControl', fXOffset, fYOffset, fWidth, fHeight, self));
	    m_pServerNameEdit.SetValue( "");
	    m_pServerNameEdit.CreateTextLabel( Localize("MPCreateGame","Options_ServerName","R6Menu"),
									       0, 0, fWidth * 0.5, fHeight);
	    m_pServerNameEdit.SetEditBoxTip( Localize("Tip","Options_ServerName","R6Menu"));
	    m_pServerNameEdit.ModifyEditBoxW( 160, 0, 135, fHeight);
	    m_pServerNameEdit.EditBox.MaxLength = R6Console(Root.console).m_GameService.GetMaxUbiServerNameSize();
		m_pServerNameEdit.SetEditControlStatus( _bInGame);

        fYOffset += fYStep;
		// PASSWORD
		InitPassword( fXOffset, fYOffset, fWidth, fHeight);
    }

	fYOffset += fYStep;
    // ADMIN PASSWORD
	InitAdminPassword( fXOffset, fYOffset, fWidth, fHeight);

	// =======================================================================================================
	// buttons list
	fYOffset += fYStep;
	fWidth = K_HALFWINDOWWIDTH - fXOffset - 10;
	fHeight = 227;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
		CreateListOfButtons( fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], eCGW_Opt);

	// =======================================================================================================
	// camera list
    fXOffset = 5 + K_HALFWINDOWWIDTH;
	fYOffset = 180;
	fHeight = 100;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
		CreateListOfButtons( fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], eCGW_Camera);

	// =======================================================================================================
	// map list
	InitAllMapList();

	if (!_bInGame)
		InitEditMsgButton();

	SetCurrentGameMode(m_ANbOfGameMode[0]); // set adversarial by default
	RefreshServerOpt();

	m_bInitComplete = true;
}

function InitPassword( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
{
	local R6WindowButtonAndEditBox pButton;
	local stServerGameOpt stNewSGOItem;
	local INT i;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
	{
		pButton = CreateButAndEditBox( _fX, _fY, _fW, _fH, 
										Localize("MPCreateGame","Options_Password","R6Menu"), 
										Localize("Tip","Options_UsePass","R6Menu"),	
										Localize("Tip","Options_UsePassEdit","R6Menu"));

		stNewSGOItem.pGameOptList = pButton;
		stNewSGOItem.eGameMode	  = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID  = eCGW_Password;

		AddWindowInCreateGameArray( stNewSGOItem);
	}
}

function InitAdminPassword( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
	{
	local R6WindowButtonAndEditBox pButton;
	local stServerGameOpt stNewSGOItem;
	local INT i;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
	{
		pButton = CreateButAndEditBox( _fX, _fY, _fW, _fH, 
										Localize("MPCreateGame","Options_AdminPwd","R6Menu"), 
										Localize("Tip","Options_AdminPwd","R6Menu"),
										Localize("Tip","Options_AdminPwdEdit","R6Menu"));

		stNewSGOItem.pGameOptList = pButton;
		stNewSGOItem.eGameMode	  = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID  = eCGW_AdminPassword;

		AddWindowInCreateGameArray( stNewSGOItem);
	}
}

function InitAllMapList()
    {
	local R6MenuMapList pMapList;
	local stServerGameOpt stNewSGOItem;
	local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;	
	local INT i;
	
	fXOffset = K_HALFWINDOWWIDTH;
	fYOffset = 5;
	fWidth = K_HALFWINDOWWIDTH; 
	fHeight = 155;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
    {
		pMapList = R6MenuMapList(CreateWindow( class'R6MenuMapList', fXOffset, fYOffset, fWidth, fHeight, self));
		pMapList.m_bInGame		 = m_bInGame;
		pMapList.m_szLocGameMode = Caps(m_ALocGameMode[i]);
		pMapList.m_eMyGameMode	 = m_ANbOfGameMode[i];

		stNewSGOItem.pGameOptList = pMapList;
		stNewSGOItem.eGameMode	  = m_ANbOfGameMode[i];
		stNewSGOItem.eCGWindowID  = eCGW_MapList;

		AddWindowInCreateGameArray( stNewSGOItem);
	}
}

//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons( Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID, optional BOOL _bUpdateValue)
{
	local R6WindowListGeneral pTempList; 
	local R6ServerInfo pServerInfo;

	pTempList = R6WindowListGeneral(GetList( _eGameMode, _eCGWindowID));

#ifdefDEBUG
	if (m_bShowLog)
		log("UpdateButtons pTempList"@pTempList@"for _eCGWindowID"@_eCGWindowID);
#endif

	if (pTempList == None)
		return;

	if (_bUpdateValue)
		pServerInfo = class'Actor'.static.GetServerOptions();

	switch(_eGameMode)
	{
		//===============================================================================================================
		//===============================================================================================================
		//=============================== ADVERSARIAL ===================================================================
		//===============================================================================================================
		//===============================================================================================================
		case m_ANbOfGameMode[0]: 
			switch(_eCGWindowID)
			{
				case eCGW_Opt:
					if (_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer,  string(pServerInfo.InternetServer), pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundPerMatch,pServerInfo.RoundsPerMatch,	 pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundTime,	  pServerInfo.RoundTime / 60,	 pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_TimeBetRound, pServerInfo.BetweenRoundTime,	 pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_Players,	  pServerInfo.MaxPlayers,		 pTempList);
	#ifndefMPDEMO
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_BombTimer,	  pServerInfo.BombTime,			 pTempList);
	#endif
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_DedicatedServer,  pServerInfo.DedicatedServer,	 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_FriendlyFire,	  pServerInfo.FriendlyFire,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_TKPenalty,		  pServerInfo.TeamKillerPenalty, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AutoBalTeam,      pServerInfo.Autobalance,		 pTempList);

						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowRadar,		  pServerInfo.AllowRadar,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowTeamNames,   pServerInfo.ShowNames,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_ForceFPersonWp,   pServerInfo.ForceFPersonWeapon,pTempList);

						UpdateMenuOptions( EButtonName.EBN_FriendlyFire, pServerInfo.FriendlyFire, pTempList);
					}
					else
					{
						if (!R6Console(Root.console).m_bStartedByGSClient && !R6Console(Root.console).m_bNonUbiMatchMakingHost)
						{
							m_pButtonsDef.AddButtonCombo( EButtonName.EBN_InternetServer, pTempList, self);
							m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
							m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
						}

						m_pButtonsDef.AddButtonInt( EButtonName.EBN_RoundPerMatch,	  1, 20, 10,	 pTempList, self);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_RoundTime,		  1, 15, 3,		 pTempList, self);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_TimeBetRound,	  10, 99, 15,	 pTempList, self);
						m_pButtonsDef.SetButtonCounterUnlimited( EButtonName.EBN_TimeBetRound, true, pTempList);
			#ifndefMPDEMO
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_BombTimer,		  30,60, 35,	 pTempList, self);
			#endif
						if (!R6Console(Root.console).m_bStartedByGSClient )
						{
							m_pButtonsDef.AddButtonInt ( EButtonName.EBN_NB_Players,		  1, 16, 16,	 pTempList, self);
							if (!R6Console(Root.console).m_bNonUbiMatchMakingHost)
								m_pButtonsDef.AddButtonBool( EButtonName.EBN_DedicatedServer, false, pTempList, self);
						}
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_FriendlyFire,	  true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_TKPenalty,		  true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AutoBalTeam,     true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AllowRadar,	  true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AllowTeamNames,  true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_ForceFPersonWp,  true,  pTempList, self);
					}
					break;
				case eCGW_Camera:
					if (_bUpdateValue)
	{
						UpdateCamera( EButtonName.EBN_CamFadeToBk	, pServerInfo.CamFadeToBlack, false, pTempList);
						UpdateCamera( EButtonName.EBN_CamFirstPerson, pServerInfo.CamFirstPerson, false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamThirdPerson, pServerInfo.CamThirdPerson, false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamFreeThirdP	, pServerInfo.CamFreeThirdP	, false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamGhost		, pServerInfo.CamGhost		, false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamTeamOnly	, pServerInfo.CamTeamOnly	, false, pTempList, true);

						UpdateCamSpecialCase( pServerInfo.CamTeamOnly, false);
						UpdateCamSpecialCase( pServerInfo.CamFadeToBlack, true);
	}
	else
	{
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamFadeToBk,	  false, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamFirstPerson,  true,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamThirdPerson,  true, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamFreeThirdP,   true, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamGhost,		  true, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamTeamOnly,	  true, pTempList, self);
	}
					break;
				default:
					break;
}
			break;
		//===============================================================================================================
		//===============================================================================================================
		//=============================== COOPERATIVE ===================================================================
		//===============================================================================================================
		//===============================================================================================================
		case m_ANbOfGameMode[1]:
			switch(_eCGWindowID)
			{
				case eCGW_Opt:
					if (_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer,     string(pServerInfo.InternetServer), pTempList);
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel,			 string(pServerInfo.DiffLevel),	pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundPerMission, pServerInfo.RoundsPerMatch,    pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundTime,       pServerInfo.RoundTime / 60,    pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_TimeBetRound,	 pServerInfo.BetweenRoundTime,  pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_Players,		 pServerInfo.MaxPlayers,	    pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_of_Terro,	 pServerInfo.NbTerro,			pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_DedicatedServer,     pServerInfo.DedicatedServer,	pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AIBkp,				 pServerInfo.AIBkp,				pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_RotateMap,			 pServerInfo.RotateMap,			pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_FriendlyFire,		 pServerInfo.FriendlyFire,	    pTempList);

						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowRadar,		  pServerInfo.AllowRadar,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowTeamNames,   pServerInfo.ShowNames,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_ForceFPersonWp,   pServerInfo.ForceFPersonWeapon,pTempList);
					}
					else
					{
	 	   				if (!R6Console(Root.console).m_bStartedByGSClient  && !R6Console(Root.console).m_bNonUbiMatchMakingHost)
    					{
							m_pButtonsDef.AddButtonCombo( EButtonName.EBN_InternetServer, pTempList, self);
							m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
							m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
						}
						m_pButtonsDef.AddButtonCombo( EButtonName.EBN_DiffLevel, pTempList, self);
						m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty1", "R6Menu"), string(1), pTempList);
						m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty2", "R6Menu"), string(2), pTempList);
						m_pButtonsDef.AddItemInComboButton( EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty3", "R6Menu"), string(3), pTempList);
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, "1",	     pTempList);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_RoundPerMission,  1, 20, 10,	 pTempList, self);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_RoundTime,		  1, 60, 3,		 pTempList, self);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_TimeBetRound,	  10, 99, 15,	 pTempList, self);
						m_pButtonsDef.SetButtonCounterUnlimited( EButtonName.EBN_TimeBetRound, true, pTempList);
						m_pButtonsDef.AddButtonInt( EButtonName.EBN_NB_of_Terro,	  5, 40, 32,	 pTempList, self);
				    	if (!R6Console(Root.console).m_bStartedByGSClient )
    					{
							m_pButtonsDef.AddButtonInt( EButtonName.EBN_NB_Players,		  1, 8,	 8,		 pTempList, self);
        					if (!R6Console(Root.console).m_bNonUbiMatchMakingHost)
								m_pButtonsDef.AddButtonBool( EButtonName.EBN_DedicatedServer, false, pTempList, self);
						}
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AIBkp,			  true,  pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_RotateMap,		  true,  pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_FriendlyFire,	  true,  pTempList, self);

						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AllowRadar,	  false,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_AllowTeamNames,  false,	 pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_ForceFPersonWp,  false,	 pTempList, self);
					}
					break;
				case eCGW_Camera:
					if (_bUpdateValue)
					{
						UpdateCamera( EButtonName.EBN_CamFirstPerson, pServerInfo.CamFirstPerson, false, pTempList);
						UpdateCamera( EButtonName.EBN_CamThirdPerson, pServerInfo.CamThirdPerson, false, pTempList);
						UpdateCamera( EButtonName.EBN_CamFreeThirdP	, pServerInfo.CamFreeThirdP	, false, pTempList);
						UpdateCamera( EButtonName.EBN_CamGhost		, pServerInfo.CamGhost		, false, pTempList);
					}
					else
					{
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamFirstPerson,  true,	pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamThirdPerson,  true, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamFreeThirdP,   true, pTempList, self);
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_CamGhost,		  true, pTempList, self);
					}
					break;
				default:
					break;
			}
			break;
		default:
			log("UpdateButtons not a valid game mode");
			break;
    }
}

function InitEditMsgButton()
{
    local FLOAT                         fXOffset, fYOffset, fWidth, fHeight;

    //create buttons
    fXOffset = K_HALFWINDOWWIDTH + 10;
    fYOffset = WinHeight - 20;
    fWidth   = K_HALFWINDOWWIDTH - 20;
    fHeight  = 15;

    m_pOptionsWelcomeMsg = R6WindowButton(CreateControl(class'R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionsWelcomeMsg.SetButtonBorderColor(Root.Colors.White);
	m_pOptionsWelcomeMsg.m_bDrawBorders      = TRUE;
    m_pOptionsWelcomeMsg.m_bDrawSimpleBorder = TRUE;
	m_pOptionsWelcomeMsg.TextColor = Root.Colors.White;
    m_pOptionsWelcomeMsg.Align	   = TA_Center;
    m_pOptionsWelcomeMsg.SetFont(F_VerySmallTitle);
    m_pOptionsWelcomeMsg.SetText( Localize("MPCreateGame","EditWelcomeMsg","R6Menu"));
    m_pOptionsWelcomeMsg.ToolTipString = Localize("Tip","EditWelcomeMsg","R6Menu");
	m_pOptionsWelcomeMsg.m_iButtonID = m_pButtonsDef.EButtonName.EBN_EditMsg;
}

//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
//==============================================================
// Create a list of strings containing the list of maps that the
// user has selected
//==============================================================
function BYTE FillSelectedMapList()
{
   	local UWindowListBoxItem CurItem;
	local R6MenuMapList pCurrentMapList;
	local INT                i;

    // Clear old list

    m_SelectedMapList.Remove( 0, m_SelectedMapList.length );

	pCurrentMapList = R6MenuMapList(GetList( GetCurrentGameMode(), eCGW_MapList));

	if ( pCurrentMapList.m_pFinalMapList.Items.Next == None )
    {
#ifdefDEBUG
		log("MapList Empty!!!!"); 
#endif
        return 0;
    }
    
	CurItem = UWindowListBoxItem(pCurrentMapList.m_pFinalMapList.Items.Next);//Items.Next;

    // Go through list of maps and build a list holding the map names (m_SelectedMapList)

    i = 0;
	while ( CurItem != None ) 
	{
        m_SelectedMapList[i] = R6WindowListBoxItem(CurItem).m_szMisc;
        m_SelectedModeList[i] = GetLevel().GetGameTypeFromLocName(CurItem.m_stSubText.szGameTypeSelect, true);
        CurItem = UWindowListBoxItem(CurItem.Next);
        i++;
	}

    return i;
}

//==============================================================
// PopUpMOTDEditionBox: PopUp for the message of the day
//==============================================================
function PopUpMOTDEditionBox()
{
    local R6WindowEditBox pR6EditBoxTemp;

    if (m_pMsgOfTheDayPopUp == None)
    {
        // Create PopUp frame
        m_pMsgOfTheDayPopUp = R6WindowPopUpBox(R6MenuMPCreateGameWidget(OwnerWindow).CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480, self));
        m_pMsgOfTheDayPopUp.CreateStdPopUpWindow( Localize("MPCreateGame","WelcomeMsg","R6Menu"), 30, 75, 150, 490, 70);
        m_pMsgOfTheDayPopUp.CreateClientWindow( class'R6WindowEditBox');
		m_pMsgOfTheDayPopUp.m_ePopUpID = EPopUpID_MsgOfTheDay;
        pR6EditBoxTemp = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea);
		pR6EditBoxTemp.SetValue( m_szMsgOfTheDay);
        pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
        pR6EditBoxTemp.SetFont(F_PopUpTitle);
		pR6EditBoxTemp.MaxLength = 60;
    }
    else
	{
		pR6EditBoxTemp = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea);
		pR6EditBoxTemp.SetValue( m_szMsgOfTheDay); // set the new msg of the day -- in case of a loadserver

        m_pMsgOfTheDayPopUp.ShowWindow(); 
	}	
}

//==============================================================
// PopUpBoxDone: For now, we just receive the result of the message of the day pop-up
//==============================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
	if (Result == MR_OK)
	{
		if ( _ePopUpID == EPopUpID_MsgOfTheDay)
		{
			m_szMsgOfTheDay = R6WindowEditBox(m_pMsgOfTheDayPopUp.m_ClientArea).GetValue();
			SetServerOptions();
		}
	}
}

//==============================================================
// IsAdminPasswordValid: Verify if you check the box and if your password is different of nothing
//==============================================================
function BOOL IsAdminPasswordValid()
{
	local R6WindowButtonAndEditBox pAdminPassword;

	pAdminPassword = R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_AdminPassword));

	if (pAdminPassword.m_bSelected)
	{
		if (pAdminPassword.m_pEditBox.GetValue() == "")
		{
			return false;
		}
	}

	return true;
}

//==============================================================
// GetCreateGamePassword: get the create game password 
//==============================================================
function string GetCreateGamePassword()
{
	return R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_Password)).m_pEditBox.GetValue();
}

function UpdateCamera( INT _iButtonID, BOOL _bValue, BOOL _bDisable, R6WindowListGeneral _pCamList, optional BOOL _bBackupValue)
{
	switch(_iButtonID)
	{
		case EButtonName.EBN_CamFadeToBk:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList);
			break;
		case EButtonName.EBN_CamFirstPerson:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList, _bDisable);
			if (_bBackupValue)
				m_bBkpCamFirstPerson = _bValue;
			break;
		case EButtonName.EBN_CamThirdPerson:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList, _bDisable);
			if (_bBackupValue)
				m_bBkpCamThirdPerson = _bValue;
			break;
		case EButtonName.EBN_CamFreeThirdP:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList, _bDisable);
			if (_bBackupValue)
				m_bBkpCamFreeThirdP = _bValue;
			break;
		case EButtonName.EBN_CamGhost:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList, _bDisable);
			if (_bBackupValue)
				m_bBkpCamGhost = _bValue;
			break;
		case EButtonName.EBN_CamTeamOnly:
			m_pButtonsDef.ChangeButtonBoxValue( _iButtonID, _bValue, _pCamList, _bDisable);
			if (_bBackupValue)
				m_bBkpCamTeamOnly = _bValue;
			break;
	}
}

//=====================================================================================
// GetCameraSelection: return the current selection of the button. This function exist because when the button
//						is disable the selection is store in the bkp version
//=====================================================================================
function BOOL GetCameraSelection( INT _iButtonID, R6WindowListGeneral _pCameraList)
{
	local BOOL bSelection;

	if (m_pButtonsDef.IsButtonBoxDisabled( _iButtonID, _pCameraList))
	{
		switch( _iButtonID)
		{
			case EButtonName.EBN_CamFirstPerson:
				bSelection = m_bBkpCamFirstPerson;
				break;
			case EButtonName.EBN_CamThirdPerson:
				bSelection = m_bBkpCamThirdPerson;
				break;
			case EButtonName.EBN_CamFreeThirdP:
				bSelection = m_bBkpCamFreeThirdP;
				break;
			case EButtonName.EBN_CamGhost:
				bSelection = m_bBkpCamGhost;
				break;
			case EButtonName.EBN_CamTeamOnly:
				bSelection = m_bBkpCamTeamOnly;
				break;
		}
	}
	else
	{
		bSelection = m_pButtonsDef.GetButtonBoxValue( _iButtonID, _pCameraList);
	}

	return bSelection;
}

//==========================================================================
// UpdateCamSpecialCase:  For death cam and cam teamonly only
//==========================================================================
function UpdateCamSpecialCase( BOOL _bButtonSel, BOOL _bUpdateDeathCam)
{
	local BOOL bCamState, bCamFirstPerson, bCamThirdPerson, bCamFreeThPerson, bCamGhost, bCanTeamOnly;
	local BOOL bCamGhostDis; // cam ghost disable
	local R6WindowListGeneral pCamList;

	pCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));

	if ( _bUpdateDeathCam)
	{
		bCamState		 = _bButtonSel;

		bCamFirstPerson  = false;
		bCamThirdPerson  = false;
		bCamFreeThPerson = false;
		bCamGhost		 = false;
		bCanTeamOnly	 = false;

		if (bCamState)
		{
			m_bBkpCamFirstPerson = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamFirstPerson, pCamList);
			m_bBkpCamThirdPerson = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamThirdPerson, pCamList);
			m_bBkpCamFreeThirdP  = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamFreeThirdP, pCamList);

			bCamGhostDis		 = m_pButtonsDef.IsButtonBoxDisabled( EButtonName.EBN_CamGhost, pCamList);
			if (!bCamGhostDis) // if the cam ghost is not already disable -- that we already have the backup value
				m_bBkpCamGhost	 = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamGhost, pCamList);

			if (GetCurrentGameMode() == m_ANbOfGameMode[0])
			{
				m_bBkpCamTeamOnly	 = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamTeamOnly, pCamList);
			}
		}
		else
		{
			bCamFirstPerson  = m_bBkpCamFirstPerson;
			bCamThirdPerson  = m_bBkpCamThirdPerson;
			bCamFreeThPerson = m_bBkpCamFreeThirdP;
			bCamGhost		 = m_bBkpCamGhost;

			if (GetCurrentGameMode() == m_ANbOfGameMode[0])
				bCamGhostDis = m_bBkpCamTeamOnly;
			else
				bCamGhostDis = false;

			bCanTeamOnly	 = m_bBkpCamTeamOnly;
		}

		UpdateCamera( EButtonName.EBN_CamFadeToBk	, bCamState, false, pCamList);
		UpdateCamera( EButtonName.EBN_CamFirstPerson, bCamFirstPerson,  bCamState, pCamList);
		UpdateCamera( EButtonName.EBN_CamThirdPerson, bCamThirdPerson,  bCamState, pCamList);
		UpdateCamera( EButtonName.EBN_CamFreeThirdP	, bCamFreeThPerson, bCamState, pCamList);
		
		if (!bCamGhostDis) //if the cam ghost is not already disable -- in the case of team only
			UpdateCamera( EButtonName.EBN_CamGhost, bCamGhost, bCamState, pCamList);

		if (GetCurrentGameMode() == m_ANbOfGameMode[0])
			UpdateCamera( EButtonName.EBN_CamTeamOnly, bCanTeamOnly, bCamState, pCamList);
    }
	else // cam team only
	{
		bCamState = _bButtonSel;
		bCamGhost = false;

		if (bCamState)
		{
			m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_CamGhost, pCamList);
		}
		else
		{
			bCamGhost = m_bBkpCamGhost;
		}

		UpdateCamera( EButtonName.EBN_CamGhost, bCamGhost, bCamState, pCamList);
	}
}

function UpdateMenuOptions( INT _iButID, BOOL _bNewValue, R6WindowListGeneral _pOptionsList, optional BOOL _bChangeByUserClick)
{
	local BOOL bButState;

	switch( _iButID)
	{
		case EButtonName.EBN_CamFadeToBk:
			UpdateCamSpecialCase( _bNewValue, true);
			break;
		case EButtonName.EBN_CamTeamOnly:
			UpdateCamSpecialCase( _bNewValue, false);
			break;
		case EButtonName.EBN_FriendlyFire:

			bButState = false;

			if (!m_bInitComplete)
			{
				m_bBkpTKPenalty = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_TKPenalty, _pOptionsList);
			}

			if (_bNewValue) // enable teammates fire option
			{
				bButState = m_bBkpTKPenalty;
			}
			else if (_bChangeByUserClick)// disable teammates fire options
			{
				// get the tkpenalty value
				m_bBkpTKPenalty = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_TKPenalty, _pOptionsList);
			}

			m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_TKPenalty, bButState, _pOptionsList, !_bNewValue);
			break;
		default:
			break;
	}
}

//=======================================================================
// UpdateAllMapList: 
//=======================================================================
function UpdateAllMapList()
{
	local R6MenuMapList pTempList; 
	local INT i;

	for (i =0; i < m_ANbOfGameMode.Length; i++)
	{
		pTempList = R6MenuMapList(GetList( m_ANbOfGameMode[i], eCGW_MapList));

		if (pTempList != None)
		{
			pTempList.FillMapListItem();  // get the available maps -- from r6missiondescription
		}
	}
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt( optional BOOL _bNewServerProfile)
{
	local INT iIndex;
	local R6ServerInfo pServerOpt;
	local R6MenuMapList pCurrentMapList;

#ifdefDEBUG
	local BOOL bShowLog;

	if (bShowLog)
	{
		log("TabOptions RefreshServerOpt!!!");
	}
#endif

	pServerOpt = class'Actor'.static.GetServerOptions();

	m_bNewServerProfile = _bNewServerProfile;

	if(m_bInitComplete)
	{
		UpdateAllMapList();
	}

	if (_bNewServerProfile)
	{
		// if we load a server profile, get the new type and force the maplist to change (1 map list / per mode)
		// before fill the map list
		pCurrentMapList = R6MenuMapList( GetList( GetCurrentGameMode(), eCGW_MapList));
		m_pOptionsGameMode.SetValue( m_pOptionsGameMode.GetValue(), pCurrentMapList.GetNewServerProfileGameMode());
#ifdefDEBUG
		if (bShowLog)
		{
			log("Refresh server opt: pCurrentMapList.GetNewServerProfileGameMode() :"@pCurrentMapList.GetNewServerProfileGameMode());
			log("m_pOptionsGameMode.GetValue(): "@m_pOptionsGameMode.GetValue());
		}
#endif
		ManageComboControlNotify(m_pOptionsGameMode);
	}

	pCurrentMapList = R6MenuMapList( GetList( GetCurrentGameMode(), eCGW_MapList));
	iIndex = m_pOptionsGameMode.FindItemIndex2( pCurrentMapList.FillFinalMapList()); // refresh final map list
	m_pOptionsGameMode.SetSelectedIndex( iIndex);

    // If the server was launched by the ubi.com client application,
    // use the server name passed to the game by the ubi.com client.

	if ( !R6Console(Root.console).m_bStartedByGSClient )
    {
 		m_pServerNameEdit.SetValue( pServerOpt.ServerName);
		SetButtonAndEditBox( eCGW_Password, pServerOpt.GamePassword, pServerOpt.UsePassword);
    }

	SetButtonAndEditBox( eCGW_AdminPassword, pServerOpt.AdminPassword, pServerOpt.UseAdminPassword);

	m_szMsgOfTheDay = Localize("MPCreateGame", "Default_MsgOfTheDay", "R6Menu");
	if (pServerOpt.MOTD != "")
		m_szMsgOfTheDay = pServerOpt.MOTD;

	Super.RefreshServerOpt(); // update all the buttons

	m_bNewServerProfile = false;
}

function SetServerOptions()
{
	local UWindowWindow pCGWWindow;
	local R6WindowListGeneral pListGen;
    local INT iCounter;
    local R6StartGameInfo  StartGameInfo;
    local string szSvrName;             // String to hold server name
    local string szGameType;
    local R6ServerInfo _ServerSettings;
    local R6MapList        myList;        // Map list to cycle through
    local INT    iButtonValue;			// 

#ifdefDEBUG
	local BOOL bShowLog;

	if (bShowLog)
	{
		log("SetServerOptions!!!!!!!!!!!!!!!!");
	}
#endif    

    _ServerSettings = class'Actor'.static.GetServerOptions();
    if (_ServerSettings.m_ServerMapList==none)
    {
        _ServerSettings.m_ServerMapList = GetLevel().spawn(class'Engine.R6MapList');
    }
    
	// ========================================================================================================================================
	// Set the server name
    // If the server was launched by the ubi.com client application,
    // use the server name passed to the game by the ubi.com client.

    if ( R6Console(Root.console).m_bStartedByGSClient )
        szSvrName = R6Console(Root.console).m_GameService.m_szGSServerName;
    else
        szSvrName = m_pServerNameEdit.GetValue();

    _ServerSettings.ServerName = szSvrName;
    
	// ========================================================================================================================================
	// Set the password and the admin password

	if ( R6Console(Root.console).m_bStartedByGSClient )
	{
		_ServerSettings.UsePassword = ( R6Console(Root.console).m_GameService.m_szGSPassword != "" );
		if ( _ServerSettings.UsePassword )
			_ServerSettings.GamePassword = R6Console(Root.console).m_GameService.m_szGSPassword;
	}
	else
	{
		pCGWWindow = GetList(GetCurrentGameMode(), eCGW_Password);

		_ServerSettings.UsePassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
		_ServerSettings.GamePassword = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();
	}

	// Admin Password
	pCGWWindow = GetList(GetCurrentGameMode(), eCGW_AdminPassword);
	_ServerSettings.UseAdminPassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
	_ServerSettings.AdminPassword	 = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();

	// ========================================================================================================================================
	// Set all the camera options

	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));

	_ServerSettings.CamFirstPerson =  GetCameraSelection( EButtonName.EBN_CamFirstPerson, pListGen);
    
	_ServerSettings.CamThirdPerson = GetCameraSelection( EButtonName.EBN_CamThirdPerson, pListGen);
    
	_ServerSettings.CamFreeThirdP = GetCameraSelection( EButtonName.EBN_CamFreeThirdP, pListGen);
    
	_ServerSettings.CamGhost = GetCameraSelection( EButtonName.EBN_CamGhost, pListGen);
    
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_CamFadeToBk, pListGen) == None)
		_ServerSettings.CamFadeToBlack = false;
	else
	_ServerSettings.CamFadeToBlack = GetCameraSelection( EButtonName.EBN_CamFadeToBk, pListGen);
    
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_CamTeamOnly, pListGen) == None)
		_ServerSettings.CamTeamOnly = false;
	else
	_ServerSettings.CamTeamOnly = GetCameraSelection( EButtonName.EBN_CamTeamOnly, pListGen);

	// ========================================================================================================================================
	// Set all the options
    
	pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Opt));
    
    // Max Number of Players
    // If the server was launched by the ubi.com client application,
    // use the max number of players passed to the game by the ubi.com client.

    if ( R6Console(Root.console).m_bStartedByGSClient )
        iButtonValue = R6Console(Root.console).m_GameService.m_iGSNumPlayers;
    else
		iButtonValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_NB_Players, pListGen);

    if ( iButtonValue > 0)
    {
        _ServerSettings.MaxPlayers = iButtonValue;
    }
    else
    {
        _ServerSettings.MaxPlayers = 1;
    }
    
    // Number of terrorists to spawn
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_NB_of_Terro, pListGen) != None)
	_ServerSettings.NbTerro = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_NB_of_Terro, pListGen);
    
    // Message of the day
    _ServerSettings.MOTD = m_szMsgOfTheDay;
    
    // Round time.  The time is entered in minutes and needs to be converted into
    // seconds (that is why we multipy by 60).
	_ServerSettings.RoundTime = (m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundTime, pListGen)) * 60;
    
    // Map time.  The time is entered in minutes and needs to be converted into
    // seconds (that is why we multipy by 60).
	if (GetCurrentGameMode() == m_ANbOfGameMode[0])
    {
		_ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundPerMatch, pListGen);
    }
    else
    {
		_ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundPerMission, pListGen);
    }

    // Between round time.  The time is entered in seconds.
	_ServerSettings.BetweenRoundTime = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_TimeBetRound, pListGen);
    
	// Bomb time
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_BombTimer, pListGen) != None)
	_ServerSettings.BombTime = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_BombTimer, pListGen);

	// Internet server
	if ( R6Console(Root.console).m_bStartedByGSClient || R6Console(Root.console).m_bNonUbiMatchMakingHost)
		_ServerSettings.InternetServer = true;
	else
		_ServerSettings.InternetServer = BOOL(m_pButtonsDef.GetButtonComboValue( EButtonName.EBN_InternetServer, pListGen));

	// Dedicated server
	_ServerSettings.DedicatedServer = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_DedicatedServer, pListGen);

	// Friendly fire
	_ServerSettings.FriendlyFire = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_FriendlyFire, pListGen);

	// T.K. Penalty
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_TKPenalty, pListGen) != None)
	_ServerSettings.TeamKillerPenalty = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_TKPenalty, pListGen);

	// AIBkp
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_AIBkp, pListGen) != None)
	_ServerSettings.AIBkp = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AIBkp, pListGen);

	// RotateMap
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_RotateMap, pListGen) != None)
	_ServerSettings.RotateMap = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_RotateMap, pListGen);

	// Auto Balance
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_AutoBalTeam, pListGen) != None)
	_ServerSettings.Autobalance = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AutoBalTeam, pListGen);

	// Allow Team Names
	_ServerSettings.ShowNames = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AllowTeamNames, pListGen);

	// Force F Person Weapon
	_ServerSettings.ForceFPersonWeapon = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_ForceFPersonWp, pListGen);

	// Radar
	_ServerSettings.AllowRadar = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AllowRadar, pListGen);

	// Difficulty Level
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_DiffLevel, pListGen) != None)
	_ServerSettings.DiffLevel = INT(m_pButtonsDef.GetButtonComboValue( EButtonName.EBN_DiffLevel, pListGen));


	// ========================================================================================================================================
    // Set the map List
    FillSelectedMapList();   // Create list of selected maps
    
    // Check that user has at least selected 1 map
    if ( m_SelectedMapList.length != 0 )
    {
		szGameType = m_SelectedModeList[0];
    
#ifdefDEBUG
		if ( szGameType == "RGM_AllMode" )
		{
			log( "ERROR: no game type found for " $m_SelectedModeList[0] );
		}
#endif
    
		// Set the game mode for a non-dedicated server
		StartGameInfo = R6Console(Root.console).master.m_StartGameInfo;
		StartGameInfo.m_GameMode = GetLevel().GetGameTypeClassName(szGameType);//GetModeFromMenuName( m_szMenuGameName );

		myList = _ServerSettings.m_ServerMapList;    // GetLevel().spawn(ML);
    
		// Go though list of selecter maps and add to the command line (map0=, map1=, ...)
		for (iCounter = 0; iCounter < arraycount(myList.Maps); iCounter++)
		{
			myList.Maps[iCounter] = "";
			myList.GameType[iCounter] = "";
		}

		for ( iCounter = 0; iCounter < m_SelectedMapList.length; iCounter++ )
		{
			myList.Maps[iCounter] = m_SelectedMapList[iCounter];
        
			// Game mode (mode=,mode1=,...)
        
			// TODO: Read enum of game type from menus directly.
			myList.GameType[iCounter] = GetLevel().GetGameTypeClassName(m_SelectedModeList[iCounter]);

#ifdefDEBUG
			if ( m_SelectedModeList[iCounter] == "RGM_AllMode" )
			{
				log( "ERROR: no game type found for " $m_SelectedModeList[0] );
			}
#endif
		}
    }
}

//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E)
{
    local BOOL bProcessNotify;

#ifdefDEBUG
	if (m_bShowLog)
	{
		log("Notify: C -->"@C@"E-->"@GetNotifyMsg(E));
	}
#endif

	if (C.IsA('R6WindowButton'))
    {
        ManageR6ButtonNotify(C, E);
    }
	else if(E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            ManageR6ButtonBoxNotify(C);
            bProcessNotify = true;
        }
        else if (C.IsA('R6WindowButtonAndEditBox'))
        {
            ManageR6ButtonAndEditBoxNotify(C);
            bProcessNotify = true;
        }
    }
    else if (E == DE_Change)
    {
        if (C.IsA('UWindowComboControl'))
        {
			if (!m_bNewServerProfile)
			{
				ManageComboControlNotify(C); 
				bProcessNotify = true;
			}
        }
        else if (C.IsA('R6WindowButtonAndEditBox') ||  C.IsA('R6WindowEditControl')) // when you setvalue for this 2 class, we receive a notify(DE_Change)
        {
            bProcessNotify = true;
        }
    }

    if ((bProcessNotify) && (m_bInitComplete) && (!m_bNewServerProfile))
    {
        SetServerOptions();
    }
}


//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify( UWindowDialogControl C, byte E)
{
	Super.ManageR6ButtonNotify( C, E);

	if (E == DE_Click)
	{
		if ( R6WindowButton(C).m_iButtonID == m_pButtonsDef.EButtonName.EBN_EditMsg)
		{
			// Pop the edit welcome edit box pop-up
			PopUpMOTDEditionBox();
		}
	}
}


/////////////////////////////////////////////////////////////////
// manage the ComboControl notify message
/////////////////////////////////////////////////////////////////
function ManageComboControlNotify( UWindowDialogControl C)
{
	local string szTemp;
	local R6MenuMapList pCurrentMapList;
#ifdefDEBUG
	local BOOL bShowLog;
#endif

    if (R6WindowComboControl(C) == m_pOptionsGameMode)
    {
//		if (pCurrentMapList != None)
//		{
			szTemp = m_pOptionsGameMode.GetValue2();

#ifdefDEBUG
			if (bShowLog)
			{
				log("=========================");
				log("ManageComboControlNotify -- > CurrentMapList: "@pCurrentMapList);
				log("ManageComboControlNotify -- > GameMode"@szTemp);
			}
#endif			

			switch( szTemp)
			{
				case string(m_ANbOfGameMode[0]):
					pCurrentMapList = R6MenuMapList(GetList( m_ANbOfGameMode[0], eCGW_MapList));
//					if (m_bInGame)
//						CreateAdversarialButtons();
//					else
						SetCurrentGameMode( m_ANbOfGameMode[0], true);
					break;
				case string(m_ANbOfGameMode[1]):
					pCurrentMapList = R6MenuMapList(GetList( m_ANbOfGameMode[1], eCGW_MapList));
//					if (m_bInGame)
//						CreateCooperativeButtons();
//					else
						SetCurrentGameMode( m_ANbOfGameMode[1], true);
					break;
				default:
#ifdefDEBUG
				if (bShowLog) log("NOT DEFINED");
#endif
					break;
			}

#ifdefDEBUG
			if (bShowLog)
			{
				log("ManageComboControlNotify ---- > NewCurrentMapList: "@pCurrentMapList);
			}
#endif			
			pCurrentMapList.SetGameModeToDisplay( m_pOptionsGameMode.GetValue2());
//		}
    }
}

defaultproperties
{
}
