//=============================================================================
// Canvas - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Canvas: A drawing canvas.
// This is a built-in Unreal class and it shouldn't be modified.
//
// Notes.
//   To determine size of a drawable object, set Style to STY_None,
//   remember CurX, draw the thing, then inspect CurX and CurYL.
//=============================================================================
class Canvas extends Object
	native
 noexport;

// Modifiable properties.
var Font Font;  // Font for DrawText.
var float SpaceX;  // Spacing for after Draw*.
// NEW IN 1.60
var float SpaceY;
var float OrgX;  // Origin for drawing.
// NEW IN 1.60
var float OrgY;
var float ClipX;  // Bottom right clipping region.
// NEW IN 1.60
var float ClipY;
//R6CODE
var float HalfClipX;  // Half clip value, to save all the /2 done on all clip values
// NEW IN 1.60
var float HalfClipY;
//end R6Code
var float CurX;  // Current position for drawing.
// NEW IN 1.60
var float CurY;
var float Z;  // Z location. 1=no screenflash, 2=yes screenflash.
var byte Style;  // Drawing style STY_None means don't draw.
var float CurYL;  // Largest Y size since DrawText.
var Color DrawColor;  // Color for drawing.
var bool bCenter;  // Whether to center the text.
var bool bNoSmooth;  // Don't bilinear filter.
var const int SizeX;  // Zero-based actual dimensions.
// NEW IN 1.60
var const int SizeY;
// Stock fonts.
var Font SmallFont;  // Small system font.
var Font MedFont;  // Medium system font.
// Internal.
var const Viewport Viewport;  // Viewport that owns the canvas.
//R6VIDEO
var int m_hBink;
var bool m_bPlaying;
var int m_iPosX;
var int m_iPosY;
//R6NewRendererFeatures
var bool m_bForceMul2x;
// R6STRETCHHUD
var float m_fStretchX;
var float m_fStretchY;
var float m_fVirtualResX;
var float m_fVirtualResY;
var float m_fNormalClipX;
var float m_fNormalClipY;
// R6CHANGERES
var bool m_bDisplayGameOutroVideo;
var bool m_bChangeResRequested;
var int m_iNewResolutionX;
var int m_iNewResolutionY;
//R6CODE
var bool m_bFading;
var bool m_bFadeAutoStop;
var Color m_FadeStartColor;
var Color m_FadeEndColor;
var float m_fFadeTotalTime;
var float m_fFadeCurrentTime;
var Material m_pWritableMapIconsTexture;

// Export UCanvas::execStrLen(FFrame&, void* const)
// native functions.
 native(464) final function StrLen(coerce string String, out float XL, out float YL);

// Export UCanvas::execDrawText(FFrame&, void* const)
 native(465) final function DrawText(coerce string Text, optional bool CR);

// Export UCanvas::execDrawTile(FFrame&, void* const)
//R6DRAWTILEROTATED
 native(466) final function DrawTile(Material Mat, float XL, float YL, float U, float V, float UL, float VL, optional float fRotationAngle);

// Export UCanvas::execDrawActor(FFrame&, void* const)
//ELSE
//native(466) final function DrawTile( material Mat, float XL, float YL, float U, float V, float UL, float VL );
//END R6DRAWTILEROTATED
 native(467) final function DrawActor(Actor A, bool Wireframe, optional bool ClearZ, optional float DisplayFOV);

// Export UCanvas::execDrawTileClipped(FFrame&, void* const)
 native(468) final function DrawTileClipped(Material Mat, float XL, float YL, float U, float V, float UL, float VL);

// Export UCanvas::execDrawTextClipped(FFrame&, void* const)
 native(469) final function DrawTextClipped(coerce string Text, optional bool bCheckHotKey);

// Export UCanvas::execTextSize(FFrame&, void* const)
//R6CODE
 native(470) final function string TextSize(coerce string String, out float XL, out float YL, optional int TotalWidth, optional int SpaceWidth);

// Export UCanvas::execDrawPortal(FFrame&, void* const)
//ELSE
//native(470) final function TextSize( coerce string String, out float XL, out float YL);
//END //R6CODE
 native(480) final function DrawPortal(int X, int Y, int Width, int Height, Actor CamActor, Vector CamLocation, Rotator CamRotation, optional int FOV, optional bool ClearZ);

