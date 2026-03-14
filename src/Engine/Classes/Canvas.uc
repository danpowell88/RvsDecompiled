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

// --- Variables ---
// Modifiable properties.
// Font for DrawText.
var Font Font;
// Color for drawing.
var Color DrawColor;
var float CurX;
// ^ NEW IN 1.60
//end R6Code
// Current position for drawing.
var float CurY;
var float ClipX;
// ^ NEW IN 1.60
// Drawing style STY_None means don't draw.
var byte Style;
var float OrgX;
// ^ NEW IN 1.60
// Origin for drawing.
var float OrgY;
var const int SizeX;
// ^ NEW IN 1.60
// Zero-based actual dimensions.
var const int SizeY;
// Stock fonts.
// Small system font.
var Font SmallFont;
// Spacing for after Draw*.
var float SpaceY;
// Bottom right clipping region.
var float ClipY;
// Largest Y size since DrawText.
var float CurYL;
// Whether to center the text.
var bool bCenter;
var float SpaceX;
// ^ NEW IN 1.60
var float m_fVirtualResY;
var float m_fVirtualResX;
// Medium system font.
var Font MedFont;
// Don't bilinear filter.
var bool bNoSmooth;
// Z location. 1=no screenflash, 2=yes screenflash.
var float Z;
var float HalfClipX;
// ^ NEW IN 1.60
//R6CODE
//Half clip value, to save all the /2 done on all clip values
var float HalfClipY;
// Internal.
// Viewport that owns the canvas.
var const Viewport Viewport;
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

// --- Functions ---
// function ? SetStretch(...); // REMOVED IN 1.60
final function DrawRect(Texture Tex, float RectY, float RectX) {}
final function DrawLine(float Size, int direction) {}
static final function Color MakeColor(optional byte A, byte B, byte G, byte R) {}
// ^ NEW IN 1.60
final native function StrLen(out float YL, out float XL, coerce string String) {}
// ^ NEW IN 1.60
final native function DrawText(optional bool CR, coerce string Text) {}
// ^ NEW IN 1.60
final native function DrawTile(optional float fRotationAngle, float VL, float UL, float V, float U, float YL, float XL, Material Mat) {}
// ^ NEW IN 1.60
final native function DrawActor(optional float DisplayFOV, optional bool ClearZ, bool Wireframe, Actor A) {}
// ^ NEW IN 1.60
final native function DrawTileClipped(float VL, float UL, float V, float U, float YL, float XL, Material Mat) {}
// ^ NEW IN 1.60
final native function DrawTextClipped(optional bool bCheckHotKey, coerce string Text) {}
// ^ NEW IN 1.60
final native function string TextSize(optional int SpaceWidth, optional int TotalWidth, out float YL, out float XL, coerce string String) {}
// ^ NEW IN 1.60
final native function DrawPortal(optional bool ClearZ, optional int FOV, Rotator CamRotation, Vector CamLocation, Actor CamActor, int Height, int Width, int Y, int X) {}
// ^ NEW IN 1.60
final native function SetMotionBlurIntensity(int iIntensityValue) {}
// ^ NEW IN 1.60
final native function bool GetScreenCoordinate(optional float fFOV, Rotator rCamRotation, Vector vCamLocation, Vector v3DCoordinate, out float fScreenY, out float fScreenX) {}
// ^ NEW IN 1.60
final native function Draw3DLine(Color cLineColor, Vector vEnd, Vector vStart) {}
// ^ NEW IN 1.60
final native function VideoOpen(int bDisplayDoubleSize, string Name) {}
// ^ NEW IN 1.60
final native function VideoPlay(int bCentered, int iPosY, int iPosX) {}
// ^ NEW IN 1.60
final native function DrawWritableMap(LevelInfo Info) {}
// ^ NEW IN 1.60
final native function UseVirtualSize(optional float Y, optional float X, bool bUse) {}
final native function SetVirtualSize(float Y, float X) {}
final native function SetPos(float Y, float X) {}
final native function SetOrigin(float Y, float X) {}
final native function SetClip(float Y, float X) {}
final native function SetDrawColor(optional byte A, byte B, byte G, byte R) {}
final native function DrawStretchedTextureSegmentNative(Texture Tex, Region ClipRegion, float GUIScale, float tH, float tW, float tY, float tX, float H, float W, float Y, float X) {}
// ^ NEW IN 1.60
final native function ClipTextNative(optional bool bCheckHotKey, Region ClipRegion, float GUIScale, coerce string S, float Y, float X) {}
// ^ NEW IN 1.60
final function DrawVertical(float Height, float X) {}
final function DrawHorizontal(float Width, float Y) {}
final function DrawPattern(float Scale, float XL, float YL, Texture Tex) {}
final function DrawIcon(Texture Tex, float Scale) {}
final simulated function DrawBracket(float bracket_size, float Width, float Height) {}
final simulated function DrawBox(Canvas Canvas, float Height, float Width) {}
final native function VideoClose() {}
// ^ NEW IN 1.60
final native function VideoStop() {}
// ^ NEW IN 1.60
// UnrealScript functions.
event Reset() {}
final function float GetVirtualSizeX() {}
// ^ NEW IN 1.60
final function float GetVirtualSizeY() {}
// ^ NEW IN 1.60

defaultproperties
{
}
