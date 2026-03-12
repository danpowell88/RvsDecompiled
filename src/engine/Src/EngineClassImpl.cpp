/*=============================================================================
	EngineClassImpl.cpp: IMPLEMENT_CLASS registrations, exec function stubs,
	constructor shims, and class method implementations for Engine.dll
	exports that don't have dedicated Un*.cpp files.

	Why this file exists
	--------------------
	Unreal's class/property system uses static C++ objects to register
	each UClass with the engine at DLL load time. The IMPLEMENT_CLASS()
	macro creates one of these static objects. The retail Engine.dll
	exports hundreds of classes; each one needs an IMPLEMENT_CLASS() in
	exactly one translation unit or the linker drops the registration
	and the engine can't find the class at runtime.

	Similarly, UnrealScript native functions (exec* methods) must each
	have an IMPLEMENT_FUNCTION() registration so the VM can bind the
	script bytecode index to the C++ function pointer.

	This file collects all such registrations for classes that don't
	yet have a full decompiled Un*.cpp file. As classes are properly
	reconstructed, their IMPLEMENT_CLASS / IMPLEMENT_FUNCTION lines
	should migrate to the appropriate Un*.cpp and be removed from here.

	Additionally this file contains:
	  - Constructor bodies (AActor, APawn)
	  - FMatrix copy-ctor linker shim (retail Core.lib doesn't export it)
	  - Misc class method bodies (ABrush, ANavigationPoint, UGameEngine,
	    UViewport, UModel, UNetConnection, UChannel, ASceneManager, ...)
	  - Virtual method overrides needed because the vtable is instantiated
	    in this DLL (UCanvas, UNetDriver, UMaterial, AReplicationInfo)
=============================================================================*/
#include "EnginePrivate.h"
#include <string.h>  // memcpy

/*-----------------------------------------------------------------------------
	Missing constructors.
	
	AActor() and APawn() default constructors are declared in the SDK but
	the bodies are trivial — the UObject property system handles real
	initialisation via InitProperties().  We provide empty bodies so the
	linker is satisfied (DECLARE_CLASS's InternalConstructor calls them).

	FMatrix copy constructor — the retail Core.lib does not export the
	compiler-generated copy ctor (__imp_??0FMatrix@@QAE@ABV0@@Z).
	Because FMatrix is CORE_API (dllimport in Engine), we cannot simply
	define a member function.  Instead we wire a local implementation
	into the __imp_ thunk that the compiler emits for dllimport calls.
-----------------------------------------------------------------------------*/

AActor::AActor() {}
APawn::APawn() {}

/* FMatrix copy-ctor shim:
   1. local_FMatrix_CopyCtor — __fastcall mirrors __thiscall on x86
      (ECX = this, EDX unused, args on stack).
   2. imp_FMatrix_CopyCtor   — C-linkage pointer variable the linker
      resolves __imp_??0FMatrix@@QAE@ABV0@@Z to via /alternatename.     */
static void __fastcall local_FMatrix_CopyCtor(
	void* _this, void* /*edx*/, const void* src)
{
	memcpy(_this, src, sizeof(FMatrix));  // 4 x FPlane = 64 bytes
}
extern "C" { void* imp_FMatrix_CopyCtor = (void*)&local_FMatrix_CopyCtor; }
#pragma comment(linker, "/alternatename:__imp_??0FMatrix@@QAE@ABV0@@Z=_imp_FMatrix_CopyCtor")

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
	Exec function implementations and IMPLEMENT_FUNCTION registrations.
	These satisfy the .def native int exports.
-----------------------------------------------------------------------------*/

/*-- AActor Karma physics functions (Karma not implemented — stubs) -----*/

void AActor::execGetServerOptionsRefreshed( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerOptionsRefreshed);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetServerOptionsRefreshed );

void AActor::execKAddBoneLifter( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKAddBoneLifter);
	P_GET_NAME(BoneName);
	P_GET_VECTOR(LiftVel);
	P_GET_FLOAT(LateralFriction);
	P_GET_FLOAT(DampFactor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKAddBoneLifter );

void AActor::execKAddImpulse( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKAddImpulse);
	P_GET_VECTOR(Impulse);
	P_GET_VECTOR(Position);
	P_GET_NAME_OPTX(BoneName,NAME_None);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKAddImpulse );

void AActor::execKDisableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKDisableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKDisableCollision );

void AActor::execKEnableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKEnableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKEnableCollision );

void AActor::execKFreezeRagdoll( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKFreezeRagdoll);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKFreezeRagdoll );

void AActor::execKGetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetActorGravScale);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetActorGravScale );

void AActor::execKGetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMOffset);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMOffset );

void AActor::execKGetCOMPosition( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMPosition);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMPosition );

void AActor::execKGetDampingProps( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetDampingProps);
	P_GET_FLOAT_REF(LinDamping);
	P_GET_FLOAT_REF(AngDamping);
	P_FINISH;
	*LinDamping = 0.f;
	*AngDamping = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetDampingProps );

void AActor::execKGetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetFriction);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetFriction );

void AActor::execKGetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetImpactThreshold);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetImpactThreshold );

void AActor::execKGetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetInertiaTensor);
	P_GET_VECTOR_REF(InertiaTensor);
	P_FINISH;
	*InertiaTensor = FVector(1,1,1);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetInertiaTensor );

void AActor::execKGetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetMass );

void AActor::execKGetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetRestitution);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetRestitution );

void AActor::execKGetSkelMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetSkelMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetSkelMass );

void AActor::execKIsAwake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsAwake);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsAwake );

void AActor::execKIsRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsRagdollAvailable);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsRagdollAvailable );

void AActor::execKMakeRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMakeRagdollAvailable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMakeRagdollAvailable );

void AActor::execKMP2IOKarmaAllNativeFct( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMP2IOKarmaAllNativeFct);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMP2IOKarmaAllNativeFct );

void AActor::execKRemoveAllBoneLifters( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveAllBoneLifters);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveAllBoneLifters );

void AActor::execKRemoveLifterFromBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveLifterFromBone);
	P_GET_NAME(BoneName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveLifterFromBone );

void AActor::execKSetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetActorGravScale);
	P_GET_FLOAT(NewGravScale);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetActorGravScale );

void AActor::execKSetBlockKarma( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetBlockKarma);
	P_GET_UBOOL(bBlock);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetBlockKarma );

void AActor::execKSetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetCOMOffset);
	P_GET_VECTOR(Offset);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetCOMOffset );

void AActor::execKSetDampingProps( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetDampingProps);
	P_GET_FLOAT(LinDamping);
	P_GET_FLOAT(AngDamping);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetDampingProps );

void AActor::execKSetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetFriction);
	P_GET_FLOAT(Friction);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetFriction );

void AActor::execKSetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetImpactThreshold);
	P_GET_FLOAT(Threshold);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetImpactThreshold );

void AActor::execKSetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetInertiaTensor);
	P_GET_VECTOR(InertiaTensor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetInertiaTensor );

void AActor::execKSetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetMass);
	P_GET_FLOAT(Mass);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetMass );

void AActor::execKSetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetRestitution);
	P_GET_FLOAT(Restitution);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetRestitution );

void AActor::execKSetSkelVel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetSkelVel);
	P_GET_VECTOR(Velocity);
	P_GET_VECTOR_OPTX(AngVelocity,FVector(0,0,0));
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetSkelVel );

void AActor::execKSetStayUpright( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetStayUpright);
	P_GET_UBOOL(bStayUpright);
	P_GET_UBOOL_OPTX(bSpin,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetStayUpright );

void AActor::execKWake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKWake);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKWake );

/*-- AVolume -----------------------------------------------------------*/

void AVolume::execEncompasses( FFrame& Stack, RESULT_DECL )
{
	guard(AVolume::execEncompasses);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	*(DWORD*)Result = Other ? Encompasses( Other->Location ) : 0;
	unguard;
}
IMPLEMENT_FUNCTION( AVolume, INDEX_NONE, execEncompasses );

/*-- AZoneInfo ---------------------------------------------------------*/

void AZoneInfo::execZoneActors( FFrame& Stack, RESULT_DECL )
{
	guard(AZoneInfo::execZoneActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_FINISH;

	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			if( *Actor && (*Actor)->IsA(BaseClass) && (*Actor)->Region.Zone == this )
				break;
			*Actor = NULL;
		}
		if( *Actor == NULL )
		{
			Stack.Code = &Stack.Node->Script(wEndOffset + 1);
			break;
		}
	POST_ITERATOR;
	unguard;
}
IMPLEMENT_FUNCTION( AZoneInfo, 308, execZoneActors );

/*-- AWarpZoneInfo -----------------------------------------------------*/

void AWarpZoneInfo::execWarp( FFrame& Stack, RESULT_DECL )
{
	guard(AWarpZoneInfo::execWarp);
	P_GET_VECTOR_REF(Loc);
	P_GET_VECTOR_REF(Vel);
	P_GET_ROTATOR_REF(R);
	P_FINISH;
	// Transform through warp zone coords.
	unguard;
}
IMPLEMENT_FUNCTION( AWarpZoneInfo, 314, execWarp );

void AWarpZoneInfo::execUnWarp( FFrame& Stack, RESULT_DECL )
{
	guard(AWarpZoneInfo::execUnWarp);
	P_GET_VECTOR_REF(Loc);
	P_GET_VECTOR_REF(Vel);
	P_GET_ROTATOR_REF(R);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AWarpZoneInfo, 315, execUnWarp );

/*-- AFluidSurfaceInfo -------------------------------------------------*/

void AFluidSurfaceInfo::execPling( FFrame& Stack, RESULT_DECL )
{
	guard(AFluidSurfaceInfo::execPling);
	P_GET_VECTOR(Position);
	P_GET_FLOAT(Strength);
	P_GET_INT(Radius);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AFluidSurfaceInfo, INDEX_NONE, execPling );

/*-- AKConstraint ------------------------------------------------------*/

void AKConstraint::execKGetConstraintForce( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintForce);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintForce );

void AKConstraint::execKGetConstraintTorque( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintTorque);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintTorque );

void AKConstraint::execKUpdateConstraintParams( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKUpdateConstraintParams);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKUpdateConstraintParams );

