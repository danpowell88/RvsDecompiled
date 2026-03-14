/*=============================================================================
	UnProp.cpp: UProperty and subclass implementations — all 13 property
	types for the Unreal property system (serialization, linking, import/export).
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

// ReadToken: Read a single token (alphanumeric word or quoted string) from
// a text buffer. Returns pointer past the token, or NULL on failure.
static const TCHAR* ReadToken( const TCHAR* Buffer, TCHAR* Result, INT MaxLen )
{
	if( !Buffer )
		return NULL;

	// Skip whitespace.
	while( *Buffer == ' ' || *Buffer == '\t' )
		Buffer++;

	if( !*Buffer )
		return NULL;

	INT Len = 0;
	if( *Buffer == '"' )
	{
		// Quoted string.
		Buffer++;
		while( *Buffer && *Buffer != '"' && Len < MaxLen - 1 )
			Result[Len++] = *Buffer++;
		if( *Buffer == '"' )
			Buffer++;
	}
	else
	{
		// Unquoted token — delimited by whitespace, comma, paren, etc.
		while( *Buffer && *Buffer != ' ' && *Buffer != '\t' && *Buffer != ',' && *Buffer != ')' && *Buffer != '(' && Len < MaxLen - 1 )
			Result[Len++] = *Buffer++;
	}
	Result[Len] = 0;
	return Len > 0 ? Buffer : NULL;
}

/*-----------------------------------------------------------------------------
	UProperty base.
-----------------------------------------------------------------------------*/

UProperty::UProperty()
:	ArrayDim          ( 1 )
,	ElementSize       ( 0 )
,	PropertyFlags     ( 0 )
,	Category          ( NAME_None )
,	RepOffset         ( 0 )
,	RepIndex          ( 0 )
,	Offset            ( 0 )
,	PropertyLinkNext  ( NULL )
,	ConfigLinkNext    ( NULL )
,	ConstructorLinkNext( NULL )
,	RepOwner          ( NULL )
,	Unknown1          ( 0 )
,	Unknown2          ( 0 )
,	Unknown3          ( 0 )
,	Unknown4          ( 0 )
{}

UProperty::UProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
:	ArrayDim          ( 1 )
,	ElementSize       ( 0 )
,	PropertyFlags     ( InFlags )
,	Category          ( InCategory ? FName(InCategory) : NAME_None )
,	RepOffset         ( 0 )
,	RepIndex          ( 0 )
,	Offset            ( InOffset )
,	PropertyLinkNext  ( NULL )
,	ConfigLinkNext    ( NULL )
,	ConstructorLinkNext( NULL )
,	RepOwner          ( NULL )
,	Unknown1          ( 0 )
,	Unknown2          ( 0 )
,	Unknown3          ( 0 )
,	Unknown4          ( 0 )
{}

void UProperty::Serialize( FArchive& Ar )
{
	guard(UProperty::Serialize);
	UField::Serialize( Ar );

	Ar << ArrayDim << PropertyFlags << Category;
	if( Ar.IsLoading() )
		Offset = 0;

	Ar << RepOffset;

	unguard;
}

void UProperty::Link( FArchive& Ar, UProperty* Prev )
{
	guard(UProperty::Link);
	if( Prev )
		Offset = Align( Prev->Offset + Prev->GetSize(), PROPERTY_ALIGNMENT );
	else
		Offset = Align( 0, PROPERTY_ALIGNMENT );
	unguard;
}

void UProperty::ExportCpp( FOutputDevice& Out, UBOOL IsLocal, UBOOL IsParm ) const
{
	guard(UProperty::ExportCpp);
	if( IsParm )
	{
		for( UClass* C = GetClass(); C; C = (UClass*)C->SuperField )
		{
			if( C == UStrProperty::StaticClass() )
			{
				if( !(PropertyFlags & CPF_OutParm) )
					Out.Log( TEXT("const ") );
				break;
			}
		}
	}
	ExportCppItem( Out );
	if( ArrayDim != 1 )
	{
		TCHAR Buf[32];
		appSprintf( Buf, TEXT("[%i]"), ArrayDim );
		Out.Log( Buf );
	}
	unguard;
}

UBOOL UProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	guard(UProperty::NetSerializeItem);
	SerializeItem( Ar, Data );
	return 1;
	unguard;
}

