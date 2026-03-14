/*=============================================================================
	UnClass.cpp: UField, UStruct, UFunction, UState, UEnum, UClass, UConst
	implementation — class hierarchy, serialization, linking, registration.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FDependency.
-----------------------------------------------------------------------------*/

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10115120 size 3 bytes")
FDependency::FDependency()
:	Class         ( NULL )
,	Deep          ( 0 )
,	ScriptTextCRC ( 0 )
{}

IMPL_MATCH("Core.dll", 0x101167F0)
FDependency::FDependency( UClass* InClass, UBOOL InDeep )
:	Class         ( InClass )
,	Deep          ( InDeep )
,	ScriptTextCRC ( InClass->GetScriptTextCRC() )
{}

IMPL_MATCH("Core.dll", 0x10116850)
UBOOL FDependency::IsUpToDate()
{
	guard(FDependency::IsUpToDate);
	if( !Class )
		return 1;
	return ScriptTextCRC == Class->GetScriptTextCRC();
	unguard;
}

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FArchive& operator<<( FArchive& Ar, FDependency& Dep )
{
	return Ar << Dep.Class << Dep.Deep << Dep.ScriptTextCRC;
}

/*-----------------------------------------------------------------------------
	FLabelEntry.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10115130)
FLabelEntry::FLabelEntry( FName InName, INT iInCode )
:	Name  ( InName )
,	iCode ( iInCode )
{}

IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
FArchive& operator<<( FArchive& Ar, FLabelEntry& Label )
{
	return Ar << Label.Name << Label.iCode;
}

/*-----------------------------------------------------------------------------
	UField.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101023D0)
UField::UField( ENativeConstructor, UClass* InClass, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UField* InSuperField )
:	UObject       ( EC_NativeConstructor, InClass, InName, InPackageName, InFlags )
,	SuperField    ( InSuperField )
,	Next          ( NULL )
,	HashNext      ( NULL )
{}

IMPL_MATCH("Core.dll", 0x101023F0)
UField::UField( EStaticConstructor, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags )
:	UObject       ( EC_StaticConstructor, InName, InPackageName, InFlags )
,	SuperField    ( NULL )
,	Next          ( NULL )
,	HashNext      ( NULL )
{}

IMPL_MATCH("Core.dll", 0x10114EB0)
UField::UField( UField* InSuperField )
:	SuperField    ( InSuperField )
,	Next          ( NULL )
,	HashNext      ( NULL )
{}

IMPL_MATCH("Core.dll", 0x10115280)
void UField::Serialize( FArchive& Ar )
{
	guard(UField::Serialize);
	UObject::Serialize( Ar );
	Ar << SuperField << Next;
	unguard;
}

IMPL_MATCH("Core.dll", 0x10114F70)
void UField::PostLoad()
{
	guard(UField::PostLoad);
	UObject::PostLoad();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10115090)
void UField::Register()
{
	guard(UField::Register);
	UObject::Register();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10115010)
void UField::AddCppProperty( UProperty* Property )
{
	guard(UField::AddCppProperty);
	appErrorf( TEXT("UField::AddCppProperty") );
	unguard;
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10115000 size 6 bytes")
UBOOL UField::MergeBools()
{
	return 1;
}

IMPL_EMPTY("Retail Core.dll: truly empty, confirmed")
void UField::Bind()
{
	// Retail Core.dll: ret (truly empty)
}

IMPL_MATCH("Core.dll", 0x10115260)
UClass* UField::GetOwnerClass()
{
	guard(UField::GetOwnerClass);
	UObject* Obj;
	for( Obj=this; Obj && !Obj->IsA(UClass::StaticClass()); Obj=Obj->GetOuter() );
	return Obj ? (UClass*)Obj : NULL;
	unguard;
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10114FF0 size 3 bytes")
INT UField::GetPropertiesSize()
{
	return 0;
}

IMPLEMENT_CLASS(UField);

/*-----------------------------------------------------------------------------
	UStruct.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010C690)
UStruct::UStruct( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UStruct* InSuperStruct )
:	UField         ( EC_NativeConstructor, UStruct::StaticClass(), InName, InPackageName, InFlags, InSuperStruct )
,	ScriptText     ( NULL )
,	CppText        ( NULL )
,	Children       ( NULL )
,	PropertiesSize ( InSize )
,	FriendlyName   ( NAME_None )
,	TextPos        ( 0 )
,	Line           ( 0 )
,	StructFlags    ( 0 )
,	RefLink        ( NULL )
,	PropertyLink   ( NULL )
,	ConfigLink     ( NULL )
,	ConstructorLink( NULL )
{}

IMPL_MATCH("Core.dll", 0x1010C6B0)
UStruct::UStruct( EStaticConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags )
:	UField         ( EC_StaticConstructor, InName, InPackageName, InFlags )
,	ScriptText     ( NULL )
,	CppText        ( NULL )
,	Children       ( NULL )
,	PropertiesSize ( InSize )
,	FriendlyName   ( NAME_None )
,	TextPos        ( 0 )
,	Line           ( 0 )
,	StructFlags    ( 0 )
,	RefLink        ( NULL )
,	PropertyLink   ( NULL )
,	ConfigLink     ( NULL )
,	ConstructorLink( NULL )
{}

IMPL_MATCH("Core.dll", 0x10116240)
UStruct::UStruct( UStruct* InSuperStruct )
:	UField         ( InSuperStruct )
,	ScriptText     ( NULL )
,	CppText        ( NULL )
,	Children       ( NULL )
,	PropertiesSize ( InSuperStruct ? InSuperStruct->PropertiesSize : 0 )
,	FriendlyName   ( NAME_None )
,	TextPos        ( 0 )
,	Line           ( 0 )
,	StructFlags    ( 0 )
,	RefLink        ( NULL )
,	PropertyLink   ( NULL )
,	ConfigLink     ( NULL )
,	ConstructorLink( NULL )
{}

IMPL_MATCH("Core.dll", 0x10115440)
void UStruct::Serialize( FArchive& Ar )
{
	guard(UStruct::Serialize);
	UField::Serialize( Ar );

	// Serialize the fields.
	Ar << ScriptText << Children << CppText;
	Ar << FriendlyName;

	// Serialize the script bytecode.
	Ar << Line << TextPos;

	// Serialize the bytecodes.
	INT ScriptSize = Script.Num();
	Ar << AR_INDEX(ScriptSize);
	if( Ar.IsLoading() )
	{
		Script.Empty( ScriptSize );
		Script.Add( ScriptSize );
	}
	Ar.Serialize( &Script(0), ScriptSize );

	unguard;
}

IMPL_MATCH("Core.dll", 0x10115180)
void UStruct::PostLoad()
{
	guard(UStruct::PostLoad);
	UField::PostLoad();
	unguard;
}

IMPL_MATCH("Core.dll", 0x101153C0)
void UStruct::Destroy()
{
	guard(UStruct::Destroy);
	Script.Empty();
	UField::Destroy();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10115340)
void UStruct::Register()
{
	guard(UStruct::Register);
	UField::Register();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10115110)
void UStruct::AddCppProperty( UProperty* Property )
{
	guard(UStruct::AddCppProperty);
	Property->Next = Children;
	Children       = Property;
	unguard;
}

IMPL_MATCH("Core.dll", 0x101181C0)
void UStruct::Link( FArchive& Ar, UBOOL Props )
{
	guard(UStruct::Link);

	// Link the properties.
	if( Props )
	{
		PropertiesSize = 0;
		if( GetSuperStruct() )
			PropertiesSize = Align( GetSuperStruct()->GetPropertiesSize(), PROPERTY_ALIGNMENT );

		PropertyLink    = NULL;
		ConfigLink      = NULL;
		ConstructorLink = NULL;
		RefLink         = NULL;

		for( TFieldIterator<UProperty> It(this); It && It.GetStruct()==this; ++It )
		{
			It->Link( Ar, (UProperty*)It->Next );
		}
	}

	unguard;
}

IMPL_MATCH("Core.dll", 0x10116CA0)
void UStruct::SerializeBin( FArchive& Ar, BYTE* Data )
{
	guard(UStruct::SerializeBin);
	for( TFieldIterator<UProperty> It(this); It; ++It )
	{
		It->SerializeBin( Ar, Data );
	}
	unguard;
}

IMPL_MATCH("Core.dll", 0x10116EE0)
void UStruct::SerializeTaggedProperties( FArchive& Ar, BYTE* Data, UClass* DefaultsClass )
{
	guard(UStruct::SerializeTaggedProperties);

	if( Ar.IsLoading() )
	{
		// Load tagged properties.
		while( 1 )
		{
			FName Tag;
			Ar << Tag;
			if( Tag == NAME_None )
				break;

			// Read property info.
			BYTE Info;
			Ar << Info;
			BYTE Type       = Info & 0x0F;
			BYTE SizeType   = (Info >> 4) & 0x07;
			UBOOL ArrayFlag = (Info >> 7) & 0x01;

			// Get size.
			INT Size;
			switch( SizeType )
			{
				case 0: Size = 1;  break;
				case 1: Size = 2;  break;
				case 2: Size = 4;  break;
				case 3: Size = 12; break;
				case 4: Size = 16; break;
				case 5: { BYTE B; Ar << B; Size = B; break; }
				case 6: { _WORD W; Ar << W; Size = W; break; }
				case 7: { Ar << Size; break; }
				default: Size = 0; break;
			}

			// Array index.
			INT ArrayIndex = 0;
			if( ArrayFlag )
			{
				BYTE B;
				Ar << B;
				ArrayIndex = B;
			}

			// Find matching property.
			UProperty* Prop = NULL;
			for( TFieldIterator<UProperty> It(this); It; ++It )
			{
				if( It->GetFName() == Tag )
				{
					Prop = *It;
					break;
				}
			}

			if( Prop )
			{
				// Serialize into the property.
				Prop->SerializeItem( Ar, Data + Prop->Offset + ArrayIndex * Prop->ElementSize );
			}
			else
			{
				// Skip unknown property.
				Ar.Seek( Ar.Tell() + Size );
			}
		}
	}
	else
	{
		// Save tagged properties.
		BYTE* Defaults = DefaultsClass ? &DefaultsClass->Defaults(0) : NULL;
		for( TFieldIterator<UProperty> It(this); It; ++It )
		{
			if( It->ShouldSerializeValue(Ar) )
			{
				for( INT Index=0; Index<It->ArrayDim; Index++ )
				{
					INT Offset = It->Offset + Index * It->ElementSize;
					if( !Defaults || !It->Matches( Data, Defaults, Index ) )
					{
						FName Tag = It->GetFName();
						Ar << Tag;

						// Write type/size info.
						INT Size = It->ElementSize;
						BYTE SizeType;
						if     ( Size==1  ) SizeType = 0;
						else if( Size==2  ) SizeType = 1;
						else if( Size==4  ) SizeType = 2;
						else if( Size==12 ) SizeType = 3;
						else if( Size==16 ) SizeType = 4;
						else if( Size<=255) SizeType = 5;
						else if( Size<=65535) SizeType = 6;
						else                  SizeType = 7;

						BYTE Info = (It->GetID() & 0x0F) | (SizeType << 4) | ((Index>0) ? 0x80 : 0);
						Ar << Info;

						// Write size if needed.
						switch( SizeType )
						{
							case 5: { BYTE B=(BYTE)Size; Ar << B; break; }
							case 6: { _WORD W=(_WORD)Size; Ar << W; break; }
							case 7: { Ar << Size; break; }
						}

						// Write array index.
						if( Index > 0 )
						{
							BYTE B = (BYTE)Index;
							Ar << B;
						}

						// Serialize value.
						It->SerializeItem( Ar, Data + Offset );
					}
				}
			}
		}
		// Write terminator.
		FName None = NAME_None;
		Ar << None;
	}
	unguard;
}

IMPL_MATCH("Core.dll", 0x10117870)
void UStruct::CleanupDestroyed( BYTE* Data )
{
	guard(UStruct::CleanupDestroyed);
	for( TFieldIterator<UProperty> It(this); It; ++It )
	{
		if( It->Offset < PropertiesSize )
			It->CleanupDestroyed( Data + It->Offset );
	}
	unguard;
}

IMPL_MATCH("Core.dll", 0x101159E0)
EExprToken UStruct::SerializeExpr( INT& iCode, FArchive& Ar )
{
	guard(UStruct::SerializeExpr);
	BYTE B = Script(iCode);
	Ar << B;
	iCode++;
	return (EExprToken)B;
	unguard;
}

IMPL_MATCH("Core.dll", 0x1010E0D0)
UBOOL UStruct::StructCompare( const void* A, const void* B )
{
	guard(UStruct::StructCompare);
	for( TFieldIterator<UProperty> It(this); It; ++It )
	{
		for( INT i=0; i<It->ArrayDim; i++ )
		{
			if( !It->Matches(A,B,i) )
				return 0;
		}
	}
	return 1;
	unguard;
}

IMPLEMENT_CLASS(UStruct);

/*-----------------------------------------------------------------------------
	UFunction.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010C8A0)
UFunction::UFunction( UFunction* InSuperFunction )
:	UStruct         ( InSuperFunction )
,	FunctionFlags   ( 0 )
,	iNative         ( 0 )
,	RepOffset       ( 0 )
,	OperPrecedence  ( 0 )
,	NumParms        ( 0 )
,	ParmsSize       ( 0 )
,	ReturnValueOffset( 0 )
,	Func            ( NULL )
{}

IMPL_MATCH("Core.dll", 0x10116940)
void UFunction::Serialize( FArchive& Ar )
{
	guard(UFunction::Serialize);
	UStruct::Serialize( Ar );

	// Function info.
	Ar << iNative << OperPrecedence;
	Ar << FunctionFlags;

	// Replication info.
	if( FunctionFlags & FUNC_Net )
		Ar << RepOffset;

	unguard;
}

IMPL_MATCH("Core.dll", 0x101151F0)
void UFunction::PostLoad()
{
	guard(UFunction::PostLoad);
	UStruct::PostLoad();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10116AC0)
void UFunction::Bind()
{
	guard(UFunction::Bind);
	if( iNative )
	{
		// Bind to native function.
		if( iNative < EX_Max )
			Func = GNatives[iNative];
	}
	unguard;
}

IMPL_MATCH("Core.dll", 0x10118A80)
void UFunction::Link( FArchive& Ar, UBOOL Props )
{
	guard(UFunction::Link);
	UStruct::Link( Ar, Props );

	// Count parms and figure out sizes.
	NumParms = 0;
	ParmsSize = 0;
	ReturnValueOffset = 0;

	for( TFieldIterator<UProperty> It(this); It && (It->PropertyFlags & CPF_Parm); ++It )
	{
		NumParms++;
		ParmsSize = It->Offset + It->GetSize();
		if( It->PropertyFlags & CPF_ReturnParm )
			ReturnValueOffset = It->Offset;
	}

	unguard;
}

IMPL_MATCH("Core.dll", 0x10118110)
UProperty* UFunction::GetReturnProperty()
{
	guard(UFunction::GetReturnProperty);
	for( TFieldIterator<UProperty> It(this); It && (It->PropertyFlags & CPF_Parm); ++It )
		if( It->PropertyFlags & CPF_ReturnParm )
			return *It;
	return NULL;
	unguard;
}

IMPLEMENT_CLASS(UFunction);

/*-----------------------------------------------------------------------------
	UState.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010CA30)
UState::UState( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UState* InSuperState )
:	UStruct    ( EC_NativeConstructor, InSize, InName, InPackageName, InFlags, InSuperState )
,	ProbeMask  ( 0 )
,	IgnoreMask ( 0 )
,	StateFlags ( 0 )
,	LabelTableOffset( 0 )
{
	appMemzero( VfHash, sizeof(VfHash) );
}

IMPL_MATCH("Core.dll", 0x1010CA50)
UState::UState( EStaticConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags )
:	UStruct    ( EC_StaticConstructor, InSize, InName, InPackageName, InFlags )
,	ProbeMask  ( 0 )
,	IgnoreMask ( 0 )
,	StateFlags ( 0 )
,	LabelTableOffset( 0 )
{
	appMemzero( VfHash, sizeof(VfHash) );
}

IMPL_MATCH("Core.dll", 0x10116380)
UState::UState( UState* InSuperState )
:	UStruct    ( InSuperState )
,	ProbeMask  ( 0 )
,	IgnoreMask ( 0 )
,	StateFlags ( 0 )
,	LabelTableOffset( 0 )
{
	appMemzero( VfHash, sizeof(VfHash) );
}

IMPL_MATCH("Core.dll", 0x10115640)
void UState::Serialize( FArchive& Ar )
{
	guard(UState::Serialize);
	UStruct::Serialize( Ar );

	Ar.SerializeInt( *(DWORD*)&ProbeMask, 1 );
	Ar.SerializeInt( *((DWORD*)&ProbeMask+1), 1 );
	Ar.SerializeInt( *(DWORD*)&IgnoreMask, 1 );
	Ar.SerializeInt( *((DWORD*)&IgnoreMask+1), 1 );
	Ar << LabelTableOffset << StateFlags;

	unguard;
}

IMPL_MATCH("Core.dll", 0x101155D0)
void UState::Destroy()
{
	guard(UState::Destroy);
	UStruct::Destroy();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10118760)
void UState::Link( FArchive& Ar, UBOOL Props )
{
	guard(UState::Link);
	UStruct::Link( Ar, Props );

	// Build hash table.
	appMemzero( VfHash, sizeof(VfHash) );
	for( TFieldIterator<UFunction> It(this); It; ++It )
	{
		INT iHash = It->GetFName().GetIndex() % HASH_COUNT;
		It->HashNext = VfHash[iHash];
		VfHash[iHash] = *It;
	}

	unguard;
}

IMPLEMENT_CLASS(UState);

/*-----------------------------------------------------------------------------
	UEnum.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010CBF0)
UEnum::UEnum( UEnum* InSuperEnum )
:	UField( InSuperEnum )
{}

IMPL_MATCH("Core.dll", 0x1013A130)
void UEnum::Serialize( FArchive& Ar )
{
	guard(UEnum::Serialize);
	UField::Serialize( Ar );
	Ar << Names;
	unguard;
}

IMPLEMENT_CLASS(UEnum);

/*-----------------------------------------------------------------------------
	UClass.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1010F550)
UClass::UClass()
:	ClassFlags        ( 0 )
,	ClassUnique       ( 0 )
,	ClassWithin       ( NULL )
,	ClassConfigName   ( NAME_None )
,	ClassConstructor  ( NULL )
,	ClassStaticConstructor( NULL )
{}

IMPL_MATCH("Core.dll", 0x10117CD0)
UClass::UClass( UClass* InSuperClass )
:	UState            ( InSuperClass )
,	ClassFlags        ( 0 )
,	ClassUnique       ( 0 )
,	ClassWithin       ( NULL )
,	ClassConfigName   ( NAME_None )
,	ClassConstructor  ( NULL )
,	ClassStaticConstructor( NULL )
{
	if( InSuperClass )
	{
		ClassFlags    = InSuperClass->ClassFlags & CLASS_Inherit;
		ClassWithin   = InSuperClass->ClassWithin;
		Defaults      = InSuperClass->Defaults;
	}
}

IMPL_MATCH("Core.dll", 0x10117D80)
UClass::UClass( ENativeConstructor, DWORD InSize, DWORD InClassFlags, UClass* InBaseClass, UClass* InWithinClass, FGuid InGuid, const TCHAR* InNameStr, const TCHAR* InPackageName, const TCHAR* InClassConfigName, DWORD InFlags, void(*InClassConstructor)(void*), void(UObject::*InClassStaticConstructor)() )
:	UState            ( EC_NativeConstructor, InSize, InNameStr, InPackageName, InFlags, InBaseClass )
,	ClassFlags        ( InClassFlags | CLASS_Parsed | CLASS_Compiled )
,	ClassUnique       ( 0 )
,	ClassGuid         ( InGuid )
,	ClassWithin       ( InWithinClass )
,	ClassConfigName   ( InClassConfigName )
,	ClassConstructor  ( InClassConstructor )
,	ClassStaticConstructor( InClassStaticConstructor )
{
	// Set defaults size.
	Defaults.AddZeroed( InSize );
}

IMPL_MATCH("Core.dll", 0x10117D80)
UClass::UClass( EStaticConstructor, DWORD InSize, DWORD InClassFlags, FGuid InGuid, const TCHAR* InNameStr, const TCHAR* InPackageName, const TCHAR* InClassConfigName, DWORD InFlags, void(*InClassConstructor)(void*), void(UObject::*InClassStaticConstructor)() )
:	UState            ( EC_StaticConstructor, InSize, InNameStr, InPackageName, InFlags )
,	ClassFlags        ( InClassFlags | CLASS_Parsed | CLASS_Compiled )
,	ClassUnique       ( 0 )
,	ClassGuid         ( InGuid )
,	ClassWithin       ( NULL )
,	ClassConfigName   ( InClassConfigName )
,	ClassConstructor  ( InClassConstructor )
,	ClassStaticConstructor( InClassStaticConstructor )
{
	Defaults.AddZeroed( InSize );
}

IMPL_MATCH("Core.dll", 0x10117960)
void UClass::Serialize( FArchive& Ar )
{
	guard(UClass::Serialize);
	UState::Serialize( Ar );

	Ar << ClassFlags << ClassGuid;
	Ar << Dependencies << PackageImports;
	Ar << ClassWithin << ClassConfigName;

	// Defaults.
	if( Ar.IsLoading() )
	{
		check(googledummy==0);
		Defaults.Empty();
		Defaults.AddZeroed( PropertiesSize );
	}
	SerializeTaggedProperties( Ar, &Defaults(0), GetSuperClass() );

	unguard;
}

IMPL_MATCH("Core.dll", 0x101158E0)
void UClass::PostLoad()
{
	guard(UClass::PostLoad);
	UState::PostLoad();
	unguard;
}

IMPL_MATCH("Core.dll", 0x101166C0)
void UClass::Destroy()
{
	guard(UClass::Destroy);
	Defaults.Empty();
	Dependencies.Empty();
	PackageImports.Empty();
	NetFields.Empty();
	ClassReps.Empty();
	UState::Destroy();
	unguard;
}

IMPL_MATCH("Core.dll", 0x10116470)
void UClass::Register()
{
	guard(UClass::Register);
	UState::Register();

	// Notify.
	debugf( NAME_Log, TEXT("Class %s registered"), GetName() );

	unguard;
}

IMPL_MATCH("Core.dll", 0x101156F0)
void UClass::Bind()
{
	guard(UClass::Bind);
	UState::Bind();

	// Bind native function table.
	UPackage* Pkg = CastChecked<UPackage>( GetOuter() );
	if( Pkg && !Pkg->AttemptedBind )
	{
		Pkg->AttemptedBind = 1;
		// Bind the package's DLL if it exists.
		Pkg->GetDllExport( TEXT("ProcessRegistrant"), 0 );
	}

	unguard;
}

IMPL_MATCH("Core.dll", 0x10118860)
void UClass::Link( FArchive& Ar, UBOOL Props )
{
	guard(UClass::Link);
	UState::Link( Ar, Props );

	// Build replication list.
	ClassReps.Empty();
	NetFields.Empty();

	unguard;
}

IMPLEMENT_CLASS(UClass);

/*-----------------------------------------------------------------------------
	UConst.
-----------------------------------------------------------------------------*/

// Small helper class — script constants.
// Not in UnClass.h on all SDK versions, but needed for completeness.

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
