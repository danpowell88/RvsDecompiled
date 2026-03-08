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
	AActor trivial method implementations.
	Reconstructed from Ghidra decompilation + UT99 reference.
-----------------------------------------------------------------------------*/

// Pending-state queries
INT AActor::IsPendingKill()
{
	return bDeleteMe;
}

INT AActor::IsPendingDelete()
{
	return bPendingDelete;
}

// Brush type queries
INT AActor::IsBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass());
}

INT AActor::IsStaticBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && bStatic;
}

INT AActor::IsMovingBrush() const
{
	return Brush!=NULL && IsA(ABrush::StaticClass()) && !bStatic;
}

INT AActor::IsVolumeBrush() const
{
	return IsA(AVolume::StaticClass());
}

INT AActor::IsEncroacher() const
{
	return bCollideActors && (IsA(AMover::StaticClass()) || IsA(AKActor::StaticClass()));
}

// Editor / octree queries
INT AActor::IsHiddenEd()
{
	return bHiddenEd || bHiddenEdGroup;
}

INT AActor::IsInOctree()
{
	return OctreeNodes.Num() > 0;
}

UBOOL AActor::IsPlayer() const
{
	guardSlow(AActor::IsPlayer);
	if( !IsA(APawn::StaticClass()) )
		return 0;
	return ((APawn*)this)->m_bIsPlayer;
	unguardSlow;
}

// Simple getters
ULevel* AActor::GetLevel() const
{
	return XLevel;
}

AActor* AActor::GetHitActor()
{
	return (AActor*)this;
}

AActor* AActor::GetTopOwner()
{
	AActor* Top;
	for( Top=(AActor*)this; Top->Owner!=NULL; Top=Top->Owner );
	return Top;
}

FVector AActor::GetCylinderExtent() const
{
	return FVector(CollisionRadius, CollisionRadius, CollisionHeight);
}

AActor* AActor::GetAmbientLightingActor()
{
	return (AActor*)this;
}

FRotator AActor::GetViewRotation()
{
	return Rotation;
}

AActor* AActor::GetProjectorBase()
{
	return (AActor*)this;
}

APawn* AActor::GetPawnOrColBoxOwner() const
{
	guardSlow(AActor::GetPawnOrColBoxOwner);
	return NULL;
	unguardSlow;
}

APawn* AActor::GetPlayerPawn() const
{
	guardSlow(AActor::GetPlayerPawn);
	if( !IsA(APawn::StaticClass()) )
		return NULL;
	return NULL;
	unguardSlow;
}

UPrimitive* AActor::GetPrimitive()
{
	return NULL;
}

// Simple setters
void AActor::SetOwner( AActor* NewOwner )
{
	guard(AActor::SetOwner);
	Owner = NewOwner;
	unguard;
}

void AActor::SetDrawScale( FLOAT NewScale )
{
	guard(AActor::SetDrawScale);
	DrawScale = NewScale;
	unguard;
}

void AActor::SetDrawScale3D( FVector NewScale3D )
{
	guard(AActor::SetDrawScale3D);
	DrawScale3D = NewScale3D;
	unguard;
}

void AActor::SetDrawType( EDrawType NewDrawType )
{
	guard(AActor::SetDrawType);
	DrawType = NewDrawType;
	unguard;
}

void AActor::SetStaticMesh( UStaticMesh* NewStaticMesh )
{
	guard(AActor::SetStaticMesh);
	StaticMesh = NewStaticMesh;
	unguard;
}

void AActor::SetGameType( FString GameType )
{
	guard(AActor::SetGameType);
	unguard;
}


/*-----------------------------------------------------------------------------
	AActor method implementations -- batch from .bak reference.
	Reconstructed from Ghidra decompilation.
-----------------------------------------------------------------------------*/

void AActor::Serialize( FArchive& Ar )
{
	guard(AActor::Serialize);
	UObject::Serialize( Ar );
	// TODO: Serialize actor-specific data (attachments, physics state, etc.)
	unguard;
}

void AActor::PostLoad()
{
	guard(AActor::PostLoad);
	UObject::PostLoad();
	unguard;
}

void AActor::Destroy()
{
	guard(AActor::Destroy);
	UObject::Destroy();
	unguard;
}

