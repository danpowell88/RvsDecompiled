/*=============================================================================
	UnMath.cpp: Unreal math routines — method bodies for FVector, FCoords,
	FRotator, FMatrix, FQuat, FGlobalMath, FBox, FSphere.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	FGlobalMath constructor — builds trig and sqrt lookup tables.
-----------------------------------------------------------------------------*/

FGlobalMath::FGlobalMath()
:	WorldMin		(-32700.f,-32700.f,-32700.f)
,	WorldMax		(32700.f,32700.f,32700.f)
,	UnitCoords		(FVector(0,0,0),FVector(1,0,0),FVector(0,1,0),FVector(0,0,1))
,	UnitScale		(FVector(1,1,1),0.0f,SHEER_None)
,	ViewCoords		(FVector(0,0,0),FVector(0,1,0),FVector(0,0,-1),FVector(1,0,0))
{
	// Init trig table.
	for( INT i=0; i<NUM_ANGLES; i++ )
		TrigFLOAT[i] = appSin( (FLOAT)i * 2.f * PI / (FLOAT)NUM_ANGLES );

	// Init sqrt table.
	for( INT i=0; i<NUM_SQRTS; i++ )
	{
		FLOAT IsFloat = (FLOAT)i / (FLOAT)NUM_SQRTS;
		SqrtFLOAT[i] = appSqrt( IsFloat );
		LightSqrtFLOAT[i] = appSqrt( appSqrt( IsFloat ) );
	}
}

/*-----------------------------------------------------------------------------
	FVector out-of-line methods.
-----------------------------------------------------------------------------*/

FLOAT FVector::Size() const
{
	return appSqrt( X*X + Y*Y + Z*Z );
}

FLOAT FVector::Size2D() const
{
	return appSqrt( X*X + Y*Y );
}

UBOOL FVector::Normalize()
{
	FLOAT SquareSum = X*X + Y*Y + Z*Z;
	if( SquareSum >= SMALL_NUMBER )
	{
		FLOAT Scale = 1.f / appSqrt(SquareSum);
		X *= Scale; Y *= Scale; Z *= Scale;
		return 1;
	}
	return 0;
}

FVector FVector::UnsafeNormal() const
{
	FLOAT Scale = 1.f / appSqrt(X*X + Y*Y + Z*Z);
	return FVector( X*Scale, Y*Scale, Z*Scale );
}

FVector FVector::SafeNormal() const
{
	FLOAT SquareSum = X*X + Y*Y + Z*Z;
	if( SquareSum > SMALL_NUMBER )
	{
		FLOAT Scale = 1.f / appSqrt(SquareSum);
		return FVector( X*Scale, Y*Scale, Z*Scale );
	}
	return FVector( 0.f, 0.f, 0.f );
}

FRotator FVector::Rotation()
{
	FRotator R;

	// Find yaw.
	R.Yaw = appRound( appAtan2(Y,X) * (FLOAT)MAXWORD / (2.f*PI) );

	// Find pitch.
	R.Pitch = appRound( appAtan2(Z, appSqrt(X*X+Y*Y) ) * (FLOAT)MAXWORD / (2.f*PI) );

	// Find roll.
	R.Roll = 0;

	return R;
}

void FVector::FindBestAxisVectors( FVector& Axis1, FVector& Axis2 )
{
	FLOAT NX = Abs(X);
	FLOAT NY = Abs(Y);
	FLOAT NZ = Abs(Z);

	// Find best basis vectors.
	if( NZ>NX && NZ>NY )	Axis1 = FVector(1,0,0);
	else					Axis1 = FVector(0,0,1);

	Axis1 = (Axis1 - *this * (Axis1 | *this)).SafeNormal();
	Axis2 = Axis1 ^ *this;
}

FLOAT FDist( const FVector& V1, const FVector& V2 )
{
	return appSqrt( Square(V2.X-V1.X) + Square(V2.Y-V1.Y) + Square(V2.Z-V1.Z) );
}

/*-----------------------------------------------------------------------------
	FBox.
-----------------------------------------------------------------------------*/

FBox::FBox( const FVector* Points, INT Count )
:	Min(0,0,0), Max(0,0,0), IsValid(0)
{
	for( INT i=0; i<Count; i++ )
		*this += Points[i];
}

/*-----------------------------------------------------------------------------
	FSphere.
-----------------------------------------------------------------------------*/

FSphere::FSphere( const FVector* Pts, INT Count )
:	FPlane(0,0,0,0)
{
	if( Count )
	{
		FBox Box( Pts, Count );
		*this = FSphere( (Box.Min+Box.Max)/2.f, 0 );
		for( INT i=0; i<Count; i++ )
		{
			FLOAT Dist = FDistSquared( Pts[i], *this );
			if( Dist > W )
				W = Dist;
		}
		W = appSqrt(W) * 1.001f;
	}
}

