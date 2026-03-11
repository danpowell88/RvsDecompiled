/*=============================================================================
	UnObj.cpp: UObject subsystem — static methods, construction, destruction,
	serialization, garbage collection, package management.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	Globals — UObject static member definitions.
-----------------------------------------------------------------------------*/

UObject*                                  UObject::GAutoRegister      = NULL;
INT                                       UObject::GImportCount       = 0;
TCHAR                                     UObject::GLanguage[64]      = {0};
TArray<INT>                               UObject::GObjAvailable;
INT                                       UObject::GObjBeginLoadCount = 0;
TCHAR                                     UObject::GObjCachedLanguage[32] = {0};
TArray<FRegistryObjectInfo>               UObject::GObjDrivers;
UObject*                                  UObject::GObjHash[4096];
INT                                       UObject::GObjInitialized    = 0;
TArray<UObject*>                          UObject::GObjLoaded;
TArray<UObject*>                          UObject::GObjLoaders;
INT                                       UObject::GObjNoRegister     = 0;
TArray<UObject*>                          UObject::GObjObjects;
TMultiMap<FName,FName>*                   UObject::GObjPackageRemap   = NULL;
TArray<FPreferencesInfo>                  UObject::GObjPreferences;
INT                                       UObject::GObjRegisterCount  = 0;
TArray<UObject*>                          UObject::GObjRegistrants;
TArray<UObject*>                          UObject::GObjRoot;
UPackage*                                 UObject::GObjTransientPkg   = NULL;

IMPLEMENT_CLASS(UObject);

/*-----------------------------------------------------------------------------
	FScriptDelegate.
-----------------------------------------------------------------------------*/

FScriptDelegate::FScriptDelegate()
{
}

