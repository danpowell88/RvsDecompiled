/*=============================================================================
	SNDext.cpp: DARE Sound Engine extension / platform abstraction layer.
	Reconstructed for Ravenshield decompilation project.

	SNDext provides platform-specific services to the DARE sound engine:
	memory allocation, file I/O, error display, and asynchronous streaming.
	Two retail variants exist (SNDext_ret.dll and SNDext_VSR.dll) with
	identical export tables.

	Retail binary analysis (SNDext_ret.dll, 2004-10-08):
	  Imports from Core.dll:    ?GMalloc@@3PAVFMalloc@@A
	  Imports from KERNEL32:    CreateFileA, ReadFile, SetFilePointer,
	                            CloseHandle, FindFirstFileA, FindClose,
	                            WaitForSingleObject, ReleaseMutex, CreateMutexA
	  Imports from USER32:      MessageBoxA
	  Imports from MSVCR71:     malloc, free, memmove, sprintf, strncpy

	Memory strategy:
	  pvMallocSnd / pvReAllocSnd / pvFreeSnd
	    Retail routes these through GMalloc (Unreal allocator from Core.dll).
	    Clean-room: process heap (HeapAlloc/HeapFree).
	    Divergence documented — behaviour is identical from the caller's view.

	  pvMallocSndAligned / vFreeSndAligned
	    Retail uses CRT malloc with a 4-byte header storing the base pointer.
	    Clean-room: _aligned_malloc / _aligned_free.
	    Same divergence note applies.

	Async streaming:
	  The retail uses a 300-byte (0x12C) per-stream descriptor and Win32
	  overlapped I/O (WaitForSingleObject + CreateMutexA).
	  State machine: 0 = idle, 2 = done (observed from bIsLastStreamAsyncDoneSnd
	  disassembly: returns 1 iff descriptor[+0] == 2).
	  Clean-room: synchronous ReadFile fallback with the same state values.
	  The hFile field in the descriptor (offset +0x08) must be populated by
	  the caller before vStartStreamAsyncSnd; otherwise silence is returned.

	32 exports (all __stdcall C linkage).
=============================================================================*/

#pragma warning(disable: 4100) // unreferenced formal parameter

#include <windows.h>
#include <malloc.h>   // _aligned_malloc / _aligned_free
#include <string.h>   // memcpy, memmove, memset

/*-----------------------------------------------------------------------------
	DllMain entry point.
-----------------------------------------------------------------------------*/

BOOL WINAPI DllMain( HINSTANCE hInDLL, DWORD dwReason, LPVOID lpReserved )
{
	return TRUE;
}

