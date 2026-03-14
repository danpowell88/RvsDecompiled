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

ULevelBase::ULevelBase( UEngine* InOwner, const FURL& InURL )
:	Actors( this )
,	URL( InURL )
{
	Engine = InOwner;
	NetDriver = NULL;
	DemoRecDriver = NULL;
}

void ULevelBase::Destroy()
{
	UObject::Destroy();
}

void ULevelBase::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
	Ar << Actors;
}

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

ULevel::ULevel( UEngine* InEngine, INT InRootOutside )
:	ULevelBase( InEngine )
{
	guard(ULevel::ULevel);
	// Ghidra 0xc2c40: large constructor body.
	// Phase 1 (compiler-generated): FArray::FArray() on all TArray/TMap member fields.
	// Phase 2 (TMap hash-table setup): many pairs of (ptr[+0xC]=0, ptr[+0x10]=8, FUN_103*())
	//          at offsets 0xdc, 0x10150, 0x10164, 0x101ac, 0x101e4, 0x101f8, 0x1020c, …
	//          FUN_1031f850/f990/fa30/fb80/fc20 = TMap hash-table rehash helpers (8 initial buckets).
	//          DIVERGENCE: TMap hash tables left empty; game TMap usage rare at startup.
	// Phase 3 (runtime init):
	SetFlags( RF_Transactional );
	// TODO: UModel allocation via StaticAllocateObject
	// TODO: ALevelInfo spawn via FRotator(0,0,0)+SpawnActor
	// TODO: SpawnBrush and brush/model RF flag setup
	// TODO: GetDefaultPhysicsVolume call
	// TODO: GScriptCycles/GScriptEntryTag zero-init and level flags
	unguard;
}

void ULevel::Serialize( FArchive& Ar )
{
	ULevelBase::Serialize( Ar );
}

void ULevel::PostLoad()
{
	UObject::PostLoad();
}

void ULevel::Destroy()
{
	ULevelBase::Destroy();
}

// GNewCollisionHash is defined in UnCamera.cpp
ENGINE_API FCollisionHashBase* GNewCollisionHash();

void ULevel::Modify( INT DoTransArrays )
{
	guard(ULevel::Modify);
	UObject::Modify();
	UModel* m = *(UModel**)((BYTE*)this + 0x90);
	if (m) m->Modify(DoTransArrays);
	unguard;
}

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

void ULevel::Tick( ELevelTick TickType, FLOAT DeltaSeconds )
{
	guard(ULevel::Tick);
	// TODO: implement ULevel::Tick (actor iteration, physics, script events, timer firing)
	unguard;
}

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
		// DIVERGENCE: BrowseLevel to ?failed not implemented (requires UEngine::Browse).
	}
	unguard;
}

void ULevel::TickNetServer( FLOAT DeltaSeconds )
{
	guard(ULevel::TickNetServer);
	// TODO: implement ULevel::TickNetServer (replication, channel ticking, player updates)
	unguard;
}

INT ULevel::ServerTickClient( UNetConnection* Conn, FLOAT DeltaSeconds )
{
	guard(ULevel::ServerTickClient);
	// TODO: implement ULevel::ServerTickClient (per-connection channel processing)
	return 0;
	unguard;
}

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
				// DestroyActor may have compacted the array; don't increment
			}
		}
		else
		{
			ai++;
		}
	}
	unguard;
}