void AActor::PostEditChange()
{
	guard(AActor::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

void AActor::InitExecution()
{
	guard(AActor::InitExecution);
	UObject::InitExecution();
	unguard;
}

void AActor::ProcessEvent( UFunction* Function, void* Parms, void* Result )
{
	guard(AActor::ProcessEvent);
	UObject::ProcessEvent( Function, Parms, Result );
	unguard;
}

void AActor::ProcessState( FLOAT DeltaSeconds )
{
	guard(AActor::ProcessState);
	UObject::ProcessState( DeltaSeconds );
	unguard;
}

INT AActor::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessRemoteFunction);
	return UObject::ProcessRemoteFunction( Function, Parms, Stack );
	unguard;
}

void AActor::ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(AActor::ProcessDemoRecFunction);
	// Demo recording stub.
	unguard;
}

void AActor::NetDirty( UProperty* Property )
{
	guard(AActor::NetDirty);
	bNetDirty = 1;
	unguard;
}

INT* AActor::GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Ch )
{
	guard(AActor::GetOptimizedRepList);
	// TODO: Build optimized replication list from replicated properties.
	return Ptr;
	unguard;
}

FLOAT AActor::GetNetPriority( AActor* Sent, FLOAT Time, FLOAT Lag )
{
	guard(AActor::GetNetPriority);
	return NetPriority * (Time + 1.0f);
	unguard;
}

INT AActor::IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation )
{
	guard(AActor::IsNetRelevantFor);
	return bAlwaysRelevant || (Owner == Viewer);
	unguard;
}

void AActor::PreNetReceive()
{
	guard(AActor::PreNetReceive);
	unguard;
}

void AActor::PostNetReceive()
{
	guard(AActor::PostNetReceive);
	unguard;
}

void AActor::PostNetReceiveLocation()
{
	guard(AActor::PostNetReceiveLocation);
	unguard;
}

INT AActor::PlayerControlled()
{
	return 0;
}

INT AActor::IsBlockedBy( const AActor* Other ) const
{
	guardSlow(AActor::IsBlockedBy);
	checkSlow(this!=NULL);
	checkSlow(Other!=NULL);

	if( Other == (AActor*)Level )
		return bCollideWorld;
	else if( Other->IsBrush() )
		return bCollideWorld && Other->bBlockActors;
	else if( IsBrush() )
		return Other->bCollideWorld && bBlockActors;
	else
		return Other->bBlockActors && bBlockActors;
	unguardSlow;
}

UBOOL AActor::IsOverlapping( AActor* Other, FCheckResult* Hit )
{
	guard(AActor::IsOverlapping);
	// TODO: Broad-phase + narrow-phase collision check.
	return 0;
	unguard;
}

INT AActor::ShouldTrace( AActor* SourceActor, DWORD TraceFlags )
{
	guard(AActor::ShouldTrace);
	return (bCollideActors || bBlockActors || bBlockPlayers || bWorldGeometry);
	unguard;
}

void AActor::UpdateColBox( FVector& NewLocation, INT bTest, INT bForce, INT bIgnoreEncroach )
{
	guard(AActor::UpdateColBox);
	// TODO: Update collision box / octree.
	unguard;
}

FCoords AActor::ToLocal() const
{
	return GMath.UnitCoords / Rotation / Location;
}

FCoords AActor::ToWorld() const
{
	return GMath.UnitCoords * Location * Rotation;
}

FMatrix AActor::LocalToWorld() const
{
	guard(AActor::LocalToWorld);
	// TODO: Build actorâworld transform matrix.
	return FMatrix();
	unguard;
}

FMatrix AActor::WorldToLocal() const
{
	guard(AActor::WorldToLocal);
	// TODO: Build worldâactor transform matrix.
	return FMatrix();
	unguard;
}

INT AActor::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	guard(AActor::Tick);
	// TODO: Full tick implementation â physics, timers, state, animation.
	return 1;
	unguard;
}

void AActor::TickAuthoritative( FLOAT DeltaTime )
{
	guard(AActor::TickAuthoritative);
	unguard;
}

void AActor::TickSimulated( FLOAT DeltaTime )
{
	guard(AActor::TickSimulated);
	unguard;
}

