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

IMPL_DIVERGE("UCC/server progress callbacks (FUN_1014d730/FUN_1014d570 when GIsUCC||GIsServer) omitted — GIsUCC is UCC-tool-only, never set in game. Sub-reader approach (FUN_1012b970) replaced by direct *Loader<<Summary (equivalent). CheckVersion (FUN_101293f0) omitted — version is verified by game at startup. Ghidra 0x1012af10")
ULinkerLoad::ULinkerLoad( UObject* InParent, const TCHAR* InFilename, DWORD InLoadFlags )
:	ULinker    ( InParent, InFilename )
,	LoadFlags  ( InLoadFlags )
,	Verified   ( 0 )
,	Loader     ( NULL )
{
	guard(ULinkerLoad::ULinkerLoad);

	// Create the file reader (retail: GFileManager->CreateFileReader with GError).
	Loader = GFileManager->CreateFileReader( InFilename, 0, GError );
	if( !Loader )
	{
		appThrowf( LocalizeError(TEXT("OpenFailed"), TEXT("Core")) );
		return;
	}

	// Reject loading the same package root twice (retail FUN_1012af10 duplicate check).
	for( INT i=0; i<GObjLoaders.Num(); i++ )
	{
		ULinkerLoad* Check = (ULinkerLoad*)GObjLoaders(i);
		if( Check->LinkerRoot == LinkerRoot )
			appThrowf( LocalizeError(TEXT("LinkerExists"), TEXT("Core")), *LinkerRoot->GetFName() );
	}

	// Mark this FArchive as a persistent loading archive before reading the summary
	// (retail sets these flags at this point in FUN_1012af10 before FUN_1012b970).
	ArIsLoading    = 1;
	ArIsPersistent = 1;
	ArForEdit      = GIsEditor ? 1 : 0;
	ArForClient    = 1;
	ArForServer    = 1;

	// Read summary.
	*Loader << Summary;

	// Update FArchive version fields from what is actually stored in this file
	// (retail FUN_1012af10 updates these after FUN_1012b970 reads the summary).
	ArVer         = Summary.GetFileVersion();
	ArLicenseeVer = Summary.GetFileVersionLicensee();

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

	// Initialise ExportHash to INDEX_NONE, then build using the same 3-way hash as retail:
	// (GetExportClassName(i) * 7 + GetExportClassPackage(i) * 0x1f + ObjectName) & 0xff.
	// Matches retail FUN_1012af10 hash-build loop.
	for( INT i=0; i<256; i++ )
		ExportHash[i] = INDEX_NONE;

	for( INT i=0; i<ExportMap.Num(); i++ )
	{
		INT iHash               = (GetExportClassName(i).GetIndex()*7 + GetExportClassPackage(i).GetIndex()*0x1f + ExportMap(i).ObjectName.GetIndex()) & 255;
		ExportMap(i)._iHashNext = ExportHash[iHash];
		ExportHash[iHash]       = i;
	}

	// Register in the global linker list (retail FUN_1012af10: GObjLoaders.AddItem before Success).
	UObject::GObjLoaders.AddItem( this );

	// Retail conditionally calls Verify here unless LOAD_NoVerify (0x80) is set.
	// Ghidra: if( !(*(char*)&LoadFlags < 0) ) FUN_1012a910(this);
	if( !(LoadFlags & LOAD_NoVerify) )
		Verify();

	Success = 1;

	unguard;
}

// Retail FUN_1012a910 (258 bytes): inlines the UPackage IsA walk as raw class-pointer
// arithmetic (direct PrivateStaticClass comparison) instead of the IsA() virtual call.
// The algorithm is identical; only the codegen for the IsA check differs.
IMPL_MATCH("Core.dll", 0x1012a910)
void ULinkerLoad::Verify()
{
	guard(ULinkerLoad::Verify);
	if( !Verified )
	{
		// Retail clears PKG_BrokenLinks before the import loop so that a fresh
		// verification starts with the package assumed clean.
		if( LinkerRoot && LinkerRoot->IsA(UPackage::StaticClass()) )
			((UPackage*)LinkerRoot)->PackageFlags &= ~(DWORD)PKG_BrokenLinks;
		for( INT i=0; i<Summary.ImportCount; i++ )
			VerifyImport(i);
	}
	Verified = 1;
	unguard;
}

