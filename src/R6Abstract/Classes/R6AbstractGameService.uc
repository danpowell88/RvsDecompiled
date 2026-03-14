//=============================================================================
// R6AbstractGameService - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6AbstractGameService extends Object
    native
    config;

var bool m_bServerWaitMatchStartReply;  // we have to reset this to true when we are going to a new round
var bool m_bClientWaitMatchStartReply;  // we have to reset this to true when we are going to a new round
var bool m_bClientWillSubmitResult;  // if this client will be required to do score submission
var bool m_bWaitSubmitMatchReply;
var bool m_bMSClientLobbyDisconnect;  // The connection for the MSClient lobby server has been lost
var bool m_bMSClientRouterDisconnect;  // The connection for the MSClient router has been lost
var PlayerController m_LocalPlayerController;
var config string m_szUserID;  // User login name for GameService

// Export UR6AbstractGameService::execNativeSubmitMatchResult(FFrame&, void* const)
native(1297) final function NativeSubmitMatchResult();

function CallNativeSetMatchResult(string szUbiUserID, int iField, int iValue)
{
	return;
}

function bool CallNativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime)
{
	return;
}

// NEW IN 1.60
function string MyID()
{
	return;
}

