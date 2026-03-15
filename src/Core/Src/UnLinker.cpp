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

IMPL_DIVERGE("Retail (0x1012af10, ~1741 bytes) checks GObjLoaders for existing linkers, handles UCC/server context, and reads FPackageFileSummary via a complex internal reader; our version is significantly simplified")
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

IMPL_DIVERGE("Retail (catch@0x1012aa12) registers the linker in GObjLoaders in addition to verifying imports; our version omits linker lifecycle management")
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

IMPL_DIVERGE("Retail (FUN_10128890) has no guard/unguard; iNumber not written in retail (only iName set), as MSVC 7.1 elides iNumber=0; code-gen differs from our MSVC 2019 build")
FName ULinkerLoad::GetExportClassPackage( INT i )
{
	FObjectExport& Export = ExportMap(i);
	if( Export.ClassIndex < 0 )
		return ImportMap(-Export.ClassIndex-1).ClassPackage;
	else if( Export.ClassIndex > 0 )
		return LinkerRoot->GetFName();
	else
		return FName(NAME_Core);
}

IMPL_DIVERGE("Retail (at 0x101288e0, ~73 bytes) has no guard/unguard; iNumber not written in retail paths; code-gen differs from our MSVC 2019 build")
FName ULinkerLoad::GetExportClassName( INT i )
{
	FObjectExport& Export = ExportMap(i);
	if( Export.ClassIndex < 0 )
		return ImportMap(-Export.ClassIndex-1).ObjectName;
	else if( Export.ClassIndex > 0 )
		return ExportMap(Export.ClassIndex-1).ObjectName;
	else
		return FName(NAME_Class);
}

IMPL_DIVERGE("Retail (catch@0x1012a4a6) resolves imports through a full linker chain; our version is a simplified stub")
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

IMPL_DIVERGE("Retail (catch@0x1012a524) iterates ExportMap calling CreateExport; concept matches but retail internals differ")
void ULinkerLoad::LoadAllObjects()
{
	guard(ULinkerLoad::LoadAllObjects);
	for( INT i=0; i<ExportMap.Num(); i++ )
		CreateExport(i);
	unguard;
}

IMPL_DIVERGE("Retail (FUN_1012aa50) uses a 3-way hash (ClassName*7 + ClassPackage*0x1f + ObjectName) & 0xff with a linear-scan fallback and a Mesh→LodMesh compatibility loop; our version uses only ObjectName hash with no fallback or compat shim")
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

IMPL_DIVERGE("Retail (0x1012ac30, ~209 bytes) calls FindExportIndex internally; concept matches but retail omits the Checked/error-path logic we have")
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

IMPL_DIVERGE("Retail (catch@0x10128baf) implements Preload with validation; concept matches but may have divergences in seek/precache handling")
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

IMPL_DIVERGE("Retail (catch@0x1012fbac) creates exports; concept matches but struct field offsets and flag handling may differ")
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

IMPL_DIVERGE("Retail (catch@0x1012bc4) has significant divergences in import resolution logic compared to our version")
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

IMPL_DIVERGE("Retail (0x1012a630, ~247 bytes) has bounds checking our version lacks; otherwise concept matches")
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

IMPL_DIVERGE("Retail (0x10128fc0, ~450 bytes) has extensive validation and error logging; our version is a simplified stub")
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

IMPL_DIVERGE("Retail (FUN_101291c0 at 0x101291c0) calls ULinker::Serialize then Ar.CountBytes(LazyLoaders.Num()*4, LazyLoaders.Max()*4); our version matches this logic but generates different code (register allocation differs between MSVC 7.1 and MSVC 2019)")
void ULinkerLoad::Serialize( FArchive& Ar )
{
	guard(ULinkerLoad::Serialize_FArchive);
	ULinker::Serialize( Ar );
	LazyLoaders.CountBytes( Ar );
	unguard;
}

IMPL_DIVERGE("Retail (0x1012a760) removes the linker from GObjLoaders; our version omits linker lifecycle management")
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

