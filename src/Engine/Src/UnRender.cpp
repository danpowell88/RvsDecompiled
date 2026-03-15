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

IMPL_MATCH("Engine.dll", 0x10388830)
void UCanvas::Init( UViewport* InViewport )
{
	guard(UCanvas::Init);
	Viewport = InViewport;
	UBOOL bSaved = GIsScriptable;
	GIsScriptable = 1;
	UFunction* Func = FindFunctionChecked(FName(TEXT("Reset"), FNAME_Add));
	ProcessEvent(Func, NULL);
	GIsScriptable = bSaved;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103888e0)
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

IMPL_MATCH("Engine.dll", 0x10388410)
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

IMPL_MATCH("Engine.dll", 0x10388500)
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

IMPL_MATCH("Engine.dll", 0x103885f0)
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

IMPL_MATCH("Engine.dll", 0x103886f0)
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

IMPL_MATCH("Engine.dll", 0x1038b5c0)
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

IMPL_MATCH("Engine.dll", 0x1038b7b0)
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

IMPL_TODO("stub body (2 line(s)) — Ghidra 0x1038c810 is 630 bytes, not fully reconstructed")
void UCanvas::execClipTextNative( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execClipTextNative);
	P_GET_STR(Text);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execClipTextNative );

IMPL_TODO("VA confirmed 0x103889b0; Ghidra reports unreachable blocks in function body — main draw logic not fully reconstructed")
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

IMPL_MATCH("Engine.dll", 0x10389140)
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

IMPL_MATCH("Engine.dll", 0x1038a180)
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

IMPL_MATCH("Engine.dll", 0x10388c50)
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

IMPL_MATCH("Engine.dll", 0x10389320)
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

IMPL_MATCH("Engine.dll", 0x10389b10)
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

IMPL_MATCH("Engine.dll", 0x10388210)
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

IMPL_MATCH("Engine.dll", 0x1038b970)
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

IMPL_TODO("stub body (3 line(s)) — Ghidra 0x103897b0 is 760 bytes, not fully reconstructed")
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

IMPL_MATCH("Engine.dll", 0x1038a810)
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

IMPL_MATCH("Engine.dll", 0x1038a700)
void UCanvas::execUseVirtualSize( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execUseVirtualSize);
	P_GET_UBOOL(bUse);
	P_GET_FLOAT(fX);
	P_GET_FLOAT(fY);
	P_FINISH;
	UseVirtualSize(bUse, fX, fY);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execUseVirtualSize );

IMPL_MATCH("Engine.dll", 0x10389690)
void UCanvas::execSetMotionBlurIntensity( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetMotionBlurIntensity);
	P_GET_INT(Intensity);
	P_FINISH;
	if( Intensity >= 256 ) Intensity = 255;
	else if( Intensity < 0 ) Intensity = 0;
	if( Viewport )
	{
		INT* v = *(INT**)((BYTE*)Viewport + 0x34);
		if( v )
		{
			INT* target = *(INT**)((BYTE*)v + 0x144);
			if( target )
				*(INT*)((BYTE*)target + 0x444) = Intensity;
		}
	}
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetMotionBlurIntensity );

IMPL_TODO("stub body (1 line(s)) — Ghidra 0x1038bc40 is 2918 bytes, not fully reconstructed")
void UCanvas::execDrawWritableMap( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawWritableMap);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawWritableMap );

IMPL_TODO("Ghidra 0x1038a520: calls UR6ModMgr::eventGetVideosRoot(GModMgr) and writes to DAT_1066a428/1066a328 static ANSI buffers before dispatching through RenDev vtable[0x9c/4]; GModMgr and static buffers not yet declared")
void UCanvas::execVideoOpen( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoOpen);
	P_GET_STR(Filename);
	P_GET_INT(Flags);
	P_FINISH;
	*(INT*)Result = 0;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoOpen );

IMPL_MATCH("Engine.dll", 0x10389da0)
void UCanvas::execVideoPlay( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoPlay);
	P_GET_INT(Handle);
	P_GET_INT(p2);
	P_GET_INT(p3);
	P_FINISH;
	BYTE* rd = *(BYTE**)((BYTE*)Viewport + 0x8c);
	typedef void (__thiscall *tVP)(BYTE*, BYTE*, INT, INT, INT);
	((tVP)((*(INT**)rd)[0xa8/4]))(rd, (BYTE*)this, Handle, p2, p3);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoPlay );

IMPL_DIVERGE("Ghidra 0x10389ee0: calls _BinkSetVolume_12(Canvas+0x80, 0, 0) then RenDev vtable[0xac/4]; Bink SDK not available so volume mute is skipped")
void UCanvas::execVideoStop( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoStop);
	P_FINISH;
	// _BinkSetVolume_12(*(INT*)((BYTE*)this + 0x80), 0, 0) -- Bink SDK unavailable.
	BYTE* rd = *(BYTE**)((BYTE*)Viewport + 0x8c);
	typedef void (__thiscall *tVS)(BYTE*, BYTE*);
	((tVS)((*(INT**)rd)[0xac/4]))(rd, (BYTE*)this);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoStop );

IMPL_MATCH("Engine.dll", 0x10389cc0)
void UCanvas::execVideoClose( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoClose);
	P_FINISH;
	BYTE* rd = *(BYTE**)((BYTE*)Viewport + 0x8c);
	typedef void (__thiscall *tVC)(BYTE*, BYTE*);
	((tVC)((*(INT**)rd)[0xa0/4]))(rd, (BYTE*)this);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoClose );

/*=============================================================================
	AHUD implementation.
=============================================================================*/