void AActor::TickSpecial( FLOAT DeltaTime )
{
	guard(AActor::TickSpecial);
	unguard;
}

INT AActor::TickThisFrame( FLOAT DeltaTime )
{
	guard(AActor::TickThisFrame);
	if( m_bSkipTick )
		return 0;
	return 1;
	unguard;
}

void AActor::UpdateTimers( FLOAT DeltaSeconds )
{
	guard(AActor::UpdateTimers);
	if( TimerRate > 0.f )
	{
		TimerCounter += DeltaSeconds;
		if( TimerCounter >= TimerRate )
		{
			if( bTimerLoop )
				TimerCounter -= TimerRate;
			else
			{
				TimerCounter = 0.f;
				TimerRate = 0.f;
			}
			eventTimer();
		}
	}
	unguard;
}

INT AActor::CheckOwnerUpdated()
{
	guard(AActor::CheckOwnerUpdated);
	return 1;
	unguard;
}

void AActor::BoundProjectileVelocity()
{
	guard(AActor::BoundProjectileVelocity);
	unguard;
}

void AActor::PostBeginPlay()
{
	guard(AActor::PostBeginPlay);
	unguard;
}

void AActor::PostEditLoad()
{
	guard(AActor::PostEditLoad);
	unguard;
}

void AActor::PostEditMove()
{
	guard(AActor::PostEditMove);
	unguard;
}

void AActor::PostPath()
{
	guard(AActor::PostPath);
	unguard;
}

void AActor::PostRaytrace()
{
	guard(AActor::PostRaytrace);
	unguard;
}

void AActor::PostScriptDestroyed()
{
	guard(AActor::PostScriptDestroyed);
	unguard;
}

void AActor::PrePath()
{
	guard(AActor::PrePath);
	unguard;
}

void AActor::PreRaytrace()
{
	guard(AActor::PreRaytrace);
	unguard;
}

void AActor::Spawned()
{
	guard(AActor::Spawned);
	unguard;
}

UMaterial* AActor::GetSkin( INT Index )
{
	guard(AActor::GetSkin);
	if( Index < Skins.Num() && Skins(Index) )
		return Skins(Index);
	return Texture;
	unguard;
}

void AActor::NotifyAnimEnd( INT Channel )
{
	guard(AActor::NotifyAnimEnd);
	eventAnimEnd( Channel );
	unguard;
}

void AActor::UpdateAnimation( FLOAT DeltaSeconds )
{
	guard(AActor::UpdateAnimation);
	// TODO: Update mesh animation state.
	unguard;
}

void AActor::StartAnimPoll()
{
	guard(AActor::StartAnimPoll);
	unguard;
}

INT AActor::CheckAnimFinished( INT Channel )
{
	guard(AActor::CheckAnimFinished);
	return 0;
	unguard;
}

INT AActor::IsAnimating( INT Channel ) const
{
	return 0;
}

void AActor::PlayAnim( INT Channel, FName SequenceName, FLOAT Rate, FLOAT TweenTime, INT bLooping, INT bOverride, INT bRestart )
{
	guard(AActor::PlayAnim);
	// TODO: Start animation playback on specified channel.
	unguard;
}

void AActor::PlayReplicatedAnim()
{
	guard(AActor::PlayReplicatedAnim);
	// TODO: Apply replicated animation state from SimAnim.
	unguard;
}

void AActor::ReplicateAnim( INT Channel, FName SequenceName, FLOAT Rate, FLOAT TweenTime, FLOAT Frame, FLOAT LastFrame, INT bLooping )
{
	guard(AActor::ReplicateAnim);
	// TODO: Send animation state for network replication.
	unguard;
}

void AActor::AnimBlendParams( INT Channel, FLOAT BlendAlpha, FLOAT InTime, FLOAT OutTime, FName BoneName )
{
	guard(AActor::AnimBlendParams);
	// TODO: Configure animation blend parameters.
	unguard;
}

void AActor::BeginTouch( AActor* Other )
{
	guard(AActor::BeginTouch);
	if( Other )
	{
		// Add to touching array if not already present.
		INT i;
		for( i=0; i<Touching.Num(); i++ )
			if( Touching(i) == Other )
				return;
		Touching.AddItem( Other );
		Other->Touching.AddItem( (AActor*)this );

		// Notify both actors.
		eventTouch( Other );
		Other->eventTouch( (AActor*)this );
	}
	unguard;
}

