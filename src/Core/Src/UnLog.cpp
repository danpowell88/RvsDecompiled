/*=============================================================================
	UnLog.cpp: FOutputDevice implementations — logging, error handling.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FOutputDevice base class implementation.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
void FOutputDevice::Log( const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, NAME_Log );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
void FOutputDevice::Log( enum EName Type, const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, Type );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
void FOutputDevice::Log( const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, NAME_Log );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
void FOutputDevice::Log( enum EName Type, const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, Type );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
void FOutputDevice::Logf( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	Serialize( TempStr, NAME_Log );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnLog.cpp")
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

IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FErrorOutError::FErrorOutError() {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FErrorOutError::FErrorOutError( const FErrorOutError& ) {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FErrorOutError& FErrorOutError::operator=( const FErrorOutError& ) { return *this; }
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
void FErrorOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GError )
		GError->Serialize( V, Event );
}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
void FErrorOutError::HandleError()
{
	if( GError )
		GError->HandleError();
}

IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FLogOutError::FLogOutError() {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FLogOutError::FLogOutError( const FLogOutError& ) {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FLogOutError& FLogOutError::operator=( const FLogOutError& ) { return *this; }
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
void FLogOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GLog )
		GLog->Serialize( V, Event );
}

IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FNullOutError::FNullOutError() {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FNullOutError::FNullOutError( const FNullOutError& ) {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FNullOutError& FNullOutError::operator=( const FNullOutError& ) { return *this; }
IMPL_GHIDRA("Core.dll", 0x1290)
void FNullOutError::Serialize( const TCHAR* V, EName Event )
{
	guard(FNullOutError::Serialize);
	// Retail 0x1290: shared null-stub, no-op.
	unguard;
}

IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FThrowOut::FThrowOut() {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FThrowOut::FThrowOut( const FThrowOut& ) {}
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
FThrowOut& FThrowOut::operator=( const FThrowOut& ) { return *this; }
IMPL_INFERRED("Ravenshield-specific output device; reconstructed from context")
void FThrowOut::Serialize( const TCHAR* V, EName Event )
{
	appThrowf( TEXT("%s"), V );
}

/*-----------------------------------------------------------------------------
	FFrame::Serialize.
-----------------------------------------------------------------------------*/

IMPL_INFERRED("retail 0x1bd50: logs script frame context to GLog/GError")
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
