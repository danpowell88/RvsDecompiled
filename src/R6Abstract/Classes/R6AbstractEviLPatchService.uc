//=============================================================================
// R6AbstractEviLPatchService - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//================================================================================
// R6AbstractEviLPatchService.
//================================================================================
class R6AbstractEviLPatchService extends Object
 native;

enum PatchState
{
	PS_Unknown,                     // 0
	PS_Initializing,                // 1
	PS_DownloadVersionFile,         // 2
	PS_SelectPatch,                 // 3
	PS_DownloadPatch,               // 4
	PS_Terminate,                   // 5
	PS_RunPatch                     // 6
};

// Export UR6AbstractEviLPatchService::execGetState(FFrame&, void* const)
 native static function R6AbstractEviLPatchService.PatchState GetState();


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function GetState
