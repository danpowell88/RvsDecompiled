//=============================================================================
// WarpZoneMarker.
//=============================================================================
class WarpZoneMarker extends SmallNavigationPoint
    native;

// --- Variables ---
var WarpZoneInfo markedWarpZone;
// AI related
//used to tell AI how to trigger me
var Actor TriggerActor;
var Actor TriggerActor2;

// --- Functions ---
function Actor SpecialHandling(Pawn Other) {}
// ^ NEW IN 1.60
function FindTriggerActor() {}
function PostBeginPlay() {}

defaultproperties
{
}
