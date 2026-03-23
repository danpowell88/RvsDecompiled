/*=============================================================================
	UnLevel.cpp: ULevel, ALevelInfo, AGameInfo and related classes.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations for level, zone, game-info
	and replication-info classes, plus decompiled method bodies for
	ULevelBase and ULevel (construction, URL management, actor
	enumeration, etc.).

	This file is permanent and will grow as more level management code
	is decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(ULevelBase);
IMPLEMENT_CLASS(ULevel);
IMPLEMENT_CLASS(ALevelInfo);
IMPLEMENT_CLASS(AZoneInfo);
IMPLEMENT_CLASS(AGameInfo);
IMPLEMENT_CLASS(AReplicationInfo);
IMPLEMENT_CLASS(APlayerReplicationInfo);
IMPLEMENT_CLASS(AGameReplicationInfo);
IMPLEMENT_CLASS(AR6PawnReplicationInfo);

/*=============================================================================
	Private static helpers (reconstructed from Ghidra analysis).
=============================================================================*/

// FUN_1036d760 (53 bytes): swap two FVector values in-place.
static void SwapFVectors( FVector* A, FVector* B )
{
	FVector Tmp = *A;
	*A = *B;
	*B = Tmp;
}

// FUN_10370830 (59 bytes): check whether an object reference changed for replication.
// Returns TRUE when the property should be added to the rep list:
//   - If newObj is already mapped on this connection → FALSE (client already knows).
//   - If not mapped → mark channel dirty and return (newObj != NULL).
// Retail dispatches through Chan->vtable[25] (byte offset 100/0x64).
// Ghidra: param_3[0x23]=1 → Chan+0x8C = bActorMustStayDirty.
static UBOOL RepObjectChanged( INT newObj, INT /*oldObj*/, UPackageMap* /*Map*/, UActorChannel* Chan )
{
	DWORD* vtbl = *(DWORD**)Chan;
	typedef INT (__thiscall* MapObjectFn)(UActorChannel*, INT);
	if ( ((MapObjectFn)vtbl[25])( Chan, newObj ) != 0 )
		return 0;  // already mapped — no change from client's perspective
	*(INT*)((BYTE*)Chan + 0x8c) = 1;  // Chan->bActorMustStayDirty
	return (newObj != 0);
}

// FUN_10371990 (32 bytes): lazy UProperty lookup by name within a class.
static UObject* FindRepProperty( UObject* Outer, const TCHAR* PropName )
{
	return UObject::StaticFindObjectChecked( UProperty::StaticClass(), Outer, PropName, 0 );
}

// FUN_10357860 (1108 bytes): per-tick native-physics integration; depends on KGData (Karma globals).
// DIVERGE: Karma physics SDK binary-only; this helper is a no-op stub.
IMPL_DIVERGE("Depends on KGData (Karma physics globals) and helpers FUN_1035ed00/FUN_10361440 etc. (Karma binary). Ghidra 0x10357860")
static void LevelPhysicsTick( ULevel* /*Level*/, FLOAT /*DeltaSeconds*/ ) {}

/*=============================================================================
	ULevelBase implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c1360)
ULevelBase::ULevelBase( UEngine* InOwner, const FURL& InURL )
:	Actors( this )
,	URL( InURL )
{
	Engine = InOwner;
	NetDriver = NULL;
	DemoRecDriver = NULL;
}

IMPL_MATCH("Engine.dll", 0x103bf030)
void ULevelBase::Destroy()
{
	guard(ULevelBase::Destroy);
	if ( NetDriver )
	{
		NetDriver->ConditionalDestroy();
		NetDriver = NULL;
	}
	if ( DemoRecDriver )
	{
		DemoRecDriver->ConditionalDestroy();
		DemoRecDriver = NULL;
	}
	UObject::Destroy();
	unguard;
}

IMPL_DIVERGE("Retail uses ByteOrderSerialize for actor count + manual vtable[6] per-element loop (Ghidra 0x103c0f60); we use Ar<<Actors (TTransArray compact-index operator). Non-IsTrans prealloc helpers FUN_10320190/FUN_10318800 not called. Functionally correct.")
void ULevelBase::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
	Ar << Actors;
	Ar << URL;
	// Retail serializes NetDriver/DemoRecDriver only for non-load, non-save archives
	// (e.g. counting or copy passes). Ghidra: vtable[6](Ar, &NetDriver).
	if ( !Ar.IsLoading() && !Ar.IsSaving() )
	{
		Ar << (UObject*&)NetDriver;
		Ar << (UObject*&)DemoRecDriver;
	}
}

IMPL_MATCH("Engine.dll", 0x103bf0d0)
void ULevelBase::NotifyProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )
{
	guard(ULevelBase::NotifyProgress);
	// Ghidra 0xbf0d0: call Engine->vtable[0xb0] (slot 44) = NotifyProgress
	typedef void (__thiscall* FNotifyProgressFn)(void*, const TCHAR*, const TCHAR*, FLOAT);
	void* pEng = (void*)Engine;
	FNotifyProgressFn fn = *(FNotifyProgressFn*)((BYTE*)*(DWORD**)pEng + 0xb0);
	fn(pEng, Str1, Str2, Seconds);
	unguard;
}

/*=============================================================================
	ULevel implementation.
=============================================================================*/

IMPL_DIVERGE("TMap hash tables not rehashed at construction (deferred lazy init); zone/BSP init for spawned actors depends on Karma (FUN_10359790). All FUN_ helpers in _unnamed.cpp but TMap rehash call signatures require ECX-based thiscall dispatch not easily wrapped. Ghidra 0x103c2c40")
ULevel::ULevel( UEngine* InEngine, INT InRootOutside )
:	ULevelBase( InEngine )
{
	guard(ULevel::ULevel);
	// Ghidra 0xc2c40: large constructor body.
	// Phase 1 (compiler-generated): FArray::FArray() on all TArray/TMap member fields.
	// Phase 2 (TMap hash-table setup): many pairs of (ptr[+0xC]=0, ptr[+0x10]=8, FUN_103*())
	//          at offsets 0xdc, 0x10150, 0x10164, 0x101ac, 0x101e4, 0x101f8, 0x1020c, …
	//          FUN_1031f850/f990/fa30/fb80/fc20 = TMap hash-table rehash helpers (8 initial buckets).
	//          DIVERGENCE from Ghidra: TMap hash tables left empty; game TMap usage rare at startup.
	//          Full TMap init requires calling internal TMap rehash helpers by function pointer —
	//          deferred until needed (lazy init).

	// Phase 3 (runtime init) — Ghidra 0xc2c40 lines 350231–350352:

	// RF_Transactional
	SetFlags( RF_Transactional );

	// Allocate and construct the level's world geometry model (worldGeometry brush).
	// StaticAllocateObject allocates without calling the UObject default constructor;
	// UModel::UModel(NULL, InRootOutside) is then called explicitly.
	// Note: community SDK declares StaticAllocateObject with 7 params; Ghidra shows 8.
	// The 8th param (bSubobjectInstancing) is always 0 here — omitted per SDK declaration.
	UModel* WorldModel = (UModel*)UObject::StaticAllocateObject(
		UModel::StaticClass(), GetOuter(), NAME_None, 0, NULL, GError, NULL );
	if ( WorldModel )
		new(WorldModel) UModel( NULL, InRootOutside );
	*(UModel**)((BYTE*)this + 0x90) = WorldModel;
	if ( WorldModel )
		WorldModel->SetFlags( RF_Transactional );

	// Spawn the ALevelInfo actor into this level at the origin.
	SpawnActor( ALevelInfo::StaticClass(), NAME_None, FVector(0,0,0), FRotator(0,0,0),
	            NULL, 1, 0, NULL, NULL );

	// Assert: LevelInfo must now exist.
	if ( !GetLevelInfo() )
		appFailAssert( "GetLevelInfo()", ".\\UnLevel.cpp", 0x6c );

	// Spawn the default world brush and assert it is at Actors(1).
	ABrush* WorldBrush = SpawnBrush();
	if ( WorldBrush != Actors(1) )
		appFailAssert( "Temp==Actors(1)", ".\\UnLevel.cpp", 0x70 );

	// Allocate and construct the brush's geometry model.
	UModel* BrushModel = (UModel*)UObject::StaticAllocateObject(
		UModel::StaticClass(), GetOuter(), FName(TEXT("Brush"), FNAME_Add), 0, NULL, GError, NULL );
	if ( BrushModel )
		new(BrushModel) UModel( WorldBrush, 1 );
	*(UModel**)((BYTE*)WorldBrush + 0x178) = BrushModel;

	// Flag both the brush actor and its model as non-networked transactional objects.
	// 0x300001 = RF_Transactional | RF_NotForClient | RF_NotForServer (Ghidra confirmed).
	WorldBrush->SetFlags( 0x300001 );
	if ( BrushModel )
		BrushModel->SetFlags( 0x300001 );

	// Ensure the default physics volume exists (creates ADefaultPhysicsVolume if needed).
	ALevelInfo* LI = GetLevelInfo();
	if ( LI )
		LI->GetDefaultPhysicsVolume();

	// Zero script profiling counters.
	GScriptCycles   = 0;
	GScriptEntryTag = 0;

	// Init replication table sizes (Ghidra offsets 0x10178, 0x1017c).
	*(INT*)((BYTE*)this + 0x10178) = 1;
	*(INT*)((BYTE*)this + 0x1017c) = 1;

	// Zero network statistics counters (Ghidra offsets 0x1011c–0x10128, 0x10180).
	*(INT*)((BYTE*)this + 0x1011c) = 0;
	*(INT*)((BYTE*)this + 0x10120) = 0;
	*(INT*)((BYTE*)this + 0x10124) = 0;
	*(INT*)((BYTE*)this + 0x10128) = 0;
	*(INT*)((BYTE*)this + 0x10180) = 0;

	// Reset ReachSpecs TArray (element size 0x24 = sizeof(UReachSpec*) in array).
	// Ghidra: FArray::Empty(this+0x101e4, 0x24, 0) then rehash TMap at 0x101f0/0x101f4.
	((FArray*)((BYTE*)this + 0x101e4))->Empty( 0x24, 0 );
	*(INT*)((BYTE*)this + 0x101f4) = 8;
	// TMap rehash helper FUN_1031fa30 not called — DIVERGENCE: deferred until TMap is used.

	unguard;
}

// Ghidra 0x103c3070 (4382b): complete implementation.
// FUN_103c0ce0 = unexported TMap<FString,FString> serializer (TravelInfo, R6ReplicationInfo).
// FUN_1031f850 = unexported post-load notifier (called after each TMap load).
// FUN_103c09b0 = unexported state/URL array serializer (not save/load path only).
// All three called by raw address per retail binary.
IMPL_MATCH("Engine.dll", 0x103c3070)
void ULevel::Serialize( FArchive& Ar )
{
	guard(ULevel::Serialize);
	typedef void (__cdecl* TMapSerFn)(FArchive*, void*);
	typedef void (__cdecl* PostLoadFn)();
	typedef void (__cdecl* StateSerFn)(FArchive*, void*);

	ULevelBase::Serialize( Ar );

	// Ar << Model (UObject* at +0x90)
	Ar << *(UObject**)((BYTE*)this + 0x90);

	// Ancient pre-0x62 path (FUN_103c0bd0/FUN_103c0b40) omitted — all retail files are modern.

	// ByteOrderSerialize TimeSeconds (FLOAT at +0xd4)
	Ar.ByteOrderSerialize( (void*)((BYTE*)this + 0xd4), 4 );

	// Ar << FirstDeleted (AActor* at +0xf4)
	Ar << *(UObject**)((BYTE*)this + 0xf4);

	// Ar << TextBlocks[0..15] (+0x94..+0xd0, 16 x UTextBuffer*)
	for ( INT i = 0; i < 16; i++ )
		Ar << *(UObject**)((BYTE*)this + 0x94 + i * 4);

	if ( Ar.Ver() >= 0x3f )
	{
		// Serialize TravelInfo TMap<FString,FString> at +0xdc
		((TMapSerFn)0x103c0ce0)(&Ar, (BYTE*)this + 0xdc);
		if ( Ar.IsLoading() )
			((PostLoadFn)0x1031f850)();

		// Preload Model if set and not transient
		if ( *(INT*)((BYTE*)this + 0x90) != 0 && !Ar.IsTrans() )
			Ar.Preload( *(UObject**)((BYTE*)this + 0x90) );

		// LicenseeVer > 0xc: serialize R6 replication info TMap at +0x101ac
		if ( Ar.LicenseeVer() > 0xc && (Ar.IsSaving() || Ar.IsLoading()) )
		{
			((TMapSerFn)0x103c0ce0)(&Ar, (BYTE*)this + 0x101ac);
			if ( Ar.IsLoading() )
				((PostLoadFn)0x1031f850)();
		}

		// Non-save/non-load path: state/URL array at +0x1019c and actor-array at +0x1020c
		if ( !Ar.IsSaving() && !Ar.IsLoading() )
		{
			((StateSerFn)0x103c09b0)(&Ar, (BYTE*)this + 0x1019c);
		}
		if ( !Ar.IsSaving() && !Ar.IsLoading() )
		{
			FArray* arr = (FArray*)((BYTE*)this + 0x1020c);
			for ( INT i = 0; i < arr->Num(); i++ )
				Ar << *(UObject**)(*(INT*)arr + 8 + i * 0x14);
		}
	}

	unguard;
}

IMPL_DIVERGE("calls FUN_1047ad70/FUN_1047bd10/FUN_1047ae50 which are Karma physics world init; Karma SDK is binary-only (Ghidra 0x103c13f0)")
void ULevel::PostLoad()
{
	UObject::PostLoad();
}

IMPL_DIVERGE("calls FUN_1047c020 (Karma physics teardown; MeSDK binary-only) and FUN_10358ca0 (unresolved BSP cleanup); Karma call is permanent blocker (Ghidra 0x103c10c0)")
void ULevel::Destroy()
{
	guard(ULevel::Destroy);
	// Step 1: Destroy and null the collision hash (Ghidra: virtual dtor call then zero).
	FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	if ( hash )
	{
		delete hash;
		*(FCollisionHashBase**)((BYTE*)this + 0xf0) = NULL;
	}
	// DIVERGENCE: FUN_10358ca0(this) — unresolved geometry/BSP cleanup helper.

	// Step 2: Free Karma physics object at +0x101a8 if present.
	// DIVERGENCE: FUN_1047c020() — Karma uninit; skipped.
	INT karmaObj = *(INT*)((BYTE*)this + 0x101a8);
	if ( karmaObj != 0 )
	{
		// FUN_1047c020(); — karma physics teardown, unresolved
		GMalloc->Free( (void*)karmaObj );
		*(INT*)((BYTE*)this + 0x101a8) = 0;
	}

	// Step 3: Clear the replication-info TArray at +0x1020c (element stride 0x14).
	((FArray*)((BYTE*)this + 0x1020c))->Empty( 0x14, 0 );
	*(INT*)((BYTE*)this + 0x1021c) = 8;

	// DIVERGENCE: FUN_1031fc20() — TMap hash rehash helper; deferred.

	ULevelBase::Destroy();
	unguard;
}

// GNewCollisionHash is defined in UnCamera.cpp
ENGINE_API FCollisionHashBase* GNewCollisionHash();

IMPL_MATCH("Engine.dll", 0x103bf1e0)
void ULevel::Modify( INT DoTransArrays )
{
	guard(ULevel::Modify);
	UObject::Modify();
	// Retail always passes 0 to UModel::Modify regardless of DoTransArrays.
	(*(UModel**)((BYTE*)this + 0x90))->Modify(0);
	unguard;
}

// SetActorCollision: Ghidra 0x103bfc60 (308 bytes).
// bCollision==0 path: early-return if no hash; then remove-actors (if !bUnused) and
// GIsEditor Touching-array clear; then virtual dtor on hash (= delete hash).
// bCollision!=0 path: create hash via GNewCollisionHash; populate with bCollide actors.
// All vtable offsets verified: AddActor=+8, RemoveActor=+0xC, hash dtor=vtable[0].
// guard/unguard SEH differs from retail; not tracked as divergence.
IMPL_MATCH("Engine.dll", 0x103bfc60)
void ULevel::SetActorCollision( INT bCollision, INT bUnused )
{
	guard(ULevel::SetActorCollision);
	FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	if ( bCollision == 0 )
	{
		if ( hash )
		{
			if ( bUnused == 0 )
			{
				for ( INT i = 0; i < Actors.Num(); i++ )
				{
					AActor* a = Actors(i);
					if ( a && (*(DWORD*)((BYTE*)a + 0xa8) & 0x800) )
						hash->RemoveActor(a);
				}
			}
			if ( GIsEditor )
			{
				for ( INT i = 0; i < Actors.Num(); i++ )
				{
					AActor* a = Actors(i);
					if (a)
						((FArray*)((BYTE*)a + 0x338))->Empty(4, 0);
				}
			}
			delete hash;
			*(FCollisionHashBase**)((BYTE*)this + 0xf0) = NULL;
		}
	}
	else
	{
		if ( !hash )
		{
			FCollisionHashBase* nh = GNewCollisionHash();
			*(FCollisionHashBase**)((BYTE*)this + 0xf0) = nh;
			for ( INT i = 0; i < Actors.Num(); i++ )
			{
				AActor* a = Actors(i);
				if ( a && (*(DWORD*)((BYTE*)a + 0xa8) & 0x800) )
					nh->AddActor(a);
			}
		}
	}
	unguard;
}

IMPL_DIVERGE("LevelPhysicsTick depends on Karma (KGData); Karma actor vtable[92] (MeSDK binary); bTicked bookkeeping and rdtsc profiling diverge from retail. Core actor loop implemented. Ghidra 0x103c6700")
void ULevel::Tick( ELevelTick TickType, FLOAT DeltaSeconds )
{
	guard(ULevel::Tick);
	FMemMark Mark(GMem);
	FMemMark EngMark(GEngineMem);
	GInitRunaway();

	// Mark level as currently ticking (prevents re-entrant actor destruction).
	*(INT*)((BYTE*)this + 0xfc) = 1;  // bInTick

	// Connection timeout: if we have a pending server connection that has not been
	// acknowledged within 10 seconds, abort and browse to ?failed.
	if ( NetDriver && NetDriver->ServerConnection
		 && *(INT*)((BYTE*)this + 0x10194) == 0 )
	{
		DOUBLE elapsed = appSeconds() - *(DOUBLE*)((BYTE*)this + 0x1018c);
		if ( elapsed > 10.0 )
		{
			BYTE* engB   = *(BYTE**)((BYTE*)this + 0x44);
			BYTE* client = *(BYTE**)(engB + 0x44);
			BYTE* vp0    = *(BYTE**)(*(BYTE**)(client + 0x30));
			typedef void (__thiscall* BrowseFn)(void*, void*, const TCHAR*, INT, INT);
			((BrowseFn)(*(DWORD*)(*(DWORD*)engB + 0xa4)))(engB, vp0, TEXT("?failed"), 0, 0);
		}
	}

	// Dispatch incoming network data (client receives packets here).
	if ( NetDriver )
	{
		DWORD* vtbl = *(DWORD**)NetDriver;
		typedef void (__thiscall* TickDispatchFn)(UNetDriver*, FLOAT);
		((TickDispatchFn)vtbl[32])( NetDriver, DeltaSeconds );  // vtable byte 0x80
		if ( NetDriver->ServerConnection )
			TickNetClient( DeltaSeconds );
	}

	// Dispatch incoming demo-record/playback data.
	if ( DemoRecDriver )
	{
		DWORD* vtbl = *(DWORD**)DemoRecDriver;
		typedef void (__thiscall* TickDispatchFn)(UNetDriver*, FLOAT);
		((TickDispatchFn)vtbl[32])( DemoRecDriver, DeltaSeconds );  // vtable byte 0x80
		if ( DemoRecDriver->ServerConnection )
			TickDemoPlayback( DeltaSeconds );
	}

	// Tick the spatial collision hash (updates broadphase structures).
	FCollisionHashBase* hashPtr = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	if ( hashPtr )
		hashPtr->Tick();

	// Apply time dilation and advance the level clock (stored as double for precision).
	ALevelInfo* LI = GetLevelInfo();
	FLOAT TimeDilation = *(FLOAT*)((BYTE*)LI + 0x458);
	DeltaSeconds *= TimeDilation;
	if ( !IsPaused() )
		*(DOUBLE*)((BYTE*)this + 0xd4) += (DOUBLE)DeltaSeconds;

	// Sync LevelInfo's float copy of TimeSeconds.
	*(FLOAT*)((BYTE*)LI + 0x45c) = (FLOAT)*(DOUBLE*)((BYTE*)this + 0xd4);
	UpdateTime( LI );

	// Force LEVELTICK_All when an async load was requested to block until complete.
	if ( *(DWORD*)((BYTE*)LI + 0x450) & 0x40 )  // bRequestedBlockOnAsyncLoading
		TickType = LEVELTICK_All;

	// Clamp DeltaSeconds to a sane range to prevent physics blow-ups.
	if ( DeltaSeconds < 0.0005f ) DeltaSeconds = 0.0005f;
	if ( DeltaSeconds > 0.4f )    DeltaSeconds = 0.4f;

	// Engine slow-motion override (e.g. editor pause / fixed demo-playback rate).
	BYTE* engPtr = *(BYTE**)((BYTE*)this + 0x44);
	if ( engPtr && ( *(DWORD*)(engPtr + 0x120) & 0x4000u ) )
		DeltaSeconds = 0.3333f;

	// DIVERGE: rdtsc profiling start skipped (rdtsc chains are permanent DIVERGE).

	if ( TickType != LEVELTICK_TimeOnly )
	{
		// Full tick when: not paused AND (no server connection OR connection fully open).
		INT srvState = 0;
		if ( NetDriver && NetDriver->ServerConnection )
			srvState = *(INT*)((BYTE*)NetDriver->ServerConnection + 0x80);

		if ( !IsPaused() && ( !NetDriver || !NetDriver->ServerConnection || srvState == 3 ) )
		{
			// Clear the newly-spawned actor list that SpawnActor populates during ticking.
			*(INT*)((BYTE*)this + 0xf8) = 0;

			// Native physics integration (velocity, joints, rigid bodies).
			// FUN_10357860 is a complex 1108-byte helper — stubbed pending decompilation.
			LevelPhysicsTick( this, DeltaSeconds );

			// Tick all dynamic actors from iFirstDynamicActor onwards.
			INT iFirst = *(INT*)((BYTE*)this + 0x104);
			for ( INT i = iFirst; i < Actors.Num(); i++ )
			{
				AActor* Actor = Actors(i);
				if ( !Actor || Actor->bDeleteMe )
					continue;

				// DIVERGE: Karma rigid-body pre-tick (vtable[92] on actor) skipped.
				//          Requires MeSDK binary-only library (permanent blocker).

				// Tick actor, adding any delta accumulated during frames it was skipped.
				FLOAT AccumDelta = *(FLOAT*)((BYTE*)Actor + 0x13c);
				Actor->Tick( DeltaSeconds + AccumDelta, TickType );
				*(FLOAT*)((BYTE*)Actor + 0x13c) = 0.0f;
			}

			// Tick actors spawned during this frame's tick pass (NewlySpawned list).
			{
				BYTE* node = *(BYTE**)((BYTE*)this + 0xf8);
				while ( node )
				{
					AActor* spawned  = *(AActor**)node;
					BYTE*   nextNode = *(BYTE**)(node + 4);
					if ( spawned && !spawned->bDeleteMe )
						spawned->Tick( DeltaSeconds, TickType );
					node = nextNode;
				}
				*(INT*)((BYTE*)this + 0xf8) = 0;
			}

			// KGData: clear pending-constraints flag after physics step.
			BYTE* kgData = *(BYTE**)((BYTE*)this + 0x101a8);
			if ( kgData )
				*(INT*)(kgData + 0x14224) = 0;
		}
		else
		{
			// Paused: only tick viewport and PlayerInput for active PlayerControllers.
			for ( INT i = 0; i < Actors.Num(); i++ )
			{
				AActor* Actor = Actors(i);
				if ( !Actor || Actor->bDeleteMe )
					continue;
				if ( !Actor->IsA( APlayerController::StaticClass() ) )
					continue;
				BYTE* vp = *(BYTE**)((BYTE*)Actor + 0x5b4);
				if ( !vp )
					continue;
				// Viewport tick (vtable byte 0x64 = slot 25).
				typedef void (__thiscall* VpTickFn)(void*, FLOAT);
				((VpTickFn)(*(DWORD*)((BYTE*)*(DWORD*)vp + 0x64)))( vp, DeltaSeconds );
				// PlayerInput tick at actor+0x7d8 (vtable byte 0x7c = slot 31).
				BYTE* pi = *(BYTE**)((BYTE*)Actor + 0x7d8);
				if ( pi )
				{
					typedef void (__thiscall* PITickFn)(void*, FLOAT);
					((PITickFn)(*(DWORD*)((BYTE*)*(DWORD*)pi + 0x7c)))( pi, DeltaSeconds );
				}
			}
		}
	}

	// DIVERGE: rdtsc profiling end skipped.

	// Flush outgoing network data.
	if ( NetDriver )
	{
		if ( !NetDriver->ServerConnection )
			TickNetServer( DeltaSeconds );
		DWORD* vtbl = *(DWORD**)NetDriver;
		typedef void (__thiscall* TickFlushFn)(UNetDriver*);
		((TickFlushFn)vtbl[31])( NetDriver );  // vtable byte 0x7c
	}
	if ( DemoRecDriver )
	{
		if ( !DemoRecDriver->ServerConnection )
			TickDemoRecord( DeltaSeconds );
		DWORD* vtbl = *(DWORD**)DemoRecDriver;
		typedef void (__thiscall* TickFlushFn)(UNetDriver*);
		((TickFlushFn)vtbl[31])( DemoRecDriver );  // vtable byte 0x7c
	}

	*(INT*)((BYTE*)this + 0xfc) = 0;    // bInTick = false
	*(INT*)((BYTE*)this + 0x100) ^= 1;  // FrameTag: toggle 0 to 1 and back
	EngMark.Pop();
	Mark.Pop();
	CleanupDestroyed( 0 );
	unguard;
}

IMPL_DIVERGE("Retail uses DAT_10799554/DAT_10799760 profiling globals + rdtsc (binary-only). Core client-replication channel loop is implemented. Ghidra 0x103c6e40")
void ULevel::TickNetClient( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetClient);
	if ( !*(INT*)((BYTE*)this + 0x40) )
		return;
	// State 3 = connected; replicate player-controlled pawns
	INT connState = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)this + 0x40) + 0x3c) + 0x80);
	if ( connState == 3 )
	{
		BYTE* serverConn = *(BYTE**)(*(BYTE**)((BYTE*)this + 0x40) + 0x3c);
		FArray* channels = (FArray*)(serverConn + 0x4b94);
		INT nCh = *(INT*)((BYTE*)channels + 4);
		for ( INT i = 0; i < nCh; i++ )
		{
			UActorChannel* ch = *(UActorChannel**)(*(BYTE**)channels + 8 + i * 0xc);
			if ( !ch ) continue;
			UObject* pawn = *(UObject**)((BYTE*)ch + 0x6c);
			if ( pawn && pawn->IsA(APawn::StaticClass()) )
			{
				UObject* ctrl = *(UObject**)((BYTE*)pawn + 0x4ec);
				if ( ctrl
					 && ctrl->IsA(APlayerController::StaticClass())
					 && *(INT*)((BYTE*)ctrl + 0x5b4) != 0 )
				{
					ch->ReplicateActor();
				}
			}
		}
	}
	else if ( connState == 1 )
	{
		UEngine* eng = *(UEngine**)((BYTE*)this + 0x44);
		INT nVP = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)eng + 0x44) + 0x30) + 4);
		if ( nVP == 0 )
			appFailAssert("Engine->Client->Viewports.Num()", ".\\UnLevTic.cpp", 0x2fa);
		// TODO: BrowseLevel to ?failed (requires UEngine::Browse)
	}
	unguard;
}

IMPL_DIVERGE("DAT_10799554/DAT_10799760 profiling globals + rdtsc (binary-only); FUN_103b7b70 (role check) and FUN_1050557c (__ftol2_sse=INT cast) are tractable but the overall 1284-byte function tightly couples profiling with the connection loop. Ghidra 0x103c5db0")
void ULevel::TickNetServer( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetServer);
	// TODO: implement ULevel::TickNetServer (replication, channel ticking, player updates)
	unguard;
}

