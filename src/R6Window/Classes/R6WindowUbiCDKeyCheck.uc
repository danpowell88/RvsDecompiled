//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiCDKeyCheck extends R6WindowMPManager;


enum eJoinRoomChoice
{
    EJRC_NO,
//    EJRC_BY_MSCLIENT_ID,
    EJRC_BY_LOBBY_AND_ROOM_ID
};

var R6WindowPopUpBox                  m_pPleaseWait;             // Ask user to wait while we get authorization ID 
var R6GSServers                       m_GameService;             // Manages servers from game service
var UWindowWindow                     m_pSendMessageDest;
var R6WindowPopUpBox                  m_pR6EnterCDKey;           // Menu to enter a cd key.
var eJoinRoomChoice                   m_eJoinRoomChoice;         // Need to join the ubi.com room
var string                            m_szPassword;              // Game Password
//var INT                               m_iGroupID;                // Server Group ID (either from MS Cleint lib or from RegServer Lib)
//var INT                               m_iLobbyID;                // Server Lobby ID
//var BOOL                              m_bLocked;                 // Server is locked (password required)
var config BOOL bShowLog;


//=======================================================================
// StartLogInProcedure - Called from the menus when the user should
// enter his ubi.com userID/password
//=======================================================================
function StartPreJoinProcedure( UWindowWindow   _pCurrentWidget, 
                                optional eJoinRoomChoice  _eJoinUbiComRoom, 
                                optional ClientBeaconReceiver.PreJoinResponseInfo _preJResponseInfo) 
{
    m_GameService.RequestModCDKeyProcess(false);
    // Save values of function parameters for use in other member functions
    m_pSendMessageDest  = _pCurrentWidget;
    m_eJoinRoomChoice   = _eJoinUbiComRoom;
    m_preJoinRespInfo = _preJResponseInfo;

#ifdefMPDEMO
    // CDKEY disabled for multi player demo
    ShowWindow();
    HandlePunkBusterSvrSituation();
    return;
#endif

#ifdefDEBUG
    if ( !m_GameService.m_bUseCDKey )
    {
        ShowWindow();
        HandlePunkBusterSvrSituation();
    }
    else
    {
#endif
        if ( !m_GameService.m_bValidActivationID )
        {
            m_pR6EnterCDKey.ShowWindow();
        }
        else
        {
            m_GameService.RequestGSCDKeyAuthID();
            m_pPleaseWait.ShowLockPopUp();
        }
        ShowWindow();
#ifdefDEBUG
    }
#endif
}