UBOOL UProperty::ExportText( INT ArrayElement, TCHAR* ValueStr, BYTE* Data, BYTE* Delta, INT PortFlags ) const
{
	guard(UProperty::ExportText);
	ExportTextItem( ValueStr, Data + ArrayElement*ElementSize, Delta ? Delta + ArrayElement*ElementSize : NULL, PortFlags );
	return 1;
	unguard;
}

void UProperty::CopySingleValue( void* Dest, void* Src ) const
{
	guard(UProperty::CopySingleValue);
	appMemcpy( Dest, Src, ElementSize );
	unguard;
}

void UProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	guard(UProperty::CopyCompleteValue);
	for( INT i=0; i<ArrayDim; i++ )
		CopySingleValue( (BYTE*)Dest + i*ElementSize, (BYTE*)Src + i*ElementSize );
	unguard;
}

void UProperty::DestroyValue( void* Dest ) const
{
	guard(UProperty::DestroyValue);
	unguard;
}

UBOOL UProperty::Port() const
{
	return (Category != NAME_None) && !(PropertyFlags & (CPF_Transient|CPF_Native));
}

BYTE UProperty::GetID() const
{
	// DIVERGENCE: Ghidra reads *(BYTE*)(GetClass() + 0x20) — a class-object-embedded
	// type byte that identifies the CPT_ property type.  The named field is unknown;
	// we replicate the raw access faithfully.
	return *(BYTE*)((BYTE*)GetClass() + 0x20);
}

IMPLEMENT_CLASS(UProperty);

/*-----------------------------------------------------------------------------
	UByteProperty.
-----------------------------------------------------------------------------*/

void UByteProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << Enum;
}

void UByteProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(BYTE);
}

UBOOL UByteProperty::Identical( const void* A, const void* B ) const
{
	return *(BYTE*)A == (B ? *(BYTE*)B : 0);
}

void UByteProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(BYTE*)Value;
}

UBOOL UByteProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	Ar << *(BYTE*)Data;
	return 1;
}

void UByteProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("BYTE") );
}

void UByteProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	if( Enum )
		appSprintf( ValueStr, TEXT("%s"), Enum->Names.IsValidIndex(*(BYTE*)PropertyValue) ? *Enum->Names(*(BYTE*)PropertyValue) : TEXT("(invalid)") );
	else
		appSprintf( ValueStr, TEXT("%i"), *(BYTE*)PropertyValue );
}

const TCHAR* UByteProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UByteProperty::ImportText);
	TCHAR Temp[256];
	if( Enum )
	{
		Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
		if( !Buffer )
			return NULL;
		FName EnumName( Temp, FNAME_Find );
		if( EnumName != NAME_None )
		{
			for( INT i=0; i<Enum->Names.Num(); i++ )
			{
				if( Enum->Names(i) == EnumName )
				{
					*(BYTE*)Data = (BYTE)i;
					return Buffer;
				}
			}
		}
	}
	*(BYTE*)Data = (BYTE)appAtoi(Buffer);
	while( *Buffer && *Buffer!=',' && *Buffer!=')' && *Buffer!='\r' && *Buffer!='\n' )
		Buffer++;
	return Buffer;
	unguard;
}

void UByteProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(BYTE*)Dest = *(BYTE*)Src;
}

void UByteProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	for( INT i=0; i<ArrayDim; i++ )
		((BYTE*)Dest)[i] = ((BYTE*)Src)[i];
}

IMPLEMENT_CLASS(UByteProperty);

/*-----------------------------------------------------------------------------
	UIntProperty.
-----------------------------------------------------------------------------*/

void UIntProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(INT);
}

UBOOL UIntProperty::Identical( const void* A, const void* B ) const
{
	return *(INT*)A == (B ? *(INT*)B : 0);
}

void UIntProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(INT*)Value;
}

void UIntProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("INT") );
}

void UIntProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%i"), *(INT*)PropertyValue );
}

const TCHAR* UIntProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UIntProperty::ImportText);
	*(INT*)Data = appAtoi(Buffer);
	while( *Buffer && *Buffer!=',' && *Buffer!=')' && *Buffer!='\r' && *Buffer!='\n' )
		Buffer++;
	return Buffer;
	unguard;
}

void UIntProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(INT*)Dest = *(INT*)Src;
}

IMPLEMENT_CLASS(UIntProperty);

/*-----------------------------------------------------------------------------
	UBoolProperty.
-----------------------------------------------------------------------------*/

void UBoolProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << BitMask;
}