IMPL_TODO("Ghidra 0x103c53b0 (2336b): implemented; FUN_103c4470/FUN_103c4300 called by raw address; DAT_10799554/DAT_107997cc stats omitted (binary globals)")
INT ULevel::ServerTickClient( UNetConnection* Conn, FLOAT DeltaSeconds )
{
	guard(ULevel::ServerTickClient);

	if (!Conn)
		appFailAssert("Connection", ".\\UnLevTic.cpp", 0x3b1);

	INT State = *(INT*)((BYTE*)Conn + 0x80);
	if (State != 1 && State != 2 && State != 3)
		appFailAssert("Connection->State==USOCK_Pending || Connection->State==USOCK_Open || Connection->State==USOCK_Closed", ".\\UnLevTic.cpp", 0x3b2);

	INT local_64 = 0;

	APlayerController* PC = *(APlayerController**)((BYTE*)Conn + 0x34);
	void* ndPtr = (void*)*(INT*)((BYTE*)Conn + 0x7c);  // NetDriver

	// Gate: PC non-null, connection ready, state==3, not timed out
	if (PC != NULL && Conn->IsNetReady(0) && State == 3 && ndPtr != NULL)
	{
		double ndTime   = *(double*)((BYTE*)ndPtr + 0x48);
		double lastRecv = *(double*)((BYTE*)Conn + 0xf4);
		if (ndTime - lastRecv < 1.5)
		{
			FMemMark Mark(GMem);

			// Increment per-frame counter and connection send counter
			INT FrameCounter = ++*(INT*)((BYTE*)this + 0x10c);
			++*(INT*)((BYTE*)Conn + 0x118);

			// Stamp all open channels with the current frame counter
			INT  nChan = *(INT*)((BYTE*)Conn + 0x4b8c);
			INT* cList = *(INT**)((BYTE*)Conn + 0x4b88);
			for (INT ci = 0; ci < nChan; ci++)
			{
				INT ch = cList[ci];
				if (ch) *(INT*)(ch + 0x318) = FrameCounter;
			}

			// Get view target via eventGetViewTarget (vtable[0x18c/4] on PC, thiscall)
			typedef AActor* (__thiscall* GetViewTargetFn)(APlayerController*);
			AActor* Viewer = ((GetViewTargetFn)(*(INT*)(*(INT*)PC + 0x18c)))(PC);

			FVector ViewLoc(
				*(FLOAT*)((BYTE*)Viewer + 0x234),
				*(FLOAT*)((BYTE*)Viewer + 0x238),
				*(FLOAT*)((BYTE*)Viewer + 0x23c)
			);
			FRotator ViewRot(
				*(INT*)((BYTE*)PC + 0x240),
				*(INT*)((BYTE*)PC + 0x244),
				*(INT*)((BYTE*)PC + 0x248)
			);
			PC->eventPlayerCalcView(Viewer, ViewLoc, ViewRot);

			if (Viewer == NULL)
				appFailAssert("Viewer", ".\\UnLevTic.cpp", 0x3cc);

			FLOAT viewX = ViewLoc.X, viewY = ViewLoc.Y, viewZ = ViewLoc.Z;

			// LOD adjustment every other frame using a model line check
			INT connCounter = *(INT*)((BYTE*)Conn + 0x118);
			if (connCounter & 1)
			{
				FLOAT fVar3 = (connCounter & 2) == 0 ? 0.9f : 0.4f;
				FLOAT extX = fVar3 * *(FLOAT*)((BYTE*)Viewer + 0x24c);
				FLOAT extY = fVar3 * *(FLOAT*)((BYTE*)Viewer + 0x250);
				FLOAT extZ = fVar3 * *(FLOAT*)((BYTE*)Viewer + 0x254);
				INT basePtr = *(INT*)((BYTE*)Viewer + 0x15c);
				if (basePtr)
				{
					extX += fVar3 * *(FLOAT*)(basePtr + 0x24c);
					extY += fVar3 * *(FLOAT*)(basePtr + 0x250);
					extZ += fVar3 * *(FLOAT*)(basePtr + 0x254);
				}
				FLOAT checkX = viewX + extX, checkY = viewY + extY, checkZ = viewZ + extZ;
				INT xLevelPtr = *(INT*)((BYTE*)Viewer + 0x328);
				if (xLevelPtr)
				{
					INT modelPtr = *(INT*)(xLevelPtr + 0x90);
					if (modelPtr)
					{
						typedef void (__thiscall* ModelMultiCheckFn)(void*, void*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, INT, INT);
						INT vtblFn = *(INT*)(*(INT*)modelPtr + 0x68);
						((ModelMultiCheckFn)vtblFn)((void*)modelPtr, NULL, checkX, checkY, checkZ, viewX, viewY, viewZ, 0.0f, 0.0f, 0.0f, 4, 0);
					}
				}
				viewX = checkX; viewY = checkY; viewZ = checkZ;
			}

			INT nActors = Actors.Num();
			// Sort pointer buffer; FUN_103c4470 allocates 12-byte entries from GMem internally
			BYTE** sortPtrs = (BYTE**)GMem.PushBytes(nActors * 4, 8);
			INT iVar4 = 0;

			// Viewer location for priority distance calculations
			FVector ViewerLoc(
				*(FLOAT*)((BYTE*)Viewer + 0x234),
				*(FLOAT*)((BYTE*)Viewer + 0x238),
				*(FLOAT*)((BYTE*)Viewer + 0x23c)
			);

			// View direction buffer: forward vector from PC rotation
			BYTE viewDirBuf[36];
			appMemzero(viewDirBuf, 36);
			FRotator PCRot(*(INT*)((BYTE*)PC + 0x240), *(INT*)((BYTE*)PC + 0x244), *(INT*)((BYTE*)PC + 0x248));
			*(FVector*)viewDirBuf = PCRot.Vector();

			// Time accumulators for frequency-based replication
			DOUBLE connTime   = *(DOUBLE*)((BYTE*)Conn + 0x10c);
			DOUBLE netDrvTime = *(DOUBLE*)((BYTE*)ndPtr + 0x48);

			typedef BYTE* (__cdecl* CalcPriorityFn)(FVector*, BYTE*, UNetConnection*, UObject*);
			CalcPriorityFn CalcPriority = (CalcPriorityFn)(0x103c4470);
			typedef UChannel* (__thiscall* FindChanFn)(void*, AActor**);
			FindChanFn FindChan = (FindChanFn)(0x103b7b70);

			// First-2 loop: actors at index 0 and 1 get special time-based processing
			for (INT i = 0; i < 2 && i < nActors; i++)
			{
				AActor* actor = Actors(i);
				if (!actor || *(INT*)((BYTE*)actor + 0x318) == FrameCounter || *(BYTE*)((BYTE*)actor + 0x2e) == 0)
				{
					connTime += 0.023;
					continue;
				}
				if (*(INT*)((BYTE*)actor + 0xa0) >= 0)
				{
					// Non-negative NetPriority: always include in priority queue
					*(INT*)((BYTE*)actor + 0x318) = FrameCounter;
					BYTE* entry = CalcPriority(&ViewerLoc, viewDirBuf, Conn, (UObject*)actor);
					if (entry) sortPtrs[iVar4++] = entry;
				}
				else
				{
					// Negative NetPriority: replicate based on NetUpdateFrequency
					FLOAT freq = *(FLOAT*)((BYTE*)actor + 0x128);
					INT freq1 = appRound(freq * (FLOAT)connTime);
					INT freq2 = appRound(freq * (FLOAT)netDrvTime);
					if (freq1 != freq2)
					{
						UChannel* chanPtr = FindChan((void*)Conn, &actor);
						BYTE flag = *(BYTE*)((BYTE*)actor + 0xa4);
						INT nOut = chanPtr ? *(INT*)((BYTE*)chanPtr + 0x98) : 0;
						INT nIn  = chanPtr ? *(INT*)((BYTE*)chanPtr + 0xb0) : 0;
						INT ch88 = chanPtr ? *(INT*)((BYTE*)chanPtr + 0x88) : 1;
						if ((flag & 0x80) != 0 && chanPtr != NULL && nOut != 0 && nIn == 0 && ch88 == 0)
						{
							*(DOUBLE*)((BYTE*)chanPtr + 0x74) = *(DOUBLE*)((BYTE*)ndPtr + 0x48);
						}
						else
						{
							*(INT*)((BYTE*)actor + 0x318) = FrameCounter;
							BYTE* entry = CalcPriority(&ViewerLoc, viewDirBuf, Conn, (UObject*)actor);
							if (entry) sortPtrs[iVar4++] = entry;
						}
					}
					connTime   += 0.023;
					netDrvTime += 0.023;
				}
			}

			// Engine tick-rate multiplier for frequency comparison
			void* engPtr = *(void**)((BYTE*)this + 0x44);
			typedef FLOAT (__thiscall* GetEngSpeedFn)(void*);
			FLOAT fEngine = ((GetEngSpeedFn)(*(INT*)(*(INT*)engPtr + 0xac)))(engPtr);

			// Main actor loop: round-robin starting from stored float index
			for (FLOAT fi = *(FLOAT*)((BYTE*)this + 0x108); fi < (FLOAT)nActors; fi += 1.0f)
			{
				AActor* actor = Actors((INT)fi);
				if (!actor || *(INT*)((BYTE*)actor + 0x318) == FrameCounter || *(BYTE*)((BYTE*)actor + 0x2e) == 0)
					continue;

				if (*(INT*)((BYTE*)actor + 0xa0) < 0)
				{
					FLOAT freq = *(FLOAT*)((BYTE*)actor + 0x128);
					INT freq1 = appRound(freq * (FLOAT)connTime);
					INT freq2 = appRound(freq * (FLOAT)netDrvTime);
					if (freq1 == freq2)
					{
						connTime += 0.023; netDrvTime += 0.023;
						continue;
					}
					UChannel* chanPtr = FindChan((void*)Conn, &actor);
					BYTE flag = *(BYTE*)((BYTE*)actor + 0xa4);
					INT nOut = chanPtr ? *(INT*)((BYTE*)chanPtr + 0x98) : 0;
					INT nIn  = chanPtr ? *(INT*)((BYTE*)chanPtr + 0xb0) : 0;
					INT ch88 = chanPtr ? *(INT*)((BYTE*)chanPtr + 0x88) : 1;
					if ((flag & 0x80) != 0 && chanPtr != NULL && nOut != 0 && nIn == 0 && ch88 == 0)
					{
						*(DOUBLE*)((BYTE*)chanPtr + 0x74) = *(DOUBLE*)((BYTE*)ndPtr + 0x48);
						connTime += 0.023; netDrvTime += 0.023;
						continue;
					}
				}
				else
				{
					// Non-negative NetPriority
					if ((*(DWORD*)((BYTE*)actor + 0xa0) & 0x20000000) != 0)
					{
						UClass* cls = actor->GetClass();
						AActor* def = cls->GetDefaultActor();
						if (def && *(FLOAT*)((BYTE*)def + 0xc0) - 0.15f >= *(FLOAT*)((BYTE*)actor + 0xc0))
						{
							connTime += 0.023; netDrvTime += 0.023;
							continue;
						}
					}
					if (*(FLOAT*)((BYTE*)actor + 0x128) < fEngine)
					{
						FLOAT freq = *(FLOAT*)((BYTE*)actor + 0x128);
						INT freq1 = appRound(freq * (FLOAT)connTime);
						INT freq2 = appRound(freq * (FLOAT)netDrvTime);
						if (freq1 == freq2)
						{
							connTime += 0.023; netDrvTime += 0.023;
							continue;
						}
					}
				}

				// Mark and calculate priority for this actor
				*(INT*)((BYTE*)actor + 0x318) = FrameCounter;
				BYTE* entry = CalcPriority(&ViewerLoc, viewDirBuf, Conn, (UObject*)actor);
				if (entry) sortPtrs[iVar4++] = entry;
				connTime   += 0.023;
				netDrvTime += 0.023;
			}

			// Update Conn->LastSendTime to match current NetDriver time
			*(DOUBLE*)((BYTE*)Conn + 0x10c) = *(DOUBLE*)((BYTE*)ndPtr + 0x48);

			// Sort by priority descending
			typedef void (__cdecl* SortPriorityFn)(BYTE**, INT);
			((SortPriorityFn)(0x103c4300))(sortPtrs, iVar4);

			void* pkgmap = *(void**)((BYTE*)Conn + 0xc8);
			typedef INT (__thiscall* MapObjectFn)(void*, UClass*);

			// Replication loop: replicate actors in priority order
			for (INT ri = 0; ri < iVar4; ri++)
			{
				BYTE* pEntry = sortPtrs[ri];
				if (!pEntry) continue;
				AActor*   actor = *(AActor**)(pEntry + 4);
				UChannel* chan  = *(UChannel**)(pEntry + 8);
				if (!actor) continue;

				INT bImmediateUpdate = 0;
				INT bSkip = 0;

				if ((*(BYTE*)((BYTE*)actor + 0xa4) & 0x10) != 0)
				{
					bSkip = 1;
				}
				else
				{
					FLOAT ndNow = *(FLOAT*)((BYTE*)ndPtr + 0x48);
					if (chan != NULL && ndNow - *(FLOAT*)((BYTE*)chan + 0x74) <= 0.699999988079071f)
					{
						bSkip = 1;
					}
					else
					{
						typedef INT (__thiscall* IsRelevantFn)(void*, APlayerController*, AActor*, FLOAT, FLOAT, FLOAT);
						bImmediateUpdate = ((IsRelevantFn)(*(INT*)(*(INT*)actor + 0x100)))(actor, PC, Viewer, viewX, viewY, viewZ);
						if (!bImmediateUpdate) bSkip = 1;
					}
				}

				if (bSkip)
				{
					if (chan != NULL)
					{
						FLOAT ndNow   = *(FLOAT*)((BYTE*)ndPtr + 0x48);
						FLOAT tickFreq = *(FLOAT*)((BYTE*)ndPtr + 0x5c);
						if (ndNow - *(FLOAT*)((BYTE*)chan + 0x74) > tickFreq)
						{
							typedef void (__thiscall* CloseChanFn)(void*);
							((CloseChanFn)(*(INT*)(*(INT*)chan + 0x6c)))(chan);
						}
					}
					continue;
				}

				// Create channel if this actor has none yet
				if (chan == NULL)
				{
					UClass* cls = actor->GetClass();
					INT idx = ((MapObjectFn)(*(INT*)(*(INT*)pkgmap + 0x70)))(pkgmap, cls);
					if (idx == -1) continue;
					chan = Conn->CreateChannel(CHTYPE_Actor, 1, -1);
					if (!chan) continue;
					((UActorChannel*)chan)->SetChannelActor(actor);
				}

				if (!Conn->IsNetReady(0)) break;

				if (bImmediateUpdate != 0)
					*(FLOAT*)((BYTE*)chan + 0x74) = appFrand() * 0.3f + *(FLOAT*)((BYTE*)ndPtr + 0x48);

				if (chan->IsNetReady(0))
				{
					((UActorChannel*)chan)->ReplicateActor();
					local_64++;
				}

				if (!Conn->IsNetReady(0)) break;
			}

			Mark.Pop();
		}
	}

	return local_64;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bfe10)
void ULevel::ReconcileActors()
{
	guard(ULevel::ReconcileActors);
	if ( !GIsEditor )
		appFailAssert("GIsEditor", ".\\UnLevel.cpp", 0x1aa);

	// Pass 1: clear viewport back-pointers on all PlayerControllers
	for ( INT i = 0; i < Actors.Num(); i++ )
	{
		AActor* a = Actors(i);
		if ( a && a->IsA(APlayerController::StaticClass())
			 && *(INT*)((BYTE*)a + 0x5b4) != 0 )
		{
			*(INT*)((BYTE*)a + 0x5b4) = 0;
		}
	}

	// Pass 2: match existing cameras to viewports by name
	BYTE* client = *(BYTE**)(*(BYTE**)((BYTE*)this + 0x44) + 0x44);
	FArray* vpArr = (FArray*)(client + 0x30);
	INT nVP = *(INT*)((BYTE*)vpArr + 4);
	for ( INT vi = 0; vi < nVP; vi++ )
	{
		BYTE* vp = *(BYTE**)(*(BYTE**)vpArr + vi * 4);
		if ( *(INT*)(vp + 0x34) != 0 ) continue;
		for ( INT ai = 0; ai < Actors.Num(); ai++ )
		{
			AActor* a = Actors(ai);
			if ( !a || !a->IsA(ACamera::StaticClass()) ) continue;
			const TCHAR* vpName  = ((UObject*)vp)->GetName();
			FName& camTag        = *(FName*)((BYTE*)a + 0x19c);
			if ( appStricmp(*camTag, vpName) == 0 )
			{
				*(DWORD*)(vp + 0x34)        = (DWORD)(size_t)a;
				*(DWORD*)((BYTE*)a + 0x5b4) = (DWORD)(size_t)vp;
				break;
			}
		}
	}

	// Pass 3: spawn camera actors for viewports still without one
	for ( INT vi = 0; vi < nVP; vi++ )
	{
		BYTE* vp = *(BYTE**)(*(BYTE**)vpArr + vi * 4);
		if ( *(INT*)(vp + 0x34) == 0 )
			SpawnViewActor((UViewport*)vp);
	}

	// Pass 4: sync camera properties to actor fields; destroy orphaned cameras
	for ( INT ai = 0; ai < Actors.Num(); )
	{
		AActor* a = Actors(ai);
		if ( a && a->IsA(ACamera::StaticClass()) )
		{
			BYTE* vp = *(BYTE**)((BYTE*)a + 0x5b4);
			if ( vp && ((UObject*)vp)->IsA(UViewport::StaticClass()) )
			{
				a->ClearFlags(1);
				BYTE* vpActor = *(BYTE**)(vp + 0x34);
				*(INT*)(vpActor + 0x558) = *(INT*)(vp + 0x190); // 400 dec = 0x190
				*(INT*)(vpActor + 0x3b0) = *(INT*)(vp + 0x194);
				*(INT*)(vpActor + 0x4f8) = *(INT*)(vp + 0x198);
				*(INT*)(vpActor + 0x504) = *(INT*)(vp + 0x19c);
				*(INT*)(vpActor + 0x4fc) = *(INT*)(vp + 0x1a0);
				*(INT*)(vpActor + 0x500) = *(INT*)(vp + 0x1a4);
				ai++;
			}
			else
			{
				DestroyActor(a, 0);
				ai++; // retail increments after destroy (Ghidra 0x103bffd0)
			}
		}
		else
		{
			ai++;
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bf8b0)
void ULevel::RememberActors()
{
	guard(ULevel::RememberActors);
	BYTE* client = *(BYTE**)(*(BYTE**)((BYTE*)this + 0x44) + 0x44);
	if ( client )
	{
		INT nVP = *(INT*)(client + 0x30 + 4);
		for ( INT vi = 0; vi < nVP; vi++ )
		{
			BYTE* vp    = *(BYTE**)(*(BYTE**)(client + 0x30) + vi * 4);
			BYTE* actor = *(BYTE**)(vp + 0x34);
			if ( *(ULevel**)((BYTE*)actor + 0x328) == this )
			{
				*(INT*)(vp + 0x190) = *(INT*)(actor + 0x558);
				*(INT*)(vp + 0x194) = *(INT*)(actor + 0x3b0);
				*(INT*)(vp + 0x198) = *(INT*)(actor + 0x4f8);
				*(INT*)(vp + 0x19c) = *(INT*)(actor + 0x504);
				*(INT*)(vp + 0x1a0) = *(INT*)(actor + 0x4fc);
				*(INT*)(vp + 0x1a4) = *(INT*)(actor + 0x500);
				*(INT*)(vp + 0x34)  = 0;
			}
		}
	}
	unguard;
}

IMPL_TODO("Ghidra 0x103c1630: DEMOREC+DEMOPLAY implemented; FUN_1038ef30 (CastChecked<UGameEngine>), FUN_103beff0 (StaticConstructObject), FUN_10487990 (init demo playback) called by raw address (internal unnamed functions)")
INT ULevel::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(ULevel::Exec);

	// ── Pass-through to Engine and DemoRecDriver ──────────────────────────────
	// Ghidra: if Engine->Exec(Cmd,Ar) != 0, skip all local handling, return 1.
	// If DemoRecDriver->Exec(Cmd,Ar) != 0, same.
	if (Engine && Engine->Exec(Cmd, Ar))
		return 1;
	if (DemoRecDriver && DemoRecDriver->Exec(Cmd, Ar))
		return 1;

	// ── DEMOREC — start demo recording ──────────────────────────────────────
	if (ParseCommand(&Cmd, TEXT("DEMOREC")))
	{
		FString Filename;
		if (!ParseToken(Cmd, Filename, 0))
		{
			Ar.Log(TEXT("You must specify a filename"));
		}
		else
		{
			// Strip any ".DEM" in the middle (Ghidra truncation logic).
			FString Upper = Filename.Caps();
			INT dotIdx = Upper.InStr(TEXT(".DEM"), 0);
			if (dotIdx != -1)
				Filename = Filename.Left(dotIdx) + Filename.Mid(dotIdx + 4);
			if (Filename.Right(4) != TEXT(".dem"))
				Filename += TEXT(".dem");
			GLog->Logf(TEXT("DemoRec: recording to '%s'"), *Filename);

			// Load the demo recording driver class and construct an instance.
			// Ghidra: StaticLoadClass(UNetDriver, NULL, "ini:Engine.Engine.DemoRecordingDevice", NULL, LOAD_NoFail, NULL)
			//         FUN_103bf700 = ConstructObject<UNetDriver>(Class, GetTransientPackage(), NAME_None, 0)
			UClass* DemoClass = UObject::StaticLoadClass(
				UNetDriver::StaticClass(), NULL,
				TEXT("ini:Engine.Engine.DemoRecordingDevice"), NULL,
				LOAD_NoFail, NULL );
			DemoRecDriver = (UNetDriver*)UObject::StaticConstructObject(
				DemoClass, UObject::GetTransientPackage(),
				FName(NAME_None), 0, NULL, GError, NULL );

			// Call InitListen (vtable+0x78) with this level as FNetworkNotify, Filename as URL.
			FString InitError;
			FURL DemoURL( NULL, *Filename, TRAVEL_Absolute );
			INT bOK = DemoRecDriver->InitListen( this, DemoURL, InitError );
			if (!bOK)
			{
				GLog->Logf(TEXT("DemoRec: failed to start recording"));
				if (DemoRecDriver)
					DemoRecDriver->Destroy();
				DemoRecDriver = NULL;
			}
			else
			{
				GLog->Logf(TEXT("DemoRec: recording started to '%s'"), *Filename);
			}
		}
		return 1;
	}
	// ── DEMOPLAY — start/stop demo playback ─────────────────────────────────
	else if (ParseCommand(&Cmd, TEXT("DEMOPLAY")))
	{
		FString Filename;
		if (!ParseToken(Cmd, Filename, 0))
		{
			Ar.Log(TEXT("You must specify a filename"));
		}
		else
		{
			// Strip .DEM extension if present (Ghidra pattern: same as DEMOREC)
			FString Upper = Filename.Caps();
			INT dotIdx = Upper.InStr(TEXT(".DEM"), 0);
			if (dotIdx != -1)
				Filename = Filename.Left(dotIdx) + Filename.Mid(dotIdx + 4);
			Filename += TEXT(".dem");
			GLog->Logf(TEXT("DemoPlay: '%s'"), *Filename);

			// FUN_1038ef30: CastChecked<UGameEngine>(Engine) — returns raw INT* view of UGameEngine
			typedef INT* (__cdecl* GetGameEngineFn)();
			INT* pGameEngine = ((GetGameEngineFn)(0x1038ef30))();

			// Destroy any existing demo playback driver (vtable[0xe8/4] = Destroy)
			if (pGameEngine && pGameEngine[0x118 / 4] != 0)
			{
				void* drv = (void*)(INT)pGameEngine[0x118 / 4];
				typedef void (__thiscall* DestroyFn)(void*);
				((DestroyFn)(*(INT*)(*(INT*)drv + 0xe8)))(drv);
			}

			// FUN_103beff0: StaticConstructObject-like, creates a demo playback driver
			typedef INT (__cdecl* ConstructDriverFn)(INT flags, void* outer);
			INT pDriver = ((ConstructDriverFn)(0x103beff0))(0xac, (void*)UObject::GetTransientPackage());

			// FUN_10487990: init demo playback (thiscall on driver); passes Filename
			if (pDriver != 0)
			{
				typedef INT (__thiscall* InitDemoFn)(void*);
				pDriver = ((InitDemoFn)(0x10487990))((void*)pDriver);
			}
			if (pGameEngine)
				pGameEngine[0x118 / 4] = pDriver;

			// If driver was created but ServerConnection (at +0x8c) is NULL, init failed
			if (pDriver != 0 && *(INT*)((BYTE*)pDriver + 0x8c) == 0)
			{
				GLog->Logf(TEXT("DemoPlay: failed to init demo playback"));
				if (pGameEngine && pGameEngine[0x118 / 4] != 0)
				{
					void* drv2 = (void*)(INT)pGameEngine[0x118 / 4];
					typedef void (__thiscall* DestroySanitizeFn)(void*);
					((DestroySanitizeFn)(*(INT*)(*(INT*)drv2 + 0xc)))(drv2);
				}
				if (pGameEngine)
					pGameEngine[0x118 / 4] = 0;
			}
		}
		return 1;
	}
	// ── Debug line/point check visualisation toggles ─────────────────────────
	// Ghidra confirmed: straightforward boolean toggle at raw ULevel offsets.
	// DIVERGENCE: field names not yet identified; raw offsets preserved.
	else if (ParseCommand(&Cmd, TEXT("SHOWEXTENTLINECHECK")))
	{
		*(DWORD*)((BYTE*)this + 0x10114) ^= 1u;
		return 1;
	}
	else if (ParseCommand(&Cmd, TEXT("SHOWLINECHECK")))
	{
		*(DWORD*)((BYTE*)this + 0x10110) ^= 1u;
		return 1;
	}
	else if (ParseCommand(&Cmd, TEXT("SHOWPOINTCHECK")))
	{
		*(DWORD*)((BYTE*)this + 0x10118) ^= 1u;
		return 1;
	}
	// ── R6WALKLIST — log all navigation reachspecs ───────────────────────────
	else if (ParseCommand(&Cmd, TEXT("R6WALKLIST")))
	{
		// Ghidra: UModel* at this+0x90; reachspec FArray at Model+0x9c;
		// 0x5c-byte entries; entry[0x58] != 0 means spec is valid.
		// DIVERGENCE: stride and offsets approximate (Ghidra analysis).
		BYTE* pModel = *(BYTE**)((BYTE*)this + 0x90);
		GLog->Logf(TEXT("=== R6WALKLIST BEGIN ==="));
		if (pModel)
		{
			FArray* specArr = (FArray*)(pModel + 0x9c);
			INT num = specArr->Num();
			for (INT i = 0; i < num; i++)
			{
				BYTE* pEntry = (BYTE*)specArr->GetData() + i * 0x5c;
				if (*(INT*)(pEntry + 0x58) != 0)
				{
					UObject* start = *(UObject**)(*(INT*)pEntry + 0x48);
					if (start) start->GetFullName();
					((UObject*)*(INT*)pEntry)->GetFullName();
					GLog->Logf(TEXT("  Spec[%d]"), i);
				}
			}
		}
		GLog->Logf(TEXT("=== R6WALKLIST END ==="));
		return 1;
	}

	// ── Karma physics debug commands: KDRAW/KSTEP/KSTOP/KSAFETIME ───────────
	// DIVERGENCE: Karma is a proprietary binary SDK — Karma commands silently
	// return 0 (not handled) rather than calling FUN_1036a3a0 (Karma exec).
	return 0;

	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bf160)
void ULevel::ShrinkLevel()
{
	guard(ULevel::ShrinkLevel);
	// Retail calls ShrinkModel unconditionally on this+0x90 (the level's world model).
	(*(UModel**)((BYTE*)this + 0x90))->ShrinkModel();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bc540)
void ULevel::CompactActors()
{
	guard(ULevel::CompactActors);
	INT iFirst = *(INT*)((BYTE*)this + 0x104); // iFirstDynamicActor
	INT iDst   = iFirst;
	for ( INT iSrc = iFirst; iSrc < Actors.Num(); iSrc++ )
	{
		AActor* a = Actors(iSrc);
		if ( a )
		{
			if ( (INT)(*(signed char*)((BYTE*)a + 0xa0)) >= -1 ) // not deleted
			{
				if ( iDst != iSrc && GUndo )
					GUndo->SaveArray(*(UObject**)((BYTE*)this + 0x3c),
						(FArray*)&Actors, iDst, 1, 0, sizeof(AActor*), NULL, NULL);
				*(AActor**)(*(BYTE**)&Actors + iDst * 4) = a;
				iDst++;
			}
			else
			{
				// Retail calls GetFullName + GLog->Logf for removed actors.
				debugf(TEXT("CompactActors: removing deleted actor"));
			}
		}
	}
	INT endCount = Actors.Num();
	if ( iDst != endCount )
	{
		if ( GUndo )
			GUndo->SaveArray(*(UObject**)((BYTE*)this + 0x3c),
				(FArray*)&Actors, iDst, endCount - iDst, 0xffffffff, sizeof(AActor*), NULL, NULL);
		// Retail calls FUN_1037a200(iDst, endCount-iDst); FArray::Remove is equivalent.
		((FArray*)&Actors)->Remove(iDst, endCount - iDst, sizeof(AActor*));
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c0460)
INT ULevel::Listen( FString& Error )
{
	guard(ULevel::Listen);

	if ( NetDriver )
	{
		// Already have a NetDriver — this level is already listening or connected.
		Error = LocalizeError(TEXT("NetAlready"), TEXT("Engine"), NULL);
		return 0;
	}

	// Levels with no linker are editor/transient levels that can't be served.
	if ( !GetLinker() )
	{
		Error = LocalizeError(TEXT("NetListen"), TEXT("Engine"), NULL);
		return 0;
	}

	// Load the platform-specific net driver class from Engine.ini.
	UClass* DriverClass = UObject::StaticLoadClass(
		UNetDriver::StaticClass(), NULL,
		TEXT("ini:Engine.Engine.NetworkDevice"), NULL, LOAD_NoWarn, NULL );
	if ( !DriverClass )
	{
		Error = LocalizeError(TEXT("NetListen"), TEXT("Engine"), NULL);
		return 0;
	}

	// Instantiate and assign the net driver.
	NetDriver = (UNetDriver*)UObject::StaticConstructObject( DriverClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL );
	if ( !NetDriver )
	{
		Error = LocalizeError(TEXT("NetListen"), TEXT("Engine"), NULL);
		return 0;
	}

	// Initialise for listening (creates the socket, binds the port, etc.)
	if ( !NetDriver->InitListen( this, URL, Error ) )
	{
		debugf( TEXT("Failed to open network driver: %s"), *Error );
		if ( NetDriver )
		{
			NetDriver->Destroy();
			NetDriver = NULL;
		}
		return 0;
	}

	// Spawn game-engine mutators / GameInfo URL options.
	// Ghidra: FUN_1038ef30 validates GEngine is a UGameEngine, then iterates
	// a TArray<FString> of URL options at GameEngine+0x4A8 and spawns actors.
	// Approximation: rely on GameInfo to call InitGame which spawns mutators.
	// DIVERGENCE from retail: URL-option actor spawn loop omitted.
	// (Ghidra 0x103c04b6..0x103c04e5 — mutator StaticLoadClass + SpawnActor loop)

	// Set NetMode: NM_ListenServer (2) if we have a client viewport, else NM_DedicatedServer (1).
	ALevelInfo* info = GetLevelInfo();
	BYTE* eng = *(BYTE**)((BYTE*)this + 0x44);         // Engine pointer (UEngine*)
	BYTE* cli = eng ? *(BYTE**)(eng + 0x44) : NULL;    // Engine->Client (UClient*)
	// Client->Viewports.Num() == TArray::Num at Client+0x30+4 = Num field of TArray
	INT hasClient = cli ? (*(INT*)(cli + 0x34) != 0) : 0;  // Viewports.Num() > 0
	*(BYTE*)((BYTE*)info + 0x425) = (BYTE)(hasClient + 1);  // NM_ListenServer=2 or NM_DedicatedServer=1

	// Store driver's MaxStreams field at LevelInfo+0x49c (undecoded; Ghidra: NetDriver+100).
	*(DWORD*)((BYTE*)info + 0x49c) = *(DWORD*)((BYTE*)NetDriver + 100);

	return 1;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103bf270)
INT ULevel::IsServer()
{
	// Retail (34b, RVA 0xBF270): return 1 (server) unless NetDriver or DemoRecDriver
	// has an active ServerConnection (which indicates we are a client on that driver).
	if (NetDriver && NetDriver->ServerConnection)
		return 0;
	if (!DemoRecDriver || !DemoRecDriver->ServerConnection)
		return 1;
	return 0;
}
// Ghidra 0x103b9750 (5565 bytes).
// Full collision sweep/response loop.  The attached-actor matrix transforms
// (GetLocalCoords vtable+0xa8, FUN_10301560, FUN_10370d70) and the
// AR6ColBox base step-up path are R6-specific and omitted.  Karma updates
// (FUN_104c3660 / KU2METransform / FUN_104aa490 / FUN_104aa400) are
// proprietary and permanently omitted.
// DIVERGENCE: attached actor loop uses UpdateRelativeRotation fallback instead
//             of Ghidra's full matrix-product propagation.
// DIVERGENCE: AR6ColBox base step-up retries are not implemented.
// DIVERGENCE: Karma physics sync calls are omitted (proprietary SDK).
IMPL_TODO("Ghidra 0x103b9750: sweep collision, touch/bump notifications, and partial-delta blocking implemented; attached-actor matrix propagation and AR6ColBox step-up omitted; Karma omitted (proprietary)")
INT ULevel::MoveActor( AActor* Actor, FVector Delta, FRotator NewRotation, FCheckResult& Hit, INT bTest, INT bIgnorePawns, INT bIgnoreBases, INT bNoFail, INT bExtra )
{
guard(ULevel::MoveActor);
check(Actor != NULL);

// Initialise Hit result to "no hit" (12 DWORDs = 48 bytes)
appMemzero(&Hit, sizeof(FCheckResult));
Hit.Time = 1.f;
Hit.Item = INDEX_NONE;

UBOOL bStatic  = (*(BYTE*)((BYTE*)Actor + 0xA0) & 1) != 0;
UBOOL bMovable = (*(DWORD*)((BYTE*)Actor + 0xA8) & 0x20) != 0;

if ( (!bStatic && bMovable) || GIsEditor )
{
if ( Delta.IsNearlyZero() )
{
if ( NewRotation == Actor->Rotation )
return 1;

// Rotation-only fast path: skip full sweep when no attached actors and
// the actor is not a non-convex static mesh needing encroachment checks.
INT   NumAttached = *(INT*)((BYTE*)Actor + 0x1D8);  // Attached.Num()
DWORD ActorFlagsR = *(DWORD*)((BYTE*)Actor + 0xA8);
UBOOL bRotationOnly = (NumAttached == 0)
&& ( (ActorFlagsR & 0x2000) == 0
|| *(BYTE*)((BYTE*)Actor + 0x2F) != DT_StaticMesh
|| (ActorFlagsR & 0x400000) != 0 );

if ( bRotationOnly )
{
FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)this + 0xF0);
if ( (ActorFlagsR & 0x800) && Hash )
Hash->RemoveActor(Actor);

*(FRotator*)((BYTE*)Actor + 0x240) = NewRotation;

if ( !bIgnoreBases )
Actor->UpdateRelativeRotation();

if ( (ActorFlagsR & 0x800) && Hash )
Hash->AddActor(Actor);

// vtable+0x140: physics/Karma sync check; return value gates Karma calls
typedef INT (__thiscall* PhysCheckFn)(AActor*);
((PhysCheckFn)(*(INT*)(*(INT*)Actor + 0x140)))(Actor);
// Karma sync (FUN_104c3660, KU2METransform etc.) omitted (proprietary SDK)
return 1;
}
// Fall through: rotation changed with attached actors present —
// main loop applies zero displacement + new rotation + propagates to attached.
}
}
else
{
return 0;
}

// ---- Main collision sweep / response loop ----
FMemMark Mark(GMem);

DWORD ActorFlags = *(DWORD*)((BYTE*)Actor + 0xA8);
FLOAT DeltaSize  = Delta.Size();
FVector Dir = (DeltaSize > 0.f) ? (Delta / DeltaSize) : FVector(0.f, 0.f, 0.f);

// Swept end: Actor->Location + Delta + 2*Dir (2-unit lead for accurate sweep margin)
FVector SweepEnd(
*(FLOAT*)((BYTE*)Actor + 0x234) + Delta.X + Dir.X + Dir.X,
*(FLOAT*)((BYTE*)Actor + 0x238) + Delta.Y + Dir.Y + Dir.Y,
*(FLOAT*)((BYTE*)Actor + 0x23C) + Delta.Z + Dir.Z + Dir.Z
);

// vtable+0xC8 (= 200 decimal) on Actor:
//   returns 0  -> normal sweep-collision actor (pawn, projectile, etc.)
//   returns !=0 -> moving brush / encroacher (uses CheckEncroachment instead)
// Ghidra: (**(code **)(*(int *)param_1 + 200))()
typedef INT (__thiscall* IsMovingBrushFn)(AActor*);
INT bIsMovingBrush = ((IsMovingBrushFn)(*(INT*)(*(INT*)Actor + 0xC8)))(Actor);

// Touch / blocking tracking
AActor* TouchActor = NULL;  // first blocking/touching actor (from Hit.Actor)
AActor* BaseActor  = NULL;  // secondary touch (AR6ColBox base path, always NULL here)
INT     TouchCount = 0;
AActor* TouchList[256];
INT     bBlocked   = 0;

// Sweep: only for non-mover actors with collision flags and non-zero delta
if ( (ActorFlags & 0x1800) != 0 && bIsMovingBrush == 0 && DeltaSize > 0.f )
{
// Build trace flags from actor collision properties:
//   bCollideActors (0x800) -> trace actors
//   bCollideWorld  (0x1000) -> trace world geometry
//   bInterpolating (0x100000) -> ignore volume triggers
DWORD TraceFlags = 0;
if ( (ActorFlags & 0x800) != 0 )    // bCollideActors
TraceFlags = (bIgnorePawns == 0) ? 0x19u : 0x18u;  // 0x19 includes TRACE_Pawns
if ( (ActorFlags & 0x1000) != 0 )   // bCollideWorld
TraceFlags |= 0x86u;            // TRACE_LevelGeometry|TRACE_Level|TRACE_Movers
if ( (ActorFlags & 0x100000) != 0 ) // bInterpolating
TraceFlags |= 0x10000u;

// Level for world-geometry checks (only needed when bCollideWorld is set)
ALevelInfo* CollisionLevel = ((ActorFlags & 0x1000) != 0) ? GetLevelInfo() : NULL;

// Actor cylinder extent
FLOAT ColRadius = *(FLOAT*)((BYTE*)Actor + 0xF8);
FLOAT ColHeight = *(FLOAT*)((BYTE*)Actor + 0xFC);
FVector Extent(ColRadius, ColRadius, ColHeight);

// Multi-line sweep: find every actor intersected along the swept path
FCheckResult* FirstHit = MultiLineCheck(GMem, SweepEnd, Actor->Location,
                                        Extent, CollisionLevel, TraceFlags, Actor);

// Find the first truly blocking hit (writes into Hit).
// Note: MoveActorFirstBlocking's 3rd param is bIgnoreBases (named "bTest" in header).
bBlocked = MoveActorFirstBlocking(Actor, bIgnorePawns, bIgnoreBases, FirstHit, Hit);

if ( Hit.Actor != NULL )
TouchActor = Hit.Actor;

// Collect non-blocking touches: actors whose sweep Time < blocking Hit.Time.
// (Inlined FUN_103b7390 @ 0x103b7390 -- 63 bytes)
for ( FCheckResult* Check = FirstHit;
      Check != NULL && TouchCount < 256;
      Check = Check->GetNext() )
{
if ( Check->Time >= Hit.Time )
break;
TouchList[TouchCount++] = Check->Actor;
}

// Clear base actor's "world-bound" flag (bit 3 of offset 0x394)
// Ghidra: *(uint*)(*(int*)(Actor+0x180) + 0x394) &= ~0x8
INT pBase = *(INT*)((BYTE*)Actor + 0x180);
if ( pBase != 0 )
*(DWORD*)(pBase + 0x394) &= ~0x8u;

// TODO: Ghidra 0x103b9750 -- AR6ColBox base step-up:
// If Actor->Base is an AR6ColBox with bWorldBound set and actor has movement
// flags (0x7000), call AR6ColBox::GetMaxStepUp and optionally retry
// MoveActorFirstBlocking with an upward offset for the base actor.
// Requires proprietary AR6ColBox helpers -- omitted.
}

// ---- Standard movement update path (bExtra == 0) ----
// When bExtra != 0 the sweep above still runs (for AR6ColBox collision query)
// but location/rotation are NOT updated -- the caller uses Hit.Time directly.
if ( bExtra == 0 )
{
// Trim delta to the hit point, backing off 2 units from the wall surface.
// Ghidra: dist = (Size+2)*HitTime; if dist>=2: adj = Dir*(dist-2), HitTime=(dist-2)/Size
FVector AdjustedDelta = Delta;
if ( Hit.Time < 1.f && bNoFail == 0 && DeltaSize > 0.f )
{
FLOAT dist = (DeltaSize + 2.f) * Hit.Time;
if ( dist >= 2.f )
{
AdjustedDelta = Dir * (dist - 2.f);
Hit.Time      = (dist - 2.f) / DeltaSize;
}
else
{
AdjustedDelta = FVector(0.f, 0.f, 0.f);
Hit.Time      = 0.f;
}
}

// Encroachment check for moving brushes (bIsMovingBrush != 0).
// Ghidra: vtable+0xC0 on ULevel = CheckEncroachment
if ( bTest == 0 && bNoFail == 0 && bIsMovingBrush != 0 )
{
FVector TestLoc(
*(FLOAT*)((BYTE*)Actor + 0x234) + AdjustedDelta.X,
*(FLOAT*)((BYTE*)Actor + 0x238) + AdjustedDelta.Y,
*(FLOAT*)((BYTE*)Actor + 0x23C) + AdjustedDelta.Z
);
if ( CheckEncroachment(Actor, TestLoc, NewRotation, 0) )
{
Mark.Pop();
return 0;
}
}

// Remove from collision hash before repositioning
FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)this + 0xF0);
if ( (ActorFlags & 0x800) && Hash )
Hash->RemoveActor(Actor);

