/*=============================================================================
	UnRender.cpp: URenderDevice, UCanvas, AHUD implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations and decompiled method
	bodies for the rendering interface classes. URenderDevice is the
	abstract base that D3D/OpenGL drivers implement, UCanvas is the
	2D drawing API used by HUD and menus, and AHUD is the in-game
	heads-up display actor.

	This file is permanent and will grow as rendering code is
	decompiled.
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(URenderDevice);
IMPLEMENT_CLASS(UCanvas);
IMPLEMENT_CLASS(AHUD);

/*=============================================================================
	UCanvas implementation.
=============================================================================*/

IMPL_INFERRED("sets Viewport pointer")
void UCanvas::Init( UViewport* InViewport )
{
	guard(UCanvas::Init);
	Viewport = InViewport;
	unguard;
}

IMPL_INFERRED("syncs SizeX/SizeY/ClipX/ClipY/HalfClip from Viewport")
void UCanvas::Update()
{
	guard(UCanvas::Update);
	if( Viewport )
	{
		SizeX = ClipX = m_fNormalClipX = Viewport->SizeX;
		SizeY = ClipY = m_fNormalClipY = Viewport->SizeY;
		HalfClipX = ClipX * 0.5f;
		HalfClipY = ClipY * 0.5f;
	}
	unguard;
}

/*-----------------------------------------------------------------------------
	UCanvas exec functions.
-----------------------------------------------------------------------------*/

IMPL_INFERRED("sets CurX/CurY from script parameters")
void UCanvas::execSetPos( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetPos);
	P_GET_FLOAT(X);
	P_GET_FLOAT(Y);
	P_FINISH;
	CurX = X;
	CurY = Y;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetPos );

IMPL_INFERRED("sets OrgX/OrgY from script parameters")
void UCanvas::execSetOrigin( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetOrigin);
	P_GET_FLOAT(X);
	P_GET_FLOAT(Y);
	P_FINISH;
	OrgX = X;
	OrgY = Y;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetOrigin );

IMPL_INFERRED("sets ClipX/ClipY/HalfClip/NormalClip from script parameters")
void UCanvas::execSetClip( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetClip);
	P_GET_FLOAT(X);
	P_GET_FLOAT(Y);
	P_FINISH;
	ClipX = X;
	ClipY = Y;
	HalfClipX = ClipX * 0.5f;
	HalfClipY = ClipY * 0.5f;
	m_fNormalClipX = ClipX;
	m_fNormalClipY = ClipY;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetClip );

IMPL_INFERRED("sets DrawColor RGBA from script parameters")
void UCanvas::execSetDrawColor( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetDrawColor);
	P_GET_BYTE(R);
	P_GET_BYTE(G);
	P_GET_BYTE(B);
	P_GET_BYTE_OPTX(A, 255);
	P_FINISH;
	DrawColor = FColor(R, G, B, A);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetDrawColor );

IMPL_INFERRED("draws text string and advances cursor position")
void UCanvas::execDrawText( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawText);
	P_GET_STR(Text);
	P_GET_UBOOL_OPTX(CR, 1);
	P_FINISH;
	if( Viewport && Viewport->RenDev && Font )
	{
		FPlane ColorPlane(DrawColor.R/255.f, DrawColor.G/255.f, DrawColor.B/255.f, DrawColor.A/255.f);
		INT XL = _DrawString( Font, appRound(CurX), appRound(CurY), *Text, ColorPlane, 0, 0, 0 );
		CurYL = Font ? 16.0f : 0.0f;
		if( CR )
		{
			CurY += CurYL;
			CurX = 0;
		}
	}
	else
		CurYL = 0.0f;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawText );

IMPL_INFERRED("draws text string without cursor advance")
void UCanvas::execDrawTextClipped( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawTextClipped);
	P_GET_STR(Text);
	P_GET_UBOOL_OPTX(bCheckHotKey, 0);
	P_FINISH;
	if( Viewport && Viewport->RenDev && Font )
	{
		FPlane ColorPlane(DrawColor.R/255.f, DrawColor.G/255.f, DrawColor.B/255.f, DrawColor.A/255.f);
		_DrawString( Font, appRound(CurX), appRound(CurY), *Text, ColorPlane, 0, 0, 0 );
		CurYL = 16.0f;
	}
	else
		CurYL = 0.0f;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTextClipped );

