/*=============================================================================
	UnCache.cpp: FMemCache — fast memory cache implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Raven_Shield_C_SDK/432Core/Inc/UnCache.h
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FMemCache implementation.
-----------------------------------------------------------------------------*/

void FMemCache::Init( INT BytesToAllocate, INT MaxItems, void* Start, INT SegSize )
{
	guard(FMemCache::Init);

	// Allocate item memory.
	ItemMemory = (FCacheItem*)appMalloc( MaxItems * sizeof(FCacheItem), TEXT("CacheItems") );

	// Allocate or use provided cache memory.
	if( Start )
		CacheMemory = (BYTE*)Start;
	else
		CacheMemory = (BYTE*)appMalloc( BytesToAllocate, TEXT("CacheData") );

	// Initialize hash table.
	for( INT i=0; i<HASH_COUNT; i++ )
		HashItems[i] = NULL;

	// Set up the free item list.
	UnusedItems = &ItemMemory[0];
	for( INT i=0; i<MaxItems-1; i++ )
		ItemMemory[i].LinearNext = &ItemMemory[i+1];
	ItemMemory[MaxItems-1].LinearNext = NULL;

	// Create initial free space spanning entire cache.
	CacheItems = NULL;
	LastItem   = NULL;
	CreateNewFreeSpace( CacheMemory, CacheMemory + BytesToAllocate, NULL, NULL, 0 );

	// Initialize state.
	Time        = 0;
	MruId       = 0;
	MruItem     = NULL;
	Initialized = 1;

	// Reset stats.
	NumGets = NumCreates = CreateCycles = GetCycles = TickCycles = 0;
	ItemsFresh = ItemsStale = ItemsTotal = ItemGaps = 0;
	MemFresh = MemStale = MemTotal = 0;

	unguard;
}

void FMemCache::Exit( INT FreeMemory )
{
	guard(FMemCache::Exit);
	if( Initialized )
	{
		if( FreeMemory )
		{
			appFree( CacheMemory );
			CacheMemory = NULL;
		}
		appFree( ItemMemory );
		ItemMemory  = NULL;
		CacheItems  = NULL;
		LastItem    = NULL;
		UnusedItems = NULL;
		Initialized = 0;
	}
	unguard;
}

void FMemCache::Flush( QWORD Id, DWORD Mask, UBOOL IgnoreLocked )
{
	guard(FMemCache::Flush);
	if( Initialized )
	{
		MruId   = 0;
		MruItem = NULL;
		for( FCacheItem* Item=CacheItems; Item; Item=Item->LinearNext )
		{
			if( Item->Id && (Item->Id & Mask) == (Id & Mask) )
				FlushItem( Item, IgnoreLocked );
		}
	}
	unguard;
}

BYTE* FMemCache::Create( QWORD Id, FCacheItem*& Item, INT CreateSize, INT Alignment, INT SafetyPad )
{
	guard(FMemCache::Create);
	check(Initialized);
	NumCreates++;

	// Flush any existing item with this Id.
	Flush( Id, ~(DWORD)0, 0 );

	// Find space by scanning for free items large enough.
	for( FCacheItem* TestItem=CacheItems; TestItem; TestItem=TestItem->LinearNext )
	{
		if( TestItem->Id == 0 && TestItem->GetSize() >= CreateSize + SafetyPad )
		{
			// Found free space — use it.
			Item = TestItem;
			Item->Id   = Id;
			Item->Time = Time;
			Item->Cost = COST_INFINITE;

			// Hash it.
			FCacheItem** HashSlot = &HashItems[GHash(Id)];
			Item->HashNext = *HashSlot;
			*HashSlot = Item;

			MruId   = Id;
			MruItem = Item;

			return Align( Item->Data, Alignment );
		}
	}

	// No space found — flush stale items to create space.
	for( FCacheItem* TestItem=CacheItems; TestItem; TestItem=TestItem->LinearNext )
	{
		if( TestItem->Id != 0 && TestItem->Cost < COST_INFINITE )
		{
			FlushItem( TestItem );
			// Try again recursively.
			return Create( Id, Item, CreateSize, Alignment, SafetyPad );
		}
	}

	Item = NULL;
	return NULL;
	unguard;
}

