// ScriptedController
// AI controller which is controlling the pawn through a scripted sequence specified by 
// an AIScript
class ScriptedController extends AIController;

// --- Variables ---
var LatentScriptedAction CurrentAction;
var int ActionNum;
var ScriptedSequence SequenceScript;
var Action_PLAYANIM CurrentAnimation;
var Actor ScriptedFocus;
// controller which will get this pawn after scripted sequence is complete
var Controller PendingController;
var PlayerController MyPlayerController;
var bool bBroken;
var bool bUseScriptFacing;
var bool bPendingShoot;
var bool bShootSpray;
var int AnimsRemaining;
var bool bShootTarget;
var int IterationSectionStart;
var int IterationCounter;
// FIXME - this is currently a hack
var bool bFakeShot;
var int NumShots;
var name FiringMode;

// --- Functions ---
function SetNewScript(ScriptedSequence NewScript) {}
function DestroyPawn() {}
function ClearAnimation() {}
function LeaveScripting() {}
function TakeControlOf(Pawn aPawn) {}
function bool CheckIfNearPlayer(float Distance) {}
// ^ NEW IN 1.60
function int SetFireYaw(int FireYaw) {}
// ^ NEW IN 1.60
function SetEnemyReaction(int AlertnessLevel) {}
function Pawn GetMyPlayer() {}
// ^ NEW IN 1.60
function Pawn GetInstigator() {}
// ^ NEW IN 1.60
function Actor GetSoundSource() {}
// ^ NEW IN 1.60

state Scripting
{
    function Trigger(Actor Other, Pawn EventInstigator) {}
    function LeaveScripting() {}
    function AnimEnd(int Channel) {}
    function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
    function SetMoveTarget() {}
    function Tick(float DeltaTime) {}
    function UnPossess() {}
    function InitForNextAction() {}
    function Timer() {}
    function CompleteAction() {}
    function AbortScript() {}
    function MayShootAtEnemy() {}
    function MayShootTarget() {}
    function EndState() {}
}

state Broken
{
}

defaultproperties
{
}