IMPL_APPROX("Needs Ghidra analysis")
void UCanvas::execClipTextNative( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execClipTextNative);
	P_GET_STR(Text);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execClipTextNative );

IMPL_INFERRED("draws a material tile and advances cursor")
void UCanvas::execDrawTile( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawTile);
	P_GET_OBJECT(UMaterial, Mat);
	P_GET_FLOAT(XL);
	P_GET_FLOAT(YL);
	P_GET_FLOAT(U);
	P_GET_FLOAT(V);
	P_GET_FLOAT(UL);
	P_GET_FLOAT(VL);
	P_FINISH;
	if( Viewport && Viewport->RenDev && Mat )
	{
		FPlane Color(DrawColor.R/255.f, DrawColor.G/255.f, DrawColor.B/255.f, DrawColor.A/255.f);
		DrawTile( Mat, CurX, CurY, XL, YL, U, V, UL, VL, Z, Color, FPlane(0,0,0,0), 0.0f );
	}
	CurX += XL;
	CurYL = Max(CurYL, YL);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTile );

IMPL_INFERRED("draws a clipped material tile and advances cursor")
void UCanvas::execDrawTileClipped( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawTileClipped);
	P_GET_OBJECT(UMaterial, Mat);
	P_GET_FLOAT(XL);
	P_GET_FLOAT(YL);
	P_GET_FLOAT(U);
	P_GET_FLOAT(V);
	P_GET_FLOAT(UL);
	P_GET_FLOAT(VL);
	P_FINISH;
	if( Viewport && Viewport->RenDev && Mat )
		DrawTileClipped( Mat, XL, YL, U, V, UL, VL );
	CurX += XL;
	CurYL = Max(CurYL, YL);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTileClipped );

IMPL_INFERRED("advances CurX and updates CurYL; actual stretch draw diverged")
void UCanvas::execDrawStretchedTextureSegmentNative( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawStretchedTextureSegmentNative);
	P_GET_FLOAT(X1);
	P_GET_FLOAT(Y1);
	P_GET_FLOAT(X2);
	P_GET_FLOAT(Y2);
	P_GET_FLOAT(U);
	P_GET_FLOAT(V);
	P_GET_FLOAT(UL);
	P_GET_FLOAT(VL);
	P_GET_OBJECT(UMaterial, Mat);
	P_FINISH;
	CurX = X2;
	CurYL = Max(CurYL, Y2 - Y1);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawStretchedTextureSegmentNative );

IMPL_APPROX("Needs Ghidra analysis")
void UCanvas::execDrawActor( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawActor);
	P_GET_OBJECT(AActor, Actor);
	P_GET_UBOOL(WireFrame);
	P_GET_UBOOL_OPTX(ClearZ, 0);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawActor );

IMPL_APPROX("Needs Ghidra analysis")
void UCanvas::execDrawPortal( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawPortal);
	P_GET_INT(X);
	P_GET_INT(Y);
	P_GET_INT(Width);
	P_GET_INT(Height);
	P_GET_OBJECT(AActor, CamActor);
	P_GET_VECTOR(CamLocation);
	P_GET_STRUCT(FRotator, CamRotation);
	P_GET_INT(FOV);
	P_GET_UBOOL_OPTX(ClearZ, 0);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawPortal );

IMPL_GHIDRA("Engine.dll", 0x89b10)
void UCanvas::execDraw3DLine( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDraw3DLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor, Color);
	P_FINISH;
	// Retail (0x89b10): creates FLineBatcher with RI at Viewport+0x164,
	// calls DrawLine, then destructs the batcher.
	if( Viewport )
	{
		FRenderInterface* RI = *(FRenderInterface**)((BYTE*)Viewport + 0x164);
		if( RI )
		{
			FLineBatcher Batcher( RI, 1, 0 );
			Batcher.DrawLine( Start, End, Color );
		}
	}
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDraw3DLine );