//=======================================================================
// Manager - Should be called regularly by the parent window whenever
// a reques is in progress
//=======================================================================
function Manager( UWindowWindow _pCurrentWidget )
{
    local R6WindowTextLabel pR6TextLabelTemp;
    
    switch( m_GameService.m_eMenuGetCDKeyActID )
    {
    case EMENU_REQ_TIMEOUT_ERROR:
        if ( bShowLog) log ( "*** Act ID Fail ***" );
        m_GameService.m_eMenuGetCDKeyActID = EMENU_REQ_NONE;
        m_pPleaseWait.HideWindow();
        m_pR6EnterCDKey.ModifyTextWindow( Localize("Errors", "CDKeyServerNotResponding", "R6ENGINE"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        break;
        
        // player  is trying to connect to a server on the same subnet, and not a ubi.com server
        // ignore the timeout
    case EMENU_REQ_TIMEOUT:
        m_GameService.m_eMenuGetCDKeyActID = EMENU_REQ_NONE;
        m_GameService.RequestGSCDKeyAuthID();
        if ( bShowLog) log ("*** ActId TimeOut Error ***");
        break;
        
    case EMENU_REQ_SUCCESS:
        
        m_GameService.m_eMenuGetCDKeyActID = EMENU_REQ_NONE;
        m_GameService.SaveConfig();
        m_GameService.RequestGSCDKeyAuthID();
        if ( bShowLog) log ("*** Activation ID obtained ***");
        break;
        
    case EMENU_REQ_FAILURE:
        if ( bShowLog) log ( "*** Act ID Fail ***" );
        m_GameService.m_eMenuGetCDKeyActID = EMENU_REQ_NONE;
        m_pPleaseWait.HideWindow();
        switch (m_GameService.m_eMenuCDKeyFailReason)
        {
        case EFAIL_INVALIDCDKEY:
            m_pR6EnterCDKey.ModifyTextWindow( Localize("Errors", "INVALIDCDKEY", "R6ENGINE"), 205, 170, 230, 30);
            m_pR6EnterCDKey.ShowWindow();
            break;
        case EFAIL_CDKEYUSED:
            DisplayErrorMsg( Localize("Errors","CDKeyAlreadyInUse","R6ENGINE"), EPopUpID_JoinRoomErrorCDKeyInUse);
            break;
        default:
            m_pR6EnterCDKey.ModifyTextWindow( Localize("Errors", "CDKeyTryLater", "R6ENGINE"), 205, 170, 230, 30);
            m_pR6EnterCDKey.ShowWindow();
            break;
        }
        break;
    }


    switch ( m_GameService.m_eMenuCDKeyAuthorization )
    {
    case EMENU_REQ_TIMEOUT_ERROR:
        if ( bShowLog) log ( "*** Auth ID Timeout ERROR ***" );
        m_pPleaseWait.HideWindow();
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        DisplayErrorMsg( Localize("Errors", "CDKeyServerNotResponding", "R6ENGINE"), EPopUpID_JoinRoomErrorCDKeySrvNotResp);
        break;
    case EMENU_REQ_INUSE_ERROR:
        m_pPleaseWait.HideWindow();
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        DisplayErrorMsg( Localize("Errors", "CDKeyAlreadyInUse", "R6ENGINE"), EPopUpID_JoinRoomErrorCDKeyInUse);
        break;
        
    case EMENU_REQ_TIMEOUT:
        if ( bShowLog) log ( "*** Auth ID Timeout Let client play ***" );
    case EMENU_REQ_SUCCESS:
        // If we need to join a ubi.com room, do so now
        m_pPleaseWait.HideWindow();
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        HandlePunkBusterSvrSituation();
        break;
        
    case EMENU_REQ_NOTCHALLENGED:
        if (bShowLog) log( "*** Auth ID NOT Challenged ***" );
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        m_pPleaseWait.HideWindow();
        m_pPleaseWait.ModifyTextWindow( Localize("Errors","CDKeyTryLater","R6ENGINE")$": 3" , 205, 170, 230, 30);
        m_pPleaseWait.ShowWindow();
        break;
        
    case EMENU_REQ_INT_ERROR:
        if (bShowLog) log( "*** Auth ID Internal Error ***" );
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        m_pPleaseWait.HideWindow();
        m_pPleaseWait.ModifyTextWindow( Localize("Errors","CDKeyTryLater","R6ENGINE")$": 5", 205, 170, 230, 30);
        m_pPleaseWait.ShowWindow();
        break;
        
    case EMENU_REQ_FAILURE:
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
#ifdefDEBUG
        if ( m_GameService.m_bUseCDKey )
        {
#endif
            if ( bShowLog) log ( "*** Auth ID Fail ***" );
            m_pPleaseWait.HideWindow();
            m_GameService.m_bValidActivationID = FALSE;
            m_pR6EnterCDKey.ModifyTextWindow( Localize("Errors", "INVALIDCDKEY", "R6ENGINE"), 205, 170, 230, 30);
            m_pR6EnterCDKey.ShowWindow();
#ifdefDEBUG
        }
        else
        {
            m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
            m_pPleaseWait.HideWindow();
        }
        break;
#endif
    }

    // For now, just wait for the join room process to finish before continuing
    // with the login procedure.  A good optimisation would be to have a
    // "password failed" message appear now instead of allowing the user to try
    // and join the game with an incorrect password, then getting the error message.

    switch ( m_GameService.m_eMenuJoinServer )
    {
    case EMENU_REQ_SUCCESS:
        m_GameService.m_eMenuJoinServer = EMENU_REQ_NONE;
        m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
        m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_SUCCESS );
        m_GameService.NativeMSClientServerConnected( m_preJoinRespInfo.iLobbyID, m_preJoinRespInfo.iGroupID);
        //            m_pPleaseWait.HideWindow();
        //            HideWindow();
        break;
    case EMENU_REQ_TIMEOUT:
    case EMENU_REQ_FAILURE:
        m_GameService.m_eMenuJoinServer = EMENU_REQ_NONE;
        m_pPleaseWait.HideWindow();
        switch ( m_GameService.m_eMenuJoinRoomFailReason )
        {
        case EFAIL_PASSWORDNOTCORRECT:
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_PassWd","R6Menu"), EPopUpID_JoinRoomErrorPassWd);
            break;
        case EFAIL_ROOMFULL:
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_ServerFull","R6Menu"), EPopUpID_JoinRoomErrorSrvFull);
            break;
        case EFAIL_DEFAULT:
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_RoomJoin","R6Menu"), EPopUpID_JoinRoomError);
            break;
        }
        break;
    }
    
    
}
//=======================================================================
// PopUpBoxCreate - Creates the pop up windows
//=======================================================================

function PopUpBoxCreate()
{
    local R6WindowEditBox pR6EditBoxTemp;
    local R6WindowTextLabel pR6TextLabelTemp;
    
    // Create PopUp frame for please wait window
    
    Super.PopUpBoxCreate();
    
    m_pPleaseWait = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPleaseWait.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Wait","R6Menu"), 30, 205, 170, 230, 50, MessageBoxButtons.MB_Cancel);
    m_pPleaseWait.CreateClientWindow( class'R6WindowTextLabel');
    m_pPleaseWait.m_ePopUpID = EPopUpID_CDKeyPleaseWait;
    m_pPleaseWait.SetPopUpResizable(true);
    pR6TextLabelTemp = R6WindowTextLabel(m_pPleaseWait.m_ClientArea);
    pR6TextLabelTemp.Text = Localize("MultiPlayer","PopUp_Cancel","R6Menu");
    pR6TextLabelTemp.Align = TA_Center;
    pR6TextLabelTemp.m_Font = Root.Fonts[F_VerySmallTitle];
    pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
    pR6TextLabelTemp.m_BGTexture = None;
    pR6TextLabelTemp.m_HBorderTexture = None;
    pR6TextLabelTemp.m_VBorderTexture = None;
    pR6TextLabelTemp.m_TextDrawstyle  = ERenderStyle.STY_Alpha;
    m_pPleaseWait.HideWindow();
    
    // Create PopUp frame for cdkey window
    
    m_pR6EnterCDKey = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pR6EnterCDKey.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_EnterCDKey","R6Menu"), 30, 205, 170, 230, 50);
    m_pR6EnterCDKey.CreateClientWindow( class'R6WindowEditBox');
    m_pR6EnterCDKey.m_ePopUpID = EPopUpID_EnterCDKey;
    pR6EditBoxTemp = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea);
    pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
    pR6EditBoxTemp.SetFont(F_PopUpTitle);
    //pR6EditBoxTemp.bPassword = TRUE;
    m_pR6EnterCDKey.HideWindow();
    
    // Create PopUp frame for password
    
    m_pPassword = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPassword.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Password","R6Menu"), 30, 205, 170, 230, 50);
    m_pPassword.CreateClientWindow( class'R6WindowEditBox');
    m_pPassword.m_ePopUpID = EPopUpID_Password;
    m_pPasswordEditBox = R6WindowEditBox(m_pPassword.m_ClientArea);
    m_pPasswordEditBox.TextColor = Root.Colors.BlueLight;
    m_pPasswordEditBox.SetFont(F_PopUpTitle);
    m_pPasswordEditBox.MaxLength = 16;
    m_pPasswordEditBox.bCaps = FALSE;
    m_pPasswordEditBox.bPassword = TRUE;
    m_pPassword.HideWindow();
    
}