void UBoolProperty::Link( FArchive& Ar, UProperty* Prev )
{
	guard(UBoolProperty::Link);
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(BITFIELD);
	if( Prev && Prev->IsA(UBoolProperty::StaticClass()) && Prev->GetOuter()==GetOuter() )
	{
		UBoolProperty* PrevBool = (UBoolProperty*)Prev;
		if( PrevBool->BitMask != NEXT_BITFIELD(PrevBool->BitMask) )
		{
			Offset  = PrevBool->Offset;
			BitMask = NEXT_BITFIELD(PrevBool->BitMask);
		}
		else
		{
			BitMask = 1;
		}
	}
	else
	{
		BitMask = 1;
	}
	unguard;
}

UBOOL UBoolProperty::Identical( const void* A, const void* B ) const
{
	return (!IsA(UBoolProperty::StaticClass())) || ((*(BITFIELD*)A ^ (B ? *(BITFIELD*)B : 0)) & BitMask) == 0;
}

void UBoolProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	BYTE B = (*(BITFIELD*)Value & BitMask) ? 1 : 0;
	Ar << B;
	if( B )
		*(BITFIELD*)Value |= BitMask;
	else
		*(BITFIELD*)Value &= ~BitMask;
}

void UBoolProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("BITFIELD") );
}

void UBoolProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%s"), (*(BITFIELD*)PropertyValue & BitMask) ? TEXT("True") : TEXT("False") );
}

const TCHAR* UBoolProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UBoolProperty::ImportText);
	TCHAR Temp[256];
	Buffer = ReadToken( Buffer, Temp, ARRAY_COUNT(Temp) );
	if( !Buffer )
		return NULL;
	if( appStricmp(Temp,TEXT("True"))==0 || appStricmp(Temp,TEXT("1"))==0 || appStricmp(Temp,GTrue)==0 )
		*(BITFIELD*)Data |= BitMask;
	else
		*(BITFIELD*)Data &= ~BitMask;
	return Buffer;
	unguard;
}

void UBoolProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(BITFIELD*)Dest = (*(BITFIELD*)Dest & ~BitMask) | (*(BITFIELD*)Src & BitMask);
}

IMPLEMENT_CLASS(UBoolProperty);

/*-----------------------------------------------------------------------------
	UFloatProperty.
-----------------------------------------------------------------------------*/

void UFloatProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(FLOAT);
}

UBOOL UFloatProperty::Identical( const void* A, const void* B ) const
{
	return *(FLOAT*)A == (B ? *(FLOAT*)B : 0.f);
}

void UFloatProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(FLOAT*)Value;
}

void UFloatProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("FLOAT") );
}

void UFloatProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%f"), *(FLOAT*)PropertyValue );
}

const TCHAR* UFloatProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UFloatProperty::ImportText);
	*(FLOAT*)Data = appAtof(Buffer);
	while( *Buffer && *Buffer!=',' && *Buffer!=')' && *Buffer!='\r' && *Buffer!='\n' )
		Buffer++;
	return Buffer;
	unguard;
}

void UFloatProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FLOAT*)Dest = *(FLOAT*)Src;
}

IMPLEMENT_CLASS(UFloatProperty);

/*-----------------------------------------------------------------------------
	UObjectProperty.
-----------------------------------------------------------------------------*/

void UObjectProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << PropertyClass;
}

void UObjectProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(UObject*);
}

UBOOL UObjectProperty::Identical( const void* A, const void* B ) const
{
	return *(UObject**)A == (B ? *(UObject**)B : NULL);
}

void UObjectProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(UObject**)Value;
}

void UObjectProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("class %s*"), PropertyClass->GetNameCPP() );
}

void UObjectProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	UObject* Obj = *(UObject**)PropertyValue;
	if( Obj )
		appSprintf( ValueStr, TEXT("%s'%s'"), Obj->GetClass()->GetName(), Obj->GetPathName(NULL,NULL) );
	else
		appSprintf( ValueStr, TEXT("None") );
}