IMPL_INFERRED("approximates string pixel width from character count times 8")
void UCanvas::execStrLen( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execStrLen);
	P_GET_STR(InText);
	P_GET_FLOAT_REF(XL);
	P_GET_FLOAT_REF(YL);
	P_FINISH;
	// Approximate string length from character count if no font measurement available.
	if( Font )
	{
		*XL = (FLOAT)(InText.Len() * 8);
		*YL = 16.0f;
	}
	else
	{
		*XL = 0.0f;
		*YL = 0.0f;
	}
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execStrLen );

IMPL_INFERRED("approximates text size and returns text via Result")
void UCanvas::execTextSize( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execTextSize);
	P_GET_STR(InText);
	P_GET_FLOAT_REF(XL);
	P_GET_FLOAT_REF(YL);
	P_GET_INT_OPTX(TotalWidth, 0);
	P_GET_INT_OPTX(SpaceWidth, 0);
	P_FINISH;
	if( Font )
	{
		*XL = (FLOAT)(InText.Len() * 8);
		*YL = 16.0f;
	}
	else
	{
		*XL = 0.0f;
		*YL = 0.0f;
	}
	*(FString*)Result = InText;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execTextSize );

IMPL_INFERRED("projects to screen centre; full view-matrix projection diverged")
void UCanvas::execGetScreenCoordinate( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execGetScreenCoordinate);
	P_GET_VECTOR(WorldLoc);
	P_GET_VECTOR_REF(ScreenLoc);
	P_FINISH;
	// Project world location to screen coordinates.
	// Basic projection using viewport dimensions. Full implementation
	// requires the scene view matrix which lives in FSceneNode.
	*ScreenLoc = FVector(SizeX * 0.5f, SizeY * 0.5f, 0.0f);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execGetScreenCoordinate );

IMPL_INFERRED("calls SetVirtualSize with W/H")
void UCanvas::execSetVirtualSize( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetVirtualSize);
	P_GET_FLOAT(W);
	P_GET_FLOAT(H);
	P_FINISH;
	SetVirtualSize(W, H);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetVirtualSize );

IMPL_INFERRED("calls UseVirtualSize with stored virtual resolution")
void UCanvas::execUseVirtualSize( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execUseVirtualSize);
	P_GET_UBOOL(bUse);
	P_FINISH;
	UseVirtualSize(bUse, m_fVirtualResX, m_fVirtualResY);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execUseVirtualSize );

IMPL_APPROX("Needs Ghidra analysis")
void UCanvas::execSetMotionBlurIntensity( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetMotionBlurIntensity);
	P_GET_FLOAT(Intensity);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetMotionBlurIntensity );

IMPL_APPROX("Needs Ghidra analysis")
void UCanvas::execDrawWritableMap( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawWritableMap);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawWritableMap );

IMPL_APPROX("video subsystem API unimplemented; returns invalid handle 0")
void UCanvas::execVideoOpen( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoOpen);
	P_GET_STR(Filename);
	P_FINISH;
	// DIVERGENCE: Retail calls into the Bink or proprietary video subsystem via a
	// vtable-dispatched VideoOpen API (Ghidra signature differs from UC declaration).
	// Returning 0 (invalid handle) — video playback not implemented.
	*(INT*)Result = 0;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoOpen );

IMPL_APPROX("video subsystem API unimplemented")
void UCanvas::execVideoPlay( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoPlay);
	P_GET_INT(Handle);
	P_FINISH;
	// DIVERGENCE: video subsystem API call — see execVideoOpen. No-op.
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoPlay );

IMPL_APPROX("video subsystem API unimplemented")
void UCanvas::execVideoStop( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoStop);
	P_GET_INT(Handle);
	P_FINISH;
	// DIVERGENCE: video subsystem API call — see execVideoOpen. No-op.
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoStop );

IMPL_APPROX("video subsystem API unimplemented")
void UCanvas::execVideoClose( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoClose);
	P_GET_INT(Handle);
	P_FINISH;
	// DIVERGENCE: video subsystem API call — see execVideoOpen. No-op.
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoClose );

/*=============================================================================
	AHUD implementation.
=============================================================================*/