void ULevel::RememberActors()
{
	guard(ULevel::RememberActors);
	UEngine* eng = *(UEngine**)((BYTE*)this + 0x44);
	BYTE* client = *(BYTE**)((BYTE*)eng + 0x44);
	if ( client )
	{
		FArray* vpArr = (FArray*)(client + 0x30);
		INT nVP = *(INT*)((BYTE*)vpArr + 4);
		for ( INT vi = 0; vi < nVP; vi++ )
		{
			BYTE* vp    = *(BYTE**)(*(BYTE**)vpArr + vi * 4);
			BYTE* actor = *(BYTE**)(vp + 0x34);
			if ( actor && *(ULevel**)((BYTE*)actor + 0x328) == this )
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

INT ULevel::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(ULevel::Exec);
	// TODO: implement ULevel::Exec command dispatch (stat, show, flush, etc.)
	return 0;
	unguard;
}

void ULevel::ShrinkLevel()
{
	guard(ULevel::ShrinkLevel);
	UModel* m = *(UModel**)((BYTE*)this + 0x90);
	if (m) m->ShrinkModel();
	unguard;
}

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
		// Raw remove without undo (we already notified GUndo above)
		((FArray*)&Actors)->Remove(iDst, endCount - iDst, sizeof(AActor*));
	}
	unguard;
}

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
INT ULevel::MoveActor( AActor* Actor, FVector Delta, FRotator NewRotation, FCheckResult& Hit, INT bTest, INT bIgnorePawns, INT bIgnoreBases, INT bNoFail, INT bExtra )
{
	guard(ULevel::MoveActor);
	// TODO: implement ULevel::MoveActor sweep/collision
	return 1;
	unguard;
}

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

ABrush* ULevel::SpawnBrush()
{
	guard(ULevel::SpawnBrush);
	ABrush* result = (ABrush*)SpawnActor(ABrush::StaticClass());
	if (!result)
		appFailAssert("Result", ".\\UnLevAct.cpp", 0xc2);
	return result;
	unguard;
}

void ULevel::SpawnViewActor( UViewport* Viewport )
{
	guard(ULevel::SpawnViewActor);
	// TODO: implement ULevel::SpawnViewActor (spawns per-viewport camera actor, sets ViewTarget)
	unguard;
}

APlayerController* ULevel::SpawnPlayActor( UPlayer* Player, ENetRole RemoteRole, const FURL& URL, FString& Error )
{
	guard(ULevel::SpawnPlayActor);
	// TODO: implement ULevel::SpawnPlayActor (creates PlayerController, sets up connection replication)
	return NULL;
	unguard;
}

INT ULevel::FindSpot( FVector Extent, FVector& Location, INT bCheckActors, AActor* Requester )
{
	guard(ULevel::FindSpot);
	// TODO: implement ULevel::FindSpot (BSP + actor collision-free spawn point search)
	return 1;
	unguard;
}

INT ULevel::CheckSlice( FVector& Adjusted, FVector TraceDest, INT& TraceLen, AActor* Actor )
{
	guard(ULevel::CheckSlice);
	// TODO: implement ULevel::CheckSlice (vertical slab adjustment for player capsule fitting)
	return 0;
	unguard;
}

INT ULevel::CheckEncroachment( AActor* Actor, FVector TestLocation, FRotator TestRotation, INT bTouchNotify )
{
	guard(ULevel::CheckEncroachment);
	// TODO: implement ULevel::CheckEncroachment (collision check for actor placement validity)
	return 0;
	unguard;
}

INT ULevel::SinglePointCheck( FCheckResult& Hit, AActor* SourceActor, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors )
{
	guard(ULevel::SinglePointCheck);
	FMemMark Mark(GMem);
	FCheckResult* res = MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, bActors, 0, 0, NULL);
	if ( !res ) { Mark.Pop(); return 1; }
	appMemcpy(&Hit, res, sizeof(FCheckResult));
	// Walk list to find closest to Location (skip SourceActor)
	for ( FCheckResult* cur = res->GetNext(); cur; cur = cur->GetNext() )
	{
		if ( cur->Actor == SourceActor ) continue;
		FVector dCur = cur->Location - Location;
		FVector dHit = Hit.Location - Location;
		if ( dCur.SizeSquared() < dHit.SizeSquared() )
			appMemcpy(&Hit, cur, sizeof(FCheckResult));
	}
	Mark.Pop();
	return 0;
	unguard;
}

INT ULevel::SinglePointCheck( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors )
{
	guard(ULevel::SinglePointCheck);
	FMemMark Mark(GMem);
	FCheckResult* res = MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, bActors, 0, 0, NULL);
	if ( !res ) { Mark.Pop(); return 1; }
	appMemcpy(&Hit, res, sizeof(FCheckResult));
	// Walk list to find closest to Location
	for ( FCheckResult* cur = res->GetNext(); cur; cur = cur->GetNext() )
	{
		FVector dCur = cur->Location - Location;
		FVector dHit = Hit.Location - Location;
		if ( dCur.SizeSquared() < dHit.SizeSquared() )
			appMemcpy(&Hit, cur, sizeof(FCheckResult));
	}
	Mark.Pop();
	return 0;
	unguard;
}