/*-----------------------------------------------------------------------------
	FCoords functions.
-----------------------------------------------------------------------------*/

FCoords FCoords::Inverse() const
{
	FLOAT RDet = 1.f / (XAxis | (YAxis ^ ZAxis));
	return FCoords
	(
		-Origin.TransformVectorBy(*this),
		RDet * FVector
		(
			+(YAxis.Y*ZAxis.Z - YAxis.Z*ZAxis.Y),
			-(XAxis.Y*ZAxis.Z - XAxis.Z*ZAxis.Y),
			+(XAxis.Y*YAxis.Z - XAxis.Z*YAxis.Y)
		),
		RDet * FVector
		(
			-(YAxis.X*ZAxis.Z - YAxis.Z*ZAxis.X),
			+(XAxis.X*ZAxis.Z - XAxis.Z*ZAxis.X),
			-(XAxis.X*YAxis.Z - XAxis.Z*YAxis.X)
		),
		RDet * FVector
		(
			+(YAxis.X*ZAxis.Y - YAxis.Y*ZAxis.X),
			-(XAxis.X*ZAxis.Y - XAxis.Y*ZAxis.X),
			+(XAxis.X*YAxis.Y - XAxis.Y*YAxis.X)
		)
	);
}

FCoords FCoords::PivotInverse() const
{
	return FCoords
	(
		-Origin,
		FVector( XAxis.X, YAxis.X, ZAxis.X ),
		FVector( XAxis.Y, YAxis.Y, ZAxis.Y ),
		FVector( XAxis.Z, YAxis.Z, ZAxis.Z )
	);
}

FCoords FCoords::ApplyPivot(const FCoords& CoordsB) const
{
	// Equivalent to IsometricInverse * CoordsB.
	FCoords Result;
	Result.Origin = CoordsB.Origin + Origin;
	Result.XAxis  = CoordsB.XAxis;
	Result.YAxis  = CoordsB.YAxis;
	Result.ZAxis  = CoordsB.ZAxis;
	return Result;
}

FRotator FCoords::OrthoRotation() const
{
	FRotator R;

	// Find yaw.
	R.Yaw = appRound( appAtan2( XAxis.Y, XAxis.X ) * (FLOAT)MAXWORD / (2.f*PI) );

	// Find pitch.
	R.Pitch = appRound( appAtan2( XAxis.Z, appSqrt(XAxis.X*XAxis.X + XAxis.Y*XAxis.Y) ) * (FLOAT)MAXWORD / (2.f*PI) );

	// Find roll.
	FCoords Temp = GMath.UnitCoords / FRotator(R.Pitch, R.Yaw, 0);
	R.Roll = appRound( appAtan2( Temp.ZAxis | YAxis, Temp.YAxis | YAxis ) * (FLOAT)MAXWORD / (2.f*PI) );

	return R;
}

/*-----------------------------------------------------------------------------
	FMatrix.
-----------------------------------------------------------------------------*/

FMatrix CombineTransforms( const FMatrix& M, const FMatrix& N )
{
	FMatrix Result;
	// Row 0
	Result.XPlane.X = M.XPlane.X*N.XPlane.X + M.XPlane.Y*N.YPlane.X + M.XPlane.Z*N.ZPlane.X;
	Result.XPlane.Y = M.XPlane.X*N.XPlane.Y + M.XPlane.Y*N.YPlane.Y + M.XPlane.Z*N.ZPlane.Y;
	Result.XPlane.Z = M.XPlane.X*N.XPlane.Z + M.XPlane.Y*N.YPlane.Z + M.XPlane.Z*N.ZPlane.Z;
	Result.XPlane.W = M.XPlane.X*N.XPlane.W + M.XPlane.Y*N.YPlane.W + M.XPlane.Z*N.ZPlane.W + M.XPlane.W;
	// Row 1
	Result.YPlane.X = M.YPlane.X*N.XPlane.X + M.YPlane.Y*N.YPlane.X + M.YPlane.Z*N.ZPlane.X;
	Result.YPlane.Y = M.YPlane.X*N.XPlane.Y + M.YPlane.Y*N.YPlane.Y + M.YPlane.Z*N.ZPlane.Y;
	Result.YPlane.Z = M.YPlane.X*N.XPlane.Z + M.YPlane.Y*N.YPlane.Z + M.YPlane.Z*N.ZPlane.Z;
	Result.YPlane.W = M.YPlane.X*N.XPlane.W + M.YPlane.Y*N.YPlane.W + M.YPlane.Z*N.ZPlane.W + M.YPlane.W;
	// Row 2
	Result.ZPlane.X = M.ZPlane.X*N.XPlane.X + M.ZPlane.Y*N.YPlane.X + M.ZPlane.Z*N.ZPlane.X;
	Result.ZPlane.Y = M.ZPlane.X*N.XPlane.Y + M.ZPlane.Y*N.YPlane.Y + M.ZPlane.Z*N.ZPlane.Y;
	Result.ZPlane.Z = M.ZPlane.X*N.XPlane.Z + M.ZPlane.Y*N.YPlane.Z + M.ZPlane.Z*N.ZPlane.Z;
	Result.ZPlane.W = M.ZPlane.X*N.XPlane.W + M.ZPlane.Y*N.YPlane.W + M.ZPlane.Z*N.ZPlane.W + M.ZPlane.W;
	// Row 3
	Result.WPlane.X = 0.f;
	Result.WPlane.Y = 0.f;
	Result.WPlane.Z = 0.f;
	Result.WPlane.W = 1.f;
	return Result;
}

