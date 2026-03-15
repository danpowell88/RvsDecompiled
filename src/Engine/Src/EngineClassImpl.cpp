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

IMPL_EMPTY("UObject property system handles initialisation via InitProperties()")
AActor::AActor() {}
IMPL_EMPTY("UObject property system handles initialisation via InitProperties()")
APawn::APawn() {}

/* FMatrix copy-ctor shim:
   1. local_FMatrix_CopyCtor — __fastcall mirrors __thiscall on x86
      (ECX = this, EDX unused, args on stack).
   2. imp_FMatrix_CopyCtor   — C-linkage pointer variable the linker
      resolves __imp_??0FMatrix@@QAE@ABV0@@Z to via /alternatename.     */
IMPL_DIVERGE("Linker shim: Core.lib does not export FMatrix copy-ctor; this function has no retail counterpart")
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

IMPL_MATCH("Engine.dll", 0x1042c7d0)
void AActor::execGetServerOptionsRefreshed( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execGetServerOptionsRefreshed);
	P_FINISH;
	// Load server config from ini path returned by mod manager.
	FString ini = GModMgr->eventGetServerIni();
	GServerOptions->LoadConfig(0, NULL, *ini);
	// If GServerOptions has a sub-object (at +0x58), load its config too.
	UObject* sub = *(UObject**)((BYTE*)GServerOptions + 0x58);
	if (sub) {
		FString ini2 = GModMgr->eventGetServerIni();
		sub->LoadConfig(0, NULL, *ini2);
	}
	*(UR6ServerInfo**)Result = GServerOptions;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execGetServerOptionsRefreshed );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10364340 (582 bytes): retail calls MeSDK KAddBoneLifter")
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

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363f00 (622 bytes): retail calls MeSDK KAddImpulse")
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

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363090 (187 bytes): retail calls MeSDK KDisableCollision")
void AActor::execKDisableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKDisableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKDisableCollision );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363180 (187 bytes): retail calls MeSDK KEnableCollision")
void AActor::execKEnableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKEnableCollision);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKEnableCollision );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362d60 (104 bytes): retail calls KFreezeRagdoll(this)")
void AActor::execKFreezeRagdoll( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKFreezeRagdoll);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKFreezeRagdoll );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363d30 (132 bytes): retail reads grav scale from KarmaParams")
void AActor::execKGetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetActorGravScale);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetActorGravScale );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363870 (295 bytes): retail reads COM offset from KarmaParams")
void AActor::execKGetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMOffset);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMOffset );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103626d0 (235 bytes): retail calls vtable KGetCOMPosition")
void AActor::execKGetCOMPosition( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetCOMPosition);
	P_FINISH;
	*(FVector*)Result = Location;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetCOMPosition );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363ae0 (313 bytes): retail reads lin/ang damping from KarmaParams")
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

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362a40 (115 bytes): retail reads friction from KarmaParams+0x30")
void AActor::execKGetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetFriction);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetFriction );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362bc0 (115 bytes): retail reads impact threshold from KarmaParams")
void AActor::execKGetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetImpactThreshold);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetImpactThreshold );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363440 (446 bytes): retail reads inertia tensor from KarmaParams")
void AActor::execKGetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetInertiaTensor);
	P_GET_VECTOR_REF(InertiaTensor);
	P_FINISH;
	*InertiaTensor = FVector(1,1,1);
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetInertiaTensor );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363380 (132 bytes): retail reads mass from UKarmaParams")
void AActor::execKGetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetMass );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103628c0 (115 bytes): retail reads restitution from KarmaParams")
void AActor::execKGetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetRestitution);
	P_FINISH;
	*(FLOAT*)Result = 0.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetRestitution );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103645c0 (324 bytes): retail calls MeSDK KGetSkelMass")
void AActor::execKGetSkelMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKGetSkelMass);
	P_FINISH;
	*(FLOAT*)Result = 1.f;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKGetSkelMass );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362c70 (190 bytes): retail calls MeSDK KIsAwake")
void AActor::execKIsAwake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsAwake);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsAwake );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362e00 (180 bytes): retail checks ragdoll availability via MeSDK")
void AActor::execKIsRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKIsRagdollAvailable);
	P_FINISH;
	*(DWORD*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKIsRagdollAvailable );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10364740 (440 bytes): retail calls MeSDK KMakeRagdollAvailable")