/*-- ASceneManager -----------------------------------------------------*/

void ASceneManager::execGetTotalSceneTime( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execGetTotalSceneTime);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, INDEX_NONE, execGetTotalSceneTime );

void ASceneManager::execSceneDestroyed( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execSceneDestroyed);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2909, execSceneDestroyed );

void ASceneManager::execTerminateAIAction( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execTerminateAIAction);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2906, execTerminateAIAction );

/*-- AStatLog ----------------------------------------------------------*/

void AStatLog::execBatchLocal( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBatchLocal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBatchLocal );

void AStatLog::execBrowseRelativeLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBrowseRelativeLocalURL);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBrowseRelativeLocalURL );

void AStatLog::execExecuteLocalLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteLocalLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteLocalLogBatcher );

void AStatLog::execExecuteSilentLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteSilentLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteSilentLogBatcher );

void AStatLog::execExecuteWorldLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteWorldLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteWorldLogBatcher );

void AStatLog::execGetGMTRef( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetGMTRef);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetGMTRef );

void AStatLog::execGetMapFileName( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetMapFileName);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetMapFileName );

void AStatLog::execGetPlayerChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetPlayerChecksum);
	P_GET_OBJECT(AActor,P);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetPlayerChecksum );

void AStatLog::execInitialCheck( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execInitialCheck);
	P_GET_OBJECT(AActor,Game);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execInitialCheck );

/*-- AStatLogFile ------------------------------------------------------*/

void AStatLogFile::execCloseLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execCloseLog);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execCloseLog );

void AStatLogFile::execFileFlush( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileFlush);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileFlush );

void AStatLogFile::execFileLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileLog);
	P_GET_STR(Item);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileLog );

void AStatLogFile::execGetChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execGetChecksum);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execGetChecksum );

void AStatLogFile::execOpenLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execOpenLog);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execOpenLog );

void AStatLogFile::execWatermark( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execWatermark);
	P_GET_STR(Item);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execWatermark );

/*-- AR6ColBox ---------------------------------------------------------*/

void AR6ColBox::execEnableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AR6ColBox::execEnableCollision);
	P_GET_UBOOL(bEnable);
	P_FINISH;
	SetCollision( bEnable, bBlockActors, bBlockPlayers );
	unguard;
}
IMPLEMENT_FUNCTION( AR6ColBox, 1503, execEnableCollision );

/*-- AR6DecalGroup & AR6DecalManager -----------------------------------*/

void AR6DecalGroup::execActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execActivateGroup);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2904, execActivateGroup );

void AR6DecalGroup::execAddDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execAddDecal);
	P_GET_VECTOR(HitLocation);
	P_GET_ROTATOR(HitRotation);
	P_GET_FLOAT_OPTX(DecalSize,1.f);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2902, execAddDecal );

void AR6DecalGroup::execDeActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execDeActivateGroup);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2905, execDeActivateGroup );

void AR6DecalGroup::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2903, execKillDecal );

void AR6DecalManager::execAddDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalManager::execAddDecal);
	P_GET_VECTOR(HitLocation);
	P_GET_ROTATOR(HitRotation);
	P_GET_FLOAT_OPTX(DecalSize,1.f);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalManager, 2900, execAddDecal );

void AR6DecalManager::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalManager::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalManager, 2901, execKillDecal );

/*-- AR6eviLTesting ----------------------------------------------------*/

void AR6eviLTesting::execNativeRunAllTests( FFrame& Stack, RESULT_DECL )
{
	guard(AR6eviLTesting::execNativeRunAllTests);
	P_FINISH;
	debugf( TEXT("NativeRunAllTests: no tests implemented") );
	unguard;
}
IMPLEMENT_FUNCTION( AR6eviLTesting, 1356, execNativeRunAllTests );

/*-- UInteraction ------------------------------------------------------*/

void UInteraction::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execConsoleCommand );

void UInteraction::execInitialize( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execInitialize);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execInitialize );

// =============================================================================
// ABrush
// =============================================================================

void ABrush::PostLoad() { Super::PostLoad(); }
void ABrush::PostEditChange() { Super::PostEditChange(); }
FCoords ABrush::ToLocal() const { return FCoords(); }
FCoords ABrush::ToWorld() const { return FCoords(); }
UPrimitive* ABrush::GetPrimitive()
{
	// Retail (27b, RVA 0x78E20): check Brush/UModel primitive field, then
	// fall through to the same nested StaticMeshInstance-like chain at +0x328.
	UPrimitive* p;
	if ((p = *(UPrimitive**)((BYTE*)this + 0x178)) != NULL) return p; // Brush/UModel
	void* c = *(void**)((BYTE*)this + 0x328);
	if (!c) return NULL;
	p = *(UPrimitive**)((BYTE*)c + 0x44);
	if (!p) return NULL;
	return *(UPrimitive**)((BYTE*)p + 0x40);
}
void ABrush::CheckForErrors() { Super::CheckForErrors(); }
void ABrush::CopyPosRotScaleFrom(ABrush* Other) {}
void ABrush::InitPosRotScale() {}
FLOAT ABrush::BuildCoords(FModelCoords* Coords, FModelCoords* UnCoords) { return 0.0f; }
FLOAT ABrush::OldBuildCoords(FModelCoords* Coords, FModelCoords* UnCoords) { return 0.0f; }
FCoords ABrush::OldToLocal() const { return FCoords(); }
FCoords ABrush::OldToWorld() const { return FCoords(); }