const TCHAR* UObjectProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UObjectProperty::ImportText);

	// Parse "None".
	if( ParseCommand(&Buffer,TEXT("None")) )
	{
		*(UObject**)Data = NULL;
		return Buffer;
	}

	// Parse "Class'Package.Name'" format.
	TCHAR ClassName[NAME_SIZE];
	const TCHAR* Start = Buffer;

	// Read class name up to apostrophe.
	INT i=0;
	while( *Buffer && *Buffer!='\'' && i<NAME_SIZE-1 )
		ClassName[i++] = *Buffer++;
	ClassName[i] = 0;

	if( *Buffer == '\'' )
	{
		Buffer++;
		TCHAR ObjName[NAME_SIZE];
		INT j=0;
		while( *Buffer && *Buffer!='\'' && j<NAME_SIZE-1 )
			ObjName[j++] = *Buffer++;
		ObjName[j] = 0;
		if( *Buffer == '\'' )
			Buffer++;

		// Look up the object.
		UClass* ObjClass = FindObject<UClass>( ANY_PACKAGE, ClassName );
		if( ObjClass )
			*(UObject**)Data = StaticFindObject( ObjClass, ANY_PACKAGE, ObjName, 0 );
		else
			*(UObject**)Data = NULL;
	}
	else
	{
		// Try plain name lookup.
		Buffer = Start;
		TCHAR Temp[NAME_SIZE];
		Buffer = ReadToken( Buffer, Temp, NAME_SIZE );
		if( Buffer )
			*(UObject**)Data = StaticFindObject( PropertyClass, ANY_PACKAGE, Temp, 0 );
	}

	return Buffer;
	unguard;
}

void UObjectProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(UObject**)Dest = *(UObject**)Src;
}

IMPLEMENT_CLASS(UObjectProperty);

/*-----------------------------------------------------------------------------
	UClassProperty.
-----------------------------------------------------------------------------*/

void UClassProperty::Serialize( FArchive& Ar )
{
	UObjectProperty::Serialize( Ar );
	Ar << MetaClass;
}

IMPLEMENT_CLASS(UClassProperty);

/*-----------------------------------------------------------------------------
	UNameProperty.
-----------------------------------------------------------------------------*/

void UNameProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(FName);
}

UBOOL UNameProperty::Identical( const void* A, const void* B ) const
{
	return *(FName*)A == (B ? *(FName*)B : NAME_None);
}

void UNameProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(FName*)Value;
}

void UNameProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("FName") );
}

void UNameProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("%s"), **(FName*)PropertyValue );
}

const TCHAR* UNameProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UNameProperty::ImportText);
	TCHAR Temp[NAME_SIZE];
	Buffer = ReadToken( Buffer, Temp, NAME_SIZE );
	if( !Buffer )
		return NULL;
	*(FName*)Data = FName(Temp);
	return Buffer;
	unguard;
}

void UNameProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FName*)Dest = *(FName*)Src;
}

IMPLEMENT_CLASS(UNameProperty);

/*-----------------------------------------------------------------------------
	UStrProperty.
-----------------------------------------------------------------------------*/

void UStrProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(FString);
}

UBOOL UStrProperty::Identical( const void* A, const void* B ) const
{
	return *(FString*)A == (B ? *(FString*)B : TEXT(""));
}

void UStrProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	Ar << *(FString*)Value;
}

void UStrProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("FString") );
}

void UStrProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	appSprintf( ValueStr, TEXT("\"%s\""), **(FString*)PropertyValue );
}

const TCHAR* UStrProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UStrProperty::ImportText);
	FString& S = *(FString*)Data;
	if( *Buffer == '"' )
	{
		// Quoted string — read until closing quote, handle escape sequences.
		Buffer++;
		S = TEXT("");
		while( *Buffer && *Buffer!='"' )
		{
			if( *Buffer == '\\' && *(Buffer+1) )
			{
				Buffer++;
				if     ( *Buffer == 'n' ) S += TEXT("\n");
				else if( *Buffer == 't' ) S += TEXT("\t");
				else if( *Buffer == '\\') S += TEXT("\\");
				else if( *Buffer == '"' ) S += TEXT("\"");
				else                      { S += TEXT("\\"); S += FString::Printf(TEXT("%c"),*Buffer); }
			}
			else
			{
				S += FString::Printf(TEXT("%c"),*Buffer);
			}
			Buffer++;
		}
		if( *Buffer == '"' )
			Buffer++;
	}
	else
	{
		// Unquoted — read a single token.
		TCHAR Temp[1024];
		INT i=0;
		while( *Buffer && *Buffer!=' ' && *Buffer!='\t' && *Buffer!='\r' && *Buffer!='\n' && i<1023 )
			Temp[i++] = *Buffer++;
		Temp[i] = 0;
		S = Temp;
	}
	return Buffer;
	unguard;
}

void UStrProperty::CopySingleValue( void* Dest, void* Src ) const
{
	*(FString*)Dest = *(FString*)Src;
}

void UStrProperty::DestroyValue( void* Dest ) const
{
	for( INT i=0; i<ArrayDim; i++ )
		((FString*)Dest)[i].~FString();
}

