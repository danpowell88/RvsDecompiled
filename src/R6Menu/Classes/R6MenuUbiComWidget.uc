//=============================================================================
//  R6MenuUbiComWidget.uc : Game Main Menu when the game is start by Ubi.com
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/09/18 * Created by Yannick Joly
//=============================================================================
class R6MenuUbiComWidget extends R6MenuWidget;

var R6WindowUbiCDKeyCheck             m_pCDKeyCheckWindow;       // Windows and logic for cdkey validation
var R6GSServers                       m_GameService;             // Manages servers from game service
var BOOL                              m_bPreJoinInProgress;
var string							  m_szIPAddress;
var BOOL							  m_bChangeMap;

var R6WindowButtonMainMenu            m_ButtonQuit;
var R6WindowButtonMainMenu            m_ButtonReturn;

function Created()
{
    local FLOAT fButtonXpos, fButtonWidth, fButtonHeight, fFirstButtonYpos, fButtonOffset;

    fButtonXpos      = 350;
    fButtonWidth     = 250;
    fFirstButtonYpos = 225;
    fButtonOffset    = 35;
    fButtonHeight    = 35;

    // randomly update the background texture
    Root.SetLoadRandomBackgroundImage("");

    m_GameService = R6Console(Root.console).m_GameService;

	m_pCDKeyCheckWindow = R6WindowUbiCDKeyCheck(CreateWindow(Root.MenuClassDefines.ClassUbiCDKeyCheck, 0, 0, 640, 480, self, TRUE));
    m_pCDKeyCheckWindow.m_GameService = m_GameService;
    m_pCDKeyCheckWindow.PopUpBoxCreate();
    m_pCDKeyCheckWindow.HideWindow();

    // create buttons
	m_ButtonQuit = R6WindowButtonMainMenu(CreateControl( class'R6WindowButtonMainMenu', fButtonXpos, fFirstButtonYpos, fButtonWidth, fButtonHeight, self));
    m_ButtonQuit.ToolTipString = Localize("UbiCom","ButtonQuit","R6Menu");
	m_ButtonQuit.Text = Localize("UbiCom","ButtonQuit","R6Menu");
	m_ButtonQuit.Align = TA_Right;
    m_ButtonQuit.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
    m_ButtonQuit.m_eButton_Action = Button_UbiComQuit;
	m_ButtonQuit.ResizeToText();
	

	m_ButtonReturn = R6WindowButtonMainMenu(CreateControl( class'R6WindowButtonMainMenu', fButtonXpos, fFirstButtonYpos + fButtonOffset, fButtonWidth, fButtonHeight, self));
	m_ButtonReturn.ToolTipString = Localize("UbiCom","ButtonReturn","R6Menu");
	m_ButtonReturn.Text = Localize("UbiCom","ButtonReturn","R6Menu");
	m_ButtonReturn.Align = TA_Right;
    m_ButtonReturn.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
    m_ButtonReturn.m_eButton_Action = Button_UbiComReturn;
    m_ButtonReturn.ResizeToText();
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);

    // Only display the Quit/Return buttons if the game has been
    // maximized manually by the player, that is if we are in the
    // EGS_WAITING_FOR_GS_INIT state.

    if ( m_GameService.m_eGSGameState == EGS_WAITING_FOR_GS_INIT )
    {
        if ( !m_ButtonQuit.bWindowVisible )
            m_ButtonQuit.ShowWindow();
        if ( !m_ButtonReturn.bWindowVisible )
            m_ButtonReturn.ShowWindow();
    }
    else
    {
        if ( m_ButtonQuit.bWindowVisible )
            m_ButtonQuit.HideWindow();
        if ( m_ButtonReturn.bWindowVisible )
            m_ButtonReturn.HideWindow();
    }
}

function ShowWindow()
{
	// randomly update the background texture
    Root.SetLoadRandomBackgroundImage("");

	Super.ShowWindow();
}

//===============================================================
// Tick: Overload this fct in mod to bypass CheckForGSClientStart or change empty CheckForGSClientStart 
//===============================================================
function Tick(float Delta)
{
	if (CheckForGSClientStart())
		return;

    // Join a server!

	if ( R6Console(Root.Console).m_bJoinUbiServer )
	{
        R6Console(Root.Console).m_bJoinUbiServer = FALSE;

        m_szIPAddress = m_GameService.m_szGSClientIP;
        m_pCDKeyCheckWindow.StartPreJoinProcedure( self );
        m_bPreJoinInProgress = TRUE;

		//R6Console(Root.Console).ConsoleCommand("MAXIMIZEAPP");
        //JoinServer( m_szIPAddress, FALSE);
    }

    // Create a server!


    else if ( R6Console(Root.Console).m_bCreateUbiServer )
    {
        R6Console(Root.Console).m_bCreateUbiServer = FALSE;
        Root.ChangeCurrentWidget( MPCreateGameWidgetID);

        R6MenuRootWindow(Root).InitBeaconService();
    }

   
    // Need to call ubi login manager when pre-join is in progress
    if ( m_bPreJoinInProgress )
        m_pCDKeyCheckWindow.Manager( self );
}

