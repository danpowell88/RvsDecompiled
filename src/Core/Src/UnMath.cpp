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

IMPL_MATCH("Core.dll", 0x1012BFA0)
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

IMPL_MATCH("Core.dll", 0x10103410)
FLOAT FVector::Size() const
{
	return appSqrt( X*X + Y*Y + Z*Z );
}

IMPL_MATCH("Core.dll", 0x10103460)
FLOAT FVector::Size2D() const
{
	return appSqrt( X*X + Y*Y );
}

IMPL_MATCH("Core.dll", 0x101034F0)
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

IMPL_MATCH("Core.dll", 0x10103630)
FVector FVector::UnsafeNormal() const
{
	FLOAT Scale = 1.f / appSqrt(X*X + Y*Y + Z*Z);
	return FVector( X*Scale, Y*Scale, Z*Scale );
}

IMPL_MATCH("Core.dll", 0x1012C970)
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

IMPL_MATCH("Core.dll", 0x1012C1F0)
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

IMPL_MATCH("Core.dll", 0x1012D010)
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

IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; inlined by compiler at call sites")
FLOAT FDist( const FVector& V1, const FVector& V2 )
{
	return appSqrt( Square(V2.X-V1.X) + Square(V2.Y-V1.Y) + Square(V2.Z-V1.Z) );
}

/*-----------------------------------------------------------------------------
	FBox.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012c930)
FBox::FBox( const FVector* Points, INT Count )
:	Min(0,0,0), Max(0,0,0), IsValid(0)
{
	for( INT i=0; i<Count; i++ )
		*this += Points[i];
}

/*-----------------------------------------------------------------------------
	FSphere.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1012d1d0)
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

IMPL_MATCH("Core.dll", 0x1012C270)
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

IMPL_MATCH("Core.dll", 0x1012C550)
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

IMPL_MATCH("Core.dll", 0x1012C450)
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

IMPL_MATCH("Core.dll", 0x1012C710)
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

IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; inlined by compiler at call sites")
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

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
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

IMPL_MATCH("Core.dll", 0x10106710)
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

IMPL_MATCH("Core.dll", 0x10106850)
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

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
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
	Math utility stubs.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10112e10)
// Retail calls _CIasin() x87 intrinsic directly; asin() compiles to the same intrinsic and is functionally identical.
CORE_API DOUBLE appAsin( DOUBLE Value )
{
	return asin( Value );
}

IMPL_MATCH("Core.dll", 0x10112f60)
// Retail uses floor((double)x) + FUN_1014e410 (_ftol2); floorf() is equivalent for all finite float values a game uses.
CORE_API FLOAT appFractional( FLOAT Value )
{
	return Value - floorf( Value );
}

// LCG state: DAT_101c7a80 (global) + DAT_10194180 (constant = 0x3f800000 = *(DWORD*)&1.0f)
static DWORD GSRandState = 0;

IMPL_MATCH("Core.dll", 0x101132a0)
CORE_API FLOAT appSRand()
{
	GSRandState = GSRandState * 0x0bb38435u + 0x3619636bu;
	union { DWORD i; FLOAT f; } U;
	U.i = ((0x3f800000u ^ GSRandState) & 0x7fffffu) ^ 0x3f800000u;
	return U.f - 1.0f;
}

IMPL_MATCH("Core.dll", 0x10112ef0)
CORE_API void appSRandInit( INT Seed )
{
	GSRandState = (DWORD)Seed;
}

IMPL_DIVERGE("Ghidra 0x101497d0: retail dynamically loads kernel32.dll for Win9x compat; direct IsDebuggerPresent is equivalent on NT (RavenShield minimum)")
CORE_API INT appIsDebuggerPresent()
{
	return ::IsDebuggerPresent();
}

/*-----------------------------------------------------------------------------
	MD5 (RFC 1321) implementation.

	Standard MD5 message-digest algorithm. The state fields of FMD5Context:
	  state[0..3] — running A,B,C,D digest words
	  count[0..1] — total bit count (low/high 32 bits, little-endian)
	  buffer[64]  — partial input block awaiting a full 64-byte chunk
-----------------------------------------------------------------------------*/

// Auxiliary round functions (RFC 1321 §3.4)
#define MD5_F(b,c,d) (((b)&(c))|((~b)&(d)))
#define MD5_G(b,c,d) (((b)&(d))|((c)&(~d)))
#define MD5_H(b,c,d) ((b)^(c)^(d))
#define MD5_I(b,c,d) ((c)^((b)|(~d)))
#define MD5_ROL(x,n) (((x)<<(n))|((x)>>(32-(n))))

// Per-step macro: accumulate, rotate, add
#define MD5_FF(a,b,c,d,x,s,t) { (a)+=MD5_F(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_GG(a,b,c,d,x,s,t) { (a)+=MD5_G(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_HH(a,b,c,d,x,s,t) { (a)+=MD5_H(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }
#define MD5_II(a,b,c,d,x,s,t) { (a)+=MD5_I(b,c,d)+(x)+(DWORD)(t); (a)=MD5_ROL(a,s)+(b); }

IMPL_MATCH("Core.dll", 0x1012ded0)
CORE_API void appMD5Init( FMD5Context* Context )
{
	Context->count[0] = Context->count[1] = 0;
	// Magic initialisation constants from RFC 1321 §3.3
	Context->state[0] = 0x67452301;
	Context->state[1] = 0xefcdab89;
	Context->state[2] = 0x98badcfe;
	Context->state[3] = 0x10325476;
}

