/*=============================================================================
	UnLog.cpp: FOutputDevice implementations — logging, error handling.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FOutputDevice base class implementation.
-----------------------------------------------------------------------------*/

void FOutputDevice::Log( const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, NAME_Log );
	unguard;
}

void FOutputDevice::Log( enum EName Type, const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, Type );
	unguard;
}

void FOutputDevice::Log( const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, NAME_Log );
	unguard;
}

void FOutputDevice::Log( enum EName Type, const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, Type );
	unguard;
}

void FOutputDevice::Logf( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	Serialize( TempStr, NAME_Log );
}

void FOutputDevice::Logf( enum EName Type, const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	Serialize( TempStr, Type );
}

/*-----------------------------------------------------------------------------
	FOutputDeviceNull — silent/discarding output.
-----------------------------------------------------------------------------*/

// Implementation is entirely in the header (inline Serialize that does nothing).

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
