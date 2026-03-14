// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6GenericHB extends R6InteractiveObject
    native
    abstract;

// --- Variables ---
// Sound made when projectile hits something.
var Sound m_ImpactSound;
var bool m_bFirstImpact;
var Sound m_ImpactWaterSound;
var Sound m_ImpactGroundSound;

// --- Functions ---
simulated function ProcessTouch(Vector vHitLocation, Actor Other) {}
simulated function Landed(Vector HitNormal) {}
simulated function SetSpeed(float fSpeed) {}
simulated event HitWall(Actor Wall, Vector HitNormal) {}
singular simulated function Touch(Actor Other) {}

defaultproperties
{
}