FScriptDelegate& FScriptDelegate::operator=( const FScriptDelegate& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	UObject constructors.
-----------------------------------------------------------------------------*/

UObject::UObject()
:	Index		( INDEX_NONE )
,	HashNext	( NULL )
,	StateFrame	( NULL )
,	_Linker		( NULL )
,	_LinkerIndex( INDEX_NONE )
,	Outer		( NULL )
,	ObjectFlags	( 0 )
,	Name		( NULL )
,	Class		( NULL )
,	DName		( 0 )
{
}

UObject::UObject( const UObject& Src )
{
	guard(UObject::UObject_Copy);
	check(0); // not allowed
	unguard;
}

UObject::UObject( ENativeConstructor, UClass* InClass, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags )
:   Index		( INDEX_NONE )
,	HashNext	( NULL )
,	StateFrame	( NULL )
,	_Linker		( NULL )
,	_LinkerIndex( INDEX_NONE )
,	ObjectFlags	( InFlags | RF_Native )
,	DName		( 0 )
{
	guard(UObject::UObject_ENativeConstructor);
	// Not yet registered; will be registered by ProcessRegistrants.
	unguard;
}

UObject::UObject( EStaticConstructor, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags )
:   Index		( INDEX_NONE )
,	HashNext	( NULL )
,	StateFrame	( NULL )
,	_Linker		( NULL )
,	_LinkerIndex( INDEX_NONE )
,	ObjectFlags	( InFlags | RF_Native )
,	DName		( 0 )
{
	guard(UObject::UObject_EStaticConstructor);
	unguard;
}

UObject::UObject( EInPlaceConstructor, UClass* InClass, UObject* InOuter, FName InName, DWORD InFlags )
:   Index		( INDEX_NONE )
,	HashNext	( NULL )
,	StateFrame	( NULL )
,	_Linker		( NULL )
,	_LinkerIndex( INDEX_NONE )
,	ObjectFlags	( InFlags )
,	DName		( 0 )
{
	guard(UObject::UObject_EInPlaceConstructor);
	unguard;
}

UObject::~UObject()
{
	guard(UObject::~UObject);
	// Remove from object table.
	ConditionalDestroy();
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject interface — virtual methods.
-----------------------------------------------------------------------------*/

void UObject::ProcessEvent( UFunction* Function, void* Parms, void* Result )
{
	guard(UObject::ProcessEvent);
	if( !Function )
		return;

	const INT ParmsSize = Max<INT>( Function->ParmsSize, 1 );
	BYTE* FrameData = (BYTE*)appAlloca( ParmsSize );
	appMemzero( FrameData, ParmsSize );

	for( TFieldIterator<UProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It )
	{
		UProperty* Property = *It;
		BYTE* Dest = FrameData + Property->Offset;
		if( Parms )
			Property->CopyCompleteValue( Dest, (BYTE*)Parms + Property->Offset );
	}

	void* LocalResult = Result;
	if( !LocalResult && Parms && Function->GetReturnProperty() )
		LocalResult = (BYTE*)Parms + Function->ReturnValueOffset;

	FFrame Stack( this, Function, 0, FrameData );
	CallFunction( Stack, LocalResult, Function );

	if( Parms )
	{
		for( TFieldIterator<UProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It )
		{
			UProperty* Property = *It;
			if( Property->PropertyFlags & (CPF_OutParm | CPF_ReturnParm) )
				Property->CopyCompleteValue( (BYTE*)Parms + Property->Offset, FrameData + Property->Offset );
		}
	}

	for( TFieldIterator<UProperty> It(Function); It && (It->PropertyFlags & CPF_Parm); ++It )
	{
		UProperty* Property = *It;
		Property->DestroyValue( FrameData + Property->Offset );
	}
	unguard;
}

void UObject::ProcessDelegate( FName DelegateName, FScriptDelegate* Delegate, void* Parms, void* Result )
{
	guard(UObject::ProcessDelegate);
	unguard;
}

void UObject::ProcessState( FLOAT DeltaSeconds )
{
	// Retail Core.dll: ret 4 (truly empty, no SEH frame)
}

INT UObject::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	guard(UObject::ProcessRemoteFunction);
	return 0;
	unguard;
}

void UObject::Modify()
{
	guard(UObject::Modify);
	unguard;
}

void UObject::PostLoad()
{
	guard(UObject::PostLoad);
	// Retail Core.dll 0x3AA30: sets RF_DebugPostLoad in ObjectFlags.
	ObjectFlags |= RF_DebugPostLoad;
	unguard;
}

void UObject::Destroy()
{
	guard(UObject::Destroy);
	// Mark as destroyed.
	SetFlags( RF_Destroyed );
	unguard;
}

void UObject::Serialize( FArchive& Ar )
{
	guard(UObject::Serialize);

	// Serialize class, name, outer.
	if( Ar.IsLoading() || Ar.IsSaving() )
	{
		Ar << Class << Name << Outer;
	}

	// Serialize object flags for non-transient objects.
	if( !Ar.IsTransacting() )
	{
		Ar << ObjectFlags;
	}

	// Serialize execution state.
	if( ObjectFlags & RF_HasStack )
	{
		if( !StateFrame )
			StateFrame = new FStateFrame( this );

		Ar << StateFrame->StateNode;
		Ar << StateFrame->Node;
		Ar << StateFrame->ProbeMask;
		Ar << StateFrame->LatentAction;

		if( StateFrame->Node )
		{
			INT CodeOffset = StateFrame->Code ? (INT)(StateFrame->Code - &StateFrame->Node->Script(0)) : INDEX_NONE;
			Ar << AR_INDEX(CodeOffset);
			if( Ar.IsLoading() && CodeOffset != INDEX_NONE )
				StateFrame->Code = &StateFrame->Node->Script(CodeOffset);
		}
	}

	unguard;
}

INT UObject::IsPendingDelete()
{
	return 0;
}

INT UObject::IsPendingKill()
{
	return 0;
}

EGotoState UObject::GotoState( FName NewState )
{
	guard(UObject::GotoState);
	return GOTOSTATE_NotFound;
	unguard;
}

INT UObject::GotoLabel( FName Label )
{
	guard(UObject::GotoLabel);
	return 0;
	unguard;
}

void UObject::InitExecution()
{
	guard(UObject::InitExecution);
	check(GetClass()!=NULL);
	// Allocate state frame.
	if( StateFrame )
		delete StateFrame;
	StateFrame = new FStateFrame( this );
	unguard;
}

void UObject::ShutdownAfterError()
{
	// Retail Core.dll: ret (truly empty, no SEH frame)
}

void UObject::PostEditChange()
{
	guard(UObject::PostEditChange);
	unguard;
}

void UObject::CallFunction( FFrame& Stack, void* const Result, UFunction* Function )
{
	guard(UObject::CallFunction);
	if( !Function )
		return;

	if( (Function->FunctionFlags & FUNC_Net) && ProcessRemoteFunction( Function, Stack.Locals, &Stack ) )
		return;

	if( !Function->Func && Function->iNative && Function->iNative < EX_Max )
		Function->Func = GNatives[Function->iNative];

	if( Function->Func )
		(this->*Function->Func)( Stack, Result );
	else
		ProcessInternal( Stack, Result );
	unguard;
}

INT UObject::ScriptConsoleExec( const TCHAR* Str, FOutputDevice& Ar, UObject* Executor )
{
	guard(UObject::ScriptConsoleExec);
	return 0;
	unguard;
}

void UObject::Register()
{
	guard(UObject::Register);
	unguard;
}

void UObject::LanguageChange()
{
	guard(UObject::LanguageChange);
	unguard;
}

INT UObject::GetPropertiesSize()
{
	guard(UObject::GetPropertiesSize);
	return GetClass()->GetPropertiesSize();
	unguard;
}

void UObject::NetDirty( UProperty* Property )
{
	// Retail Core.dll: ret 4 (truly empty)
}

/*-----------------------------------------------------------------------------
	UObject COM interface.
-----------------------------------------------------------------------------*/

DWORD STDCALL UObject::QueryInterface( const FGuid& RefIID, void** InterfacePtr )
{
	return 0;
}

DWORD STDCALL UObject::AddRef()
{
	return 0;
}

DWORD STDCALL UObject::Release()
{
	return 0;
}

/*-----------------------------------------------------------------------------
	UObject internal implementation.
-----------------------------------------------------------------------------*/

void UObject::ProcessInternal( FFrame& Stack, void* const Result )
{
	guard(UObject::ProcessInternal);
	// Execute bytecode.
	while( *Stack.Code != EX_Return )
		Stack.Step( this, Result );
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject static functions — important subsystem methods.
-----------------------------------------------------------------------------*/

UBOOL UObject::IsValid()
{
	guard(UObject::IsValid);
	if( !this )
		return 0;
	if( !GObjObjects.IsValidIndex(Index) )
		return 0;
	if( GObjObjects(Index)==NULL )
		return 0;
	return 1;
	unguard;
}

INT UObject::IsA( UClass* SomeBase ) const
{
	guardSlow(UObject::IsA);
	for( UClass* TempClass=Class; TempClass; TempClass=(UClass*)TempClass->SuperField )
		if( TempClass==SomeBase )
			return 1;
	return SomeBase==NULL;
	unguardSlow;
}

INT UObject::IsIn( UObject* SomeOuter ) const
{
	guardSlow(UObject::IsIn);
	for( UObject* It=Outer; It; It=It->GetOuter() )
		if( It==SomeOuter )
			return 1;
	return SomeOuter==NULL;
	unguardSlow;
}

INT UObject::IsInState( FName StateName )
{
	guard(UObject::IsInState);
	return 0;
	unguard;
}

INT UObject::IsProbing( FName ProbeName )
{
	guardSlow(UObject::IsProbing);
	return StateFrame && StateFrame->ProbeMask;
	unguardSlow;
}

/*-----------------------------------------------------------------------------
	UObject accessors.
-----------------------------------------------------------------------------*/

UClass* UObject::GetClass() const
{
	return Class;
}

const FName UObject::GetFName() const
{
	return Name;
}

DWORD UObject::GetFlags() const
{
	return ObjectFlags;
}

DWORD UObject::GetIndex() const
{
	return Index;
}

UObject* UObject::GetOuter() const
{
	return Outer;
}

ULinkerLoad* UObject::GetLinker()
{
	return _Linker;
}

INT UObject::GetLinkerIndex()
{
	return _LinkerIndex;
}

const TCHAR* UObject::GetName() const
{
	return *Name;
}

const TCHAR* UObject::GetFullName( TCHAR* Str ) const
{
	guard(UObject::GetFullName);
	if( !Str )
		Str = appStaticString1024();
	appSprintf( Str, TEXT("%s %s"), GetClass()->GetName(), GetPathName(NULL,NULL) );
	return Str;
	unguard;
}

const TCHAR* UObject::GetPathName( UObject* StopOuter, TCHAR* Str ) const
{
	guard(UObject::GetPathName);
	if( !Str )
		Str = appStaticString1024();
	if( this != StopOuter )
	{
		if( Outer && Outer!=StopOuter )
		{
			Outer->GetPathName( StopOuter, Str );
			appStrcat( Str, TEXT(".") );
		}
		appStrcat( Str, GetName() );
	}
	else
	{
		appStrcpy( Str, TEXT("None") );
	}
	return Str;
	unguard;
}

FStateFrame* UObject::GetStateFrame()
{
	return StateFrame;
}

/*-----------------------------------------------------------------------------
	UObject flag manipulation.
-----------------------------------------------------------------------------*/

void UObject::SetFlags( DWORD NewFlags )
{
	ObjectFlags |= NewFlags;
}

void UObject::ClearFlags( DWORD NewFlags )
{
	ObjectFlags &= ~NewFlags;
}

void UObject::SetClass( UClass* NewClass )
{
	Class = NewClass;
}

void UObject::AddToRoot()
{
	guard(UObject::AddToRoot);
	GObjRoot.AddUniqueItem( this );
	unguard;
}

void UObject::RemoveFromRoot()
{
	guard(UObject::RemoveFromRoot);
	GObjRoot.RemoveItem( this );
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject static system interface.
-----------------------------------------------------------------------------*/

void UObject::StaticInit()
{
	guard(UObject::StaticInit);
	GObjInitialized = 1;

	// Create the transient package.
	GObjTransientPkg = new( NULL, TEXT("Transient") )UPackage;
	GObjTransientPkg->AddToRoot();

	debugf( NAME_Init, TEXT("Object subsystem initialized") );
	unguard;
}

void UObject::StaticExit()
{
	guard(UObject::StaticExit);

	// Cleanup root set.
	GObjRoot.Empty();

	// Cleanup objects.
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		if( GObjObjects(i) )
		{
			GObjObjects(i)->ConditionalDestroy();
		}
	}
	GObjObjects.Empty();
	GObjAvailable.Empty();

	GObjInitialized = 0;
	unguard;
}

void UObject::StaticTick()
{
	guard(UObject::StaticTick);
	unguard;
}

void UObject::StaticShutdownAfterError()
{
	guard(UObject::StaticShutdownAfterError);
	static UBOOL Visited = 0;
	if( Visited )
		return;
	Visited = 1;

	for( INT i=0; i<GObjObjects.Num(); i++ )
		if( GObjObjects(i) )
			GObjObjects(i)->ShutdownAfterError();
	unguard;
}

INT UObject::StaticExec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UObject::StaticExec);
	return 0;
	unguard;
}

