//=============================================================================
// The moving brush class.
// This is a built-in Unreal class and it shouldn't be modified.
// Note that movers by default have bNoDelete==true.  This makes movers and their default properties
// remain on the client side.  If a mover subclass has bNoDelete=false, then its default properties must
// be replicated
//=============================================================================
class Mover extends Actor
    native
    nativereplication;

// --- Enums ---
enum EBumpType
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EMoverEncroachType
{
    // enum values not recoverable from binary — see 1.56 source
};
enum EMoverGlideType
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var byte KeyNum;
// ^ NEW IN 1.60
//-----------------------------------------------------------------------------
// Mover state.
// Who we were triggered by.
var Actor SavedTrigger;
var EBumpType BumpType;
// ^ NEW IN 1.60
var Mover Follower;
var float MoveTime;
// ^ NEW IN 1.60
var bool bDelaying;
// ^ NEW IN 1.60
// number of times triggered ( count down to untrigger )
var int numTriggerEvents;
var float DelayTime;
// ^ NEW IN 1.60
// for having multiple movers return together
var Mover Leader;
// mover is in closed position, and no longer moving
var bool bClosed;
var bool bOpening;
// ^ NEW IN 1.60
//-----------------------------------------------------------------------------
// Keyframe numbers.
// Previous keyframe.
var byte PrevKeyNum;
var /* replicated */ Vector RealPosition;
var const byte NumKeys;
// ^ NEW IN 1.60
// Interpolating position, 0.0-1.0.
var float PhysAlpha;
var name ReturnGroup;
// ^ NEW IN 1.60
var bool bSlave;
// ^ NEW IN 1.60
// AI related
var NavigationPoint myMarker;
var bool bClientPause;
var Rotator OldRot;
// ^ NEW IN 1.60
var array<array> AntiPortals;
// ^ NEW IN 1.60
var int StepDirection;
// ^ NEW IN 1.60
var int ClientUpdate;
var /* replicated */ Rotator RealRotation;
var bool bTriggerOnceOnly;
// ^ NEW IN 1.60
var EMoverEncroachType MoverEncroachType;
// ^ NEW IN 1.60
var float StayOpenTime;
// ^ NEW IN 1.60
var bool bDamageTriggered;
// ^ NEW IN 1.60
var Sound MoveAmbientSound;
// ^ NEW IN 1.60
//-----------------------------------------------------------------------------
// Internal.
var Vector KeyPos[24];
var Rotator KeyRot[24];
var Vector OldPos;
// ^ NEW IN 1.60
var /* replicated */ Vector SimInterpolate;
var name AntiPortalTag;
// ^ NEW IN 1.60
// Interpolation rate per second.
var float PhysRate;
var Rotator BaseRot;
// ^ NEW IN 1.60
var Vector BasePos;
// ^ NEW IN 1.60
var bool bOscillatingLoop;
// ^ NEW IN 1.60
var name OpeningEvent;
// ^ NEW IN 1.60
var Sound LoopSound;
// ^ NEW IN 1.60
var Sound OpeningSound;
// ^ NEW IN 1.60
var name BumpEvent;
// ^ NEW IN 1.60
var name PlayerBumpEvent;
// ^ NEW IN 1.60
var bool bIsLeader;
// ^ NEW IN 1.60
var /* replicated */ int SimOldRotRoll;
var /* replicated */ int SimOldRotYaw;
// ^ NEW IN 1.60
var /* replicated */ int SimOldRotPitch;
// ^ NEW IN 1.60
// for client side replication
var /* replicated */ Vector SimOldPos;
var name LoopEvent;
// ^ NEW IN 1.60
var name ClosedEvent;
// ^ NEW IN 1.60
var name ClosingEvent;
// ^ NEW IN 1.60
var name OpenedEvent;
// ^ NEW IN 1.60
var Sound ClosedSound;
// ^ NEW IN 1.60
var Sound ClosingSound;
// ^ NEW IN 1.60
var Sound OpenedSound;
// ^ NEW IN 1.60
var float DamageThreshold;
// ^ NEW IN 1.60
var bool bUseTriggered;
// ^ NEW IN 1.60
var bool bToggleDirection;
// ^ NEW IN 1.60
var float OtherTime;
// ^ NEW IN 1.60
var EMoverGlideType MoverGlideType;
// ^ NEW IN 1.60
var const byte WorldRaytraceKey;
// ^ NEW IN 1.60
var const byte BrushRaytraceKey;
// ^ NEW IN 1.60
var int EncroachDamage;
// ^ NEW IN 1.60
var bool bDynamicLightMover;
// ^ NEW IN 1.60
var bool bUseShortestRotation;
// ^ NEW IN 1.60
var Vector OldPrePivot;
// ^ NEW IN 1.60
var Vector SavedPos;
var Rotator SavedRot;
var bool bPlayerOnly;
var bool bNoAIRelevance;
// ^ NEW IN 1.60

