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

UPackage::UPackage()
:	DllHandle    ( NULL )
,	AttemptedBind( 0 )
,	PackageFlags ( 0 )
{
}

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

void UPackage::Serialize( FArchive& Ar )
{
	guard(UPackage::Serialize);
	UObject::Serialize( Ar );
	Ar << PackageFlags;
	unguard;
}

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

UTextBuffer::UTextBuffer( const TCHAR* InText )
:	Pos  ( 0 )
,	Top  ( 0 )
,	Text ( InText )
{
}

void UTextBuffer::Serialize( FArchive& Ar )
{
	guard(UTextBuffer::Serialize);
	UObject::Serialize( Ar );
	Ar << Pos << Top << Text;
	unguard;
}

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

UCommandlet::UCommandlet()
:	LogToStdout   ( 0 )
,	IsServer      ( 0 )
,	IsClient      ( 0 )
,	IsEditor      ( 0 )
,	LazyLoad      ( 0 )
,	ShowErrorCount( 0 )
,	ShowBanner    ( 1 )
{
}

UCommandlet::~UCommandlet()
{
}

INT UCommandlet::Main( const TCHAR* Parms )
{
	guard(UCommandlet::Main);
	return eventMain( Parms );
	unguard;
}

void UCommandlet::execMain( FFrame& Stack, RESULT_DECL )
{
	guard(UCommandlet::execMain);
	P_GET_STR(InParms);
	P_FINISH;
	*(INT*)Result = Main( *InParms );
	unguard;
}
IMPLEMENT_FUNCTION( UCommandlet, 0, execMain );

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

USystem::USystem()
:	LicenseeMode  ( 0 )
,	PurgeCacheDays( 30 )
,	SavePath      ( TEXT("..\\Save") )
,	CachePath     ( TEXT("..\\Cache") )
,	CacheExt      ( TEXT(".uxx") )
{
}

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

UBOOL USystem::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(USystem::Exec);
	return 0;
	unguard;
}

IMPLEMENT_CLASS(USystem);

/*-----------------------------------------------------------------------------
	UConst.
-----------------------------------------------------------------------------*/

UConst::UConst( UConst* InSuperConst, const TCHAR* InValue )
:	UField( InSuperConst )
,	Value( InValue )
{
}

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
