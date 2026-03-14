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
	__NFUN_280__(30.0000000, true);
	return;
}

function Destroyed()
{
	// End:0x17
	if(__NFUN_119__(LocalLog, none))
	{
		LocalLog.__NFUN_279__();
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
			LocalLog = __NFUN_278__(Class);
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
	__NFUN_231__(EventString);
	// End:0x22
	if(__NFUN_119__(LocalLog, none))
	{
		LocalLog.__NFUN_231__(EventString);
	}
	return;
}

function LogWorldEventString(string EventString)
{
	__NFUN_231__(EventString);
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
	if(__NFUN_150__(Level.Month, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Month));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Month));
	}
	// End:0xAE
	if(__NFUN_150__(Level.Day, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Day));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Day));
	}
	// End:0x10B
	if(__NFUN_150__(Level.Hour, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Hour));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Hour));
	}
	// End:0x168
	if(__NFUN_150__(Level.Minute, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Minute));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Minute));
	}
	// End:0x1C5
	if(__NFUN_150__(Level.Second, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Second));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Second));
	}
	// End:0x222
	if(__NFUN_150__(Level.Millisecond, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Millisecond));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Millisecond));
	}
	GMTRef = GetGMTRef();
	AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), GMTRef);
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
	if(__NFUN_150__(Level.Month, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Month));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Month));
	}
	// End:0xAE
	if(__NFUN_150__(Level.Day, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Day));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Day));
	}
	// End:0x10B
	if(__NFUN_150__(Level.Hour, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Hour));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Hour));
	}
	// End:0x168
	if(__NFUN_150__(Level.Minute, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Minute));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Minute));
	}
	// End:0x1C5
	if(__NFUN_150__(Level.Second, 10))
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, ".0"), string(Level.Second));		
	}
	else
	{
		AbsoluteTime = __NFUN_112__(__NFUN_112__(AbsoluteTime, "."), string(Level.Second));
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
	Time = __NFUN_128__(Time, __NFUN_146__(__NFUN_126__(Time, "."), 3));
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
	__NFUN_184__(TimeStamp, Delta);
	return;
}

// Standard Log Entries
function LogStandardInfo()
{
	// End:0x9A
	if(bWorld)
	{
		LogWorldEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Log_Standard"), __NFUN_236__(9)), WorldStandard));
		// End:0x97
		if(__NFUN_119__(LocalLog, none))
		{
			LocalLog.LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Log_Standard"), __NFUN_236__(9)), LocalStandard));
		}		
	}
	else
	{
		LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Log_Standard"), __NFUN_236__(9)), LocalStandard));
	}
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Log_Version"), __NFUN_236__(9)), LogVersion));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Log_Info_URL"), __NFUN_236__(9)), LogInfoURL));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Game_Name"), __NFUN_236__(9)), GameName));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Game_Version"), __NFUN_236__(9)), Level.EngineVersion));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Game_Creator"), __NFUN_236__(9)), GameCreator));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Game_Creator_URL"), __NFUN_236__(9)), GameCreatorURL));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Game_Decoder_Ring_URL"), __NFUN_236__(9)), DecoderRingURL));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Absolute_Time"), __NFUN_236__(9)), GetAbsoluteTime()));
	// End:0x38C
	if(bWorld)
	{
		// End:0x350
		if(__NFUN_124__(Level.ConsoleCommand("get UdpServerUplink douplink"), string(true)))
		{
			LogWorldEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_Public"), __NFUN_236__(9)), "1"));			
		}
		else
		{
			LogWorldEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_Public"), __NFUN_236__(9)), "0"));
		}
	}
	return;
}

function LogServerInfo()
{
	local string NetworkNumber;

	NetworkNumber = Level.Game.GetNetworkNumber();
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_ServerName"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.ServerName));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_AdminName"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.AdminName));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_AdminEmail"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.AdminEmail));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_Region"), __NFUN_236__(9)), string(Level.Game.GameReplicationInfo.ServerRegion)));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_MOTDLine1"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.MOTDLine1));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_MOTDLine2"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.MOTDLine2));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_MOTDLine3"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.MOTDLine3));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_MOTDLine4"), __NFUN_236__(9)), Level.Game.GameReplicationInfo.MOTDLine4));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_IP"), __NFUN_236__(9)), NetworkNumber));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "info"), __NFUN_236__(9)), "Server_Port"), __NFUN_236__(9)), string(Level.Game.GetServerPort())));
	return;
}

final event LogGameSpecial(string SpecialID, string SpecialParam)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), SpecialID), __NFUN_236__(9)), SpecialParam));
	return;
}