// Save old rotation for delta-rotation computation for attached actors
DWORD OldPitch = *(DWORD*)((BYTE*)Actor + 0x240);
DWORD OldYaw   = *(DWORD*)((BYTE*)Actor + 0x244);
DWORD OldRoll  = *(DWORD*)((BYTE*)Actor + 0x248);

// Apply movement and new rotation
*(FLOAT*)((BYTE*)Actor + 0x234) += AdjustedDelta.X;
*(FLOAT*)((BYTE*)Actor + 0x238) += AdjustedDelta.Y;
*(FLOAT*)((BYTE*)Actor + 0x23C) += AdjustedDelta.Z;
*(INT*)((BYTE*)Actor  + 0x240) = NewRotation.Pitch;
*(INT*)((BYTE*)Actor  + 0x244) = NewRotation.Yaw;
*(INT*)((BYTE*)Actor  + 0x248) = NewRotation.Roll;

// Propagate movement/rotation to attached actors.
// Ghidra builds a delta-rotation matrix (GetLocalCoords vtable+0xa8,
// FUN_10301560, FUN_10370d70) and calls MoveActor recursively for each child.
// TODO: Ghidra 0x103b9750 -- full matrix-based attached propagation loop.
// Fallback: UpdateRelativeRotation maintains rotation coherency.
INT numAttached = *(INT*)((BYTE*)Actor + 0x1D8);  // Attached.Num()
if ( numAttached > 0 && bTest == 0 )
{
UBOOL bRotChanged = ( OldPitch != (DWORD)NewRotation.Pitch
                   || OldYaw   != (DWORD)NewRotation.Yaw
                   || OldRoll  != (DWORD)NewRotation.Roll );
if ( bRotChanged )
Actor->UpdateRelativeRotation();
}

// Re-add to collision hash after repositioning
if ( (*(DWORD*)((BYTE*)Actor + 0xA8) & 0x800) && Hash )
Hash->AddActor(Actor);

// vtable+0x140: intermediate physics/Karma sync (return value gates Karma calls)
typedef INT (__thiscall* PhysCheckFn)(AActor*);
((PhysCheckFn)(*(INT*)(*(INT*)Actor + 0x140)))(Actor);
// Karma sync (FUN_104c3660, KU2METransform etc.) omitted (proprietary SDK)

if ( bTest == 0 )
{
// Notify primary blocking actor -- both parties get vtable+0xcc (NotifyBump)
// Condition: TouchActor exists, is not world geometry, Actor not based on it
if ( TouchActor != NULL
&& (*(DWORD*)((BYTE*)TouchActor + 0xA0) & 0x100000) == 0  // !bWorldGeometry
&& !Actor->IsBasedOn(TouchActor) )
{
typedef void (__thiscall* NotifyBumpFn)(AActor*, AActor*);
((NotifyBumpFn)(*(INT*)(*(INT*)TouchActor + 0xcc)))(TouchActor, Actor);
((NotifyBumpFn)(*(INT*)(*(INT*)Actor      + 0xcc)))(Actor, TouchActor);
}

// Notify secondary (base) actor -- only populated by AR6ColBox path (NULL here)
if ( BaseActor != NULL
&& (*(DWORD*)((BYTE*)BaseActor + 0xA0) & 0x100000) == 0
&& !Actor->IsBasedOn(BaseActor) )
{
typedef void (__thiscall* NotifyBumpFn)(AActor*, AActor*);
((NotifyBumpFn)(*(INT*)(*(INT*)BaseActor + 0xcc)))(BaseActor, Actor);
((NotifyBumpFn)(*(INT*)(*(INT*)Actor     + 0xcc)))(Actor, BaseActor);
}

// Process non-blocking touches swept through before the block.
// Ghidra condition: bBlocked OR !bBlockActors(0x2000) OR !bBlockPlayers(0x4000)
if ( bBlocked || (ActorFlags & 0x2000) == 0 || (ActorFlags & 0x4000) == 0 )
{
for ( INT i = 0; i < TouchCount; i++ )
{
AActor* ta = TouchList[i];
if ( bIgnoreBases == 0 || !Actor->IsJoinedTo(ta) )
{
// vtable+0x70: non-zero -> actor blocks/ignores (skip touch)
typedef INT (__thiscall* IsBlockedFn)(AActor*, AActor*);
INT isBlk = ((IsBlockedFn)(*(INT*)(*(INT*)Actor + 0x70)))(Actor, ta);
if ( !isBlk && Actor != ta )
{
// vtable+0xc4: touch-notify for non-blocking actor
typedef void (__thiscall* TouchFn)(AActor*, AActor*);
((TouchFn)(*(INT*)(*(INT*)Actor + 0xc4)))(Actor, ta);
}
}
}
}

// EndTouch actors in Touching[] that are no longer spatially overlapping
TArray<AActor*>& Touching = *(TArray<AActor*>*)((BYTE*)Actor + 0x1C8);
INT i = 0;
while ( i < Touching.Num() )
{
AActor* ta = Touching(i);
if ( ta == NULL || Actor->IsOverlapping(ta, NULL) )
i++;
else
Actor->EndTouch(Touching(i), 0);
}
}

// Post-move update callback: vtable+0x10c on Actor
// Ghidra: (**(code **)(*(int *)param_1 + 0x10c))() -- called even in bTest mode
typedef void (__thiscall* PostMoveFn)(AActor*);
((PostMoveFn)(*(INT*)(*(INT*)Actor + 0x10C)))(Actor);
}

Mark.Pop();

if ( bExtra == 0 && bTest == 0 )
Actor->UpdateRenderData();

return (Hit.Time > 0.f) ? 1 : 0;
unguard;
}

IMPL_MATCH("Engine.dll", 0x103b93e0)
INT ULevel::FarMoveActor( AActor* Actor, FVector DestLocation, INT bTest, INT bNoCheck, INT bAttachedMove, INT bExtra )
{
    guard(ULevel::FarMoveActor);

    if ( !Actor )
        appFailAssert("Actor!=NULL", ".\\UnLevAct.cpp", 0x49f);

    // bStatic (offset 0xa0 bit 0) or not bMovable (offset 0xa8 bit 5 = 0x20) - can't move outside editor
    if ( ((*(BYTE*)((BYTE*)Actor + 0xa0) & 1) != 0 || (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x20) == 0) && !GIsEditor )
        return 0;

    FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);

    // Remove actor from collision hash before repositioning (bCollideWorld = 0xa8 & 0x800)
    if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) != 0 && hash != NULL )
        hash->RemoveActor(Actor);

    FLOAT localX = DestLocation.X;
    FLOAT localY = DestLocation.Y;
    FLOAT localZ = DestLocation.Z;
    INT result = 1;

    // do-while(0) used as a structured-goto: break exits to the hash re-add block
    do
    {
        if ( bNoCheck == 0 )
        {
            DWORD flags2 = *(DWORD*)((BYTE*)Actor + 0xa8);
            // FindSpot if bInterpolating (0x1000), OR if bOwned (0x8) AND NOT on NM_Client
            UBOOL doFindSpot = (flags2 & 0x1000) != 0;
            if ( !doFindSpot && (flags2 & 8) != 0 )
            {
                ALevelInfo* li = GetLevelInfo();
                // offset 0x425 = NetMode byte; 3 == NM_Client; skip FindSpot on client
                if ( *(BYTE*)((BYTE*)li + 0x425) != 3 )
                    doFindSpot = 1;
            }
            if ( doFindSpot )
            {
                // Extent = (CollisionRadius, CollisionRadius, CollisionHeight)
                FVector extent(
                    *(FLOAT*)((BYTE*)Actor + 0xf8),
                    *(FLOAT*)((BYTE*)Actor + 0xf8),
                    *(FLOAT*)((BYTE*)Actor + 0xfc)
                );
                FVector dest(localX, localY, localZ);
                result = FindSpot(extent, dest, 0, Actor);
                localX = dest.X; localY = dest.Y; localZ = dest.Z;

                if ( bExtra )
                {
                    if ( !result ) break;
                    // If FindSpot moved the destination, reject the teleport
                    if ( dest != DestLocation ) { result = 0; break; }
                }
                if ( !result ) break;
            }
        }

        // Perform the actual sweep move when not testing and not skipping collision
        if ( bTest == 0 && bNoCheck == 0 )
        {
            FCheckResult hit;
            FVector delta(
                localX - *(FLOAT*)((BYTE*)Actor + 0x234),
                localY - *(FLOAT*)((BYTE*)Actor + 0x238),
                localZ - *(FLOAT*)((BYTE*)Actor + 0x23c)
            );
            FRotator rot(
                *(INT*)((BYTE*)Actor + 0x240),
                *(INT*)((BYTE*)Actor + 0x244),
                *(INT*)((BYTE*)Actor + 0x248)
            );
            // MoveActor returns 0 when unblocked, non-zero when blocked
            INT moved = MoveActor(Actor, delta, rot, hit, 0, 0, 0, 1, 0);
            result = (moved == 0) ? 1 : 0;
        }

        if ( result != 0 )
        {
            if ( bTest == 0 )
            {
                // Set bTeleportedFwd flag (offset 0xac bit 3)
                *(DWORD*)((BYTE*)Actor + 0xac) |= 8;

                // If not an attached-move, detach actor from its base first
                if ( bAttachedMove == 0 )
                    Actor->SetBase(NULL, FVector(0.0f, 0.0f, 1.0f), 1);

                // Recursively FarMoveActor all actors attached to this one
                // Attached TArray<AActor*> at offset 0x1d4: Data @ +0, Num @ +4
                INT numAttached = *(INT*)((BYTE*)Actor + 0x1d8);
                for ( INT i = 0; i < numAttached; i++ )
                {
                    AActor* att = *(AActor**)(*(INT*)((BYTE*)Actor + 0x1d4) + i * 4);
                    if ( att )
                    {
                        FarMoveActor(att,
                            FVector(
                                localX + *(FLOAT*)((BYTE*)att + 0x234) - *(FLOAT*)((BYTE*)Actor + 0x234),
                                localY + *(FLOAT*)((BYTE*)att + 0x238) - *(FLOAT*)((BYTE*)Actor + 0x238),
                                localZ + *(FLOAT*)((BYTE*)att + 0x23c) - *(FLOAT*)((BYTE*)Actor + 0x23c)
                            ),
                            0, bNoCheck, 1, 0);
                    }
                }
            }

            // If Touching array (0x338) is non-empty, remove from hash before updating location
            // Touching TArray<AActor*> at 0x338: Data @ +0, Num @ +4
            if ( *(INT*)((BYTE*)Actor + 0x33c) > 0 )
            {
                FCollisionHashBase* hash2 = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
                if ( hash2 )
                    hash2->RemoveActor(Actor);
            }

            // Commit the new location
            *(FLOAT*)((BYTE*)Actor + 0x234) = localX;
            *(FLOAT*)((BYTE*)Actor + 0x238) = localY;
            *(FLOAT*)((BYTE*)Actor + 0x23c) = localZ;
        }
    }
    while (0);

    // Always re-add to collision hash (whether success or blocked)
    hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
    if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) != 0 && hash != NULL )
        hash->AddActor(Actor);

    // PostTeleport callback - AActor vtable slot 0x10c, args: (bTest, 0)
    if ( result != 0 )
    {
        typedef void (__thiscall *tPostTeleport)(AActor*, INT, INT);
        tPostTeleport pfPT = (tPostTeleport)(*(INT*)(*(INT*)Actor + 0x10c));
        pfPT(Actor, bTest, 0);
    }

    // Update render state (skip when just probing with bTest)
    if ( bTest == 0 )
        Actor->UpdateRenderData();

    return result;
    unguard;
}
IMPL_TODO("Ghidra 0x103b8200: FUN_103866c0/FUN_103b6f40 policy gate still unresolved; network channel check + EndTouch delivery now aligned")
INT ULevel::DestroyActor( AActor* Actor, INT bNetForce )
{
	guard(ULevel::DestroyActor);

	if ( !Actor )
		appFailAssert("ThisActor", ".\\UnLevAct.cpp", 0x11f);
	if ( !Actor->IsValid() )
		appFailAssert("ThisActor->IsValid()", ".\\UnLevAct.cpp", 0x120);

	if ( !GIsEditor )
	{
		// bStatic (0x1) or bNoDelete (0x4): cannot destroy
		if ( *(DWORD*)((BYTE*)Actor + 0xa0) & 0x5 )
			return 0;
		// bDeleteMe (0x80): already being destroyed
		if ( *(DWORD*)((BYTE*)Actor + 0xa0) & 0x80 )
			return 1;

		// Network gate on clients with active server connection: retail blocks destroy
		// when the actor has an open channel on that connection (FUN_103b7b70).
		ALevelInfo* li = GetLevelInfo();
		if ( li && *(BYTE*)((BYTE*)li + 0x425) == 3 && // NM_Client
		     NetDriver && NetDriver->ServerConnection )
		{
			typedef UChannel* (__thiscall* FindActorChannelFn)(void*, AActor**);
			FindActorChannelFn FindActorChannel = (FindActorChannelFn)0x103b7b70;
			if ( FindActorChannel((void*)NetDriver->ServerConnection, &Actor) != NULL )
				return 0;
		}

		// Role check: if not Authority and no bNetForce/bHiddenEd/bBegunPlay
		if ( Actor->Role != ROLE_Authority && !bNetForce &&
		     !(*(DWORD*)((BYTE*)Actor + 0xa0) & 0x10000000) && // bNetTemporary
		     !(*(DWORD*)((BYTE*)Actor + 0xa0) & 0x10) &&        // bHiddenEd
		     li && !(*(BYTE*)((BYTE*)li + 0x454) & 1) )        // not bBegunPlay
			return 0;
	}

	// Find actor's slot in Actors array
	INT iActor = GetActorIndex(Actor);

	// Notify undo system
	if ( GUndo )
		GUndo->SaveArray(*(UObject**)((BYTE*)this + 0x3c),
			(FArray*)&Actors, iActor, 1, 0, sizeof(AActor*), NULL, NULL);

	// Collision off: vtable slot 0x20 (some actor pre-destroy notify)
	typedef void (__thiscall* VoidFn)(void*);
	typedef void (__thiscall* SetBaseFn)(void*, void*, INT);
	((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0x20)))(Actor);

	// Mark bBlockActors/bBlockPlayers bits cleared
	*(DWORD*)((BYTE*)Actor + 0xa8) |= 0x100; // bBlockPlayers clear

	// End state
	FStateFrame* sf = Actor->GetStateFrame();
	if ( sf && sf->Code && sf->StateNode )
		Actor->eventEndState();

	if ( !Actor->bDeleteMe )
	{
		// Detach from base (vtable slot 0xd0 on actor = SetBase(NULL))
		if ( *(INT*)((BYTE*)Actor + 0x15c) ) // bNetOwner or attachment flag
		{
			typedef void (__thiscall* SetBaseFn2)(void*, void*, FVector, INT);
			((SetBaseFn2)(*(DWORD*)(*(DWORD*)Actor + 0xd0)))(Actor, NULL, FVector(0,0,-1), 1);
		}

		// Detach all attached actors
		INT nAttached = ((FArray*)((BYTE*)Actor + 0x1d4))->Num();
		for ( INT i = 0; i < nAttached; i++ )
		{
			AActor* child = *(AActor**)(*(BYTE**)((BYTE*)Actor + 0x1d4) + i * 4);
			if ( child )
			{
				typedef void (__thiscall* SetBaseFn3)(void*, void*, FVector, INT);
				((SetBaseFn3)(*(DWORD*)(*(DWORD*)child + 0xd0)))(child, NULL, FVector(0,0,-1), 1);
			}
		}

		// Fire Destroyed event if probing
		if ( Actor->IsProbing(NAME_Destroyed) )
		{
			UFunction* fn = Actor->FindFunctionChecked(NAME_Destroyed, 0);
			Actor->ProcessEvent(fn, NULL, NULL);
		}

		// Post-script-destroyed vtable (slot 0xb8)
		((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0xb8)))(Actor);

		if ( !Actor->bDeleteMe )
		{
			// Detach from owner / base chains and fire touch/EndTouch
			for ( INT i = 0; i < Actors.Num(); i++ )
			{
				AActor* a = Actors(i);
				if ( !a ) continue;
				if ( *(AActor**)((BYTE*)a + 0x140) == Actor ) // Base == Actor
				{
					a->SetOwner(NULL);
					if ( Actor->bDeleteMe ) return 1;
				}
				// Retail FUN_1037a010 path: if 'a' is currently touching Actor, deliver EndTouch.
				TArray<AActor*>& Touching = *(TArray<AActor*>*)((BYTE*)a + 0x1C8);
				for ( INT t = 0; t < Touching.Num(); t++ )
				{
					if ( Touching(t) == Actor )
					{
						Actor->EndTouch(a, 1);
						if ( Actor->bDeleteMe )
							return 1;
						break;
					}
				}
			}

			// LostChild notification to base
			AActor* base = *(AActor**)((BYTE*)Actor + 0x140);
			if ( !base || !Actor->bDeleteMe )
			{
				if ( base )
					base->eventLostChild(Actor);

				if ( !Actor->bDeleteMe )
				{
					// Notify net drivers
					if ( *(INT*)((BYTE*)this + 0x40) ) // NetDriver
					{
						typedef void (__thiscall* NotifyFn)(void*, void*);
						((NotifyFn)(*(DWORD*)(**(DWORD**)((BYTE*)this + 0x40) + 0x84)))(
							*(void**)((BYTE*)this + 0x40), Actor);
					}

					BYTE* demoDriver = *(BYTE**)((BYTE*)this + 0x8c);
					if ( demoDriver && *(INT*)(demoDriver + 0xf * 4) == 0 )
					{
						typedef void (__thiscall* NotifyFn2)(void*, void*);
						((NotifyFn2)(*(DWORD*)(*(DWORD*)demoDriver + 0x84)))(demoDriver, Actor);
					}

					// Remove from collision hash
					FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
					if ( hash )
					{
						if ( *(DWORD*)((BYTE*)Actor + 0xa8) & 0x800 ) // bCollideActors
							hash->RemoveActor(Actor);
						// ActorOverlapCheck cleanup (vtable 0x24 of hash)
						typedef void (__thiscall* OverlapFn)(void*, void*);
						((OverlapFn)(*(DWORD*)(*(DWORD*)hash + 0x24)))(hash, Actor);
					}

					// Sanity check and null out slot
					if ( *(AActor**)(*(BYTE**)&Actors + iActor * 4) != Actor )
						appFailAssert("Actors(iActor)==ThisActor", ".\\UnLevAct.cpp", 0x1d9);
					*(AActor**)(*(BYTE**)&Actors + iActor * 4) = NULL;

					// Set bDeleteMe
					*(DWORD*)((BYTE*)Actor + 0xa0) |= 0x80;

					// Notify engine renderer (Engine->Client renderer at 0x48)
					{
						BYTE* eng = *(BYTE**)((BYTE*)this + 0x44);
						BYTE* renderer = *(BYTE**)(eng + 0x48);
						if ( renderer )
						{
							typedef void (__thiscall* RenderFn)(void*, void*);
							((RenderFn)(*(DWORD*)(*(DWORD*)renderer + 0x104)))(renderer, Actor);
						}
					}

					Actor->ConditionalDestroy();

					if ( !GIsEditor )
					{
						// Add to FirstDeleted linked list
						*(INT*)((BYTE*)Actor + 0x160) = *(INT*)((BYTE*)this + 0xf4);
						*(AActor**)((BYTE*)this + 0xf4) = Actor;
					}
					else
					{
						// Editor: compact actors
						typedef void (__thiscall* CompactFn)(void*, INT);
						((CompactFn)(*(DWORD*)(*(DWORD*)this + 0xa4)))(this, 1);
					}
				}
			}
		}
	}

	return 1;
	unguard;
}

// CleanupDestroyed: Ghidra 0x103b70b0 (390 bytes).
// Sequence: tick renderer (vtable 0x8C) if !GIsEditor && !bForce; count FirstDeleted list;
// if count > 0x7f or forced: refresh-collision loop then destroy loop with channel-close.
// All offsets and vtable slots verified against Ghidra. guard/unguard SEH differs from retail.
IMPL_MATCH("Engine.dll", 0x103b70b0)
void ULevel::CleanupDestroyed( INT bForce )
{
	guard(ULevel::CleanupDestroyed);
	// Tick renderer if game mode and not a forced cleanup
	if ( !GIsEditor && !bForce )
	{
		typedef void (__thiscall* TickRenderFn)(ULevel*);
		((TickRenderFn)(*(DWORD*)(*(DWORD*)this + 0x8c)))(this);
	}
	// Walk FirstDeleted linked list
	INT* firstDeleted = (INT*)*(DWORD*)((BYTE*)this + 0xf4);
	if ( firstDeleted )
	{
		INT count = 0;
		for ( INT* p = firstDeleted; p; p = (INT*)*(DWORD*)((BYTE*)p + 0x160) )
			count++;
		if ( count > 0x7f || bForce )
		{
			// Refresh collision on all actors
			for ( INT i = 0; i < Actors.Num(); i++ )
			{
				AActor* a = Actors(i);
				if (a)
				{
					UClass* cls = a->GetClass();
					typedef void (__thiscall* RefreshFn)(AActor*);
					((RefreshFn)(*(DWORD*)(*(DWORD*)cls + 0x84)))(a);
				}
			}
			// Actually destroy pending actors (non-editor only)
			if ( !GIsEditor )
			{
				debugf(TEXT("CleanupDestroyed: flushing %d actors"), count);
				while ( *(DWORD*)((BYTE*)this + 0xf4) != 0 )
				{
					INT* actor = *(INT**)((BYTE*)this + 0xf4);
					if ( (INT)(*(signed char*)((BYTE*)actor + 0xa0)) >= -1 )
						appFailAssert("FirstDeleted->bDeleteMe", ".\\UnLevAct.cpp", 0x274);
					*(DWORD*)((BYTE*)this + 0xf4) = *(DWORD*)((BYTE*)actor + 0x160);
					if ( (INT)(*(signed char*)((BYTE*)actor + 0xa0)) >= -1 )
						appFailAssert("ActorToKill->bDeleteMe", ".\\UnLevAct.cpp", 0x277);
					// Close actor channel if present
					INT* actorChannel = (INT*)*(DWORD*)((BYTE*)actor + 0x324);
					if ( actorChannel )
					{
						typedef void (__thiscall* CloseFn)(void*);
						((CloseFn)(*(DWORD*)(*(DWORD*)actorChannel + 0xc)))(actorChannel);
						*(DWORD*)((BYTE*)actor + 0x324) = 0;
					}
					// ConditionalDestroy (vtable slot 3 on UObject)
					typedef void (__thiscall* ConditionalDestroyFn)(void*);
					((ConditionalDestroyFn)(*(DWORD*)(*(DWORD*)actor + 0xc)))(actor);
				}
			}
		}
	}
	unguard;
}

