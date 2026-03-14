//=============================================================================
//  eviLPatchService.uc : This class provides a script front-end to the 
//  patch service client facilities.
//
//============================================================================//
class eviLPatchService extends R6AbstractEviLPatchService
    native;

// --- Enums ---
enum ExitCause{
	EC_Unknown,
	EC_PatchStarted,
	EC_NoPatchNeeded,
	EC_FatalDownloadError,
	EC_PartialDownloadError,
	EC_UserAborted,
	EC_UserQuit
};

// --- Variables ---
var float m_bLastUpdateTime;

// --- Functions ---
static final native function GetDownloadProgress(out float totalBytes, out float totalRecvdBytes, out float fileBytes, out float fileRecvdBytes) {}
static native function PatchState GetState() {}
static final native function bool CanRunUpdateService() {}
static final native function ExitCause GetExitCause() {}
static final native function AbortPatchService() {}
static final native function StartPatch() {}

defaultproperties
{
}