INT ULevel::SingleLineCheck( FCheckResult& Hit, AActor* SourceActor, const FVector& End, const FVector& Start, DWORD TraceFlags, FVector Extent )
{
	guard(ULevel::SingleLineCheck);
	FMemMark Mark(GMem);
	ALevelInfo* traceLevel = (TraceFlags & TRACE_Level) ? GetLevelInfo() : NULL;
	FCheckResult* res = MultiLineCheck(GMem, End, Start, Extent, traceLevel, TraceFlags | TRACE_SingleResult, SourceActor);
	if ( !res )
	{
		Hit.Time  = 1.0f;
		Hit.Actor = NULL;
		Mark.Pop();
		return 1;
	}
	appMemcpy(&Hit, res, sizeof(FCheckResult));
	Mark.Pop();
	return 0;
	unguard;
}

INT ULevel::EncroachingWorldGeometry( FCheckResult& Hit, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, AActor* Actor )
{
	guard(ULevel::EncroachingWorldGeometry);
	FMemMark Mark(GMem);
	FCheckResult* res = MultiPointCheck(GMem, Location, Extent, ExtraNodeFlags, Level, 1, 1, 1, Actor);
	if ( !res )
	{
		Mark.Pop();
		return 0;
	}
	appMemcpy(&Hit, res, sizeof(FCheckResult));
	Mark.Pop();
	return 1;
	unguard;
}

FCheckResult* ULevel::MultiPointCheck( FMemStack& Mem, FVector Location, FVector Extent, DWORD ExtraNodeFlags, ALevelInfo* Level, INT bActors, INT bOnlyWorldGeometry, INT bSingleResult, AActor* Requester )
{
	guard(ULevel::MultiPointCheck);
	// TODO: implement ULevel::MultiPointCheck (returns all actors/BSP overlapping a box)
	return NULL;
	unguard;
}

FCheckResult* ULevel::MultiLineCheck( FMemStack& Mem, FVector End, FVector Start, FVector Extent, ALevelInfo* Level, DWORD TraceFlags, AActor* SourceActor )
{
	guard(ULevel::MultiLineCheck);
	// TODO: implement ULevel::MultiLineCheck (returns linked list of all hits along a ray)
	return NULL;
	unguard;
}

void ULevel::DetailChange( INT NewDetail )
{
	guard(ULevel::DetailChange);
	ALevelInfo* info = GetLevelInfo();
	if ( !info ) return;
	// Toggle bHighDetailMode (bit 7 of flags dword at 0x450)
	{
		DWORD& flags = *(DWORD*)((BYTE*)info + 0x450);
		flags = flags ^ ((DWORD(NewDetail) << 7 ^ flags) & 0x80u);
	}
	info = GetLevelInfo();
	// Notify GameReplicationInfo if present (at offset 0x4cc)
	UObject* gri = *(UObject**)((BYTE*)info + 0x4cc);
	if ( gri )
	{
		static FName NAME_DetailChange(TEXT("DetailChange"), FNAME_Find);
		if ( NAME_DetailChange != NAME_None )
		{
			UFunction* func = gri->FindFunctionChecked(NAME_DetailChange, 0);
			if ( func )
			{
				typedef void (__thiscall* ProcessEventFn)(UObject*, UFunction*, void*, void*);
				((ProcessEventFn)(*(DWORD*)(*(DWORD*)gri + 0x10)))(gri, func, NULL, NULL);
			}
		}
	}
	unguard;
}

INT ULevel::TickDemoRecord( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoRecord);
	if ( !*(INT*)((BYTE*)this + 0x8c) ) // DemoRecDriver == NULL
		return 0;
	// TODO: implement DemoRecDriver actor replication
	return 1;
	unguard;
}

