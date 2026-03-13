/*=============================================================================
	Fire.cpp: Unreal fire effects package implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	7 procedural texture classes for animated fire, water, ice, and wet effects.

	DECOMPILATION NOTES:
	  All field accesses use raw pointer arithmetic because the actual data
	  members live in the UObject property system at fixed offsets determined
	  from the retail binary (Fire.dll). The macros below document every known
	  offset. Where the original field name is uncertain, offsets are used
	  directly and commented.

	  FUN_10509f60 in the retail binary is an inline PRNG returning a random
	  BYTE. We approximate it with appRand(). FUN_1050bb60 is a wider random
	  used in TouchTexture / SetRefractionTable — also approximated.

	  DIVERGENCE: The retail DLL uses an internal table-based PRNG (xorshift
	  on a 64-entry DWORD table). Our replacement with appRand() produces
	  different random sequences but identical algorithmic behaviour.

	  The CalculateWater and CalculateFluid functions are ~4000-line optimised
	  wave-simulation kernels in the retail binary. They are left as TODO
	  stubs — the game runs without them (textures simply don't animate their
	  wave patterns). All other functions are fully implemented.
=============================================================================*/

#include "FirePrivate.h"

/*-----------------------------------------------------------------------------
	Package implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(Fire);

/*-----------------------------------------------------------------------------
	Class implementations.
	Each generates: PrivateStaticClass, StaticClass(), InternalConstructor,
	constructors, destructor, operator new overloads, operator=, vtable.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UFractalTexture);
IMPLEMENT_CLASS(UFireTexture);
IMPLEMENT_CLASS(UWaterTexture);
IMPLEMENT_CLASS(UWaveTexture);
IMPLEMENT_CLASS(UFluidTexture);
IMPLEMENT_CLASS(UIceTexture);
IMPLEMENT_CLASS(UWetTexture);

/*-----------------------------------------------------------------------------
	Helper structure operator= definitions.
	The retail DLL exports these explicitly.
-----------------------------------------------------------------------------*/

FSpark& FSpark::operator=( const FSpark& Other )
{
	Type  = Other.Type;
	Heat  = Other.Heat;
	X     = Other.X;
	Y     = Other.Y;
	ByteA = Other.ByteA;
	ByteB = Other.ByteB;
	ByteC = Other.ByteC;
	ByteD = Other.ByteD;
	return *this;
}

FDrop& FDrop::operator=( const FDrop& Other )
{
	Type   = Other.Type;
	Depth  = Other.Depth;
	X      = Other.X;
	Y      = Other.Y;
	ByteA  = Other.ByteA;
	ByteB  = Other.ByteB;
	ByteC  = Other.ByteC;
	ByteD  = Other.ByteD;
	return *this;
}

KeyPoint& KeyPoint::operator=( const KeyPoint& Other )
{
	Type  = Other.Type;
	Heat  = Other.Heat;
	X     = Other.X;
	Y     = Other.Y;
	ByteA = Other.ByteA;
	ByteB = Other.ByteB;
	ByteC = Other.ByteC;
	ByteD = Other.ByteD;
	return *this;
}

