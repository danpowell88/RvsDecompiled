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

IMPL_INFERRED("Ravenshield FScriptDelegate; reconstructed from context")
FScriptDelegate::FScriptDelegate()
{
}

IMPL_INFERRED("Ravenshield FScriptDelegate; reconstructed from context")
FScriptDelegate& FScriptDelegate::operator=( const FScriptDelegate& Other )
{
	Object       = Other.Object;
	FunctionName = Other.FunctionName;
	return *this;
}

/*-----------------------------------------------------------------------------
	UObject constructors.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject::UObject( const UObject& Src )
{
	guard(UObject::UObject_Copy);
	check(0); // not allowed
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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
	Class = InClass;
	// Store raw string pointers temporarily in Name/Outer; Register() converts them later.
	*(const TCHAR**)&Name = InName;
	Outer = (UObject*)InPackageName;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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
	// Store raw string pointers temporarily in Name/Outer; Register() converts them later.
	*(const TCHAR**)&Name = InName;
	Outer = (UObject*)InPackageName;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ProcessDelegate( FName DelegateName, FScriptDelegate* Delegate, void* Parms, void* Result )
{
	guard(UObject::ProcessDelegate);
	UObject*   DelegateObject = this;
	UFunction* Func           = NULL;

	if( Delegate && Delegate->Object )
	{
		if( !Delegate->Object->IsValid() )
		{
			// Delegate object is no longer valid; clear the binding.
			Delegate->Object       = NULL;
			Delegate->FunctionName = NAME_None;
		}
		else
		{
			// Valid delegate: call the bound function on the bound object.
			Func           = Delegate->Object->FindFunctionChecked( Delegate->FunctionName, 0 );
			DelegateObject = Delegate->Object;
		}
	}

	// Fall back to calling DelegateName on this object if no valid binding.
	if( !Func )
		Func = FindFunctionChecked( DelegateName, 0 );

	DelegateObject->ProcessEvent( Func, Parms, Result );
	unguard;
}

IMPL_INTENTIONALLY_EMPTY("Retail Core.dll: truly empty, no SEH frame")
void UObject::ProcessState( FLOAT DeltaSeconds )
{
	// Retail Core.dll: ret 4 (truly empty, no SEH frame)
}

IMPL_GHIDRA("Core.dll", 0x1bd40)
INT UObject::ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack )
{
	// Ghidra 0x1bd40: genuine stub; returns 0.
	return 0;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::Modify()
{
	guard(UObject::Modify);
	if( GUndo && (ObjectFlags & RF_Transactional) )
		GUndo->SaveObject( this );
	unguard;
}

IMPL_GHIDRA("Core.dll", 0x3AA30)
void UObject::PostLoad()
{
	guard(UObject::PostLoad);
	// Retail Core.dll 0x3AA30: sets RF_DebugPostLoad in ObjectFlags.
	ObjectFlags |= RF_DebugPostLoad;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::Destroy()
{
	guard(UObject::Destroy);
	// Mark as destroyed.
	SetFlags( RF_Destroyed );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_GHIDRA("Core.dll", 0x1da0)
INT UObject::IsPendingDelete()
{
	// Ghidra 0x1da0: shared stub; returns 0.
	return 0;
}

IMPL_GHIDRA("Core.dll", 0x1da0)
INT UObject::IsPendingKill()
{
	// Ghidra 0x1da0: shared stub; returns 0.
	return 0;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
EGotoState UObject::GotoState( FName NewState )
{
	guard(UObject::GotoState);
	if( !StateFrame )
		return GOTOSTATE_NotFound;

	// DIVERGENCE: binary has LatentAction at StateFrame+0x28, our struct has it at +0x24
	StateFrame->LatentAction = 0;

	// Remember the current state name (NAME_None means we're at the class/default level).
	FName PrevStateName = (StateFrame->StateNode == (UState*)GetClass())
		? NAME_None
		: StateFrame->StateNode->GetFName();

	// Locate the destination state node.
	UState* NewStateNode = NULL;
	if( NewState == NAME_Auto )
	{
		// Find the first state marked as the automatic (default) state.
		for( TFieldIterator<UState> It(GetClass()); It; ++It )
		{
			if( (*It)->StateFlags & STATE_Auto )
			{
				NewStateNode = *It;
				break;
			}
		}
	}
	else
	{
		NewStateNode = FindState( NewState );
	}

	// If no matching state, transition to the base class (no state).
	if( !NewStateNode )
	{
		NewStateNode = (UState*)GetClass();
		NewState     = NAME_None;
	}
	else if( NewState == NAME_Auto )
	{
		NewState = NewStateNode->GetFName();
	}

	// Call EndState when leaving a named state, guarded against re-entrancy.
	// RF_InEndState (0x2000) marks that we are already inside a GotoState chain.
	// RF_StateChanged (0x1000) is used to detect preemption by a nested GotoState.
	if( PrevStateName != NAME_None
		&& NewState    != PrevStateName
		&& StateFrame->ProbeMask
		&& !(ObjectFlags & RF_InEndState) )
	{
		// Enter the chain: clear RF_StateChanged, set RF_InEndState.
		ObjectFlags = (ObjectFlags & ~RF_StateChanged) | RF_InEndState;
		eventEndState();
		DWORD PostEndStateFlags = ObjectFlags;
		ObjectFlags = PostEndStateFlags & ~RF_InEndState; // leave the chain

		// If RF_StateChanged was set during EndState a nested GotoState preempted us.
		if( PostEndStateFlags & RF_StateChanged )
			return GOTOSTATE_Preempted;
	}

	// Apply the new state.
	StateFrame->Node      = NewStateNode;
	StateFrame->StateNode = NewStateNode;
	StateFrame->Code      = NULL;
	StateFrame->ProbeMask = (GetClass()->ProbeMask | NewStateNode->ProbeMask) & NewStateNode->IgnoreMask;

	if( NewState != NAME_None )
	{
		if( NewState != PrevStateName && StateFrame->ProbeMask )
		{
			// Call BeginState; preemption detection uses the same RF_StateChanged flag.
			ObjectFlags &= ~RF_StateChanged;
			eventBeginState();
			if( ObjectFlags & RF_StateChanged )
				return GOTOSTATE_Preempted;
		}
		ObjectFlags |= RF_StateChanged;
		return GOTOSTATE_Success;
	}

	return GOTOSTATE_NotFound;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::GotoLabel( FName Label )
{
	guard(UObject::GotoLabel);
	if( StateFrame )
	{
		// DIVERGENCE: binary has LatentAction at StateFrame+0x28, our struct has it at +0x24
		StateFrame->LatentAction = 0;
		if( Label != NAME_None )
		{
			for( UState* StateNode = StateFrame->StateNode; StateNode; StateNode = StateNode->GetSuperState() )
			{
				if( StateNode->LabelTableOffset != 0xffff )
				{
					for( FLabelEntry* Entry = (FLabelEntry*)&StateNode->Script(StateNode->LabelTableOffset);
						 Entry->Name != NAME_None; Entry++ )
					{
						if( Entry->Name == Label )
						{
							StateFrame->Node = StateNode;
							StateFrame->Code = &StateNode->Script(Entry->iCode);
							return 1;
						}
					}
				}
			}
		}
		StateFrame->Code = NULL;
	}
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_INTENTIONALLY_EMPTY("Retail Core.dll: truly empty")
void UObject::ShutdownAfterError()
{
	// Retail Core.dll: ret (truly empty, no SEH frame)
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::PostEditChange()
{
	guard(UObject::PostEditChange);
	Modify();
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::ScriptConsoleExec( const TCHAR* Str, FOutputDevice& Ar, UObject* Executor )
{
	guard(UObject::ScriptConsoleExec);
	if( !GIsScriptable )
		return 0;

	// Parse the function name.
	TCHAR FuncName[64];
	const TCHAR* TempStr = Str;
	if( !ParseToken( TempStr, FuncName, ARRAY_COUNT(FuncName), 1 ) )
		return 0;

	FName FuncFName( FuncName, FNAME_Find );
	if( FuncFName == NAME_None )
		return 0;

	UFunction* Func = FindFunction( FuncFName, 0 );
	if( !Func || !(Func->FunctionFlags & FUNC_Exec) )
		return 0;

	// Allocate and zero-fill the parameter block.
	BYTE* ParmBuf = NULL;
	if( Func->ParmsSize > 0 )
	{
		ParmBuf = (BYTE*)appAlloca( Func->ParmsSize );
		appMemzero( ParmBuf, Func->ParmsSize );
	}

	// Parse each non-return parameter from the remaining string.
	for( TFieldIterator<UProperty> It(Func);
		 It && (It->PropertyFlags & (CPF_Parm|CPF_ReturnParm)) == CPF_Parm;
		 ++It )
	{
		UProperty* Property = *It;
		TCHAR ParamStr[256];
		if( ParseToken( TempStr, ParamStr, ARRAY_COUNT(ParamStr), 1 ) )
			Property->ImportText( ParamStr, ParmBuf + Property->Offset, 0 );
		else if( Property->PropertyFlags & CPF_OptionalParm )
			break;
	}

	ProcessEvent( Func, ParmBuf, NULL );
	return 1;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::Register()
{
	guard(UObject::Register);
	check(GObjInitialized);
	// The ENativeConstructor/EStaticConstructor temporarily stores raw string pointers
	// in the Name and Outer fields before the name table is available.
	const TCHAR* NameStr    = *(const TCHAR**)&Name;
	const TCHAR* PackageStr = (const TCHAR*)Outer;
	if( NameStr )
	{
		Outer        = CreatePackage( NULL, PackageStr );
		Name         = FName( NameStr, FNAME_Add );
		_LinkerIndex = INDEX_NONE;
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::LanguageChange()
{
	guard(UObject::LanguageChange);
	LoadLocalized();
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::GetPropertiesSize()
{
	guard(UObject::GetPropertiesSize);
	return GetClass()->GetPropertiesSize();
	unguard;
}

IMPL_INTENTIONALLY_EMPTY("Retail Core.dll: truly empty")
void UObject::NetDirty( UProperty* Property )
{
	// Retail Core.dll: ret 4 (truly empty)
}

/*-----------------------------------------------------------------------------
	UObject COM interface.
-----------------------------------------------------------------------------*/