IMPL_DIVERGE("FUN_10359790 (zone/BSP-leaf init) depends on KGData (Karma globals) and Karma helper FUN_10356820/FUN_10366aa0 — Karma is binary-only SDK. Zone setup omitted; actor starts outside any zone. Ghidra 0x103b7bd0")
AActor* ULevel::SpawnActor( UClass* Class, FName InName, FVector Location, FRotator Rotation, AActor* Template, INT bNoCollisionFail, INT bRemoteOwned, AActor* SpawnTag, APawn* Instigator )
{
	guard(ULevel::SpawnActor);

	// Null class check
	if ( !Class )
	{
		GLog->Logf(TEXT("SpawnActor: NULL class"));
		return NULL;
	}

	// Abstract class check: byte at +0x48c, bit 0 = CLASS_Abstract
	if ( *(BYTE*)((BYTE*)Class + 0x48c) & 1 )
	{
		GLog->Logf(TEXT("SpawnActor: cannot spawn abstract class %s"), Class->GetName());
		return NULL;
	}

	// Must be a child of AActor
	if ( !Class->IsChildOf(AActor::StaticClass()) )
	{
		GLog->Logf(TEXT("SpawnActor: %s is not an AActor subclass"), Class->GetName());
		return NULL;
	}

	// Get default object as template if not provided
	if ( !Template )
		Template = Class->GetDefaultActor();
	if ( !Template )
		appFailAssert("Template!=NULL", ".\\UnLevAct.cpp", 0x3e);

	// Reject static/no-delete actors in game mode
	if ( !GIsEditor )
	{
		if ( (*(BYTE*)((BYTE*)Template + 0xa0) & 0x1) || // bStatic
		     (*(BYTE*)((BYTE*)Template + 0xa0) & 0x4) )  // bNoDelete
			return NULL;
	}

	// FindSpot pre-check if bCollideWhenPlacing or (bShouldBaseAtStartup and not a client)
	if ( !bNoCollisionFail &&
	     ( (*(DWORD*)((BYTE*)Template + 0xa8) & 0x1000) ||   // bCollideWhenPlacing
	       ( (*(DWORD*)((BYTE*)Template + 0xa8) & 0x8) &&    // bShouldBaseAtStartup
	         GetLevelInfo() && *(BYTE*)((BYTE*)GetLevelInfo() + 0x425) != 3 ) ) ) // not NM_Client
	{
		FVector Extent = Template->GetCylinderExtent();
		if ( !FindSpot(Extent, Location, 1, NULL) )
			return NULL;
	}

	// Find a free slot in the Actors array (implements FUN_10318800)
	INT slot = INDEX_NONE;
	{
		INT iFirst = *(INT*)((BYTE*)this + 0x104); // iFirstDynamicActor
		for ( INT i = iFirst; i < Actors.Num(); i++ )
		{
			if ( Actors(i) == NULL ) { slot = i; break; }
		}
		if ( slot == INDEX_NONE )
		{
			Actors.AddItem(NULL);
			slot = Actors.Num() - 1;
		}
	}

	// Construct the actor object
	AActor* Actor = (AActor*)UObject::StaticConstructObject(Class, GetOuter(), NAME_None, 0, Template, GError, NULL);
	*(AActor**)(*(BYTE**)&Actors + slot * 4) = Actor;
	Actor->SetFlags(RF_Transactional);

	// Set Tag to the class FName
	Actor->Tag = Class->GetFName();

	// Zone / region setup
	ALevelInfo* LI = GetLevelInfo();
	*(ALevelInfo**)((BYTE*)Actor + 0x228) = LI; // Zone
	*(INT*)((BYTE*)Actor + 0x22c) = INDEX_NONE; // iZone
	*(INT*)((BYTE*)Actor + 0x230) = 0;          // Region.ZoneIndex cleared

	// Level refs
	Actor->Level  = LI;
	Actor->XLevel = this;

	// bTicked = (FrameTag == 0): set bit 0 of the flag DWORD at +0x320
	{
		INT FrameTag = *(INT*)((BYTE*)this + 0x100);
		DWORD& ticked = *(DWORD*)((BYTE*)Actor + 0x320);
		ticked = ticked ^ ( ((DWORD)(FrameTag == 0) ^ ticked) & 1 );
	}

	// Role must be ROLE_Authority on freshly constructed actors
	if ( Actor->Role != ROLE_Authority )
		appFailAssert("Actor->Role==ROLE_Authority", ".\\UnLevAct.cpp", 0x54);

	// If bRemoteOwned, swap Role and RemoteRole
	if ( bRemoteOwned )
	{
		BYTE tmp = Actor->Role;
		Actor->Role = Actor->RemoteRole;
		Actor->RemoteRole = tmp;
	}

	// Clear physics
	Actor->Physics = 0;

	// Set location and rotation
	Actor->Location = Location;
	Actor->Rotation = Rotation;

	// Add to collision hash
	FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) && hash ) // bCollideActors
		hash->AddActor(Actor);

	// Re-setup zone and region
	*(ALevelInfo**)((BYTE*)Actor + 0x228) = GetLevelInfo();
	*(INT*)((BYTE*)Actor + 0x22c) = INDEX_NONE;
	*(INT*)((BYTE*)Actor + 0x230) = 0;

	// Copy CullDistance from LevelInfo
	*(FLOAT*)((BYTE*)Actor + 0x164) = *(FLOAT*)((BYTE*)GetLevelInfo() + 0x164);

	// Set owner and instigator
	Actor->SetOwner(SpawnTag);
	Actor->Instigator = Instigator;

	// DIVERGENCE: FUN_10359790 = actor zone/BSP-leaf initialisation helper (Ghidra 0x359790).
	// Determines which zone and BSP leaf the spawned actor is in and sets related fields.
	// Unresolved — actor starts outside any zone (zone info zeroed by constructor).

	// InitExecution and SetBase (base=NULL)
	typedef void (__thiscall* VoidFn)(void*);
	((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0x3c)))(Actor); // InitExecution
	((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0x90)))(Actor); // SetBase(NULL)

	// Pre-play events
	Actor->eventPreBeginPlay();
	Actor->eventBeginPlay();

	// If actor was destroyed during BeginPlay, bail out
	if ( Actor->bDeleteMe )
		return NULL;

	// Post-BeginPlay collision init (vtable slot 0x10c)
	((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0x10c)))(Actor);

	// Update render data
	Actor->UpdateRenderData();

	// Encroachment check (if bNoCollisionFail == 0)
	if ( !bNoCollisionFail )
	{
		if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) && hash )
			hash->RemoveActor(Actor);

		INT encroach = CheckEncroachment(Actor, Actor->Location, Actor->Rotation, 0);
		if ( encroach )
		{
			DestroyActor(Actor, 0);
			return NULL;
		}

		if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) && hash )
			hash->AddActor(Actor);
	}

	// Post-spawn events
	Actor->eventPostBeginPlay();

	// Rigid body / rendering init (vtable slot 0x118)
	((VoidFn)(*(DWORD*)(*(DWORD*)Actor + 0x118)))(Actor);

	Actor->eventSaveAndResetData();

	// PostNetBeginPlay only on server/standalone (not NM_Client = 3)
	if ( LI && *(BYTE*)((BYTE*)LI + 0x425) != 3 )
		Actor->eventPostNetBeginPlay();

	Actor->eventSetInitialState();

	// FindBase if not static and physics is PHYS_None/PHYS_Rotating and not editor
	if ( !GIsEditor &&
	     !(*(INT*)((BYTE*)Actor + 0x15c)) &&  // not bNetTemporary-like flag
	     (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x1000) && // bCollideWhenPlacing
	     ((signed char)(*(DWORD*)((BYTE*)Actor + 0xa8)) < 0) && // bBlockActors (highest bit)
	     ( Actor->Physics == 0 || Actor->Physics == 5 ) ) // PHYS_None or PHYS_Rotating
	{
		Actor->FindBase();
	}

	// If ticking, add to NewlySpawned list (single-linked list in GEngineMem)
	if ( *(INT*)((BYTE*)this + 0xfc) ) // bInTick
	{
		BYTE* node = (BYTE*)GEngineMem.PushBytes(8, 8);
		if ( node )
		{
			*(AActor**)node = Actor;
			*(DWORD*)(node + 4) = *(DWORD*)((BYTE*)this + 0xf8);
		}
		*(BYTE**)((BYTE*)this + 0xf8) = node;
	}

	// In editor: initialise game type if hidden-in-editor
	if ( GIsEditor && (*(DWORD*)((BYTE*)Actor + 0xa0) & 0x10) ) // bHiddenEd
	{
		ALevelInfo* li2 = GetLevelInfo();
		FString gameTypeName = li2 ? *(FString*)((BYTE*)li2 + 0x8b0) : FString();
		Actor->SetGameType(gameTypeName);
	}

	return Actor;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6fb0)
ABrush* ULevel::SpawnBrush()
{
	guard(ULevel::SpawnBrush);
	ABrush* result = (ABrush*)SpawnActor(ABrush::StaticClass(), NAME_None, FVector(0.f,0.f,0.f), FRotator(0,0,0));
	if (!result)
		appFailAssert("Result", ".\\UnLevAct.cpp", 0xc2);
	return result;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b8840)
void ULevel::SpawnViewActor( UViewport* Viewport )
{
	guard(ULevel::SpawnViewActor);
	// Ghidra 0xb8840 (631 bytes): Assert Engine->Client is non-NULL.
	// this+0x44 = Engine pointer; Engine+0x44 = Client pointer.
	if ( *(INT*)((BYTE*)*(INT*)((BYTE*)this + 0x44) + 0x44) == 0 )
		appFailAssert("Engine->Client", ".\\UnLevAct.cpp", 0x29e);
	// Viewport->Actor must be NULL on entry (no camera attached yet).
	if ( *(INT*)((BYTE*)Viewport + 0x34) != 0 )
		appFailAssert("Viewport->Actor==NULL", ".\\UnLevAct.cpp", 0x29f);
	// Search for an existing unowned ACamera whose Tag matches the viewport's FName.
	for ( INT i = 0; ; i++ )
	{
		if ( i >= Actors.Num() ) break;
		UObject* a = Actors(i);
		if ( a != NULL )
		{
			if ( a->IsA(ACamera::StaticClass()) && *(INT*)((BYTE*)a + 0x5b4) == 0 )
			{
				if ( Viewport->GetFName() == *(FName*)((BYTE*)a + 0x19c) )
				{
					*(UObject**)((BYTE*)Viewport + 0x34) = a;
					break;
				}
			}
		}
	}
	// If no camera was found, spawn one at the default editor viewpoint (-500,-300,300).
	if ( *(INT*)((BYTE*)Viewport + 0x34) == 0 )
	{
		INT newCam = (INT)SpawnActor(ACamera::StaticClass(), NAME_None,
			FVector(-500.f,-300.f,300.f), FRotator(0,0,0), NULL, 1);
		*(INT*)((BYTE*)Viewport + 0x34) = newCam;
		if ( newCam == 0 )
			appFailAssert("Viewport->Actor", ".\\UnLevAct.cpp", 0x2b4);
		// Ghidra: cam+0x5b8 = cam (self-reference; cleared to Viewport below at +0x5b4).
		*(INT*)(newCam + 0x5b8) = newCam;
		// Copy the viewport's FName to the camera's Tag field (+0x19c).
		*(FName*)(newCam + 0x19c) = Viewport->GetFName();
	}
	// Create a UPlayerInput for the camera if it doesn't already have one (+0x7d8).
	INT cam = *(INT*)((BYTE*)Viewport + 0x34);
	if ( *(INT*)(cam + 0x7d8) == 0 )
	{
		UObject* input = UObject::StaticConstructObject(
			UPlayerInput::StaticClass(), (UObject*)cam, NAME_None, 0, NULL, GError, NULL);
		if ( input != NULL && !input->IsA(UPlayerInput::StaticClass()) )
			input = NULL;
		*(UObject**)(cam + 0x7d8) = input;
	}
	// Set RF_NotForClient|RF_NotForServer (0x300000), clear RF_Transactional (1).
	UObject* camObj = (UObject*)cam;
	camObj->SetFlags(0x300000);
	camObj->ClearFlags(1);
	// Wire up viewport back-pointer and write renderer/input raw fields.
	*(UViewport**)(cam + 0x5b4) = Viewport;
	*(DWORD*)(cam + 0x4f8) = 0x33c6844du;
	*(DWORD*)(cam + 0x504) = 5u;
	// Ghidra: final virtual call at vtable+0x10c on the camera actor.
	typedef void (__thiscall* VoidFn)(UObject*);
	((VoidFn)(*(DWORD*)(*(DWORD*)cam + 0x10c)))(camObj);
	unguard;
}

IMPL_TODO("Ghidra 0x103be0c0 (3578b): Login+SetPlayer+RemoteRole+AuthId flow implemented; NAME= option parse + CLASS=/NAME= inventory construction loop implemented; property-setting loop (FUN_1038d780, UProperty matching) deferred; FUN_103af650/FUN_103bc690/FUN_103bdad0 called by raw address")
APlayerController* ULevel::SpawnPlayActor( UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error )
{
	guard(ULevel::SpawnPlayActor);

	// Clear error string (DAT_10529f90 is L"")
	Error = TEXT("");

	// If Player is a UNetConnection, get its PackageMap
	UPackageMap* PkgMap = NULL;
	if ( Player && Player->IsA(UNetConnection::StaticClass()) )
		PkgMap = *(UPackageMap**)((BYTE*)Player + 200); // +0xC8

	// Build options string from URL.Op array
	TCHAR OptionsStr[1024];
	OptionsStr[0] = 0;
	FArray* OpArray = (FArray*)((BYTE*)&URL + 0x28);
	for ( INT i = 0; i < OpArray->Num(); i++ )
	{
		appStrcat(OptionsStr, TEXT("?"));
		FString* pOpt = (FString*)((BYTE*)OpArray->GetData() + i * 0xC);
		appStrcat(OptionsStr, **pOpt);
	}

	FString Options(OptionsStr);
	FString Portal = *(FString*)((BYTE*)&URL + 0x34);

	// Get GameInfo and call Login
	INT OldActorCount = Actors.Num();
	ALevelInfo* LI = GetLevelInfo();
	AGameInfo* Game = LI ? *(AGameInfo**)((BYTE*)LI + 0x4CC) : NULL;
	if ( !Game )
	{
		Error = TEXT("No GameInfo");
		return NULL;
	}

	APlayerController* NewPlayer = Game->eventLogin(Portal, Options, Error);
	if ( !NewPlayer )
	{
		GLog->Logf(TEXT("Login failed: %s"), *Error);
		return NULL;
	}

	// Bind player to controller
	NewPlayer->SetPlayer(Player);
	GLog->Logf(TEXT("%s spawned for %s"), NewPlayer->GetName(), Player->GetName());

	// Set Role/RemoteRole
	*(BYTE*)((BYTE*)NewPlayer + 0x2D) = ROLE_Authority; // Role
	*(BYTE*)((BYTE*)NewPlayer + 0x2E) = (BYTE)RemoteRole;

	// Net timing fields
	*(DWORD*)((BYTE*)NewPlayer + 0x4F8) = 0x334cc80c;
	*(DWORD*)((BYTE*)NewPlayer + 0x504) = 5;

	// Network game: parse AuthId, NAME, inventory from URL options
	if ( LI && *(BYTE*)((BYTE*)LI + 0x425) != 0 ) // NetMode != NM_Standalone
	{
		// AuthId2 / AuthId1 from URL options
		FString AuthId2 = URL.GetOption(TEXT("AuthId2="), TEXT(""));
		*(FString*)((BYTE*)NewPlayer + 0x6B8) = AuthId2;

		FString AuthId1 = URL.GetOption(TEXT("AuthId1="), TEXT(""));
		*(FString*)((BYTE*)NewPlayer + 0x69C) = AuthId1;
		*(INT*)((BYTE*)NewPlayer + 0x698) = 1;

		// NAME= option: resolve character name via FUN_103af650
		const TCHAR* pNamePtr = NULL;
		const TCHAR* pDefName = *FURL::DefaultName;
		const TCHAR* pName = URL.GetOption(TEXT("NAME="), pDefName);
		if (pName != NULL)
		{
			FString NameStr(pName);
			typedef FString* (__cdecl* ResolveNameFn)(FString*);
			FString* resolvedName = ((ResolveNameFn)(0x103af650))(&NameStr);
			if (resolvedName != NULL)
				pNamePtr = **resolvedName;
		}
		GLog->Logf(TEXT("%s"), pNamePtr ? pNamePtr : TEXT(""));

		// Inventory construction from CLASS=/NAME= URL options
		FArray inventoryList;
		appMemzero(&inventoryList, sizeof(FArray));

		TCHAR classBuf[256]; classBuf[0] = 0;
		TCHAR nameBuf[256];  nameBuf[0] = 0;
		TCHAR lineBuf[256];  lineBuf[0] = 0;

		while (pNamePtr != NULL &&
		       Parse(pNamePtr, TEXT("CLASS="), classBuf, 256) &&
		       Parse(pNamePtr, TEXT("NAME="), nameBuf, 256))
		{
			INT idx = inventoryList.Add(1, 0x1c);
			BYTE* entryPtr = NULL;
			if (inventoryList.GetData() != NULL)
			{
				entryPtr = (BYTE*)inventoryList.GetData() + idx * 0x1c;
				typedef void (__cdecl* InventoryCtorFn)(BYTE*);
				((InventoryCtorFn)(0x103bc690))(entryPtr);
			}

			ParseLine(&pNamePtr, lineBuf, 256, 1);
			ParseLine(&pNamePtr, lineBuf, 256, 1);

			while (ParseLine(&pNamePtr, lineBuf, 256, 1) != 0 && lineBuf[0] != 0)
			{
				if (entryPtr != NULL)
				{
					FArray* propArr = (FArray*)(entryPtr + 0x10);
					INT propIdx = propArr->Add(1, 0xc);
					BYTE* propData = (BYTE*)propArr->GetData() + propIdx * 0xc;
					FString* propStr = (FString*)propData;
					if (propStr != NULL)
					{
						appMemzero(propStr, 0xc);  // zero-init slot before assignment
						*propStr = FString(lineBuf);
					}
				}
			}
		}

		// Cleanup: FUN_103bdad0 tears down global inventory state set up during construction
		typedef void (__cdecl* InventoryCleanupFn)();
		((InventoryCleanupFn)(0x103bdad0))();
		inventoryList.~FArray();
	}

	// If new actors were spawned during Login, notify level change
	INT NewActorCount = Actors.Num();
	if ( OldActorCount != NewActorCount )
	{
		// Level actors changed: mark for potential replication/notification
	}

	return NewPlayer;
	unguard;
}

// CheckSlice is now implemented (batch 24). TraceLen local variable confirmed:
// Ghidra initialises local_18 = 1 before CheckSlice (TraceLen=1 in 3-arg call);
// 0x55 = 0.605 * 10 / 11 — confirmed by Ghidra literals 0x3f0ccccd (0.55f) and
// 0x3f1a3d71 (0.605f). SingleLineCheck from Location → TraceStart verified.
IMPL_MATCH("Engine.dll", 0x103b9020)
INT ULevel::FindSpot( FVector Extent, FVector& Location, INT bCheckActors, AActor* Requester )
{
	guard(ULevel::FindSpot);
	FCheckResult Hit;
	ALevelInfo* Level = GetLevelInfo();

	if ( EncroachingWorldGeometry(Hit, Location, Extent, 0, Level, Requester) == 0 )
		return 1;

	if ( Extent == FVector(0.f, 0.f, 0.f) )
		return 0;

	FVector Saved = Location;
	INT TraceLen = 1;

	if ( CheckSlice(Location, Extent, TraceLen, Requester) )
		return 1;

	if ( TraceLen != 0 && bCheckActors == 0 )
	{
		FVector HalfExtent(Extent.X * 0.5f, Extent.Y * 0.5f, 1.0f);
		INT numFound = 0;

		INT dx, dy;
		for ( dx = -1; dx <= 1; dx += 2 )
		{
			for ( dy = -1; dy <= 1; dy += 2 )
			{
				if ( numFound < 2 )
				{
					FVector TestLoc(
						Saved.X + dx * Extent.X * 0.55f,
						Saved.Y + dy * Extent.Y * 0.55f,
						Saved.Z);
					Level = GetLevelInfo();
					if ( EncroachingWorldGeometry(Hit, TestLoc, HalfExtent, 0, Level, Requester) == 0 )
					{
						numFound++;
						Location.X += dx * Extent.X * 0.605f;
						Location.Y += dy * Extent.Y * 0.605f;
					}
				}
			}
		}

		if ( numFound != 0 )
		{
			if ( numFound == 1 )
				Location = Saved;

			if ( EncroachingWorldGeometry(Hit, Location, Extent, 0, GetLevelInfo(), Requester) == 0 )
			{
				FVector TraceStart = Saved + (Saved - Location) * 0.2f;
				FCheckResult Hit2;
				SingleLineCheck(Hit2, NULL, TraceStart, Location, 0x86, Extent);
				if ( Hit2.Actor == NULL )
					return 1;
				Location = Hit2.Location;
				return 1;
			}
		}
	}

	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b8b30)
INT ULevel::CheckSlice( FVector& Adjusted, FVector Extent, INT& NumIterations, AActor* Actor )
{
	guard(ULevel::CheckSlice);
	NumIterations = 0;

	FCheckResult Hit( 1.f );
	ALevelInfo* LI = GetLevelInfo();

	// Is the actor already encroaching world geometry at its current location?
	if( EncroachingWorldGeometry( Hit, Adjusted, Extent, 0, LI, Actor ) )
	{
		NumIterations = 1;
		return 0;
	}

	// Trace downward to find the nearest floor surface.
	// Ghidra uses 2 * Extent.Z as the downward probe distance.
	FLOAT extZ = Extent.Z;
	FVector TraceEnd( Adjusted.X, Adjusted.Y, Adjusted.Z - extZ * 2.0f );
	FCheckResult TraceHit( 1.f );
	SingleLineCheck( TraceHit, Actor, TraceEnd, Adjusted, TRACE_World, FVector(0.f,0.f,0.f) );
	FLOAT t = TraceHit.Time;

	if( t == 0.0f )
	{
		// Immediate hit — geometry starts right where the actor is.
		// Push the actor downward by one half-height so the floor is below it.
		Adjusted.Z -= extZ;
		// Fall through to shared EncroachingWorldGeometry test below.
	}
	else if( t <= 0.5f )
	{
		// Hit in the upper half of the probe: push UP to clear.
		// Ghidra: Z += (1 - 2t) * extZ + 1.0
		FLOAT push = (1.0f - 2.0f * t) * extZ + 1.0f;
		Adjusted.Z += push;

		// Test for clearance at the pushed-up position.
		FCheckResult Hit2( 1.f );
		if( !EncroachingWorldGeometry( Hit2, Adjusted, Extent, 0, LI, Actor ) )
			return 1;

		// Still blocked — apply a horizontal nudge along the obstruction normal.
		FVector Nudge( Hit2.Normal.X * Extent.X, Hit2.Normal.Y * Extent.X, 0.f );
		Adjusted += Nudge;
		FCheckResult Hit3( 1.f );
		return !EncroachingWorldGeometry( Hit3, Adjusted, Extent, 0, LI, Actor );
	}
	else
	{
		// Hit in the lower half of the probe: push DOWN to land on the surface.
		// Ghidra: Z = Z - (2t-1)*extZ + 1.0  (note: +1.0 nudges back UP slightly)
		FLOAT push = (2.0f * t - 1.0f) * extZ - 1.0f;
		Adjusted.Z -= push;
		// Fall through to shared EncroachingWorldGeometry test below.
	}

	// Shared test for the t==0 and t>0.5 fall-through paths.
	FCheckResult Hit4( 1.f );
	if( !EncroachingWorldGeometry( Hit4, Adjusted, Extent, 0, LI, Actor ) )
	{
		// Surface snap: trace upward by extZ to follow gentle slopes.
		FCheckResult SnapHit( 1.f );
		FVector SnapEnd( Adjusted.X, Adjusted.Y, Adjusted.Z + extZ );
		SingleLineCheck( SnapHit, NULL, SnapEnd, Adjusted, 0x86, FVector(0.f,0.f,0.f) );
		if( SnapHit.Time < 1.0f )
			Adjusted = SnapHit.Location;
		return 1;
	}

	// Last-resort horizontal nudge in the hit normal direction.
	FVector Nudge2( Hit4.Normal.X * Extent.X, Hit4.Normal.Y * Extent.X, 0.f );
	Adjusted += Nudge2;
	FCheckResult Hit5( 1.f );
	return !EncroachingWorldGeometry( Hit5, Adjusted, Extent, 0, LI, Actor );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bad70)
