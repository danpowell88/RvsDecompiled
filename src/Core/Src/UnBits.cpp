/*=============================================================================
	UnBits.cpp: FBitWriter and FBitReader — bitstream serialization.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Ut99PubSrc/Core/Inc/UnBits.h
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FBitWriter.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
FBitWriter::FBitWriter( INT InMaxBits )
:	Num( 0 )
,	Max( InMaxBits )
{
	Buffer.Add( (InMaxBits + 7) >> 3 );
	appMemzero( &Buffer(0), Buffer.Num() );
	ArIsSaving = 1;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::SerializeBits( void* Src, INT LengthBits )
{
	if( Num + LengthBits > Max )
	{
		SetOverflowed();
		return;
	}
	for( INT i=0; i<LengthBits; i++ )
		WriteBit( ((BYTE*)Src)[i>>3] & GShift[i&7] ? 1 : 0 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::SerializeInt( DWORD& Value, DWORD Max )
{
	WriteInt( Value, Max );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::WriteInt( DWORD Result, DWORD ValueMax )
{
	check(ValueMax>=2);
	DWORD NewValue = 0;
	for( DWORD Mask=1; NewValue+Mask<ValueMax && Mask; Mask*=2 )
		WriteBit( (Result&Mask) ? 1 : 0 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::WriteBit( BYTE In )
{
	if( Num >= Max )
	{
		SetOverflowed();
		return;
	}
	Buffer(Num>>3) |= In << (Num&7);
	Num++;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::Serialize( void* Src, INT LengthBytes )
{
	SerializeBits( Src, LengthBytes*8 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
BYTE* FBitWriter::GetData()
{
	return &Buffer(0);
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
INT FBitWriter::GetNumBytes()
{
	return (Num+7)>>3;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
INT FBitWriter::GetNumBits()
{
	return Num;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriter::SetOverflowed()
{
	ArIsError = 1;
}

/*-----------------------------------------------------------------------------
	FBitWriterMark.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitWriterMark::Pop( FBitWriter& Writer )
{
	checkSlow(Num<=Writer.Num);
	Writer.ArIsError = Overflowed;
	Writer.Num       = Num;
}

/*-----------------------------------------------------------------------------
	FBitReader.
-----------------------------------------------------------------------------*/

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
FBitReader::FBitReader( BYTE* Src, INT CountBits )
:	Num( CountBits )
,	Pos( 0 )
{
	ArIsLoading = 1;
	if( Src )
	{
		INT ByteCount = (CountBits+7)>>3;
		Buffer.Add( ByteCount );
		if( ByteCount )
			appMemcpy( &Buffer(0), Src, ByteCount );
	}
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitReader::SetData( FBitReader& Src, INT CountBits )
{
	Num    = CountBits;
	Pos    = 0;
	ArIsError = 0;
	Buffer.Empty();
	INT ByteCount = (CountBits+7)>>3;
	Buffer.Add( ByteCount );
	if( ByteCount )
		appMemcpy( &Buffer(0), &Src.Buffer(0), ByteCount );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitReader::SerializeBits( void* Dest, INT LengthBits )
{
	appMemzero( Dest, (LengthBits+7)>>3 );
	for( INT i=0; i<LengthBits; i++ )
		if( ReadBit() )
			((BYTE*)Dest)[i>>3] |= GShift[i&7];
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitReader::SerializeInt( DWORD& Value, DWORD Max )
{
	Value = ReadInt( Max );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
DWORD FBitReader::ReadInt( DWORD Max )
{
	check(Max>=2);
	DWORD Value=0;
	for( DWORD Mask=1; Value+Mask<Max && Mask; Mask*=2 )
		if( ReadBit() )
			Value |= Mask;
	return Value;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
BYTE FBitReader::ReadBit()
{
	if( Pos >= Num )
	{
		SetOverflowed();
		return 0;
	}
	BYTE Bit = (Buffer(Pos>>3) >> (Pos&7)) & 1;
	Pos++;
	return Bit;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitReader::Serialize( void* Dest, INT LengthBytes )
{
	SerializeBits( Dest, LengthBytes*8 );
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
BYTE* FBitReader::GetData()
{
	return &Buffer(0);
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
UBOOL FBitReader::AtEnd()
{
	return ArIsError || Pos >= Num;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
void FBitReader::SetOverflowed()
{
	ArIsError = 1;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
INT FBitReader::GetNumBytes()
{
	return (Num+7)>>3;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
INT FBitReader::GetNumBits()
{
	return Num;
}

IMPL_APPROX("sdk/Ut99PubSrc/Core/Src/UnBits.cpp")
INT FBitReader::GetPosBits()
{
	return Pos;
}

/*-----------------------------------------------------------------------------
	FBitReader implicit special members — force emission.
	The copy ctor and operator= are implicitly declared but must be
	exported (CORE_API on the struct).  MSVC only emits them when used.
-----------------------------------------------------------------------------*/
IMPL_APPROX("link-time emission helper for FBitReader special members")
void _ForceFBitReaderEmit() {
	FBitReader a;
	FBitReader b(a);
	a = b;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