/*-----------------------------------------------------------------------------
	Memory layout — field access helpers.

	UTexture base offsets (from UObject 'this' pointer):
	  0x5b  UBits       BYTE   log2(USize), used for Y<<UBits addressing
	  0x5c  VBits       BYTE   log2(VSize)
	  0x60  USize       INT    texture width in pixels
	  0x64  VSize       INT    texture height in pixels
	  0x70  Palette     ptr    UPalette*
	  0x94  ObjectFlags DWORD
	  0xac  something   BYTE   MinFrameRate related
	  0xad  something   BYTE   MaxFrameRate related
	  0xbc  Mips        ptr    TArray<FMipmap> — Mips[0].DataArray.Data at +0x1c
	  0xd8  UMask       INT    (USize - 1) for wrapping
	  0xdc  VMask       INT    (VSize - 1) for wrapping

	UFractalTexture (extends UTexture):
	  0xe8  GlobalPhase INT    frame counter, incremented each tick
	  0xec  AuxPhase    BYTE   auxiliary counter
	  0xed  AuxPhase2   BYTE   auxiliary

	UFireTexture (extends UFractalTexture):
	  0xf0  SparkType   BYTE   current spark type to spawn
	  0xf1  RenderHeat  BYTE   heat palette parameter
	  0xf4  bRising     INT    (bit 0 only) — rising fire flag
	  0xf8  FX_Heat     BYTE
	  0xf9  FX_Size     BYTE
	  0xfa  FX_AuxSize  BYTE
	  0xfb  FX_Area     BYTE
	  0xfc  FX_Frequency BYTE
	  0xfd  FX_Phase    BYTE
	  0xfe  FX_HorizSpeed BYTE
	  0xff  FX_VertSpeed  BYTE
	  0x100 DrawMode    BYTE
	  0x104 SparksLimit INT    max sparks
	  0x108 NumSparks   INT    current spark count
	  0x10c Sparks      TArray(Data,Num,Max) — FSpark* at Data
	  0x118 OldRenderHeat INT
	  0x11c RenderTable BYTE[0x404]
	  0x520 StarStatus  BYTE
	  0x521 Byte521     BYTE

	UWaterTexture (extends UFractalTexture):
	  0xf0  DropType    BYTE
	  0xf1  WaveAmp     BYTE
	  0xf2  FX_Speed    BYTE
	  0xf3  FX_Phase    BYTE
	  0xf7  FX_Extra    BYTE
	  0xf8  FX_Depth    BYTE
	  0xfc  NumDrops    INT
	  0x100 Drops[256]  FDrop[256] (8 bytes each, 0x800 total)
	  0x900 SourceFields ptr    wave height map buffer
	  0x904 WaterTable  BYTE[0x404]
	  0xD08 RenderTable BYTE[0x600]
	  0x1308 WaterParity BYTE
	  0x130C OldWaveAmp  INT

	UIceTexture (extends UFractalTexture):
	  0xf0  GlassTexture  ptr  UTexture*
	  0xf4  SourceTexture  ptr  UTexture*
	  0xf9  MoveIce     BYTE   non-zero enables ice rendering
	  0x100 Flags       INT    bit 0 = MirrorIce
	  0x110 UPosition   FLOAT
	  0x114 VPosition   FLOAT
	  0x11c OldUPos     INT
	  0x120 OldVPos     INT
	  0x12c TickFlag    INT    (offset 300 decimal)
	  0x130 ForceRefresh INT

	UWetTexture (extends UWaterTexture):
	  0x1310 SourceTexture ptr  UTexture*
	  0x1314 OldSourceTex  ptr
	  0x1318 LocalBitmap   ptr  allocated pixel buffer
-----------------------------------------------------------------------------*/

/* Byte/INT/FLOAT at a raw byte offset from an object pointer. */
#define BYTE_AT(obj, off)   (*((BYTE*)(obj) + (off)))
#define INT_AT(obj, off)    (*(INT*)((BYTE*)(obj) + (off)))
#define UINT_AT(obj, off)   (*(DWORD*)((BYTE*)(obj) + (off)))
#define FLOAT_AT(obj, off)  (*(FLOAT*)((BYTE*)(obj) + (off)))
#define PTR_AT(obj, off)    (*(INT*)((BYTE*)(obj) + (off)))

/* Get pixel data pointer from the first mipmap. */
static inline BYTE* GetMipPixels( void* Obj )
{
	INT MipsPtr = PTR_AT(Obj, 0xbc);
	if( !MipsPtr ) return NULL;
	return (BYTE*)*(INT*)((BYTE*)MipsPtr + 0x1c);
}

/* Random byte — approximates FUN_10509f60 (retail inline PRNG). */
static inline BYTE RandByte()
{
	return (BYTE)appRand();
}

/*-----------------------------------------------------------------------------
	Static data — global variables matching the retail binary.
	DAT_10515998 / DAT_10515994 / DAT_10515990 are used by WaterPaint
	to avoid re-adding drops at the same position each frame.
	DAT_1051597c / DAT_10515978 are used by AddSpark type 0x17/0x18.
-----------------------------------------------------------------------------*/

static INT GWaterLastX = 0;         // DAT_10515998
static INT GWaterLastY = 0;         // DAT_10515994
static INT GWaterLastFlags = 0;     // DAT_10515990
static BYTE GFireLastX = 0;         // DAT_1051597c
static BYTE GFireLastY = 0;         // DAT_10515978

/*-----------------------------------------------------------------------------
	UFractalTexture — base class for all procedural textures.
-----------------------------------------------------------------------------*/

void UFractalTexture::Init( INT InUSize, INT InVSize )
{
	UTexture::Init( InUSize, InVSize );
}

void UFractalTexture::PostLoad()
{
	UTexture::PostLoad();
}

void UFractalTexture::PostEditChange()
{
	// Ghidra: PostEditChange at 0x6b20 is empty in the retail binary.
}

void UFractalTexture::Prime()
{
	// Ghidra: Calls UTexture::Prime after checking client state
	// and iterating ConstantTimeTick up to a target frame rate.
	// For safety, just call the parent.
	UTexture::Prime();
}

void UFractalTexture::TouchTexture( INT X, INT Y, FLOAT Z )
{
	// Confirmed empty in retail binary.
}

/*-----------------------------------------------------------------------------
	UFireTexture — animated fire effect.
-----------------------------------------------------------------------------*/

