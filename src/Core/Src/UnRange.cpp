/*=============================================================================
	UnRange.cpp: FRange and FRangeVector — ranged value types.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	Reference: sdk/Raven_Shield_C_SDK/inc/CoreClasses.h L278, L486
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FRange.
-----------------------------------------------------------------------------*/

FRange::FRange()
:	Min( 0.f )
,	Max( 0.f )
{
}

FRange::FRange( FLOAT InVal )
:	Min( InVal )
,	Max( InVal )
{
}

FRange::FRange( FLOAT InMin, FLOAT InMax )
:	Min( InMin < InMax ? InMin : InMax )
,	Max( InMin < InMax ? InMax : InMin )
{
	// Ghidra 0x94b0: sorts inputs so Min <= Max.
}

FLOAT FRange::GetCenter() const
{
	return (Min + Max) * 0.5f;
}

FLOAT FRange::GetMax() const
{
	return Max;
}

FLOAT FRange::GetMin() const
{
	return Min;
}

FLOAT FRange::GetRand() const
{
	return Min + (Max - Min) * appFrand();
}

FLOAT FRange::GetSRand() const
{
	return Min + (Max - Min) * appSRand();
}

FLOAT FRange::Size() const
{
	return Max - Min;
}

INT FRange::Booleanize()
{
	return Min != 0.f || Max != 0.f;
}

FLOAT& FRange::Component( INT Index )
{
	return Index == 0 ? Min : Max;
}

FRange FRange::GridSnap( const FRange& Grid )
{
	return FRange(
		appFloor(Min / Grid.Min + 0.5f) * Grid.Min,
		appFloor(Max / Grid.Max + 0.5f) * Grid.Max
	);
}

INT FRange::IsNearlyZero() const
{
	return Abs(Min) < KINDA_SMALL_NUMBER && Abs(Max) < KINDA_SMALL_NUMBER;
}

INT FRange::IsZero() const
{
	return Min == 0.f && Max == 0.f;
}

FRange FRange::operator+( const FRange& R ) const
{
	return FRange( Min + R.Min, Max + R.Max );
}

FRange FRange::operator+( FLOAT F ) const
{
	return FRange( Min + F, Max + F );
}

FRange FRange::operator-( const FRange& R ) const
{
	return FRange( Min - R.Min, Max - R.Max );
}

FRange FRange::operator-( FLOAT F ) const
{
	return FRange( Min - F, Max - F );
}

FRange FRange::operator-() const
{
	return FRange( -Min, -Max );
}

FRange FRange::operator*( const FRange& R ) const
{
	return FRange( Min * R.Min, Max * R.Max );
}

FRange FRange::operator*( FLOAT F ) const
{
	return FRange( Min * F, Max * F );
}

FRange FRange::operator/( FLOAT F ) const
{
	FLOAT Inv = 1.f / F;
	return FRange( Min * Inv, Max * Inv );
}

FRange FRange::operator+=( const FRange& R )
{
	Min += R.Min;
	Max += R.Max;
	return *this;
}

FRange FRange::operator+=( FLOAT F )
{
	Min += F;
	Max += F;
	return *this;
}

FRange FRange::operator-=( const FRange& R )
{
	Min -= R.Min;
	Max -= R.Max;
	return *this;
}

FRange FRange::operator-=( FLOAT F )
{
	Min -= F;
	Max -= F;
	return *this;
}

FRange FRange::operator*=( const FRange& R )
{
	Min *= R.Min;
	Max *= R.Max;
	return *this;
}

FRange FRange::operator*=( FLOAT F )
{
	Min *= F;
	Max *= F;
	return *this;
}

FRange FRange::operator/=( const FRange& R )
{
	Min /= R.Min;
	Max /= R.Max;
	return *this;
}

FRange FRange::operator/=( FLOAT F )
{
	FLOAT Inv = 1.f / F;
	Min *= Inv;
	Max *= Inv;
	return *this;
}

INT FRange::operator==( const FRange& R ) const
{
	return Min == R.Min && Max == R.Max;
}

INT FRange::operator!=( const FRange& R ) const
{
	return Min != R.Min || Max != R.Max;
}

FRange& FRange::operator=( const FRange& R )
{
	Min = R.Min;
	Max = R.Max;
	return *this;
}

/*-----------------------------------------------------------------------------
	FRangeVector.
-----------------------------------------------------------------------------*/

FRangeVector::FRangeVector()
{
}

