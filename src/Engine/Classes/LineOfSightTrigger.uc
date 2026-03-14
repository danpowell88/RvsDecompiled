//=============================================================================
// LineOfSightTrigger
// triggers its event when player looks at it from close enough
// ONLY WORKS IN SINGLE PLAYER (or for the local client on a listen server)
// You could implement a multiplayer version using a tick function and PlayerCanSeeMe(),
// but that would have more performance cost
//=============================================================================
class LineOfSightTrigger extends Triggers
    native;

// --- Variables ---
var name SeenActorTag;
// ^ NEW IN 1.60
var bool bEnabled;
// ^ NEW IN 1.60
var bool bTriggered;
var Actor SeenActor;
var int MaxViewAngle;
// ^ NEW IN 1.60
// how directly player must be looking at SeenActor - 1.0 = straight on, 0.75 = barely on screen
var float RequiredViewDir;
var float MaxViewDist;
// ^ NEW IN 1.60
var float OldTickTime;

// --- Functions ---
event PlayerSeesMe(PlayerController P) {}
function PostBeginPlay() {}
function Trigger(Actor Other, Pawn EventInstigator) {}

defaultproperties
{
}