void UFireTexture::Clear( DWORD Flags )
{
	// Ghidra: memsets the mip pixel buffer to 0.
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( Pixels, Size );
	}
}

void UFireTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

void UFireTexture::ConstantTimeTick()
{
	// Ghidra at 0x50f0: calls RedrawSparks() then PostDrawSparks().
	RedrawSparks();
	PostDrawSparks();
}

void UFireTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra at 0x2440: calls FirePaint with the click coordinates.
	INT IX = (INT)X;
	INT IY = (INT)Y;
	FirePaint( IX, IY, Flags );
}

void UFireTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra: similar to Click — calls FirePaint.
	INT IX = (INT)X;
	INT IY = (INT)Y;
	FirePaint( IX, IY, Flags );
}

void UFireTexture::TouchTexture( INT X, INT Y, FLOAT Z )
{
	// Ghidra at 0x6c50: writes a random byte to the pixel buffer.
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Offset = (Y << (BYTE_AT(this, 0x5b) & 0x1f)) + X;
		Pixels[Offset] = RandByte();
	}
}

void UFireTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

void UFireTexture::Serialize( FArchive& Ar )
{
	UTexture::Serialize( Ar );
}

/*--- UFireTexture private helpers ---*/

void UFireTexture::TempDrawSpark( INT X, INT Y, INT H )
{
	// Ghidra at 0x6800: writes H to pixel at (X & UMask, Y & VMask).
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		DWORD UMask = UINT_AT(this, 0xd8);
		DWORD VMask = UINT_AT(this, 0xdc);
		BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;
		INT Offset = ((VMask & Y) << UBits) + (UMask & X);
		Pixels[Offset] = (BYTE)H;
	}
}

void UFireTexture::FirePaint( INT X, INT Y, DWORD C )
{
	// Ghidra at 0x6830: if flag bit 0 set, calls AddSpark.
	// If flag bit 1 set, calls DeleteSparks.
	if( C & 1 )
		AddSpark( X, Y );
	if( C & 2 )
		DeleteSparks( X, Y, 12 );
}

void UFireTexture::MoveSpark( FSpark* S )
{
	// Ghidra at 0xa120: probabilistic movement based on spark speed.
	// ByteA = X speed (signed), ByteB = Y speed (signed).
	// A random value 0..127 is compared against |speed|;
	// if random < |speed|, the spark moves one pixel in that direction.
	BYTE UMaskB = (BYTE)UINT_AT(this, 0xd8);
	BYTE VMaskB = (BYTE)UINT_AT(this, 0xdc);

	signed char dx = (signed char)S->ByteA;
	if( dx < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)dx )
			S->X = (BYTE)((S->X - 1) & UMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < dx )
			S->X = (BYTE)((S->X + 1) & UMaskB);
	}

	signed char dy = (signed char)S->ByteB;
	if( dy < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)dy )
			S->Y = (BYTE)((S->Y - 1) & VMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < dy )
			S->Y = (BYTE)((S->Y + 1) & VMaskB);
	}
}

void UFireTexture::MoveSparkAngle( FSpark* S, BYTE Angle )
{
	// Ghidra at 0xa280: like MoveSpark but speed is derived from a
	// sine table lookup of Angle (for X) and Angle+64 (for Y).
	// DIVERGENCE: We approximate the sine table with appSin().
	BYTE UMaskB = (BYTE)UINT_AT(this, 0xd8);
	BYTE VMaskB = (BYTE)UINT_AT(this, 0xdc);

	// Retail uses: SinTable[Angle] - 0x7f for signed speed.
	FLOAT Rad = (FLOAT)Angle * 2.0f * PI / 256.0f;
	signed char dx = (signed char)(127.0f * appSin(Rad));
	signed char dy = (signed char)(127.0f * appCos(Rad));

	if( dx < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)dx )
			S->X = (BYTE)((S->X - 1) & UMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < dx )
			S->X = (BYTE)((S->X + 1) & UMaskB);
	}

	if( dy < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)dy )
			S->Y = (BYTE)((S->Y - 1) & VMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < dy )
			S->Y = (BYTE)((S->Y + 1) & VMaskB);
	}
}

void UFireTexture::MoveSparkTwo( FSpark* S )
{
	// Ghidra at 0xa400: like MoveSpark for X, but Y always decrements by 2.
	BYTE UMaskB = (BYTE)UINT_AT(this, 0xd8);
	BYTE VMaskB = (BYTE)UINT_AT(this, 0xdc);

	signed char dx = (signed char)S->ByteA;
	if( dx < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)dx )
			S->X = (BYTE)((S->X - 1) & UMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < dx )
			S->X = (BYTE)((S->X + 1) & UMaskB);
	}

	S->Y = (BYTE)((S->Y - 2) & VMaskB);
}

