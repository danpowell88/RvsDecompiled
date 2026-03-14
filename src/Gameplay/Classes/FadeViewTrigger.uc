// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Gameplay.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class FadeViewTrigger extends Triggers
    notplaceable;

// --- Variables ---
var Vector TargetFlash;
// ^ NEW IN 1.60
var bool bTriggered;
var Vector OldViewFlash;
var float FadeSeconds;
// ^ NEW IN 1.60
var bool bTriggerOnceOnly;
// ^ NEW IN 1.60
var Vector ViewFlash;
// ^ NEW IN 1.60
var Vector ViewFog;
// ^ NEW IN 1.60

// --- Functions ---
event Trigger(Actor Other, Pawn EventInstigator) {}

state IsTriggered
{
    event Tick(float DeltaTime) {}
}

defaultproperties
{
}