// =============================================================================
// ANavigationPoint
// =============================================================================

void ANavigationPoint::Destroy() { Super::Destroy(); }
void ANavigationPoint::PostEditMove() {}
void ANavigationPoint::Spawned()
{
	// Retail (27b, RVA 0xD5B50): clear bit 11 (bPathsChanged) of Zone's flags at +0x450,
	// then mark our own bPathsChanged = 1.
	AZoneInfo* Z = Region.Zone;
	*(DWORD*)((BYTE*)Z + 0x450) &= ~0x800u;
	bPathsChanged = 1;
}
void ANavigationPoint::InitForPathFinding() {}
void ANavigationPoint::CheckSymmetry(ANavigationPoint* Other) {}
void ANavigationPoint::PostaddReachSpecs(APawn* Scout) {}
void ANavigationPoint::SetVolumes(const TArray<AVolume*>& Volumes) {}
void ANavigationPoint::CheckForErrors() { Super::CheckForErrors(); }
INT ANavigationPoint::ProscribedPathTo(ANavigationPoint* Nav) { return 0; }
void ANavigationPoint::addReachSpecs(APawn* Scout, INT bOnlyChanged) {}
void ANavigationPoint::SetupForcedPath(APawn* Scout, UReachSpec* Spec) {}
void ANavigationPoint::ClearPaths()
{
	// Retail: 104b SEH. Zeros the 4 path-chain pointer fields, then empties PathList.
	// PathList confirmed at this+0x3D8 via disassembly; chain ptrs from +0x3A8.
	nextNavigationPoint = NULL;
	nextOrdered         = NULL;
	prevOrdered         = NULL;
	previousPath        = NULL;
	((TArray<UReachSpec*>*)((BYTE*)this + 0x3D8))->Empty();
}
void ANavigationPoint::FindBase() {}
INT ANavigationPoint::PrunePaths() { return 0; }
INT ANavigationPoint::IsIdentifiedAs(FName Name) { return 0; }
INT ANavigationPoint::ReviewPath(APawn* Scout) { return 0; }
INT ANavigationPoint::CanReach(ANavigationPoint* Nav, FLOAT Dist) { return 0; }
void ANavigationPoint::CleanUpPruned()
{
	// Retail: 124b SEH. Iterates PathList backwards, removing specs with bPruned set.
	// Finishes with TArray::Shrink to release excess memory.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = myPathList->Num() - 1; i >= 0; i--)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec && Spec->bPruned)
			myPathList->Remove(i, 1);
	}
	myPathList->Shrink();
}
INT ANavigationPoint::FindAlternatePath(UReachSpec* Spec, INT bOnlyChanged) { return 0; }
UReachSpec* ANavigationPoint::GetReachSpecTo(ANavigationPoint* Nav)
{
	// Retail: 103b SEH. Linear scan of PathList (at this+0x3D8) for spec->End == Nav.
	TArray<UReachSpec*>* myPathList = (TArray<UReachSpec*>*)((BYTE*)this + 0x3D8);
	for (INT i = 0; i < myPathList->Num(); i++)
	{
		UReachSpec* Spec = (*myPathList)(i);
		if (Spec->End == Nav)
			return Spec;
	}
	return NULL;
}
INT ANavigationPoint::ShouldBeBased()
{
	// Retail: 32b (JNZ at +24 uses shared return-0 epilog 3 bytes past function end).
	// Check the object at this+0x164 (Level): if [Level+0x410] bit 6 is set => always base nav point.
	// Otherwise check bNotBased (bit 10 of bitfield DWORD at this+0x3A4): if set => return 0.
	BYTE* levelObj = *(BYTE**)((BYTE*)this + 0x164);
	if (*(BYTE*)(levelObj + 0x410) & 0x40)
		return 1;
	return bNotBased ? 0 : 1;
}

/*-- UInteraction screen/world transforms ------------------------------*/

void UInteraction::execScreenToWorld( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execScreenToWorld);
	P_GET_VECTOR(ScreenLoc);
	P_GET_VECTOR_REF(WorldLoc);
	P_FINISH;
	*WorldLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execScreenToWorld );

void UInteraction::execWorldToScreen( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execWorldToScreen);
	P_GET_VECTOR(WorldLoc);
	P_GET_VECTOR_REF(ScreenLoc);
	P_FINISH;
	*ScreenLoc = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execWorldToScreen );

/*-- UInteractionMaster ------------------------------------------------*/

void UInteractionMaster::execTravel( FFrame& Stack, RESULT_DECL )
{
	guard(UInteractionMaster::execTravel);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UInteractionMaster, INDEX_NONE, execTravel );

/*-- UR6AbstractGameManager -------------------------------------------*/

void UR6AbstractGameManager::execClientLeaveServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execClientLeaveServer);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execClientLeaveServer );