void FMemCache::Tick()
{
	guard(FMemCache::Tick);

	// Start timing this tick.
	DWORD TickStart = appCycles();
	TickCycles -= TickStart;

	// Reset MRU so items don't get free access across tick boundaries.
	MruId   = 0;
	MruItem = NULL;

	// Reset per-tick stats.
	ItemsFresh = 0;
	ItemsStale = 0;
	ItemGaps   = 0;
	MemFresh   = 0;
	MemStale   = 0;

	// Decay cost for stale items (ones not accessed this tick).
	for( FCacheItem* Item=CacheItems; Item!=LastItem; Item=Item->LinearNext )
	{
		if( Item->Id != 0 && (INT)(DWORD)Item->Time < Time )
			Item->Cost -= Item->Cost >> 5;
	}

	// Advance the time counter.
	Time++;

	TickCycles += appCycles() - 0x22;
	unguard;
}

void FMemCache::CheckState()
{
	guard(FMemCache::CheckState);
	// Validate the linear list integrity.
	if( !Initialized )
		return;
	for( FCacheItem* Item=CacheItems; Item; Item=Item->LinearNext )
	{
		if( Item->LinearNext )
			check( Item->LinearNext->LinearPrev == Item );
		if( Item->LinearPrev )
			check( Item->LinearPrev->LinearNext == Item );
	}
	unguard;
}

UBOOL FMemCache::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(FMemCache::Exec);
	if( ParseCommand(&Cmd, TEXT("CACHEFLUSH")) )
	{
		Flush();
		Ar.Logf( TEXT("Cache flushed.") );
		return 1;
	}
	return 0;
	unguard;
}

void FMemCache::Status( TCHAR* Msg )
{
	guard(FMemCache::Status);
	appSprintf( Msg, TEXT("Cache: Items=%i Gets=%i Creates=%i"), ItemsTotal, NumGets, NumCreates );
	unguard;
}

void FMemCache::CreateNewFreeSpace( BYTE* Start, BYTE* End, FCacheItem* Prev, FCacheItem* Next, INT Segment )
{
	guard(FMemCache::CreateNewFreeSpace);
	check(UnusedItems);

	FCacheItem* NewItem = UnusedItems;
	UnusedItems = UnusedItems->LinearNext;

	NewItem->Id          = 0;
	NewItem->Data        = Start;
	NewItem->Time        = 0;
	NewItem->Segment     = Segment;
	NewItem->Extra       = 0;
	NewItem->Cost        = 0;
	NewItem->LinearNext  = Next;
	NewItem->LinearPrev  = Prev;
	NewItem->HashNext    = NULL;

	if( Prev )
		Prev->LinearNext = NewItem;
	else
		CacheItems = NewItem;

	if( Next )
		Next->LinearPrev = NewItem;
	else
		LastItem = NewItem;

	unguard;
}

FMemCache::FCacheItem* FMemCache::MergeWithNext( FCacheItem* First )
{
	guard(FMemCache::MergeWithNext);
	check(First);
	check(First->LinearNext);
	check(First->Id==0);
	check(First->LinearNext->Id==0);

	FCacheItem* Second = First->LinearNext;

	// Unlink Second from the list.
	First->LinearNext = Second->LinearNext;
	if( Second->LinearNext )
		Second->LinearNext->LinearPrev = First;
	else
		LastItem = First;

	// Return Second to the free list.
	Second->LinearNext = UnusedItems;
	UnusedItems = Second;

	return First;
	unguard;
}

FMemCache::FCacheItem* FMemCache::FlushItem( FCacheItem* Item, UBOOL IgnoreLocked )
{
	guard(FMemCache::FlushItem);
	if( Item->Cost >= COST_INFINITE && !IgnoreLocked )
		return Item;

	// Unhash.
	if( Item->Id )
		Unhash( Item->Id );

	Item->Id   = 0;
	Item->Cost = 0;
	Item->Time = 0;

	// Merge with adjacent free items.
	if( Item->LinearPrev && Item->LinearPrev->Id == 0 )
		Item = MergeWithNext( Item->LinearPrev );
	if( Item->LinearNext && Item->LinearNext->Id == 0 )
		MergeWithNext( Item );

	return Item;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