/*-----------------------------------------------------------------------------
	Error handling.
	Retail byte analysis:
	  vDisplayError       = C2 08 00  (ret 8  — no-op)
	  vDisplayErrorEx     = C2 0C 00  (ret 12 — no-op; same RVA as _snd_assert)
	  vInitErrorSnd       = stores *(iParam+4) globally, zeroes 43-DWORD table
	  vDesInitErrorSnd    = C3        (ret    — same RVA as vDesInitMallocSnd)
	  _snd_assert         = C2 0C 00  (ret 12 — aliased to vDisplayErrorEx)
	  _snd_assert_message = C2 10 00  (ret 16 — no-op)
	All are intentional no-ops in the retail release build.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDisplayError( int iCode, int iSeverity )
{
	// retail: ret 8 — no-op
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDisplayErrorEx( int iCode, int iSeverity, int iExtra )
{
	// retail: ret 12 — no-op; _snd_assert shares this address
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vInitErrorSnd( int iParam )
{
	// retail: stores *(iParam+4) into global, zeroes 43-DWORD error table
	// clean-room: no-op (error table not used in our stub implementation)
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitErrorSnd()
{
	// retail: ret (same RVA as vDesInitMallocSnd) — no-op
}

extern "C" __declspec(dllexport) void __stdcall _snd_assert( int iCode, int iLine, int iFile )
{
	// retail: ret 12 — aliased to vDisplayErrorEx
}

extern "C" __declspec(dllexport) void __stdcall _snd_assert_message( int iCode, int iLine, int iFile, int iMsg )
{
	// retail: ret 16 — no-op in release build
}

/*-----------------------------------------------------------------------------
	Sound driver busy probe.
	Retail: shows MessageBoxA(MB_SETFOREGROUND | MB_RETRYCANCEL) when the
	        audio driver is occupied by another app; returns non-zero if the
	        user clicks Retry.
	Clean-room: returns 0 (not busy) to avoid blocking dialogs in batch/
	        automated contexts and because modern hardware rarely contends.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) int __stdcall SND_fn_iSoundDriverBusy( int iParam )
{
	return 0; // 0 = not busy (treat as "cancel")
}

/*-----------------------------------------------------------------------------
	File I/O — thin Win32 wrappers.
	Retail uses: CreateFileA, ReadFile, SetFilePointer, CloseHandle,
	             FindFirstFileA, FindClose.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) void* __stdcall SND_fn_hOpenFileReadSnd( const char* pszFileName )
{
	// retail: CreateFileA(name, GENERIC_READ, FILE_SHARE_READ, NULL,
	//                     OPEN_EXISTING, 0, NULL)  — dwFlagsAndAttributes=0
	// Returns INVALID_HANDLE_VALUE on failure (normalised to NULL here).
	HANDLE h = CreateFileA( pszFileName,
	                        GENERIC_READ,
	                        FILE_SHARE_READ,
	                        NULL,
	                        OPEN_EXISTING,
	                        FILE_ATTRIBUTE_NORMAL,
	                        NULL );
	return ( h == INVALID_HANDLE_VALUE ) ? NULL : (void*)h;
}

extern "C" __declspec(dllexport) unsigned long __stdcall SND_fn_ulReadFileSnd( void* hFile, void* pBuffer, unsigned long ulSize )
{
	// retail: ReadFile; returns bytes actually read
	DWORD dwRead = 0;
	if ( !ReadFile( (HANDLE)hFile, pBuffer, ulSize, &dwRead, NULL ) )
		return 0;
	return (unsigned long)dwRead;
}

extern "C" __declspec(dllexport) unsigned long __stdcall SND_fn_ulSeekFileSnd( void* hFile, long lOffset, unsigned long ulOrigin )
{
	// retail: SetFilePointer; DARE passes ulOrigin == 0/1/2 matching Win32
	//         FILE_BEGIN / FILE_CURRENT / FILE_END directly.
	return SetFilePointer( (HANDLE)hFile, lOffset, NULL, ulOrigin );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vCloseFileSnd( void* hFile )
{
	// retail: FF 25 xx xx xx xx = jmp [CloseHandle] — single thunk instruction
	if ( hFile )
		CloseHandle( (HANDLE)hFile );
}

extern "C" __declspec(dllexport) char __stdcall SND_fn_cGetDirectorySeparator()
{
	// retail: B0 5C C3 = mov al,'\\'; ret — confirmed exact match
	return '\\';
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_bTestFileExistSnd( const char* pszFileName )
{
	// retail: allocates a 320-byte stack buffer, uses CreateFileA / CloseHandle
	//         to test existence.  GetFileAttributesA is semantically equivalent.
	return ( GetFileAttributesA( pszFileName ) != INVALID_FILE_ATTRIBUTES ) ? 1 : 0;
}

/*-----------------------------------------------------------------------------
	Memory management.
	See file header for divergence notes.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) int __stdcall SND_fn_bInitMallocSnd()
{
	// retail: initialises an internal allocator pair (Malloc/Free pointers)
	//         sourced from GMalloc.  Returns 1 on success.
	// clean-room: process heap is always ready; unconditional success.
	return 1;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitMallocSnd()
{
	// retail: ret (same RVA as vDesInitErrorSnd) — no-op
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvMallocSnd( unsigned long ulSize )
{
	// retail: GMalloc->Malloc(ulSize, tag)
	return HeapAlloc( GetProcessHeap(), 0, ulSize );
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvMallocSndAligned( unsigned long ulSize, unsigned long ulAlignment )
{
	// retail: CRT malloc(size + align + 8), stores base ptr at [result-4].
	// clean-room: _aligned_malloc (same semantic, different header layout).
	if ( ulSize == 0 ) return NULL;
	if ( ulAlignment <= 1 ) return HeapAlloc( GetProcessHeap(), 0, ulSize );
	return _aligned_malloc( ulSize, ulAlignment );
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvReAllocSnd( void* pMem, unsigned long ulSize )
{
	// retail: GMalloc->Realloc(pMem, ulSize, tag)
	if ( !pMem ) return HeapAlloc( GetProcessHeap(), 0, ulSize );
	return HeapReAlloc( GetProcessHeap(), 0, pMem, ulSize );
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvReAllocSndAligned( void* pMem, unsigned long ulSize, unsigned long ulAlignment )
{
	// retail: custom aligned realloc (reads [pMem-4] original ptr, malloc new,
	//         copy, free old).
	// clean-room: _aligned_malloc + memcpy + _aligned_free.
	if ( !pMem ) return SND_fn_pvMallocSndAligned( ulSize, ulAlignment );
	if ( ulAlignment <= 1 ) return HeapReAlloc( GetProcessHeap(), 0, pMem, ulSize );
	void* pNew = _aligned_malloc( ulSize, ulAlignment );
	if ( !pNew ) return NULL;
	memcpy( pNew, pMem, ulSize );
	_aligned_free( pMem );
	return pNew;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vFreeSnd( void* pMem )
{
	// retail: GMalloc->Free(pMem) via vtable[2]  (FF 62 08 = jmp [edx+8])
	if ( pMem ) HeapFree( GetProcessHeap(), 0, pMem );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vFreeSndAligned( void* pMem, unsigned long ulAlignment )
{
	// retail: reads *(pMem-4) = original CRT-malloc ptr, calls CRT free on it.
	// clean-room: _aligned_free handles the header transparently.
	if ( !pMem ) return;
	if ( ulAlignment <= 1 ) HeapFree( GetProcessHeap(), 0, pMem );
	else _aligned_free( pMem );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemCopySnd( void* pDst, const void* pSrc, unsigned long ulSize )
{
	// retail: opt. MMX 16-byte copy loop (MOVQ mm0,[esi]; MOVQ mm1,[esi+8]; ...)
	memcpy( pDst, pSrc, ulSize );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemMoveSnd( void* pDst, const void* pSrc, unsigned long ulSize )
{
	// retail: direct tail-call to memmove via IAT  (FF 15 xx xx xx xx)
	memmove( pDst, pSrc, ulSize );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemsetSnd( void* pDst, int iValue, unsigned long ulSize )
{
	// retail: opt. MMX 16-byte fill loop
	memset( pDst, iValue, ulSize );
}

/*-----------------------------------------------------------------------------
	Asynchronous streaming — synchronous ReadFile fallback.

	Retail state machine (from disassembly):
	  descriptor[+0x00] int   state     0 = idle   2 = done
	  descriptor[+0x04] HANDLE hMutex   per-stream Win32 mutex
	  descriptor[+0x08] HANDLE          file / descriptor handle
	  descriptor[+0x0C] DWORD           current position / offset
	  descriptor[+0x10] DWORD           max bytes per read
	  descriptor[+0x14..+0x12B] fields zeroed by vAbortLastStreamAsyncSnd

	300-byte total size confirmed from: hCreateStreamAsyncSnd calls
	  pvMallocSnd(0x12C) where 0x12C == 300.

	bIsLastStreamAsyncDoneSnd returns (state == 2).
	vAbortLastStreamAsyncSnd zeroes descriptors[0,8,C,10,14,20,24,28].
	vDestroyStreamAsyncSnd loads descriptor[+4] (the mutex HANDLE) before
	  zeroing the struct and freeing it.

	Clean-room: synchronous ReadFile; state transitions to DONE immediately.
	  The hFile field (descriptor[+0x08]) must be populated by the layer
	  above (DareAudio) before vStartStreamAsyncSnd is called, otherwise
	  the buffer is zero-filled (silence).
-----------------------------------------------------------------------------*/

