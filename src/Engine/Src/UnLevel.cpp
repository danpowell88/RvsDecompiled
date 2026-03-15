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

IMPL_TODO("IsTrans path calls FUN_103c0ab0 (unresolved); non-IsTrans uses ByteOrderSerialize; Ghidra 0x103c0f60")
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

IMPL_TODO("TMap hash tables not initialized; zone/BSP init helpers unresolved; retail at Ghidra 0x103c2c40")
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

IMPL_DIVERGE("TravelInfo TMap serialization unresolved (FUN_103c0ce0); modern path partially missing; retail at Ghidra 0x103c3070")
void ULevel::Serialize( FArchive& Ar )
{
	guard(ULevel::Serialize);
	ULevelBase::Serialize( Ar );

	// Ar << Model (UModel* at this+0x90)
	Ar << *(UObject**)((BYTE*)this + 0x90);

	// Ghidra: if ver < 0x62: old path with FUN_103c0bd0/FUN_103c0b40 (ancient format, skip)

	// ByteOrderSerialize TimeSeconds (FLOAT at this+0xd4)
	Ar.ByteOrderSerialize( (void*)((BYTE*)this + 0xd4), 4 );

	// Ar << FirstDeleted (AActor* at this+0xf4)
	Ar << *(UObject**)((BYTE*)this + 0xf4);

	// Ar << TextBlocks[0..15] (16 x UTextBuffer* at this+0x94..+0xd0)
	for ( INT i = 0; i < 16; i++ )
		Ar << *(UObject**)((BYTE*)this + 0x94 + i * 4);

	// Ghidra: if ver < 0x3f: very old path (FUN_103c0e40 etc.), skip for modern archives
	// Modern path (ver >= 0x3f):
	//   FUN_103c0ce0(Ar, this+0xdc) — serialize TravelInfo TMap (unresolved loader)
	//   if loading: FUN_1031f850() — post-load action (unresolved)
	//   if Model && !IsTrans: Ar.vtable[4](Model) — Preload(Model) (unresolved)
	//   if LicenseeVer > 0xc && (IsSaving||IsLoading): FUN_103c0ce0(Ar, this+0x101ac)

	unguard;
}

IMPL_DIVERGE("calls FUN_1047ad70/FUN_1047bd10/FUN_1047ae50 which are Karma physics world init; Karma SDK is binary-only (Ghidra 0x103c13f0)")
void ULevel::PostLoad()
{
	UObject::PostLoad();
}

IMPL_TODO("calls FUN_10358ca0 and FUN_1031fc20 omitted; retail at Ghidra 0x103c10c0")
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

IMPL_TODO("stub; retail Tick is full physics/script event loop at Ghidra 0x103c6700")
void ULevel::Tick( ELevelTick TickType, FLOAT DeltaSeconds )
{
	guard(ULevel::Tick);
	// TODO: implement ULevel::Tick (actor iteration, physics, script events, timer firing)
	unguard;
}

IMPL_TODO("partial stub; retail TickNetClient at Ghidra 0x103c6e40")
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

IMPL_TODO("stub; retail TickNetServer at Ghidra 0x103c5db0")
void ULevel::TickNetServer( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetServer);
	// TODO: implement ULevel::TickNetServer (replication, channel ticking, player updates)
	unguard;
}

