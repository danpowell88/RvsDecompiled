//=============================================================================
// StatLog - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Logs game events for stat collection
//
// ngLog, ngStats, and ngWorldStats are registered trademarks of 
// NetGames USA, Inc. at http://www.netgamesusa.com All rights reserved. A
// ny and all occurrences of code related to supporting their products and 
// services appears with their express permission.
//=============================================================================
class StatLog extends Info
    native
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

// Internal
var int Context;
// State
var bool bWorld;
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
var bool bWorldBatcherError;  // An error occured last time we tried to process stats.
var bool bBatchLocal;
// Time
var float TimeStamp;
var StatLog LocalLog;  // used by world log when also logging to local log
// Log Variables
var() string LocalStandard;  // The standard this log is compliant to.
var() string WorldStandard;  // The standard this log is compliant to.
var() string LogVersion;  // Version of the log standard.
var() string LogInfoURL;  // URL to info on logging standard.
var() string GameName;  // Name of this game.
var() string GameCreator;  // Name of game creator.
var() string GameCreatorURL;  // URL to info on game creator.
var() string DecoderRingURL;  // URL to log format decoder ring.

// Object
function BeginPlay()
{
	SetTimer(30.0000000, true);
	return;
}

function Destroyed()
{
	// End:0x17
	if((LocalLog != none))
	{
		LocalLog.Destroy();
	}
	return;
}

function Timer()
{
	LogPings();
	return;
}

function GenerateLogs(bool bLogLocal, bool bLogWorld)
{
	// End:0x28
	if(bLogWorld)
	{
		bWorld = true;
		// End:0x28
		if(bLogLocal)
		{
			LocalLog = Spawn(Class);
		}
	}
	return;
}

// Logging
function StartLog()
{
	return;
}

function StopLog()
{
	return;
}

function FlushLog()
{
	return;
}

function LogEventString(string EventString)
{
	Log(EventString);
	// End:0x22
	if((LocalLog != none))
	{
		LocalLog.Log(EventString);
	}
	return;
}

function LogWorldEventString(string EventString)
{
	Log(EventString);
	return;
}

// Export UStatLog::execExecuteLocalLogBatcher(FFrame&, void* const)
// Batching
native final function ExecuteLocalLogBatcher();

// Export UStatLog::execExecuteSilentLogBatcher(FFrame&, void* const)
native final function ExecuteSilentLogBatcher();

// Export UStatLog::execBatchLocal(FFrame&, void* const)
native static final function BatchLocal();

// Export UStatLog::execExecuteWorldLogBatcher(FFrame&, void* const)
native final function ExecuteWorldLogBatcher();

// Export UStatLog::execBrowseRelativeLocalURL(FFrame&, void* const)
native static function BrowseRelativeLocalURL(string URL);

// Export UStatLog::execInitialCheck(FFrame&, void* const)
// Special
native final function InitialCheck(GameInfo Game);

// Export UStatLog::execGetPlayerChecksum(FFrame&, void* const)
native static function GetPlayerChecksum(PlayerController P, out string Checksum);

// Export UStatLog::execGetGMTRef(FFrame&, void* const)
// Time
native final function string GetGMTRef();

// Return absolute time.
function string GetAbsoluteTime()
{
	local string AbsoluteTime, GMTRef;

	AbsoluteTime = string(Level.Year);
	// End:0x51
	if((Level.Month < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Month));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Month));
	}
	// End:0xAE
	if((Level.Day < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Day));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Day));
	}
	// End:0x10B
	if((Level.Hour < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Hour));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Hour));
	}
	// End:0x168
	if((Level.Minute < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Minute));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Minute));
	}
	// End:0x1C5
	if((Level.Second < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Second));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Second));
	}
	// End:0x222
	if((Level.Millisecond < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Millisecond));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Millisecond));
	}
	GMTRef = GetGMTRef();
	AbsoluteTime = ((AbsoluteTime $ ".") $ GMTRef);
	TimeStamp = 0.0000000;
	return AbsoluteTime;
	return;
}

// A less verbose version...
function string GetShortAbsoluteTime()
{
	local string AbsoluteTime;

	AbsoluteTime = string(Level.Year);
	// End:0x51
	if((Level.Month < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Month));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Month));
	}
	// End:0xAE
	if((Level.Day < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Day));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Day));
	}
	// End:0x10B
	if((Level.Hour < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Hour));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Hour));
	}
	// End:0x168
	if((Level.Minute < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Minute));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Minute));
	}
	// End:0x1C5
	if((Level.Second < 10))
	{
		AbsoluteTime = ((AbsoluteTime $ ".0") $ string(Level.Second));		
	}
	else
	{
		AbsoluteTime = ((AbsoluteTime $ ".") $ string(Level.Second));
	}
	TimeStamp = 0.0000000;
	return AbsoluteTime;
	return;
}

