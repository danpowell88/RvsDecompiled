//=============================================================================
// AIController, the base class of AI.
//
// Controllers are non-physical actors that can be attached to a pawn to control 
// its actions.  AIControllers implement the artificial intelligence for the pawns they control.  
//
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIController extends Controller
    native;

// --- Variables ---
// skill, scaled by game difficulty (add difficulty to this value)
var float Skill;
var AIScript MyScript;
// tells navigation code that pawn is hunting another pawn,
var bool bHunting;
										//	so fall back to finding a path to a visible pathnode if none
										//	are reachable
// auto-adjust around corners, with no hitwall notification for controller or pawn
var bool bAdjustFromWalls;

// --- Functions ---
// function ? HearPickup(...); // REMOVED IN 1.60
function Trigger(Pawn EventInstigator, Actor Other) {}
function bool TriggerScript(Pawn EventInstigator, Actor Other) {}
// ^ NEW IN 1.60
function WaitForMover(Mover M) {}
function int GetFacingDirection() {}
// ^ NEW IN 1.60
function UnderLift(Mover M) {}
function DisplayDebug(Canvas Canvas, out float YPos, out float YL) {}
// AdjustView() called if Controller's pawn is viewtarget of a player
function AdjustView(float DeltaTime) {}
final native latent function WaitToSeeEnemy() {}
// ^ NEW IN 1.60
event PreBeginPlay() {}
function Reset() {}
function SetOrders(name NewOrders, Controller OrderGiver) {}
function Actor GetOrderObject() {}
// ^ NEW IN 1.60
function name GetOrders() {}
// ^ NEW IN 1.60
event PrepareForMove(NavigationPoint Goal, ReachSpec Path) {}
function MoverFinished() {}

defaultproperties
{
}