IMPL_GHIDRA_APPROX("Engine.dll", 0x12d710, "Player->Viewport accessed via raw offset 0x5B4 not in public headers")
void AHUD::execDraw3DLine( FFrame& Stack, RESULT_DECL )
{
	guard(AHUD::execDraw3DLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor, Color);
	P_FINISH;
	// Retail (0x12d710): gets viewport via Player+0x5B4, checks IsA(UViewport),
	// creates FLineBatcher with RI at Viewport+0x164, draws, destructs.
	// DIVERGENCE: Player->Viewport accessed via raw offset 0x5B4 (not in public headers).
	if( Player )
	{
		UViewport* VP = *(UViewport**)((BYTE*)Player + 0x5B4);
		if( VP && VP->IsA( UViewport::StaticClass() ) )
		{
			FRenderInterface* RI = *(FRenderInterface**)((BYTE*)VP + 0x164);
			if( RI )
			{
				FLineBatcher Batcher( RI, 1, 0 );
				Batcher.DrawLine( Start, End, Color );
			}
		}
	}
	unguardexec;
}
IMPLEMENT_FUNCTION( AHUD, INDEX_NONE, execDraw3DLine );

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

// ============================================================================
// FSceneNode / FLevelSceneNode / scene subclass implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0FSceneNode@@QAE@PAV0@@Z
IMPL_INFERRED("copies all fields except vtable via appMemcpy")
FSceneNode::FSceneNode(FSceneNode * p0)
{
	appMemcpy(((BYTE*)this) + 4, ((BYTE*)p0) + 4, 0x1B4);
}

// ??0FSceneNode@@QAE@ABV0@@Z
IMPL_INFERRED("copies all fields except vtable via appMemcpy")
FSceneNode::FSceneNode(FSceneNode const & p0)
{
	appMemcpy(((BYTE*)this) + 4, ((const BYTE*)&p0) + 4, 0x1B4);
}

// ??0FSceneNode@@QAE@PAVUViewport@@@Z
IMPL_INFERRED("zero-initializes fields then sets Viewport pointer")
FSceneNode::FSceneNode(UViewport * Viewport)
{
	appMemzero(((BYTE*)this) + 4, 0x1B4);
	*(UViewport**)(((BYTE*)this) + 0x04) = Viewport;
}

// ??1FSceneNode@@UAE@XZ
IMPL_APPROX("Needs Ghidra analysis")
FSceneNode::~FSceneNode() {}

// ?GetActorSceneNode@FSceneNode@@UAEPAVFActorSceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FActorSceneNode overrides")
FActorSceneNode * FSceneNode::GetActorSceneNode() { return NULL; }

// ?GetCameraSceneNode@FSceneNode@@UAEPAVFCameraSceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FCameraSceneNode overrides")
FCameraSceneNode * FSceneNode::GetCameraSceneNode() { return NULL; }

// ?GetLevelSceneNode@FSceneNode@@UAEPAVFLevelSceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FLevelSceneNode overrides")
FLevelSceneNode * FSceneNode::GetLevelSceneNode() { return NULL; }

// ?GetMirrorSceneNode@FSceneNode@@UAEPAVFMirrorSceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FMirrorSceneNode overrides")
FMirrorSceneNode * FSceneNode::GetMirrorSceneNode() { return NULL; }

// ?GetSkySceneNode@FSceneNode@@UAEPAVFSkySceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FSkySceneNode overrides")
FSkySceneNode * FSceneNode::GetSkySceneNode() { return NULL; }

// ?GetWarpZoneSceneNode@FSceneNode@@UAEPAVFWarpZoneSceneNode@@XZ
IMPL_INFERRED("base class returns NULL; subclass FWarpZoneSceneNode overrides")
FWarpZoneSceneNode * FSceneNode::GetWarpZoneSceneNode() { return NULL; }

// ?Project@FSceneNode@@QAE?AVFPlane@@VFVector@@@Z
IMPL_APPROX("Needs Ghidra analysis")
FPlane FSceneNode::Project(FVector p0) { return FPlane(); }

// ?Deproject@FSceneNode@@QAE?AVFVector@@VFPlane@@@Z
IMPL_APPROX("Needs Ghidra analysis")
FVector FSceneNode::Deproject(FPlane p0) { return FVector(); }