// Return a timestamp relative to last absolute time.
function string GetTimeStamp()
{
	local string Time;
	local int pos;

	Time = string(TimeStamp);
	Time = Left(Time, (InStr(Time, ".") + 3));
	return Time;
	return;
}

// Return a logfile name if relevant.
event string GetLocalLogFileName()
{
	return "";
	return;
}

// Track relative timestamps.
function Tick(float Delta)
{
	(TimeStamp += Delta);
	return;
}

// Standard Log Entries
function LogStandardInfo()
{
	// End:0x9A
	if(bWorld)
	{
		LogWorldEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Log_Standard") $ Chr(9)) $ WorldStandard));
		// End:0x97
		if((LocalLog != none))
		{
			LocalLog.LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Log_Standard") $ Chr(9)) $ LocalStandard));
		}		
	}
	else
	{
		LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Log_Standard") $ Chr(9)) $ LocalStandard));
	}
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Log_Version") $ Chr(9)) $ LogVersion));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Log_Info_URL") $ Chr(9)) $ LogInfoURL));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Game_Name") $ Chr(9)) $ GameName));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Game_Version") $ Chr(9)) $ Level.EngineVersion));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Game_Creator") $ Chr(9)) $ GameCreator));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Game_Creator_URL") $ Chr(9)) $ GameCreatorURL));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Game_Decoder_Ring_URL") $ Chr(9)) $ DecoderRingURL));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Absolute_Time") $ Chr(9)) $ GetAbsoluteTime()));
	// End:0x38C
	if(bWorld)
	{
		// End:0x350
		if((Level.ConsoleCommand("get UdpServerUplink douplink") ~= string(true)))
		{
			LogWorldEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_Public") $ Chr(9)) $ "1"));			
		}
		else
		{
			LogWorldEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_Public") $ Chr(9)) $ "0"));
		}
	}
	return;
}

function LogServerInfo()
{
	local string NetworkNumber;

	NetworkNumber = Level.Game.GetNetworkNumber();
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_ServerName") $ Chr(9)) $ Level.Game.GameReplicationInfo.ServerName));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_AdminName") $ Chr(9)) $ Level.Game.GameReplicationInfo.AdminName));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_AdminEmail") $ Chr(9)) $ Level.Game.GameReplicationInfo.AdminEmail));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_Region") $ Chr(9)) $ string(Level.Game.GameReplicationInfo.ServerRegion)));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_MOTDLine1") $ Chr(9)) $ Level.Game.GameReplicationInfo.MOTDLine1));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_MOTDLine2") $ Chr(9)) $ Level.Game.GameReplicationInfo.MOTDLine2));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_MOTDLine3") $ Chr(9)) $ Level.Game.GameReplicationInfo.MOTDLine3));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_MOTDLine4") $ Chr(9)) $ Level.Game.GameReplicationInfo.MOTDLine4));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_IP") $ Chr(9)) $ NetworkNumber));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "info") $ Chr(9)) $ "Server_Port") $ Chr(9)) $ string(Level.Game.GetServerPort())));
	return;
}

final event LogGameSpecial(string SpecialID, string SpecialParam)
{
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ SpecialID) $ Chr(9)) $ SpecialParam));
	return;
}

final event LogGameSpecial2(string SpecialID, string SpecialParam, string SpecialParam2)
{
	LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "game") $ Chr(9)) $ SpecialID) $ Chr(9)) $ SpecialParam) $ Chr(9)) $ SpecialParam2));
	return;
}

// Export UStatLog::execGetMapFileName(FFrame&, void* const)
native final function string GetMapFileName();

function LogMapParameters()
{
	local string MapName;

	MapName = GetMapFileName();
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "map") $ Chr(9)) $ "Name") $ Chr(9)) $ MapName));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "map") $ Chr(9)) $ "Title") $ Chr(9)) $ Level.Title));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "map") $ Chr(9)) $ "Author") $ Chr(9)) $ Level.Author));
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "map") $ Chr(9)) $ "LevelEnterText") $ Chr(9)) $ Level.LevelEnterText));
	return;
}