IMPLEMENT_CLASS(UStrProperty);

/*-----------------------------------------------------------------------------
	UFixedArrayProperty.
-----------------------------------------------------------------------------*/

void UFixedArrayProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << Inner << Count;
}

void UFixedArrayProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	if( Inner )
		ElementSize = Inner->ElementSize * Count;
}

UBOOL UFixedArrayProperty::Identical( const void* A, const void* B ) const
{
	// Ghidra 0x44790: iterate all Count elements and compare via Inner->Identical.
	// No SEH frame in Ghidra.
	for( INT i = 0; i < Count; i++ )
	{
		const void* BElem = B ? (const void*)((BYTE*)B + Inner->ElementSize * i) : NULL;
		if( !Inner->Identical( (const void*)((BYTE*)A + Inner->ElementSize * i), BElem ) )
			return 0;
	}
	return 1;
}

void UFixedArrayProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	for( INT i=0; i<Count; i++ )
		Inner->SerializeItem( Ar, (BYTE*)Value + i*Inner->ElementSize );
}

void UFixedArrayProperty::ExportCppItem( FOutputDevice& Out ) const {}

void UFixedArrayProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	*ValueStr = 0;
}

const TCHAR* UFixedArrayProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	return Buffer;
}

void UFixedArrayProperty::CopySingleValue( void* Dest, void* Src ) const
{
	for( INT i=0; i<Count; i++ )
		Inner->CopySingleValue( (BYTE*)Dest + i*Inner->ElementSize, (BYTE*)Src + i*Inner->ElementSize );
}

void UFixedArrayProperty::DestroyValue( void* Dest ) const
{
	for( INT i=0; i<Count; i++ )
		Inner->DestroyValue( (BYTE*)Dest + i*Inner->ElementSize );
}

IMPLEMENT_CLASS(UFixedArrayProperty);

/*-----------------------------------------------------------------------------
	UArrayProperty.
-----------------------------------------------------------------------------*/

void UArrayProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << Inner;
}

void UArrayProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	ElementSize = sizeof(FArray);
}

UBOOL UArrayProperty::Identical( const void* A, const void* B ) const
{
	// Ghidra 0x44ca0: compare element counts first, then compare each element via Inner->Identical.
	// No SEH frame in Ghidra.
	const FArray* ArrayA = (const FArray*)A;
	const FArray* ArrayB = (const FArray*)B;
	INT CountA = ArrayA->Num();
	INT CountB = B ? ArrayB->Num() : 0;
	if( CountA != CountB )
		return 0;
	BYTE* DataA = (BYTE*)ArrayA->GetData();
	if( B == NULL )
	{
		for( INT i = 0; i < CountA; i++ )
		{
			if( !Inner->Identical( DataA, NULL ) )
				return 0;
			DataA += Inner->ElementSize;
		}
	}
	else
	{
		BYTE* DataB = (BYTE*)ArrayB->GetData();
		for( INT i = 0; i < CountA; i++ )
		{
			if( !Inner->Identical( DataA, DataB ) )
				return 0;
			DataA += Inner->ElementSize;
			DataB += Inner->ElementSize;
		}
	}
	return 1;
}

void UArrayProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	guard(UArrayProperty::SerializeItem);
	FArray* Array = (FArray*)Value;
	INT Count = Array->Num();
	Ar << AR_INDEX(Count);
	if( Ar.IsLoading() )
	{
		Array->Empty( Inner->ElementSize, Count );
		Array->AddZeroed( Inner->ElementSize, Count );
	}
	for( INT i=0; i<Count; i++ )
		Inner->SerializeItem( Ar, (BYTE*)Array->GetData() + i*Inner->ElementSize );
	unguard;
}

void UArrayProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("TArray") );
}

void UArrayProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	*ValueStr = 0;
}

const TCHAR* UArrayProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	return Buffer;
}

void UArrayProperty::CopySingleValue( void* Dest, void* Src ) const
{
	// Deep copy the dynamic array.
	FArray* DestArr = (FArray*)Dest;
	FArray* SrcArr  = (FArray*)Src;
	if( !Inner )
	{
		appMemcpy( Dest, Src, sizeof(FArray) );
		return;
	}
	INT Count = SrcArr->Num();
	DestArr->Empty( Inner->ElementSize );
	if( Count )
	{
		DestArr->AddZeroed( Inner->ElementSize, Count );
		for( INT i=0; i<Count; i++ )
			Inner->CopySingleValue( (BYTE*)DestArr->GetData() + i*Inner->ElementSize, (BYTE*)SrcArr->GetData() + i*Inner->ElementSize );
	}
}

