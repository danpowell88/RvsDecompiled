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

FBitWriter::FBitWriter( INT InMaxBits )
:	Num( 0 )
,	Max( InMaxBits )
{
	Buffer.Add( (InMaxBits + 7) >> 3 );
	appMemzero( &Buffer(0), Buffer.Num() );
	ArIsSaving = 1;
}

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

void FBitWriter::SerializeInt( DWORD& Value, DWORD Max )
{
	WriteInt( Value, Max );
}

void FBitWriter::WriteInt( DWORD Result, DWORD ValueMax )
{
	check(ValueMax>=2);
	DWORD NewValue = 0;
	for( DWORD Mask=1; NewValue+Mask<ValueMax && Mask; Mask*=2 )
		WriteBit( (Result&Mask) ? 1 : 0 );
}

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

void FBitWriter::Serialize( void* Src, INT LengthBytes )
{
	SerializeBits( Src, LengthBytes*8 );
}

BYTE* FBitWriter::GetData()
{
	return &Buffer(0);
}

INT FBitWriter::GetNumBytes()
{
	return (Num+7)>>3;
}

INT FBitWriter::GetNumBits()
{
	return Num;
}

void FBitWriter::SetOverflowed()
{
	ArIsError = 1;
}

/*-----------------------------------------------------------------------------
	FBitWriterMark.
-----------------------------------------------------------------------------*/

void FBitWriterMark::Pop( FBitWriter& Writer )
{
	checkSlow(Num<=Writer.Num);
	Writer.ArIsError = Overflowed;
	Writer.Num       = Num;
}

/*-----------------------------------------------------------------------------
	FBitReader.
-----------------------------------------------------------------------------*/

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

void FBitReader::SerializeBits( void* Dest, INT LengthBits )
{
	appMemzero( Dest, (LengthBits+7)>>3 );
	for( INT i=0; i<LengthBits; i++ )
		if( ReadBit() )
			((BYTE*)Dest)[i>>3] |= GShift[i&7];
}

void FBitReader::SerializeInt( DWORD& Value, DWORD Max )
{
	Value = ReadInt( Max );
}

DWORD FBitReader::ReadInt( DWORD Max )
{
	check(Max>=2);
	DWORD Value=0;
	for( DWORD Mask=1; Value+Mask<Max && Mask; Mask*=2 )
		if( ReadBit() )
			Value |= Mask;
	return Value;
}

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

void FBitReader::Serialize( void* Dest, INT LengthBytes )
{
	SerializeBits( Dest, LengthBytes*8 );
}

BYTE* FBitReader::GetData()
{
	return &Buffer(0);
}

UBOOL FBitReader::AtEnd()
{
	return ArIsError || Pos >= Num;
}

void FBitReader::SetOverflowed()
{
	ArIsError = 1;
}

INT FBitReader::GetNumBytes()
{
	return (Num+7)>>3;
}

INT FBitReader::GetNumBits()
{
	return Num;
}

INT FBitReader::GetPosBits()
{
	return Pos;
}

/*-----------------------------------------------------------------------------
	FBitReader implicit special members — force emission.
	The copy ctor and operator= are implicitly declared but must be
	exported (CORE_API on the struct).  MSVC only emits them when used.
-----------------------------------------------------------------------------*/
void _ForceFBitReaderEmit() {
	FBitReader a;
	FBitReader b(a);
	a = b;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
