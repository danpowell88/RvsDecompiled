//=============================================================================
// FireTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// FireTexture: A FireEngine fire texture.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class FireTexture extends FractalTexture
    native
    noexport
    safereplace
    hidecategories(Object);

enum ESpark
{
	SPARK_Burn,                     // 0
	SPARK_Sparkle,                  // 1
	SPARK_Pulse,                    // 2
	SPARK_Signal,                   // 3
	SPARK_Blaze,                    // 4
	SPARK_OzHasSpoken,              // 5
	SPARK_Cone,                     // 6
	SPARK_BlazeRight,               // 7
	SPARK_BlazeLeft,                // 8
	SPARK_Cylinder,                 // 9
	SPARK_Cylinder3D,               // 10
	SPARK_Lissajous,                // 11
	SPARK_Jugglers,                 // 12
	SPARK_Emit,                     // 13
	SPARK_Fountain,                 // 14
	SPARK_Flocks,                   // 15
	SPARK_Eels,                     // 16
	SPARK_Organic,                  // 17
	SPARK_WanderOrganic,            // 18
	SPARK_RandomCloud,              // 19
	SPARK_CustomCloud,              // 20
	SPARK_LocalCloud,               // 21
	SPARK_Stars,                    // 22
	SPARK_LineLightning,            // 23
	SPARK_RampLightning,            // 24
	SPARK_SphereLightning,          // 25
	SPARK_Wheel,                    // 26
	SPARK_Gametes,                  // 27
	SPARK_Sprinkler                 // 28
};

enum DMode
{
	DRAW_Normal,                    // 0
	DRAW_Lathe,                     // 1
	DRAW_Lathe_2,                   // 2
	DRAW_Lathe_3,                   // 3
	DRAW_Lathe_4                    // 4
};

struct Spark
{
	var FireTexture.ESpark type;  // Spark type.
	var byte Heat;  // Spark heat.
	var byte X;  // Spark X location (0 - Xdimension-1).
	var byte Y;  // Spark Y location (0 - Ydimension-1).
	var byte ByteA;  // X-speed.
	var byte ByteB;  // Y-speed.
	var byte ByteC;  // Age, Emitter freq.
	var byte ByteD;  // Exp.Time.
};

var(FirePaint) FireTexture.ESpark SparkType;
var(FirePaint) byte RenderHeat;
var(FirePaint) bool bRising;
var(FirePaint) byte FX_Heat;
var(FirePaint) byte FX_Size;
var(FirePaint) byte FX_AuxSize;
var(FirePaint) byte FX_Area;
var(FirePaint) byte FX_Frequency;
var(FirePaint) byte FX_Phase;
var(FirePaint) byte FX_HorizSpeed;
var(FirePaint) byte FX_VertSpeed;
var(FirePaint) FireTexture.DMode DrawMode;
var(FirePaint) int SparksLimit;
var int NumSparks;
var transient array<Spark> Sparks;
var transient int OldRenderHeat;
var transient byte RenderTable[1028];
var transient byte StarStatus;
var transient byte PenDownX;
var transient byte PenDownY;

