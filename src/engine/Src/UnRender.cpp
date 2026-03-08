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

void UCanvas::Init( UViewport* InViewport )
{
	guard(UCanvas::Init);
	Viewport = InViewport;
	unguard;
}

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

void UCanvas::execClipTextNative( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execClipTextNative);
	P_GET_STR(Text);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execClipTextNative );

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

void UCanvas::execDraw3DLine( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDraw3DLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor, Color);
	P_FINISH;
	if( Viewport && Viewport->RenDev )
		Viewport->RenDev->Draw3DLine( Viewport, Start, End, Color );
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDraw3DLine );

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

void UCanvas::execUseVirtualSize( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execUseVirtualSize);
	P_GET_UBOOL(bUse);
	P_FINISH;
	UseVirtualSize(bUse, m_fVirtualResX, m_fVirtualResY);
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execUseVirtualSize );

void UCanvas::execSetMotionBlurIntensity( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execSetMotionBlurIntensity);
	P_GET_FLOAT(Intensity);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetMotionBlurIntensity );

void UCanvas::execDrawWritableMap( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execDrawWritableMap);
	P_FINISH;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawWritableMap );

void UCanvas::execVideoOpen( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoOpen);
	P_GET_STR(Filename);
	P_FINISH;
	INT Handle = 0;
	if( Viewport && Viewport->RenDev )
		Handle = Viewport->RenDev->OpenVideo( *Filename );
	*(INT*)Result = Handle;
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoOpen );

void UCanvas::execVideoPlay( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoPlay);
	P_GET_INT(Handle);
	P_FINISH;
	if( Viewport && Viewport->RenDev )
		Viewport->RenDev->DisplayVideo( Handle );
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoPlay );

void UCanvas::execVideoStop( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoStop);
	P_GET_INT(Handle);
	P_FINISH;
	if( Viewport && Viewport->RenDev )
		Viewport->RenDev->StopVideo( Handle );
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoStop );

void UCanvas::execVideoClose( FFrame& Stack, RESULT_DECL )
{
	guard(UCanvas::execVideoClose);
	P_GET_INT(Handle);
	P_FINISH;
	if( Viewport && Viewport->RenDev )
		Viewport->RenDev->CloseVideo( Handle );
	unguardexec;
}
IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoClose );

/*=============================================================================
	AHUD implementation.
=============================================================================*/

void AHUD::execDraw3DLine( FFrame& Stack, RESULT_DECL )
{
	guard(AHUD::execDraw3DLine);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_GET_STRUCT(FColor, Color);
	P_FINISH;
	// Delegate to the viewport's render device if available.
	if( XLevel && XLevel->Engine )
	{
		UViewport* Viewport = Cast<UViewport>( Player );
		if( Viewport && Viewport->RenDev )
			Viewport->RenDev->Draw3DLine( Viewport, Start, End, Color );
	}
	unguardexec;
}
IMPLEMENT_FUNCTION( AHUD, INDEX_NONE, execDraw3DLine );

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