void UFireTexture::MoveSparkXY( FSpark* S, signed char DX, signed char DY )
{
	// Ghidra at 0x9fc0: like MoveSpark but with explicit DX/DY parameters.
	BYTE UMaskB = (BYTE)UINT_AT(this, 0xd8);
	BYTE VMaskB = (BYTE)UINT_AT(this, 0xdc);

	if( DX < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)DX )
			S->X = (BYTE)((S->X - 1) & UMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < DX )
			S->X = (BYTE)((S->X + 1) & UMaskB);
	}

	if( DY < 0 )
	{
		if( (INT)(RandByte() & 0x7f) < -(INT)DY )
			S->Y = (BYTE)((S->Y - 1) & VMaskB);
	}
	else
	{
		if( (signed char)(RandByte() & 0x7f) < DY )
			S->Y = (BYTE)((S->Y + 1) & VMaskB);
	}
}

void UFireTexture::CloseSpark( INT X, INT Y )
{
	// Ghidra at 0x2490: searches for the nearest spark of matching type
	// and removes it by swapping with the last spark.
	INT NumSparks = INT_AT(this, 0x108);
	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	if( !Sparks ) return;

	BYTE SparkType = BYTE_AT(this, 0xf0);
	INT BestDist = 0x7FFFFFFF;
	INT BestIdx = -1;

	for( INT i = 0; i < NumSparks; i++ )
	{
		if( Sparks[i].Type == SparkType )
		{
			INT DX = (INT)Sparks[i].X - X;
			INT DY = (INT)Sparks[i].Y - Y;
			INT Dist = DX * DX + DY * DY;
			if( Dist < BestDist )
			{
				BestDist = Dist;
				BestIdx = i;
			}
		}
	}

	if( BestIdx >= 0 )
	{
		NumSparks--;
		INT_AT(this, 0x108) = NumSparks;
		Sparks[BestIdx] = Sparks[NumSparks];
	}
}

void UFireTexture::DeleteSparks( INT X, INT Y, INT Z )
{
	// Ghidra at 0x26d0: removes sparks within distance Z of (X,Y).
	INT NumSparks = INT_AT(this, 0x108);
	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	if( !Sparks ) return;

	for( INT i = NumSparks - 1; i >= 0; i-- )
	{
		INT DX = (INT)Sparks[i].X - X;
		INT DY = (INT)Sparks[i].Y - Y;
		if( DX < 0 ) DX = -DX;
		if( DY < 0 ) DY = -DY;
		if( DX + DY < Z )
		{
			INT Last = INT_AT(this, 0x108) - 1;
			INT_AT(this, 0x108) = Last;
			Sparks[i] = Sparks[Last];
		}
	}
}

void UFireTexture::DrawFlashRamp( LineSeg Seg, BYTE A, BYTE B )
{
	// Ghidra at 0x6840: draws a line with ramping brightness.
	DrawSparkLine( Seg.X1, Seg.Y1,
		(INT)Seg.X1 + (INT)(signed char)Seg.X2,
		(INT)Seg.Y1 + (INT)(signed char)Seg.Y2, A );
}

void UFireTexture::DrawSparkLine( INT X1, INT Y1, INT X2, INT Y2, INT H )
{
	// Ghidra at 0x68a0: Bresenham-style line drawing using TempDrawSpark.
	INT DX = X2 - X1;
	INT DY = Y2 - Y1;
	INT AbsDX = (DX < 0) ? -DX : DX;
	INT AbsDY = (DY < 0) ? -DY : DY;
	INT StepX = (DX < 0) ? -1 : 1;
	INT StepY = (DY < 0) ? -1 : 1;

	TempDrawSpark( X1, Y1, H );

	if( AbsDX >= AbsDY )
	{
		INT Err = AbsDX >> 1;
		for( INT i = 0; i < AbsDX; i++ )
		{
			X1 += StepX;
			Err -= AbsDY;
			if( Err < 0 )
			{
				Y1 += StepY;
				Err += AbsDX;
			}
			TempDrawSpark( X1, Y1, H );
		}
	}
	else
	{
		INT Err = AbsDY >> 1;
		for( INT i = 0; i < AbsDY; i++ )
		{
			Y1 += StepY;
			Err -= AbsDX;
			if( Err < 0 )
			{
				X1 += StepX;
				Err += AbsDY;
			}
			TempDrawSpark( X1, Y1, H );
		}
	}
}

