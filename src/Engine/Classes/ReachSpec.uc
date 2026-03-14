//=============================================================================
// ReachSpec.
//
// A Reachspec describes the reachability requirements between two NavigationPoints
//
//=============================================================================
class ReachSpec extends Object
    native;

// --- Variables ---
// navigationpoint at start of this path
var const NavigationPoint Start;
var int Distance;
// navigationpoint at endpoint of this path (next waypoint or goal)
var const NavigationPoint End;
var int CollisionRadius;
var int CollisionHeight;
// see EReachSpecFlags definition in UnPath.h
var int reachFlags;
var int MaxLandingVelocity;
var byte bPruned;
var const bool bForced;

defaultproperties
{
}
