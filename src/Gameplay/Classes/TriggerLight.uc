//=============================================================================
// TriggerLight.
// A lightsource which can be triggered on or off.
//=============================================================================
class TriggerLight extends Light;

// --- Variables ---
// var ? Direction; // REMOVED IN 1.60
var Actor SavedTrigger;
var float direction;
// ^ NEW IN 1.60
var float Alpha;
// ^ NEW IN 1.60
var float ChangeTime;
// ^ NEW IN 1.60
var bool bInitiallyOn;
// ^ NEW IN 1.60
// Initial brightness.
var float InitialBrightness;
var float poundTime;
var bool bDelayFullOn;
// ^ NEW IN 1.60
var float RemainOnTime;
// ^ NEW IN 1.60

// --- Functions ---
// Called whenever time passes.
function Tick(float DeltaTime) {}
// Called at start of gameplay.
simulated function BeginPlay() {}

state TriggerPound
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function Timer() {}
}

state TriggerControl
{
    function UnTrigger(Actor Other, Pawn EventInstigator) {}
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state TriggerToggle
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state TriggerTurnsOff
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state TriggerTurnsOn
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

defaultproperties
{
}