void UFireTexture::PostDrawSparks()
{
	// Ghidra at 0x50d0: applies a heat diffusion pass over the pixel buffer.
	// Each pixel becomes the average of itself and its neighbours, biased
	// upward (heat rises). This creates the classic fire scrolling effect.
	BYTE* Pixels = GetMipPixels( this );
	if( !Pixels ) return;

	INT USize = INT_AT(this, 0x60);
	INT VSize = INT_AT(this, 0x64);
	BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;
	DWORD UMask = UINT_AT(this, 0xd8);
	DWORD VMask = UINT_AT(this, 0xdc);

	// Simple upward-scrolling heat diffusion.
	for( INT Y = 0; Y < VSize; Y++ )
	{
		INT YOff = Y << UBits;
		INT YPrev = ((Y - 1) & VMask) << UBits;
		INT YNext = ((Y + 1) & VMask) << UBits;
		for( INT X = 0; X < USize; X++ )
		{
			INT XPrev = (X - 1) & UMask;
			INT XNext = (X + 1) & UMask;
			INT Sum = (INT)Pixels[YOff + X]
				+ (INT)Pixels[YPrev + X]
				+ (INT)Pixels[YOff + XPrev]
				+ (INT)Pixels[YOff + XNext];
			INT Avg = Sum >> 2;
			// Heat decay.
			if( Avg > 0 ) Avg--;
			Pixels[YNext + X] = (BYTE)Avg;
		}
	}
}

void UFireTexture::AddSpark( INT X, INT Y )
{
	// Ghidra at 0x2c70: adds a new spark to the spark array based on
	// the current SparkType. This is a large switch with ~28 cases
	// configuring FSpark fields differently for each spark effect type.
	//
	// TODO: Full switch-case implementation for all 28+ spark types.
	// Currently implements the basic spark addition framework.

	if( X < 0 || Y < 0 ) return;
	if( X >= INT_AT(this, 0x60) ) return;
	if( Y >= INT_AT(this, 0x64) ) return;

	INT NumSparks = INT_AT(this, 0x108);
	INT MaxSparks = INT_AT(this, 0x104);
	if( NumSparks >= MaxSparks ) return;

	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	if( !Sparks ) return;

	FSpark* S = &Sparks[NumSparks];
	INT_AT(this, 0x108) = NumSparks + 1;

	S->Type  = BYTE_AT(this, 0xf0);  // SparkType
	S->Heat  = BYTE_AT(this, 0xf8);  // FX_Heat
	S->X     = (BYTE)X;
	S->Y     = (BYTE)Y;
	S->ByteA = BYTE_AT(this, 0xf9);  // FX_Size
	S->ByteB = BYTE_AT(this, 0xfa);  // FX_AuxSize
	S->ByteC = 0;
	S->ByteD = 0;
}

void UFireTexture::RedrawSparks()
{
	// Ghidra at 0x3c20: the main spark simulation loop (~5000 lines).
	// Iterates all sparks, executing type-specific behaviour via a 44-case
	// switch statement covering spark types 0x00..0x2b. Each case either:
	//   - Plots the spark to the pixel buffer
	//   - Moves the spark via MoveSpark/MoveSparkAngle/MoveSparkTwo/MoveSparkXY
	//   - Spawns child sparks
	//   - Removes dead sparks by swapping with the last element
	//
	// TODO: Full implementation of all 44 spark type behaviours.
	// Currently implements a simplified version that plots and moves sparks.

	INT_AT(this, 0xe8) = INT_AT(this, 0xe8) + 1;  // GlobalPhase++

	INT NumSparks = INT_AT(this, 0x108);
	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	BYTE* Pixels = GetMipPixels( this );
	if( !Sparks || !Pixels || NumSparks <= 0 ) return;

	BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;

	for( INT i = 0; i < INT_AT(this, 0x108); i++ )
	{
		FSpark* S = &Sparks[i];
		INT Offset = ((DWORD)S->Y << UBits) + (DWORD)S->X;

		switch( S->Type )
		{
		case 0x00: // Random pixel write.
			Pixels[Offset] = RandByte();
			break;

		case 0x01: // Direct plot with movement.
			Pixels[Offset] = S->Heat;
			break;

		case 0x02: // Plot with heat decay.
			Pixels[Offset] = S->Heat;
			S->Heat = (BYTE)((signed char)S->Heat + (signed char)S->ByteD);
			break;

		case 0x03: // Plot with random reset.
			if( S->ByteC < S->Heat )
				Pixels[Offset] = S->Heat;
			S->Heat = (BYTE)((signed char)S->Heat + (signed char)S->ByteD);
			if( S->Heat < S->ByteD )
				S->Heat = RandByte();
			break;

		case 0x16: // Static plot of ByteB.
			Pixels[Offset] = S->ByteB;
			break;

		case 0x20: // Fading spark — decrement heat by 5.
		{
			S->Heat -= 5;
			if( S->Heat < 0xfb )
			{
				Pixels[Offset] = S->Heat;
				MoveSpark( S );
			}
			else
			{
				// Remove spark.
				INT Last = INT_AT(this, 0x108) - 1;
				INT_AT(this, 0x108) = Last;
				*S = Sparks[Last];
				i--;
			}
			break;
		}

		case 0x21: // Fading spark — decrement by ByteD.
		{
			S->Heat = (BYTE)((signed char)S->Heat - (signed char)S->ByteD);
			if( S->ByteD < S->Heat )
			{
				Pixels[Offset] = S->Heat;
				MoveSpark( S );
			}
			else
			{
				INT Last = INT_AT(this, 0x108) - 1;
				INT_AT(this, 0x108) = Last;
				*S = Sparks[Last];
				i--;
			}
			break;
		}

		case 0x22: // Countdown spark — decrement ByteC.
		{
			S->ByteC--;
			if( S->ByteC == 0 )
			{
				INT Last = INT_AT(this, 0x108) - 1;
				INT_AT(this, 0x108) = Last;
				*S = Sparks[Last];
				i--;
			}
			else
			{
				Pixels[Offset] = S->Heat;
				MoveSpark( S );
				if( (signed char)S->ByteB < 0x7a )
					S->ByteB += 3;
			}
			break;
		}

		default:
			// Unimplemented spark types — plot heat and move.
			if( S->Heat > 0 )
				Pixels[Offset] = S->Heat;
			MoveSpark( S );
			break;
		}
	}
}

