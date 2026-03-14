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

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange::FRange()
:	Min( 0.f )
,	Max( 0.f )
{
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange::FRange( FLOAT InVal )
:	Min( InVal )
,	Max( InVal )
{
}

IMPL_MATCH("Core.dll", 0x94b0)
FRange::FRange( FLOAT InMin, FLOAT InMax )
:	Min( InMin < InMax ? InMin : InMax )
,	Max( InMin < InMax ? InMax : InMin )
{
	// Ghidra 0x94b0: sorts inputs so Min <= Max.
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::GetCenter() const
{
	return (Min + Max) * 0.5f;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::GetMax() const
{
	return Max;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::GetMin() const
{
	return Min;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::GetRand() const
{
	return Min + (Max - Min) * appFrand();
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::GetSRand() const
{
	return Min + (Max - Min) * appSRand();
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT FRange::Size() const
{
	return Max - Min;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
INT FRange::Booleanize()
{
	return Min != 0.f || Max != 0.f;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FLOAT& FRange::Component( INT Index )
{
	return Index == 0 ? Min : Max;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::GridSnap( const FRange& Grid )
{
	return FRange(
		appFloor(Min / Grid.Min + 0.5f) * Grid.Min,
		appFloor(Max / Grid.Max + 0.5f) * Grid.Max
	);
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
INT FRange::IsNearlyZero() const
{
	return Abs(Min) < KINDA_SMALL_NUMBER && Abs(Max) < KINDA_SMALL_NUMBER;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
INT FRange::IsZero() const
{
	return Min == 0.f && Max == 0.f;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator+( const FRange& R ) const
{
	return FRange( Min + R.Min, Max + R.Max );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator+( FLOAT F ) const
{
	return FRange( Min + F, Max + F );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator-( const FRange& R ) const
{
	return FRange( Min - R.Min, Max - R.Max );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator-( FLOAT F ) const
{
	return FRange( Min - F, Max - F );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator-() const
{
	return FRange( -Min, -Max );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator*( const FRange& R ) const
{
	return FRange( Min * R.Min, Max * R.Max );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator*( FLOAT F ) const
{
	return FRange( Min * F, Max * F );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator/( FLOAT F ) const
{
	FLOAT Inv = 1.f / F;
	return FRange( Min * Inv, Max * Inv );
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator+=( const FRange& R )
{
	Min += R.Min;
	Max += R.Max;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator+=( FLOAT F )
{
	Min += F;
	Max += F;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator-=( const FRange& R )
{
	Min -= R.Min;
	Max -= R.Max;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator-=( FLOAT F )
{
	Min -= F;
	Max -= F;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator*=( const FRange& R )
{
	Min *= R.Min;
	Max *= R.Max;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator*=( FLOAT F )
{
	Min *= F;
	Max *= F;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator/=( const FRange& R )
{
	Min /= R.Min;
	Max /= R.Max;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange FRange::operator/=( FLOAT F )
{
	FLOAT Inv = 1.f / F;
	Min *= Inv;
	Max *= Inv;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
INT FRange::operator==( const FRange& R ) const
{
	return Min == R.Min && Max == R.Max;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
INT FRange::operator!=( const FRange& R ) const
{
	return Min != R.Min || Max != R.Max;
}

IMPL_APPROX("Ravenshield-specific FRange type; reconstructed from context")
FRange& FRange::operator=( const FRange& R )
{
	Min = R.Min;
	Max = R.Max;
	return *this;
}

/*-----------------------------------------------------------------------------
	FRangeVector.
-----------------------------------------------------------------------------*/

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector::FRangeVector()
{
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector::FRangeVector( FRange InX, FRange InY, FRange InZ )
:	X( InX )
,	Y( InY )
,	Z( InZ )
{
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector::FRangeVector( FVector V )
:	X( V.X )
,	Y( V.Y )
,	Z( V.Z )
{
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FVector FRangeVector::GetCenter() const
{
	return FVector( X.GetCenter(), Y.GetCenter(), Z.GetCenter() );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FVector FRangeVector::GetMax() const
{
	return FVector( X.GetMax(), Y.GetMax(), Z.GetMax() );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FVector FRangeVector::GetRand() const
{
	return FVector( X.GetRand(), Y.GetRand(), Z.GetRand() );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FVector FRangeVector::GetSRand() const
{
	return FVector( X.GetSRand(), Y.GetSRand(), Z.GetSRand() );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRange& FRangeVector::Component( INT Index )
{
	switch( Index )
	{
		case 0:  return X;
		case 1:  return Y;
		default: return Z;
	}
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::GridSnap( const FRangeVector& Grid )
{
	return FRangeVector( X.GridSnap(Grid.X), Y.GridSnap(Grid.Y), Z.GridSnap(Grid.Z) );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
INT FRangeVector::IsNearlyZero() const
{
	return X.IsNearlyZero() && Y.IsNearlyZero() && Z.IsNearlyZero();
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
INT FRangeVector::IsZero() const
{
	return X.IsZero() && Y.IsZero() && Z.IsZero();
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator+( const FRangeVector& R ) const
{
	return FRangeVector( X+R.X, Y+R.Y, Z+R.Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator+( const FVector& V ) const
{
	return FRangeVector( X+V.X, Y+V.Y, Z+V.Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator-( const FRangeVector& R ) const
{
	return FRangeVector( X-R.X, Y-R.Y, Z-R.Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator-( const FVector& V ) const
{
	return FRangeVector( X-V.X, Y-V.Y, Z-V.Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator-() const
{
	return FRangeVector( -X, -Y, -Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator*( const FRangeVector& R ) const
{
	return FRangeVector( X*R.X, Y*R.Y, Z*R.Z );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator*( FLOAT F ) const
{
	return FRangeVector( X*F, Y*F, Z*F );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator/( FLOAT F ) const
{
	return FRangeVector( X/F, Y/F, Z/F );
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator+=( const FRangeVector& R )
{
	X += R.X; Y += R.Y; Z += R.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator+=( const FVector& V )
{
	X += V.X; Y += V.Y; Z += V.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator-=( const FRangeVector& R )
{
	X -= R.X; Y -= R.Y; Z -= R.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator-=( const FVector& V )
{
	X -= V.X; Y -= V.Y; Z -= V.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator*=( const FRangeVector& R )
{
	X *= R.X; Y *= R.Y; Z *= R.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator*=( FLOAT F )
{
	X *= F; Y *= F; Z *= F;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator/=( const FRangeVector& R )
{
	X /= R.X; Y /= R.Y; Z /= R.Z;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
FRangeVector FRangeVector::operator/=( FLOAT F )
{
	X /= F; Y /= F; Z /= F;
	return *this;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
INT FRangeVector::operator==( const FRangeVector& R ) const
{
	return X==R.X && Y==R.Y && Z==R.Z;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
INT FRangeVector::operator!=( const FRangeVector& R ) const
{
	return X!=R.X || Y!=R.Y || Z!=R.Z;
}

IMPL_APPROX("Ravenshield-specific FRangeVector type; reconstructed from context")
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
