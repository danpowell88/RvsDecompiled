/*=============================================================================
	SNDext.cpp: DARE Sound Engine extension / platform abstraction layer.
	Reconstructed for Ravenshield decompilation project.

	SNDext provides platform-specific services to the DARE sound engine:
	memory allocation (routing to Unreal's GMalloc), file I/O, error
	display, and asynchronous streaming. Two retail variants exist
	(SNDext_ret.dll and SNDext_VSR.dll) with identical export tables
	but different internal implementations.

	32 exports (all __stdcall C linkage).
=============================================================================*/

#pragma warning(disable: 4100) // unreferenced formal parameter

#include <windows.h>

/*-----------------------------------------------------------------------------
	DllMain entry point.
-----------------------------------------------------------------------------*/

BOOL WINAPI DllMain( HINSTANCE hInDLL, DWORD dwReason, LPVOID lpReserved )
{
	return TRUE;
}

/*-----------------------------------------------------------------------------
	Error handling.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDisplayError( int iCode, int iSeverity )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDisplayErrorEx( int iCode, int iSeverity, int iExtra )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vInitErrorSnd( int iParam )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitErrorSnd()
{
}

extern "C" __declspec(dllexport) void __stdcall _snd_assert( int iCode, int iLine, int iFile )
{
}

extern "C" __declspec(dllexport) void __stdcall _snd_assert_message( int iCode, int iLine, int iFile, int iMsg )
{
}

/*-----------------------------------------------------------------------------
	File I/O — thin wrappers around Win32 file API.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) int __stdcall SND_fn_iSoundDriverBusy( int iParam )
{
	return 0;
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_hOpenFileReadSnd( const char* pszFileName )
{
	return NULL;
}

extern "C" __declspec(dllexport) unsigned long __stdcall SND_fn_ulReadFileSnd( void* hFile, void* pBuffer, unsigned long ulSize )
{
	return 0;
}

extern "C" __declspec(dllexport) unsigned long __stdcall SND_fn_ulSeekFileSnd( void* hFile, long lOffset, unsigned long ulOrigin )
{
	return 0;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vCloseFileSnd( void* hFile )
{
}

extern "C" __declspec(dllexport) char __stdcall SND_fn_cGetDirectorySeparator()
{
	return '\\';
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_bTestFileExistSnd( const char* pszFileName )
{
	return 0;
}

/*-----------------------------------------------------------------------------
	Memory management — routes through Unreal's GMalloc.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) int __stdcall SND_fn_bInitMallocSnd()
{
	return 1;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitMallocSnd()
{
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvMallocSnd( unsigned long ulSize )
{
	return NULL;
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvMallocSndAligned( unsigned long ulSize, unsigned long ulAlignment )
{
	return NULL;
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvReAllocSnd( void* pMem, unsigned long ulSize )
{
	return NULL;
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_pvReAllocSndAligned( void* pMem, unsigned long ulSize, unsigned long ulAlignment )
{
	return NULL;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vFreeSnd( void* pMem )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vFreeSndAligned( void* pMem, unsigned long ulAlignment )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemCopySnd( void* pDst, const void* pSrc, unsigned long ulSize )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemMoveSnd( void* pDst, const void* pSrc, unsigned long ulSize )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vMemsetSnd( void* pDst, int iValue, unsigned long ulSize )
{
}

/*-----------------------------------------------------------------------------
	Asynchronous streaming.
-----------------------------------------------------------------------------*/

extern "C" __declspec(dllexport) int __stdcall SND_fn_bInitStreamAsyncSnd( int iParam1, int iParam2 )
{
	return 1;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDesInitStreamAsyncSnd()
{
}

extern "C" __declspec(dllexport) void* __stdcall SND_fn_hCreateStreamAsyncSnd( int iParam1, int iParam2 )
{
	return NULL;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vDestroyStreamAsyncSnd( void* hStream )
{
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vAbortLastStreamAsyncSnd( void* hStream )
{
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_bIsLastStreamAsyncDoneSnd( void* hStream )
{
	return 1;
}

extern "C" __declspec(dllexport) void __stdcall SND_fn_vStartStreamAsyncSnd( void* hStream, void* pBuffer, unsigned long ulSize )
{
}

extern "C" __declspec(dllexport) int __stdcall SND_fn_eSynchStreamAsyncSnd( void* hStream, void* pBuffer, unsigned long ulSize, int iParam4 )
{
	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