// ??4FSceneNode@@QAEAAV0@ABV0@@Z
IMPL_INFERRED("bitwise copy via appMemcpy")
FSceneNode& FSceneNode::operator=(const FSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ??1FLevelSceneNode@@UAE@XZ
IMPL_APPROX("Needs Ghidra analysis")
FLevelSceneNode::~FLevelSceneNode() {}

// ??4FLevelSceneNode@@QAEAAV0@ABV0@@Z
IMPL_INFERRED("bitwise copy via appMemcpy")
FLevelSceneNode& FLevelSceneNode::operator=(const FLevelSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// =============================================================================
// UVertexStream class implementations.
// =============================================================================
IMPL_INFERRED("initializes element size, flags, and stream type")
UVertexStreamBase::UVertexStreamBase(INT InElementSize, DWORD InFlags, DWORD InType)
: ElementSize(InElementSize), StreamFlags(InFlags), StreamType(InType) {}
IMPL_INFERRED("calls Super::Serialize; serializes element size, flags, type for Ver >= 75")
void UVertexStreamBase::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);
	if (Ar.Ver() >= 75)
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
}
IMPL_INFERRED("updates StreamFlags and bumps Revision if changed")
void UVertexStreamBase::SetPolyFlags(DWORD Flags) {
	DWORD OldFlags = StreamFlags;
	StreamFlags = Flags;
	if( OldFlags != Flags )
		Revision++;
}

IMPL_INFERRED("default ctor: element size 0x2C, flags 0, type 4")
UVertexBuffer::UVertexBuffer()
: UVertexStreamBase(0x2C, 0, 4) {}
IMPL_INFERRED("ctor with flags: element size 0x2C, type 0")
UVertexBuffer::UVertexBuffer(DWORD InFlags)
: UVertexStreamBase(0x2C, InFlags, 0) {}
IMPL_INFERRED("delegates to UVertexStreamBase::Serialize")
void UVertexBuffer::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
IMPL_INFERRED("returns raw Data array pointer")
void* UVertexBuffer::GetData() { return Data.GetData(); }
IMPL_INFERRED("returns Data.Num() times 0x2C bytes")
INT UVertexBuffer::GetDataSize() { return Data.Num() * 0x2C; }

IMPL_INFERRED("default ctor: element size 4, flags 0, type 2")
UVertexStreamCOLOR::UVertexStreamCOLOR()
: UVertexStreamBase(4, 0, 2) {}
IMPL_INFERRED("ctor with flags: element size 4, type 2")
UVertexStreamCOLOR::UVertexStreamCOLOR(DWORD InFlags)
: UVertexStreamBase(4, InFlags, 2) {}
IMPL_INFERRED("delegates to UVertexStreamBase::Serialize")
void UVertexStreamCOLOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
IMPL_INFERRED("returns raw Data array pointer")
void* UVertexStreamCOLOR::GetData() { return Data.GetData(); }
IMPL_INFERRED("returns Data.Num() times 4 bytes")
INT UVertexStreamCOLOR::GetDataSize() { return Data.Num() * 4; }

IMPL_INFERRED("default ctor: element size 0x28, flags 0, type 5")
UVertexStreamPosNormTex::UVertexStreamPosNormTex()
: UVertexStreamBase(0x28, 0, 5) {}
IMPL_INFERRED("ctor with flags: element size 0x28, type 5")
UVertexStreamPosNormTex::UVertexStreamPosNormTex(DWORD InFlags)
: UVertexStreamBase(0x28, InFlags, 5) {}
IMPL_INFERRED("delegates to UVertexStreamBase::Serialize")
void UVertexStreamPosNormTex::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
IMPL_INFERRED("returns raw Data array pointer")
void* UVertexStreamPosNormTex::GetData() { return Data.GetData(); }
IMPL_INFERRED("returns Data.Num() times 0x28 bytes")
INT UVertexStreamPosNormTex::GetDataSize() { return Data.Num() * 0x28; }

