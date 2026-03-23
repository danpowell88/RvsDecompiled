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

IMPL_MATCH("Core.dll", 0x101094b0)
FRange::FRange()
:	Min( 0.f )
,	Max( 0.f )
{
}

IMPL_MATCH("Core.dll", 0x101094B0)
FRange::FRange( FLOAT InVal )
:	Min( InVal )
,	Max( InVal )
{
}

IMPL_MATCH("Core.dll", 0x101094b0)
FRange::FRange( FLOAT InMin, FLOAT InMax )
:	Min( InMin < InMax ? InMin : InMax )
,	Max( InMin < InMax ? InMax : InMin )
{
	// Ghidra 0x94b0: sorts inputs so Min <= Max.
}

IMPL_MATCH("Core.dll", 0x101046E0)
FLOAT FRange::GetCenter() const
{
	return (Min + Max) * 0.5f;
}

IMPL_MATCH("Core.dll", 0x10109710)
FLOAT FRange::GetMax() const
{
	return Max;
}

IMPL_MATCH("Core.dll", 0x10109730)
FLOAT FRange::GetMin() const
{
	return Min;
}

IMPL_MATCH("Core.dll", 0x101046F0)
FLOAT FRange::GetRand() const
{
	return Min + (Max - Min) * appFrand();
}

IMPL_MATCH("Core.dll", 0x10104710)
FLOAT FRange::GetSRand() const
{
	return Min + (Max - Min) * appSRand();
}

IMPL_MATCH("Core.dll", 0x10109750)
FLOAT FRange::Size() const
{
	return Max - Min;
}

