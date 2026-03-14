/*=============================================================================
	UnLog.cpp: FOutputDevice implementations — logging, error handling.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FOutputDevice base class implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012EE70)
void FOutputDevice::Log( const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, NAME_Log );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1012EEA0)
void FOutputDevice::Log( enum EName Type, const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, Type );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1012EED0)
void FOutputDevice::Log( const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, NAME_Log );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1012EF20)
void FOutputDevice::Log( enum EName Type, const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, Type );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1012EF70)
void FOutputDevice::Logf( const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	Serialize( TempStr, NAME_Log );
}

IMPL_MATCH("Core.dll", 0x1012EFD0)
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

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10108500 size 9 bytes")
FErrorOutError::FErrorOutError() {}
IMPL_MATCH("Core.dll", 0x10108510)
FErrorOutError::FErrorOutError( const FErrorOutError& ) {}
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FErrorOutError& FErrorOutError::operator=( const FErrorOutError& ) { return *this; }
IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void FErrorOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GError )
		GError->Serialize( V, Event );
}
IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void FErrorOutError::HandleError()
{
	if( GError )
		GError->HandleError();
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10108520 size 9 bytes")
FLogOutError::FLogOutError() {}
IMPL_MATCH("Core.dll", 0x10108530)
FLogOutError::FLogOutError( const FLogOutError& ) {}
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FLogOutError& FLogOutError::operator=( const FLogOutError& ) { return *this; }
IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
void FLogOutError::Serialize( const TCHAR* V, EName Event )
{
	if( GLog )
		GLog->Serialize( V, Event );
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x101012A0 size 9 bytes")
FNullOutError::FNullOutError() {}
IMPL_MATCH("Core.dll", 0x101012B0)
FNullOutError::FNullOutError( const FNullOutError& ) {}
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FNullOutError& FNullOutError::operator=( const FNullOutError& ) { return *this; }
IMPL_MATCH("Core.dll", 0x10101290)
void FNullOutError::Serialize( const TCHAR* V, EName Event )
{
	guard(FNullOutError::Serialize);
	// Retail 0x1290: shared null-stub, no-op.
	unguard;
}

IMPL_MATCH("Core.dll", 0x10101260)
FThrowOut::FThrowOut() {}
IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10108540 size 9 bytes")
FThrowOut::FThrowOut( const FThrowOut& ) {}
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FThrowOut& FThrowOut::operator=( const FThrowOut& ) { return *this; }
IMPL_MATCH("Core.dll", 0x10101220)
void FThrowOut::Serialize( const TCHAR* V, EName Event )
{
	appThrowf( TEXT("%s"), V );
}

/*-----------------------------------------------------------------------------
	FFrame::Serialize.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011BD50)
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
