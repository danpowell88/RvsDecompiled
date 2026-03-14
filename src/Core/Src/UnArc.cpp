/*=============================================================================
	UnArc.cpp: FArchive serialization helpers — FCompactIndex and FTime.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FCompactIndex — compact variable-length integer encoding.

	Encoding scheme:
		Byte 0:  6 data bits + sign bit (bit 7) + continuation bit (bit 6)
		Byte 1+: 7 data bits + continuation bit (bit 7)

	This encodes small values in 1 byte, up to ~16K in 2 bytes, and
	larger values in up to 5 bytes.
-----------------------------------------------------------------------------*/

CORE_API FArchive& operator<<( FArchive& Ar, FCompactIndex& I )
{
	if( Ar.IsLoading() )
	{
		BYTE B;
		Ar << B;
		INT Negative = (B & 0x80);
		INT Value    = B & 0x3F;
		if( B & 0x40 )
		{
			Ar << B;
			Value |= (INT)(B & 0x7F) << 6;
			if( B & 0x80 )
			{
				Ar << B;
				Value |= (INT)(B & 0x7F) << 13;
				if( B & 0x80 )
				{
					Ar << B;
					Value |= (INT)(B & 0x7F) << 20;
					if( B & 0x80 )
					{
						Ar << B;
						Value |= (INT)(B & 0x3F) << 27;
					}
				}
			}
		}
		I.Value = Negative ? -Value : Value;
	}
	else
	{
		DWORD V = Abs( I.Value );
		BYTE B0 = ((I.Value < 0) ? 0x80 : 0) | (V & 0x3F);
		if( V <= 0x3F )
		{
			Ar << B0;
		}
		else
		{
			B0 |= 0x40;
			Ar << B0;
			V >>= 6;
			BYTE B1 = V & 0x7F;
			if( V <= 0x7F )
			{
				Ar << B1;
			}
			else
			{
				B1 |= 0x80;
				Ar << B1;
				V >>= 7;
				BYTE B2 = V & 0x7F;
				if( V <= 0x7F )
				{
					Ar << B2;
				}
				else
				{
					B2 |= 0x80;
					Ar << B2;
					V >>= 7;
					BYTE B3 = V & 0x7F;
					if( V <= 0x7F )
					{
						Ar << B3;
					}
					else
					{
						B3 |= 0x80;
						Ar << B3;
						V >>= 7;
						BYTE B4 = V & 0x3F;
						Ar << B4;
					}
				}
			}
		}
	}
	return Ar;
}

/*-----------------------------------------------------------------------------
	FTime — double-precision time value.
-----------------------------------------------------------------------------*/

CORE_API FArchive& operator<<( FArchive& Ar, FTime& F )
{
	return Ar.ByteOrderSerialize( &F, sizeof(F) );
}

/*-----------------------------------------------------------------------------
	FArchiveCountMem class.
-----------------------------------------------------------------------------*/

FArchiveCountMem::FArchiveCountMem( UObject* Src )
: Num(0), Max(0)
{
	guard(FArchiveCountMem::FArchiveCountMem);
	if( Src )
		Src->Serialize( *this );
	unguard;
}

FArchiveCountMem::FArchiveCountMem( const FArchiveCountMem& Other )
: FArchive(Other), Num(Other.Num), Max(Other.Max)
{
}

FArchiveCountMem::~FArchiveCountMem()
{
}

void FArchiveCountMem::CountBytes( SIZE_T InNum, SIZE_T InMax )
{
	Num += InNum;
	Max += InMax;
}

DWORD FArchiveCountMem::GetNum()
{
	return (DWORD)Num;
}

DWORD FArchiveCountMem::GetMax()
{
	return (DWORD)Max;
}

FArchiveCountMem& FArchiveCountMem::operator=( const FArchiveCountMem& Other )
{
	Num = Other.Num;
	Max = Other.Max;
	return *this;
}

/*-----------------------------------------------------------------------------
	FArchiveDummySave class.
-----------------------------------------------------------------------------*/

FArchiveDummySave::FArchiveDummySave()
{
	ArIsSaving = 1;
}

FArchiveDummySave::FArchiveDummySave( const FArchiveDummySave& Other )
: FArchive(Other)
{
}

FArchiveDummySave::~FArchiveDummySave()
{
}

FArchiveDummySave& FArchiveDummySave::operator=( const FArchiveDummySave& Other )
{
	return *this;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
