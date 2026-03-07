/*=============================================================================
	EngineExtra.cpp: Additional IMPLEMENT_CLASS registrations and exec
	function stubs required by Engine.def ordinal exports.
	
	These classes were not in the original Engine .cpp stubs but are
	referenced by the retail Engine.dll export table.
=============================================================================*/
#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	IMPLEMENT_CLASS registrations for all additional classes.
-----------------------------------------------------------------------------*/

// Parent / intermediate classes
IMPLEMENT_CLASS(UEngine);
IMPLEMENT_CLASS(UClient);
IMPLEMENT_CLASS(UInteractions);
IMPLEMENT_CLASS(UDownload);
IMPLEMENT_CLASS(UMatObject);
IMPLEMENT_CLASS(UPendingLevel);
IMPLEMENT_CLASS(ULodMeshInstance);
IMPLEMENT_CLASS(UCameraEffect);
IMPLEMENT_CLASS(UKarmaParamsCollision);
IMPLEMENT_CLASS(UVertexStreamBase);
IMPLEMENT_CLASS(UTexModifier);
IMPLEMENT_CLASS(UAnimNotify);
IMPLEMENT_CLASS(UMatAction);
IMPLEMENT_CLASS(UMatSubAction);

// Children of engine subsystem classes
IMPLEMENT_CLASS(UGameEngine);
IMPLEMENT_CLASS(UInteraction);
IMPLEMENT_CLASS(UInteractionMaster);
IMPLEMENT_CLASS(UConsole);
IMPLEMENT_CLASS(UInput);
IMPLEMENT_CLASS(UInputPlanning);
IMPLEMENT_CLASS(UPlayerInput);
IMPLEMENT_CLASS(UCheatManager);
IMPLEMENT_CLASS(UFont);
IMPLEMENT_CLASS(UAnimation);
IMPLEMENT_CLASS(UMeshAnimation);
IMPLEMENT_CLASS(UViewport);
IMPLEMENT_CLASS(UChannelDownload);
IMPLEMENT_CLASS(UBinaryFileDownload);
IMPLEMENT_CLASS(UDemoRecConnection);
IMPLEMENT_CLASS(UDemoRecDriver);
IMPLEMENT_CLASS(UNetPendingLevel);
IMPLEMENT_CLASS(UDemoPlayPendingLevel);
IMPLEMENT_CLASS(UNullRenderDevice);

// Primitive subclasses
IMPLEMENT_CLASS(UConvexVolume);
IMPLEMENT_CLASS(UFluidSurfacePrimitive);
IMPLEMENT_CLASS(UProjectorPrimitive);
IMPLEMENT_CLASS(UTerrainPrimitive);

// Mesh subclasses
IMPLEMENT_CLASS(UVertMesh);
IMPLEMENT_CLASS(UVertMeshInstance);

// Render resource subclasses
IMPLEMENT_CLASS(USkinVertexBuffer);
IMPLEMENT_CLASS(UIndexBuffer);
IMPLEMENT_CLASS(UVertexBuffer);
IMPLEMENT_CLASS(UVertexStreamCOLOR);
IMPLEMENT_CLASS(UVertexStreamPosNormTex);
IMPLEMENT_CLASS(UVertexStreamUV);
IMPLEMENT_CLASS(UVertexStreamVECTOR);

// Camera effect subclasses
IMPLEMENT_CLASS(UCameraOverlay);
IMPLEMENT_CLASS(UMotionBlur);

// Material subclasses
IMPLEMENT_CLASS(UFadeColor);
IMPLEMENT_CLASS(UDiffuseAttenuationMaterial);
IMPLEMENT_CLASS(UParticleMaterial);
IMPLEMENT_CLASS(UTerrainMaterial);
IMPLEMENT_CLASS(UTexCoordSource);
IMPLEMENT_CLASS(UProxyBitmapMaterial);
IMPLEMENT_CLASS(UShadowBitmapMaterial);
IMPLEMENT_CLASS(UMaterialSwitch);

// Karma params
IMPLEMENT_CLASS(UKarmaParams);
IMPLEMENT_CLASS(UKarmaParamsRBFull);
IMPLEMENT_CLASS(UKarmaParamsSkel);
IMPLEMENT_CLASS(UKMeshProps);

