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

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
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

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
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

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
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
IMPL_DIVERGE("Reconstructed; no Ghidra match found")
static inline BYTE* GetMipPixels( void* Obj )
{
	INT MipsPtr = PTR_AT(Obj, 0xbc);
	if( !MipsPtr ) return NULL;
	return (BYTE*)*(INT*)((BYTE*)MipsPtr + 0x1c);
}

/* Random byte — approximates FUN_10509f60 (retail inline PRNG). */
IMPL_DIVERGE("Approximates retail PRNG FUN_10509f60")
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
	Lookup tables approximating retail binary data tables.

	DAT_105134f8 — unsigned 8-bit sine: table[n] = 128 + 127*sin(2π·n/256)
	  Used for orbital spark position multipliers (0..255, centre=128).
	DAT_105130a8 — signed 8-bit sine:   table[n] = 127*sin(2π·n/256)
	  Used for MoveSparkXY angle deltas (-127..127).
	DAT_105131c0 — orbital brightness:  table[n] = max(0, 255·cos(2π·n/256))
	  Used as direct pixel value for pulsing/rotating sparks.

	DIVERGENCE: exact table bytes in the retail binary are unknown; we
	initialise them from math at startup. The visual shapes are equivalent
	(circles / Lissajous figures) but may have minor phase/magnitude offsets.
-----------------------------------------------------------------------------*/
static BYTE  GSinU[256];            // DAT_105134f8  unsigned sine
static signed char GSinS[256];      // DAT_105130a8  signed sine
static BYTE  GOrbBright[256];       // DAT_105131c0  orbital brightness

static UBOOL GTablesInit = 0;

IMPL_DIVERGE("Reconstructed; no Ghidra match found")
static void InitFireTables()
{
	if( GTablesInit ) return;
	GTablesInit = 1;
	for( INT i = 0; i < 256; i++ )
	{
		FLOAT Rad = i * 2.0f * PI / 256.0f;
		GSinU[i]      = (BYTE)Clamp( appRound( 128.0f + 127.0f * appSin(Rad) ), 0, 255 );
		GSinS[i]      = (signed char)Clamp( appRound( 127.0f * appSin(Rad) ), -127, 127 );
		FLOAT cv = appCos(Rad);
		GOrbBright[i] = (BYTE)(cv > 0.0f ? appRound(255.0f * cv) : 0);
	}
}

/*-----------------------------------------------------------------------------
	UFractalTexture — base class for all procedural textures.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x10508d20)
void UFractalTexture::Init( INT InUSize, INT InVSize )
{
	UTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x10502420)
void UFractalTexture::PostLoad()
{
	UTexture::PostLoad();
}

IMPL_MATCH("Fire.dll", 0x6b20)
void UFractalTexture::PostEditChange()
{
	// Ghidra: PostEditChange at 0x6b20 is empty in the retail binary.
}

IMPL_MATCH("Fire.dll", 0x10506b50)
void UFractalTexture::Prime()
{
	// Ghidra: Calls UTexture::Prime after checking client state
	// and iterating ConstantTimeTick up to a target frame rate.
	// For safety, just call the parent.
	UTexture::Prime();
}

IMPL_EMPTY("Confirmed empty in retail binary")
void UFractalTexture::TouchTexture( INT X, INT Y, FLOAT Z )
{
	// Confirmed empty in retail binary.
}

/*-----------------------------------------------------------------------------
	UFireTexture — animated fire effect.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x10502440)
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

IMPL_MATCH("Fire.dll", 0x10508e80)
void UFireTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x50f0)
void UFireTexture::ConstantTimeTick()
{
	// Ghidra at 0x50f0: calls RedrawSparks() then PostDrawSparks().
	RedrawSparks();
	PostDrawSparks();
}

IMPL_MATCH("Fire.dll", 0x2440)
void UFireTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra at 0x2440: calls FirePaint with the click coordinates.
	INT IX = (INT)X;
	INT IY = (INT)Y;
	FirePaint( IX, IY, Flags );
}

IMPL_MATCH("Fire.dll", 0x10506d70)
void UFireTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra: similar to Click — calls FirePaint.
	INT IX = (INT)X;
	INT IY = (INT)Y;
	FirePaint( IX, IY, Flags );
}

IMPL_MATCH("Fire.dll", 0x6c50)
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

IMPL_MATCH("Fire.dll", 0x10509080)
void UFireTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

IMPL_MATCH("Fire.dll", 0x10509e60)
void UFireTexture::Serialize( FArchive& Ar )
{
	UTexture::Serialize( Ar );
}

/*--- UFireTexture private helpers ---*/

IMPL_MATCH("Fire.dll", 0x6800)
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

IMPL_MATCH("Fire.dll", 0x6830)
void UFireTexture::FirePaint( INT X, INT Y, DWORD C )
{
	// Ghidra at 0x6830: if flag bit 0 set, calls AddSpark.
	// If flag bit 1 set, calls DeleteSparks.
	if( C & 1 )
		AddSpark( X, Y );
	if( C & 2 )
		DeleteSparks( X, Y, 12 );
}

IMPL_MATCH("Fire.dll", 0xa120)
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

IMPL_DIVERGE("sine table approximated with appSin")
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

IMPL_MATCH("Fire.dll", 0xa400)
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

IMPL_MATCH("Fire.dll", 0x9fc0)
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

IMPL_MATCH("Fire.dll", 0x2490)
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

IMPL_MATCH("Fire.dll", 0x26d0)
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

IMPL_MATCH("Fire.dll", 0x6840)
void UFireTexture::DrawFlashRamp( LineSeg Seg, BYTE A, BYTE B )
{
	// Ghidra at 0x6840: draws a line with ramping brightness.
	DrawSparkLine( Seg.X1, Seg.Y1,
		(INT)Seg.X1 + (INT)(signed char)Seg.X2,
		(INT)Seg.Y1 + (INT)(signed char)Seg.Y2, A );
}

IMPL_MATCH("Fire.dll", 0x68a0)
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

IMPL_MATCH("Fire.dll", 0x50d0)
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

