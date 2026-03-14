/*=============================================================================
	UnLinker.cpp: ULinker, ULinkerLoad, ULinkerSave — package file
	loading/saving, export/import tables, object resolution.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FObjectExport / FObjectImport constructors.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101287C0)
FObjectExport::FObjectExport()
:	ClassIndex   ( 0 )
,	SuperIndex   ( 0 )
,	PackageIndex ( 0 )
,	ObjectName   ( NAME_None )
,	ObjectFlags  ( 0 )
,	SerialSize   ( 0 )
,	SerialOffset ( 0 )
,	_Object      ( NULL )
,	_iHashNext   ( INDEX_NONE )
{}

IMPL_MATCH("Core.dll", 0x101287E0)
FObjectExport::FObjectExport( UObject* InObject )
:	ClassIndex   ( 0 )
,	SuperIndex   ( 0 )
,	PackageIndex ( 0 )
,	ObjectName   ( InObject ? InObject->GetFName() : NAME_None )
,	ObjectFlags  ( InObject ? InObject->GetFlags() : 0 )
,	SerialSize   ( 0 )
,	SerialOffset ( 0 )
,	_Object      ( InObject )
,	_iHashNext   ( INDEX_NONE )
{}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10128840 size 3 bytes")
FObjectImport::FObjectImport()
:	ClassPackage ( NAME_None )
,	ClassName    ( NAME_None )
,	PackageIndex ( 0 )
,	ObjectName   ( NAME_None )
,	XObject      ( NULL )
,	SourceLinker ( NULL )
,	SourceIndex  ( INDEX_NONE )
{}

IMPL_MATCH("Core.dll", 0x10128850)
FObjectImport::FObjectImport( UObject* InObject )
:	ClassPackage ( InObject ? FName(InObject->GetClass()->GetOuter()->GetName()) : NAME_None )
,	ClassName    ( InObject ? FName(InObject->GetClass()->GetName()) : NAME_None )
,	PackageIndex ( 0 )
,	ObjectName   ( InObject ? InObject->GetFName() : NAME_None )
,	XObject      ( InObject )
,	SourceLinker ( NULL )
,	SourceIndex  ( INDEX_NONE )
{}

/*-----------------------------------------------------------------------------
	FGenerationInfo / FPackageFileSummary constructors.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not individually exported from Core.dll; trivial struct initializer, functionally correct")
FGenerationInfo::FGenerationInfo( INT InExportCount, INT InNameCount )
:	ExportCount( InExportCount )
,	NameCount  ( InNameCount )
{}

IMPL_DIVERGE("Not individually exported from Core.dll; trivial struct initializer, functionally correct")
FPackageFileSummary::FPackageFileSummary()
:	Tag          ( PACKAGE_FILE_TAG )
,	FileVersion  ( PACKAGE_FILE_VERSION )
,	PackageFlags ( 0 )
,	NameCount    ( 0 )
,	NameOffset   ( 0 )
,	ExportCount  ( 0 )
,	ExportOffset ( 0 )
,	ImportCount  ( 0 )
,	ImportOffset ( 0 )
{}

/*-----------------------------------------------------------------------------
	ULinker.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010FF20)
ULinker::ULinker( UObject* InRoot, const TCHAR* InFilename )
:	LinkerRoot    ( InRoot )
,	Success       ( 0 )
,	Filename      ( InFilename )
,	_ContextFlags ( 0 )
{
	guard(ULinker::ULinker);
	check(LinkerRoot);
	check(InFilename);
	unguard;
}

IMPL_MATCH("Core.dll", 0x10128C00)
void ULinker::Serialize( FArchive& Ar )
{
	guard(ULinker::Serialize);
	UObject::Serialize( Ar );
	Ar << LinkerRoot;

	// Serialize name/import/export maps.
	Ar << NameMap << ImportMap << ExportMap;

	unguard;
}

IMPL_MATCH("Core.dll", 0x10129680)
FString ULinker::GetImportFullName( INT i )
{
	guard(ULinker::GetImportFullName);
	FString S;
	for( INT j=-i-1; j!=0; j=ImportMap(-j-1).PackageIndex )
	{
		if( S.Len() )
			S = FString(TEXT(".")) + S;
		S = FString(*ImportMap(-j-1).ObjectName) + S;
	}
	return FString(*ImportMap(i).ClassName) + TEXT(" ") + S;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10129980)
FString ULinker::GetExportFullName( INT i, const TCHAR* FakeRoot )
{
	guard(ULinker::GetExportFullName);
	FString S;
	for( INT j=i+1; j!=0; j=ExportMap(j-1).PackageIndex )
	{
		if( S.Len() )
			S = FString(TEXT(".")) + S;
		S = FString(*ExportMap(j-1).ObjectName) + S;
	}
	if( FakeRoot )
		S = FString(FakeRoot) + TEXT(".") + S;
	return S;
	unguard;
}

IMPLEMENT_CLASS(ULinker);

/*-----------------------------------------------------------------------------
	ULinkerLoad.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not exported from Core.dll")
ULinkerLoad::ULinkerLoad( UObject* InParent, const TCHAR* InFilename, DWORD InLoadFlags )
:	ULinker    ( InParent, InFilename )
,	LoadFlags  ( InLoadFlags )
,	Verified   ( 0 )
,	Loader     ( NULL )
{
	guard(ULinkerLoad::ULinkerLoad);

	appMemzero( ExportHash, sizeof(ExportHash) );

	// Create the file reader.
	Loader = GFileManager->CreateFileReader( InFilename, 0, GError );
	if( !Loader )
	{
		appThrowf( TEXT("Failed to open '%s'"), InFilename );
		return;
	}

	// Read summary.
	*Loader << Summary;

	// Verify tag.
	if( Summary.Tag != PACKAGE_FILE_TAG )
	{
		appThrowf( TEXT("'%s' is not an Unreal package"), InFilename );
		return;
	}

	// Read name table.
	Loader->Seek( Summary.NameOffset );
	for( INT i=0; i<Summary.NameCount; i++ )
	{
		FNameEntry NameEntry;
		*Loader << NameEntry;
		NameMap.AddItem( FName( NameEntry.Name, FNAME_Add ) );
	}

	// Read import table.
	Loader->Seek( Summary.ImportOffset );
	for( INT i=0; i<Summary.ImportCount; i++ )
	{
		FObjectImport* Import = new(ImportMap)FObjectImport;
		*Loader << *Import;
	}

	// Read export table.
	Loader->Seek( Summary.ExportOffset );
	for( INT i=0; i<Summary.ExportCount; i++ )
	{
		FObjectExport* Export = new(ExportMap)FObjectExport;
		*Loader << *Export;
	}

	// Build export hash table.
	for( INT i=0; i<ExportMap.Num(); i++ )
	{
		INT iHash                    = ExportMap(i).ObjectName.GetIndex() & 255;
		ExportMap(i)._iHashNext      = ExportHash[iHash];
		ExportHash[iHash]            = i;
	}

	Success = 1;

	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Verify()
{
	guard(ULinkerLoad::Verify);
	if( !Verified )
	{
		Verified = 1;
		// Verify all imports.
		for( INT i=0; i<Summary.ImportCount; i++ )
			VerifyImport(i);
	}
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
FName ULinkerLoad::GetExportClassPackage( INT i )
{
	guard(ULinkerLoad::GetExportClassPackage);
	FObjectExport& Export = ExportMap(i);
	if( Export.ClassIndex < 0 )
		return ImportMap(-Export.ClassIndex-1).ClassPackage;
	else if( Export.ClassIndex > 0 )
		return LinkerRoot->GetFName();
	else
		return FName(TEXT("Core"));
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
FName ULinkerLoad::GetExportClassName( INT i )
{
	guard(ULinkerLoad::GetExportClassName);
	FObjectExport& Export = ExportMap(i);
	if( Export.ClassIndex < 0 )
		return ImportMap(-Export.ClassIndex-1).ObjectName;
	else if( Export.ClassIndex > 0 )
		return ExportMap(Export.ClassIndex-1).ObjectName;
	else
		return FName(NAME_Class);
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::VerifyImport( INT i )
{
	guard(ULinkerLoad::VerifyImport);
	FObjectImport& Import = ImportMap(i);
	if( !Import.XObject )
	{
		// Resolve the import's source linker.
		if( Import.SourceLinker == NULL )
		{
			// Find the package this import comes from.
			INT PackageIndex = Import.PackageIndex;
			if( PackageIndex != 0 )
			{
				// Resolve the outer import first.
				if( PackageIndex < 0 )
					VerifyImport( -PackageIndex - 1 );
			}
		}
	}
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::LoadAllObjects()
{
	guard(ULinkerLoad::LoadAllObjects);
	for( INT i=0; i<ExportMap.Num(); i++ )
		CreateExport(i);
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerLoad::FindExportIndex( FName ClassName, FName ClassPackage, FName ObjectName, INT PackageIndex )
{
	guard(ULinkerLoad::FindExportIndex);
	INT iHash = ObjectName.GetIndex() & 255;
	for( INT i=ExportHash[iHash]; i!=INDEX_NONE; i=ExportMap(i)._iHashNext )
	{
		if( ExportMap(i).ObjectName==ObjectName && ExportMap(i).PackageIndex==PackageIndex )
		{
			if( GetExportClassName(i)==ClassName && GetExportClassPackage(i)==ClassPackage )
				return i;
		}
	}
	return INDEX_NONE;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
UObject* ULinkerLoad::Create( UClass* ObjectClass, FName ObjectName, DWORD InLoadFlags, UBOOL Checked )
{
	guard(ULinkerLoad::Create);
	INT Index = FindExportIndex( FName(ObjectClass->GetName()), FName(ObjectClass->GetOuter()->GetName()), ObjectName, 0 );
	if( Index != INDEX_NONE )
		return CreateExport(Index);
	if( Checked )
		appErrorf( TEXT("Failed to create object '%s' in '%s'"), *ObjectName, *Filename );
	return NULL;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Preload( UObject* Object )
{
	guard(ULinkerLoad::Preload);
	check(Object);
	check(Object->GetLinker()==this);
	INT Index = Object->GetLinkerIndex();
	if( Index != INDEX_NONE )
	{
		FObjectExport& Export = ExportMap(Index);
		if( Export.SerialSize > 0 )
		{
			Loader->Seek( Export.SerialOffset );
			Loader->Precache( Export.SerialSize );
			Object->Serialize( *this );
		}
	}
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
UObject* ULinkerLoad::CreateExport( INT Index )
{
	guard(ULinkerLoad::CreateExport);
	FObjectExport& Export = ExportMap(Index);
	if( Export._Object )
		return Export._Object;

	// Get the export's class.
	UClass* LoadClass = NULL;
	if( Export.ClassIndex != 0 )
	{
		LoadClass = (UClass*)IndexToObject( Export.ClassIndex );
		if( !LoadClass )
			LoadClass = UObject::StaticClass();
	}
	else
	{
		LoadClass = UClass::StaticClass();
	}

	// Get the export's outer.
	UObject* ThisParent = NULL;
	if( Export.PackageIndex )
		ThisParent = IndexToObject( Export.PackageIndex );
	else
		ThisParent = LinkerRoot;

	// Create the object.
	Export._Object = UObject::StaticConstructObject( LoadClass, ThisParent, Export.ObjectName, Export.ObjectFlags & RF_Load, NULL, GError, NULL );

	// Set up linker info for deferred loading.
	if( Export._Object )
	{
		Export._Object->SetLinker( this, Index );
		Export._Object->SetFlags( RF_NeedLoad | RF_NeedPostLoad );
	}

	return Export._Object;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
UObject* ULinkerLoad::CreateImport( INT Index )
{
	guard(ULinkerLoad::CreateImport);
	FObjectImport& Import = ImportMap(Index);
	if( Import.XObject )
		return Import.XObject;

	// Find the import's outer.
	UObject* ClassPackage = NULL;
	UObject* ImportOuter = NULL;
	if( Import.PackageIndex == 0 )
	{
		// Top-level import — find the package.
		ImportOuter = UObject::CreatePackage( NULL, *Import.ObjectName );
		Import.XObject = ImportOuter;
		return Import.XObject;
	}
	else if( Import.PackageIndex < 0 )
	{
		// Outer is another import.
		ImportOuter = CreateImport( -Import.PackageIndex - 1 );
	}
	else
	{
		// Outer is an export.
		ImportOuter = CreateExport( Import.PackageIndex - 1 );
	}

	// Find the imported object.
	if( ImportOuter )
	{
		Import.XObject = UObject::StaticFindObject( NULL, ImportOuter, *Import.ObjectName, 0 );
		if( !Import.XObject )
		{
			// Try loading through the package linker.
			Import.XObject = UObject::StaticLoadObject( NULL, ImportOuter, *Import.ObjectName, NULL, LOAD_NoWarn, NULL );
		}
	}

	return Import.XObject;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
UObject* ULinkerLoad::IndexToObject( INT Index )
{
	guard(ULinkerLoad::IndexToObject);
	if( Index > 0 )
		return CreateExport( Index-1 );
	else if( Index < 0 )
		return CreateImport( -Index-1 );
	else
		return NULL;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::DetachExport( INT i )
{
	guard(ULinkerLoad::DetachExport);
	FObjectExport& Export = ExportMap(i);
	if( Export._Object )
	{
		Export._Object->_Linker      = NULL;
		Export._Object->_LinkerIndex = INDEX_NONE;
		Export._Object               = NULL;
	}
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Serialize( FArchive& Ar )
{
	guard(ULinkerLoad::Serialize_FArchive);
	ULinker::Serialize( Ar );
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Destroy()
{
	guard(ULinkerLoad::Destroy);

	// Detach all exports.
	for( INT i=0; i<ExportMap.Num(); i++ )
		DetachExport(i);

	// Detach lazy loaders.
	DetachAllLazyLoaders(0);

	// Delete loader.
	if( Loader )
		delete Loader;
	Loader = NULL;

	ULinker::Destroy();
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::AttachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::AttachLazyLoader);
	check(LazyLoader);
	LazyLoaders.AddUniqueItem( LazyLoader );
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::DetachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::DetachLazyLoader);
	LazyLoaders.RemoveItem( LazyLoader );
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::DetachAllLazyLoaders( UBOOL Load )
{
	guard(ULinkerLoad::DetachAllLazyLoaders);
	for( INT i=0; i<LazyLoaders.Num(); i++ )
	{
		if( Load )
			LazyLoaders(i)->Load();
		LazyLoaders(i)->Detach();
	}
	LazyLoaders.Empty();
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Seek( INT InPos )
{
	Loader->Seek( InPos );
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerLoad::Tell()
{
	return Loader->Tell();
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerLoad::TotalSize()
{
	return Loader->TotalSize();
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerLoad::Serialize( void* V, INT Length )
{
	Loader->Serialize( V, Length );
}

IMPLEMENT_CLASS(ULinkerLoad);

/*-----------------------------------------------------------------------------
	ULinkerSave.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not exported from Core.dll")
ULinkerSave::ULinkerSave( UObject* InParent, const TCHAR* InFilename )
:	ULinker    ( InParent, InFilename )
,	Saver      ( NULL )
{
	guard(ULinkerSave::ULinkerSave);
	Saver = GFileManager->CreateFileWriter( InFilename, 0, GError );
	if( !Saver )
		appThrowf( TEXT("Failed to create '%s'"), InFilename );
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerSave::Destroy()
{
	guard(ULinkerSave::Destroy);
	if( Saver )
		delete Saver;
	Saver = NULL;
	ULinker::Destroy();
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerSave::MapName( FName* Name )
{
	guard(ULinkerSave::MapName);
	return Name ? NameIndices(Name->GetIndex()) : 0;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerSave::MapObject( UObject* Object )
{
	guard(ULinkerSave::MapObject);
	return Object ? ObjectIndices(Object->GetIndex()) : 0;
	unguard;
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerSave::Seek( INT InPos )
{
	Saver->Seek( InPos );
}

IMPL_DIVERGE("Not exported from Core.dll")
INT ULinkerSave::Tell()
{
	return Saver->Tell();
}

IMPL_DIVERGE("Not exported from Core.dll")
void ULinkerSave::Serialize( void* V, INT Length )
{
	Saver->Serialize( V, Length );
}

IMPLEMENT_CLASS(ULinkerSave);

/*-----------------------------------------------------------------------------
	FObjectExport / FObjectImport Serialize member functions.
	The retail binary exports these as member functions in addition
	to the inline operator<< already in UnLinker.h.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10107D10)
FArchive& FObjectExport::Serialize( FArchive& Ar )
{
	guard(FObjectExport::Serialize);
	Ar << AR_INDEX(ClassIndex);
	Ar << AR_INDEX(SuperIndex);
	Ar << PackageIndex;
	Ar << ObjectName;
	Ar << ObjectFlags;
	Ar << AR_INDEX(SerialSize);
	if( SerialSize )
		Ar << AR_INDEX(SerialOffset);
	return Ar;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10107E00)
FArchive& FObjectImport::Serialize( FArchive& Ar )
{
	guard(FObjectImport::Serialize);
	Ar << ClassPackage << ClassName;
	Ar << PackageIndex;
	Ar << ObjectName;
	if( Ar.IsLoading() )
	{
		SourceIndex = INDEX_NONE;
		XObject     = NULL;
	}
	return Ar;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