//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
    local string _szEncryptedCdkey;
    // don't forget to resize popup to original value
    R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).Default.m_RSimplePopUp;
    
    if (Result == MR_OK)
    {
        switch ( _ePopUpID )
        {
        case EPopUpID_Password:
            m_szPassword = R6WindowEditBox(m_pPassword.m_ClientArea).GetValue();
            switch ( m_eJoinRoomChoice )
            {
//            case EJRC_BY_MSCLIENT_ID:
//                m_GameService.NativeMSCLientJoinServer( m_preJoinRespInfo.iGroupID, m_szPassword );
//                m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
//                m_pPleaseWait.ShowWindow();
//                break;
            case EJRC_BY_LOBBY_AND_ROOM_ID:
                m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
                m_GameService.NativeMSCLientJoinServer(m_preJoinRespInfo.iLobbyID, m_preJoinRespInfo.iGroupID, m_szPassword );
                m_pPleaseWait.ShowWindow();
                break;
                // If we do not need to join a ubi.com room, continue with the pre-login procedure
            case EJRC_NO:
                m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
                m_pPleaseWait.ShowLockPopUp();
                m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_SUCCESS );
                //                        HideWindow();
                break;
            }
            break;
            case EPopUpID_CDKeyPleaseWait:
                HideWindow();
                break;
            case EPopUpID_JoinRoomErrorPassWd:
                m_pPassword.ShowWindow();
                m_pPasswordEditBox.SelectAll();
                break;
            case EPopUpID_JoinRoomError:
            case EPopUpID_JoinRoomErrorCDKeyInUse:
            case EPopUpID_JoinRoomErrorCDKeySrvNotResp:
            case EPopUpID_JoinRoomErrorSrvFull:
                HideWindow();
                m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
                break;
            case EPopUpID_EnterCDKey:
                if ( m_GameService.m_szCDKey != R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea).GetValue() ||
                    m_GameService.m_bValidActivationID == false)
                {
                    m_GameService.m_szCDKey = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea).GetValue();
                    m_GameService.RequestGSCDKeyActID();
                    _szEncryptedCdkey = class'eviLCore'.static.EncryptCDKey(m_GameService.m_szCDKey);
                    SetRegistryKey("SOFTWARE\\Red Storm Entertainment\\RAVENSHIELD", "CDKey", _szEncryptedCdkey);
                }
                else
                    // ask for authorization id
                    m_GameService.RequestGSCDKeyAuthID();
                
                m_pPleaseWait.ShowWindow();
                break;
            case EPopUpID_PunkBusterDisabledServerWarn:
                HandleLockedServerPopUp();
                break;
            case EPopUpID_PunkBusterOnlyError:
                if ( R6Console(Root.console).m_bNonUbiMatchMaking || 
                    R6Console(Root.console).m_bStartedByGSClient )
                {
                    Root.ChangeCurrentWidget(MenuQuitID);
                }
                HideWindow();
                break;                
        }
    }
    else if (Result == MR_Cancel)
    {
        switch ( _ePopUpID )
        {
        case EPopUpID_CDKeyPleaseWait:
            m_GameService.CancelGSCDKeyActID(); 
            m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
            break;
            
        case EPopUpID_EnterCDKey:
        case EPopUpID_JoinRoomError:
        case EPopUpID_JoinRoomErrorCDKeyInUse:
        case EPopUpID_JoinRoomErrorCDKeySrvNotResp:
        case EPopUpID_JoinRoomErrorPassWd:
        case EPopUpID_JoinRoomErrorSrvFull:
            m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
            break;
        case EPopUpID_Password:
            case EPopUpID_PunkBusterDisabledServerWarn:
            case EPopUpID_PunkBusterOnlyError:
            // quit game for m_bNonUbiMatchMaking
            if (R6Console(Root.console).m_bNonUbiMatchMaking)
            {
                Root.ChangeCurrentWidget(MenuQuitID);
            }
            break;
        }
        HideWindow();
    }
}

defaultproperties
{
     bShowLog=True
}