void UR6AbstractGameManager::execConnectionInterrupted( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execConnectionInterrupted);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execConnectionInterrupted );

void UR6AbstractGameManager::execIsGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execIsGSCreateUbiServer);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execIsGSCreateUbiServer );

void UR6AbstractGameManager::execLaunchListenSrv( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execLaunchListenSrv);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execLaunchListenSrv );

void UR6AbstractGameManager::execSetGSCreateUbiServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execSetGSCreateUbiServer);
	P_GET_UBOOL(bCreate);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execSetGSCreateUbiServer );

void UR6AbstractGameManager::execStartJoinServer( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartJoinServer);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartJoinServer );

void UR6AbstractGameManager::execStartLogInProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartLogInProcedure);
	P_GET_STR(Username);
	P_GET_STR(Password);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartLogInProcedure );

void UR6AbstractGameManager::execStartPreJoinProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStartPreJoinProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStartPreJoinProcedure );

void UR6AbstractGameManager::execStopGSClientProcedure( FFrame& Stack, RESULT_DECL )
{
	guard(UR6AbstractGameManager::execStopGSClientProcedure);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6AbstractGameManager, INDEX_NONE, execStopGSClientProcedure );

/*-- UR6FileManager ----------------------------------------------------*/

void UR6FileManager::execDeleteFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execDeleteFile);
	P_GET_STR(Filename);
	P_FINISH;
	*(DWORD*)Result = GFileManager->Delete( *Filename );
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1527, execDeleteFile );

void UR6FileManager::execFindFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execFindFile);
	P_GET_STR(Pattern);
	P_FINISH;
	TArray<FString> Files = GFileManager->FindFiles( *Pattern, 1, 0 );
	*(INT*)Result = Files.Num();
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1528, execFindFile );

void UR6FileManager::execGetFileName( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetFileName);
	P_GET_INT(Index);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1526, execGetFileName );

void UR6FileManager::execGetNbFile( FFrame& Stack, RESULT_DECL )
{
	guard(UR6FileManager::execGetNbFile);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6FileManager, 1525, execGetNbFile );

/*-- UR6ModMgr ---------------------------------------------------------*/

void UR6ModMgr::execAddNewModExtraPath( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execAddNewModExtraPath);
	P_GET_STR(Path);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2020, execAddNewModExtraPath );

void UR6ModMgr::execCallSndEngineInit( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execCallSndEngineInit);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 3003, execCallSndEngineInit );

void UR6ModMgr::execGetASBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetASBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetASBuildVersion );

void UR6ModMgr::execGetIWBuildVersion( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execGetIWBuildVersion);
	P_FINISH;
	*(FString*)Result = TEXT("1.60");
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execGetIWBuildVersion );

void UR6ModMgr::execIsOfficialMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execIsOfficialMod);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execIsOfficialMod );

void UR6ModMgr::execSetGeneralModSettings( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetGeneralModSettings);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, INDEX_NONE, execSetGeneralModSettings );

void UR6ModMgr::execSetSystemMod( FFrame& Stack, RESULT_DECL )
{
	guard(UR6ModMgr::execSetSystemMod);
	P_GET_STR(ModName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UR6ModMgr, 2021, execSetSystemMod );

// =============================================================================
// UGameEngine
// =============================================================================

INT UGameEngine::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return Super::Exec( Cmd, Ar ); }
void UGameEngine::Destroy() { Super::Destroy(); }
void UGameEngine::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UGameEngine::Tick( FLOAT DeltaSeconds ) {}
void UGameEngine::UpdateConnectingMessage() {}
void UGameEngine::Init() {}
void UGameEngine::Exit() {}
void UGameEngine::Draw( UViewport* Viewport, INT bFlush, BYTE* HitData, INT* HitSize ) {}
void UGameEngine::MouseDelta( UViewport* Viewport, DWORD Buttons, FLOAT DX, FLOAT DY ) {}
void UGameEngine::MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}
void UGameEngine::MouseWheel( UViewport* Viewport, DWORD Buttons, INT Delta ) {}
void UGameEngine::Click( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}
void UGameEngine::UnClick( UViewport* Viewport, DWORD Buttons, INT MouseX, INT MouseY ) {}
void UGameEngine::SetClientTravel( UPlayer* Viewport, const TCHAR* NextURL, INT bItems, ETravelType TravelType ) {}
INT UGameEngine::ChallengeResponse( INT Challenge ) {
	// Retail: 30b. Mixes high/low halfwords and multiplies by a prime to produce the token.
	// Formula: ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE
	return ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE;
}
FLOAT UGameEngine::GetMaxTickRate() { return 0.0f; }
void UGameEngine::SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds ) {}
INT UGameEngine::Browse( FURL URL, const TMap<FString,FString>* TravelInfo, FString& Error ) { return 0; }
ULevel* UGameEngine::LoadMap( const FURL& URL, UPendingLevel* Pending, const TMap<FString,FString>* TravelInfo, FString& Error ) { return NULL; }
void UGameEngine::SaveGame( INT Position ) {}
void UGameEngine::CancelPending() {}
void UGameEngine::PaintProgress( const FURL& URL ) {}
void UGameEngine::NotifyLevelChange() {}
void UGameEngine::FixUpLevel() {}