void UArrayProperty::DestroyValue( void* Dest ) const
{
	guard(UArrayProperty::DestroyValue);
	FArray* Array = (FArray*)Dest;
	if( Inner )
	{
		for( INT i=0; i<Array->Num(); i++ )
			Inner->DestroyValue( (BYTE*)Array->GetData() + i*Inner->ElementSize );
	}
	Array->Empty( Inner ? Inner->ElementSize : 0 );
	unguard;
}

IMPLEMENT_CLASS(UArrayProperty);

/*-----------------------------------------------------------------------------
	UMapProperty.
-----------------------------------------------------------------------------*/

void UMapProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << Key << Value;
}

void UMapProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	// Map not used in Ravenshield.
}

UBOOL UMapProperty::Identical( const void* A, const void* B ) const
{
	// Ghidra 0x45270: maps are always considered identical (unused in Ravenshield).
	return 1;
}

void UMapProperty::SerializeItem( FArchive& Ar, void* Value ) const {}
void UMapProperty::ExportCppItem( FOutputDevice& Out ) const {}
void UMapProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const { *ValueStr = 0; }
const TCHAR* UMapProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const { return Buffer; }
void UMapProperty::CopySingleValue( void* Dest, void* Src ) const {}

IMPLEMENT_CLASS(UMapProperty);

/*-----------------------------------------------------------------------------
	UStructProperty.
-----------------------------------------------------------------------------*/

void UStructProperty::Serialize( FArchive& Ar )
{
	UProperty::Serialize( Ar );
	Ar << Struct;
}

void UStructProperty::Link( FArchive& Ar, UProperty* Prev )
{
	UProperty::Link( Ar, Prev );
	if( Struct )
		ElementSize = Align( Struct->GetPropertiesSize(), PROPERTY_ALIGNMENT );
}

UBOOL UStructProperty::Identical( const void* A, const void* B ) const
{
	guard(UStructProperty::Identical);
	if( !Struct )
		return 1;
	return Struct->StructCompare( A, B ? B : &((UClass*)Struct)->Defaults(0) );
	unguard;
}

void UStructProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	guard(UStructProperty::SerializeItem);
	if( Struct )
		Struct->SerializeBin( Ar, (BYTE*)Value );
	unguard;
}

void UStructProperty::ExportCppItem( FOutputDevice& Out ) const
{
	Out.Logf( TEXT("F%s"), Struct ? Struct->GetName() : TEXT("Unknown") );
}

void UStructProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	*ValueStr = 0;
}

const TCHAR* UStructProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UStructProperty::ImportText);
	if( !Struct )
		return Buffer;

	// Expect opening paren.
	if( *Buffer == '(' )
		Buffer++;

	// Import each property in the struct.
	for( TFieldIterator<UProperty> It(Struct); It; ++It )
	{
		// Skip whitespace and commas.
		while( *Buffer == ' ' || *Buffer == '\t' || *Buffer == ',' )
			Buffer++;
		if( *Buffer == ')' || *Buffer == 0 )
			break;

		// Import this sub-property.
		Buffer = It->ImportText( Buffer, Data + It->Offset, PortFlags );
		if( !Buffer )
			return NULL;
	}

	// Expect closing paren.
	if( *Buffer == ')' )
		Buffer++;

	return Buffer;
	unguard;
}

void UStructProperty::CopySingleValue( void* Dest, void* Src ) const
{
	appMemcpy( Dest, Src, ElementSize );
}

void UStructProperty::DestroyValue( void* Dest ) const
{
	guard(UStructProperty::DestroyValue);
	if( Struct )
	{
		for( TFieldIterator<UProperty> It(Struct); It; ++It )
		{
			if( It->PropertyFlags & CPF_NeedCtorLink )
				for( INT i=0; i<ArrayDim; i++ )
					It->DestroyValue( (BYTE*)Dest + i*ElementSize + It->Offset );
		}
	}
	unguard;
}

IMPLEMENT_CLASS(UStructProperty);

/*-----------------------------------------------------------------------------
	UDelegateProperty.
-----------------------------------------------------------------------------*/

UDelegateProperty::UDelegateProperty()
{
}

UDelegateProperty::UDelegateProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
{
}