void AActor::execKMakeRagdollAvailable( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMakeRagdollAvailable);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMakeRagdollAvailable );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10364a60 (1445 bytes): large MeSDK IO dispatch function")
void AActor::execKMP2IOKarmaAllNativeFct( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKMP2IOKarmaAllNativeFct);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKMP2IOKarmaAllNativeFct );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103651f0 (300 bytes): retail calls MeSDK KRemoveAllBoneLifters")
void AActor::execKRemoveAllBoneLifters( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveAllBoneLifters);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveAllBoneLifters );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10365040 (368 bytes): retail calls MeSDK KRemoveLifterFromBone")
void AActor::execKRemoveLifterFromBone( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKRemoveLifterFromBone);
	P_GET_NAME(BoneName);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKRemoveLifterFromBone );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363c50 (166 bytes): retail sets grav scale via MeSDK")
void AActor::execKSetActorGravScale( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetActorGravScale);
	P_GET_FLOAT(NewGravScale);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetActorGravScale );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362f80 (209 bytes): retail calls MeSDK KSetBlockKarma")
void AActor::execKSetBlockKarma( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetBlockKarma);
	P_GET_UBOOL(bBlock);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetBlockKarma );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363770 (196 bytes): retail sets COM offset via MeSDK")
void AActor::execKSetCOMOffset( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetCOMOffset);
	P_GET_VECTOR(Offset);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetCOMOffset );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103639d0 (212 bytes): retail sets lin/ang damping via MeSDK")
void AActor::execKSetDampingProps( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetDampingProps);
	P_GET_FLOAT(LinDamping);
	P_GET_FLOAT(AngDamping);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetDampingProps );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362970 (149 bytes): retail sets friction via MeSDK")
void AActor::execKSetFriction( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetFriction);
	P_GET_FLOAT(Friction);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetFriction );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10362af0 (149 bytes): retail sets impact threshold via MeSDK")
void AActor::execKSetImpactThreshold( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetImpactThreshold);
	P_GET_FLOAT(Threshold);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetImpactThreshold );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363630 (262 bytes): retail sets inertia tensor via MeSDK")
void AActor::execKSetInertiaTensor( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetInertiaTensor);
	P_GET_VECTOR(InertiaTensor);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetInertiaTensor );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103632a0 (173 bytes): retail sets mass via MeSDK")
void AActor::execKSetMass( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetMass);
	P_GET_FLOAT(Mass);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetMass );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103627f0 (149 bytes): retail sets restitution via MeSDK")
void AActor::execKSetRestitution( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetRestitution);
	P_GET_FLOAT(Restitution);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetRestitution );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x103641a0 (366 bytes): retail sets skeletal velocity via MeSDK")
void AActor::execKSetSkelVel( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetSkelVel);
	P_GET_VECTOR(Velocity);
	P_GET_VECTOR_OPTX(AngVelocity,FVector(0,0,0));
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetSkelVel );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10364940 (228 bytes): retail sets stay-upright params via MeSDK")
void AActor::execKSetStayUpright( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKSetStayUpright);
	P_GET_UBOOL(bStayUpright);
	P_GET_UBOOL_OPTX(bSpin,0);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKSetStayUpright );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10363df0 (219 bytes): retail calls KWake vtable on KarmaParams")
void AActor::execKWake( FFrame& Stack, RESULT_DECL )
{
	guard(AActor::execKWake);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AActor, INDEX_NONE, execKWake );

