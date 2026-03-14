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

IMPL_INTENTIONALLY_EMPTY("UObject property system handles initialisation via InitProperties()")
AActor::AActor() {}
IMPL_INTENTIONALLY_EMPTY("UObject property system handles initialisation via InitProperties()")
APawn::APawn() {}

/* FMatrix copy-ctor shim:
   1. local_FMatrix_CopyCtor — __fastcall mirrors __thiscall on x86
      (ECX = this, EDX unused, args on stack).
   2. imp_FMatrix_CopyCtor   — C-linkage pointer variable the linker
      resolves __imp_??0FMatrix@@QAE@ABV0@@Z to via /alternatename.     */
IMPL_APPROX("FMatrix copy-ctor shim; Core.lib does not export the copy constructor")
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

IMPL_APPROX("Returns empty FString; server options not populated in rebuild")
void AActor::execGetServerOptionsRefreshed( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerOptionsRefreshed);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetServerOptionsRefreshed );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
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

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
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

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKDisableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKDisableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKDisableCollision );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKEnableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKEnableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKEnableCollision );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKFreezeRagdoll( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKFreezeRagdoll);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKFreezeRagdoll );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetActorGravScale);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetActorGravScale );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMOffset);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMOffset );

IMPL_APPROX("native exec implementation")
void AActor::execKGetCOMPosition( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMPosition);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMPosition );

IMPL_APPROX("native exec implementation")
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

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetFriction);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetFriction );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetImpactThreshold);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetImpactThreshold );

IMPL_APPROX("native exec implementation")
void AActor::execKGetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetInertiaTensor);
	P_GET_VECTOR_REF(InertiaTensor);
	P_FINISH;
	*InertiaTensor = FVector(1,1,1);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetInertiaTensor );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetMass );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetRestitution);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetRestitution );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKGetSkelMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetSkelMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetSkelMass );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKIsAwake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsAwake);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsAwake );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKIsRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsRagdollAvailable);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsRagdollAvailable );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKMakeRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMakeRagdollAvailable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMakeRagdollAvailable );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKMP2IOKarmaAllNativeFct( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMP2IOKarmaAllNativeFct);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMP2IOKarmaAllNativeFct );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKRemoveAllBoneLifters( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveAllBoneLifters);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveAllBoneLifters );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKRemoveLifterFromBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveLifterFromBone);
	P_GET_NAME(BoneName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveLifterFromBone );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetActorGravScale);
	P_GET_FLOAT(NewGravScale);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetActorGravScale );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetBlockKarma( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetBlockKarma);
	P_GET_UBOOL(bBlock);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetBlockKarma );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetCOMOffset);
	P_GET_VECTOR(Offset);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetCOMOffset );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetDampingProps( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetDampingProps);
	P_GET_FLOAT(LinDamping);
	P_GET_FLOAT(AngDamping);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetDampingProps );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetFriction);
	P_GET_FLOAT(Friction);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetFriction );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetImpactThreshold);
	P_GET_FLOAT(Threshold);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetImpactThreshold );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetInertiaTensor);
	P_GET_VECTOR(InertiaTensor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetInertiaTensor );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetMass);
	P_GET_FLOAT(Mass);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetMass );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetRestitution);
	P_GET_FLOAT(Restitution);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetRestitution );

IMPL_APPROX("native exec implementation")
void AActor::execKSetSkelVel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetSkelVel);
	P_GET_VECTOR(Velocity);
	P_GET_VECTOR_OPTX(AngVelocity,FVector(0,0,0));
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetSkelVel );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKSetStayUpright( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetStayUpright);
	P_GET_UBOOL(bStayUpright);
	P_GET_UBOOL_OPTX(bSpin,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetStayUpright );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary; exec stub does not call Karma")
void AActor::execKWake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKWake);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKWake );

/*-- AVolume -----------------------------------------------------------*/

IMPL_APPROX("native exec implementation")
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

IMPL_APPROX("native exec implementation")
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

IMPL_APPROX("native exec implementation")
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

IMPL_APPROX("Inverse warp transform on Loc/Vel/R - symmetric to execWarp")
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

IMPL_APPROX("Script interface to create ripple in fluid surface at Position with Strength/Radius")
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

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary")
void AKConstraint::execKGetConstraintForce( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintForce);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintForce );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary")
void AKConstraint::execKGetConstraintTorque( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintTorque);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintTorque );

IMPL_DIVERGE("Karma physics - MathEngine SDK proprietary")
void AKConstraint::execKUpdateConstraintParams( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKUpdateConstraintParams);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKUpdateConstraintParams );

/*-- ASceneManager -----------------------------------------------------*/

IMPL_APPROX("Returns total accumulated scene time; returns 0 until scene time tracking is implemented")
void ASceneManager::execGetTotalSceneTime( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execGetTotalSceneTime);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, INDEX_NONE, execGetTotalSceneTime );

IMPL_APPROX("Notify script that scene has been destroyed; cleanup hook")
void ASceneManager::execSceneDestroyed( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execSceneDestroyed);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2909, execSceneDestroyed );