void AActor::EndTouch( AActor* Other, INT bNoNotifySelf )
{
	guard(AActor::EndTouch);
	if( Other )
	{
		Touching.RemoveItem( Other );
		Other->Touching.RemoveItem( (AActor*)this );
		if( !bNoNotifySelf )
			eventUnTouch( Other );
		Other->eventUnTouch( (AActor*)this );
	}
	unguard;
}

void AActor::NotifyBump( AActor* Other )
{
	guard(AActor::NotifyBump);
	eventBump( Other );
	unguard;
}

void AActor::SetBase( AActor* NewBase, FVector NewFloor, INT bNotifyActor )
{
	guard(AActor::SetBase);
	if( Base != NewBase )
	{
		// Detach from old base.
		if( Base )
			Base->Attached.RemoveItem( (AActor*)this );

		Base = NewBase;

		// Attach to new base.
		if( Base )
			Base->Attached.AddItem( (AActor*)this );

		if( bNotifyActor )
			eventBaseChange();
	}
	unguard;
}

INT AActor::AttachToBone( AActor* Attachment, FName BoneName )
{
	guard(AActor::AttachToBone);
	// TODO: Attach actor to skeletal mesh bone.
	return 0;
	unguard;
}

INT AActor::DetachFromBone( AActor* Attachment )
{
	guard(AActor::DetachFromBone);
	// TODO: Detach actor from skeletal mesh bone.
	return 0;
	unguard;
}

void AActor::AttachProjector( AProjector* Proj )
{
	guard(AActor::AttachProjector);
	unguard;
}

void AActor::DetachProjector( AProjector* Proj )
{
	guard(AActor::DetachProjector);
	unguard;
}

void AActor::SetCollision( INT bNewCollideActors, INT bNewBlockActors, INT bNewBlockPlayers )
{
	guard(AActor::SetCollision);
	bCollideActors = bNewCollideActors;
	bBlockActors   = bNewBlockActors;
	bBlockPlayers  = bNewBlockPlayers;
	unguard;
}

void AActor::SetCollisionSize( FLOAT NewRadius, FLOAT NewHeight )
{
	guard(AActor::SetCollisionSize);
	CollisionRadius = NewRadius;
	CollisionHeight = NewHeight;
	unguard;
}

void AActor::UpdateRenderData()
{
	guard(AActor::UpdateRenderData);
	// TODO: Rebuild render data (batches, static lighting).
	unguard;
}

FLOAT AActor::WorldLightRadius() const
{
	return 25.f * ((INT)LightRadius + 1);
}

void AActor::RenderEditorInfo( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
	guard(AActor::RenderEditorInfo);
	unguard;
}

void AActor::RenderEditorSelected( FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* Actor )
{
	guard(AActor::RenderEditorSelected);
	unguard;
}

void AActor::SetZone( INT bTest, INT bForceRefresh )
{
	guard(AActor::SetZone);
	// TODO: Update actor zone/region.
	unguard;
}

void AActor::SetVolumes( const TArray<AVolume*>& NewVolumes )
{
	guard(AActor::SetVolumes);
	// TODO: Update actor volume list.
	unguard;
}

void AActor::SetVolumes()
{
	guard(AActor::SetVolumes_void);
	// TODO: Recalculate actor volumes.
	unguard;
}

void AActor::setPhysics( BYTE NewPhysics, AActor* NewFloor, FVector NewFloorV )
{
	guard(AActor::setPhysics);
	Physics = NewPhysics;
	unguard;
}

void AActor::performPhysics( FLOAT DeltaSeconds )
{
	guard(AActor::performPhysics);
	// TODO: Main physics dispatch (PHYS_Walking, PHYS_Falling, etc).
	unguard;
}

void AActor::processHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::processHitWall);
	eventHitWall( HitNormal, HitActor );
	unguard;
}

void AActor::processLanded( FVector HitNormal, AActor* HitActor, FLOAT RemainingTime, INT Iterations )
{
	guard(AActor::processLanded);
	eventLanded( HitNormal );
	unguard;
}

