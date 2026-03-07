/*=============================================================================
	FMallocWindows.h: Local override for launcher module.
	The CSDK version has method bodies commented out (Malloc, Realloc, Free).
	The UT99 version has them inline which is what we need since FMallocWindows
	is instantiated locally in the exe.

	We use the CSDK FMallocWindows.h base class/struct definitions for correct
	R6 ABI compatibility, then provide the method bodies from the UT99 version.
=============================================================================*/

// Include the CSDK version first — it has correct struct layout but commented-out bodies.
// We'll provide method bodies inline below, sourced from the UT99 public source.
#include "../../sdk/Raven_Shield_C_SDK/432Core/Inc/FMallocWindows.h"

// The CSDK header declares these methods without bodies (body in comments).
// Provide complete implementations from the UT99 public source.

inline void* FMallocWindows::Malloc( DWORD Size, const TCHAR* Tag )
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
			Pool->Mem			 = (BYTE*)Free;
			Pool->Bytes			 = Bytes;
			Pool->OsBytes		 = Align(Bytes,GPageSize);
			STAT(OsPeak = Max(OsPeak,OsCurrent+=Pool->OsBytes));
			Pool->Table			 = Table;
			Pool->Taken			 = 0;
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
				// Move to exhausted list.
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
		checkSlow(!((SIZE_T)Free & 65535));

		// Create indirect.
		FPoolInfo*& Indirect = PoolIndirect[((DWORD)Free>>24)];
		if( !Indirect )
			Indirect = CreateIndirect();

		// Init pool.
		FPoolInfo* Pool = &Indirect[((DWORD)Free>>16)&255];
		Pool->Mem		= (BYTE*)Free;
		Pool->Bytes		= Size;
		Pool->OsBytes	= AlignedSize;
		Pool->Table		= &OsTable;

		STAT(OsPeak   = Max(OsPeak,  OsCurrent+=AlignedSize));
		STAT(UsedPeak = Max(UsedPeak,UsedCurrent+=Size));
	}
	MEM_TIME(MemTime += appSeconds());
	return Free;
	unguard;
}

inline void* FMallocWindows::Realloc( void* Ptr, DWORD NewSize, const TCHAR* Tag )
{
	guard(FMallocWindows::Realloc);
	// Diagnostic: catch insane allocation sizes
	if( NewSize > 0x40000000 ) {
		// Write to diag file before crashing
		HANDLE hf = CreateFileA("diag_malloc.txt", GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, 0, NULL);
		if(hf != INVALID_HANDLE_VALUE) {
			char buf[256];
			wsprintfA(buf, "HUGE Realloc! Ptr=%p NewSize=0x%08X (%d)\n", Ptr, NewSize, (INT)NewSize);
			DWORD written;
			WriteFile(hf, buf, lstrlenA(buf), &written, NULL);
			CloseHandle(hf);
		}
	}
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

inline void FMallocWindows::Free( void* Ptr )
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
		// If this pool was exhausted, move to available list.
		if( !Pool->FirstMem )
		{
			Pool->Unlink();
			Pool->Link( Pool->Table->FirstPool );
		}

		// Free a pooled allocation.
		FFreeMem* Free		= (FFreeMem*)Ptr;
		Free->Blocks		= 1;
		Free->Next			= Pool->FirstMem;
		Pool->FirstMem		= Free;
		STAT(UsedCurrent -= Pool->Table->BlockSize);

		// Free the pool if it has become empty.
		if( --Pool->Taken==0 )
		{
			Pool->Unlink();
			verify( VirtualFree( Pool->Mem, 0, MEM_RELEASE )!=0 );
			STAT(OsCurrent -= Pool->OsBytes);
		}
	}
	else
	{
		// Free an OS allocation.
		checkSlow(((INT)Ptr&65535)==0);
		STAT(UsedCurrent -= Pool->Bytes);
		STAT(OsCurrent -= Pool->OsBytes);
		verify( VirtualFree( Ptr, 0, MEM_RELEASE )!=0 );
	}
	MEM_TIME(MemTime += appSeconds());
	unguard;
}
