//=============================================================================
// WarpZoneInfo. For making disjoint spaces appear as if they were connected;
// supports both in-level warp zones and cross-level warp zones.
//=============================================================================
class WarpZoneInfo extends ZoneInfo
    native;

// --- Variables ---
var int numDestinations;
var /* replicated */ string OtherSideURL;
// ^ NEW IN 1.60
var transient /* replicated */ WarpZoneInfo OtherSideActor;
var string Destinations[8];
// ^ NEW IN 1.60
var transient Object OtherSideLevel;
var /* replicated */ name ThisTag;
// ^ NEW IN 1.60
var bool bNoTeleFrag;
// ^ NEW IN 1.60
var const Coords WarpCoords;
var const int iWarpZone;

// --- Functions ---
final native function UnWarp(out Vector Loc, out Vector Vel, out Rotator R) {}
// ^ NEW IN 1.60
final native function Warp(out Vector Loc, out Vector Vel, out Rotator R) {}
// ^ NEW IN 1.60
event ActorLeaving(Actor Other) {}
function Trigger(Pawn EventInstigator, Actor Other) {}
// When an actor enters this warp zone.
simulated function ActorEntered(Actor Other) {}
// Set up this warp zone's destination.
simulated event ForceGenerate() {}
// Set up this warp zone's destination.
simulated event Generate() {}
function PreBeginPlay() {}

state DelayedWarp
{
    function Tick(float DeltaTime) {}
}

defaultproperties
{
}