// Emitter subclasses
IMPLEMENT_CLASS(UBeamEmitter);
IMPLEMENT_CLASS(UMeshEmitter);
IMPLEMENT_CLASS(USparkEmitter);
IMPLEMENT_CLASS(USpriteEmitter);

// AnimNotify subclasses
IMPLEMENT_CLASS(UAnimNotify_DestroyEffect);
IMPLEMENT_CLASS(UAnimNotify_Effect);
IMPLEMENT_CLASS(UAnimNotify_MatSubAction);
IMPLEMENT_CLASS(UAnimNotify_Script);
IMPLEMENT_CLASS(UAnimNotify_Scripted);
IMPLEMENT_CLASS(UAnimNotify_Sound);

// Matinee action subclasses
IMPLEMENT_CLASS(UActionMoveCamera);
IMPLEMENT_CLASS(UActionMoveActor);
IMPLEMENT_CLASS(UActionPause);
IMPLEMENT_CLASS(USubActionCameraEffect);
IMPLEMENT_CLASS(USubActionCameraShake);
IMPLEMENT_CLASS(USubActionFade);
IMPLEMENT_CLASS(USubActionFOV);
IMPLEMENT_CLASS(USubActionGameSpeed);
IMPLEMENT_CLASS(USubActionOrientation);
IMPLEMENT_CLASS(USubActionSceneSpeed);
IMPLEMENT_CLASS(USubActionTrigger);

// Misc UObject subclasses
IMPLEMENT_CLASS(ULevelSummary);
IMPLEMENT_CLASS(UReachSpec);
IMPLEMENT_CLASS(UTerrainSector);
IMPLEMENT_CLASS(UI3DL2Listener);
IMPLEMENT_CLASS(USoundGen);
IMPLEMENT_CLASS(UServerCommandlet);
IMPLEMENT_CLASS(UR6FileManager);
IMPLEMENT_CLASS(UR6GameColors);
IMPLEMENT_CLASS(UR6GameMenuCom);
IMPLEMENT_CLASS(UR6Mod);
IMPLEMENT_CLASS(UR6AbstractPlanningInfo);
IMPLEMENT_CLASS(UR6AbstractTerroristMgr);

// Actor subclasses — navigation / AI
IMPLEMENT_CLASS(ACamera);
IMPLEMENT_CLASS(AScout);
IMPLEMENT_CLASS(AStatLog);
IMPLEMENT_CLASS(AStatLogFile);
IMPLEMENT_CLASS(AActorManager);
IMPLEMENT_CLASS(AAIMarker);
IMPLEMENT_CLASS(AAIScript);
IMPLEMENT_CLASS(ADoor);
IMPLEMENT_CLASS(AFluidSurfaceOscillator);
IMPLEMENT_CLASS(AFluidSurfaceInfo);
IMPLEMENT_CLASS(AInternetInfo);
IMPLEMENT_CLASS(AInterpolationPoint);
IMPLEMENT_CLASS(AJumpDest);
IMPLEMENT_CLASS(AJumpPad);
IMPLEMENT_CLASS(AKConstraint);
IMPLEMENT_CLASS(AKBSJoint);
IMPLEMENT_CLASS(AKConeLimit);
IMPLEMENT_CLASS(AKHinge);
IMPLEMENT_CLASS(ALadder);
IMPLEMENT_CLASS(ALadderVolume);
IMPLEMENT_CLASS(ALiftCenter);
IMPLEMENT_CLASS(ALiftExit);
IMPLEMENT_CLASS(ALineOfSightTrigger);
IMPLEMENT_CLASS(ALookTarget);
IMPLEMENT_CLASS(AMapList);
IMPLEMENT_CLASS(APathNode);
IMPLEMENT_CLASS(APlayerStart);
IMPLEMENT_CLASS(APotentialClimbWatcher);
IMPLEMENT_CLASS(AR6MapList);
IMPLEMENT_CLASS(ASavedMove);
IMPLEMENT_CLASS(ASceneManager);
IMPLEMENT_CLASS(ASkyZoneInfo);
IMPLEMENT_CLASS(ATeleporter);
IMPLEMENT_CLASS(ATerrainInfo);
IMPLEMENT_CLASS(AWarpZoneInfo);
IMPLEMENT_CLASS(AWarpZoneMarker);