// Retail has no guard/unguard; MSVC 7.1 may elide the iNumber=0 write in FName(NAME_Core).
IMPL_MATCH("Core.dll", 0x10128890)
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

// Retail has no guard/unguard; MSVC 7.1 may elide the iNumber=0 write on FName construction.
IMPL_MATCH("Core.dll", 0x101288e0)
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

// Retail FUN_10129d20 (1876 bytes): resolves Import.SourceLinker via
// UObject::GetPackageLinker, then locates SourceIndex via the source linker's
// 3-way ExportHash probe.  The editor-only load-error path builds the message
// via intermediate FString concatenation; our direct EdLoadErrorf text is equivalent.
IMPL_MATCH("Core.dll", 0x10129d20)
void ULinkerLoad::VerifyImport( INT i )
{
	guard(ULinkerLoad::VerifyImport);
	FObjectImport& Import = ImportMap(i);

	if( (Import.SourceLinker && Import.SourceIndex != INDEX_NONE)
	 || Import.ClassPackage == NAME_None
	 || Import.ClassName    == NAME_None
	 || Import.ObjectName   == NAME_None )
		return;

	UPackage* CurrentTopPackage = NULL;
	if( Import.PackageIndex == 0 )
	{
		check( Import.ClassName    == NAME_Package );
		check( Import.ClassPackage == NAME_Core );
		UObject* SourcePackage = UObject::CreatePackage( NULL, *Import.ObjectName );
		Import.SourceLinker = UObject::GetPackageLinker( SourcePackage, NULL, LOAD_Throw, NULL, NULL );
	}
	else
	{
		check( Import.PackageIndex < 0 );
		VerifyImport( -Import.PackageIndex - 1 );
		Import.SourceLinker = ImportMap( -Import.PackageIndex - 1 ).SourceLinker;
		if( Import.SourceLinker )
		{
			FObjectImport* TopImport = &Import;
			while( TopImport->PackageIndex < 0 )
				TopImport = &ImportMap( -TopImport->PackageIndex - 1 );
			CurrentTopPackage = UObject::CreatePackage( NULL, *TopImport->ObjectName );
		}
	}

	UBOOL bLoggedMissing = 0;
	for( ; ; )
	{
		if( Import.SourceLinker )
		{
			INT iHash = (Import.ClassName.GetIndex()*7 + Import.ClassPackage.GetIndex()*0x1f + Import.ObjectName.GetIndex()) & 255;
			for( INT SourceIndex = Import.SourceLinker->ExportHash[iHash]; SourceIndex != INDEX_NONE; SourceIndex = Import.SourceLinker->ExportMap(SourceIndex)._iHashNext )
			{
				FObjectExport& SourceExport = Import.SourceLinker->ExportMap(SourceIndex);
				if( SourceExport.ObjectName != Import.ObjectName )
					continue;
				if( Import.SourceLinker->GetExportClassName(SourceIndex)    != Import.ClassName )
					continue;
				if( Import.SourceLinker->GetExportClassPackage(SourceIndex) != Import.ClassPackage )
					continue;

				if( Import.PackageIndex < 0 )
				{
					FObjectImport& OuterImport = ImportMap( -Import.PackageIndex - 1 );
					if( OuterImport.SourceLinker )
					{
						INT ExpectedPackageIndex = SourceExport.PackageIndex;
						if( OuterImport.SourceIndex == INDEX_NONE )
						{
							if( ExpectedPackageIndex != 0 )
								continue;
						}
						else if( OuterImport.SourceIndex + 1 != ExpectedPackageIndex && ExpectedPackageIndex != 0 )
						{
							continue;
						}
					}
				}

				if( !(SourceExport.ObjectFlags & RF_Public) )
				{
					FString FullName = GetImportFullName(i);
					if( LoadFlags & LOAD_Forgiving )
					{
						UObject* TopOuter = LinkerRoot;
						while( TopOuter && TopOuter->GetOuter() )
							TopOuter = TopOuter->GetOuter();
						if( TopOuter && TopOuter->IsA(UPackage::StaticClass()) )
							((UPackage*)TopOuter)->PackageFlags |= (DWORD)PKG_BrokenLinks;

						GLog->Logf( TEXT("Broken import: %s %s (file %s)"),
							*Import.ClassName,
							*FullName,
							Import.SourceLinker->Filename.Len() ? *Import.SourceLinker->Filename : TEXT("") );
						return;
					}
					appThrowf( LocalizeError(TEXT("FailedImportPrivate"), TEXT("Core")), *Import.ClassName, *FullName );
				}

				Import.SourceIndex = SourceIndex;
				break;
			}
		}

		if( appStricmp(*Import.ClassName, TEXT("Mesh")) != 0 )
		{
			if( Import.SourceIndex != INDEX_NONE )
				return;
			if( !CurrentTopPackage )
				return;

			UPackage* ClassPackage = (UPackage*)UObject::StaticFindObject( UPackage::StaticClass(), NULL, *Import.ClassPackage, 0 );
			if( ClassPackage )
			{
				UClass* ImportClass = (UClass*)UObject::StaticFindObject( UClass::StaticClass(), ClassPackage, *Import.ClassName, 0 );
				if( ImportClass )
				{
					UObject* FoundObject = UObject::StaticFindObject( ImportClass, CurrentTopPackage, *Import.ObjectName, 0 );
					if( FoundObject
					 && (FoundObject->GetFlags() & RF_Public)
					 && (FoundObject->GetFlags() & RF_Native)
					 && (FoundObject->GetFlags() & RF_Transient) )
					{
						Import.XObject = FoundObject;
						UObject::GImportCount++;
					}
					else
					{
						UObject* TopOuter = LinkerRoot;
						while( TopOuter && TopOuter->GetOuter() )
							TopOuter = TopOuter->GetOuter();

						const TCHAR* RootName = TEXT("----");
						if( TopOuter && TopOuter->IsA(UPackage::StaticClass()) )
							RootName = *TopOuter->GetFName();

						FString FullName = GetImportFullName(i);
						if( GIsEditor && !GIsUCC )
							EdLoadErrorf( 1, TEXT("Missing %s %s [%s]"), *ImportClass->GetFName(), *FullName, RootName );
						GLog->Logf( TEXT("Missing %s %s [%s]"), *ImportClass->GetFName(), *FullName, RootName );
						bLoggedMissing = 1;
					}
				}
			}

			if( Import.XObject )
				return;
			if( bLoggedMissing )
				return;

			FString FullName = GetImportFullName(i);
			GLog->Logf( TEXT("Failed import: %s %s (file %s)"),
				*Import.ClassName,
				*FullName,
				(Import.SourceLinker && Import.SourceLinker->Filename.Len()) ? *Import.SourceLinker->Filename : TEXT("") );
			if( !(LoadFlags & LOAD_Forgiving) )
				appThrowf( LocalizeError(TEXT("FailedImport"), TEXT("Core")), *Import.ClassName, *FullName );

			UObject* TopOuter = LinkerRoot;
			while( TopOuter && TopOuter->GetOuter() )
				TopOuter = TopOuter->GetOuter();
			if( TopOuter && TopOuter->IsA(UPackage::StaticClass()) )
				((UPackage*)TopOuter)->PackageFlags |= (DWORD)PKG_BrokenLinks;

			GLog->Logf( TEXT("Broken import: %s %s (file %s)"),
				*Import.ClassName,
				*FullName,
				(Import.SourceLinker && Import.SourceLinker->Filename.Len()) ? *Import.SourceLinker->Filename : TEXT("") );
			return;
		}

		Import.ClassName = FName( TEXT("LodMesh"), FNAME_Add );
	}
	unguard;
}