IMPL_INFERRED("default ctor: element size 8, flags 0, type 3")
UVertexStreamUV::UVertexStreamUV()
: UVertexStreamBase(8, 0, 3) {}
IMPL_INFERRED("ctor with flags: element size 8, type 3")
UVertexStreamUV::UVertexStreamUV(DWORD InFlags)
: UVertexStreamBase(8, InFlags, 3) {}
IMPL_INFERRED("delegates to UVertexStreamBase::Serialize")
void UVertexStreamUV::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
IMPL_INFERRED("returns raw Data array pointer")
void* UVertexStreamUV::GetData() { return Data.GetData(); }
IMPL_INFERRED("returns Data.Num() times 8 bytes")
INT UVertexStreamUV::GetDataSize() { return Data.Num() * 8; }

IMPL_INFERRED("default ctor: element size 0xC, flags 0, type 1")
UVertexStreamVECTOR::UVertexStreamVECTOR()
: UVertexStreamBase(0xC, 0, 1) {}
IMPL_INFERRED("ctor with flags: element size 0xC, type 1")
UVertexStreamVECTOR::UVertexStreamVECTOR(DWORD InFlags)
: UVertexStreamBase(0xC, InFlags, 1) {}
IMPL_INFERRED("delegates to UVertexStreamBase::Serialize")
void UVertexStreamVECTOR::Serialize(FArchive& Ar) { UVertexStreamBase::Serialize(Ar); }
IMPL_INFERRED("returns raw Data array pointer")
void* UVertexStreamVECTOR::GetData() { return Data.GetData(); }
IMPL_INFERRED("returns Data.Num() times 0xC bytes")
INT UVertexStreamVECTOR::GetDataSize() { return Data.Num() * 0xC; }

// =============================================================================
// FColor constructor from FPlane
// =============================================================================
IMPL_INFERRED("converts normalized FPlane XYZW to RGBA bytes via Clamp+appFloor")
FColor::FColor(const FPlane& P)
:	R((BYTE)Clamp(appFloor(P.X*255.f),0,255))
,	G((BYTE)Clamp(appFloor(P.Y*255.f),0,255))
,	B((BYTE)Clamp(appFloor(P.Z*255.f),0,255))
,	A((BYTE)Clamp(appFloor(P.W*255.f),0,255))
{}