// =============================================================================
// UViewport
// =============================================================================

INT UViewport::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void UViewport::Serialize( const TCHAR* Data, EName Event ) {}
void UViewport::Destroy() { Super::Destroy(); }
void UViewport::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UViewport::ReadInput( FLOAT DeltaSeconds ) {}
INT UViewport::Lock( BYTE* HitData, INT* HitSize ) { return 0; }
void UViewport::Unlock() {}
void UViewport::Present() {}
INT UViewport::SetDrag( INT NewDrag ) { return 0; }
void* UViewport::GetServer() { return NULL; }
void UViewport::TryRenderDevice( const TCHAR* ClassName, INT NewX, INT NewY, INT NewColorBytes ) {}
void UViewport::ExecMacro( const TCHAR* Filename, FOutputDevice& Ar ) {}
UClient* UViewport::GetOuterUClient() const { return (UClient*)GetOuter(); }
void UViewport::InitInput() {}
INT UViewport::IsOrtho()
{
	// Retail (34b, RVA 0x12A60): load state ptr at +0x34, check RendMap at +0x504
	// for ortho modes 0x0D, 0x0E, 0x0F.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	return (rm == 0x0D || rm == 0x0E || rm == 0x0F) ? 1 : 0;
}
INT UViewport::IsPerspective()
{
	// Retail (74b, RVA 0x12A00): same state ptr; RendMap 1-7 or 0x1E → perspective.
	// RendMap == 0x10 only if [state+0x4FC] is non-null.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	INT rm = *(INT*)((BYTE*)st + 0x504);
	if (rm >= 1 && rm <= 7) return 1;
	if (rm == 0x1E) return 1;
	if (rm == 0x10) return *(void**)((BYTE*)st + 0x4FC) != NULL ? 1 : 0;
	return 0;
}
INT UViewport::IsRealtime()
{
	// Retail (26b, RVA 0x12A90): state ptr at +0x34; flags at +0x4F8 bits 11,14.
	void* st = *(void**)((BYTE*)this + 0x34);
	if (!st) return 0;
	return (*(DWORD*)((BYTE*)st + 0x4F8) & 0x4800) ? 1 : 0;
}
INT UViewport::IsWire() { return 0; }
void UViewport::ScreenShot() {}
BYTE* UViewport::_Screen( INT X, INT Y ) { return NULL; }

// =============================================================================
// UModel
// =============================================================================

UModel::UModel( ABrush* Owner, INT InRootOutside ) {}
void UModel::PostLoad() { Super::PostLoad(); }
void UModel::Destroy() { Super::Destroy(); }
void UModel::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
INT UModel::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags ) { return 0; }
INT UModel::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD TraceFlags, DWORD ExtraNodeFlags ) { return 0; }
FBox UModel::GetRenderBoundingBox( const AActor* Owner ) { return FBox(); }
FBox UModel::GetCollisionBoundingBox( const AActor* Owner ) const { return FBox(); }
void UModel::Illuminate( AActor* Owner, INT bExtra ) {}
FVector UModel::GetEncroachExtent( AActor* Owner ) { return FVector(0,0,0); }
FVector UModel::GetEncroachCenter( AActor* Owner ) { return FVector(0,0,0); }
INT UModel::UseCylinderCollision( const AActor* Owner ) { return 0; }
TArray<INT> UModel::BoxLeaves( FBox Box ) { return TArray<INT>(); }
void UModel::BuildBound() {}
void UModel::BuildRenderData() {}
void UModel::ClearRenderData( URenderDevice* RenDev ) {}
void UModel::CompressLightmaps() {}
INT UModel::ConvexVolumeMultiCheck( FBox& Box, FPlane* Planes, INT NumPlanes, FVector Extent, TArray<INT>& Result, FLOAT VisRadius ) { return 0; }
void UModel::EmptyModel( INT EmptySurfs, INT EmptyPolys ) {}
BYTE UModel::FastLineCheck( FVector Start, FVector End ) { return 0; }
FLOAT UModel::FindNearestVertex( const FVector& SourcePoint, FVector& DestPoint, FLOAT MinRadius, INT& iVertex ) const { return 0.0f; }
void UModel::Modify( INT DoTransArrays ) {}
void UModel::ModifyAllSurfs( INT SetBits ) {}
void UModel::ModifySelectedSurfs( INT SetBits ) {}
void UModel::ModifySurf( INT iSurf, INT SetBits ) {}
FPointRegion UModel::PointRegion( AZoneInfo* Zone, FVector Location ) const { return FPointRegion(); }
INT UModel::PotentiallyVisible( INT iLeaf0, INT iLeaf1 ) { return 0; }
void UModel::PrecomputeSphereFilter( const FPlane& Sphere ) {}
INT UModel::R6LineCheck( FCheckResult& Result, INT iNode, FVector Start, FVector End ) { return 0; }
void UModel::ShrinkModel() {}
void UModel::Transform( ABrush* Brush ) {}

// =============================================================================
// UNetConnection
// =============================================================================

