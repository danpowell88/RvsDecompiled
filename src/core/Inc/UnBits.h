/*=============================================================================
	UnBits.h: Unreal bitstream manipulation classes.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Local override for Ravenshield Core build.
	Removes C++11 move-delete declarations that weren't in the original
	MSVC 7.1 source — they suppress the implicit copy ctor/operator=
	which the retail Core.dll does export.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*-----------------------------------------------------------------------------
	FBitWriter.
-----------------------------------------------------------------------------*/

//
// Writes bitstreams.
//
struct CORE_API FBitWriter : public FArchive
{
	friend struct FBitWriterMark;
public:
	FBitWriter( INT InMaxBits );
	void SerializeBits( void* Src, INT LengthBits );
	void SerializeInt( DWORD& Value, DWORD Max );
	void WriteInt( DWORD Result, DWORD Max );
	void WriteBit( BYTE In );
	void Serialize( void* Src, INT LengthBytes );
	BYTE* GetData();
	INT GetNumBytes();
	INT GetNumBits();
	void SetOverflowed();
private:
	TArray<BYTE> Buffer;
	INT   Num;
	INT   Max;
};

//
// For pushing and popping FBitWriter positions.
//
struct CORE_API FBitWriterMark
{
public:
	FBitWriterMark()
	:	Num         ( 0 )
	{}
	FBitWriterMark( FBitWriter& Writer )
	:	Overflowed	( Writer.ArIsError )
	,	Num			( Writer.Num )
	{}
	INT GetNumBits()
	{
		return Num;
	}
	void Pop( FBitWriter& Writer );
private:
	UBOOL			Overflowed;
	INT				Num;
};

/*-----------------------------------------------------------------------------
	FBitReader.
-----------------------------------------------------------------------------*/

//
// Reads bitstreams.
//
struct CORE_API FBitReader : public FArchive
{
public:
	FBitReader( BYTE* Src=NULL, INT CountBits=0 );
	void SetData( FBitReader& Src, INT CountBits );
	void SerializeBits( void* Dest, INT LengthBits );
	void SerializeInt( DWORD& Value, DWORD Max );
	DWORD ReadInt( DWORD Max );
	BYTE ReadBit();
	void Serialize( void* Dest, INT LengthBytes );
	BYTE* GetData();
	UBOOL AtEnd();
	void SetOverflowed();
	INT GetNumBytes();
	INT GetNumBits();
	INT GetPosBits();
private:
	TArray<BYTE> Buffer;
	INT   Num;
	INT   Pos;
};

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