IMPL_TODO("Ghidra 0x1042d710: FLineBatcher::DrawLine receives garbled GNatives-tracked registers for FVector/FColor args; retail IsA check does not have an additional RI null check")
void AHUD::execDraw3DLine( FFrame& Stack, RESULT_DECL )
{
	guard(AHUD::execDraw3DLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor, Color);
	P_FINISH;
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
// Ghidra 0x103fdd40: constructs 6 FMatrix + 3 FVector (trivial ctors), copies them
// from parent, then sets +8 = parent ptr, +4 = parent's viewport, +0xc = parent depth+1,
// and stores FMatrix::Determinant(+0x110) into +0x1b4. Bulk memcpy covers matrix/vector
// data; we then fix the three overridden fields (+8, +0xc) that differ from a plain copy.
IMPL_TODO("Ghidra 0x103fdd40: uses per-field loop copies + FMatrix default ctors instead of appMemcpy; +8 parent ptr and +0xc depth-increment are applied after the bulk copy to match retail semantics")
FSceneNode::FSceneNode(FSceneNode * p0)
{
	appMemcpy(((BYTE*)this) + 4, ((BYTE*)p0) + 4, 0x1B4);
	// Retail stores p0 itself at +8 (parent node pointer), not p0's parent.
	*(FSceneNode**)(((BYTE*)this) + 8) = p0;
	// Retail increments the scene depth counter stored at +0xc.
	*(INT*)(((BYTE*)this) + 0xc) = *(const INT*)(((const BYTE*)p0) + 0xc) + 1;
}

// ??0FSceneNode@@QAE@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x10313300)
FSceneNode::FSceneNode(FSceneNode const & p0)
{
	appMemcpy(((BYTE*)this) + 4, ((const BYTE*)&p0) + 4, 0x1B4);
}

// ??0FSceneNode@@QAE@PAVUViewport@@@Z
// Ghidra 0x103fdc60: FMatrix/FVector default ctors are trivially no-ops; retail only
// stores Viewport at +4 and zeroes +8 and +0xc.  Matrices at +0x10..+0x1b0 are left
// uninitialised (callers always write before read).
IMPL_MATCH("Engine.dll", 0x103fdc60)
FSceneNode::FSceneNode(UViewport * Viewport)
{
	*(UViewport**)(((BYTE*)this) + 0x04) = Viewport;
	*(DWORD*)(((BYTE*)this) + 0x08) = 0;
	*(INT*)(((BYTE*)this) + 0x0c) = 0;
}

// ??1FSceneNode@@UAE@XZ
IMPL_EMPTY("body unanalyzed; no cleanup needed for stack-allocated scene node")
FSceneNode::~FSceneNode() {}

// ?GetActorSceneNode@FSceneNode@@UAEPAVFActorSceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FActorSceneNode * FSceneNode::GetActorSceneNode() { return NULL; }

// ?GetCameraSceneNode@FSceneNode@@UAEPAVFCameraSceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FCameraSceneNode * FSceneNode::GetCameraSceneNode() { return NULL; }

// ?GetLevelSceneNode@FSceneNode@@UAEPAVFLevelSceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FLevelSceneNode * FSceneNode::GetLevelSceneNode() { return NULL; }

// ?GetMirrorSceneNode@FSceneNode@@UAEPAVFMirrorSceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FMirrorSceneNode * FSceneNode::GetMirrorSceneNode() { return NULL; }

// ?GetSkySceneNode@FSceneNode@@UAEPAVFSkySceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FSkySceneNode * FSceneNode::GetSkySceneNode() { return NULL; }

// ?GetWarpZoneSceneNode@FSceneNode@@UAEPAVFWarpZoneSceneNode@@XZ
IMPL_MATCH("Engine.dll", 0x10414310)
FWarpZoneSceneNode * FSceneNode::GetWarpZoneSceneNode() { return NULL; }

// ?Project@FSceneNode@@QAE?AVFPlane@@VFVector@@@Z
IMPL_MATCH("Engine.dll", 0x103fdf90)
FPlane FSceneNode::Project(FVector V)
{
	// Ghidra 0x103fdf90: transform (V.X, V.Y, V.Z, 1.0) by view-proj matrix at +0x110,
	// then divide XYZ by W and return as FPlane.
	FMatrix& ViewProj = *(FMatrix*)(((BYTE*)this) + 0x110);
	FPlane P = ViewProj.TransformFPlane(FPlane(V.X, V.Y, V.Z, 1.0f));
	float InvW = 1.0f / P.W;
	return FPlane(P.X * InvW, P.Y * InvW, P.Z * InvW, P.W);
}

// ?Deproject@FSceneNode@@QAE?AVFVector@@VFPlane@@@Z
IMPL_MATCH("Engine.dll", 0x103fe020)
FVector FSceneNode::Deproject(FPlane P)
{
	// Ghidra 0x103fe020: scale XYZ by W (undo Project's divide), transform by
	// inv-view-proj matrix at +0x150, return XYZ.
	FMatrix& InvViewProj = *(FMatrix*)(((BYTE*)this) + 0x150);
	FPlane Scaled(P.X * P.W, P.Y * P.W, P.Z * P.W, P.W);
	FPlane R = InvViewProj.TransformFPlane(Scaled);
	return FVector(R.X, R.Y, R.Z);
}

// ??4FSceneNode@@QAEAAV0@ABV0@@Z
IMPL_MATCH("Engine.dll", 0x103133f0)
FSceneNode& FSceneNode::operator=(const FSceneNode& Other) { appMemcpy(this, &Other, sizeof(*this)); return *this; }

// ??1FLevelSceneNode@@UAE@XZ
IMPL_EMPTY("body unanalyzed; no cleanup needed for stack-allocated level scene node")
FLevelSceneNode::~FLevelSceneNode() {}

// ??4FLevelSceneNode@@QAEAAV0@ABV0@@Z
// Ghidra 0x103136F0: calls FSceneNode::operator= then copies 6 DWORDs at +0x1b8..+0x1cc.
IMPL_MATCH("Engine.dll", 0x103136F0)
FLevelSceneNode& FLevelSceneNode::operator=(const FLevelSceneNode& Other)
{
	FSceneNode::operator=(*(const FSceneNode*)&Other);
	appMemcpy(((BYTE*)this) + 0x1b8, ((const BYTE*)&Other) + 0x1b8, 0x18);
	return *this;
}

// =============================================================================
// UVertexStream class implementations.
// =============================================================================
IMPL_MATCH("Engine.dll", 0x10302210)
UVertexStreamBase::UVertexStreamBase(INT InElementSize, DWORD InFlags, DWORD InType)
: ElementSize(InElementSize), StreamFlags(InFlags), StreamType(InType) {}
IMPL_MATCH("Engine.dll", 0x10302260)
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
IMPL_MATCH("Engine.dll", 0x10302240)
void UVertexStreamBase::SetPolyFlags(DWORD Flags) {
	DWORD OldFlags = StreamFlags;
	StreamFlags = Flags;
	if( OldFlags != Flags )
		Revision++;
}

// Ghidra 0x10326280: calls UObject::UObject (via trivial base chain), sets the
// three stream fields, then FArray::FArray for Data.  Body-based init matches
// that sequence; the only ordering difference (Data init is a member-init, so
// it happens before the body per the C++ standard) has no observable effect.
IMPL_MATCH("Engine.dll", 0x10326280)
UVertexBuffer::UVertexBuffer()
{
	ElementSize = 0x2C;
	StreamFlags = 0;
	StreamType  = 4;
}
IMPL_TODO("No confirmed Ghidra binary address for UVertexBuffer(DWORD InFlags); StreamType=0 is an inference from class usage patterns")
UVertexBuffer::UVertexBuffer(DWORD InFlags)
: UVertexStreamBase(0x2C, InFlags, 0) {}
// Ghidra 0x10326340: URenderResource::Serialize, stream-header fields (Ver>=75),
// FUN_10321c80 (TArray<FUntransformedVertex> serializer), extra StreamFlags for
// Ver 73-74.  Data loop inlined here; FUN_10321c80 not called as separate function.
IMPL_TODO("Ghidra 0x10326340: data loop inlined via ByteOrderSerialize; FUN_10321c80 not called separately; extra StreamFlags for Ver 73-74 present")
void UVertexBuffer::Serialize(FArchive& Ar)
{
	URenderResource::Serialize(Ar);
	if( Ar.Ver() > 0x4a )
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
	if( Ar.IsLoading() )
	{
		INT Count = 0;
		Ar << AR_INDEX(Count);
		Data.Empty();
		if( Count > 0 )
			Data.Add(Count * 0x2C);
		for( INT i = 0; i < Count; i++ )
		{
			DWORD* P = (DWORD*)&Data(i * 0x2C);
			for( INT f = 0; f < 11; f++ )
				Ar.ByteOrderSerialize(P + f, 4);
		}
	}
	else
	{
		INT Count = Data.Num() / 0x2C;
		Ar << AR_INDEX(Count);
		for( INT i = 0; i < Count; i++ )
		{
			DWORD* P = (DWORD*)&Data(i * 0x2C);
			for( INT f = 0; f < 11; f++ )
				Ar.ByteOrderSerialize(P + f, 4);
		}
	}
	if( Ar.Ver() > 0x48 && Ar.Ver() < 0x4b )
		Ar << StreamFlags;
}
IMPL_MATCH("Engine.dll", 0x10318b20)
void* UVertexBuffer::GetData() { return Data.GetData(); }
IMPL_MATCH("Engine.dll", 0x10302470)
INT UVertexBuffer::GetDataSize() { return Data.Num() * 0x2C; }

IMPL_MATCH("Engine.dll", 0x10326880)
UVertexStreamCOLOR::UVertexStreamCOLOR()
{
	ElementSize = 4;
	StreamFlags = 0;
	StreamType  = 2;
}
IMPL_TODO("No confirmed Ghidra binary address for UVertexStreamCOLOR(DWORD InFlags)")
UVertexStreamCOLOR::UVertexStreamCOLOR(DWORD InFlags)
: UVertexStreamBase(4, InFlags, 2) {}
// Ghidra 0x10326950: URenderResource::Serialize, stream-header fields (Ver>=75),
// FUN_10321e30 (BGRA byte-swap TArray serializer).  Loop inlined here.
IMPL_TODO("Ghidra 0x10326950: data loop inlined with BGRA byte-swap; FUN_10321e30 not called separately")
void UVertexStreamCOLOR::Serialize(FArchive& Ar)
{
	URenderResource::Serialize(Ar);
	if( Ar.Ver() > 0x4a )
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
	if( Ar.IsLoading() )
	{
		INT Count = 0;
		Ar << AR_INDEX(Count);
		Data.Empty();
		if( Count > 0 )
			Data.Add(Count * 4);
		for( INT i = 0; i < Count; i++ )
		{
			BYTE* P = &Data(i * 4);
			Ar.Serialize(P + 2, 1);
			Ar.Serialize(P + 1, 1);
			Ar.Serialize(P + 0, 1);
			Ar.Serialize(P + 3, 1);
		}
	}
	else
	{
		INT Count = Data.Num() / 4;
		Ar << AR_INDEX(Count);
		for( INT i = 0; i < Count; i++ )
		{
			BYTE* P = &Data(i * 4);
			Ar.Serialize(P + 2, 1);
			Ar.Serialize(P + 1, 1);
			Ar.Serialize(P + 0, 1);
			Ar.Serialize(P + 3, 1);
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10318b20)
void* UVertexStreamCOLOR::GetData() { return Data.GetData(); }
IMPL_MATCH("Engine.dll", 0x10302510)
INT UVertexStreamCOLOR::GetDataSize() { return Data.Num() * 4; }

IMPL_MATCH("Engine.dll", 0x10326ea0)
UVertexStreamPosNormTex::UVertexStreamPosNormTex()
{
	ElementSize = 0x28;
	StreamFlags = 0;
	StreamType  = 5;
}
IMPL_TODO("No confirmed Ghidra binary address for UVertexStreamPosNormTex(DWORD InFlags)")
UVertexStreamPosNormTex::UVertexStreamPosNormTex(DWORD InFlags)
: UVertexStreamBase(0x28, InFlags, 5) {}
// Ghidra 0x10326f70: URenderResource::Serialize, stream-header fields (Ver>=75),
// FUN_10322130 (TArray<FPosNormTexData> serializer, 10 DWORDs each).  Loop inlined.
IMPL_TODO("Ghidra 0x10326f70: data loop inlined via ByteOrderSerialize; FUN_10322130 not called separately")
void UVertexStreamPosNormTex::Serialize(FArchive& Ar)
{
	URenderResource::Serialize(Ar);
	if( Ar.Ver() > 0x4a )
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
	if( Ar.IsLoading() )
	{
		INT Count = 0;
		Ar << AR_INDEX(Count);
		Data.Empty();
		if( Count > 0 )
			Data.Add(Count * 0x28);
		for( INT i = 0; i < Count; i++ )
		{
			DWORD* P = (DWORD*)&Data(i * 0x28);
			for( INT f = 0; f < 10; f++ )
				Ar.ByteOrderSerialize(P + f, 4);
		}
	}
	else
	{
		INT Count = Data.Num() / 0x28;
		Ar << AR_INDEX(Count);
		for( INT i = 0; i < Count; i++ )
		{
			DWORD* P = (DWORD*)&Data(i * 0x28);
			for( INT f = 0; f < 10; f++ )
				Ar.ByteOrderSerialize(P + f, 4);
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10318b20)
void* UVertexStreamPosNormTex::GetData() { return Data.GetData(); }
IMPL_MATCH("Engine.dll", 0x10302650)
INT UVertexStreamPosNormTex::GetDataSize() { return Data.Num() * 0x28; }

IMPL_MATCH("Engine.dll", 0x10326b90)
UVertexStreamUV::UVertexStreamUV()
{
	ElementSize = 8;
	StreamFlags = 0;
	StreamType  = 3;
}
IMPL_TODO("No confirmed Ghidra binary address for UVertexStreamUV(DWORD InFlags)")
UVertexStreamUV::UVertexStreamUV(DWORD InFlags)
: UVertexStreamBase(8, InFlags, 3) {}
// Ghidra 0x10326c60: URenderResource::Serialize, stream-header fields (Ver>=75),
// FUN_10321fa0 (TArray<float[2]> serializer, 2 ByteOrderSerialize each).  Loop inlined.
IMPL_TODO("Ghidra 0x10326c60: data loop inlined via ByteOrderSerialize; FUN_10321fa0 not called separately")
void UVertexStreamUV::Serialize(FArchive& Ar)
{
	URenderResource::Serialize(Ar);
	if( Ar.Ver() > 0x4a )
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
	if( Ar.IsLoading() )
	{
		INT Count = 0;
		Ar << AR_INDEX(Count);
		Data.Empty();
		if( Count > 0 )
			Data.Add(Count * 8);
		for( INT i = 0; i < Count; i++ )
		{
			FLOAT* P = (FLOAT*)&Data(i * 8);
			Ar.ByteOrderSerialize(P,     4);
			Ar.ByteOrderSerialize(P + 1, 4);
		}
	}
	else
	{
		INT Count = Data.Num() / 8;
		Ar << AR_INDEX(Count);
		for( INT i = 0; i < Count; i++ )
		{
			FLOAT* P = (FLOAT*)&Data(i * 8);
			Ar.ByteOrderSerialize(P,     4);
			Ar.ByteOrderSerialize(P + 1, 4);
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10318b20)
void* UVertexStreamUV::GetData() { return Data.GetData(); }
IMPL_MATCH("Engine.dll", 0x10302560)
INT UVertexStreamUV::GetDataSize() { return Data.Num() * 8; }

IMPL_MATCH("Engine.dll", 0x103265b0)
UVertexStreamVECTOR::UVertexStreamVECTOR()
{
	ElementSize = 0xC;
	StreamFlags = 0;
	StreamType  = 1;
}
IMPL_TODO("No confirmed Ghidra binary address for UVertexStreamVECTOR(DWORD InFlags)")
UVertexStreamVECTOR::UVertexStreamVECTOR(DWORD InFlags)
: UVertexStreamBase(0xC, InFlags, 1) {}
// Ghidra 0x10326680: URenderResource::Serialize, stream-header fields (Ver>=75),
// FUN_10321a80 (TArray<FVector> serializer, 3 ByteOrderSerialize each).  Loop inlined.
IMPL_DIVERGE("Ghidra 0x10326680: data loop inlined via ByteOrderSerialize; FUN_10321a80 not called separately")
void UVertexStreamVECTOR::Serialize(FArchive& Ar)
{
	URenderResource::Serialize(Ar);
	if( Ar.Ver() > 0x4a )
	{
		Ar << ElementSize;
		Ar << StreamFlags;
		Ar << StreamType;
	}
	if( Ar.IsLoading() )
	{
		INT Count = 0;
		Ar << AR_INDEX(Count);
		Data.Empty();
		if( Count > 0 )
			Data.Add(Count * 0xC);
		for( INT i = 0; i < Count; i++ )
		{
			FLOAT* P = (FLOAT*)&Data(i * 0xC);
			Ar.ByteOrderSerialize(P,     4);
			Ar.ByteOrderSerialize(P + 1, 4);
			Ar.ByteOrderSerialize(P + 2, 4);
		}
	}
	else
	{
		INT Count = Data.Num() / 0xC;
		Ar << AR_INDEX(Count);
		for( INT i = 0; i < Count; i++ )
		{
			FLOAT* P = (FLOAT*)&Data(i * 0xC);
			Ar.ByteOrderSerialize(P,     4);
			Ar.ByteOrderSerialize(P + 1, 4);
			Ar.ByteOrderSerialize(P + 2, 4);
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10318b20)
void* UVertexStreamVECTOR::GetData() { return Data.GetData(); }
IMPL_MATCH("Engine.dll", 0x103024c0)
INT UVertexStreamVECTOR::GetDataSize() { return Data.Num() * 0xC; }

// =============================================================================
// FColor constructor from FPlane
// =============================================================================
IMPL_MATCH("Engine.dll", 0x10318a00)
FColor::FColor(const FPlane& P)
:	R((BYTE)Clamp(appFloor(P.X*255.f),0,255))
,	G((BYTE)Clamp(appFloor(P.Y*255.f),0,255))
,	B((BYTE)Clamp(appFloor(P.Z*255.f),0,255))
,	A((BYTE)Clamp(appFloor(P.W*255.f),0,255))
{}

// ============================================================================
// FDbgVectorInfo
// ============================================================================
IMPL_MATCH("Engine.dll", 0x103029c0)
FDbgVectorInfo::FDbgVectorInfo() { appMemzero(this, sizeof(*this)); }
IMPL_MATCH("Engine.dll", 0x103029c0)
FDbgVectorInfo::FDbgVectorInfo(const FDbgVectorInfo& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_EMPTY("trivial destructor; no heap resources to free")
FDbgVectorInfo::~FDbgVectorInfo() {}
// Ghidra 0x10302a60: copies 8 DWORDs (0x0–0x1c) then calls FString::operator= for m_szDef at +0x20.
IMPL_MATCH("Engine.dll", 0x10302a60)
FDbgVectorInfo& FDbgVectorInfo::operator=(const FDbgVectorInfo& Other)
{
	appMemcpy(this, &Other, 0x20);
	*(FString*)((BYTE*)this + 0x20) = *(const FString*)((const BYTE*)&Other + 0x20);
	return *this;
}

// ============================================================================
// FRenderInterface
// ============================================================================
IMPL_MATCH("Engine.dll", 0x10303240)
FRenderInterface::FRenderInterface() { appMemzero(RIPad, sizeof(RIPad)); }
IMPL_MATCH("Engine.dll", 0x10303240)
FRenderInterface::FRenderInterface(const FRenderInterface& Other) { appMemcpy(this, &Other, sizeof(*this)); }
// Ghidra 0x103032b0: copies 9 DWORDs from +4 to +0x24 (skips vtable at +0).
IMPL_MATCH("Engine.dll", 0x103032b0)
FRenderInterface& FRenderInterface::operator=(const FRenderInterface& Other)
{
	appMemcpy(((BYTE*)this) + 4, ((const BYTE*)&Other) + 4, 0x24);
	return *this;
}

// ============================================================================
// FSceneNode subclasses
// ============================================================================

// FActorSceneNode
IMPL_EMPTY("virtual base no-op — rendering subclass overrides")
void FActorSceneNode::Render(FRenderInterface*) {}
IMPL_MATCH("Engine.dll", 0x10301a90)
FActorSceneNode* FActorSceneNode::GetActorSceneNode() { return this; }

// FCameraSceneNode
IMPL_EMPTY("virtual base no-op — rendering subclass overrides")
void FCameraSceneNode::Render(FRenderInterface*) {}
IMPL_MATCH("Engine.dll", 0x10301a90)
FCameraSceneNode* FCameraSceneNode::GetCameraSceneNode() { return this; }
IMPL_EMPTY("body unanalyzed; view/projection matrices not updated")
void FCameraSceneNode::UpdateMatrices() {}

// FMirrorSceneNode
IMPL_MATCH("Engine.dll", 0x103139c0)
FMirrorSceneNode::FMirrorSceneNode(FLevelSceneNode* Parent, FPlane Mirror, INT a, INT b)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_MATCH("Engine.dll", 0x10301a90)
FMirrorSceneNode* FMirrorSceneNode::GetMirrorSceneNode() { return this; }

// FSkySceneNode
IMPL_MATCH("Engine.dll", 0x10313980)
FSkySceneNode::FSkySceneNode(FLevelSceneNode* Parent, INT Zone)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_MATCH("Engine.dll", 0x10301a90)
FSkySceneNode* FSkySceneNode::GetSkySceneNode() { return this; }

// FWarpZoneSceneNode
IMPL_MATCH("Engine.dll", 0x10313a60)
FWarpZoneSceneNode::FWarpZoneSceneNode(FLevelSceneNode* Parent, AWarpZoneInfo*)
	: FSceneNode((FSceneNode*)Parent) { appMemzero(Pad2, sizeof(Pad2)); }
IMPL_MATCH("Engine.dll", 0x10301a90)
FWarpZoneSceneNode* FWarpZoneSceneNode::GetWarpZoneSceneNode() { return this; }

// FLevelSceneNode
IMPL_TODO("stub body (1 line(s)) — Ghidra 0x10400290 is 2966 bytes, not fully reconstructed")
FConvexVolume FLevelSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FLightMapSceneNode
extern ENGINE_API FRebuildTools GRebuildTools;
IMPL_EMPTY("virtual base no-op — rendering subclass overrides")
void FLightMapSceneNode::Render(FRenderInterface*) {}
IMPL_MATCH("Engine.dll", 0x103d0dc0)
INT FLightMapSceneNode::FilterActor(AActor* Actor)
{
	if ((GRebuildTools.Pad[0x10] & 0x10) && (*(DWORD*)((BYTE*)Actor + 0xAC) & 0x1800))
		return 0;
	return (*(DWORD*)((BYTE*)Actor + 0xA4) >> 30) & 1;
}

// FDirectionalLightMapSceneNode
IMPL_TODO("stub body (1 line(s)) — Ghidra 0x103d25d0 is 1896 bytes, not fully reconstructed")
FConvexVolume FDirectionalLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// FPointLightMapSceneNode
IMPL_TODO("stub body (1 line(s)) — Ghidra 0x103d1740 is 1492 bytes, not fully reconstructed")
FConvexVolume FPointLightMapSceneNode::GetViewFrustum() { return FConvexVolume(); }

// ============================================================================
// HCoords
// ============================================================================
IMPL_EMPTY("body unanalyzed; camera-coordinate transform pending Ghidra analysis")
HCoords::HCoords(FCameraSceneNode*) {}

// --- Moved from EngineStubs.cpp ---
IMPL_MATCH("Engine.dll", 0x10410d00)
void URenderResource::Serialize(FArchive& Ar)
{
	UObject::Serialize(Ar);
	Ar << Revision;
}
IMPL_EMPTY("virtual base no-op — subclass handles hit events")
void FHitObserver::Click(const FHitCause& Cause, const HHitProxy& Hit) {}

// ?AVIStart@@YAXPBGPAVUEngine@@H@Z
IMPL_EMPTY("body unanalyzed; AVI recording start not implemented")
void AVIStart(const TCHAR* p0, UEngine * p1, int p2) {}

// ?AVIStop@@YAXXZ
IMPL_EMPTY("body unanalyzed; AVI recording stop not implemented")
void AVIStop() {}

// ?AVITakeShot@@YAXPAVUEngine@@@Z
IMPL_EMPTY("body unanalyzed; AVI frame capture not implemented")
void AVITakeShot(UEngine * p0) {}

// ?DrawSprite@@YAXPAVAActor@@VFVector@@PAVUMaterial@@PAVFLevelSceneNode@@PAVFRenderInterface@@@Z
IMPL_EMPTY("body unanalyzed; sprite draw (actor overload) not implemented")
void DrawSprite(AActor * p0, FVector p1, UMaterial * p2, FLevelSceneNode * p3, FRenderInterface * p4) {}

// ?DrawSprite@@YAXMVFVector@@0PAVUMaterial@@VFPlane@@EPAVFCameraSceneNode@@PAVFRenderInterface@@MHH@Z
IMPL_EMPTY("body unanalyzed; sprite draw (scale/camera overload) not implemented")
void DrawSprite(float p0, FVector p1, FVector p2, UMaterial * p3, FPlane p4, BYTE p5, FCameraSceneNode * p6, FRenderInterface * p7, float p8, int p9, int p10) {}
