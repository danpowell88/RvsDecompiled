//=============================================================================
// StatLogFile - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Logs game events for stat collection
//
// Logs to a file.
//=============================================================================
class StatLogFile extends StatLog
    native
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

// Internal
var int LogAr;  // C++ FArchive*.
var bool bWatermark;
// Configs
var string StatLogFile;
var string StatLogFinal;

// Export UStatLogFile::execOpenLog(FFrame&, void* const)
// File Manipulation
native final function OpenLog();

// Export UStatLogFile::execCloseLog(FFrame&, void* const)
native final function CloseLog();

// Export UStatLogFile::execWatermark(FFrame&, void* const)
native final function Watermark(string EventString);

// Export UStatLogFile::execGetChecksum(FFrame&, void* const)
native final function GetChecksum(out string Checksum);

// Export UStatLogFile::execFileFlush(FFrame&, void* const)
native final function FileFlush();

// Export UStatLogFile::execFileLog(FFrame&, void* const)
native final function FileLog(string EventString);

// Logging.
function StartLog()
{
	return;
}

function StopLog()
{
	FileFlush();
	CloseLog();
	// End:0x1B
	if(bBatchLocal)
	{
		ExecuteSilentLogBatcher();
	}
	// End:0x35
	if((LocalLog != none))
	{
		LocalLog.StopLog();
	}
	return;
}

function FlushLog()
{
	FileFlush();
	// End:0x20
	if((LocalLog != none))
	{
		LocalLog.FlushLog();
	}
	return;
}

function LogEventString(string EventString)
{
	// End:0x14
	if(bWatermark)
	{
		Watermark(EventString);
	}
	FileLog(EventString);
	FileFlush();
	// End:0x44
	if((LocalLog != none))
	{
		LocalLog.LogEventString(EventString);
	}
	return;
}

function LogWorldEventString(string EventString)
{
	// End:0x14
	if(bWatermark)
	{
		Watermark(EventString);
	}
	FileLog(EventString);
	FileFlush();
	return;
}

// Return a logfile name if relevant.
event string GetLocalLogFileName()
{
	// End:0x33
	if(bWorld)
	{
		// End:0x30
		if((StatLogFile(LocalLog) != none))
		{
			return StatLogFile(LocalLog).StatLogFinal;			
		}
		else
		{
			return "";
		}
	}
	return StatLogFinal;
	return;
}

function LogPlayerConnect(Controller Player, optional string Checksum)
{
	// End:0x91
	if(bWorld)
	{
		LogEventString(((((((((((GetTimeStamp() $ Chr(9)) $ "player") $ Chr(9)) $ "Connect") $ Chr(9)) $ Player.PlayerReplicationInfo.PlayerName) $ Chr(9)) $ string(Player.PlayerReplicationInfo.PlayerID)) $ Chr(9)) $ Checksum));
		LogPlayerInfo(Player);		
	}
	else
	{
		super.LogPlayerConnect(Player, Checksum);
	}
	return;
}

function LogGameEnd(string Reason)
{
	local string Checksum;

	// End:0x5B
	if(bWorld)
	{
		bWatermark = false;
		GetChecksum(Checksum);
		LogEventString((((((((GetTimeStamp() $ Chr(9)) $ "game_end") $ Chr(9)) $ Reason) $ Chr(9)) $ Checksum) $ ""));		
	}
	else
	{
		super.LogGameEnd(Reason);
	}
	return;
}

defaultproperties
{
	StatLogFile="../Logs/unreal.ngStats.Unknown.log"
}
