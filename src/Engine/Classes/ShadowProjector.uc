//=============================================================================
// ShadowProjector.
//=============================================================================
class ShadowProjector extends Projector;

// --- Variables ---
var ShadowBitmapMaterial ShadowTexture;
var Actor ShadowActor;
// ^ NEW IN 1.60
var float LightDistance;
// ^ NEW IN 1.60
var bool m_bAttached;
var byte m_bOpacity;
var Vector LightDirection;
// ^ NEW IN 1.60
var bool bUseLightAverage;
// ^ NEW IN 1.60

// --- Functions ---
simulated function LightUpdateDirect(Vector LightDir, float LightDist, byte bOpacity) {}
event Touch(Actor Other) {}
event UpdateShadow() {}
simulated event Destroyed() {}
simulated function Tick(float DeltaTime) {}
simulated event PostBeginPlay() {}

defaultproperties
{
}
