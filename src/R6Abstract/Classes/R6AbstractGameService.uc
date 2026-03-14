// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Abstract.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6AbstractGameService extends Object
    native;

// --- Variables ---
var PlayerController m_LocalPlayerController;
// User login name for GameService
var config string m_szUserID;
// we have to reset this to true when we are going to a new round
var bool m_bServerWaitMatchStartReply;
// we have to reset this to true when we are going to a new round
var bool m_bClientWaitMatchStartReply;
// if this client will be required to do score submission
var bool m_bClientWillSubmitResult;
var bool m_bWaitSubmitMatchReply;
// The connection for the MSClient lobby server has been lost
var bool m_bMSClientLobbyDisconnect;
// The connection for the MSClient router has been lost
var bool m_bMSClientRouterDisconnect;

// --- Functions ---
final native function NativeSubmitMatchResult() {}
// ^ NEW IN 1.60
function CallNativeSetMatchResult(string szUbiUserID, int iField, int iValue) {}
function bool CallNativeProcessIcmpPing(string _ServerIpAddress, out int piPingTime) {}
// ^ NEW IN 1.60
function string MyID() {}
// ^ NEW IN 1.60

defaultproperties
{
}