// RVS-specific actor subclasses
IMPLEMENT_CLASS(AR6AbstractCircumstantialActionQuery);
IMPLEMENT_CLASS(AR6AbstractClimbableObj);
IMPLEMENT_CLASS(AR6ActionPointAbstract);
IMPLEMENT_CLASS(AR6ActionSpot);
IMPLEMENT_CLASS(AR6ColBox);
IMPLEMENT_CLASS(AR6DecalsBase);
IMPLEMENT_CLASS(AR6Decal);
IMPLEMENT_CLASS(AR6DecalGroup);
IMPLEMENT_CLASS(AR6DecalManager);
IMPLEMENT_CLASS(AR6EngineFirstPersonWeapon);
IMPLEMENT_CLASS(AR6EngineWeapon);
IMPLEMENT_CLASS(AR6FootStep);
IMPLEMENT_CLASS(AR6GlowLight);
IMPLEMENT_CLASS(AR6RainbowStartInfo);
IMPLEMENT_CLASS(AR6StartGameInfo);
IMPLEMENT_CLASS(AR6TeamStartInfo);
IMPLEMENT_CLASS(AR6WallHit);

/*-----------------------------------------------------------------------------
	Exec function stubs and IMPLEMENT_FUNCTION registrations.
	These satisfy the .def native int exports.
-----------------------------------------------------------------------------*/

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

// AActor — Karma physics functions
EXEC_STUB(AActor,execGetServerOptionsRefreshed)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetServerOptionsRefreshed );
EXEC_STUB(AActor,execKAddBoneLifter)       IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKAddBoneLifter );
EXEC_STUB(AActor,execKAddImpulse)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKAddImpulse );
EXEC_STUB(AActor,execKDisableCollision)    IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKDisableCollision );
EXEC_STUB(AActor,execKEnableCollision)     IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKEnableCollision );
EXEC_STUB(AActor,execKFreezeRagdoll)       IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKFreezeRagdoll );
EXEC_STUB(AActor,execKGetActorGravScale)   IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetActorGravScale );
EXEC_STUB(AActor,execKGetCOMOffset)        IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMOffset );
EXEC_STUB(AActor,execKGetCOMPosition)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMPosition );
EXEC_STUB(AActor,execKGetDampingProps)     IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetDampingProps );
EXEC_STUB(AActor,execKGetFriction)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetFriction );
EXEC_STUB(AActor,execKGetImpactThreshold)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetImpactThreshold );
EXEC_STUB(AActor,execKGetInertiaTensor)    IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetInertiaTensor );
EXEC_STUB(AActor,execKGetMass)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetMass );
EXEC_STUB(AActor,execKGetRestitution)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetRestitution );
EXEC_STUB(AActor,execKGetSkelMass)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetSkelMass );
EXEC_STUB(AActor,execKIsAwake)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsAwake );
EXEC_STUB(AActor,execKIsRagdollAvailable)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsRagdollAvailable );
EXEC_STUB(AActor,execKMakeRagdollAvailable) IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMakeRagdollAvailable );
EXEC_STUB(AActor,execKMP2IOKarmaAllNativeFct) IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMP2IOKarmaAllNativeFct );
EXEC_STUB(AActor,execKRemoveAllBoneLifters) IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveAllBoneLifters );
EXEC_STUB(AActor,execKRemoveLifterFromBone) IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveLifterFromBone );
EXEC_STUB(AActor,execKSetActorGravScale)   IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetActorGravScale );
EXEC_STUB(AActor,execKSetBlockKarma)       IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetBlockKarma );
EXEC_STUB(AActor,execKSetCOMOffset)        IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetCOMOffset );
EXEC_STUB(AActor,execKSetDampingProps)     IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetDampingProps );
EXEC_STUB(AActor,execKSetFriction)         IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetFriction );
EXEC_STUB(AActor,execKSetImpactThreshold)  IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetImpactThreshold );
EXEC_STUB(AActor,execKSetInertiaTensor)    IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetInertiaTensor );
EXEC_STUB(AActor,execKSetMass)             IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetMass );
EXEC_STUB(AActor,execKSetRestitution)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetRestitution );
EXEC_STUB(AActor,execKSetSkelVel)          IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetSkelVel );
EXEC_STUB(AActor,execKSetStayUpright)      IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetStayUpright );
EXEC_STUB(AActor,execKWake)                IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKWake );

// AVolume
EXEC_STUB(AVolume,execEncompasses)         IMPLEMENT_FUNCTION( AVolume, INDEX_NONE, execEncompasses );

// AZoneInfo
EXEC_STUB(AZoneInfo,execZoneActors)        IMPLEMENT_FUNCTION( AZoneInfo, 308, execZoneActors );

// AWarpZoneInfo
EXEC_STUB(AWarpZoneInfo,execWarp)          IMPLEMENT_FUNCTION( AWarpZoneInfo, 314, execWarp );
EXEC_STUB(AWarpZoneInfo,execUnWarp)        IMPLEMENT_FUNCTION( AWarpZoneInfo, 315, execUnWarp );

// AFluidSurfaceInfo
EXEC_STUB(AFluidSurfaceInfo,execPling)     IMPLEMENT_FUNCTION( AFluidSurfaceInfo, INDEX_NONE, execPling );

// AKConstraint
EXEC_STUB(AKConstraint,execKGetConstraintForce)   IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintForce );
EXEC_STUB(AKConstraint,execKGetConstraintTorque)   IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintTorque );
EXEC_STUB(AKConstraint,execKUpdateConstraintParams) IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKUpdateConstraintParams );

// ASceneManager
EXEC_STUB(ASceneManager,execGetTotalSceneTime) IMPLEMENT_FUNCTION( ASceneManager, INDEX_NONE, execGetTotalSceneTime );
EXEC_STUB(ASceneManager,execSceneDestroyed)    IMPLEMENT_FUNCTION( ASceneManager, 2909, execSceneDestroyed );
EXEC_STUB(ASceneManager,execTerminateAIAction) IMPLEMENT_FUNCTION( ASceneManager, 2906, execTerminateAIAction );

// AStatLog
EXEC_STUB(AStatLog,execBatchLocal)              IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBatchLocal );
EXEC_STUB(AStatLog,execBrowseRelativeLocalURL)  IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBrowseRelativeLocalURL );
EXEC_STUB(AStatLog,execExecuteLocalLogBatcher)  IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteLocalLogBatcher );
EXEC_STUB(AStatLog,execExecuteSilentLogBatcher) IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteSilentLogBatcher );
EXEC_STUB(AStatLog,execExecuteWorldLogBatcher)  IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteWorldLogBatcher );
EXEC_STUB(AStatLog,execGetGMTRef)               IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetGMTRef );
EXEC_STUB(AStatLog,execGetMapFileName)           IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetMapFileName );
EXEC_STUB(AStatLog,execGetPlayerChecksum)        IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetPlayerChecksum );
EXEC_STUB(AStatLog,execInitialCheck)             IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execInitialCheck );

// AStatLogFile
EXEC_STUB(AStatLogFile,execCloseLog)     IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execCloseLog );
EXEC_STUB(AStatLogFile,execFileFlush)    IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileFlush );
EXEC_STUB(AStatLogFile,execFileLog)      IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileLog );
EXEC_STUB(AStatLogFile,execGetChecksum)  IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execGetChecksum );
EXEC_STUB(AStatLogFile,execOpenLog)      IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execOpenLog );
EXEC_STUB(AStatLogFile,execWatermark)    IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execWatermark );

// AR6ColBox
EXEC_STUB(AR6ColBox,execEnableCollision)       IMPLEMENT_FUNCTION( AR6ColBox, 1503, execEnableCollision );

// AR6DecalGroup
EXEC_STUB(AR6DecalGroup,execActivateGroup)     IMPLEMENT_FUNCTION( AR6DecalGroup, 2904, execActivateGroup );
EXEC_STUB(AR6DecalGroup,execAddDecal)          IMPLEMENT_FUNCTION( AR6DecalGroup, 2902, execAddDecal );
EXEC_STUB(AR6DecalGroup,execDeActivateGroup)   IMPLEMENT_FUNCTION( AR6DecalGroup, 2905, execDeActivateGroup );
EXEC_STUB(AR6DecalGroup,execKillDecal)         IMPLEMENT_FUNCTION( AR6DecalGroup, 2903, execKillDecal );