IMPL_DIVERGE("Retail (FUN_10129260 at 0x10129260) appends unconditionally then sets LazyLoader->SavedAr = this (FArchive*) and SavedPos = Tell(); our version matches this logic but TArray growth code generation differs from retail MSVC 7.1")
void ULinkerLoad::AttachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::AttachLazyLoader);
	check(LazyLoader);
	LazyLoaders.AddItem( LazyLoader );
	LazyLoader->SavedAr  = this;
	LazyLoader->SavedPos = Tell();
	unguard;
}

IMPL_DIVERGE("Retail (FUN_1012a860 at 0x1012a860) removes from the array then unconditionally zeros SavedAr/SavedPos, and logs to GError if removal count != 1; our version omits the warning log")
void ULinkerLoad::DetachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::DetachLazyLoader);
	LazyLoaders.RemoveItem( LazyLoader );
	LazyLoader->SavedAr  = NULL;
	LazyLoader->SavedPos = 0;
	unguard;
}

IMPL_DIVERGE("Retail (FUN_10129330 at 0x10129330) iterates the array calling Load() if requested, then directly zeroes SavedAr/SavedPos on each loader, then calls FArray::Realloc to free; our version is functionally equivalent — Detach() zeroes the same fields, Empty() frees the array — but the generated code differs from retail")
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

IMPL_MATCH("Core.dll", 0x101284e0)
void ULinkerLoad::Seek( INT InPos )
{
	guard(ULinkerLoad::Seek);
	Loader->Seek( InPos );
	unguard;
}

IMPL_MATCH("Core.dll", 0x10128560)
INT ULinkerLoad::Tell()
{
	guard(ULinkerLoad::Tell);
	return Loader->Tell();
	unguard;
}

IMPL_MATCH("Core.dll", 0x101285e0)
INT ULinkerLoad::TotalSize()
{
	guard(ULinkerLoad::TotalSize);
	return Loader->TotalSize();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10128660)
void ULinkerLoad::Serialize( void* V, INT Length )
{
	guard(ULinkerLoad::Serialize);
	Loader->Serialize( V, Length );
	unguard;
}

IMPLEMENT_CLASS(ULinkerLoad);

/*-----------------------------------------------------------------------------
	ULinkerSave.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Retail (0x1012ad40, ~462 bytes) initializes FArchive state, handles package flags, and sets up class hierarchy; our version is significantly simplified")
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

IMPL_DIVERGE("Retail (0x101286e0) calls UObject::Destroy directly (bypassing ULinker::Destroy); guard/unguard frame and vtable delete call generate differently under MSVC 2019 vs 7.1")
void ULinkerSave::Destroy()
{
	guard(ULinkerSave::Destroy);
	if( Saver )
		delete Saver;
	Saver = NULL;
	UObject::Destroy();
	unguard;
}

IMPL_DIVERGE("Retail (0x10128bd0, 15 bytes) has no guard, no NULL guard, and directly indexes NameIndices data pointer without bounds check: mov eax,[esp+4]; mov edx,[eax]; mov eax,[ecx+0x50]; mov eax,[eax+edx*4]; ret 4. Our version has guard/unguard and NULL check.")
INT ULinkerSave::MapName( FName* Name )
{
	guard(ULinkerSave::MapName);
	return Name ? NameIndices(Name->GetIndex()) : 0;
	unguard;
}

IMPL_DIVERGE("Retail (0x10128be0, 25 bytes) has no guard, NULL check present, but uses direct ObjectIndices data pointer arithmetic (mov eax,[eax+4]; mov ecx,[ecx+0x44]; mov eax,[ecx+eax*4]) vs our TArray bounds-checked accessor. Code-gen differs between MSVC 7.1 and 2019.")
INT ULinkerSave::MapObject( UObject* Object )
{
	guard(ULinkerSave::MapObject);
	return Object ? ObjectIndices(Object->GetIndex()) : 0;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10128770)
void ULinkerSave::Seek( INT InPos )
{
	Saver->Seek( InPos );
}

IMPL_MATCH("Core.dll", 0x10128780)
INT ULinkerSave::Tell()
{
	return Saver->Tell();
}

IMPL_MATCH("Core.dll", 0x10128790)
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
