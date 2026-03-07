/*=============================================================================
	UnRender.cpp: URenderDevice, UCanvas, AHUD stubs.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(URenderDevice);
IMPLEMENT_CLASS(UCanvas);
IMPLEMENT_CLASS(AHUD);

#define EXEC_STUB(cls,func) void cls::func( FFrame& Stack, RESULT_DECL ) { P_FINISH; }

EXEC_STUB(UCanvas,execSetPos)                  IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetPos );
EXEC_STUB(UCanvas,execSetOrigin)               IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetOrigin );
EXEC_STUB(UCanvas,execSetClip)                 IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetClip );
EXEC_STUB(UCanvas,execSetDrawColor)            IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetDrawColor );
EXEC_STUB(UCanvas,execDrawText)                IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawText );
EXEC_STUB(UCanvas,execDrawTextClipped)         IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTextClipped );
EXEC_STUB(UCanvas,execClipTextNative)          IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execClipTextNative );
EXEC_STUB(UCanvas,execDrawTile)                IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTile );
EXEC_STUB(UCanvas,execDrawTileClipped)         IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawTileClipped );
EXEC_STUB(UCanvas,execDrawStretchedTextureSegmentNative) IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawStretchedTextureSegmentNative );
EXEC_STUB(UCanvas,execDrawActor)               IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawActor );
EXEC_STUB(UCanvas,execDrawPortal)              IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawPortal );
EXEC_STUB(UCanvas,execDraw3DLine)              IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDraw3DLine );
EXEC_STUB(UCanvas,execStrLen)                  IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execStrLen );
EXEC_STUB(UCanvas,execTextSize)                IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execTextSize );
EXEC_STUB(UCanvas,execGetScreenCoordinate)     IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execGetScreenCoordinate );
EXEC_STUB(UCanvas,execSetVirtualSize)          IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetVirtualSize );
EXEC_STUB(UCanvas,execUseVirtualSize)          IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execUseVirtualSize );
EXEC_STUB(UCanvas,execSetMotionBlurIntensity)  IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execSetMotionBlurIntensity );
EXEC_STUB(UCanvas,execDrawWritableMap)         IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execDrawWritableMap );
EXEC_STUB(UCanvas,execVideoOpen)               IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoOpen );
EXEC_STUB(UCanvas,execVideoPlay)               IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoPlay );
EXEC_STUB(UCanvas,execVideoStop)               IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoStop );
EXEC_STUB(UCanvas,execVideoClose)              IMPLEMENT_FUNCTION( UCanvas, INDEX_NONE, execVideoClose );
EXEC_STUB(AHUD,execDraw3DLine)                 IMPLEMENT_FUNCTION( AHUD, INDEX_NONE, execDraw3DLine );

// UCanvas virtual interface stubs.
void UCanvas::Init( UViewport* InViewport ) {}
void UCanvas::Update() {}

#undef EXEC_STUB