void UDelegateProperty::Serialize( FArchive& Ar )
{
	guard(UDelegateProperty::Serialize);
	UProperty::Serialize( Ar );
	unguard;
}

void UDelegateProperty::CleanupDestroyed( BYTE* Data ) const
{
	guard(UDelegateProperty::CleanupDestroyed);
	// Clear delegate references to destroyed objects.
	if( Data )
	{
		// Delegate is stored as FName + UObject* pair (8 bytes on x86).
		*(UObject**)(Data + 4) = NULL;
		*(FName*)Data = NAME_None;
	}
	unguard;
}

void UDelegateProperty::Link( FArchive& Ar, UProperty* Prev )
{
	guard(UDelegateProperty::Link);
	UProperty::Link( Ar, Prev );
	// Delegate is FName (4 bytes) + UObject* (4 bytes) = 8 bytes.
	ElementSize = 8;
	unguard;
}

UBOOL UDelegateProperty::Identical( const void* A, const void* B ) const
{
	guard(UDelegateProperty::Identical);
	if( !B )
		return *(FName*)A == NAME_None;
	return *(FName*)A == *(FName*)B && *((UObject**)A + 1) == *((UObject**)B + 1);
	unguard;
}

void UDelegateProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const
{
	guard(UDelegateProperty::ExportCppItem);
	Out.Logf( TEXT("FScriptDelegate") );
	unguard;
}

void UDelegateProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const
{
	guard(UDelegateProperty::SerializeItem);
	Ar << *(FName*)Value;
	Ar << *((UObject**)Value + 1);
	unguard;
}

UBOOL UDelegateProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const
{
	guard(UDelegateProperty::NetSerializeItem);
	SerializeItem( Ar, Data, 0 );
	return 1;
	unguard;
}

void UDelegateProperty::ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const
{
	guard(UDelegateProperty::ExportTextItem);
	FName DelegateName = *(FName*)PropertyValue;
	UObject* DelegateObj = *((UObject**)(PropertyValue + 4));
	if( DelegateName != NAME_None && DelegateObj )
		appSprintf( ValueStr, TEXT("%s.%s"), DelegateObj->GetName(), *DelegateName );
	else
		appSprintf( ValueStr, TEXT("None") );
	unguard;
}

const TCHAR* UDelegateProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	guard(UDelegateProperty::ImportText);
	TCHAR Temp[NAME_SIZE];
	Buffer = ReadToken( Buffer, Temp, NAME_SIZE );
	if( !Buffer )
		return NULL;
	if( appStricmp(Temp, TEXT("None")) == 0 )
	{
		*(FName*)Data = NAME_None;
		*((UObject**)(Data + 4)) = NULL;
	}
	else
	{
		*(FName*)Data = FName(Temp);
	}
	return Buffer;
	unguard;
}

void UDelegateProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	guard(UDelegateProperty::CopySingleValue);
	*(FName*)Dest = *(FName*)Src;
	*((UObject**)Dest + 1) = *((UObject**)Src + 1);
	unguard;
}

void UDelegateProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	guard(UDelegateProperty::CopyCompleteValue);
	for( INT i=0; i<ArrayDim; i++ )
		CopySingleValue( (BYTE*)Dest + i*ElementSize, (BYTE*)Src + i*ElementSize, SuperObject );
	unguard;
}

IMPLEMENT_CLASS(UDelegateProperty);

/*-----------------------------------------------------------------------------
	UStruct::SerializeBin with MaxReadBytes.
-----------------------------------------------------------------------------*/

void UStruct::SerializeBin( FArchive& Ar, BYTE* Data, INT MaxReadBytes )
{
	SerializeBin( Ar, Data );
}

/*-----------------------------------------------------------------------------
	UNameProperty::CopyCompleteValue 2-arg.
-----------------------------------------------------------------------------*/

void UNameProperty::CopyCompleteValue( void* Dest, void* Src ) const
{
	*(FName*)Dest = *(FName*)Src;
}

/*-----------------------------------------------------------------------------
	UClassProperty::ImportText — delegates to UObjectProperty.
-----------------------------------------------------------------------------*/

const TCHAR* UClassProperty::ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const
{
	return UObjectProperty::ImportText( Buffer, Data, PortFlags );
}

/*-----------------------------------------------------------------------------
	UProperty overloaded methods — Ravenshield 3-arg variants.
	These delegate to existing 2-arg base versions.
-----------------------------------------------------------------------------*/

// UProperty base overloads.
void UProperty::ExportCpp( FOutputDevice& Out, UBOOL IsLocal, UBOOL IsParm, UBOOL IsStruct ) const
{
	ExportCpp( Out, IsLocal, IsParm );
}