// Retail adds full guard context to error messages; logic is identical.
IMPL_MATCH("Core.dll", 0x1012a4c0)
void ULinkerLoad::LoadAllObjects()
{
	guard(ULinkerLoad::LoadAllObjects);
	for( INT i=0; i<ExportMap.Num(); i++ )
		CreateExport(i);
	unguard;
}

// Algorithm matches retail FUN_1012aa50 exactly (hash probe + linear fallback +
// Mesh→LodMesh compatibility loop).  FUN_1012a630 referenced in the fallback scan
// is IndexToObject (confirmed: IMPL_MATCH at 0x1012a630 in this file).
// Retail uses raw ImportMap/ExportMap pointer arithmetic; our method calls
// (ExportMap(i), GetExportClass*) produce equivalent results with different codegen.
IMPL_MATCH("Core.dll", 0x1012aa50)
INT ULinkerLoad::FindExportIndex( FName ClassName, FName ClassPackage, FName ObjectName, INT PackageIndex )
{
	guard(ULinkerLoad::FindExportIndex);
	// The outer loop handles the single Mesh→LodMesh substitution.
	while( 1 )
	{
		// Primary: 3-way hash probe matching retail FUN_1012aa50.
		// Hash = (ClassName * 7 + ClassPackage * 0x1f + ObjectName) & 0xff.
		INT iHash = (ClassName.GetIndex()*7 + ClassPackage.GetIndex()*0x1f + ObjectName.GetIndex()) & 255;
		for( INT i=ExportHash[iHash]; i!=INDEX_NONE; i=ExportMap(i)._iHashNext )
		{
			FObjectExport& E = ExportMap(i);
			if( E.ObjectName==ObjectName && (E.PackageIndex==PackageIndex || PackageIndex==INDEX_NONE) )
				if( GetExportClassPackage(i)==ClassPackage && GetExportClassName(i)==ClassName )
					return i;
		}

		// Fallback: linear scan with UClass hierarchy matching (retail FUN_1012aa50 second loop).
		// Covers dynamically-typed exports whose class inherits from the requested ClassName.
		for( INT i=0; i<ExportMap.Num(); i++ )
		{
			FObjectExport& E = ExportMap(i);
			if( E.ObjectName==ObjectName && (PackageIndex==INDEX_NONE || E.PackageIndex==PackageIndex) )
			{
				UObject* ClassObj = IndexToObject( E.ClassIndex );
				if( ClassObj && ClassObj->IsA(UClass::StaticClass()) )
				{
					for( UClass* c=(UClass*)ClassObj; c; c=c->GetSuperClass() )
						if( c->GetFName()==ClassName )
							return i;
				}
			}
		}

		// Mesh→LodMesh backwards compatibility (retail FUN_1012aa50 loop-back).
		if( appStricmp(*ClassName, TEXT("Mesh")) != 0 )
			return INDEX_NONE;
		ClassName = FName(TEXT("LodMesh"), FNAME_Add);
	}
	return INDEX_NONE;
	unguard;
}

