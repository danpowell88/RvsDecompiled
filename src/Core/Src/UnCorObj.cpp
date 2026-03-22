/*=============================================================================
	UnCorObj.cpp: Standard core object implementations — UPackage,
	UTextBuffer, USystem, UCommandlet, ULanguage.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	UPackage.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1013b0a0)
UPackage::UPackage()
:	DllHandle    ( NULL )
,	AttemptedBind( 0 )
,	PackageFlags ( 0 )
{
	guard(UPackage::UPackage);
	// Ghidra 0x1013b0a0: after member-init, register with the object system
	// and zero the unknown DWORD at +0x38 (before DllHandle at +0x3C).
	UObject::BindPackage( this );
	*(DWORD*)((BYTE*)this + 0x38) = 0;	// unknown field before DllHandle
	unguard;
}

IMPL_MATCH("Core.dll", 0x1013b240)
void UPackage::Destroy()
{
	guard(UPackage::Destroy);
	if( DllHandle )
	{
		appFreeDllHandle( DllHandle );
		DllHandle = NULL;
	}
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Core.dll", 0x1013a2a0)
void UPackage::Serialize( FArchive& Ar )
{
	guard(UPackage::Serialize);
	UObject::Serialize( Ar );
	Ar << PackageFlags;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10137880)
void* UPackage::GetDllExport( const TCHAR* ExportName, UBOOL Checked )
{
	guard(UPackage::GetDllExport);
	if( !AttemptedBind )
	{
		AttemptedBind = 1;
		TCHAR DllName[256];
		appSprintf( DllName, TEXT("%s.dll"), GetName() );
		DllHandle = appGetDllHandle( DllName );
	}
	if( DllHandle )
	{
		void* Result = appGetDllExport( DllHandle, ExportName );
		if( !Result && Checked )
			appErrorf( TEXT("Failed to find '%s' in '%s.dll'"), ExportName, GetName() );
		return Result;
	}
	if( Checked )
		appErrorf( TEXT("Failed to bind '%s.dll'"), GetName() );
	return NULL;
	unguard;
}

IMPLEMENT_CLASS(UPackage);

/*-----------------------------------------------------------------------------
	USubsystem.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(USubsystem);

/*-----------------------------------------------------------------------------
	ULanguage.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(ULanguage);

/*-----------------------------------------------------------------------------
	UTextBuffer.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1013aee0)
UTextBuffer::UTextBuffer( const TCHAR* InText )
:	Pos  ( 0 )
,	Top  ( 0 )
,	Text ( InText )
{
	guard(UTextBuffer::UTextBuffer);
	// Ghidra 0x1013aee0: has SEH frame; init list handles all member setup.
	unguard;
}

IMPL_MATCH("Core.dll", 0x1013a070)
void UTextBuffer::Serialize( FArchive& Ar )
{
	guard(UTextBuffer::Serialize);
	UObject::Serialize( Ar );
	Ar << Pos << Top << Text;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1013a070)
void UTextBuffer::Serialize( const TCHAR* Data, EName Event )
{
	guard(UTextBuffer::Serialize_OutputDevice);
	Text += (TCHAR*)Data;
	unguard;
}

IMPLEMENT_CLASS(UTextBuffer);

/*-----------------------------------------------------------------------------
	UCommandlet.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1013af70)
UCommandlet::UCommandlet()
:	LogToStdout   ( 0 )
,	IsServer      ( 0 )
,	IsClient      ( 0 )
,	IsEditor      ( 0 )
,	LazyLoad      ( 0 )
,	ShowErrorCount( 0 )
,	ShowBanner    ( 1 )
{
	guard(UCommandlet::UCommandlet);
	// Ghidra 0x1013af70: has SEH frame; compiler calls _eh_vector_constructor_iterator_
	// for FStringNoInit arrays at +0x5C and +0x11C (member init handled by compiler).
	unguard;
}

// UCommandlet::~UCommandlet (Ghidra 0x1010bf20): calls ConditionalDestroy() then
// compiler-emitted member/base destructors.  Provided inline by DECLARE_CLASS.
IMPL_TODO("Byte-parity unverified — destructor body is compiler-generated member cleanup")
UCommandlet::~UCommandlet()
{
}

IMPL_MATCH("Core.dll", 0x1013aff0)
INT UCommandlet::Main( const TCHAR* Parms )
{
	guard(UCommandlet::Main);
	return eventMain( Parms );
	unguard;
}

IMPL_MATCH("Core.dll", 0x1013a1d0)
void UCommandlet::execMain( FFrame& Stack, RESULT_DECL )
{
	guard(UCommandlet::execMain);
	P_GET_STR(InParms);
	P_FINISH;
	*(INT*)Result = Main( *InParms );
	unguard;
}
IMPLEMENT_FUNCTION( UCommandlet, 0, execMain );

IMPL_MATCH("Core.dll", 0x1010f360)
INT UCommandlet::eventMain( const FString& InParms )
{
	UCommandlet_eventMain_Parms Parms;
	Parms.InParms = InParms;
	Parms.ReturnValue = 0;
	ProcessEvent( FindFunctionChecked(NAME_Main, 0), &Parms, NULL );
	return Parms.ReturnValue;
}

IMPLEMENT_CLASS(UCommandlet);

/*-----------------------------------------------------------------------------
	USystem.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1014ba90)
USystem::USystem()
:	LicenseeMode  ( 0 )
,	PurgeCacheDays( 30 )
,	SavePath      ( TEXT("..\\Save") )
,	CachePath     ( TEXT("..\\Cache") )
,	CacheExt      ( TEXT(".uxx") )
{
	// Ghidra 0x1014ba90: no SEH frame; compiler default-constructs Paths/Suppress
	// TArrays (offsets +0x5C, +0x60, +0x64 zeroed directly in compiled output).
}

IMPL_TODO("USystem StaticConstructor: FObjectExport Paths/Suppress field offsets unverified against retail binary layout — verify struct offsets against Ghidra analysis of Core.dll")
void USystem::StaticConstructor()
{
	guard(USystem::StaticConstructor);

	// Retail binary sets CDO LicenseeMode=1 at class registration time.
	LicenseeMode = 1;

	new(GetClass(),TEXT("PurgeCacheDays"),RF_Public) UIntProperty(CPP_PROPERTY(PurgeCacheDays), TEXT("Options"), CPF_Config);
	new(GetClass(),TEXT("SavePath"),     RF_Public) UStrProperty(CPP_PROPERTY(SavePath),      TEXT("Options"), CPF_Config);
	new(GetClass(),TEXT("CachePath"),    RF_Public) UStrProperty(CPP_PROPERTY(CachePath),     TEXT("Options"), CPF_Config);
	new(GetClass(),TEXT("CacheExt"),     RF_Public) UStrProperty(CPP_PROPERTY(CacheExt),      TEXT("Options"), CPF_Config);

	UArrayProperty* PA = new(GetClass(),TEXT("Paths"),   RF_Public) UArrayProperty(CPP_PROPERTY(Paths),    TEXT("Options"), CPF_Config);
	PA->Inner          = new(PA,         TEXT("StrProperty0"),  RF_Public) UStrProperty(EC_CppProperty,  0, TEXT("Options"), CPF_Config);

	UArrayProperty* SA = new(GetClass(),TEXT("Suppress"),RF_Public) UArrayProperty(CPP_PROPERTY(Suppress), TEXT("Options"), CPF_Config);
	SA->Inner          = new(SA,         TEXT("NameProperty0"), RF_Public) UNameProperty(EC_CppProperty, 0, TEXT("Options"), CPF_Config);

	// DIVERGENCE: Ghidra shows a 12-byte gap between CacheExt (+0x50) and Paths (+0x68)
	// suggesting an additional FString field not present in our reconstruction.
	// CPP_PROPERTY offsets will differ from binary; Paths/Suppress config loading
	// may not match retail exactly.

	unguard;
}

IMPL_MATCH("Core.dll", 0x1014bac0)
UBOOL USystem::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(USystem::Exec);
	if( ParseCommand( &Cmd, TEXT("MEMSTAT") ) )
	{
		MEMORYSTATUS Status;
		Status.dwLength = sizeof(Status);
		GlobalMemoryStatus( &Status );
		Ar.Logf( TEXT("Memory status:") );
		Ar.Logf( TEXT("  Physical: %uk used, %uk total"), (Status.dwTotalPhys - Status.dwAvailPhys) / 1024, Status.dwTotalPhys / 1024 );
		Ar.Logf( TEXT("  Pagefile: %uk used, %uk total"), (Status.dwTotalPageFile - Status.dwAvailPageFile) / 1024, Status.dwTotalPageFile / 1024 );
		Ar.Logf( TEXT("  Virtual:  %uk used, %uk total"), (Status.dwTotalVirtual - Status.dwAvailVirtual) / 1024, Status.dwTotalVirtual / 1024 );
		return 1;
	}
	else if( ParseCommand( &Cmd, TEXT("CONFIGHASH") ) )
	{
		GConfig->Dump( Ar );
		return 1;
	}
	else if( ParseCommand( &Cmd, TEXT("EXIT") ) || ParseCommand( &Cmd, TEXT("QUIT") ) )
	{
		Ar.Log( TEXT("Exiting.") );
		GIsRequestingExit = 1;
		return 1;
	}
	else if( ParseCommand( &Cmd, TEXT("RELAUNCH") ) )
	{
		GIsRequestingExit = 1;
		return 1;
	}
	else if( ParseCommand( &Cmd, TEXT("DEBUG") ) )
	{
		if( appIsDebuggerPresent() )
			appDebugBreak();
		return 1;
	}
	return 0;
	unguard;
}

IMPLEMENT_CLASS(USystem);

/*-----------------------------------------------------------------------------
	UConst.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10116c40)
UConst::UConst( UConst* InSuperConst, const TCHAR* InValue )
:	UField( InSuperConst )
,	Value( InValue )
{
	guard(UConst::UConst);
	// Ghidra 0x10116c40: has SEH frame; init list handles UField base and Value FString.
	unguard;
}

IMPL_MATCH("Core.dll", 0x101161b0)
void UConst::Serialize( FArchive& Ar )
{
	guard(UConst::Serialize);
	UField::Serialize( Ar );
	Ar << Value;
	unguard;
}

IMPLEMENT_CLASS(UConst);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