void AActor::physFalling( FLOAT DeltaTime, INT Iterations )
{
	guard(AActor::physFalling);
	// TODO: Falling physics with gravity + air control.
	unguard;
}

void AActor::physProjectile( FLOAT DeltaTime, INT Iterations )
{
	guard(AActor::physProjectile);
	// TODO: Projectile physics (ballistic arc, bouncing).
	unguard;
}

void AActor::physTrailer( FLOAT DeltaTime )
{
	guard(AActor::physTrailer);
	// TODO: Trailer physics (follows owner).
	unguard;
}

void AActor::physRootMotion( FLOAT DeltaTime )
{
	guard(AActor::physRootMotion);
	// TODO: Root motion physics from skeletal animation.
	unguard;
}

void AActor::physicsRotation( FLOAT DeltaTime )
{
	guard(AActor::physicsRotation);
	if( bRotateToDesired )
	{
		// TODO: Smooth rotation toward DesiredRotation at RotationRate.
	}
	unguard;
}

FRotator AActor::FindSlopeRotation( FVector FloorNormal, FRotator NewRotation )
{
	guard(AActor::FindSlopeRotation);
	return NewRotation;
	unguard;
}

void AActor::SmoothHitWall( FVector HitNormal, AActor* HitActor )
{
	guard(AActor::SmoothHitWall);
	processHitWall( HitNormal, HitActor );
	unguard;
}

void AActor::stepUp( FVector GravDir, FVector DesiredDir, FVector Delta, FCheckResult& Hit )
{
	guard(AActor::stepUp);
	// TODO: Step-up ledge logic.
	unguard;
}

INT AActor::moveSmooth( FVector Delta )
{
	guard(AActor::moveSmooth);
	// TODO: Smooth movement with wall sliding.
	return 1;
	unguard;
}

INT AActor::fixedTurn( INT Current, INT Desired, INT DeltaRate )
{
	guard(AActor::fixedTurn);
	if( DeltaRate == 0 )
		return Current & 0xFFFF;
	if( Current == Desired )
		return Current & 0xFFFF;
	INT Diff = (Desired - Current) & 0xFFFF;
	if( Diff > 0x8000 )
		Diff -= 0x10000;
	if( Diff > DeltaRate )
		Diff = DeltaRate;
	else if( Diff < -DeltaRate )
		Diff = -DeltaRate;
	return (Current + Diff) & 0xFFFF;
	unguard;
}

void AActor::TwoWallAdjust( FVector& DesiredDir, FVector& Delta, FVector& HitNormal, FVector& OldHitNormal, FLOAT HitTime )
{
	guard(AActor::TwoWallAdjust);
	if( (OldHitNormal | HitNormal) <= 0 )
	{
		FVector NewDir = (HitNormal ^ OldHitNormal);
		NewDir = NewDir.SafeNormal();
		Delta = (Delta | NewDir) * (1.f - HitTime) * NewDir;
		if( (DesiredDir | Delta) < 0 )
			Delta = -1 * Delta;
	}
	else
	{
		Delta = (Delta - HitNormal * (Delta | HitNormal)) * (1.f - HitTime);
		if( (Delta | DesiredDir) <= 0 )
			Delta = FVector(0,0,0);
	}
	unguard;
}

void AActor::FindBase()
{
	guard(AActor::FindBase);
	// TODO: Trace downward to find base actor to stand on.
	unguard;
}

void AActor::PutOnGround()
{
	guard(AActor::PutOnGround);
	// TODO: Drop actor to ground level.
	unguard;
}

struct _McdModel* AActor::getKModel() const
{
	return NULL;
}

void AActor::physKarma( FLOAT DeltaTime )
{
	guard(AActor::physKarma);
	unguard;
}

void AActor::physKarma_internal( FLOAT DeltaTime )
{
	guard(AActor::physKarma_internal);
	unguard;
}

void AActor::physKarmaRagDoll( FLOAT DeltaTime )
{
	guard(AActor::physKarmaRagDoll);
	unguard;
}

void AActor::physKarmaRagDoll_internal( FLOAT DeltaTime )
{
	guard(AActor::physKarmaRagDoll_internal);
	unguard;
}

void AActor::preKarmaStep( FLOAT DeltaTime )
{
	guard(AActor::preKarmaStep);
	unguard;
}

