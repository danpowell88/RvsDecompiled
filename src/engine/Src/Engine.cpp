/*=============================================================================
	Engine.cpp: Unreal engine package implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.

	This is the main translation unit for the Engine package. In Epic's
	Unreal Engine architecture every DLL is an "Unreal package" and must
	contain exactly one IMPLEMENT_PACKAGE() call. That macro expands to
	a DllMain-style entry point plus the package's static registration
	data so the engine's class/property system can discover everything
	at load time.

	This file also holds:
	  - IMPLEMENT_CLASS() for classes that don't have their own Un*.cpp
	  - UPrimitive virtual stubs (vtable must exist somewhere)
	  - Global engine variables (GEngineMem, GCache, GStats, ...)
	  - FName event/callback token definitions (ENGINE_Tick, etc.)

	Companion files in this module:
	  EngineStubs.cpp       - Trivial stub bodies for not-yet-decompiled exports
	  EngineClassImpl.cpp   - IMPLEMENT_CLASS, exec stubs, constructor shims
	  EngineEvents.cpp      - UnrealScript event thunks (ProcessEvent wrappers)
	  EngineLinkerShims.cpp - __FUNC_NAME__ / /alternatename linker tricks
	  Un*.cpp               - Per-class decompiled implementations
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Package implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(Engine);

// Classes declared in EngineClasses.h that live in Engine.cpp (no dedicated .cpp).
IMPLEMENT_CLASS(UPrimitive);
IMPLEMENT_CLASS(UMeshInstance);
IMPLEMENT_CLASS(URenderResource);
IMPLEMENT_CLASS(UPlayer);
IMPLEMENT_CLASS(UR6AbstractGameManager);
IMPLEMENT_CLASS(UR6MissionDescription);
IMPLEMENT_CLASS(UR6ModMgr);
IMPLEMENT_CLASS(UR6ServerInfo);
IMPLEMENT_CLASS(UR6GameOptions);
IMPLEMENT_CLASS(UGlobalTempObjects);
IMPLEMENT_CLASS(AR6eviLTesting);

/*-----------------------------------------------------------------------------
	UPrimitive virtual function stubs.
	The vtable requires definitions for all declared virtuals.
-----------------------------------------------------------------------------*/

void UPrimitive::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
}
INT UPrimitive::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{ return 0; }
INT UPrimitive::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags )
{ return 0; }
FBox UPrimitive::GetRenderBoundingBox( const AActor* Owner )
{ return FBox(0); }
FSphere UPrimitive::GetRenderBoundingSphere( const AActor* Owner )
{ return FSphere(0); }
FBox UPrimitive::GetCollisionBoundingBox( const AActor* Owner ) const
{ return FBox(0); }
INT UPrimitive::UseCylinderCollision( const AActor* Owner )
{ return 0; }
void UPrimitive::Illuminate( AActor* Owner, INT bDynamic )
{}
FVector UPrimitive::GetEncroachExtent( AActor* Owner )
{
	// Retail (37b, RVA 0xF78E0): cylindrical half-extents — uses CollisionRadius
	// for both X and Y, and CollisionHeight for Z.
	// CollisionRadius at Owner+0xF8, CollisionHeight at Owner+0xFC.
	FLOAT r = *(FLOAT*)((BYTE*)Owner + 0xF8);
	FLOAT h = *(FLOAT*)((BYTE*)Owner + 0xFC);
	return FVector(r, r, h);
}
FVector UPrimitive::GetEncroachCenter( AActor* Owner )
{
	// Retail (38b, RVA 0xF7730): returns FVector at Owner+0x234 (actor world position).
	return *(FVector*)((BYTE*)Owner + 0x234);
}

/*-----------------------------------------------------------------------------
	Global variables.
-----------------------------------------------------------------------------*/

// Engine globals — UT432 base.
ENGINE_API FMemStack		GEngineMem;
ENGINE_API FMemCache		GCache;

// Engine statistics.
ENGINE_API FEngineStats		GEngineStats;
ENGINE_API FStats			GStats;

// Tool subsystems (editor/rebuild).
ENGINE_API FRebuildTools	GRebuildTools;
ENGINE_API FMatineeTools	GMatineeTools;
ENGINE_API FTerrainTools	GTerrainTools;
ENGINE_API INT				GNumActiveScenes		= 0;

// Debug visualisation.
ENGINE_API FStatGraph*		GStatGraph			= NULL;
ENGINE_API FTempLineBatcher* GTempLineBatcher	= NULL;
ENGINE_API STDbgLine*		GDbgLine			= NULL;
ENGINE_API INT				GDbgLineIndex		= 0;

// Ravenshield-specific globals.
ENGINE_API UR6AbstractGameManager*	GR6GameManager			= NULL;
ENGINE_API UR6MissionDescription*	GR6MissionDescription	= NULL;
ENGINE_API UR6ModMgr*				GModMgr					= NULL;
ENGINE_API UR6ServerInfo*			GServerOptions			= NULL;
ENGINE_API UR6GameOptions*			GGameOptions			= NULL;
ENGINE_API UGlobalTempObjects*		GGlobalTempObjects		= NULL;
ENGINE_API AR6eviLTesting*			GEvilTest				= NULL;

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
	These are used by eventX() thunks to call UnrealScript event handlers.
	Each name is registered at package-load time and used for
	ProcessEvent( FindFunctionChecked(ENGINE_Xxx), &Parms ).
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) ENGINE_API FName ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
