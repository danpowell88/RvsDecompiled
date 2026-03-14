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
	FErrorOutError / FLogOutError / FNullOutError / FThrowOut classes.
-----------------------------------------------------------------------------*/

FErrorOutError::FErrorOutError() {}
FErrorOutError::FErrorOutError( const FErrorOutError& ) {}
FErrorOutError& FErrorOutError::operator=( const FErrorOutError& ) { return *this; }
void FErrorOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GError )
		GError->Serialize( V, Event );
}
void FErrorOutError::HandleError()
{
	if( GError )
		GError->HandleError();
}

FLogOutError::FLogOutError() {}
FLogOutError::FLogOutError( const FLogOutError& ) {}
FLogOutError& FLogOutError::operator=( const FLogOutError& ) { return *this; }
void FLogOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GLog )
		GLog->Serialize( V, Event );
}

FNullOutError::FNullOutError() {}
FNullOutError::FNullOutError( const FNullOutError& ) {}
FNullOutError& FNullOutError::operator=( const FNullOutError& ) { return *this; }
void FNullOutError::Serialize( const TCHAR* V, EName Event )
{
	guard(FNullOutError::Serialize);
	// Retail 0x1290: shared null-stub, no-op.
	unguard;
}

FThrowOut::FThrowOut() {}
FThrowOut::FThrowOut( const FThrowOut& ) {}
FThrowOut& FThrowOut::operator=( const FThrowOut& ) { return *this; }
void FThrowOut::Serialize( const TCHAR* V, EName Event )
{
	appThrowf( TEXT("%s"), V );
}

/*-----------------------------------------------------------------------------
	FFrame::Serialize.
-----------------------------------------------------------------------------*/

void FFrame::Serialize( const TCHAR* V, EName Event )
{
	guard(FFrame::Serialize);
	// Retail 0x1bd50: logs script frame context to GLog or GError.
	// TODO: implement FFrame::Serialize (retail 0x1bd50: logs script frame context to GLog/GError)
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