IMPL_TODO("stub; retail ServerTickClient at Ghidra 0x103c53b0")
INT ULevel::ServerTickClient( UNetConnection* Conn, FLOAT DeltaSeconds )
{
	guard(ULevel::ServerTickClient);
	// TODO: implement ULevel::ServerTickClient (per-connection channel processing)
	return 0;
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

IMPL_TODO("stub; retail command dispatch at Ghidra 0x103c1630")
INT ULevel::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(ULevel::Exec);
	// TODO: implement ULevel::Exec command dispatch (stat, show, flush, etc.)
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

IMPL_TODO("partial stub; retail Listen at Ghidra 0x103c0460")
INT ULevel::Listen( FString& Error )
{
	guard(ULevel::Listen);
	if ( !*(INT*)((BYTE*)this + 0x40) ) // NetDriver == NULL
	{
		// TODO: Create UNetDriver + InitListen + GameInfo spawn
		return 1;
	}
	Error = LocalizeError(TEXT("NetAlready"), TEXT("Engine"), NULL);
	return 0;
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
IMPL_TODO("stub; retail sweep/collision at Ghidra 0x103b9750")
INT ULevel::MoveActor( AActor* Actor, FVector Delta, FRotator NewRotation, FCheckResult& Hit, INT bTest, INT bIgnorePawns, INT bIgnoreBases, INT bNoFail, INT bExtra, FLOAT fStepDist )
{
	guard(ULevel::MoveActor);
	// TODO: implement ULevel::MoveActor sweep/collision
	return 1;
	unguard;
}

IMPL_TODO("partial stub; retail FarMoveActor at Ghidra 0x103b93e0")
INT ULevel::FarMoveActor( AActor* Actor, FVector DestLocation, INT bTest, INT bNoCheck, INT bAttachedMove, INT bExtra )
{
	guard(ULevel::FarMoveActor);
	if ( !Actor )
		appFailAssert("Actor!=NULL", ".\\UnLevAct.cpp", 0x49f);
	// bStatic or not bMovable — cannot move in non-editor mode
	if ( ((*(BYTE*)((BYTE*)Actor + 0xa0) & 1) != 0
		  || (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x20) == 0)
		 && !GIsEditor )
	{
		return 0;
	}
	FCollisionHashBase* hash = *(FCollisionHashBase**)((BYTE*)this + 0xf0);
	// Remove from hash before move
	if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) && hash )
		hash->RemoveActor(Actor);
	// TODO: implement full FarMoveActor sweep and blocked-movement logic
	// Re-add to hash after move
	if ( (*(DWORD*)((BYTE*)Actor + 0xa8) & 0x800) && hash )
		hash->AddActor(Actor);
	return 1;
	unguard;
}

