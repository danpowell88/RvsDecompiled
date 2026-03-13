/*=============================================================================
	UnExport.cpp: UExporter and UFactory — object import/export system.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Ut99PubSrc/Core/Inc/UExporter.h, UFactory.h
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	UExporter.
-----------------------------------------------------------------------------*/

UExporter::UExporter()
:	SupportedClass( NULL )
,	TextIndent     ( 0 )
,	bText          ( 0 )
,	bMulti         ( 0 )
{
}

void UExporter::StaticConstructor()
{
	guard(UExporter::StaticConstructor);
	// Ghidra offset 0x11240: register TArray<FString> Formats as a reflected property.
	UArrayProperty* A = new(GetClass(), TEXT("Formats"), RF_Public)
		UArrayProperty(CPP_PROPERTY(Formats), TEXT(""), 0);
	A->Inner = new(A, TEXT("StrProperty0"), RF_Public)
		UStrProperty(EC_CppProperty, 0, TEXT(""), 0);
	unguard;
}

void UExporter::Serialize( FArchive& Ar )
{
	guard(UExporter::Serialize);
	UObject::Serialize( Ar );
	Ar << SupportedClass;
	unguard;
}

UExporter* UExporter::FindExporter( UObject* Object, const TCHAR* FileType )
{
	guard(UExporter::FindExporter);
	check(Object);

	UExporter* BestExporter = NULL;
	for( TObjectIterator<UExporter> It; It; ++It )
	{
		if( Object->IsA(It->SupportedClass) )
		{
			for( INT i=0; i<It->Formats.Num(); i++ )
			{
				if( appStricmp(*It->Formats(i), FileType) == 0 )
				{
					if( !BestExporter || It->GetClass()->IsChildOf(BestExporter->GetClass()) )
						BestExporter = *It;
				}
			}
		}
	}
	return BestExporter;
	unguard;
}

INT UExporter::ExportToFile( UObject* Object, UExporter* InExporter, const TCHAR* Filename, UBOOL NoReplaceIdentical, UBOOL Prompt )
{
	guard(UExporter::ExportToFile);
	check(Object);

	// Find the file extension.
	const TCHAR* Ext = Filename + appStrlen(Filename);
	while( Ext > Filename && *Ext != '.' )
		Ext--;
	if( *Ext == '.' )
		Ext++;

	UExporter* Exporter = InExporter ? InExporter : FindExporter( Object, Ext );
	if( !Exporter )
	{
		debugf( NAME_Warning, TEXT("No exporter for %s with extension %s"), Object->GetFullName(), Ext );
		return 0;
	}

	if( Exporter->bText )
	{
		FStringOutputDevice Buffer;
		Exporter->ExportText( Object, Ext, Buffer, GWarn );
		if( NoReplaceIdentical )
		{
			FString Existing;
			if( appLoadFileToString(Existing, Filename) && Existing == *Buffer )
				return 1;
		}
		return appSaveStringToFile( *Buffer, Filename );
	}
	else
	{
		FBufferArchive Buffer;
		Exporter->ExportBinary( Object, Ext, Buffer, GWarn );
		if( NoReplaceIdentical )
		{
			TArray<BYTE> Existing;
			if( appLoadFileToArray(Existing, Filename) && Existing.Num()==Buffer.Num() && appMemcmp(&Existing(0),&Buffer(0),Buffer.Num())==0 )
				return 1;
		}
		return Buffer.Num() ? appSaveArrayToFile(Buffer, Filename) : 0;
	}
	unguard;
}

void UExporter::ExportToArchive( UObject* Object, UExporter* InExporter, FArchive& Ar, const TCHAR* FileType )
{
	guard(UExporter::ExportToArchive);
	check(Object);
	UExporter* Exporter = InExporter ? InExporter : FindExporter( Object, FileType );
	if( Exporter )
		Exporter->ExportBinary( Object, FileType, Ar, GWarn );
	unguard;
}

void UExporter::ExportToOutputDevice( UObject* Object, UExporter* InExporter, FOutputDevice& Out, const TCHAR* FileType, INT Indent )
{
	guard(UExporter::ExportToOutputDevice);
	check(Object);
	UExporter* Exporter = InExporter ? InExporter : FindExporter( Object, FileType );
	if( Exporter )
	{
		Exporter->TextIndent = Indent;
		Exporter->ExportText( Object, FileType, Out, GWarn );
	}
	unguard;
}

IMPLEMENT_CLASS(UExporter);

/*-----------------------------------------------------------------------------
	UFactory.
-----------------------------------------------------------------------------*/

UFactory::UFactory()
:	SupportedClass    ( NULL )
,	ContextClass      ( NULL )
,	bCreateNew        ( 0 )
,	bShowPropertySheet( 0 )
,	bShowCategories   ( 0 )
,	bText             ( 0 )
,	bMulti            ( 0 )
,	AutoPriority      ( 0 )
{
}

