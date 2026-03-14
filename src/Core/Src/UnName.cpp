/*=============================================================================
	UnName.cpp: FName implementation — global name table with hash buckets.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FName statics.
-----------------------------------------------------------------------------*/

TArray<FNameEntry*>  FName::Names;
TArray<INT>          FName::Available;
FNameEntry*          FName::NameHash[4096];
UBOOL                FName::Initialized = 0;

/*-----------------------------------------------------------------------------
	FNameEntry serialization.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
CORE_API FNameEntry* AllocateNameEntry( const TCHAR* Name, DWORD Index, DWORD Flags, FNameEntry* HashNext )
{
	guard(AllocateNameEntry);
	INT NameLen = appStrlen(Name);
	FNameEntry* Entry = (FNameEntry*)appMalloc( sizeof(FNameEntry), TEXT("NameEntry") );
	Entry->Index    = Index;
	Entry->Flags    = Flags;
	Entry->HashNext = HashNext;
	appStrncpy( Entry->Name, Name, NAME_SIZE );
	return Entry;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
CORE_API FArchive& operator<<( FArchive& Ar, FNameEntry& E )
{
	guard(FNameEntry<<);

	// Serialize the name string.
	if( Ar.IsLoading() )
	{
		// Load ANSI string, convert to TCHAR.
		INT SaveNum;
		Ar << AR_INDEX(SaveNum);

		ANSICHAR AnsiName[NAME_SIZE];
		Ar.Serialize( AnsiName, SaveNum );
		AnsiName[SaveNum] = 0;

		for( INT i=0; i<=SaveNum; i++ )
			E.Name[i] = FromAnsi( AnsiName[i] );
	}
	else
	{
		// Save as ANSI.
		INT SaveNum = appStrlen(E.Name);
		Ar << AR_INDEX(SaveNum);

		ANSICHAR AnsiName[NAME_SIZE];
		for( INT i=0; i<SaveNum; i++ )
			AnsiName[i] = ToAnsi( E.Name[i] );
		Ar.Serialize( AnsiName, SaveNum );
	}

	// Serialize flags.
	Ar << E.Flags;

	return Ar;
	unguard;
}

/*-----------------------------------------------------------------------------
	FName implementation.
-----------------------------------------------------------------------------*/

//
// Hash function for name strings.
//
IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
static DWORD GetNameHash( const TCHAR* Name )
{
	DWORD Hash = 0;
	while( *Name )
	{
		TCHAR Ch = appToUpper(*Name++);
		Hash = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ (BYTE)Ch) & 0xFF];
#if UNICODE
		BYTE HiByte = (BYTE)(Ch >> 8);
		Hash = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ HiByte) & 0xFF];
#endif
	}
	return Hash & (4096 - 1);
}

//
// Find or add a name by string.
//
IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
FName::FName( const TCHAR* Name, EFindName FindType )
{
	guard(FName::FName);
	check(Initialized);
	check(Name);
	check(appStrlen(Name)<NAME_SIZE);

	// Search in hash table.
	DWORD iHash = GetNameHash( Name );
	for( FNameEntry* Entry=NameHash[iHash]; Entry; Entry=Entry->HashNext )
	{
		if( appStricmp(Entry->Name, Name)==0 )
		{
			// Found existing name.
			Index = Entry->Index;
			return;
		}
	}

	// Not found.
	if( FindType == FNAME_Find )
	{
		// Name not found and we only wanted to find it.
		Index = 0;
		return;
	}

	// Add new name.
	FNameEntry* NewEntry = AllocateNameEntry( Name, Names.Num(), (FindType==FNAME_Intrinsic) ? RF_Native : 0, NameHash[iHash] );
	NameHash[iHash] = NewEntry;

	if( Available.Num() )
	{
		Index = Available( Available.Num()-1 );
		Available.Remove( Available.Num()-1 );
		Names(Index) = NewEntry;
		NewEntry->Index = Index;
	}
	else
	{
		Index = Names.Add();
		Names(Index) = NewEntry;
		NewEntry->Index = Index;
	}

	unguard;
}

/*-----------------------------------------------------------------------------
	FName subsystem init/exit.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
void FName::StaticInit()
{
	guard(FName::StaticInit);
	check(!Initialized);

	// Init hash table.
	for( INT i=0; i<ARRAY_COUNT(NameHash); i++ )
		NameHash[i] = NULL;

	// Register hardcoded names.
	#define REGISTER_NAME(num,name)  Hardcode(AllocateNameEntry(TEXT(#name),(num),RF_Native,NULL));
	#define REG_NAME_HIGH(num,name)  Hardcode(AllocateNameEntry(TEXT(#name),(num),RF_Native,NULL));
	#include "UnNames.h"

	Initialized = 1;

	if( GLog )
		debugf( NAME_Init, TEXT("Name subsystem initialized") );

	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
void FName::StaticExit()
{
	guard(FName::StaticExit);

	// Free all names.
	for( INT i=0; i<Names.Num(); i++ )
	{
		if( Names(i) )
		{
			appFree( Names(i) );
			Names(i) = NULL;
		}
	}
	Names.Empty();
	Available.Empty();

	Initialized = 0;

	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
void FName::DeleteEntry( int i )
{
	guard(FName::DeleteEntry);
	check(i>0);
	check(i<Names.Num());
	check(Names(i));

	// Remove from hash.
	DWORD iHash = GetNameHash( Names(i)->Name );
	FNameEntry** Link;
	for( Link=&NameHash[iHash]; *Link && *Link!=Names(i); Link=&(*Link)->HashNext );
	if( *Link )
		*Link = (*Link)->HashNext;

	// Free and mark available.
	appFree( Names(i) );
	Names(i) = NULL;
	Available.AddItem( i );

	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
void FName::DisplayHash( FOutputDevice& Ar )
{
	guard(FName::DisplayHash);

	INT Used = 0, Max = 0;
	for( INT i=0; i<ARRAY_COUNT(NameHash); i++ )
	{
		INT Count = 0;
		for( FNameEntry* Entry=NameHash[i]; Entry; Entry=Entry->HashNext )
			Count++;
		if( Count )
			Used++;
		Max = ::Max( Max, Count );
	}
	Ar.Logf( TEXT("Hash: %i/%i bins used, max %i"), Used, ARRAY_COUNT(NameHash), Max );

	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnName.cpp")
void FName::Hardcode( FNameEntry* AutoName )
{
	guard(FName::Hardcode);

	// Register name at the autoname's index.
	while( Names.Num() <= (INT)AutoName->Index )
		Names.Add();
	Names(AutoName->Index) = AutoName;

	// Add to hash.
	DWORD iHash = GetNameHash( AutoName->Name );
	AutoName->HashNext = NameHash[iHash];
	NameHash[iHash] = AutoName;

	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
