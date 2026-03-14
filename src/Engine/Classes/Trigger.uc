//=============================================================================
// Trigger: senses things happening in its proximity and generates 
// sends Trigger/UnTrigger to actors whose names match 'EventName'.
//=============================================================================
class Trigger extends Triggers
    native;

#exec Texture Import File=Textures\Trigger.pcx Name=S_Trigger Mips=Off MASKED=1

// --- Enums ---
enum ETriggerType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var bool bInitiallyActive;
// ^ NEW IN 1.60
var ETriggerType TriggerType;
// ^ NEW IN 1.60
// AI vars
// actor that triggers this trigger
var Actor TriggerActor;
var localized string Message;
// ^ NEW IN 1.60
var Actor TriggerActor2;
var bool bTriggerOnceOnly;
// ^ NEW IN 1.60
var float ReTriggerDelay;
// ^ NEW IN 1.60
var float TriggerTime;
var float RepeatTriggerTime;
// ^ NEW IN 1.60
var bool bSavedInitialCollision;
var bool bSavedInitialActive;
var R6Alarm m_pAlarm;
// ^ NEW IN 1.60
var bool m_bAlarm;
// ^ NEW IN 1.60
var class<Actor> ClassProximityType;
// ^ NEW IN 1.60
var float DamageThreshold;
// ^ NEW IN 1.60

// --- Functions ---
//
// When something untouches the trigger.
//
function UnTouch(Actor Other) {}
//
// Called when something touches the trigger.
//
function Touch(Actor Other) {}
function CheckTouchList() {}
function Timer() {}
function int TakeDamage(Pawn instigatedBy, int iKillValue, Vector vHitLocation, int iStunValue, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
function FindTriggerActor() {}
//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant(Actor Other) {}
// ^ NEW IN 1.60
function Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
function PreBeginPlay() {}
function PostBeginPlay() {}
function Reset() {}
//------------------------------------------------------------------
// ResetOriginalData
//
//------------------------------------------------------------------
simulated function ResetOriginalData() {}

state OtherTriggerTurnsOn
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state NormalTrigger
{
}

state OtherTriggerToggles
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state OtherTriggerTurnsOff
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

defaultproperties
{
}
