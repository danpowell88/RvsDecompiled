//=============================================================================
//  R6AbstractGameManager.uc : game manager object.
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//  Revision history:
//      * 18-08-2003 : Created by Yannick Joly
//=============================================================================
class R6AbstractGameManager extends Object
    native;

// --- Variables ---
// The GG client SDK has been intialized
var bool m_bGSClientInitialized;
// Flag to indicate if the game was launched by the ubi.com client
var bool m_bStartedByGSClient;
// Minimize game and return to ubi.com client
var bool m_bReturnToGSClient;
var bool m_bGSClientAlreadyInit;
var bool m_bMultiPlayerGameActive;
// ^ NEW IN 1.60
var bool m_bGSJoinUbiServer;
// ^ NEW IN 1.60
var bool m_bQueryServerInfoDone;
// ^ NEW IN 1.60

// --- Functions ---
// function ? GSClientManager(...); // REMOVED IN 1.60
// function ? InitializeGSClient(...); // REMOVED IN 1.60
final native function StartJoinServer(int _iPlayerSpawnNumber, string _szOptions, string _szIPAddress) {}
// ^ NEW IN 1.60
final native function LaunchListenSrv(string _szMode, string _szMap) {}
// ^ NEW IN 1.60
final native function bool ConnectionInterrupted(optional bool _bUserDisconnect) {}
// ^ NEW IN 1.60
final native function SetGSCreateUbiServer(bool gsCreateUbiServer) {}
// ^ NEW IN 1.60
final native function ClientLeaveServer() {}
// ^ NEW IN 1.60
final native function StartPreJoinProcedure() {}
// ^ NEW IN 1.60
final native function StartLogInProcedure() {}
// ^ NEW IN 1.60
final native function StopGSClientProcedure() {}
// ^ NEW IN 1.60
static final native function bool IsGSCreateUbiServer() {}
// ^ NEW IN 1.60
function SetConsoleInGameMgr(Console _pConsole) {}
// ^ NEW IN 1.60
function Object GetGameMgrGameService() {}
// ^ NEW IN 1.60
function SetLocalPlayerCtrl(PlayerController _localPlayer) {}
// ^ NEW IN 1.60
event GMProcessMsg(string _szMsg) {}
// ^ NEW IN 1.60

defaultproperties
{
}