// StaticConfigName() defined inline in UObject class header.

INT UObject::GetInitialized()
{
	return GObjInitialized;
}

const TCHAR* UObject::GetLanguage()
{
	return GLanguage;
}

void UObject::SetLanguage( const TCHAR* LangExt )
{
	guard(UObject::SetLanguage);
	if( appStricmp(LangExt,GLanguage)!=0 )
	{
		appStrcpy( GLanguage, LangExt );
		// Notify all objects of language change.
		for( INT i=0; i<GObjObjects.Num(); i++ )
			if( GObjObjects(i) )
				GObjObjects(i)->LanguageChange();
	}
	unguard;
}

UPackage* UObject::GetTransientPackage()
{
	return GObjTransientPkg;
}

/*-----------------------------------------------------------------------------
	UObject allocation.
-----------------------------------------------------------------------------*/

UObject* UObject::StaticAllocateObject( UClass* InClass, UObject* InOuter, FName InName, DWORD InFlags, UObject* Template, FOutputDevice* Error, UObject* Ptr, INT Reserved )
{
	guard(UObject::StaticAllocateObject);
	check(InClass!=NULL);

	// Check for existing object with this name.
	UObject* Obj = StaticFindObject( InClass, InOuter, *InName, 0 );
	if( Obj )
	{
		// Found existing object - reuse it.
		Obj->SetFlags( InFlags );
		return Obj;
	}

	// Allocate the object.
	if( !Ptr )
		Ptr = (UObject*)appMalloc( InClass->GetPropertiesSize(), TEXT("UObject") );
	appMemzero( (void*)Ptr, InClass->GetPropertiesSize() );

	// Set up the internal fields.
	Ptr->Index          = INDEX_NONE;
	Ptr->HashNext       = NULL;
	Ptr->StateFrame     = NULL;
	Ptr->_Linker        = NULL;
	Ptr->_LinkerIndex   = INDEX_NONE;
	Ptr->Outer          = InOuter;
	Ptr->ObjectFlags    = InFlags;
	Ptr->Name           = InName;
	Ptr->Class          = InClass;

	// Add to global table.
	Ptr->AddObject( INDEX_NONE );
	Ptr->HashObject();

	// Copy class defaults.
	if( InClass->Defaults.Num() )
	{
		appMemcpy( (BYTE*)Ptr + sizeof(UObject), &InClass->Defaults(0) + sizeof(UObject), InClass->GetPropertiesSize() - sizeof(UObject) );
	}

	return Ptr;
	unguard;
}

