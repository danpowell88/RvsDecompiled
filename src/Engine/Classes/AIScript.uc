//=============================================================================
// AIScript - used by Level Designers to specify special AI scripts for pawns 
// placed in a level, and to change which type of AI controller to use for a pawn.
// AIScripts can be shared by one or many pawns. 
// Game specific subclasses of AIScript will have editable properties defining game specific behavior and AI
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIScript extends Keypoint
    native;

// --- Variables ---
var AIMarker myMarker;
var class<AIController> ControllerClass;
// ^ NEW IN 1.60
var bool bLoggingEnabled;
// if true, put an associated path in the navigation network
var bool bNavigate;

// --- Functions ---
function SpawnControllerFor(Pawn P) {}
function TakeOver(Pawn P) {}
function Actor GetMoveTarget() {}
// ^ NEW IN 1.60

defaultproperties
{
}