// Export UCanvas::execSetMotionBlurIntensity(FFrame&, void* const)
//R6MOTIONBLUR
 native(2005) final function SetMotionBlurIntensity(int iIntensityValue);

// Export UCanvas::execGetScreenCoordinate(FFrame&, void* const)
// R6AUTOTARGET
 native(2400) final function bool GetScreenCoordinate(out float fScreenX, out float fScreenY, Vector v3DCoordinate, Vector vCamLocation, Rotator rCamRotation, optional float fFOV);

// Export UCanvas::execDraw3DLine(FFrame&, void* const)
// R6DRAW3DLINE
 native(2403) final function Draw3DLine(Vector vStart, Vector vEnd, Color cLineColor);

// Export UCanvas::execVideoOpen(FFrame&, void* const)
// #ifdef R6VIDEO
 native(2601) final function VideoOpen(string Name, int bDisplayDoubleSize);

// Export UCanvas::execVideoClose(FFrame&, void* const)
 native(2602) final function VideoClose();

// Export UCanvas::execVideoPlay(FFrame&, void* const)
 native(2603) final function VideoPlay(int iPosX, int iPosY, int bCentered);

// Export UCanvas::execVideoStop(FFrame&, void* const)
 native(2604) final function VideoStop();

// Export UCanvas::execDrawWritableMap(FFrame&, void* const)
// #ifdef R6WRITABLEMAP
 native(2800) final function DrawWritableMap(LevelInfo Info);

// Export UCanvas::execUseVirtualSize(FFrame&, void* const)
// #ifdef R6STRETCHHUD
 native(1606) final function UseVirtualSize(bool bUse, optional float X, optional float Y);

// Export UCanvas::execSetVirtualSize(FFrame&, void* const)
 native(1607) final function SetVirtualSize(float X, float Y);

// Export UCanvas::execSetPos(FFrame&, void* const)
// R6CODE
 native(2623) final function SetPos(float X, float Y);

// Export UCanvas::execSetOrigin(FFrame&, void* const)
 native(2624) final function SetOrigin(float X, float Y);

// Export UCanvas::execSetClip(FFrame&, void* const)
 native(2625) final function SetClip(float X, float Y);

// Export UCanvas::execSetDrawColor(FFrame&, void* const)
 native(2626) final function SetDrawColor(byte R, byte G, byte B, optional byte A);

// Export UCanvas::execDrawStretchedTextureSegmentNative(FFrame&, void* const)
 native(2627) final function DrawStretchedTextureSegmentNative(float X, float Y, float W, float H, float tX, float tY, float tW, float tH, float GUIScale, Region ClipRegion, Texture Tex);

// Export UCanvas::execClipTextNative(FFrame&, void* const)
 native(2628) final function ClipTextNative(float X, float Y, coerce string S, float GUIScale, Region ClipRegion, optional bool bCheckHotKey);

// UnrealScript functions.
event Reset()
{
	Font = Font(DynamicLoadObject("R6Font.SmallFont", Class'Engine.Font'));
	SmallFont = Font;
	MedFont = Font(DynamicLoadObject("R6Font.MediumFont", Class'Engine.Font'));
	SpaceX = default.SpaceX;
	SpaceY = default.SpaceY;
	OrgX = default.OrgX;
	OrgY = default.OrgY;
	CurX = default.CurX;
	CurY = default.CurY;
	Style = default.Style;
	DrawColor = default.DrawColor;
	CurYL = default.CurYL;
	bCenter = false;
	bNoSmooth = false;
	Z = 1.0000000;
	return;
}

final function DrawPattern(Texture Tex, float XL, float YL, float Scale)
{
	__NFUN_466__(Tex, XL, YL, __NFUN_171__(__NFUN_175__(CurX, OrgX), Scale), __NFUN_171__(__NFUN_175__(CurY, OrgY), Scale), __NFUN_171__(XL, Scale), __NFUN_171__(YL, Scale));
	return;
}

final function DrawIcon(Texture Tex, float Scale)
{
	// End:0x6B
	if(__NFUN_119__(Tex, none))
	{
		__NFUN_466__(Tex, __NFUN_171__(float(Tex.USize), Scale), __NFUN_171__(float(Tex.VSize), Scale), 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize));
	}
	return;
}