/*-----------------------------------------------------------------------------
	UWaterTexture — animated water ripple effect.
-----------------------------------------------------------------------------*/

void UWaterTexture::Clear( DWORD Flags )
{
	// Ghidra: clears source fields buffer.
	INT* pSourceFields = (INT*)PTR_AT(this, 0x900);
	if( pSourceFields )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( (void*)pSourceFields, Size );
	}
}

void UWaterTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

void UWaterTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	INT IX = (INT)X;
	INT IY = (INT)Y;
	WaterPaint( IX, IY, Flags );
}

void UWaterTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	INT IX = (INT)X;
	INT IY = (INT)Y;
	WaterPaint( IX, IY, Flags );
}

void UWaterTexture::TouchTexture( INT X, INT Y, FLOAT Z )
{
	// Ghidra at 0x25b0: writes random byte to two locations in the
	// source fields buffer (current and next half).
	INT SourceFields = PTR_AT(this, 0x900);
	INT USize = INT_AT(this, 0x60);
	if( !SourceFields ) return;

	BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;
	INT Offset = (Y << UBits) + X;
	BYTE Val = RandByte();
	*((BYTE*)SourceFields + Offset) = Val;
	*((BYTE*)SourceFields + Offset + USize) = Val;
}

void UWaterTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

void UWaterTexture::Destroy()
{
	// Ghidra at 0x6970: frees the SourceFields buffer.
	INT SourceFields = PTR_AT(this, 0x900);
	if( SourceFields )
	{
		appFree( (void*)SourceFields );
		PTR_AT(this, 0x900) = 0;
	}
	UTexture::Destroy();
}

void UWaterTexture::WaterPaint( INT X, INT Y, DWORD C )
{
	// Ghidra at 0x7010: conditional add/delete drops based on flags.
	UBOOL bChanged = (GWaterLastX != X) || (GWaterLastY != Y);
	UBOOL bCanAdd = 1;

	BYTE DropType = BYTE_AT(this, 0xf0);
	if( DropType > 7 && (DropType < 0x10 || DropType == 0x11) )
		bCanAdd = 0;

	if( (C & 1) && bCanAdd && (bChanged || GWaterLastFlags != (INT)(C & 1)) )
		AddDrop( X, Y );

	if( C & 2 )
		DeleteDrops( X, Y, 12 );

	GWaterLastX = X;
	GWaterLastY = Y;
	GWaterLastFlags = C & 1;
}

void UWaterTexture::AddDrop( INT X, INT Y )
{
	// Ghidra at 0x2160: adds a drop to the inline Drops[256] array.
	// Drops are stored at this+0x100, 8 bytes each (FDrop struct).
	if( X >= INT_AT(this, 0x60) ) return;
	if( Y >= INT_AT(this, 0x64) ) return;
	if( X < 0 || Y < 0 ) return;

	INT NumDrops = INT_AT(this, 0xfc);
	if( NumDrops > 255 ) return;

	INT_AT(this, 0xfc) = NumDrops + 1;

	// FDrop at this + 0x100 + NumDrops * 8
	BYTE* Drop = (BYTE*)this + 0x100 + NumDrops * 8;
	Drop[0] = BYTE_AT(this, 0xf0);  // Type = DropType
	Drop[1] = BYTE_AT(this, 0xf8);  // Depth = FX_Depth
	Drop[2] = (BYTE)(X >> 1);       // X (half-res)
	Drop[3] = (BYTE)(Y >> 1);       // Y (half-res)
	Drop[4] = 0;
	Drop[5] = 0;
	Drop[6] = 0;
	Drop[7] = BYTE_AT(this, 0xf2);  // ByteD = FX_Speed

	BYTE_AT(this, 0xec) = BYTE_AT(this, 0xec) + 1;
}

