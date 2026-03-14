//=============================================================================
//  R6MenuNonUbiWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2003/07/03 * Created by Yannick Joly
//=============================================================================
class R6MenuNonUbiWidget extends R6MenuWidget;

var R6GSServers                       m_GameService;

var R6WindowUbiLogIn                  m_pLoginWindow;
var R6WindowUbiCDKeyCheck             m_pCDKeyCheckWindow;       // Windows and logic for cdkey validation
var R6WindowJoinIp                    m_pJoinIPWindow;           // Windows and login for Join IP steps
var R6WindowQueryServerInfo           m_pQueryServerInfo;        // Windows and login for logic to query a server for information

var string                            m_szGamePwd;

var BOOL                              m_bLoginInProgress;        // procedure to login to ubi.com in progress
var BOOL                              m_bPreJoinInProgress;      // procedure to validate cd key in progress
var BOOL                              m_bJoinIPInProgress;
var BOOL                              m_bQueryServerInfoInProgress;

var BOOL                              m_bNonUbiMatchMakingClient;

function Created()
{
    m_GameService = R6Console(Root.console).m_GameService;

	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0, 0, 640, 480, self, TRUE));
    m_pLoginWindow.m_GameService = R6Console(Root.console).m_GameService;
    m_pLoginWindow.PopUpBoxCreate();
    m_pLoginWindow.HideWindow();

	m_pCDKeyCheckWindow = R6WindowUbiCDKeyCheck(CreateWindow(Root.MenuClassDefines.ClassUbiCDKeyCheck, 0, 0, 640, 480, self, TRUE));
    m_pCDKeyCheckWindow.m_GameService = R6Console(Root.console).m_GameService;
    m_pCDKeyCheckWindow.PopUpBoxCreate();
    m_pCDKeyCheckWindow.HideWindow();

	m_pJoinIPWindow = R6WindowJoinIP(CreateWindow(Root.MenuClassDefines.ClassMultiJoinIP, 0, 0, 640, 480, self, TRUE));
    m_pJoinIPWindow.m_GameService = m_GameService;
    m_pJoinIPWindow.PopUpBoxCreate();
    m_pJoinIPWindow.HideWindow();

	m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0, 0, 640, 480, self, TRUE));
    m_pQueryServerInfo.m_GameService = m_GameService;
    m_pQueryServerInfo.PopUpBoxCreate();
    m_pQueryServerInfo.HideWindow();

    m_bNonUbiMatchMakingClient = R6Console(Root.console).m_bNonUbiMatchMaking;
}

function ShowWindow()
{
    if (m_bNonUbiMatchMakingClient ||
        R6Console(Root.Console).m_bAutoLoginFirstPass)
    {
        R6Console(Root.Console).m_bAutoLoginFirstPass = FALSE;
        
        R6MenuRootWindow(Root).InitBeaconService();

        R6Console(Root.console).m_GameService.StartAutoLogin();
        
        if (!R6Console(Root.console).m_GameService.m_bAutoLoginInProgress)
        {
            R6Console(Root.console).szStoreGamePassWd = R6Console(Root.console).m_GameService.m_szSavedPwd;//m_pCreateTabOptions.m_pCurrentPassword.m_pEditBox.GetValue();
            m_pLoginWindow.StartLogInProcedure(Self);
            m_bLoginInProgress = TRUE;                
        }
        else
        {
            // autologin in progress, m_pLoginWindow trap the result of autologin
            m_pLoginWindow.m_pSendMessageDest = self;
            m_bLoginInProgress = TRUE; 
        }
    }
    
	Super.ShowWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local string szTemp;
	local FLOAT W, H;

	// DrawBackGround
	C.Style = ERenderStyle.STY_Alpha;

	C.SetDrawColor( Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B);        

	DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 0, 0, 10, 10, Texture'UWindow.WhiteTexture' );
	//
}

function Tick(float Delta)
{
    if ( m_bLoginInProgress )
        m_pLoginWindow.Manager( self );

    if ( m_bPreJoinInProgress )
        m_pCDKeyCheckWindow.Manager( self );

    if ( m_bJoinIPInProgress )
        m_pJoinIPWindow.Manager( self );

    if ( m_bQueryServerInfoInProgress )
        m_pQueryServerInfo.Manager( self );
}

