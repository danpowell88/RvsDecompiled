//=============================================================================
// R6GameManager.uc: game manager object.
//
// Revision history:
//      * 22-04-2003 : Created by Jean-Francois Dube
//=============================================================================
class R6GameManager extends R6AbstractGameManager
    native;

var BOOL    bShowLog;
var R6GSServers m_GameService;

native(1550) final function BOOL    InitGSClient();				// 
native(1288) final function BOOL    NativeInitGSClient();

/*
event InitGameManager()
{

}
*/

//=============================================================================
// InitializeGSClient: Initialize the GS Client SDK, connect to the ubi.com
// client application.
//=============================================================================
function InitializeGSClient()
{
    local BOOL bInitialized;
    m_bGSClientInitialized = m_GameService.NativeInitGSClient();
    m_bStartedByGSClient = class'Actor'.static.NativeStartedByGSClient();
    
    if (m_bStartedByGSClient==true)
    {
        bInitialized = m_GameService.SetGSClientComInterface();
        if (bInitialized==false)
        {
            log("ERROR: GS Client Com interface not initialized!!!");
        }
    }
}

///////////////////////////////////////////////////////////////
// This function manages the ubi.com GSClient SDK integration
///////////////////////////////////////////////////////////////

function GSClientManager(Console LocalConsole)
{
#ifndefSPDEMO

    local R6Console _LocalConsole;    
    
    _LocalConsole = R6Console(LocalConsole);
    m_GameService = _LocalConsole.m_GameService;
//    _GService = R6GSServers(_GameService);
    
	if (!m_bGSClientAlreadyInit && !m_bGSClientInitialized )
	{
	    InitializeGSClient();
		m_bGSClientAlreadyInit = m_bGSClientInitialized;
	}

    // TODO, add something to try initializing a few times, if 
    // continues to fail, quit game

    _LocalConsole.m_GameService.GameServiceManager( TRUE, TRUE, FALSE, TRUE );

    // -----------------------------------------------------
    // Process game state when controlled by GS client
    // -----------------------------------------------------

    switch ( _LocalConsole.m_GameService.m_eGSGameState )
    {
        // Waiting for ubi.com to tell us if we are a server or a client

        case EGS_WAITING_FOR_GS_INIT:
            // If the ubi.com client is not responding, exit the application
            if ( _LocalConsole.m_GameService.m_bUbiComClientDied )
            {
                _LocalConsole.ConsoleCommand("quit");
                log ("Game exited because ubi.com client application died");
            }
        
            // Minimize the game
            if ( m_bReturnToGSClient )
            {
                m_bReturnToGSClient = FALSE;
                _LocalConsole.MinimizeAndPauseMusic();
            }
            break;

        // State machine for client

        case EGS_CLIENT_INIT_RCVD:
            if ( bShowLog ) log ( "*** EGS_GS_CLIENT_INIT_RCVD");
            _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_INITCLIENTSESSION_AK );
            _LocalConsole.m_GameService.SetGSGameState(EGS_CLIENT_WAITING_CHSTA);
            break;

        case EGS_CLIENT_WAITING_CHSTA:
            // If the ubi.com client is not responding, exit the application
            if ( _LocalConsole.m_GameService.m_bUbiComClientDied )
            {
                _LocalConsole.ConsoleCommand("quit");
                log ("Game exited because ubi.com client application died");
            }
            // If the room has been destroyed, return to initial state
            if ( _LocalConsole.m_GameService.m_bUbiComRoomDestroyed )
            {
                _LocalConsole.m_GameService.m_bUbiComRoomDestroyed = FALSE;
                _LocalConsole.m_GameService.SetGSGameState(EGS_WAITING_FOR_GS_INIT);
            }

            break;

        case EGS_CLIENT_CHSTA_RCVD:
            if ( bShowLog ) log ( "*** EGS_CLIENT_CHSTA_RCVD");
            _LocalConsole.ConsoleCommand("MAXIMIZEAPP");
            _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_CLIENTSESSION_AK );
            _LocalConsole.m_GameService.SetGSGameState(EGS_CLIENT_IN_GAME);
            _LocalConsole.m_bJoinUbiServer = TRUE;
            break;

        case EGS_CLIENT_IN_GAME:
            if ( m_bReturnToGSClient )
            {
                if ( bShowLog ) log ( "*** EGS_WAITING_FOR_GS_INIT");
                m_bReturnToGSClient = FALSE;
                _LocalConsole.MinimizeAndPauseMusic();
                _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_SWITCHTOGS );
                _LocalConsole.m_GameService.SetGSGameState(EGS_WAITING_FOR_GS_INIT);
            }
            break;

        // State machine for server

        case EGS_SERVER_INIT_RCVD:

            if ( bShowLog ) log ( "*** EGS_SERVER_INIT_RCVD");
            _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_INITMASTERSESSION_AK );
            _LocalConsole.m_GameService.SetGSGameState(EGS_SERVER_WAITING_CHSTA);
            break;

        case EGS_SERVER_WAITING_CHSTA:
            // If the ubi.com client is not responding, exit the application
            if ( _LocalConsole.m_GameService.m_bUbiComClientDied )
            {
                _LocalConsole.ConsoleCommand("quit");
                log ("Game exited because ubi.com client application died");
            }
            break;

        case EGS_SERVER_CHSTA_RCVD:
            if ( bShowLog ) log ( "*** EGS_SERVER_CHSTA_RCVD");
	        _LocalConsole.ViewportOwner.Actor.PlaySound(Sound'Music.Play_Theme_MusicSilence', SLOT_Music);
            _LocalConsole.ConsoleCommand("MAXIMIZEAPP");
            _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_MASTERSESSION_AK );
            _LocalConsole.m_GameService.SetGSGameState(EGS_SERVER_SETTING_UP_GAME);
            _LocalConsole.m_bCreateUbiServer = TRUE;
            break;

        case EGS_SERVER_SETTING_UP_GAME:
            if ( m_bReturnToGSClient )
            {
                if ( bShowLog ) log ( "*** EGS_WAITING_FOR_GS_INIT");       
                m_bReturnToGSClient = FALSE;
                _LocalConsole.MinimizeAndPauseMusic();
                _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_SWITCHTOGS );
                _LocalConsole.m_GameService.SetGSGameState(EGS_WAITING_FOR_GS_INIT);
            }
            else if ( _LocalConsole.bMultiPlayerGameActive )
            {
                if ( bShowLog ) log ( "*** EGS_SERVER_READY");
                _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_READYTORECEIVECONNECTIONS );
                _LocalConsole.m_GameService.SetGSGameState(EGS_SERVER_READY);            
            }
            break;

        case EGS_SERVER_READY:
            if ( m_bReturnToGSClient )
            {
                if ( bShowLog ) log ( "*** EGS_WAITING_FOR_GS_INIT");
                m_bReturnToGSClient = FALSE;
                _LocalConsole.MinimizeAndPauseMusic();
                _LocalConsole.m_GameService.NativeGSClientPostMessage( EGSMESSAGE_SWITCHTOGS );
                _LocalConsole.m_GameService.SetGSGameState(EGS_WAITING_FOR_GS_INIT);
            }
            break;

        case EGS_TERMINATE_RCVD:
            _LocalConsole.ConsoleCommand("quit");
            break;
    }

#endif //SPDEMO
}

defaultproperties
{
}