FQuat FMatrix::FMatrixToFQuat()
{
	FQuat Q;
	FLOAT tr = M(0,0) + M(1,1) + M(2,2);

	if( tr > 0.f )
	{
		FLOAT s = appSqrt( tr + 1.f );
		Q.W = s * 0.5f;
		s = 0.5f / s;
		Q.X = (M(1,2) - M(2,1)) * s;
		Q.Y = (M(2,0) - M(0,2)) * s;
		Q.Z = (M(0,1) - M(1,0)) * s;
	}
	else
	{
		INT i = 0;
		if( M(1,1) > M(0,0) ) i = 1;
		if( M(2,2) > M(i,i) ) i = 2;

		static const INT nxt[3] = { 1, 2, 0 };
		INT j = nxt[i];
		INT k = nxt[j];

		FLOAT s = appSqrt( (M(i,i) - (M(j,j) + M(k,k))) + 1.f );
		FLOAT* qt[4] = { &Q.X, &Q.Y, &Q.Z, &Q.W };
		*qt[i] = s * 0.5f;
		if( s != 0.f ) s = 0.5f / s;
		*qt[3] = (M(j,k) - M(k,j)) * s;
		*qt[j] = (M(i,j) + M(j,i)) * s;
		*qt[k] = (M(i,k) + M(k,i)) * s;
	}
	return Q;
}

/*-----------------------------------------------------------------------------
	FQuat out-of-line methods.
-----------------------------------------------------------------------------*/

UBOOL FQuat::Normalize()
{
	FLOAT SquareSum = X*X + Y*Y + Z*Z + W*W;
	if( SquareSum >= DELTA )
	{
		FLOAT Scale = 1.0f / appSqrt(SquareSum);
		X *= Scale;
		Y *= Scale;
		Z *= Scale;
		W *= Scale;
		return 1;
	}
	else
	{
		X = 0.0f;
		Y = 0.0f;
		Z = 0.1f;
		W = 0.0f;
		return 0;
	}
}

FQuat FQuat::AngAxisToFQuat()
{
	FLOAT scale = X*X + Y*Y + Z*Z;
	FQuat Q;

	if( scale >= DELTA )
	{
		FLOAT invscale = 1.0f / appSqrt(scale);
		Q.X = X * invscale;
		Q.Y = Y * invscale;
		Q.Z = Z * invscale;
		Q.W = appCos( W * 0.5f );
	}
	else
	{
		Q.X = 0.0f;
		Q.Y = 0.0f;
		Q.Z = 1.0f;
		Q.W = 0.0f;
	}
	return Q;
}

FMatrix FQuat::FQuatToFMatrix()
{
	FMatrix M;

	FLOAT wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;

	x2 = X + X;  y2 = Y + Y;  z2 = Z + Z;
	xx = X * x2; xy = X * y2; xz = X * z2;
	yy = Y * y2; yz = Y * z2; zz = Z * z2;
	wx = W * x2; wy = W * y2; wz = W * z2;

	M.XPlane.X = 1.0f - (yy + zz);
	M.XPlane.Y = xy - wz;
	M.XPlane.Z = xz + wy;
	M.XPlane.W = 0.0f;

	M.YPlane.X = xy + wz;
	M.YPlane.Y = 1.0f - (xx + zz);
	M.YPlane.Z = yz - wx;
	M.YPlane.W = 0.0f;

	M.ZPlane.X = xz - wy;
	M.ZPlane.Y = yz + wx;
	M.ZPlane.Z = 1.0f - (xx + yy);
	M.ZPlane.W = 0.0f;

	M.WPlane.X = 0.0f;
	M.WPlane.Y = 0.0f;
	M.WPlane.Z = 0.0f;
	M.WPlane.W = 1.0f;

	return M;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