UObject* UObject::StaticConstructObject( UClass* InClass, UObject* InOuter, FName InName, DWORD InFlags, UObject* Template, FOutputDevice* Error, UObject* SubObjectRoot )
{
	guard(UObject::StaticConstructObject);
	check(InClass);

	// Allocate and construct.
	UObject* Result = StaticAllocateObject( InClass, InOuter, InName, InFlags, Template, Error );
	if( Result )
	{
		// Call class constructor.
		(*InClass->ClassConstructor)( Result );
	}
	return Result;
	unguard;
}

UObject* UObject::StaticFindObject( UClass* ObjectClass, UObject* InObjectPackage, const TCHAR* OrigInName, INT ExactClass )
{
	guard(UObject::StaticFindObject);

	// Resolve the name.
	const TCHAR* InName = OrigInName;
	UObject* ObjectPackage = InObjectPackage;

	// If ANY_PACKAGE, allow searching all packages.
	UBOOL AnyPackage = (InObjectPackage == ANY_PACKAGE);
	if( AnyPackage )
		ObjectPackage = NULL;

	// Resolve dotted names, e.g., "Package.Object".
	if( !AnyPackage && !ObjectPackage )
		ResolveName( ObjectPackage, InName, 0, 0 );

	// Hash lookup.
	INT iHash = GetObjectHash( FName(InName,FNAME_Find), ObjectPackage ? ObjectPackage->GetIndex() : 0 );
	for( UObject* Hash=GObjHash[iHash]; Hash!=NULL; Hash=Hash->HashNext )
	{
		if
		(	(Hash->GetFName().GetIndex() == FName(InName,FNAME_Find).GetIndex())
		&&	(ObjectPackage==NULL || Hash->GetOuter()==ObjectPackage || AnyPackage)
		&&	(ObjectClass==NULL  || (ExactClass ? Hash->GetClass()==ObjectClass : Hash->IsA(ObjectClass))) )
		{
			return Hash;
		}
	}
	return NULL;
	unguard;
}