IMPL_MATCH("Core.dll", 0x10104770)
INT FRange::Booleanize()
{
	return Min != 0.f || Max != 0.f;
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10104760 size 10 bytes")
FLOAT& FRange::Component( INT Index )
{
	return Index == 0 ? Min : Max;
}

IMPL_MATCH("Core.dll", 0x101097E0)
FRange FRange::GridSnap( const FRange& Grid )
{
	return FRange(
		appFloor(Min / Grid.Min + 0.5f) * Grid.Min,
		appFloor(Max / Grid.Max + 0.5f) * Grid.Max
	);
}

IMPL_MATCH("Core.dll", 0x10109790)
INT FRange::IsNearlyZero() const
{
	return Abs(Min) < KINDA_SMALL_NUMBER && Abs(Max) < KINDA_SMALL_NUMBER;
}

IMPL_MATCH("Core.dll", 0x10104730)
INT FRange::IsZero() const
{
	return Min == 0.f && Max == 0.f;
}

IMPL_MATCH("Core.dll", 0x10109500)
FRange FRange::operator+( const FRange& R ) const
{
	return FRange( Min + R.Min, Max + R.Max );
}

IMPL_MATCH("Core.dll", 0x10109540)
FRange FRange::operator+( FLOAT F ) const
{
	return FRange( Min + F, Max + F );
}

IMPL_MATCH("Core.dll", 0x101095c0)
FRange FRange::operator-( const FRange& R ) const
{
	return FRange( Min - R.Min, Max - R.Max );
}

IMPL_MATCH("Core.dll", 0x10109580)
FRange FRange::operator-( FLOAT F ) const
{
	return FRange( Min - F, Max - F );
}

IMPL_MATCH("Core.dll", 0x101096d0)
FRange FRange::operator-() const
{
	return FRange( -Min, -Max );
}

IMPL_MATCH("Core.dll", 0x10109690)
FRange FRange::operator*( const FRange& R ) const
{
	return FRange( Min * R.Min, Max * R.Max );
}

IMPL_MATCH("Core.dll", 0x10109600)
FRange FRange::operator*( FLOAT F ) const
{
	return FRange( Min * F, Max * F );
}

IMPL_MATCH("Core.dll", 0x10109640)
FRange FRange::operator/( FLOAT F ) const
{
	FLOAT Inv = 1.f / F;
	return FRange( Min * Inv, Max * Inv );
}

IMPL_MATCH("Core.dll", 0x10104560)
FRange FRange::operator+=( const FRange& R )
{
	Min += R.Min;
	Max += R.Max;
	return *this;
}

IMPL_MATCH("Core.dll", 0x101045c0)
FRange FRange::operator+=( FLOAT F )
{
	Min += F;
	Max += F;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104590)
FRange FRange::operator-=( const FRange& R )
{
	Min -= R.Min;
	Max -= R.Max;
	return *this;
}

IMPL_MATCH("Core.dll", 0x101045f0)
FRange FRange::operator-=( FLOAT F )
{
	Min -= F;
	Max -= F;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104680)
FRange FRange::operator*=( const FRange& R )
{
	Min *= R.Min;
	Max *= R.Max;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104620)
FRange FRange::operator*=( FLOAT F )
{
	Min *= F;
	Max *= F;
	return *this;
}

IMPL_MATCH("Core.dll", 0x101046b0)
FRange FRange::operator/=( const FRange& R )
{
	Min /= R.Min;
	Max /= R.Max;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104650)
FRange FRange::operator/=( FLOAT F )
{
	FLOAT Inv = 1.f / F;
	Min *= Inv;
	Max *= Inv;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10105150)
INT FRange::operator==( const FRange& R ) const
{
	return Min == R.Min && Max == R.Max;
}

IMPL_MATCH("Core.dll", 0x10104530)
INT FRange::operator!=( const FRange& R ) const
{
	return Min != R.Min || Max != R.Max;
}

IMPL_MATCH("Core.dll", 0x10101ca0)
FRange& FRange::operator=( const FRange& R )
{
	Min = R.Min;
	Max = R.Max;
	return *this;
}

/*-----------------------------------------------------------------------------
	FRangeVector.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x0x101047e0)
FRangeVector::FRangeVector()
{
}

IMPL_MATCH("Core.dll", 0x101047E0)
FRangeVector::FRangeVector( FRange InX, FRange InY, FRange InZ )
:	X( InX )
,	Y( InY )
,	Z( InZ )
{
}

IMPL_MATCH("Core.dll", 0x101047E0)
FRangeVector::FRangeVector( FVector V )
:	X( V.X )
,	Y( V.Y )
,	Z( V.Z )
{
}

IMPL_MATCH("Core.dll", 0x10104C70)
FVector FRangeVector::GetCenter() const
{
	return FVector( X.GetCenter(), Y.GetCenter(), Z.GetCenter() );
}

IMPL_MATCH("Core.dll", 0x1010A060)
FVector FRangeVector::GetMax() const
{
	return FVector( X.GetMax(), Y.GetMax(), Z.GetMax() );
}

IMPL_MATCH("Core.dll", 0x10104CB0)
FVector FRangeVector::GetRand() const
{
	return FVector( X.GetRand(), Y.GetRand(), Z.GetRand() );
}

IMPL_MATCH("Core.dll", 0x10104D10)
FVector FRangeVector::GetSRand() const
{
	return FVector( X.GetSRand(), Y.GetSRand(), Z.GetSRand() );
}

IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x10104DF0 size 10 bytes")
FRange& FRangeVector::Component( INT Index )
{
	switch( Index )
	{
		case 0:  return X;
		case 1:  return Y;
		default: return Z;
	}
}

IMPL_MATCH("Core.dll", 0x1010A130)
FRangeVector FRangeVector::GridSnap( const FRangeVector& Grid )
{
	return FRangeVector( X.GridSnap(Grid.X), Y.GridSnap(Grid.Y), Z.GridSnap(Grid.Z) );
}

IMPL_MATCH("Core.dll", 0x1010A0C0)
INT FRangeVector::IsNearlyZero() const
{
	return X.IsNearlyZero() && Y.IsNearlyZero() && Z.IsNearlyZero();
}

IMPL_MATCH("Core.dll", 0x10104D70)
INT FRangeVector::IsZero() const
{
	return X.IsZero() && Y.IsZero() && Z.IsZero();
}

IMPL_MATCH("Core.dll", 0x101098b0)
FRangeVector FRangeVector::operator+( const FRangeVector& R ) const
{
	return FRangeVector( X+R.X, Y+R.Y, Z+R.Z );
}

IMPL_MATCH("Core.dll", 0x10109a90)
FRangeVector FRangeVector::operator+( const FVector& V ) const
{
	return FRangeVector( X+V.X, Y+V.Y, Z+V.Z );
}

IMPL_MATCH("Core.dll", 0x101099a0)
FRangeVector FRangeVector::operator-( const FRangeVector& R ) const
{
	return FRangeVector( X-R.X, Y-R.Y, Z-R.Z );
}

IMPL_MATCH("Core.dll", 0x10109b90)
FRangeVector FRangeVector::operator-( const FVector& V ) const
{
	return FRangeVector( X-V.X, Y-V.Y, Z-V.Z );
}

IMPL_MATCH("Core.dll", 0x10109f70)
FRangeVector FRangeVector::operator-() const
{
	return FRangeVector( -X, -Y, -Z );
}

IMPL_MATCH("Core.dll", 0x10109e80)
FRangeVector FRangeVector::operator*( const FRangeVector& R ) const
{
	return FRangeVector( X*R.X, Y*R.Y, Z*R.Z );
}

IMPL_MATCH("Core.dll", 0x10109c90)
FRangeVector FRangeVector::operator*( FLOAT F ) const
{
	return FRangeVector( X*F, Y*F, Z*F );
}

IMPL_MATCH("Core.dll", 0x10109d80)
FRangeVector FRangeVector::operator/( FLOAT F ) const
{
	return FRangeVector( X/F, Y/F, Z/F );
}

IMPL_MATCH("Core.dll", 0x101048f0)
FRangeVector FRangeVector::operator+=( const FRangeVector& R )
{
	X += R.X; Y += R.Y; Z += R.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x101049d0)
FRangeVector FRangeVector::operator+=( const FVector& V )
{
	X += V.X; Y += V.Y; Z += V.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104960)
FRangeVector FRangeVector::operator-=( const FRangeVector& R )
{
	X -= R.X; Y -= R.Y; Z -= R.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104a40)
FRangeVector FRangeVector::operator-=( const FVector& V )
{
	X -= V.X; Y -= V.Y; Z -= V.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104b90)
FRangeVector FRangeVector::operator*=( const FRangeVector& R )
{
	X *= R.X; Y *= R.Y; Z *= R.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104ab0)
FRangeVector FRangeVector::operator*=( FLOAT F )
{
	X *= F; Y *= F; Z *= F;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104c00)
FRangeVector FRangeVector::operator/=( const FRangeVector& R )
{
	X /= R.X; Y /= R.Y; Z /= R.Z;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104b20)
FRangeVector FRangeVector::operator/=( FLOAT F )
{
	X /= F; Y /= F; Z /= F;
	return *this;
}

IMPL_MATCH("Core.dll", 0x10104810)
INT FRangeVector::operator==( const FRangeVector& R ) const
{
	return X==R.X && Y==R.Y && Z==R.Z;
}

IMPL_MATCH("Core.dll", 0x10104880)
INT FRangeVector::operator!=( const FRangeVector& R ) const
{
	return X!=R.X || Y!=R.Y || Z!=R.Z;
}

IMPL_MATCH("Core.dll", 0x101038d0)
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