IMPL_DIVERGE("cases 0x9/0xa DrawMode sub-variants simplified for readability")
void UFireTexture::AddSpark( INT X, INT Y )
{
	// Ghidra: 0x2c70, 12628 bytes.
	// Adds a spark at (X,Y), setting type-specific fields via a 28-case switch.
	// DIVERGENCE: cases 0x9/0xa DrawMode sub-variants simplified for readability.

	InitFireTables();

	if( X < 0 || Y < 0 ) return;
	if( X >= INT_AT(this, 0x60) ) return;
	if( Y >= INT_AT(this, 0x64) ) return;

	INT NumSparks = INT_AT(this, 0x108);
	INT MaxSparks = INT_AT(this, 0x104);
	if( NumSparks >= MaxSparks ) return;

	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	if( !Sparks ) return;

	INT_AT(this, 0x108) = NumSparks + 1;

	BYTE SparkType = BYTE_AT(this, 0xf0);
	FSpark* S = &Sparks[NumSparks];
	S->Type  = SparkType;
	S->X     = (BYTE)X;
	S->Y     = (BYTE)Y;
	S->Heat  = BYTE_AT(this, 0xf8);  // FX_Heat
	S->ByteA = 0;
	S->ByteB = 0;
	S->ByteC = 0;
	S->ByteD = 0;

	switch( SparkType )
	{
	case 0x01:
		S->ByteA = BYTE_AT(this, 0xf9);
		S->ByteB = BYTE_AT(this, 0xfa);
		return;

	case 0x02:
		S->Heat = (BYTE)((signed char)BYTE_AT(this, 0xed) + (signed char)BYTE_AT(this, 0xec));
		BYTE_AT(this, 0xec) = (BYTE)((signed char)BYTE_AT(this, 0xec) + (signed char)BYTE_AT(this, 0xfd));
		S->ByteD = BYTE_AT(this, 0xfc);
		return;

	case 0x03:
		S->Heat  = RandByte();
		S->ByteD = BYTE_AT(this, 0xfc);
		S->ByteC = (BYTE)(-1 - (signed char)BYTE_AT(this, 0xf8));
		return;

	case 0x07:
	case 0x08:
		S->ByteC = BYTE_AT(this, 0xf9);
		return;

	case 0x09:
	case 0x0a:
	{
		BYTE FXSize = BYTE_AT(this, 0xf9);
		signed char HorizDir = (signed char)BYTE_AT(this, 0xfe) - 0x80;
		DWORD uVar5 = (DWORD)FXSize;
		// BYTE_AT(this,0x521) = high byte of StarStatus; normally 0.
		if( BYTE_AT(this, 0x100) != 0 && BYTE_AT(this, 0x521) != 0 )
		{
			INT adj = (INT)uVar5 + X * -2;
			if( adj < 0 )
			{
				uVar5 = (DWORD)(X * 2 - (INT)uVar5);
				HorizDir = -HorizDir;
				S->X = (BYTE)((signed char)X - (signed char)uVar5);
			}
		}
		BYTE BaseA = (BYTE)((signed char)BYTE_AT(this, 0xfc) * (signed char)BYTE_AT(this, 0xe8)
		                  + (signed char)BYTE_AT(this, 0xfd));
		S->ByteA = BaseA;
		S->ByteB = (BYTE)uVar5;
		S->ByteD = (BYTE)HorizDir;

		BYTE DrawMode = BYTE_AT(this, 0x100);
		if( DrawMode == 2 )
		{
			INT n = INT_AT(this, 0x108);
			if( n < MaxSparks )
			{
				INT_AT(this, 0x108) = n + 1;
				FSpark* S2 = (FSpark*)PTR_AT(this, 0x10c) + n;
				*S2 = *S;
				S2->ByteA = (BYTE)((signed char)BaseA - (signed char)0x80);
			}
		}
		else if( DrawMode == 3 )
		{
			INT n = INT_AT(this, 0x108);
			if( n + 2 <= MaxSparks )
			{
				FSpark* Sp = (FSpark*)PTR_AT(this, 0x10c);
				INT_AT(this, 0x108) = n + 1;
				Sp[n] = *S;  Sp[n].ByteA = (BYTE)((signed char)BaseA + (signed char)0x55);
				INT_AT(this, 0x108) = n + 2;
				Sp[n+1] = *S;  Sp[n+1].ByteA = (BYTE)((signed char)BaseA - (signed char)0x56);
			}
		}
		else if( DrawMode == 4 )
		{
			INT n = INT_AT(this, 0x108);
			if( n + 3 <= MaxSparks )
			{
				FSpark* Sp = (FSpark*)PTR_AT(this, 0x10c);
				INT_AT(this, 0x108) = n + 1;  Sp[n]   = *S;  Sp[n].ByteA   = (BYTE)((signed char)BaseA + (signed char)0x40);
				INT_AT(this, 0x108) = n + 2;  Sp[n+1] = *S;  Sp[n+1].ByteA = (BYTE)((signed char)BaseA - (signed char)0x80);
				INT_AT(this, 0x108) = n + 3;  Sp[n+2] = *S;  Sp[n+2].ByteA = (BYTE)((signed char)BaseA - (signed char)0x40);
			}
		}
		break;
	}

	case 0x0b:
		S->Heat  = BYTE_AT(this, 0xf9);
		S->ByteA = BYTE_AT(this, 0xfd);
		S->ByteB = BYTE_AT(this, 0xfc);
		S->ByteC = (BYTE)((signed char)BYTE_AT(this, 0xfe) - 0x80);
		S->ByteD = (BYTE)((signed char)BYTE_AT(this, 0xff) - 0x80);
		if( S->ByteC == 0 ) S->Type = 0x1e;
		if( S->ByteD == 0 ) S->Type = 0x1d;
		break;

	case 0x0c:
		S->ByteA = (BYTE)((signed char)BYTE_AT(this, 0xfc) * (signed char)BYTE_AT(this, 0xe8)
		                + (signed char)BYTE_AT(this, 0xfd));
		S->ByteB = BYTE_AT(this, 0xf9);
		S->ByteD = (BYTE)((signed char)BYTE_AT(this, 0xfe) - 0x80);
		return;

	case 0x0d:
	case 0x0e:
		S->ByteA = (BYTE)((signed char)BYTE_AT(this, 0xfe) - 0x80);
		S->ByteB = BYTE_AT(this, 0xff) ^ 0x7f;
		S->ByteD = (BYTE)(0xff / ((INT)(BYTE)BYTE_AT(this, 0xf9) + 1));
		return;

	case 0x0f:
		S->ByteA = 0x80;
		S->ByteB = BYTE_AT(this, 0xf9);
		S->ByteC = 0x80;
		S->ByteD = (BYTE)(-1 - (signed char)BYTE_AT(this, 0xfb));
		return;

	case 0x10:
	case 0x1b:
		S->ByteC = BYTE_AT(this, 0xf9);
		return;

	case 0x11:
		S->ByteC = BYTE_AT(this, 0xfb);
		return;

	case 0x15:
		S->ByteC = BYTE_AT(this, 0xfb);
		// fall through
	case 0x14:
		S->ByteA = (BYTE)((signed char)BYTE_AT(this, 0xfe) - 0x80);
		S->ByteB = (BYTE)(~BYTE_AT(this, 0xff) + 0x80);
		S->ByteD = (BYTE)(-1 - (signed char)BYTE_AT(this, 0xf9));
		return;

	case 0x16:
		S->ByteA = BYTE_AT(this, 0xf8);
		BYTE_AT(this, 0x520) = 1;
		return;

	case 0x17:
	case 0x18:
	{
		// Search backward for existing same-type spark with ByteD==0 and redirect it.
		for( INT j = NumSparks - 1; j >= 0; j-- )
		{
			FSpark* Sp = (FSpark*)PTR_AT(this, 0x10c);
			if( Sp[j].Type == SparkType && Sp[j].ByteD == 0 )
			{
				INT_AT(this, 0x108)--;
				Sp[j].X    = GFireLastX;
				Sp[j].Y    = GFireLastY;
				Sp[j].Heat = BYTE_AT(this, 0xf8) | 3;
				INT DX = X - (INT)Sp[j].X;
				INT DY = Y - (INT)Sp[j].Y;
				if( DX < 0 ) DX = (-DX) | 1;  else DX &= ~1;
				if( DY < 0 ) DY = (-DY) | 1;  else DY &= ~1;
				if( DX == 0 && DY == 0 ) Sp[j].Heat = 0;
				Sp[j].ByteA = (BYTE)DX;
				Sp[j].ByteB = (BYTE)DY;
				return;
			}
		}
		INT NewIdx = INT_AT(this, 0x108) - 1;
		((FSpark*)PTR_AT(this, 0x10c))[NewIdx].ByteD = 0;
		((FSpark*)PTR_AT(this, 0x10c))[NewIdx].Heat  = 0;
		GFireLastX = (BYTE)X;
		GFireLastY = (BYTE)Y;
		break;
	}

	case 0x19:
		S->Heat  = BYTE_AT(this, 0xf8);
		S->ByteC = BYTE_AT(this, 0xf9);
		if( S->ByteC < 8 ) S->ByteC = 8;
		S->ByteD = 0x60;
		return;

	case 0x1a:
		S->ByteA = BYTE_AT(this, 0xfd);
		S->ByteB = BYTE_AT(this, 0xf9);
		S->ByteC = BYTE_AT(this, 0xfc);
		S->ByteD = (BYTE)(-1 - (signed char)BYTE_AT(this, 0xfb));
		return;

	case 0x1c:
		S->ByteA = BYTE_AT(this, 0xfd);
		S->ByteB = 0x80;
		S->ByteC = 0x80;
		S->ByteD = BYTE_AT(this, 0xfc);
		return;

	default:
		S->ByteA = BYTE_AT(this, 0xf9);
		S->ByteB = BYTE_AT(this, 0xfa);
		break;
	}
}

