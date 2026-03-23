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

IMPL_MATCH("Core.dll", 0x10113bf0)
FBitWriter::FBitWriter( INT InMaxBits )
:	Num( 0 )
,	Max( InMaxBits )
{
	Buffer.Add( (InMaxBits + 7) >> 3 );
	appMemzero( &Buffer(0), Buffer.Num() );
	ArIsSaving = 1;
}

IMPL_MATCH("Core.dll", 0x10113820)
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

IMPL_MATCH("Core.dll", 0x101138F0)
void FBitWriter::SerializeInt( DWORD& Value, DWORD Max )
{
	WriteInt( Value, Max );
}

IMPL_MATCH("Core.dll", 0x10113970)
void FBitWriter::WriteInt( DWORD Result, DWORD ValueMax )
{
	check(ValueMax>=2);
	DWORD NewValue = 0;
	for( DWORD Mask=1; NewValue+Mask<ValueMax && Mask; Mask*=2 )
		WriteBit( (Result&Mask) ? 1 : 0 );
}

IMPL_MATCH("Core.dll", 0x101139F0)
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

IMPL_MATCH("Core.dll", 0x101138A0)
void FBitWriter::Serialize( void* Src, INT LengthBytes )
{
	SerializeBits( Src, LengthBytes*8 );
}

IMPL_MATCH("Core.dll", 0x10113a40)
BYTE* FBitWriter::GetData()
{
	return &Buffer(0);
}

IMPL_MATCH("Core.dll", 0x101134b0)
INT FBitWriter::GetNumBytes()
{
	return (Num+7)>>3;
}

IMPL_MATCH("Core.dll", 0x101134c0)
INT FBitWriter::GetNumBits()
{
	return Num;
}

IMPL_MATCH("Core.dll", 0x101134d0)
void FBitWriter::SetOverflowed()
{
	ArIsError = 1;
}

/*-----------------------------------------------------------------------------
	FBitWriterMark.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10113A50)
void FBitWriterMark::Pop( FBitWriter& Writer )
{
	checkSlow(Num<=Writer.Num);
	Writer.ArIsError = Overflowed;
	Writer.Num       = Num;
}

/*-----------------------------------------------------------------------------
	FBitReader.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10113ce0)
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

IMPL_MATCH("Core.dll", 0x10113DF0)
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

IMPL_MATCH("Core.dll", 0x10113AD0)
void FBitReader::SerializeBits( void* Dest, INT LengthBits )
{
	appMemzero( Dest, (LengthBits+7)>>3 );
	for( INT i=0; i<LengthBits; i++ )
		if( ReadBit() )
			((BYTE*)Dest)[i>>3] |= GShift[i&7];
}

IMPL_MATCH("Core.dll", 0x10113B70)
void FBitReader::SerializeInt( DWORD& Value, DWORD Max )
{
	Value = ReadInt( Max );
}

IMPL_MATCH("Core.dll", 0x101134E0)
DWORD FBitReader::ReadInt( DWORD Max )
{
	check(Max>=2);
	DWORD Value=0;
	for( DWORD Mask=1; Value+Mask<Max && Mask; Mask*=2 )
		if( ReadBit() )
			Value |= Mask;
	return Value;
}

IMPL_MATCH("Core.dll", 0x10113500)
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

IMPL_MATCH("Core.dll", 0x10113520)
void FBitReader::Serialize( void* Dest, INT LengthBytes )
{
	SerializeBits( Dest, LengthBytes*8 );
}

IMPL_MATCH("Core.dll", 0x10113be0)
BYTE* FBitReader::GetData()
{
	return &Buffer(0);
}

IMPL_MATCH("Core.dll", 0x10113530)
UBOOL FBitReader::AtEnd()
{
	return ArIsError || Pos >= Num;
}

IMPL_MATCH("Core.dll", 0x10113550)
void FBitReader::SetOverflowed()
{
	ArIsError = 1;
}

IMPL_MATCH("Core.dll", 0x10113560)
INT FBitReader::GetNumBytes()
{
	return (Num+7)>>3;
}

IMPL_MATCH("Core.dll", 0x10113570)
INT FBitReader::GetNumBits()
{
	return Num;
}

IMPL_MATCH("Core.dll", 0x10113580)
INT FBitReader::GetPosBits()
{
	return Pos;
}

/*-----------------------------------------------------------------------------
	FBitReader implicit special members — force emission.
	The copy ctor and operator= are implicitly declared but must be
	exported (CORE_API on the struct).  MSVC only emits them when used.
-----------------------------------------------------------------------------*/
IMPL_DIVERGE("Free function or static; not a class method in Core.dll export")
void _ForceFBitReaderEmit() {
	FBitReader a;
	FBitReader b(a);
	a = b;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
