/*=============================================================================
	Fire.cpp: Unreal fire effects package implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
	7 procedural texture classes for animated fire, water, ice, and wet effects.
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
}
void UFractalTexture::Prime()
{
}
void UFractalTexture::TouchTexture( INT X, INT Y, FLOAT Z )
{
}

/*-----------------------------------------------------------------------------
	UFireTexture — animated fire effect.
-----------------------------------------------------------------------------*/

void UFireTexture::Clear( DWORD Flags ) {}
void UFireTexture::Init( INT InUSize, INT InVSize ) { UFractalTexture::Init( InUSize, InVSize ); }
void UFireTexture::ConstantTimeTick() {}
void UFireTexture::Click( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UFireTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UFireTexture::TouchTexture( INT X, INT Y, FLOAT Z ) {}
void UFireTexture::PostLoad() { UFractalTexture::PostLoad(); }
void UFireTexture::Serialize( FArchive& Ar ) { UFractalTexture::Serialize( Ar ); }

void UFireTexture::AddSpark( INT X, INT Y ) {}
void UFireTexture::CloseSpark( INT X, INT Y ) {}
void UFireTexture::DeleteSparks( INT X, INT Y, INT Z ) {}
void UFireTexture::DrawFlashRamp( LineSeg Seg, BYTE A, BYTE B ) {}
void UFireTexture::DrawSparkLine( INT X1, INT Y1, INT X2, INT Y2, INT H ) {}
void UFireTexture::FirePaint( INT X, INT Y, DWORD C ) {}
void UFireTexture::MoveSpark( FSpark* S ) {}
void UFireTexture::MoveSparkAngle( FSpark* S, BYTE Angle ) {}
void UFireTexture::MoveSparkTwo( FSpark* S ) {}
void UFireTexture::MoveSparkXY( FSpark* S, signed char DX, signed char DY ) {}
void UFireTexture::PostDrawSparks() {}
void UFireTexture::RedrawSparks() {}
void UFireTexture::TempDrawSpark( INT X, INT Y, INT H ) {}

/*-----------------------------------------------------------------------------
	UWaterTexture — animated water ripple effect.
-----------------------------------------------------------------------------*/

void UWaterTexture::Clear( DWORD Flags ) {}
void UWaterTexture::Init( INT InUSize, INT InVSize ) { UFractalTexture::Init( InUSize, InVSize ); }
void UWaterTexture::Click( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UWaterTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UWaterTexture::TouchTexture( INT X, INT Y, FLOAT Z ) {}
void UWaterTexture::PostLoad() { UFractalTexture::PostLoad(); }
void UWaterTexture::Destroy() { UFractalTexture::Destroy(); }

void UWaterTexture::CalculateWater() {}
void UWaterTexture::WaterRedrawDrops() {}
void UWaterTexture::AddDrop( INT X, INT Y ) {}
void UWaterTexture::DeleteDrops( INT X, INT Y, INT Z ) {}
void UWaterTexture::WaterPaint( INT X, INT Y, DWORD C ) {}

/*-----------------------------------------------------------------------------
	UWaveTexture — animated wave effect.
-----------------------------------------------------------------------------*/

void UWaveTexture::Clear( DWORD Flags ) {}
void UWaveTexture::Init( INT InUSize, INT InVSize ) { UWaterTexture::Init( InUSize, InVSize ); }
void UWaveTexture::ConstantTimeTick() {}
void UWaveTexture::PostLoad() { UWaterTexture::PostLoad(); }
void UWaveTexture::SetWaveLight() {}

/*-----------------------------------------------------------------------------
	UFluidTexture — fluid simulation texture.
-----------------------------------------------------------------------------*/

void UFluidTexture::Clear( DWORD Flags ) {}
void UFluidTexture::Init( INT InUSize, INT InVSize ) { UWaterTexture::Init( InUSize, InVSize ); }
void UFluidTexture::ConstantTimeTick() {}
void UFluidTexture::PostLoad() { UWaterTexture::PostLoad(); }
void UFluidTexture::CalculateFluid() {}

/*-----------------------------------------------------------------------------
	UIceTexture — animated ice/glass effect.
-----------------------------------------------------------------------------*/

void UIceTexture::Clear( DWORD Flags ) {}
void UIceTexture::Init( INT InUSize, INT InVSize ) { UFractalTexture::Init( InUSize, InVSize ); }
void UIceTexture::ConstantTimeTick() {}
void UIceTexture::Tick( FLOAT DeltaTime ) {}
void UIceTexture::Click( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UIceTexture::MousePosition( DWORD Flags, FLOAT X, FLOAT Y ) {}
void UIceTexture::PostLoad() { UFractalTexture::PostLoad(); }
void UIceTexture::Destroy() { UFractalTexture::Destroy(); }

void UIceTexture::MoveIcePosition( FLOAT Delta ) {}
void UIceTexture::RenderIce( FLOAT Delta ) {}
void UIceTexture::BlitIceTex() {}
void UIceTexture::BlitTexIce() {}

/*-----------------------------------------------------------------------------
	UWetTexture — animated wet surface effect.
-----------------------------------------------------------------------------*/

void UWetTexture::Clear( DWORD Flags ) {}
void UWetTexture::Init( INT InUSize, INT InVSize ) { UFractalTexture::Init( InUSize, InVSize ); }
void UWetTexture::ConstantTimeTick() {}
void UWetTexture::PostLoad() { UFractalTexture::PostLoad(); }
void UWetTexture::Destroy() { UFractalTexture::Destroy(); }

void UWetTexture::ApplyWetTexture() {}
void UWetTexture::SetRefractionTable() {}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