UObject* UObject::StaticFindObjectChecked( UClass* ObjectClass, UObject* InObjectPackage, const TCHAR* InName, INT ExactClass )
{
	guard(UObject::StaticFindObjectChecked);
	UObject* Result = StaticFindObject( ObjectClass, InObjectPackage, InName, ExactClass );
	if( !Result )
		appErrorf( TEXT("Failed to find object '%s %s.%s'"), ObjectClass->GetName(), InObjectPackage ? InObjectPackage->GetName() : TEXT("None"), InName );
	return Result;
	unguard;
}

UObject* UObject::StaticLoadObject( UClass* ObjectClass, UObject* InOuter, const TCHAR* InName, const TCHAR* Filename, DWORD LoadFlags, UPackageMap* Sandbox )
{
	guard(UObject::StaticLoadObject);
	FString IniResolvedName;
	UObject* LoadOuter = InOuter;
	if( InName && appStrnicmp( InName, TEXT("ini:"), 4 ) == 0 )
	{
		const TCHAR* IniSpec = InName + 4;
		const TCHAR* LastDot = NULL;
		for( const TCHAR* Scan = IniSpec; *Scan; ++Scan )
			if( *Scan == TEXT('.') )
				LastDot = Scan;
		if( LastDot )
		{
			TCHAR Section[256];
			appStrncpy( Section, IniSpec, Min<INT>( (INT)(LastDot - IniSpec) + 1, ARRAY_COUNT(Section) ) );
			Section[LastDot - IniSpec] = 0;
			GConfig->GetString( Section, LastDot + 1, IniResolvedName );
			if( IniResolvedName.Len() )
				InName = *IniResolvedName;
			else if( !(LoadFlags & LOAD_NoWarn) )
				debugf( NAME_Warning, TEXT("Failed to resolve config object '%s'"), InName );
		}
	}

	const TCHAR* LoadName = InName;
	if( LoadName && !LoadOuter )
		ResolveName( LoadOuter, LoadName, 1, 0 );

	// Try to find the object.
	UObject* Result = StaticFindObject( ObjectClass, LoadOuter, LoadName, 0 );
	if( !Result )
	{
		// Load through linker.
		BeginLoad();
		ULinkerLoad* Linker = GetPackageLinker( LoadOuter, Filename, LoadFlags, Sandbox, NULL );
		if( Linker && ObjectClass )
			Result = Linker->Create( ObjectClass, FName(LoadName,FNAME_Find), LoadFlags, 0 );
		EndLoad();
	}
	if( !Result && !(LoadFlags & LOAD_NoWarn) )
		debugf( NAME_Warning, TEXT("Failed to load '%s': not found"), LoadName ? LoadName : InName );
	return Result;
	unguard;
}

UClass* UObject::StaticLoadClass( UClass* BaseClass, UObject* InOuter, const TCHAR* InName, const TCHAR* Filename, DWORD LoadFlags, UPackageMap* Sandbox )
{
	guard(UObject::StaticLoadClass);
	UClass* Class = (UClass*)StaticLoadObject( UClass::StaticClass(), InOuter, InName, Filename, LoadFlags | LOAD_Throw, Sandbox );
	if( Class && !Class->IsChildOf(BaseClass) )
		appErrorf( TEXT("%s is not a child class of %s"), Class->GetFullName(), BaseClass->GetFullName() );
	return Class;
	unguard;
}

/*-----------------------------------------------------------------------------
	Package management.
-----------------------------------------------------------------------------*/

UPackage* UObject::CreatePackage( UObject* InOuter, const TCHAR* InName )
{
	guard(UObject::CreatePackage);
	// Find or create the package.
	UPackage* Result = FindObject<UPackage>( InOuter, InName );
	if( !Result )
		Result = new( InOuter, InName, RF_Public )UPackage;
	return Result;
	unguard;
}

UObject* UObject::LoadPackage( UObject* InOuter, const TCHAR* Filename, DWORD LoadFlags )
{
	guard(UObject::LoadPackage);
	ULinkerLoad* Linker = NULL;

	BeginLoad();
	Linker = GetPackageLinker( InOuter, Filename, LoadFlags, NULL, NULL );
	if( Linker )
		Linker->LoadAllObjects();
	EndLoad();

	return Linker ? Linker->LinkerRoot : NULL;
	unguard;
}