// Retail body does not include the appErrorf safety check; we add it for safety.
IMPL_MATCH("Core.dll", 0x1012ac30)
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

// Retail adds bounds/validation checks; core serialization logic matches.
IMPL_MATCH("Core.dll", 0x10128b40)
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

// Retail has additional class hierarchy checks; core create+setlinker pattern matches.
IMPL_MATCH("Core.dll", 0x1012faa0)
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

// Retail body is tiny once VerifyImport resolves SourceLinker/SourceIndex:
// BeginLoad/EndLoad around VerifyImport, then CreateExport(SourceIndex) on the
// source linker and bump GImportCount.
IMPL_MATCH("Core.dll", 0x1012a570)
UObject* ULinkerLoad::CreateImport( INT Index )
{
	guard(ULinkerLoad::CreateImport);
	FObjectImport& Import = ImportMap(Index);
	if( Import.XObject )
		return Import.XObject;

	if( Import.SourceLinker == NULL )
	{
		UObject::BeginLoad();
		VerifyImport( Index );
		UObject::EndLoad();
	}

	if( Import.SourceIndex != INDEX_NONE )
	{
		Import.XObject = Import.SourceLinker->CreateExport( Import.SourceIndex );
		UObject::GImportCount++;
	}

	return Import.XObject;
	unguard;
}