// --- Functions ---
// function ? TakeDamage(...); // REMOVED IN 1.60
final simulated function InterpolateTo(byte NewKeyNum, float Seconds) {}
// Interpolation ended.
simulated event KeyFrameReached() {}
// When bumped by player.
function Bump(Actor Other) {}
function BaseStarted() {}
// ^ NEW IN 1.60
function BaseFinished() {}
// ^ NEW IN 1.60
// When mover enters gameplay.
simulated function BeginPlay() {}
final function SetKeyframe(byte NewKeyNum, Vector NewLocation, Rotator NewRotation) {}
function int R6TakeDamage(Pawn instigatedBy, int iKillValue, int iStunValue, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup) {}
// ^ NEW IN 1.60
// Handle when the mover finishes closing.
function FinishedClosing() {}
// Notify AI that mover finished movement
function FinishNotify() {}
// Return true to abort, false to continue.
function bool EncroachingOn(Actor Other) {}
// ^ NEW IN 1.60
// Immediately after mover enters gameplay.
function PostBeginPlay() {}
simulated function StartInterpolation() {}
simulated function Timer() {}
// Handle when the mover finishes opening.
function FinishedOpening() {}
// Open the mover.
function DoOpen() {}
// Close the mover.
function DoClose() {}
function MakeGroupStop() {}
function MakeGroupReturn() {}
function MoverLooped() {}
// ^ NEW IN 1.60

state OpenTimedMover
{
    function DisableTrigger() {}
    function EnableTrigger() {}
    function bool ShouldReTrigger() {}
// ^ NEW IN 1.60
}

state TriggerPound
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function UnTrigger(Actor Other, Pawn EventInstigator) {}
    function BeginState() {}
}

state TriggerControl
{
    function UnTrigger(Actor Other, Pawn EventInstigator) {}
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function BeginState() {}
}

state TriggerToggle
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
}

state LoopMove
{
    event UnTrigger(Actor Other, Pawn EventInstigator) {}
    event Trigger(Actor Other, Pawn EventInstigator) {}
// Interpolation ended.
    event KeyFrameReached() {}
    function BeginState() {}
}

state TriggerOpenTimed
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function DisableTrigger() {}
    function EnableTrigger() {}
}

state RotatingMover
{
    simulated function BaseFinished() {}
// ^ NEW IN 1.60
    simulated function BaseStarted() {}
// ^ NEW IN 1.60
    simulated function BeginState() {}
}

state StandOpenTimed
{
    function Attach(Actor Other) {}
    function bool ShouldReTrigger() {}
// ^ NEW IN 1.60
    function bool CanTrigger(Actor Other) {}
// ^ NEW IN 1.60
    function DisableTrigger() {}
    function EnableTrigger() {}
}

state BumpOpenTimed
{
// When bumped by player.
    function Bump(Actor Other) {}
    function DisableTrigger() {}
    function EnableTrigger() {}
}

state BumpButton
{
// When bumped by player.
    function Bump(Actor Other) {}
    function BeginEvent() {}
    function EndEvent() {}
}

state ConstantLoop
{
// Interpolation ended.
    event KeyFrameReached() {}
    function BeginState() {}
}

state LeadInOutLooper
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
// Interpolation ended.
    event KeyFrameReached() {}
    function BeginState() {}
}

state LeadInOutLooping
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
// Interpolation ended.
    event KeyFrameReached() {}
}

defaultproperties
{
}