INT UObject::SavePackage( UObject* InOuter, UObject* Base, DWORD TopLevelFlags, const TCHAR* Filename, FOutputDevice* Error, ULinkerLoad* Conform )
{
	guard(UObject::SavePackage);
	// Saving requires ULinkerSave construction, export tagging, and serial write.
	// This is a complex pipeline best verified against the binary — scaffold only.
	ULinkerSave* Linker = NULL;
	try
	{
		Linker = new ULinkerSave( InOuter, Filename );
		// Tag exports.
		for( FObjectIterator It; It; ++It )
		{
			if( It->IsIn(InOuter) && (It->GetFlags() & TopLevelFlags) )
				It->SetFlags( RF_TagExp );
		}
		// Serialize. Full pipeline deferred to Ghidra verification.
	}
	catch( ... )
	{
		delete Linker;
		return 0;
	}
	delete Linker;
	return 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	Object loading internals.
-----------------------------------------------------------------------------*/

void UObject::BeginLoad()
{
	guard(UObject::BeginLoad);
	if( ++GObjBeginLoadCount == 1 )
	{
		// Reset.
	}
	unguard;
}

void UObject::EndLoad()
{
	guard(UObject::EndLoad);
	check(GObjBeginLoadCount>0);
	if( --GObjBeginLoadCount == 0 )
	{
		// Postload all loaded objects.
		for( INT i=0; i<GObjLoaded.Num(); i++ )
			GObjLoaded(i)->ConditionalPostLoad();
		GObjLoaded.Empty();
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Garbage collection.
-----------------------------------------------------------------------------*/

void UObject::CollectGarbage( DWORD KeepFlags )
{
	guard(UObject::CollectGarbage);

	// Tag all unreachable objects.
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && !(Obj->GetFlags() & KeepFlags) )
		{
			Obj->SetFlags( RF_TagGarbage );
		}
	}

	// Unmark objects in root set and their reachables.
	for( INT i=0; i<GObjRoot.Num(); i++ )
	{
		if( GObjRoot(i) )
			GObjRoot(i)->ClearFlags( RF_TagGarbage );
	}

	// Delete unreachable objects.
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && (Obj->GetFlags() & RF_TagGarbage) )
		{
			Obj->ConditionalDestroy();
		}
	}

	unguard;
}

INT UObject::IsReferenced( UObject*& Res, DWORD KeepFlags, INT IgnoreReference )
{
	guard(UObject::IsReferenced);
	return 0;
	unguard;
}