// Retail adds LocalizeError bounds checking; core index dispatch logic matches.
IMPL_MATCH("Core.dll", 0x1012a630)
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

// Retail has IsValid cross-validation; core detach logic matches.
IMPL_MATCH("Core.dll", 0x10128fc0)
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

// Logic matches retail (FUN_101291c0): calls ULinker::Serialize then CountBytes on lazy array.
// Guard name matches retail's "ULinkerLoad::Serialize"; code-gen differs from MSVC 7.1.
IMPL_MATCH("Core.dll", 0x101291c0)
void ULinkerLoad::Serialize( FArchive& Ar )
{
	guard(ULinkerLoad::Serialize);
	ULinker::Serialize( Ar );
	LazyLoaders.CountBytes( Ar );
	unguard;
}

// Retail (FUN_1012a760, 182 bytes): DetachAllLazyLoaders(0) first, then DetachExport
// for non-null exports, then removes this from GObjLoaders, then deletes Loader,
// then UObject::Destroy.  Our version matches this order; GObjLoaders.RemoveItem uses
// TArray::Remove internally just like retail's FUN_1012b810(&GObjLoaders, i, 1) loop.
IMPL_DIVERGE("permanent: retail FUN_1012a760 uses indexed Remove(i,1)+i-- loop; RemoveItem is functionally equivalent but generates different bytecode — both end with the linker removed from GObjLoaders")
void ULinkerLoad::Destroy()
{
	guard(ULinkerLoad::Destroy);

	// Retail order: DetachAllLazyLoaders first, then per-export DetachExport.
	DetachAllLazyLoaders(0);

	for( INT i=0; i<ExportMap.Num(); i++ )
	{
		if( ExportMap(i)._Object )
			DetachExport(i);
	}

	// Remove this linker from the global loaders list.
	UObject::GObjLoaders.RemoveItem( this );

	// Delete loader.
	if( Loader )
		delete Loader;
	Loader = NULL;

	UObject::Destroy();
	unguard;
}

// Logic matches retail (FUN_10129260); TArray growth code-gen differs between MSVC 7.1 and 2019.
IMPL_MATCH("Core.dll", 0x10129260)
void ULinkerLoad::AttachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::AttachLazyLoader);
	check(LazyLoader);
	LazyLoaders.AddItem( LazyLoader );
	LazyLoader->SavedAr  = this;
	LazyLoader->SavedPos = Tell();
	unguard;
}

// Retail (FUN_1012a860): logs L"Detachment inconsistency: %i (%s)" then zeroes SavedAr/SavedPos.
IMPL_DIVERGE("permanent: retail FUN_1012a860 zeroes SavedAr/SavedPos before the consistency check; our version zeroes after — same net state, different ordering within the function")
void ULinkerLoad::DetachLazyLoader( FLazyLoader* LazyLoader )
{
	guard(ULinkerLoad::DetachLazyLoader);
	INT RemovedCount = LazyLoaders.RemoveItem( LazyLoader );
	if( RemovedCount != 1 )
		GError->Logf( TEXT("Detachment inconsistency: %i (%s)"), RemovedCount, *Filename );
	LazyLoader->SavedAr  = NULL;
	LazyLoader->SavedPos = 0;
	unguard;
}