function SendMessage( eR6MenuWidgetMessage eMessage )
{

    switch ( eMessage )
    {
        case MWM_CDKEYVAL_SKIPPED:
        case MWM_CDKEYVAL_SUCCESS:
            m_bPreJoinInProgress = FALSE;
            JoinServer(m_szIPAddress);
            break;
        case MWM_CDKEYVAL_FAIL:
            class'Actor'.static.GetGameManager().m_bReturnToGSClient = TRUE;
            m_bPreJoinInProgress = FALSE;
            break;
    }

}


//==============================================================================
// JoinSelectedServer -  Join the IP address passed as a function argument.
//==============================================================================
function JoinServer( string szIPAddress)
{

	local INT    iPlayerSpawnNumber;
    local string szOptions;
    local string m_CharacterName;
    local string szUbiUserID;
    local string m_ArmorName;
    local string m_WeaponNameOne;
    local string m_WeaponGadgetNameOne;
    local string m_BulletTypeOne;
    local string m_WeaponNameTwo;
    local string m_WeaponGadgetNameTwo;
    local string m_BulletTypeTwo;
    local string m_GadgetNameOne;
    local string m_GadgetNameTwo;
    local PlayerController aPlayerController;

#ifdefMPDEMO
    GetPlayerOwner().StopAllMusic();
#endif

    iPlayerSpawnNumber = R6Console(Root.console).GetSpawnNumber();    

    // Build the command line options, options use keywords and
    // are spearated by question marks.  

    // Start with empty string

    szOptions = "";

    // Password

    if ( m_GameService.m_szGSPassword != "" )
        szOptions = szOptions$"?Password="$m_GameService.m_szGSPassword;

    // Player Name

    Root.Console.ViewportOwner.Actor.GetPlayerSetupInfo( m_CharacterName,
                                                         m_ArmorName,
                                                         m_WeaponNameOne,
                                                         m_WeaponGadgetNameOne,
                                                         m_BulletTypeOne,
                                                         m_WeaponNameTwo,
                                                         m_WeaponGadgetNameTwo,
                                                         m_BulletTypeTwo,
                                                         m_GadgetNameOne,
                                                         m_GadgetNameTwo);

    // Some symbols cannot be included in the name since they will 
    // be misinterpreted by the engine.  This includes ?,#/ and spaces.
    // To get around this problem we will replace all these symbols with ~'s
    // and then replace the ~'s with spaces when the name is interpreted
    // on the server side.

    ReplaceText(m_CharacterName, "?", "~");
    ReplaceText(m_CharacterName, ",", "~");
    ReplaceText(m_CharacterName, "#", "~");
    ReplaceText(m_CharacterName, "/", "~");

    szOptions = szOptions$"?Name="$m_CharacterName;    

    // Spaces are replaced by the "~" symbol, the "~"'s are removed in gameinfo.uc

    ReplaceText(szOptions, " ", "~");

    // Ubi.com uder ID

    szUbiUserID = m_GameService.m_szUserID;

    szOptions = szOptions$"?UbiUserID="$m_GameService.m_szUserID;    

	// Gender
//	szOptions = szOptions$"?Gender="$class'Actor'.static.GetGameOptions().Gender;

    // Update ubi.com that we have joined the server

//    m_GameService.NativeMSCLientJoinServer( m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iID, m_szGamePwd );
//    m_GameService.GameServiceManager();


    m_GameService.SaveConfig();
    
//#ifdef R6PUNKBUSTER
    szOptions = szOptions$"?iPB="$class'PlayerController'.static.IsPBEnabled();
//#endif R6PUNKBUSTER	


    // Launch command
    Root.Console.ConsoleCommand("Open "$szIPAddress$"?SpawnNum="$iPlayerSpawnNumber$szOptions$"?AuthID1="$m_GameService.m_szRSAuthorizationID);

    //Root = None;        // Will be cleaned on garbage collection

    Self.HideWindow();
    //Root.Console.CloseUWindow();

    // Save values to be used in the in-game menus
    R6Console(Root.console).szStoreIP = szIPAddress;
    R6Console(Root.console).szStoreGamePassWd = m_GameService.m_szGSPassword;

    //m_GameService.NativeLogout();
}