/*-- AVolume -----------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x104254d0)
void AVolume::execEncompasses( FFrame& Stack, RESULT_DECL )
{
	guard(AVolume::execEncompasses);
	P_GET_OBJECT(AActor,Other);
	P_FINISH;
	*(DWORD*)Result = Encompasses( Other->Location );
	unguard;
}
IMPLEMENT_FUNCTION( AVolume, INDEX_NONE, execEncompasses );

/*-- AZoneInfo ---------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x1042b1e0)
void AZoneInfo::execZoneActors( FFrame& Stack, RESULT_DECL )
{
	guard(AZoneInfo::execZoneActors);
	P_GET_OBJECT(UClass,BaseClass);
	P_GET_OBJECT_REF(AActor,Actor);
	P_FINISH;

	if( !BaseClass )
		BaseClass = AActor::StaticClass();
	INT iActor = 0;
	PRE_ITERATOR;
		*Actor = NULL;
		while( iActor < XLevel->Actors.Num() )
		{
			*Actor = XLevel->Actors(iActor++);
			// Retail checks two zone pointers (Region.Zone at +0x228, Zone at +0x144)
			if( *Actor && (*Actor)->IsA(BaseClass) &&
				(*(AZoneInfo**)((BYTE*)*Actor + 0x228) == *(AZoneInfo**)((BYTE*)*Actor + 0x144) ||
				 *(AZoneInfo**)((BYTE*)*Actor + 0x228) == this) )
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

IMPL_MATCH("Engine.dll", 0x10424c80)
void AWarpZoneInfo::execWarp( FFrame& Stack, RESULT_DECL )
{
	guard(AWarpZoneInfo::execWarp);
	P_GET_VECTOR_REF(Loc);
	P_GET_VECTOR_REF(Vel);
	P_GET_ROTATOR_REF(R);
	P_FINISH;
	// WarpCoords lives at this+0x434 (confirmed by AWarpZoneInfo ctor, Ghidra 0x10424040)
	FCoords& WC = *(FCoords*)((BYTE*)this + 0x434);
	*Loc = Loc->TransformPointBy(WC.Transpose());
	*Vel = Vel->TransformVectorBy(WC.Transpose());
	*R   = ((GMath.UnitCoords / *R) * WC.Transpose()).OrthoRotation();
	unguard;
}
IMPLEMENT_FUNCTION( AWarpZoneInfo, 314, execWarp );

IMPL_MATCH("Engine.dll", 0x10424e90)
void AWarpZoneInfo::execUnWarp( FFrame& Stack, RESULT_DECL )
{
	guard(AWarpZoneInfo::execUnWarp);
	P_GET_VECTOR_REF(Loc);
	P_GET_VECTOR_REF(Vel);
	P_GET_ROTATOR_REF(R);
	P_FINISH;
	// WarpCoords lives at this+0x434 (confirmed by AWarpZoneInfo ctor, Ghidra 0x10424040)
	FCoords& WC = *(FCoords*)((BYTE*)this + 0x434);
	*Loc = Loc->TransformPointBy(WC);
	*Vel = Vel->TransformVectorBy(WC);
	*R   = ((GMath.UnitCoords / *R) * WC).OrthoRotation();
	unguard;
}
IMPLEMENT_FUNCTION( AWarpZoneInfo, 315, execUnWarp );

/*-- AFluidSurfaceInfo -------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x1039b290)
void AFluidSurfaceInfo::execPling( FFrame& Stack, RESULT_DECL )
{
	guard(AFluidSurfaceInfo::execPling);
	P_GET_VECTOR(Position);
	P_GET_FLOAT(Strength);
	P_GET_FLOAT(Radius);
	P_FINISH;
	Pling(Position, Strength, Radius);
	unguard;
}
IMPLEMENT_FUNCTION( AFluidSurfaceInfo, INDEX_NONE, execPling );

/*-- AKConstraint ------------------------------------------------------*/

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10359ea0 (227 bytes): retail reads constraint force via MeSDK")
void AKConstraint::execKGetConstraintForce( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintForce);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintForce );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x10359fc0 (227 bytes): retail reads constraint torque via MeSDK")
void AKConstraint::execKGetConstraintTorque( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKGetConstraintTorque);
	P_FINISH;
	*(FVector*)Result = FVector(0,0,0);
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKGetConstraintTorque );

IMPL_DIVERGE("Karma physics not implemented; Ghidra 0x1035a0e0 (107 bytes): retail calls virtual KUpdateConstraintParams")
void AKConstraint::execKUpdateConstraintParams( FFrame& Stack, RESULT_DECL )
{
	guard(AKConstraint::execKUpdateConstraintParams);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AKConstraint, INDEX_NONE, execKUpdateConstraintParams );