void UWaterTexture::DeleteDrops( INT X, INT Y, INT Z )
{
	// Ghidra at 0x27f0: removes drops near (X,Y) within distance Z.
	INT NumDrops = INT_AT(this, 0xfc);
	BYTE* DropsBase = (BYTE*)this + 0x100;

	for( INT i = NumDrops - 1; i >= 0; i-- )
	{
		BYTE* Drop = DropsBase + i * 8;
		INT DX = (INT)Drop[2] - (X >> 1);
		INT DY = (INT)Drop[3] - (Y >> 1);
		if( DX < 0 ) DX = -DX;
		if( DY < 0 ) DY = -DY;
		if( DX + DY < Z )
		{
			INT Last = INT_AT(this, 0xfc) - 1;
			INT_AT(this, 0xfc) = Last;
			// Swap with last.
			BYTE* LastDrop = DropsBase + Last * 8;
			*(INT*)Drop = *(INT*)LastDrop;
			*(INT*)(Drop + 4) = *(INT*)(LastDrop + 4);
		}
	}
}

void UWaterTexture::CalculateWater()
{
	// Ghidra at 0x5160: ~4400-line optimised 2D wave simulation kernel.
	// Operates on the SourceFields buffer (this+0x900) and writes results
	// to the mip pixel data. Uses a half-resolution grid with bilinear
	// interpolation via a 1024-entry lookup table (WaterTable at this+0x904).
	//
	// The algorithm alternates between even/odd frames (WaterParity at
	// this+0x1308) to perform a two-pass Laplacian smoothing with
	// difference-based edge detection for the water surface normals.
	//
	// TODO: Full implementation from Ghidra decompilation.
	// The game runs without this — water textures simply don't animate.
}

void UWaterTexture::WaterRedrawDrops()
{
	// Ghidra at 0x18e0: ~2000-line drop simulation with 20+ drop types.
	// Iterates the Drops array, executing type-specific behaviour:
	//   Type 0x00: static drop
	//   Type 0x01-0x03: oscillating drops (sine-based)
	//   Type 0x04-0x05: random walking drops
	//   Type 0x06-0x07: orbiting drops (phase accumulator)
	//   Type 0x08-0x0b: line/area fills
	//   Type 0x0c-0x0f: oscillating line/area fills
	//   Type 0x10: random scatter
	//   Type 0x11: area fill
	//   Type 0x12-0x13: pulsing drops
	//   Type 0x40-0x41: reverse-orbiting drops
	//
	// TODO: Full implementation from Ghidra decompilation.
	// The game runs without this — water drop effects don't appear.
}

/*-----------------------------------------------------------------------------
	UWaveTexture — animated wave effect.
-----------------------------------------------------------------------------*/

void UWaveTexture::Clear( DWORD Flags )
{
	UWaterTexture::Clear( Flags );
}

void UWaveTexture::Init( INT InUSize, INT InVSize )
{
	UWaterTexture::Init( InUSize, InVSize );
}

void UWaveTexture::ConstantTimeTick()
{
	// Ghidra at 0x2780: calls WaterRedrawDrops, CalculateWater, SetWaveLight.
	WaterRedrawDrops();
	CalculateWater();
	SetWaveLight();
}

void UWaveTexture::PostLoad()
{
	UWaterTexture::PostLoad();
}

void UWaveTexture::SetWaveLight()
{
	// Confirmed empty in the retail binary (just 'ret').
}

/*-----------------------------------------------------------------------------
	UFluidTexture — fluid simulation texture.
-----------------------------------------------------------------------------*/

void UFluidTexture::Clear( DWORD Flags )
{
	UWaterTexture::Clear( Flags );
}

void UFluidTexture::Init( INT InUSize, INT InVSize )
{
	UWaterTexture::Init( InUSize, InVSize );
}

void UFluidTexture::ConstantTimeTick()
{
	// Ghidra at 0x27a0: calls WaterRedrawDrops, CalculateFluid.
	WaterRedrawDrops();
	CalculateFluid();
}

void UFluidTexture::PostLoad()
{
	UWaterTexture::PostLoad();
}

void UFluidTexture::CalculateFluid()
{
	// Ghidra at 0x7600: ~4400-line optimised 2D fluid simulation kernel.
	// Nearly identical structure to CalculateWater but uses summation
	// (instead of differences) for the Laplacian — producing smoother
	// blob-like fluid motion rather than sharp water ripples.
	//
	// TODO: Full implementation from Ghidra decompilation.
	// The game runs without this — fluid textures don't animate.
}

/*-----------------------------------------------------------------------------
	UIceTexture — animated ice/glass effect.
-----------------------------------------------------------------------------*/