void UProperty::SerializeItem( FArchive& Ar, void* Value ) const
{
	guard(UProperty::SerializeItem);
	// Retail: base no-op; subclasses override.
	unguard;
}

void UProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const
{
	SerializeItem( Ar, Value );
}

void UProperty::SerializeBin( FArchive& Ar, BYTE* Data ) const
{
	SerializeItem( Ar, Data );
}

void UProperty::CleanupDestroyed( BYTE* Data ) const
{
	guard(UProperty::CleanupDestroyed);
	// Retail 0x43880 (3b): no-op.
	unguard;
}

void UProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	CopySingleValue( Dest, Src );
}

void UProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const
{
	CopyCompleteValue( Dest, Src );
}

// UByteProperty.
void UByteProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UByteProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UByteProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UByteProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UIntProperty.
void UIntProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UIntProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UIntProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UIntProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(INT*)Dest = *(INT*)Src; }
void UIntProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UBoolProperty.
void UBoolProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UBoolProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UBoolProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }

// UFloatProperty.
void UFloatProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UFloatProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UFloatProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UFloatProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(FLOAT*)Dest = *(FLOAT*)Src; }
void UFloatProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UObjectProperty.
void UObjectProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UObjectProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UObjectProperty::CleanupDestroyed( BYTE* Data ) const {}
void UObjectProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UObjectProperty::CopyCompleteValue( void* Dest, void* Src ) const { *(UObject**)Dest = *(UObject**)Src; }
void UObjectProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { CopyCompleteValue( Dest, Src ); }

// UNameProperty.
void UNameProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UNameProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UNameProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UNameProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { UProperty::CopyCompleteValue( Dest, Src ); }

// UStrProperty.
void UStrProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UStrProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { ExportCppItem( Out ); }
void UStrProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UStrProperty::Serialize( FArchive& Ar ) { UProperty::Serialize( Ar ); }

// UFixedArrayProperty.
void UFixedArrayProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UFixedArrayProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* FixedArray */") ); }
void UFixedArrayProperty::CleanupDestroyed( BYTE* Data ) const {}
void UFixedArrayProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UFixedArrayProperty::AddCppProperty( UProperty* Property, INT Count ) {}

// UArrayProperty.
void UArrayProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UArrayProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Array */") ); }
void UArrayProperty::CleanupDestroyed( BYTE* Data ) const {}
void UArrayProperty::CopyCompleteValue( void* Dest, void* Src, UObject* SuperObject ) const { UProperty::CopyCompleteValue( Dest, Src ); }
void UArrayProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UArrayProperty::AddCppProperty( UProperty* Property ) { Inner = Property; }

// UMapProperty.
void UMapProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UMapProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Map */") ); }
void UMapProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }
void UMapProperty::DestroyValue( void* Dest ) const {}

// UStructProperty.
void UStructProperty::SerializeItem( FArchive& Ar, void* Value, INT MaxReadBytes ) const { UProperty::SerializeItem( Ar, Value ); }
void UStructProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const { Out.Log( TEXT("/* Struct */") ); }
void UStructProperty::CleanupDestroyed( BYTE* Data ) const {}
void UStructProperty::CopySingleValue( void* Dest, void* Src, UObject* SuperObject ) const { CopySingleValue( Dest, Src ); }

// UDelegateProperty — ExportCppItem already implemented in UnProp.cpp.

/*-----------------------------------------------------------------------------
	NetSerializeItem overloads.
-----------------------------------------------------------------------------*/

UBOOL UBoolProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UFloatProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UIntProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UObjectProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UFixedArrayProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UMapProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }
UBOOL UStructProperty::NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const { return UProperty::NetSerializeItem( Ar, Map, Data ); }

/*-----------------------------------------------------------------------------
	UProperty base class ExportCppItem implementations.
	Needed because we declared virtual (non-pure) in UProperty.
-----------------------------------------------------------------------------*/

void UProperty::ExportCppItem( FOutputDevice& Out ) const
{
	guard(UProperty::ExportCppItem);
	// Retail: base no-op; subclasses override.
	unguard;
}

void UProperty::ExportCppItem( FOutputDevice& Out, INT Indent ) const
{
	guard(UProperty::ExportCppItem);
	// Retail: base no-op; subclasses override.
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