void AActor::postKarmaStep()
{
	guard(AActor::postKarmaStep);
	unguard;
}

void AActor::preKarmaStep_skeletal( FLOAT DeltaTime )
{
	guard(AActor::preKarmaStep_skeletal);
	unguard;
}

void AActor::postKarmaStep_skeletal()
{
	guard(AActor::postKarmaStep_skeletal);
	unguard;
}

INT AActor::KMP2DynKarmaInterface( INT Mode, FVector Position, FRotator Rotation, AActor* Other )
{
	guard(AActor::KMP2DynKarmaInterface);
	return 0;
	unguard;
}

AActor* AActor::AssociatedLevelGeometry()
{
	guard(AActor::AssociatedLevelGeometry);
	return NULL;
	unguard;
}

INT AActor::HasAssociatedLevelGeometry( AActor* Other )
{
	guard(AActor::HasAssociatedLevelGeometry);
	return 0;
	unguard;
}

void AActor::KFreezeRagdoll()
{
	guard(AActor::KFreezeRagdoll);
	// TODO: Freeze ragdoll simulation.
	unguard;
}

INT AActor::IsRelevantToPawnHeartBeat( APawn* P )
{
	guard(AActor::IsRelevantToPawnHeartBeat);
	return 0;
	unguard;
}

INT AActor::IsRelevantToPawnHeatVision( APawn* P )
{
	guard(AActor::IsRelevantToPawnHeatVision);
	return 0;
	unguard;
}

INT AActor::IsRelevantToPawnRadar( APawn* P )
{
	guard(AActor::IsRelevantToPawnRadar);
	return 0;
	unguard;
}

void AActor::CheckForErrors()
{
	guard(AActor::CheckForErrors);
	unguard;
}

void AActor::AddMyMarker( AActor* S )
{
	guard(AActor::AddMyMarker);
	unguard;
}

UBOOL AActor::IsOwnedBy( const AActor* TestOwner ) const
{
	guardSlow(AActor::IsOwnedBy);
	for( const AActor* Arg=this; Arg; Arg=Arg->Owner )
		if( Arg == TestOwner )
			return 1;
	return 0;
	unguardSlow;
}

UBOOL AActor::IsBasedOn( const AActor* Other ) const
{
	guard(AActor::IsBasedOn);
	for( const AActor* Test=this; Test!=NULL; Test=Test->Base )
		if( Test == Other )
			return 1;
	return 0;
	unguard;
}

UBOOL AActor::IsInZone( const AZoneInfo* TestZone ) const
{
	return Region.Zone!=Level ? Region.Zone==TestZone : 1;
}

FLOAT AActor::LifeFraction()
{
	return Clamp( 1.f - LifeSpan / GetClass()->GetDefaultActor()->LifeSpan, 0.f, 1.f );
}

INT AActor::IsJoinedTo( const AActor* Other ) const
{
	return 0;
}

INT AActor::TestCanSeeMe( APlayerController* Viewer )
{
	guard(AActor::TestCanSeeMe);
	return 0;
	unguard;
}

void AActor::UpdateRelativeRotation()
{
	guard(AActor::UpdateRelativeRotation);
	// TODO: Update relative rotation when attached.
	unguard;
}

void AActor::CheckNoiseHearing( FLOAT Loudness, ENoiseType NoiseType, EPawnType PawnType, ESoundType SoundType )
{
	guard(AActor::CheckNoiseHearing);
	// TODO: Propagate noise to AIs with hearing.
	unguard;
}

AActor* AActor::Trace( FVector& HitLocation, FVector& HitNormal, FVector& TraceEnd, FVector& TraceStart, INT bTraceActors, FVector& Extent, UMaterial** HitMaterial )
{
	guard(AActor::Trace);
	// TODO: World trace implementation.
	return NULL;
	unguard;
}

void AActor::GetNetBuoyancy( FLOAT& NetBuoyancy, FLOAT& NetFluidFriction )
{
	guard(AActor::GetNetBuoyancy);
	NetBuoyancy = Buoyancy;
	NetFluidFriction = 0.f;
	unguard;
}

