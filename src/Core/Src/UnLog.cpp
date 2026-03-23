/*=============================================================================
	UnLog.cpp: FOutputDevice implementations — logging, error handling.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FOutputDevice base class implementation.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x0x1012ef20)
void FOutputDevice::Log( const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, NAME_Log );
	unguard;
}

IMPL_MATCH("Core.dll", 0x0x1012ef20)
void FOutputDevice::Log( enum EName Type, const TCHAR* S )
{
	guard(FOutputDevice::Log);
	Serialize( S, Type );
	unguard;
}

IMPL_MATCH("Core.dll", 0x0x1012ef20)
void FOutputDevice::Log( const FString& S )
{
	guard(FOutputDevice::Log);
	Serialize( *S, NAME_Log );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1012EF20)
void FOutputDevice::Log( enum EName Type, const FString& S )
{
	guardSlow(FOutputDevice::Log);
	Serialize( *S, Type );
	unguardSlow;
}

IMPL_MATCH("Core.dll", 0x0x1012efd0)
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

IMPL_MATCH("Core.dll", 0x10108500)
FErrorOutError::FErrorOutError() {}
IMPL_MATCH("Core.dll", 0x10108510)
FErrorOutError::FErrorOutError( const FErrorOutError& ) {}
// Retail 0x13c0: shared trivial-return stub (same VA as FLogOutError/FNullOutError/FThrowOut::operator=).
IMPL_MATCH("Core.dll", 0x101013C0)
FErrorOutError& FErrorOutError::operator=( const FErrorOutError& ) { return *this; }
// Retail 0x1290: shared null-stub (same VA as FLogOutError::Serialize and FNullOutError::Serialize).
IMPL_MATCH("Core.dll", 0x10101290)
void FErrorOutError::Serialize( const TCHAR* V, EName Event ) {}
// Retail 0x1320: shared no-op stub.
IMPL_MATCH("Core.dll", 0x10101320)
void FErrorOutError::HandleError() {}

IMPL_MATCH("Core.dll", 0x10108520)
FLogOutError::FLogOutError() {}
IMPL_MATCH("Core.dll", 0x10108530)
FLogOutError::FLogOutError( const FLogOutError& ) {}
// Retail 0x13c0: shared trivial-return stub.
IMPL_MATCH("Core.dll", 0x101013C0)
FLogOutError& FLogOutError::operator=( const FLogOutError& ) { return *this; }
// Retail 0x1290: shared null-stub.
IMPL_MATCH("Core.dll", 0x10101290)
void FLogOutError::Serialize( const TCHAR* V, EName Event ) {}

IMPL_MATCH("Core.dll", 0x101012a0)
FNullOutError::FNullOutError() {}
IMPL_MATCH("Core.dll", 0x101012B0)
FNullOutError::FNullOutError( const FNullOutError& ) {}
// Retail 0x13c0: shared trivial-return stub.
IMPL_MATCH("Core.dll", 0x101013C0)
FNullOutError& FNullOutError::operator=( const FNullOutError& ) { return *this; }
IMPL_MATCH("Core.dll", 0x10101290)
void FNullOutError::Serialize( const TCHAR* V, EName Event )
{
	guard(FNullOutError::Serialize);
	// Retail 0x1290: shared null-stub, no-op.
	unguard;
}

IMPL_MATCH("Core.dll", 0x10108540)
FThrowOut::FThrowOut() {}
IMPL_MATCH("Core.dll", 0x10101260)
FThrowOut::FThrowOut( const FThrowOut& ) {}
// Retail 0x13c0: shared trivial-return stub.
IMPL_MATCH("Core.dll", 0x101013C0)
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
	FArchive Ravenshield additions.
-----------------------------------------------------------------------------*/

// IsCriticalError: Ghidra 0x10101580 (4 bytes): returns ArIsCriticalError at this+0x34
IMPL_MATCH("Core.dll", 0x10101580)
INT FArchive::IsCriticalError()
{
	return ArIsCriticalError;
}

/*-----------------------------------------------------------------------------
	FFeedbackContext Ravenshield MapCheck methods.
-----------------------------------------------------------------------------*/

// All MapCheck base-class methods are trivial no-ops in Core.dll.
// MapCheck_Add: Ghidra 0x10101330 (3 bytes — ret only)
IMPL_MATCH("Core.dll", 0x10101330)
void FFeedbackContext::MapCheck_Add( INT Type, void* Obj, const TCHAR* Msg )
{
}

// MapCheck_Clear/Hide/Show/ShowConditionally: Ghidra 0x10101320 (1 byte — ret only)
IMPL_EMPTY("Ghidra 0x10101320: 1-byte trivial no-op")
void FFeedbackContext::MapCheck_Clear()
{
}

IMPL_MATCH("Core.dll", 0x10101320)
void FFeedbackContext::MapCheck_Hide()
{
}

IMPL_EMPTY("Ghidra 0x10101320: 1-byte trivial no-op (shared stub)")
void FFeedbackContext::MapCheck_Show()
{
}

IMPL_EMPTY("Ghidra 0x10101320: 1-byte trivial no-op (shared stub)")
void FFeedbackContext::MapCheck_ShowConditionally()
{
}

/*-----------------------------------------------------------------------------
	FMalloc Ravenshield additions.
-----------------------------------------------------------------------------*/

// GetMemoryBlockSize: Ghidra 0x10101c70 (shared thunk with FUnknown::Release — returns 0)
IMPL_EMPTY("Ghidra 0x10101c70: shared trivial stub that returns 0")
INT FMalloc::GetMemoryBlockSize( void* Original )
{
	return 0;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