INT ULevel::TickDemoPlayback( FLOAT DeltaSeconds )
{
	guard(ULevel::TickDemoPlayback);
	ALevelInfo* info = GetLevelInfo();
	UEngine* eng     = *(UEngine**)((BYTE*)this + 0x44);
	// DemoRecDriver->ServerConnection->State
	INT state = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)this + 0x8c) + 0x3c) + 0x80);
	if ( *(BYTE*)((BYTE*)info + 0x928) == 3 && state != 2 )
	{
		*(BYTE*)((BYTE*)info + 0x928) = 0;
		// ServerTravel("","",0) — vtable slot 0xb0/4 on UEngine
		typedef void (__thiscall* ServerTravelFn)(UEngine*, const TCHAR*, const TCHAR*, INT);
		((ServerTravelFn)(*(DWORD*)(*(DWORD*)eng + 0xb0)))(eng, TEXT(""), TEXT(""), 0);
	}
	if ( state == 1 )
	{
		INT nVP = *(INT*)(*(BYTE**)(*(BYTE**)((BYTE*)eng + 0x44) + 0x30) + 4);
		if ( nVP == 0 )
			appFailAssert("Engine->Client->Viewports.Num()", ".\\UnLevTic.cpp", 0x527);
		// TODO: BrowseLevel to ?entry (requires UEngine::Browse)
	}
	return 1;
	unguard;
}

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
INT ULevel::IsAudibleAt( FVector Location, FVector ListenerLocation, AActor* SourceActor, ESoundOcclusion Occlusion ) { return 1; }
FLOAT ULevel::CalculateRadiusMultiplier( INT SoundRadius, INT SoundRadiusInner ) { return 25.f * ((INT)SoundRadius + 1); }

// FNetworkNotify interface.
EAcceptConnection ULevel::NotifyAcceptingConnection() { return ACCEPTC_Reject; }
void ULevel::NotifyAcceptedConnection( UNetConnection* Connection )
{
	guard(ULevel::NotifyAcceptedConnection);
	if( !NetDriver )
		appFailAssert("NetDriver!=NULL",".\\UnLevel.cpp",0x348);
	if( *(UNetConnection**)((BYTE*)NetDriver + 0x3c) != NULL )
		appFailAssert("NetDriver->ServerConnection==NULL",".\\UnLevel.cpp",0x349);
	// DIVERGENCE: retail calls Connection->LowLevelDescribe() via vtable[0x1a] (offset 0x68)
	// and logs to DevNet. Ghidra 0xbf2a0. Omitted — no-op here.
	unguard;
}
INT ULevel::NotifyAcceptingChannel( UChannel* Channel ) { return 1; }
ULevel* ULevel::NotifyGetLevel() { return this; }
void ULevel::NotifyReceivedText( UNetConnection* Connection, const TCHAR* Text )
{
	guard(ULevel::NotifyReceivedText);
	// DIVERGENCE: retail full network command dispatch (HELLO/NETSPEED/HAVE/JOIN/FILEREQ/
	// WELCOME/UPGRADE/FAILURE etc.) — 3802 bytes of network protocol handling (Ghidra 0xc1d30).
	// Unresolved — accepting connections will not progress through the handshake.
	unguard;
}
INT ULevel::NotifySendingFile( UNetConnection* Connection, FGuid GUID )
{
	// Retail (18b, RVA 0xBF590): returns 1 if [this+0x14]->field@+0x3C is NULL, else 0.
	// Connection and GUID params are NOT referenced in retail assembly.
	// [this+0x14] is likely the embedded NetDriver/network object pointer.
	void* driver = *(void**)((BYTE*)this + 0x14);
	if (!driver) return 1; // safety: not present in retail, but avoids NULL deref
	return (*(DWORD*)((BYTE*)driver + 0x3C) == 0) ? 1 : 0;
}
void ULevel::NotifyReceivedFile( UNetConnection* Connection, INT PackageIndex, const TCHAR* Error, INT Forced )
{
	guard(ULevel::NotifyReceivedFile);
	GError->Logf(TEXT("")); // Ghidra 0xbf500: FOutputDevice::Logf(GError, ...)
	unguard;
}

