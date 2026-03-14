//=============================================================================
// R6GameManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// R6GameManager.uc: game manager object.
//
// Revision history:
//      * 22-04-2003 : Created by Jean-Francois Dube
//=============================================================================
class R6GameManager extends R6AbstractGameManager
 native;

// NEW IN 1.60
var R6GSServers m_GameMgrGameService;
// NEW IN 1.60
var R6Console m_GameMgrConsole;

// NEW IN 1.60
function SetConsoleInGameMgr(Console _pConsole)
{
	m_GameMgrConsole = R6Console(_pConsole);
	return;
}

// NEW IN 1.60
function Object GetGameMgrGameService()
{
	return m_GameMgrGameService;
	return;
}

// NEW IN 1.60
function SetLocalPlayerCtrl(PlayerController _localPlayer)
{
	m_GameMgrGameService.m_LocalPlayerController = _localPlayer;
	return;
}

// NEW IN 1.60
event GMProcessMsg(string _szMsg)
{
	// End:0x28
	if(__NFUN_119__(m_GameMgrConsole, none))
	{
		m_GameMgrConsole.Root.ProcessGSMsg(_szMsg);
	}
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var bShowLog
// REMOVED IN 1.60: var m_GameService
// REMOVED IN 1.60: function InitGSClient
// REMOVED IN 1.60: function NativeInitGSClient
// REMOVED IN 1.60: function InitGameManager
// REMOVED IN 1.60: function InitializeGSClient
// REMOVED IN 1.60: function GSClientManager
