//=============================================================================
// FireTexture: A FireEngine fire texture.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class FireTexture extends FractalTexture
    native
    noexport;

// --- Enums ---
enum ESpark
{	
	SPARK_Burn				,
	SPARK_Sparkle			,
	SPARK_Pulse				,
	SPARK_Signal			,
	SPARK_Blaze				,
	SPARK_OzHasSpoken		,
	SPARK_Cone				,
	SPARK_BlazeRight		,
	SPARK_BlazeLeft			,
	SPARK_Cylinder			,
	SPARK_Cylinder3D		,
	SPARK_Lissajous 		,
	SPARK_Jugglers   		,
	SPARK_Emit				,
    SPARK_Fountain			,
	SPARK_Flocks			,
	SPARK_Eels				,
	SPARK_Organic			,
	SPARK_WanderOrganic		,
	SPARK_RandomCloud		,
	SPARK_CustomCloud		,
	SPARK_LocalCloud		,
	SPARK_Stars				,
	SPARK_LineLightning		,
	SPARK_RampLightning		,
    SPARK_SphereLightning	,
    SPARK_Wheel				,
	SPARK_Gametes    		,
	SPARK_Sprinkler			,
};
enum DMode
{
	DRAW_Normal  ,
	DRAW_Lathe   ,
	DRAW_Lathe_2 ,
	DRAW_Lathe_3 ,
	DRAW_Lathe_4 ,
};

// --- Structs ---
struct Spark
{
    var ESpark Type;   // Spark type.
    var byte   Heat;   // Spark heat.
    var byte   X;      // Spark X location (0 - Xdimension-1).
    var byte   Y;      // Spark Y location (0 - Ydimension-1).

    var byte   ByteA;  // X-speed.
    var byte   ByteB;  // Y-speed.
    var byte   ByteC;  // Age, Emitter freq.
    var byte   ByteD;  // Exp.Time.
};

// --- Variables ---
// var ? ByteA; // REMOVED IN 1.60
// var ? ByteB; // REMOVED IN 1.60
// var ? ByteC; // REMOVED IN 1.60
// var ? ByteD; // REMOVED IN 1.60
// var ? Heat; // REMOVED IN 1.60
// var ? Type; // REMOVED IN 1.60
// var ? X; // REMOVED IN 1.60
// var ? Y; // REMOVED IN 1.60
var ESpark SparkType;
// ^ NEW IN 1.60
var byte RenderHeat;
// ^ NEW IN 1.60
var bool bRising;
// ^ NEW IN 1.60
var byte FX_Heat;
// ^ NEW IN 1.60
var byte FX_Size;
// ^ NEW IN 1.60
var byte FX_AuxSize;
// ^ NEW IN 1.60
var byte FX_Area;
// ^ NEW IN 1.60
var byte FX_Frequency;
// ^ NEW IN 1.60
var byte FX_Phase;
// ^ NEW IN 1.60
var byte FX_HorizSpeed;
// ^ NEW IN 1.60
var byte FX_VertSpeed;
// ^ NEW IN 1.60
var DMode DrawMode;
// ^ NEW IN 1.60
var int SparksLimit;
// ^ NEW IN 1.60
var int NumSparks;
var transient array<array> Sparks;
var transient int OldRenderHeat;
var transient byte RenderTable[1028];
var transient byte StarStatus;
var transient byte PenDownX;
var transient byte PenDownY;

defaultproperties
{
}