// Non-virtual methods.
ABrush* ULevel::Brush() { return (Actors.Num()>=2 && Actors(1)) ? (ABrush*)Actors(1) : NULL; }
INT ULevel::EditorDestroyActor( AActor* Actor ) { return DestroyActor( Actor ); }
INT ULevel::GetActorIndex( AActor* Actor )
{
	for( INT i=0; i<Actors.Num(); i++ )
		if( Actors(i) == Actor )
			return i;
	return INDEX_NONE;
}
ALevelInfo* ULevel::GetLevelInfo() { return (Actors.Num()>0 && Actors(0)) ? (ALevelInfo*)Actors(0) : NULL; }
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
INT ULevel::MoveActorFirstBlocking( AActor* Actor, INT bTest, INT bIgnorePawns, FCheckResult* FirstHit, FCheckResult& Hit ) { return 0; }
INT ULevel::ToFloor( AActor* Actor, INT bTest, AActor* IgnoreActor ) { return 0; }
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
void ALevelInfo::execGetAddressURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetAddressURL);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Host;
	if( XLevel->URL.Port != 7777 )
		*(FString*)Result += FString::Printf( TEXT(":%i"), XLevel->URL.Port );
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetAddressURL );

// GetLocalURL() - returns the current map URL.
void ALevelInfo::execGetLocalURL( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetLocalURL);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetLocalURL );

// GetMapNameLocalisation() - returns the localised map name.
void ALevelInfo::execGetMapNameLocalisation( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execGetMapNameLocalisation);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Map;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execGetMapNameLocalisation );

// FinalizeLoading() - called when level loading is complete.
void ALevelInfo::execFinalizeLoading( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execFinalizeLoading);
	P_FINISH;
	// Notify the engine that loading is finalized.
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execFinalizeLoading );

// ResetLevelInNative() - resets native-side level state.
void ALevelInfo::execResetLevelInNative( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execResetLevelInNative);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execResetLevelInNative );

// SetBankSound() - registers a sound bank with the audio subsystem.
void ALevelInfo::execSetBankSound( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execSetBankSound);
	P_GET_STR(BankName);
	P_FINISH;
	// Audio bank loading delegated to DARE audio subsystem.
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execSetBankSound );

// NotifyMatchStart() - notifies native code that a match has begun.
void ALevelInfo::execNotifyMatchStart( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execNotifyMatchStart);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execNotifyMatchStart );

// PBNotifyServerTravel() - PunkBuster server travel notification.
void ALevelInfo::execPBNotifyServerTravel( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execPBNotifyServerTravel);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execPBNotifyServerTravel );

// CallLogThisActor() - logging helper.
void ALevelInfo::execCallLogThisActor( FFrame& Stack, RESULT_DECL )
{
	guard(ALevelInfo::execCallLogThisActor);
	P_GET_STR(LogText);
	P_FINISH;
	debugf( TEXT("LogActor: %s"), *LogText );
	unguard;
}
IMPLEMENT_FUNCTION( ALevelInfo, INDEX_NONE, execCallLogThisActor );

// AddWritableMapPoint() - adds a point to the writable minimap overlay.
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
void AGameInfo::execGetNetworkNumber( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetNetworkNumber);
	P_FINISH;
	*(FString*)Result = XLevel->URL.Host;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetNetworkNumber );

// GetCurrentMapNum() - returns the current map index from the map list.
void AGameInfo::execGetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execGetCurrentMapNum);
	P_FINISH;
	*(INT*)Result = 0;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execGetCurrentMapNum );

// SetCurrentMapNum() - sets the current map index.
void AGameInfo::execSetCurrentMapNum( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execSetCurrentMapNum);
	P_GET_INT(MapNum);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execSetCurrentMapNum );

// ParseKillMessage() - formats a kill message string.
void AGameInfo::execParseKillMessage( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execParseKillMessage);
	P_GET_STR(KillerName);
	P_GET_STR(VictimName);
	P_GET_STR(WeaponName);
	P_GET_STR(DeathMessage);
	P_FINISH;
	*(FString*)Result = DeathMessage;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execParseKillMessage );