/*-- ASceneManager -----------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x1041df80)
void ASceneManager::execGetTotalSceneTime( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execGetTotalSceneTime);
	P_FINISH;
	*(FLOAT*)Result = GetTotalSceneTime();
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, INDEX_NONE, execGetTotalSceneTime );

IMPL_TODO("Ghidra 0x1041f610 (137 bytes): calls GLog->Logf() and FUN_103db080 scene teardown; blocked pending scene manager implementation")
void ASceneManager::execSceneDestroyed( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execSceneDestroyed);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2909, execSceneDestroyed );

IMPL_MATCH("Engine.dll", 0x1041d870)
void ASceneManager::execTerminateAIAction( FFrame& Stack, RESULT_DECL )
{
	guard(ASceneManager::execTerminateAIAction);
	P_FINISH;
	// Accumulates time: this->TimeField(+0x3d0) += *(this->OwnerPtr(+0x3d8))->TimeBase(+0x34)
	*(FLOAT*)((BYTE*)this + 0x3d0) += *(FLOAT*)(*(INT*)((BYTE*)this + 0x3d8) + 0x34);
	unguard;
}
IMPLEMENT_FUNCTION( ASceneManager, 2906, execTerminateAIAction );

/*-- AStatLog ----------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x10317870)
void AStatLog::execBatchLocal( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBatchLocal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBatchLocal );

IMPL_MATCH("Engine.dll", 0x10317930)
void AStatLog::execBrowseRelativeLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execBrowseRelativeLocalURL);
	P_GET_STR(URL);
	P_FINISH;
	// Prefix URL with the file manager's default (base game) directory,
	// then launch it in the system browser.  operator* does path-separator-
	// aware concatenation (appends PATH_SEPARATOR if not already present).
	FString FullPath = GFileManager->GetDefaultDirectory() * URL;
	appLaunchURL(*FullPath, NULL, NULL);
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execBrowseRelativeLocalURL );

IMPL_MATCH("Engine.dll", 0x103176f0)
void AStatLog::execExecuteLocalLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteLocalLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteLocalLogBatcher );

IMPL_MATCH("Engine.dll", 0x103177b0)
void AStatLog::execExecuteSilentLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteSilentLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteSilentLogBatcher );

IMPL_MATCH("Engine.dll", 0x10317a80)
void AStatLog::execExecuteWorldLogBatcher( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execExecuteWorldLogBatcher);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execExecuteWorldLogBatcher );

IMPL_MATCH("Engine.dll", 0x10317b40)
void AStatLog::execGetGMTRef( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetGMTRef);
	P_FINISH;
	*(FString*)Result = appGetGMTRef();
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetGMTRef );

IMPL_MATCH("Engine.dll", 0x10317c30)
void AStatLog::execGetMapFileName( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetMapFileName);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetMapFileName );

// Ghidra 0x10317d10 (561 bytes).
// Params: Actor P (in), string Checksum (out).
// P+0x7b4 = player's unique ID string; P+0x450 = sub-object with name string at +0x408.
// If the unique ID string is empty, Checksum = "NoChecksum".
// Otherwise MD5(name_string || unique_id_string) → 32-char hex digest written to *Checksum.
IMPL_MATCH("Engine.dll", 0x10317d10)
void AStatLog::execGetPlayerChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execGetPlayerChecksum);
	P_GET_OBJECT(AActor,P);
	P_GET_STR_REF(Checksum);
	P_FINISH;
	FString& uniqueId = *(FString*)((BYTE*)P + 0x7b4);
	if (uniqueId.Len() == 0)
	{
		*Checksum = TEXT("NoChecksum");
	}
	else
	{
		FMD5Context ctx;
		appMD5Init(&ctx);
		// Feed the player's name string (at *(P+0x450)+0x408) into MD5.
		FString& nameStr = *(FString*)(*(INT*)((BYTE*)P + 0x450) + 0x408);
		appMD5Update(&ctx, (BYTE*)*nameStr, nameStr.Len() * 2);
		// Feed the unique ID string (at P+0x7b4) into MD5.
		appMD5Update(&ctx, (BYTE*)*uniqueId, uniqueId.Len() * 2);
		BYTE digest[16];
		appMD5Final(digest, &ctx);
		*Checksum = TEXT("");
		for (INT i = 0; i < 16; i++)
			*Checksum += FString::Printf(TEXT("%02x"), (DWORD)digest[i]);
	}
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execGetPlayerChecksum );

IMPL_TODO("Ghidra 0x1032f0c0 (1867 bytes): large function; FMD5Context computations + UClass lookup + FString comparisons; pending full stat system implementation")
void AStatLog::execInitialCheck( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLog::execInitialCheck);
	P_GET_OBJECT(AActor,Game);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AStatLog, INDEX_NONE, execInitialCheck );

/*-- AStatLogFile ------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x103180d0)
void AStatLogFile::execCloseLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execCloseLog);
	P_FINISH;
	// Free FMD5Context at this+0x394 if allocated.
	if (*(INT*)((BYTE*)this + 0x394)) {
		GMalloc->Free((void*)*(INT*)((BYTE*)this + 0x394));
	}
	*(INT*)((BYTE*)this + 0x394) = 0;
	// Delete the FArchive writer at this+0x404 (virtual dtor with deleting=1).
	FArchive* arch = *(FArchive**)((BYTE*)this + 0x404);
	if (arch) {
		delete arch;
	}
	*(INT*)((BYTE*)this + 0x404) = 0;
	// Move temp log to final filename: Move(dest=this+0x418, src=this+0x40c).
	FString& srcPath  = *(FString*)((BYTE*)this + 0x40c);
	FString& destPath = *(FString*)((BYTE*)this + 0x418);
	GFileManager->Move(*destPath, *srcPath, 1, 1, 1);
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execCloseLog );

IMPL_MATCH("Engine.dll", 0x10318500)
void AStatLogFile::execFileFlush( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileFlush);
	P_FINISH;
	// Flush the FArchive writer at this+0x404 (vtable slot 19 = Flush()).
	FArchive* arch = *(FArchive**)((BYTE*)this + 0x404);
	if (arch) {
		arch->Flush();
	}
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileFlush );

IMPL_MATCH("Engine.dll", 0x103185e0)
void AStatLogFile::execFileLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execFileLog);
	P_GET_STR(Item);
	P_FINISH;
	// Append newline separator (DAT_1052d238 = L"\n") then write to archive.
	Item += TEXT("\n");
	FArchive* arch = *(FArchive**)((BYTE*)this + 0x404);
	if (*(BYTE*)((BYTE*)this + 0x398) & 1)
	{
		// XOR-encode path: each wide-char's two bytes are XOR'd with 0xa7
		// and formatted as a 4-digit hex string (DAT_1052d2e8 = TEXT("%04x")).
		FString encoded;
		for (INT i = 0; i < Item.Len(); i++)
		{
			_WORD w = 0;
			const BYTE* src = reinterpret_cast<const BYTE*>(*Item) + i * sizeof(TCHAR);
			reinterpret_cast<BYTE*>(&w)[0] = src[0] ^ 0xa7;
			reinterpret_cast<BYTE*>(&w)[1] = src[1] ^ 0xa7;
			encoded += FString::Printf(TEXT("%04x"), static_cast<DWORD>(w));
		}
		if (arch)
			arch->Serialize(const_cast<TCHAR*>(*encoded), encoded.Len() * sizeof(TCHAR));
	}
	else
	{
		if (arch)
			arch->Serialize(const_cast<TCHAR*>(*Item), Item.Len() * sizeof(TCHAR));
	}
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execFileLog );

IMPL_MATCH("Engine.dll", 0x10318320)
void AStatLogFile::execGetChecksum( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execGetChecksum);
	P_GET_STR_REF(Checksum);
	P_FINISH;
	FMD5Context* ctx = *(FMD5Context**)((BYTE*)this + 0x394);
	if (ctx) {
		// Append a hardcoded 16-byte salt ("M4yfGp69keJdDV1q") before
		// finalising — offsets taken directly from Ghidra 0x10318320.
		BYTE salt[16] = {
			0x4d, 0x34, 0x79, 0x66, 0x47, 0x70, 0x36, 0x39,
			0x6b, 0x65, 0x4a, 0x64, 0x44, 0x56, 0x31, 0x71
		};
		appMD5Update(ctx, salt, 16);
		BYTE digest[16];
		appMD5Final(digest, ctx);
		*Checksum = TEXT("");
		for (INT i = 0; i < 16; i++) {
			*Checksum += FString::Printf(TEXT("%02x"), (DWORD)digest[i]);
		}
	}
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execGetChecksum );

IMPL_MATCH("Engine.dll", 0x10317fa0)
void AStatLogFile::execOpenLog( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execOpenLog);
	P_FINISH;
	// Ensure the Logs directory exists before opening file.
	GFileManager->MakeDirectory(TEXT("..\\Logs"));
	// Open (or create) the log file for writing (flags=4 = append).
	FString& logPath = *(FString*)((BYTE*)this + 0x40c);
	*(FArchive**)((BYTE*)this + 0x404) = GFileManager->CreateFileWriter(*logPath, 4, GNull);
	// If bUseMD5 (bit 0 of byte at this+0x398), allocate and initialise
	// an FMD5Context for checksumming written data.
	if (*(BYTE*)((BYTE*)this + 0x398) & 1) {
		FMD5Context* ctx = (FMD5Context*)GMalloc->Malloc(sizeof(FMD5Context), TEXT("FMD5Context"));
		*(FMD5Context**)((BYTE*)this + 0x394) = ctx;
		appMD5Init(ctx);
	}
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execOpenLog );

IMPL_MATCH("Engine.dll", 0x103181f0)
void AStatLogFile::execWatermark( FFrame& Stack, RESULT_DECL )
{
	guard(AStatLogFile::execWatermark);
	P_GET_STR(Item);
	P_FINISH;
	// Retail appends a newline (DAT_1052d238 = L"\n") then feeds the
	// wide-char data into the running MD5 context.
	Item += TEXT("\n");
	FMD5Context* ctx = *(FMD5Context**)((BYTE*)this + 0x394);
	appMD5Update(ctx, (BYTE*)*Item, Item.Len() * sizeof(TCHAR));
	unguard;
}
IMPLEMENT_FUNCTION( AStatLogFile, INDEX_NONE, execWatermark );

/*-- AR6ColBox ---------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x10476c80)
void AR6ColBox::execEnableCollision( FFrame& Stack, RESULT_DECL )
{
	guard(AR6ColBox::execEnableCollision);
	P_GET_UBOOL(bNewCollideActors);
	P_GET_UBOOL(bNewBlockActors);
	P_GET_UBOOL(bNewBlockPlayers);
	P_FINISH;
	EnableCollision( bNewCollideActors, bNewBlockActors, bNewBlockPlayers );
	unguard;
}
IMPLEMENT_FUNCTION( AR6ColBox, 1503, execEnableCollision );

/*-- AR6DecalGroup & AR6DecalManager -----------------------------------*/

