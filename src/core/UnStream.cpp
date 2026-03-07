/*=============================================================================
	UnStream.cpp: FFileStream — Ravenshield streaming file I/O.
	Copyright 1997-2003 Epic Games / Ubisoft. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Raven_Shield_C_SDK/inc/CoreClasses.h L3247
	This is a Ravenshield-specific extension not present in UT99.
=============================================================================*/

#include "CorePrivate.h"

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
	if( !Instance )
	{
		Instance   = new FFileStream();
		MaxStreams  = InMaxStreams;
		Destroyed  = 0;
		GFileStream = Instance;
	}
	return Instance;
}

void FFileStream::Destroy()
{
	if( Instance )
	{
		delete Instance;
		Instance    = NULL;
		GFileStream = NULL;
		Destroyed   = 1;
	}
}

INT FFileStream::Create( INT StreamId, const TCHAR* Filename )
{
	guard(FFileStream::Create);
	return 0;
	unguard;
}

INT FFileStream::CreateStream( const TCHAR* Filename, INT Offset, INT Size, void* Buffer, EFileStreamType Type, void* Callback )
{
	guard(FFileStream::CreateStream);
	return 0;
	unguard;
}

INT FFileStream::Destroy( INT StreamId )
{
	guard(FFileStream::Destroy_Stream);
	return 0;
	unguard;
}

void FFileStream::DestroyStream( INT StreamId, INT bForce )
{
	guard(FFileStream::DestroyStream);
	unguard;
}

void FFileStream::Enter( INT StreamId )
{
	guard(FFileStream::Enter);
	unguard;
}

void FFileStream::Leave( INT StreamId )
{
	guard(FFileStream::Leave);
	unguard;
}

INT FFileStream::QueryStream( INT StreamId, INT& OutStatus )
{
	guard(FFileStream::QueryStream);
	OutStatus = 0;
	return 0;
	unguard;
}

INT FFileStream::Read( INT StreamId, INT NumBytes )
{
	guard(FFileStream::Read);
	return 0;
	unguard;
}

void FFileStream::RequestChunks( INT StreamId, INT NumChunks, void* ChunkInfo )
{
	guard(FFileStream::RequestChunks);
	unguard;
}

FFileStream& FFileStream::operator=( const FFileStream& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