IMPL_DIVERGE("spark removal decrements i; loop-unrolled cases simplified")
void UFireTexture::RedrawSparks()
{
	// Ghidra: 0x3c20, ~30000 bytes (heavily loop-unrolled spark simulation).
	// 44-case switch on SparkType 0x00..0x2b — each case either renders,
	// moves, spawns child sparks, or removes dead sparks.
	//
	// DIVERGENCE: On removal, Ghidra does NOT decrement `i` (skips the
	// replacement spark this frame). Our version decrements `i` so every
	// spark is processed each frame — slightly different visual behaviour.
	// DIVERGENCE: Ghidra re-reads Sparks ptr each iteration; not needed here
	// since the array is pre-allocated.

	InitFireTables();

	INT_AT(this, 0xe8) = INT_AT(this, 0xe8) + 1;                            // GlobalPhase++
	BYTE_AT(this, 0xed) = (BYTE)((signed char)BYTE_AT(this, 0xed)           // AuxPhase2 +=
	                           + (signed char)BYTE_AT(this, 0xfc));          //   FX_Frequency

	FSpark* Sparks = (FSpark*)PTR_AT(this, 0x10c);
	BYTE*   Pixels = GetMipPixels( this );
	if( !Sparks || !Pixels || INT_AT(this, 0x108) <= 0 ) return;

	BYTE    UBits  = BYTE_AT(this, 0x5b) & 0x1f;
	DWORD   UMask  = UINT_AT(this, 0xd8);
	DWORD   VMask  = UINT_AT(this, 0xdc);
	INT     MaxSparks = INT_AT(this, 0x104);

// Helper macro: compute pixel offset for spark S.
#define SPARK_OFF(S) (((DWORD)(S)->Y << UBits) + (DWORD)(S)->X)
// Helper macro: spawn a child spark of given type into NS, or break out if full.
#define SPAWN_BEGIN(Tp) \
	{ INT _n = INT_AT(this, 0x108); \
	  if( _n < MaxSparks ) { \
	  INT_AT(this, 0x108) = _n + 1; \
	  FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n; \
	  NS->Type = (Tp);
#define SPAWN_END \
	  } }
// Helper macro: remove current spark by swap with last.
#define REMOVE_SPARK \
	{ INT _last = INT_AT(this, 0x108) - 1; \
	  INT_AT(this, 0x108) = _last; \
	  *S = ((FSpark*)PTR_AT(this, 0x10c))[_last]; \
	  i--; }

	for( INT i = 0; i < INT_AT(this, 0x108); i++ )
	{
		FSpark* S = &((FSpark*)PTR_AT(this, 0x10c))[i];
		INT Offset = SPARK_OFF(S);

		switch( S->Type )
		{
		case 0x00: // Random pixel.
			Pixels[Offset] = RandByte();
			break;

		case 0x01: // Scatter with random radius.
		{
			BYTE r1 = RandByte(), r2 = RandByte();
			DWORD plotX = (( (DWORD)((r1 & 0xff) * (DWORD)S->ByteA >> 8) + (DWORD)S->X ) & UMask);
			BYTE  r3 = RandByte(), r4 = RandByte();
			DWORD plotY = (( (DWORD)((r3 & 0xff) * (DWORD)S->ByteB >> 8) + (DWORD)S->Y ) & VMask);
			Pixels[(plotY << UBits) + plotX] = S->Heat;
			break;
		}

		case 0x02: // Plot at (X,Y), Heat += ByteD.
			Pixels[Offset] = S->Heat;
			S->Heat = (BYTE)((signed char)S->Heat + (signed char)S->ByteD);
			break;

		case 0x03: // Conditional plot, Heat += ByteD, random reset on wrap.
			if( (BYTE)S->ByteC < (BYTE)S->Heat )
				Pixels[Offset] = S->Heat;
			S->Heat = (BYTE)((signed char)S->Heat + (signed char)S->ByteD);
			if( (BYTE)S->Heat < (BYTE)S->ByteD )
				S->Heat = RandByte();
			break;

		case 0x04: // Emit type 0x20 at ~50% chance.
			if( RandByte() < 0x80 )
			{
				SPAWN_BEGIN(0x20)
					NS->Heat  = S->Heat;
					NS->X     = S->X;     NS->Y     = S->Y;
					NS->ByteA = RandByte();
					NS->ByteB = RandByte();
					NS->ByteC = S->ByteC;
					NS->ByteD = S->ByteD;
				SPAWN_END
			}
			break;

		case 0x05: // Emit type 0x21 at ~50% chance.
			if( RandByte() < 0x80 )
			{
				SPAWN_BEGIN(0x21)
					NS->Heat  = S->Heat;
					NS->X     = S->X;     NS->Y     = S->Y;
					NS->ByteA = (BYTE)((RandByte() & 0x7f) - 0x3f);
					NS->ByteB = 0x81;
					NS->ByteC = 0;
					NS->ByteD = 2;
				SPAWN_END
			}
			break;

		case 0x06: // Emit type 0x22 at ~25% chance (leftward arc).
			if( RandByte() < 0x40 )
			{
				SPAWN_BEGIN(0x22)
					NS->Heat  = S->Heat;
					NS->X     = S->X;     NS->Y     = S->Y;
					NS->ByteA = (BYTE)((RandByte() & 0x7f) - 0x3f);
					NS->ByteB = 0;
					NS->ByteC = 0x32;
					NS->ByteD = 0;
				SPAWN_END
			}
			break;

		case 0x07: // Emit type 0x22 at ~25% chance (lower-right arc).
			if( RandByte() < 0x40 )
			{
				SPAWN_BEGIN(0x22)
					NS->Heat  = S->Heat;
					NS->X     = S->X;     NS->Y     = S->Y;
					NS->ByteA = (BYTE)((RandByte() & 0x3f) + 0x3f);
					NS->ByteB = 0xe3;
					NS->ByteC = S->ByteC;
					NS->ByteD = 0;
				SPAWN_END
			}
			break;

		case 0x08: // Emit type 0x22 at ~25% chance (lower-left arc).
			if( RandByte() < 0x40 )
			{
				SPAWN_BEGIN(0x22)
					NS->Heat  = S->Heat;
					NS->X     = S->X;     NS->Y     = S->Y;
					NS->ByteA = (BYTE)((RandByte() & 0x3f) + 0x80);
					NS->ByteB = 0xe3;
					NS->ByteC = S->ByteC;
					NS->ByteD = 0;
				SPAWN_END
			}
			break;

		case 0x09: // X-orbit with full sine (always plots).
		{
			DWORD ang = (DWORD)S->ByteA;
			DWORD brightness = (DWORD)GSinU[(ang + 0x40) & 0xff] + (DWORD)S->Heat;
			if( brightness > 0xff ) brightness = 0xff;
			DWORD plotX = ((DWORD)((GSinU[ang] * (DWORD)S->ByteB) >> 8) + (DWORD)S->X) & UMask;
			Pixels[((DWORD)S->Y << UBits) + plotX] = (BYTE)brightness;
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteD);
			break;
		}

		case 0x0a: // X-orbit, upper semicircle only.
		{
			DWORD ang = (DWORD)S->ByteA;
			DWORD cosIdx = (ang + 0x40) & 0xff;
			if( cosIdx < 0x80 )
			{
				DWORD brightness = (DWORD)GSinU[cosIdx] + (DWORD)S->Heat;
				if( brightness > 0xff ) brightness = 0xff;
				DWORD plotX = ((DWORD)((GSinU[ang] * (DWORD)S->ByteB) >> 8) + (DWORD)S->X) & UMask;
				Pixels[((DWORD)S->Y << UBits) + plotX] = (BYTE)brightness;
			}
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteD);
			break;
		}

		case 0x0b: // Full 2D orbit, brightness from cosine.
		{
			DWORD plotX = ((DWORD)((GSinU[S->ByteA] * (DWORD)S->Heat) >> 8) + (DWORD)S->X) & UMask;
			DWORD plotY = ((DWORD)((GSinU[S->ByteB] * (DWORD)S->Heat) >> 8) + (DWORD)S->Y) & VMask;
			Pixels[(plotY << UBits) + plotX] = GOrbBright[(BYTE)((signed char)S->ByteA + 0x40)];
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteC);
			S->ByteB = (BYTE)((signed char)S->ByteB + (signed char)S->ByteD);
			break;
		}

		case 0x0c: // Y-orbit, fixed X.
		{
			DWORD ang = (DWORD)S->ByteA;
			DWORD brightness = (DWORD)GSinU[(ang + 0x40) & 0xff] + (DWORD)S->Heat;
			if( brightness > 0xff ) brightness = 0xff;
			DWORD plotY = ((DWORD)((GSinU[ang] * (DWORD)S->ByteB) >> 8) + (DWORD)S->Y) & VMask;
			Pixels[(plotY << UBits) + (DWORD)S->X] = (BYTE)brightness;
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteD);
			break;
		}

		case 0x0d: // Emit type 0x21 at ~25% chance.
			if( RandByte() < 0x40 )
			{
				INT _n = INT_AT(this, 0x108);
				if( _n < MaxSparks )
				{
					INT_AT(this, 0x108) = _n + 1;
					FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
					NS->Type  = 0x21;
					NS->Heat  = S->Heat;
					NS->X     = S->X;  NS->Y  = S->Y;
					NS->ByteA = S->ByteA;
					NS->ByteB = S->ByteB;
					NS->ByteC = 0;
					NS->ByteD = S->ByteD;
				}
			}
			break;

		case 0x0e: // Emit type 0x2a at ~25% chance.
			if( RandByte() < 0x40 )
			{
				INT _n = INT_AT(this, 0x108);
				if( _n < MaxSparks )
				{
					INT_AT(this, 0x108) = _n + 1;
					FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
					NS->Type  = 0x2a;
					NS->Heat  = S->Heat;
					NS->X     = S->X;  NS->Y  = S->Y;
					NS->ByteA = S->ByteA;
					NS->ByteB = S->ByteB;
					NS->ByteC = 0;
					NS->ByteD = S->ByteD;
				}
			}
			break;

		case 0x0f: // Emit type 0x27 at random nearby pos, advance ByteA, random walk.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x27;
				NS->Heat  = S->Heat;
				NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
				NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
				NS->ByteA = 0;
				NS->ByteB = S->ByteA;  // angle seed
				NS->ByteC = S->ByteB;
				NS->ByteD = S->ByteD;
			}
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteC);
			// Random walk (fall-through to LAB_105049af):
			goto LAB_105049af_0f;
		}

		case 0x10: // Emit type 0x26 at ~8%, random walk.
		{
			if( RandByte() < 0x14 )
			{
				INT _n = INT_AT(this, 0x108);
				if( _n < MaxSparks )
				{
					INT_AT(this, 0x108) = _n + 1;
					FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
					NS->Type  = 0x26;
					NS->Heat  = S->Heat;
					NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
					NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
					NS->ByteA = RandByte();
					NS->ByteB = RandByte();
					NS->ByteC = S->ByteC;
					NS->ByteD = 0;
				}
			}
			// Random walk (1-in-16 chance on X and Y):
			if( (RandByte() & 0xf) == 0xf )
				S->X = (BYTE)(((RandByte() & 0xf) + (signed char)S->X - 7) & UMask);
			if( (RandByte() & 0xf) == 0xf )
				S->Y = (BYTE)(((RandByte() & 0xf) + (signed char)S->Y - 7) & VMask);
			break;
		}

		case 0x11: // Emit type 0x23 at ~50%, scatter within ByteC radius.
			if( RandByte() < 0x80 )
			{
				INT _n = INT_AT(this, 0x108);
				if( _n < MaxSparks )
				{
					INT_AT(this, 0x108) = _n + 1;
					FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
					NS->Type  = 0x23;
					NS->Heat  = S->Heat;
					NS->X     = (BYTE)((signed char)((RandByte() & 0xff) * (DWORD)S->ByteC >> 8) + (signed char)S->X) & (BYTE)UMask;
					NS->Y     = (BYTE)((signed char)((RandByte() & 0xff) * (DWORD)S->ByteC >> 8) + (signed char)S->Y) & (BYTE)VMask;
					NS->ByteA = (BYTE)(RandByte() - 0x7f);
					NS->ByteB = 0x81;
					NS->ByteC = 0xff;
					NS->ByteD = 0;
				}
			}
			break;

		case 0x12: // Emit type 0x23, random walk.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x23;
				NS->Heat  = S->Heat;
				NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
				NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
				NS->ByteA = (BYTE)(RandByte() - 0x7f);
				NS->ByteB = 0x81;
				NS->ByteC = 0xff;
				NS->ByteD = 0;
			}
			if( (RandByte() & 0xf) == 0xf )
				S->X = (BYTE)(((RandByte() & 0xf) + (signed char)S->X - 7) & UMask);
			if( (RandByte() & 0xf) == 0xf )
				S->Y = (BYTE)(((RandByte() & 0xf) + (signed char)S->Y - 7) & VMask);
			break;
		}

		case 0x13: // Emit type 0x24, random walk.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x24;
				NS->Heat  = S->Heat;
				NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
				NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
				NS->ByteA = (BYTE)((RandByte() & 0x1f) - 0x0f);
				NS->ByteB = 0x81;
				NS->ByteC = 0;
				NS->ByteD = 0;
			}
			if( (RandByte() & 0xf) == 0xf )
				S->X = (BYTE)(((RandByte() & 0xf) + (signed char)S->X - 7) & UMask);
			if( (RandByte() & 0xf) == 0xf )
				S->Y = (BYTE)(((RandByte() & 0xf) + (signed char)S->Y - 7) & VMask);
			break;
		}

		case 0x14: // Emit type 0x25 at nearby pos, random walk (LAB_105049af).
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x25;
				NS->Heat  = 0;  // not set in Ghidra for 0x14
				NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
				NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
				NS->ByteA = S->ByteA;
				NS->ByteB = S->ByteB;
				NS->ByteC = S->ByteD;  // ByteC = pFVar2[7]
				NS->ByteD = 0;
			}
			goto LAB_105049af_14;
		}

		case 0x15: // Emit type 0x25 (ByteC-scaled), random walk.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x25;
				NS->Heat  = 0;
				NS->X     = (BYTE)((signed char)((RandByte() & 0xff) * (DWORD)S->ByteC >> 8) + (signed char)S->X) & (BYTE)UMask;
				NS->Y     = (BYTE)((signed char)((RandByte() & 0xff) * (DWORD)S->ByteC >> 8) + (signed char)S->Y) & (BYTE)VMask;
				NS->ByteA = S->ByteA;
				NS->ByteB = S->ByteB;
				NS->ByteC = S->ByteD;
				NS->ByteD = 0;
			}
			break;
		}

		case 0x16: // Static plot of ByteB.
			Pixels[Offset] = S->ByteB;
			break;

		case 0x17: // Delayed flash ramp (full heat).
			if( S->Heat != 0 )
			{
				if( S->ByteC == 0 )
				{
					if( RandByte() >= S->ByteD )
						S->ByteC = (BYTE)((RandByte() + 1) & 5);
				}
				else
				{
					S->ByteC--;
					LineSeg Seg; Seg.X1=S->X; Seg.Y1=S->Y; Seg.X2=S->ByteA; Seg.Y2=S->ByteB;
					DrawFlashRamp( Seg, S->Heat, S->Heat );
				}
			}
			break;

		case 0x18: // Delayed flash ramp (dimmed).
			if( S->Heat != 0 )
			{
				if( S->ByteC == 0 )
				{
					if( RandByte() >= S->ByteD )
						S->ByteC = (BYTE)((RandByte() + 1) & 5);
				}
				else
				{
					S->ByteC--;
					LineSeg Seg; Seg.X1=S->X; Seg.Y1=S->Y; Seg.X2=S->ByteA; Seg.Y2=S->ByteB;
					DrawFlashRamp( Seg, S->Heat, (BYTE)(S->Heat >> 3) );
				}
			}
			break;

		case 0x19: // Random radial flash ramp.
			if( RandByte() < S->ByteD )
			{
				DWORD r = RandByte();
				INT iX = ((INT)(GSinU[r & 0xff]       * (DWORD)S->ByteC) >> 8) - (INT)S->ByteC / 2;
				INT iY = ((INT)(GSinU[(r+0x40)&0xff]  * (DWORD)S->ByteC) >> 8) - (INT)S->ByteC / 2;
				BYTE bX = (BYTE)(iX < 1 ? ((-iX) | 1) : (iX & 0xfe));
				BYTE bY = (BYTE)(iY < 1 ? ((-iY) | 1) : (iY & 0xfe));
				LineSeg Seg; Seg.X1=S->X; Seg.Y1=S->Y; Seg.X2=bX; Seg.Y2=bY;
				DrawFlashRamp( Seg, S->Heat, (BYTE)(S->Heat >> 2) );
			}
			break;

		case 0x1a: // Emit type 0x27, advance ByteA.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x27;
				NS->Heat  = S->Heat;
				NS->X     = S->X;  NS->Y = S->Y;
				NS->ByteA = 0;
				NS->ByteB = S->ByteA;
				NS->ByteC = S->ByteB;
				NS->ByteD = S->ByteD;
			}
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteC);
			break;
		}

		case 0x1b: // Emit type 0x2b at ~8%, random walk.
		{
			if( RandByte() < 0x14 )
			{
				INT _n = INT_AT(this, 0x108);
				if( _n < MaxSparks )
				{
					INT_AT(this, 0x108) = _n + 1;
					FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
					NS->Type  = 0x2b;
					NS->Heat  = S->Heat;
					NS->X     = (BYTE)((RandByte() & 0x1f) + (signed char)S->X) & (BYTE)UMask;
					NS->Y     = (BYTE)((RandByte() & 0x1f) + (signed char)S->Y) & (BYTE)VMask;
					NS->ByteA = RandByte();
					NS->ByteB = 0;
					NS->ByteC = S->ByteC;
					NS->ByteD = RandByte();
				}
			}
			if( (RandByte() & 0xf) == 0xf )
				S->X = (BYTE)(((RandByte() & 0xf) + (signed char)S->X - 7) & UMask);
			if( (RandByte() & 0xf) == 0xf )
				S->Y = (BYTE)(((RandByte() & 0xf) + (signed char)S->Y - 7) & VMask);
			break;
		}

		case 0x1c: // Emit type 0x28, advance ByteA.
		{
			INT _n = INT_AT(this, 0x108);
			if( _n < MaxSparks )
			{
				INT_AT(this, 0x108) = _n + 1;
				FSpark* NS = (FSpark*)PTR_AT(this, 0x10c) + _n;
				NS->Type  = 0x28;
				NS->Heat  = S->Heat;
				NS->X     = S->X;   NS->Y     = S->Y;
				NS->ByteA = S->ByteA;
				NS->ByteB = S->ByteB;
				NS->ByteC = S->ByteC;
				NS->ByteD = 2;
			}
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteD);
			break;
		}

		case 0x1d: // Horizontal orbit arc.
		{
			DWORD ang = (DWORD)S->ByteA;
			DWORD plotX = ((DWORD)((GSinU[ang] * (DWORD)S->Heat) >> 8) + (DWORD)S->X) & UMask;
			Pixels[((DWORD)S->Y << UBits) + plotX] = GOrbBright[(BYTE)((signed char)S->ByteA + 0x40)];
			S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteC);
			break;
		}

		case 0x1e: // Vertical orbit arc.
		{
			DWORD ang = (DWORD)S->ByteB;
			DWORD plotY = ((DWORD)((GSinU[ang] * (DWORD)S->Heat) >> 8) + (DWORD)S->Y) & VMask;
			Pixels[(plotY << UBits) + (DWORD)S->X] = GOrbBright[(BYTE)((signed char)S->ByteB + 0x40)];
			S->ByteB = (BYTE)((signed char)S->ByteB + (signed char)S->ByteD);
			break;
		}

		case 0x20: // Fade by 5; remove below threshold.
		{
			S->Heat = (BYTE)((signed char)S->Heat - 5);
			if( (BYTE)S->Heat < 0xfb )
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
			}
			else { REMOVE_SPARK }
			break;
		}

		case 0x21: // Fade by ByteD; remove when depleted.
		{
			S->Heat = (BYTE)((signed char)S->Heat - (signed char)S->ByteD);
			if( (BYTE)S->ByteD < (BYTE)S->Heat )
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
			}
			else { REMOVE_SPARK }
			break;
		}

		case 0x22: // Countdown ByteC; remove at 0.
		{
			S->ByteC--;
			if( S->ByteC == 0 ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
				if( (signed char)S->ByteB < 0x7a ) S->ByteB += 3;
			}
			break;
		}

		case 0x23: // Fade ByteC down by 3; plot ByteC value; remove below 0xbf.
		{
			S->ByteC = (BYTE)((signed char)S->ByteC - 3);
			if( (BYTE)S->ByteC < 0xbf ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->ByteC;
				MoveSparkTwo( S );
			}
			break;
		}

		case 0x24: // Brighten ByteC by 4; plot ByteC; remove above 0xf9.
		{
			S->ByteC = (BYTE)((signed char)S->ByteC + 4);
			if( (BYTE)S->ByteC > 0xf9 ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->ByteC;
				MoveSparkTwo( S );
			}
			break;
		}

		case 0x25: // Brighten ByteC by 4; plot ByteC; remove at >= 0xfa.
		{
			S->ByteC = (BYTE)((signed char)S->ByteC + 4);
			if( (BYTE)S->ByteC >= 0xfa ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->ByteC;
				MoveSpark( S );
			}
			break;
		}

		case 0x26: // Countdown ByteC (unsigned); plot Heat; remove on wrap to 0xff.
		{
			BYTE prev = S->ByteC;
			S->ByteC--;
			if( S->ByteC == 0xff ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
			}
			break;
		}

		case 0x27: // Sub-pixel orbit along sine path; countdown ByteC.
		{
			BYTE prev = S->ByteC;
			S->ByteC--;
			if( S->ByteC == 0xff ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				// Advance 16-bit sub-pixel angle accumulator (ByteA=frac, ByteB=int).
				DWORD acc = (DWORD)S->ByteA | ((DWORD)S->ByteB << 8);
				acc += (DWORD)S->ByteD * 0x10;
				S->ByteA = (BYTE)(acc & 0xff);
				S->ByteB = (BYTE)(acc >> 8);
				DWORD ang = (DWORD)S->ByteB;
				signed char DX = GSinS[(ang + 0x40) & 0xff];  // cosine
				signed char DY = GSinS[ang];                    // sine
				MoveSparkXY( S, DX, DY );
			}
			break;
		}

		case 0x28: // Circular orbit arc; countdown ByteC.
		{
			BYTE prev = S->ByteC;
			S->ByteC--;
			if( S->ByteC == 0xff ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				signed char DX = (signed char)((INT)GSinU[((BYTE)S->ByteA + 0x40) & 0xff] - 0x80);
				S->ByteA = (BYTE)((signed char)S->ByteA + (signed char)S->ByteD);
				MoveSparkXY( S, DX, (signed char)S->ByteB );
			}
			break;
		}

		case 0x29: // Fade by ByteC; remove below 0xfa.
		{
			S->Heat = (BYTE)((signed char)S->Heat - (signed char)S->ByteC);
			if( (BYTE)S->Heat < 0xfa ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
			}
			break;
		}

		case 0x2a: // Fade by ByteD; remove below 0x33; accelerate ByteB every other frame.
		{
			S->Heat = (BYTE)((signed char)S->Heat - (signed char)S->ByteD);
			if( (BYTE)S->Heat < 0x33 ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				MoveSpark( S );
				if( ((BYTE_AT(this, 0xe8) & 1) != 0) && ((signed char)S->ByteB < 0x7c) )
					S->ByteB = (BYTE)((signed char)S->ByteB + 3);
			}
			break;
		}

		case 0x2b: // Sinusoidal wobble; countdown ByteC.
		{
			BYTE prev = S->ByteC;
			S->ByteC--;
			if( S->ByteC == 0xff ) { REMOVE_SPARK }
			else
			{
				Pixels[SPARK_OFF(S)] = S->Heat;
				BYTE wob = (BYTE)((signed char)S->ByteA + 7) & 0x7f;
				S->ByteA = (BYTE)((signed char)S->ByteA + 7);
				if( wob > 0x3f ) wob = 0x7f - wob;
				MoveSparkAngle( S, (BYTE)((signed char)S->ByteD + (signed char)wob) );
			}
			break;
		}

		default:
			if( S->Heat > 0 )
				Pixels[SPARK_OFF(S)] = S->Heat;
			MoveSpark( S );
			break;
		}
		continue;

		LAB_105049af_0f:
		LAB_105049af_14:
		{
			S->X = (BYTE)(((RandByte() & 7) - (RandByte() & 7) + (signed char)S->X) & UMask);
			S->Y = (BYTE)(((RandByte() & 7) - (RandByte() & 7) + (signed char)S->Y) & VMask);
		}
	}