// ProcessR6Availabilty() - processes R6-specific game type availability.
void AGameInfo::execProcessR6Availabilty( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execProcessR6Availabilty);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execProcessR6Availabilty );

// AbortScoreSubmission() - aborts an in-progress score submission.
void AGameInfo::execAbortScoreSubmission( FFrame& Stack, RESULT_DECL )
{
	guard(AGameInfo::execAbortScoreSubmission);
	P_FINISH;
	unguard;
}
IMPLEMENT_FUNCTION( AGameInfo, INDEX_NONE, execAbortScoreSubmission );

// ============================================================================
// FPointRegion implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??4FPointRegion@@QAEAAV0@ABV0@@Z
FPointRegion& FPointRegion::operator=(const FPointRegion& Other)
{
	Zone = Other.Zone;
	iLeaf = Other.iLeaf;
	ZoneNumber = Other.ZoneNumber;
	return *this;
}

// ??0FPointRegion@@QAE@XZ
FPointRegion::FPointRegion() : Zone(NULL), iLeaf(0), ZoneNumber(0) {}
// ??0FPointRegion@@QAE@PAVAZoneInfo@@@Z
FPointRegion::FPointRegion(AZoneInfo* InZone) : Zone(InZone), iLeaf(INDEX_NONE), ZoneNumber(0) {}
// ??0FPointRegion@@QAE@PAVAZoneInfo@@HE@Z
FPointRegion::FPointRegion(AZoneInfo* InZone, INT InLeaf, BYTE InZoneNumber) : Zone(InZone), iLeaf(InLeaf), ZoneNumber(InZoneNumber) {}

// --- Moved from EngineStubs.cpp ---
void ALevelInfo::SetVolumes(const TArray<class AVolume*>&) {}
void ALevelInfo::SetVolumes() {}
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
void ALevelInfo::PostNetReceive() {}
void ALevelInfo::PreNetReceive() {}
void ALevelInfo::CheckForErrors() {}
INT* ALevelInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void ALevelInfo::CallLogThisActor(AActor*) {}
// ?GetDefaultPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@XZ  Ghidra at ~279 bytes.
// Lazily spawns ADefaultPhysicsVolume and caches it at this+0x164.
// The original also sets vol+0x40C (Priority field, raw 0xFFF0BDC0) and vol+0xA0 |= 4.
// Priority raw-write deferred until AVolume layout is confirmed byte-accurate.
// CRITICAL: this must never return NULL as callers dereference the result unchecked.
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
FString ALevelInfo::GetDisplayAs(FString s) { return s; }

// ?GetPhysicsVolume@ALevelInfo@@QAEPAVAPhysicsVolume@@VFVector@@PAVAActor@@H@Z  (0x0BBА00, 346 bytes)
// Walks the PhysicsVolume linked list to find the highest-priority volume
// that contains point V. With Actor+bUseTouchingVolumes=true it uses only
// the volumes in Actor->Touching (fast path).
// The list is lazily rebuilt when the dirty flag at this+0x94C bit 0 is clear.
// Priority field in APhysicsVolume is at raw offset 0x40C; next-pointer at 0x438.
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
void AGameReplicationInfo::PostNetReceive() {}
INT* AGameReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
void APlayerReplicationInfo::PostNetReceive() {}
INT* APlayerReplicationInfo::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	return AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);
}
/*-----------------------------------------------------------------------------
  AReplicationInfo virtual method stubs.
  Only methods NOT defined in EngineClassImpl.cpp remain here.
-----------------------------------------------------------------------------*/
void AReplicationInfo::DisplayVideo(UCanvas*, void*, INT) {}
void AReplicationInfo::Draw3DLine(FVector, FVector, FColor, UTexture*, FLOAT, FLOAT, FLOAT, FLOAT) {}
void AReplicationInfo::GetAvailableResolutions(TArray<FResolutionInfo>&) {}
DWORD AReplicationInfo::GetAvailableVideoMemory() { return 0; }
void AReplicationInfo::HandleFullScreenEffects(INT, INT) {}