void AActor::SafeDestroyActor( AActor* A )
{
	guard(AActor::SafeDestroyActor);
	if( A && !A->bDeleteMe )
		A->eventDestroyed();
	unguard;
}

void AActor::CopyR6Availability( AActor* Src )
{
	guard(AActor::CopyR6Availability);
	if( Src )
	{
		m_eStoryMode           = Src->m_eStoryMode;
		m_eMissionMode         = Src->m_eMissionMode;
		m_eTerroristHunt       = Src->m_eTerroristHunt;
		m_eTerroristHuntCoop   = Src->m_eTerroristHuntCoop;
		m_eHostageRescue       = Src->m_eHostageRescue;
		m_eHostageRescueCoop   = Src->m_eHostageRescueCoop;
		m_eHostageRescueAdv    = Src->m_eHostageRescueAdv;
		m_eDefend              = Src->m_eDefend;
		m_eDefendCoop          = Src->m_eDefendCoop;
		m_eRecon               = Src->m_eRecon;
		m_eReconCoop           = Src->m_eReconCoop;
		m_eDeathmatch          = Src->m_eDeathmatch;
		m_eTeamDeathmatch      = Src->m_eTeamDeathmatch;
		m_eBomb                = Src->m_eBomb;
		m_eEscort              = Src->m_eEscort;
		m_eLoneWolf            = Src->m_eLoneWolf;
		m_eSquadDeathmatch     = Src->m_eSquadDeathmatch;
		m_eSquadTeamDeathmatch = Src->m_eSquadTeamDeathmatch;
		m_eTerroristHuntAdv    = Src->m_eTerroristHuntAdv;
		m_eScatteredHuntAdv    = Src->m_eScatteredHuntAdv;
		m_eCaptureTheEnemyAdv  = Src->m_eCaptureTheEnemyAdv;
		m_eCountDown           = Src->m_eCountDown;
		m_eKamikaze            = Src->m_eKamikaze;
		m_eFreeBackupAdv       = Src->m_eFreeBackupAdv;
		m_eGazAlertAdv         = Src->m_eGazAlertAdv;
		m_eIntruderAdv         = Src->m_eIntruderAdv;
		m_eLimitSeatsAdv       = Src->m_eLimitSeatsAdv;
		m_eVirusUploadAdv      = Src->m_eVirusUploadAdv;
	}
	unguard;
}

FString AActor::GlobalIDToString( BYTE* const Bytes )
{
	guard(AActor::GlobalIDToString);
	// TODO: Convert 16-byte global ID to string representation.
	return FString();
	unguard;
}

void AActor::SecondsToString( INT TotalSeconds, INT bAlignMinOnTwoDigits, FString& Result )
{
	guard(AActor::SecondsToString);
	INT Minutes = TotalSeconds / 60;
	INT Seconds = TotalSeconds % 60;
	// TODO: Format string output.
	unguard;
}

void AActor::SaveServerOptions( FString FileName )
{
	guard(AActor::SaveServerOptions);
	unguard;
}

BYTE* AActor::GetR6AvailabilityPtr( FString GameType, INT Index )
{
	guard(AActor::GetR6AvailabilityPtr);
	return NULL;
	unguard;
}

INT AActor::IsAvailableInGameType( FString GameType )
{
	guard(AActor::IsAvailableInGameType);
	if( !m_bUseR6Availability )
		return 1;
	return 1;
	unguard;
}

INT AActor::NativeNonUbiMatchMaking()
{
	return 0;
}

INT AActor::NativeNonUbiMatchMakingHost()
{
	return 0;
}

INT AActor::NativeStartedByGSClient()
{
	return 0;
}

void AActor::DbgAddLine( FVector Start, FVector End, FColor Color )
{
	guard(AActor::DbgAddLine);
	unguard;
}

void AActor::DbgVectorAdd( FVector Point, FVector Cylinder, INT VectorIndex, FString Def, FColor* Color )
{
	guard(AActor::DbgVectorAdd);
	unguard;
}

void AActor::DbgVectorDraw( FLevelSceneNode* SceneNode, FRenderInterface& RI )
{
	guard(AActor::DbgVectorDraw);
	unguard;
}

void AActor::DbgVectorReset( INT VectorIndex )
{
	guard(AActor::DbgVectorReset);
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