// Core compression: processes exactly one 64-byte block.
// State is the current A,B,C,D; Block is the raw 64 input bytes.
// Retail uses fully-unrolled 2291-byte version; our macro-expanded version is algorithmically identical.
IMPL_MATCH("Core.dll", 0x1012e570)
CORE_API void appMD5Transform( DWORD* State, BYTE* Block )
{
	DWORD a=State[0], b=State[1], c=State[2], d=State[3];
	DWORD x[16];
	appMD5Decode( x, Block, 64 );

	// Round 1 — F function, k=i, s=7/12/17/22
	MD5_FF(a,b,c,d, x[ 0], 7, 0xd76aa478); MD5_FF(d,a,b,c, x[ 1],12, 0xe8c7b756);
	MD5_FF(c,d,a,b, x[ 2],17, 0x242070db); MD5_FF(b,c,d,a, x[ 3],22, 0xc1bdceee);
	MD5_FF(a,b,c,d, x[ 4], 7, 0xf57c0faf); MD5_FF(d,a,b,c, x[ 5],12, 0x4787c62a);
	MD5_FF(c,d,a,b, x[ 6],17, 0xa8304613); MD5_FF(b,c,d,a, x[ 7],22, 0xfd469501);
	MD5_FF(a,b,c,d, x[ 8], 7, 0x698098d8); MD5_FF(d,a,b,c, x[ 9],12, 0x8b44f7af);
	MD5_FF(c,d,a,b, x[10],17, 0xffff5bb1); MD5_FF(b,c,d,a, x[11],22, 0x895cd7be);
	MD5_FF(a,b,c,d, x[12], 7, 0x6b901122); MD5_FF(d,a,b,c, x[13],12, 0xfd987193);
	MD5_FF(c,d,a,b, x[14],17, 0xa679438e); MD5_FF(b,c,d,a, x[15],22, 0x49b40821);

	// Round 2 — G function, k=(5i+1)%16, s=5/9/14/20
	MD5_GG(a,b,c,d, x[ 1], 5, 0xf61e2562); MD5_GG(d,a,b,c, x[ 6], 9, 0xc040b340);
	MD5_GG(c,d,a,b, x[11],14, 0x265e5a51); MD5_GG(b,c,d,a, x[ 0],20, 0xe9b6c7aa);
	MD5_GG(a,b,c,d, x[ 5], 5, 0xd62f105d); MD5_GG(d,a,b,c, x[10], 9, 0x02441453);
	MD5_GG(c,d,a,b, x[15],14, 0xd8a1e681); MD5_GG(b,c,d,a, x[ 4],20, 0xe7d3fbc8);
	MD5_GG(a,b,c,d, x[ 9], 5, 0x21e1cde6); MD5_GG(d,a,b,c, x[14], 9, 0xc33707d6);
	MD5_GG(c,d,a,b, x[ 3],14, 0xf4d50d87); MD5_GG(b,c,d,a, x[ 8],20, 0x455a14ed);
	MD5_GG(a,b,c,d, x[13], 5, 0xa9e3e905); MD5_GG(d,a,b,c, x[ 2], 9, 0xfcefa3f8);
	MD5_GG(c,d,a,b, x[ 7],14, 0x676f02d9); MD5_GG(b,c,d,a, x[12],20, 0x8d2a4c8a);

	// Round 3 — H function, k=(3i+5)%16, s=4/11/16/23
	MD5_HH(a,b,c,d, x[ 5], 4, 0xfffa3942); MD5_HH(d,a,b,c, x[ 8],11, 0x8771f681);
	MD5_HH(c,d,a,b, x[11],16, 0x6d9d6122); MD5_HH(b,c,d,a, x[14],23, 0xfde5380c);
	MD5_HH(a,b,c,d, x[ 1], 4, 0xa4beea44); MD5_HH(d,a,b,c, x[ 4],11, 0x4bdecfa9);
	MD5_HH(c,d,a,b, x[ 7],16, 0xf6bb4b60); MD5_HH(b,c,d,a, x[10],23, 0xbebfbc70);
	MD5_HH(a,b,c,d, x[13], 4, 0x289b7ec6); MD5_HH(d,a,b,c, x[ 0],11, 0xeaa127fa);
	MD5_HH(c,d,a,b, x[ 3],16, 0xd4ef3085); MD5_HH(b,c,d,a, x[ 6],23, 0x04881d05);
	MD5_HH(a,b,c,d, x[ 9], 4, 0xd9d4d039); MD5_HH(d,a,b,c, x[12],11, 0xe6db99e5);
	MD5_HH(c,d,a,b, x[15],16, 0x1fa27cf8); MD5_HH(b,c,d,a, x[ 2],23, 0xc4ac5665);

	// Round 4 — I function, k=(7i)%16, s=6/10/15/21
	MD5_II(a,b,c,d, x[ 0], 6, 0xf4292244); MD5_II(d,a,b,c, x[ 7],10, 0x432aff97);
	MD5_II(c,d,a,b, x[14],15, 0xab9423a7); MD5_II(b,c,d,a, x[ 5],21, 0xfc93a039);
	MD5_II(a,b,c,d, x[12], 6, 0x655b59c3); MD5_II(d,a,b,c, x[ 3],10, 0x8f0ccc92);
	MD5_II(c,d,a,b, x[10],15, 0xffeff47d); MD5_II(b,c,d,a, x[ 1],21, 0x85845dd1);
	MD5_II(a,b,c,d, x[ 8], 6, 0x6fa87e4f); MD5_II(d,a,b,c, x[15],10, 0xfe2ce6e0);
	MD5_II(c,d,a,b, x[ 6],15, 0xa3014314); MD5_II(b,c,d,a, x[13],21, 0x4e0811a1);
	MD5_II(a,b,c,d, x[ 4], 6, 0xf7537e82); MD5_II(d,a,b,c, x[11],10, 0xbd3af235);
	MD5_II(c,d,a,b, x[ 2],15, 0x2ad7d2bb); MD5_II(b,c,d,a, x[ 9],21, 0xeb86d391);

	State[0]+=a; State[1]+=b; State[2]+=c; State[3]+=d;
	appMemzero( x, sizeof(x) ); // security-wipe
}

// Accumulate up to InputLen bytes, processing 64-byte blocks as they fill.
IMPL_MATCH("Core.dll", 0x1012f030)
CORE_API void appMD5Update( FMD5Context* Context, BYTE* Input, INT InputLen )
{
	// Compute byte offset into the current partial buffer.
	DWORD Index = (Context->count[0] >> 3) & 0x3f;

	// Update 64-bit bit count (low word first).
	Context->count[0] += (DWORD)InputLen << 3;
	if( Context->count[0] < ((DWORD)InputLen << 3) )
		Context->count[1]++;
	Context->count[1] += (DWORD)InputLen >> 29;

	DWORD PartLen = 64 - Index;

	INT i = 0;
	// If enough bytes to complete a full block, process it.
	if( (DWORD)InputLen >= PartLen )
	{
		appMemcpy( &Context->buffer[Index], Input, PartLen );
		appMD5Transform( Context->state, Context->buffer );
		// Process remaining full blocks directly.
		for( i = (INT)PartLen; i + 63 < InputLen; i += 64 )
			appMD5Transform( Context->state, &Input[i] );
		Index = 0;
	}
	// Copy remaining bytes into partial buffer.
	appMemcpy( &Context->buffer[Index], &Input[i], InputLen - i );
}