IMPL_APPROX("Terminate current AI action in scene; signals abort to active scripted sequence")
void ASceneManager::execTerminateAIAction( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execTerminateAIAction);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2906, execTerminateAIAction );

/*-- AStatLog ----------------------------------------------------------*/

IMPL_APPROX("Batch local stat log entry - no-op in rebuild, game stats not implemented")
void AStatLog::execBatchLocal( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBatchLocal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBatchLocal );

IMPL_APPROX("Opens a relative local URL for stat/log browsing; no-op in rebuild")
void AStatLog::execBrowseRelativeLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBrowseRelativeLocalURL);
	P_GET_STR(URL);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBrowseRelativeLocalURL );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execExecuteLocalLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteLocalLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteLocalLogBatcher );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execExecuteSilentLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteSilentLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteSilentLogBatcher );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execExecuteWorldLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteWorldLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteWorldLogBatcher );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execGetGMTRef( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetGMTRef);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetGMTRef );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execGetMapFileName( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetMapFileName);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetMapFileName );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execGetPlayerChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetPlayerChecksum);
	P_GET_OBJECT(AActor,P);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetPlayerChecksum );

IMPL_APPROX("Stat logging exec stub - statistics not implemented in rebuild")
void AStatLog::execInitialCheck( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execInitialCheck);
	P_GET_OBJECT(AActor,Game);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execInitialCheck );

/*-- AStatLogFile ------------------------------------------------------*/

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execCloseLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execCloseLog);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execCloseLog );

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execFileFlush( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileFlush);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileFlush );

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execFileLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileLog);
	P_GET_STR(Item);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileLog );

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execGetChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execGetChecksum);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execGetChecksum );

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execOpenLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execOpenLog);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execOpenLog );

IMPL_APPROX("Stat log file exec stub - file logging not implemented in rebuild")
void AStatLogFile::execWatermark( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execWatermark);
	P_GET_STR(Item);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execWatermark );

/*-- AR6ColBox ---------------------------------------------------------*/

IMPL_APPROX("native exec implementation")
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

IMPL_APPROX("Decal system exec stub")
void AR6DecalGroup::execActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execActivateGroup);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2904, execActivateGroup );

IMPL_APPROX("Decal system exec stub")
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

IMPL_APPROX("Decal system exec stub")
void AR6DecalGroup::execDeActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execDeActivateGroup);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2905, execDeActivateGroup );

IMPL_APPROX("Decal system exec stub")
void AR6DecalGroup::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2903, execKillDecal );

IMPL_APPROX("Decal system exec stub")
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

IMPL_APPROX("Decal system exec stub")
void AR6DecalManager::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalManager::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalManager, 2901, execKillDecal );

/*-- AR6eviLTesting ----------------------------------------------------*/

IMPL_APPROX("native exec implementation")
void AR6eviLTesting::execNativeRunAllTests( FFrame& Stack, RESULT_DECL )
{
	guard(AR6eviLTesting::execNativeRunAllTests);
	P_FINISH;
	debugf( TEXT("NativeRunAllTests: no tests implemented") );
	unguard;
}
IMPLEMENT_FUNCTION( AR6eviLTesting, 1356, execNativeRunAllTests );

/*-- UInteraction ------------------------------------------------------*/

IMPL_APPROX("Interaction system exec stub")
void UInteraction::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	*(FString*)Result = TEXT("");
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execConsoleCommand );

IMPL_APPROX("Interaction system exec stub")
void UInteraction::execInitialize( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execInitialize);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execInitialize );

// =============================================================================

// =============================================================================
// AReplicationInfo
// =============================================================================

// AReplicationInfo
// ---------------------------------------------------------------------------
IMPL_APPROX("AReplicationInfo stub - replication not fully implemented")
void AReplicationInfo::StaticConstructor()
{
	guard(AReplicationInfo::StaticConstructor);
	unguard;
}

IMPL_APPROX("AReplicationInfo stub - replication not fully implemented")
void AReplicationInfo::StartVideo(UCanvas* Canvas, INT X, INT Y, INT Z)
{
	guard(AReplicationInfo::StartVideo);
	unguard;
}

IMPL_APPROX("AReplicationInfo stub - replication not fully implemented")
void AReplicationInfo::StopVideo(UCanvas* Canvas)
{
	guard(AReplicationInfo::StopVideo);
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x114310)
INT AReplicationInfo::OpenVideo(UCanvas* Canvas, char* A, char* B, INT C)
{
	guard(AReplicationInfo::OpenVideo);
	// Ghidra 0x114310: shared zero-return vtable stub.
	return 0;
	unguard;
}

IMPL_APPROX("AReplicationInfo stub - replication not fully implemented")
void AReplicationInfo::ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param)
{
	guard(AReplicationInfo::ChangeDrawingSurface);
	unguard;
}

/*-----------------------------------------------------------------------------
	PunkBuster export.
-----------------------------------------------------------------------------*/

IMPL_INTENTIONALLY_EMPTY("PunkBuster export stub; body intentionally empty")
extern "C" ENGINE_API void pb_Export() {}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