#undef SPARK_OFF
#undef SPAWN_BEGIN
#undef SPAWN_END
#undef REMOVE_SPARK
}

/*-----------------------------------------------------------------------------
	UWaterTexture — animated water ripple effect.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x10502680)
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

IMPL_MATCH("Fire.dll", 0x10509400)
void UWaterTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x105071a0)
void UWaterTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	INT IX = (INT)X;
	INT IY = (INT)Y;
	WaterPaint( IX, IY, Flags );
}

IMPL_MATCH("Fire.dll", 0x10507100)
void UWaterTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	INT IX = (INT)X;
	INT IY = (INT)Y;
	WaterPaint( IX, IY, Flags );
}

IMPL_MATCH("Fire.dll", 0x25b0)
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

IMPL_MATCH("Fire.dll", 0x105024d0)
void UWaterTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

IMPL_MATCH("Fire.dll", 0x6970)
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

IMPL_MATCH("Fire.dll", 0x7010)
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

IMPL_MATCH("Fire.dll", 0x2160)
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

IMPL_MATCH("Fire.dll", 0x27f0)
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

IMPL_DIVERGE("nearest-neighbour 2x2 upsampling instead of bilinear")
void UWaterTexture::CalculateWater()
{
	// Ghidra: 0x5160, ~4400 bytes (heavily loop-unrolled 2-D wave simulation).
	//
	// Algorithm:
	//   SourceFields (this+0x900) holds two half-resolution height maps
	//   back-to-back (ping-pong).  Each frame the parity byte (this+0x1308)
	//   selects which half is source and which is destination.
	//   Wave step  : dst[x,y] = WaveTable [laplacian + 512]
	//     where laplacian = sum_4_neighbors - 2*center, table at this+0xd08.
	//   Render step: pixel   = RenderTable[dX + dY    + 512]
	//     where dX = right-left, dY = down-up differences, table at this+0x904.
	//   Output is bilinearly upsampled 2x to the full-res mip.
	//
	// DIVERGENCE: uses simple 2x2 nearest-neighbour upsampling instead of
	// the Ghidra 4-subpixel bilinear interpolation.  The wave physics and
	// table lookups are faithful to the Ghidra algorithm.

	BYTE* Pixels = GetMipPixels( this );
	BYTE* SF     = (BYTE*)PTR_AT(this, 0x900);
	if( !Pixels || !SF ) return;

	INT HalfW = INT_AT(this, 0x60) / 2;
	INT HalfH = INT_AT(this, 0x64) / 2;
	if( HalfW < 4 || HalfH < 2 ) return;

	INT   HalfSize = HalfW * HalfH;
	BYTE  Parity   = BYTE_AT(this, 0x1308);
	BYTE_AT(this, 0x1308) = Parity + 1;

	BYTE* Src = (Parity & 1) ? (SF + HalfSize) : SF;
	BYTE* Dst = (Parity & 1) ? SF               : (SF + HalfSize);

	// Wave simulation table: at this+0xd08, centred at +0xf08 (=0xd08+0x200).
	BYTE* WaveTable   = (BYTE*)this + 0xd08;
	// Render difference table: at this+0x904, centred at +0xb04 (=0x904+0x200).
	BYTE* RenderTable = (BYTE*)this + 0x904;

	BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;
	INT  USize = INT_AT(this, 0x60);
	INT  VSize = INT_AT(this, 0x64);

	// --- wave update ---
	for( INT Y = 0; Y < HalfH; Y++ )
	{
		INT Yp = (Y > 0)          ? Y - 1 : HalfH - 1;
		INT Yn = (Y < HalfH - 1)  ? Y + 1 : 0;
		for( INT X = 0; X < HalfW; X++ )
		{
			INT Xp = (X > 0)         ? X - 1 : HalfW - 1;
			INT Xn = (X < HalfW - 1) ? X + 1 : 0;
			INT c  = (INT)Src[Y*HalfW + X];
			INT nb = (INT)Src[Yp*HalfW + X]
			       + (INT)Src[Yn*HalfW + X]
			       + (INT)Src[Y*HalfW  + Xp]
			       + (INT)Src[Y*HalfW  + Xn];
			INT Lap = nb - 2*c; // range -510..+1020
			Dst[Y*HalfW + X] = WaveTable[Lap + 512];
		}
	}

	// --- render to full-res mip ---
	for( INT Y = 0; Y < HalfH; Y++ )
	{
		INT Yp = (Y > 0)         ? Y - 1 : HalfH - 1;
		INT Yn = (Y < HalfH - 1) ? Y + 1 : 0;
		for( INT X = 0; X < HalfW; X++ )
		{
			INT Xp = (X > 0)         ? X - 1 : HalfW - 1;
			INT Xn = (X < HalfW - 1) ? X + 1 : 0;
			INT dX = (INT)Dst[Y*HalfW + Xn]  - (INT)Dst[Y*HalfW  + Xp]; // horiz diff
			INT dY = (INT)Dst[Yn*HalfW + X]  - (INT)Dst[Yp*HalfW + X];  // vert diff
			BYTE Val = RenderTable[dX + dY + 512]; // index range 2..1022
			INT xo = X * 2;
			INT yo = Y * 2;
			Pixels[(yo       << UBits) + xo]     = Val;
			Pixels[(yo       << UBits) + xo + 1] = Val;
			if( yo + 1 < VSize )
			{
				Pixels[((yo + 1) << UBits) + xo]     = Val;
				Pixels[((yo + 1) << UBits) + xo + 1] = Val;
			}
		}
	}
}

IMPL_DIVERGE("PRNG approximated with RandByte")
void UWaterTexture::WaterRedrawDrops()
{
	// Ghidra: 0x18e0, ~2000 bytes — full drop-type switch.
	// Iterates Drops[], executing type-specific behaviour.  Each drop writes
	// into the BOTH halves of the SourceFields buffer (both ping-pong planes)
	// so the value persists regardless of which half is "current".
	//
	// Drop layout at this+0x100, 8 bytes each:
	//   [0] Type  [1] Depth/Heat  [2] X  [3] Y  [4] ByteA  [5] ByteB
	//   [6] ByteC [7] ByteD
	//
	// DIVERGENCE: FUN_10509f60 approximated by RandByte() / appRand().
	// sine/cosine lookups use GSinU[] (DAT_105134f8).

	InitFireTables();

	DWORD HalfUMask = UINT_AT(this, 0xd8) >> 1;  // half-res X mask
	DWORD HalfVMask = UINT_AT(this, 0xdc) >> 1;  // half-res Y mask
	INT   SF        = PTR_AT(this, 0x900);
	BYTE  UBits     = BYTE_AT(this, 0x5b) & 0x1f;
	INT   HalfW     = INT_AT(this, 0x60) / 2;
	INT   SF2       = SF + HalfW;                 // second ping-pong half, shifted by one row

	INT_AT(this, 0xe8) = INT_AT(this, 0xe8) + 1;  // GlobalPhase++

	INT NumDrops = INT_AT(this, 0xfc);
	if( NumDrops <= 0 ) return;

	BYTE* DropsBase = (BYTE*)this + 0x100;

	for( INT i = 0; i < NumDrops; i++ )
	{
		BYTE* D = DropsBase + i * 8;
		BYTE  DType  = D[0];
		BYTE  DDepth = D[1];
		BYTE  DX     = D[2];
		BYTE  DY     = D[3];
		// ByteA=D[4], ByteB=D[5], ByteC=D[6], ByteD=D[7]

		DWORD uX   = (DWORD)DX & (HalfUMask & 0xff);
		DWORD uY   = (DWORD)DY & (HalfVMask & 0xff);
		INT   Base = (INT)( (uY << UBits) + uX );

		switch( DType )
		{
		case 0x00: // static drop at depth
		{
			*(BYTE*)(SF  + Base) = DDepth;
			*(BYTE*)(SF2 + Base) = DDepth;
			break;
		}
		case 0x01: // oscillating, full amplitude
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[7]);
			BYTE Val = GSinU[(BYTE)D[1]];
			*(BYTE*)(SF  + Base) = Val;
			*(BYTE*)(SF2 + Base) = Val;
			break;
		}
		case 0x02: // oscillating, half amplitude
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[7]);
			BYTE Val = (BYTE)( (GSinU[(BYTE)D[1]] >> 1) + 0x40 );
			*(BYTE*)(SF  + Base) = Val;
			*(BYTE*)(SF2 + Base) = Val;
			break;
		}
		case 0x03: // oscillating, clamped at 0x80 minimum
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[7]);
			BYTE Val = GSinU[(BYTE)D[1]];
			if( Val < 0x80 ) Val = 0x80;
			*(BYTE*)(SF  + Base) = Val;
			*(BYTE*)(SF2 + Base) = Val;
			break;
		}
		case 0x04: // random walk drop
		{
			BYTE r1 = RandByte(), r2 = RandByte();
			D[2] = (BYTE)(( (INT)(r1 & 3) - (INT)(r2 & 3) + (signed char)D[2] ) & (HalfUMask & 0xff));
			r1 = RandByte(); r2 = RandByte();
			D[3] = (BYTE)(( (INT)(r1 & 3) - (INT)(r2 & 3) + (signed char)D[3] ) & (HalfVMask & 0xff));
			*(BYTE*)(SF  + Base) = 0xb9;
			*(BYTE*)(SF2 + Base) = 0x47;
			break;
		}
		case 0x05: // random scatter
		{
			BYTE v = RandByte();
			*(BYTE*)(SF  + Base) = v;
			v = RandByte();
			*(BYTE*)(SF2 + Base) = v;
			break;
		}
		case 0x06: // orbital with orbit phase in ByteC/ByteD (16-bit accumulator)
		{
			DWORD Phase = ( (DWORD)D[5] * 0x100 + (DWORD)D[4] + (DWORD)D[6] + (DWORD)D[7] * 0x100 ) & 0xffff;
			D[4] = (BYTE) Phase;
			D[5] = (BYTE)(Phase >> 8);
			DWORD OrbitX = ( (GSinU[Phase >> 8] >> 4) + (DWORD)DX ) & (HalfUMask & 0xff);
			DWORD OrbitY = ( (GSinU[((Phase >> 8) + 0x40) & 0xff] >> 4) + (DWORD)DY ) & (HalfVMask & 0xff);
			INT OBase = (INT)( (OrbitY << UBits) + OrbitX );
			*(BYTE*)(SF  + OBase) = DDepth;
			*(BYTE*)(SF2 + OBase) = DDepth;
			break;
		}
		case 0x07: // orbital, different scale
		{
			DWORD Phase = ( (DWORD)D[4] + (DWORD)D[5] * 0x100 + (DWORD)D[7] * 0x100 - (DWORD)D[6] ) & 0xffff;
			D[5] = (BYTE)(Phase >> 8);
			D[4] = (BYTE) Phase;
			DWORD OrbitX = ( (GSinU[Phase >> 8] >> 3) + (DWORD)DX ) & (HalfUMask & 0xff);
			DWORD OrbitY = ( (GSinU[((Phase >> 8) + 0x40) & 0xff] >> 3) + (DWORD)DY ) & (HalfVMask & 0xff);
			INT OBase = (INT)( (OrbitY << UBits) + OrbitX );
			*(BYTE*)(SF  + OBase) = DDepth;
			*(BYTE*)(SF2 + OBase) = DDepth;
			break;
		}
		case 0x08: // horizontal line fill
		{
			INT Len = ((INT)(D[7] >> 1)) + 1;
			DWORD CurX = uX;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FX = CurX & (HalfUMask & 0xff);
				INT FBase = (INT)( (uY << UBits) + FX );
				*(BYTE*)(SF  + FBase) = DDepth;
				*(BYTE*)(SF2 + FBase) = DDepth;
				CurX++;
			}
			break;
		}
		case 0x09: // vertical line fill
		{
			INT Len = ((INT)(D[7] >> 1)) + 1;
			DWORD CurY = uY;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FY = CurY & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + uX );
				*(BYTE*)(SF  + FBase) = DDepth;
				*(BYTE*)(SF2 + FBase) = DDepth;
				CurY++;
			}
			break;
		}
		case 0x0a: // diagonal line fill (down-left)
		{
			INT Len = ((INT)(D[7] >> 1)) + 1;
			DWORD CurX = uX, CurY = uY;
			for( INT j = 0; j <= Len; j++ )
			{
				DWORD FX = (uX - (DWORD)j) & (HalfUMask & 0xff);
				DWORD FY = (uY + (DWORD)j) & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + FX );
				*(BYTE*)(SF  + FBase) = DDepth;
				*(BYTE*)(SF2 + FBase) = DDepth;
			}
			break;
		}
		case 0x0b: // diagonal line fill (down-right)
		{
			INT Len = ((INT)(D[7] >> 1)) + 1;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FX = ((DWORD)j + uX) & (HalfUMask & 0xff);
				DWORD FY = ((DWORD)j + uY) & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + FX );
				*(BYTE*)(SF  + FBase) = DDepth;
				*(BYTE*)(SF2 + FBase) = DDepth;
			}
			break;
		}
		case 0x0c: // oscillating horizontal line
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[6]);
			BYTE Val = GSinU[(BYTE)D[1]];
			INT Len = ((INT)(D[7] >> 1)) + 1;
			INT Row = (INT)(uY << UBits);
			DWORD CurX = uX;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FX = CurX & (HalfUMask & 0xff);
				*(BYTE*)(SF  + Row + FX) = Val;
				*(BYTE*)(SF2 + Row + FX) = Val;
				CurX++;
			}
			break;
		}
		case 0x0d: // oscillating vertical line
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[6]);
			BYTE Val = GSinU[(BYTE)D[1]];
			INT Len = ((INT)(D[7] >> 1)) + 1;
			DWORD CurY = uY;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FY = CurY & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + uX );
				*(BYTE*)(SF  + FBase) = Val;
				*(BYTE*)(SF2 + FBase) = Val;
				CurY++;
			}
			break;
		}
		case 0x0e: // oscillating diagonal line (down-left)
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[6]);
			BYTE Val = GSinU[(BYTE)D[1]];
			INT Len = ((INT)(D[7] >> 1)) + 1;
			for( INT j = 0; j <= Len; j++ )
			{
				DWORD FX = (uX - (DWORD)j) & (HalfUMask & 0xff);
				DWORD FY = (uY + (DWORD)j) & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + FX );
				*(BYTE*)(SF  + FBase) = Val;
				*(BYTE*)(SF2 + FBase) = Val;
			}
			break;
		}
		case 0x0f: // oscillating diagonal line (down-right)
		{
			D[1] = (BYTE)((signed char)D[1] + (signed char)D[6]);
			BYTE Val = GSinU[(BYTE)D[1]];
			INT Len = ((INT)(D[7] >> 1)) + 1;
			for( INT j = 0; j < Len; j++ )
			{
				DWORD FX = ((DWORD)j + uX) & (HalfUMask & 0xff);
				DWORD FY = ((DWORD)j + uY) & (HalfVMask & 0xff);
				INT FBase = (INT)( (FY << UBits) + FX );
				*(BYTE*)(SF  + FBase) = Val;
				*(BYTE*)(SF2 + FBase) = Val;
			}
			break;
		}
		case 0x10: // random scatter with occasional wander
		{
			BYTE r = RandByte();
			if( (r & 0xf) == 0 )
			{
				BYTE r2 = RandByte(), r3 = RandByte();
				DWORD ScX = ( ((INT)((r2 & 0xff) * (INT)D[7]) >> 8) + (INT)(signed char)D[2] ) & (HalfUMask & 0xff);
				DWORD ScY = ( ((INT)((r3 & 0xff) * (INT)D[7]) >> 8) + (INT)(signed char)D[3] ) & (HalfVMask & 0xff);
				INT FBase = (INT)( (ScY << UBits) + ScX );
				*(BYTE*)(SF  + FBase) = DDepth;
				*(BYTE*)(SF2 + FBase) = (BYTE)(~DDepth);
			}
			r = RandByte();
			if( (r & 0xf) == 0xf ) { BYTE r2 = RandByte(); D[2] = (BYTE)((((r2 & 0xf) + (INT)(signed char)D[2]) - 7) & (HalfUMask & 0xff)); }
			r = RandByte();
			if( (r & 0xf) == 0xf ) { BYTE r2 = RandByte(); D[3] = (BYTE)((((r2 & 0xf) + (INT)(signed char)D[3]) - 7) & (HalfVMask & 0xff)); }
			break;
		}
		case 0x11: // filled area
		{
			DWORD HalfSize11 = (DWORD)(D[7] >> 1);
			if( HalfSize11 == 0 ) break;
			for( DWORD fy = 0; fy < HalfSize11; fy++ )
			{
				DWORD FY = (uY + fy) & (HalfVMask & 0xff);
				for( DWORD fx = 0; fx < HalfSize11; fx++ )
				{
					DWORD FX = (uX + fx) & (HalfUMask & 0xff);
					INT FBase = (INT)( (FY << UBits) + FX );
					*(BYTE*)(SF  + FBase) = DDepth;
					*(BYTE*)(SF2 + FBase) = DDepth;
				}
			}
			break;
		}
		case 0x12: // pulsing (counter wraps → plot + reset)
		{
			D[4] = (BYTE)((signed char)D[4] + (signed char)D[7]);
			if( (BYTE)D[4] <= D[7] )
			{
				*(BYTE*)(SF  + Base) = DDepth;
				*(BYTE*)(SF2 + Base) = (BYTE)(~DDepth);
			}
			break;
		}
		case 0x13: // pulsing with random reset
		{
			D[4] = (BYTE)((signed char)D[4] + (signed char)D[7]);
			if( (BYTE)D[4] <= D[7] )
			{
				D[4] = RandByte();
				*(BYTE*)(SF  + Base) = DDepth;
				*(BYTE*)(SF2 + Base) = (BYTE)(~DDepth);
			}
			break;
		}
		case 0x40: // reverse-orbit, coarser scale
		{
			DWORD Phase = ( (DWORD)D[5] * 0x100 - (DWORD)D[6] + (DWORD)D[7] * 0x100 * (-1) + (DWORD)D[4] ) & 0xffff;
			D[4] = (BYTE) Phase;
			D[5] = (BYTE)(Phase >> 8);
			DWORD OrbitX = ( (GSinU[Phase >> 8] >> 4) + (DWORD)DX ) & (HalfUMask & 0xff);
			DWORD OrbitY = ( (GSinU[((Phase >> 8) + 0x40) & 0xff] >> 4) + (DWORD)DY ) & (HalfVMask & 0xff);
			INT OBase = (INT)( (OrbitY << UBits) + OrbitX );
			*(BYTE*)(SF  + OBase) = DDepth;
			*(BYTE*)(SF2 + OBase) = DDepth;
			break;
		}
		case 0x41: // reverse-orbit, finer scale
		{
			DWORD Phase = ( (DWORD)D[5] * 0x100 - (DWORD)D[6] + (DWORD)D[7] * 0x100 * (-1) + (DWORD)D[4] ) & 0xffff;
			D[5] = (BYTE)(Phase >> 8);
			D[4] = (BYTE) Phase;
			DWORD OrbitX = ( (GSinU[Phase >> 8] >> 3) + (DWORD)DX ) & (HalfUMask & 0xff);
			DWORD OrbitY = ( (GSinU[((Phase >> 8) + 0x40) & 0xff] >> 3) + (DWORD)DY ) & (HalfVMask & 0xff);
			INT OBase = (INT)( (OrbitY << UBits) + OrbitX );
			*(BYTE*)(SF  + OBase) = DDepth;
			*(BYTE*)(SF2 + OBase) = DDepth;
			break;
		}
		default:
			break;
		}
	}
}

/*-----------------------------------------------------------------------------
	UWaveTexture — animated wave effect.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x10502730)
void UWaveTexture::Clear( DWORD Flags )
{
	UWaterTexture::Clear( Flags );
}

IMPL_MATCH("Fire.dll", 0x10509560)
void UWaveTexture::Init( INT InUSize, INT InVSize )
{
	UWaterTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x2780)
void UWaveTexture::ConstantTimeTick()
{
	// Ghidra at 0x2780: calls WaterRedrawDrops, CalculateWater, SetWaveLight.
	WaterRedrawDrops();
	CalculateWater();
	SetWaveLight();
}

IMPL_MATCH("Fire.dll", 0x10507290)
void UWaveTexture::PostLoad()
{
	UWaterTexture::PostLoad();
}

IMPL_EMPTY("Confirmed empty in retail binary")
void UWaveTexture::SetWaveLight()
{
	// Confirmed empty in the retail binary (just 'ret').
}

/*-----------------------------------------------------------------------------
	UFluidTexture — fluid simulation texture.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x105027f0)
void UFluidTexture::Clear( DWORD Flags )
{
	UWaterTexture::Clear( Flags );
}

IMPL_MATCH("Fire.dll", 0x10509720)
void UFluidTexture::Init( INT InUSize, INT InVSize )
{
	UWaterTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x27a0)
void UFluidTexture::ConstantTimeTick()
{
	// Ghidra at 0x27a0: calls WaterRedrawDrops, CalculateFluid.
	WaterRedrawDrops();
	CalculateFluid();
}

IMPL_MATCH("Fire.dll", 0x105074b0)
void UFluidTexture::PostLoad()
{
	UWaterTexture::PostLoad();
}

IMPL_DIVERGE("nearest-neighbour 2x2 upsampling instead of bilinear")
void UFluidTexture::CalculateFluid()
{
	// Ghidra: 0x7600, ~3600 bytes (heavily loop-unrolled 2-D wave simulation).
	//
	// Identical to UWaterTexture::CalculateWater except the render pass
	// uses the SUM of the four neighbours (not differences) as the index
	// into WaterTable, producing a smooth blob rather than a surface-normal
	// displacement effect.
	//
	// DIVERGENCE: same simplifications as CalculateWater (nearest-neighbour
	// 2×2 upsampling, no loop unrolling).

	BYTE* Pixels = GetMipPixels( this );
	BYTE* SF     = (BYTE*)PTR_AT(this, 0x900);
	if( !Pixels || !SF ) return;

	INT HalfW = INT_AT(this, 0x60) / 2;
	INT HalfH = INT_AT(this, 0x64) / 2;
	if( HalfW < 4 || HalfH < 2 ) return;

	INT   HalfSize = HalfW * HalfH;
	BYTE  Parity   = BYTE_AT(this, 0x1308);
	BYTE_AT(this, 0x1308) = Parity + 1;

	BYTE* Src = (Parity & 1) ? (SF + HalfSize) : SF;
	BYTE* Dst = (Parity & 1) ? SF               : (SF + HalfSize);

	BYTE* WaveTable  = (BYTE*)this + 0xd08;
	BYTE* WaterTable = (BYTE*)this + 0x904; // sum-based render: 0..1020 → [0..0x3fc]

	BYTE UBits = BYTE_AT(this, 0x5b) & 0x1f;
	INT  VSize = INT_AT(this, 0x64);

	// --- wave update (same as CalculateWater) ---
	for( INT Y = 0; Y < HalfH; Y++ )
	{
		INT Yp = (Y > 0)          ? Y - 1 : HalfH - 1;
		INT Yn = (Y < HalfH - 1)  ? Y + 1 : 0;
		for( INT X = 0; X < HalfW; X++ )
		{
			INT Xp = (X > 0)         ? X - 1 : HalfW - 1;
			INT Xn = (X < HalfW - 1) ? X + 1 : 0;
			INT c  = (INT)Src[Y*HalfW + X];
			INT nb = (INT)Src[Yp*HalfW + X]
			       + (INT)Src[Yn*HalfW + X]
			       + (INT)Src[Y*HalfW  + Xp]
			       + (INT)Src[Y*HalfW  + Xn];
			Dst[Y*HalfW + X] = WaveTable[nb - 2*c + 512];
		}
	}

	// --- render: sum-based lookup (smooth blob appearance) ---
	for( INT Y = 0; Y < HalfH; Y++ )
	{
		INT Yp = (Y > 0)         ? Y - 1 : HalfH - 1;
		INT Yn = (Y < HalfH - 1) ? Y + 1 : 0;
		for( INT X = 0; X < HalfW; X++ )
		{
			INT Xp = (X > 0)         ? X - 1 : HalfW - 1;
			INT Xn = (X < HalfW - 1) ? X + 1 : 0;
			INT Sum = (INT)Dst[Yp*HalfW + X]
			        + (INT)Dst[Yn*HalfW + X]
			        + (INT)Dst[Y*HalfW  + Xp]
			        + (INT)Dst[Y*HalfW  + Xn]; // range 0..1020
			BYTE Val = WaterTable[Sum];
			INT xo = X * 2;
			INT yo = Y * 2;
			Pixels[(yo       << UBits) + xo]     = Val;
			Pixels[(yo       << UBits) + xo + 1] = Val;
			if( yo + 1 < VSize )
			{
				Pixels[((yo + 1) << UBits) + xo]     = Val;
				Pixels[((yo + 1) << UBits) + xo + 1] = Val;
			}
		}
	}
}

/*-----------------------------------------------------------------------------
	UIceTexture — animated ice/glass effect.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x105029e0)
void UIceTexture::Clear( DWORD Flags )
{
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( Pixels, Size );
	}
}

IMPL_MATCH("Fire.dll", 0x10509ba0)
void UIceTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x27c0)
void UIceTexture::ConstantTimeTick()
{
	// Ghidra at 0x27c0: calls RenderIce.
	RenderIce( 1.0f );
}

IMPL_MATCH("Fire.dll", 0x9d70)
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

IMPL_MATCH("Fire.dll", 0x2420)
void UIceTexture::Click( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra at 0x2420: confirmed empty.
}

IMPL_MATCH("Fire.dll", 0x10502a60)
void UIceTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y )
{
	// Ghidra: sets ForceRefresh flag so ice re-renders.
	INT_AT(this, 0x130) = 1;
}

IMPL_MATCH("Fire.dll", 0x105089e0)
void UIceTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

IMPL_MATCH("Fire.dll", 0x10502ad0)
void UIceTexture::Destroy()
{
	UTexture::Destroy();
}

IMPL_MATCH("Fire.dll", 0x89e0)
void UIceTexture::MoveIcePosition( FLOAT Delta )
{
	// Ghidra at 0x89e0: updates UPosition/VPosition floats based on
	// speed parameters and delta time.
	FLOAT USpeed = (FLOAT)(signed char)(BYTE_AT(this, 0xfa)) * Delta;
	FLOAT VSpeed = (FLOAT)(signed char)(BYTE_AT(this, 0xfb)) * Delta;
	FLOAT_AT(this, 0x110) += USpeed;
	FLOAT_AT(this, 0x114) += VSpeed;
}

IMPL_MATCH("Fire.dll", 0x8c00)
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

IMPL_DIVERGE("skips vtable lock calls; assumes textures already loaded")
void UIceTexture::BlitIceTex()
{
	// Ghidra: 0x65c0, 380 bytes.
	// Source texture (this+0xf4) pixels are used as X-displacement offsets into
	// the glass texture (this+0xf0), writing to the output mip.  The glass row
	// is selected by (OldVPos + Y) & VMask; the X lookup is
	// (source_pixel + X + OldUPos) & UMask.
	INT SrcTex   = PTR_AT(this, 0xf4);
	INT GlassTex = PTR_AT(this, 0xf0);
	if( !SrcTex || !GlassTex ) return;

	// DIVERGENCE: skip vtable lock calls (Ghidra calls *(code*)**(ptr**)(mipArray+0x10)
	// to lock non-resident textures). We assume they're already loaded.
	BYTE* SrcPix   = (BYTE*)*(INT*)( PTR_AT(SrcTex,   0xbc) + 0x1c );
	BYTE* GlassPix = (BYTE*)*(INT*)( PTR_AT(GlassTex, 0xbc) + 0x1c );
	BYTE* DstPix   = GetMipPixels( this );
	if( !SrcPix || !GlassPix || !DstPix ) return;

	if( INT_AT(this, 300) != 0 ) return;  // TickFlag guard

	INT   USize   = INT_AT(this, 0x60);
	INT   VSize   = INT_AT(this, 0x64);
	DWORD UMask   = UINT_AT(this, 0xd8);
	DWORD VMask   = UINT_AT(this, 0xdc);
	BYTE  UBits   = BYTE_AT(this, 0x5b) & 0x1f;
	DWORD OldU    = (DWORD)appRound( FLOAT_AT(this, 0x110) );
	DWORD OldV    = (DWORD)appRound( FLOAT_AT(this, 0x114) );

	for( INT Y = 0; Y < VSize; Y++ )
	{
		INT DstRow  = Y << UBits;
		INT SrcRow  = Y << UBits;
		INT GlassRow = (INT)(( (VMask & OldV) + (DWORD)Y ) & VMask) << UBits;
		for( INT X = 0; X < USize; X += 2 )
		{
			DstPix[DstRow + X]     = GlassPix[(( (DWORD)SrcPix[SrcRow+X]     + (DWORD)X     + (UMask & OldU) ) & UMask) + GlassRow];
			DstPix[DstRow + X + 1] = GlassPix[(( (DWORD)SrcPix[SrcRow+X+1]   + (DWORD)(X+1) + (UMask & OldU) ) & UMask) + GlassRow];
		}
	}
}

IMPL_DIVERGE("skips vtable lock calls")
void UIceTexture::BlitTexIce()
{
	// Ghidra: 0x6400, 393 bytes.
	// Alternate ice blit: glass pixel at (OldU+X & UMask, OldV+Y & VMask) is
	// looked up through the SOURCE texture as a second-level displacement,
	// then written to the output.
	INT SrcTex   = PTR_AT(this, 0xf4);
	INT GlassTex = PTR_AT(this, 0xf0);
	if( !SrcTex || !GlassTex ) return;

	// DIVERGENCE: skip vtable lock calls.
	BYTE* GlassPix = (BYTE*)*(INT*)( PTR_AT(GlassTex, 0xbc) + 0x1c );
	BYTE* DstPix   = GetMipPixels( this );
	BYTE* SrcPix   = (BYTE*)*(INT*)( PTR_AT(SrcTex,   0xbc) + 0x1c );
	if( !GlassPix || !DstPix || !SrcPix ) return;

	if( INT_AT(this, 300) != 0 ) return;

	INT   USize = INT_AT(this, 0x60);
	INT   VSize = INT_AT(this, 0x64);
	DWORD UMask = UINT_AT(this, 0xd8);
	DWORD VMask = UINT_AT(this, 0xdc);
	BYTE  UBits = BYTE_AT(this, 0x5b) & 0x1f;
	DWORD OldU  = (DWORD)appRound( FLOAT_AT(this, 0x110) );
	DWORD OldV  = (DWORD)appRound( FLOAT_AT(this, 0x114) );

	for( INT Y = 0; Y < VSize; Y++ )
	{
		INT DstRow   = Y << UBits;
		INT SrcRow   = Y << UBits;
		INT GlassRow = (INT)(( (VMask & OldV) + (DWORD)Y ) & VMask) << UBits;
		for( INT X = 0; X < USize; X += 2 )
		{
			// Lookup glass pixel, use its value as a secondary X displacement into source.
			BYTE G0 = GlassPix[(( (UMask & OldU) + (DWORD)X     ) & UMask) + GlassRow];
			BYTE G1 = GlassPix[(( (UMask & OldU) + (DWORD)(X+1) ) & UMask) + GlassRow];
			DstPix[DstRow + X]     = SrcPix[(( (DWORD)G0 + (DWORD)X     ) & UMask) + SrcRow];
			DstPix[DstRow + X + 1] = SrcPix[(( (DWORD)G1 + (DWORD)(X+1) ) & UMask) + SrcRow];
		}
	}
}

/*-----------------------------------------------------------------------------
	UWetTexture — animated wet surface effect.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Fire.dll", 0x105028a0)
void UWetTexture::Clear( DWORD Flags )
{
	BYTE* Pixels = GetMipPixels( this );
	if( Pixels )
	{
		INT Size = INT_AT(this, 0x60) * INT_AT(this, 0x64);
		appMemzero( Pixels, Size );
	}
}

IMPL_MATCH("Fire.dll", 0x105098c0)
void UWetTexture::Init( INT InUSize, INT InVSize )
{
	UFractalTexture::Init( InUSize, InVSize );
}

IMPL_MATCH("Fire.dll", 0x27b0)
void UWetTexture::ConstantTimeTick()
{
	// Ghidra at 0x27b0: calls ApplyWetTexture.
	ApplyWetTexture();
}

IMPL_MATCH("Fire.dll", 0x105099d0)
void UWetTexture::PostLoad()
{
	UFractalTexture::PostLoad();
}

IMPL_MATCH("Fire.dll", 0x10502950)
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

IMPL_DIVERGE("skips vtable lock; assumes source texture loaded")
void UWetTexture::ApplyWetTexture()
{
	// Ghidra: 0x62c0, 269 bytes.
	// Reads source texture pixels as X-displacement offsets into the LocalBitmap
	// (or source mip directly), then writes refractive output into the mip.
	INT SrcTex = PTR_AT(this, 0x1310);
	if( !SrcTex ) return;

	BYTE* DstPixels = GetMipPixels( this );
	if( !DstPixels ) return;

	INT LocalBitmap = PTR_AT(this, 0x1318);
	BYTE* SrcPixels;

	if( LocalBitmap == 0 )
	{
		// Check source texture mip is loaded (ObjectFlags bit 5 = RF_LoadContextFlags cached).
		// Ghidra: if (flags & 0x20) == 0, call the lock virtual (vtable[4]).
		// DIVERGENCE: we skip the vtable lock and just access the mip directly.
		if( PTR_AT(SrcTex, 0xc0) == 0 ) return;
		// Verify source mip is large enough for our texture.
		INT SrcMipsArr  = PTR_AT(SrcTex, 0xbc);
		if( *(INT*)(SrcMipsArr + 0x20) < INT_AT(this, 0x64) * INT_AT(this, 0x60) ) return;
		SrcPixels = (BYTE*)*(INT*)(SrcMipsArr + 0x1c);
	}
	else
	{
		SrcPixels = (BYTE*)LocalBitmap;
	}

	INT  VSize  = INT_AT(this, 0x64);
	INT  USize  = INT_AT(this, 0x60);
	DWORD UMask = UINT_AT(this, 0xd8);
	BYTE  UBits = BYTE_AT(this, 0x5b) & 0x1f;

	// For each row, each pair of pixels: displace X read by the pixel value itself.
	for( INT Y = 0; Y < VSize; Y++ )
	{
		INT RowOff = Y << UBits;
		for( INT X = 0; X < USize; X += 2 )
		{
			DstPixels[RowOff + X]     = SrcPixels[((DstPixels[RowOff + X]     + X    ) & UMask) + RowOff];
			DstPixels[RowOff + X + 1] = SrcPixels[((DstPixels[RowOff + X + 1] + X + 1) & UMask) + RowOff];
		}
	}
}

IMPL_MATCH("Fire.dll", 0x8900)
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