UNetConnection::UNetConnection( UNetDriver* InDriver, const FURL& InURL ) {}
INT UNetConnection::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void UNetConnection::Serialize( const TCHAR* Data, EName Event ) {}
void UNetConnection::Destroy() { Super::Destroy(); }
void UNetConnection::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UNetConnection::ReadInput( FLOAT DeltaSeconds ) {}
void UNetConnection::InitOut() {}
void UNetConnection::AssertValid() {}
void UNetConnection::SendAck( INT PacketId, INT RemotePacketId ) {}
void UNetConnection::FlushNet() {}
void UNetConnection::Tick() {}
INT UNetConnection::IsNetReady( INT Saturate ) { return 1; }
void UNetConnection::HandleClientPlayer( APlayerController* PC ) {}
UNetDriver* UNetConnection::GetDriver() { return Driver; }
void UNetConnection::PreSend( INT SizeBits )
{
	// Out(FBitWriter) at offset 0x250, MaxPacket(INT) at offset 0xD0
	FBitWriter& Out = *(FBitWriter*)((BYTE*)this + 0x250);
	INT MaxPacket = *(INT*)((BYTE*)this + 0xD0);
	// If adding SizeBits + 1 bit would overflow, flush first.
	if (Out.GetNumBits() + 1 + SizeBits > MaxPacket * 8)
		FlushNet();
	// If Out is empty, write packet header (OutPacketId at 0xEA8).
	if (Out.GetNumBits() == 0)
	{
		Out.WriteInt(*(DWORD*)((BYTE*)this + 0xEA8), 0x4000);
		if (Out.GetNumBits() > 16)
			appFailAssert("Out.GetNumBits()<=MAX_PACKET_HEADER_BITS", ".\\UnConn.cpp", 0x2A4);
	}
	// Final overflow check.
	if (Out.GetNumBits() + 1 + SizeBits > MaxPacket * 8)
		appErrorf(TEXT("PreSend overflow: %i+%i>%i"), Out.GetNumBits(), SizeBits, MaxPacket * 8);
}
void UNetConnection::PurgeAcks() {}
void UNetConnection::ReceiveFile( INT PackageIndex ) {}
void UNetConnection::ReceivedNak( INT NakPacketId ) {}
void UNetConnection::ReceivedPacket( FBitReader& Reader ) {}
void UNetConnection::ReceivedRawPacket( void* Data, INT Count ) {}
void UNetConnection::SendPackageMap() {}
INT UNetConnection::SendRawBunch( FOutBunch& Bunch, INT InPacketId ) { return 0; }
void UNetConnection::SetActorDirty( AActor* Actor ) {}
void UNetConnection::SlowAssertValid() {}

// =============================================================================
// UChannel
// =============================================================================

void UChannel::Destroy() { Super::Destroy(); }
void UChannel::Init( UNetConnection* InConnection, INT InChIndex, INT InOpenedLocally )
{
	ChIndex = InChIndex;
	Connection = InConnection;
	OpenedLocally = InOpenedLocally;
	OpenPacketId = INDEX_NONE;
	// NegotiatedVer copies from the connection's negotiated protocol version.
	// UNetConnection::NegotiatedVer is within _ConnPad (not yet decoded from Ghidra).
	// Default to 0 (minimum version) until the field offset is confirmed.
	NegotiatedVer = 0;
}
void UChannel::SetClosingFlag() { Closing = 1; }
void UChannel::Close() {}
FString UChannel::Describe() { return FString(); }
void UChannel::ReceivedNak( INT NakPacketId ) {}
void UChannel::Tick() {}
void UChannel::AssertInSequenced() {}
INT CDECL UChannel::IsKnownChannelType( INT Type ) { return 0; }
INT UChannel::IsNetReady( INT Saturate ) { return 1; }
INT UChannel::MaxSendBytes() { return 0; }
void UChannel::ReceivedAcks() {}
void UChannel::ReceivedRawBunch( FInBunch& Bunch ) {}
INT UChannel::ReceivedSequencedBunch( FInBunch& Bunch ) { return 0; }
INT UChannel::RouteDestroy() { return 0; }

// =============================================================================
// ASceneManager
// =============================================================================

void ASceneManager::PostEditChange() { Super::PostEditChange(); }
INT ASceneManager::Tick( FLOAT DeltaTime, ELevelTick TickType ) { return Super::Tick( DeltaTime, TickType ); }
void ASceneManager::PostBeginPlay() {}
void ASceneManager::CheckForErrors() { Super::CheckForErrors(); }
FLOAT ASceneManager::GetTotalSceneTime() { return 0.0f; }

// =============================================================================
// Virtual method implementations (merged from EngineVirtuals.cpp).
// These are needed because the vtable is instantiated in our DLL.
// =============================================================================

// ---------------------------------------------------------------------------
// UCanvas
// ---------------------------------------------------------------------------
void UCanvas::Destroy()
{
	Super::Destroy();
}

void UCanvas::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);
}

UBOOL UCanvas::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

// ---------------------------------------------------------------------------
// UNetDriver
// ---------------------------------------------------------------------------
UBOOL UNetDriver::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

void UNetDriver::LowLevelDestroy()
{
}

FString UNetDriver::LowLevelGetNetworkNumber()
{
	return FString();
}