IMPL_GHIDRA("Core.dll", 0x38a80)
DWORD STDCALL UObject::QueryInterface( const FGuid& RefIID, void** InterfacePtr )
{
	// Ghidra 0x38a80: sets *InterfacePtr = NULL (E_NOINTERFACE), returns 0.
	if (InterfacePtr) *InterfacePtr = NULL;
	return 0;
}

IMPL_GHIDRA("Core.dll", 0x38a90)
DWORD STDCALL UObject::AddRef()
{
	// Ghidra 0x38a90: genuine stub; returns 0.
	return 0;
}

IMPL_GHIDRA("Core.dll", 0x38aa0)
DWORD STDCALL UObject::Release()
{
	// Ghidra 0x38aa0: genuine stub; returns 0.
	return 0;
}

/*-----------------------------------------------------------------------------
	UObject internal implementation.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::IsA( UClass* SomeBase ) const
{
	guardSlow(UObject::IsA);
	for( UClass* TempClass=Class; TempClass; TempClass=(UClass*)TempClass->SuperField )
		if( TempClass==SomeBase )
			return 1;
	return SomeBase==NULL;
	unguardSlow;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::IsIn( UObject* SomeOuter ) const
{
	guardSlow(UObject::IsIn);
	for( UObject* It=Outer; It; It=It->GetOuter() )
		if( It==SomeOuter )
			return 1;
	return SomeOuter==NULL;
	unguardSlow;
}

IMPL_APPROX("not yet implemented; stub returning 0")
INT UObject::IsInState( FName StateName )
{
	guard(UObject::IsInState);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::IsProbing( FName ProbeName )
{
	guardSlow(UObject::IsProbing);
	return StateFrame && StateFrame->ProbeMask;
	unguardSlow;
}

/*-----------------------------------------------------------------------------
	UObject accessors.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UClass* UObject::GetClass() const
{
	return Class;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
const FName UObject::GetFName() const
{
	return Name;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
DWORD UObject::GetFlags() const
{
	return ObjectFlags;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
DWORD UObject::GetIndex() const
{
	return Index;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UObject::GetOuter() const
{
	return Outer;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
ULinkerLoad* UObject::GetLinker()
{
	return _Linker;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::GetLinkerIndex()
{
	return _LinkerIndex;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
const TCHAR* UObject::GetName() const
{
	return *Name;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
const TCHAR* UObject::GetFullName( TCHAR* Str ) const
{
	guard(UObject::GetFullName);
	if( !Str )
		Str = appStaticString1024();
	appSprintf( Str, TEXT("%s %s"), GetClass()->GetName(), GetPathName(NULL,NULL) );
	return Str;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FStateFrame* UObject::GetStateFrame()
{
	return StateFrame;
}

/*-----------------------------------------------------------------------------
	UObject flag manipulation.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SetFlags( DWORD NewFlags )
{
	ObjectFlags |= NewFlags;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ClearFlags( DWORD NewFlags )
{
	ObjectFlags &= ~NewFlags;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SetClass( UClass* NewClass )
{
	Class = NewClass;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::AddToRoot()
{
	guard(UObject::AddToRoot);
	GObjRoot.AddUniqueItem( this );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::RemoveFromRoot()
{
	guard(UObject::RemoveFromRoot);
	GObjRoot.RemoveItem( this );
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject static system interface.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::StaticTick()
{
	guard(UObject::StaticTick);
	check(GObjBeginLoadCount == 0);
	if( GNativeDuplicate )
		GError->Logf( TEXT("Duplicate native function registered: index %i"), GNativeDuplicate );
	if( GCastDuplicate )
		GError->Logf( TEXT("Duplicate native cast registered: index %i"), GCastDuplicate );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::StaticExec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UObject::StaticExec);

	const TCHAR* Str = Cmd;
	if( ParseCommand(&Str, TEXT("OBJ")) )
	{
		if( ParseCommand(&Str, TEXT("GC")) || ParseCommand(&Str, TEXT("GARBAGE")) )
		{
			// Force a full garbage collect.
			CollectGarbage( RF_Native );
			Ar.Log( TEXT("Garbage collected.") );
			return 1;
		}
		if( ParseCommand(&Str, TEXT("LIST")) )
		{
			// List all objects of an optional class.
			TCHAR ClassName[64]; ClassName[0] = 0;
			Parse( Str, TEXT("CLASS="), ClassName, ARRAY_COUNT(ClassName) );
			UClass* FilterClass = ClassName[0] ? (UClass*)StaticFindObject(UClass::StaticClass(), ANY_PACKAGE, ClassName, 0) : NULL;
			INT Count = 0;
			for( FObjectIterator It; It; ++It )
			{
				if( !FilterClass || It->IsA(FilterClass) )
				{
					Ar.Logf( TEXT("%s"), It->GetFullName() );
					Count++;
				}
			}
			Ar.Logf( TEXT("%i object(s)"), Count );
			return 1;
		}
		if( ParseCommand(&Str, TEXT("DUMP")) )
		{
			TCHAR ObjName[256]; ObjName[0] = 0;
			Parse( Str, TEXT("NAME="), ObjName, ARRAY_COUNT(ObjName) );
			if( ObjName[0] )
			{
				UObject* Obj = StaticFindObject( NULL, ANY_PACKAGE, ObjName, 0 );
				if( Obj )
					ExportProperties( Ar, Obj->GetClass(), (BYTE*)Obj, 0, NULL, NULL );
			}
			return 1;
		}
		if( ParseCommand(&Str, TEXT("HASH")) )
		{
			// Dump hash bucket statistics.
			INT MaxChain = 0, Total = 0;
			for( INT i=0; i<ARRAY_COUNT(GObjHash); i++ )
			{
				INT Chain = 0;
				for( UObject* H=GObjHash[i]; H; H=H->HashNext )
					Chain++;
				if( Chain > MaxChain ) MaxChain = Chain;
				Total += Chain;
			}
			Ar.Logf( TEXT("Hash: %i objects, max chain %i"), Total, MaxChain );
			return 1;
		}
		if( ParseCommand(&Str, TEXT("LINKERS")) )
		{
			Ar.Logf( TEXT("Linkers: %i"), GObjLoaders.Num() );
			for( INT i=0; i<GObjLoaders.Num(); i++ )
				Ar.Logf( TEXT("  %s"), GObjLoaders(i)->GetFullName() );
			return 1;
		}
	}
	return 0;
	unguard;
}

// StaticConfigName() defined inline in UObject class header.

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::GetInitialized()
{
	return GObjInitialized;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
const TCHAR* UObject::GetLanguage()
{
	return GLanguage;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UPackage* UObject::GetTransientPackage()
{
	return GObjTransientPkg;
}

/*-----------------------------------------------------------------------------
	UObject allocation.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UObject::StaticFindObjectChecked( UClass* ObjectClass, UObject* InObjectPackage, const TCHAR* InName, INT ExactClass )
{
	guard(UObject::StaticFindObjectChecked);
	UObject* Result = StaticFindObject( ObjectClass, InObjectPackage, InName, ExactClass );
	if( !Result )
		appErrorf( TEXT("Failed to find object '%s %s.%s'"), ObjectClass->GetName(), InObjectPackage ? InObjectPackage->GetName() : TEXT("None"), InName );
	return Result;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::BeginLoad()
{
	guard(UObject::BeginLoad);
	if( ++GObjBeginLoadCount == 1 )
	{
		// Reset.
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::IsReferenced( UObject*& Res, DWORD KeepFlags, INT IgnoreReference )
{
	guard(UObject::IsReferenced);
	// Mark all objects as garbage candidates, then re-mark reachables.
	// If Res is still tagged after the sweep it has no strong references.
	for( INT i=0; i<GObjObjects.Num(); i++ )
		if( GObjObjects(i) )
			GObjObjects(i)->SetFlags( RF_TagGarbage );
	for( INT i=0; i<GObjRoot.Num(); i++ )
		if( GObjRoot(i) )
			GObjRoot(i)->ClearFlags( RF_TagGarbage );
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && (Obj->GetFlags() & KeepFlags) )
			Obj->ClearFlags( RF_TagGarbage );
	}
	// Intentionally leave RF_TagGarbage set on unreferenced objects so that
	// the subsequent PurgeGarbage() call knows what to destroy.
	return !(Res->GetFlags() & RF_TagGarbage);
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::AttemptDelete( UObject*& Res, DWORD KeepFlags, INT IgnoreReference )
{
	guard(UObject::AttemptDelete);
	if( !(Res->GetFlags() & RF_Native) && !IsReferenced(Res, KeepFlags, IgnoreReference) )
	{
		PurgeGarbage();
		return 1;
	}
	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Object serialization helpers.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::BindPackage( UPackage* Package )
{
	guard(UObject::BindPackage);
	if( Package && !Package->DllHandle && !Package->Outer && !Package->AttemptedBind )
	{
		TCHAR Path[256];
		appStrcpy( Path, appBaseDir() );
		appStrcat( Path, Package->GetName() );
		appStrupr( Path );
		Package->AttemptedBind = 1;
		GObjNoRegister = 0;
		Package->DllHandle = appGetDllHandle( Path );
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UObject::GetIndexedObject( INT Index )
{
	if( GObjObjects.IsValidIndex(Index) )
		return GObjObjects(Index);
	return NULL;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::GetObjectHash( FName ObjName, INT Outer )
{
	return (ObjName.GetIndex() ^ Outer) & (ARRAY_COUNT(GObjHash)-1);
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
TArray<UObject*> UObject::GetLoaderList()
{
	return GObjLoaded;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ResetLoaders( UObject* Pkg, INT DynamicOnly, INT ForceLazyLoad )
{
	guard(UObject::ResetLoaders);
	for( INT i=GObjLoaders.Num()-1; i>=0; i-- )
	{
		ULinkerLoad* Linker = (ULinkerLoad*)GObjLoaders(i);
		if( !Pkg || Linker->LinkerRoot == Pkg )
		{
			Linker->DetachAllLazyLoaders( ForceLazyLoad );
		}
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::VerifyLinker( ULinkerLoad* Linker )
{
	guard(UObject::VerifyLinker);
	if( Linker )
		Linker->Verify();
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::GetRegistryObjects( TArray<FRegistryObjectInfo>& Results, UClass* InClass, UClass* InMetaClass, INT InIterateFlags )
{
	guard(UObject::GetRegistryObjects);
	CacheDrivers( InIterateFlags != 0 );
	for( INT i=0; i<GObjDrivers.Num(); i++ )
	{
		FRegistryObjectInfo& Info = GObjDrivers(i);
		if( InClass && InMetaClass )
		{
			// Filter by meta-class: the description encodes the class name.
			if( appStricmp(*Info.MetaClass, InMetaClass->GetPathName()) == 0 )
				Results.AddItem( Info );
		}
		else
		{
			Results.AddItem( Info );
		}
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::GetPreferences( TArray<FPreferencesInfo>& Results, const TCHAR* Category, INT InIterateFlags )
{
	guard(UObject::GetPreferences);
	CacheDrivers( InIterateFlags != 0 );
	for( INT i=0; i<GObjPreferences.Num(); i++ )
	{
		FPreferencesInfo& Info = GObjPreferences(i);
		if( !Category || *Category == TEXT('\0') || appStricmp(*Info.Caption, Category) == 0 )
			Results.AddItem( Info );
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::GlobalSetProperty( const TCHAR* Value, UClass* InClass, UProperty* Property, INT Offset, INT Immediate )
{
	guard(UObject::GlobalSetProperty);
	for( FObjectIterator It; It; ++It )
	{
		if( It->IsA(InClass) )
		{
			Property->ImportText( Value, (BYTE*)*It + Offset, 0 );
			if( Immediate )
				It->PostEditChange();
		}
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject property methods.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ExportProperties( FOutputDevice& Out, UClass* ObjectClass, BYTE* Object, INT Indent, UClass* DiffClass, BYTE* Diff )
{
	guard(UObject::ExportProperties);
	if( !ObjectClass || !Object )
		return;
	TCHAR ValueStr[4096];
	for( TFieldIterator<UProperty> It(ObjectClass); It; ++It )
	{
		UProperty* Property = *It;
		for( INT Idx=0; Idx<Property->ArrayDim; Idx++ )
		{
			BYTE* DiffPtr = (Diff && DiffClass) ? Diff + Property->Offset + Idx * Property->ElementSize : NULL;
			ValueStr[0] = 0;
			if( Property->ExportText( Idx, ValueStr, Object, DiffPtr, 0 ) )
			{
				Out.Logf( TEXT("%s%s=%s"), appSpc(Indent), Property->GetName(), ValueStr );
			}
		}
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::InitClassDefaultObject( UClass* InClass, INT SetOuter )
{
	guard(UObject::InitClassDefaultObject);
	// Zero the UObject header area.
	appMemzero( this, sizeof(UObject) );
	// Restore the vtable pointer from InClass (vtable lives at offset 0).
	*(void**)this = *(void**)InClass;
	Class         = InClass;
	Index         = INDEX_NONE;
	if( SetOuter )
		Outer = InClass->GetOuter();

	// Initialise properties using the super class defaults if available.
	UClass* SuperClass = (UClass*)InClass->SuperField;
	BYTE* SuperDefaults = SuperClass ? &SuperClass->Defaults(0) : NULL;
	INT   SuperSize     = SuperClass ? SuperClass->GetPropertiesSize() : 0;
	InitProperties( (BYTE*)this, InClass->GetPropertiesSize(), InClass, SuperDefaults, SuperSize, this, NULL );
	unguard;
}

/*-----------------------------------------------------------------------------
	Search methods.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UFunction* UObject::FindFunctionChecked( FName FuncName, INT Global )
{
	guard(UObject::FindFunctionChecked);
	UFunction* Result = FindFunction( FuncName, Global );
	if( !Result )
		appErrorf( TEXT("Failed to find function '%s' in '%s'"), *FuncName, GetFullName() );
	return Result;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UField* UObject::FindObjectField( FName FieldName, INT Global )
{
	guard(UObject::FindObjectField);
	INT HashIndex = FieldName.GetIndex() & (UField::HASH_COUNT - 1);

	// Search current state first (unless Global flag is set).
	if( !Global && StateFrame && StateFrame->StateNode != (UState*)GetClass() )
	{
		UState* State = StateFrame->StateNode;
		for( UField* F = State->VfHash[HashIndex]; F; F = F->HashNext )
			if( F->GetFName() == FieldName )
				return F;
	}

	// Walk the class hierarchy.
	for( UStruct* Struct = GetClass(); Struct; Struct = (UStruct*)Struct->SuperField )
	{
		if( Struct->IsA(UState::StaticClass()) )
		{
			for( UField* F = ((UState*)Struct)->VfHash[HashIndex]; F; F = F->HashNext )
				if( F->GetFName() == FieldName )
					return F;
		}
	}
	return NULL;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UState* UObject::FindState( FName StateName )
{
	guard(UObject::FindState);
	INT HashIndex = StateName.GetIndex() & (UField::HASH_COUNT - 1);
	for( UStruct* Struct = GetClass(); Struct; Struct = (UStruct*)Struct->SuperField )
	{
		if( Struct->IsA(UState::StaticClass()) )
		{
			for( UField* F = ((UState*)Struct)->VfHash[HashIndex]; F; F = F->HashNext )
			{
				if( F->GetFName() == StateName && F->IsA(UState::StaticClass()) )
					return (UState*)F;
			}
		}
	}
	return NULL;
	unguard;
}

/*-----------------------------------------------------------------------------
	Property search helpers.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindBoolProperty( FString PropertyName, INT* Value )
{
	guard(UObject::FindBoolProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindIntProperty( FString PropertyName, INT* Value )
{
	guard(UObject::FindIntProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindFloatProperty( FString PropertyName, FLOAT* Value )
{
	guard(UObject::FindFloatProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindFNameProperty( FString PropertyName, FName* Value )
{
	guard(UObject::FindFNameProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindObjectProperty( FString PropertyName, UObject** Value )
{
	guard(UObject::FindObjectProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindArrayProperty( FString PropertyName, FArray** Value, INT* ElementSize )
{
	guard(UObject::FindArrayProperty);
	return 0;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::FindStructProperty( FString PropertyName, UStruct** Value )
{
	guard(UObject::FindStructProperty);
	return 0;
	unguard;
}

/*-----------------------------------------------------------------------------
	Config.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::LoadConfig( INT Immediate, UClass* InClass, const TCHAR* Filename )
{
	guard(UObject::LoadConfig);
	UClass* ConfigClass = InClass ? InClass : GetClass();
	const TCHAR* Section = *ConfigClass->ClassConfigName;
	for( TFieldIterator<UProperty> It(ConfigClass); It; ++It )
	{
		UProperty* Property = *It;
		if( !(Property->PropertyFlags & CPF_Config) )
			continue;
		TCHAR Buffer[1024]; Buffer[0] = 0;
		if( GConfig->GetString(Section, Property->GetName(), Buffer, ARRAY_COUNT(Buffer), Filename) )
		{
			Property->ImportText( Buffer, (BYTE*)this + Property->Offset, 0 );
		}
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SaveConfig( DWORD Flags, const TCHAR* Filename )
{
	guard(UObject::SaveConfig);
	UClass* ConfigClass = GetClass();
	const TCHAR* Section = *ConfigClass->ClassConfigName;
	TCHAR ValueStr[4096];
	for( TFieldIterator<UProperty> It(ConfigClass); It; ++It )
	{
		UProperty* Property = *It;
		if( !(Property->PropertyFlags & CPF_Config) )
			continue;
		ValueStr[0] = 0;
		Property->ExportText( 0, ValueStr, (BYTE*)this, NULL, PPF_Delimited );
		GConfig->SetString( Section, Property->GetName(), ValueStr, Filename );
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ResetConfig( UClass* InClass, const TCHAR* Section, INT StartIndex )
{
	guard(UObject::ResetConfig);
	if( !InClass )
		return;
	UObject* Defaults = InClass->GetDefaultObject();
	if( !Defaults )
		return;
	// Re-apply config defaults to every live instance of InClass.
	for( FObjectIterator It; It; ++It )
	{
		if( !It->IsA(InClass) )
			continue;
		for( TFieldIterator<UProperty> PropIt(InClass); PropIt; ++PropIt )
		{
			UProperty* Property = *PropIt;
			if( !(Property->PropertyFlags & CPF_Config) )
				continue;
			for( INT Idx=0; Idx<Property->ArrayDim; Idx++ )
			{
				Property->CopySingleValue(
					(BYTE*)*It      + Property->Offset + Idx * Property->ElementSize,
					(BYTE*)Defaults + Property->Offset + Idx * Property->ElementSize );
			}
		}
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::LoadLocalized()
{
	guard(UObject::LoadLocalized);
	UClass* LocClass = GetClass();
	const TCHAR* PackageName = LocClass->GetOuter() ? LocClass->GetOuter()->GetName() : TEXT("Core");
	const TCHAR* SectionName = LocClass->GetName();
	for( TFieldIterator<UProperty> It(LocClass); It; ++It )
	{
		UProperty* Property = *It;
		if( !(Property->PropertyFlags & CPF_Localized) )
			continue;
		const TCHAR* Localized = Localize( SectionName, Property->GetName(), PackageName, NULL, 1 );
		if( Localized && *Localized )
			Property->ImportText( Localized, (BYTE*)this + Property->Offset, PPF_Localized );
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ParseParms( const TCHAR* Parms )
{
	guard(UObject::ParseParms);
	if( !Parms )
		return;
	for( TFieldIterator<UProperty> It(GetClass()); It; ++It )
	{
		UProperty* Property = *It;
		if( !(Property->PropertyFlags & CPF_Parm) )
			continue;
		TCHAR Buffer[256]; Buffer[0] = 0;
		if( Parse(Parms, Property->GetName(), Buffer, ARRAY_COUNT(Buffer)) )
			Property->ImportText( Buffer, (BYTE*)this + Property->Offset, 0 );
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	Conditional operations.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::ConditionalRegister()
{
	guard(UObject::ConditionalRegister);
	Register();
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
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

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::CheckDanglingOuter( UObject* Obj )
{
	guard(UObject::CheckDanglingOuter);
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::CheckDanglingRefs( UObject* Obj )
{
	guard(UObject::CheckDanglingRefs);
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::StaticConstructor()
{
	guard(UObject::StaticConstructor);
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::InternalConstructor( void* X )
{
	guard(UObject::InternalConstructor);
	new( (EInternal*)X )UObject;
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject event helpers.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::eventBeginState()
{
	guard(eventBeginState);
	ProcessEvent( FindFunctionChecked(NAME_BeginState,0), NULL, NULL );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::eventEndState()
{
	guard(eventEndState);
	ProcessEvent( FindFunctionChecked(NAME_EndState,0), NULL, NULL );
	unguard;
}

/*-----------------------------------------------------------------------------
	Global variable definitions.
-----------------------------------------------------------------------------*/

