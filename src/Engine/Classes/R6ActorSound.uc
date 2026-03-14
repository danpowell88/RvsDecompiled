//============================================================================//
// Class            R6ActorSound.uc
//----------------------------------------------------------------------------//
//============================================================================//
class R6ActorSound extends Actor;

// --- Variables ---
var /* replicated */ Sound m_ImpactSoundStop;
var /* replicated */ Sound m_ImpactSound;
var /* replicated */ float m_fExplosionDelay;
var /* replicated */ ESoundSlot m_eTypeSound;

// --- Functions ---
simulated function Timer() {}
simulated function SpawnSound() {}
simulated function FirstPassReset() {}

state StartUp
{
    simulated function Tick(float DeltaTime) {}
}

defaultproperties
{
}
