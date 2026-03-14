//=============================================================================
// FluidSurfaceInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class FluidSurfaceInfo extends Info
	native
	noexport
 placeable;

enum EFluidGridType
{
	FGT_Square,                     // 0
	FGT_Hexagonal                   // 1
};

// NEW IN 1.60
var() FluidSurfaceInfo.EFluidGridType FluidGridType;
var() float FluidGridSpacing;  // distance between grid points
var() int FluidXSize;  // num vertices in X direction
var() int FluidYSize;  // num vertices in Y direction
var() float FluidHeightScale;  // vertical scale factor
var() float FluidSpeed;  // wave speed
var() float FluidDamping;  // between 0 and 1
var() float FluidNoiseFrequency;
var() Range FluidNoiseStrength;
var() bool TestRipple;
var() float TestRippleSpeed;
var() float TestRippleStrength;
var() float TestRippleRadius;
var() float UTiles;
var() float UOffset;
var() float VTiles;
var() float VOffset;
var() float AlphaCurveScale;
var() float AlphaHeightScale;
var() byte AlphaMax;
// How hard to ripple water when shot
var() float ShootStrength;
// How much to ripple the water when interacting with actors
var() float RippleVelocityFactor;
var() float TouchStrength;
// Effect spawned when water surface it shot or touched by an actor
var() Class<Effects> ShootEffect;
var() bool OrientShootEffect;
var() Class<Effects> TouchEffect;
var() bool OrientTouchEffect;
// Bitmap indicating which water verts are 'clamped' ie. dont move
var const array<int> ClampBitmap;
// Terrain used for auto-clamping water verts if below terrain level.
var() edfindable TerrainInfo ClampTerrain;
var() bool bShowBoundingBox;
// Amount of time to simulate during postload before water is first displayed
var() float WarmUpTime;
// Rate at which fluid sim will be updated (default 30Hz)
var() float UpdateRate;
// Sim storage
var const transient array<float> Verts0;
var const transient array<float> Verts1;
var const transient array<byte> VertAlpha;
var const transient int LatestVerts;
var const transient Box FluidBoundingBox;  // Current world-space AABB
var const transient Vector FluidOrigin;  // Current bottom-left corner
var const transient float TimeRollover;
//var transient const float			AverageTimeStep;
//var transient const int  			StepCount;
var const transient float TestRippleAng;
var const transient FluidSurfacePrimitive Primitive;
var const transient array<FluidSurfaceOscillator> Oscillators;
var const transient bool bHasWarmedUp;

// Export UFluidSurfaceInfo::execPling(FFrame&, void* const)
// Ripple water at a particlar location.
// Ignores 'z' componenet of position.
 native final function Pling(Vector Position, float Strength, optional float Radius);

// NEW IN 1.60
function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	Pling(vHitLocation, ShootStrength, 0.0000000);
	// End:0x51
	if(__NFUN_119__(ShootEffect, none))
	{
		// End:0x42
		if(OrientShootEffect)
		{
			__NFUN_278__(ShootEffect, self,, vHitLocation, Rotator(vMomentum));			
		}
		else
		{
			__NFUN_278__(ShootEffect, self,, vHitLocation);
		}
	}
	return 0;
	return;
}

function Touch(Actor Other)
{
	local Vector touchLocation;

	super(Actor).Touch(Other);
	// End:0x22
	if(__NFUN_242__(Other.bDisturbFluidSurface, false))
	{
		return;
	}
	touchLocation = Other.Location;
	touchLocation.Z = Location.Z;
	Pling(touchLocation, TouchStrength, Other.CollisionRadius);
	// End:0xAE
	if(__NFUN_119__(ShootEffect, none))
	{
		// End:0x9F
		if(OrientTouchEffect)
		{
			__NFUN_278__(TouchEffect, self,, touchLocation, Rotator(Other.Velocity));			
		}
		else
		{
			__NFUN_278__(TouchEffect, self,, touchLocation);
		}
	}
	return;
}

defaultproperties
{
	FluidGridType=1
	FluidGridSpacing=32.0000000
	FluidXSize=32
	FluidYSize=32
	FluidHeightScale=1.0000000
	FluidSpeed=150.0000000
	FluidDamping=0.3000000
	FluidNoiseStrength=(Min=-100.0000000,Max=100.0000000)
	TestRippleSpeed=6000.0000000
	TestRippleStrength=-300.0000000
	TestRippleRadius=34.0000000
	UTiles=1.0000000
	VTiles=1.0000000
	AlphaHeightScale=10.0000000
	AlphaMax=128
	ShootStrength=-300.0000000
	RippleVelocityFactor=-0.0400000
	TouchStrength=-200.0000000
	WarmUpTime=2.0000000
	UpdateRate=30.0000000
	DrawType=12
	bHidden=false
	bCollideActors=true
	bProjTarget=true
	Texture=Texture'Engine.S_TerrainInfo'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var EFluidGridType
// REMOVED IN 1.60: function TakeDamage
