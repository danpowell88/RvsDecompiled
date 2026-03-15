//=============================================================================
// ReachSpec - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// ReachSpec.
//
// A Reachspec describes the reachability requirements between two NavigationPoints
//
//=============================================================================
class ReachSpec extends Object
    native;

var byte bPruned;
var int Distance;
var int CollisionRadius;
var int CollisionHeight;
var int reachFlags;  // see EReachSpecFlags definition in UnPath.h
var int MaxLandingVelocity;
var const bool bForced;
var const NavigationPoint Start;  // navigationpoint at start of this path
var const NavigationPoint End;  // navigationpoint at endpoint of this path (next waypoint or goal)