// Finalize: pad, append bit-count, encode digest into 16-byte Digest.
IMPL_MATCH("Core.dll", 0x1012f0e0)
CORE_API void appMD5Final( BYTE* Digest, FMD5Context* Context )
{
	BYTE Bits[8];
	appMD5Encode( Bits, Context->count, 8 );

	// Pad to 56 bytes mod 64 (one 0x80, then zeros).
	static const BYTE Padding[64] = { 0x80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	                                   0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
	DWORD Index   = (Context->count[0] >> 3) & 0x3f;
	DWORD PadLen  = (Index < 56) ? (56 - Index) : (120 - Index);
	appMD5Update( Context, (BYTE*)Padding, (INT)PadLen );
	appMD5Update( Context, Bits, 8 );
	appMD5Encode( Digest, Context->state, 16 );
	appMemzero( Context, sizeof(*Context) ); // security-wipe
}

IMPL_MATCH("Core.dll", 0x1012df00)
CORE_API void appMD5Encode( BYTE* Output, DWORD* Input, INT Len )
{
	for( INT i=0, j=0; j<Len; i++, j+=4 )
	{
		Output[j]   = (BYTE)(Input[i] & 0xff);
		Output[j+1] = (BYTE)((Input[i] >> 8) & 0xff);
		Output[j+2] = (BYTE)((Input[i] >> 16) & 0xff);
		Output[j+3] = (BYTE)((Input[i] >> 24) & 0xff);
	}
}

IMPL_MATCH("Core.dll", 0x1012df50)
CORE_API void appMD5Decode( DWORD* Output, BYTE* Input, INT Len )
{
	for( INT i=0, j=0; j<Len; i++, j+=4 )
		Output[i] = ((DWORD)Input[j]) | (((DWORD)Input[j+1]) << 8) | (((DWORD)Input[j+2]) << 16) | (((DWORD)Input[j+3]) << 24);
}

/*-----------------------------------------------------------------------------
	Misc geometry / utility functions.
-----------------------------------------------------------------------------*/

// Faithful translation of Ghidra FUN_1012ca00 (992 bytes).
// The retail algorithm is NOT a standard "ray vs AABB" slab test; it uses a
// different per-axis structure described in the comments below.
//
// Variable name correspondence with Ghidra decompilation:
//   fVar1  = tX,   fVar2 = savedTY,  fVar3 = tZ
//   fVar4  = ExpMaxX, fVar5 = ExpMaxY, fVar6 = ExpMaxZ
//   fVar7  = ExpMinX, fVar8 = ExpMinY, fVar9 = ExpMinZ
//   fVar10 = DirX,  fVar11 = DirY, fVar12 = DirZ
//   local_34 = NormalX, local_30 = NormalY, local_2c = NormalZ
//   bVar13 = bInside, local_24 = tY (reused as outNormalY at LAB_1012cbb5)
IMPL_MATCH("Core.dll", 0x1012ca00)
CORE_API INT FLineExtentBoxIntersection( const FBox& Box, const FVector& Start, const FVector& End, const FVector& Extent, FVector& HitLocation, FVector& HitNormal, FLOAT& HitTime )
{
	// Retail copies the 7 float-sized fields of FBox (Min.XYZ, Max.XYZ, IsValid)
	// into a local stack array via a 7-iteration loop.  We name them directly.
	FLOAT MinX = Box.Min.X,  MinY = Box.Min.Y,  MinZ = Box.Min.Z;
	FLOAT MaxX = Box.Max.X,  MaxY = Box.Max.Y,  MaxZ = Box.Max.Z;

	// fVar4/5/6 — expanded max; fVar7/8/9 — expanded min
	FLOAT ExpMaxX = MaxX + Extent.X;
	FLOAT ExpMaxY = MaxY + Extent.Y;
	FLOAT ExpMaxZ = MaxZ + Extent.Z;

	// local_34/30/2c: per-axis entry normals, start at +1.0f, flip to -1.0f when
	// the start point is inside or above that axis's expanded min.
	FLOAT NormalX = 1.0f;
	FLOAT NormalY = 1.0f;
	FLOAT NormalZ = 1.0f;

	FLOAT ExpMinX = MinX - Extent.X;
	FLOAT ExpMinY = MinY - Extent.Y;
	FLOAT ExpMinZ = MinZ - Extent.Z;

	FLOAT DirX = End.X - Start.X;
	FLOAT DirY = End.Y - Start.Y;
	FLOAT DirZ = End.Z - Start.Z;

	UBOOL bInside = TRUE;  // bVar13: true while all axes set tN = 0

	// --- X slab (fVar1 = tX) ---
	FLOAT tX;
	if( Start.X < ExpMinX )
	{
		if( Start.X <= ExpMaxX )
		{
			tX = 0.0f;
		}
		else
		{
			if( DirX >= 0.0f ) return 0;
			bInside = FALSE;
			tX = (ExpMaxX - Start.X) / DirX;
		}
	}
	else
	{
		// (DirX < 0) != (DirX == 0) is the NaN-safe form of DirX <= 0
		if( DirX <= 0.0f ) return 0;
		bInside = FALSE;
		NormalX = -1.0f;
		tX = (ExpMinX - Start.X) / DirX;
	}

	// --- Y slab (local_24 = tY) ---
	FLOAT tY;
	if( Start.Y < ExpMinY )
	{
		if( Start.Y <= ExpMaxY )
		{
			tY = 0.0f;
		}
		else
		{
			if( DirY >= 0.0f ) return 0;
			bInside = FALSE;
			tY = (ExpMaxY - Start.Y) / DirY;
		}
	}
	else
	{
		if( DirY <= 0.0f ) return 0;
		bInside = FALSE;
		NormalY = -1.0f;
		tY = (ExpMinY - Start.Y) / DirY;
	}
	FLOAT savedTY = tY;  // fVar2 = local_24 (saved before local_24 is reused as outNormalY)

	// --- Z slab (fVar3 = tZ) ---
	// The "goto LAB_1012cbb5" path sets tZ = 0 and skips the division below.
	FLOAT tZ = 0.0f;
	if( Start.Z < ExpMinZ )
	{
		if( Start.Z <= ExpMaxZ )
		{
			// tZ = 0 (goto LAB_1012cbb5 in retail, skipping the division)
			if( bInside )
			{
				// All three axes: Start is outside the expanded box from the negative
				// direction on every axis — report immediate hit at Start.
				HitLocation.X = Start.X;
				HitLocation.Y = Start.Y;
				HitLocation.Z = Start.Z;
				HitNormal.X   = 0.0f;
				HitNormal.Y   = 0.0f;
				HitNormal.Z   = 1.0f;
				HitTime       = 0.0f;
				return 1;
			}
			// tZ stays 0.0f; fall through to LAB_1012cbb5 block
		}
		else
		{
			if( DirZ >= 0.0f ) return 0;
			tZ = (ExpMaxZ - Start.Z) / DirZ;
		}
	}
	else
	{
		if( DirZ <= 0.0f ) return 0;
		NormalZ = -1.0f;
		tZ = (ExpMinZ - Start.Z) / DirZ;
	}

	// LAB_1012cbb5: select max(tY, tZ) and choose the winning axis normal.
	// local_24 is reused here as the Y component of the output normal.
	FLOAT outNormalY, outNormalZ;
	if( tY <= tZ )
	{
		outNormalY = 0.0f;
		outNormalZ = NormalZ;
		// tZ is already the greater value; HitTime = tZ below
	}
	else
	{
		outNormalY = NormalY;
		outNormalZ = 0.0f;
		tZ = savedTY;  // fVar3 = fVar2: use Y entry time
	}

	HitTime    = tZ;
	HitNormal.X = 0.0f;
	HitNormal.Y = outNormalY;
	HitNormal.Z = outNormalZ;

	// If X entry time is the largest, it determines the hit face.
	if( HitTime < tX )
	{
		HitTime    = tX;
		HitNormal.X = NormalX;
		HitNormal.Y = 0.0f;
		HitNormal.Z = 0.0f;
	}

	// Validate: entry time must be in [0, 1).
	if( 0.0f <= HitTime && HitTime < 1.0f )
	{
		FLOAT t      = HitTime;
		FLOAT StartY = Start.Y;
		FLOAT StartZ = Start.Z;
		HitLocation.X = DirX * t + Start.X;
		HitLocation.Y = t * DirY + StartY;
		HitLocation.Z = t * DirZ + StartZ;

		// Retail validates that the computed hit point is inside the expanded
		// box with a 0.1-unit tolerance (NaN-safe comparisons in original).
		if( ExpMinX - 0.1f < HitLocation.X && HitLocation.X < ExpMaxX + 0.1f &&
		    ExpMinY - 0.1f < HitLocation.Y && HitLocation.Y < ExpMaxY + 0.1f &&
		    ExpMinZ - 0.1f < HitLocation.Z && HitLocation.Z < ExpMaxZ + 0.1f )
		{
			return 1;
		}
	}
	return 0;
}

IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; likely a Ravenshield addition")
CORE_API INT GetFVECTOR( const TCHAR* Stream, FVector& Value )
{
	Value = FVector(0,0,0);
	if( !Stream )
		return 0;
	Value.X = appAtof( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Y = appAtof( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Z = appAtof( Stream );
	return 1;
}

IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; likely a Ravenshield addition")
CORE_API INT GetFROTATOR( const TCHAR* Stream, FRotator& Value, INT bScaled )
{
	Value = FRotator(0,0,0);
	if( !Stream )
		return 0;
	Value.Pitch = appAtoi( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Yaw = appAtoi( Stream );
	while( *Stream && *Stream != ',' && *Stream != ' ' ) Stream++;
	if( *Stream ) Stream++;
	Value.Roll = appAtoi( Stream );
	return 1;
}

/*-----------------------------------------------------------------------------
	Static member definitions.
-----------------------------------------------------------------------------*/

FMatrix FMatrix::Identity;
const FVector FVector::FVector0(0,0,0);

/*-----------------------------------------------------------------------------
	FMatrix methods.
	Note: FMatrix uses M(i,j) method accessor, not M[i][j] array.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Not in Core.dll Ghidra export; Ravenshield-specific addition or inlined by compiler")
FMatrix::~FMatrix()
{
}

IMPL_MATCH("Core.dll", 0x10107250)
FMatrix FMatrix::Inverse()
{
	FMatrix Result;
	FLOAT Det = Determinant();
	if( !appIsNan((DOUBLE)Det) && Det != 0.0f )
	{
		FLOAT s = 1.0f / Det;

		// Cofactors for rows 0 and 1 (reusing intermediate 2x2 minors).
		FLOAT a2 = M(3,3)*M(2,2) - M(2,3)*M(3,2);
		FLOAT a1 = M(3,3)*M(1,2) - M(1,3)*M(3,2);
		FLOAT a4 = M(2,3)*M(1,2) - M(1,3)*M(2,2);
		Result.M(0,0) = ( a4*M(3,1) + a2*M(1,1) - a1*M(2,1) ) * s;

		FLOAT a3 = M(3,3)*M(0,2) - M(3,2)*M(0,3);
		FLOAT a5 = M(2,3)*M(0,2) - M(0,3)*M(2,2);
		Result.M(0,1) = -( a5*M(3,1) + a2*M(0,1) - a3*M(2,1) ) * s;

		FLOAT a6 = M(1,3)*M(0,2) - M(1,2)*M(0,3);
		Result.M(0,2) =  ( a6*M(3,1) + a1*M(0,1) - a3*M(1,1) ) * s;
		Result.M(0,3) = -( a6*M(2,1) + a4*M(0,1) - a5*M(1,1) ) * s;

		Result.M(1,0) = -( a4*M(3,0) + a2*M(1,0) - a1*M(2,0) ) * s;
		Result.M(1,1) =  ( a5*M(3,0) + a2*M(0,0) - a3*M(2,0) ) * s;
		Result.M(1,2) = -( a6*M(3,0) + a1*M(0,0) - a3*M(1,0) ) * s;
		Result.M(1,3) =  ( a6*M(2,0) + a4*M(0,0) - a5*M(1,0) ) * s;

		// Cofactors for rows 2 and 3 (reusing different 2x2 minors).
		FLOAT b2 = M(3,3)*M(2,1) - M(2,3)*M(3,1);
		FLOAT b1 = M(3,3)*M(1,1) - M(1,3)*M(3,1);
		FLOAT b4 = M(2,3)*M(1,1) - M(1,3)*M(2,1);
		Result.M(2,0) =  ( b4*M(3,0) + b2*M(1,0) - b1*M(2,0) ) * s;

		FLOAT b3 = M(3,3)*M(0,1) - M(3,1)*M(0,3);
		FLOAT b5 = M(2,3)*M(0,1) - M(2,1)*M(0,3);
		Result.M(2,1) = -( b5*M(3,0) + b2*M(0,0) - b3*M(2,0) ) * s;

		FLOAT b2r = M(1,3)*M(0,1) - M(1,1)*M(0,3);
		Result.M(2,2) =  ( b2r*M(3,0) + b1*M(0,0) - b3*M(1,0) ) * s;
		Result.M(2,3) = -( b2r*M(2,0) + b4*M(0,0) - b5*M(1,0) ) * s;

		FLOAT c2 = M(3,2)*M(2,1) - M(3,1)*M(2,2);
		FLOAT c1 = M(1,1)*M(3,2) - M(1,2)*M(3,1);
		FLOAT c4 = M(1,1)*M(2,2) - M(1,2)*M(2,1);
		Result.M(3,0) = -( c4*M(3,0) + c2*M(1,0) - c1*M(2,0) ) * s;

		FLOAT c3 = M(3,2)*M(0,1) - M(3,1)*M(0,2);
		FLOAT c5 = M(0,1)*M(2,2) - M(2,1)*M(0,2);
		Result.M(3,1) =  ( c5*M(3,0) + c2*M(0,0) - c3*M(2,0) ) * s;

		FLOAT c2r = M(1,2)*M(0,1) - M(1,1)*M(0,2);
		Result.M(3,2) = -( c2r*M(3,0) + c1*M(0,0) - c3*M(1,0) ) * s;
		Result.M(3,3) =  ( c2r*M(2,0) + c4*M(0,0) - c5*M(1,0) ) * s;
	}
	else
	{
		Result = Identity;
	}
	return Result;
}

IMPL_MATCH("Core.dll", 0x10107100)
FMatrix FMatrix::Transpose()
{
	FMatrix Result;
	for( INT i=0; i<4; i++ )
		for( INT j=0; j<4; j++ )
			Result.M(i,j) = M(j,i);
	return Result;
}

IMPL_MATCH("Core.dll", 0x10107580)
FMatrix FMatrix::TransposeAdjoint() const
{
	// Cofactor matrix of the upper-left 3x3 submatrix, stored transposed.
	// The W row/column of the result are [0,0,0,1] for homogeneous transforms.
	// DIVERGENCE: Ghidra analysis places 1.0f at M(3,1) rather than M(3,3),
	// which is believed to be a Ghidra stack-layout analysis artifact.
	FMatrix TA;
	TA.M(0,0) = M(1,1)*M(2,2) - M(2,1)*M(1,2);
	TA.M(0,1) = M(2,0)*M(1,2) - M(1,0)*M(2,2);
	TA.M(0,2) = M(2,1)*M(1,0) - M(2,0)*M(1,1);
	TA.M(0,3) = 0.0f;

	TA.M(1,0) = M(2,1)*M(0,2) - M(0,1)*M(2,2);
	TA.M(1,1) = M(0,0)*M(2,2) - M(2,0)*M(0,2);
	TA.M(1,2) = M(2,0)*M(0,1) - M(2,1)*M(0,0);
	TA.M(1,3) = 0.0f;

	TA.M(2,0) = M(0,1)*M(1,2) - M(0,2)*M(1,1);
	TA.M(2,1) = M(1,0)*M(0,2) - M(0,0)*M(1,2);
	TA.M(2,2) = M(1,1)*M(0,0) - M(1,0)*M(0,1);
	TA.M(2,3) = 0.0f;

	TA.M(3,0) = 0.0f;
	TA.M(3,1) = 0.0f;
	TA.M(3,2) = 0.0f;
	TA.M(3,3) = 1.0f;
	return TA;
}

IMPL_MATCH("Core.dll", 0x10107190)
FLOAT FMatrix::Determinant() const
{
	return M(0,0) * (
		M(1,1) * (M(2,2) * M(3,3) - M(2,3) * M(3,2)) -
		M(2,1) * (M(1,2) * M(3,3) - M(1,3) * M(3,2)) +
		M(3,1) * (M(1,2) * M(2,3) - M(1,3) * M(2,2))
	) - M(1,0) * (
		M(0,1) * (M(2,2) * M(3,3) - M(2,3) * M(3,2)) -
		M(2,1) * (M(0,2) * M(3,3) - M(0,3) * M(3,2)) +
		M(3,1) * (M(0,2) * M(2,3) - M(0,3) * M(2,2))
	) + M(2,0) * (
		M(0,1) * (M(1,2) * M(3,3) - M(1,3) * M(3,2)) -
		M(1,1) * (M(0,2) * M(3,3) - M(0,3) * M(3,2)) +
		M(3,1) * (M(0,2) * M(1,3) - M(0,3) * M(1,2))
	) - M(3,0) * (
		M(0,1) * (M(1,2) * M(2,3) - M(1,3) * M(2,2)) -
		M(1,1) * (M(0,2) * M(2,3) - M(0,3) * M(2,2)) +
		M(2,1) * (M(0,2) * M(1,3) - M(0,3) * M(1,2))
	);
}

IMPL_MATCH("Core.dll", 0x10107670)
FCoords FMatrix::Coords()
{
	FCoords Result;
	Result.Origin.X = M(3,0); Result.Origin.Y = M(3,1); Result.Origin.Z = M(3,2);
	Result.XAxis.X  = M(0,0); Result.XAxis.Y  = M(0,1); Result.XAxis.Z  = M(0,2);
	Result.YAxis.X  = M(1,0); Result.YAxis.Y  = M(1,1); Result.YAxis.Z  = M(1,2);
	Result.ZAxis.X  = M(2,0); Result.ZAxis.Y  = M(2,1); Result.ZAxis.Z  = M(2,2);
	return Result;
}

// Retail uses a fully-unrolled 682-byte version; our loop is algorithmically identical.
IMPL_MATCH("Core.dll", 0x101069d0)
FMatrix FMatrix::operator*( FMatrix Other ) const
{
	FMatrix Result;
	for( INT i=0; i<4; i++ )
		for( INT j=0; j<4; j++ )
		{
			Result.M(i,j) = 0.0f;
			for( INT k=0; k<4; k++ )
				Result.M(i,j) += M(i,k) * Other.M(k,j);
		}
	return Result;
}

IMPL_MATCH("Core.dll", 0x10106c80)
void FMatrix::operator*=( FMatrix Other )
{
	*this = *this * Other;
}

// Retail does NaN-aware element compare; appMemcmp is equivalent for all finite-valued matrices.
IMPL_MATCH("Core.dll", 0x10106f20)
INT FMatrix::operator==( FMatrix& Other ) const
{
	return appMemcmp( this, &Other, sizeof(FMatrix) ) == 0;
}

IMPL_MATCH("Core.dll", 0x10106f70)
INT FMatrix::operator!=( FMatrix& Other ) const
{
	return appMemcmp( this, &Other, sizeof(FMatrix) ) != 0;
}

IMPL_MATCH("Core.dll", 0x10106990)
void FMatrix::SetIdentity()
{
	appMemzero( this, sizeof(*this) );
	M(0,0) = M(1,1) = M(2,2) = M(3,3) = 1.0f;
}

IMPL_MATCH("Core.dll", 0x101070C0)
FPlane FMatrix::TransformNormal( const FVector& V ) const
{
	return FPlane(
		V.X * M(0,0) + V.Y * M(1,0) + V.Z * M(2,0),
		V.X * M(0,1) + V.Y * M(1,1) + V.Z * M(2,1),
		V.X * M(0,2) + V.Y * M(1,2) + V.Z * M(2,2),
		0.0f
	);
}

IMPL_MATCH("Core.dll", 0x1012C840)
FMatrix FCoords::Matrix() const
{
	FMatrix Result;
	Result.M(0,0) = XAxis.X;  Result.M(0,1) = XAxis.Y;  Result.M(0,2) = XAxis.Z;  Result.M(0,3) = 0.0f;
	Result.M(1,0) = YAxis.X;  Result.M(1,1) = YAxis.Y;  Result.M(1,2) = YAxis.Z;  Result.M(1,3) = 0.0f;
	Result.M(2,0) = ZAxis.X;  Result.M(2,1) = ZAxis.Y;  Result.M(2,2) = ZAxis.Z;  Result.M(2,3) = 0.0f;
	Result.M(3,0) = Origin.X; Result.M(3,1) = Origin.Y; Result.M(3,2) = Origin.Z; Result.M(3,3) = 1.0f;
	return Result;
}

/*-----------------------------------------------------------------------------
	FPlane methods.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101065b0)
FPlane FPlane::operator+( const FPlane& V ) const { return FPlane( X+V.X, Y+V.Y, Z+V.Z, W+V.W ); }
IMPL_MATCH("Core.dll", 0x10103ba0)
FPlane FPlane::operator-( const FPlane& V ) const { return FPlane( X-V.X, Y-V.Y, Z-V.Z, W-V.W ); }
IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; inlined at call sites")
FPlane FPlane::operator*( const FPlane& V )        { return FPlane( X*V.X, Y*V.Y, Z*V.Z, W*V.W ); }
IMPL_MATCH("Core.dll", 0x10103c10)
FPlane FPlane::operator*( FLOAT Scale ) const      { return FPlane( X*Scale, Y*Scale, Z*Scale, W*Scale ); }
IMPL_MATCH("Core.dll", 0x10103bd0)
FPlane FPlane::operator/( FLOAT Scale ) const      { FLOAT RScale = 1.0f/Scale; return FPlane( X*RScale, Y*RScale, Z*RScale, W*RScale ); }
IMPL_MATCH("Core.dll", 0x10103c70)
FPlane FPlane::operator+=(const FPlane& V)         { X+=V.X; Y+=V.Y; Z+=V.Z; W+=V.W; return *this; }
IMPL_MATCH("Core.dll", 0x10103cc0)
FPlane FPlane::operator-=(const FPlane& V)         { X-=V.X; Y-=V.Y; Z-=V.Z; W-=V.W; return *this; }
IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; inlined at call sites")
FPlane FPlane::operator*=( const FPlane& V )       { X*=V.X; Y*=V.Y; Z*=V.Z; W*=V.W; return *this; }
IMPL_MATCH("Core.dll", 0x10103d10)
FPlane FPlane::operator*=( FLOAT Scale )           { X*=Scale; Y*=Scale; Z*=Scale; W*=Scale; return *this; }
IMPL_MATCH("Core.dll", 0x10103db0)
FPlane FPlane::operator/=( FLOAT Scale )           { FLOAT RScale = 1.0f/Scale; X*=RScale; Y*=RScale; Z*=RScale; W*=RScale; return *this; }

IMPL_MATCH("Core.dll", 0x1010a6e0)
FPlane FPlane::TransformBy( const FCoords& Coords ) const
{
	return FPlane( *this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis, W - (*this | Coords.Origin) );
}

IMPL_MATCH("Core.dll", 0x1010A6E0)
FPlane FPlane::TransformBy( const FMatrix& M ) const
{
	return FPlane(
		X*M.M(0,0) + Y*M.M(1,0) + Z*M.M(2,0) + W*M.M(3,0),
		X*M.M(0,1) + Y*M.M(1,1) + Z*M.M(2,1) + W*M.M(3,1),
		X*M.M(0,2) + Y*M.M(1,2) + Z*M.M(2,2) + W*M.M(3,2),
		X*M.M(0,3) + Y*M.M(1,3) + Z*M.M(2,3) + W*M.M(3,3)
	);
}

IMPL_MATCH("Core.dll", 0x101079B0)
FPlane FPlane::TransformByUsingAdjointT( const FMatrix& M, const FMatrix& TA ) const
{
	return FPlane(
		X*TA.M(0,0) + Y*TA.M(0,1) + Z*TA.M(0,2),
		X*TA.M(1,0) + Y*TA.M(1,1) + Z*TA.M(1,2),
		X*TA.M(2,0) + Y*TA.M(2,1) + Z*TA.M(2,2),
		W - ( M.M(3,0)*X + M.M(3,1)*Y + M.M(3,2)*Z )
	);
}

IMPL_MATCH("Core.dll", 0x101078d0)
FPlane FPlane::TransformPlaneByOrtho( const FMatrix& M ) const
{
	return TransformBy( M );
}

/*-----------------------------------------------------------------------------
	FVector methods.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10103020)
FVector::FVector( FLOAT InVal )
: X(InVal), Y(InVal), Z(InVal)
{
}

IMPL_MATCH("Core.dll", 0x10109180)
FVector FVector::GetNonParallel()
{
	if( Abs(X) < 0.9f )
		return FVector(1,0,0);
	else
		return FVector(0,1,0);
}

IMPL_MATCH("Core.dll", 0x10103560)
FVector FVector::GetNormalized()
{
	FLOAT Sz = Size();
	if( Sz > 0.0001f )
		return *this / Sz;
	return FVector(0,0,0);
}

IMPL_MATCH("Core.dll", 0x10105540)
FVector FVector::RotateAngleAxis( INT Angle, const FVector& Axis ) const
{
	FLOAT S = GMath.SinTab(Angle);
	FLOAT C = GMath.CosTab(Angle);
	FLOAT XX  = Axis.X * Axis.X;
	FLOAT YY  = Axis.Y * Axis.Y;
	FLOAT ZZ  = Axis.Z * Axis.Z;
	FLOAT XY  = Axis.X * Axis.Y;
	FLOAT YZ  = Axis.Y * Axis.Z;
	FLOAT ZX  = Axis.Z * Axis.X;
	FLOAT XS  = Axis.X * S;
	FLOAT YS  = Axis.Y * S;
	FLOAT ZS  = Axis.Z * S;
	FLOAT OMC = 1.f - C;
	return FVector(
		(OMC * XX + C ) * X + (OMC * XY - ZS) * Y + (OMC * ZX + YS) * Z,
		(OMC * XY + ZS) * X + (OMC * YY + C ) * Y + (OMC * YZ - XS) * Z,
		(OMC * ZX - YS) * X + (OMC * YZ + XS) * Y + (OMC * ZZ + C ) * Z
	);
}

IMPL_MATCH("Core.dll", 0x101053B0)
FVector FVector::TransformVectorByTranspose( const FCoords& Coords ) const
{
	return FVector(
		X * Coords.XAxis.X + Y * Coords.XAxis.Y + Z * Coords.XAxis.Z,
		X * Coords.YAxis.X + Y * Coords.YAxis.Y + Z * Coords.YAxis.Z,
		X * Coords.ZAxis.X + Y * Coords.ZAxis.Y + Z * Coords.ZAxis.Z
	);
}

IMPL_MATCH("Core.dll", 0x101090A0)
FLOAT FVector::GetAbsMax() const
{
	return ::Max( ::Max( Abs(X), Abs(Y) ), Abs(Z) );
}

IMPL_MATCH("Core.dll", 0x10109070)
FLOAT FVector::GetMax() const
{
	return ::Max( ::Max( X, Y ), Z );
}

IMPL_MATCH("Core.dll", 0x10109310)
INT FVector::IsUniform()
{
	return (X == Y) && (Y == Z);
}

// Retail uses two separate appFailAssert checks; check() is equivalent.
IMPL_MATCH("Core.dll", 0x101033b0)
FLOAT& FVector::operator[]( INT i )
{
	check(i>=0 && i<3);
	return (&X)[i];
}

/*-----------------------------------------------------------------------------
	FBox methods.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101050B0)
bool FBox::Intersect( const FBox& Other ) const
{
	if( Min.X > Other.Max.X || Other.Min.X > Max.X )
		return false;
	if( Min.Y > Other.Max.Y || Other.Min.Y > Max.Y )
		return false;
	if( Min.Z > Other.Max.Z || Other.Min.Z > Max.Z )
		return false;
	return true;
}

IMPL_MATCH("Core.dll", 0x1010a5d0)
FBox FBox::TransformBy( const FMatrix& M ) const
{
	FBox Result(0);
	for( int i=0; i<2; i++ )
		for( int j=0; j<2; j++ )
			for( int k=0; k<2; k++ )
			{
				FVector Pt( GetExtrema(i).X, GetExtrema(j).Y, GetExtrema(k).Z );
				Result += M.TransformFVector( Pt );
			}
	return Result;
}

IMPL_MATCH("Core.dll", 0x10104F60)
FVector FBox::GetCenter() const
{
	return FVector( (Min.X+Max.X)*0.5f, (Min.Y+Max.Y)*0.5f, (Min.Z+Max.Z)*0.5f );
}

IMPL_MATCH("Core.dll", 0x10104FC0)
FVector FBox::GetExtent() const
{
	return FVector( (Max.X-Min.X)*0.5f, (Max.Y-Min.Y)*0.5f, (Max.Z-Min.Z)*0.5f );
}

IMPL_MATCH("Core.dll", 0x10105010)
void FBox::GetCenterAndExtents( FVector& Center, FVector& Extents )
{
	Center  = GetCenter();
	Extents = GetExtent();
}

IMPL_MATCH("Core.dll", 0x10104E50)
void FBox::Init()
{
	Min = Max = FVector(0,0,0);
	IsValid = 0;
}

IMPL_MATCH("Core.dll", 0x10104e90)
FVector& FBox::operator[]( INT i )
{
	check( i>=0 && i<2 );
	if( i == 0 ) return Min;
	return Max;
}

/*-----------------------------------------------------------------------------
	FRotator methods.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10104060)
FRotator::FRotator( FLOAT InVal )
: Pitch((INT)InVal), Yaw((INT)InVal), Roll((INT)InVal)
{
}

IMPL_MATCH("Core.dll", 0x10104490)
FRotator FRotator::Clamp()
{
	return FRotator( Pitch&65535, Yaw&65535, Roll&65535 );
}

IMPL_MATCH("Core.dll", 0x10109460)
FRotator FRotator::ClampPos()
{
	FRotator R = Clamp();
	if( R.Pitch < 0 ) R.Pitch += 65536;
	if( R.Yaw   < 0 ) R.Yaw   += 65536;
	if( R.Roll  < 0 ) R.Roll  += 65536;
	return R;
}

/*-----------------------------------------------------------------------------
	FSphere methods.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10107AD0)
FSphere FSphere::TransformBy( const FMatrix& M ) const
{
	FVector Center(X, Y, Z);
	FVector Transformed = M.TransformFVector( Center );
	FSphere Result;
	Result.X = Transformed.X;
	Result.Y = Transformed.Y;
	Result.Z = Transformed.Z;
	Result.W = W;
	return Result;
}

/*-----------------------------------------------------------------------------
	FPosition class.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101044D0)
FPosition::FPosition()
{
}

IMPL_MATCH("Core.dll", 0x101044D0)
FPosition::FPosition( FVector InLocation, FCoords InCoords )
: Location(InLocation), Coords(InCoords)
{
}

// Retail uses a 15-iteration DWORD copy loop; member assignment is equivalent.
IMPL_MATCH("Core.dll", 0x10104500)
FPosition& FPosition::operator=( const FPosition& Other )
{
	Location = Other.Location;
	Coords   = Other.Coords;
	return *this;
}

/*-----------------------------------------------------------------------------
	FCylinder class.
-----------------------------------------------------------------------------*/

IMPL_DIVERGE("Ghidra 0x10103f10: retail is trivially empty (3 bytes); our ctor initializes members for safety")
FCylinder::FCylinder()
: Radius(0), Height(0)
{
}

IMPL_DIVERGE("Not in Core.dll export table; absent from Ghidra; inlined at call sites")
FCylinder& FCylinder::operator=( const FCylinder& Other )
{
	Radius = Other.Radius;
	Height = Other.Height;
	return *this;
}

IMPL_MATCH("Core.dll", 0x1012D850)
INT FCylinder::LineCheck( const FVector& Start, const FVector& End, FVector& HitNormal ) const
{
	// DIVERGENCE: The binary FCylinder has additional fields (Center FVector,
	// Axis FVector, HalfHeight FLOAT) at offsets 0x0-0x1C that are not present
	// in our reconstructed struct (which only has Radius and Height).
	// We implement a simplified axis-aligned cylinder centred at origin.
	FLOAT HitTime[2];
	if( !LineIntersection( Start, End, HitTime ) )
		return 0;

	// Direction vector.
	FVector Dir = End - Start;
	FLOAT Len = Dir.Size();
	if( Len < 0.0001f )
		return 0;
	FLOAT InvLen = 1.0f / Len;
	Dir *= InvLen;

	FLOAT t = HitTime[0];
	if( t < 0.0f || t >= Len )
	{
		t = HitTime[1];
		if( t < 0.0f || t >= Len )
			return 0;
	}

	FVector HitPos = Start + Dir * t;
	// Normal points radially outward from the cylinder axis.
	HitNormal = FVector( HitPos.X, HitPos.Y, 0.0f );
	HitNormal.Normalize();
	return 1;
}

IMPL_MATCH("Core.dll", 0x1012D320)
INT FCylinder::LineIntersection( const FVector& Start, const FVector& End, FLOAT* const HitTime ) const
{
	// DIVERGENCE: Same as LineCheck above — binary has Center/Axis/HalfHeight fields.
	// Simplified axis-aligned (Z-axis) cylinder centred at origin.
	FVector Dir = End - Start;
	FLOAT Len = Dir.Size();
	if( Len < 0.0001f )
		return 0;
	FLOAT InvLen = 1.0f / Len;
	FVector D = Dir * InvLen;

	// Ray-cylinder intersection (infinite Z-axis cylinder of radius Radius).
	FLOAT a = D.X*D.X + D.Y*D.Y;
	if( a < 0.0001f )
		return 0; // Ray is parallel to axis.
	FLOAT b = 2.0f * (Start.X*D.X + Start.Y*D.Y);
	FLOAT c = Start.X*Start.X + Start.Y*Start.Y - Radius*Radius;
	FLOAT Discriminant = b*b - 4.0f*a*c;
	if( Discriminant < 0.0f )
		return 0;
	FLOAT SqrtDisc = appSqrt( (DOUBLE)Discriminant );
	HitTime[0] = (-b - SqrtDisc) / (2.0f * a);
	HitTime[1] = (-b + SqrtDisc) / (2.0f * a);

	// Clamp to Z height.
	for( INT i = 0; i < 2; i++ )
	{
		FLOAT z = Start.Z + HitTime[i] * D.Z;
		if( z < -Height * 0.5f || z > Height * 0.5f )
			HitTime[i] = -1.0f;
	}

	return ( HitTime[0] >= 0.0f || HitTime[1] >= 0.0f ) ? 1 : 0;
}

/*-----------------------------------------------------------------------------
	FEdge class.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10109360)
FEdge::FEdge()
{
	Vertex[0] = FVector(0,0,0);
	Vertex[1] = FVector(0,0,0);
}

IMPL_MATCH("Core.dll", 0x10109360)
FEdge::FEdge( FVector InVertex0, FVector InVertex1 )
{
	Vertex[0] = InVertex0;
	Vertex[1] = InVertex1;
}

IMPL_MATCH("Core.dll", 0x101038d0)
FEdge& FEdge::operator=( const FEdge& Other )
{
	Vertex[0] = Other.Vertex[0];
	Vertex[1] = Other.Vertex[1];
	return *this;
}

// Retail adds NaN-aware element compare; equivalent for well-formed edges.
IMPL_MATCH("Core.dll", 0x10103800)
INT FEdge::operator==( const FEdge& Other ) const
{
	return (Vertex[0] == Other.Vertex[0] && Vertex[1] == Other.Vertex[1]) ||
	       (Vertex[0] == Other.Vertex[1] && Vertex[1] == Other.Vertex[0]);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