final event LogGameSpecial2(string SpecialID, string SpecialParam, string SpecialParam2)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "game"), __NFUN_236__(9)), SpecialID), __NFUN_236__(9)), SpecialParam), __NFUN_236__(9)), SpecialParam2));
	return;
}

// Export UStatLog::execGetMapFileName(FFrame&, void* const)
 native final function string GetMapFileName();

function LogMapParameters()
{
	local string MapName;

	MapName = GetMapFileName();
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "map"), __NFUN_236__(9)), "Name"), __NFUN_236__(9)), MapName));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "map"), __NFUN_236__(9)), "Title"), __NFUN_236__(9)), Level.Title));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "map"), __NFUN_236__(9)), "Author"), __NFUN_236__(9)), Level.Author));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "map"), __NFUN_236__(9)), "LevelEnterText"), __NFUN_236__(9)), Level.LevelEnterText));
	return;
}

function LogPlayerConnect(Controller Player, optional string Checksum)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "Connect"), __NFUN_236__(9)), Player.PlayerReplicationInfo.PlayerName), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.PlayerID)));
	LogPlayerInfo(Player);
	return;
}

function LogPlayerInfo(Controller Player)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "TeamID"), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.PlayerID)), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.TeamID)));
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "Ping"), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.PlayerID)), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.Ping)));
	return;
}

function LogPlayerDisconnect(Controller Player)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "Disconnect"), __NFUN_236__(9)), string(Player.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogKill(PlayerReplicationInfo KillerPRI, PlayerReplicationInfo VictimPRI, string KillerWeaponName, string VictimWeaponName)
{
	local string KillType;

	// End:0x0D
	if(__NFUN_114__(VictimPRI, none))
	{
		return;
	}
	// End:0x74
	if(__NFUN_114__(KillerPRI, VictimPRI))
	{
		LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "suicide"), __NFUN_236__(9)), string(KillerPRI.PlayerID)), __NFUN_236__(9)), KillerWeaponName), __NFUN_236__(9)), __NFUN_236__(9)), "None"));
		return;
	}
	KillType = "kill";
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), KillType), __NFUN_236__(9)), string(KillerPRI.PlayerID)), __NFUN_236__(9)), KillerWeaponName), __NFUN_236__(9)), string(VictimPRI.PlayerID)), __NFUN_236__(9)), VictimWeaponName), __NFUN_236__(9)));
	return;
}

function LogNameChange(Controller Other)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "Rename"), __NFUN_236__(9)), Other.PlayerReplicationInfo.PlayerName), __NFUN_236__(9)), string(Other.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogTypingEvent(bool bTyping, Controller Other)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "typing"), __NFUN_236__(9)), string(bTyping)), __NFUN_236__(9)), string(Other.PlayerReplicationInfo.PlayerID)));
	return;
}

function LogSpecialEvent(string EventType, coerce optional string Arg1, coerce optional string Arg2, coerce optional string Arg3, coerce optional string Arg4)
{
	local string Event;

	Event = EventType;
	// End:0x2F
	if(__NFUN_123__(Arg1, ""))
	{
		Event = __NFUN_112__(__NFUN_112__(Event, __NFUN_236__(9)), Arg1);
	}
	// End:0x53
	if(__NFUN_123__(Arg2, ""))
	{
		Event = __NFUN_112__(__NFUN_112__(Event, __NFUN_236__(9)), Arg2);
	}
	// End:0x77
	if(__NFUN_123__(Arg3, ""))
	{
		Event = __NFUN_112__(__NFUN_112__(Event, __NFUN_236__(9)), Arg3);
	}
	// End:0x9B
	if(__NFUN_123__(Arg4, ""))
	{
		Event = __NFUN_112__(__NFUN_112__(Event, __NFUN_236__(9)), Arg4);
	}
	LogEventString(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), Event));
	return;
}

function LogPings()
{
	local PlayerReplicationInfo PRI;

	// End:0x6B
	foreach __NFUN_313__(Class'Engine.PlayerReplicationInfo', PRI)
	{
		LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "player"), __NFUN_236__(9)), "Ping"), __NFUN_236__(9)), string(PRI.PlayerID)), __NFUN_236__(9)), string(PRI.Ping)));		
	}	
	return;
}

function LogGameStart()
{
	LogEventString(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "game_start"));
	return;
}

function LogGameEnd(string Reason)
{
	LogEventString(__NFUN_112__(__NFUN_112__(__NFUN_112__(__NFUN_112__(GetTimeStamp(), __NFUN_236__(9)), "game_end"), __NFUN_236__(9)), Reason));
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