#define SND_STREAM_BYTES  0x12C
#define SND_STATE_IDLE    0
#define SND_STATE_DONE    2

struct SndStream
{
	int    state;                                      // [+0x00]
	HANDLE hMutex;                                     // [+0x04]
	HANDLE hFile;                                      // [+0x08] caller-populated
	DWORD  ulPos;                                      // [+0x0C]
	DWORD  ulLast;                                     // [+0x10] bytes from last read
	BYTE   _pad[ SND_STREAM_BYTES - 5 * (int)sizeof(DWORD) ]; // [+0x14..+0x12B]
};

static_assert( sizeof(SndStream) == SND_STREAM_BYTES, "SndStream size mismatch" );

extern "C" __declspec(dllexport) int __stdcall SND_fn_bInitStreamAsyncSnd( int iMaxBytesPerRead, int iStreamCount )
{
	// retail: FPU multiply of the two params, stores result in a global.
	return 1;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitStreamAsyncSnd()
{
	// retail: jmp to a cleanup routine; nothing global to release here.
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_hCreateStreamAsyncSnd( int iParam1, int iParam2 )
{
	// retail: pvMallocSnd(300), then CreateMutexA for descriptor[+4].
	SndStream* s = (SndStream*)SND_fn_pvMallocSnd( sizeof(SndStream) );
	if ( !s ) return (void*)-1;   // retail returns -1 (INVALID_HANDLE_VALUE) on OOM
	memset( s, 0, sizeof(SndStream) );
	s->hMutex = CreateMutexA( NULL, FALSE, NULL );
	s->hFile  = INVALID_HANDLE_VALUE;
	s->state  = SND_STATE_DONE;   // ready for first Start call
	return s;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDestroyStreamAsyncSnd( void* hStream )
{
	if ( !hStream || hStream == (void*)-1 ) return;
	SndStream* s = (SndStream*)hStream;
	// retail: loads descriptor[+4] first, zeroes struct, frees descriptor.
	if ( s->hMutex ) CloseHandle( s->hMutex );
	// hFile is caller-owned; we do not close it here.
	SND_fn_vFreeSnd( s );
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vAbortLastStreamAsyncSnd( void* hStream )
{
	if ( !hStream || hStream == (void*)-1 ) return;
	SndStream* s = (SndStream*)hStream;
	// retail zeroes descriptor fields: [0],[8],[0xC],[0x10],[0x14],[0x20],[0x24],[0x28]
	s->state  = SND_STATE_IDLE;
	s->ulLast = 0;
	s->ulPos  = 0;
	memset( s->_pad, 0, sizeof(s->_pad) );
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_bIsLastStreamAsyncDoneSnd( void* hStream )
{
	// retail: returns (descriptor[+0] == 2) ? 1 : 0
	if ( !hStream || hStream == (void*)-1 ) return 1;
	SndStream* s = (SndStream*)hStream;
	return ( s->state == SND_STATE_DONE ) ? 1 : 0;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vStartStreamAsyncSnd( void* hStream, void* pBuffer, unsigned long ulSize )
{
	if ( !hStream || hStream == (void*)-1 || !pBuffer || ulSize == 0 ) return;
	SndStream* s = (SndStream*)hStream;
	// retail only starts if state == 0 (idle) or state == 2 (done); skips if
	// state == 1 or any other value.
	if ( s->state != SND_STATE_IDLE && s->state != SND_STATE_DONE ) return;

	DWORD dwRead = 0;
	if ( s->hFile != NULL && s->hFile != INVALID_HANDLE_VALUE )
	{
		ReadFile( s->hFile, pBuffer, ulSize, &dwRead, NULL );
	}
	else
	{
		// No file associated: return silence.
		memset( pBuffer, 0, ulSize );
		dwRead = ulSize;
	}
	s->ulLast = dwRead;
	s->state  = SND_STATE_DONE;
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_eSynchStreamAsyncSnd( void* hStream, void* pBuffer, unsigned long ulSize, int iParam4 )
{
	// retail: large stack frame, synchronous read.  Used when caller cannot poll.
	if ( !hStream || hStream == (void*)-1 || !pBuffer || ulSize == 0 ) return 0;
	SndStream* s = (SndStream*)hStream;

	DWORD dwRead = 0;
	if ( s->hFile != NULL && s->hFile != INVALID_HANDLE_VALUE )
	{
		ReadFile( s->hFile, pBuffer, ulSize, &dwRead, NULL );
	}
	else
	{
		memset( pBuffer, 0, ulSize );
		dwRead = ulSize;
	}
	s->ulLast = dwRead;
	s->state  = SND_STATE_DONE;
	return (int)dwRead;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