IMPL_MATCH("Engine.dll", 0x104776f0)
void AR6DecalGroup::execActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execActivateGroup);
	P_FINISH;
	ActivateGroup();
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2904, execActivateGroup );

IMPL_MATCH("Engine.dll", 0x10477530)
void AR6DecalGroup::execAddDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execAddDecal);
	P_GET_VECTOR(HitLocation);
	P_GET_ROTATOR(HitRotation);
	P_GET_OBJECT(UTexture,Tex);
	P_GET_INT(Type);
	P_GET_FLOAT(f1);
	P_GET_FLOAT(f2);
	P_GET_FLOAT(f3);
	P_GET_FLOAT(f4);
	P_FINISH;
	*(INT*)Result = AddDecal(&HitLocation, &HitRotation, Tex, Type, f1, f2, f3, f4, 0);
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2902, execAddDecal );

IMPL_MATCH("Engine.dll", 0x10476d70)
void AR6DecalGroup::execDeActivateGroup( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execDeActivateGroup);
	P_FINISH;
	// Clears bActive bit (bit 0) of BITFIELD at this+0x3a0
	*(DWORD*)((BYTE*)this + 0x3a0) &= ~1u;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2905, execDeActivateGroup );

IMPL_MATCH("Engine.dll", 0x10476e20)
void AR6DecalGroup::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalGroup::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalGroup, 2903, execKillDecal );

