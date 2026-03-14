//=============================================================================
// Emitter: An Unreal Sprite Particle Emitter.
//=============================================================================
class SpriteEmitter extends ParticleEmitter
    native;

// --- Enums ---
enum EParticleDirectionUsage
{
	PTDU_None,
	PTDU_Up,
	PTDU_Right,
	PTDU_Forward,
	PTDU_Normal,
	PTDU_UpAndNormal,
	PTDU_RightAndNormal
};

// --- Variables ---
var EParticleDirectionUsage UseDirectionAs;
var Vector ProjectionNormal;
var transient Vector RealProjectionNormal;

defaultproperties
{
}
