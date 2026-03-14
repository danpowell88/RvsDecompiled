//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
    native;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1

// --- Variables ---
var array<array> Emitters;
var bool AutoDestroy;
var bool AutoReset;
var bool DisableFogging;
var RangeVector GlobalOffsetRange;
var Range TimeTillResetRange;
var transient int Initialized;
var transient Box BoundingBox;
var transient float EmitterRadius;
var transient float EmitterHeight;
var transient bool ActorForcesEnabled;
var transient Vector GlobalOffset;
var transient float TimeTillReset;
var transient bool UseParticleProjectors;
var transient ParticleMaterial ParticleMaterial;
var transient bool DeleteParticleEmitters;

// --- Functions ---
function Trigger(Actor Other, Pawn EventInstigator) {}
// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill() {}

defaultproperties
{
}