//===========================================================================================
// CheckForGSClientStart: a engine start from Ubi.com
//===========================================================================================
function BOOL CheckForGSClientStart()
{
	local R6ModMgr pModManager;
#ifdefDEBUG
	local BOOL bShowLogCheckForGSClientStart;
#endif

	// When the server is created via the GSClient, the game is start with RS. So now check if you're in the appropriate mod.
	// We receive the info from GSClient about the room/mod you start

	if (R6Console(Root.console).m_bStartedByGSClient)
	{
		pModManager = class'Actor'.static.GetModMgr();

#ifdefDEBUG
		if (bShowLogCheckForGSClientStart)
		{
			log("--> we start the game with GSClient");
			log("--> ModManager.m_szPendingModName = "$pModManager.m_szPendingModName);
			log("m_pRVS.m_szGameServiceGameName = "$pModManager.m_pRVS.m_szGameServiceGameName);
		}
#endif

		if ( !(pModManager.m_szPendingModName ~= pModManager.m_pRVS.m_szGameServiceGameName) && (pModManager.m_szPendingModName != ""))
		{  
#ifdefDEBUG
			if (bShowLogCheckForGSClientStart)
				log("--> SetCurrentMod to "@pModManager.m_szPendingModName);
#endif
			if ( (R6Console(Root.console).m_GameService.m_eGSGameState == EGS_SERVER_SETTING_UP_GAME) ||
			     (R6Console(Root.console).m_GameService.m_eGSGameState == EGS_CLIENT_WAITING_CHSTA) )
			{
				pModManager.SetCurrentMod(pModManager.m_szPendingModName, GetLevel(), true);
                R6Console(Root.console).CleanAndChangeMod();				
				R6Console(Root.console).m_eLastPreviousWID = UbiComWidgetID;
				R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_InitMod);
			}
#ifdefDEBUG
			else
			{
			    if (bShowLogCheckForGSClientStart)
				    log("--> SetCurrentMod to "@pModManager.m_szPendingModName@" didn't happen");
			}
#endif

			return true;
		}
	}

	return false;
}

//==============================================================================
// PromptConnectionError -  A connection error has occured, put up a pop
// up menu.
//==============================================================================
function PromptConnectionError()
{
	local R6MenuRootWindow R6Root;
	local string szTemp;

    // A connection error to the server has occured, display the pop up menu
    // with the appropriate message.

	R6Root = R6MenuRootWindow(Root);

	R6Root.m_RSimplePopUp.X = 140;
	R6Root.m_RSimplePopUp.Y = 170;
	R6Root.m_RSimplePopUp.W = 360;
	R6Root.m_RSimplePopUp.H = 77;

    if(R6Console(Root.console).m_szLastError!="")
    {
		szTemp = Localize("Multiplayer",  R6Console(Root.console).m_szLastError, "R6Menu", true);

        if (szTemp == "")
            szTemp = Localize("Errors",  R6Console(Root.console).m_szLastError, "R6Engine", true);

		if (szTemp == "")
			szTemp = R6Console(Root.console).m_szLastError;

	    R6Root.SimplePopUp( Localize("MultiPlayer","Popup_Error_Title","R6Menu"),
							szTemp, EPopUpID_ErrorConnect, MessageBoxButtons.MB_OK, false, self);

        R6Console(Root.console).m_szLastError = "";
    }
    else
	{
	    R6Root.SimplePopUp( Localize("MultiPlayer","Popup_Error_Title","R6Menu"),
							Localize("MultiPlayer","Popup_ConnectionError","R6Menu"), 
							EPopUpID_ErrorConnect, MessageBoxButtons.MB_OK, false, self);
	}
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
	// don't forget to resize popup to original value
	R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).Default.m_RSimplePopUp;
	
    // Minimize game and return to ubi.com client.
    class'Actor'.static.GetGameManager().m_bReturnToGSClient = TRUE;
}

//==============================================================================
// Notify -  Called when the player presses on a button (quit or return).
//==============================================================================
function Notify(UWindowDialogControl C, byte E)
{
	if (C.IsA('R6WindowButtonMainMenu'))
    {
        if(E == DE_Click)
        {
            // Quit button, quit the game.
            if (C == m_ButtonQuit)
                Root.DoQuitGame();

            // Return to ubi.com button, Minimize the game.
            else if (C == m_ButtonReturn)
                class'Actor'.static.GetGameManager().m_bReturnToGSClient = TRUE;
        }
    }
}

defaultproperties
{
}
