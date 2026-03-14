/*=============================================================================
	UnMem.cpp: FMemStack implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FMemStack statics.
-----------------------------------------------------------------------------*/

FMemStack::FTaggedMemory* FMemStack::UnusedChunks = NULL;

/*-----------------------------------------------------------------------------
	FMemStack implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012DA00)
void FMemStack::Init( INT InDefaultChunkSize )
{
	guard(FMemStack::Init);

	DefaultChunkSize = InDefaultChunkSize;
	TopChunk         = NULL;
	Top              = NULL;
	End              = NULL;

	unguard;
}

IMPL_MATCH("Core.dll", 0x1012DAB0)
void FMemStack::Exit()
{
	guard(FMemStack::Exit);

	Tick();

	while( TopChunk )
	{
		FTaggedMemory* Old = TopChunk;
		TopChunk = TopChunk->Next;
		appFree( Old );
	}

	while( UnusedChunks )
	{
		FTaggedMemory* Old = UnusedChunks;
		UnusedChunks = UnusedChunks->Next;
		appFree( Old );
	}

	unguard;
}

IMPL_MATCH("Core.dll", 0x1012DA20)
void FMemStack::Tick()
{
	guard(FMemStack::Tick);

	// Free unused chunks.
	while( UnusedChunks )
	{
		FTaggedMemory* Old = UnusedChunks;
		UnusedChunks = UnusedChunks->Next;
		appFree( Old );
	}

	unguard;
}

IMPL_MATCH("Core.dll", 0x1012DB40)
INT FMemStack::GetByteCount()
{
	guard(FMemStack::GetByteCount);

	INT Count = 0;
	for( FTaggedMemory* Chunk = TopChunk; Chunk; Chunk = Chunk->Next )
		Count += Chunk->DataSize;
	return Count;

	unguard;
}

IMPL_MATCH("Core.dll", 0x1012DBC0)
BYTE* FMemStack::AllocateNewChunk( INT MinSize )
{
	guard(FMemStack::AllocateNewChunk);

	FTaggedMemory* Chunk = NULL;
	for( FTaggedMemory** Link = &UnusedChunks; *Link; Link = &(*Link)->Next )
	{
		if( (*Link)->DataSize >= MinSize )
		{
			Chunk = *Link;
			*Link = (*Link)->Next;
			break;
		}
	}

	if( !Chunk )
	{
		INT DataSize = Max( MinSize, DefaultChunkSize );
		Chunk = (FTaggedMemory*)appMalloc( sizeof(FTaggedMemory) + DataSize - 1, TEXT("MemStack") );
		Chunk->DataSize = DataSize;
	}

	Chunk->Next = TopChunk;
	TopChunk    = Chunk;
	Top         = Chunk->Data;
	End         = Top + Chunk->DataSize;

	return Top;

	unguard;
}

IMPL_MATCH("Core.dll", 0x1012DB70)
void FMemStack::FreeChunks( FTaggedMemory* NewTopChunk )
{
	guard(FMemStack::FreeChunks);

	while( TopChunk != NewTopChunk )
	{
		FTaggedMemory* RemoveChunk = TopChunk;
		TopChunk = TopChunk->Next;
		RemoveChunk->Next = UnusedChunks;
		UnusedChunks = RemoveChunk;
	}
	Top = TopChunk ? TopChunk->Data : NULL;
	End = TopChunk ? Top + TopChunk->DataSize : NULL;

	unguard;
}

/*-----------------------------------------------------------------------------
	FMallocWindows method bodies (declared extern in header).
	The commented-out implementations in FMallocWindows.h are for reference;
	these provide the actual compiled implementations.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void* FMallocWindows::Malloc( DWORD Size, const TCHAR* Tag )
{
	guard(FMallocWindows::Malloc);
	checkSlow(Size>0);
	checkSlow(MemInit);
	MEM_TIME(MemTime -= appSeconds());
	STAT(CurrentAllocs++);
	STAT(TotalAllocs++);
	FFreeMem* Free;
	if( Size<POOL_MAX )
	{
		// Allocate from pool.
		FPoolTable* Table = MemSizeToPoolTable[Size];
		checkSlow(Size<=Table->BlockSize);
		FPoolInfo* Pool = Table->FirstPool;
		if( !Pool )
		{
			// Must create a new pool.
			DWORD Blocks  = 65536 / Table->BlockSize;
			DWORD Bytes   = Blocks * Table->BlockSize;
			checkSlow(Blocks>=1);
			checkSlow(Blocks*Table->BlockSize<=Bytes);

			// Allocate memory.
			Free = (FFreeMem*)VirtualAlloc( NULL, Bytes, MEM_COMMIT, PAGE_READWRITE );
			if( !Free )
				OutOfMemory();

			// Create pool in the indirect table.
			FPoolInfo*& Indirect = PoolIndirect[((DWORD)Free>>24)];
			if( !Indirect )
				Indirect = CreateIndirect();
			Pool = &Indirect[((DWORD)Free>>16)&255];

			// Init pool.
			Pool->Link( Table->FirstPool );
			Pool->Mem            = (BYTE*)Free;
			Pool->Bytes          = Bytes;
			Pool->OsBytes        = Align(Bytes,GPageSize);
			STAT(OsPeak = Max(OsPeak,OsCurrent+=Pool->OsBytes));
			Pool->Table          = Table;
			Pool->Taken          = 0;
			Pool->FirstMem       = Free;

			// Create first free item.
			Free->Blocks         = Blocks;
			Free->Next           = NULL;
		}

		// Pick first available block and unlink it.
		Pool->Taken++;
		checkSlow(Pool->FirstMem);
		checkSlow(Pool->FirstMem->Blocks>0);
		Free = (FFreeMem*)((BYTE*)Pool->FirstMem + --Pool->FirstMem->Blocks * Table->BlockSize);
		if( Pool->FirstMem->Blocks==0 )
		{
			Pool->FirstMem = Pool->FirstMem->Next;
			if( !Pool->FirstMem )
			{
				// Move to exausted list.
				Pool->Unlink();
				Pool->Link( Table->ExaustedPool );
			}
		}
		STAT(UsedPeak = Max(UsedPeak,UsedCurrent+=Table->BlockSize));
	}
	else
	{
		// Use OS for large allocations.
		INT AlignedSize = Align(Size,GPageSize);
		Free = (FFreeMem*)VirtualAlloc( NULL, AlignedSize, MEM_COMMIT, PAGE_READWRITE );
		if( !Free )
			OutOfMemory();
		checkSlow(!((SIZE_T)Free&65535));

		// Create indirect.
		FPoolInfo*& Indirect = PoolIndirect[((DWORD)Free>>24)];
		if( !Indirect )
			Indirect = CreateIndirect();

		// Init pool.
		FPoolInfo* Pool = &Indirect[((DWORD)Free>>16)&255];
		Pool->Mem       = (BYTE*)Free;
		Pool->Bytes     = Size;
		Pool->OsBytes   = AlignedSize;
		Pool->Table     = &OsTable;
		STAT(OsPeak   = Max(OsPeak,  OsCurrent+=AlignedSize));
		STAT(UsedPeak = Max(UsedPeak,UsedCurrent+=Size));
	}
	MEM_TIME(MemTime += appSeconds());
	return Free;
	unguard;
}

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void* FMallocWindows::Realloc( void* Ptr, DWORD NewSize, const TCHAR* Tag )
{
	guard(FMallocWindows::Realloc);
	checkSlow(MemInit);
	MEM_TIME(MemTime -= appSeconds());
	check(NewSize>=0);
	void* NewPtr = Ptr;
	if( Ptr && NewSize )
	{
		checkSlow(MemInit);
		FPoolInfo* Pool = &PoolIndirect[(DWORD)Ptr>>24][((DWORD)Ptr>>16)&255];
		if( Pool->Table!=&OsTable )
		{
			// Allocated from pool, so grow or shrink if necessary.
			if( NewSize>Pool->Table->BlockSize || MemSizeToPoolTable[NewSize]!=Pool->Table )
			{
				NewPtr = Malloc( NewSize, Tag );
				appMemcpy( NewPtr, Ptr, Min(NewSize,Pool->Table->BlockSize) );
				Free( Ptr );
			}
		}
		else
		{
			// Allocated from OS.
			checkSlow(!((INT)Ptr&65535));
			if( NewSize>Pool->OsBytes || NewSize*3<Pool->OsBytes*2 )
			{
				// Grow or shrink.
				NewPtr = Malloc( NewSize, Tag );
				appMemcpy( NewPtr, Ptr, Min(NewSize,Pool->Bytes) );
				Free( Ptr );
			}
			else
			{
				// Keep as-is, reallocation isn't worth the overhead.
				Pool->Bytes = NewSize;
			}
		}
	}
	else if( NewSize )
	{
		NewPtr = Malloc( NewSize, Tag );
	}
	else
	{
		if( Ptr )
			Free( Ptr );
		NewPtr = NULL;
	}
	MEM_TIME(MemTime += appSeconds());
	return NewPtr;
	unguardf(( TEXT("%08X %i %s"), (INT)Ptr, NewSize, Tag ));
}

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void FMallocWindows::Free( void* Ptr )
{
	guard(FMallocWindows::Free);
	if( !Ptr )
		return;
	checkSlow(MemInit);
	MEM_TIME(MemTime -= appSeconds());
	STAT(CurrentAllocs--);

	// Windows version.
	FPoolInfo* Pool = &PoolIndirect[(DWORD)Ptr>>24][((DWORD)Ptr>>16)&255];
	checkSlow(Pool->Bytes!=0);
	if( Pool->Table!=&OsTable )
	{
		// If this pool was exausted, move to available list.
		if( !Pool->FirstMem )
		{
			Pool->Unlink();
			Pool->Link( Pool->Table->FirstPool );
		}

		// Free a pooled allocation.
		FFreeMem* Free      = (FFreeMem *)Ptr;
		Free->Blocks        = 1;
		Free->Next          = Pool->FirstMem;
		Pool->FirstMem      = Free;
		STAT(UsedCurrent   -= Pool->Table->BlockSize);

		// Free this pool.
		checkSlow(Pool->Taken>=1);
		if( --Pool->Taken == 0 )
		{
			// Free the OS memory.
			Pool->Unlink();
			verify( VirtualFree( Pool->Mem, 0, MEM_RELEASE )!=0 );
			STAT(OsCurrent -= Pool->OsBytes);
		}
	}
	else
	{
		// Free an OS allocation.
		checkSlow(!((INT)Ptr&65535));
		STAT(UsedCurrent -= Pool->Bytes);
		STAT(OsCurrent   -= Pool->OsBytes);
		verify( VirtualFree( Ptr, 0, MEM_RELEASE )!=0 );
	}
	MEM_TIME(MemTime += appSeconds());
	unguard;
}

/*-----------------------------------------------------------------------------
	FMallocAnsi method bodies.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void* FMallocAnsi::Realloc( void* Ptr, DWORD NewSize, const TCHAR* Tag )
{
	guard(FMallocAnsi::Realloc);
	check(NewSize>=0);
	void* Result;
	if( Ptr && NewSize )
	{
		Result = realloc( Ptr, NewSize );
	}
	else if( NewSize )
	{
		Result = malloc( NewSize );
	}
	else
	{
		if( Ptr )
			free( Ptr );
		Result = NULL;
	}
	return Result;
	unguardf(( TEXT("%08X %i %s"), (INT)Ptr, NewSize, Tag ));
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
