/*=============================================================================
	UnStream.cpp: FFileStream — Ravenshield streaming file I/O.
	Copyright 1997-2003 Epic Games / Ubisoft. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Raven_Shield_C_SDK/inc/CoreClasses.h L3247
	This is a Ravenshield-specific extension not present in UT99.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FStream — per-slot streaming state.

	Each FFileStream::Streams slot is 0x28 bytes.  Field names and types
	were recovered from Ghidra offset analysis of the retail binary.
-----------------------------------------------------------------------------*/

// Ogg Vorbis support requires headers from the vorbisfile SDK (not bundled).
// Define WITH_VORBIS and supply vorbisfile.h / vorbisfile.lib to enable.
#ifdef WITH_VORBIS
#include "vorbis/vorbisfile.h"
#else
// Minimal opaque type so the struct compiles without the vorbis SDK.
// DIVERGENCE: OggVorbis_File is not the real struct; Ogg code paths
// are disabled.  The retail binary linked against vorbisfile.dll directly.
typedef struct { char _opaque[120]; } OggVorbis_File;
#endif

struct FStream
{
	void*          Buffer;              // +0x00  read/write data buffer (advanced after each Win32 read)
	HANDLE         FileHandle;          // +0x04  Win32 file HANDLE (or FILE* cast for Ogg)
	OggVorbis_File* VorbisFile;         // +0x08  pre-allocated OggVorbis_File* supplied by caller; also stores callback for generic streams
	INT            VorbisSection;       // +0x0C  current Ogg section index (written by ov_read)
	INT            BlockSize;           // +0x10  bytes per streaming chunk
	INT            ChunkCount;          // +0x14  number of chunks requested so far
	INT            Lock;                // +0x18  spinlock: 0=free, 1=held
	INT            bActive;             // +0x1C  non-zero when stream is open/active
	INT            bError;              // +0x20  non-zero on I/O error
	EFileStreamType Type;               // +0x24  stream type (FST_Unknown=Win32, FST_Read/Write=Ogg)
};
static_assert( sizeof(FStream) == 0x28, "FStream must be 0x28 bytes" );

/*-----------------------------------------------------------------------------
	FFileStream — singleton streaming file manager.

	Provides asynchronous/chunked file I/O for map streaming.
	The retail binary exports these as non-virtual class methods.
-----------------------------------------------------------------------------*/

// Static instance (GFileStream is exported from retail Core.dll).
CORE_API FFileStream* GFileStream = NULL;

// Static member variable definitions (exported as @@2 symbols in .def).
FFileStream* FFileStream::Instance   = NULL;
INT          FFileStream::Destroyed  = 0;
INT          FFileStream::MaxStreams  = 0;
INT          FFileStream::StreamIndex = 0;
FStream*     FFileStream::Streams    = NULL;

FFileStream::FFileStream()
{
}

FFileStream::~FFileStream()
{
}

FFileStream* FFileStream::Init( INT InMaxStreams )
{
	// Ghidra: Instance is allocated with GMalloc->Malloc(sizeof(FFileStream)).
	// sizeof(FFileStream) == 1 (no instance data; all members are static).
	if( !Instance )
	{
		Instance    = new FFileStream();
		MaxStreams   = InMaxStreams;
		Destroyed   = 0;
		Streams     = (FStream*)appMalloc( InMaxStreams * sizeof(FStream), TEXT("FFileStream") );
		appMemzero( Streams, InMaxStreams * sizeof(FStream) );
		GFileStream = Instance;
	}
	return Instance;
}

void FFileStream::Destroy()
{
	// DIVERGENCE: The retail binary sets Destroyed=1 and then busy-waits for a
	// background streaming thread to drain (the thread signals Destroyed=0 when
	// done).  We have no streaming thread, so we skip the wait.
	if( Instance )
	{
		Destroyed = 1;
		if( Streams )
		{
			appFree( Streams );
			Streams = NULL;
		}
		delete Instance;
		Instance    = NULL;
		GFileStream = NULL;
	}
}