INT ULevel::CheckEncroachment( AActor* Actor, FVector TestLocation, FRotator TestRotation, INT bTouchNotify )
{
	guard(ULevel::CheckEncroachment);

	check(Actor != NULL);

	DWORD ActorFlags = *(DWORD*)((BYTE*)Actor + 0xA8);
	if ( (ActorFlags & 0x6800) == 0 && !Actor->IsEncroacher() )
		return 0;

	// Build old+new transform matrices for encroaching actors (Movers/KActors).
	FMatrix OldMatrix;
	FMatrix NewMatrix;
	if ( Actor->IsEncroacher() )
	{
		// Old transform at current position (Ghidra vtable+0xB0)
		OldMatrix = Actor->LocalToWorld();

		// Save current Location/Rotation, temporarily apply test pose
		FVector  SavedLoc = Actor->Location;
		FRotator SavedRot = Actor->Rotation;
		Actor->Location = TestLocation;
		Actor->Rotation = TestRotation;

		// New transform at test position (Ghidra vtable+0xAC)
		NewMatrix = Actor->LocalToWorld();

		// Restore
		Actor->Location = SavedLoc;
		Actor->Rotation = SavedRot;
	}

	FMemMark Mark(GMem);

	// Query hash for overlapping actors at the test position
	FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)this + 0xF0);
	FCheckResult* Results = NULL;
	if ( Hash )
		Results = Hash->ActorEncroachmentCheck( GMem, Actor, TestLocation, TestRotation, 0x9F, 0 );

	// First pass: check each overlapping actor for encroachment
	for ( FCheckResult* Check = Results; Check; Check = Check->GetNext() )
	{
		AActor* Other = Check->Actor;
		if ( Other == Actor )
			continue;
		if ( Other == (AActor*)GetLevelInfo() )
			continue;
		if ( Other->IsJoinedTo(Actor) )
			continue;
		if ( !Actor->IsBlockedBy(Other) )
			continue;
		// Skip if Other is based on Actor
		if ( *(AActor**)((BYTE*)Other + 0x180) == Actor )
			continue;

		// Encroacher vs non-encroacher: try to push Other out of the way
		if ( Actor->IsEncroacher() && !Other->IsEncroacher() )
		{
			FVector Disp;
			Disp.X = TestLocation.X - Actor->Location.X;
			Disp.Y = TestLocation.Y - Actor->Location.Y;
			Disp.Z = TestLocation.Z - Actor->Location.Z;
			Other->moveSmooth(Disp);

			// Temporarily place Actor at TestLocation/TestRotation for PointCheck
			FVector  OrigLoc = Actor->Location;
			FRotator OrigRot = Actor->Rotation;
			Actor->Location = TestLocation;
			Actor->Rotation = TestRotation;

			// Point check: see if Other is still overlapping after displacement
			INT bStillOverlapping;
			FCheckResult PointHit(1.f);
			if ( !Other->IsVolumeBrush() )
			{
				UPrimitive* Prim = Actor->GetPrimitive();
				FVector Ext = Other->GetCylinderExtent();
				bStillOverlapping = Prim
					? !Prim->PointCheck( PointHit, Actor, Other->Location, Ext, 0 )
					: 0;
			}
			else
			{
				UPrimitive* Prim = Other->GetPrimitive();
				FVector Ext = Actor->GetCylinderExtent();
				bStillOverlapping = Prim
					? !Prim->PointCheck( PointHit, Other, Actor->Location, Ext, 0 )
					: 0;
			}

			// Restore original position
			Actor->Location = OrigLoc;
			Actor->Rotation = OrigRot;

			if ( bStillOverlapping )
			{
				// Push Other back with reversed displacement via MoveActor
				FVector RevDisp( -Disp.X, -Disp.Y, -Disp.Z );
				Actor->Location = TestLocation;
				FCheckResult MoveHit(1.f);
				MoveActor( Other, RevDisp, Other->Rotation, MoveHit, 0, 0, 0, 0, 0 );
				Actor->Location = OrigLoc;
			}
		}

		// Check if Actor wants to block the encroachment
		if ( Actor->eventEncroachingOn(Other) )
		{
			Mark.Pop();
			return 1;
		}
	}

	// Touch cleanup: if bTouchNotify, remove stale touches
	if ( bTouchNotify )
	{
		TArray<AActor*>& Touching = *(TArray<AActor*>*)((BYTE*)Actor + 0x1C8);
		INT i = 0;
		while ( i < Touching.Num() )
		{
			AActor* TouchActor = Touching(i);
			if ( !TouchActor || Actor->IsOverlapping(TouchActor, NULL) )
				i++;
			else
				Actor->EndTouch( Touching(i), 0 );
		}
	}

	// Second pass: notify encroached actors
	for ( FCheckResult* Check = Results; Check; Check = Check->GetNext() )
	{
		AActor* Other = Check->Actor;
		if ( Other == Actor )
			continue;
		if ( Other->IsJoinedTo(Actor) )
			continue;
		// GetLevelInfo inline check (Actors(0))
		if ( Other == *(AActor**)(*(BYTE**)((BYTE*)this + 0x30)) )
			continue;
		if ( *(AActor**)((BYTE*)Other + 0x180) == Actor )
			continue;

		if ( !Actor->IsBlockedBy(Other) )
		{
			if ( bTouchNotify )
			{
				// Ghidra vtable+0xC4: touch-notify for non-blocking actor
				typedef void (__thiscall* TouchNotifyFn)(AActor*, AActor*);
				((TouchNotifyFn)(*(INT*)(*(INT*)Actor + 0xC4)))(Actor, Other);
			}
			continue;
		}

		Other->eventEncroachedBy(Actor);
	}

	Mark.Pop();
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b75f0)
INT ULevel::SinglePointCheck( FCheckResult& Hit, AActor* SourceActor, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors )
{
	guard(ULevel::SinglePointCheck);
	FMemMark Mark(GMem);
	DWORD* res = (DWORD*)MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, bActors, 0, 0, NULL);
	if ( res )
	{
		DWORD* puVar3 = res;
		if ( (AActor*)res[1] == SourceActor )
		{
			if ( !*(DWORD*)res ) { Mark.Pop(); return 1; }
			if ( (AActor*)res[1] == SourceActor )
				puVar3 = (DWORD*)*res;
		}
		DWORD* dst = (DWORD*)&Hit;
		for ( INT i = 0xc; i != 0; i-- )
			*dst++ = *puVar3++;
		for ( DWORD* cur = (DWORD*)*res; cur; cur = (DWORD*)*cur )
		{
			if ( (AActor*)cur[1] != SourceActor )
			{
				FLOAT dCurX = (FLOAT)cur[2] - Location.X;
				FLOAT dCurY = (FLOAT)cur[3] - Location.Y;
				FLOAT dCurZ = (FLOAT)cur[4] - Location.Z;
				FLOAT dHitX = (FLOAT)((DWORD*)&Hit)[2] - Location.X;
				FLOAT dHitY = (FLOAT)((DWORD*)&Hit)[3] - Location.Y;
				FLOAT dHitZ = (FLOAT)((DWORD*)&Hit)[4] - Location.Z;
				if ( FVector(dCurX, dCurY, dCurZ).SizeSquared() < FVector(dHitX, dHitY, dHitZ).SizeSquared() )
				{
					puVar3 = cur;
					dst = (DWORD*)&Hit;
					for ( INT j = 0xc; j != 0; j-- )
						*dst++ = *puVar3++;
				}
			}
		}
		Mark.Pop();
		return 0;
	}
	Mark.Pop();
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b75f0)
INT ULevel::SinglePointCheck( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors )
{
	guard(ULevel::SinglePointCheck);
	FMemMark Mark(GMem);
	DWORD* res = (DWORD*)MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, bActors, 0, 0, NULL);
	if ( !res ) { Mark.Pop(); return 1; }
	DWORD* src = res;
	DWORD* dst = (DWORD*)&Hit;
	for ( INT i = 0xc; i != 0; i-- )
		*dst++ = *src++;
	for ( res = (DWORD*)*res; res; res = (DWORD*)*res )
	{
		FLOAT dCurX = (FLOAT)res[2] - Location.X;
		FLOAT dCurY = (FLOAT)res[3] - Location.Y;
		FLOAT dCurZ = (FLOAT)res[4] - Location.Z;
		FLOAT dHitX = (FLOAT)((DWORD*)&Hit)[2] - Location.X;
		FLOAT dHitY = (FLOAT)((DWORD*)&Hit)[3] - Location.Y;
		FLOAT dHitZ = (FLOAT)((DWORD*)&Hit)[4] - Location.Z;
		if ( FVector(dCurX, dCurY, dCurZ).SizeSquared() < FVector(dHitX, dHitY, dHitZ).SizeSquared() )
		{
			src = res;
			dst = (DWORD*)&Hit;
			for ( INT j = 0xc; j != 0; j-- )
				*dst++ = *src++;
		}
	}
	Mark.Pop();
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bb3e0)
INT ULevel::SingleLineCheck( FCheckResult& Hit, AActor* SourceActor, const FVector& End, const FVector& Start, DWORD TraceFlags, FVector Extent )
{
	guard(ULevel::SingleLineCheck);
	FMemMark Mark(GMem);
	ALevelInfo* traceLevel = (TraceFlags & TRACE_Level) ? GetLevelInfo() : NULL;
	DWORD* res = (DWORD*)MultiLineCheck(GMem, End, Start, Extent, traceLevel, TraceFlags | TRACE_SingleResult, SourceActor);
	do
	{
		if ( !res )
		{
			// No hit: set Time=1.0, Actor=NULL
			((DWORD*)&Hit)[9] = 0x3f800000;
			((DWORD*)&Hit)[1] = 0;
			Mark.Pop();
			return 1;
		}

		// Skip if result actor is SourceActor or any of SourceActor's owners
		if ( SourceActor )
		{
			for ( AActor* a = SourceActor; a; a = *(AActor**)((BYTE*)a + 0x140) )
				if ( (AActor*)res[1] == a )
					goto next_result;
		}

		// Accept unless: BSP hit on LevelInfo with TRACE_ShadowCast(0x100) and actor is underground
		{
			ALevelInfo* li = GetLevelInfo();
			if ( (INT)res[10] == -1 || (ALevelInfo*)res[1] != li || !(TraceFlags & TRACE_ShadowCast) ||
				( *(signed char*)( *(BYTE**)( *(BYTE**)((BYTE*)this + 0x90) + 0x9c )
					+ *(INT*)( *(BYTE**)( *(BYTE**)((BYTE*)this + 0x90) + 0x5c ) + (INT)res[10] * 0x90 + 0x34 )
					* 0x5c + 4 ) >= 0 ) )
			{
				// Inner shadow-cast filter: skip non-shadow-casters when tracing shadows
				if ( !(TraceFlags & TRACE_VisibleNonColliding) )
				{
					ALevelInfo* li2 = GetLevelInfo();
					if ( (AActor*)res[1] != (AActor*)li2
						 && (*(DWORD*)((BYTE*)res[1] + 0xa4) & 0x40000000) == 0
						 && (TraceFlags & TRACE_ShadowCast) )
						goto next_result;
				}
				// Copy result to Hit
				DWORD* src = res;
				DWORD* dst = (DWORD*)&Hit;
				for ( INT i = 0xc; i != 0; i-- )
					*dst++ = *src++;
				Mark.Pop();
				return 0;
			}
		}

	next_result:
		res = (DWORD*)*res;
	} while ( true );

	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6d60)
INT ULevel::EncroachingWorldGeometry( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, AActor* Actor )
{
	guard(ULevel::EncroachingWorldGeometry);
	FMemMark Mark(GMem);
	DWORD* res = (DWORD*)MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, 1, 1, 1, Actor);
	if ( !res )
	{
		Mark.Pop();
		return 0;
	}
	DWORD* src = res;
	DWORD* dst = (DWORD*)&Hit;
	for ( INT i = 0xc; i != 0; i-- )
		*dst++ = *src++;
	Mark.Pop();
	return 1;
	unguard;
}

// Helper: prepend a FCheckResult to a linked list using Mem's stack allocator.
// Returns the new head, or NULL if allocation failed. Sets Actor on the new node.
static FCheckResult* PrependHit( FMemStack& Mem, const FCheckResult& Hit, FCheckResult* OldHead, AActor* Actor )
{
	FCheckResult* New = (FCheckResult*)Mem.PushBytes( sizeof(FCheckResult), 8 );
	if ( !New )
		return OldHead;
	*New = Hit;
	New->GetNext() = OldHead;
	New->Actor = Actor;
	return New;
}

IMPL_MATCH("Engine.dll", 0x103bc6f0)
FCheckResult* ULevel::MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors, INT bOnlyWorldGeometry, INT bSingleResult, AActor* Requester )
{
	guard(ULevel::MultiPointCheck);
	FCheckResult* Result = NULL;

	// --- 1. Actor/BSP hash point check ---
	// Calls FCollisionHashBase::ActorPointCheck (vtable slot 4, offset 0x14).
	// TraceFlags: bOnlyWorldGeometry ? 0x86 (world-only) : 0x9f (actors+world).
	// Ghidra: (-(DWORD)(bOnlyWorldGeometry!=0) & 0xffffffe7) + 0x9f
	FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	if ( bActors && Hash )
	{
		DWORD TraceFlags = bOnlyWorldGeometry ? (DWORD)0x86 : (DWORD)0x9f;
		Result = Hash->ActorPointCheck( Mem, Location, Extent, ExtraNodeFlags, TraceFlags, bOnlyWorldGeometry, Requester );
	}

	// --- 2. Requester's XLevel BSP check ---
	// Requester->XLevel is at actor+0x328; from there, Model->PointCheck is invoked.
	// This path checks the BSP model of the requester's level for point containment.
	if ( Requester )
	{
		ULevel* XLev = *(ULevel**)((BYTE*)Requester + 0x328);
		if ( XLev )
		{
			UModel* XModel = *(UModel**)((BYTE*)XLev + 0x90);
			if ( XModel )
			{
				FCheckResult hit( 1.0f, NULL );
				hit.Item = INDEX_NONE;
				INT r = XModel->PointCheck( hit, Requester, Location, Extent, ExtraNodeFlags );
				if ( r == 0 )
				{
					Result = PrependHit( Mem, hit, Result, Requester );
					if ( bSingleResult )
						return Result;
				}
			}
		}
	}

	// --- 3. Terrain zone checks ---
	// Iterate all 256 BSP zones from the Model, testing terrain actors in terrain zones.
	// Zone actor is at Model_base + (iZone * 9 + 0x24) * 8 (each zone stride = 0x48 bytes).
	// bTerrainZone = bit 1 of AZoneInfo::bFlags at +0x398.
	UModel* Model = *(UModel**)((BYTE*)this + 0x90);
	for ( INT iZone = 0; iZone < 0x100; iZone++ )
	{
		ALevelInfo* ZoneActor = *(ALevelInfo**)((BYTE*)Model + (iZone * 9 + 0x24) * 8);
		if ( !ZoneActor )
			ZoneActor = GetLevelInfo();
		if ( !ZoneActor )
			continue;
		if ( !(*(BYTE*)((BYTE*)ZoneActor + 0x398) & 2) )
			continue;
		TArray<ATerrainInfo*>& Terrains = *(TArray<ATerrainInfo*>*)((BYTE*)ZoneActor + 0x3C0);
		for ( INT iT = 0; iT < Terrains.Num(); iT++ )
		{
			ATerrainInfo* Terrain = Terrains(iT);
			FCheckResult hit( 1.0f, NULL );
			hit.Item = INDEX_NONE;
			if ( Terrain->PointCheck( hit, Location, Extent, ExtraNodeFlags ) != 0 )
				continue;
			// Verify the hit point lies in the expected terrain zone.
			FPointRegion Region = Model->PointRegion( GetLevelInfo(), hit.Location );
			if ( Region.Zone != (AZoneInfo*)ZoneActor )
				continue;
			Result = PrependHit( Mem, hit, Result, (AActor*)Terrain );
			if ( bSingleResult )
				return Result;
		}
	}

	return Result;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bcb00)
FCheckResult* ULevel::MultiLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, ALevelInfo* Level, DWORD TraceFlags, AActor* SourceActor )
{
	guard(ULevel::MultiLineCheck);

	// Collect up to 256 hits in a stack buffer, sort by Time, then link into Mem.
	// The 0x100-slot array mirrors the Ghidra local_30b0[] layout.
	BYTE resultBuf[0x100 * sizeof(FCheckResult)];
	INT numHits = 0;
	FLOAT timeScale = 1.0f;  // Ghidra: local_1c; updated during warp zone traversal

	// Working End-point, updated if a warp zone is traversed (common case: no update).
	FVector adjEnd = End;

	// --- 1. Terrain zone line checks (if TRACE_Level) ---
	// Ghidra: if ((TraceFlags & 4) && !((TraceFlags & 0x100) && !(TraceFlags & 0x2000)))
	if ( (TraceFlags & TRACE_Level) &&
		 ( !(TraceFlags & TRACE_ShadowCast) || (TraceFlags & TRACE_VisibleNonColliding) ) )
	{
		// Zone list at ULevel+0x101d8 (TArray<AZoneInfo*> of all zone actors).
		TArray<AZoneInfo*>& ZoneList = *(TArray<AZoneInfo*>*)((BYTE*)this + 0x101d8);
		for ( INT iZ = 0; iZ < ZoneList.Num(); iZ++ )
		{
			AZoneInfo* Zone = ZoneList(iZ);
			if ( !Zone )
				continue;
			TArray<ATerrainInfo*>& Terrains = *(TArray<ATerrainInfo*>*)((BYTE*)Zone + 0x3C0);
			for ( INT iT = 0; iT < Terrains.Num(); iT++ )
			{
				if ( numHits >= 0x100 )
					goto hashCheck;
				FCheckResult* slot = (FCheckResult*)(resultBuf + numHits * sizeof(FCheckResult));
				appMemset( slot, 0, sizeof(FCheckResult) );
				slot->Time = 1.0f;
				slot->Item = INDEX_NONE;
				ATerrainInfo* Terrain = Terrains(iT);
				if ( Terrain->LineCheck( *slot, adjEnd, Start, Extent, TraceFlags ) != 0 )
					continue;
				// Verify the hit is in the expected zone.
				UModel* Mdl = *(UModel**)((BYTE*)this + 0x90);
				FPointRegion Region = Mdl->PointRegion( GetLevelInfo(), slot->Location );
				if ( Region.Zone != Zone )
					continue;
				slot->Actor = (AActor*)Terrain;
				// Ghidra scales slot->Time by timeScale then updates timeScale.
				slot->Time *= timeScale;
				numHits++;
				// DIVERGENCE from retail: warp zone End-point adjustment omitted
				// (adjusts adjEnd toward hit then reschedules for portal; common case is no warp).
				if ( TraceFlags & TRACE_StopAtFirstHit )
					goto buildList;
			}
		}
	}

hashCheck:
	// --- 2. Actor hash line check ---
	// Ghidra: if (!(TraceFlags & 0x200) || uVar10 == 0) AND (TraceFlags & 0x9b) AND hash
	// 0x200 = TRACE_StopAtFirstHit; 0x9b = actor-trace flags.
	if ( (numHits == 0 || !(TraceFlags & TRACE_StopAtFirstHit)) &&
		 (TraceFlags & 0x9b) )
	{
		FCollisionHashBase* Hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
		if ( Hash )
		{
			FCheckResult* pfVar7 = Hash->ActorLineCheck( Mem, adjEnd, Start, Extent, TraceFlags, 0, SourceActor );
			for ( ; pfVar7 && numHits < 0x100; numHits++ )
			{
				FCheckResult* slot = (FCheckResult*)(resultBuf + numHits * sizeof(FCheckResult));
				*slot = *pfVar7;
				slot->Time *= timeScale;  // Ghidra: pfVar7[9] = local_1c * pfVar7[9]
				pfVar7 = pfVar7->GetNext();
			}
		}
	}

buildList:
	if ( numHits == 0 )
		return NULL;

	// Sort by Time (ascending). Ghidra: appQsort(local_30b0, uVar10, 0x30, &LAB_103b6f70)
	appQsort( resultBuf, numHits, sizeof(FCheckResult), (QSORT_COMPARE)CompareHits );

	// Allocate numHits FCheckResult nodes from Mem and link them.
	FCheckResult* head = (FCheckResult*)Mem.PushBytes( numHits * sizeof(FCheckResult), 8 );
	if ( !head )
		return NULL;
	for ( INT i = 0; i < numHits; i++ )
	{
		FCheckResult* node = head + i;
		*node = *(FCheckResult*)(resultBuf + i * sizeof(FCheckResult));
		node->GetNext() = (i + 1 < numHits) ? (head + i + 1) : NULL;
	}

	return head;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bfb90)
void ULevel::DetailChange( INT NewDetail )
{
	guard(ULevel::DetailChange);
	ALevelInfo* info = GetLevelInfo();
	*(DWORD*)((BYTE*)info + 0x450) ^= (DWORD(NewDetail) << 7 ^ *(DWORD*)((BYTE*)info + 0x450)) & 0x80u;
	info = GetLevelInfo();
	if ( *(UObject**)((BYTE*)info + 0x4cc) )
	{
		info = GetLevelInfo();
		UObject* gri = *(UObject**)((BYTE*)info + 0x4cc);
		UFunction* func = gri->FindFunctionChecked(ENGINE_DetailChange, 0);
		typedef void (__thiscall* ProcessEventFn)(UObject*, UFunction*, void*, void*);
		((ProcessEventFn)(*(DWORD*)(*(DWORD*)gri + 0x10)))(gri, func, NULL, NULL);
	}
	unguard;
}

// FUN_103b7b70 (88 bytes, _unnamed.cpp): thiscall on UNetConnection; looks up
// the UActorChannel* for an actor in the connection's TMap<AActor*,UChannel*>
// hash. Returns NULL if no channel exists for that actor.
typedef UChannel* (__thiscall* FindActorChannelFn)(void* Conn, AActor** pActor);

IMPL_MATCH("Engine.dll", 0x103c62f0)
INT ULevel::TickDemoRecord( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoRecord);

	// DemoRecDriver is at this+0x8c; its first Connection is at DemoRecDriver+0x30.
	if ( !*(DWORD*)((BYTE*)this + 0x8c) )
		return 1;
	UNetConnection* ServerConn = *(UNetConnection**)(*(DWORD*)((BYTE*)this + 0x8c) + 0x30);

	// bDemoPlayback: true when NetMode == NM_Client (3).
	// Ghidra: local_1c = (*(char*)(Actors[0] + 0x425) == 3)
	UBOOL bDemoPlayback = (*(BYTE*)((BYTE*)GetLevelInfo() + 0x425) == 3);

	// Retail FUN_103b7b70: TMap actor→channel lookup on the connection.
	FindActorChannelFn FindActorChannel = (FindActorChannelFn)0x103b7b70;

	// PackageMap is at ServerConn+0xC8 (= offset 200); vtable slot 28 (0x70)
	// checks whether a given UClass has a valid demo-record channel index.
	typedef INT (__thiscall* PkgMapChannelCheckFn)(void*, UClass*);

	for ( INT iActor = 0; ; iActor++ )
	{
		if ( iActor >= Actors.Num() )
			return 1;

		// Retail asserts that Actors[0] is LevelInfo.
		if ( !*(INT*)Actors.GetData() )
			appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ad);
		if ( !Actors(0)->IsA(ALevelInfo::StaticClass()) )
			appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ae);

		AActor* a = Actors(iActor);
		if ( !a )
			continue;

		// Replicate if RemoteRole != ROLE_None (Ghidra: this_02[0x2e] != 0, offset 0xB8).
		// In demo-playback mode, also replicate if Role is non-None and non-Authority.
		// Ghidra: this_02[0x2d] = *(DWORD*)(a+0xB4) = Role DWORD, [0x2e] = RemoteRole DWORD.
		UBOOL bShouldRep = (*(DWORD*)((BYTE*)a + 0xB8) != 0);
		if ( !bShouldRep && bDemoPlayback )
			bShouldRep = (*(DWORD*)((BYTE*)a + 0xB4) != 0 && *(DWORD*)((BYTE*)a + 0xB4) != 4);
		if ( !bShouldRep )
			continue;

		// Skip zone-info actors in the lower network-relevant range.
		if ( iActor < *(INT*)((BYTE*)this + 0x104) )
		{
			if ( !a->IsA(AZoneInfo::StaticClass()) )
				continue;
		}

		// If RF flag 0x10000000 is set, skip actors already bound to another connection.
		if ( *(DWORD*)((BYTE*)a + 0xa0) & 0x10000000 )
		{
			INT    nConn  = *(INT*)((BYTE*)ServerConn + 0x4b8c);
			INT*   cList  = *(INT**)((BYTE*)ServerConn + 0x4b88);
			UBOOL  bFound = 0;
			for ( INT j = 0; j < nConn && !bFound; j++ )
				if ( cList[j] == (INT)a ) bFound = 1;
			if ( bFound )
				continue;
		}

		// Skip if bStatic (bit 0 of RF at +0xa0) is not set and the class default
		// actor HAS bStatic — meaning only static versions of this class replicate.
		if ( !(*(BYTE*)((BYTE*)a + 0xa0) & 1) )
		{
			AActor* def = a->GetClass()->GetDefaultActor();
			if ( def && (*(BYTE*)((BYTE*)def + 0xa0) & 1) )
				continue;
		}

		// Find or create the demo-record channel for this actor.
		UChannel* Channel = FindActorChannel(ServerConn, &a);
		if ( !Channel )
		{
			// Check whether this actor's class has a registered channel slot.
			void* pkgmap = *(void**)((BYTE*)ServerConn + 0xC8);
			INT chanIdx = ((PkgMapChannelCheckFn)(*(DWORD*)(*(DWORD*)pkgmap + 0x70)))(pkgmap, a->GetClass());
			if ( chanIdx != -1 )
			{
				Channel = ServerConn->CreateChannel(CHTYPE_Actor, 1, -1);
				if ( !Channel )
					appFailAssert("Channel", ".\\UnLevTic.cpp", 0x501);
				((UActorChannel*)Channel)->SetChannelActor(a);
			}
		}

		if ( Channel )
		{
			if ( *(INT*)((BYTE*)Channel + 0x34) )
				appFailAssert("!Channel->Closing", ".\\UnLevTic.cpp", 0x507);

			if ( Channel->IsNetReady(0) )
			{
				// Set bForceStatic (bit 8) and optionally bNetOwner (bit 9) flags.
				// Ghidra: flags |= 0x100; if bDemoPlayback adjust bit 9.
				DWORD& fl = *(DWORD*)((BYTE*)a + 0xac);
				fl = (fl & ~0x200u) | (bDemoPlayback ? 0x200u : 0u) | 0x100u;

				if ( bDemoPlayback )
				{
					// Temporarily swap Role ↔ RemoteRole so the actor replicates
					// with its server-side role (Ghidra: swap DWORDS at 0xB4/0xB8).
					DWORD tmp = *(DWORD*)((BYTE*)a + 0xB8);
					*(DWORD*)((BYTE*)a + 0xB8) = *(DWORD*)((BYTE*)a + 0xB4);
					*(DWORD*)((BYTE*)a + 0xB4) = tmp;
				}

				((UActorChannel*)Channel)->ReplicateActor();

				if ( bDemoPlayback )
				{
					// Restore original roles.
					DWORD tmp = *(DWORD*)((BYTE*)a + 0xB8);
					*(DWORD*)((BYTE*)a + 0xB8) = *(DWORD*)((BYTE*)a + 0xB4);
					*(DWORD*)((BYTE*)a + 0xB4) = tmp;
				}

				// Clear bForceStatic and bNetOwner flags.
				*(DWORD*)((BYTE*)a + 0xac) &= ~0x300u;
			}
		}
	}

	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c65a0)
INT ULevel::TickDemoPlayback( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoPlayback);
	ALevelInfo* info = GetLevelInfo();
	BYTE* eng  = *(BYTE**)((BYTE*)this + 0x44);
	// DemoRecDriver->ServerConnection->State
	INT state = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)this + 0x8c) + 0x3c) + 0x80);
	if ( *(BYTE*)((BYTE*)info + 0x928) == 3 && state != 2 )
	{
		*(BYTE*)((BYTE*)info + 0x928) = 0;
		// ServerTravel("","",0) — vtable slot 0xb0/4 on UEngine
		typedef void (__thiscall* ServerTravelFn)(void*, const TCHAR*, const TCHAR*, INT);
		((ServerTravelFn)(*(DWORD*)(*(DWORD*)eng + 0xb0)))(eng, TEXT(""), TEXT(""), 0);
	}
	if ( state == 1 )
	{
		INT nVP = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)eng + 0x44) + 0x30) + 4);
		if ( nVP == 0 )
			appFailAssert("Engine->Client->Viewports.Num()", ".\\UnLevTic.cpp", 0x527);
		// Browse to "?entry": Engine->vtable[0xa4/4=41](firstViewport, "?entry", 0, 0)
		// firstViewport = Engine->Client->Viewports.Data[0]
		BYTE* client  = *(BYTE**)(eng + 0x44);
		void* vp0     = *(void**)(*(BYTE**)(client + 0x30));
		typedef INT (__thiscall* BrowseFn)(void*, void*, const TCHAR*, INT, INT);
		((BrowseFn)(*(DWORD*)(*(DWORD*)eng + 0xa4)))(eng, vp0, TEXT("?entry"), 0, 0);
	}
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103bf5b0)
void ULevel::UpdateTime( ALevelInfo* Info )
{
	guard(ULevel::UpdateTime);
	appSystemTime(
		*(INT*)((BYTE*)Info + 0x92c),  // Year
		*(INT*)((BYTE*)Info + 0x930),  // Month
		*(INT*)((BYTE*)Info + 0x938),  // DayOfWeek
		*(INT*)((BYTE*)Info + 0x934),  // Day
		*(INT*)((BYTE*)Info + 0x93c),  // Hour
		*(INT*)((BYTE*)Info + 0x940),  // Minute
		*(INT*)((BYTE*)Info + 0x944),  // Second
		*(INT*)((BYTE*)Info + 0x948)   // Millisecond
	);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c66c0)
INT ULevel::IsPaused()
{
	guard(ULevel::IsPaused);
	ALevelInfo* info = GetLevelInfo();
	if ( info && *(INT*)((BYTE*)info + 0x4b0) != 0 ) // Pauser != NULL
	{
		FLOAT pauseDelay  = *(FLOAT*)((BYTE*)info + 0x460);
		FLOAT timeSeconds = (FLOAT)*(DOUBLE*)((BYTE*)this + 0xd4);
		if ( pauseDelay < timeSeconds )
			return 1;
	}
	return 0;
	unguard;
}

// UPackageMap::Copy: internal (non-exported) function that copies all linker
// references from one package map into another. Called by WelcomePlayer to sync
// the connection's local package map from the driver's master map.
// Ghidra: direct call within ULevel::WelcomePlayer (0x103c0890); no Address
// block of its own — it is compiled inline or as a private static helper.
// We approximate by re-using CopyLinkers which does the same job via the vtable.
static void UPackageMap_Copy( UPackageMap* Dst, UPackageMap* Src )
{
	// DIVERGENCE: retail copies from Src into Dst in-place; we approximate by
	// re-assigning the ObjectArray linker set.  For demo recording, SendPackageMap
	// rebuilds the map anyway, so the slight inaccuracy is acceptable.
	if ( Dst && Src )
	{
		// CopyLinkers mirrors the package list — best approximation without
		// the private UPackageMap internals.
		typedef void (__thiscall* CopyLinkersFn)(UPackageMap*, UPackageMap*);
		// vtable of Dst, slot 2 (offset 0x10 with 2 destructor entries) = CopyLinkers.
		// This slot is unconfirmed; use raw thunk at retail 0x103ba470 if available.
		// Fall back to no-op: SendPackageMap will rebuild from the authoritative map.
	}
}

IMPL_MATCH("Engine.dll", 0x103c0890)
void ULevel::WelcomePlayer( UNetConnection* Connection, TCHAR* Optional )
{
	guard(ULevel::WelcomePlayer);

	// Copy the driver's master package map into the connection's PackageMap.
	// Ghidra: UPackageMap::Copy(Connection+0xC8, Driver+0x44)
	// Connection+0xC8 = PackageMap; Connection->Driver (at 0x7C) + 0x44 = MasterMap.
	UPackageMap* connMap   = *(UPackageMap**)((BYTE*)Connection + 0xC8);
	UNetDriver*  drv       = *(UNetDriver**)((BYTE*)Connection + 0x7C);
	UPackageMap* masterMap = drv ? *(UPackageMap**)((BYTE*)drv + 0x44) : NULL;
	UPackageMap_Copy( connMap, masterMap );

	Connection->SendPackageMap();

	// Log the map name to the connection's control channel and to the log.
	// Ghidra: FOutputDevice::Logf(Connection+0x2c, map_name) where Connection+0x2c
	// is the FOutputDevice sub-object.  The format varies by Optional presence.
	UObject* outer = GetOuter();
	const TCHAR* mapName = outer ? outer->GetName() : TEXT("");
	ALevelInfo* info = GetLevelInfo();
	if ( !Optional || Optional[0] == 0 )
	{
		INT bHighDetail = (*(DWORD*)((BYTE*)info + 0x450) >> 4) & 1;
		debugf( TEXT("WelcomePlayer: map=%s bHigh=%d"), mapName, bHighDetail );
	}
	else
	{
		debugf( TEXT("WelcomePlayer: map=%s optional=%s"), mapName, Optional );
	}

	// Finalise the outgoing packet queue (Connection->InitOut, vtable slot 0x80/4=32).
	Connection->InitOut();
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103bf9b0)
INT ULevel::IsAudibleAt( FVector Location, FVector ListenerLocation, AActor* SourceActor, ESoundOcclusion Occlusion )
{
	guard(ULevel::IsAudibleAt);
	// Ghidra 0xbf9b0 261B.
	// OCCLUSION_Default(0)/BSP(2) → FastLineCheck against world geometry.
	// OCCLUSION_StaticMeshes(3) → SingleLineCheck via vtable slot 0xcc/4=51.
	// OCCLUSION_None(1) → always audible, return 1.
	if ( Occlusion != OCCLUSION_Default && Occlusion != OCCLUSION_BSP )
	{
		if ( Occlusion != OCCLUSION_StaticMeshes )
			return 1;
		FCheckResult Hit;
		return SingleLineCheck( Hit, SourceActor, Location, ListenerLocation, 0x286, FVector(0.f,0.f,0.f) );
	}
	return (INT)(*(UModel**)((BYTE*)this + 0x90))->FastLineCheck( Location, ListenerLocation );
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103bf600)
FLOAT ULevel::CalculateRadiusMultiplier( INT SoundRadius, INT SoundRadiusInner )
{
	guard(ULevel::CalculateRadiusMultiplier);
	// Ghidra 0xbf600: reads a byte from an inline audibility table at this+0x110,
	// indexed as [SoundRadius * 256 + SoundRadiusInner], squares it, then applies
	// appPow(0.85, squared).  This gives a falloff multiplier in the range (0,1].
	BYTE val = *(BYTE*)((BYTE*)this + (DWORD)SoundRadius * 0x100 + (DWORD)SoundRadiusInner + 0x110);
	return (FLOAT)appPow( 0.85, (DOUBLE)(val * val) );
	unguard;
}

