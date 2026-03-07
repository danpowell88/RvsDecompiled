// SNDDSound3D.cpp - DARE Sound Engine DirectSound3D backend stubs
// Auto-generated stubs for SNDDSound3DDLL_ret.dll and SNDDSound3DDLL_VSR.dll
// All functions defined here; .def files control which are exported per variant.
//
// DARE (Digital Audio Rendering Engine) is third-party audio middleware by
// Ubi Soft Montreal's audio team. This module provides the DirectSound3D
// backend implementation with EAX support.

#pragma warning(disable: 4100) // unreferenced formal parameter

#include <windows.h>

// DARE HRTF type enum (for C++ mangled export)
enum _SND_tdeHTRFType { SND_HRTF_NONE = 0 };

// =============================================================================
// Data exports
// =============================================================================

extern "C" {
__declspec(dllexport) void* functions = 0;
__declspec(dllexport) void* liste_of_association = 0;
__declspec(dllexport) void* liste_of_voices = 0;
__declspec(dllexport) void* names = 0;
}

// =============================================================================
// C++ exports (name-mangled)
// =============================================================================

// ?SND_fn_vDisableHardwareAcceleration@@YAXH@Z
void SND_fn_vDisableHardwareAcceleration(int bDisable) {}

// ?SND_fn_vSetHRTFOption@@YAXW4_SND_tdeHTRFType@@@Z
void SND_fn_vSetHRTFOption(_SND_tdeHTRFType eType) {}

// =============================================================================
// __stdcall exports (decorated _Name@N)
// =============================================================================

