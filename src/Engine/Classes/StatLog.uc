//=============================================================================
// Logs game events for stat collection
//
// ngLog, ngStats, and ngWorldStats are registered trademarks of 
// NetGames USA, Inc. at http://www.netgamesusa.com All rights reserved. A
// ny and all occurrences of code related to supporting their products and 
// services appears with their express permission.
//=============================================================================
class StatLog extends Info
    native;

// --- Variables ---
// used by world log when also logging to local log
var StatLog LocalLog;
// State
var bool bWorld;
// Time
var float TimeStamp;
var string LocalStandard;
// ^ NEW IN 1.60
var string WorldStandard;
// ^ NEW IN 1.60
var string LogVersion;
// ^ NEW IN 1.60
var string LogInfoURL;
// ^ NEW IN 1.60
var string GameName;
// ^ NEW IN 1.60
var string GameCreator;
// ^ NEW IN 1.60
var string GameCreatorURL;
// ^ NEW IN 1.60
var string DecoderRingURL;
// ^ NEW IN 1.60
//#ifndef R6CODE
//var() globalconfig string	    LocalBatcherURL;		// Batcher URL.
//var() globalconfig string	    LocalBatcherParams;		// Batcher command line parameters.
//var() globalconfig string	    LocalStatsURL;			// URL to local stats information.
//var() globalconfig string	    WorldBatcherURL;		// Batcher URL.
//var() globalconfig string	    WorldBatcherParams;		// Batcher command line parameters.
//var() globalconfig string	    WorldStatsURL;			// URL to world stats information.
//var() globalconfig string		LocalLogDir;
//var() globalconfig string		WorldLogDir;
//
//var globalconfig bool			bWorldBatcherError;		// An error occured last time we tried to process stats.
//var globalconfig bool			bBatchLocal;
//#else
// An error occured last time we tried to process stats.
var bool bWorldBatcherError;
var bool bBatchLocal;
// Internal
var int Context;

// --- Functions ---
// function ? LogItemActivate(...); // REMOVED IN 1.60
// function ? LogItemDeactivate(...); // REMOVED IN 1.60
// function ? LogMutator(...); // REMOVED IN 1.60
// function ? LogPickup(...); // REMOVED IN 1.60
// function ? LogTeamChange(...); // REMOVED IN 1.60
function LogPlayerConnect(Controller Player, optional string Checksum) {}
function LogGameEnd(string Reason) {}
function LogEventString(string EventString) {}
function LogWorldEventString(string EventString) {}
// Logging
function StartLog() {}
function StopLog() {}
function FlushLog() {}
final native function ExecuteSilentLogBatcher() {}
// Time
final native function string GetGMTRef() {}
// ^ NEW IN 1.60
// Return a logfile name if relevant.
event string GetLocalLogFileName() {}
// ^ NEW IN 1.60
final native function string GetMapFileName() {}
// ^ NEW IN 1.60
function LogTypingEvent(bool bTyping, Controller Other) {}
function LogPlayerDisconnect(Controller Player) {}
final event LogGameSpecial2(string SpecialID, string SpecialParam, string SpecialParam2) {}
final event LogGameSpecial(string SpecialID, string SpecialParam) {}
// Track relative timestamps.
function Tick(float Delta) {}
static native function GetPlayerChecksum(PlayerController P, out string Checksum) {}
// Special
final native function InitialCheck(GameInfo Game) {}
static native function BrowseRelativeLocalURL(string URL) {}
function GenerateLogs(bool bLogLocal, bool bLogWorld) {}
function LogServerInfo() {}
function LogMapParameters() {}
function LogNameChange(Controller Other) {}
function LogKill(PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI, string KillerWeaponName, string VictimWeaponName) {}
function LogPings() {}
function LogPlayerInfo(Controller Player) {}
// Return a timestamp relative to last absolute time.
function string GetTimeStamp() {}
// ^ NEW IN 1.60
function LogSpecialEvent(optional coerce string Arg1, optional coerce string Arg2, optional coerce string Arg3, optional coerce string Arg4, string EventType) {}
// A less verbose version...
function string GetShortAbsoluteTime() {}
// ^ NEW IN 1.60
// Return absolute time.
function string GetAbsoluteTime() {}
// ^ NEW IN 1.60
function LogGameStart() {}
// Standard Log Entries
function LogStandardInfo() {}
final native function ExecuteWorldLogBatcher() {}
static final native function BatchLocal() {}
// Batching
final native function ExecuteLocalLogBatcher() {}
function Timer() {}
function Destroyed() {}
// Object
function BeginPlay() {}

defaultproperties
{
}
