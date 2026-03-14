//=============================================================================
// SpriteEmitter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Emitter: An Unreal Sprite Particle Emitter.
//=============================================================================
class SpriteEmitter extends ParticleEmitter
	native
	editinlinenew;

enum EParticleDirectionUsage
{
	PTDU_None,                      // 0
	PTDU_Up,                        // 1
	PTDU_Right,                     // 2
	PTDU_Forward,                   // 3
	PTDU_Normal,                    // 4
	PTDU_UpAndNormal,               // 5
	PTDU_RightAndNormal             // 6
};

var(Sprite) SpriteEmitter.EParticleDirectionUsage UseDirectionAs;
var(Sprite) Vector ProjectionNormal;
var transient Vector RealProjectionNormal;

defaultproperties
{
	ProjectionNormal=(X=0.0000000,Y=0.0000000,Z=1.0000000)
}