function LogPlayerConnect(Controller Player, optional string Checksum)
{
	LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Connect") $ Chr(9)) $ Player.PlayerReplicationInfo.PlayerName) $ Chr(9)) $ string(Player.PlayerReplicationInfo.PlayerID)));
	LogPlayerInfo(Player);
	return;
}

function LogPlayerInfo(Controller Player)
{
	LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "TeamID") $ Chr(9)) $ string(Player.PlayerReplicationInfo.PlayerID)) $ Chr(9)) $ string(Player.PlayerReplicationInfo.TeamID)));
	LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Ping") $ Chr(9)) $ string(Player.PlayerReplicationInfo.PlayerID)) $ Chr(9)) $ string(Player.PlayerReplicationInfo.Ping)));
	return;
}

function LogPlayerDisconnect(Controller Player)
{
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Disconnect") $ Chr(9)) $ string(Player.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogKill(PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI, string KillerWeaponName, string VictimWeaponName)
{
	local string KillType;

	// End:0x0D
	if((VictimPRI == none))
	{
		return;
	}
	// End:0x74
	if((KillerPRI == VictimPRI))
	{
		LogEventString((((((((((GetTimeStamp() $ Chr(9)) $ "suicide") $ Chr(9)) $ string(KillerPRI.PlayerID)) $ Chr(9)) $ KillerWeaponName) $ Chr(9)) $ Chr(9)) $ "None"));
		return;
	}
	KillType = "kill";
	LogEventString((((((((((((GetTimeStamp() $ Chr(9)) $ KillType) $ Chr(9)) $ string(KillerPRI.PlayerID)) $ Chr(9)) $ KillerWeaponName) $ Chr(9)) $ string(VictimPRI.PlayerID)) $ Chr(9)) $ VictimWeaponName) $ Chr(9)));
	return;
}

function LogNameChange(Controller Other)
{
	LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Rename") $ Chr(9)) $ Other.PlayerReplicationInfo.PlayerName) $ Chr(9)) $ string(Other.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogTypingEvent(bool bTyping, Controller Other)
{
	LogEventString(((((((GetTimeStamp() $ Chr(9)) $ "typing") $ Chr(9)) $ string(bTyping)) $ Chr(9)) $ string(Other.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogSpecialEvent(string EventType, coerce optional string Arg1, coerce optional string Arg2, coerce optional string Arg3, coerce optional string Arg4)
{
	local string Event;

	Event = EventType;
	// End:0x2F
	if((Arg1 != ""))
	{
		Event = ((Event $ Chr(9)) $ Arg1);
	}
	// End:0x53
	if((Arg2 != ""))
	{
		Event = ((Event $ Chr(9)) $ Arg2);
	}
	// End:0x77
	if((Arg3 != ""))
	{
		Event = ((Event $ Chr(9)) $ Arg3);
	}
	// End:0x9B
	if((Arg4 != ""))
	{
		Event = ((Event $ Chr(9)) $ Arg4);
	}
	LogEventString(((GetTimeStamp() $ Chr(9)) $ Event));
	return;
}

function LogPings()
{
	local PlayerReplicationInfo PRI;

	// End:0x6B
	foreach DynamicActors(Class'Engine.PlayerReplicationInfo', PRI)
	{
		LogEventString(((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Ping") $ Chr(9)) $ string(PRI.PlayerID)) $ Chr(9)) $ string(PRI.Ping)));		
	}	
	return;
}

function LogGameStart()
{
	LogEventString(((GetTimeStamp() $ Chr(9)) $ "game_start"));
	return;
}

function LogGameEnd(string Reason)
{
	LogEventString(((((GetTimeStamp() $ Chr(9)) $ "game_end") $ Chr(9)) $ Reason));
	return;
}

defaultproperties
{
	LocalStandard="ngLog"
	WorldStandard="ngLog"
	LogVersion="1.2"
	LogInfoURL="http://www.netgamesusa.com/ngLog/"
	GameName="Unreal"
	GameCreator="Epic MegaGames, Inc."
	GameCreatorURL="http://www.epicgames.com/"
	DecoderRingURL="http://unreal.epicgames.com/Unreal_Log_Decoder_Ring.html"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function LogMutator
// REMOVED IN 1.60: function LogTeamChange
// REMOVED IN 1.60: function LogPickup
// REMOVED IN 1.60: function LogItemActivate
// REMOVED IN 1.60: function LogItemDeactivate
