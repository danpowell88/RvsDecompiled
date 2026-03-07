/*=============================================================================
	UnActor.cpp: AActor and subclass registration + exec function stubs.
	Reconstructed for Ravenshield decompilation project.
	Full implementations in UnActor.cpp.bak — will restore when headers complete.
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(AActor);
IMPLEMENT_CLASS(AInfo);
IMPLEMENT_CLASS(ABrush);
IMPLEMENT_CLASS(AVolume);
IMPLEMENT_CLASS(AKeypoint);
IMPLEMENT_CLASS(ATriggers);
IMPLEMENT_CLASS(ATrigger);
IMPLEMENT_CLASS(ALight);
IMPLEMENT_CLASS(ANavigationPoint);
IMPLEMENT_CLASS(ASmallNavigationPoint);
IMPLEMENT_CLASS(APhysicsVolume);
IMPLEMENT_CLASS(ADefaultPhysicsVolume);
IMPLEMENT_CLASS(ABlockingVolume);
IMPLEMENT_CLASS(AAntiPortalActor);
IMPLEMENT_CLASS(ANote);
IMPLEMENT_CLASS(APolyMarker);
IMPLEMENT_CLASS(AClipMarker);
IMPLEMENT_CLASS(AStaticMeshActor);
IMPLEMENT_CLASS(AEffects);
IMPLEMENT_CLASS(AAmbientSound);
IMPLEMENT_CLASS(ADecoVolumeObject);
IMPLEMENT_CLASS(ADecorationList);
IMPLEMENT_CLASS(AKActor);
IMPLEMENT_CLASS(AMover);
// AProjector and AShadowProjector registered in UnEffects.cpp
IMPLEMENT_CLASS(AR6MorphMeshActor);
IMPLEMENT_CLASS(AR6ActorSound);
IMPLEMENT_CLASS(AR6Alarm);

/*-----------------------------------------------------------------------------
	AActor exec function stubs.
-----------------------------------------------------------------------------*/

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(AActor,execError)                    IMPLEMENT_FUNCTION( AActor, 233, execError );
EXEC_STUB(AActor,execSleep)                    IMPLEMENT_FUNCTION( AActor, 256, execSleep );
EXEC_STUB(AActor,execPollSleep)                IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollSleep );
EXEC_STUB(AActor,execDestroy)                  IMPLEMENT_FUNCTION( AActor, 279, execDestroy );
EXEC_STUB(AActor,execSpawn)                    IMPLEMENT_FUNCTION( AActor, 278, execSpawn );
EXEC_STUB(AActor,execMove)                     IMPLEMENT_FUNCTION( AActor, 266, execMove );
EXEC_STUB(AActor,execMoveSmooth)               IMPLEMENT_FUNCTION( AActor, 3969, execMoveSmooth );
EXEC_STUB(AActor,execSetLocation)              IMPLEMENT_FUNCTION( AActor, 267, execSetLocation );
EXEC_STUB(AActor,execSetRotation)              IMPLEMENT_FUNCTION( AActor, 299, execSetRotation );
EXEC_STUB(AActor,execSetRelativeLocation)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetRelativeLocation );
EXEC_STUB(AActor,execSetRelativeRotation)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetRelativeRotation );
EXEC_STUB(AActor,execSetPhysics)               IMPLEMENT_FUNCTION( AActor, 3970, execSetPhysics );
EXEC_STUB(AActor,execAutonomousPhysics)        IMPLEMENT_FUNCTION( AActor, 3971, execAutonomousPhysics );
EXEC_STUB(AActor,execSetCollision)             IMPLEMENT_FUNCTION( AActor, 262, execSetCollision );
EXEC_STUB(AActor,execSetCollisionSize)         IMPLEMENT_FUNCTION( AActor, 283, execSetCollisionSize );
EXEC_STUB(AActor,execSetTimer)                 IMPLEMENT_FUNCTION( AActor, 280, execSetTimer );
EXEC_STUB(AActor,execSetOwner)                 IMPLEMENT_FUNCTION( AActor, 272, execSetOwner );
EXEC_STUB(AActor,execSetBase)                  IMPLEMENT_FUNCTION( AActor, 298, execSetBase );
EXEC_STUB(AActor,execTrace)                    IMPLEMENT_FUNCTION( AActor, 277, execTrace );
EXEC_STUB(AActor,execFastTrace)                IMPLEMENT_FUNCTION( AActor, 548, execFastTrace );
EXEC_STUB(AActor,execR6Trace)                  IMPLEMENT_FUNCTION( AActor, 1806, execR6Trace );
EXEC_STUB(AActor,execFindSpot)                 IMPLEMENT_FUNCTION( AActor, 1800, execFindSpot );
EXEC_STUB(AActor,execPlayAnim)                 IMPLEMENT_FUNCTION( AActor, 259, execPlayAnim );
EXEC_STUB(AActor,execLoopAnim)                 IMPLEMENT_FUNCTION( AActor, 260, execLoopAnim );
EXEC_STUB(AActor,execTweenAnim)                IMPLEMENT_FUNCTION( AActor, 294, execTweenAnim );
EXEC_STUB(AActor,execFinishAnim)               IMPLEMENT_FUNCTION( AActor, 261, execFinishAnim );
EXEC_STUB(AActor,execPollFinishAnim)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishAnim );
EXEC_STUB(AActor,execStopAnimating)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopAnimating );
EXEC_STUB(AActor,execIsAnimating)              IMPLEMENT_FUNCTION( AActor, 282, execIsAnimating );
EXEC_STUB(AActor,execIsTweening)               IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execIsTweening );
EXEC_STUB(AActor,execHasAnim)                  IMPLEMENT_FUNCTION( AActor, 263, execHasAnim );
EXEC_STUB(AActor,execGetAnimGroup)             IMPLEMENT_FUNCTION( AActor, 1500, execGetAnimGroup );
EXEC_STUB(AActor,execGetAnimParams)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetAnimParams );
EXEC_STUB(AActor,execAnimBlendParams)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimBlendParams );
EXEC_STUB(AActor,execAnimBlendToAlpha)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimBlendToAlpha );
EXEC_STUB(AActor,execGetAnimBlendAlpha)        IMPLEMENT_FUNCTION( AActor, 2208, execGetAnimBlendAlpha );
EXEC_STUB(AActor,execAnimIsInGroup)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAnimIsInGroup );
EXEC_STUB(AActor,execFreezeAnimAt)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execFreezeAnimAt );
EXEC_STUB(AActor,execGetNotifyChannel)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNotifyChannel );
EXEC_STUB(AActor,execEnableChannelNotify)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execEnableChannelNotify );
EXEC_STUB(AActor,execClearChannel)             IMPLEMENT_FUNCTION( AActor, 1805, execClearChannel );
EXEC_STUB(AActor,execLinkMesh)                 IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLinkMesh );
EXEC_STUB(AActor,execLinkSkelAnim)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLinkSkelAnim );
EXEC_STUB(AActor,execUnLinkSkelAnim)           IMPLEMENT_FUNCTION( AActor, 2210, execUnLinkSkelAnim );
EXEC_STUB(AActor,execWasSkeletonUpdated)       IMPLEMENT_FUNCTION( AActor, 1501, execWasSkeletonUpdated );
EXEC_STUB(AActor,execLockRootMotion)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execLockRootMotion );
EXEC_STUB(AActor,execGetRootLocation)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocation );
EXEC_STUB(AActor,execGetRootLocationDelta)     IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootLocationDelta );
EXEC_STUB(AActor,execGetRootRotation)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotation );
EXEC_STUB(AActor,execGetRootRotationDelta)     IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRootRotationDelta );
EXEC_STUB(AActor,execGetBoneCoords)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneCoords );
EXEC_STUB(AActor,execGetBoneRotation)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetBoneRotation );
EXEC_STUB(AActor,execSetBoneRotation)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneRotation );
EXEC_STUB(AActor,execSetBoneDirection)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneDirection );
EXEC_STUB(AActor,execSetBoneLocation)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneLocation );
EXEC_STUB(AActor,execSetBoneScale)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetBoneScale );
EXEC_STUB(AActor,execGetRenderBoundingSphere)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetRenderBoundingSphere );
EXEC_STUB(AActor,execAttachToBone)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAttachToBone );
EXEC_STUB(AActor,execDetachFromBone)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDetachFromBone );
EXEC_STUB(AActor,execPlaySound)                IMPLEMENT_FUNCTION( AActor, 264, execPlaySound );
EXEC_STUB(AActor,execPlayOwnedSound)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPlayOwnedSound );
EXEC_STUB(AActor,execDemoPlaySound)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execDemoPlaySound );
EXEC_STUB(AActor,execMakeNoise)                IMPLEMENT_FUNCTION( AActor, 512, execMakeNoise );
EXEC_STUB(AActor,execIsPlayingSound)           IMPLEMENT_FUNCTION( AActor, 2703, execIsPlayingSound );
EXEC_STUB(AActor,execPlayMusic)                IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPlayMusic );
EXEC_STUB(AActor,execStopMusic)                IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopMusic );
EXEC_STUB(AActor,execStopAllMusic)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execStopAllMusic );
EXEC_STUB(AActor,execStopAllSounds)            IMPLEMENT_FUNCTION( AActor, 2712, execStopAllSounds );
EXEC_STUB(AActor,execStopAllSoundsActor)       IMPLEMENT_FUNCTION( AActor, 2719, execStopAllSoundsActor );
EXEC_STUB(AActor,execStopSound)                IMPLEMENT_FUNCTION( AActor, 2725, execStopSound );
EXEC_STUB(AActor,execFadeSound)                IMPLEMENT_FUNCTION( AActor, 2721, execFadeSound );
EXEC_STUB(AActor,execAddSoundBank)             IMPLEMENT_FUNCTION( AActor, 2716, execAddSoundBank );
EXEC_STUB(AActor,execAddAndFindBankInSound)    IMPLEMENT_FUNCTION( AActor, 2717, execAddAndFindBankInSound );
EXEC_STUB(AActor,execResetVolume_AllTypeSound) IMPLEMENT_FUNCTION( AActor, 2704, execResetVolume_AllTypeSound );
EXEC_STUB(AActor,execResetVolume_TypeSound)    IMPLEMENT_FUNCTION( AActor, 2720, execResetVolume_TypeSound );
EXEC_STUB(AActor,execChangeVolumeType)         IMPLEMENT_FUNCTION( AActor, 2705, execChangeVolumeType );
EXEC_STUB(AActor,execSaveCurrentFadeValue)     IMPLEMENT_FUNCTION( AActor, 2722, execSaveCurrentFadeValue );
EXEC_STUB(AActor,execReturnSavedFadeValue)     IMPLEMENT_FUNCTION( AActor, 2723, execReturnSavedFadeValue );
EXEC_STUB(AActor,execGetSoundDuration)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetSoundDuration );
EXEC_STUB(AActor,execSetDrawScale)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale );
EXEC_STUB(AActor,execSetDrawScale3D)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawScale3D );
EXEC_STUB(AActor,execSetDrawType)              IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetDrawType );
EXEC_STUB(AActor,execSetStaticMesh)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSetStaticMesh );
EXEC_STUB(AActor,execOnlyAffectPawns)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execOnlyAffectPawns );
EXEC_STUB(AActor,execFinishInterpolation)      IMPLEMENT_FUNCTION( AActor, 301, execFinishInterpolation );
EXEC_STUB(AActor,execPollFinishInterpolation)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execPollFinishInterpolation );
EXEC_STUB(AActor,execConsoleCommand)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execConsoleCommand );
EXEC_STUB(AActor,execAllActors)                IMPLEMENT_FUNCTION( AActor, 304, execAllActors );
EXEC_STUB(AActor,execDynamicActors)            IMPLEMENT_FUNCTION( AActor, 313, execDynamicActors );
EXEC_STUB(AActor,execChildActors)              IMPLEMENT_FUNCTION( AActor, 305, execChildActors );
EXEC_STUB(AActor,execBasedActors)              IMPLEMENT_FUNCTION( AActor, 306, execBasedActors );
EXEC_STUB(AActor,execTouchingActors)           IMPLEMENT_FUNCTION( AActor, 307, execTouchingActors );
EXEC_STUB(AActor,execTraceActors)              IMPLEMENT_FUNCTION( AActor, 309, execTraceActors );
EXEC_STUB(AActor,execRadiusActors)             IMPLEMENT_FUNCTION( AActor, 310, execRadiusActors );
EXEC_STUB(AActor,execVisibleActors)            IMPLEMENT_FUNCTION( AActor, 311, execVisibleActors );
EXEC_STUB(AActor,execVisibleCollidingActors)   IMPLEMENT_FUNCTION( AActor, 312, execVisibleCollidingActors );
EXEC_STUB(AActor,execCollidingActors)          IMPLEMENT_FUNCTION( AActor, 321, execCollidingActors );
EXEC_STUB(AActor,execPlayerCanSeeMe)           IMPLEMENT_FUNCTION( AActor, 532, execPlayerCanSeeMe );
EXEC_STUB(AActor,execGetMapName)               IMPLEMENT_FUNCTION( AActor, 539, execGetMapName );
EXEC_STUB(AActor,execGetMapNameExt)            IMPLEMENT_FUNCTION( AActor, 1519, execGetMapNameExt );
EXEC_STUB(AActor,execGetURLMap)                IMPLEMENT_FUNCTION( AActor, 547, execGetURLMap );
EXEC_STUB(AActor,execGetNextSkin)              IMPLEMENT_FUNCTION( AActor, 545, execGetNextSkin );
EXEC_STUB(AActor,execGetNextInt)               IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNextInt );
EXEC_STUB(AActor,execGetNextIntDesc)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetNextIntDesc );
EXEC_STUB(AActor,execGetCacheEntry)            IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetCacheEntry );
EXEC_STUB(AActor,execMoveCacheEntry)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMoveCacheEntry );
EXEC_STUB(AActor,execGetTime)                  IMPLEMENT_FUNCTION( AActor, 1012, execGetTime );
EXEC_STUB(AActor,execGetGameManager)           IMPLEMENT_FUNCTION( AActor, 1551, execGetGameManager );
EXEC_STUB(AActor,execGetModMgr)                IMPLEMENT_FUNCTION( AActor, 1524, execGetModMgr );
EXEC_STUB(AActor,execGetGameOptions)           IMPLEMENT_FUNCTION( AActor, 1009, execGetGameOptions );
EXEC_STUB(AActor,execGetServerOptions)         IMPLEMENT_FUNCTION( AActor, 1273, execGetServerOptions );
EXEC_STUB(AActor,execSaveServerOptions)        IMPLEMENT_FUNCTION( AActor, 1283, execSaveServerOptions );
EXEC_STUB(AActor,execGetMissionDescription)    IMPLEMENT_FUNCTION( AActor, 1302, execGetMissionDescription );
EXEC_STUB(AActor,execSetServerBeacon)          IMPLEMENT_FUNCTION( AActor, 1311, execSetServerBeacon );
EXEC_STUB(AActor,execGetServerBeacon)          IMPLEMENT_FUNCTION( AActor, 1312, execGetServerBeacon );
EXEC_STUB(AActor,execNativeStartedByGSClient)  IMPLEMENT_FUNCTION( AActor, 1200, execNativeStartedByGSClient );
EXEC_STUB(AActor,execNativeNonUbiMatchMaking)           IMPLEMENT_FUNCTION( AActor, 1303, execNativeNonUbiMatchMaking );
EXEC_STUB(AActor,execNativeNonUbiMatchMakingAddress)    IMPLEMENT_FUNCTION( AActor, 1304, execNativeNonUbiMatchMakingAddress );
EXEC_STUB(AActor,execNativeNonUbiMatchMakingPassword)   IMPLEMENT_FUNCTION( AActor, 1305, execNativeNonUbiMatchMakingPassword );
EXEC_STUB(AActor,execNativeNonUbiMatchMakingHost)       IMPLEMENT_FUNCTION( AActor, 1316, execNativeNonUbiMatchMakingHost );
EXEC_STUB(AActor,execGetGameVersion)           IMPLEMENT_FUNCTION( AActor, 1419, execGetGameVersion );
EXEC_STUB(AActor,execIsPBClientEnabled)        IMPLEMENT_FUNCTION( AActor, 1400, execIsPBClientEnabled );
EXEC_STUB(AActor,execIsPBServerEnabled)        IMPLEMENT_FUNCTION( AActor, 1402, execIsPBServerEnabled );
EXEC_STUB(AActor,execSetPBStatus)              IMPLEMENT_FUNCTION( AActor, 1401, execSetPBStatus );
EXEC_STUB(AActor,execIsAvailableInGameType)    IMPLEMENT_FUNCTION( AActor, 1513, execIsAvailableInGameType );
EXEC_STUB(AActor,execConvertGameTypeIntToString)  IMPLEMENT_FUNCTION( AActor, 1256, execConvertGameTypeIntToString );
EXEC_STUB(AActor,execConvertGameTypeToInt)        IMPLEMENT_FUNCTION( AActor, 2015, execConvertGameTypeToInt );
EXEC_STUB(AActor,execConvertIntTimeToString)      IMPLEMENT_FUNCTION( AActor, 1520, execConvertIntTimeToString );
EXEC_STUB(AActor,execGlobalIDToString)         IMPLEMENT_FUNCTION( AActor, 1522, execGlobalIDToString );
EXEC_STUB(AActor,execGlobalIDToBytes)          IMPLEMENT_FUNCTION( AActor, 1523, execGlobalIDToBytes );
EXEC_STUB(AActor,execGetTagInformations)       IMPLEMENT_FUNCTION( AActor, 2008, execGetTagInformations );
EXEC_STUB(AActor,execDbgVectorReset)           IMPLEMENT_FUNCTION( AActor, 1505, execDbgVectorReset );
EXEC_STUB(AActor,execDbgVectorAdd)             IMPLEMENT_FUNCTION( AActor, 1506, execDbgVectorAdd );
EXEC_STUB(AActor,execDbgAddLine)               IMPLEMENT_FUNCTION( AActor, 1801, execDbgAddLine );
EXEC_STUB(AActor,execGetFPlayerMenuInfo)       IMPLEMENT_FUNCTION( AActor, 1230, execGetFPlayerMenuInfo );
EXEC_STUB(AActor,execSetFPlayerMenuInfo)       IMPLEMENT_FUNCTION( AActor, 1231, execSetFPlayerMenuInfo );
EXEC_STUB(AActor,execGetPlayerSetupInfo)       IMPLEMENT_FUNCTION( AActor, 1232, execGetPlayerSetupInfo );
EXEC_STUB(AActor,execSetPlayerSetupInfo)       IMPLEMENT_FUNCTION( AActor, 1233, execSetPlayerSetupInfo );
EXEC_STUB(AActor,execSortFPlayerMenuInfo)      IMPLEMENT_FUNCTION( AActor, 1279, execSortFPlayerMenuInfo );
EXEC_STUB(AActor,execSetPlanningMode)          IMPLEMENT_FUNCTION( AActor, 2011, execSetPlanningMode );
EXEC_STUB(AActor,execSetFloorToDraw)           IMPLEMENT_FUNCTION( AActor, 2012, execSetFloorToDraw );
EXEC_STUB(AActor,execInPlanningMode)           IMPLEMENT_FUNCTION( AActor, 2014, execInPlanningMode );
EXEC_STUB(AActor,execLoadLoadingScreen)        IMPLEMENT_FUNCTION( AActor, 2613, execLoadLoadingScreen );
EXEC_STUB(AActor,execLoadRandomBackgroundImage)  IMPLEMENT_FUNCTION( AActor, 2607, execLoadRandomBackgroundImage );
EXEC_STUB(AActor,execGetNbAvailableResolutions)  IMPLEMENT_FUNCTION( AActor, 2614, execGetNbAvailableResolutions );
EXEC_STUB(AActor,execGetAvailableResolution)   IMPLEMENT_FUNCTION( AActor, 2615, execGetAvailableResolution );
EXEC_STUB(AActor,execReplaceTexture)           IMPLEMENT_FUNCTION( AActor, 2616, execReplaceTexture );
EXEC_STUB(AActor,execIsVideoHardwareAtLeast64M) IMPLEMENT_FUNCTION( AActor, 2617, execIsVideoHardwareAtLeast64M );
EXEC_STUB(AActor,execGetCanvas)                IMPLEMENT_FUNCTION( AActor, 2618, execGetCanvas );
EXEC_STUB(AActor,execEnableLoadingScreen)      IMPLEMENT_FUNCTION( AActor, 2619, execEnableLoadingScreen );
EXEC_STUB(AActor,execAddMessageToConsole)      IMPLEMENT_FUNCTION( AActor, 2620, execAddMessageToConsole );
EXEC_STUB(AActor,execUpdateGraphicOptions)     IMPLEMENT_FUNCTION( AActor, 2621, execUpdateGraphicOptions );
EXEC_STUB(AActor,execGarbageCollect)           IMPLEMENT_FUNCTION( AActor, 2622, execGarbageCollect );
EXEC_STUB(AActor,execDrawDashedLine)           IMPLEMENT_FUNCTION( AActor, 2608, execDrawDashedLine );
EXEC_STUB(AActor,execDrawText3D)               IMPLEMENT_FUNCTION( AActor, 2609, execDrawText3D );
EXEC_STUB(AActor,execRenderLevelFromMe)        IMPLEMENT_FUNCTION( AActor, 2610, execRenderLevelFromMe );
EXEC_STUB(AActor,execMultiply_ColorFloat)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMultiply_ColorFloat );
EXEC_STUB(AActor,execMultiply_FloatColor)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execMultiply_FloatColor );
EXEC_STUB(AActor,execAdd_ColorColor)           IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execAdd_ColorColor );
EXEC_STUB(AActor,execSubtract_ColorColor)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execSubtract_ColorColor );

#undef EXEC_STUB

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
