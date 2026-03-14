//=============================================================================
// R6FileManagerCampaign - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6FileManagerCampaign extends R6FileManager
    native;

// Export UR6FileManagerCampaign::execLoadCampaign(FFrame&, void* const)
//native(1003) final function R6PlayerCampaign LoadCampaign(string szFileName);
native(1003) final function bool LoadCampaign(R6PlayerCampaign MyCampaign);

// Export UR6FileManagerCampaign::execSaveCampaign(FFrame&, void* const)
native(1004) final function bool SaveCampaign(R6PlayerCampaign MyCampaign);


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: function LoadCustomMissionAvailable
// REMOVED IN 1.60: function SaveCustomMissionAvailable