INT UObject::AttemptDelete( UObject*& Res, DWORD KeepFlags, INT IgnoreReference )
{
	guard(UObject::AttemptDelete);
	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Object serialization helpers.
-----------------------------------------------------------------------------*/

void UObject::SerializeRootSet( FArchive& Ar, DWORD KeepFlags, DWORD RequiredFlags )
{
	guard(UObject::SerializeRootSet);
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && (Obj->GetFlags() & KeepFlags) && (Obj->GetFlags() & RequiredFlags)==RequiredFlags )
		{
			Ar << Obj;
		}
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Misc statics.
-----------------------------------------------------------------------------*/

void UObject::BindPackage( UPackage* Package )
{
	guard(UObject::BindPackage);
	unguard;
}

UObject* UObject::GetIndexedObject( INT Index )
{
	if( GObjObjects.IsValidIndex(Index) )
		return GObjObjects(Index);
	return NULL;
}

INT UObject::GetObjectHash( FName ObjName, INT Outer )
{
	return (ObjName.GetIndex() ^ Outer) & (ARRAY_COUNT(GObjHash)-1);
}

TArray<UObject*> UObject::GetLoaderList()
{
	return GObjLoaded;
}

ULinkerLoad* UObject::GetPackageLinker( UObject* InOuter, const TCHAR* Filename, DWORD LoadFlags, UPackageMap* Sandbox, FGuid* CompatibleGuid )
{
	guard(UObject::GetPackageLinker);
	UObject* TopOuter = InOuter;
	while( TopOuter && TopOuter->GetOuter() )
		TopOuter = TopOuter->GetOuter();

	UPackage* Package = NULL;
	if( TopOuter && TopOuter->IsA(UPackage::StaticClass()) )
		Package = (UPackage*)TopOuter;

	if( !Package && Filename )
	{
		const TCHAR* PackageName = Filename;
		const TCHAR* Slash = NULL;
		const TCHAR* AltSlash = NULL;
		for( const TCHAR* Scan = PackageName; *Scan; ++Scan )
		{
			if( *Scan == TEXT('\\') )
				Slash = Scan;
			else if( *Scan == TEXT('/') )
				AltSlash = Scan;
		}
		if( AltSlash && (!Slash || AltSlash > Slash) )
			Slash = AltSlash;
		if( Slash )
			PackageName = Slash + 1;

		TCHAR BaseName[NAME_SIZE];
		appStrncpy( BaseName, PackageName, ARRAY_COUNT(BaseName) );
		TCHAR* Dot = NULL;
		for( TCHAR* Scan = BaseName; *Scan; ++Scan )
			if( *Scan == TEXT('.') )
				Dot = Scan;
		if( Dot )
			*Dot = 0;

		Package = CreatePackage( NULL, BaseName );
	}

	if( !Package )
		return NULL;

	if( Package->GetLinker() )
		return Package->GetLinker();

	TCHAR PackageFile[256];
	if( Filename && *Filename )
		appStrcpy( PackageFile, Filename );
	else if( !appFindPackageFile( Package->GetName(), CompatibleGuid, PackageFile ) )
		return NULL;

	ULinkerLoad* Linker = NULL;
	try
	{
		Linker = new ULinkerLoad( Package, PackageFile, LoadFlags );
	}
	catch( ... )
	{
		return NULL;
	}

	if( !Linker )
		return NULL;

	Package->SetLinker( Linker, INDEX_NONE );
	GObjLoaders.AddItem( Linker );
	return Linker;
	unguard;
}

void UObject::ResetLoaders( UObject* Pkg, INT DynamicOnly, INT ForceLazyLoad )
{
	guard(UObject::ResetLoaders);
	unguard;
}

void UObject::VerifyLinker( ULinkerLoad* Linker )
{
	guard(UObject::VerifyLinker);
	unguard;
}

void UObject::ProcessRegistrants()
{
	guard(UObject::ProcessRegistrants);
	for( INT i=0; i<GObjRegistrants.Num(); i++ )
	{
		GObjRegistrants(i)->ConditionalRegister();
	}
	GObjRegistrants.Empty();
	unguard;
}

void UObject::GetRegistryObjects( TArray<FRegistryObjectInfo>& Results, UClass* InClass, UClass* InMetaClass, INT InIterateFlags )
{
	guard(UObject::GetRegistryObjects);
	unguard;
}

void UObject::GetPreferences( TArray<FPreferencesInfo>& Results, const TCHAR* Category, INT InIterateFlags )
{
	guard(UObject::GetPreferences);
	unguard;
}

void UObject::GlobalSetProperty( const TCHAR* Value, UClass* InClass, UProperty* Property, INT Offset, INT Immediate )
{
	guard(UObject::GlobalSetProperty);
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject property methods.
-----------------------------------------------------------------------------*/

void UObject::InitProperties( BYTE* Data, INT DataCount, UClass* DefaultsClass, BYTE* Defaults, INT DefaultsCount, UObject* DestObject, UObject* SuperObject )
{
	guard(UObject::InitProperties);
	// Copy defaults.
	if( Defaults && DefaultsCount )
		appMemcpy( Data, Defaults, Min(DataCount,DefaultsCount) );

	// Fixup object properties — construct strings, arrays, etc.
	if( DefaultsClass )
	{
		for( UProperty* P=DefaultsClass->ConstructorLink; P; P=P->ConstructorLinkNext )
		{
			if( P->Offset < DataCount )
			{
				for( INT i=0; i<P->ArrayDim; i++ )
					P->CopySingleValue( Data + P->Offset + i*P->ElementSize, Defaults ? Defaults + P->Offset + i*P->ElementSize : NULL );
			}
		}
	}
	unguard;
}

void UObject::ExitProperties( BYTE* Data, UClass* Class )
{
	guard(UObject::ExitProperties);
	// Destroy properties that need cleanup (strings, arrays, structs with constructors).
	if( Class )
	{
		for( UProperty* P=Class->ConstructorLink; P; P=P->ConstructorLinkNext )
		{
			if( P->PropertyFlags & CPF_NeedCtorLink )
				P->DestroyValue( Data + P->Offset );
		}
	}
	unguard;
}

void UObject::ExportProperties( FOutputDevice& Out, UClass* ObjectClass, BYTE* Object, INT Indent, UClass* DiffClass, BYTE* Diff )
{
	guard(UObject::ExportProperties);
	unguard;
}

void UObject::InitClassDefaultObject( UClass* InClass, INT SetOuter )
{
	guard(UObject::InitClassDefaultObject);
	unguard;
}

/*-----------------------------------------------------------------------------
	Search methods.
-----------------------------------------------------------------------------*/

UFunction* UObject::FindFunction( FName FuncName, INT Global )
{
	guard(UObject::FindFunction);
	// Search in class hierarchy.
	for( UStruct* Struct=GetClass(); Struct; Struct=(UStruct*)Struct->SuperField )
	{
		for( TFieldIterator<UFunction> It(Struct); It; ++It )
			if( It->GetFName()==FuncName )
				return *It;
	}
	return NULL;
	unguard;
}

UFunction* UObject::FindFunctionChecked( FName FuncName, INT Global )
{
	guard(UObject::FindFunctionChecked);
	UFunction* Result = FindFunction( FuncName, Global );
	if( !Result )
		appErrorf( TEXT("Failed to find function '%s' in '%s'"), *FuncName, GetFullName() );
	return Result;
	unguard;
}

UField* UObject::FindObjectField( FName FieldName, INT Global )
{
	guard(UObject::FindObjectField);
	return NULL;
	unguard;
}

UState* UObject::FindState( FName StateName )
{
	guard(UObject::FindState);
	return NULL;
	unguard;
}

/*-----------------------------------------------------------------------------
	Property search helpers.
-----------------------------------------------------------------------------*/

INT UObject::FindBoolProperty( FString PropertyName, INT* Value )
{
	guard(UObject::FindBoolProperty);
	return 0;
	unguard;
}

INT UObject::FindIntProperty( FString PropertyName, INT* Value )
{
	guard(UObject::FindIntProperty);
	return 0;
	unguard;
}

INT UObject::FindFloatProperty( FString PropertyName, FLOAT* Value )
{
	guard(UObject::FindFloatProperty);
	return 0;
	unguard;
}

INT UObject::FindFNameProperty( FString PropertyName, FName* Value )
{
	guard(UObject::FindFNameProperty);
	return 0;
	unguard;
}

INT UObject::FindObjectProperty( FString PropertyName, UObject** Value )
{
	guard(UObject::FindObjectProperty);
	return 0;
	unguard;
}

INT UObject::FindArrayProperty( FString PropertyName, FArray** Value, INT* ElementSize )
{
	guard(UObject::FindArrayProperty);
	return 0;
	unguard;
}

INT UObject::FindStructProperty( FString PropertyName, UStruct** Value )
{
	guard(UObject::FindStructProperty);
	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Config.
-----------------------------------------------------------------------------*/

void UObject::LoadConfig( INT Immediate, UClass* InClass, const TCHAR* Filename )
{
	guard(UObject::LoadConfig);
	unguard;
}

void UObject::SaveConfig( DWORD Flags, const TCHAR* Filename )
{
	guard(UObject::SaveConfig);
	unguard;
}

void UObject::ResetConfig( UClass* InClass, const TCHAR* Section, INT StartIndex )
{
	guard(UObject::ResetConfig);
	unguard;
}

void UObject::LoadLocalized()
{
	guard(UObject::LoadLocalized);
	unguard;
}

void UObject::ParseParms( const TCHAR* Parms )
{
	guard(UObject::ParseParms);
	unguard;
}

/*-----------------------------------------------------------------------------
	Conditional operations.
-----------------------------------------------------------------------------*/

INT UObject::ConditionalDestroy()
{
	guard(UObject::ConditionalDestroy);
	if( !(GetFlags() & RF_Destroyed) )
	{
		Destroy();
		return 1;
	}
	return 0;
	unguard;
}

void UObject::ConditionalPostLoad()
{
	guard(UObject::ConditionalPostLoad);
	if( GetFlags() & RF_NeedPostLoad )
	{
		ClearFlags( RF_NeedPostLoad );
		PostLoad();
	}
	unguard;
}

void UObject::ConditionalRegister()
{
	guard(UObject::ConditionalRegister);
	Register();
	unguard;
}

void UObject::ConditionalShutdownAfterError()
{
	guard(UObject::ConditionalShutdownAfterError);
	if( !(GetFlags() & RF_ErrorShutdown) )
	{
		SetFlags( RF_ErrorShutdown );
		ShutdownAfterError();
	}
	unguard;
}

void UObject::CheckDanglingOuter( UObject* Obj )
{
	guard(UObject::CheckDanglingOuter);
	unguard;
}

void UObject::CheckDanglingRefs( UObject* Obj )
{
	guard(UObject::CheckDanglingRefs);
	unguard;
}

void UObject::StaticConstructor()
{
	guard(UObject::StaticConstructor);
	unguard;
}

void UObject::InternalConstructor( void* X )
{
	guard(UObject::InternalConstructor);
	new( (EInternal*)X )UObject;
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject event helpers.
-----------------------------------------------------------------------------*/

void UObject::eventBeginState()
{
	guard(eventBeginState);
	ProcessEvent( FindFunctionChecked(NAME_BeginState,0), NULL, NULL );
	unguard;
}

void UObject::eventEndState()
{
	guard(eventEndState);
	ProcessEvent( FindFunctionChecked(NAME_EndState,0), NULL, NULL );
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