INT FFileStream::Create( INT StreamId, const TCHAR* Filename )
{
	guard(FFileStream::Create);
	check( Streams );
	FStream& S = Streams[StreamId];

	if( S.Type != FST_Unknown )
	{
		// Ogg Vorbis stream (FST_Read or FST_Write).
		if( (INT)S.Type < 1 || (INT)S.Type > 2 )
			return 0;
#ifdef WITH_VORBIS
		FILE* f = NULL;
		if( GUnicodeOS )
			f = _wfopen( Filename, TEXT("rb") );
		else
		{
			ANSICHAR ACh[1024];
			winToANSI( ACh, Filename, ARRAY_COUNT(ACh) );
			f = fopen( ACh, "rb" );
		}
		if( !f )
			return 0;
		if( ov_open( f, S.VorbisFile, NULL, 0 ) < 0 )
			return 0;
		S.FileHandle = (HANDLE)f;
		return 1;
#else
		// DIVERGENCE: Ogg Vorbis not available at build time.
		return 0;
#endif
	}

	// Win32 raw file stream.
	HANDLE hFile;
	if( GUnicodeOS )
	{
		hFile = CreateFileW( Filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
	}
	else
	{
		ANSICHAR ACh[1024];
		winToANSI( ACh, Filename, ARRAY_COUNT(ACh) );
		hFile = CreateFileA( ACh, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL );
	}

	if( hFile == INVALID_HANDLE_VALUE )
	{
		S.FileHandle = NULL;
		return 0;
	}
	S.FileHandle = hFile;
	return 1;
	unguard;
}

INT FFileStream::CreateStream( const TCHAR* Filename, INT BlockSizeIn, INT NumChunks, void* Buffer, EFileStreamType Type, void* Callback )
{
	guard(FFileStream::CreateStream);
	check( Streams );
	INT Idx = StreamIndex;
	FStream& S = Streams[Idx];

	// Acquire lock and wait if busy.
	while( S.Lock )
		appSleep( 0.0f );
	S.Lock = 1;

	S.Type       = Type;
	S.VorbisFile = (OggVorbis_File*)Callback;
	S.Lock       = 1; // keep locked while creating

	if( !Create( Idx, Filename ) )
	{
		appMemzero( &S, sizeof(FStream) );
		return -1;
	}

	S.Buffer     = Buffer;
	S.BlockSize  = BlockSizeIn;
	S.ChunkCount = 0;
	S.bError     = 0;
	S.bActive    = 1;
	Read( Idx, BlockSizeIn * NumChunks );

	S.Lock = 0;
	StreamIndex = (StreamIndex + 1) % MaxStreams;
	return Idx;
	unguard;
}

INT FFileStream::Destroy( INT StreamId )
{
	guard(FFileStream::Destroy_Stream);
	check( Streams );
	FStream& S = Streams[StreamId];

	if( S.Type == FST_Unknown )
	{
		if( S.FileHandle )
			CloseHandle( S.FileHandle );
		S.VorbisFile = NULL;
		S.FileHandle = NULL;
		S.bActive    = 0;
		return 1;
	}
	if( (INT)S.Type > 0 && (INT)S.Type < 3 )
	{
#ifdef WITH_VORBIS
		if( S.VorbisFile )
			ov_clear( S.VorbisFile );
#endif
		S.VorbisFile = NULL;
		S.FileHandle = NULL;
		S.bActive    = 0;
		return 1;
	}
	return 0;
	unguard;
}

void FFileStream::DestroyStream( INT StreamId, INT bForce )
{
	guard(FFileStream::DestroyStream);
	check( Streams );
	FStream& S = Streams[StreamId];

	while( S.Lock )
		appSleep( 0.0f );
	S.Lock = 1;

	if( S.bActive )
	{
		if( bForce )
			Read( StreamId, S.ChunkCount * S.BlockSize );
		Destroy( StreamId );
	}
	S.Lock = 0;
	unguard;
}

void FFileStream::Enter( INT StreamId )
{
	guard(FFileStream::Enter);
	check( Streams );
	FStream& S = Streams[StreamId];
	while( S.Lock )
		appSleep( 0.0f );
	S.Lock = 1;
	unguard;
}

void FFileStream::Leave( INT StreamId )
{
	guard(FFileStream::Leave);
	check( Streams );
	Streams[StreamId].Lock = 0;
	unguard;
}

INT FFileStream::QueryStream( INT StreamId, INT& OutStatus )
{
	guard(FFileStream::QueryStream);
	check( Streams );
	FStream& S = Streams[StreamId];

	while( S.Lock )
		appSleep( 0.0f );
	S.Lock = 1;

	OutStatus = S.ChunkCount;

	INT Result = 0;
	if( S.bError == 0 && S.bActive )
		Result = 1;

	S.Lock = 0;
	return Result;
	unguard;
}

INT FFileStream::Read( INT StreamId, INT NumBytes )
{
	guard(FFileStream::Read);
	check( Streams );
	FStream& S = Streams[StreamId];

	if( !S.FileHandle || !S.Buffer )
		return 0;

	if( S.Type == FST_Unknown )
	{
		// Win32 raw file read.
		DWORD BytesRead = 0;
		BOOL bOK = ReadFile( S.FileHandle, S.Buffer, NumBytes, &BytesRead, NULL );
		if( bOK )
			S.Buffer = (BYTE*)S.Buffer + BytesRead; // advance write pointer
		if( BytesRead != (DWORD)NumBytes )
			S.bError = 1;
		return bOK ? 1 : 0;
	}

	if( (INT)S.Type > 0 && (INT)S.Type < 3 )
	{
#ifdef WITH_VORBIS
		// Ogg Vorbis streaming read.
		if( NumBytes < 1 )
			return 1;
		INT Offset = 0;
		do
		{
			long nRead = ov_read( S.VorbisFile, (char*)S.Buffer + Offset, NumBytes - Offset, 0, 2, 1, &S.VorbisSection );
			if( nRead == 0 )
			{
				// End of stream.
				if( S.Type != FST_Write ) // FST_Write = looping
				{
					// Zero remaining bytes and flag error.
					appMemzero( (BYTE*)S.Buffer + Offset, NumBytes - Offset );
					S.bError = 1;
					return 0;
				}
				ov_time_seek( S.VorbisFile, 0.0 ); // loop back to start
			}
			else if( nRead < 0 )
			{
				return 0; // decode error
			}
			else
			{
				Offset += (INT)nRead;
			}
		} while( Offset < NumBytes );
		return 1;
#else
		// DIVERGENCE: Ogg Vorbis not available.
		return 0;
#endif
	}

	return 0;
	unguard;
}

void FFileStream::RequestChunks( INT StreamId, INT NumChunks, void* ChunkInfo )
{
	guard(FFileStream::RequestChunks);
	check( Streams );
	FStream& S = Streams[StreamId];

	while( S.Lock )
		appSleep( 0.0f );
	S.Lock = 1;

	S.ChunkCount += NumChunks;
	S.Buffer      = ChunkInfo;

	S.Lock = 0;
	unguard;
}

FFileStream& FFileStream::operator=( const FFileStream& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