final function DrawRect(Texture Tex, float RectX, float RectY)
{
	__NFUN_466__(Tex, RectX, RectY, 0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize));
	return;
}

static final function Color MakeColor(byte R, byte G, byte B, optional byte A)
{
	local Color C;

	C.R = R;
	C.G = G;
	C.B = B;
	// End:0x47
	if(__NFUN_154__(int(A), 0))
	{
		A = byte(255);
	}
	C.A = A;
	return C;
	return;
}

// Draw a vertical line
final function DrawVertical(float X, float Height)
{
	__NFUN_2623__(X, CurY);
	DrawRect(Texture'Engine.WhiteSquareTexture', 2.0000000, Height);
	return;
}

// Draw a horizontal line
final function DrawHorizontal(float Y, float Width)
{
	__NFUN_2623__(CurX, Y);
	DrawRect(Texture'Engine.WhiteSquareTexture', Width, 2.0000000);
	return;
}

final function DrawLine(int direction, float Size)
{
	local float X, Y;

	X = CurX;
	Y = CurY;
	switch(direction)
	{
		// End:0x4D
		case 0:
			__NFUN_2623__(X, __NFUN_175__(Y, Size));
			DrawRect(Texture'Engine.WhiteSquareTexture', 2.0000000, Size);
			// End:0xBA
			break;
		// End:0x69
		case 1:
			DrawRect(Texture'Engine.WhiteSquareTexture', 2.0000000, Size);
			// End:0xBA
			break;
		// End:0x9A
		case 2:
			__NFUN_2623__(__NFUN_175__(X, Size), Y);
			DrawRect(Texture'Engine.WhiteSquareTexture', Size, 2.0000000);
			// End:0xBA
			break;
		// End:0xB7
		case 3:
			DrawRect(Texture'Engine.WhiteSquareTexture', Size, 2.0000000);
			// End:0xBA
			break;
		// End:0xFFFF
		default:
			break;
	}
	__NFUN_2623__(X, Y);
	return;
}

final simulated function DrawBracket(float Width, float Height, float bracket_size)
{
	local float X, Y;

	X = CurX;
	Y = CurY;
	Width = float(__NFUN_250__(int(Width), 5));
	Height = float(__NFUN_250__(int(Height), 5));
	DrawLine(3, bracket_size);
	DrawLine(1, bracket_size);
	__NFUN_2623__(__NFUN_174__(X, Width), Y);
	DrawLine(2, bracket_size);
	DrawLine(1, bracket_size);
	__NFUN_2623__(__NFUN_174__(X, Width), __NFUN_174__(Y, Height));
	DrawLine(0, bracket_size);
	DrawLine(2, bracket_size);
	__NFUN_2623__(X, __NFUN_174__(Y, Height));
	DrawLine(3, bracket_size);
	DrawLine(0, bracket_size);
	__NFUN_2623__(X, Y);
	return;
}

final simulated function DrawBox(Canvas Canvas, float Width, float Height)
{
	local float X, Y;

	X = Canvas.CurX;
	Y = Canvas.CurY;
	Canvas.DrawRect(Texture'Engine.WhiteSquareTexture', 2.0000000, Height);
	Canvas.DrawRect(Texture'Engine.WhiteSquareTexture', Width, 2.0000000);
	Canvas.__NFUN_2623__(__NFUN_174__(X, Width), Y);
	Canvas.DrawRect(Texture'Engine.WhiteSquareTexture', 2.0000000, Height);
	Canvas.__NFUN_2623__(X, __NFUN_174__(Y, Height));
	Canvas.DrawRect(Texture'Engine.WhiteSquareTexture', __NFUN_174__(Width, float(1)), 2.0000000);
	Canvas.__NFUN_2623__(X, Y);
	return;
}

final function float GetVirtualSizeX()
{
	return m_fVirtualResX;
	return;
}

final function float GetVirtualSizeY()
{
	return m_fVirtualResY;
	return;
}

defaultproperties
{
	Z=1.0000000
	Style=1
	DrawColor=(R=127,G=127,B=127,A=255)
	m_fStretchX=1.0000000
	m_fStretchY=1.0000000
	m_fVirtualResX=800.0000000
	m_fVirtualResY=600.0000000
	m_fNormalClipX=-1.0000000
	m_fNormalClipY=-1.0000000
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var Y
// REMOVED IN 1.60: function SetStretch