IMPL_MATCH("Engine.dll", 0x10477a90)
void AR6DecalManager::execAddDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalManager::execAddDecal);
	P_GET_VECTOR(HitLocation);
	P_GET_ROTATOR(HitRotation);
	P_GET_OBJECT(UTexture,Tex);
	P_GET_BYTE(DecalType);
	P_GET_INT(Type);
	P_GET_FLOAT(f1);
	P_GET_FLOAT(f2);
	P_GET_FLOAT(f3);
	P_GET_FLOAT(f4);
	P_FINISH;
	*(INT*)Result = AddDecal(&HitLocation, &HitRotation, Tex, (eDecalType)DecalType, Type, f1, f2, f3, f4, 0);
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalManager, 2900, execAddDecal );

IMPL_MATCH("Engine.dll", 0x10477790)
void AR6DecalManager::execKillDecal( FFrame& Stack, RESULT_DECL )
{
	guard(AR6DecalManager::execKillDecal);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AR6DecalManager, 2901, execKillDecal );

/*-- AR6eviLTesting ----------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x10478e30)
void AR6eviLTesting::execNativeRunAllTests( FFrame& Stack, RESULT_DECL )
{
	guard(AR6eviLTesting::execNativeRunAllTests);
	P_FINISH;
	eviLTestATS();
	unguard;
}
IMPLEMENT_FUNCTION( AR6eviLTesting, 1356, execNativeRunAllTests );

/*-- UInteraction ------------------------------------------------------*/

