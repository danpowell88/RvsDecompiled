//=============================================================================
//  eviLPatchService.uc : This class provides a script front-end to the 
//  patch service client facilities.
//
//============================================================================//

class eviLPatchService extends Object
	native;

enum PatchState{
	PS_Unknown,
	PS_Initializing,
	PS_DownloadVersionFile,
	PS_SelectPatch,
	PS_DownloadPatch,
	PS_Terminate,
	PS_RunPatch
};

enum ExitCause{
	EC_Unknown,
	EC_PatchStarted,
	EC_NoPatchNeeded,
	EC_FatalDownloadError,
	EC_PartialDownloadError,
	EC_UserAborted,
	EC_UserQuit
};

native(3102) final static function 				StartPatch();
native(3104) final static function PatchState 	GetState();
native(3105) final static function 				GetDownloadProgress(out float totalBytes, out float recvdBytes);
native(3106) final static function 				AbortPatchService();
native(3107) final static function ExitCause	GetExitCause();

defaultproperties
{
}