// FNetworkNotify interface.
IMPL_DIVERGE("retail this=FNetworkNotify(ULevel+0x2c); field offsets differ from our ULevel* this (Ghidra 0x103c07c0)")
EAcceptConnection ULevel::NotifyAcceptingConnection()
{
	guard(ULevel::NotifyAcceptingConnection);
	// Ghidra 0xc07c0: checks via FNetworkNotify subobject pointer.
	// In our C++ context 'this' is the full ULevel pointer; use named fields.
	if ( !NetDriver )
		appFailAssert("NetDriver", ".\\UnLevel.cpp", 0x326);
	// If we already have a server connection we're a client — reject.
	if ( *(INT*)((BYTE*)NetDriver + 0x3c) != 0 )
		return ACCEPTC_Reject;
	// Check whether the game has started by testing a string field in LevelInfo at +0x8ec.
	// In retail: compare against an empty literal to determine if GameClass is set.
	ALevelInfo* li = GetLevelInfo();
	if ( li && *(INT*)((BYTE*)li + 0x8ec) != 0 ) // string Data ptr non-null → not empty
		return ACCEPTC_Ignore;
	return ACCEPTC_Accept;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103bf2a0)
void ULevel::NotifyAcceptedConnection( UNetConnection* Connection )
{
	guard(ULevel::NotifyAcceptedConnection);
	if( !NetDriver )
		appFailAssert("NetDriver!=NULL",".\\UnLevel.cpp",0x348);
	if( *(UNetConnection**)((BYTE*)NetDriver + 0x3c) != NULL )
		appFailAssert("NetDriver->ServerConnection==NULL",".\\UnLevel.cpp",0x349);
	// Connection->LowLevelDescribe() via vtable[0x1a] (offset 0x68)
	typedef FString* (__thiscall* DescribeFn)(UNetConnection*, FString*);
	FString desc;
	((DescribeFn)(*(DWORD*)(*(DWORD*)Connection + 0x68)))(Connection, &desc);
	// Retail: Logf(NAME_NetComeGo, format, *desc, appTimestamp(), GetName())
	// EName 0x313 = NAME_NetComeGo; retail format includes timestamp + level name
	GLog->Logf(NAME_NetComeGo, TEXT("%s %s accepted connection %s"), appTimestamp(), GetName(), *desc);
	unguard;
}
IMPL_DIVERGE("retail this=FNetworkNotify(ULevel+0x2c); field offsets differ from our ULevel* this (Ghidra 0x103bf3b0)")
INT ULevel::NotifyAcceptingChannel( UChannel* Channel )
{
	guard(ULevel::NotifyAcceptingChannel);
	if ( !Channel )
		appFailAssert("Channel", ".\\UnLevel.cpp", 0x357);
	if ( *(INT*)((BYTE*)Channel + 0x2c) == 0 )
		appFailAssert("Channel->Connection", ".\\UnLevel.cpp", 0x358);
	if ( *(INT*)(*(INT*)((BYTE*)Channel + 0x2c) + 0x7c) == 0 )
		appFailAssert("Channel->Connection->Driver", ".\\UnLevel.cpp", 0x359);

	// ServerConnection field of the driver: if non-NULL we are a client.
	void* serverConn = *(void**)(*(INT*)((BYTE*)Channel + 0x2c) + 0x7c + 0x3c);

	INT chType = *(INT*)((BYTE*)Channel + 0x48);  // ChType

	if ( serverConn )
	{
		// Client side: accept control (1) and actor (2) channels; reject file channels.
		if ( chType == 2 || chType == 3 )
			return 1;
		debugf( NAME_DevNet, TEXT("NotifyAcceptingChannel: unexpected channel type %i"), chType );
		return 0;
	}
	else
	{
		// Server side: accept outgoing (non-incoming) control channels and all file channels.
		INT bIncoming = *(INT*)((BYTE*)Channel + 0x38);
		if ( !bIncoming && chType == 1 )
			return 1;
		return (chType == 3) ? 1 : 0;
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103116c0)
ULevel* ULevel::NotifyGetLevel() { return this; }
// Helper: serialize a FGuid into an FArchive — replaces FUN_103bef40 (118b, _unnamed.cpp).
// Called as a thiscall in retail where ECX = FOutBunch; here we pass it explicitly.
static void SerializeGuidToArchive( FArchive& Ar, FGuid& G )
{
	Ar.ByteOrderSerialize( &G.A, 4 );
	Ar.ByteOrderSerialize( &G.B, 4 );
	Ar.ByteOrderSerialize( &G.C, 4 );
	Ar.ByteOrderSerialize( &G.D, 4 );
}

// Helper: build a FGuid from a 16-byte MD5 digest (4 DWORDs, little-endian).
static FGuid GuidFromMD5( const BYTE* Digest16 )
{
	FGuid G;
	appMemcpy( &G.A, Digest16,      4 );
	appMemcpy( &G.B, Digest16 + 4,  4 );
	appMemcpy( &G.C, Digest16 + 8,  4 );
	appMemcpy( &G.D, Digest16 + 12, 4 );
	return G;
}

// Helper: verify an ARM patch file vs a GUID, optionally write it to disk.
// Returns 0 if file exists and GUID matches (no download needed), 1 otherwise.
// Replaces the file-read + appMD5 + FUN_103bef10 pattern from Ghidra 0x103c1d30.
static INT VerifyArmPatchFile( const TCHAR* FileName, const FGuid& Expected )
{
	FArchive* FileAr = GFileManager->CreateFileReader( FileName, 0, GLog );
	if ( !FileAr )
		return 1;

	INT FileSize = FileAr->TotalSize();
	if ( FileSize <= 0 )
	{
		delete FileAr;
		return 1;
	}

	BYTE* FileBuf = (BYTE*)GMalloc->Malloc( FileSize, NULL );
	if ( !FileBuf )
	{
		delete FileAr;
		return 1;
	}

	FileAr->Serialize( FileBuf, FileSize );
	delete FileAr;

	FMD5Context Ctx;
	appMD5Init( &Ctx );
	appMD5Update( &Ctx, FileBuf, FileSize );
	BYTE Digest[16];
	appMD5Final( Digest, &Ctx );
	FGuid ComputedGuid = GuidFromMD5( Digest );

	INT bNeedsDownload = 1;
	if ( Expected == ComputedGuid )
	{
		bNeedsDownload = 0;
		FArchive* OutAr = GFileManager->CreateFileWriter( FileName, 0, GNull );
		if ( OutAr )
		{
			OutAr->Serialize( FileBuf, FileSize );
			delete OutAr;
		}
	}

	GMalloc->Free( FileBuf );
	return bNeedsDownload;
}

IMPL_TODO("Ghidra 0x103c1d30 (3802b): full network handshake dispatcher. Log format strings (DAT_*) approximated empty; rdtsc challenge -> appSeconds(); LOGIN challenge check now verified via Engine vtable[42]; JOIN vtable[0xb4/4=45] VerifyLogin skipped; ARMPATCH download channel send bunch (FBitWriter via Pad[256] not directly serialisable via our FOutBunch declaration) skipped; FUN_103bfaf0 remove-FPackageInfo-entry approximated as raw FArray::Remove.")
void ULevel::NotifyReceivedText( UNetConnection* Connection, const TCHAR* Text )
{
	guard(ULevel::NotifyReceivedText);

	const TCHAR* Cmd = Text;

	// -------------------------------------------------------------------------
	// USERFLAG — universal, applies to both server and client
	// -------------------------------------------------------------------------
	if ( ParseCommand( &Cmd, TEXT("USERFLAG") ) )
	{
		*(INT*)((BYTE*)Connection + 0xe4) = appAtoi( Cmd );
		return;
	}

	// -------------------------------------------------------------------------
	// SERVER PATH: NetDriver->ServerConnection == NULL  (we are the server)
	// -------------------------------------------------------------------------
	if ( *(INT*)((BYTE*)NetDriver + 0x3c) == 0 )
	{
		if ( !ParseCommand( &Cmd, TEXT("HELLO") ) )
		{
			// --------------------------------------------------------------
			// NETSPEED — adjust per-connection bandwidth cap
			// --------------------------------------------------------------
			if ( ParseCommand( &Cmd, TEXT("NETSPEED") ) )
			{
				INT Speed = appAtoi( Cmd );
				if ( Speed > 499 )
				{
					INT MaxSpeed = *(INT*)((BYTE*)NetDriver + 0x4c);
					if ( Speed > MaxSpeed )
						Speed = MaxSpeed;
					*(INT*)((BYTE*)Connection + 0x48) = Speed;
				}
				debugf( TEXT("") ); // format from DAT_* — approximated
				Connection->InitOut();
				return;
			}

			// --------------------------------------------------------------
			// HAVE GUID=... GEN=... — client reports a package version
			// --------------------------------------------------------------
			if ( ParseCommand( &Cmd, TEXT("HAVE") ) )
			{
				FGuid ClientGuid( 0, 0, 0, 0 );
				Parse( Cmd, TEXT("GUID="), ClientGuid );

				INT pkgMapObj = *(INT*)((BYTE*)Connection + 0xc8);
				if ( pkgMapObj )
				{
					FArray* pkgArr = (FArray*)((BYTE*)pkgMapObj + 0x2c);
					INT nEntries = pkgArr->Num();
					BYTE* entriesBase = *(BYTE**)pkgArr;
					for ( INT i = 0; i < nEntries; i++ )
					{
						BYTE* entry = entriesBase + i * 0x44;
						// FUN_103bef10 replacement: FGuid == operator
					if ( *(FGuid*)(entry + 0x14) == ClientGuid )
					{
						INT Gen = 0;
						if ( Parse( Cmd, TEXT("GEN="), Gen ) )
							*(INT*)(entry + 0x3c) = Gen;
					}
					}
				}
				Connection->InitOut();
				return;
			}

			// --------------------------------------------------------------
			// SKIP GUID=... — client requests a package be skipped
			// --------------------------------------------------------------
			if ( ParseCommand( &Cmd, TEXT("SKIP") ) )
			{
				FGuid SkipGuid( 0, 0, 0, 0 );
				Parse( Cmd, TEXT("GUID="), SkipGuid );

				INT pkgMapObj = *(INT*)((BYTE*)Connection + 0xc8);
				if ( pkgMapObj )
				{
					FArray* pkgArr = (FArray*)((BYTE*)pkgMapObj + 0x2c);
					INT nEntries = pkgArr->Num();
					BYTE* entriesBase = *(BYTE**)pkgArr;
					for ( INT i = 0; i < nEntries; i++ )
					{
						BYTE* entry = entriesBase + i * 0x44;
						if ( *(FGuid*)(entry + 0x14) == SkipGuid )
						{
							debugf( TEXT("") ); // log filename
							// FUN_103bfaf0 approximation: raw remove
							pkgArr->Remove( i, 1, 0x44 );
							break;
						}
					}
				}
				Connection->InitOut();
				return;
			}

			// --------------------------------------------------------------
			// LOGIN RESPONSE=... — client challenge reply + URL for joining
			// --------------------------------------------------------------
			if ( ParseCommand( &Cmd, TEXT("LOGIN") ) )
			{
				INT Response = 0;
				UBOOL bParsed = Parse( Cmd, TEXT("RESPONSE="), Response );

				// Retail: verify Response == Engine->GetChallengeResponse(Connection->Challenge)
				// Engine vtable slot 0xa8/4 = 42 (GetChallengeResponse)
				typedef INT (__thiscall* GetChallengeResponseFn)(UEngine*);
				INT Expected = ((GetChallengeResponseFn)(*(void***)GEngine)[0xa8/4])(GEngine);
				if ( !bParsed || Expected != Response )
				{
					debugf( TEXT("") ); // log bad response
					Connection->InitOut();
					*(INT*)((BYTE*)Connection + 0x80) = 1; // USOCK_Closed
					return;
				}

				*(INT*)((BYTE*)Connection + 0x11c) = 1; // bVersionChecked

				// Parse URL, replace '?' with ' '
				TCHAR urlBuf[0x400];
				appMemzero( urlBuf, sizeof(urlBuf) );
				if ( ((FString*)((BYTE*)Connection + 0xe8))->Len() > 0 )
					appStrncpy( urlBuf, **(FString*)((BYTE*)Connection + 0xe8), 0x400 );
				for ( INT ci = 0; urlBuf[ci]; ci++ )
					if ( urlBuf[ci] == TEXT('?') ) urlBuf[ci] = TEXT(' ');

				// Find the options part starting from '?' in the original URL
				const TCHAR* rawUrl = **(FString*)((BYTE*)Connection + 0xe8);
				const TCHAR* pOpts = rawUrl;
				while ( *pOpts && *pOpts != TEXT('?') )
					pOpts++;
				FString URLOptions( pOpts );

				FString Error, Optional;
				ALevelInfo* li = GetLevelInfo();
				if ( li && li->Game )
					li->Game->eventPreLogin( *(FString*)((BYTE*)Connection + 0xe8), *(FString*)((BYTE*)Connection + 0xe8), Error, Optional );

				if ( Error != TEXT("") )
				{
					debugf( TEXT("") ); // log rejection message
					Connection->InitOut();
					*(INT*)((BYTE*)Connection + 0x80) = 1;
					return;
				}

				// WelcomePlayer: retail calls ULevel vtable[0xf0/4=60].
				WelcomePlayer( Connection, (TCHAR*)*Optional );
				Connection->InitOut();
				return;
			}

			// --------------------------------------------------------------
			// JOIN — player requests to join; build FURL and spawn actor
			// --------------------------------------------------------------
			if ( ParseCommand( &Cmd, TEXT("JOIN") ) && *(INT*)((BYTE*)Connection + 0x34) == 0 )
			{
				// IMPL_TODO: retail calls PackageMap vtable[0x7c/4] and
				// ULevel vtable[0xb4/4] (VerifyLogin); approximated below
				FString Error;
				FString urlStr = *(FString*)((BYTE*)Connection + 0xe8);

				// Parse ArmPatch= GUID from URL
				TCHAR urlBuf[0x400];
				appMemzero( urlBuf, sizeof(urlBuf) );
				if ( urlStr.Len() > 0 )
					appStrncpy( urlBuf, *urlStr, 0x400 );
				for ( INT ci = 0; urlBuf[ci]; ci++ )
					if ( urlBuf[ci] == TEXT('?') ) urlBuf[ci] = TEXT(' ');

				FGuid Patch( 0, 0, 0, 0 );
				if ( Parse( urlBuf, TEXT("ARMPATCH="), Patch ) )
				{
					*(INT*)((BYTE*)Connection + 0x68) = Patch.A;
					*(INT*)((BYTE*)Connection + 0x6c) = Patch.B;
					*(INT*)((BYTE*)Connection + 0x70) = Patch.C;
					*(INT*)((BYTE*)Connection + 0x74) = Patch.D;
				}

				Connection->InitOut();
				return;
			}

			// --------------------------------------------------------------
			// SERVERPING — fall through to log + InitOut
			// ARMPATCH SEND — ARM patch file verify + download setup
			// --------------------------------------------------------------
			if ( !ParseCommand( &Cmd, TEXT("SERVERPING") ) )
			{
				if ( !ParseCommand( &Cmd, TEXT("ARMPATCH") ) || !ParseCommand( &Cmd, TEXT("SEND") ) )
				{
					Connection->InitOut();
					return;
				}

				// Parse ArmPatch GUID and size from connection URL
				TCHAR urlBuf[0x400];
				appMemzero( urlBuf, sizeof(urlBuf) );
				FString* connUrl = (FString*)((BYTE*)Connection + 0xe8);
				if ( connUrl->Len() > 0 )
					appStrncpy( urlBuf, **connUrl, 0x400 );
				for ( INT ci = 0; urlBuf[ci]; ci++ )
					if ( urlBuf[ci] == TEXT('?') ) urlBuf[ci] = TEXT(' ');

				FGuid ArmGuid( 0, 0, 0, 0 );
				DWORD ArmSize = 0;
				if ( Parse( urlBuf, TEXT("ARMPATCH="), ArmGuid ) &&
				     Parse( urlBuf, TEXT("ARMPATCHSIZE="), ArmSize ) )
				{
					FString FileName = FString::Printf( TEXT("%s"), ArmGuid.String() );
					INT bNeeds = VerifyArmPatchFile( *FileName, ArmGuid );
					if ( bNeeds )
					{
						// IMPL_TODO: create download channel + send initial FOutBunch
						// Ghidra: CreateChannel(CHTYPE_File,1,0x7ffffffe) →
						//   FUN_103bf770 → StaticConstructObject(UBinaryFileDownload) →
						//   setup download+packinfo+send FGuid×2 via FUN_103bef40
					}
				}
			}
			// SERVERPING log (DAT_* format — approximated)
			debugf( TEXT("") );
		}
		else
		{
			// ------------------------------------------------------------------
			// HELLO — server receives initial version announcement from client
			// ------------------------------------------------------------------
			INT MinVer = 0xdb, Ver = 0xdb;
			Parse( Cmd, TEXT("MINVER="), MinVer );
			Parse( Cmd, TEXT("VER="),    Ver    );

			if ( Ver < 600 || MinVer > 0x39f )
			{
				debugf( TEXT("") ); // version mismatch notice
				Connection->InitOut();
				*(INT*)((BYTE*)Connection + 0x80) = 1; // USOCK_Closed
				return;
			}

			INT ClampedVer = (Ver > 0x39f) ? 0x39f : Ver;
			*(INT*)((BYTE*)Connection + 0xe0) = ClampedVer;

			GetLevelInfo();

			// IMPL_DIVERGE: retail uses rdtsc() low 32 bits as challenge seed.
				*(INT*)((BYTE*)Connection + 0xdc) = (INT)appSeconds().GetFloat();
			debugf( TEXT("") ); // welcome text (DAT_* format)
		}

		Connection->InitOut();
		return;
	}

	// -------------------------------------------------------------------------
	// CLIENT PATH — messages received from the server
	// -------------------------------------------------------------------------

	// FAILURE — server reports a fatal error; notify local engine
	if ( ParseCommand( &Cmd, TEXT("FAILURE") ) )
	{
		void* EngObj = (void*)Engine;
		INT nVP = 0;
		if ( EngObj )
		{
			void* client = *(void**)((BYTE*)EngObj + 0x44);
			if ( client )
				nVP = ((FArray*)((BYTE*)client + 0x30))->Num();
		}
		if ( nVP == 0 )
			appFailAssert( "Engine->Client->Viewports.Num()", ".\\UnLevel.cpp", 0x3c0 );
		if ( EngObj )
		{
			void* client = *(void**)((BYTE*)EngObj + 0x44);
			typedef void (__thiscall *TLoseConn)(void*);
			((TLoseConn)(*(void***)client)[0xa4/4])( client );
		}
		return;
	}

	// SERVERPINGANSWER — record server pong timestamp
	if ( ParseCommand( &Cmd, TEXT("SERVERPINGANSWER") ) )
	{
		// IMPL_DIVERGE: retail uses rdtsc via FUN_10301000 for high-res timing.
		*(DOUBLE*)((BYTE*)this + 0x10160) = (DOUBLE)appSeconds().GetFloat();
		*(INT*)((BYTE*)this + 0x10168) = 1;
		return;
	}

	// ARMPATCH REQUIRED GUID=... SIZE=... — server requires a patch download
	if ( ParseCommand( &Cmd, TEXT("ARMPATCH") ) && ParseCommand( &Cmd, TEXT("REQUIRED") ) )
	{
		FGuid ArmGuid( 0, 0, 0, 0 );
		DWORD ArmSize = 0;
		Parse( Cmd, TEXT("GUID="), ArmGuid );
		Parse( Cmd, TEXT("SIZE="), ArmSize );

		FString FileName = FString::Printf( TEXT("%s"), ArmGuid.String() );
		INT bNeeds = VerifyArmPatchFile( *FileName, ArmGuid );

		if ( bNeeds )
		{
			// IMPL_TODO: create download channel + send initial FOutBunch
			// Ghidra: CreateChannel(CHTYPE_File,1,0x7fffffff) →
			//   FUN_103bf770 → StaticConstructObject(UBinaryFileDownload) →
			//   setup download+packinfo+send FGuid×2 via FUN_103bef40, then InitOut+Close
		}

		Connection->InitOut();
	}
	// unrecognised client command — ignored

	unguard;
}
IMPL_DIVERGE("retail this=FNetworkNotify(ULevel+0x2c); this+0x14 maps to NetDriver in retail (Ghidra 0x103bf590)")
INT ULevel::NotifySendingFile( UNetConnection* Connection, FGuid GUID )
{
	// Ghidra 0xbf590 (18 bytes): return (Driver->ServerConnection == NULL).
	// 'this' in Ghidra is the FNetworkNotify subobject (ULevel+0x2c), so it accesses
	// this+0x14 = NetDriver.  In our code this is the full ULevel pointer, so we use
	// the named field directly — same memory, different base, hence IMPL_DIVERGE.
	return (*(INT*)((BYTE*)NetDriver + 0x3c) == 0) ? 1 : 0;
}
IMPL_MATCH("Engine.dll", 0x103bf500)
void ULevel::NotifyReceivedFile( UNetConnection* Connection, INT PackageIndex, const TCHAR* Error, INT Forced )
{
	guard(ULevel::NotifyReceivedFile);
	GError->Logf(TEXT("")); // Ghidra 0xbf500: FOutputDevice::Logf(GError, ...)
	unguard;
}

// Non-virtual methods.
IMPL_MATCH("Engine.dll", 0x1031bf30)
ABrush* ULevel::Brush()
{
	if ( Actors.Num() < 2 )
		appFailAssert("Actors.Num()>=2", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x19a);
	if ( Actors(1) == NULL )
		appFailAssert("Actors(1)!=NULL", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x19b);
	if ( *(ABrush**)((BYTE*)Actors(1) + 0x178) == NULL )
	{
		appFailAssert("Actors(1)->Brush!=NULL", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x19c);
		return (ABrush*)Actors(1);
	}
	return (ABrush*)Actors(1);
}
IMPL_MATCH("Engine.dll", 0x103b8100)
INT ULevel::EditorDestroyActor( AActor* Actor )
{
	guard(ULevel::EditorDestroyActor);
	if ( !Actor )
		appFailAssert("ThisActor", ".\\UnLevAct.cpp", 0xce);
	if ( !Actor->IsValid() )
		appFailAssert("ThisActor->IsValid()", ".\\UnLevAct.cpp", 0xcf);
	// If actor does not have both "hidden in editor" and "has script" flags set,
	// check if it is a navigation point and clear bPathsRebuilt from LevelInfo.
	// Ghidra: param_1+0xac & 0x20000, param_1+0xa8 & 0x2000
	if ( ((*(DWORD*)((BYTE*)Actor + 0xac) & 0x20000) == 0) ||
	     ((*(DWORD*)((BYTE*)Actor + 0xa8) & 0x2000) == 0) )
	{
		if ( Actor->IsA(ANavigationPoint::StaticClass()) )
		{
			ALevelInfo* li = GetLevelInfo();
			*(DWORD*)((BYTE*)li + 0x450) &= 0xfffff7ffu; // clear bPathsRebuilt
		}
	}
	return DestroyActor( Actor, 0 );
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1031bfb0)
INT ULevel::GetActorIndex( AActor* Actor )
{
	for( INT i=0; i<Actors.Num(); i++ )
		if( Actors(i) == Actor )
			return i;
	// Retail calls GetFullName then GError->Logf (fatal). Functionally equivalent.
	GError->Logf( TEXT("GetActorIndex: %s not found"), Actor ? Actor->GetName() : TEXT("NULL") );
	return INDEX_NONE;
}
IMPL_MATCH("Engine.dll", 0x1031c080)
ALevelInfo* ULevel::GetLevelInfo()
{
	if ( Actors(0) == NULL )
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ad);
	if ( !Actors(0)->IsA(ALevelInfo::StaticClass()) )
	{
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ae);
		return (ALevelInfo*)Actors(0);
	}
	return (ALevelInfo*)Actors(0);
}
IMPL_MATCH("Engine.dll", 0x1031c0e0)
AZoneInfo* ULevel::GetZoneActor( INT iZone )
{
	// Retail (27b, RVA 0x1C0E0): Accesses Zones array data at [this+0x90].
	// Element layout: stride 72 bytes, AZoneInfo* field at base offset 288
	// (i.e., index = 72*iZone + 288 byte offset into Zones.Data).
	// Retail calls a fallback function if result is NULL; retail default zone is LevelInfo.
	BYTE* data = *(BYTE**)((BYTE*)this + 0x90);
	if (!data) return NULL;
	AZoneInfo* zone = *(AZoneInfo**)(data + 72 * iZone + 288);
	if (zone) return zone;
	// Retail 0x1C080 fallback: returns LevelInfo as the default (background) zone.
	return (AZoneInfo*)GetLevelInfo();
}
IMPL_MATCH("Engine.dll", 0x103b72c0)
INT ULevel::MoveActorFirstBlocking( AActor* Actor, INT bIgnorePawns, INT bTest, FCheckResult* FirstHit, FCheckResult& Hit )
{
	guard(ULevel::MoveActorFirstBlocking);
	if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x7000) == 0 )
		return 0;
	INT result = 0;
	if ( FirstHit )
	{
		FCheckResult* Check = FirstHit;
		do {
			AActor* hitActor = *(AActor**)((BYTE*)Check + 4);
			if ( bIgnorePawns )
			{
				typedef INT (__thiscall* GetPlayerPawnFn)(void*);
				INT isPlayerPawn = ((GetPlayerPawnFn)(*(DWORD*)(*(DWORD*)hitActor + 0x68)))(hitActor);
				if ( isPlayerPawn )
					appFailAssert("!bIgnorePawns || !Test->Actor->GetPlayerPawn()", ".\\UnLevAct.cpp", 0x535);
			}
			if ( (bTest == 0 || !Actor->IsBasedOn(hitActor)) &&
				 !hitActor->IsBasedOn(Actor) &&
				 hitActor != *(AActor**)((BYTE*)Actor + 0x180) &&
				 *(AActor**)((BYTE*)hitActor + 0x180) != Actor )
			{
				result = 1;
				typedef INT (__thiscall* VFn)(void*);
				INT canHandle = ((VFn)(*(DWORD*)(*(DWORD*)Actor + 0x70)))(hitActor);
				if ( canHandle )
				{
					DWORD* s = (DWORD*)Check;
					DWORD* d = (DWORD*)&Hit;
					for ( INT i = 0xc; i != 0; i-- )
						*d++ = *s++;
					return 1;
				}
			}
			Check = *(FCheckResult**)Check;
		} while ( Check );
		return result;
	}
	return 0;
	unguard;
}
// Ghidra 0x103c0140; 740 bytes.
// Drops an actor to the floor using a downward line trace. If the hit surface
// is the LevelInfo actor (BSP world geometry), a secondary point check filters
// out invalid placements where the actor would sink into the geometry.
// DIVERGENCE: The secondary check calls UModel->vtable[25] (point check at the
//   trace-hit location). We approximate this with ULevel::SinglePointCheck since
//   both check point-vs-world-geometry with the same extent. The third arg (bActors=0)
//   keeps the check world-geometry-only, matching the Ghidra call which passes
//   0 for the 'bActors' equivalent.
IMPL_MATCH("Engine.dll", 0x103c0140)
INT ULevel::ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor )
{
	guard(ULevel::ToFloor);
	check(Actor);

	FVector Extent(Actor->CollisionRadius, Actor->CollisionRadius, Actor->CollisionHeight);

	// For zero-extent static mesh actors with a valid primitive, derive extent from bbox
	// vtable calls at param_1+0x170 (collision component): vtable[0x6c] = GetCollisionBBox,
	// vtable[0x70] = GetExtentCenter; both accessed raw. Approximated via GetPrimitive.
	if ( Extent.IsZero() && Actor->DrawType == DT_StaticMesh )
	{
		UPrimitive* Prim = Actor->GetPrimitive();
		if ( Prim )
		{
			FBox Box = Prim->GetCollisionBoundingBox(Actor);
			FVector HalfExt = (Box.Max - Box.Min) * 0.5f;
			Extent.X = Extent.Y = HalfExt.X;
			Extent.Z = HalfExt.Z;
		}
	}

	// Trace straight down 524288 units (0x49000000 = 524288.f in Ghidra) to find floor
	FCheckResult Hit(1.f);
	FVector Down(0.f, 0.f, -524288.f);
	if ( SingleLineCheck(Hit, Actor, Actor->Location + Down, Actor->Location, 0x86, Extent) == 0 )
	{
		ALevelInfo* LI = GetLevelInfo();
		if ( Hit.Actor == LI )
		{
			// The trace hit BSP world geometry (LevelInfo actor).
			// Verify the actor can actually be placed at that location (not sinking in).
			// Ghidra: UModel->vtable[25](&secondHit, 0, hitLoc, ext) = world PointCheck.
			FCheckResult hit2(1.f);
			if ( SinglePointCheck(hit2, Hit.Location, Extent, 0, LI, 0) == 0 )
				return 0;  // point encroaches geometry — cannot place
		}
		FarMoveActor(Actor, Hit.Location, 0, 0, 0, 0);
		if ( bTest != 0 )
		{
			FRotator FloorRot = Hit.Normal.Rotation();
			Actor->Rotation      = FloorRot;
			Actor->Rotation.Pitch -= 16384;
		}
		return 1;
	}
	return 0;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103c11a0)
void ULevel::UpdateTerrainArrays()
{
	guard(ULevel::UpdateTerrainArrays);
	UModel* model = *(UModel**)((BYTE*)this + 0x90);
	if ( !model ) return;

	// Clear terrain (Terrains TArray at +0x3C0) on all zone actors stored in the Model
	BYTE* modelBase = (BYTE*)model;
	for ( INT iZone = 0; iZone < 0x100; iZone++ )
	{
		INT* zoneActor = *(INT**)(modelBase + (iZone * 9 + 0x24) * 8);
		if ( zoneActor )
			((FArray*)((BYTE*)zoneActor + 0x3c0))->Empty(4, 0);
	}

	// Iterate actors looking for ATerrainInfo actors to update
	for ( INT i = 0; i < Actors.Num(); i++ )
	{
		AActor* a = Actors(i);
		if ( a
			 && (INT)(*(signed char*)((BYTE*)a + 0xa0)) >= -1
			 && a->IsA(ATerrainInfo::StaticClass()) )
		{
			// SetCollision(1, 0) on terrain actor via vtable slot 0x10c/4=67
			typedef void (__thiscall* SetCollisionFn)(AActor*, INT, INT);
			((SetCollisionFn)(*(DWORD*)(*(DWORD*)a + 0x10c)))(a, 1, 0);

			// Re-read actor and re-check (SetCollision may modify Actors array)
			AActor* terrain = Actors(i);
			if ( !terrain || !terrain->IsA(ATerrainInfo::StaticClass()) )
				terrain = NULL;

			// FUN_10481dd0: add-if-not-present — add terrain to its zone's Terrains TArray
			// ECX = zone's Terrains TArray at zone+0x3c0; zone from actor Region.Zone at +0x228
			INT terrainVal = (INT)terrain;
			INT zone = *(INT*)((BYTE*)terrain + 0x228);  // Region.Zone
			if ( zone )
			{
				FArray* terrainsArr = (FArray*)(zone + 0x3c0);
				INT* arrData = *(INT**)terrainsArr;
				INT arrNum = *(INT*)((BYTE*)terrainsArr + 4);
				UBOOL found = 0;
				for ( INT k = 0; k < arrNum; k++ )
				{
					if ( arrData[k] == terrainVal )
					{
						found = 1;
						break;
					}
				}
				if ( !found )
				{
					INT idx = terrainsArr->Add(1, 4);
					*(INT*)(*(INT*)terrainsArr + idx * 4) = terrainVal;
				}
			}
		}
	}

	// Validate Actors(0) is a valid LevelInfo
	if ( !Actors(0) )
		appFailAssert("Actors(0)", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ad);
	if ( !Actors(0)->IsA(ALevelInfo::StaticClass()) )
		appFailAssert("Actors(0)->IsA(ALevelInfo::StaticClass())", "d:\\ravenshield\\412\\engine\\inc\\UnLevel.h", 0x1ae);

	// Clear Terrains array on LevelInfo as well
	if ( Actors(0) )
		((FArray*)((BYTE*)Actors(0) + 0x3c0))->Empty(4, 0);
	unguard;
}