// AR6DecalManager
EXEC_STUB(AR6DecalManager,execAddDecal)        IMPLEMENT_FUNCTION( AR6DecalManager, 2900, execAddDecal );
EXEC_STUB(AR6DecalManager,execKillDecal)       IMPLEMENT_FUNCTION( AR6DecalManager, 2901, execKillDecal );

// AR6eviLTesting
EXEC_STUB(AR6eviLTesting,execNativeRunAllTests) IMPLEMENT_FUNCTION( AR6eviLTesting, 1356, execNativeRunAllTests );

// UInteraction
EXEC_STUB(UInteraction,execConsoleCommand) IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execConsoleCommand );
EXEC_STUB(UInteraction,execInitialize)     IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execInitialize );
EXEC_STUB(UInteraction,execScreenToWorld)  IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execScreenToWorld );
EXEC_STUB(UInteraction,execWorldToScreen)  IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execWorldToScreen );

// UInteractionMaster
EXEC_STUB(UInteractionMaster,execTravel)   IMPLEMENT_FUNCTION( UInteractionMaster, INDEX_NONE, execTravel );

// UR6AbstractGameManager
EXEC_STUB(UR6AbstractGameManager,execClientLeaveServer)       IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execClientLeaveServer );
EXEC_STUB(UR6AbstractGameManager,execConnectionInterrupted)   IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execConnectionInterrupted );
EXEC_STUB(UR6AbstractGameManager,execIsGSCreateUbiServer)     IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execIsGSCreateUbiServer );
EXEC_STUB(UR6AbstractGameManager,execLaunchListenSrv)         IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execLaunchListenSrv );
EXEC_STUB(UR6AbstractGameManager,execSetGSCreateUbiServer)    IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execSetGSCreateUbiServer );
EXEC_STUB(UR6AbstractGameManager,execStartJoinServer)         IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartJoinServer );
EXEC_STUB(UR6AbstractGameManager,execStartLogInProcedure)     IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartLogInProcedure );
EXEC_STUB(UR6AbstractGameManager,execStartPreJoinProcedure)   IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartPreJoinProcedure );
EXEC_STUB(UR6AbstractGameManager,execStopGSClientProcedure)   IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStopGSClientProcedure );

// UR6FileManager
EXEC_STUB(UR6FileManager,execDeleteFile)   IMPLEMENT_FUNCTION( UR6FileManager, 1527, execDeleteFile );
EXEC_STUB(UR6FileManager,execFindFile)     IMPLEMENT_FUNCTION( UR6FileManager, 1528, execFindFile );
EXEC_STUB(UR6FileManager,execGetFileName)  IMPLEMENT_FUNCTION( UR6FileManager, 1526, execGetFileName );
EXEC_STUB(UR6FileManager,execGetNbFile)    IMPLEMENT_FUNCTION( UR6FileManager, 1525, execGetNbFile );

// UR6ModMgr
EXEC_STUB(UR6ModMgr,execAddNewModExtraPath)     IMPLEMENT_FUNCTION( UR6ModMgr, 2020, execAddNewModExtraPath );
EXEC_STUB(UR6ModMgr,execCallSndEngineInit)      IMPLEMENT_FUNCTION( UR6ModMgr, 3003, execCallSndEngineInit );
EXEC_STUB(UR6ModMgr,execGetASBuildVersion)       IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetASBuildVersion );
EXEC_STUB(UR6ModMgr,execGetIWBuildVersion)       IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetIWBuildVersion );
EXEC_STUB(UR6ModMgr,execIsOfficialMod)           IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execIsOfficialMod );
EXEC_STUB(UR6ModMgr,execSetGeneralModSettings)   IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execSetGeneralModSettings );
EXEC_STUB(UR6ModMgr,execSetSystemMod)            IMPLEMENT_FUNCTION( UR6ModMgr, 2021, execSetSystemMod );

#undef EXEC_STUB

/*-----------------------------------------------------------------------------
	PunkBuster export.
-----------------------------------------------------------------------------*/

extern "C" ENGINE_API void pb_Export() {}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