CORE_API TArray<FEdLoadError> GEdLoadErrors;
CORE_API TArray<INT> GIndexArrayDebugPkg;
CORE_API TArray<INT> GIntArrayDebugPkg;

class UDebugger;
CORE_API UDebugger* GDebugger = NULL;

Native GCasts[256];

FGuid FGuid::SpecialGUIDArmPatches;

/*-----------------------------------------------------------------------------
	FEdLoadError class.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FEdLoadError::FEdLoadError()
: Type(0), Desc()
{
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FEdLoadError::FEdLoadError( INT InType, TCHAR* InDesc )
: Type(InType), Desc(InDesc)
{
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FEdLoadError::FEdLoadError( const FEdLoadError& Other )
: Type(Other.Type), Desc(Other.Desc)
{
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FEdLoadError::~FEdLoadError()
{
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FEdLoadError& FEdLoadError::operator=( FEdLoadError Other )
{
	Type = Other.Type;
	Desc = Other.Desc;
	return *this;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT FEdLoadError::operator==( const FEdLoadError& Other ) const
{
	return Type == Other.Type && Desc == Other.Desc;
}

/*-----------------------------------------------------------------------------
	Editor load error helpers.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
CORE_API void EdClearLoadErrors()
{
	GEdLoadErrors.Empty();
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
CORE_API void VARARGS EdLoadErrorf( INT Type, const TCHAR* Fmt, ... )
{
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	new(GEdLoadErrors) FEdLoadError( Type, TempStr );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
CORE_API BYTE GRegisterCast( INT CastCode, const Native& Func )
{
	// On first call, initialise all cast slots to execUndefined.
	static INT Initialized = 0;
	if( !Initialized )
	{
		for( INT i = 0; i < 256; i++ )
			GCasts[i] = &UObject::execUndefined;
		Initialized = 1;
	}

	if( CastCode != -1 )
	{
		if( (DWORD)CastCode > 255 || GCasts[CastCode] != &UObject::execUndefined )
			GCastDuplicate = CastCode;
		else
			GCasts[CastCode] = Func;
	}
	return 0;
}

/*-----------------------------------------------------------------------------
	ParseObject.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
CORE_API INT ParseObject( const TCHAR* Stream, const TCHAR* Match, UClass* Class, UObject*& DestRes, UObject* InParent )
{
	guard(ParseObject);
	// Ghidra Core 0x2fa20 (178 bytes): parse a token then look it up as a UObject.
	TCHAR TempStr[256];
	if( !Parse( Stream, Match, TempStr, 0x40 ) )
		return 0;
	if( appStricmp( TempStr, TEXT("NONE") ) == 0 )
	{
		DestRes = NULL;
	}
	else
	{
		UObject* Found = UObject::StaticFindObject( Class, InParent, TempStr, 0 );
		if( !Found )
			return 0;
		DestRes = Found;
	}
	return 1;
	unguard;
}

/*-----------------------------------------------------------------------------
	UObject::operator delete — out-of-line definition.
	Must be out-of-line so the linker can export the symbol via .def.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::operator delete( void* Object, size_t Size )
{
	guard(UObject::operator delete);
	appFree( Object );
	unguard;
}

/*-----------------------------------------------------------------------------
	Additional UObject methods.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::AddObject( INT InIndex )
{
	guard(UObject::AddObject);
	if( InIndex == INDEX_NONE )
	{
		if( GObjAvailable.Num() )
		{
			InIndex = GObjAvailable( GObjAvailable.Num()-1 );
			GObjAvailable.Remove( GObjAvailable.Num()-1 );
		}
		else
		{
			InIndex = GObjObjects.Add();
		}
	}
	GObjObjects(InIndex) = this;
	Index = InIndex;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::HashObject()
{
	guard(UObject::HashObject);
	INT iHash       = GetObjectHash( Name, Outer ? Outer->GetIndex() : 0 );
	HashNext        = GObjHash[iHash];
	GObjHash[iHash] = this;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::UnhashObject( INT OuterIndex )
{
	guard(UObject::UnhashObject);
	INT iHash = GetObjectHash( Name, OuterIndex );
	UObject** Hash = &GObjHash[iHash];
	while( *Hash != NULL )
	{
		if( *Hash == this )
		{
			*Hash = HashNext;
			break;
		}
		Hash = &(*Hash)->HashNext;
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SetLinker( ULinkerLoad* InLinker, INT InLinkerIndex )
{
	guard(UObject::SetLinker);
	_Linker      = InLinker;
	_LinkerIndex = InLinkerIndex;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
FName UObject::MakeUniqueObjectName( UObject* Parent, UClass* Class )
{
	guard(UObject::MakeUniqueObjectName);
	TCHAR NewBase[NAME_SIZE];
	appSprintf( NewBase, TEXT("%s"), Class->GetName() );
	TCHAR Result[NAME_SIZE];
	do
	{
		appSprintf( Result, TEXT("%s%i"), NewBase, GObjRegisterCount++ );
	}
	while( StaticFindObject( NULL, Parent, Result, 0 ) );
	return FName( Result );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
ULinkerLoad* UObject::GetLoader( INT i )
{
	guard(UObject::GetLoader);
	if( i >= 0 && i < GObjLoaders.Num() )
		return (ULinkerLoad*)GObjLoaders(i);
	return NULL;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SafeLoadError( DWORD LoadFlags, const TCHAR* Error, const TCHAR* Fmt, ... )
{
	guard(UObject::SafeLoadError);
	TCHAR TempStr[4096];
	GET_VARARGS( TempStr, ARRAY_COUNT(TempStr), Fmt );
	if( LoadFlags & LOAD_Throw )
		appThrowf( TEXT("%s"), TempStr );
	else if( LoadFlags & LOAD_NoWarn )
		debugf( NAME_Log, TEXT("%s"), TempStr );
	else
		GWarn->Logf( TEXT("%s"), TempStr );
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject& UObject::operator=( const UObject& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	UCommandlet stubs.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UCommandlet::UCommandlet( const UCommandlet& Other )
: UObject( Other )
, HelpCmd     ( Other.HelpCmd )
, HelpOneLiner( Other.HelpOneLiner )
, HelpUsage   ( Other.HelpUsage )
, HelpWebLink ( Other.HelpWebLink )
{
	guard(UCommandlet::UCommandlet);
	for( INT i = 0; i < ARRAY_COUNT(HelpParm); i++ ) HelpParm[i] = Other.HelpParm[i];
	for( INT i = 0; i < ARRAY_COUNT(HelpDesc); i++ ) HelpDesc[i] = Other.HelpDesc[i];
	LogToStdout    = Other.LogToStdout;
	IsServer       = Other.IsServer;
	IsClient       = Other.IsClient;
	IsEditor       = Other.IsEditor;
	LazyLoad       = Other.LazyLoad;
	ShowErrorCount = Other.ShowErrorCount;
	ShowBanner     = Other.ShowBanner;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UCommandlet& UCommandlet::operator=( const UCommandlet& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	Ravenshield UObject overloads.
	These Ravenshield-specific overloads delegate to existing base versions.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::Rename( const TCHAR* NewName )
{
	guard(UObject::Rename);
	INT OldOuterIndex = Outer ? Outer->GetIndex() : 0;
	UnhashObject( OldOuterIndex );
	if( NewName )
		Name = FName( NewName );
	HashObject();
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::Rename( const TCHAR* NewName, UObject* NewOuter )
{
	INT OldOuterIndex = Outer ? Outer->GetIndex() : 0;
	UnhashObject( OldOuterIndex );
	if( NewName )
		Name = FName( NewName );
	if( NewOuter )
		Outer = NewOuter;
	HashObject();
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::LoadLocalized( INT Flags, UClass* Class )
{
	LoadLocalized();
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::SetKey( UClass* InClass, const TCHAR* Key )
{
	guard(UObject::SetKey);
	TCHAR TokenBuf[258];
	const TCHAR* P = Key;
	if( ParseToken( P, TokenBuf, ARRAY_COUNT(TokenBuf), 0 ) )
	{
		while( *P == TEXT(' ') )
			P++;
		if( appStrlen(P) > 0 )
		{
			TCHAR SectionBuf[32000];
			UBOOL bFound = GConfig->GetSection( InClass->GetPathName(), SectionBuf, 32000, *InClass->ClassConfigName );
			if( bFound )
			{
				for( TCHAR* Entry = SectionBuf; *Entry; Entry += appStrlen(Entry) + 1 )
				{
					TCHAR* Eq = appStrstr( Entry, TEXT("=") );
					if( Eq )
					{
						*Eq = TEXT('\0');
						if( appStricmp( Eq+1, P ) == 0 )
						{
							UProperty* Prop = FindField<UProperty>( InClass, Entry );
							if( Prop )
								GlobalSetProperty( TEXT(""), InClass, Prop, Prop->Offset, 1 );
						}
					}
				}
			}
		}
		UProperty* Prop = FindField<UProperty>( InClass, TokenBuf );
		if( Prop )
			GlobalSetProperty( P, InClass, Prop, Prop->Offset, 1 );
	}
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::InitProperties( BYTE* Data, INT DataCount, UClass* DefaultsClass, BYTE* Defaults, INT DefaultsCount, UObject* DestObject, INT bNativeDefaults )
{
	InitProperties( Data, DataCount, DefaultsClass, Defaults, DefaultsCount, DestObject, (UObject*)NULL );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UObject::StaticConstructObject( UClass* Class, UObject* InOuter, FName Name, DWORD Flags, UObject* Template, FOutputDevice* Error, INT Reserved )
{
	return StaticConstructObject( Class, InOuter, Name, Flags, Template, Error, (UObject*)NULL );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::StaticExec( const TCHAR* Cmd, FOutputDevice& Ar, INT bShowHelp )
{
	return StaticExec( Cmd, Ar );
}

/*-----------------------------------------------------------------------------
	UFactory Ravenshield overloads with ULevel* parameter.
	Delegates to base version ignoring ULevel*.
-----------------------------------------------------------------------------*/

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UFactory::FactoryCreateText( ULevel* Level, UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn )
{
	return FactoryCreateText( Class, InParent, Name, Flags, Context, Type, Buffer, BufferEnd, Warn );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
UObject* UFactory::StaticImportObject( ULevel* Level, UClass* Class, UObject* InOuter, FName Name, DWORD Flags, const TCHAR* Filename, UObject* Context, UFactory* Factory, const TCHAR* Parms, FFeedbackContext* Warn )
{
	return StaticImportObject( Class, InOuter, Name, Flags, Filename, Context, Factory, Parms, Warn );
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
INT UObject::ResolveName( UObject*& InPackage, const TCHAR*& InName, INT Create, INT Throw )
{
	guard(UObject::ResolveName);
	while( 1 )
	{
		const TCHAR* Dot = appStrchr( InName, '.' );
		if( !Dot )
			break;
		TCHAR Part[NAME_SIZE];
		appStrncpy( Part, InName, Min<INT>((INT)(Dot-InName)+1, NAME_SIZE) );
		Part[Dot-InName] = 0;
		UObject* NewPackage = StaticFindObject( UPackage::StaticClass(), InPackage, Part, 0 );
		if( !NewPackage )
		{
			if( Create )
				NewPackage = CreatePackage( InPackage, Part );
			else
				return 0;
		}
		InPackage = NewPackage;
		InName = Dot + 1;
	}
	return 1;
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::CacheDrivers( INT bForceRefresh )
{
	guard(UObject::CacheDrivers);
	// GObjDrivers/GObjPreferences are populated here from config.
	// Full implementation requires iterating GConfig sections for "Driver=" and
	// "Preferences=" entries and building FRegistryObjectInfo/FPreferencesInfo entries.
	// Stub: no-op — subsystems that depend on this (editor tools) will see empty lists.
	unguard;
}

IMPL_SDK("sdk/Ut99PubSrc/Core/Src/UnObj.cpp")
void UObject::PurgeGarbage()
{
	guard(UObject::PurgeGarbage);
	debugf( NAME_Log, TEXT("Purging garbage") );
	// Destroy all objects still tagged as garbage (tagged by IsReferenced / CollectGarbage).
	// DIVERGENCE: binary also garbage-collects FName entries; we skip that here.
	INT NumDestroyed = 0;
	for( INT i=0; i<GObjObjects.Num(); i++ )
	{
		UObject* Obj = GObjObjects(i);
		if( Obj && (Obj->GetFlags() & RF_TagGarbage) && !(Obj->GetFlags() & RF_Native) )
		{
			Obj->ConditionalDestroy();
			NumDestroyed++;
		}
	}
	// Clear any residual tags so objects are not double-destroyed.
	for( INT i=0; i<GObjObjects.Num(); i++ )
		if( GObjObjects(i) )
			GObjObjects(i)->ClearFlags( RF_TagGarbage );
	debugf( NAME_Log, TEXT("Garbage: purged %i object(s)"), NumDestroyed );
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
