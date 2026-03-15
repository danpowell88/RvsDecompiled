//=============================================================================
// eviLPatchService - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  eviLPatchService.uc : This class provides a script front-end to the 
//  patch service client facilities.
//
//============================================================================//
class eviLPatchService extends R6
    AbstractEviLPatchService
    native;

enum ExitCause
{
	EC_Unknown,                     // 0
	EC_PatchStarted,                // 1
	EC_NoPatchNeeded,               // 2
	EC_FatalDownloadError,          // 3
	EC_PartialDownloadError,        // 4
	EC_UserAborted,                 // 5
	EC_UserQuit                     // 6
};

var float m_bLastUpdateTime;

// Export UeviLPatchService::execStartPatch(FFrame&, void* const)
native(3102) static final function StartPatch();

// Export UeviLPatchService::execGetDownloadProgress(FFrame&, void* const)
native(3105) static final function GetDownloadProgress(out float totalBytes, out float totalRecvdBytes, out float fileBytes, out float fileRecvdBytes);

// Export UeviLPatchService::execAbortPatchService(FFrame&, void* const)
native(3106) static final function AbortPatchService();

// Export UeviLPatchService::execGetExitCause(FFrame&, void* const)
native(3107) static final function eviLPatchService.ExitCause GetExitCause();

// Export UeviLPatchService::execCanRunUpdateService(FFrame&, void* const)
// NEW IN 1.60
native(3109) static final function bool CanRunUpdateService();

// Export UeviLPatchService::execGetState(FFrame&, void* const)
native static function R6AbstractEviLPatchService.PatchState GetState();


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetState
// REMOVED IN 1.60: function GetExitCause