// Ghidra 0x103b5fd0 (264 bytes).
// Dispatches Command to UInteractionMaster::Exec.
// Output device sourced from ViewportOwner (this+0x30) or Master's viewport chain (this+0x34 → +0x34 → +0x30[0]).
// Returns the INT result of Exec to the script VM.
IMPL_MATCH("Engine.dll", 0x103b5fd0)
void UInteraction::execConsoleCommand( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execConsoleCommand);
	P_GET_STR(Command);
	P_FINISH;
	UInteractionMaster* master = *(UInteractionMaster**)((BYTE*)this + 0x34);
	if (!master)
	{
		GWarn->Logf(TEXT(""));
		return;
	}
	UViewport* viewport = *(UViewport**)((BYTE*)this + 0x30);
	FOutputDevice* ar = NULL;
	if (viewport)
	{
		// Console output device is embedded at viewport+0x2c.
		ar = (FOutputDevice*)((BYTE*)viewport + 0x2c);
	}
	else
	{
		// Fall back to first viewport in master's client viewport array.
		// master+0x34 = some object (engine/client), that object+0x30 = Viewports TArray Data ptr.
		INT masterObj = *(INT*)((BYTE*)master + 0x34);
		if (masterObj)
		{
			INT firstVp = **(INT**)(masterObj + 0x30);
			if (firstVp)
				ar = (FOutputDevice*)(firstVp + 0x2c);
		}
	}
	*(INT*)Result = master->Exec(*Command, ar ? *ar : *GNull);
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execConsoleCommand );

// Ghidra 0x103b5ee0 (132 bytes).
// vtable+0x3c (slot 15) = UObject::GotoLabel — resets script state machine to None.
// Then fires the script event 'Initialized' via eventInitialized() (= FindFunctionChecked + ProcessEvent).
IMPL_MATCH("Engine.dll", 0x103b5ee0)
void UInteraction::execInitialize( FFrame& Stack, RESULT_DECL )
{
	guard(UInteraction::execInitialize);
	P_FINISH;
	GotoLabel(NAME_None);
	eventInitialized();
	unguard;
}
IMPLEMENT_FUNCTION( UInteraction, INDEX_NONE, execInitialize );

// =============================================================================

// =============================================================================
// AReplicationInfo
// =============================================================================

// AReplicationInfo
// ---------------------------------------------------------------------------
IMPL_EMPTY("Not in Engine.dll Ghidra export; confirmed empty virtual override")
void AReplicationInfo::StaticConstructor()
{
	guard(AReplicationInfo::StaticConstructor);
	unguard;
}

IMPL_EMPTY("Not in Engine.dll Ghidra export; confirmed empty virtual override")
void AReplicationInfo::StartVideo(UCanvas* Canvas, INT X, INT Y, INT Z)
{
	guard(AReplicationInfo::StartVideo);
	unguard;
}

IMPL_EMPTY("Not in Engine.dll Ghidra export; confirmed empty virtual override")
void AReplicationInfo::StopVideo(UCanvas* Canvas)
{
	guard(AReplicationInfo::StopVideo);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT AReplicationInfo::OpenVideo(UCanvas* Canvas, char* A, char* B, INT C)
{
	guard(AReplicationInfo::OpenVideo);
	// Ghidra 0x114310: shared zero-return vtable stub.
	return 0;
	unguard;
}

IMPL_EMPTY("Not in Engine.dll Ghidra export; confirmed empty virtual override")
void AReplicationInfo::ChangeDrawingSurface(ER6SwitchSurface Surface, INT Param)
{
	guard(AReplicationInfo::ChangeDrawingSurface);
	unguard;
}

/*-----------------------------------------------------------------------------
	PunkBuster export.
-----------------------------------------------------------------------------*/

IMPL_EMPTY("PunkBuster export stub; body intentionally empty")
extern "C" ENGINE_API void pb_Export() {}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
