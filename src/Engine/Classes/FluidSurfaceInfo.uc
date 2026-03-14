// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class FluidSurfaceInfo extends Info
    native
    noexport;

// --- Enums ---
enum EFluidGridType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
// Effect spawned when water surface it shot or touched by an actor
var class<Effects> ShootEffect;
var class<Effects> TouchEffect;
// How hard to ripple water when shot
var float ShootStrength;
var float TouchStrength;
var bool OrientShootEffect;
var bool OrientTouchEffect;
var transient const bool bHasWarmedUp;
var transient const array<array> Oscillators;
var transient const FluidSurfacePrimitive Primitive;
//var transient const float			AverageTimeStep;
//var transient const int  			StepCount;
var transient const float TestRippleAng;
var transient const float TimeRollover;
// Current bottom-left corner
var transient const Vector FluidOrigin;
// Current world-space AABB
var transient const Box FluidBoundingBox;
var transient const int LatestVerts;
var transient const array<array> VertAlpha;
var transient const array<array> Verts1;
// Sim storage
var transient const array<array> Verts0;
// Rate at which fluid sim will be updated (default 30Hz)
var float UpdateRate;
// Amount of time to simulate during postload before water is first displayed
var float WarmUpTime;
var bool bShowBoundingBox;
// Terrain used for auto-clamping water verts if below terrain level.
var TerrainInfo ClampTerrain;
// Bitmap indicating which water verts are 'clamped' ie. dont move
var const array<array> ClampBitmap;
// How much to ripple the water when interacting with actors
var float RippleVelocityFactor;
var byte AlphaMax;
var float AlphaHeightScale;
var float AlphaCurveScale;
var float VOffset;
var float VTiles;
var float UOffset;
var float UTiles;
var float TestRippleRadius;
var float TestRippleStrength;
var float TestRippleSpeed;
var bool TestRipple;
var Range FluidNoiseStrength;
var float FluidNoiseFrequency;
// between 0 and 1
var float FluidDamping;
// wave speed
var float FluidSpeed;
// vertical scale factor
var float FluidHeightScale;
// num vertices in Y direction
var int FluidYSize;
// num vertices in X direction
var int FluidXSize;
// distance between grid points
var float FluidGridSpacing;
var EFluidGridType FluidGridType;
// ^ NEW IN 1.60

// --- Functions ---
// function ? TakeDamage(...); // REMOVED IN 1.60
// Ripple water at a particlar location.
// Ignores 'z' componenet of position.
final native function Pling(Vector Position, float Strength, optional float Radius) {}
function int R6TakeDamage(Vector vHitLocation, Vector vMomentum, optional int iBulletGoup, int iBulletToArmorModifier, Pawn instigatedBy, int iStunValue, int iKillValue) {}
// ^ NEW IN 1.60
function Touch(Actor Other) {}

defaultproperties
{
}
