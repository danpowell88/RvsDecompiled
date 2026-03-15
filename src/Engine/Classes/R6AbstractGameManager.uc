//=============================================================================
// R6AbstractGameManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractGameManager.uc : game manager object.
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//  Revision history:
//      * 18-08-2003 : Created by Yannick Joly
//=============================================================================
class R6AbstractGameManager extends Object
    native;

var bool m_bGSClientInitialized;  // The GG client SDK has been intialized
var bool m_bStartedByGSClient;  // Flag to indicate if the game was launched by the ubi.com client
var bool m_bReturnToGSClient;  // Minimize game and return to ubi.com client
var bool m_bGSClientAlreadyInit;
// NEW IN 1.60
var bool m_bMultiPlayerGameActive;
// NEW IN 1.60
var bool m_bGSJoinUbiServer;
// NEW IN 1.60
var bool m_bQueryServerInfoDone;

// Export UR6AbstractGameManager::execStartJoinServer(FFrame&, void* const)
// NEW IN 1.60
native(1284) final function StartJoinServer(string _szIPAddress, string _szOptions, int _iPlayerSpawnNumber);

// Export UR6AbstractGameManager::execLaunchListenSrv(FFrame&, void* const)
// NEW IN 1.60
native(1285) final function LaunchListenSrv(string _szMap, string _szMode);

// Export UR6AbstractGameManager::execClientLeaveServer(FFrame&, void* const)
// NEW IN 1.60
native(1286) final function ClientLeaveServer();

// Export UR6AbstractGameManager::execConnectionInterrupted(FFrame&, void* const)
// NEW IN 1.60
native(1287) final function bool ConnectionInterrupted(optional bool _bUserDisconnect);

// Export UR6AbstractGameManager::execStartPreJoinProcedure(FFrame&, void* const)
// NEW IN 1.60
native(1288) final function StartPreJoinProcedure();

// Export UR6AbstractGameManager::execStartLogInProcedure(FFrame&, void* const)
// NEW IN 1.60
native(1289) final function StartLogInProcedure();

// Export UR6AbstractGameManager::execStopGSClientProcedure(FFrame&, void* const)
// NEW IN 1.60
native(1290) final function StopGSClientProcedure();

// Export UR6AbstractGameManager::execIsGSCreateUbiServer(FFrame&, void* const)
// NEW IN 1.60
native(1201) static final function bool IsGSCreateUbiServer();

// Export UR6AbstractGameManager::execSetGSCreateUbiServer(FFrame&, void* const)
// NEW IN 1.60
native(1203) final function SetGSCreateUbiServer(bool gsCreateUbiServer);

// NEW IN 1.60
function SetConsoleInGameMgr(Console _pConsole)
{
	return;
}

// NEW IN 1.60
function Object GetGameMgrGameService()
{
	return;
}

// NEW IN 1.60
function SetLocalPlayerCtrl(PlayerController _localPlayer)
{
	return;
}

// NEW IN 1.60
event GMProcessMsg(string _szMsg)
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function InitializeGSClient
// REMOVED IN 1.60: function GSClientManager
