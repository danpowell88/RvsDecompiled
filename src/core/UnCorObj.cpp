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
	return 0;
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
	// Properties are loaded from [Core.System] in the INI by the config system.
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
