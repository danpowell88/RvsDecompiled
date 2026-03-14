// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuCDKeyManager extends UWindowWindow;

// --- Variables ---
var R6WindowUbiCDKeyCheck m_pCDKeyCheckWindow;
var UWindowWindow m_pProcedureOwner;
var bool m_bPreJoinInProgress;
var eGameWidgetID m_eCurrentWID;
var bool m_bShowManagerCDKeyLog;

// --- Functions ---
function ProcessCDKeyMessage(eR6MenuWidgetMessage eMessage) {}
function StartCDKeyProcess(optional eJoinRoomChoice _eJoinUbiComRoom, optional PreJoinResponseInfo _preJResponseInfo) {}
function SetWindowUser(eGameWidgetID _eGameWID, UWindowWindow _ProcedureOwner) {}
function SendMessage(eR6MenuWidgetMessage eMessage) {}
function JoinServer(optional string _szPassword, string _szIPAddress) {}
function LaunchServer() {}
function Created() {}
function FinishCDKeyProcess() {}
function SaveGameServiceConfig() {}

defaultproperties
{
}