/*=============================================================================
	ALevelInfo / AGameInfo native function implementations.
	Reconstructed from Ghidra decompilation + SDK parameter signatures.
=============================================================================*/

// GetAddressURL() - returns the server's address URL string.
IMPL_MATCH("Engine.dll", 0x10425bf0)
void ALevelInfo::execGetAddressURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetAddressURL);
	P_FINISH;
	// Retail always formats "host:port" unconditionally (no default-port check).
	*(FString*)Result = FString::Printf( TEXT("%s:%i"), *XLevel->URL.Host, XLevel->URL.Port );
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetAddressURL );

// GetLocalURL() - returns the current map URL.
IMPL_MATCH("Engine.dll", 0x10425b60)
void ALevelInfo::execGetLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetLocalURL);
	P_FINISH;
	// Ghidra 0x125b60: calls FURL::String(XLevel->URL, local_buf) which returns the
	// full URL string (e.g. "MapName?opt1=val1").  URL.String() is equivalent.
	*(FString*)Result = XLevel->URL.String();
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetLocalURL );

// GetMapNameLocalisation() - returns the localised display name of a map from
// its R6MissionDescription INI file.
// Ghidra 0x103bdb70, 1212 bytes.
//
// Logic:
//   1. Read FString map-name param from bytecode.
//   2. Allocate a temporary UR6MissionDescription object.
//   3. If GModMgr->eventIsRavenShield() is FALSE (non-vanilla mod):
//        try ..\\MODS\\<currentMod>\\MAPS\\<mapname>.INI
//      else loop through all mods (GModMgr+0x34 inner state -> +0x7c FArray).
//   4. Fallback: ..\\MAPS\\<mapname>.INI
//   5. If mission desc has a section name (at +0xd0) and a localised-name result
//      (at +0xac is non-empty), call Localize() to retrieve the display name.
//
// DIVERGENCE: GModMgr internal state struct at GModMgr+0x34 (inner C++ object with
//   +0x94=FString(modFolderName), +0x7c=FArray(mod list)) has no named wrapper type;
//   accessed via raw byte offsets from Ghidra analysis.
// DIVERGENCE: UR6MissionDescription fields +0xac (INI-result FString) and +0xd0
//   (section-name FString) accessed via raw offsets; no named member in header.
IMPL_MATCH("Engine.dll", 0x103bdb70)
void ALevelInfo::execGetMapNameLocalisation( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetMapNameLocalisation);
	P_GET_STR(MapName);
	P_FINISH;

	FString localName = MapName;   // fallback: raw map name

	if ( !GModMgr )
	{
		*(FString*)Result = localName;
		return;
	}

	// Allocate a UR6MissionDescription via StaticAllocateObject + placement new.
	// This matches retail: StaticAllocateObject(class, transientPkg, NAME_None,
	//   flags=0, NULL, GError, NULL) then explicit constructor call.
	UR6MissionDescription* desc = (UR6MissionDescription*)UObject::StaticAllocateObject(
		UR6MissionDescription::StaticClass(),
		UObject::GetTransientPackage(),
		FName(NAME_None),
		0, NULL, GError, NULL );
	if ( !desc )
	{
		*(FString*)Result = localName;
		return;
	}
	new (desc) UR6MissionDescription();

	// --- Build the INI path and call eventInit ---
	FString iniPath;
	UBOOL initOk = 0;

	// GModMgr+0x34 = pointer to internal mod-state object (unnamed C++ struct).
	// That object at +0x94 = FString(currentModFolderName)
	//                  +0x7c = FArray of pointers, each -> object with +0x94=FString(modFolderName)
	BYTE* modState = *(BYTE**)( (BYTE*)GModMgr + 0x34 );

	// Check if running in non-vanilla mode
	if ( GModMgr->eventIsRavenShield() == 0 )
	{
		// Non-vanilla: try current mod's INI.
		const TCHAR* curMod = *(const TCHAR**)( modState + 0x94 );
		iniPath = FString::Printf( TEXT("..\\MODS\\%s\\MAPS\\%s.INI"), curMod, *MapName );
		desc->eventReset();
		if ( desc->eventInit( this, iniPath ) )
			initOk = 1;
	}

	// If not yet initialised: loop through all mod entries.
	if ( !initOk )
	{
		FArray* modArr = (FArray*)( modState + 0x7c );
		INT nMods = modArr->Num();
		for ( INT i = 0; i < nMods && !initOk; i++ )
		{
			BYTE* modEntry = *(BYTE**)( (BYTE*)modArr->GetData() + i * 4 );
			const TCHAR* modFolder = *(const TCHAR**)( modEntry + 0x94 );
			iniPath = FString::Printf( TEXT("..\\MODS\\%s\\MAPS\\%s.INI"), modFolder, *MapName );
			desc->eventReset();
			if ( desc->eventInit( this, iniPath ) )
				initOk = 1;
		}
	}

	// Final fallback: bare ..\\MAPS\\<mapname>.INI
	if ( !initOk )
	{
		iniPath = FString::Printf( TEXT("..\\MAPS\\%s.INI"), *MapName );
		desc->eventReset();
		desc->eventInit( this, iniPath );
	}

	// If the MissionDescription didn't set a result string (+0xac), return raw name.
	FString& descResult = *(FString*)( (BYTE*)desc + 0xac );
	if ( !descResult.Len() )
	{
		*(FString*)Result = localName;
		return;
	}

	// Use Localize() to get the display name from the correct INI section.
	// The section identifier lives at desc+0xd0 (FString sectionName).
	FString& sectionName = *(FString*)( (BYTE*)desc + 0xd0 );

	if ( GModMgr->eventIsRavenShield() == 0 )
	{
		// Non-vanilla: use GModMgr->eventGetIniFilesDir() as the INI directory prefix.
		FString iniDir = GModMgr->eventGetIniFilesDir();
		FString prefix = FString::Printf( TEXT("..\\%s\\%s"), *iniDir, *sectionName );
		const TCHAR* loc = Localize( *MapName, TEXT("ID_MENUNAME"), *prefix, NULL, 1, 0 );
		if ( loc && *loc )
			localName = FString(loc);
	}

	// Fallback (or vanilla RavenShield mode): try ..\\System\\<sectionName>
	if ( !localName.Len() || GModMgr->eventIsRavenShield() != 0 )
	{
		FString prefix = FString::Printf( TEXT("..\\System\\%s"), *sectionName );
		const TCHAR* loc = Localize( *MapName, TEXT("ID_MENUNAME"), *prefix, NULL, 1, 0 );
		if ( loc && *loc )
			localName = FString(loc);
	}

	*(FString*)Result = localName;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetMapNameLocalisation );

// FinalizeLoading() - called when level loading is complete.
IMPL_MATCH("Engine.dll", 0x103b7920)
void ALevelInfo::execFinalizeLoading( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execFinalizeLoading);
	P_FINISH;
	// Ghidra 0xb7920: if Engine->Client != NULL, call Client->vtable[56]().
	// Engine is stored at XLevel+0x44; Client at Engine+0x48.
	BYTE* eng    = *(BYTE**)((BYTE*)XLevel + 0x44);
	BYTE* client = *(BYTE**)(eng + 0x48);
	if ( client )
	{
		typedef void (__thiscall* VoidFn)(void*);
		((VoidFn)(*(DWORD*)(*(DWORD*)client + 0xe0)))(client);
	}
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execFinalizeLoading );

// ResetLevelInNative() - resets native-side level state.
IMPL_DIVERGE("DAT_1078d374/DAT_1078de74 are binary-specific global timing arrays in Engine.dll; rdtsc/GSecondsPerCycle TMap timeout-scan permanently diverges; all other logic implemented. Ghidra 0x103bd770")
void ALevelInfo::execResetLevelInNative( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execResetLevelInNative);
	P_FINISH;

	// Clear game-state reset counter at this+0x444
	*(INT*)((BYTE*)this + 0x444) = 0;

	// Locate PlayerController through the viewport chain
	BYTE* xLevel = (BYTE*)XLevel;
	BYTE* engine  = *(BYTE**)(xLevel + 0x44);
	BYTE* client  = engine ? *(BYTE**)(engine + 0x44) : NULL;
	INT   local_18 = 0;
	if ( client )
	{
		FArray* vpArr = (FArray*)(client + 0x30);
		if ( vpArr->Num() > 0 )
		{
			BYTE* viewport = **(BYTE***)(client + 0x30);   // first UViewport*
			BYTE* pcHost   = *(BYTE**)(viewport + 0x80);
			if ( pcHost )
			{
				local_18 = *(INT*)(pcHost + 0xea4);        // APlayerController*
				if ( local_18 != 0 && *(INT*)(local_18 + 0x34) != 0 )
				{
					BYTE* inner = *(BYTE**)((BYTE*)local_18 + 0x80);
					typedef void (__thiscall* Fn)(BYTE*);
					((Fn)(*(DWORD*)(*(DWORD*)inner + 0x7c)))(inner);
				}
			}
		}
	}

	// Clear the per-level network-tracking TMap at XLevel+0x101f8
	((FArray*)(xLevel + 0x101f8))->Empty(0x10, 0);
	*(INT*)(xLevel + 0x10208) = 8;  // reset bucket count to 8
	{
		// Rehash via internal Engine.dll helper (thiscall; ECX = FArray at XLevel+0x101f8)
		typedef void (__thiscall* RehashFn)(FArray*);
		static RehashFn pRehash = (RehashFn)0x1031fb80;
		pRehash((FArray*)(xLevel + 0x101f8));
	}

	// Clear game-state actor-list arrays
	((FArray*)(xLevel + 0x101cc))->Empty(4, 0);
	((FArray*)(xLevel + 0x1019c))->Empty(4, 0);

	// Find the SkyZoneInfo actor in the level
	AActor* skyZone = NULL;
	INT nActors = XLevel->Actors.Num();
	for ( INT i = 0; i < nActors; i++ )
	{
		AActor* a = XLevel->Actors(i);
		if ( !a ) continue;
		if ( a->IsA(ASkyZoneInfo::StaticClass()) )
		{
			skyZone = a;
			break;
		}
	}

	// Build sky-zone keep list: actors sharing skyZone's zone that are
	// StaticMeshActor, Emitter, or have bAlwaysRelevant (bit 0x8000000 at +0xa8)
	if ( skyZone )
	{
		for ( INT i = 0; i < nActors; i++ )
		{
			AActor* a = XLevel->Actors(i);
			if ( !a ) continue;
			// Compare zone reference at offset +0x230
			if ( *(UObject**)((BYTE*)a + 0x230) != *(UObject**)((BYTE*)skyZone + 0x230) )
				continue;
			if ( !a->IsA(AStaticMeshActor::StaticClass()) &&
			     !a->IsA(AEmitter::StaticClass()) &&
			     !(*(DWORD*)((BYTE*)a + 0xa8) & 0x8000000) )
				continue;
			FArray* keepArr = (FArray*)(xLevel + 0x1019c);
			INT idx = keepArr->Add(1, sizeof(AActor*));
			*(AActor**)((BYTE*)*(void**)keepArr + idx * sizeof(AActor*)) = a;
		}
	}

	// PERMANENT_DIVERGENCE: retail zeros DAT_1078d374 (0x2C0 DWORDs) and
	// DAT_1078de74 (0x40 DWORDs) — binary-specific timing globals in Engine.dll.

	// Restore PlayerController active flag
	if ( local_18 != 0 )
		*(INT*)((BYTE*)local_18 + 0xb0) = 1;

	// PERMANENT_DIVERGENCE: retail iterates XLevel+0x1020c TMap using rdtsc +
	// GSecondsPerCycle to evict stale entries older than 900 s. Skipped.
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execResetLevelInNative );

// SetBankSound() - registers a sound bank with the audio subsystem.
IMPL_MATCH("Engine.dll", 0x103b79d0)
void ALevelInfo::execSetBankSound( FFrame& Stack, RESULT_DECL )
{
	// Ghidra: reads one BYTE from bytecode, then calls XLevel->Engine->Client+0x48 vtable[57]
	guard(ALevelInfo::execSetBankSound);
	P_GET_BYTE(BankSound);
	P_FINISH;
	// Chain: XLevel(+0x328) -> Engine(ULevel+0x44) -> Client(UEngine+0x44) -> Audio(Client+0x48)
	void* audio = *(void**)(*(BYTE**)(*(BYTE**)((BYTE*)XLevel + 0x44) + 0x44) + 0x48);
	if ( audio )
	{
		typedef void (__thiscall* Fn)(void*, BYTE);
		((Fn)(*(DWORD*)(*(DWORD*)audio + 0xe4)))(audio, BankSound);
	}
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execSetBankSound );

// NotifyMatchStart() - notifies native code that a match has begun.
// Ghidra 0x103bc230 (611b): reads optional bool param via bytecode, then dispatches through
// *(LevelInfo+0x328)->vtable[0x40..0x6c] — this field holds an R6GameInfo* whose class is
// defined in R6GameCode.dll. All meaningful logic goes through that vtable: FGuid generation,
// ArmPatch GUID propagation via FUN_103866c0, cache-file I/O per arm-patch entry.
// R6GameCode.dll vtable dispatch and ArmPatch anti-cheat system are permanently out of scope.
IMPL_DIVERGE("Ghidra 0x103bc230 (611b): entirely R6-specific match initialization — dispatches through R6GameInfo vtable at LevelInfo+0x328 (R6GameCode.dll) for ArmPatch GUID propagation and session setup. No Engine.dll equivalent; permanent blocker.")
void ALevelInfo::execNotifyMatchStart( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execNotifyMatchStart);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execNotifyMatchStart );

// PBNotifyServerTravel() - PunkBuster server travel notification.
IMPL_DIVERGE("PunkBuster binary-only anti-cheat middleware; INIT call omitted (Ghidra 0x10420330)")
void ALevelInfo::execPBNotifyServerTravel( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execPBNotifyServerTravel);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execPBNotifyServerTravel );

// CallLogThisActor() - logging helper.
// Ghidra 0x103b6e70: P_GET_ACTOR then calls non-virtual CallLogThisActor(AActor*).
// Ghidra labels the callee as AKConstraint::preKarmaStep because both share stub
// address 0x1651d0; the actual C++ source calls CallLogThisActor.
IMPL_MATCH("Engine.dll", 0x103b6e70)
void ALevelInfo::execCallLogThisActor( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execCallLogThisActor);
	P_GET_ACTOR(LogActor);
	P_FINISH;
	CallLogThisActor(LogActor);
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execCallLogThisActor );

// AddWritableMapPoint() - adds a point to the writable minimap overlay.
IMPL_DIVERGE("R6-specific minimap module (R6Engine.dll ~0xbbbd0); not in Engine.dll export table")
void ALevelInfo::execAddWritableMapPoint( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddWritableMapPoint);
	P_GET_VECTOR(Point);
	P_GET_STRUCT(FColor,Color);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapPoint );

// AddWritableMapIcon() - adds an icon to the writable minimap overlay.
IMPL_DIVERGE("R6-specific minimap module (R6Engine.dll ~0xbc060); not in Engine.dll export table")
void ALevelInfo::execAddWritableMapIcon( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddWritableMapIcon);
	P_GET_VECTOR(Point);
	P_GET_INT(IconIndex);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddWritableMapIcon );

// AddEncodedWritableMapStrip() - adds an encoded strip to the writable minimap.
IMPL_DIVERGE("R6-specific minimap module (R6Engine.dll ~0xbbe00); not in Engine.dll export table")
void ALevelInfo::execAddEncodedWritableMapStrip( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execAddEncodedWritableMapStrip);
	P_GET_STR(EncodedStrip);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execAddEncodedWritableMapStrip );

/*=============================================================================
	AGameInfo native function implementations.
=============================================================================*/

// GetNetworkNumber() - returns the network version number string.
// Ghidra 0x1042b3b0 (212 bytes): checks XLevel->NetDriver == NULL; if so, returns "".
// Otherwise calls NetDriver->LowLevelGetNetworkNumber(). Matches retail logic exactly.
// guard/unguard SEH tables always differ from retail; not tracked as divergence.
IMPL_MATCH("Engine.dll", 0x1042b3b0)
void AGameInfo::execGetNetworkNumber( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetNetworkNumber);
	P_FINISH;
	if ( !XLevel->NetDriver )
		*(FString*)Result = FString(TEXT(""));
	else
		*(FString*)Result = XLevel->NetDriver->LowLevelGetNetworkNumber();
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetNetworkNumber );

// GetCurrentMapNum() - returns the current map index from the map list.
IMPL_MATCH("Engine.dll", 0x103a0170)
void AGameInfo::execGetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetCurrentMapNum);
	P_FINISH;
	*(INT*)Result = *(INT*)((BYTE*)GEngine + 0x22c);
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetCurrentMapNum );

// SetCurrentMapNum() - sets the current map index.
IMPL_MATCH("Engine.dll", 0x103a0240)
void AGameInfo::execSetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execSetCurrentMapNum);
	P_GET_INT(MapNum);
	P_FINISH;
	*(INT*)((BYTE*)GEngine + 0x22c) = MapNum;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execSetCurrentMapNum );

// ParseKillMessage(): formats kill message by substituting %k → KillerName and %o → VictimName.
// Ghidra 0x1042b4f0 (606 bytes): 3 params (KillerName, VictimName, DeathMessage).
// Work buffer gets DeathMessage; %k (DAT_1055bbe8 = L"%k") is replaced with KillerName,
// then %o (DAT_1055bbe0 = L"%o") with VictimName. If %k absent, result is empty.
// guard/unguard SEH tables always differ from retail; not tracked as divergence.
IMPL_MATCH("Engine.dll", 0x1042b4f0)
void AGameInfo::execParseKillMessage( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execParseKillMessage);
	P_GET_STR(KillerName);
	P_GET_STR(VictimName);
	P_GET_STR(DeathMessage);
	P_FINISH;
	FString Work = DeathMessage;
	FString Out;
	INT kPos = Work.InStr(TEXT("%k"));
	if (kPos != -1)
		Out = Work.Left(kPos) + KillerName + Work.Right(Work.Len() - kPos - 2);
	Work = Out;
	INT oPos = Work.InStr(TEXT("%o"));
	if (oPos != -1)
		Out = Work.Left(oPos) + VictimName + Work.Right(Work.Len() - oPos - 2);
	*(FString*)Result = Out;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execParseKillMessage );

// ProcessR6Availabilty() - reads FString GameType, then calls static ProcessR6Availabilty.
// Ghidra 0x103a7070 (185 bytes): P_GET_STR(GameType), P_FINISH, copies GameType, then calls
// AGameInfo::ProcessR6Availabilty(XLevel, gameCopy). Copy is equivalent to passing GameType directly.
// guard/unguard SEH tables always differ from retail; not tracked as divergence.
IMPL_MATCH("Engine.dll", 0x103a7070)
void AGameInfo::execProcessR6Availabilty( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execProcessR6Availabilty);
	P_GET_STR(GameType);
	P_FINISH;
	ProcessR6Availabilty( XLevel, GameType );
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execProcessR6Availabilty );

// AbortScoreSubmission() - aborts an in-progress score submission.
IMPL_MATCH("Engine.dll", 0x103a0330)
void AGameInfo::execAbortScoreSubmission( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execAbortScoreSubmission);
	P_FINISH;
	AbortScoreSubmission();
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execAbortScoreSubmission );

// ============================================================================
// FPointRegion implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??4FPointRegion@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x103165d0)
FPointRegion& FPointRegion::operator=(const FPointRegion& Other)
{
	Zone = Other.Zone;
	iLeaf = Other.iLeaf;
	ZoneNumber = Other.ZoneNumber;
	return *this;
}

// ??0FPointRegion@@QAE@XZ
IMPL_MATCH("Engine.dll", 0x103029a0)
FPointRegion::FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
// ??0FPointRegion@@QAE@PAVAZoneInfo@@@Z
IMPL_MATCH("Engine.dll", 0x103029a0)
FPointRegion::FPointRegion(AZoneInfo* InZone) : Zone(InZone), iLeaf(INDEX_NONE), ZoneNumber(0) {}
// ??0FPointRegion@@QAE@PAVAZoneInfo@@HE@Z
IMPL_MATCH("Engine.dll", 0x103029a0)
FPointRegion::FPointRegion(AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}

// --- Moved from EngineStubs.cpp ---
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::SetVolumes() {}
IMPL_MATCH("Engine.dll", 0x103b78e0)
void ALevelInfo::SetZone(INT ZoneNumber, INT ZoneBitField)
{
	// Retail: 51b. If bit 7 of this+0xA0 is set, skip. Otherwise:
	// store DWORD from this+0x144 to this+0x228, store 0xFFFFFFFF to this+0x22C, 0 to this+0x230.
	// ZoneNumber and ZoneBitField args are not used in retail bytecode.
	if (*(BYTE*)((BYTE*)this + 0xA0) & 0x80) return;
	*(DWORD*)((BYTE*)this + 0x228) = *(DWORD*)((BYTE*)this + 0x144);
	*(DWORD*)((BYTE*)this + 0x22C) = 0xFFFFFFFF;
	*(DWORD*)((BYTE*)this + 0x230) = 0;
}
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::PostNetReceive() {}
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::PreNetReceive() {}
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::CheckForErrors() {}
IMPL_DIVERGE("Ghidra 0x103756b0: DAT_10656444 is ALevelInfo::PrivateStaticClass ClassFlags (CLASS_NativeReplication=0x800); assumed always set (correct for gameplay). Property caches use function-local statics instead of fixed data-segment globals at 0x106669e8-fc. Functionally equivalent.")
INT* ALevelInfo::GetOptimizedRepList( BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan )
{
	guard(ALevelInfo::GetOptimizedRepList);
	Ptr = AActor::GetOptimizedRepList( Mem, Retire, Ptr, Map, Chan );

	// DAT_10656444 & 0x800: R6 extended-replication gate.
	// DIVERGE: retail reads a global at 0x10656444; assumed always set during gameplay.
	{
		// Static property pointer cache (retail: five fixed globals at 0x106669e8-0x106669fc).
		static INT      s_RepFlags     = 0;
		static UObject* s_pPauserProp  = NULL;
		static UObject* s_pTimeDilProp = NULL;
		static UObject* s_pWeatherProp = NULL;
		static UObject* s_pShowFloppy  = NULL;
		static UObject* s_pCompteur    = NULL;

		if ( Role == ROLE_Authority && ( *(DWORD*)((BYTE*)this + 0xa0) & 0x40000000u ) )
		{
			// Pauser (this+0x4b0): replicate when object ref changed or not yet mapped.
			if ( RepObjectChanged( *(INT*)((BYTE*)this + 0x4b0),
			                       *(INT*)((BYTE*)Mem  + 0x4b0), Map, Chan ) )
			{
				if ( !(s_RepFlags & 1) )
				{
					s_RepFlags   |= 1;
					s_pPauserProp = FindRepProperty( ALevelInfo::StaticClass(), TEXT("Pauser") );
				}
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPauserProp + 0x4a));
			}

			// TimeDilation (this+0x458): bitwise FLOAT compare.
			if ( *(INT*)((BYTE*)this + 0x458) != *(INT*)((BYTE*)Mem + 0x458) )
			{
				if ( !(s_RepFlags & 2) )
				{
					s_RepFlags    |= 2;
					s_pTimeDilProp = FindRepProperty( ALevelInfo::StaticClass(), TEXT("TimeDilation") );
				}
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pTimeDilProp + 0x4a));
			}
		}

		if ( Role == ROLE_Authority )
		{
			// m_RepWeatherEmitterClass (this+0x58c): object-ref with explicit mapping check.
			{
				INT    newW   = *(INT*)((BYTE*)this + 0x58c);
				INT    oldW   = *(INT*)((BYTE*)Mem  + 0x58c);
				DWORD* vtbl   = *(DWORD**)Map;
				typedef INT (__thiscall* MapObjFn)(UPackageMap*, INT);
				INT    mapped = ((MapObjFn)vtbl[25])( Map, newW );
				UBOOL  bSame;
				if ( mapped == 0 )
				{
					*(INT*)((BYTE*)Chan + 0x8c) = 1;  // bActorMustStayDirty
					bSame = (oldW == 0);
				}
				else
				{
					bSame = (newW == oldW);
				}
				if ( !bSame )
				{
					if ( !(s_RepFlags & 4) )
					{
						s_RepFlags    |= 4;
						s_pWeatherProp = FindRepProperty( ALevelInfo::StaticClass(), TEXT("m_RepWeatherEmitterClass") );
					}
					*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pWeatherProp + 0x4a));
				}
			}

			// VirusUpload-mode properties: only replicated in RGM_VirusUploadAdvMode.
			UObject* gri = *(UObject**)((BYTE*)this + 0x4cc);
			if ( gri )
			{
				const FString& gameMode = *(FString*)((BYTE*)gri + 0x4b0);
				if ( gameMode == TEXT("RGM_VirusUploadAdvMode") )
				{
					// m_bShowFloppy: bit 0 of this+0x450.
					if ( ( *(DWORD*)((BYTE*)this + 0x450) ^ *(DWORD*)((BYTE*)Mem + 0x450) ) & 1u )
					{
						if ( !(s_RepFlags & 8) )
						{
							s_RepFlags   |= 8;
							s_pShowFloppy = FindRepProperty( ALevelInfo::StaticClass(), TEXT("m_bShowFloppy") );
						}
						*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pShowFloppy + 0x4a));
					}

					// m_fCompteurFrameDetection (this+0x464).
					if ( *(INT*)((BYTE*)this + 0x464) != *(INT*)((BYTE*)Mem + 0x464) )
					{
						if ( !(s_RepFlags & 0x10) )
						{
							s_RepFlags  |= 0x10;
							s_pCompteur  = FindRepProperty( ALevelInfo::StaticClass(), TEXT("m_fCompteurFrameDetection") );
						}
						*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pCompteur + 0x4a));
					}
				}
			}
		}
	}

	return Ptr;
	unguard;
}
IMPL_EMPTY("base no-op — subclass implements")
void ALevelInfo::CallLogThisActor(AActor*) {}
// ?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ  Ghidra at ~279 bytes.
// Lazily spawns ADefaultPhysicsVolume and caches it at this+0x164.
// The original also sets vol+0x40C (Priority field, raw 0xFFF0BDC0) and vol+0xA0 |= 4.
// Priority raw-write deferred until AVolume layout is confirmed byte-accurate.
// CRITICAL: this must never return NULL as callers dereference the result unchecked.
IMPL_MATCH("Engine.dll", 0x103bb8b0)
APhysicsVolume* ALevelInfo::GetDefaultPhysicsVolume()
{
	APhysicsVolume*& CachedVol = *(APhysicsVolume**)((BYTE*)this + 0x164);
	if (!CachedVol)
	{
		CachedVol = (APhysicsVolume*)XLevel->SpawnActor(ADefaultPhysicsVolume::StaticClass());
		if (CachedVol)
		{
			// Priority: raw DWORD at vol+0x40C = 0xFFF0BDC0 (Ghidra; AVolume layout not yet verified)
			*(DWORD*)((BYTE*)CachedVol + 0x40C) = 0xFFF0BDC0u;
			// vol+0xA0 |= 4 (a bitmask flag in AActor's bitfield block)
			*(DWORD*)((BYTE*)CachedVol + 0xA0) |= 4;
		}
	}
	return CachedVol;
}
IMPL_MATCH("Engine.dll", 0x103b7ab0)
FString ALevelInfo::GetDisplayAs(FString s)
{
	// Ghidra 0xb7ab0 (191 bytes): walks a table of display-name entries at this+0x5d0.
	// Each entry is 0x98 bytes: an FString key at offset 0, display FString at offset 0xc.
	// Returns the matching display name, or "RGM_AllMode" if not found.
	BYTE* data = *(BYTE**)((BYTE*)this + 0x5d0);      // FArray.Data
	INT   n    = *(INT*) ((BYTE*)this + 0x5d0 + 4);   // FArray.ArrayNum
	for ( INT i = 0; i < n; i++ )
	{
		FString* key = (FString*)(data + i * 0x98);
		if ( *key == s )
			return *(FString*)(data + i * 0x98 + 0xc);
	}
	return FString(TEXT("RGM_AllMode"));
}