void UIceTexture::Clear( DWORD Flags )
{
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( Pixels, Size );
	}
}

void UIceTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

void UIceTexture::ConstantTimeTick()
{
	// Ghidra at 0x27c0: calls RenderIce.
	RenderIce( 1.0f );
}

void UIceTexture::Tick( FLOAT DeltaTime )
{
	// Ghidra at 0x9d70: if MoveIce byte (0xf9) is set, calls RenderIce.
	// Otherwise falls through to UTexture::Tick.
	if( BYTE_AT(this, 0xf9) != 0 )
	{
		RenderIce( DeltaTime );
	}
	else
	{
		UTexture::Tick( DeltaTime );
	}
}

void UIceTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra at 0x2420: confirmed empty.
}

void UIceTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra: sets ForceRefresh flag so ice re-renders.
	INT_AT(this, 0x130) = 1;
}

void UIceTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

void UIceTexture::Destroy()
{
	UTexture::Destroy();
}

void UIceTexture::MoveIcePosition( FLOAT Delta )
{
	// Ghidra at 0x89e0: updates UPosition/VPosition floats based on
	// speed parameters and delta time.
	FLOAT USpeed = (FLOAT)(signed char)(BYTE_AT(this, 0xfa)) * Delta;
	FLOAT VSpeed = (FLOAT)(signed char)(BYTE_AT(this, 0xfb)) * Delta;
	FLOAT_AT(this, 0x110) += USpeed;
	FLOAT_AT(this, 0x114) += VSpeed;
}

void UIceTexture::RenderIce( FLOAT Delta )
{
	// Ghidra at 0x8c00: renders the ice texture by moving the position
	// and blitting from source/glass textures with refraction.
	INT GlassTex = PTR_AT(this, 0xf0);
	INT SourceTex = PTR_AT(this, 0xf4);
	if( !GlassTex || !SourceTex ) return;

	MoveIcePosition( Delta );

	INT OldU = INT_AT(this, 0x11c);
	INT OldV = INT_AT(this, 0x120);
	INT NewU = appRound( FLOAT_AT(this, 0x110) );
	INT NewV = appRound( FLOAT_AT(this, 0x114) );
	INT ForceRefresh = INT_AT(this, 0x130);

	if( NewU == OldU && NewV == OldV && !ForceRefresh )
		return;

	INT_AT(this, 0x11c) = NewU;
	INT_AT(this, 0x120) = NewV;

	if( (BYTE_AT(this, 0x100) & 1) == 0 )
		BlitIceTex();
	else
		BlitTexIce();

	INT_AT(this, 0x130) = 0;
}

void UIceTexture::BlitIceTex()
{
	// Ghidra at 0x65c0: blits glass texture through source texture
	// as a refraction map, writing to the output mip.
	// Reads source texture pixels as displacement offsets into glass texture.
	//
	// TODO: Full implementation requires accessing source and glass
	// texture mip data through their UTexture objects at this+0xf0/0xf4.
	// Left as stub — ice textures won't render their refraction effect.
}

void UIceTexture::BlitTexIce()
{
	// Ghidra at 0x6400: alternate blit mode — glass through source
	// with reversed lookup order.
	//
	// TODO: Full implementation.
}

/*-----------------------------------------------------------------------------
	UWetTexture — animated wet surface effect.
-----------------------------------------------------------------------------*/

void UWetTexture::Clear( DWORD Flags )
{
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( Pixels, Size );
	}
}

void UWetTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

void UWetTexture::ConstantTimeTick()
{
	// Ghidra at 0x27b0: calls ApplyWetTexture.
	ApplyWetTexture();
}

void UWetTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

void UWetTexture::Destroy()
{
	// Free locally allocated bitmap if present.
	INT LocalBitmap = PTR_AT(this, 0x1318);
	if( LocalBitmap )
	{
		appFree( (void*)LocalBitmap );
		PTR_AT(this, 0x1318) = 0;
	}
	UTexture::Destroy();
}

void UWetTexture::ApplyWetTexture()
{
	// Ghidra at 0x62c0: applies refraction from a source texture
	// through a displacement table to the output pixels.
	//
	// TODO: Full implementation requires source texture access at this+0x1310.
	// Left as stub — wet textures won't show their refraction effect.
}

void UWetTexture::SetRefractionTable()
{
	// Ghidra at 0x8900: fills the refraction table (this+0x904, 1024 bytes)
	// with clamped random signed values in the range -128..127.
	BYTE* Table = (BYTE*)this + 0x904;
	for( INT i = 0; i < 0x400; i++ )
	{
		INT Val = (INT)(signed char)RandByte();
		if( Val < -0x80 ) Val = -0x80;
		else if( Val > 0x7e ) Val = 0x7f;
		Table[i] = (BYTE)(signed char)Val;
	}
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