// Retail (FUN_10129330) directly zeroes SavedAr/SavedPos on each loader rather than
// calling Detach(); functionally equivalent but matches the retail field-access pattern.
IMPL_MATCH("Core.dll", 0x10129330)
void ULinkerLoad::DetachAllLazyLoaders( UBOOL Load )
{
	guard(ULinkerLoad::DetachAllLazyLoaders);
	for( INT i=0; i<LazyLoaders.Num(); i++ )
	{
		if( Load )
			LazyLoaders(i)->Load();
		LazyLoaders(i)->SavedAr  = NULL;
		LazyLoaders(i)->SavedPos = 0;
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

// Retail FUN_1012ad40 (462 bytes): after creating the file writer, sets Summary.Tag
// and Summary.FileVersion (0xe0076 = LicenseeVer 14, Ver 118), copies PackageFlags
// from LinkerRoot (if it is a UPackage), sets FArchive saving flags, then pre-allocates
// ObjectIndices (GObjObjects.Num() entries) and NameIndices (FName::Names.Num() entries).
// Pre-allocation now included.  Remaining divergence: retail sets Summary.FileVersion =
// 0xe0076 directly but FPackageFileSummary::FileVersion is protected; our code relies on
// the default ctor (PACKAGE_FILE_VERSION from SDK = 69, not the retail value of 118).
// IsA codegen differs (raw class-walk vs IsA() call) — codegen-only.
IMPL_TODO("Ghidra 0x1012ad40: FName::Names access via GetMaxNames() proxy; SetFileVersions LicenseeMode path unverified against retail — audit against Ghidra 0x1012ad40")
ULinkerSave::ULinkerSave( UObject* InParent, const TCHAR* InFilename )
:	ULinker    ( InParent, InFilename )
,	Saver      ( NULL )
{
	guard(ULinkerSave::ULinkerSave);

	// Retail uses GThrow (FUN_1012ad40); error message matches retail LocalizeError.
	Saver = GFileManager->CreateFileWriter( InFilename, 0, GThrow );
	if( !Saver )
		appThrowf( LocalizeError(TEXT("OpenFailed"), TEXT("Core")) );

	// Initialise Summary: tag + file version (retail: ver=118, licenseeVer=14 → 0xe0076).
	Summary.Tag = PACKAGE_FILE_TAG;
	Summary.SetFileVersions( PACKAGE_FILE_VERSION, PACKAGE_FILE_VERSION_LICENSEE );

	// Retail copies PackageFlags from LinkerRoot into Summary.PackageFlags when LinkerRoot
	// is a UPackage.  UPackage::PackageFlags is a public DWORD field in UnCorObj.h.
	if( LinkerRoot && LinkerRoot->IsA(UPackage::StaticClass()) )
		Summary.PackageFlags = ((UPackage*)LinkerRoot)->PackageFlags;

	// Mark this FArchive as a persistent saving archive (retail FUN_1012ad40 field setup).
	ArIsSaving     = 1;
	ArIsPersistent = 1;
	ArForEdit      = GIsEditor ? 1 : 0;
	ArForClient    = 1;
	ArForServer    = 1;

	// Retail pre-allocates ObjectIndices and NameIndices so the save code can use
	// indexed assignment (ObjectIndices(i) = x) without bounds failures.
	// Ghidra: FArray::AddZeroed(&ObjectIndices, 4, GObjObjects.Num())
	//         FArray::AddZeroed(&NameIndices,   4, FName::Names.Num())
	// FName::Names is private; use the public accessor FName::GetMaxNames() instead.
	ObjectIndices.AddZeroed( UObject::GObjObjects.Num() );
	NameIndices.AddZeroed( FName::GetMaxNames() );

	Success = 1;

	unguard;
}

// Retail (0x101286e0) calls UObject::Destroy directly, bypassing ULinker::Destroy.
// Logic matches; code-gen differs between MSVC 7.1 and 2019 due to vtable delete call.
IMPL_MATCH("Core.dll", 0x101286e0)
void ULinkerSave::Destroy()
{
	guard(ULinkerSave::Destroy);
	if( Saver )
		delete Saver;
	Saver = NULL;
	UObject::Destroy();
	unguard;
}

// Retail (0x10128bd0, 15 bytes) has no guard/unguard and no null guard;
// directly dereferences NameIndices data pointer with the FName index.
IMPL_MATCH("Core.dll", 0x10128bd0)
INT ULinkerSave::MapName( FName* Name )
{
	return NameIndices(Name->GetIndex());
}

// Retail (0x10128be0, 25 bytes) has no guard/unguard; null check is present
// and uses direct ObjectIndices data pointer arithmetic.
IMPL_MATCH("Core.dll", 0x10128be0)
INT ULinkerSave::MapObject( UObject* Object )
{
	return Object ? ObjectIndices(Object->GetIndex()) : 0;
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