void UFactory::StaticConstructor()
{
	guard(UFactory::StaticConstructor);
	// Ghidra offset 0x12310: register config string properties and Formats array.
	new(GetClass(), TEXT("Description"), RF_Public)
		UStrProperty(CPP_PROPERTY(Description), TEXT("Config"), CPF_Config);
	new(GetClass(), TEXT("InContextCommand"), RF_Public)
		UStrProperty(CPP_PROPERTY(InContextCommand), TEXT("Config"), CPF_Config);
	new(GetClass(), TEXT("OutOfContextCommand"), RF_Public)
		UStrProperty(CPP_PROPERTY(OutOfContextCommand), TEXT("Config"), CPF_Config);
	UArrayProperty* A = new(GetClass(), TEXT("Formats"), RF_Public)
		UArrayProperty(CPP_PROPERTY(Formats), TEXT("Config"), CPF_Config);
	A->Inner = new(A, TEXT("StrProperty0"), RF_Public)
		UStrProperty(EC_CppProperty, 0, TEXT("Config"), CPF_Config);
	unguard;
}

void UFactory::Serialize( FArchive& Ar )
{
	guard(UFactory::Serialize);
	UObject::Serialize( Ar );
	Ar << SupportedClass << ContextClass;
	unguard;
}

UObject* UFactory::StaticImportObject( UClass* Class, UObject* InOuter, FName Name, DWORD Flags, const TCHAR* Filename, UObject* Context, UFactory* InFactory, const TCHAR* Parms, FFeedbackContext* Warn )
{
	guard(UFactory::StaticImportObject);
	check(Class);

	// Find file extension.
	const TCHAR* Ext = Filename + appStrlen(Filename);
	while( Ext > Filename && *Ext != '.' )
		Ext--;
	if( *Ext == '.' )
		Ext++;

	// Find a matching factory.
	UFactory* BestFactory = InFactory;
	if( !BestFactory )
	{
		INT BestPriority = -1;
		for( TObjectIterator<UFactory> It; It; ++It )
		{
			if( Class->IsChildOf(It->SupportedClass) && It->AutoPriority > BestPriority )
			{
				for( INT i=0; i<It->Formats.Num(); i++ )
				{
					if( appStricmp(*It->Formats(i), Ext) == 0 )
					{
						BestFactory  = *It;
						BestPriority = It->AutoPriority;
					}
				}
			}
		}
	}
	if( !BestFactory )
	{
		Warn->Logf( NAME_Warning, TEXT("No factory for %s"), Filename );
		return NULL;
	}

	// Import via text or binary factory.
	if( BestFactory->bText )
	{
		FString Data;
		if( appLoadFileToString(Data, Filename) )
		{
			const TCHAR* Buffer = *Data;
			return BestFactory->FactoryCreateText( Class, InOuter, Name, Flags, Context, Ext, Buffer, Buffer + Data.Len(), Warn );
		}
	}
	else
	{
		TArray<BYTE> Data;
		if( appLoadFileToArray(Data, Filename) )
		{
			const BYTE* Buffer = &Data(0);
			return BestFactory->FactoryCreateBinary( Class, InOuter, Name, Flags, Context, Ext, Buffer, Buffer + Data.Num(), Warn );
		}
	}

	return NULL;
	unguard;
}

IMPLEMENT_CLASS(UFactory);

/*-----------------------------------------------------------------------------
	UObjectExporterT3D.
-----------------------------------------------------------------------------*/

class CORE_API UObjectExporterT3D : public UExporter
{
	DECLARE_CLASS(UObjectExporterT3D,UExporter,0,Core)
	UObjectExporterT3D() {}
	void StaticConstructor()
	{
		SupportedClass = UObject::StaticClass();
		bText = 1;
		new(Formats)FString(TEXT("T3D"));
	}
	UBOOL ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn )
	{
		guard(UObjectExporterT3D::ExportText);
		Ar.Logf( TEXT("%sBegin Object Class=%s Name=%s\r\n"), appSpc(TextIndent), Object->GetClass()->GetName(), Object->GetName() );
		ExportProperties( Ar, Object->GetClass(), (BYTE*)Object, TextIndent+3, Object->GetClass(), &Object->GetClass()->Defaults(0) );
		Ar.Logf( TEXT("%sEnd Object\r\n"), appSpc(TextIndent) );
		return 1;
		unguard;
	}
};
IMPLEMENT_CLASS(UObjectExporterT3D);

/*-----------------------------------------------------------------------------
	UTextBufferFactory.
-----------------------------------------------------------------------------*/

class CORE_API UTextBufferFactory : public UFactory
{
	DECLARE_CLASS(UTextBufferFactory,UFactory,0,Core)
	UTextBufferFactory() {}
	void StaticConstructor()
	{
		SupportedClass = UTextBuffer::StaticClass();
		bText = 1;
		new(Formats)FString(TEXT("TXT"));
	}
	UObject* FactoryCreateText( UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn )
	{
		guard(UTextBufferFactory::FactoryCreateText);
		UTextBuffer* Result = new(InParent,Name,Flags) UTextBuffer;
		Result->Text = Buffer;
		return Result;
		unguard;
	}
	UObject* FactoryCreateText( ULevel* Level, UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn )
	{
		return FactoryCreateText( Class, InParent, Name, Flags, Context, Type, Buffer, BufferEnd, Warn );
	}
};
IMPLEMENT_CLASS(UTextBufferFactory);

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
