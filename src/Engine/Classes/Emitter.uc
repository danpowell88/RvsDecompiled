//=============================================================================
// Emitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
    native
    placeable;

var(Global) bool AutoDestroy;
var(Global) bool AutoReset;
var(Global) bool DisableFogging;
var() export editinline array<export editinline ParticleEmitter> Emitters;
var(Global) RangeVector GlobalOffsetRange;
var(Global) Range TimeTillResetRange;
var transient int Initialized;
var transient bool ActorForcesEnabled;
var transient bool UseParticleProjectors;
var transient bool DeleteParticleEmitters;
var transient float EmitterRadius;
var transient float EmitterHeight;
var transient float TimeTillReset;
var transient ParticleMaterial ParticleMaterial;
var transient Box BoundingBox;
var transient Vector GlobalOffset;

// Export UEmitter::execKill(FFrame&, void* const)
// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill();

function Trigger(Actor Other, Pawn EventInstigator)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x5F [Loop If]
	if((i < Emitters.Length))
	{
		// End:0x55
		if((Emitters[i] != none))
		{
			Emitters[i].Disabled = (!Emitters[i].Disabled);
		}
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	return;
}

defaultproperties
{
	DrawType=10
	Style=6
	bNoDelete=true
	m_bUseR6Availability=true
	bUnlit=true
	Texture=Texture'Engine.S_Emitter'
}