extern "C" {

int __stdcall SND_Is_SSE_Supported(void) { return 0; }
int __stdcall SND_fn_bCanFreeSubBlockDataSxd(int p0) { return 0; }
int __stdcall SND_fn_bDesInitDataLoadSnd(void) { return 0; }
int __stdcall SND_fn_bEnableEAXSxd(int p0) { return 0; }
int __stdcall SND_fn_bEnterCriticalSectionForDriverThreadSnd(void) { return 0; }
int __stdcall SND_fn_bFileNameExist(int p0) { return 0; }
int __stdcall SND_fn_bGetAllEventsId(int p0, int p1) { return 0; }
int __stdcall SND_fn_bGetMasterDirectory(int p0, int p1) { return 0; }
int __stdcall SND_fn_bGetOnePartialDirectory(int p0, int p1, int p2) { return 0; }
int __stdcall SND_fn_bGetOptions(int p0, int p1, int p2, int p3) { return 0; }
int __stdcall SND_fn_bGetSoundEventNameFromEditorId(int p0, int p1, int p2) { return 0; }
int __stdcall SND_fn_bGetStereoSxd(void) { return 0; }
int __stdcall SND_fn_bInitDataLoadSnd(int p0) { return 0; }
int __stdcall SND_fn_bIsDataDirectory(int p0) { return 0; }
int __stdcall SND_fn_bIsEAXCompatibleSxd(void) { return 0; }
int __stdcall SND_fn_bIsProjectLocalised(void) { return 0; }
int __stdcall SND_fn_bIsResourceLoopingSxd(int p0) { return 0; }
int __stdcall SND_fn_bIsResourceStreamedSxd(int p0) { return 0; }
int __stdcall SND_fn_bIsScriptModeUsed(void) { return 0; }
int __stdcall SND_fn_bLoadBank(int p0) { return 0; }
int __stdcall SND_fn_bLoadBankSet(int p0) { return 0; } // VSR only
int __stdcall SND_fn_bLoadDataInMem(int p0, int p1, int p2, int p3) { return 0; }
int __stdcall SND_fn_bLoadMap(int p0) { return 0; }
int __stdcall SND_fn_bLoadResBinarySxd(int p0, int p1, int p2, int p3) { return 0; }
int __stdcall SND_fn_bLoadResScriptSxd(int p0, int p1) { return 0; }
int __stdcall SND_fn_bLoadSubMap(int p0) { return 0; }
int __stdcall SND_fn_bSetNextTransitionSxd(int p0, int p1) { return 0; }
int __stdcall SND_fn_bSetParamSxd(int p0, int p1, int p2) { return 0; }
int __stdcall SND_fn_bSetParamTransitionSxd(int p0, int p1) { return 0; }
int __stdcall SND_fn_bSetResourceStaticVolumeSxd(int p0, int p1) { return 0; }
int __stdcall SND_fn_bSetSlowMotionFactorSxd(int p0) { return 0; }
int __stdcall SND_fn_bStartFadeSxd(int p0, int p1, int p2, int p3, int p4, int p5) { return 0; }
int __stdcall SND_fn_bTestIsPlayingSxd(int p0) { return 0; }
int __stdcall SND_fn_bTestIsPlayingTransitionSxd(int p0) { return 0; }
int __stdcall SND_fn_bTestSnd_MMX(void) { return 0; }
int __stdcall SND_fn_bTestSnd_Pentium(void) { return 0; }
int __stdcall SND_fn_bTestSnd_Win32(void) { return 0; }
int __stdcall SND_fn_bTestSnd_WinMM(int p0) { return 0; }
int __stdcall SND_fn_bTestSnd_WinNT4(void) { return 0; }
int __stdcall SND_fn_bTryToEnterCriticalSectionThreadSnd(void) { return 0; }
int __stdcall SND_fn_bUnLoadBank(int p0) { return 0; }
int __stdcall SND_fn_bUnLoadBankSet(int p0) { return 0; } // VSR only
const char* __stdcall SND_fn_czGetEvtGrpByNameTableName(int p0) { return 0; } // VSR only
int __stdcall SND_fn_eGetDataProjectLoadMode(void) { return 0; }
int __stdcall SND_fn_eGetMainFormatSxd(void) { return 0; }
int __stdcall SND_fn_eGetProjectDataLoadMode(void) { return 0; }
int __stdcall SND_fn_eInitSxd(int p0) { return 0; }
void* __stdcall SND_fn_hGetHanldeThreadSnd(void) { return 0; }
void* __stdcall SND_fn_hGetSoundEventHandleFromEditorId(int p0) { return 0; }
void* __stdcall SND_fn_hGetSoundEventHandleFromSectionName(int p0) { return 0; }
int __stdcall SND_fn_iGetEvtGrpByNameTableSize(void) { return 0; } // VSR only
int __stdcall SND_fn_iIsEvtGrpLoaded(int p0) { return 0; } // VSR only
long __stdcall SND_fn_lCreateBufferSxd(int p0, int p1, int p2, int p3) { return 0; }
long __stdcall SND_fn_lCreateMicroSxd(int p0) { return 0; }
long __stdcall SND_fn_lCreateTimer(void) { return 0; }
long __stdcall SND_fn_lGenerateSndTocKey(int p0) { return 0; }
long __stdcall SND_fn_lGetEventGroupIdFromFileTitle(int p0) { return 0; } // VSR only
long __stdcall SND_fn_lGetNbVoiceWishedSxd(void) { return 0; }
long __stdcall SND_fn_lGetSifTypeCount(void) { return 0; }
long __stdcall SND_fn_lGetSifTypeId(int p0) { return 0; }
long __stdcall SND_fn_lGetSifTypeIdArray(int p0, int p1) { return 0; }
long __stdcall SND_fn_lGetSifTypeName(int p0, int p1, int p2) { return 0; }
long __stdcall SND_fn_lGetSifValueCount(int p0) { return 0; }
long __stdcall SND_fn_lGetSifValueId(int p0, int p1) { return 0; }
long __stdcall SND_fn_lGetSifValueIdArray(int p0, int p1, int p2) { return 0; }
long __stdcall SND_fn_lGetSifValueName(int p0, int p1, int p2, int p3) { return 0; }
long __stdcall SND_fn_lPlaySxd(int p0, int p1, int p2, int p3, int p4) { return 0; }
long __stdcall SND_fn_lPlayTransitionExSxd(int p0, int p1, int p2, int p3, int p4, int p5) { return 0; }
long __stdcall SND_fn_lQueueDataBufferSxd(int p0, int p1, int p2) { return 0; }
long __stdcall SND_fn_lQueueResetBufferSxd(int p0) { return 0; }
long __stdcall SND_fn_lStrLwr(int p0) { return 0; }
long __stdcall SND_fn_lStriCmp(int p0, int p1) { return 0; }
void* __stdcall SND_fn_pGetBinEvent(int p0) { return 0; }
void* __stdcall SND_fn_pGetBinRes(int p0) { return 0; }
void* __stdcall SND_fn_pstGetResFromEdIdSnd(int p0) { return 0; }
float __stdcall SND_fn_rAbsRealSnd(int p0) { return 0.0f; }
float __stdcall SND_fn_rDistanceToVolume(int p0) { return 0.0f; }
float __stdcall SND_fn_rDistanceToVolumeEx(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rDivRealRealQuickSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rDivRealRealSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rDopplerPitch(int p0, int p1, int p2, int p3) { return 0.0f; }
float __stdcall SND_fn_rGetCurrentTime(int p0) { return 0.0f; }
float __stdcall SND_fn_rGetDopplerFactor(void) { return 0.0f; }
float __stdcall SND_fn_rGetLengthSxd(int p0) { return 0.0f; }
float __stdcall SND_fn_rGetNormeSxd(int p0) { return 0.0f; }
float __stdcall SND_fn_rGetPosBufferSxd(int p0) { return 0.0f; }
float __stdcall SND_fn_rGetPosSxd(int p0) { return 0.0f; }
float __stdcall SND_fn_rGetPosTransitionSxd(int p0) { return 0.0f; }
float __stdcall SND_fn_rMulRealRealQuickSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rMulRealRealSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rNormeVectorSnd(int p0) { return 0.0f; }
float __stdcall SND_fn_rPseudoNormeRealSnd(int p0, int p1, int p2) { return 0.0f; }
float __stdcall SND_fn_rPseudoNormeVectorSnd(int p0) { return 0.0f; }
float __stdcall SND_fn_rPseudoScalaireNormeVectorSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rScalaireVectorSnd(int p0, int p1) { return 0.0f; }
float __stdcall SND_fn_rSqrtRealSnd(int p0) { return 0.0f; }
float __stdcall SND_fn_rtSndRealToSndRealTwin(int p0, int p1) { return 0.0f; }
const char* __stdcall SND_fn_szGetCurrentLangDirectory(void) { return 0; }
const char* __stdcall SND_fn_szGetSoftDirectory(void) { return 0; }
unsigned char __stdcall SND_fn_ucPositionToDolby(int p0, int p1, int p2) { return 0; }
unsigned char __stdcall SND_fn_ucPositionToPan(int p0, int p1, int p2, int p3) { return 0; }
unsigned long __stdcall SND_fn_ulGetEditorIdFromSoundEventName(int p0) { return 0; }
unsigned long __stdcall SND_fn_ulGetListOfSoundEventGroupName(int p0, int p1) { return 0; }
unsigned long __stdcall SND_fn_ulGetListOfSoundEventNameInGroup(int p0, int p1, int p2) { return 0; }
unsigned long __stdcall SND_fn_ulGetNbHWVoiceSxd(int p0) { return 0; }
unsigned long __stdcall SND_fn_ulGetNumberOfEvents(void) { return 0; }
unsigned long __stdcall SND_fn_ulGetNumberOfPartialDirectory(void) { return 0; }
unsigned long __stdcall SND_fn_ulGetNumberOfSoundEventGroup(void) { return 0; }
unsigned long __stdcall SND_fn_ulGetNumberOfSoundEventInGroup(int p0) { return 0; }
unsigned short __stdcall SND_fn_uwGetResourceNbChannelSxd(int p0) { return 0; }
void __stdcall SND_fn_vAddPartialDirectory(int p0) { }
void __stdcall SND_fn_vAnalyzeScriptFile(int p0) { }
void __stdcall SND_fn_vConvertResDiskToMemSxd(int p0, int p1, int p2) { }
void __stdcall SND_fn_vDeleteBufferSxd(int p0) { }
void __stdcall SND_fn_vDesInitSxd(void) { }
void __stdcall SND_fn_vDesInitThreadSnd(void) { }
void __stdcall SND_fn_vDestroyMicroSxd(int p0) { }
void __stdcall SND_fn_vDestroyTimer(int p0) { }
void __stdcall SND_fn_vDisableEventLogGeneration(void) { }
void __stdcall SND_fn_vEnableEventLogGeneration(int p0) { }
void __stdcall SND_fn_vEnterCriticalSectionForErrorDisplay(void) { }
void __stdcall SND_fn_vEnterCriticalSectionThreadSnd_(void) { }
void __stdcall SND_fn_vFlushQueueBuffersSxd(int p0) { }
void __stdcall SND_fn_vGetDefaultRollOff(int p0) { }
void __stdcall SND_fn_vGetHModuleDbg(void) { }
void __stdcall SND_fn_vInitCallbacks(void) { } // VSR only
void __stdcall SND_fn_vInitThreadSnd(void) { }
void __stdcall SND_fn_vMouchardThreadsnd(int p0, int p1) { }
void __stdcall SND_fn_vParam3Dto2D(int p0, int p1) { }
void __stdcall SND_fn_vPauseBufferSxd(int p0) { }
void __stdcall SND_fn_vPauseSxd(int p0) { }
void __stdcall SND_fn_vPauseTimer(int p0) { }
void __stdcall SND_fn_vPauseTransitionSxd(int p0) { }
void __stdcall SND_fn_vProduitVectorSnd(int p0, int p1, int p2) { }
void __stdcall SND_fn_vPurgeAllDirectories(void) { }
void __stdcall SND_fn_vQuitCriticalSectionForErrorDisplay(void) { }
void __stdcall SND_fn_vQuitCriticalSectionThreadSnd(void) { }
void __stdcall SND_fn_vRegisterAnlCallback(int p0, int p1, int p2) { }
void __stdcall SND_fn_vReleaseDriverSxd(void) { }
void __stdcall SND_fn_vReloadDataSnd(int p0) { } // VSR only
void __stdcall SND_fn_vRemovePartialDirectory(int p0) { }
void __stdcall SND_fn_vResetTimer(int p0) { }
void __stdcall SND_fn_vResolveFileName(int p0, int p1, int p2) { }
void __stdcall SND_fn_vRestoreDriverSxd(void) { }
void __stdcall SND_fn_vResumeBufferSxd(int p0) { }
void __stdcall SND_fn_vResumeSxd(int p0) { }
void __stdcall SND_fn_vResumeTimer(int p0) { }
void __stdcall SND_fn_vResumeTransitionSxd(int p0) { }
void __stdcall SND_fn_vSetCurrentLangDirectory(int p0) { }
void __stdcall SND_fn_vSetCurrentLanguage(int p0) { }
void __stdcall SND_fn_vSetDefaultRollOff(int p0) { }
void __stdcall SND_fn_vSetDefaultRollOffSxd(int p0) { }
void __stdcall SND_fn_vSetDopplerFactor(int p0) { }
void __stdcall SND_fn_vSetDopplerFactorSxd(int p0) { }
void __stdcall SND_fn_vSetEffectSxd(int p0) { }
void __stdcall SND_fn_vSetMasterDirectory(int p0) { }
void __stdcall SND_fn_vSetMicroParamSxd(int p0, int p1) { }
void __stdcall SND_fn_vSetNbVoiceWishedSxd(int p0, int p1) { }
void __stdcall SND_fn_vSetOptions(int p0, int p1, int p2) { }
void __stdcall SND_fn_vSetParamBufferSxd(int p0, int p1) { }
void __stdcall SND_fn_vSetPosSxd(int p0, int p1) { }
void __stdcall SND_fn_vSetRefreshFunc(int p0) { } // VSR only
void __stdcall SND_fn_vSetSoftDirectory(int p0) { }
void __stdcall SND_fn_vSetStereoSxd(int p0) { }
void __stdcall SND_fn_vSndRealTwinToSndReal(int p0, int p1, int p2) { }
void __stdcall SND_fn_vStartIndexFadeSxd(int p0, int p1, int p2, int p3, int p4) { }
void __stdcall SND_fn_vStopBeforeUnLoadResSnd(int p0) { }
void __stdcall SND_fn_vStopSxd(int p0) { }
void __stdcall SND_fn_vStopTransitionSxd(int p0) { }
void __stdcall SND_fn_vStrncpy(int p0, int p1, int p2) { }
void __stdcall SND_fn_vSynchroSxd(void) { }
void __stdcall SND_fn_vSynchroTimer(void) { }
void __stdcall SND_fn_vUnLoadResSnd(int p0) { }
void __stdcall SND_fn_vUnLoadResSxd(int p0) { }
void __stdcall SND_fn_vVolPanToVolLR(int p0, int p1, int p2, int p3, int p4) { }
void __stdcall SND_fn_vWaitForValueThreadSnd(int p0, int p1) { }
int __stdcall dbgSND_fn_bAddEventToEngineTable(int p0) { return 0; } // VSR only
int __stdcall dbgSND_fn_bAddResToEngineTable(int p0) { return 0; } // VSR only
int __stdcall dbgSND_fn_bLoadResScriptSnd(int p0, int p1) { return 0; } // VSR only
int __stdcall dbgSND_fn_bSetResourceStaticVolume(int p0, int p1) { return 0; } // VSR only
const char* __stdcall dbgSND_fn_czGetProjectTitle(void) { return 0; } // VSR only
long __stdcall dbgSND_fn_lGetLoadedBanks(int p0, int p1) { return 0; } // VSR only
long __stdcall dbgSND_fn_lGetNumberOfBanks(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateCoordinateM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateEffectGraphM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateEventM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateMultiLayerElementM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateRandomElementM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateResM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateSequenceElementM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateSwitchElementM(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateThemePart(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pCreateThemePartOutro(void) { return 0; } // VSR only
void* __stdcall dbgSND_fn_pGetThemeInfos(int p0) { return 0; } // VSR only
float __stdcall dbgSND_fn_rGetDopplerFactor(void) { return 0.0f; } // VSR only
void __stdcall dbgSND_fn_vAddEventInTSNEditor(int p0, int p1, int p2) { } // VSR only
void __stdcall dbgSND_fn_vDestroyEventM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroyMultiLayerElementM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroyRandomElementM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroyResM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroySequenceElementM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroySwitchElementM(int p0) { } // VSR only
void __stdcall dbgSND_fn_vDestroyThemePart(int p0) { } // VSR only
void __stdcall dbgSND_fn_vGetAudioFrameBufferSize(int p0, int p1) { } // VSR only
void __stdcall dbgSND_fn_vGetInfoForObjectSound(int p0, int p1, int p2, int p3) { } // VSR only
void __stdcall dbgSND_fn_vKillAllObjectTypeSound(void) { } // VSR only
void __stdcall dbgSND_fn_vSendRequestSound(int p0) { } // VSR only

} // extern "C"

// =============================================================================
// __cdecl exports (undecorated names)
// =============================================================================

extern "C" {

int SND_fn_bAreWavPresent() { return 0; }
int SND_fn_bEnableEAX() { return 0; }
int SND_fn_bGetStereoSound() { return 0; }
int SND_fn_bIsEAXCompatible() { return 0; }
int SND_fn_bIsSoundRequestPlaying() { return 0; }
int SND_fn_bLoadResScriptSnd() { return 0; } // VSR only
int SND_fn_bSetSlowMotionFactor() { return 0; }
const char* SND_fn_czGetProjectTitle() { return 0; } // VSR only
int SND_fn_eInitSound() { return 0; }
float SND_fn_fGetLengthSoundEvent() { return 0.0f; }
float SND_fn_fGetLengthSoundRequest() { return 0.0f; }
float SND_fn_fGetPosClientBuffer() { return 0.0f; }
float SND_fn_fGetPosSoundRequest() { return 0.0f; }
float SND_fn_fGetSoundVolumeLine() { return 0.0f; }
float SND_fn_fGetVolumeMTTChannelTrack() { return 0.0f; }
float SND_fn_fGetVolumeSoundObject() { return 0.0f; }
float SND_fn_fGetVolumeSoundObjectType() { return 0.0f; }
void* SND_fn_hGenerateSoundEventPlay() { return 0; }
void* SND_fn_hGenerateSoundEventPlayStream() { return 0; }
void* SND_fn_hGenerateSoundEventStop() { return 0; }
void* SND_fn_hGetLastSoundEventOfSoundObjectType() { return 0; }
long SND_fn_lAddSoundObjectType() { return 0; }
long SND_fn_lAddSoundVolumeLine() { return 0; }
long SND_fn_lCreateClientBuffer() { return 0; }
long SND_fn_lCreateSoundMicro() { return 0; }
long SND_fn_lFlushQueueClientBuffer() { return 0; }
long SND_fn_lGetLatestPlayingSoundRequest() { return 0; }
long SND_fn_lGetMTTChannelIdFromMTTChannelName() { return 0; }
long SND_fn_lGetNbVoiceWishedSound() { return 0; }
long SND_fn_lQueueDataClientBuffer() { return 0; }
long SND_fn_lQueueResetClientBuffer() { return 0; }
long SND_fn_lSendSoundRequest() { return 0; }
long SND_fn_lSendSoundRequestOnChannel() { return 0; }
long SND_fn_lSendSoundRequestOnChannelWithFadeIn() { return 0; }
long SND_fn_lSendSoundRequestWithFadeIn() { return 0; }
void* SND_fn_pCreateCoordinateM() { return 0; } // VSR only
void* SND_fn_pCreateEffectGraphListM() { return 0; } // VSR only
void* SND_fn_pCreateEffectGraphM() { return 0; } // VSR only
void* SND_fn_pCreateEventM() { return 0; } // VSR only
void* SND_fn_pCreateMultiLayerElementListM() { return 0; } // VSR only
void* SND_fn_pCreateMultiLayerElementM() { return 0; } // VSR only
void* SND_fn_pCreateMultiTrackElementM() { return 0; } // VSR only
void* SND_fn_pCreateRandomElementM() { return 0; } // VSR only
void* SND_fn_pCreateResM() { return 0; } // VSR only
void* SND_fn_pCreateSequenceElement() { return 0; } // VSR only
void* SND_fn_pCreateSwitchElementM() { return 0; } // VSR only
void* SND_fn_pCreateThemePart() { return 0; } // VSR only
void* SND_fn_pCreateThemePartOutro() { return 0; } // VSR only
void* SND_fn_pvGetDirectSound8Object() { return 0; }
unsigned long SND_fn_ulGetEditorIdFromSoundEventHandle() { return 0; }
void SND_fn_vChangeVolumeAllSoundObjectTypes() { }
void SND_fn_vChangeVolumeAllSoundObjectTypesButOne() { }
void SND_fn_vChangeVolumeAllSoundObjects() { }
void SND_fn_vChangeVolumeAllSoundObjectsButOne() { }
void SND_fn_vChangeVolumeMTTChannelTrack() { }
void SND_fn_vChangeVolumeSoundObject() { }
void SND_fn_vChangeVolumeSoundObjectType() { }
void SND_fn_vCopyCoordinateM() { } // VSR only
void SND_fn_vCopyEffectGraphM() { } // VSR only
void SND_fn_vCopyEventM() { } // VSR only
void SND_fn_vCopyMultiLayerElementM() { } // VSR only
void SND_fn_vCopyMultiTrackElementM() { } // VSR only
void SND_fn_vCopyRandomElementM() { } // VSR only
void SND_fn_vCopyResM() { } // VSR only
void SND_fn_vCopySequenceElement() { } // VSR only
void SND_fn_vCopySwitchElementM() { } // VSR only
void SND_fn_vCopyThemePart() { } // VSR only
void SND_fn_vCopyThemePartOutro() { } // VSR only
void SND_fn_vDesInitSound() { }
void SND_fn_vDestroyAllSoundMicros() { }
void SND_fn_vDestroyClientBuffer() { }
void SND_fn_vDestroyCoordinateM() { } // VSR only
void SND_fn_vDestroyEffectGraphM() { } // VSR only
void SND_fn_vDestroyEventM() { } // VSR only
void SND_fn_vDestroyMultiLayerElementM() { } // VSR only
void SND_fn_vDestroyMultiTrackElementM() { } // VSR only
void SND_fn_vDestroyRandomElementM() { } // VSR only
void SND_fn_vDestroyResM() { } // VSR only
void SND_fn_vDestroySequenceElement() { } // VSR only
void SND_fn_vDestroySoundEvent() { }
void SND_fn_vDestroySoundMicro() { }
void SND_fn_vDestroySwitchElementM() { } // VSR only
void SND_fn_vDestroyThemePart() { } // VSR only
void SND_fn_vDestroyThemePartOutro() { } // VSR only
void SND_fn_vExternalInitScriptSound() { }
void SND_fn_vGetSoundEngineVersion() { }
void SND_fn_vGetSoundObjectInfo() { }
void SND_fn_vKillAllSoundObjectTypes() { }
void SND_fn_vKillAllSoundObjectTypesButOne() { }
void SND_fn_vKillAllSoundObjectTypesButOneWithFade() { }
void SND_fn_vKillAllSoundObjectTypesWithFade() { }
void SND_fn_vKillAllSoundObjects() { }
void SND_fn_vKillAllSoundObjectsWithFade() { }
void SND_fn_vKillSoundChannel() { }
void SND_fn_vKillSoundObject() { }
void SND_fn_vKillSoundObjectWithFade() { }
void SND_fn_vPauseAllSoundObjectTypes() { }
void SND_fn_vPauseAllSoundObjectTypesButOne() { }
void SND_fn_vPauseClientBuffer() { }
void SND_fn_vPauseSoundObject() { }
void SND_fn_vPauseSoundObjectType() { }
void SND_fn_vReleaseSoundDriver() { }
void SND_fn_vResetVolumeAllSoundObjectTypes() { }
void SND_fn_vResetVolumeAllSoundObjectTypesButOne() { }
void SND_fn_vResetVolumeAllSoundObjects() { }
void SND_fn_vResetVolumeAllSoundObjectsButOne() { }
void SND_fn_vResetVolumeSoundObject() { }
void SND_fn_vResetVolumeSoundObjectType() { }
void SND_fn_vRestoreSoundDriver() { }
void SND_fn_vResumeAllSoundObjectTypes() { }
void SND_fn_vResumeAllSoundObjectTypesButOne() { }
void SND_fn_vResumeClientBuffer() { }
void SND_fn_vResumeSoundObject() { }
void SND_fn_vResumeSoundObjectType() { }
void SND_fn_vSetDefaultSoundRollOff() { }
void SND_fn_vSetNbVoiceWishedSound() { }
void SND_fn_vSetParamClientBuffer() { }
void SND_fn_vSetPosSoundRequest() { }
void SND_fn_vSetRetInfoSoundObjectType() { }
void SND_fn_vSetRetRollOffSoundObjectType() { }
void SND_fn_vSetRetSoundChannelType() { }
void SND_fn_vSetRetSoundMicros() { }
void SND_fn_vSetRetSoundObjectType() { }
void SND_fn_vSetSoundDopplerFactor() { }
void SND_fn_vSetSoundEffect() { }
void SND_fn_vSetSoundVolumeLine() { }
void SND_fn_vSetStereoSound() { }
void SND_fn_vStopEventBeforeUnloadSound() { }
void SND_fn_vStopSoundRequest() { }
void SND_fn_vStopSoundRequestWithFade() { }
void SND_fn_vSynchroSound() { }
void SND_fn_vUnRegisterAllAnlCallback() { }
void SND_fn_vUnRegisterAnlCallback() { }

} // extern "C"

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    return TRUE;
}
