/*=============================================================================
	UnNet.cpp: UPackageMap, FClassNetCache, FFieldNetCache, FPackageInfo —
	core networking support for object/name serialization.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Ut99PubSrc/Core/Inc/UnCoreNet.h
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FFieldNetCache.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FArchive& operator<<( FArchive& Ar, FFieldNetCache& F )
{
	return Ar << F.Field << F.FieldNetIndex << F.ConditionIndex;
}

/*-----------------------------------------------------------------------------
	FClassNetCache.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1ab10)
FClassNetCache::FClassNetCache()
:	FieldsBase        ( 0 )
,	Super             ( NULL )
,	RepConditionCount ( 0 )
,	Class             ( NULL )
{
	guard(FClassNetCache::FClassNetCache);
	// TArray default ctor is trivially-empty; zero fields explicitly (Ghidra 0x1ab10).
	appMemzero( &RepProperties, sizeof(RepProperties) );
	appMemzero( &Fields,        sizeof(Fields)        );
	// FieldMap is default-constructed: TMapBase() sets HashCount=8 and calls Rehash()
	// (retail: FUN_10118f90(&FieldMap) at Ghidra 0x1ab10)
	unguard;
}

IMPL_MATCH("Core.dll", 0x1a580)
FClassNetCache::FClassNetCache( UClass* InClass )
:	FieldsBase        ( 0 )
,	Super             ( NULL )
,	RepConditionCount ( 0 )
,	Class             ( InClass )
{
	guard(FClassNetCache::FClassNetCache);
	// TArray default ctor is trivially-empty; zero fields explicitly (Ghidra 0x1a580).
	appMemzero( &RepProperties, sizeof(RepProperties) );
	appMemzero( &Fields,        sizeof(Fields)        );
	// FieldMap is default-constructed: TMapBase() sets HashCount=8 and calls Rehash()
	// (retail: FUN_10118f90(&FieldMap) at Ghidra 0x1a580)
	unguard;
}

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FArchive& operator<<( FArchive& Ar, FClassNetCache& Cache )
{
	return Ar << Cache.FieldsBase << Cache.RepConditionCount << Cache.Fields;
}

/*-----------------------------------------------------------------------------
	FPackageInfo.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010BC50)
FPackageInfo::FPackageInfo( ULinkerLoad* InLinker )
:	Linker          ( InLinker )
,	Parent          ( InLinker ? InLinker->LinkerRoot : NULL )
,	Guid            ( InLinker ? InLinker->Summary.Guid : FGuid(0,0,0,0) )
,	FileSize        ( 0 )
,	ObjectBase      ( INDEX_NONE )
,	ObjectCount     ( 0 )
,	NameBase        ( INDEX_NONE )
,	NameCount       ( 0 )
,	LocalGeneration ( 0 )
,	RemoteGeneration( 0 )
,	PackageFlags    ( InLinker ? InLinker->Summary.PackageFlags : 0 )
{
	if( InLinker )
		URL = InLinker->Filename;
}

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FArchive& operator<<( FArchive& Ar, FPackageInfo& I )
{
	return Ar << I.URL << I.Parent << I.Guid << I.FileSize
	          << I.ObjectBase << I.ObjectCount
	          << I.NameBase << I.NameCount
	          << I.LocalGeneration << I.RemoteGeneration
	          << I.PackageFlags;
}

/*-----------------------------------------------------------------------------
	UPackageMap.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011AA50)
void UPackageMap::Serialize( FArchive& Ar )
{
	guard(UPackageMap::Serialize);
	UObject::Serialize( Ar );
	Ar << List;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011AB80)
void UPackageMap::Destroy()
{
	guard(UPackageMap::Destroy);
	// Clean up cached net class info.
	for( TMap<UObject*,FClassNetCache*>::TIterator It(ClassFieldIndices); It; ++It )
		delete It.Value();
	ClassFieldIndices.Empty();
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119B50)
UBOOL UPackageMap::CanSerializeObject( UObject* Obj )
{
	guard(UPackageMap::CanSerializeObject);
	appErrorf( TEXT("Unexpected UPackageMap::CanSerializeObject") );
	return 1;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119BE0)
UBOOL UPackageMap::SerializeObject( FArchive& Ar, UClass* Class, UObject*& Obj )
{
	guard(UPackageMap::SerializeObject);
	INT Index;
	if( Ar.IsSaving() )
	{
		Index = ObjectToIndex( Obj );
		Ar << Index;
	}
	else
	{
		Ar << Index;
		Obj = IndexToObject( Index, 1 );
	}
	return 1;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119DB0)
UBOOL UPackageMap::SerializeName( FArchive& Ar, FName& Name )
{
	guard(UPackageMap::SerializeName);
	INT Index;
	if( Ar.IsSaving() )
	{
		Index = Name.GetIndex();
		Ar << Index;
	}
	else
	{
		Ar << Index;
		Name = FName((EName)Index);
	}
	return 1;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011A280)
INT UPackageMap::ObjectToIndex( UObject* Object )
{
	guard(UPackageMap::ObjectToIndex);
	if( Object && Object->_Linker && Object->_LinkerIndex != INDEX_NONE )
	{
		INT* Idx = LinkerMap.Find( (UObject*)Object->_Linker );
		if( Idx && Object->_LinkerIndex < List(*Idx).ObjectCount )
			return List(*Idx).ObjectBase + Object->_LinkerIndex;
	}
	return INDEX_NONE;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119EF0)
UObject* UPackageMap::IndexToObject( INT Index, UBOOL Load )
{
	guard(UPackageMap::IndexToObject);
	if( Index >= 0 )
	{
		for( INT i=0; i<List.Num(); i++ )
		{
			if( Index < List(i).ObjectCount )
			{
				UObject*& Obj = List(i).Linker->ExportMap(Index)._Object;
				if( !Obj && Load )
				{
					BeginLoad();
					List(i).Linker->CreateExport( Index );
					EndLoad();
				}
				return Obj;
			}
			Index -= List(i).ObjectCount;
		}
	}
	return NULL;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011A110)
INT UPackageMap::AddLinker( ULinkerLoad* Linker )
{
	guard(UPackageMap::AddLinker);
	INT* Existing = LinkerMap.Find( Linker );
	if( Existing )
		return *Existing;
	INT Index = List.Num();
	new(List) FPackageInfo( Linker );
	LinkerMap.Set( Linker, Index );
	return Index;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011A370)
void UPackageMap::Compute()
{
	guard(UPackageMap::Compute);
	MaxObjectIndex = 0;
	MaxNameIndex   = 0;
	for( INT i=0; i<List.Num(); i++ )
	{
		List(i).ObjectBase = MaxObjectIndex;
		MaxObjectIndex += List(i).ObjectCount;
		List(i).NameBase = MaxNameIndex;
		MaxNameIndex += List(i).NameCount;
	}
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011A6D0)
FClassNetCache* UPackageMap::GetClassNetCache( UClass* Class )
{
	guard(UPackageMap::GetClassNetCache);
	FClassNetCache** CachePtr = ClassFieldIndices.Find( Class );
	if( CachePtr )
		return *CachePtr;

	FClassNetCache* Cache = new FClassNetCache( Class );
	ClassFieldIndices.Set( Class, Cache );

	// Set up super chain.
	if( Class->GetSuperClass() )
		Cache->Super = GetClassNetCache( Class->GetSuperClass() );

	return Cache;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119EC0)
UBOOL UPackageMap::SupportsPackage( UObject* InOuter )
{
	guard(UPackageMap::SupportsPackage);
	for( INT i=0; i<List.Num(); i++ )
		if( List(i).Parent == InOuter )
			return 1;
	return 0;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1011A600)
void UPackageMap::Copy( UPackageMap* Other )
{
	guard(UPackageMap::Copy);
	List           = Other->List;
	LinkerMap      = Other->LinkerMap;
	NameIndices    = Other->NameIndices;
	MaxObjectIndex = Other->MaxObjectIndex;
	MaxNameIndex   = Other->MaxNameIndex;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10119D10)
void UPackageMap::CopyLinkers( UPackageMap* Other )
{
	guard(UPackageMap::CopyLinkers);
	for( INT i=0; i<Other->List.Num(); i++ )
	{
		if( Other->List(i).Linker )
			AddLinker( Other->List(i).Linker );
	}
	unguard;
}

IMPLEMENT_CLASS(UPackageMap);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