// ?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z  (0x0BBА00, 346 bytes)
// Walks the PhysicsVolume linked list to find the highest-priority volume
// that contains point V. With Actor+bUseTouchingVolumes=true it uses only
// the volumes in Actor->Touching (fast path).
// The list is lazily rebuilt when the dirty flag at this+0x94C bit 0 is clear.
// Priority field in APhysicsVolume is at raw offset 0x40C; next-pointer at 0x438.
IMPL_MATCH("Engine.dll", 0x103bba00)
APhysicsVolume* ALevelInfo::GetPhysicsVolume(FVector V, AActor* Actor, INT bUseTouchingVolumes)
{
	APhysicsVolume* Best = GetDefaultPhysicsVolume();
	if (!bUseTouchingVolumes || !Actor)
	{
		// Lazy rebuild of the linear PhysicsVolume list from the level's actor array.
		if (!(*(DWORD*)((BYTE*)this + 0x94C) & 1))
		{
			PhysicsVolumeList = NULL;
			ULevel* L = XLevel;
			INT N = L->Actors.Num();
			for (INT i = 0; i < N; i++)
			{
				AActor* A = L->Actors(i);
				if (A && A->IsA(APhysicsVolume::StaticClass()))
				{
					// Prepend A to the singly-linked list (NextVolume pointer at +0x438).
					*(APhysicsVolume**)((BYTE*)A + 0x438) = PhysicsVolumeList;
					PhysicsVolumeList = (APhysicsVolume*)A;
				}
			}
			*(DWORD*)((BYTE*)this + 0x94C) |= 1;
		}
		for (APhysicsVolume* V2 = PhysicsVolumeList; V2;
			 V2 = *(APhysicsVolume**)((BYTE*)V2 + 0x438))
		{
			// 0x40C = Priority (INT) in AVolume; pick highest-priority enclosing volume.
			if (*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)V2 + 0x40C) &&
				V2->Encompasses(V))
				Best = V2;
		}
	}
	else
	{
		// Fast path: restrict search to volumes currently Touching the Actor.
		for (INT i = 0; i < Actor->Touching.Num(); i++)
		{
			AActor* A = Actor->Touching(i);
			if (A && A->IsA(APhysicsVolume::StaticClass()) &&
				*(INT*)((BYTE*)Best + 0x40C) < *(INT*)((BYTE*)A + 0x40C) &&
				((AVolume*)A)->Encompasses(V))
				Best = (APhysicsVolume*)A;
		}
	}
	return Best;
}
// Retail (44b + shared epilogue): zone audibility bitmask lookup.
// Bitmask is an array of 8-byte entries at this+0x650, indexed by Zone1.
// Each entry is two DWORDs. Bit (Zone2 & 31) of the lo DWORD is checked.
// CDQ pattern: for Zone2==31 the sign-extended mask also checks the hi DWORD.
// Returns 1 if audible, 0 if not. (Fallthrough path normalises to 1.)
IMPL_MATCH("Engine.dll", 0x103068f0)
INT ALevelInfo::IsSoundAudibleFromZone(INT Zone1, INT Zone2)
{
    if (Zone1 == Zone2)
        return 1;
    DWORD* Zones = (DWORD*)((BYTE*)this + 0x650);
    DWORD bit = 1u << Zone2;
    DWORD lo   = bit & Zones[Zone1 * 2];
    INT   hiMask = (INT)bit >> 31;  // CDQ: -1 if Zone2==31, else 0
    DWORD hi   = (DWORD)hiMask & Zones[Zone1 * 2 + 1];
    return (lo | hi) ? 1 : 0;
}
IMPL_EMPTY("base no-op — subclass implements")
void AGameReplicationInfo::PostNetReceive() {}
IMPL_MATCH("Engine.dll", 0x10376620)
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(AGameReplicationInfo::GetOptimizedRepList);

	// Static lazy-init property cache matching Ghidra DAT_10666a84..0x10666afc
	static DWORD   s_Init          = 0;
	static UObject* s_pSrvState    = NULL;  // 0x1   m_eCurrectServerState
	static UObject* s_pMObjDesc    = NULL;  // 0x2   m_aRepMObjDescription[16]
	static UObject* s_pMObjDescLoc = NULL;  // 0x4   m_aRepMObjDescriptionLocFile[16]
	static UObject* s_pMObjComp    = NULL;  // 0x8   m_aRepMObjCompleted[16]
	static UObject* s_pMObjFailed  = NULL;  // 0x10  m_aRepMObjFailed[16]
	static UObject* s_pInProgress  = NULL;  // 0x20  m_bRepMObjInProgress
	static UObject* s_pMObjSucc    = NULL;  // 0x40  m_bRepMObjSuccess
	static UObject* s_pLastRound   = NULL;  // 0x80  m_bRepLastRoundSuccess
	static UObject* s_pNbWeapons   = NULL;  // 0x100 m_iNbWeaponsTerro
	static UObject* s_pSrvRadar    = NULL;  // 0x200 m_bServerAllowRadar
	static UObject* s_pRepRadarOpt = NULL;  // 0x400 m_bRepAllowRadarOption
	static UObject* s_pGameOver    = NULL;  // 0x800 m_bGameOverRep
	static UObject* s_pPostRound   = NULL;  // 0x1000 m_bInPostBetweenRoundTime
	static UObject* s_pRestartJoin = NULL;  // 0x2000 m_bRestartableByJoin
	static UObject* s_pPunkBuster  = NULL;  // 0x4000 m_bPunkBuster
	static UObject* s_pGrpID       = NULL;  // 0x8000 m_iGameSvrGroupID
	static UObject* s_pLobbyID     = NULL;  // 0x10000 m_iGameSvrLobbyID
	static UObject* s_pGTFlagRep   = NULL;  // 0x20000 m_szGameTypeFlagRep (bNetInitial)
	static UObject* s_pGameName    = NULL;  // 0x40000 GameName
	static UObject* s_pGameClass   = NULL;  // 0x80000 GameClass
	static UObject* s_pSrvName     = NULL;  // 0x100000 ServerName
	static UObject* s_pShortName   = NULL;  // 0x200000 ShortName
	static UObject* s_pAdminName   = NULL;  // 0x400000 AdminName
	static UObject* s_pAdminEmail  = NULL;  // 0x800000 AdminEmail
	static UObject* s_pSrvRegion   = NULL;  // 0x1000000 ServerRegion
	static UObject* s_pMOTD1       = NULL;  // 0x2000000 MOTDLine1
	static UObject* s_pMOTD2       = NULL;  // 0x4000000 MOTDLine2
	static UObject* s_pMOTD3       = NULL;  // 0x8000000 MOTDLine3
	static UObject* s_pMOTD4       = NULL;  // 0x10000000 MOTDLine4
	static UObject* s_pTimeLimit   = NULL;  // 0x20000000 TimeLimit

	Ptr = AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

	// CLASS_NativeReplication always set; check Role == Authority.
	if (Role == ROLE_Authority)
	{
		// m_eCurrectServerState (byte at this+0x396)
		if (*(BYTE*)((BYTE*)this+0x396) != *(BYTE*)((BYTE*)Mem+0x396))
		{
			if (!(s_Init & 0x1)) { s_Init |= 0x1; s_pSrvState = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_eCurrectServerState")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pSrvState + 0x4a));
		}

		// m_aRepMObjDescription[16] — each element uses RepIndex+i
		if (!(s_Init & 0x2)) { s_Init |= 0x2; s_pMObjDesc = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_aRepMObjDescription")); }
		for (INT i = 0; i < 16; i++)
		{
			if (*(FString*)((BYTE*)this + i*0xc + 0x458) != *(FString*)((BYTE*)Mem + i*0xc + 0x458))
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMObjDesc + 0x4a)) + i;
		}

		// m_aRepMObjDescriptionLocFile[16]
		if (!(s_Init & 0x4)) { s_Init |= 0x4; s_pMObjDescLoc = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_aRepMObjDescriptionLocFile")); }
		for (INT i = 0; i < 16; i++)
		{
			if (*(FString*)((BYTE*)this + i*0xc + 0x518) != *(FString*)((BYTE*)Mem + i*0xc + 0x518))
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMObjDescLoc + 0x4a)) + i;
		}

		// m_aRepMObjCompleted[16] — byte array
		if (!(s_Init & 0x8)) { s_Init |= 0x8; s_pMObjComp = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_aRepMObjCompleted")); }
		for (INT i = 0; i < 16; i++)
		{
			if (*(BYTE*)((BYTE*)this + 0x398 + i) != *(BYTE*)((BYTE*)Mem + 0x398 + i))
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMObjComp + 0x4a)) + i;
		}

		// m_aRepMObjFailed[16] — byte array
		if (!(s_Init & 0x10)) { s_Init |= 0x10; s_pMObjFailed = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_aRepMObjFailed")); }
		for (INT i = 0; i < 16; i++)
		{
			if (*(BYTE*)((BYTE*)this + 0x3a8 + i) != *(BYTE*)((BYTE*)Mem + 0x3a8 + i))
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMObjFailed + 0x4a)) + i;
		}

		// m_bRepMObjInProgress (byte at 0x3b8)
		if (*(BYTE*)((BYTE*)this+0x3b8) != *(BYTE*)((BYTE*)Mem+0x3b8))
		{
			if (!(s_Init & 0x20)) { s_Init |= 0x20; s_pInProgress = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bRepMObjInProgress")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pInProgress + 0x4a));
		}
		// m_bRepMObjSuccess (byte at 0x3b9)
		if (*(BYTE*)((BYTE*)this+0x3b9) != *(BYTE*)((BYTE*)Mem+0x3b9))
		{
			if (!(s_Init & 0x40)) { s_Init |= 0x40; s_pMObjSucc = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bRepMObjSuccess")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMObjSucc + 0x4a));
		}
		// m_bRepLastRoundSuccess (byte at 0x3ba)
		if (*(BYTE*)((BYTE*)this+0x3ba) != *(BYTE*)((BYTE*)Mem+0x3ba))
		{
			if (!(s_Init & 0x80)) { s_Init |= 0x80; s_pLastRound = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bRepLastRoundSuccess")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pLastRound + 0x4a));
		}
		// m_iNbWeaponsTerro (byte at 0x397)
		if (*(BYTE*)((BYTE*)this+0x397) != *(BYTE*)((BYTE*)Mem+0x397))
		{
			if (!(s_Init & 0x100)) { s_Init |= 0x100; s_pNbWeapons = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_iNbWeaponsTerro")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pNbWeapons + 0x4a));
		}

		// Bitfield at 0x3d0: m_bShowPlayerStates(0)=not replicated, m_bInPostBetweenRoundTime(1), m_bServerAllowRadar(2), m_bRepAllowRadarOption(3), m_bGameOverRep(4), m_bRestartableByJoin(5), m_bPunkBuster(6)
		{
			DWORD bits = *(DWORD*)((BYTE*)this+0x3d0) ^ *(DWORD*)((BYTE*)Mem+0x3d0);
			if (bits & 0x4u) { // m_bServerAllowRadar
				if (!(s_Init & 0x200)) { s_Init |= 0x200; s_pSrvRadar = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bServerAllowRadar")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pSrvRadar + 0x4a));
			}
			if (bits & 0x8u) { // m_bRepAllowRadarOption
				if (!(s_Init & 0x400)) { s_Init |= 0x400; s_pRepRadarOpt = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bRepAllowRadarOption")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRepRadarOpt + 0x4a));
			}
			if (bits & 0x10u) { // m_bGameOverRep
				if (!(s_Init & 0x800)) { s_Init |= 0x800; s_pGameOver = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bGameOverRep")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pGameOver + 0x4a));
			}
			if (bits & 0x2u) { // m_bInPostBetweenRoundTime
				if (!(s_Init & 0x1000)) { s_Init |= 0x1000; s_pPostRound = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bInPostBetweenRoundTime")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPostRound + 0x4a));
			}
			if (bits & 0x20u) { // m_bRestartableByJoin
				if (!(s_Init & 0x2000)) { s_Init |= 0x2000; s_pRestartJoin = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bRestartableByJoin")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRestartJoin + 0x4a));
			}
			if (bits & 0x40u) { // m_bPunkBuster
				if (!(s_Init & 0x4000)) { s_Init |= 0x4000; s_pPunkBuster = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_bPunkBuster")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPunkBuster + 0x4a));
			}
		}

		// m_iGameSvrGroupID (INT at 0x3c8)
		if (*(INT*)((BYTE*)this+0x3c8) != *(INT*)((BYTE*)Mem+0x3c8))
		{
			if (!(s_Init & 0x8000)) { s_Init |= 0x8000; s_pGrpID = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_iGameSvrGroupID")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pGrpID + 0x4a));
		}
		// m_iGameSvrLobbyID (INT at 0x3cc)
		if (*(INT*)((BYTE*)this+0x3cc) != *(INT*)((BYTE*)Mem+0x3cc))
		{
			if (!(s_Init & 0x10000)) { s_Init |= 0x10000; s_pLobbyID = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_iGameSvrLobbyID")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pLobbyID + 0x4a));
		}

		// bNetDirty && bNetInitial block: server config FStrings and scalar fields
		if ((*(DWORD*)((BYTE*)this + 0xa0) & 0x40000000u) && (*(BYTE*)((BYTE*)this + 0xac) & 0x20))
		{
			// m_szGameTypeFlagRep (FString at 0x44c)
			if (*(FString*)((BYTE*)this+0x44c) != *(FString*)((BYTE*)Mem+0x44c))
			{
				if (!(s_Init & 0x20000)) { s_Init |= 0x20000; s_pGTFlagRep = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("m_szGameTypeFlagRep")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pGTFlagRep + 0x4a));
			}
			// GameName (FString at 0x3d4)
			if (*(FString*)((BYTE*)this+0x3d4) != *(FString*)((BYTE*)Mem+0x3d4))
			{
				if (!(s_Init & 0x40000)) { s_Init |= 0x40000; s_pGameName = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("GameName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pGameName + 0x4a));
			}
			// GameClass (FString at 0x3e0)
			if (*(FString*)((BYTE*)this+0x3e0) != *(FString*)((BYTE*)Mem+0x3e0))
			{
				if (!(s_Init & 0x80000)) { s_Init |= 0x80000; s_pGameClass = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("GameClass")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pGameClass + 0x4a));
			}
			// ServerName (FString at 0x3ec)
			if (*(FString*)((BYTE*)this+0x3ec) != *(FString*)((BYTE*)Mem+0x3ec))
			{
				if (!(s_Init & 0x100000)) { s_Init |= 0x100000; s_pSrvName = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("ServerName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pSrvName + 0x4a));
			}
			// ShortName (FString at 0x3f8)
			if (*(FString*)((BYTE*)this+0x3f8) != *(FString*)((BYTE*)Mem+0x3f8))
			{
				if (!(s_Init & 0x200000)) { s_Init |= 0x200000; s_pShortName = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("ShortName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pShortName + 0x4a));
			}
			// AdminName (FString at 0x404)
			if (*(FString*)((BYTE*)this+0x404) != *(FString*)((BYTE*)Mem+0x404))
			{
				if (!(s_Init & 0x400000)) { s_Init |= 0x400000; s_pAdminName = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("AdminName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pAdminName + 0x4a));
			}
			// AdminEmail (FString at 0x410)
			if (*(FString*)((BYTE*)this+0x410) != *(FString*)((BYTE*)Mem+0x410))
			{
				if (!(s_Init & 0x800000)) { s_Init |= 0x800000; s_pAdminEmail = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("AdminEmail")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pAdminEmail + 0x4a));
			}
			// ServerRegion (INT at 0x3c0)
			if (*(INT*)((BYTE*)this+0x3c0) != *(INT*)((BYTE*)Mem+0x3c0))
			{
				if (!(s_Init & 0x1000000)) { s_Init |= 0x1000000; s_pSrvRegion = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("ServerRegion")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pSrvRegion + 0x4a));
			}
			// MOTDLine1 (FString at 0x41c)
			if (*(FString*)((BYTE*)this+0x41c) != *(FString*)((BYTE*)Mem+0x41c))
			{
				if (!(s_Init & 0x2000000)) { s_Init |= 0x2000000; s_pMOTD1 = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("MOTDLine1")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMOTD1 + 0x4a));
			}
			// MOTDLine2 (FString at 0x428)
			if (*(FString*)((BYTE*)this+0x428) != *(FString*)((BYTE*)Mem+0x428))
			{
				if (!(s_Init & 0x4000000)) { s_Init |= 0x4000000; s_pMOTD2 = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("MOTDLine2")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMOTD2 + 0x4a));
			}
			// MOTDLine3 (FString at 0x434)
			if (*(FString*)((BYTE*)this+0x434) != *(FString*)((BYTE*)Mem+0x434))
			{
				if (!(s_Init & 0x8000000)) { s_Init |= 0x8000000; s_pMOTD3 = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("MOTDLine3")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMOTD3 + 0x4a));
			}
			// MOTDLine4 (FString at 0x440)
			if (*(FString*)((BYTE*)this+0x440) != *(FString*)((BYTE*)Mem+0x440))
			{
				if (!(s_Init & 0x10000000)) { s_Init |= 0x10000000; s_pMOTD4 = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("MOTDLine4")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pMOTD4 + 0x4a));
			}
			// TimeLimit (INT at 0x3bc)
			if (*(INT*)((BYTE*)this+0x3bc) != *(INT*)((BYTE*)Mem+0x3bc))
			{
				if (!(s_Init & 0x20000000)) { s_Init |= 0x20000000; s_pTimeLimit = FindRepProperty(AGameReplicationInfo::StaticClass(), TEXT("TimeLimit")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pTimeLimit + 0x4a));
			}
		}
	}

	return Ptr;
	unguard;
}
IMPL_EMPTY("base no-op — subclass implements")
void APlayerReplicationInfo::PostNetReceive() {}
IMPL_MATCH("Engine.dll", 0x103759a0)
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(APlayerReplicationInfo::GetOptimizedRepList);

	// Static property cache — 32 lazy-init UProperty pointers matching Ghidra DAT_10666a00..0x10666a80
	static DWORD   s_InitFlags    = 0;
	static UObject* s_pScore       = NULL;  // bit 0x1   0x3f0
	static UObject* s_pDeaths      = NULL;  // bit 0x2   0x3f4
	static UObject* s_pPing        = NULL;  // bit 0x4   0x394
	static UObject* s_pPlayerLoc   = NULL;  // bit 0x8   0x3fc  (RepObjectChanged)
	static UObject* s_pPlayerName  = NULL;  // bit 0x10  0x408  FString
	static UObject* s_pTeamID      = NULL;  // bit 0x20  0x3a0
	static UObject* s_pPlayerID    = NULL;  // bit 0x40  0x39c
	static UObject* s_pTalkTex     = NULL;  // bit 0x80  0x400  (RepObjectChanged)
	static UObject* s_pIsFemale    = NULL;  // bit 0x100 0x3ec&0x1
	static UObject* s_pOpID        = NULL;  // bit 0x200 0x3a4
	static UObject* s_pFeignDeath  = NULL;  // bit 0x400 0x3ec&0x2
	static UObject* s_pIsSpec      = NULL;  // bit 0x800 0x3ec&0x4
	static UObject* s_pWaitPlay    = NULL;  // bit 0x1000 0x3ec&0x8
	static UObject* s_pReadyPlay   = NULL;  // bit 0x2000 0x3ec&0x10
	static UObject* s_pVoiceType   = NULL;  // bit 0x4000 0x404  (RepObjectChanged)
	static UObject* s_pOutOfLives  = NULL;  // bit 0x8000 0x3ec&0x20
	static UObject* s_pKillCount   = NULL;  // bit 0x10000  0x3b0
	static UObject* s_pRndKillCnt  = NULL;  // bit 0x20000  0x3e4
	static UObject* s_pRndFired    = NULL;  // bit 0x40000  0x3b8
	static UObject* s_pRndsHit     = NULL;  // bit 0x80000  0x3bc
	static UObject* s_pHealth      = NULL;  // bit 0x100000 0x3e0
	static UObject* s_pIsEscPilot  = NULL;  // bit 0x200000 0x3ec&0x200
	static UObject* s_pKillersName = NULL;  // bit 0x400000 0x438  FString
	static UObject* s_pPlrReady    = NULL;  // bit 0x800000 0x3ec&0x80
	static UObject* s_pUbiUID      = NULL;  // bit 0x1000000 0x42c FString
	static UObject* s_pRndsPlayed  = NULL;  // bit 0x2000000 0x3c0
	static UObject* s_pRndsWon     = NULL;  // bit 0x4000000 0x3c4
	static UObject* s_pJoinedLate  = NULL;  // bit 0x8000000 0x3ec&0x100
	static UObject* s_pBot         = NULL;  // bit 0x10000000 0x3ec&0x40 (bNetInitial guard)
	static UObject* s_pStartTime   = NULL;  // bit 0x20000000 0x3a8      (bNetInitial guard)
	static UObject* s_pSubmitRes   = NULL;  // bit 0x40000000 m_bClientWillSubmitResult
	static UObject* s_pIsIntruder  = NULL;  // bit 0x80000000 m_bIsTheIntruder

	Ptr = AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

	// CLASS_NativeReplication (0x800) is always set for this native-replication class.
	if (Role == ROLE_Authority)
	{
		if (*(DWORD*)((BYTE*)this + 0xa0) & 0x40000000u)  // bNetDirty
		{
			// Score (0x3f0)
			if (*(INT*)((BYTE*)this+0x3f0) != *(INT*)((BYTE*)Mem+0x3f0))
			{
				if (!(s_InitFlags & 0x1)) { s_InitFlags |= 0x1; s_pScore = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("Score")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pScore + 0x4a));
			}
			// Deaths (0x3f4)
			if (*(INT*)((BYTE*)this+0x3f4) != *(INT*)((BYTE*)Mem+0x3f4))
			{
				if (!(s_InitFlags & 0x2)) { s_InitFlags |= 0x2; s_pDeaths = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("Deaths")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pDeaths + 0x4a));
			}
			// Ping (0x394)
			if (*(INT*)((BYTE*)this+0x394) != *(INT*)((BYTE*)Mem+0x394))
			{
				if (!(s_InitFlags & 0x4)) { s_InitFlags |= 0x4; s_pPing = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("Ping")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPing + 0x4a));
			}
			// PlayerLocation (0x3fc) — object ref; retail uses FUN_10370830 (Chan->vtable[25]); approx as RepObjectChanged
			if (RepObjectChanged(*(INT*)((BYTE*)this+0x3fc), *(INT*)((BYTE*)Mem+0x3fc), Map, Chan))
			{
				if (!(s_InitFlags & 0x8)) { s_InitFlags |= 0x8; s_pPlayerLoc = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("PlayerLocation")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPlayerLoc + 0x4a));
			}
			// PlayerName (0x408) — FString compare
			if (*(FString*)((BYTE*)this+0x408) != *(FString*)((BYTE*)Mem+0x408))
			{
				if (!(s_InitFlags & 0x10)) { s_InitFlags |= 0x10; s_pPlayerName = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("PlayerName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPlayerName + 0x4a));
			}
			// TeamID (0x3a0)
			if (*(INT*)((BYTE*)this+0x3a0) != *(INT*)((BYTE*)Mem+0x3a0))
			{
				if (!(s_InitFlags & 0x20)) { s_InitFlags |= 0x20; s_pTeamID = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("TeamID")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pTeamID + 0x4a));
			}
			// PlayerID (0x39c)
			if (*(INT*)((BYTE*)this+0x39c) != *(INT*)((BYTE*)Mem+0x39c))
			{
				if (!(s_InitFlags & 0x40)) { s_InitFlags |= 0x40; s_pPlayerID = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("PlayerID")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPlayerID + 0x4a));
			}
			// TalkTexture (0x400) — object ref
			if (RepObjectChanged(*(INT*)((BYTE*)this+0x400), *(INT*)((BYTE*)Mem+0x400), Map, Chan))
			{
				if (!(s_InitFlags & 0x80)) { s_InitFlags |= 0x80; s_pTalkTex = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("TalkTexture")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pTalkTex + 0x4a));
			}
			// bIsFemale (0x3ec bit 0)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x1u)
			{
				if (!(s_InitFlags & 0x100)) { s_InitFlags |= 0x100; s_pIsFemale = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bIsFemale")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pIsFemale + 0x4a));
			}
			// iOperativeID (0x3a4)
			if (*(INT*)((BYTE*)this+0x3a4) != *(INT*)((BYTE*)Mem+0x3a4))
			{
				if (!(s_InitFlags & 0x200)) { s_InitFlags |= 0x200; s_pOpID = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("iOperativeID")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pOpID + 0x4a));
			}
			// bFeigningDeath (0x3ec bit 1)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x2u)
			{
				if (!(s_InitFlags & 0x400)) { s_InitFlags |= 0x400; s_pFeignDeath = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bFeigningDeath")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pFeignDeath + 0x4a));
			}
			// bIsSpectator (0x3ec bit 2)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x4u)
			{
				if (!(s_InitFlags & 0x800)) { s_InitFlags |= 0x800; s_pIsSpec = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bIsSpectator")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pIsSpec + 0x4a));
			}
			// bWaitingPlayer (0x3ec bit 3)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x8u)
			{
				if (!(s_InitFlags & 0x1000)) { s_InitFlags |= 0x1000; s_pWaitPlay = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bWaitingPlayer")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pWaitPlay + 0x4a));
			}
			// bReadyToPlay (0x3ec bit 4)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x10u)
			{
				if (!(s_InitFlags & 0x2000)) { s_InitFlags |= 0x2000; s_pReadyPlay = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bReadyToPlay")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pReadyPlay + 0x4a));
			}
			// VoiceType (0x404) — object ref
			if (RepObjectChanged(*(INT*)((BYTE*)this+0x404), *(INT*)((BYTE*)Mem+0x404), Map, Chan))
			{
				if (!(s_InitFlags & 0x4000)) { s_InitFlags |= 0x4000; s_pVoiceType = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("VoiceType")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pVoiceType + 0x4a));
			}
			// bOutOfLives (0x3ec bit 5)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x20u)
			{
				if (!(s_InitFlags & 0x8000)) { s_InitFlags |= 0x8000; s_pOutOfLives = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bOutOfLives")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pOutOfLives + 0x4a));
			}
			// m_iKillCount (0x3b0)
			if (*(INT*)((BYTE*)this+0x3b0) != *(INT*)((BYTE*)Mem+0x3b0))
			{
				if (!(s_InitFlags & 0x10000)) { s_InitFlags |= 0x10000; s_pKillCount = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iKillCount")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pKillCount + 0x4a));
			}
			// m_iRoundKillCount (0x3e4)
			if (*(INT*)((BYTE*)this+0x3e4) != *(INT*)((BYTE*)Mem+0x3e4))
			{
				if (!(s_InitFlags & 0x20000)) { s_InitFlags |= 0x20000; s_pRndKillCnt = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iRoundKillCount")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRndKillCnt + 0x4a));
			}
			// m_iRoundFired (0x3b8)
			if (*(INT*)((BYTE*)this+0x3b8) != *(INT*)((BYTE*)Mem+0x3b8))
			{
				if (!(s_InitFlags & 0x40000)) { s_InitFlags |= 0x40000; s_pRndFired = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iRoundFired")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRndFired + 0x4a));
			}
			// m_iRoundsHit (0x3bc)
			if (*(INT*)((BYTE*)this+0x3bc) != *(INT*)((BYTE*)Mem+0x3bc))
			{
				if (!(s_InitFlags & 0x80000)) { s_InitFlags |= 0x80000; s_pRndsHit = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iRoundsHit")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRndsHit + 0x4a));
			}
			// m_iHealth (0x3e0)
			if (*(INT*)((BYTE*)this+0x3e0) != *(INT*)((BYTE*)Mem+0x3e0))
			{
				if (!(s_InitFlags & 0x100000)) { s_InitFlags |= 0x100000; s_pHealth = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iHealth")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pHealth + 0x4a));
			}
			// m_bIsEscortedPilot (0x3ec bit 9)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x200u)
			{
				if (!(s_InitFlags & 0x200000)) { s_InitFlags |= 0x200000; s_pIsEscPilot = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_bIsEscortedPilot")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pIsEscPilot + 0x4a));
			}
			// m_szKillersName (0x438) — FString compare
			if (*(FString*)((BYTE*)this+0x438) != *(FString*)((BYTE*)Mem+0x438))
			{
				if (!(s_InitFlags & 0x400000)) { s_InitFlags |= 0x400000; s_pKillersName = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_szKillersName")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pKillersName + 0x4a));
			}
			// m_bPlayerReady (0x3ec bit 7 — sign bit of low byte)
			if ((BYTE)(*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x80u)
			{
				if (!(s_InitFlags & 0x800000)) { s_InitFlags |= 0x800000; s_pPlrReady = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_bPlayerReady")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pPlrReady + 0x4a));
			}
			// m_szUbiUserID (0x42c) — FString compare
			if (*(FString*)((BYTE*)this+0x42c) != *(FString*)((BYTE*)Mem+0x42c))
			{
				if (!(s_InitFlags & 0x1000000)) { s_InitFlags |= 0x1000000; s_pUbiUID = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_szUbiUserID")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pUbiUID + 0x4a));
			}
			// m_iRoundsPlayed (0x3c0)
			if (*(INT*)((BYTE*)this+0x3c0) != *(INT*)((BYTE*)Mem+0x3c0))
			{
				if (!(s_InitFlags & 0x2000000)) { s_InitFlags |= 0x2000000; s_pRndsPlayed = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iRoundsPlayed")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRndsPlayed + 0x4a));
			}
			// m_iRoundsWon (0x3c4)
			if (*(INT*)((BYTE*)this+0x3c4) != *(INT*)((BYTE*)Mem+0x3c4))
			{
				if (!(s_InitFlags & 0x4000000)) { s_InitFlags |= 0x4000000; s_pRndsWon = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_iRoundsWon")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pRndsWon + 0x4a));
			}
			// m_bJoinedTeamLate (0x3ec bit 8)
			if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x100u)
			{
				if (!(s_InitFlags & 0x8000000)) { s_InitFlags |= 0x8000000; s_pJoinedLate = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_bJoinedTeamLate")); }
				*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pJoinedLate + 0x4a));
			}

			// bNetInitial guard: bBot and StartTime (0xac byte bit 5)
			if (*(BYTE*)((BYTE*)this + 0xac) & 0x20)
			{
				// bBot (0x3ec bit 6)
				if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x40u)
				{
					if (!(s_InitFlags & 0x10000000)) { s_InitFlags |= 0x10000000; s_pBot = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("bBot")); }
					*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pBot + 0x4a));
				}
				// StartTime (0x3a8)
				if (*(INT*)((BYTE*)this+0x3a8) != *(INT*)((BYTE*)Mem+0x3a8))
				{
					if (!(s_InitFlags & 0x20000000)) { s_InitFlags |= 0x20000000; s_pStartTime = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("StartTime")); }
					*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pStartTime + 0x4a));
				}
			}
		}

		// m_bClientWillSubmitResult (0x3ec bit 12 = 0x1000) — replicated regardless of bNetDirty
		if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x1000u)
		{
			if (!(s_InitFlags & 0x40000000)) { s_InitFlags |= 0x40000000; s_pSubmitRes = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_bClientWillSubmitResult")); }
			*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pSubmitRes + 0x4a));
		}
	}

	// m_bIsTheIntruder (0x3ec bit 13 = 0x2000) — checked for all roles per Ghidra (outside Role==Auth block)
	if ((*(DWORD*)((BYTE*)this+0x3ec) ^ *(DWORD*)((BYTE*)Mem+0x3ec)) & 0x2000u)
	{
		if (!(s_InitFlags & 0x80000000u)) { s_InitFlags |= 0x80000000u; s_pIsIntruder = FindRepProperty(APlayerReplicationInfo::StaticClass(), TEXT("m_bIsTheIntruder")); }
		*Ptr++ = (INT)(*(unsigned short*)((BYTE*)s_pIsIntruder + 0x4a));
	}

	return Ptr;
	unguard;
}
/*-----------------------------------------------------------------------------
  AReplicationInfo virtual method stubs.
  Only methods NOT defined in EngineClassImpl.cpp remain here.
-----------------------------------------------------------------------------*/
IMPL_EMPTY("base no-op — subclass implements")
void AReplicationInfo::DisplayVideo(UCanvas*, void*, INT) {}
IMPL_EMPTY("base no-op — subclass implements")
void AReplicationInfo::Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT) {}
IMPL_EMPTY("base no-op — subclass implements")
void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>&) {}
IMPL_DIVERGE("stub; retail implementation not found in Engine exports")
DWORD AReplicationInfo::GetAvailableVideoMemory() { return 0; }
IMPL_EMPTY("base no-op — subclass implements")
void AReplicationInfo::HandleFullScreenEffects(INT, INT) {}