function SendMessage( eR6MenuWidgetMessage eMessage )
{
    local string _szIPaddress;

#ifdefDEBUG
    local BOOL bShowLog;

    if (bShowLog)
    {
        log("R6MenuNonUbiWidget SendMessage");

        switch ( eMessage )
        {
            case MWM_QUERYSERVER_TRYAGAIN: log("MWM_QUERYSERVER_TRYAGAIN");     break;
            case MWM_UBI_LOGIN_SUCCESS:    log("MWM_UBI_LOGIN_SUCCESS");        break;
            case MWM_UBI_LOGIN_SKIPPED:    log("MWM_UBI_LOGIN_SKIPPED");        break;
            case MWM_UBI_LOGIN_FAIL:       log("MWM_UBI_LOGIN_FAIL");           break;
            case MWM_CDKEYVAL_SKIPPED:     log("MWM_CDKEYVAL_SKIPPED");         break;
            case MWM_CDKEYVAL_SUCCESS:     log("MWM_CDKEYVAL_SUCCESS");         break;
            case MWM_CDKEYVAL_FAIL:        log("MWM_CDKEYVAL_FAIL");            break;
            case MWM_UBI_JOINIP_SUCCESS:   log("MWM_UBI_JOINIP_SUCCESS");       break;
            case MWM_QUERYSERVER_SUCCESS:  log("MWM_QUERYSERVER_SUCCESS");      break;
            case MWM_QUERYSERVER_FAIL:     log("MWM_QUERYSERVER_FAIL");         break;
            default: log("eMessage is :"@eMessage); break;
        }
    }
#endif

    switch ( eMessage )
    {
        case MWM_QUERYSERVER_TRYAGAIN:
            m_bQueryServerInfoInProgress = FALSE;
        case MWM_UBI_LOGIN_SUCCESS:
        case MWM_UBI_LOGIN_SKIPPED:
            m_bLoginInProgress = FALSE;

            class'Actor'.static.NativeNonUbiMatchMakingAddress(_szIPaddress);

            if (m_bNonUbiMatchMakingClient)
            {
                // Get info from server!!!
                m_pQueryServerInfo.StartQueryServerInfoProcedure( self, _szIPaddress, 0 );
                m_bQueryServerInfoInProgress = TRUE;
            }
            break;
        case MWM_CDKEYVAL_SKIPPED:
        case MWM_CDKEYVAL_SUCCESS:
            m_bPreJoinInProgress = FALSE;

            if (m_bNonUbiMatchMakingClient)
            {
                class'Actor'.static.NativeNonUbiMatchMakingAddress(_szIPaddress);

                m_szGamePwd = m_pCDKeyCheckWindow.m_szPassword;
                JoinServer( _szIPaddress);

            }
            break;
        case MWM_UBI_LOGIN_FAIL:
            m_bLoginInProgress = FALSE;
        case MWM_CDKEYVAL_FAIL:
            m_bPreJoinInProgress = FALSE;
            Root.ChangeCurrentWidget(MenuQuitID);
            break;
        case MWM_UBI_JOINIP_SUCCESS:
            m_bJoinIPInProgress = FALSE;
            
            JoinServer( m_pJoinIPWindow.m_szIP);
            break;
        case MWM_QUERYSERVER_SUCCESS:
            QueryReceivedStartPreJoin();                    

            log("m_bRoomValid ="@m_pQueryServerInfo.m_bRoomValid);

            m_bQueryServerInfoInProgress = FALSE;
            break;
        case MWM_QUERYSERVER_FAIL:
            m_bQueryServerInfoInProgress = FALSE;
            break;
    }
}

function QueryReceivedStartPreJoin()
{
    local R6WindowUbiCDKeyCheck.eJoinRoomChoice eJoinRoom;
    local BOOL                                  bRoomValid;

    bRoomValid = ( m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0 &&
                   m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0    );

    if ( bRoomValid )
        eJoinRoom = EJRC_BY_LOBBY_AND_ROOM_ID;
    else
        eJoinRoom = EJRC_NO;

    m_pCDKeyCheckWindow.StartPreJoinProcedure( self, 
                                               eJoinRoom, 
                                               m_GameService.m_ClientBeacon.PreJoinInfo);
    m_bPreJoinInProgress = TRUE;


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
    
    iPlayerSpawnNumber = R6Console(Root.Console).GetSpawnNumber();    

    // Build the command line options, options use keywords and
    // are spearated by question marks.  

    // Start with empty string

    szOptions = "";

        szOptions = szOptions$"?Password="$m_pCDKeyCheckWindow.m_szPassword;

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

    m_GameService.SaveConfig();
    
//#ifdef R6PUNKBUSTER
    szOptions = szOptions$"?iPB="$class'PlayerController'.static.IsPBEnabled();
//#endif R6PUNKBUSTER	

    // Launch command
    Root.Console.ConsoleCommand("Start "$szIPAddress$"?SpawnNum="$iPlayerSpawnNumber$szOptions$"?AuthID1="$m_GameService.m_szAuthorizationID);

    // Save values to be used in the in-game menus
    R6Console(Root.console).szStoreIP = szIPAddress;
    R6Console(Root.console).szStoreGamePassWd = m_pCDKeyCheckWindow.m_szPassword;

    //m_GameService.NativeLogout();
	R6MenuRootWindow(Root).m_bJoinServerProcess = true;
}

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

    if (Result == MR_OK)
    {
        Root.ChangeCurrentWidget(MenuQuitID);
    }
}

defaultproperties
{
}
