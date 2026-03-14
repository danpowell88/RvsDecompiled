// SNDDSound3D.cpp - DARE Sound Engine DirectSound3D backend stubs
// Auto-generated stubs for SNDDSound3DDLL_ret.dll and SNDDSound3DDLL_VSR.dll
// All functions defined here; .def files control which are exported per variant.
//
// DARE (Digital Audio Rendering Engine) is third-party audio middleware by
// Ubi Soft Montreal's audio team. This module provides the DirectSound3D
// backend implementation with EAX support.

#pragma warning(disable: 4100) // unreferenced formal parameter

#include <windows.h>
#include "ImplSource.h"

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
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDisableHardwareAcceleration(int bDisable) {}

// ?SND_fn_vSetHRTFOption@@YAXW4_SND_tdeHTRFType@@@Z
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetHRTFOption(_SND_tdeHTRFType eType) {}

// =============================================================================
// __stdcall exports (decorated _Name@N)
// =============================================================================

extern "C" {

IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_Is_SSE_Supported(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bCanFreeSubBlockDataSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bDesInitDataLoadSnd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bEnableEAXSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bEnterCriticalSectionForDriverThreadSnd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bFileNameExist(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetAllEventsId(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetMasterDirectory(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetOnePartialDirectory(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetOptions(int p0, int p1, int p2, int p3) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetSoundEventNameFromEditorId(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bGetStereoSxd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bInitDataLoadSnd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsDataDirectory(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsEAXCompatibleSxd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsProjectLocalised(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsResourceLoopingSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsResourceStreamedSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bIsScriptModeUsed(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadBank(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadBankSet(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadDataInMem(int p0, int p1, int p2, int p3) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadMap(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadResBinarySxd(int p0, int p1, int p2, int p3) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadResScriptSxd(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bLoadSubMap(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bSetNextTransitionSxd(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bSetParamSxd(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bSetParamTransitionSxd(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bSetResourceStaticVolumeSxd(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bSetSlowMotionFactorSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bStartFadeSxd(int p0, int p1, int p2, int p3, int p4, int p5) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestIsPlayingSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestIsPlayingTransitionSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestSnd_MMX(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestSnd_Pentium(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestSnd_Win32(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestSnd_WinMM(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTestSnd_WinNT4(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bTryToEnterCriticalSectionThreadSnd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bUnLoadBank(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_bUnLoadBankSet(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
const char* __stdcall SND_fn_czGetEvtGrpByNameTableName(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_eGetDataProjectLoadMode(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_eGetMainFormatSxd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_eGetProjectDataLoadMode(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_eInitSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_hGetHanldeThreadSnd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_hGetSoundEventHandleFromEditorId(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_hGetSoundEventHandleFromSectionName(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_iGetEvtGrpByNameTableSize(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall SND_fn_iIsEvtGrpLoaded(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lCreateBufferSxd(int p0, int p1, int p2, int p3) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lCreateMicroSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lCreateTimer(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGenerateSndTocKey(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetEventGroupIdFromFileTitle(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetNbVoiceWishedSxd(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifTypeCount(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifTypeId(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifTypeIdArray(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifTypeName(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifValueCount(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifValueId(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifValueIdArray(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lGetSifValueName(int p0, int p1, int p2, int p3) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lPlaySxd(int p0, int p1, int p2, int p3, int p4) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lPlayTransitionExSxd(int p0, int p1, int p2, int p3, int p4, int p5) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lQueueDataBufferSxd(int p0, int p1, int p2) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lQueueResetBufferSxd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lStrLwr(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long __stdcall SND_fn_lStriCmp(int p0, int p1) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_pGetBinEvent(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_pGetBinRes(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall SND_fn_pstGetResFromEdIdSnd(int p0) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rAbsRealSnd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rDistanceToVolume(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rDistanceToVolumeEx(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rDivRealRealQuickSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rDivRealRealSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rDopplerPitch(int p0, int p1, int p2, int p3) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetCurrentTime(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetDopplerFactor(void) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetLengthSxd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetNormeSxd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetPosBufferSxd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetPosSxd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rGetPosTransitionSxd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rMulRealRealQuickSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rMulRealRealSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rNormeVectorSnd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rPseudoNormeRealSnd(int p0, int p1, int p2) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rPseudoNormeVectorSnd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rPseudoScalaireNormeVectorSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rScalaireVectorSnd(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rSqrtRealSnd(int p0) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float __stdcall SND_fn_rtSndRealToSndRealTwin(int p0, int p1) { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
const char* __stdcall SND_fn_szGetCurrentLangDirectory(void) { return 0; }
IMPL_TODO("Needs Ghidra analysis")
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
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vAddPartialDirectory(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vAnalyzeScriptFile(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vConvertResDiskToMemSxd(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDeleteBufferSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDesInitSxd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDesInitThreadSnd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDestroyMicroSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDestroyTimer(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vDisableEventLogGeneration(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vEnableEventLogGeneration(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vEnterCriticalSectionForErrorDisplay(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vEnterCriticalSectionThreadSnd_(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vFlushQueueBuffersSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vGetDefaultRollOff(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vGetHModuleDbg(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vInitCallbacks(void) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vInitThreadSnd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vMouchardThreadsnd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vParam3Dto2D(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vPauseBufferSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vPauseSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vPauseTimer(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vPauseTransitionSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vProduitVectorSnd(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vPurgeAllDirectories(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vQuitCriticalSectionForErrorDisplay(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vQuitCriticalSectionThreadSnd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vRegisterAnlCallback(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vReleaseDriverSxd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vReloadDataSnd(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vRemovePartialDirectory(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResetTimer(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResolveFileName(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vRestoreDriverSxd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResumeBufferSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResumeSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResumeTimer(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vResumeTransitionSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetCurrentLangDirectory(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetCurrentLanguage(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetDefaultRollOff(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetDefaultRollOffSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetDopplerFactor(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetDopplerFactorSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetEffectSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetMasterDirectory(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetMicroParamSxd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetNbVoiceWishedSxd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetOptions(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetParamBufferSxd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetPosSxd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetRefreshFunc(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetSoftDirectory(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSetStereoSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSndRealTwinToSndReal(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vStartIndexFadeSxd(int p0, int p1, int p2, int p3, int p4) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vStopBeforeUnLoadResSnd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vStopSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vStopTransitionSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vStrncpy(int p0, int p1, int p2) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSynchroSxd(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vSynchroTimer(void) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vUnLoadResSnd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vUnLoadResSxd(int p0) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vVolPanToVolLR(int p0, int p1, int p2, int p3, int p4) { }
IMPL_TODO("Needs Ghidra analysis")
void __stdcall SND_fn_vWaitForValueThreadSnd(int p0, int p1) { }
IMPL_TODO("Needs Ghidra analysis")
int __stdcall dbgSND_fn_bAddEventToEngineTable(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall dbgSND_fn_bAddResToEngineTable(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall dbgSND_fn_bLoadResScriptSnd(int p0, int p1) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int __stdcall dbgSND_fn_bSetResourceStaticVolume(int p0, int p1) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
const char* __stdcall dbgSND_fn_czGetProjectTitle(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
long __stdcall dbgSND_fn_lGetLoadedBanks(int p0, int p1) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
long __stdcall dbgSND_fn_lGetNumberOfBanks(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateCoordinateM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateEffectGraphM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateEventM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateMultiLayerElementM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateRandomElementM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateResM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateSequenceElementM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateSwitchElementM(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateThemePart(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pCreateThemePartOutro(void) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* __stdcall dbgSND_fn_pGetThemeInfos(int p0) { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
float __stdcall dbgSND_fn_rGetDopplerFactor(void) { return 0.0f; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vAddEventInTSNEditor(int p0, int p1, int p2) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroyEventM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroyMultiLayerElementM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroyRandomElementM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroyResM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroySequenceElementM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroySwitchElementM(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vDestroyThemePart(int p0) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vGetAudioFrameBufferSize(int p0, int p1) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vGetInfoForObjectSound(int p0, int p1, int p2, int p3) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vKillAllObjectTypeSound(void) { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void __stdcall dbgSND_fn_vSendRequestSound(int p0) { } // VSR only

} // extern "C"

// =============================================================================
// __cdecl exports (undecorated names)
// =============================================================================

extern "C" {

IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bAreWavPresent() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bEnableEAX() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bGetStereoSound() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bIsEAXCompatible() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bIsSoundRequestPlaying() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bLoadResScriptSnd() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_bSetSlowMotionFactor() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
const char* SND_fn_czGetProjectTitle() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
int SND_fn_eInitSound() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetLengthSoundEvent() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetLengthSoundRequest() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetPosClientBuffer() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetPosSoundRequest() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetSoundVolumeLine() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetVolumeMTTChannelTrack() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetVolumeSoundObject() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
float SND_fn_fGetVolumeSoundObjectType() { return 0.0f; }
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_hGenerateSoundEventPlay() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_hGenerateSoundEventPlayStream() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_hGenerateSoundEventStop() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_hGetLastSoundEventOfSoundObjectType() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lAddSoundObjectType() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lAddSoundVolumeLine() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lCreateClientBuffer() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lCreateSoundMicro() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lFlushQueueClientBuffer() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lGetLatestPlayingSoundRequest() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lGetMTTChannelIdFromMTTChannelName() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lGetNbVoiceWishedSound() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lQueueDataClientBuffer() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lQueueResetClientBuffer() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lSendSoundRequest() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lSendSoundRequestOnChannel() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lSendSoundRequestOnChannelWithFadeIn() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
long SND_fn_lSendSoundRequestWithFadeIn() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateCoordinateM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateEffectGraphListM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateEffectGraphM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateEventM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateMultiLayerElementListM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateMultiLayerElementM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateMultiTrackElementM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateRandomElementM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateResM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateSequenceElement() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateSwitchElementM() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateThemePart() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pCreateThemePartOutro() { return 0; } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void* SND_fn_pvGetDirectSound8Object() { return 0; }
unsigned long SND_fn_ulGetEditorIdFromSoundEventHandle() { return 0; }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeAllSoundObjectTypes() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeAllSoundObjectTypesButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeAllSoundObjects() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeAllSoundObjectsButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeMTTChannelTrack() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeSoundObject() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vChangeVolumeSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyCoordinateM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyEffectGraphM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyEventM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyMultiLayerElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyMultiTrackElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyRandomElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyResM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopySequenceElement() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopySwitchElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyThemePart() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vCopyThemePartOutro() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDesInitSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyAllSoundMicros() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyClientBuffer() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyCoordinateM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyEffectGraphM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyEventM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyMultiLayerElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyMultiTrackElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyRandomElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyResM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroySequenceElement() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroySoundEvent() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroySoundMicro() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroySwitchElementM() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyThemePart() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vDestroyThemePartOutro() { } // VSR only
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vExternalInitScriptSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vGetSoundEngineVersion() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vGetSoundObjectInfo() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjectTypes() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjectTypesButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjectTypesButOneWithFade() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjectTypesWithFade() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjects() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillAllSoundObjectsWithFade() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillSoundChannel() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillSoundObject() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vKillSoundObjectWithFade() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vPauseAllSoundObjectTypes() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vPauseAllSoundObjectTypesButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vPauseClientBuffer() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vPauseSoundObject() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vPauseSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vReleaseSoundDriver() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeAllSoundObjectTypes() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeAllSoundObjectTypesButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeAllSoundObjects() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeAllSoundObjectsButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeSoundObject() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResetVolumeSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vRestoreSoundDriver() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResumeAllSoundObjectTypes() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResumeAllSoundObjectTypesButOne() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResumeClientBuffer() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResumeSoundObject() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vResumeSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetDefaultSoundRollOff() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetNbVoiceWishedSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetParamClientBuffer() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetPosSoundRequest() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetRetInfoSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetRetRollOffSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetRetSoundChannelType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetRetSoundMicros() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetRetSoundObjectType() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetSoundDopplerFactor() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetSoundEffect() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetSoundVolumeLine() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSetStereoSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vStopEventBeforeUnloadSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vStopSoundRequest() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vStopSoundRequestWithFade() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vSynchroSound() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vUnRegisterAllAnlCallback() { }
IMPL_TODO("Needs Ghidra analysis")
void SND_fn_vUnRegisterAnlCallback() { }

} // extern "C"

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved)
{
    return TRUE;
}