FRangeVector::FRangeVector( FRange InX, FRange InY, FRange InZ )
:	X( InX )
,	Y( InY )
,	Z( InZ )
{
}

FRangeVector::FRangeVector( FVector V )
:	X( V.X )
,	Y( V.Y )
,	Z( V.Z )
{
}

FVector FRangeVector::GetCenter() const
{
	return FVector( X.GetCenter(), Y.GetCenter(), Z.GetCenter() );
}

FVector FRangeVector::GetMax() const
{
	return FVector( X.GetMax(), Y.GetMax(), Z.GetMax() );
}

FVector FRangeVector::GetRand() const
{
	return FVector( X.GetRand(), Y.GetRand(), Z.GetRand() );
}

FVector FRangeVector::GetSRand() const
{
	return FVector( X.GetSRand(), Y.GetSRand(), Z.GetSRand() );
}

FRange& FRangeVector::Component( INT Index )
{
	switch( Index )
	{
		case 0:  return X;
		case 1:  return Y;
		default: return Z;
	}
}

FRangeVector FRangeVector::GridSnap( const FRangeVector& Grid )
{
	return FRangeVector( X.GridSnap(Grid.X), Y.GridSnap(Grid.Y), Z.GridSnap(Grid.Z) );
}

INT FRangeVector::IsNearlyZero() const
{
	return X.IsNearlyZero() && Y.IsNearlyZero() && Z.IsNearlyZero();
}

INT FRangeVector::IsZero() const
{
	return X.IsZero() && Y.IsZero() && Z.IsZero();
}

FRangeVector FRangeVector::operator+( const FRangeVector& R ) const
{
	return FRangeVector( X+R.X, Y+R.Y, Z+R.Z );
}

FRangeVector FRangeVector::operator+( const FVector& V ) const
{
	return FRangeVector( X+V.X, Y+V.Y, Z+V.Z );
}

FRangeVector FRangeVector::operator-( const FRangeVector& R ) const
{
	return FRangeVector( X-R.X, Y-R.Y, Z-R.Z );
}

FRangeVector FRangeVector::operator-( const FVector& V ) const
{
	return FRangeVector( X-V.X, Y-V.Y, Z-V.Z );
}

FRangeVector FRangeVector::operator-() const
{
	return FRangeVector( -X, -Y, -Z );
}

FRangeVector FRangeVector::operator*( const FRangeVector& R ) const
{
	return FRangeVector( X*R.X, Y*R.Y, Z*R.Z );
}

FRangeVector FRangeVector::operator*( FLOAT F ) const
{
	return FRangeVector( X*F, Y*F, Z*F );
}

FRangeVector FRangeVector::operator/( FLOAT F ) const
{
	return FRangeVector( X/F, Y/F, Z/F );
}

FRangeVector FRangeVector::operator+=( const FRangeVector& R )
{
	X += R.X; Y += R.Y; Z += R.Z;
	return *this;
}

FRangeVector FRangeVector::operator+=( const FVector& V )
{
	X += V.X; Y += V.Y; Z += V.Z;
	return *this;
}

FRangeVector FRangeVector::operator-=( const FRangeVector& R )
{
	X -= R.X; Y -= R.Y; Z -= R.Z;
	return *this;
}

FRangeVector FRangeVector::operator-=( const FVector& V )
{
	X -= V.X; Y -= V.Y; Z -= V.Z;
	return *this;
}

FRangeVector FRangeVector::operator*=( const FRangeVector& R )
{
	X *= R.X; Y *= R.Y; Z *= R.Z;
	return *this;
}

FRangeVector FRangeVector::operator*=( FLOAT F )
{
	X *= F; Y *= F; Z *= F;
	return *this;
}

FRangeVector FRangeVector::operator/=( const FRangeVector& R )
{
	X /= R.X; Y /= R.Y; Z /= R.Z;
	return *this;
}

FRangeVector FRangeVector::operator/=( FLOAT F )
{
	X /= F; Y /= F; Z /= F;
	return *this;
}

INT FRangeVector::operator==( const FRangeVector& R ) const
{
	return X==R.X && Y==R.Y && Z==R.Z;
}

INT FRangeVector::operator!=( const FRangeVector& R ) const
{
	return X!=R.X || Y!=R.Y || Z!=R.Z;
}

FRangeVector& FRangeVector::operator=( const FRangeVector& R )
{
	X = R.X;
	Y = R.Y;
	Z = R.Z;
	return *this;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