// ---------------------------------------------------------------------------
// UChannel
// ---------------------------------------------------------------------------
void UChannel::StaticConstructor()
{
}

void UChannel::ReceivedBunch(FInBunch& Bunch)
{
}

void UChannel::Serialize(const TCHAR* Name, EName Type)
{
}

// ---------------------------------------------------------------------------
// UMaterial
// ---------------------------------------------------------------------------
void UMaterial::PostEditChange()
{
	Super::PostEditChange();
}

// ---------------------------------------------------------------------------
// AReplicationInfo
// ---------------------------------------------------------------------------
void AReplicationInfo::StaticConstructor()
{
}

void AReplicationInfo::StartVideo(UCanvas* Canvas, INT X, INT Y, INT Z)
{
}

void AReplicationInfo::StopVideo(UCanvas* Canvas)
{
}

INT AReplicationInfo::OpenVideo(UCanvas* Canvas, char* A, char* B, INT C)
{
	return 0;
}

void AReplicationInfo::ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param)
{
}

void AReplicationInfo::CloseVideo(UCanvas* Canvas)
{
}
void ASceneManager::SetCurrentTime( FLOAT NewTime ) {
	// Retail: 42b. Stores raw time at this+0x3D0, clears reset counter at this+0x448,
	// then calls RefreshSubActions with time normalized by TotalSceneTime at this+0x3CC.
	*(FLOAT*)((BYTE*)this + 0x3D0) = NewTime;
	*(INT*)((BYTE*)this + 0x448) = 0;
	RefreshSubActions( NewTime / *(FLOAT*)((BYTE*)this + 0x3CC) );
}
void ASceneManager::SetSceneStartTime() {}

// =============================================================================
// AFluidSurfaceInfo
// =============================================================================

void AFluidSurfaceInfo::PostLoad() { Super::PostLoad(); }
void AFluidSurfaceInfo::Destroy() { Super::Destroy(); }
void AFluidSurfaceInfo::PostEditChange() { Super::PostEditChange(); }
INT AFluidSurfaceInfo::Tick( FLOAT DeltaTime, ELevelTick TickType ) { return Super::Tick( DeltaTime, TickType ); }
void AFluidSurfaceInfo::PostEditMove() {}
void AFluidSurfaceInfo::Spawned() {}
UPrimitive* AFluidSurfaceInfo::GetPrimitive() { return NULL; }
void AFluidSurfaceInfo::Init() {}
void AFluidSurfaceInfo::Pling( const FVector& Location, FLOAT Strength, FLOAT Radius ) {}
void AFluidSurfaceInfo::PlingVertex( INT X, INT Y, FLOAT Strength ) {}
void AFluidSurfaceInfo::UpdateSimulation( FLOAT DeltaTime ) {}

// =============================================================================
// UInput
// =============================================================================

INT UInput::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void UInput::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UInput::Init( UViewport* InViewport ) {}
void UInput::ReadInput( FLOAT DeltaSeconds, FOutputDevice& Ar ) {}
void UInput::ResetInput() {}
BYTE UInput::GetKey( const TCHAR* KeyName ) { return 0; }
void UInput::SetKey( const TCHAR* KeyName ) {}
FString UInput::GetActionKey( BYTE Key ) { return FString(); }
BYTE* UInput::FindButtonName( AActor* Actor, const TCHAR* ButtonName ) const { return NULL; }
FLOAT* UInput::FindAxisName( AActor* Actor, const TCHAR* AxisName ) const { return NULL; }
void UInput::ExecInputCommands( const TCHAR* Cmd, FOutputDevice& Ar ) {}
BYTE UInput::KeyDown( INT Key )
{
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Key < 0)
		return KeyDownMap[0];
	if (Key > 0xFD)
		Key = 0xFE;
	return KeyDownMap[Key];
}
void UInput::StaticConstructor() {}

// =============================================================================
// UNullRenderDevice
// =============================================================================

INT UNullRenderDevice::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
INT UNullRenderDevice::Init() { return 1; }
INT UNullRenderDevice::SetRes( UViewport* Viewport, INT NewX, INT NewY, INT NewColorBytes ) { return 0; }
void UNullRenderDevice::Exit( UViewport* Viewport ) {}
void UNullRenderDevice::Flush( UViewport* Viewport ) {}
void UNullRenderDevice::Present( UViewport* Viewport ) {}
void UNullRenderDevice::Unlock( FRenderInterface* RI ) {}
void UNullRenderDevice::UpdateGamma( UViewport* Viewport ) {}
void UNullRenderDevice::FlushResource( QWORD ResourceId ) {}
void UNullRenderDevice::ReadPixels( UViewport* Viewport, FColor* Pixels ) {}
void UNullRenderDevice::RestoreGamma() {}
FRenderInterface* UNullRenderDevice::Lock( UViewport* Viewport, BYTE* HitData, INT* HitSize ) { return NULL; }
FRenderCaps* UNullRenderDevice::GetRenderCaps() { return NULL; }
void UNullRenderDevice::StaticConstructor() {}

/*-----------------------------------------------------------------------------
	PunkBuster export.
-----------------------------------------------------------------------------*/

extern "C" ENGINE_API void pb_Export() {}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
