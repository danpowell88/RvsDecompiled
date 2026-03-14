//=============================================================================
// Logs game events for stat collection
//
// Logs to a file.
//=============================================================================
class StatLogFile extends StatLog
    native;

// --- Variables ---
var bool bWatermark;
var string StatLogFinal;
// Configs
var string StatLogFile;
// Internal
// C++ FArchive*.
var int LogAr;

// --- Functions ---
final native function FileFlush() {}
final native function Watermark(string EventString) {}
final native function FileLog(string EventString) {}
final native function CloseLog() {}
final native function GetChecksum(out string Checksum) {}
function LogWorldEventString(string EventString) {}
function LogGameEnd(string Reason) {}
function LogEventString(string EventString) {}
function LogPlayerConnect(Controller Player, optional string Checksum) {}
// Return a logfile name if relevant.
event string GetLocalLogFileName() {}
// ^ NEW IN 1.60
function FlushLog() {}
function StopLog() {}
// Logging.
function StartLog() {}
// File Manipulation
final native function OpenLog() {}

defaultproperties
{
}