// ============================================================================
// FDbgVectorInfo
// ============================================================================
IMPL_INFERRED("zero-initializes all fields via appMemzero")
FDbgVectorInfo::FDbgVectorInfo() { appMemzero(this, sizeof(*this)); }
IMPL_INFERRED("bitwise copy via appMemcpy")
FDbgVectorInfo::FDbgVectorInfo(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_APPROX("Needs Ghidra analysis")
FDbgVectorInfo::~FDbgVectorInfo() {}
IMPL_INFERRED("bitwise copy via appMemcpy")
FDbgVectorInfo& FDbgVectorInfo::operator=(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FRenderInterface
// ============================================================================
IMPL_INFERRED("zero-initializes RIPad array")
FRenderInterface::FRenderInterface() { appMemzero(RIPad, sizeof(RIPad)); }
IMPL_INFERRED("bitwise copy via appMemcpy")
FRenderInterface::FRenderInterface(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_INFERRED("bitwise copy via appMemcpy")
FRenderInterface& FRenderInterface::operator=(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ============================================================================
// FSceneNode subclasses
// ============================================================================

// FActorSceneNode
IMPL_APPROX("Needs Ghidra analysis")
void FActorSceneNode::Render(FRenderInterface*) {}
IMPL_INFERRED("returns this as FActorSceneNode")
FActorSceneNode* FActorSceneNode::GetActorSceneNode() { return this; }

// FCameraSceneNode
IMPL_APPROX("Needs Ghidra analysis")
void FCameraSceneNode::Render(FRenderInterface*) {}
IMPL_INFERRED("returns this as FCameraSceneNode")
FCameraSceneNode* FCameraSceneNode::GetCameraSceneNode() { return this; }
IMPL_APPROX("Needs Ghidra analysis")
void FCameraSceneNode::UpdateMatrices() {}

// FMirrorSceneNode
IMPL_INFERRED("delegates to FSceneNode(FSceneNode*) base ctor; zero-initializes Pad2")
FMirrorSceneNode::FMirrorSceneNode(FLevelSceneNode* Parent, FPlane Mirror, INT a, INT b)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_INFERRED("returns this as FMirrorSceneNode")
FMirrorSceneNode* FMirrorSceneNode::GetMirrorSceneNode() { return this; }

// FSkySceneNode
IMPL_INFERRED("delegates to FSceneNode(FSceneNode*) base ctor; zero-initializes Pad2")
FSkySceneNode::FSkySceneNode(FLevelSceneNode* Parent, INT Zone)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_INFERRED("returns this as FSkySceneNode")
FSkySceneNode* FSkySceneNode::GetSkySceneNode() { return this; }

// FWarpZoneSceneNode
IMPL_INFERRED("delegates to FSceneNode(FSceneNode*) base ctor; zero-initializes Pad2")
FWarpZoneSceneNode::FWarpZoneSceneNode(FLevelSceneNode* Parent, AWarpZoneInfo*)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_INFERRED("returns this as FWarpZoneSceneNode")
FWarpZoneSceneNode* FWarpZoneSceneNode::GetWarpZoneSceneNode() { return this; }

// FLevelSceneNode
IMPL_APPROX("Needs Ghidra analysis")
FConvexVolume FLevelSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FLightMapSceneNode
extern ENGINE_API FRebuildTools GRebuildTools;
IMPL_APPROX("Needs Ghidra analysis")
void FLightMapSceneNode::Render(FRenderInterface*) {}
IMPL_INFERRED("filters actors by rebuild tool flags and actor bits")
INT FLightMapSceneNode::FilterActor(AActor* Actor)
{
	if ((GRebuildTools.Pad[0x10] & 0x10) && (*(DWORD*)((BYTE*)Actor + 0xAC) & 0x1800))
		return 0;
	return (*(DWORD*)((BYTE*)Actor + 0xA4) >> 30) & 1;
}

// FDirectionalLightMapSceneNode
IMPL_APPROX("Needs Ghidra analysis")
FConvexVolume FDirectionalLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FPointLightMapSceneNode
IMPL_APPROX("Needs Ghidra analysis")
FConvexVolume FPointLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// ============================================================================
// HCoords
// ============================================================================
IMPL_APPROX("Needs Ghidra analysis")
HCoords::HCoords(FCameraSceneNode*) {}

// --- Moved from EngineStubs.cpp ---
IMPL_INFERRED("calls UObject::Serialize then serializes Revision")
void URenderResource::Serialize(FArchive& Ar)
{
	UObject::Serialize(Ar);
	Ar << Revision;
}
IMPL_APPROX("Needs Ghidra analysis")
void FHitObserver::Click(const FHitCause& Cause, const HHitProxy& Hit) {}

// ?AVIStart@@YAXPBGPAVUEngine@@H@Z
IMPL_APPROX("Needs Ghidra analysis")
void AVIStart(const TCHAR* p0, UEngine * p1, int p2) {}

// ?AVIStop@@YAXXZ
IMPL_APPROX("Needs Ghidra analysis")
void AVIStop() {}

// ?AVITakeShot@@YAXPAVUEngine@@@Z
IMPL_APPROX("Needs Ghidra analysis")
void AVITakeShot(UEngine * p0) {}

// ?DrawSprite@@YAXPAVAActor@@VFVector@@PAVUMaterial@@PAVFLevelSceneNode@@PAVFRenderInterface@@@Z
IMPL_APPROX("Needs Ghidra analysis")
void DrawSprite(AActor * p0, FVector p1, UMaterial * p2, FLevelSceneNode * p3, FRenderInterface * p4) {}

// ?DrawSprite@@YAXMVFVector@@0PAVUMaterial@@VFPlane@@EPAVFCameraSceneNode@@PAVFRenderInterface@@MHH@Z
IMPL_APPROX("Needs Ghidra analysis")
void DrawSprite(float p0, FVector p1, FVector p2, UMaterial * p3, FPlane p4, BYTE p5, FCameraSceneNode * p6, FRenderInterface * p7, float p8, int p9, int p10) {}