IMPL_TODO("reconstructed; touch notifications and network destruction check diverge from retail at Ghidra 0x103b8200")
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

		// Network: if client, non-Authority actors normally can't be destroyed
		// (simplified — full net logic omitted; DIVERGENCE: FUN_103b7b70 = server-driven
		// network destruction check; unresolved, destruction is permitted unconditionally here)
		ALevelInfo* li = GetLevelInfo();
		if ( li && *(BYTE*)((BYTE*)li + 0x425) == 3 && // NM_Client
		     NetDriver && NetDriver->ServerConnection )
		{
			// DIVERGENCE: FUN_103b7b70 performs a server-side network role check before
			// allowing the actor to be destroyed on the client. Unresolved; skipping allows
			// local actor destruction regardless of network authority.
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
				// DIVERGENCE: FUN_1037a010 = actor-touching check followed by EndTouch events.
			// Determines if Actor is in the touching list of 'a', calls eventEndTouch.
			// Unresolved — touch notifications not sent for destroyed actor's touchees.
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

IMPL_TODO("zone/BSP init helper unresolved; retail SpawnActor at Ghidra 0x103b7bd0")
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

IMPL_TODO("stub; retail SpawnPlayActor at Ghidra 0x103be0c0")
APlayerController* ULevel::SpawnPlayActor( UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error )
{
	guard(ULevel::SpawnPlayActor);
	// TODO: implement ULevel::SpawnPlayActor (creates PlayerController, sets up connection replication)
	return NULL;
	unguard;
}

IMPL_TODO("stub; retail FindSpot at Ghidra 0x103b9020")
INT ULevel::FindSpot( FVector Extent, FVector& Location, INT bCheckActors, AActor* Requester )
{
	guard(ULevel::FindSpot);
	// TODO: implement ULevel::FindSpot (BSP + actor collision-free spawn point search)
	return 1;
	unguard;
}

IMPL_TODO("stub; retail CheckSlice at Ghidra 0x103b8b30")
INT ULevel::CheckSlice( FVector& Adjusted, FVector TraceDest, INT& TraceLen, AActor* Actor )
{
	guard(ULevel::CheckSlice);
	// TODO: implement ULevel::CheckSlice (vertical slab adjustment for player capsule fitting)
	return 0;
	unguard;
}

IMPL_TODO("stub; retail CheckEncroachment at Ghidra 0x103bad70")
INT ULevel::CheckEncroachment( AActor* Actor, FVector TestLocation, FRotator TestRotation, INT bTouchNotify )
{
	guard(ULevel::CheckEncroachment);
	// TODO: implement ULevel::CheckEncroachment (collision check for actor placement validity)
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

IMPL_MATCH("Engine.dll", 0x103b7460)
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

IMPL_TODO("stub; retail MultiPointCheck at Ghidra 0x103bc6f0")
FCheckResult* ULevel::MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors, INT bOnlyWorldGeometry, INT bSingleResult, AActor* Requester )
{
	guard(ULevel::MultiPointCheck);
	// TODO: implement ULevel::MultiPointCheck (returns all actors/BSP overlapping a box)
	return NULL;
	unguard;
}

IMPL_TODO("stub; retail MultiLineCheck at Ghidra 0x103bcb00")
FCheckResult* ULevel::MultiLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, ALevelInfo* Level, DWORD TraceFlags, AActor* SourceActor )
{
	guard(ULevel::MultiLineCheck);
	// TODO: implement ULevel::MultiLineCheck (returns linked list of all hits along a ray)
	return NULL;
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

IMPL_TODO("partial stub; retail TickDemoRecord at Ghidra 0x103c62f0")
INT ULevel::TickDemoRecord( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoRecord);
	if ( !*(INT*)((BYTE*)this + 0x8c) ) // DemoRecDriver == NULL
		return 0;
	// TODO: implement DemoRecDriver actor replication
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

IMPL_TODO("UPackageMap::Copy omitted; retail WelcomePlayer at Ghidra 0x103c0890")
void ULevel::WelcomePlayer( UNetConnection* Connection, TCHAR* Optional )
{
	guard(ULevel::WelcomePlayer);
	// Copy driver's package map into connection's package map
	// TODO: UPackageMap::Copy(Connection+0xC8, Driver+0x44) — package map not synced
	Connection->SendPackageMap();
	ALevelInfo* info = GetLevelInfo();
	UObject* outer   = GetOuter();
	const TCHAR* mapName = outer ? outer->GetName() : TEXT("");
	if ( !Optional || Optional[0] == 0 )
	{
		INT bHighDetail = (*(DWORD*)((BYTE*)info + 0x450) >> 7) & 1;
		debugf(TEXT("WelcomePlayer: detail=%d map=%s"), bHighDetail, mapName);
	}
	else
	{
		debugf(TEXT("WelcomePlayer: optional=%s map=%s"), Optional, mapName);
	}
	// Notify connection (vtable slot 0x80/4 = 32)
	typedef void (__thiscall* Fn32)(void*);
	((Fn32)(*(DWORD*)(*(DWORD*)Connection + 0x80)))(Connection);
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
IMPL_DIVERGE("retail this=FNetworkNotify(ULevel+0x2c); field offsets differ; DevNet log format approximated (Ghidra 0x103bf2a0)")
void ULevel::NotifyAcceptedConnection( UNetConnection* Connection )
{
	guard(ULevel::NotifyAcceptedConnection);
	if( !NetDriver )
		appFailAssert("NetDriver!=NULL",".\\UnLevel.cpp",0x348);
	if( *(UNetConnection**)((BYTE*)NetDriver + 0x3c) != NULL )
		appFailAssert("NetDriver->ServerConnection==NULL",".\\UnLevel.cpp",0x349);
	// Ghidra 0xbf2a0: calls Connection->LowLevelDescribe() via vtable[0x1a] (offset 0x68)
	// then logs "[timestamp] level accepted [description]" to GLog at DevNet verbosity.
	// Retail format string is at 0x313 offset; approximated here with debugf.
	typedef FString* (__thiscall* DescribeFn)(UNetConnection*, FString*);
	FString desc;
	((DescribeFn)(*(DWORD*)(*(DWORD*)Connection + 0x68)))(Connection, &desc);
	debugf( NAME_DevNet, TEXT("%s accepted connection %s"), GetName(), *desc );
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
IMPL_TODO("stub; retail dispatches network protocol commands at Ghidra 0x103c1d30")
void ULevel::NotifyReceivedText( UNetConnection* Connection, const TCHAR* Text )
{
	guard(ULevel::NotifyReceivedText);
	// DIVERGENCE: retail full network command dispatch (HELLO/NETSPEED/HAVE/JOIN/FILEREQ/
	// WELCOME/UPGRADE/FAILURE etc.) — 3802 bytes of network protocol handling (Ghidra 0xc1d30).
	// Unresolved — accepting connections will not progress through the handshake.
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
IMPL_TODO("stub; retail ToFloor at Ghidra 0x103c0140")
INT ULevel::ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor ) { return 0; }
IMPL_TODO("partial; terrain zone registration helper unresolved at Ghidra 0x103c11a0")
void ULevel::UpdateTerrainArrays()
{
	guard(ULevel::UpdateTerrainArrays);
	UModel* model = *(UModel**)((BYTE*)this + 0x90);
	if ( !model ) return;

	// Clear terrain (Terrains TArray at +0x3C0) on all zone actors stored in the Model
	// Zone data layout in Model: stride = 9 DWORDs, start offset = 0x24*8 = 0x120
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
			// SetCollision on terrain info (vtable slot 0x10c bytes into ULevel vtable)
			typedef void (__thiscall* SetCollisionFn)(AActor*, INT, INT);
			((SetCollisionFn)(*(DWORD*)(*(DWORD*)this + 0x10c)))((AActor*)Actors(0), 1, 0);
			// FUN_10481dd0 = terrain zone registration helper: links ATerrainInfo to its
			// zone actor and populates the Terrains TArray.
			// TODO: implement terrain zone registration (FUN_10481dd0 = terrain zone registration helper)
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

// GetMapNameLocalisation() - returns the localised map name.
IMPL_TODO("1212-byte function; creates UR6MissionDescription via StaticAllocateObject to get localised map name; Ghidra 0x103bdb70")
void ALevelInfo::execGetMapNameLocalisation( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetMapNameLocalisation);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
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
IMPL_TODO("795-byte function; clears game state arrays, viewport state, calls FUN_1031fb80; Ghidra 0x103bd770")
void ALevelInfo::execResetLevelInNative( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execResetLevelInNative);
	P_FINISH;
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
IMPL_TODO("611-byte function; FGuid generation via engine vtable, sets session state; Ghidra 0x103bc230")
void ALevelInfo::execNotifyMatchStart( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execNotifyMatchStart);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execNotifyMatchStart );

// PBNotifyServerTravel() - PunkBuster server travel notification.
IMPL_DIVERGE("stub; retail calls PunkBuster INIT; Ghidra 0x120330")
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
IMPL_MATCH("Engine.dll", 0x10301a90)
FPointRegion::FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
// ??0FPointRegion@@QAE@PAVAZoneInfo@@@Z
IMPL_MATCH("Engine.dll", 0x10302980)
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
IMPL_TODO("FUN_10370830 (rep-object compare) and FUN_10371990 (lazy property lookup) unresolved; Ghidra 0x103756b0")
INT* ALevelInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
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
IMPL_TODO("FUN_10370870 (string diff for rep arrays) and FUN_10371990 unresolved; 4039-byte function (Ghidra 0x10376620)")
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
IMPL_EMPTY("base no-op — subclass implements")
void APlayerReplicationInfo::PostNetReceive() {}
IMPL_TODO("FUN_10370830 (rep-object compare), FUN_10371990 unresolved; 3146-byte function (Ghidra 0x103759a0)")
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
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
